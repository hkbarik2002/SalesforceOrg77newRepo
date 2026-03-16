public class DemoTest {
    public static wrapper testMethods(integer a){
        wrapper wp = new wrapper();
       if(a==1){
            wp.str = 'Salesforce';
        }
        else if(a==2){
            wp.inte = 99;
        }
        else{
          wp.lint = new List<Integer>{1,2,3};
        }
        return wp;
    }
    public class wrapper{
        public integer inte;
        public String str;
        public List<Integer> lint;
    }
}