trigger TriggerOnLoan on Loan__c (after update) {
    if(trigger.isAfter){
        handlerOnLoan.insertRecord(trigger.new);
    }
}