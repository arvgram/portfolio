package game;

import javax.swing.JOptionPane;
public class TakePinsGame {

	public static void main(String[] args) {
		userInterface.showWelcomeMessage();
		
		int choice = userInterface.askOptionQuestion(
				"Vill du spela?", 
				"Starta spel");
		if(choice == 1) {
			userInterface.reactToNo();
		}
		
		String humanName = userInterface.askFreeQuestion("Vad vill du att din spelare ska heta?");
		String computerName = userInterface.askFreeQuestion("Vad vill du att din motståndare ska heta?");
		HumanPlayer human = new HumanPlayer(humanName);
		ComputerPlayer computer = new ComputerPlayer(computerName);
		int diff = userInterface.askForDifficulty();
		if(diff == 0) {
			computer = new SmartComputerPlayer(computerName);
		}
		else {
			computer = new ComputerPlayer(computerName);
		}
		
		
		int nbrPins = userInterface.askHowManyToStartWith();
		
		Board b = new Board();
		b.setUp(nbrPins);
		System.out.print(b.getNoPins());
		while(b.getNoPins() > 0) {
			int humanPins = human.takePins(b);
			if(b.getNoPins() == 0) {
				userInterface.sendMessage("Grattis " + humanName + ", du vann!", "Matchen är över");
				System.exit(0);
			}
			computer.takePins(b);
			if(b.getNoPins() == 0) {
				userInterface.sendMessage("Tyvärr " + humanName + ", du förlorade!", "Matchen är över");
				System.exit(0);
			}
			else if(b.getNoPins()<0) {
				userInterface.sendMessage("Grattis " + humanName + ", datorn " + computerName + "sprack, så du vann!", "Matchen är över");
			}
		}	
	}
	
}
