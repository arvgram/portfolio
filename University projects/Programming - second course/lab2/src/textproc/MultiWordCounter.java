package textproc;

import java.util.HashMap;
import java.util.Map;
import java.util.TreeMap;

public class MultiWordCounter implements TextProcessor {
	private Map<String, Integer> map;

	public MultiWordCounter(String[] words) {
		map = new HashMap<String, Integer>();
		for(String word : words) {
			map.put(word, 0);
		}
	}

	@Override
	public void process(String w) {
		if(map.containsKey(w)) {
			int oldVal = map.get(w);
			map.put(w, oldVal+1);
		}
	}

	@Override
	public void report() {
		for(String key : map.keySet()) {
			System.out.println(key + ": " + map.get(key));
		}

	}

}
