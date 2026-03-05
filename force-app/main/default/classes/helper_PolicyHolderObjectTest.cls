@IsTest
private class helper_PolicyHolderObjectTest {
    
    @testSetup
    static void setupData() {
        // Create two Accounts to aggregate PolicyHolder__c into
        Account a1 = new Account(Name = 'Acct One');
        Account a2 = new Account(Name = 'Acct Two');
        insert new List<Account>{ a1, a2 };
        
        // Create Policy Holders for countTotalPolicyHolder tests
        // a1 - 2 policy holders; a2 - 1 policy holder
        List<PolicyHolder__c> phs = new List<PolicyHolder__c>{
            new PolicyHolder__c(Name = 'PH1-A1', PH_Account__c = a1.Id, ContactEmail__c = 'ph1a1@test.com', DOB__c = Date.newInstance(1990, 1, 1)),
            new PolicyHolder__c(Name = 'PH2-A1', PH_Account__c = a1.Id, ContactEmail__c = 'ph2a1@test.com', DOB__c = Date.newInstance(1991, 2, 2)),
            new PolicyHolder__c(Name = 'PH1-A2', PH_Account__c = a2.Id, ContactEmail__c = 'ph1a2@test.com', DOB__c = Date.newInstance(1992, 3, 3))
        };
        insert phs;
    }
    
    @IsTest
    static void test_countTotalPolicyHolder_updatesTotals() {
        // Arrange
        Account a1 = [SELECT Id, Total_policyholder__c FROM Account WHERE Name = 'Acct One' LIMIT 1];
        Account a2 = [SELECT Id, Total_policyholder__c FROM Account WHERE Name = 'Acct Two' LIMIT 1];
        
        // Ensure fields start empty/null (field may be Number, default null or 0; do not assert here)
        Set<Id> accIds = new Set<Id>{ a1.Id, a2.Id };
        
        Test.startTest();
        helper_PolicyHolderObject.countTotalPolicyHolder(accIds);
        Test.stopTest();
        
        // Assert
        Map<Id, Account> refreshed = new Map<Id, Account>([
            SELECT Id, Total_policyholder__c
            FROM Account
            WHERE Id IN :accIds
        ]);
        System.assertEquals(2, (Integer)refreshed.get(a1.Id).Total_policyholder__c,
        'Account One should reflect 2 policy holders.');
        System.assertEquals(1, (Integer)refreshed.get(a2.Id).Total_policyholder__c,
        'Account Two should reflect 1 policy holder.');
    }
    
    @IsTest
    static void test_checkEmailFiel_newInsert_conflictingEmail_addsError() {
        // Create an additional PolicyHolder with duplicate email to trigger conflict for new records
        Account a = [SELECT Id FROM Account WHERE Name = 'Acct One' LIMIT 1];
        PolicyHolder__c existing = new PolicyHolder__c(
            Name = 'Existing Email Holder',
        PH_Account__c = a.Id,
        ContactEmail__c = 'dup@test.com',
        DOB__c = Date.newInstance(1985, 5, 5)
            );
        insert existing;
        
        // New records trying to insert with same email should receive addError
        PolicyHolder__c toInsert1 = new PolicyHolder__c(
            Name = 'New PH 1',
        PH_Account__c = a.Id,
        ContactEmail__c = 'dup@test.com',
        DOB__c = Date.newInstance(1986, 6, 6)
            );
        PolicyHolder__c toInsert2 = new PolicyHolder__c(
            Name = 'New PH 2',
        PH_Account__c = a.Id,
        ContactEmail__c = 'dup@test.com',
        DOB__c = Date.newInstance(1987, 7, 7)
            );
        
        List<PolicyHolder__c> newList = new List<PolicyHolder__c>{ toInsert1, toInsert2 };
        List<String> emails = new List<String>{ 'dup@test.com' };
        
        Test.startTest();
        // Invoke helper directly; this should add errors on the in-memory records
        helper_PolicyHolderObject.checkEmailFiel(newList, emails, null);
        Test.stopTest();
        
        // Since addError marks records with errors, attempting DML should fail
        Boolean dmlFailed = false;
        try {
            insert newList;
        } catch (DmlException e) {
            dmlFailed = true;
            System.assert(e.getMessage().contains('A Policy Holder with this Email already exists'),
            'Expected duplicate email message for new insert case.');
        }
        System.assertEquals(true, dmlFailed, 'Insert must fail due to addError on duplicate email.');
    }
    
    @IsTest
    static void test_checkEmailFiel_noConflicts_allowsDml() {
        // When no records exist with provided emails, helper should not add any errors
        Account a = [SELECT Id FROM Account WHERE Name = 'Acct One' LIMIT 1];
        
        PolicyHolder__c ph = new PolicyHolder__c(
            Name = 'No Conflict',
        PH_Account__c = a.Id,
        ContactEmail__c = 'unique_email@test.com',
        DOB__c = Date.newInstance(1999, 12, 31)
            );
        
        List<PolicyHolder__c> newList = new List<PolicyHolder__c>{ ph };
        List<String> emails = new List<String>{ 'unique_email@test.com' };
        
        Test.startTest();
        // Since there is no pre-existing PH with this email, SOQL inside helper returns empty and no addError should be called
        helper_PolicyHolderObject.checkEmailFiel(newList, emails, null);
        insert newList; // should succeed
        Test.stopTest();
        
        PolicyHolder__c inserted = [SELECT Id, ContactEmail__c FROM PolicyHolder__c WHERE Id = :newList[0].Id];
        System.assertEquals('unique_email@test.com', inserted.ContactEmail__c, 'Record should insert successfully without errors.');
    }
}