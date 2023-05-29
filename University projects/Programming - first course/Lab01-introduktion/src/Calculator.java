import java.util.Scanner;

public class Calculator {
	public static void main(String[] args) {
		System.out.println("Skriv två tal");
		Scanner scan = new Scanner(System.in);
		double nbr1 = scan.nextDouble();
		double nbr2 = scan.nextDouble();
		double sum = nbr1 + nbr2;
		double kvt = nbr1 / nbr2;
		double dfr = nbr1 - nbr2;
		double prd = nbr1 * nbr2;
		System.out.println("Summan av talen är " + sum + 
				"; Skillnaden mellan talen är " + dfr
				+ "; Kvoten av talen är " + kvt + "; Produkten av talen är " + prd);

	
	}
}
