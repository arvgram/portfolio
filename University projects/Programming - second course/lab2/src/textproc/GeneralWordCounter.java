package textproc;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.List;
import java.util.ArrayList;

public class GeneralWordCounter implements TextProcessor {
	private Set<String> stopwords;
	private Map<String, Integer> map;

	public GeneralWordCounter(Set<String> stopwords) {
		this.stopwords = stopwords;
		this.map = new HashMap<String, Integer>(); 
	}

	@Override
	public void process(String w) {
		if(!stopwords.contains(w)) {
			if(map.containsKey(w)) {
				int oldVal = map.get(w);
				map.put(w, oldVal+1);
			}
			else {
				map.put(w, 1);
			}
		}
	}

	@Override
	public void report() {
		Set<Map.Entry<String, Integer>> wordSet = map.entrySet();
        List<Map.Entry<String, Integer>> wordList = new ArrayList<>(wordSet);
        
        
        wordList.sort((a,b) -> {
        	if (b.getValue() - a.getValue() == 0) {
        		return a.getKey().compareTo(b.getKey());
        	}
        	return b.getValue() - a.getValue();
        	}
        );
        
		for(int i = 0; i < 20;i++) {
			System.out.println(wordList.get(i));
		}
		
//		for(String key : map.keySet()) {
//			if(map.get(key) >= 200) {
//				System.out.println(key + ": " + map.get(key));
//			}
//		}
	}
	public List<Map.Entry<String, Integer>> getWordList() {
		List<Map.Entry<String, Integer>> tjena = new ArrayList<>(map.entrySet());
		return tjena;
	}

}
