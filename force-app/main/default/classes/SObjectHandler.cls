public with sharing class SObjectHandler {
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getSObjects() {
        Map<String, String> objects = new Map<String, String>();

        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();

        for (Schema.SObjectType sobjType : globalDescribe.values()) {
            Schema.DescribeSObjectResult objectDescription = sobjType.getDescribe();

            String apiName = objectDescription.getName();
            String label = objectDescription.getLabel();

            if (
                meetsNameCriteria(apiName) &&
                objectDescription.isCreateable() &&
                !objectDescription.isCustomSetting() &&
                objectDescription.getRecordTypeInfos().size() > 0
            ) {
                objects.put(apiName, label);
            }
        }

        if (!objects.isEmpty()) {
            return objects;
        }

        return null;
    }

    private static Boolean meetsNameCriteria(String name) {
        return !name.contains('ChangeEvent') &&
            !name.contains('Feed') &&
            !name.contains('History') &&
            !name.contains('Share') &&
            !name.contains('Access');
    }
}
