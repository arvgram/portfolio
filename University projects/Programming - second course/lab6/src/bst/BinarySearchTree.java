package bst;


import java.util.ArrayList;
import java.util.Comparator;


public class BinarySearchTree<E> {
	BinaryNode<E> root;  // Används också i BSTVisaulizer
	int size;            // Används också i BSTVisaulizer
	private Comparator<E> comparator;
	boolean hasComp;
	
	public static void main(String[] args) {
		BinarySearchTree<String> bstString = new BinarySearchTree<String>();
		BinarySearchTree<Integer> bstInt = new BinarySearchTree<Integer>((a,b) -> a - b);
		
		int[] integers = {5, 3, 1, 6, 3, 1, 4, 10, 2, 7, 8, 9};
		String[] strings = {"Arvid", "Hoppohej", "A", "B", "Öl"};
		
		for(int i:integers) {
			bstInt.add(i);
		}
		for(String s: strings) {
			bstString.add(s);
		}
		
		bstInt.rebuild();
		bstInt.printTree();
		
		bstString.rebuild();
		bstString.printTree();
		
		BSTVisualizer bstIntVis = new BSTVisualizer("Strings, normal order", 500, 500);
		BSTVisualizer bstStringVis = new BSTVisualizer("Integer, reversed order", 500, 500);
		bstStringVis.drawTree(bstString);
		bstIntVis.drawTree(bstInt);
		
	}
	/**
	 * Constructs an empty binary search tree.
	 */
	public BinarySearchTree() {
		this.hasComp = false;
		this.root = null;
		this.size = 0;
	}
	
	/**
	 * Constructs an empty binary search tree, sorted according to the specified comparator.
	 */
	public BinarySearchTree(Comparator<E> comparator) {
		this.comparator = comparator;
		this.hasComp = true;
		this.root = null;
		this.size = 0;
	}
	
	/**
	 * Displaying a tree
	 */
	public void displayTree() {
		
	}
	
	/**
	 * For laboration presentation purposes
	 */
	public static void displayLaboration() {
		BinarySearchTree<String> bst = new BinarySearchTree<String>();
		BinarySearchTree<Integer> bstRev = new BinarySearchTree<Integer>((a,b) -> b - a);
		
		int[] integers = {5, 3, 1, 6, 3, 1, 4, 10, 2, 7, 8, 9};
		String[] strings = {"Arvid", "Hoppohej", "A", "B", "Öl"};
		
		for(int i:integers) {
			bstRev.add(i);
		}
		for(String s: strings) {
			bst.add(s);
		}
		
		
		BSTVisualizer bstVis = new BSTVisualizer("Strings, normal order", 500, 500);
		BSTVisualizer bstRevVis = new BSTVisualizer("Integer, reversed order", 500, 500);
		bstVis.drawTree(bst);
		bstRevVis.drawTree(bstRev);
		
		bst.printTree();
		bstRev.printTree();
		
	}

	/**
	 * Inserts the specified element in the tree if no duplicate exists.
	 * @param x element to be inserted
	 * @return true if the the element was inserted
	 */
	public boolean add(E x) {
		if(root == null) {
			root = new BinaryNode<E>(x);
			size++;
			return true;
		}
		return add(x, root);
	}
	
	/**
	 * Private help method to insert element i tree
	 * @param x the element to be inserted
	 * @param n current node
	 * @return true of element was inserted, else false
	 */

	@SuppressWarnings("unchecked")
	private boolean add(E x, BinaryNode<E> n) {
		int comp;
		if(hasComp) {
			comp = comparator.compare(x, n.element);
		} else {
			comp = ((Comparable<E>) x).compareTo(n.element);
		}
		
		if(comp < 0) {
			if(n.left == null) {
				n.left = new BinaryNode<E>(x);
				this.size++;
				return true;
			} else {
				return add(x, n.left);
			}
		}
		
		if(comp > 0) {
			if(n.right == null) {
				n.right = new BinaryNode<E>(x);
				this.size++;
				return true;
			} else {
				return add(x,n.right);
			}
		}
		
		return false;
	}
	
	/**
	 * Computes the height of tree.
	 * @return the height of the tree
	 */
	public int height() {
		// use a recursive method that computes the depth from a node n. Starting at root.
		return height(root);
	}
	
	/**
	 * Private help method. returns the height of the heighest subtree from node n
	 * @param n the node that is root of said subtree
	 * @return the height of the tree with root n
	 */
	private int height(BinaryNode<E> n) {
		if(n != null) {
			return 1 + Math.max(height(n.left),height(n.right));
		}
		return 0;
	}
	
	/**
	 * Returns the number of elements in this tree.
	 * @return the number of elements in this tree
	 */
	public int size() {
		return size;
	}
	
	/**
	 * Removes all of the elements from this list.
	 */
	public void clear() {
		this.root = null;
		size = 0;
	}
	
	/**
	 * Print tree contents in inorder.
	 */
	public void printTree() {
		printTree(root);
	}
	
	private void printTree(BinaryNode <E> n) {
		if(n != null) {
			printTree(n.left);
			System.out.println(n.element);
			printTree(n.right);
		}
	}

	/** 
	 * Builds a complete tree from the elements in the tree.
	 */
	public void rebuild() {
		ArrayList<E> sorted = new ArrayList<E>();
		toArray(root,sorted);
		root = buildTree(sorted, 0, sorted.size()-1);
	}
	
	//This is just for me to test my toArray-method
	public void testArray() {
		ArrayList<E> list = new ArrayList<E>();
		toArray(root,list);
		for(E entry:list) {
			System.out.println(entry);
		}
	}
	
	/*
	 * Adds all elements from the tree rooted at n in inorder to the list sorted.
	 */
	private void toArray(BinaryNode<E> n, ArrayList<E> sorted) {
		if(n != null) {
			toArray(n.left, sorted);
			sorted.add(n.element);
			toArray(n.right,sorted);
		}
	}
	
	
	/*
	 * Builds a complete tree from the elements from position first to 
	 * last in the list sorted.
	 * Elements in the list a are assumed to be in ascending order.
	 * Returns the root of tree.
	 */
	private BinaryNode<E> buildTree(ArrayList<E> sorted, int first, int last) {		
		int mid = first+(last-first)/2;
		if(last >= first) {
			BinaryNode<E> temp = new BinaryNode<E>(sorted.get(mid));
			temp.left = buildTree(sorted,first,mid-1);
			temp.right = buildTree(sorted,mid+1,last);
			return temp;
		}
		return null;
	}

	static class BinaryNode<E> {
		E element;
		BinaryNode<E> left;
		BinaryNode<E> right;

		private BinaryNode(E element) {
			this.element = element;
		}	
	}
	
}
