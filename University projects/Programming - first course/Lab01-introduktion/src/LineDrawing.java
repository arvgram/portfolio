import java.awt.Color;
import java.util.Scanner;
import se.lth.cs.pt.square.Square;
import se.lth.cs.pt.window.SimpleWindow;

public class LineDrawing {
	public static void main(String[] args) {
		SimpleWindow w = new SimpleWindow(500, 500, "LineDrawing");
		w.moveTo(0, 0);
		Scanner scan = new Scanner(System.in);
		System.out.println("Vad är din favoritfärg? 1: Grön, 2: Röd, 3: Blå");
		int f = scan.nextInt();
		if (f == 1) {
			w.setLineColor(Color.GREEN);
		}
		if (f == 2) {
			w.setLineColor(Color.RED);
		}
		if (f == 3) {
			w.setLineColor(Color.BLUE);
		}
		while (true) {
			System.out.println("Vill du göra 1: kvadrater, eller 2: streck?, eller 3: byta färg");

			int typ = scan.nextInt();
			if (typ == 2) {

				w.waitForMouseClick();
				w.moveTo(w.getMouseX(), w.getMouseY());
				w.waitForMouseClick();
				w.lineTo(w.getMouseX(), w.getMouseY());
			}
			if (typ == 1) {
				System.out.println("Ange storlek på kvadrat");
				int strlk = scan.nextInt();
				w.waitForMouseClick();
				Square sq = new Square(w.getMouseX(), w.getMouseY(), strlk);
				sq.draw(w);
				if (typ == 3) {

				}
			}

		}
	}
}
