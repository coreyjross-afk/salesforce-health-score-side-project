public class AccountHealthScorer {

    public static void scoreAllAccounts() {
       
        List<Account> accounts = [
            SELECT Id, Health_Score__c, Risk_Tier__c, Last_Score_Date__c,
                   (SELECT Sessions__c, Features_Used__c FROM Usage_Logs1__r)
            FROM Account
        ];
       
        List<Account> accountsToUpdate = new List<Account>();
       
        for (Account acc : accounts) {
            Integer score = calculateScore(acc);
            acc.Health_Score__c = score;
            acc.Last_Score_Date__c = Date.today();
            accountsToUpdate.add(acc);
        }
       
        update accountsToUpdate;
    }
   
    private static Integer calculateScore(Account acc) {
       
        // --- Usage Log signals ---
        Decimal totalSessions = 0;
        Decimal totalFeatures = 0;
        Integer logCount = acc.Usage_Logs1__r.size();
       
        if (logCount > 0) {
            for (Usage_Log__c log : acc.Usage_Logs1__r) {
                totalSessions += log.Sessions__c != null ? log.Sessions__c : 0;
                totalFeatures += log.Features_Used__c != null ? log.Features_Used__c : 0;
            }
        }
       
        Decimal avgSessions = logCount > 0 ? totalSessions / logCount : 0;
        Decimal avgFeatures = logCount > 0 ? totalFeatures / logCount : 0;
       
        // Score sessions out of 100 (cap at 80 sessions = perfect score)
        Decimal sessionScore = Math.min((avgSessions / 80) * 100, 100);
       
        // Score features out of 100 (cap at 12 features = perfect score)
        Decimal featureScore = Math.min((avgFeatures / 12) * 100, 100);
       
        // --- Weighted final score ---
        // Sessions 40%, Features 30%, flat 30% base score for now
        Decimal finalScore = (sessionScore * 0.40) + (featureScore * 0.30) + 30;
       
        return Integer.valueOf(Math.min(finalScore, 100).setScale(0));
    }
}