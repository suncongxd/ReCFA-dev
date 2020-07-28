import java.io.*;
import java.util.regex.*;
import java.util.*;

public class Checker {
	private static final String funcNamePattern="([0-9a-fA-F]{16})\\s<([\\w_]+)>:";
	private static final String iCallPattern="\\s([0-9a-fA-F]+):\\s[\\w\\s]+callq[\\s]+\\*%[a-z]+";
	private static final String iJmpPattern="\\s([0-9a-fA-F]+):\\s[\\w\\s]+jmpq[\\s]+\\*%[a-z]+";
	private static final String wildPattern="\\s([0-9a-fA-F]+):\\s[\\w\\s%(),\\*\\(\\)%#<>]+";
	private static final String libCallPattern="\\s[0-9a-fA-F]+:\\s[\\w\\s]+callq[\\s]+[0-9a-fA-F]+\\s<[\\w]+@plt>";
	private static final String dynamicCallPattern="\\s[0-9a-fA-F]+:\\s[\\w\\s]+callq[\\s]+\\*(0x[0-9a-fA-F]+)*\\([\\w\\s%,]+\\)[\\w\\s#<>@.]*";
	private static final String dCallPattern="\\s([0-9a-fA-F]+):\\s[\\w\\s]+callq[\\s]+[0-9a-fA-F]+\\s<[\\w]+>";
	private static final String retPattern="\\s([0-9a-fA-F]+):\\sc3\\s+retq\\s*";
	
	private static final String []filtedFunctions= {
		"_start",
		" __libc_start_main",
		"__libc_init_first",
		"__libc_csu_init",
		"__libc_csu_fini",
		"_init",
		"__x86.get_pc_thunk.ax",
		"__x86.get_pc_thunk.bx",
		"__x86.get_pc_thunk.cx",
		"__x86.get_pc_thunk.dx",
		"__gmon_start__ ",
		"frame_dummy",
		"__do_global_dtors_aux",
		"__do_global_ctors_aux",
		"register_tm_clones",
		"deregister_tm_clones",
		"_exit",
		"__call_tls_dtors",
		"_fini",
		"__stat",
		"__fstat",
		"__plt_dispatcher",
		"__divsc3",
		"__mulsc3",
		"stat64",
		"fstat64",
		"lstat64",
		"fstatat64",
		"atexit",
		"_dl_relocate_static_pie"
	};
	
	private List<AbsEntry> entryList =new ArrayList<AbsEntry>();
	private List<AbsFunction> funList=new ArrayList<AbsFunction>();
	
	private Set<Long> dump_iCalls=new HashSet<Long>();
	private Set<Long> dump_callAfter=new HashSet<Long>();
	private Set<Long> dump_iJmps=new HashSet<Long>();
	private Set<Long> dump_rets=new HashSet<Long>();
	private Set<Long> instru_iCalls=new HashSet<Long>();
	private Set<Long> instru_iJmps=new HashSet<Long>();
	private Set<Long> instru_callAfter=new HashSet<Long>();
	private Set<Long> instru_rets=new HashSet<Long>();
	
	public void arrangeDumpSites() {
		for(AbsFunction af: funList) {
			for(InterSucc is: af.iInterSuccList) {
				this.dump_iCalls.add(is.get_call_site());
				this.dump_callAfter.add(is.get_ret_after());
			}
			for(InterSucc is: af.dInterSuccList) {
				this.dump_callAfter.add(is.get_ret_after());
			}
			this.dump_iJmps.addAll(af.iJmpList);
			this.dump_rets.addAll(af.retList);
		}
	}
	
	public void extractInstrumentationSites(String site_file_path) {
		File f=new File(site_file_path);
		if(!f.exists()){
			System.out.println("Wrong instrumentation site path.");
			return;
		}
		
		try{
			BufferedReader in=new BufferedReader(new InputStreamReader(new FileInputStream(f)));
			String s;
			while((s=in.readLine())!=null) {
				if(s.contains("Fail to build call-after point of")) {
					//objdump cannot decide non-returned call-after
					//these info from the instrumentation site file should be checked as well.
					long addr = Long.parseLong(s.substring(5,s.indexOf(":")), 16);
					this.instru_callAfter.add(addr);
					continue;
				}
				int pos;
				if((pos=s.indexOf("0x")) !=-1) {
					//System.out.println(s.substring(pos+2));
					long addr = Long.parseLong(s.substring(pos+2), 16);
					if(s.startsWith("IJMP"))
						this.instru_iJmps.add(addr);
					else if(s.startsWith("ICALL"))
						this.instru_iCalls.add(addr);
					else if(s.startsWith("RET"))
						this.instru_rets.add(addr);
					else if(s.startsWith("CALLAFTER")) {
						this.instru_callAfter.add(addr);
					}
				}
			}
			in.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	public void iJmpSanityCheck() {
		System.out.println("Sanity check for indirect jumps ...");
		if(this.dump_iJmps.containsAll( this.instru_iJmps) && this.instru_iJmps.containsAll(this.dump_iJmps)) {
			System.out.println("Valid.");
		} else {
			System.out.println("Invalid.");
			Set<Long> common=new HashSet<Long>(this.dump_iJmps);
			common.retainAll(this.instru_iJmps);
			
			Set<Long> diff=new HashSet<Long>(this.dump_iJmps);
			diff.removeAll(common);
			System.out.print("Instrumentation Sites miss: ");
			for(long l: diff) {
				System.out.printf("0x%x, ", l);
			}
			System.out.println();
			
			diff=new HashSet<Long>(this.instru_iJmps);
			diff.removeAll(common);
			System.out.print("Objdump misses: ");
			for(long l: diff) {
				System.out.printf("0x%x, ", l);
			}
			System.out.println();
		}
	}
	
	public void iCallSanityCheck() {
		System.out.println("Sanity check for indirect calls ...");
		if(this.dump_iCalls.containsAll(this.instru_iCalls) && this.instru_iCalls.containsAll(this.dump_iCalls)) {
			System.out.println("Valid.");
		} else {
			System.out.println("Invalid.");
			Set<Long> common=new HashSet<Long>(this.dump_iCalls);
			common.retainAll(this.instru_iCalls);
			
			Set<Long> diff=new HashSet<Long>(this.dump_iCalls);
			diff.removeAll(common);
			System.out.print("Instrumentation Sites miss: ");
			for(long l: diff) {
				System.out.printf("0x%x, ", l);
			}
			System.out.println();
			
			diff=new HashSet<Long>(this.instru_iCalls);
			diff.removeAll(common);
			System.out.print("Objdump misses: ");
			for(long l: diff) {
				System.out.printf("0x%x, ", l);
			}
			System.out.println();
		}
	}
	
	public void callAfterSanityCheck() {
		System.out.println("Sanity check for call-after points ...");
		if(this.dump_callAfter.containsAll(this.instru_callAfter) 
				&& this.instru_callAfter.containsAll(this.dump_callAfter)) {
			System.out.println("Valid.");
		} else {
			System.out.println("Invalid.");
			
			Set<Long> common=new HashSet<Long>(this.dump_callAfter);
			common.retainAll(this.instru_callAfter);
			
			Set<Long> diff=new HashSet<Long>(this.dump_callAfter);
			diff.removeAll(common);
			System.out.print("Instrumentation Sites miss: ");
			for(long l: diff) {
				System.out.printf("0x%x, ", l);
			}
			System.out.println();
			
			diff=new HashSet<Long>(this.instru_callAfter);
			diff.removeAll(common);
			System.out.print("Objdump misses: ");
			for(long l: diff) {
				System.out.printf("0x%x, ", l);
			}
			System.out.println();
		}
	}
	
	public void retSanityCheck() {
		System.out.println("Sanity check for returns ...");
		if(this.dump_rets.containsAll(this.instru_rets) && this.instru_rets.containsAll(this.dump_rets)) {
			System.out.println("Valid.");
		} else {
			System.out.println("Invalid.");
			
			Set<Long> common=new HashSet<Long>(this.dump_rets);
			common.retainAll(this.instru_rets);
			
			Set<Long> diff=new HashSet<Long>(this.dump_rets);
			diff.removeAll(common);
			System.out.print("Instrumentation Sites miss: ");
			for(long l: diff) {
				System.out.printf("0x%x, ", l);
			}
			System.out.println();
			
			diff=new HashSet<Long>(this.instru_rets);
			diff.removeAll(common);
			System.out.print("Objdump misses: ");
			for(long l: diff) {
				System.out.printf("0x%x, ", l);
			}
			System.out.println();
		}
	}
	
	public void SanityChecks() {
		this.iJmpSanityCheck();
		this.iCallSanityCheck();
		this.callAfterSanityCheck();
		this.retSanityCheck();
	}
	
	private boolean findInFilted(String funName) {
		for(String s:filtedFunctions) {
			if(s.equals(funName))
				return true;
		}
		return false;
	}
	
	private void shrinkFuncList() {
		Iterator<AbsFunction> it=this.funList.iterator();
		
		while(it.hasNext()) {
			AbsFunction af=it.next();
			if(findInFilted(af.getName())) {
				it.remove();
			}
		}
	}
	
	public void printEntryList() {
		for(AbsEntry af: entryList) {
			af.print();
		}
	}
	
	public void printFuncList() {
		for(AbsFunction af: this.funList) {
			af.print();
		}
	}
	
	public void generateFunctionList() {
		//int fromIdx=0;
		//boolean inFunc = false;
		AbsFunction af=null;
		for(int i=0;i< entryList.size(); i++) {
			AbsEntry ae=entryList.get(i);
			AbsEntry next=null;
			if(i<entryList.size()-1) {
				next=entryList.get(i+1);
			}
			if(!ae.name.equals("iCallInst") &&
				!ae.name.equals("iRetSite") &&
				!ae.name.equals("iJmpInst") &&
				!ae.name.equals("dCallInst") &&
				!ae.name.equals("dRetSite") &&
				!ae.name.equals("RET")) {
				if(af!=null) {
					this.funList.add(af);
				}
				af=new AbsFunction(ae.hexOffset, ae.name);
				continue;
			}
			if(ae.name.equals("iJmpInst") && af!=null) {
				af.iJmpList.add(ae.hexOffset);
				continue;
			}
			if(ae.name.equals("RET") && af!=null) {
				af.retList.add(ae.hexOffset);
				continue;
			}
			if(ae.name.equals("iCallInst") && af!=null) {
				af.iInterSuccList.add(new InterSucc(ae.hexOffset,next.hexOffset));
				continue;
			}
			if(ae.name.equals("dCallInst") && af!=null) {
				af.dInterSuccList.add(new InterSucc(ae.hexOffset, next.hexOffset));
				continue;
			}
		}
		this.funList.add(af);
		
		this.shrinkFuncList();
	}
	
	public void generateEntryList(String path) {
		File f=new File(path);
		if(!f.exists()){
			System.out.println("Wrong objdump output path.");
			return;
		}
		
		try{
			Pattern p1=Pattern.compile(funcNamePattern);
			Pattern p2=Pattern.compile(iCallPattern);
			Pattern p3=Pattern.compile(iJmpPattern);
			Pattern p4=Pattern.compile(wildPattern);
			Pattern p5=Pattern.compile(libCallPattern);
			Pattern p6=Pattern.compile(dynamicCallPattern);
			Pattern p7=Pattern.compile(dCallPattern);
			Pattern p8=Pattern.compile(retPattern);
			Matcher m1;
			Matcher m2;
			Matcher m3;
			Matcher m4;
			Matcher m5;
			Matcher m6;
			Matcher m7;
			Matcher m8;
			
			BufferedReader in=new BufferedReader(new InputStreamReader(new FileInputStream(f)));
			PrintStream out=new PrintStream(new FileOutputStream(path.concat(".summary")));
			
			String s;
			AbsEntry af;
			s=in.readLine();
			while(s!=null) {
Label:			m5=p5.matcher(s);
				if(m5.find()) {
					//for the calls like: callq  cb0 <__cxa_finalize@plt>
					//System.out.println("lib-call: "+ s);
					s=in.readLine();
					continue;
				}
				m6=p6.matcher(s);
				if(m6.find()) {
					//for the calls like: callq  *0x21b2f6(%rip)        # 21bfe0 <__libc_start_main@GLIBC_2.2.5>
					//System.out.println("dyn-call: "+ s);
					s=in.readLine();
					continue;
				}
				
				m1=p1.matcher(s);
				m2=p2.matcher(s);
				m3=p3.matcher(s);
				m7=p7.matcher(s);
				m8=p8.matcher(s);
				
				if(m1.find()) {
					af=new AbsEntry(m1.group(1), m1.group(2));
					this.entryList.add(af);
					out.printf("%x:%s\n",af.hexOffset,af.name);
					s=in.readLine();
					continue;
				}
				
				if(m8.find()) {
					af=new AbsEntry(m8.group(1), "RET");
					this.entryList.add(af);
					out.printf("%x:%s\n", af.hexOffset,af.name);
					s=in.readLine();
					continue;
				}
				if(m2.find()) {
					af = new AbsEntry(m2.group(1), "iCallInst");
					this.entryList.add(af);
					out.printf("%x:%s\n",af.hexOffset,af.name);
					
					s=in.readLine();
					m4=p4.matcher(s);
					if(m4.find()) {
						af = new AbsEntry(m4.group(1), "iRetSite");
						this.entryList.add(af);
						out.printf("%x:%s\n",af.hexOffset,af.name);
					}
					continue;
				}
				if(m7.find()) {
					af = new AbsEntry(m7.group(1), "dCallInst");
					this.entryList.add(af);
					out.printf("%x:%s\n",af.hexOffset,af.name);
					
					s=in.readLine();
					m4=p4.matcher(s);
					if(m4.find()) {
						af = new AbsEntry(m4.group(1), "dRetSite");
						this.entryList.add(af);
						out.printf("%x:%s\n",af.hexOffset,af.name);
					}
					continue;
				}

				if(m3.find()) {
					af = new AbsEntry(m3.group(1), "iJmpInst");
					this.entryList.add(af);
					out.printf("%x:%s\n", af.hexOffset, af.name);
					s=in.readLine();
					continue;
				}
				
				s=in.readLine();
			}
			in.close();
			out.close();
		} catch(IOException e){
			e.printStackTrace();
		}
	}

	
	public static void main(String[] args){
		if(args==null || args.length!=2){
			System.out.println("Usage: java -jar Checker.jar [path of objdump output] [path of site file]");
			return;
		}

		Checker checker=new Checker();

		checker.generateEntryList(args[0]);
		//checker.printEntryList();
		checker.generateFunctionList();
		//checker.printFuncList();
		checker.arrangeDumpSites();
		
		checker.extractInstrumentationSites(args[1]);
		checker.SanityChecks();
	}
}






