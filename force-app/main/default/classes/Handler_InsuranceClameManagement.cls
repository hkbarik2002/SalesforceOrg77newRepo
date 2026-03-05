public with sharing class Handler_InsuranceClameManagement {
    public static void creatClamePayoutRecords(List<Claim_Assessment__c> newAssessment) {
        if(Trigger.isUpdate){
            for(Claim_Assessment__c ca :newAssessment){
                if(ca.Recommendation__c == 'Approved'){
                    Helper_InsuranceClameManagement.creatClamePayoutRecord(newAssessment);
                }
            }
        }
        
    }
    public static void creatAssessmentRecords(List<Claim__c> newlistOfClaim){
        if(Trigger.isInsert || Trigger.isUpdate){
            for(Claim__c cla:newlistOfClaim){
                if(cla.Status__c == 'Under Review'){
                    Helper_InsuranceClameManagement.creatAssessmentRecord(newlistOfClaim);
                }
            }
        }
    }
    public static void checkIpRemainingamonts(List<Claim__c> listOfClaim){
        if(Trigger.isInsert){
            Helper_InsuranceClameManagement.checkIpRemainingamont(listOfClaim);
        }
    }
    public static void calculateTotalInusurancePolicys(list<InsurancePolicy__c> newListOfIp,Map<Id,InsurancePolicy__c> oldMapIp){
        if(trigger.isInsert || trigger.isDelete || trigger.isUndelete || trigger.isUpdate){
            //system.debug('newListOfIp>>>'+newListOfIp+'<<<oldMapIp>>>>'+oldMapIp);
            set<Id> setOfIp = new Set<Id>();
            if(newListOfIp != null && oldMapIp != null){
                //system.debug('Inside First If>>>');
                for(InsurancePolicy__c ipo:newListOfIp){
                    setOfIp.add(ipo.PolicyHolder__c  );
                }
            }
            //system.debug('setOfIp>>>'+ setOfIp);            
            if(newListOfIp == null && oldMapIp != null){
                //system.debug('Inside second If>>>');
                for(Id phoId :oldMapIp.keySet()){
                    //system.debug('phoId>>>'+phoId);
                    InsurancePolicy__c oldIpo =  oldMapIp.get(phoId);
                    //system.debug('oldIpo>>>'+oldIpo);
                    setOfIp.add(oldIpo.PolicyHolder__c  );
                }
            }
            Helper_InsuranceClameManagement.calculateTotalInusurancePolicy(setOfIp);
            Helper_InsuranceClameManagement.calculateTotalCoverageAmount(setOfIp);
        }
    }
}