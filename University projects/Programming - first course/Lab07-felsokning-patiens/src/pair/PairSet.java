package pair;

import java.util.Random;

public class PairSet {
	private int n; // Antal talpar?
	private Pair[] pairs; // Vektor med talpar
	private static Random rand = new Random();

	/**
	 * Skapar en mängd av alla talpar (a,b) sådana att 0 <= a < rows och 0 <= b <
	 * cols
	 */
	public PairSet(int rows, int cols) {
		n = rows * cols;
		int parNr = 0; // Numrerar platserna
		pairs = new Pair[n];
		for (int i = 0; i < rows; i++) {
			for (int k = 0; k < cols; k++) {
				pairs[parNr] = new Pair(i, k);
				parNr++; // Räknar upp varje plats
			}
		}

	}

	/** Undersöker om det finns fler par i mängden. */
	public boolean more() {
		if (n != 0) {
			return true;
		}
		return false;
	}

	/**
	 * Hämtar ett slumpmässigt valt talpar ur mängden. Mängden blir ett element
	 * mindre. Om mängden är tom returneras null.
	 */
	public Pair pick() {
		if (n != 0) {
			int pick = rand.nextInt(n);
			Pair valtPar = pairs[pick];
			pairs[pick] = pairs[n-1];
			pairs[n-1] = null;
			n--;
			return valtPar;
		}
		return null;
	}
}
