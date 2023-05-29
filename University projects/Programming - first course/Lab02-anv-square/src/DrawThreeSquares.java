import se.lth.cs.pt.window.SimpleWindow;
import se.lth.cs.pt.square.Square;

public class DrawThreeSquares {
	public static void main(String[] args) {
		SimpleWindow w = new SimpleWindow(600, 600, "DrawSquare");
		Square sq = new Square(250, 250, 100);
		sq.draw(w);
		SimpleWindow.delay(100);
		sq.move(100, 0);
		SimpleWindow.delay(100);
		sq.draw(w);
		SimpleWindow.delay(100);
		sq.move(0, 100);
		SimpleWindow.delay(100);
		sq.draw(w);
		SimpleWindow.delay(5000);
		sq.move(100, 0);
		SimpleWindow.delay(100);
		sq.move(0,100);
		sq.draw(w);
		sq.move(100, 0);
		sq.draw(w);
	
	}
}
