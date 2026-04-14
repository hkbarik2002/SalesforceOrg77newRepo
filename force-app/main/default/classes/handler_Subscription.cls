public class handler_Subscription {
    public static Boolean isStatusUpdate = false;
    //public static Boolean isUpdated = false;
    public static void preventDeletionCheck(List<Subscription__c> NewSubObj,List<Subscription__c> oldlSubObj,map<Id,Subscription__c> oldmaplSubObj){
        // system.debug('oldlSubObj>>>'+oldlSubObj);
        If(trigger.isDelete){
            set<Id> subId = new set<Id>();
            for(Subscription__c su: oldlSubObj){
                subId.add(su.Id);
            }
            List<Subscription_Usage__c> listSubUs =  [SELECT  id from Subscription_Usage__c where SubscriptionId__c IN:subId];
            if(listSubUs.size() > 0){
                for(Subscription__c su: oldlSubObj){
                    su.addError('It has '+listSubUs.size()+' child record');
                }
            }
        }
        
        if(trigger.isInsert || trigger.isUpdate){
            for(Subscription__c Ns :NewSubObj){
                
                if(trigger.isInsert){
                    if(Ns.Status_c__c == 'Active'){
                        isStatusUpdate = true;
                    }
                }
                if(trigger.isUpdate){
                    if(Ns.Status_c__c != oldmaplSubObj.get(Ns.Id).Status_c__c || Ns.Customer__c != oldmaplSubObj.get(Ns.Id).Customer__c){
                        isStatusUpdate = true;
                    }
                }
            }
            
            // system.debug('>>>>isStatusUpdate>>'+isStatusUpdate);
            //system.debug('>>>>isUpdated1>>'+isUpdated);
            // Boolean isUpdated = false;
            if(isStatusUpdate ){
                Helper_Subscription.updateStatusField(NewSubObj,oldmaplSubObj);
                //system.debug('>>>>isUpdated2>>'+isUpdated);
            }
        }
        
    }
    public static void updateNextBillingDate(List<Subscription__c> NewSubObj){
        if(trigger.isInsert || trigger.isUpdate){
            Helper_Subscription.updateNextBillingDates(NewSubObj);
        }
    }
}