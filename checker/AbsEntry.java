public class AbsEntry{
	long hexOffset;
	String name;
	
	public AbsEntry(String hexOffStr, String name) {
		this.hexOffset = Long.parseLong(hexOffStr, 16);
		this.name = name;
	}
	
	public void print() {
		System.out.printf("%x:%s\n", this.hexOffset, this.name);
	}
}