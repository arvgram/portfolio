package cardreader;

//import java.util.Scanner;
public class UserTableTest {

	public static void main(String[] args) {
		UserTable ut = new UserTable();

		System.out.println("findTest74: " + ut.find(24074));
		System.out.println("findTest73: " + ut.find(24073));
		System.out.println("findByNameTest: " + ut.findByName("Jens Holmgren"));
		System.out.println("nbrTest: " + ut.getNbrUsers());
		System.out.println("findTestTest: " + ut.testFind());

	}

}
