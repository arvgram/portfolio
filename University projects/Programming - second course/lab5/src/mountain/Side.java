package mountain;

public class Side {
	private Point p1;
	private Point p2;
	
	public Side(Point p1, Point p2) {
		this.p1 = p1;
		this.p2 = p2;		
	}
	
	public Point[] getPoints() {
		Point[] vec = new Point[2];
		vec[0] = this.p1;
		vec[1] = this.p2;
		return vec;
	}
	@Override
	public boolean equals(Object obj) {
		if (obj instanceof Side) {
			Side s = (Side) obj;
			Point[] vec = s.getPoints();
			if(vec[0].equals(p1) || vec[0].equals(p2)) {
				if(vec[1].equals(p1) || vec[1].equals(p2)) {
					return true;
				}
			}
		}
		return false;
	}
	@Override
	public int hashCode() {
		return p1.hashCode() + p2.hashCode();
	}
	

}
