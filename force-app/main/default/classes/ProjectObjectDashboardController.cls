public with sharing class ProjectObjectDashboardController {
    @AuraEnabled
    public static List<wrapperClass> FatchProjectData(String selectedStatus){
        List<wrapperClass> wc1 = new List<wrapperClass>();
        if(selectedStatus != null){
            List<Project__c > listOfProject = [Select Id,Name,Project_Manager__r.Name,Budget__c from Project__c where Status__c =:selectedStatus];
            for(Project__c pj : listOfProject){
                wrapperClass wc2 = new wrapperClass();
                wc2.ids = pj.Id;
                wc2.Name = pj.Name;
                wc2.pmName = pj.Project_Manager__r.Name;
                wc2.budget = pj.Budget__c;
                wc1.add(wc2);
            } 
        }
        if(!wc1.isEmpty()){
            system.debug(wc1);
            return wc1;
        }else return wc1;
    }
    @AuraEnabled
    Public Static List<wrapperClass> FatchProjectTaskData(Id pId){
        List<wrapperClass> listWrapper = new List<wrapperClass>();
        List<Project_Task__c > listPt = [SELECT Id ,Name__c,Project__r.Name,Status__c,Assigned_To__r.Name FROM Project_Task__c where Project__r.Id =:pId];
        for(Project_Task__c pt : listPt){
            wrapperClass wc = new wrapperClass();
            wc.ids = pt.Id;
            wc.Name = pt.Name__c;
            wc.pmName = pt.Project__r.Name;
            wc.status = pt.Status__c;
            wc.AuName = pt.Assigned_To__r.Name;
            listWrapper.add(wc);
            
        }
        if(!listWrapper.isEmpty()){
            return listWrapper;
        }else return listWrapper;
    }
    @AuraEnabled(cacheable = true)
    public static List<User> getUserDetail(){
        return [SELECT Id,name FROM User where IsActive  = true];
    }
    @AuraEnabled
    public static string creatNewProjectTask(Id proId,String ptname ,Id ptuser ,String ptStatus ){
        //system.debug('>>>'+proId+'>>>'+ptname+'>>>'+ptuser+'>>>'+ptStatus);
        if(ptname != null && ptuser != null && ptStatus != null){
            Project_Task__c  newPTast = new Project_Task__c (Project__c = proId,Name__c = ptname,Assigned_To__c = ptuser,Status__c = ptStatus);
            //system.debug('>>>'+newPTast);
            insert newPTast;
            return 'New project task just creat now';
        }else return 'New project task fail to creat';
    }
    @AuraEnabled
    public static string updateProTaskRecord(List<sObject> listPTask){
        //system.debug('>>>'+listPTask);
        if(!listPTask.isEmpty()){
            update listPTask;
            return 'Sucess';
        }else return 'Update fail';
    }
    @AuraEnabled
    public static void deleteProject(Id pId){
        //system.debug('>>>P'+pId);
        Project__c pro = [select id,Name from Project__c where Id =: pId];
        if(pro != null){
            delete pro;
        }
    }
    
    
    public class wrapperClass{
        @AuraEnabled public Id ids{get;set;}
        @AuraEnabled public String Name{get;set;}
        @AuraEnabled public String pmName{get;set;}
        @AuraEnabled public String AuName{get;set;}
        @AuraEnabled public String status{get;set;}
        @AuraEnabled public Decimal budget{get;set;}
        
    }
}