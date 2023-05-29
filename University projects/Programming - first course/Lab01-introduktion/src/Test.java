import java.util.Scanner;
public class Test {    public static void main(String[] args) {
    Scanner scan = new Scanner(System.in);
    int[] a = new int[10];
    for (int i = 0; i < 10; i++){
        a[i] = scan.nextInt();
    }
      for (int k = 9; k > 0; k--){
        System.out.println(a[k]);
    }
}

}
