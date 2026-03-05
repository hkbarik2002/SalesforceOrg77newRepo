public with sharing class LoanRepaymentPortalController {
    @AuraEnabled(cacheable = true)
    public static list<loan__c> getApprovedLoans(){
        try {
            return [select Id,name,Status__c from Loan__c where Status__c = 'Approved' ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static loanWrapper1 fetchRemainingAmount(Id lonIds){
        system.debug('lds>>>'+ lonIds);
        try {
            loanWrapper1 lw = new loanWrapper1();
            for(Loan__c lo:[SELECT Id,Name, Status__c, (select Remaining_Balance__c,Payment_Date__c  from Repayments__r  order by Remaining_Balance__c  ASC limit 1) FROM Loan__c WHERE Id =:lonIds]){
                // loanWrapper1 lw = new loanWrapper1();
                lw.Name = lo.Name;
                lw.Status = lo.Status__c;
                lw.RemainAmount = lo.Repayments__r[0].Remaining_Balance__c;
                lw.nextDueDateLabel = lo.Repayments__r[0].Payment_Date__c.addDays(30);
                // return lw;
            }
            return lw;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static map<Id,loanWrapper2> RepaymentAndPenalty(Id lonId){
        try{
            Loan__c loan = [SELECT Id FROM Loan__c WHERE Id =: lonId LIMIT 1];
            loanWrapper2 lw2 = new loanWrapper2();
            map<Id,loanWrapper2> mapwrapper2 = new map<Id,loanWrapper2>();
            lw2.listOfRepayment = [SELECT Name,Payment_Date__c, Amount_Paid__c from Repayment__c  where Loan__c =: lonId ];
            lw2.listOfPenalty = [SELECT Name ,Penalty_Date__c, Amount__c,Reason__c from Penalty__c where Loan__c =:lonId];
            
            if(lw2 != null){
                mapwrapper2.put(lonId,lw2);
                system.debug('mapwrapper2>>>'+mapwrapper2);
                return mapwrapper2;
            }else return mapwrapper2;
        }catch(Exception e){
            throw new AuraHandledException('Data not Found'+ e);
        }
    }
    @AuraEnabled
    public static date creatNewRepayment(Id lonId, Decimal rAmount,Date rDate ){
        try {
            Loan__c loan = [SELECT Id FROM Loan__c WHERE Id =: lonId LIMIT 1];
            System.debug('D>>>>>'+lonId+'>>'+rAmount+'>>'+rDate);
            if(lonId != null && rAmount != null && rDate != null){
                Repayment__c rp = new Repayment__c(Loan__c = lonId,Amount_Paid__c = rAmount, Payment_Date__c = rDate);
                if(rp != null){
                    insert rp;
                }
            }
            Date  newDate = rDate.addDays(30);
            return newDate;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<loanWrapper3> getActiveLoans(){
        try {
            List<loanWrapper3> resLlw = new List<loanWrapper3>();
            for(Loan__c lo:[SELECT Id ,Name, Status__c, Amount__c, (select id ,Amount_Paid__c from Repayments__r order by Amount_Paid__c  ASC) FROM Loan__c  where Status__c ='Approved' ]){
                Decimal totalRepaid = 0;
                for(Repayment__c rep : lo.Repayments__r){
                    totalRepaid += rep.Amount_Paid__c;
                }
                Decimal outstandingBalance = lo.Amount__c - totalRepaid;
                resLlw.add(new loanWrapper3(lo.Id,lo.Name,lo.Status__c,lo.Amount__c,totalRepaid,outstandingBalance));
            }
            if(!resLlw.isEmpty()){
                system.debug('resLlw>>>'+resLlw);
                return resLlw;
            }else return resLlw;
            
        } catch (Exception e) {
            system.debug('Line number>>>'+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public class loanWrapper1{
        @AuraEnabled public string Name{get;set;}
        @AuraEnabled public string Status{get;set;}
        @AuraEnabled public Decimal RemainAmount{get;set;}
        @AuraEnabled public Date nextDueDateLabel{get;set;}
    }
    public class loanWrapper2{
        @AuraEnabled public List<Repayment__c > listOfRepayment{get;set;}
        @AuraEnabled public List<Penalty__c  > listOfPenalty{get;set;}
    }
    public class loanWrapper3{
        @AuraEnabled public Id lonId;
        @AuraEnabled public string loanName;
        @AuraEnabled public string status;
        @AuraEnabled public Decimal originalAmount;
        @AuraEnabled public Decimal totalRepaid;
        @AuraEnabled public Decimal outstandingBalance;
        public loanWrapper3(Id lonId, String loanName, String status, Decimal originalAmount, Decimal totalRepaid, Decimal outstandingBalance) {
            this.lonId = lonId;
            this.loanName = loanName;
            this.status = status;
            this.originalAmount = originalAmount;
            this.totalRepaid = totalRepaid;
            this.outstandingBalance = outstandingBalance;
        }
    }
}