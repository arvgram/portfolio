import se.lth.cs.pt.window.SimpleWindow;
import java.util.Random;

public class TurtleKing {

	public static void main(String[] args) {
		SimpleWindow w = new SimpleWindow(600, 600, "Turtle king");
		Turtle t = new Turtle(w, 500, 500);
		t.penDown();
		Random rand = new Random();
		for (int i = 0; i < 1000; i++) {
			t.forward(1 + rand.nextInt(10));
			t.left(-180 + rand.nextInt(361));
			w.delay(20);
			if (t.getX() > 600) {
				t.jumpTo(600, (int) Math.round(t.getY()));
			}
			if (t.getY() > 600) {
				t.jumpTo((int) Math.round(t.getX()), 600);
			}
			if (t.getY() < 0) {
				t.jumpTo((int) Math.round(t.getX()), 1);
			}
			if (t.getX() < 0) {
				t.jumpTo(0, (int) Math.round(t.getY()));

			}
		}
	}
}
