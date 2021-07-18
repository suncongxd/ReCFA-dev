import java.util.*;

public class Filter {
	public static void main(String[] args) {
		if (args.length != 3) {
			System.out.println("Usage: csfilter.jar [dot-file-path] [asm-file-path] [filterred call-sites output path]");
			return;
		}
		CFG cfg = new CFG();
		cfg.ReadDyninst(args[0]);
//		Scanner input = new Scanner(System.in);
//		System.out.println("输入dyninst文件");
		//String FilePath = input.nextLine();
		//String DyninstPath="/home/ly/workspace/indirectjump/sourcecode/test/zuoye/AmyZhang319-resilientremoteattestation-2a9089600d1b/llvm-10/O0/hmmer_base.llvm_O0.dot";
		//String DyninstPath="/home/ly/workspace/indirectjump/sourcecode/test/zuoye/AmyZhang319-resilientremoteattestation-2a9089600d1b/1月19日_修改格式的spec各编译等级/O0/new_gcc/hmmer_base.cfa.dot";
		//String TypeArmor="/home/ly/software/idea-IC-201.8743.12/hello/send/binfo.403.gcc_gcc";
		
		// System.out.println("here1");
		// cfg.ReadTypearmor(TypeArmor);
		// System.out.println(cfg.BlockStarJump.get("417a33").Jump.size());
		// System.out.println(cfg.Function.get("46444e"));
		// System.out.println(cfg.BlockStarJump.get("421f9a").Jump.contains("4178a7"));
		CFGconstruct cfgconstruct = new CFGconstruct();
		//System.out.println("输入汇编文件");
		//FilePath = input.nextLine();
		cfgconstruct.ReadAsm(args[1], cfg, args[2]);
		// cfgconstruct.ReadAsm("/home/ly/workspace/indirectjump/sourcecode/test/zuoye/AmyZhang319-resilientremoteattestation-2a9089600d1b/1月19日_修改格式的spec各编译等级/O0/new_gcc/hmmer_base.cfa_huibian.txt",cfg);
		// cfgconstruct.ReadAsm("/home/ly/workspace/indirectjump/sourcecode/test/zuoye/AmyZhang319-resilientremoteattestation-2a9089600d1b/llvm-10/O0/hmmer_base.huibian.txt",cfg);
		// System.out.println(cfgconstruct.Reduction.get("468652").keySet().contains("45ab8b"));
		// CFG cfg1=new CFG();
		// cfg1.ReadDyninst(DyninstPath);
		// cfg1.ReadTypearmor(TypeArmor);
		// test test=new test();
		// test.verify(cfg1,cfgconstruct);
	}
}
