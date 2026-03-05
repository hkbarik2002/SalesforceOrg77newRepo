public With sharing class Account360Controller {
    @AuraEnabled(cacheable = true)
    public static List<Account> getAccounts(){
        Set<Id> Accid = new Set<Id>();
        For(Account acc:[Select Id From Account]){
            For(Contact Con:[select AccountId From Contact Where AccountId =:acc.Id]){
                Accid.add(con.AccountId);
            }
            For(Opportunity opp:[select AccountId From Opportunity Where AccountId =:acc.Id]){
                Accid.add(opp.AccountId);
            }
        }
        List<Account> AccList = new List<Account>([Select Id,Name,Industry,AnnualRevenue From Account Where Id IN:Accid]);
        System.Debug(AccList);
        return AccList;
    }
    @AuraEnabled(cacheable = true)
    public Static wraperAccount360Controller accountRelatedObjectDetails(Id AccId){
        System.Debug('AccId>>'+ AccId);
        If(AccId != null){
            List<Contact> contactList = new List<Contact>([select Id , Name, Email From Contact Where AccountId =:AccId]);
            System.Debug('contactList>>'+ contactList);
            List<Opportunity> opportunityList = new List<Opportunity>([select Id , Name, StageName,Amount From Opportunity Where AccountId =:AccId]);
            System.Debug('opportunityList>>'+ opportunityList);
            wraperAccount360Controller wrp = new wraperAccount360Controller();
            wrp.conList = contactList;
            wrp.oppList = opportunityList;
            system.debug(wrp);
            return wrp;
        }else return null;
        
    }
    
    public class wraperAccount360Controller{
        @AuraEnabled public List<Contact> conList{get;set;}
        @AuraEnabled public List<Opportunity> oppList{get;set;}
    }
    @AuraEnabled
    public static void updateContacts(String changesJson) {
        List<Object> rawList1 = (List<Object>) JSON.deserializeUntyped(changesJson);
        system.debug('rawList1>>'+rawList1);
        try {
            if (String.isNotBlank(changesJson)) {
                List<Object> rawList = (List<Object>) JSON.deserializeUntyped(changesJson);
                List<Contact> contactsToUpdate = new List<Contact>();
                
                for (Object obj : rawList) {
                    Map<String, Object> item = (Map<String, Object>) obj;
                    System.debug('Item >>> ' + item);
                    
                    String contactIdStr = (String) item.get('contactId');
                    String newEmail = (String) item.get('contactEmail');
                    
                    // Validate ID before casting
                    if (String.isNotBlank(contactIdStr) && contactIdStr.length() == 18) {
                        Contact con = new Contact(
                            Id = contactIdStr,
                            Email = newEmail
                        );
                        contactsToUpdate.add(con);
                    } else {
                        System.debug('Skipping invalid contactId: ' + contactIdStr);
                    }
                }
                
                System.debug('contactsToUpdate >>> ' + contactsToUpdate);
                
                if (!contactsToUpdate.isEmpty()) {
                    update contactsToUpdate;
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error while updating contacts: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Opportunity creatOpportunity(Id accId , Opportunity opp){
        ///system.debug('accId>>>'+accId);
        //system.debug('opp>>>'+opp);
        opp.AccountId = accId;
        system.debug('opp>>>'+opp);
        insert opp;
        return opp;
    }
    
}