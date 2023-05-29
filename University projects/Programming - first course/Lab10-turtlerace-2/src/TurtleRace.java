import java.util.ArrayList;

public class TurtleRace {
	public static void main(String[] args) {
		ArrayList<RaceTurtle> paddor = new ArrayList<RaceTurtle>();
		RaceWindow w = new RaceWindow();
		boolean[] iMål = new boolean[9];

		for (int i = 0; i < 9; i++) {
			RaceTurtle padda = new RaceTurtle(w, i);
			paddor.add(padda);
			iMål[i] = false;
		}
		RaceTurtle[] vinnare = new RaceTurtle[9];
		int antVinnare = 0;
		while(antVinnare < 8) {
			w.delay(10);
			for(int i = 1; i < 9; i++) {
				if(paddor.get(i).getX() < RaceWindow.X_END_POS) {
					paddor.get(i).raceStep();
				}
				else if (!iMål[i]){
					vinnare[antVinnare] = paddor.get(i);
					antVinnare++;
					iMål[i] = true;
				}
			} 
		} 
		System.out.println("På plats 1: "+vinnare[0].toString());
		System.out.println("På plats 2: "+vinnare[1].toString());
		System.out.println("På plats 3: "+vinnare[2].toString());
}

}
