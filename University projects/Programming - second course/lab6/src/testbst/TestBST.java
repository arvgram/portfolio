package testbst;

import static org.junit.jupiter.api.Assertions.*;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import bst.BinarySearchTree;

class TestBST {
	BinarySearchTree<Integer> bstCompRev;
	BinarySearchTree<Integer> bstComp;
	BinarySearchTree<String> bstNoComp;

	@BeforeEach
	void setUp() {
		
		this.bstNoComp = new BinarySearchTree<String>();
		
		this.bstComp = new BinarySearchTree<Integer>((a,b) -> a - b);
		// testing a lambda expression that should sort in reverse order
		this.bstCompRev = new BinarySearchTree<Integer>((a,b) -> b - a);
		
	}

	@AfterEach
	void tearDown() {
		bstNoComp.clear();
		bstComp.clear();
		bstCompRev.clear();
	}

	@Test
	void testNewBST() {
		assertEquals(0,bstNoComp.size());
		assertEquals(0,bstNoComp.height());
	}
	
	@Test
	void testAddExisting() {
		bstNoComp.add("Tjena");
		assertFalse(bstNoComp.add("Tjena"));
	}
	
	@Test
	void testAddHeight() {
		bstComp.add(4);
		bstComp.add(5);
		bstComp.add(1);
		bstComp.add(2);
		assertTrue(bstComp.add(9));
		bstComp.add(3);
		bstComp.add(8);
		bstComp.add(6);
		bstComp.add(7);
		bstComp.add(8);
		assertFalse(bstComp.add(8));
		bstComp.add(8);
		assertEquals(6,bstComp.height());
		
		bstNoComp.add("Arvid");
		bstNoComp.add("Tjoho");
		bstNoComp.add("Hej");
		bstNoComp.add("Programmering");
		bstNoComp.add("Tjoho");
		assertEquals(4,bstNoComp.height());
		
	}
	
	@Test
	void testClear() {
		bstComp.add(6);
		bstComp.add(7);
		bstComp.add(8);
		bstComp.add(8);
		bstComp.add(8);
		bstComp.clear();
		assertEquals(0,bstComp.height());
		assertEquals(0,bstComp.size());
		
		bstNoComp.add("Tjoho");
		bstNoComp.add("Hej");
		bstNoComp.add("Programmering");
		bstNoComp.add("Tjoho");
		bstNoComp.clear();
		assertEquals(0,bstNoComp.height());
		assertEquals(0,bstNoComp.size());
	}
	

}
