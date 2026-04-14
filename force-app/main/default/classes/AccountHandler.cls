public class AccountHandler {
    public static void fierAccountPlatformEvent(List<Account> accList,Map<Id,Account> oldAccMap){
        System.debug('accList>>>'+accList);
        System.debug('oldAccMap>>>'+oldAccMap);
        List<Account_Update_Event__e> events = new List<Account_Update_Event__e>();
        for (Account acc : accList) {
            Account oldAcc = oldAccMap.get(acc.Id);
            
            // Fire event only if something changed (e.g., Name)
            if (acc.Industry != oldAcc.Industry || acc.Industry != null) {
                events.add(new Account_Update_Event__e(
                    Message__c = 'Account updated: ' + acc.Name
                ));
            }
        }
        
        if (!events.isEmpty()) {
            Database.SaveResult[] results = EventBus.publish(events);
            System.debug('Published ' + results.size() + ' events.');
        }
    }
    public static void preventAccountDeletionProcess(List<Account> oldAccList){
        //system.debug('oldAccList>>>>>'+oldAccList);
        Set<Id> accId = new Set<Id>();
        For(Account acc:oldAccList){
            accId.add(acc.Id);
        }
        list<Opportunity> oppList = [SELECT  id ,Name,StageName from Opportunity  where AccountId IN:accId and StageName NOT IN('Closed Lost' ,'Closed Won')];
        if(!oppList.isEmpty()){
            For(Account acc:oldAccList){
                acc.addError('Account Have Open Opportunities');
            }
        }
    }
    static boolean isRunThisMethod = false;
    public static void copyAccBillAddToShipAdd(List<Account> accList,Map<Id,Account> oldAccMap){
        if(isRunThisMethod){
            return;
        }
        isRunThisMethod = true;
        AccountHelper.copyAccBillAddreToShipAdd(accList,oldAccMap);
        
    }
    public static void updateWebsuteOnAccount(List<Account> AccList){
        Map<Id,string> mapAccid = new  Map<Id,string>();
        for(Account ac : AccList){
            if(!mapAccid.containsKey(ac.Id)){
            mapAccid.put(ac.Id,ac.Website);
            }
        }
        List<Contact> conlist = [select id,Company_Website__c,AccountId from Contact Where AccountId In:mapAccid.keySet()];
        List<Contact> contList = new List<Contact>();
        for(Contact con : conlist){
            contact c = new Contact(Id = con.Id,Company_Website__c = mapAccid.get(con.AccountId));
            contList.add(c);
        }
        if(!contList.isEmpty()){
            update contList;
        }
    }
    
    public static void ownerUpdateMethod(List<Account> accList,Map<Id,Account> oldAccMap,Map<Id,Account> newAccMap){
        if(trigger.isUpdate){
            Set<Id> AccId = new Set<Id>();
            for(Account acc : accList){
                if(acc.OwnerId != oldAccMap.get(acc.Id).OwnerId){
                   AccId.add(acc.Id); 
                }
            }
            
            List<Opportunity> updateOppList = new List<Opportunity>();
            for(Opportunity opp : [Select id,OwnerId,AccountId from Opportunity where AccountId In:AccId]){
                if(opp.OwnerId != oldAccMap.get(opp.AccountId).OwnerId){
                    opp.OwnerId = newAccMap.get(opp.AccountId).OwnerId;
                    updateOppList.add(opp);
                }
            }
            if(!updateOppList.isEmpty()){
                update updateOppList;
            }
        }
    }
}