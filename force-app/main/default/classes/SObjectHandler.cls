public with sharing class SObjectHandler {
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getSObjects() {
        List<String> permissionableObjects = getPermissionableObjects();
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();

        Map<String, String> objects = new Map<String, String>();

        for (Schema.SObjectType sobjType : globalDescribe.values()) {
            Schema.DescribeSObjectResult objectDescription = sobjType.getDescribe();

            String apiName = objectDescription.getName();
            String label = objectDescription.getLabel();

            if (permissionableObjects.contains(apiName)) {
                objects.put(apiName, label);
            }
        }

        return objects;
    }

    public static List<String> getPermissionableObjects() {
        List<Schema.PicklistEntry> entries = ObjectPermissions.SobjectType.getDescribe().getPicklistValues();

        List<String> objects = new List<String>();

        for (Schema.PicklistEntry entry : entries) {
            objects.add(entry.getValue());
        }

        return objects;
    }

    public static List<String> getFields(String sObjectName) {
        List<String> filteredFields = new List<String>();

        try {
            Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(sObjectName);

            Schema.DescribeSObjectResult sobjectDescribe = sObjectType.getDescribe();
            List<Schema.SObjectField> fieldList = sobjectDescribe.fields.getMap().values();

            for (Schema.SObjectField f : fieldList) {
                Schema.DescribeFieldResult df = f.getDescribe();
                String name = df.getName();

                if (df.isPermissionable() && !isAddressComponent(name)) {
                    filteredFields.add(name);
                }
            }
        } catch (NullPointerException e) {
            throw new IllegalArgumentException(
                'Invalid SObject Name in getFields: ' + sObjectName + '. ' + e.getMessage()
            );
        }

        return filteredFields;
    }

    private static Boolean isAddressComponent(String field) {
        List<String> components = new List<String>{
            'Street',
            'City',
            'State',
            'PostalCode',
            'Country',
            'Latitude',
            'Longitude',
            'GeocodeAccuracy'
        };

        for (String c : components) {
            if (field.contains(c)) {
                return true;
            }
        }
        return false;
    }
}
