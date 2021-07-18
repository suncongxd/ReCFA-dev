import java.util.*;
import java.io.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class CallRet {
	public HashSet<String> PersonlFun = new HashSet<>();
	HashSet<String> CollectionCall = new HashSet<>();
	HashMap<String, String> CallTarget = new HashMap<>();

	public void ReadFile(String FilePath) {
		Scanner input = new Scanner(System.in);
		// System.out.println("请输入反汇编文件");
		// String FilePath = input.next();
		// ReadFileFirst(FilePath);
		HashMap<String, Set<String>> HeadCall = new HashMap<>();
		HashMap<String, String> CallNum = null;
		HashSet<String> Sto = null;
		try {
			File filename = new File(FilePath);
			InputStreamReader reader = new InputStreamReader(new FileInputStream(filename));
			BufferedReader br = new BufferedReader(reader);
			String in = br.readLine();
			String call = "([0-9a-f]+)(.*)(callq  )([0-9a-f]+)";
			String start = "0000000000([0-9a-f]+)";
			Pattern r, r1;
			Matcher m, m1;
			r = Pattern.compile(call);
			r1 = Pattern.compile(start);
			String Head = null;
			int count = 0;
			while (in != null) {
				m = r1.matcher(in);
				if (m.find()) {
					CallNum = new HashMap<>();
					Sto = new HashSet<>();
					HeadCall.put(m.group(1), Sto);
					Head = m.group(1);
					// System.out.println(m.group(1)+"45445454545454");
					in = br.readLine();
					continue;
				}
				m = r.matcher(in);
				// if (m.find() && PersonlFun.contains(m.group(4))) {
				if (m.find()) {
					CallTarget.put(m.group(1), m.group(4));
					if (CallNum.keySet().contains(m.group(4))) {
						CollectionCall.add(CallNum.get(m.group(4)));
						CollectionCall.add(m.group(1));
						Sto.add(m.group(1));
					} else {
						CallNum.put(m.group(4), m.group(1));
					}
				}
				in = br.readLine();
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
		//System.out.println(CollectionCall.size());
		// for (Iterator it = CollectionCall.iterator(); it.hasNext(); ) {
		// System.out.println(it.next() + " ");
		// }
	}

	public void ReadFileFirst(String FilePath) {
		try {
			File filename = new File(FilePath);
			InputStreamReader reader = new InputStreamReader(new FileInputStream(filename));
			BufferedReader br = new BufferedReader(reader);
			String in = br.readLine();
			String start = "0000000000([0-9a-f]+)";
			Pattern r;
			Matcher m;
			r = Pattern.compile(start);
			while (in != null) {
				m = r.matcher(in);
				if (m.find()) {
					// System.out.println(m.group(1));
					PersonlFun.add(m.group(1));
				}
				in = br.readLine();
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
