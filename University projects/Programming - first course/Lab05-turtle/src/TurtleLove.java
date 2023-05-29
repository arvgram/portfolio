
import se.lth.cs.pt.window.SimpleWindow;
import java.util.Random;

public class TurtleLove {

	public static void main(String[] args) {
		SimpleWindow w = new SimpleWindow(600, 600, "Turtle love");
		Turtle t1 = new Turtle(w, 250, 250);
		Turtle t2 = new Turtle(w, 350, 350);
		t1.penDown();
		t2.penDown();
		Random rand = new Random();
		double distX;
		double distY;
		double dist = 51;
		while ( dist >= 50) {
			distX = t1.getX() - t2.getX();
			distY = t1.getY() - t2.getY();
			dist = Math.sqrt(distY * distY + distX * distX);
			t1.forward(1 + rand.nextInt(10));
			t1.left(-180 + rand.nextInt(361));
			//w.delay(1);

			t2.forward(1 + rand.nextInt(10));
			t2.left(-180 + rand.nextInt(361));
			//w.delay(1);
			if (t2.getX() > 600) {
				t2.jumpTo(600, (int) Math.round(t2.getY()));
			}
			if (t2.getY() > 600) {
				t2.jumpTo((int) Math.round(t2.getX()), 600);
			}
			if (t2.getY() < 0) {
				t2.jumpTo((int) Math.round(t2.getX()), 1);
			}
			if (t2.getX() < 0) {
				t2.jumpTo(0, (int) Math.round(t2.getY()));

				if (t1.getX() > 600) {
					t1.jumpTo(600, (int) Math.round(t1.getY()));
				}
				if (t1.getY() > 600) {
					t1.jumpTo((int) Math.round(t1.getX()), 600);
				}
				if (t1.getY() < 0) {
					t1.jumpTo((int) Math.round(t1.getX()), 1);
				}
				if (t1.getX() < 0) {
					t1.jumpTo(0, (int) Math.round(t1.getY()));
				}
			}

		}
	}
}
