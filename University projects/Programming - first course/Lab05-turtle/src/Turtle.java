import se.lth.cs.pt.window.SimpleWindow;

public class Turtle {
	protected boolean isPenDown;
	protected double alfa;
	private double x;
	private double y;
	private SimpleWindow w;

	/**
	 * Skapar en sköldpadda som ritar i ritfönstret w. Från början befinner sig
	 * sköldpaddan i punkten x, y med pennan lyft och huvudet pekande rakt uppåt i
	 * fönstret (i negativ y-riktning).
	 */
	public Turtle(SimpleWindow w, int x, int y) {

		this.x = x;
		this.y = y;
		this.w = w;
		isPenDown = false;
		alfa = Math.PI / 2;

	}

	/** Sänker pennan. */
	public void penDown() {
		isPenDown = true;

	}

	/** Lyfter pennan. */
	public void penUp() {
		isPenDown = false;

	}

	/** Går rakt framåt n pixlar i den riktning huvudet pekar. */
	public void forward(int n) {
		double x1 = x + n * Math.cos(alfa);
		double y1 = y - n * Math.sin(alfa);
		w.moveTo((int) x, (int) y);

		if (isPenDown) {
			w.lineTo((int) x1, (int) y1);
		}

		x = x1;
		y = y1;

	}

	/** Vrider beta grader åt vänster runt pennan. */
	public void left(int beta) {
		alfa = alfa + Math.toRadians(beta);
	}

	/**
	 * Går till punkten newX, newY utan att rita. Pennans läge (sänkt eller lyft)
	 * och huvudets riktning påverkas inte.
	 */
	public void jumpTo(int newX, int newY) {
		x = newX;
		y = newY;

	}

	/** Återställer huvudriktningen till den ursprungliga. */
	public void turnNorth() {
		alfa = Math.PI / 2;

	}

	/** Tar reda på x-koordinaten för sköldpaddans aktuella position. */
	public int getX() {
		return (int) Math.round(x);
	}

	/** Tar reda på y-koordinaten för sköldpaddans aktuella position. */
	public int getY() {
		return (int) Math.round(y);
	}

	/** Tar reda på sköldpaddans riktning, i grader från den positiva X-axeln. */
	public int getDirection() {
		return (int) Math.round(Math.toDegrees(alfa));
	}
}
