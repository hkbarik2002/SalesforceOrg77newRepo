public class handler_PolicyHolderObject {
    public static void countTotalPolicyHolders(List<PolicyHolder__c> newPhList,map<Id,PolicyHolder__c> oldphMap,List<PolicyHolder__c> oldPhList){
        Set<Id> pHAId = new Set<Id>();
        if(trigger.isInsert || trigger.isUndelete || trigger.isUpdate){
            for(PolicyHolder__c po:newPhList){
                PolicyHolder__c opo = oldphMap != null && oldphMap.containsKey(po.Id)?oldphMap.get(po.Id):null;
                if(opo != null && opo.PH_Account__c != po.PH_Account__c){
                    pHAId.add(po.PH_Account__c);
                    pHAId.add(opo.PH_Account__c);
                }else{
                    pHAId.add(po.PH_Account__c);
                }
            }
            helper_PolicyHolderObject.countTotalPolicyHolder(pHAId);
        }
        if(trigger.isDelete){
            for(PolicyHolder__c po:oldPhList){
                pHAId.add(po.PH_Account__c);
            }
            helper_PolicyHolderObject.countTotalPolicyHolder(pHAId);
        }
    }
    
    public static void checkEmailFiels(List<PolicyHolder__c> newPhList,map<Id,PolicyHolder__c> oldphMap){
        if(trigger.isInsert || trigger.isUpdate){
            List<String> listEmails = new List<String>();
            string sEmail;
            for(PolicyHolder__c po :newPhList){ 
                sEmail = po.ContactEmail__c != null && oldphMap != null && oldphMap.containsKey(po.Id)?oldphMap.get(po.Id).ContactEmail__c:null;
                if(sEmail != null && sEmail == po.ContactEmail__c){
                    listEmails.add(sEmail);
                }
                else{
                    listEmails.add(po.ContactEmail__c);
                }
            }
            helper_PolicyHolderObject.checkEmailFiel(newPhList,listEmails,oldphMap);
        }
    }
}