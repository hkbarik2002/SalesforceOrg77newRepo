public class handlerOnLoan {
    public static void insertRecord(List<Loan__c> newLoanList){
        if(trigger.isUpdate){
            helperOnLoan.insertRepayment(newLoanList);
            helperOnLoan.rejectRepayment(newLoanList);
        }
    }
    public static void handleRepayments(List<Repayment__c> newRepayments){
        if(trigger.isInsert){
            helperOnLoan.helpRepayment(newRepayments);
        }
    }
}