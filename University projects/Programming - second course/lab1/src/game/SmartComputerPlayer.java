package game;

public class SmartComputerPlayer extends ComputerPlayer{
	public SmartComputerPlayer(String playerId) {
		super(playerId);
	}
	public String getUserId() {
		return userId;
	}
	public int takePins(Board board) {
		userInterface.sendMessage("Det finns " + board.getNoPins() + " stickor kvar. \nDatorn funderar på hur många den ska ta...", "Datorns tur");
		int stickor;
		int pinsLeft = board.getNoPins();
		if(pinsLeft > 4) {
			stickor = 2;
		}
		else {
			stickor = 1;
		}
		board.takePins(stickor);
		System.out.print(stickor);
		userInterface.sendMessage("Datorn tog " + stickor + "!", "Datorn har tänkt färdigt");
		return stickor;
	}


}
