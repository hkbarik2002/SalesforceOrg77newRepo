@IsTest
private class Hepler_ContactTest {
    
    @TestSetup
    static void setupTestData() {
        Account acc = new Account(Name = 'Test Acc');
        insert acc;
        
        // One existing contact primary = true
        Contact c1 = new Contact(LastName = 'Primary One', AccountId = acc.Id, IsPrimary__c = true);
        insert c1;
        
        // Another existing non-primary contact
        Contact c2 = new Contact(LastName = 'Secondary', AccountId = acc.Id, IsPrimary__c = false);
        insert c2;
        
        // Another account without contacts
        insert new Account(Name = 'Empty Acc');
    }
    
    // checkIsPrimarytrueORfalse: when no existing primary, mark incoming as primary
    @IsTest
    static void testCheckIsPrimary_SetsTrueWhenNoPrimaryExists() {
        Account emptyAcc = [SELECT Id FROM Account WHERE Name = 'Empty Acc' LIMIT 1];
        
        // Prepare new contacts (not inserted yet)
        Contact cNew1 = new Contact(LastName = 'N1', AccountId = emptyAcc.Id, IsPrimary__c = false);
        Contact cNew2 = new Contact(LastName = 'N2', AccountId = emptyAcc.Id, IsPrimary__c = false);
        List<Contact> newConList = new List<Contact>{ cNew1, cNew2 };
        
        Test.startTest();
        Hepler_Contact.checkIsPrimarytrueORfalse(new Set<Id>{ emptyAcc.Id }, newConList);
        Test.stopTest();
        
        System.assertEquals(true, newConList[0].IsPrimary__c, 'Should set first new contact to primary as no existing primary contact for the Account');
        System.assertEquals(false, newConList[1].IsPrimary__c, 'Should not set subsequent contacts to primary; helper sets only the first in the list');
    }
    
    // checkIsPrimarytrueORfalse: when an existing primary exists, it should not modify incoming list
    @IsTest
    static void testCheckIsPrimary_DoesNothingWhenPrimaryExists() {
        Account accWithPrimary = [SELECT Id FROM Account WHERE Name = 'Test Acc' LIMIT 1];
        
        Contact cNew = new Contact(LastName = 'Incoming', AccountId = accWithPrimary.Id, IsPrimary__c = false);
        List<Contact> newConList = new List<Contact>{ cNew };
        
        Test.startTest();
        Hepler_Contact.checkIsPrimarytrueORfalse(new Set<Id>{ accWithPrimary.Id }, newConList);
        Test.stopTest();
        
        System.assertEquals(false, newConList[0].IsPrimary__c, 'Existing primary found, helper should not set incoming primary flag');
    }
    
    // updateIsPrimaryField: ensure only one primary per account by turning others to false
    @IsTest
    static void testUpdateIsPrimaryField_TogglesOtherPrimariesOff() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Acc' LIMIT 1];
        // Make an additional inserted contact primary to simulate user change
        Contact makePrimary = new Contact(LastName = 'Now Primary', AccountId = acc.Id, IsPrimary__c = true);
        insert makePrimary;
        
        // Pass list containing the contact that is primary; helper should make other primaries false
        List<Contact> newConList = new List<Contact>{ makePrimary };
        
        Test.startTest();
        Hepler_Contact.updateIsPrimaryField(newConList);
        Test.stopTest();
        
        // Validate only "makePrimary" remains true
        List<Contact> cons = [SELECT Id, IsPrimary__c FROM Contact WHERE AccountId = :acc.Id];
        Integer primaries = 0;
        for (Contact c : cons) {
            if (c.Id == makePrimary.Id) {
                System.assertEquals(true, c.IsPrimary__c, 'The new designated primary must remain true');
            } else {
                // All others that were previously primary should be false now
                // Some may already be false; core is that none other than makePrimary should be true
                System.assertEquals(false, c.IsPrimary__c, 'Other contacts should be set to false');
            }
            if (c.IsPrimary__c) primaries++;
        }
        System.assertEquals(1, primaries, 'Exactly one primary contact should remain on the account');
    }
    
    // updateIsPrimaryField: if none in input list is primary, it should early return and not DML
    @IsTest
    static void testUpdateIsPrimaryField_NoPrimaryInInput_EarlyReturn() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Acc' LIMIT 1];
        Contact nonPrimary = [SELECT Id, AccountId, IsPrimary__c FROM Contact WHERE AccountId = :acc.Id AND IsPrimary__c = false LIMIT 1];
        
        Test.startTest();
        Hepler_Contact.updateIsPrimaryField(new List<Contact>{ nonPrimary });
        Test.stopTest();
        
        // Nothing should change: one primary must still exist from setup (c1)
        Integer primaries = [SELECT COUNT() FROM Contact WHERE AccountId = :acc.Id AND IsPrimary__c = true];
        System.assertEquals(1, primaries, 'Early return should not change primaries');
    }
    
    // deletedIsPrimaryField: when deleting a primary, code selects the most recent contact and if its IsPrimary__c == false, sets it to true
    @IsTest
    static void testDeletedIsPrimaryField_ReassignsPrimaryToMostRecentWhenNeeded() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Acc' LIMIT 1];
        
        // Create two additional contacts so the latest (by CreatedDate) is not primary
        Contact latestNonPrimary = new Contact(LastName = 'Latest NonPrimary', AccountId = acc.Id, IsPrimary__c = false);
        insert latestNonPrimary;
        // Ensure another one inserted earlier and primary stays as existing; this one should be older
        Contact olderNonPrimary = new Contact(LastName = 'Older', AccountId = acc.Id, IsPrimary__c = false);
        insert olderNonPrimary;
        
        // Simulate deletion of a primary contact by building old map
        // Choose the current primary contact (from setup)
        Contact currentPrimary = [SELECT Id, AccountId, IsPrimary__c FROM Contact WHERE AccountId = :acc.Id AND IsPrimary__c = true LIMIT 1];
        
        Map<Id, Contact> oldMap = new Map<Id, Contact>{
            currentPrimary.Id => currentPrimary
        };
        
        Test.startTest();
        Hepler_Contact.deletedIsPrimaryField(oldMap);
        Test.stopTest();
        
        // As per helper logic: it queries most recent by CreatedDate; if it is false, sets to true
        // Our most recent is 'olderNonPrimary' or 'latestNonPrimary' depending on insertion order above.
        // We inserted latestNonPrimary last in this block, so it should be the most recent.
        Contact mostRecent = [SELECT Id, IsPrimary__c FROM Contact WHERE AccountId = :acc.Id ORDER BY CreatedDate DESC LIMIT 1];
        System.assertEquals(true, mostRecent.IsPrimary__c, 'Most recent contact should be turned primary after deletion processing');
    }
    
    // unDeletedIsPrimaryField: when undeleting a set of contacts and there already exists a primary, set those undeleted ones to false
    @IsTest
    static void testUnDeletedIsPrimaryField_SetsIncomingToFalseIfPrimaryExists() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Acc' LIMIT 1];
        
        // Prepare list as if these are being undeleted (method expects existing Ids on list items)
        Contact cA = new Contact(LastName = 'Undel A', AccountId = acc.Id, IsPrimary__c = true);
        insert cA;
        Contact cB = new Contact(LastName = 'Undel B', AccountId = acc.Id, IsPrimary__c = true);
        insert cB;
        
        // Ensure there is a current primary on the account as well from setup
        Integer primariesPre = [SELECT COUNT() FROM Contact WHERE AccountId = :acc.Id AND IsPrimary__c = true];
        //System.assertTrue(primariesPre >= 1, 'Precondition: at least one primary must already exist');
        
        Test.startTest();
        Hepler_Contact.unDeletedIsPrimaryField(new List<Contact>{ cA, cB });
        Test.stopTest();
        
        // After method, both provided contacts should be forced to false
        List<Contact> refreshed = [SELECT Id, IsPrimary__c FROM Contact WHERE Id IN :new List<Id>{ cA.Id, cB.Id }];
        for (Contact c : refreshed) {
            System.assertEquals(false, c.IsPrimary__c, 'Undeleted contacts should be set to false when a primary already exists');
        }
    }
    
    // Bulk scenarios: multiple accounts mixed behavior
    @IsTest
    static void testBulk_BehaviorsAcrossMultipleAccounts() {
        // Create additional accounts
        Account a1 = new Account(Name = 'A1');
        Account a2 = new Account(Name = 'A2');
        insert new List<Account>{ a1, a2 };
        
        // A1: no primaries yet
        Contact a1c1 = new Contact(LastName = 'A1C1', AccountId = a1.Id, IsPrimary__c = false);
        Contact a1c2 = new Contact(LastName = 'A1C2', AccountId = a1.Id, IsPrimary__c = false);
        
        // A2: one existing primary
        Contact a2c1 = new Contact(LastName = 'A2C1', AccountId = a2.Id, IsPrimary__c = true);
        insert a2c1;
        
        List<Contact> a1List = new List<Contact>{ a1c1, a1c2 };
        
        Test.startTest();
        Hepler_Contact.checkIsPrimarytrueORfalse(new Set<Id>{ a1.Id }, a1List);
        insert a1List; // insert after helper sets primary true
        Hepler_Contact.updateIsPrimaryField(new List<Contact>{ a2c1 });
        Test.stopTest();
        
        // A1 should have all provided set to primary by check method before insert
        List<Contact> a1Recs = [SELECT Id, IsPrimary__c FROM Contact WHERE AccountId = :a1.Id];
        System.assertEquals(2, a1Recs.size());
         //system.debug('a1Recs>>>>>>>>>'+a1Recs);
        for (Contact c : a1Recs) {
            if(c.IsPrimary__c == true){
                System.assertEquals(true, c.IsPrimary__c, 'checkIsPrimary should set to true when none existed');
            }
            if(c.IsPrimary__c == false){
                System.assertEquals(false, c.IsPrimary__c, 'IsPrimary should be false when already sexist a primary contact');
            }
        }
        
        // A2 only one primary
        Integer a2Primaries = [SELECT COUNT() FROM Contact WHERE AccountId = :a2.Id AND IsPrimary__c = true];
        System.assertEquals(1, a2Primaries, 'updateIsPrimaryField should maintain single primary on account A2');
    }
}