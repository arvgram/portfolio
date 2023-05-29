package sudoku;

//import javax.swing.JTextField;

public class SudokuApplication {
	
	public SudokuApplication() { 
	}

	public static void main(String[] args) {
		Solver solver = new Solver();
		for (int i = 0; i<9;i++) {
			for(int j = 0; j<9; j++) {
				solver.add(i, j, 0);
			}
		}
		SudokuViewer sv= new SudokuViewer(solver);
		
	}

}
