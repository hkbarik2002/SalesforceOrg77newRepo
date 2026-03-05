public class CSVGenerator {
    public static void creatCSVandMail(string AccId){
        List<Opportunity> oppList = [select id,name,StageName,account.Owner.email from opportunity where accountId =:AccId];
        String csvString = 'Opportunity Id,Opportunity Name,Opportunity Stage\n';
        
        for(Opportunity opp : oppList){
            csvString = csvString+opp.id+','+opp.Name+','+opp.StageName+'\n';
        }
        system.debug('csvString>>>>'+csvString);
        
        Messaging.EmailFileAttachment csvFile = new Messaging.EmailFileAttachment();
        csvFile.setfileName('Opportunitydata.csv');
        csvFile.setbody(blob.valueOf(csvString));
        
        messaging.singleEmailMessage emailDate = new messaging.singleEmailMessage();
        emailDate.setToaddresses(new List<String>{oppList[0].account.Owner.email});
        emailDate.setSubject('Opportunity Related Data');
        emailDate.setFileAttachments(new List<Messaging.EmailFileAttachment>{csvFile});
        emailDate.setPlainTextbody('Please find attached required opportunity details');
        messaging.sendEmail(new List<Messaging.singleEmailmessage>{emailDate});
    }
}