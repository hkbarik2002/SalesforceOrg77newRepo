public with sharing class AccountDataService {
    @AuraEnabled(cacheable = true)
    public static AccountDataServiceWrapper getPaginatedAccountsWithOpps(Integer pageSize, Integer offsets) {
        AccountDataServiceWrapper adsw = new AccountDataServiceWrapper();
        // accountRows already initialized in wrapper constructor, no need to reassign here
        
        Set<Id> accountIds = new Set<Id>();
        List<Account> accList = [
            SELECT Id, Name 
            FROM Account 
            WHERE Id IN (
                SELECT AccountId 
                FROM Opportunity 
                WHERE Amount != null AND AccountId != null
            )
            ORDER BY Name ASC
            LIMIT :pageSize
            OFFSET :offsets
        ];
        
        for (Account acc : accList) {
            accountIds.add(acc.Id);
        }
        
        // Aggregate Opp totals and latest close date by Account
        Map<Id, Decimal> accountTotalAmounts = new Map<Id, Decimal>();
        Map<Id, Date> accountLatestCloseDates = new Map<Id, Date>();
        for (AggregateResult ar : [
            SELECT AccountId aId, SUM(Amount) totalAmount, MAX(CloseDate) latestClose
            FROM Opportunity
            WHERE AccountId IN :accountIds
            GROUP BY AccountId
        ]) {
            Id aId = (Id) ar.get('aId');
            accountTotalAmounts.put(aId, (Decimal) ar.get('totalAmount'));
            accountLatestCloseDates.put(aId, (Date) ar.get('latestClose'));
        }
        
        for (Account acc : accList) {
            Decimal total = accountTotalAmounts.containsKey(acc.Id) ? accountTotalAmounts.get(acc.Id) : 0;
            Date latest = accountLatestCloseDates.containsKey(acc.Id) ? accountLatestCloseDates.get(acc.Id) : null;
            adsw.accountRows.add(new AccountRow(acc.Id, acc.Name, total, latest));
        }
        
        List<AggregateResult> agr = [
            SELECT COUNT_DISTINCT(AccountId) cnt
            FROM Opportunity
            WHERE Amount != null AND AccountId != null
        ];
        adsw.totalCount = agr.isEmpty() ? 0 : (Integer) agr[0].get('cnt');
        
        return adsw;
    }
    
    // --- moved out so inner types are siblings (not nested inside wrapper) ---
    public class AccountRow {
        @AuraEnabled public Id accountId;
        @AuraEnabled public String accountName;
        @AuraEnabled public Decimal totalOpportunityAmount;
        @AuraEnabled public Date latestOpportunityCloseDate;
        
        public AccountRow(Id accountId, String accountName, Decimal totalOpportunityAmount, Date latestOpportunityCloseDate) {
            this.accountId = accountId;
            this.accountName = accountName;
            this.totalOpportunityAmount = totalOpportunityAmount;
            this.latestOpportunityCloseDate = latestOpportunityCloseDate;
        }
    }
    
    public class AccountDataServiceWrapper {
        @AuraEnabled public Integer totalCount;
        @AuraEnabled public List<AccountRow> accountRows;
        
        public AccountDataServiceWrapper() {
            this.totalCount = 0;
            this.accountRows = new List<AccountRow>();
        }
    }
}