package testSudoku;
import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import sudoku.Solver;
import sudoku.SudokuSolver;

public class TestSudoku {
	private int[][] unsolvableMatrix = { { 1, 2, 3, 0, 0, 0, 0, 0, 0 }, { 4, 5, 6, 0, 0, 0, 0, 0, 0 },
			{ 0, 0, 0, 7, 0, 0, 0, 0, 0 }, { 0, 0, 0, 0, 0, 0, 0, 0, 0 }, { 0, 0, 0, 0, 0, 0, 0, 0, 0 },
			{ 0, 0, 0, 0, 0, 0, 0, 0, 0 }, { 0, 0, 0, 0, 0, 0, 0, 0, 0 }, { 0, 0, 0, 0, 0, 0, 0, 0, 0 },
			{ 0, 0, 0, 0, 0, 0, 0, 0, 0 } };
	
	private int[][] solvableMatrix1 = { { 0, 0, 3, 0, 0, 9, 0, 8, 0 }, { 7, 4, 0, 5, 3, 0, 0, 0, 9 },
			{ 0, 0, 9, 0, 6, 0, 0, 0, 4 }, { 8, 1, 7, 3, 4, 0, 9, 2, 0 }, { 0, 9, 4, 7, 2, 6, 0, 0, 1 },
			{ 2, 6, 0, 8, 0, 0, 4, 0, 0 }, { 0, 7, 0, 0, 1, 0, 0, 0, 0 }, { 9, 5, 1, 0, 0, 0, 0, 0, 2 },
			{ 6, 0, 0, 0, 0, 0, 1, 9, 7 } };
	
	private int[][] solvableMatrix2 = { { 0, 0, 8, 0, 0, 9, 0, 6, 2 }, { 0, 0, 0, 0, 0, 0, 0, 0, 5 },
			{ 1, 0, 2, 5, 0, 0, 0, 0, 0 }, { 0, 0, 0, 2, 1, 0, 0, 9, 0 }, { 0, 5, 0, 0, 0, 0, 6, 0, 0 },
			{ 6, 0, 0, 0, 0, 0, 0, 2, 8 }, { 4, 1, 0, 6, 0, 8, 0, 0, 0 }, { 8, 6, 0, 0, 3, 0, 1, 0, 0 },
			{ 0, 0, 0, 0, 0, 0, 4, 0, 0 } };

	private SudokuSolver solver;
	
	@BeforeEach
	void setUp() {
		this.solver = new Solver();
	}
	
	@AfterEach
	void tearDown() {
		solver.clear();
	}
	
	@Test
	void testEmpty() {
		assertTrue(solver.solve());
		assertTrue(solver.get(4, 7) == 0);
	}
	
	@Test
	void testAdd() {
		solver.setMatrix(solvableMatrix1);
		solver.add(1, 2, 1);
		assertEquals(solver.get(1, 2),0);
	}
	
	@Test
	void testRemove() {
		solver.setMatrix(unsolvableMatrix);
		solver.remove(1, 2);
		assertEquals(solver.get(1, 2),0);
	}
	
	@Test
	void testIsValid() {
		solver.add(4, 5, 7);
		solver.add(4, 6, 7);
		assertFalse(solver.allValid());
		assertFalse(solver.isValid(4, 7, 7));
	}
	
	
}
