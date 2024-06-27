public with sharing class FieldPermissionsHandler {
    public class TogglesInfoWrapper {
        public String field;
        public Boolean read;
        public Boolean edit;
    }

    @AuraEnabled
    public static void setPermissions(Id profileId, String sobjectName, String permissionsJSON) {
        try {
            List<TogglesInfoWrapper> togglesInfo = (List<TogglesInfoWrapper>) JSON.deserialize(
                permissionsJSON,
                List<TogglesInfoWrapper>.class
            );
            Id permissionSetId = PermissionSetHandler.getPermissionSet(profileId).Id;
            List<FieldPermissions> fps = getExistingPermissions(profileId, sobjectName, permissionSetId);
            List<FieldPermissions> recordsToUpsert = new List<FieldPermissions>();
            List<String> fieldNames = getFieldNames(fps);

            for (TogglesInfoWrapper info : togglesInfo) {
                info.field = sobjectName + '.' + info.field;
                FieldPermissions record;
                System.debug(info);

                if (fieldNames.contains(info.field)) {
                    record = findRecord(info.field, fps);
                    record.PermissionsRead = info.read;
                    record.PermissionsEdit = info.edit;
                    recordsToUpsert.add(record);
                } else {
                    if (info.read) {
                        record = createRecord(permissionSetId, sobjectName, info);
                        recordsToUpsert.add(record);
                    }
                }
            }

            upsert recordsToUpsert;
        } catch (Exception e) {
            throw new AuraHandledException('Error setting field permissions: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Map<String, Boolean>> getFieldPermissions(String sobjectName, Id profileId) {
        Map<String, Map<String, Boolean>> profileFieldsPermissions = new Map<String, Map<String, Boolean>>();

        try {
            Id permissionSetId = PermissionSetHandler.getPermissionSet(profileId).Id;
            List<FieldPermissions> fps = getExistingPermissions(profileId, sobjectName, permissionSetId);

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

    private static Boolean areMissingFields(String sobjectName, Set<String> fieldsAdded) {
        return fieldsAdded.size() < SObjectHandler.getFields(sobjectName).size();
    }

    private static Map<String, Map<String, Boolean>> getMissingFields(String sobjectName, Set<String> fieldNames) {
        Map<String, Map<String, Boolean>> missingPermissions = new Map<String, Map<String, Boolean>>();

        for (String field : SObjectHandler.getFields(sobjectName)) {
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

    private static List<FieldPermissions> getExistingPermissions(Id profileId, String sobjectName, Id permissionSetId) {
        return [
            SELECT Id, SobjectType, Field, PermissionsEdit, PermissionsRead
            FROM FieldPermissions
            WHERE SobjectType = :sobjectName AND ParentId = :permissionSetId
        ];
    }

    private static List<String> getFieldNames(List<FieldPermissions> fps) {
        List<String> fieldNames = new List<String>();

        for (FieldPermissions fp : fps) {
            fieldNames.add(fp.Field);
        }

        return fieldNames;
    }

    private static FieldPermissions findRecord(String fieldName, List<FieldPermissions> fps) {
        FieldPermissions record;

        for (FieldPermissions fp : fps) {
            if (fp.Field == fieldName) {
                record = fp;
            }
        }

        return record;
    }

    private static FieldPermissions createRecord(Id permissionSetId, String sobjectName, TogglesInfoWrapper info) {
        FieldPermissions record = new FieldPermissions();
        record.ParentId = permissionSetId;
        record.SobjectType = sobjectName;
        record.Field = info.field;
        record.PermissionsRead = info.read;
        record.PermissionsEdit = info.edit;

        return record;
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
