package game;

import javax.swing.JOptionPane;

public class HumanPlayer extends Player{
	
	public HumanPlayer(String userId) {
		super(userId);
	}
	
	public int takePins(Board board) {
		int nbrPinsLeft = board.getNoPins();
		String[] oneOrTwo = {"1","2"};
		int pins2Take = 1 + JOptionPane.showOptionDialog(
				null, 
				"Nu är det din tur, "+ userId + "!\n" + "Det finns " + nbrPinsLeft + " pinnar kvar. \nHur många pinnar vill du plocka?", 
				"Antal pinnar", 
				JOptionPane.YES_NO_OPTION, 
				JOptionPane.QUESTION_MESSAGE, 
				null, 
				oneOrTwo, 
				"1");
		board.takePins(pins2Take);
		return pins2Take;
	}

}
