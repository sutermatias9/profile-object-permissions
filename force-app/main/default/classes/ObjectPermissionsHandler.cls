public with sharing class ObjectPermissionsHandler {
    @AuraEnabled
    public static void setPermissions(String sobjectName, Id profileId, String permissionsJSON) {
        try {
            Map<String, Boolean> permissions = (Map<String, Boolean>) JSON.deserialize(
                permissionsJSON,
                Map<String, Boolean>.class
            );

            Id permissionSetId = PermissionSetHandler.getPermissionSet(profileId).Id;

            List<ObjectPermissions> ops = getExistingPermissions(permissionSetId, sobjectName);

            if (ops.isEmpty()) {
                createRecord(permissionSetId, sobjectName, permissions);
            } else {
                ObjectPermissions op = ops[0];
                updateRecord(op, permissions);
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error setting permissions: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Boolean> getObjectPermissions(String sobjectName, Id profileId) {
        try {
            PermissionSet permissionSet = PermissionSetHandler.getPermissionSet(profileId);
            List<ObjectPermissions> ops = getExistingPermissions(permissionSet.Id, sobjectName);

            Map<String, Boolean> permissions = new Map<String, Boolean>{
                'isCustom' => permissionSet.isCustom,
                'Read' => false,
                'Create' => false,
                'Edit' => false,
                'Delete' => false,
                'ViewAll' => false,
                'ModifyAll' => false
            };

            if (!ops.isEmpty()) {
                ObjectPermissions op = ops[0];
                setMapPermissions(permissions, op);
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
            Id permissionSetId = PermissionSetHandler.getPermissionSet(profileId).Id;
            List<ObjectPermissions> ops = getExistingPermissions(permissionSetId, null);

            for (ObjectPermissions op : ops) {
                Map<String, Boolean> permissions = new Map<String, Boolean>();
                setMapPermissions(permissions, op);
                profileObjectPermissions.put(op.SobjectType, permissions);
            }

            Set<String> objectsAdded = profileObjectPermissions.keySet();

            if (areMissingObjects(objectsAdded)) {
                profileObjectPermissions.putAll(getMissingObjects(objectsAdded));
            }

            return Utils.sortMapByKeys(profileObjectPermissions);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static void createRecord(Id permissionSetId, String sobjectName, Map<String, Boolean> permissions) {
        ObjectPermissions op = new ObjectPermissions();
        op.ParentId = permissionSetId;
        op.SobjectType = sobjectName;
        op.PermissionsRead = permissions.get('Read');
        op.PermissionsCreate = permissions.get('Create');
        op.PermissionsEdit = permissions.get('Edit');
        op.PermissionsDelete = permissions.get('Delete');
        op.PermissionsViewAllRecords = permissions.get('ViewAll');
        op.PermissionsModifyAllRecords = permissions.get('ModifyAll');

        insert op;
    }

    private static void updateRecord(ObjectPermissions op, Map<String, Boolean> permissions) {
        op.PermissionsRead = permissions.get('Read');
        op.PermissionsCreate = permissions.get('Create');
        op.PermissionsEdit = permissions.get('Edit');
        op.PermissionsDelete = permissions.get('Delete');
        op.PermissionsViewAllRecords = permissions.get('ViewAll');
        op.PermissionsModifyAllRecords = permissions.get('ModifyAll');

        update op;
    }

    private static void setMapPermissions(Map<String, Boolean> permissions, ObjectPermissions op) {
        permissions.put('Read', op.PermissionsRead);
        permissions.put('Create', op.PermissionsCreate);
        permissions.put('Edit', op.PermissionsEdit);
        permissions.put('Delete', op.PermissionsDelete);
        permissions.put('ViewAll', op.PermissionsViewAllRecords);
        permissions.put('ModifyAll', op.PermissionsModifyAllRecords);
    }

    private static List<ObjectPermissions> getExistingPermissions(Id PermissionSetId, String sobjectName) {
        String query = 'SELECT SobjectType, PermissionsRead, PermissionsCreate, PermissionsEdit, PermissionsDelete, PermissionsViewAllRecords, PermissionsModifyAllRecords FROM ObjectPermissions WHERE ParentId = :permissionSetId';

        if (sobjectName != null) {
            query += ' AND SobjectType = :sobjectName';
        } else {
            Set<String> sobjects = SObjectHandler.getSObjects().keySet();
            query += ' AND SobjectType IN :sobjects';
        }

        return Database.query(query);
    }

    private static Boolean areMissingObjects(Set<String> objectsAdded) {
        return objectsAdded.size() < SObjectHandler.getSObjects().size();
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
}
