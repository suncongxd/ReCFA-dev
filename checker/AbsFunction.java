import java.util.ArrayList;
import java.util.List;


public class AbsFunction{
	private long hexOffset;
	private String name;
	List<InterSucc> iInterSuccList=new ArrayList<InterSucc>();
	List<InterSucc> dInterSuccList=new ArrayList<InterSucc>();
	List<Long> iJmpList=new ArrayList<Long>();
	List<Long> retList=new ArrayList<Long>();
	
	public AbsFunction(long hex, String name) {
		this.hexOffset=hex;
		this.name=name;
	}
	
	public String getName() {
		return this.name;
	}
	
	public void print() {
		System.out.printf("--------- %x: %s ---------------\n", this.hexOffset, this.name);
		for(InterSucc is: this.iInterSuccList) {
			System.out.printf("<%x;%x>\n", is.get_call_site(), is.get_ret_after());
		}
		for(InterSucc is: this.dInterSuccList) {
			System.out.printf("[%x;%x]\n", is.get_call_site(), is.get_ret_after());
		}
		for(Long j:this.iJmpList) {
			System.out.printf("%x, ",j);
		}
		for(Long j:this.retList) {
			System.out.printf("%x; ",j);
		}
		System.out.println("\n-----------------------------------");
	}
}