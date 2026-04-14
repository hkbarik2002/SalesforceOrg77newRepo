trigger TriggerOnRepayment on Repayment__c (before insert) {
    if(trigger.isBefore){
        handlerOnLoan.handleRepayments(trigger.new);
    }
}