import se.lth.cs.pt.square.Square;
import se.lth.cs.pt.window.SimpleWindow;

public class WalkingSquare {

	public static void main(String[] args) {
		SimpleWindow w = new SimpleWindow(600, 600, "DrawSquare");
		int oldX = 250;
		int oldY = 250;
		Square sq = new Square(oldX, oldY, 100);
		sq.draw(w);
		while (true) {
			w.waitForMouseClick();
			int newX = w.getMouseX();
			int newY = w.getMouseY();
			int dx = newX - oldX;
			int dy = newY - oldY;
			int stegX = (dx) / 10;
			int stegY = (dy) / 10;
			for (int i = 0; i < 10; i++) {
				sq.erase(w);
				sq.move(stegX, stegY);
				sq.draw(w);
				SimpleWindow.delay(10);
				
			}
			oldX = sq.getX();
			oldY = sq.getY();

		}
	}
}