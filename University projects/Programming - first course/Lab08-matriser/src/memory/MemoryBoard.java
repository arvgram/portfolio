
package memory;

import java.util.Random;

public class MemoryBoard {
	private int size;
	private MemoryCardImage[][] board;
	private boolean[][] boolboard;

	/**
	 * Skapar ett memorybräde med size * size kort. backFileName är filnamnet för
	 * filen med baksidesbilden. Vektorn frontFileNames innehåller filnamnen för
	 * frontbilderna.
	 */
	public MemoryBoard(int size, String backFileName, String[] frontFileNames) {
		this.size = size;
		createCards(backFileName, frontFileNames);
	}

	/*
	 * Skapar size * size / 2 st memorykortbilder. Placerar ut varje kort på två
	 * slumpmässiga ställen på spelplanen.
	 */
	private void createCards(String backFileName, String[] frontFileNames) {
		this.board = new MemoryCardImage[size][size];
		boolboard = new boolean[size][size];
		Random rand = new Random();
		int i = size * size / 2-1;

		while (i >= 0) {
			int r1 = rand.nextInt(size);
			int c1 = rand.nextInt(size);
			if (board[r1][c1] == null) {
				MemoryCardImage mc= new MemoryCardImage(backFileName, frontFileNames[i]);
				board[r1][c1] = mc;
				boolboard[r1][c1] = true;
				while (true) {
					int r2 = rand.nextInt(size);
					int c2 = rand.nextInt(size);
					if (board[r2][c2] == null) {
						board[r2][c2] = mc; // new MemoryCardImage(backFileName, frontFileNames[i]);
						boolboard[r2][c2] = true;
						i--;
						break;
					}
				}

			}

		}
	}

	/** Tar reda på brädets storlek. */
	public int getSize() {
		return size;
	}

	/**
	 * Hämtar den tvåsidiga bilden av kortet på rad r, kolonn c. Raderna och
	 * kolonnerna numreras från 0 och uppåt.
	 */
	public MemoryCardImage getCard(int r, int c) {
		return board[r][c];
	}

	/** Vänder kortet på rad r, kolonn c. */
	public void turnCard(int r, int c) {
		if (boolboard[r][c]) { 
			boolboard[r][c] = false;
		} else if (!boolboard[r][c]) {
			boolboard[r][c] = true;
		}

	}

	/** Returnerar true om kortet r, c har framsidan upp. */
	public boolean frontUp(int r, int c) {
		if (boolboard[r][c]) {
			return true;
		} else {
			return false;
		}
	}

	/**
	 * Returnerar true om det är samma kort på rad r1, kolonn c2 som på rad r2,
	 * kolonn c2.
	 */
	public boolean same(int r1, int c1, int r2, int c2) {
		if (board[r1][c1] == board[r2][c2]) {
			return true;
		}return false;
	}

	/** Returnerar true om alla kort har framsidan upp. */
	public boolean hasWon() {
		for (int i = 0; i < size; i++) {
			for (int k = 0; k < size; k++) {
				if (boolboard[i][k]) {
					return false;
				}
			}
		}
		return true;
	}
}
