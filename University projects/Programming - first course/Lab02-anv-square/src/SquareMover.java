import se.lth.cs.pt.square.Square;
import se.lth.cs.pt.window.SimpleWindow;

public class SquareMover {

	public static void main(String[] args) {
		SimpleWindow w = new SimpleWindow(600, 600, "DrawSquare");
		int oldX = 250;
		int oldY = 250;
		Square sq = new Square(oldX, oldY, 100);
		sq.draw(w);
		while (true) {
			w.waitForMouseClick();
			sq.erase(w);
			int newX = w.getMouseX();
			int newY = w.getMouseY();
			sq.move(newX - oldX, newY - oldY);
			sq.draw(w);
			oldX = newX;
			oldY = newY;

		}

	}
}
