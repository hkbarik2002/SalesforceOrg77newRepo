public class MyController {
    public String accountName { get; set; }
    
    // This list will not be stored in view state
    transient public List<Account> tempAccounts { get; set; }
    
    public MyController() {
        // Load accounts only once during construction
        tempAccounts = [SELECT Id, Name FROM Account LIMIT 10];
    }
    
    // Method to expose data to the page
    public List<Account> getAccounts() {
        return tempAccounts;
    }
}