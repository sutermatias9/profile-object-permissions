public with sharing class PermissionSetHandler {
    public static PermissionSet getPermissionSet(Id profileId) {
        return [
            SELECT Id, isCustom
            FROM PermissionSet
            WHERE isOwnedByProfile = TRUE AND ProfileId = :profileId
        ];
    }
}
