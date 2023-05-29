import java.util.Random;

public class SSP {
//private int hand;
	private int svar;
	//private double odds;
	private boolean resultat;

//public SSP () {

//}

	public int handReturn(int hand) {
		Random rand = new Random();
		double odds = rand.nextDouble();

		if (hand == 1 && odds > 0.3) {
			svar = 3;
		} else if (hand == 1 && odds <= 0.3){
			svar = 2;
		}
		if (hand == 2 && odds > 0.3) {
			svar = 1;
		} else if (hand == 2 && odds <= 0.3){
			svar = 3;
		}
		if (hand == 3 && odds > 0.3) {
			svar = 2;
		} else if (hand == 3 && odds <= 0.3){
			svar = 1;
		}

		return svar;
	}

	public boolean seger(int svar, int hand) {
		if (hand == 1 && svar == 3) {
			resultat = false;
		} else if (hand == 1 && svar == 2) {
			resultat = true;
		}
		if (hand == 2 && svar == 1) {
			resultat = false;
		} else if (hand == 2 && svar == 3) {
			resultat = true;
		}
		if (hand == 3 && svar == 2) {
			resultat = false;
		} else if (hand == 3 && svar == 1) {
			resultat = true;
		}
		return resultat;
	}
}
