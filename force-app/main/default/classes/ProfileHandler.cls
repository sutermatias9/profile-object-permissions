public with sharing class ProfileHandler {
    @AuraEnabled(cacheable=true)
    public static Map<Id, String> getProfiles() {
        try {
            Map<Id, String> profiles = new Map<Id, String>();

            for (Profile p : [SELECT Id, Name FROM Profile ORDER BY Name]) {
                profiles.put(p.Id, p.Name);
            }

            return profiles;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Map<String, Boolean>> getFieldPermissions(String sObjectName, Id profileId) {
        Map<String, Map<String, Boolean>> profileFieldsPermissions = new Map<String, Map<String, Boolean>>();
        try {
            List<FieldPermissions> fps = [
                SELECT Id, Field, PermissionsEdit, PermissionsRead
                FROM FieldPermissions
                WHERE Parent.IsOwnedByProfile = TRUE AND SobjectType = :sObjectName AND Parent.ProfileId = :profileId
                ORDER BY Field
            ];

            for (FieldPermissions fp : fps) {
                Map<String, Boolean> permissions = new Map<String, Boolean>();
                permissions.put('Readable', fp.PermissionsRead);
                permissions.put('Editable', fp.PermissionsEdit);
                profileFieldsPermissions.put(getFieldOnly(fp.Field), permissions);
            }

            Set<String> fieldsAdded = profileFieldsPermissions.keySet();

            if (areMissingFields(sObjectName, fieldsAdded)) {
                profileFieldsPermissions.putAll(getMissingFields(sObjectName, fieldsAdded));
            }

            return profileFieldsPermissions;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static Boolean areMissingFields(String sObjectName, Set<String> fieldsAdded) {
        return fieldsAdded.size() < SObjectHandler.getFields(sObjectName).size();
    }

    private static Map<String, Map<String, Boolean>> getMissingFields(String sObjectName, Set<String> fieldNames) {
        Map<String, Map<String, Boolean>> missingPermissions = new Map<String, Map<String, Boolean>>();

        for (String field : SObjectHandler.getFields(sObjectName)) {
            System.debug(field + ' is in list? ' + fieldNames.contains(field));
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
}
