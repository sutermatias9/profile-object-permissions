public with sharing class ProfileHandler {
    @AuraEnabled(cacheable=true)
    public static List<Profile> getProfiles() {
        try {
            return [SELECT Id, Name FROM Profile ORDER BY Name];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
