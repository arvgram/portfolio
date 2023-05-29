package sudoku;

public class Solver implements SudokuSolver {
	private int[][] boardMatrix;
	private int size;
	
	public Solver() {
		boardMatrix = new int[9][9];
		size = 9;
	}

	/**
	 * solves the current sudoku if possible.
	 * @return true if the sudoku was solved, false else
	 */
	public boolean solve() {
		return solve(0);
	}
	/**
	 * Private help method to solve sudoku recursively
	 * @param pos the current position in the grid
	 * @return true if solved, false if not
	 */
	private boolean solve(int pos) {
		if(pos >= size*size) {
			System.out.println("SOLVED");
			return true;
		}
		int row = pos/size;
		int col = pos%size;
		if(boardMatrix[row][col] == 0) {
			for(int i = 1; i < 10; i++) {
				System.out.println("Testing "+ i + " at row " + row + " and col " + col);
				if(isValid(row,col,i)) {
					add(row,col,i);
					System.out.println("Placing "+ i + " at row " + row + " and col " + col);
					if(!solve(pos+1)) {
						System.out.println("Removing "+ get(row,col) + " from row " + row + " and col " + col);
						remove(row,col);
						
					} else {
						return true;
					}
				}
			
			}
		} else {
			return solve(pos+1);
		}
		return false;
	}

	/**
	 * Puts digit in the box row, col.
	 * 
	 * @param row   The row
	 * @param col   The column
	 * @param digit The digit to insert in box row, col
	 * @throws IllegalArgumentException if row, col or digit is outside the range
	 *                                  [0..9]
	 */
	public void add(int row, int col, int digit) {
		if(row < 0 || row > 8 || col < 0 || col > 8 || digit < 0 || digit > 9 ) {
			throw new IllegalArgumentException();
		}
		
		boardMatrix[row][col] = digit;
		

	}

	/**
	 * Removes digit from cell at row, col.
	 * @param row the row corresponding to the cell which digit should be removed.
	 * @param col
	 * @throws IllegalArgumentException if row, col is outside [0,8]
	 */
	public void remove(int row, int col) {
		if(row < 0 || row > 8 || col < 0 || col > 8 ) {
			throw new IllegalArgumentException();
		}
		boardMatrix[row][col] = 0;

	}

	/**
	 * returns the digit at row, col.
	 * @param row the row of the digit
	 * @param col the col of the digit
	 * @return the digit at row, col
	 */
	public int get(int row, int col) {
		return boardMatrix[row][col];
	}
	

	/**
	 * Checks that the digit at row, col is valid.
	 * @param row the row of the cell
	 * @param col the col of the cell
	 * @param digit the digit at the cell
	 * @return true if valid, false if not valid
	 */
	public boolean isValid(int row, int col, int digit) {
		//check row & column
		for (int i = 0; i < 9; i++) {
			if(boardMatrix[row][i] == digit && i != col) {
				System.out.println("Unvalid because of " + digit + " in row " + row + " and col " + i);
				return false;
			}
			if(boardMatrix[i][col] == digit && i != row) {
				System.out.println("Unvalid because of " + digit + " in row  " + i + " and col " + col);
				return false;
			}
		}
		//check submatrix
		int rowStart = (row/3)*3;
		int colStart = (col/3)*3;
		
		for(int i = rowStart; i < rowStart+3; i++) {
			for (int j = colStart; j < colStart + 3; j++) {
				if(boardMatrix[i][j] == digit && i != row && j != col) {
					System.out.println("Unvalid because of " + digit + " in same submatrix");
					return false;
				}
			}
		}
		
		return true;
	}
	/** 
	 * Checks that all cells in the sudoku is valid 
	 * @return true if all cells are valid, false if not.
	 */
	public boolean allValid() {
		for(int i = 0; i < size; i++) {
			for(int j = 0; j < size; j++) {
				int currentNumb = get(i,j);
				if(currentNumb != 0) {
					if(!isValid(i,j,currentNumb)) {
						return false;
					}
				}
			}
		}
		return true;
	}
	
	/**
	 * private help method to return the current submatrix that a cell on row, col belongs to
	 * @param row the row of the cell
	 * @param col the column of the cell
	 * @return the submatrix
	 */
	private int[][]getSubMatrix(int row, int col){
		int rowStart = (row/3)*3;
		int colStart = (col/3)*3;
		int[][] subMatrix = new int[3][3];
		
		for (int i = 0; i < 3; i++) {
			int k = i + rowStart;
			for (int j = 0; j < 3; j++) {
				int l = j + colStart;
				subMatrix[i][j] = boardMatrix[k][l];
			}
		}
		return subMatrix;
	}

	/**
	 * Removes all digits from the sudoku.
	 */
	public void clear() {
		boardMatrix = new int[size][size];

	}

	/**
	 * Fills the grid with the digits in m. The digit 0 represents an empty box.
	 * 
	 * @param m the matrix with the digits to insert
	 * @throws IllegalArgumentException if m has the wrong dimension or contains
	 *                                  values outside the range [0..9]
	 */
	public void setMatrix(int[][] m) {
		if(m.length > 9) {
			throw new IllegalArgumentException();
		}
		int[][] clone = new int[9][9];
		for(int i = 0; i < size; i++) {
			for(int j = 0; j < size; j++) {
				clone[i][j] = m[i][j];
			}
		}
		boardMatrix = clone;
		size = clone.length;

	}

	/**
	 * Retrieve a matrix corresponding to the current sudoku.
	 * @return a integer matrix of the digits in the sudoku.
	 */
	public int[][] getMatrix() {
		int[][] clone = new int[9][9];
		for(int i = 0; i < size; i++) {
			for(int j = 0; j < size; j++) {
				clone[i][j] = boardMatrix[i][j];
			}
		}
		return clone;
	}
	
	public int getSize() {
		return size;
	}

}
