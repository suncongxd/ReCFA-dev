import java.util.*;
import java.io.*;
import java.util.regex.*;

public class CFG {
    HashMap<String,Block> BlockStarJump=new HashMap<>();
    HashMap<String,Block> BlockendJump=new HashMap<>();
    HashMap<String,Set<String>> Function=new HashMap<>();
    HashMap<String,Set<String>> FunctionEndJump=new HashMap<>();
    public void ReadDyninst(String FilePath)
    {
        try {
            File filename = new File(FilePath);
            InputStreamReader reader=new InputStreamReader(new FileInputStream(filename));
            BufferedReader br = new BufferedReader(reader);
            String in = br.readLine();
            String blcok="\\[([0-9a-f]+),([0-9a-f]+)";
            String jump="([0-9a-f]+)\" -> \"([0-9a-f]+)";
            String FunctionStar="\"([0-9a-f]+)\" \\[label = \"";
            //String FunctionRet="\"([0-9a-f]+)(.*)(\\[color=green\\])";
            String FunctionRet="\"([0-9a-f]+)(.*)(\\[color=green\\])";
            String FunctionName="";
            while(in!=null)
            {
                Pattern r=Pattern.compile(blcok);
                Matcher m=r.matcher(in);
                if(m.find())
                {
                    Block insert=new Block();
                    insert.BlockStar=m.group(1);
                    insert.BlockEnd=m.group(2);
                    insert.Jump=new TreeSet();
                    BlockStarJump.put(m.group(1),insert);
                    BlockendJump.put(m.group(2),insert);
                }
                r=Pattern.compile(jump);
                m=r.matcher(in);
                if(m.find())
                {
                   Block a=BlockStarJump.get(m.group(1));
                   a.Jump.add(m.group(2));
                }
                r=Pattern.compile(FunctionStar);
                m=r.matcher(in);
                if(m.find())
                {
                    Set<String> RetSet=new TreeSet<>();
                    Function.put(m.group(1),RetSet);
                    FunctionName=m.group(1);
                }
                r=Pattern.compile(FunctionRet);
                m=r.matcher(in);
                if(m.find())
                {
                    Set<String> a=Function.get(FunctionName);
                    a.add(m.group(1));
                }
                in=br.readLine();
            }

        }
        catch(IOException e)
        {
            e.printStackTrace();
        }
        return;

    }
    public void ReadTypearmor(String FilePath)
    {
        try {
            File filename = new File(FilePath);
            InputStreamReader reader = new InputStreamReader(new FileInputStream(filename));
            BufferedReader br = new BufferedReader(reader);
            String in = br.readLine();
            String IndirectRel="Indirectstar0x([0-9a-f]+)(.*)Indrectend0x([0-9a-f]+)";
            while(in!=null) {
                Pattern r = Pattern.compile(IndirectRel);
                Matcher m = r.matcher(in);
                String Flag="";
                if (m.find()) {
                    Flag=m.group(1);
                    TreeSet<String> next = (BlockendJump.get(Flag)).Jump;
                    if (next.size() != 2)
                        throw new SetException("daxiaobufu");
                    next.remove("ffffffffffffffff");
                    String NextBlock="";
                    for (Iterator it = next.iterator(); it.hasNext(); )
                    {
                        NextBlock=(String)it.next();
                    }
                    next.remove(NextBlock);
                    next.add(m.group(3));
                    FunctionEndProcess(m.group(3));
                    if (!Function.containsKey(m.group(3)))
                    {
                        in=br.readLine();
                        continue;
                    }
                    Set<String> FunctionEnd=Function.get(m.group(3));
                    for(Iterator it=FunctionEnd.iterator();it.hasNext();)
                    {
                        String FunctionEndName=(String)it.next();
                        if(getFunctionEndJump().containsKey(FunctionEndName))
                        {
                            getFunctionEndJump().get(FunctionEndName).add(NextBlock);
                        }
                        else
                        {
                            Set<String> insert=new TreeSet<String>();
                            insert.add(NextBlock);
                            getFunctionEndJump().put(FunctionEndName,insert);
                        }
                    }
                    in=br.readLine();
                    while(in!=null)
                    {
                          m=r.matcher(in);
                          if(m.find())
                          {
                              if(!Flag.equals(m.group(1)))
                              {
                                  break;
                              }
                              next.add(m.group(3));
                              FunctionEndProcess(m.group(3));
                              FunctionEnd=Function.get(m.group(3));
                              if (!Function.containsKey(m.group(3)))
                              {
                                  in=br.readLine();
                                  continue;
                              }
                              for(Iterator it=FunctionEnd.iterator();it.hasNext();)
                              {
                                  String FunctionEndName=(String)it.next();
                                  if(getFunctionEndJump().containsKey(FunctionEndName))
                                  {
                                      getFunctionEndJump().get(FunctionEndName).add(NextBlock);
                                  }
                                  else
                                  {
                                      Set<String> insert=new TreeSet<String>();
                                      insert.add(NextBlock);
                                      getFunctionEndJump().put(FunctionEndName,insert);
                                  }
                              }
                          }
                          in=br.readLine();
                    }
                    continue;
                }
                in=br.readLine();
            }
            for(Iterator it = getFunctionEndJump().keySet().iterator(); it.hasNext();)
            {
                String s=(String)it.next();
                BlockStarJump.get(s).Jump.addAll(getFunctionEndJump().get(s));
            }
        }
        catch(IOException e)
        {
            e.printStackTrace();
        }
        catch (SetException e)
        {
            return;
        }
        return;
    }
    public void FunctionEndProcess(String Star) {
        if (!Function.containsKey(Star))
        {
            //System.out.println(Star+"dsfdfsfsf");
            return;
        }
        if(Function.get(Star).size()>0)
            return;
        else {
            Set<String> flag=new HashSet<>();
            dps(Star, Star,flag);
        }
    }
    public void dps(String s,String Star,Set<String> flag)
    {
        if(flag.contains(s))
            return;
        if(s.equals("ffffffffffffffff"))
            return;
        flag.add(s);
        Block a=BlockStarJump.get(s);
        if(a.Jump==null||a.Jump.size()==0) {
            Function.get(Star).add(a.BlockEnd);
            return;
        }
        Iterator it=a.Jump.iterator();
        while(it.hasNext())
        {
                String First=(String)(it.next());
                if(Function.containsKey(First)&&Function.get(First).size()>0) {
                    Function.get(Star).addAll(Function.get(First));
                    continue;
                }
                //System.out.println(First);
                dps(First,Star,flag);
        }


    }

    public HashMap<String, Set<String>> getFunctionEndJump() {
        return FunctionEndJump;
    }

    public void setFunctionEndJump(HashMap<String, Set<String>> functionEndJump) {
        FunctionEndJump = functionEndJump;
    }
}
