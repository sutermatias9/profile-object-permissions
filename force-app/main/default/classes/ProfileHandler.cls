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
    public static Map<String, Boolean> getObjectPermissions(String sobjectName, Id profileId) {
        try {
            //lo puedo hacer dinamico
            List<ObjectPermissions> ops = [
                SELECT
                    SobjectType,
                    PermissionsRead,
                    PermissionsCreate,
                    PermissionsEdit,
                    PermissionsDelete,
                    PermissionsViewAllRecords,
                    PermissionsModifyAllRecords
                FROM ObjectPermissions
                WHERE SobjectType = :sobjectName AND Parent.isOwnedByProfile = TRUE AND Parent.ProfileId = :profileId
                LIMIT 1
            ];

            Map<String, Boolean> permissions = new Map<String, Boolean>{
                'Read' => false,
                'Create' => false,
                'Edit' => false,
                'Delete' => false,
                'ViewAll' => false,
                'ModifyAll' => false
            };

            if (!ops.isEmpty()) {
                ObjectPermissions op = ops[0];
                permissions.put('Read', op.PermissionsRead);
                permissions.put('Create', op.PermissionsCreate);
                permissions.put('Edit', op.PermissionsEdit);
                permissions.put('Delete', op.PermissionsDelete);
                permissions.put('ViewAll', op.PermissionsViewAllRecords);
                permissions.put('ModifyAll', op.PermissionsModifyAllRecords);
            }

            return permissions;
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching object permissions: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Map<String, Boolean>> getAllObjectPermissions(Id profileId) {
        Map<String, Map<String, Boolean>> profileObjectPermissions = new Map<String, Map<String, Boolean>>();
        try {
            List<ObjectPermissions> ops = [
                SELECT
                    SobjectType,
                    PermissionsRead,
                    PermissionsCreate,
                    PermissionsEdit,
                    PermissionsDelete,
                    PermissionsViewAllRecords,
                    PermissionsModifyAllRecords
                FROM ObjectPermissions
                WHERE Parent.isOwnedByProfile = TRUE AND Parent.ProfileId = :profileId
            ];

            for (ObjectPermissions op : ops) {
                Map<String, Boolean> permissions = new Map<String, Boolean>();
                permissions.put('Read', op.PermissionsRead);
                permissions.put('Create', op.PermissionsCreate);
                permissions.put('Edit', op.PermissionsEdit);
                permissions.put('Delete', op.PermissionsDelete);
                permissions.put('ViewAll', op.PermissionsViewAllRecords);
                permissions.put('ModifyAll', op.PermissionsModifyAllRecords);
                profileObjectPermissions.put(op.SobjectType, permissions);
            }

            Set<String> objectsAdded = profileObjectPermissions.keySet();

            if (areMissingObjects(objectsAdded)) {
                profileObjectPermissions.putAll(getMissingObjects(objectsAdded));
            }

            return sortMap(profileObjectPermissions);
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

            return sortMap(profileFieldsPermissions);
        } catch (Exception e) {
            throw new AuraHandledException('getFieldPermissions:' + e.getMessage());
        }
    }

    private static Boolean areMissingFields(String sObjectName, Set<String> fieldsAdded) {
        return fieldsAdded.size() < SObjectHandler.getFields(sObjectName).size();
    }

    private static Boolean areMissingObjects(Set<String> objectsAdded) {
        return objectsAdded.size() < SObjectHandler.getSObjects().size();
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

    private static Map<String, Map<String, Boolean>> getMissingObjects(Set<String> objectsAdded) {
        Map<String, Map<String, Boolean>> missingPermissions = new Map<String, Map<String, Boolean>>();

        for (String objectName : SObjectHandler.getSObjects().keySet()) {
            if (!objectsAdded.contains(objectName)) {
                missingPermissions.put(
                    objectName,
                    new Map<String, Boolean>{
                        'Read' => false,
                        'Create' => false,
                        'Edit' => false,
                        'Delete' => false,
                        'ViewAll' => false,
                        'ModifyAll' => false
                    }
                );
            }
        }

        return missingPermissions;
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
