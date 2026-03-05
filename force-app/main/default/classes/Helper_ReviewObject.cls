public with sharing class Helper_ReviewObject {
    public Static void updateReviewCount(List<Review__c> lestReview){
        Set<Id> accId = new Set<Id>();
        for(Review__c rv1:lestReview){
            accId.add(rv1.Account__c);
        }
        List<Account> acc1 =[select id,CountReview__c,(select id,Name  from Reviews__r) from Account where Id =:accId];
        Map<Id,list<Review__c>> conRevMap = new Map<Id,list<Review__c>>();
        for(Account acc2: acc1){
            if (!conRevMap.containsKey(acc2.Id)) {
                conRevMap.put(acc2.Id, new List<Review__c>());
            }
            for(Review__c rv2 : acc2.Reviews__r){
                conRevMap.get(acc2.Id).add(rv2);
            }
        }
        List<Account> accountsToUpdate = new List<Account>();
        for (Id accIdKey : conRevMap.keySet()) {
            Integer reviewCount = conRevMap.get(accIdKey).size();
            accountsToUpdate.add(new Account(Id = accIdKey, CountReview__c = reviewCount));
        }
        try{
            if(!accountsToUpdate.isEmpty()){
                update accountsToUpdate;
                system.debug('Update Sucessfully');
            }
        } catch (DmlException e) {
            System.debug('Error while updating accounts: ' + e.getMessage());
        }
        
    }
    Public static void checkEmailDuplicate(List<Review__c> emailList){
        Set<Id> idss = new Set<Id>();
        for(Review__c Rv1 : emailList){
            idss.add(rv1.Id);
        }
        system.debug('idss>>'+idss);
        Map<string,Review__c> mapEmailrv = new Map<string,Review__c>();
        for(Review__c rv1:[select id,Email__c from Review__c where Email__c != Null And Id NOT IN:idss]){
            //system.debug('rv1>>'+rv1);
            if(!mapEmailrv.containsKey(rv1.Email__c)){
                mapEmailrv.put(rv1.Email__c,rv1);
            }
        }
        for(Review__c rv2 : emailList){
            //system.debug('rv2>>'+rv2.Email__c);
            if(mapEmailrv.containsKey(rv2.Email__c)){
                rv2.addError('Emal:'+rv2.Email__c+' Already Exist');
            }
        }
    }
}