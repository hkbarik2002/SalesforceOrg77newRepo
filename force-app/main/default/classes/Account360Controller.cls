public with sharing class Account360Controller {
  @AuraEnabled(cacheable=true)
  public static List<Account> getAccounts() {
    Set<Id> Accid = new Set<Id>();
    for (Account acc : [SELECT Id FROM Account]) {
      for (Contact Con : [
        SELECT AccountId
        FROM Contact
        WHERE AccountId = :acc.Id
      ]) {
        Accid.add(con.AccountId);
      }
      for (Opportunity opp : [
        SELECT AccountId
        FROM Opportunity
        WHERE AccountId = :acc.Id
      ]) {
        Accid.add(opp.AccountId);
      }
    }
    List<Account> AccList = new List<Account>(
      [SELECT Id, Name, Industry, AnnualRevenue FROM Account WHERE Id IN :Accid]
    );
    System.Debug(AccList);
    return AccList;
  }
  @AuraEnabled(cacheable=true)
  public static wraperAccount360Controller accountRelatedObjectDetails(
    Id AccId
  ) {
    System.Debug('AccId>>' + AccId);
    if (AccId != null) {
      List<Contact> contactList = new List<Contact>(
        [SELECT Id, Name, Email FROM Contact WHERE AccountId = :AccId]
      );
      System.Debug('contactList>>' + contactList);
      List<Opportunity> opportunityList = new List<Opportunity>(
        [
          SELECT Id, Name, StageName, Amount
          FROM Opportunity
          WHERE AccountId = :AccId
        ]
      );
      System.Debug('opportunityList>>' + opportunityList);
      wraperAccount360Controller wrp = new wraperAccount360Controller();
      wrp.conList = contactList;
      wrp.oppList = opportunityList;
      system.debug(wrp);
      return wrp;
    } else
      return null;
  }

  public class wraperAccount360Controller {
    @AuraEnabled
    public List<Contact> conList { get; set; }
    @AuraEnabled
    public List<Opportunity> oppList { get; set; }
  }
  @AuraEnabled
  public static void updateContacts(String changesJson) {
    List<Object> rawList1 = (List<Object>) JSON.deserializeUntyped(changesJson);
    system.debug('rawList1>>' + rawList1);
    try {
      if (String.isNotBlank(changesJson)) {
        List<Object> rawList = (List<Object>) JSON.deserializeUntyped(
          changesJson
        );
        List<Contact> contactsToUpdate = new List<Contact>();

        for (Object obj : rawList) {
          Map<String, Object> item = (Map<String, Object>) obj;
          System.debug('Item >>> ' + item);

          String contactIdStr = (String) item.get('contactId');
          String newEmail = (String) item.get('contactEmail');

          // Validate ID before casting
          if (String.isNotBlank(contactIdStr) && contactIdStr.length() == 18) {
            Contact con = new Contact(Id = contactIdStr, Email = newEmail);
            contactsToUpdate.add(con);
          } else {
            System.debug('Skipping invalid contactId: ' + contactIdStr);
          }
        }

        System.debug('contactsToUpdate >>> ' + contactsToUpdate);

        if (!contactsToUpdate.isEmpty()) {
          update contactsToUpdate;
        }
      }
    } catch (Exception e) {
      throw new AuraHandledException(
        'Error while updating contacts: ' + e.getMessage()
      );
    }
  }

  @AuraEnabled
  public static Opportunity creatOpportunity(Id accId, Opportunity opp) {
    ///system.debug('accId>>>'+accId);
    //system.debug('opp>>>'+opp);
    opp.AccountId = accId;
    system.debug('opp>>>' + opp);
    insert opp;
    return opp;
  }
}
