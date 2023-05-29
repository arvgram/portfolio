package game;

public class Board {
	private int noPins;
	
	public Board() {

	}
	
	public void setUp(int nbrPins) {
		noPins = nbrPins;
	}
	
	public void takePins(int pins) {
		noPins -= pins;
	}
	
	public int getNoPins() {
		return noPins;
	}
	
}
