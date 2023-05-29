import java.util.Random;

public class MoleTurtle extends RaceTurtle {
	Random rand = new Random();

	public MoleTurtle(RaceWindow w, int nbr) {
		super(w, nbr);
	}

	public void raceStep() {
		if (rand.nextInt(11) < 5) {
			isPenDown = true;
		} else {
			isPenDown = false;
		}
		super.raceStep();
	}
	public String toString() {
		return super.toString() + " - MoleTurtle";
	}

}
