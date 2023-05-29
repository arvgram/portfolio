import java.util.ArrayList;
public class BankTest {

	public static void main(String[] args) {
		Bank bank = new Bank();
		bank.addAccount("Arvid Gramer", 980814);
		bank.addAccount("Simon Danielsson", 990529);
		bank.addAccount("Lovisa Ericsson", 979193);
		bank.addAccount("Björn Elwin", 959823);
		bank.addAccount("Arvid Gramer", 980814);
		bank.addAccount("Simon Danielsson", 990529);
		bank.addAccount("Lovisa Ericsson", 979193);
		bank.addAccount("Björn Elwin", 959823);		bank.addAccount("Simon Danielsson", 990529);
		bank.addAccount("Lovisa Ericsson", 979193);
		bank.addAccount("Björn Elwin", 959823);
		bank.addAccount("Lovisa Ericsson", 979193);
		bank.addAccount("Lovisa Ericsson", 979193);
		bank.addAccount("Lovisa Ericsson", 979193);

		ArrayList<BankAccount> sortTest = bank.getAllAccounts();
		ArrayList<Customer> findTest = bank.findByPartOfName("a");
		
		for (BankAccount acc : sortTest) {
			System.out.println(acc.toString());
		}
		for (Customer kund : findTest) {
			System.out.println(kund.toString());
		}
		
	}

}

