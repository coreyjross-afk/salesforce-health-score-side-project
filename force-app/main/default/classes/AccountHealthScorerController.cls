public with sharing class AccountHealthScorerController {
   
    @AuraEnabled
    public static List<Account> getAccounts() {
        return [
            SELECT Id, Name, Health_Score__c, Risk_Tier__c, Last_Score_Date__c
            FROM Account
            WHERE Health_Score__c != null
            ORDER BY Health_Score__c ASC
        ];
    }
   
    @AuraEnabled
    public static void rescoreAccounts() {
        AccountHealthScorer.scoreAllAccounts();
    }
}