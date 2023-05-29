package game;

import java.util.Random;

public class ComputerPlayer extends Player{
	public ComputerPlayer(String playerId) {
		super(playerId);
	}
	public String getUserId() {
		return userId;
	}
	public int takePins(Board board) {
		userInterface.sendMessage("Det finns " + board.getNoPins() + " stickor kvar. \nDatorn funderar på hur många den ska ta...", "Datorns tur");
		Random rand = new Random();
		int stickor = 1 + rand.nextInt(2);
		board.takePins(stickor);
		System.out.print(stickor);
		userInterface.sendMessage("Datorn tog " + stickor + "!", "Datorn har tänkt färdigt");
		return stickor;
	}

}
