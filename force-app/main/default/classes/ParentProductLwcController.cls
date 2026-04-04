public with sharing class ParentProductLwcController {
    @AuraEnabled(cacheable=true)
    public static List<ProductWrapper> getAllProduct(String inputData) {
        List<ProductWrapper> listOfWrapper = new List<ProductWrapper>();
        
        try {
            // 1. Prepare the query parameters
            Id standardPriceBookId = '01sNS000005DrN0YAK';
            String searchKey;
            String query = 'SELECT Product2Id, Product2.Name, UnitPrice FROM PricebookEntry WHERE IsActive = true AND Pricebook2Id = :standardPriceBookId';
            
            // 2. Decide if we are searching or just loading defaults
            if (String.isBlank(inputData)) {
                query += ' LIMIT 5';
            } else {
                searchKey = '%' + inputData + '%';
                query += ' AND Product2.Name LIKE :searchKey';
            }
            
            // 3. Single loop to populate the wrapper
            for (PricebookEntry pe : Database.query(query)) {
                listOfWrapper.add(new ProductWrapper(pe));
            }
            
            return listOfWrapper.isEmpty() ? null : listOfWrapper;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    // Wrapper class with a Constructor to save lines
    public class ProductWrapper {
        @AuraEnabled public Id productId {get;set;}
        @AuraEnabled public String productName {get;set;}
        @AuraEnabled public Decimal unitPrice {get;set;}
        
        public ProductWrapper(PricebookEntry pe) {
            this.productId = pe.Product2Id;
            this.productName = pe.Product2.Name;
            this.unitPrice = pe.UnitPrice;
        }
    }
}