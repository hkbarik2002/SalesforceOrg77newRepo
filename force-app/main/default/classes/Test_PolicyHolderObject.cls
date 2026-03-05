@IsTest
public class Test_PolicyHolderObject {
    @testSetup
    static void setupdata(){
        List<Account> Acclist = new List<Account>{new Account(Name = 'Test1'),new Account(Name = 'Test2')};
            insert Acclist;
        
    }
    
    @IsTest
    static void posetiveInsertOperation(){
        List<Account> Acclist = [ select id from Account limit 10];
        PolicyHolder__c ph = new PolicyHolder__c(Name = 'Ph001',DOB__c = Date.valueOf('2009-10-12'),PH_Account__c = Acclist[0].Id,ContactEmail__c = 'Test001@gmail.com');
        insert ph;
    }
}