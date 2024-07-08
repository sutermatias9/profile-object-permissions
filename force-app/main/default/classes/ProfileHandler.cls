public with sharing class ProfileHandler {
    @AuraEnabled(cacheable=true)
    public static Map<Id, String> getProfiles() {
        Map<Id, String> profiles = new Map<Id, String>();

        for (Profile p : [SELECT Id, Name FROM Profile ORDER BY Name]) {
            profiles.put(p.Id, p.Name);
        }

        return profiles;
    }
}
