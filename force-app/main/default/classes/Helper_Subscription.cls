public class Helper_Subscription {
    public static Boolean hasAlreadyRun = false;
    public static void updateStatusField(List<Subscription__c> NewSubObj,map<Id,Subscription__c> oldmaplSubObj){
        //system.debug('>>>>NewSubObj>>'+NewSubObj);
        //system.debug('hasAlreadyRun>>>'+hasAlreadyRun);
        if(hasAlreadyRun){
            System.debug('Skipping because method already ran.');
            return;
        }
        hasAlreadyRun = true;  // Mark as executed
        
        Set<Id> AccID = new Set<Id>();
        for(Subscription__c su : NewSubObj){
            if(su.Status_c__c != 'Active'){
                continue;
            }
            if(su.Id != null && su.Customer__c != null){
                AccID.add(su.Customer__c);
            }
            if(su.Id != null && oldmaplSubObj.containsKey(su.Id)){
                Subscription__c oldSuRec = oldmaplSubObj.get(su.Id);
                Boolean statusChanged = su.Status_c__c != oldSuRec.Status_c__c;
                Boolean customerChanged = su.Customer__c != oldSuRec.Customer__c; 
                
                if((statusChanged || customerChanged) && su.Customer__c != null){
                    AccID.add(su.Customer__c);
                }
            }
        }
        if (AccID.isEmpty()) {
            return;
        }
        List<Subscription__c> updateStatus = new List<Subscription__c>();
        
        for(Subscription__c sub : [select id , Status_c__c from Subscription__c where Customer__c IN:AccID AND Status_c__c = 'Active']){
            
            sub.Status_c__c = 'Cancelled';
            updateStatus.add(sub);
        }
        // System.debug('updateStatus: ' + updateStatus);
        if(!updateStatus.isEmpty()){
            update updateStatus;
        }
    }
    public static void updateNextBillingDates(List<Subscription__c> NewSubObj){
        Set<Id> AccId = new Set<Id>();
        Map<Id,Date> newMapIdDate = new Map<Id,Date>();
        for(Subscription__c sub : NewSubObj){
            if(sub.Status_c__c != 'Active' && sub.Customer__c != null){
                return;
            }
            AccId.add(sub.Customer__c);
           // system.debug('sub.EndDate__c>>>'+sub.EndDate__c);
            Date subEndDate = sub.EndDate__c.addDays(30);
           // system.debug('subEndDate>>>'+subEndDate);
            newMapIdDate.put(sub.Customer__c,newMapIdDate.containsKey(sub.Customer__c)?newMapIdDate.get(sub.Customer__c):subEndDate);
        }
       // system.debug('newMapIdDate>>>'+newMapIdDate);
        List<Account> acclist = new List<Account>();
        For(Account acc:[select id,NextSubBillDate__c from Account where Id IN:AccId]){
            Date newData = newMapIdDate.get(acc.Id);
            acc.NextSubBillDate__c = newData;
            acclist.add(acc);
        }
       // system.debug('acclist>>>'+acclist);
        if(!acclist.isEmpty()){
            update acclist;
        }
    }
}