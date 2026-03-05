public class handler_OnCaseObject {
    public static void creatJobAndJobLine(List<Case> newCaseList,Map<Id,Case> newCaseMap, Map<Id,Case> oldCaseMap){
        Set<Id> setOfCaseId = new Set<Id>();
        for(Case ca : newCaseList){
            if(ca.CaseApproval_Status__c == 'Pending' &&  oldCaseMap.get(ca.Id).CaseApproval_Status__c == 'Approved'){
                ca.addError('You cannot change the case Approval status');
                break;
            }
            if(ca.Status == 'Open' && ca.CaseApproval_Status__c == 'Approved' && oldCaseMap.get(ca.Id).CaseApproval_Status__c == 'Pending'){
                setOfCaseId.add(ca.Id);
            }
        }
        creatNewJob(setOfCaseId,newCaseMap);
    }
    public static void creatNewJob(Set<Id> setOfCaseId,Map<Id,Case> newCaseMap){
            List<Job__c> newJobList = new List<Job__c>();
            for(Id cId :setOfCaseId){
                if(newCaseMap != null){
                    Case nCase = newCaseMap.containsKey(cId) ? newCaseMap.get(cId): null;
                    If(nCase != null){
                        Job__c j = new Job__c(Job_Name__c = 'Job for '+nCase.CaseNumber,Case__c = nCase.Id, Job_Status__c = 'Open');
                        newJobList.add(j);
                    }
                }
            }
            if(newJobList != null){
                insert newJobList;
            }
            List<Job_Line__c> newListOfJobLine = new List<Job_Line__c>();
            if(newJobList != null){
                for(Job__c job :newJobList){
                    Job_Line__c jl = new Job_Line__c(Job__c = job.Id,Job_Line_Status__c = 'Open',Job_Line_Description__c = 'Job lisne for '+job.Job_Name__c);
                    newListOfJobLine.add(jl);
                }
            }
            if(newListOfJobLine != null){
                insert newListOfJobLine;
            }
        
    }
}