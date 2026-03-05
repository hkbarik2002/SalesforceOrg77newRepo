public class RenewalOpportunityHandler implements Queueable {
    List<Opportunity> qualifiedOpp = new List<Opportunity>();
    public RenewalOpportunityHandler(List<Opportunity> qualifiedOpps){
        this.qualifiedOpp = qualifiedOpps;
    }
    public void execute(QueueableContext context){
        List<Opportunity> renewalsToCreate = new List<Opportunity>();
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for(Opportunity opp : qualifiedOpp){
            Date renewalCloseDate = opp.CloseDate.addYears(1).addDays(-90);
            Opportunity renewal = new Opportunity(
                Name = 'Renewal - ' + opp.Name,
                StageName = 'Prospecting',
                CloseDate = renewalCloseDate,
                Amount = opp.Amount,
                AccountId = opp.AccountId,
                OwnerId = opp.OwnerId
            );
            renewalsToCreate.add(renewal);
            
            // Prepare Email Notification
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(opp.OwnerId);
            mail.setSaveAsActivity(false);
            mail.setSubject('Renewal Created: ' + renewal.Name);
            mail.setPlainTextBody('A renewal opportunity has been created for ' + opp.Name + '. The expected close date is ' + renewalCloseDate);
            emails.add(mail);
        }
        if (!renewalsToCreate.isEmpty()) {
            insert renewalsToCreate;
            Messaging.sendEmail(emails);
        }
    }
}