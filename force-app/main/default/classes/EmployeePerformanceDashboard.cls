public with sharing class EmployeePerformanceDashboard {
    @AuraEnabled(cacheable = true)
    public static Integer totalEmployeePerformanceData(String department, Date fromDates,Date toDates){
       system.debug('department>>'+department+'fromDates>>'+fromDates+'toDates>>'+toDates);
        List<AggregateResult> Agr = [select Count(Id) totalId from Employee_Performance__c  where Department__c =:department AND (Review_Date__c >=: fromDates AND Review_Date__c <=: toDates )];
        Integer totalRecord;
        For(AggregateResult ag:Agr){
            totalRecord = (Integer)ag.get('totalId');
        }
        if(totalRecord > 0){
            system.debug('totalRecord>>'+totalRecord);
            return totalRecord;
        }else return null;
    }
    @AuraEnabled
    public Static List<Employee_Performance__c> getEmployeePerformanceData(String department, Date fromDates,Date toDates,Integer pageSizes,Integer pageNumbers){
         system.debug('department>>'+department+'fromDates>>'+fromDates+'toDates>>'+toDates+'pageSizes'+pageSizes+'pageNumbers'+pageNumbers);
        Integer offset = (pageNumbers - 1)*pageSizes;
        List<Employee_Performance__c> listOfEp = [select Id,Employee_Name__c,Review_Date__c,Department__c,Rating__c from Employee_Performance__c  where Department__c =:department AND (Review_Date__c >=: fromDates AND Review_Date__c <=: toDates ) LIMIT: pageSizes OFFSET: offset];
        if(!listOfEp.isEmpty()){
            system.debug('listOfEp>>'+listOfEp);
            return listOfEp;
        }else return listOfEp;
    }
    @AuraEnabled
    public Static string updatePerformance(List<Employee_Performance__c> employPerformance){
        System.debug('employPerformance>>>>'+employPerformance);
        try{
            if(!employPerformance.isEmpty()){
                update employPerformance;
            }
            return 'Update SuccessFully';
        }catch(Exception e){
            throw new AuraHandledException( 'Unexpected exception>>: ' + e.getMessage() + 'Line number>>:' + e.getLineNumber());
        }
    }
}