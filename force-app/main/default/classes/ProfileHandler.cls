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
    // Si no tengo read permission directamente no me aparece el campo
    @AuraEnabled
    public static Map<String, Map<String, Boolean>> getFieldPermissions(String sObjectName, Id profileId) {
        Map<String, Map<String, Boolean>> profileFieldsPermissions = new Map<String, Map<String, Boolean>>();
        try {
            List<FieldPermissions> fps = [
                SELECT Id, Field, ParentId, PermissionsEdit, PermissionsRead, Parent.Profileid, Parent.Profile.Name
                FROM FieldPermissions
                WHERE Parent.IsOwnedByProfile = TRUE AND SobjectType = :sObjectName AND Parent.ProfileId = :profileId
                ORDER BY Field
            ];

            for (FieldPermissions fp : fps) {
                Map<String, Boolean> permissions = new Map<String, Boolean>();
                permissions.put('Readable', fp.PermissionsRead);
                permissions.put('Editable', fp.PermissionsEdit);
                profileFieldsPermissions.put(fp.Field, permissions);
            }

            if (!profileFieldsPermissions.isEmpty()) {
                return profileFieldsPermissions;
            }

            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
