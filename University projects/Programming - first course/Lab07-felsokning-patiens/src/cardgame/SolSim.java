package cardgame;

import pair.PairSet;
import pair.Pair;

public class SolSim {
	private static final int NBR_IT = 100000;
	public static void main(String[] args) {
		double corr = 0;
		for (int i = 0; i < NBR_IT; i++) { // upprepar simuleringen NBR_IT ggr
			PairSet cd = new PairSet(4, 13); // Skapar en ny kortlek för varje simulering //Antal klarade partier
			boolean r = true; // Huruvida partiet lever eller ej
			while (cd.more() && r) { // Om det finns fler kort i leken och pariet lever
				for (int k = 0; k < 3 && cd.more(); k++) { // Drar fyra kort
					Pair card = cd.pick();
					if (card.second() == k) { // Om kortets valör är detsamma som ordningen
						r = false; // blir r false
						break;
					}
				}
			}
			if (!cd.more() && r) { // Om man klarar hela leken höjs corr med 1
				corr++;
			}
		}
		System.out.println(corr / NBR_IT); // Skriver ut andelen klarade
	}

}
