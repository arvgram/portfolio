package sudoku;

public interface SudokuSolver {
	/**
	 * solves the current sudoku if possible.
	 * @return true if the sudoku was solved, false else
	 */
	boolean solve();

	/**
	 * Puts digit in the box row, col.
	 * 
	 * @param row   The row
	 * @param col   The column
	 * @param digit The digit to insert in box row, col
	 * @throws IllegalArgumentException if row, col or digit is outside the range
	 *                                  [0..9]
	 */
	void add(int row, int col, int digit);

	/**
	 * Removes digit from cell at row, col.
	 * @param row the row corresponding to the cell which digit should be removed.
	 * @param col
	 * @throws IllegalArgumentException if row, col is outside [0,8]
	 */
	void remove(int row, int col);

	/**
	 * returns the digit at row, col.
	 * @param row the row of the digit
	 * @param col the col of the digit
	 * @return the digit at row, col
	 */
	int get(int row, int col);

	/**
	 * Checks that the digit at row, col is valid.
	 * @param row the row of the cell
	 * @param col the col of the cell
	 * @param digit the digit at the cell
	 * @return true if valid, false if not valid
	 */
	boolean isValid(int row, int col, int digit);

	/** 
	 * Checks that all cells in the sudoku is valid 
	 * @return true if all cells are valid, false if not.
	 */
	boolean allValid();
	
	/**
	 * Removes all digits from the sudoku.
	 */
	void clear();

	/**
	 * Fills the grid with the digits in m. The digit 0 represents an empty box.
	 * 
	 * @param m the matrix with the digits to insert
	 * @throws IllegalArgumentException if m has the wrong dimension or contains
	 *                                  values outside the range [0..9]
	 */
	void setMatrix(int[][] m);

	/**
	 * Retrieve a matrix corresponding to the current sudoku.
	 * @return a integer matrix of the digits in the sudoku.
	 */
	int[][] getMatrix();
}
