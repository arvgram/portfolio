
public class Mole {
	private Graphics g = new Graphics(100, 90, 10);

	public static void main(String[] args) {
		Mole m = new Mole();
		m.drawWorld();
		m.dig();
	}

	public void drawWorld() {
		g.rectangle(0, 0, 100, 100, Colors.SOIL);

	}

	public void dig() {
		int x = g.getWidth() / 2;
		int y = g.getHeight() / 2;
		while (true) {
			if (x > 1000) {
				x = 100;
			} else if (x < 0) {
				x = 0;
			} else if (y > 1000) {
				y = 100;
			} else if (y < 0) {
				y = 0;
			} else {
				g.block(x, y, Colors.MOLE);
				char key = g.waitForKey();
				g.block(x, y, Colors.TUNNEL);
				if (key == 'w') {
					y = y - 1;
				} else if (key == 'a') {
					x = x - 1;
				} else if (key == 's') {
					y = y + 1;
				} else if (key == 'd') {
					x = x + 1;

				}
			}
		}
	}
}
