public with sharing class FieldPermissionsHandler {
    @AuraEnabled
    public static Map<String, Map<String, Boolean>> getFieldPermissions(String sobjectName, Id profileId) {
        Map<String, Map<String, Boolean>> profileFieldsPermissions = new Map<String, Map<String, Boolean>>();
        try {
            List<FieldPermissions> fps = [
                SELECT Id, Field, PermissionsEdit, PermissionsRead
                FROM FieldPermissions
                WHERE Parent.IsOwnedByProfile = TRUE AND SobjectType = :sobjectName AND Parent.ProfileId = :profileId
            ];

            for (FieldPermissions fp : fps) {
                Map<String, Boolean> permissions = new Map<String, Boolean>();
                permissions.put('Readable', fp.PermissionsRead);
                permissions.put('Editable', fp.PermissionsEdit);
                profileFieldsPermissions.put(getFieldOnly(fp.Field), permissions);
            }

            Set<String> fieldsAdded = profileFieldsPermissions.keySet();

            if (areMissingFields(sobjectName, fieldsAdded)) {
                profileFieldsPermissions.putAll(getMissingFields(sobjectName, fieldsAdded));
            }

            return sortMap(profileFieldsPermissions);
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching field permissions: ' + e.getMessage());
        }
    }

    private static Boolean areMissingFields(String sObjectName, Set<String> fieldsAdded) {
        return fieldsAdded.size() < SObjectHandler.getFields(sObjectName).size();
    }

    private static Map<String, Map<String, Boolean>> getMissingFields(String sObjectName, Set<String> fieldNames) {
        Map<String, Map<String, Boolean>> missingPermissions = new Map<String, Map<String, Boolean>>();

        for (String field : SObjectHandler.getFields(sObjectName)) {
            if (!fieldNames.contains(field)) {
                missingPermissions.put(field, new Map<String, Boolean>{ 'Readable' => false, 'Editable' => false });
            }
        }

        if (!missingPermissions.isEmpty()) {
            return missingPermissions;
        }

        return null;
    }

    private static String getFieldOnly(String sObjectField) {
        Integer fieldIndex = sObjectField.indexOf('.') + 1;
        return sObjectField.substring(fieldIndex);
    }

    private static Map<String, Map<String, Boolean>> sortMap(Map<String, Map<String, Boolean>> unorderedMap) {
        Map<String, Map<String, Boolean>> orderedMap = new Map<String, Map<String, Boolean>>();

        Map<String, Object> input = (Map<String, Object>) unorderedMap;
        Map<String, Object> sorted = Utils.sortMapByKeys(input);

        for (String key : sorted.keySet()) {
            orderedMap.put(key, (Map<String, Boolean>) sorted.get(key));
        }

        return orderedMap;
    }
}
