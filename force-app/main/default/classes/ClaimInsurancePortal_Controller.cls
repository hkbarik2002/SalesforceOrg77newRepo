public with sharing class ClaimInsurancePortal_Controller {
    @AuraEnabled
    public static List<PolicyHolder__c> getPolicyHolder(){
        try {
            return [SELECT Id,Name FROM PolicyHolder__c ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static PolicyHolder__c  creatNewPolicyHolder(PolicyHolder__c poho){
        try {
            // system.debug('poho>>>'+poho);
            if(poho == null){
                throw new AuraHandledException('Policy Holder details are null');
            }
            insert poho;
            return poho;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static list<InsurancePolicy__c> searchInsurancePolicies(Id pohol){
        try {
            // system.debug('pohol>>>'+pohol);
            if(pohol == null){
                throw new AuraHandledException('Policy Holder Id is null');
            }
            return [SELECT Id,Policy_Type__c,Status__c,Coverage_Amount__c,ValidFrom__c,ValidTo__c,RemainingCoverage__c FROM InsurancePolicy__c  WHERE PolicyHolder__c =:pohol AND Status__c ='Active' ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<Claim__c> fetchClaimData(Id ipoId){
        try {
            if(ipoId == null){
                throw new AuraHandledException('Insurance policy Id is null');
            }
            return [SELECT Id,Claim_Amount__c,ClaimDate__c, Status__c FROM Claim__c WHERE  Insurance_Policy__c =:ipoId AND (Status__c  ='Under Review'  OR Status__c ='Approved' )];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<string> getClaimStatus(){
        List<String> asString = new List<String>();
        Schema.DescribeFieldResult field = 	Claim__c.Status__c.getDescribe();
        for(Schema.PicklistEntry sp : field.getPicklistValues()){
            asString.add(sp.getLabel());
        }
        if(!asString.isEmpty()){
            return asString;
        }else return asString;
    }
    @AuraEnabled
    public static Claim__c creatNewClaimRecord( Claim__c newClaimData , Id clRecId){
        try {
            system.debug('newClaimData>>>>>>>>>'+newClaimData+'>>>clRecId>>>>>'+clRecId);
            if(newClaimData != null && clRecId != null){
                // throw new AuraHandledException('Claim details are null');
                newClaimData.Id = clRecId;
                update newClaimData;
                return newClaimData;
            }else{
                insert newClaimData;
                return newClaimData;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<string> getInpStatusField(){
        List<String> inpStatusString = new List<String>();
        Schema.DescribeFieldResult field = 	InsurancePolicy__c.Status__c.getDescribe();
        for(Schema.PicklistEntry sp : field.getPicklistValues()){
            inpStatusString.add(sp.getLabel());
        }
        if(!inpStatusString.isEmpty()){
            return inpStatusString;
        }else return inpStatusString;
    }
    @AuraEnabled
    public static List<string> getInpPoliTypeField(){
        List<String> inpPoTypeString = new List<String>();
        Schema.DescribeFieldResult field = 	InsurancePolicy__c.Policy_Type__c.getDescribe();
        for(Schema.PicklistEntry sp : field.getPicklistValues()){
            inpPoTypeString.add(sp.getLabel());
        }
        if(!inpPoTypeString.isEmpty()){
            return inpPoTypeString;
        }else return inpPoTypeString;
    }
    
    @AuraEnabled
    public static InsurancePolicy__c insertNewInsuPolicy( InsurancePolicy__c newInsuPoliData,Id inpoId){
        try {
            system.debug('newInsuPoliData>>>>>>>>>'+newInsuPoliData+'>>>>inpoId>>>>'+inpoId);
            if(newInsuPoliData != null && inpoId != null){
                newInsuPoliData.Id = inpoId;
                update newInsuPoliData;
                return newInsuPoliData;
            }else{
                
                insert newInsuPoliData;
                return newInsuPoliData;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static WrapperClass GetAssAndClaPayout(Id calimId){
        try {
            if(calimId == null){
                throw new AuraHandledException('Id Showed null');
            }
            WrapperClass wa = new WrapperClass();
            wa.listOfAssessment = [select Id,AssessmentDate__c,VerifiedAmount__c,Recommendation__c from Claim_Assessment__c where Claim__c =:calimId AND (Recommendation__c = 'Pending Review' OR Recommendation__c = 'Approved')];
            wa.listOfPayout = [select Id,PayoutAmount__c,Payment_Status__c from Claim_Payout__c where Claim__c=: calimId];
            
            if(wa != null){
                system.debug('wa>>>>>>>>>>>>>>>>>>>>'+wa);
                return wa;
            }else return wa;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<string> getRecommendationField(){
        List<String> inpPoTypeString = new List<String>();
        Schema.DescribeFieldResult field = 	Claim_Assessment__c.Recommendation__c.getDescribe();
        for(Schema.PicklistEntry sp : field.getPicklistValues()){
            inpPoTypeString.add(sp.getLabel());
        }
        if(!inpPoTypeString.isEmpty()){
            return inpPoTypeString;
        }else return inpPoTypeString;
    }
    @AuraEnabled
    public static Claim_Assessment__c udateAssesmentData( Claim_Assessment__c assessUpdateData){
        try {
            system.debug('assessUpdateData>>>>>>>>>'+assessUpdateData);
            if(assessUpdateData == null ){
                throw new AuraHandledException('Update Assessment Data null');
            }
            update assessUpdateData;
            return assessUpdateData;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public class WrapperClass{
        @AuraEnabled public list<Claim_Assessment__c> listOfAssessment{get;set;}
        @AuraEnabled public list<Claim_Payout__c  > listOfPayout{get;set;}
    }
}