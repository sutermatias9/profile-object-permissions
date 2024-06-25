public with sharing class PermissionSetHandler {
    public static Id getPermissionSetId(Id profileId) {
        return [
            SELECT Id
            FROM PermissionSet
            WHERE isOwnedByProfile = TRUE AND ProfileId = :profileId
        ]
        .Id;
    }
}
