
public class BankAccount {
	private long holderId;
	private String holderName;
	private double amount;
	private static int accCount = 976;
	private int accountNumber;
	
	private Customer holder;

	public BankAccount(String holderName, long holderId) {
		holder = new Customer(holderName, holderId);
		this.holderName = holder.getName();
		this.holderId = holder.getIdNr();
		accountNumber = accCount;
		accCount ++;
		
	}

	public BankAccount(Customer holder) {
		holderName = holder.getName();
		holderId = holder.getIdNr();
		accountNumber = accCount;
		accCount ++;
		this.holder = holder;
	}

	public Customer getHolder() {
		return holder;
	}

	public int getAccNbr() {
		return accountNumber;
	}
	public double getAmount() {
	return amount;	
	}
	public void deposit(double amount) {
		this.amount = this.amount + amount;
	}
	public void withdraw(double amount) {
		this.amount = this.amount - amount;
	}
	public String toString() {
		String st = " Kontonummer: " + accountNumber + ", innehavare: " + holder.getName() + " (ID: " + holder.getIdNr() + ", kundnr: " + holder.getCustomerNr() + ")" + ", saldo: " + amount;
		return st;
	}

}
