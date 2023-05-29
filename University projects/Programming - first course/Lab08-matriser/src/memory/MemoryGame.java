package memory;

public class MemoryGame {
	public static void main(String[] args) {
		String[] frontFileNames = { "can.jpg", "flopsy_mopsy_cottontail.jpg", "friends.jpg", "mother_ladybird.jpg",
				"mr_mcgregor.jpg", "mrs_rabbit.jpg", "mrs_tittlemouse.jpg", "radishes.jpg" };
		MemoryBoard spel = new MemoryBoard(4, "back.jpg", frontFileNames);
		MemoryWindow w = new MemoryWindow(spel);
		w.drawBoard();
		int c1 = 0;
		int r1 = 0;
		int r2 = 0;
		int c2 = 0;
		while (!spel.hasWon()) {
			while (true) {
				w.waitForMouseClick();
				r1 = w.getMouseRow();
				c1 = w.getMouseCol();
				if (spel.frontUp(r1, c1)) {
					spel.turnCard(r1, c1);
					w.drawCard(r1, c1);
					break;
				}
			}
			while (true) {
				w.waitForMouseClick();
				r2 = w.getMouseRow(); 
				c2 = w.getMouseCol();
				if (spel.frontUp(r2, c2)) {
					spel.turnCard(r2, c2);
					w.drawCard(r2, c2);
					break;
				}
			}
			w.delay(2000);
			if (!spel.same(r1, c1, r2, c2)) {
				spel.turnCard(r1, c1);
				w.drawCard(r1, c1);
				spel.turnCard(r2, c2);
				w.drawCard(r2, c2);

			}

		}
		System.out.println("Grattis, du vann!");

	}
}
