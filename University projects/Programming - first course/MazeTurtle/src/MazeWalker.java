
import se.lth.cs.pt.maze.*;
import se.lth.cs.pt.window.*;

public class MazeWalker {

	private Turtle turtle;

	public MazeWalker(Turtle turtle) {
		this.turtle = turtle;
	}

	public void walk(Maze maze) {
		while (!(maze.atExit(turtle.getX(), turtle.getY()))) { // Medan den inte är framme
			SimpleWindow.delay(1);
			turtle.penDown(); // För att man ska se den
			
		if (maze.wallAtLeft(turtle.getDirection(), turtle.getX(), turtle.getY())== false )
			turtle.left(90);
			
		if (maze.wallInFront(turtle.getDirection(), turtle.getX(), turtle.getY())== false ) {
			turtle.forward(1);}
			else if (maze.wallInFront(turtle.getDirection(), turtle.getX(), turtle.getY())== true) {
				turtle.left(270);
		}
		}
			
		}

			

		
	//}

	public static void main(String[] args) {
		SimpleWindow w = new SimpleWindow(600, 600, "Tuttes äventyr");
		Maze mz = new Maze(/* sc.nextInt() **/3);
		Turtle tutte = new Turtle(w, mz.getXEntry(), mz.getYEntry());
		MazeWalker mw = new MazeWalker(tutte);
		mz.draw(w);
		mw.walk(mz);

	}

}
