import java.util.ArrayList;
import java.util.Arrays;

public class Bank {
	ArrayList<BankAccount> bank;

	public Bank() {
		bank = new ArrayList<BankAccount>();
	}

	public int addAccount(String holderName, long idNr) {
		for (BankAccount acc : bank) {
			if (acc.getHolder().getIdNr() == idNr) {
				BankAccount acc1 = new BankAccount(acc.getHolder());
				addAlphabetic(acc1);
				return acc1.getAccNbr();
			}
		}
		BankAccount acc2 = new BankAccount(holderName, idNr);
		addAlphabetic(acc2);
		return acc2.getAccNbr();
	}

	public Customer findHolder(long idNr) {
		for (BankAccount acc : bank) {
			if (acc.getHolder().getIdNr() == idNr) {
				return acc.getHolder();
			}
		}
		return null;
	}

	public boolean removeAccount(int number) {
		for (BankAccount acc : bank) {
			if (acc.getAccNbr() == number) {
				return bank.remove(acc);
			}
		}
		return false;
	}

	public ArrayList<BankAccount> getAllAccounts() {
		return bank;
	}

	public ArrayList<BankAccount> altGetAllAccounts() {
		BankAccount[] sortVek = new BankAccount[bank.size()];
		for (BankAccount acc1 : bank) {
			int plats = 0;
			for (BankAccount acc2 : bank) {
				if (acc1.getHolder().getName().compareToIgnoreCase((acc2.getHolder().getName())) > 0) {
					plats++;
			}
			sortVek[plats] = acc1;
		}
		}
		return new ArrayList<BankAccount>(Arrays.asList(sortVek));
	}

	public BankAccount findByNumber(int accountNumber) {
		for (BankAccount acc : bank) {
			if (acc.getAccNbr() == accountNumber) {
				return acc;
			}
		}
		return null;
	}

	public ArrayList<BankAccount> findAccountsForHolder(long idNr) {
		ArrayList<BankAccount> konton = new ArrayList<BankAccount>();
		for (BankAccount acc : bank) {
			if (acc.getHolder().getIdNr() == idNr) {
				konton.add(acc);
			}
		}
		return konton;
	}

	private void addAlphabetic(BankAccount acc1) {
		int strlk = bank.size();
		int count = 0;
		if (strlk > 0) {
			for (BankAccount acc2 : bank) {
				if (acc1.getHolder().getName().compareToIgnoreCase(acc2.getHolder().getName()) < 0) {
					break;
				}
				count++;
			}
			if (count > strlk) {
				bank.add(acc1);
			} else {
				bank.add(count, acc1);
			}
		} else {
			bank.add(acc1);
		}
	}
	public ArrayList<Customer> findByPartOfName(String namePart){
		ArrayList<Customer> foundList = new ArrayList<Customer>();
		
		for (BankAccount acc : bank) {
			if(acc.getHolder().getName().toLowerCase().contains(namePart.toLowerCase())) {
				foundList.add(acc.getHolder());
			}
		} return foundList;
	}
}
