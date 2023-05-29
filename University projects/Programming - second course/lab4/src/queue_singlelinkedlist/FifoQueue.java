package queue_singlelinkedlist;
import java.util.*;

public class FifoQueue<E> extends AbstractQueue<E> implements Queue<E> {
	private QueueNode<E> last;
	private int size;

	public FifoQueue() {
		super();
		last = null;
		size = 0;
	}
	/**	
	 * Inserts the specified element into this queue, if possible
	 * post:	The specified element is added to the rear of this queue
	 * @param	e the element to insert
	 * @return	true if it was possible to add the element 
	 * 			to this queue, else false
	 */
	public boolean offer(E e) {
		if(this.size == 0) {
			QueueNode<E> newNode = new QueueNode<E>(e);
			last = newNode;
			newNode.next = last;
			this.size++;
			return true;
		} else {
			QueueNode<E> newNode = new QueueNode<E>(e);
			newNode.next = last.next;
			last.next = newNode;
			last = newNode;
			size++;
			return true;
		}		
	}
	
	/**	
	 * Returns the number of elements in this queue
	 * @return the number of elements in this queue
	 */
	public int size() {		
		return size;
	}
	
	/**	
	 * Retrieves, but does not remove, the head of this queue, 
	 * returning null if this queue is empty
	 * @return 	the head element of this queue, or null 
	 * 			if this queue is empty
	 */
	public E peek() {
		if(last == null) {
			return null;
		}
		return last.next.element;
	}

	/**	
	 * Retrieves and removes the head of this queue, 
	 * or null if this queue is empty.
	 * post:	the head of the queue is removed if it was not empty
	 * @return 	the head of this queue, or null if the queue is empty 
	 */
	public E poll() {
		if(size > 1) {
			E element = last.next.element;
			last.next = last.next.next;
			size--;
			return element;
		} else if(size == 1){
			E element = last.next.element;
			last.next = null;
			size--;
			return element;
		}
		return null;
	}
	/**
     * Appends the specified queue to this queue
     * post: all elements from the specified queue are appended
     * to this queue. The specified queue (q) is empty after the call.
     * @param q the queue to append
     * @throws IllegalArgumentException if this queue and q are identical
     */
	
	public void append(FifoQueue<E> q) {
		if(this.size < 1 || q.size < 1) {
			throw new NoSuchElementException("The queue is empty");
		}
		if(this.equals(q)) {
			throw new IllegalArgumentException("For some not very obvious reason you may in this example not append a queue to itself.");
		}
		QueueNode<E> tempNode = this.last.next;
		this.last.next = q.last.next;
		q.last.next = tempNode;
		this.last = q.last;
		this.size += q.size();
		q.last = null;
		q.size = 0;
	}
	
	/**	
	 * Returns an iterator over the elements in this queue
	 * @return an iterator over the elements in this queue
	 */	
	public Iterator<E> iterator() {
		return new QueueIterator();
	}
	
	private class QueueIterator implements Iterator<E>{
		private QueueNode<E> pos;
		
		private QueueIterator() {
			if(size > 0) {
				this.pos = last.next;
			} else {
				pos = null;
			}
		}

		@Override
		public boolean hasNext() {
//			if(pos == null || counter >= size) {
//				return false;
//			}
			return pos != null;
		}

		@Override
		public E next() {
			if(hasNext()) {
				E tempElement = pos.element;
				pos = pos.next;
				if(pos == last.next) {
					pos = null;
					//counter++;
				}
				return tempElement;
			}
			throw new NoSuchElementException("The list is empty");
		}

	}
	
	private static class QueueNode<E> {
		E element;
		QueueNode<E> next;

		private QueueNode(E x) {
			element = x;
			next = null;
		}
	}

}
