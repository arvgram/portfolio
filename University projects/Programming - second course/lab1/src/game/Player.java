package game;

public abstract class Player {
	protected String userId;
	
	protected Player(String userId){
		this.userId = userId;
	}
	
	public String getUserId() {
		return userId;
	}
	
	public abstract int takePins(Board board);
	
}
