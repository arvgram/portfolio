package game;

import javax.swing.JOptionPane;

public class userInterface {
	public static void showWelcomeMessage() {
		JOptionPane.showMessageDialog(
			null, 
			"Welcome to the amazing game: \n\"Take pins\"", 
			"Welcome message", 
			JOptionPane.INFORMATION_MESSAGE);
	}
	public static void reactToNo() {
		JOptionPane.showMessageDialog(
				null, 
				"Fan vad tråkig stil... \nJag lovar det blir kul!", 
				"Var lite skön?", 
				JOptionPane.INFORMATION_MESSAGE);
	}
	
	public static int askOptionQuestion(String question, String header) {
		int n = JOptionPane.showConfirmDialog(
			null, 
			question,
			header,
			JOptionPane.YES_NO_OPTION
			);
		return n;
	}
	
	public static void sendMessage(String text, String header) {
		JOptionPane.showMessageDialog(
				null, 
				text, 
				header, 
				JOptionPane.INFORMATION_MESSAGE);
	}
	
	public static String askFreeQuestion(String question) {
		return JOptionPane.showInputDialog(question);	
	}
	
	public static int askHowManyToStartWith(){
		Integer[] possibilities = {10, 15, 20};
		int nbrPins = JOptionPane.showOptionDialog(
		                    null,
		                    "Hur många pinnar vill du spela med",
		                    "Spelval",
		                    JOptionPane.YES_NO_CANCEL_OPTION,
		                    JOptionPane.QUESTION_MESSAGE,
		                    null,
		                    possibilities,
		                    10);	
		return possibilities[nbrPins];
	}
	public static int askForDifficulty(){
		String[] possibilities = {"Lätt", "Svår"};
		int difficulty = JOptionPane.showOptionDialog(
                null,
                "Vilken svårighetsgrad vill du spela på?",
                "Spelval",
                JOptionPane.YES_NO_OPTION,
                JOptionPane.QUESTION_MESSAGE,
                null,
                possibilities,
                "Lätt");
		return difficulty;
	}
	
	String name = JOptionPane.showInputDialog("Vad vill du att din spelare ska heta?");
}
