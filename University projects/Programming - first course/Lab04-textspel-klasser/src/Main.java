import java.util.Scanner;
import se.lth.cs.pt.timer.*;

public class Main {

	public static void main(String[] args) {
		Scanner scan = new Scanner(System.in);
		while (true) {
			Timer.delay(3500);
			System.out.println("Spela sten, sax, påse! \n Skriv 1 för sten, 2 för sax eller 3 för påse");
			SSP spel = new SSP();
			int hand = scan.nextInt();

			int svar = spel.handReturn(hand);
			if (hand == 1 && svar == 3) {
				System.out.println("Du gjorde sten, datorn gjorde påse. Du förlorade");
			} else if (hand == 1 && svar == 2) {
				System.out.println("Du gjorde sten, datorn gjorde sax. Du vann, grattis!");
			}
			if (hand == 2 && svar == 1) {
				System.out.println("Du gjorde sax, datorn gjorde sten. Du förlorade");

			} else if (hand == 2 && svar == 3) {
				System.out.println("Du gjorde sax, datorn gjorde påse. Du vann, grattis!");

			}
			if (hand == 3 && svar == 2) {
				System.out.println("Du gjorde påse, datorn gjorde sax. Du förlorade");

			} else if (hand == 3 && svar == 1) {
				System.out.println("Du gjorde påse, datorn gjorde sten. Du vann, grattis!");

			}

			/*
			 * boolean resultat = spel.seger(svar, hand); if (resultat = false) {
			 * System.out.println("Du förlorade"); } else if (resultat = true) {
			 * System.out.println("Du vann!"); }
			 */

		}
	}
}
