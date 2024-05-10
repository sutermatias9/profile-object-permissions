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

    public static List<String> getFieldList(String sObjectName) {
        Schema.DescribeSObjectResult sobjectDescribe = Schema.getGlobalDescribe().get(sObjectName).getDescribe();
        List<Schema.SObjectField> fieldList = sobjectDescribe.fields.getMap().values();
        return getFieldsAsString(fieldList);
    }

    private static List<String> getFieldsAsString(List<Schema.SObjectField> fieldList) {
        List<String> fields = new List<String>();

        for (Schema.SObjectField field : fieldList) {
            fields.add(field.getDescribe().getName());
        }

        return fields;
    }

    private static Boolean meetsNameCriteria(String name) {
        return !name.contains('ChangeEvent') &&
            !name.contains('Feed') &&
            !name.contains('History') &&
            !name.contains('Share') &&
            !name.contains('Access');
    }
}
