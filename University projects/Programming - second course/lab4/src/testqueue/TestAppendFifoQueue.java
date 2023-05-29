package testqueue;

import static org.junit.jupiter.api.Assertions.*;

import java.util.NoSuchElementException;
import java.util.Queue;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import queue_singlelinkedlist.FifoQueue;

class TestAppendFifoQueue {
	private FifoQueue<Integer> firstQueue;
	private FifoQueue<Integer> secondQueue;
	
	@BeforeEach
	void setUp() throws Exception {
		firstQueue = new FifoQueue<Integer>();
		secondQueue = new FifoQueue<Integer>();
	}

	@AfterEach
	void tearDown() throws Exception {
		firstQueue = null;
		secondQueue = null;
	}
	@Test
	void testAppendToEmpty() {
		firstQueue.offer(1);
		firstQueue.offer(2);
		assertThrows(NoSuchElementException.class, () -> secondQueue.append(firstQueue));
	}
	
	@Test
	void testAppendEmpty() {
		firstQueue.offer(1);
		firstQueue.offer(2);
		assertThrows(NoSuchElementException.class, () -> firstQueue.append(secondQueue));
	}
	
	@Test
	void testAppendBothEmpty() {
		assertThrows(NoSuchElementException.class, () -> firstQueue.append(secondQueue));
	}
	
	@Test
	void testAppendNonEmpty() {
		firstQueue.offer(1);
		firstQueue.offer(2);
		secondQueue.offer(3);
		secondQueue.offer(4);
		firstQueue.append(secondQueue);
		assertTrue(firstQueue.size() == 4,"Wrong size after appending");
		for(int i = 1; i < 5; i++) {
			assertTrue(firstQueue.poll() == i,"Wrong order");
		}
		assertTrue(secondQueue.size() == 0,"The second list still exists!");
		
	}
	
	@Test
	void testAppendOnSelf() {
		firstQueue.offer(1);
		assertThrows(IllegalArgumentException.class, () -> firstQueue.append(firstQueue));
	}

}
