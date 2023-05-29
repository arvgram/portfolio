package textproc;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.HashSet;
import java.util.Scanner;
import java.util.Set;

public class BookReaderApplication {

	public static void main(String[] args) throws FileNotFoundException {
		Scanner scan = new Scanner(new File("exceptionwords.txt"));
		Set<String> stopwords = new HashSet<String>();
		while(scan.hasNext()){
			String w = scan.next().toLowerCase();
			stopwords.add(w);
		}
		
		GeneralWordCounter gwc = new GeneralWordCounter(stopwords);
		
		Scanner s = new Scanner(new File("nilsholg.txt"));
		s.findWithinHorizon("\uFEFF", 1);
		s.useDelimiter("(\\s|,|\\.|:|;|!|\\?|'|\\\")+");
		while (s.hasNext()) {
			String word = s.next().toLowerCase();
			gwc.process(word);
		}
		s.close();
		
		BookReaderController brc = new BookReaderController(gwc);
		

	}

}
