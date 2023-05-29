package mountain;

import java.util.HashMap;

import fractal.*;

public class Mountain extends Fractal {
	private Point p1;
	private Point p2;
	private Point p3;
	private HashMap<Side,Point> map;
	private double dev;
	
	
	/** Creates an object that handles Mountain fractal. 
	 * @param p1,p2,p3 the position of the vertices
	 */
	public Mountain(Point p1, Point p2, Point p3, double dev) {
		super();
		this.p1 = p1;
		this.p2 = p2;
		this.p3 = p3;
		this.dev = dev;
		this.map = new HashMap<Side,Point>();
	}
	/** Returns the title of this Fractal type 
	 * @returns the title
	 */
	@Override
	public String getTitle() {
		return "Mountain fractal";
	}
	
	/** Draws the traingles using TurtleGraphics object g
	 * @param turtle the turtle graphic object
	 */
	@Override
	public void draw(TurtleGraphics g) {
		MountainTriangle(p1, p2, p3, order, g, dev);
	}
	/** recursive method for drawing a triangle with vertices p1 p2 p3 
	 * 
	 * @param p1 Point object 1
	 * @param p2 Point object 2
	 * @param order The order of fractal
	 * @param tg TurtleGraphics object
	 */
	
	private void MountainTriangle(Point p1, Point p2, Point p3, int order, TurtleGraphics tg, double dev) {
		if(order == 0) {
			tg.moveTo(p1.getX(), p1.getY());
			tg.penDown();
			tg.forwardTo(p2.getX(), p2.getY());
			tg.forwardTo(p3.getX(), p3.getY());
			tg.forwardTo(p1.getX(), p1.getY());
		} else {
			// Coordinates for the three veritces q1:3 of the inner triangle 
			Side side1 = new Side(p1,p2);
			Side side2 = new Side(p2,p3);
			Side side3 = new Side(p3,p1);
			
			Point q1;
			if(map.containsKey(side1)) {
				q1 = map.remove(side1);	
			} 
			else {
				int q1x = (p1.getX()+p2.getX())/2;
				int q1y = (int) ((p1.getY()+p2.getY())/2 + RandomUtilities.randFunc(dev));
				q1 = new Point(q1x, q1y);
				map.put(side1, q1);
			}
			
			Point q2;
			if(map.containsKey(side2)) {
				q2 = map.remove(side2);
				
			}
			else {
				int q2x = (p2.getX()+p3.getX())/2;
				int q2y = (int) ((p2.getY()+p3.getY())/2 + RandomUtilities.randFunc(dev));
				q2 = new Point(q2x,q2y);
				map.put(side2,q2);
			}
			
			Point q3;
			if(map.containsKey(side3)) {
				q3 = map.remove(side3);
			}
			else {
				int q3x = (p3.getX()+p1.getX())/2;
				int q3y = (int) ((p3.getY()+p1.getY())/2 + RandomUtilities.randFunc(dev));
				q3 = new Point(q3x, q3y);
				map.put(side3, q3);
			}			
			MountainTriangle(q1, q2, q3, order-1, tg, dev/2);
			MountainTriangle(q1, p2, q2, order-1, tg, dev/2);
			MountainTriangle(p1, q1, q3, order-1, tg, dev/2);
			MountainTriangle(q2, q3, p3, order-1, tg, dev/2);
		}
		
	}

}
