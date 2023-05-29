import java.util.Scanner;
import java.util.ArrayList;
import java.util.InputMismatchException;
import java.util.Random;

public class BankApplication {
	public static Bank b = new Bank();

	public static void main(String[] args) {
		runApplication();

	}

	private static void runApplication() {
		Scanner scan = new Scanner(System.in);
		int val = 0;
		runMenu();
		while (true){
		System.out.println("Ange val: ");
		try {val = scan.nextInt();}
		catch (InputMismatchException e) {
			System.out.println("Ogiltig input");
		}
		scan.nextLine();
		if (val == 2) {
			System.out.println("Fyll i (del av) namn:");
			String s;
			try { 
					s = scan.next();
					ArrayList<Customer> kunder = new ArrayList<Customer>();
					kunder = b.findByPartOfName(s);
					if (kunder.size() > 0) {
						for (Customer kund : kunder) {
							System.out.println(kund.toString());
						} 
					} else {
						System.out.println("Kund hittas inte");
					}
			} catch (InputMismatchException e) {
				System.out.println("Ogiltig input");
			}

		} else if (val == 1) {
				System.out.println("Ange innehavarens personnummer: ");
				try { long id = scan.nextLong();
				ArrayList<BankAccount> konton = new ArrayList<BankAccount>();
				konton = b.findAccountsForHolder(id);
					for (BankAccount acc : konton) {
						System.out.println(acc.toString());
			}
				}
				catch (InputMismatchException e) {
					System.out.println("Ogiltig input");
				}
		}
		else if (val == 3) {
			System.out.println("Ange konto: ");
			try {
			int konto = scan.nextInt();
				if(b.findByNumber(konto) != null) {
					System.out.println("Ange mängd pengar du önskar sätta in: ");
					double sum = scan.nextDouble();
					b.findByNumber(konto).deposit(sum);
					System.out.println("Pengar insatta." + b.findByNumber(konto).toString());
			} 	else {
				System.out.println("Konto hittas inte");
			} 
			} catch (InputMismatchException e) {
				System.out.println("Ogiltig input");
			}
		}
		else if (val == 4) {
			System.out.println("Ange konto");
			int konto = scan.nextInt();
			if(b.findByNumber(konto) != null) {
				System.out.println("Ange mängd pengar du önskar ta ut: ");
				double sum = scan.nextDouble();
				if(b.findByNumber(konto).getAmount() > sum) {
				b.findByNumber(konto).withdraw(sum);
				System.out.println("Pengar är överförda, nytt saldo för: " + b.findByNumber(konto).getAccNbr() + " är "+ b.findByNumber(konto).getAmount());
				} else {
					System.out.println("Medges ej");
				}
		} 	else {
			System.out.println("Konto hittas inte");
		}
			
		}
		else if (val == 5) {
			System.out.println("Ange konto du önskar överföra från: ");
			int subKont = scan.nextInt();
			if (b.findByNumber(subKont) != null) {
				System.out.println("Ange konto du önskar överföra till: ");
				int objKont = scan.nextInt();
				if (b.findByNumber(objKont) != null) {
					System.out.println("Ange belopp:");
					double sum = scan.nextDouble();
					if (b.findByNumber(subKont).getAmount() > sum) {
						b.findByNumber(subKont).withdraw(sum);
						b.findByNumber(objKont).deposit(sum);
						System.out.println("Pengarna är påväg, nytt saldo för: " + objKont + " är "+ b.findByNumber(objKont).getAmount());
						System.out.println("Nytt saldo för: " + subKont + " är "+ b.findByNumber(subKont).getAmount());
						}
					else {
						System.out.println("Saldo för konto " + subKont + " för lågt");
					}
				} 
				else {
					System.out.println("Konto hittas ej");
				}
			} 
			else {
				System.out.println("Konto hittas ej");
			}
		}
		else if (val == 6) {
			System.out.println("Ange kontoinnehavarens namn: ");
			String namn = scan.nextLine();
			System.out.println("Ange kontoinnehavarens personnummer: ");
			long idNr = scan.nextLong();
			int konto = b.addAccount(namn, idNr);
			System.out.println("Konto tillagt, nytt kontonummer: " + konto);
		}
		else if (val == 7) {
			System.out.println("Ange kontonummer för konto du önskar ta bort: ");
			int delAcc = scan.nextInt();
			if(b.removeAccount(delAcc)) {
				System.out.println("Konto " + delAcc + " borttaget." );
			}
			else {
				System.out.println("Konto hittas ej");
			}
		}
		else if (val == 8) {
			ArrayList <BankAccount> allAcc = new ArrayList <BankAccount>();
			allAcc = b.getAllAccounts();
			for (BankAccount bk : allAcc) {
				System.out.println(bk.toString());	
			}
			
		}
		else if (val == 9) {
			System.out.println("Systemet avslutas, hejdå!");
			System.exit(0);
			
		}
	}

}

	public static void runMenu() {
		System.out.println(
				"------------------------------------------ \n 1. Hitta konto(n) utifrån innehavare \n 2. Sök kontoinnehavare utifrån (del av) namn \n 3. Sätt in \n 4. Ta ut \n 5. Överföring \n 6. Skapa konto \n 7. Ta bort konto \n 8. Skriv ut samtliga konton \n 9. Avsluta ");
	}
}