import java.util.Random;

public class AbsentMindedTurtle extends RaceTurtle {
		Random rand = new Random();
		private int abs;

		public AbsentMindedTurtle(RaceWindow w, int nbr, int abs ) {
			super(w, nbr);
			this.abs = abs;
		
			}
		public void raceStep() {
			double raceAbs = 100*rand.nextDouble();
			if (raceAbs > abs) {
				super.raceStep();
			}
		}
		public String toString() {
			return super.toString() + " - AbsentMindedTurtle" + "(" + abs + "% frånvarande)";
		}

}
