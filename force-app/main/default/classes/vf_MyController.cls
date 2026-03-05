public class vf_MyController {
    private Integer pageSize = 10;
    private Integer offset = 0;
    public List<Account> accounts { get; private set; }
    
    public vf_MyController() {
        loadAccounts();
    }
    
    public PageReference previous() {
        offset -= pageSize;
        loadAccounts();
        return null;
    }
    
    public PageReference next() {
        offset += pageSize;
        loadAccounts();
        return null;
    }
    
    private void loadAccounts() {
        accounts = [SELECT Id, Name, Industry, Phone FROM Account LIMIT :pageSize OFFSET :offset];
    }
}