import java.util.Random;

public class DizzyTurtle extends RaceTurtle {
	private int dizz;
	Random rand = new Random();

	public DizzyTurtle(RaceWindow w, int nbr, int dizz) {
		super(w, nbr);
		this.dizz = dizz;
	}

	public void raceStep() {
		int dizz2 = -3 * dizz;
		left(2 * rand.nextInt(dizz * 3 + 1) + dizz2);
		super.raceStep();
		// Snubbar som knuffar in paddjäveln när den är för lost
		if (super.getY() < 0) {
			super.left(-30);
		}
		if (super.getY() > 400) {
			super.left(30);
		}
		if (super.getX() < 0) {
			super.left(180);
		}
	}

	public String toString() {
		return super.toString() + " - DizzyTurtle" + "(Yrsel" + dizz + ")";
	}

}
