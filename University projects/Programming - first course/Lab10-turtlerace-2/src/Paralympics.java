import java.util.ArrayList;
import java.util.Random;

public class Paralympics {
	public static void main(String[] args) {
		ArrayList<RaceTurtle> paddor = new ArrayList<RaceTurtle>();
		RaceWindow w = new RaceWindow();
		boolean[] iMål = new boolean[9];
		Random rand = new Random();
		
		 for (int i = 0; i < 9; i++) {
			 int typ = rand.nextInt(3);
			if (typ == 0) {
				MoleTurtle padda = new MoleTurtle(w, i);
				paddor.add(padda);
				iMål[i] = false;
			}
			else if (typ == 1) {
				AbsentMindedTurtle padda = new AbsentMindedTurtle(w, i, 1 + rand.nextInt(100));
				paddor.add(padda);
				iMål[i] = false;
			}
			else if (typ == 2) { 
				DizzyTurtle padda = new DizzyTurtle(w, i, 1 + rand.nextInt(5));
				paddor.add(padda);
				iMål[i] = false;
			}
			
		 }
		for (int i = 0; i < 9; i ++) {
		System.out.println(paddor.get(i).toString());
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
