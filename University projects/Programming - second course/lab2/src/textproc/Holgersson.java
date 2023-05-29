package textproc;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Scanner;
import java.util.Set;

public class Holgersson {

	public static final String[] REGIONS = { "blekinge", "bohuslän", "dalarna", "dalsland", "gotland", "gästrikland",
			"halland", "hälsingland", "härjedalen", "jämtland", "lappland", "medelpad", "närke", "skåne", "småland",
			"södermanland", "uppland", "värmland", "västerbotten", "västergötland", "västmanland", "ångermanland",
			"öland", "östergötland" };

	public static void main(String[] args) throws FileNotFoundException {
		long t0 = System.nanoTime();
		
		
		ArrayList<TextProcessor> list = new ArrayList<TextProcessor>();
		
		TextProcessor nils = new SingleWordCounter("nils");
		TextProcessor norge = new SingleWordCounter("norge");
		TextProcessor multi = new MultiWordCounter(REGIONS);
	
		Scanner scan = new Scanner(new File("undantagsord.txt"));
		Set<String> stopwords = new HashSet<String>();
		
		while(scan.hasNext()){
			String w = scan.next().toLowerCase();
			stopwords.add(w);
		}
		TextProcessor gw = new GeneralWordCounter(stopwords);
		
		
		list.add(nils);
		list.add(norge);
		list.add(multi);
		list.add(gw);

		Scanner s = new Scanner(new File("nilsholg.txt"));
		s.findWithinHorizon("\uFEFF", 1);
		s.useDelimiter("(\\s|,|\\.|:|;|!|\\?|'|\\\")+"); // se handledning

		while (s.hasNext()) {
			String word = s.next().toLowerCase();
			for(TextProcessor tp : list) {
				tp.process(word);
			}
		}

		s.close();
		for(TextProcessor tp : list) {
			tp.report();
		}
		long t1 = System.nanoTime();
		System.out.println("tid: " + (t1 - t0) / 1000000.0 + " ms");

	}
}