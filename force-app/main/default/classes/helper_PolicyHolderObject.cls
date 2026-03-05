public class helper_PolicyHolderObject {
    public static void countTotalPolicyHolder(Set<Id> pHAId){
        try{
            if (pHAId == null || pHAId.isEmpty()) {
                return;
            }
            
            List<AggregateResult> listAgr =[SELECT PH_Account__c,COUNT(Id) TotalPH FROM PolicyHolder__c   WHERE  PH_Account__c In:pHAId GROUP BY PH_Account__c];
            List<Account> AccList = new List<Account>();
            for(AggregateResult ag:listAgr){
                Id AId = (Id)ag.get('PH_Account__c');
                Integer tPh = (Integer)ag.get('TotalPH');
                Account acc = new Account(Id = AId,Total_policyholder__c = tPh);
                AccList.add(acc);
            }
            if(!AccList.isEmpty()){
                update AccList;
            }
            
        }catch(Exception e){
            System.debug('exception>>'+e.getLineNumber()+' '+e.getMessage());
        }
    }
    public static void checkEmailFiel(List<PolicyHolder__c> newPhList,List<String> listEmails,map<Id,PolicyHolder__c> oldphMap){
        if(newPhList.isEmpty() && listEmails.isEmpty() && oldphMap.isEmpty()){
            return;
        }
        try{
            Map<String, List<PolicyHolder__c>> existingByEmail = new Map<String, List<PolicyHolder__c>>();
            for(PolicyHolder__c newPoli : [select id,ContactEmail__c from PolicyHolder__c where ContactEmail__c != null AND ContactEmail__c IN:listEmails]){
                String key = newPoli.ContactEmail__c != null?newPoli.ContactEmail__c.trim().toLowerCase():null;
                if(key != null){
                    existingByEmail.put(key, new List<PolicyHolder__c>());
                    existingByEmail.get(key).add(newPoli);
                }
            }
            for(PolicyHolder__c ph : newPhList){
                String newKey = ph.ContactEmail__c.trim().toLowerCase();
                string oldKey ;
                if(oldphMap != null && oldphMap.containsKey(ph.Id) && oldphMap.get(ph.Id).ContactEmail__c != null){
                    oldKey = oldphMap.get(ph.Id).ContactEmail__c.trim().toLowerCase();
                }
                if(oldKey != null && oldKey == newKey){
                    continue;
                }
                List<PolicyHolder__c> matches = existingByEmail.get(newKey);
                if (matches == null || matches.isEmpty()) {
                    continue;
                }
                Boolean dupByOther = false;
                for (PolicyHolder__c match : matches) {
                    if (match.Id != ph.Id) {
                        dupByOther = true;
                        break;
                    }
                }
                if (dupByOther) {
                    ph.addError('A Policy Holder with this Email already exists and is Active.');
                }
            }
        }
        catch(Exception e){
            System.debug('exception>>'+e.getLineNumber()+' '+e.getMessage());
        }
    }
}