
public class Customer {
	private String name;
	private long idNr;
	private static int customerCount = 100;
	private int cn;

	public Customer(String name, long idNr) {
		this.name = name;
		this.idNr = idNr;
		cn = customerCount;
		customerCount++;
	}
	public String getName() {
		return name;
	}
	public long getIdNr() {
		return idNr;
	}
	public int getCustomerNr() {
		return cn;
	}
	public String toString() {
		String st = "Namn: " + name + ", ID-nummer: " + idNr + ", kundnummer: " + cn;
		return st;
		
	}

}
