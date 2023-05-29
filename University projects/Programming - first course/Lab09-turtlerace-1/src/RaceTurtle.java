import java.util.Random;

public class RaceTurtle extends Turtle {
	private int nbr;
	private Random rand = new Random();

	public RaceTurtle(RaceWindow w, int nbr) {
		super(w,RaceWindow.getStartXPos(nbr),RaceWindow.getStartYPos(nbr));
		this.nbr = nbr;
		alfa = 0;
		isPenDown = true;
	}

	public void raceStep() {
		int step = 1 + rand.nextInt(6);
		forward(step);
		}
	public String toString() {
		return "Nummer " + nbr;
	}
	public boolean isFinished() {
		if(getX()<RaceWindow.X_END_POS) {
			return false;
		}
		return true;
	}
	

}
