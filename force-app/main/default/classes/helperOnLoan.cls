public class helperOnLoan {
    public static void insertRepayment(List<Loan__c> newLoanList){
        List<Repayment__c> repay = new List<Repayment__c>();
        for(Loan__c loan:newLoanList){
            if(loan.Status__c == 'Approved'){
                Repayment__c repm = new Repayment__c(Payment_Date__c = date.today(),Loan__c = loan.Id,Amount_Paid__c = 0,Remaining_Balance__c = loan.Amount__c);
                repay.add(repm);
            }
        }
        try{
            if(!repay.isEmpty()){
                insert repay;
            }
        }
        catch(Exception e){
            for(Loan__c loan : newLoanList){
                loan.addError('Failed to create repayment record: ' + e.getMessage());
            }
        }
    }
    
    public static void rejectRepayment(List<Loan__c> newLoanList){
        for(Loan__c lon:newLoanList){
            if(lon.Status__c == 'Reject'){
                lon.addError('Cannot create repayment for Rejected Loan.');
                continue;
            }
        }
    }
    
    public static void helpRepayment(List<Repayment__c> newRepayments){
        Set<Id> loanIds = new Set<Id>();
        for(Repayment__c rpm:newRepayments){
            loanIds.add(rpm.Loan__c); 
        }
        Map<Id,Repayment__c> mapOfRepayment = new Map<Id,Repayment__c>();
        for(Repayment__c rm : [select Loan__c, Payment_Date__c,Remaining_Balance__c from  Repayment__c where Loan__c In: loanIds ORDER BY Remaining_Balance__c ASC limit 1]){
            if(!mapOfRepayment.containsKey(rm.Loan__c)){
                mapOfRepayment.put(rm.Loan__c,rm);
            }                
        }
        // system.debug('mapOfRepayment>>'+mapOfRepayment);
        List<Loan__c> loansToUpdate = new List<Loan__c>();
        List<Penalty__c> penalties = new List<Penalty__c>();
        Map<Id,list<Loan__c>> loanMap = new Map<Id,list<Loan__c>>();
        for(loan__c lon :[ select id,Status__c from Loan__c where Id =:loanIds]){
            if(!loanMap.containsKey(lon.Id)){
                loanMap.put(lon.Id,new list<Loan__c>());
            }
            loanMap.get(lon.Id).add(lon);
        }
        
        try{
            for(Repayment__c rep:newRepayments){
                Repayment__c repm = mapOfRepayment.get(rep.Loan__c);
                //system.debug('repm>>'+repm+'>>'+ rep.Amount_Paid__c);
                if(repm != null && repm.Remaining_Balance__c > rep.Amount_Paid__c){
                    //system.debug('Remaining_Balance__c>>'+ repm.Remaining_Balance__c +' '+rep.Amount_Paid__c);
                    Decimal newBalance = repm.Remaining_Balance__c - rep.Amount_Paid__c;
                    rep.Remaining_Balance__c = (newBalance <= 0) ? 0 : newBalance;
                }
                //system.debug('repm>>'+ rep.Remaining_Balance__c);
                if( rep.Remaining_Balance__c == null || rep.Remaining_Balance__c <= 0){
                    //list<Loan__c> loanData = loanMap.get(rep.Loan__c);
                    for(Loan__c lo :loanMap.get(rep.Loan__c)){
                        lo.Status__c = 'Closed';
                        // system.debug('lo>>>'+lo);
                        loansToUpdate.add(lo);
                    }
                }
                //Date lastPaymentDate = repm?.Payment_Date__c != null ?repm.Payment_Date__c.addDays(30):date.today();
                date lastPaymentDate;
                if (repm != null && repm.Payment_Date__c != null) {
                    lastPaymentDate = repm.Payment_Date__c.addDays(30);
                } else {
                    lastPaymentDate = Date.today();
                }
                //system.debug('date>>'+rep.Payment_Date__c+'>>>'+lastPaymentDate);
                if(rep.Payment_Date__c != null && rep.Payment_Date__c > lastPaymentDate){
                    penalties.add(new Penalty__c(
                        Loan__c = rep.Loan__c,
                        Repayment__c = rep.Id,
                        Amount__c = 500,
                        Reason__c = 'Late Payment',
                        Penalty_Date__c = rep.Payment_Date__c
                    ));
                }
            }
            if(!loansToUpdate.isEmpty()){
                //system.debug('up>>');
                update loansToUpdate;
            }
            if(!penalties.isEmpty()){
                // system.debug('In>>');
                insert penalties;
            }
        }
        catch(Exception e){
            for(Repayment__c rep : newRepayments){
                rep.addError('Failed to create repayment record: ' + e.getMessage());
                rep.addError('Line number: ' + e.getLineNumber());
            }
        }  
    }
}