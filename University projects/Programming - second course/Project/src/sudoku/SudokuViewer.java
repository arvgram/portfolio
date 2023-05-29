package sudoku;


import java.awt.BorderLayout;
import javax.swing.JButton;

import java.awt.Color;


import java.awt.Container;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.GridLayout;
import java.util.ArrayList;

import javax.swing.JFrame;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JTextField;
import javax.swing.SwingUtilities;

public class SudokuViewer {
	private JTextField[][] grid;
	private JPanel panel;
	private SudokuSolver sudoku;
	private static Font FONT = new Font("SansSerif", Font.PLAIN, 20);
	private static ArrayList<Integer> ALLOWEDINPUT = new ArrayList<Integer>();
	private static int VIEWDIMENSION = 600;

	public SudokuViewer(Solver sudoku) {
		for (int i = 1; i < 10; i++) {
			ALLOWEDINPUT.add(i);
		}
		this.grid = new JTextField[9][9];
		for (int i = 0; i<9;i++) {
			for(int j = 0; j<9; j++) {
				this.grid[i][j] = new JTextField("");
			}
		}
		this.panel = new JPanel(new GridLayout(9, 9));
		this.sudoku = sudoku;
		SwingUtilities.invokeLater(() -> createWindow("Sudoku", VIEWDIMENSION, VIEWDIMENSION));
	}

	private void createWindow(String title, int width, int height) {
		JFrame frame = new JFrame(title);
		frame.setResizable(true);
		createGrid();

		JButton solve = new JButton("Solve");
		solve.addActionListener(e -> {
			if (!updateSudoku()) {
				JOptionPane.showMessageDialog(null,
						"Please remove invalid inputs, please make sure all inputs are in the range [1,9] and the given sudoku is valid.");
			} else {
				if(sudoku.solve()) {
					JOptionPane.showMessageDialog(null, "Solved Sudoku");
				} else {
					JOptionPane.showMessageDialog(null, "Soduku is unsolvable");
				}
				updateGrid();
			}

		});

		JButton clear = new JButton("Clear");
		clear.addActionListener(e -> {
			updateSudoku();
			sudoku.clear();
			updateGrid();
		});
		
		frame.add(clear, BorderLayout.PAGE_START);
		frame.add(solve, BorderLayout.PAGE_END);
		frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		Container pane = frame.getContentPane();
		pane.add(panel, BorderLayout.CENTER);
		frame.setSize(width, height);
		frame.setVisible(true);
	}

	private boolean purpleConditions(int i, int j) {
		if (i < 3) {
			return j < 3 || j > 5;
		} else if (5 < i) {
			return 5 < j || j < 3;
		} else if (2 < i && i < 6) {
			return 2 < j && j < 6;
		}

		else {
			return false;
		}

	}

	private void createGrid() {
		for (int i = 0; i < 9; i++) {
			for (int j = 0; j < 9; j++) {
				JTextField textfield = new JTextField();
				textfield.setLocation(5, 5);
				textfield.setSize(100, 20);
				textfield.setFont(FONT);
				grid[i][j] = textfield;
				if (sudoku.get(i, j) != 0) {
					grid[i][j].setText(String.valueOf(sudoku.get(i, j)));
				}
				if (purpleConditions(i, j)) {
					grid[i][j].setBackground(Color.MAGENTA);
				}
				grid[i][j].setHorizontalAlignment(JTextField.CENTER);

				panel.add(grid[i][j]);
			}
		}
	}

	private boolean updateGrid() {
		for (int i = 0; i < 9; i++) {
			for (int j = 0; j < 9; j++) {
				if (sudoku.get(i, j) != 0) {
					try {
						grid[i][j].setText(String.valueOf(sudoku.get(i, j)));
					} catch (NumberFormatException e) {
						return false;
					}
				} else {
					grid[i][j].setText("");
				}
			}
		}
		return true;
	}

	private boolean updateSudoku() {
		for (int i = 0; i < grid.length; i++) {
			for (int j = 0; j < grid.length; j++) {
				if (!(grid[i][j].getText().equals(""))) {
					try {
						sudoku.add(i, j, Integer.parseInt(grid[i][j].getText()));
					} catch (NumberFormatException e) {
						return false;
					}
					catch (IllegalArgumentException f) {
						return false;
					}
					if (!ALLOWEDINPUT.contains(Integer.parseInt(grid[i][j].getText()))) {
						return false;
					}

				} else {
					sudoku.add(i, j, 0);
				}
			}
		}
		return sudoku.allValid();
	}
}