public with sharing class Lwc_Practice_map_1_Controller {
    // @AuraEnabled(cacheable=true)
    // public static Map<Id, List<Contact>> getAccountContactsMap() {
        //     Map<Id, List<Contact>> resultMap = new Map<Id, List<Contact>>();
        //     List<Account> accounts = [
        //      SELECT Id, Name, (SELECT Id, Name, Email FROM Contacts)
        //     FROM Account where Id In(select AccountId From Contact where AccountId != null)
        // ];
        
        //     for (Account acc : accounts) {
            //         resultMap.put(acc.Id, acc.Contacts);
        //     }
        //     return resultMap;
    // }
    
    /*@AuraEnabled(cacheable=true)
    public static Map<Id, List<Opportunity>> getOpportunitiesByUser() {
        Map<Id, List<Opportunity>> userOppMap = new Map<Id, List<Opportunity>>();
        
        List<Opportunity> opps = [
        SELECT Id, Name, Amount, StageName, OwnerId
        FROM Opportunity
        WHERE StageName IN ('Prospecting', 'Negotiation')
        ORDER BY Amount DESC
    ];
        
        for (Opportunity opp : opps) {
            if (!userOppMap.containsKey(opp.OwnerId)) {
                userOppMap.put(opp.OwnerId, new List<Opportunity>());
            }
            userOppMap.get(opp.OwnerId).add(opp);
        }
        
        return userOppMap;
    }*/
    @AuraEnabled(cacheable=true)
    public static List<Contact> getAllContacts() {
        return [SELECT Id, Name, Email, AccountId, Account.Name FROM Contact WHERE AccountId != null LIMIT 3];
    }
}