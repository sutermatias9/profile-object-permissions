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

        return objects;
    }

    public static List<String> getFields(String sObjectName) {
        List<Schema.SObjectField> filteredFields = new List<Schema.SObjectField>();

        Schema.DescribeSObjectResult sobjectDescribe = Schema.getGlobalDescribe().get(sObjectName).getDescribe();
        List<Schema.SObjectField> fieldList = sobjectDescribe.fields.getMap().values();

        for (Schema.SObjectField f : fieldList) {
            Schema.DescribeFieldResult df = f.getDescribe();
            String name = df.getName();

            if (df.isPermissionable() && !Utils.isAddressComponent(name)) {
                filteredFields.add(f);
            }
        }

        return Utils.getFieldsAsString(filteredFields);
    }

    private static Boolean meetsNameCriteria(String name) {
        return !name.contains('ChangeEvent') &&
            !name.contains('Feed') &&
            !name.contains('History') &&
            !name.contains('Share') &&
            !name.contains('Access');
    }
}
