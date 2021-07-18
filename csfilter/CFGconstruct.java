//import org.omg.Messaging.SYNC_WITH_TRANSPORT;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.util.*;
import java.io.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class CFGconstruct {
	TreeSet<String> Call = new TreeSet<>();
	TreeSet<String> Jump = new TreeSet<>();
	TreeSet<String> Ret = new TreeSet<>();
	HashMap<String, Set<String>> Backup = new HashMap<>();
	HashSet<String> P = new HashSet<String>();
	HashSet<String> PltSet = new HashSet<>();
	ConcurrentHashMap<String, HashMap<String, Set<String>>> Reduction = new ConcurrentHashMap<>();

	public void ReadAsm(String AsmFile, CFG cfg, String outPath) {
		String setret = "([0-9a-f]{6}) \\<(.*)longjmp\\@plt\\>";
		String setcall = "([0-9a-f]{6}) \\<(.*)setjmp\\@plt\\>";
		String address = "([0-9a-f]{6}):";
		String setjmp = null;
		String longjmp = null;
		Set<String> setjmpSet = new HashSet();
		Set<String> IndirectCallJump = new HashSet<>();
		try {
			File filename = new File(AsmFile);
			InputStreamReader reader = new InputStreamReader(new FileInputStream(filename));
			BufferedReader br = new BufferedReader(reader);
			String in = br.readLine();
			String call = "([0-9a-f]+)(.*)(callq  \\*)";
			String jump = "([0-9a-f]+)(.*)(jmpq   \\*\\%)";
			String main = "([0-9a-f]{6}) \\<main\\>";
			String directCall = "([0-9a-f]+)(.*)(callq)";
			String ret = "([0-9a-f]{6})(.*)(retq)";
			String plt = "([0-9a-f]{6}) \\<(.*)\\>:";
			while (in != null) {
				Pattern r1 = Pattern.compile(plt);
				Matcher m1 = r1.matcher(in);
				if (m1.find()) {
					PltSet.add(m1.group(1));
					r1 = Pattern.compile(setret);
					m1 = r1.matcher(in);
					if (m1.find()) {
						longjmp = m1.group(1);
					}
					r1 = Pattern.compile(setcall);
					m1 = r1.matcher(in);
					if (m1.find())
						setjmp = m1.group(1);
				}
				if (in.equals("Disassembly of section .text:"))
					break;
				in = br.readLine();
			}
			Pattern r;
			Matcher m;
			while (in != null) {
				Pattern r1 = Pattern.compile(directCall);
				Matcher m1 = r1.matcher(in);
				if (m1.find()) {
					r1 = Pattern.compile(call);
					Matcher m2 = r1.matcher(in);
					if (!m2.find()) {
						if (cfg.BlockendJump.keySet().contains(m1.group(1))) {
							Set<String> a = new HashSet<>(PltSet);
							a.retainAll(cfg.BlockendJump.get(m1.group(1)).Jump);
							if (longjmp != null && cfg.BlockendJump.get(m1.group(1)).Jump.contains(longjmp))
								cfg.BlockendJump.get(m1.group(1)).Jump = null;
							else {
								if (setjmp != null && cfg.BlockendJump.get(m1.group(1)).Jump.contains(setjmp)) {
									in = br.readLine();
									r1 = Pattern.compile(address);
									m2 = r1.matcher(in);
									if (m2.find())
										setjmpSet.add(m2.group(1));
									else {
										System.out.println("fail");
									}
									continue;
								}
								if (a.size() == 0 && judgeplt(in)) // 判断隐形plt文件
									Call.add(cfg.BlockendJump.get(m1.group(1)).BlockStar);

							}
						}
						// System.out.println(m1.group(1) + "gfgfgdfgdf");
					} else {
						if (!cfg.BlockendJump.containsKey(m2.group(1)))
							System.out.println(m2.group(1) + "dyninst fail to solve");
						else {
							P.addAll(cfg.BlockendJump.get(m2.group(1)).Jump);
							cfg.BlockendJump.get(m2.group(1)).Jump = null;
							IndirectCallJump.add(m2.group(1));
						}
					}
					in = br.readLine();
					continue;
				}
				r = Pattern.compile(main);
				m = r.matcher(in);
				if (m.find()) {
					P.add(m.group(1));
					in = br.readLine();
					continue;
				}
				r = Pattern.compile(ret);
				m = r.matcher(in);
				if (m.find()) {
					if (cfg.BlockendJump.keySet().contains(m.group(1))) {
						Ret.add(cfg.BlockendJump.get(m.group(1)).BlockStar);
						P.add(cfg.BlockendJump.get(m.group(1)).BlockStar);
					}
					// System.out.println(m.group(1)+"retretret");
				}
				r = Pattern.compile(jump);
				m = r.matcher(in);
				if (m.find()) {
					P.addAll(cfg.BlockendJump.get(m.group(1)).Jump);
					cfg.BlockendJump.get(m.group(1)).Jump = null;
					IndirectCallJump.add(m.group(1));
				}
				in = br.readLine();
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
		for (Iterator it = Call.iterator(); it.hasNext();) {
			String s = (String) it.next();
			Backup.put(s, cfg.BlockStarJump.get(s).Jump);
			P.addAll(cfg.BlockStarJump.get(s).Jump);
			cfg.BlockStarJump.get(s).Jump = null;
		}
		for (Iterator it = Ret.iterator(); it.hasNext();) {
			String s = (String) it.next();
			Backup.put(s, cfg.BlockStarJump.get(s).Jump);
			P.addAll(cfg.BlockStarJump.get(s).Jump);
			cfg.BlockStarJump.get(s).Jump = null;
		}
		//System.out.println(setjmpSet);
		P.addAll(cfg.Function.keySet());
		P.addAll(setjmpSet);
		// System.out.println(P.size());
		System.out.println("Num of Direct Calls: " + Call.size());
		// System.out.println(Call);
		// System.exit(0);
		construct(cfg);
		CallRet callRet = new CallRet();
		callRet.ReadFile(AsmFile);
		Set<String> out = new HashSet<>();
		Set<String> in = new HashSet<>();
		// Map<String,Set<String>> re=Reduction.get("59c252");
		// for(Iterator it=re.keySet().iterator();it.hasNext();)
		// System.out.println(it.next()+"weiweiwei");
		for (Iterator it = P.iterator(); it.hasNext();) {
			String a = (String) it.next();
			Set<String> b = Reduction.get(a).keySet();
			// b.retainAll(new HashSet<>(callRet.CollectionCall));
			/*
			 * if(b.size()>=2) { Set<String> Insert=new HashSet<>(); Map<String,String>
			 * before=new HashMap<>(); //key是call跳转地址，value for(Iterator
			 * it1=b.iterator();it1.hasNext();) { String callAdress=(String) it1.next();
			 * //调用地址 if(before.keySet().contains(callRet.CallTarget.get(callAdress))) {
			 * Insert.add(callAdress);
			 * //System.out.println(callAdress+" "+callRet.CallTarget.get(callAdress)+" "
			 * +callRet.CallTarget.get(before.get(callRet.CallTarget.get(callAdress))));
			 * Insert.add(before.get(callRet.CallTarget.get(callAdress)));
			 * //System.out.println(before.get(callRet.CallTarget.get(callAdress))); } else
			 * before.put(callRet.CallTarget.get(callAdress),callAdress); } }
			 */
			// b.retainAll(callRet.CallTarget.keySet());
			if (b.size() <= 1) {
				b.retainAll(callRet.CallTarget.keySet());
				out.addAll(b);
			} else
				in.addAll(b);
		}
		// for(Iterator it=out.iterator();it.hasNext();)
		// System.out.println(it.next());
		out.removeAll(in);
		out.removeAll(IndirectCallJump);
		/*
		 * for(Iterator it=setjmpSet.iterator();it.hasNext();) { String
		 * a=(String)it.next(); Set<String> b=Reduction.get(a).keySet();
		 * out.removeAll(b); }
		 */
		System.out.println("Num of Filtered DCalls: " + out.size());
		/*
		 * for(Iterator it=P.iterator();it.hasNext();) { String a=(String)it.next();
		 * Set<String> b=Reduction.get(a).keySet(); Set<String> c=new HashSet<>(b);
		 * c.retainAll(out); if(c.size()>0) { System.out.println(a+" "+b); } }
		 */
		PrintWriter pw=null;
		try {
			pw = new PrintWriter((new FileWriter(outPath)));
			for (Iterator it = out.iterator(); it.hasNext();) {
				//System.out.println(it.next());
				pw.println(it.next());
			}
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			if(pw!=null)
				pw.close();
		}
		return;
	}

	public void construct(CFG cfg) {
		/*
		 * long startTime=System.currentTimeMillis(); for(Iterator
		 * it=P.iterator();it.hasNext();) { String p = (String) it.next(); process(p,
		 * cfg); }
		 */
		ExecutorService service = Executors.newFixedThreadPool(5);
		Iterator it = P.iterator();
		String lock = "";
		CountDownLatch count = new CountDownLatch(P.size());
		long startTime = System.currentTimeMillis();
		for (; it.hasNext();) {
			String p = (String) it.next();
			service.execute(new Runnable() {
				@Override
				public void run() {
					process(p, cfg);
					count.countDown();
				}
			});
		}
		try {
			count.await();
		} catch (InterruptedException e) {
			System.out.println("闭锁处失败");
			System.exit(-1);
		}
		service.shutdown();
		long endTime = System.currentTimeMillis();
		// System.out.println(i+"ddddddddddddddddddddddddddddddddddd");
		System.out.println("Execution time:  " + (endTime - startTime) + "ms" + P.size() + " " + j);
	}

	public void process(String pHead, CFG cfg) {
		HashSet<String> flag = new HashSet<>();
		HashSet<String> TailSet = new HashSet<>();
		if (!Reduction.keySet().contains(pHead)) {
			dps(pHead, cfg, flag, TailSet);
			HashMap<String, Set<String>> Insert = new HashMap<>();
			for (Iterator it = TailSet.iterator(); it.hasNext();) {
				String s = (String) it.next();
				Insert.put(cfg.BlockStarJump.get(s).BlockEnd, Backup.get(s));
			}
			// synchronized (this) {
			Reduction.put(pHead, Insert);
			// }

		} else
			return;
	}

	volatile int i = 0, j = 0;

	// Set<String> sb=new HashSet<>();
	public void dps(String pHead, CFG cfg, HashSet<String> flag, HashSet<String> TailSet) {
		java.util.Queue<String> sto = new java.util.LinkedList<String>();
		sto.offer(pHead);
		// flag.add(pHead);
		while (!sto.isEmpty()) {
			String str = sto.poll();
			// System.out.println(str+" "+i++);
			if (flag.contains(str))
				continue;
			synchronized (this) {
				i++;
			}
			if (str.equals("ffffffffffffffff")) {
				flag.add(str);
				continue;
			}
			if (!cfg.BlockStarJump.containsKey(str)) {
				flag.add(str);
				continue;
			}
			TreeSet<String> a = cfg.BlockStarJump.get(str).Jump;
			if (a == null || a.size() == 0) {
				TailSet.add(str);
				flag.add(str);
				continue;
			}
			flag.add(str);
			for (Iterator it = a.iterator(); it.hasNext();) {
				String test = (String) it.next();
				if (flag.contains(test))
					continue;
				else {
					if (a.size() > 1999998)
						System.out.println(Thread.currentThread().getName() + " " + j);
					sto.offer(test);
					// flag.add (test);
					// System.out.println(test+" "+(i++)+" "+Thread.currentThread().getName());
				}
			}
		}
//        if(flag.contains(pHead))
//            return;
//        flag.add(pHead);
//        if(pHead.equals("ffffffffffffffff"))
//            return;
//        System.out.println(pHead+" "+i++);
//        if(!cfg.BlockStarJump.containsKey(pHead))
//            return;
//        TreeSet<String> a=cfg.BlockStarJump.get(pHead).Jump;
//        if(a==null||a.size()==0)
//        {
//            TailSet.add(pHead);
//            return;
//        }
//        for(Iterator it=a.iterator();it.hasNext();)
//        {
//          dps((String)it.next(),cfg,flag,TailSet);
//        }
	}

	boolean judgeplt(String in) {

		String pltcall = "([0-9a-f]+)(.*)(callq  .*\\@)";
		Pattern r = Pattern.compile(pltcall);
		Matcher m = r.matcher(in);
		if (!m.find())
			return true;// 判断跳转不为plt时
		else
			return false;
	}
}
