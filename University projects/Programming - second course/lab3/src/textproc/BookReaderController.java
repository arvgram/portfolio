package textproc;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Container;
import java.awt.Dimension;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.List;
import java.util.Map;

import javax.swing.*;
import javax.swing.JFrame;
import javax.swing.SwingUtilities;
import javax.swing.text.Position;
import javax.swing.JList;
import javax.swing.JPanel;
import javax.swing.JScrollPane;


public class BookReaderController {

	public BookReaderController(GeneralWordCounter counter) {
		SwingUtilities.invokeLater(() -> createWindow(counter,"Bookreader", 100, 300));		
	}
	
	private void createWindow(GeneralWordCounter counter, String title, int width, int height) {
		JFrame frame = new JFrame(title);
		frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		
		Container pane = frame.getContentPane();
		
		List<Map.Entry<String, Integer>> listInput = counter.getWordList();
		SortedListModel<Map.Entry<String, Integer>> listModel = new SortedListModel<Map.Entry<String, Integer>>(listInput);
		
		JPanel southPanel = new JPanel();
//		JButton alpha = new JButton("Alphabetic");
//		JButton freq = new JButton("Frequentetic");
		
		JRadioButton alpha = new JRadioButton("Alphabetic");
		JRadioButton freq = new JRadioButton("Frequentetic");
		
		freq.addActionListener(event -> listModel.sort((a,b) -> b.getValue().compareTo(a.getValue())));
		alpha.addActionListener(event -> listModel.sort((a,b) -> a.getKey().compareTo(b.getKey())));
		
		ButtonGroup bg = new ButtonGroup();
		bg.add(freq);
		bg.add(alpha);
	
		southPanel.add(alpha);
		southPanel.add(freq);
		
		
		
		JList<Map.Entry<String, Integer>> jList = new JList<Map.Entry<String, Integer>>(listModel);
		JScrollPane scrollPane = new JScrollPane(jList);
		
		pane.add(scrollPane, BorderLayout.NORTH);
		pane.add(southPanel, BorderLayout.SOUTH);
		
		JTextField textfield = new JTextField();
		textfield.setPreferredSize(new Dimension(100,26));
		JPanel centralPanel = new JPanel();
		JButton search = new JButton("Search");
		
		//search.addActionListener(new ActionListener(){
		search.addActionListener(a -> {
		//	   public void actionPerformed(ActionEvent ae){
	      String textFieldValue = textfield.getText();
	      String cleanText = textFieldValue.strip();
	      String lowerCaseClean = cleanText.toLowerCase();
	      int index = jList.getNextMatch(lowerCaseClean, 0, Position.Bias.Forward);
	      if(index > 0) {
	    	  jList.ensureIndexIsVisible(index);
	    	  jList.setSelectedIndex(index);
	    	  jList.setSelectionBackground(Color.blue);
	      } else if (index == -1) {
	    	  JOptionPane.showMessageDialog(frame,
	    			    "Ordet finns inte i listan.");
	      }
		});
		
		centralPanel.add(textfield);
		centralPanel.add(search);
	
		pane.add(centralPanel, BorderLayout.CENTER);
		frame.pack();
		frame.setVisible(true);
	}
	

}
