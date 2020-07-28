public class InterSucc{
	private long call_site;
	private long ret_after;
	
	public InterSucc(long from, long to) {
		this.call_site=from;
		this.ret_after=to;
	}
	
	public long get_call_site() {
		return this.call_site;
	}
	
	public long get_ret_after() {
		return this.ret_after;
	}
}