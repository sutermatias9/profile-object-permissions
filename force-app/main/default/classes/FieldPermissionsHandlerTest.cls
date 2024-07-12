@isTest
public with sharing class FieldPermissionsHandlerTest {
    @isTest
    static void testSetPermissions() {
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Test profile' LIMIT 1].Id;
        String sobjectName = 'Account';

        List<FieldPermissionsHandler.FieldPermissionsInfo> testPermissions = new List<FieldPermissionsHandler.FieldPermissionsInfo>();

        testPermissions.add(new FieldPermissionsHandler.FieldPermissionsInfo('Phone', true, false));
        testPermissions.add(new FieldPermissionsHandler.FieldPermissionsInfo('Description', false, false));
        testPermissions.add(new FieldPermissionsHandler.FieldPermissionsInfo('Type', true, true));
        testPermissions.add(new FieldPermissionsHandler.FieldPermissionsInfo('CleanStatus', true, true));

        String permissionsJSON = JSON.serialize(testPermissions);

        Test.startTest();
        FieldPermissionsHandler.setPermissions(profileId, sobjectName, permissionsJSON);
        Test.stopTest();

        List<FieldPermissions> result = [
            SELECT Id, SobjectType, Field, PermissionsEdit, PermissionsRead
            FROM FieldPermissions
            WHERE SobjectType = :sobjectName AND Parent.ProfileId = :profileId
        ];

        for (FieldPermissions fp : result) {
            if (fp.Field == 'Phone') {
                Assert.isTrue(fp.PermissionsRead && !fp.PermissionsEdit);
            } else if (fp.Field == 'Description') {
                Assert.isTrue(!fp.PermissionsRead && !fp.PermissionsEdit);
            } else if (fp.Field == 'Type') {
                Assert.isTrue(fp.PermissionsRead && fp.PermissionsEdit);
            } else if (fp.Field == 'CleanStatus') {
                Assert.isTrue(fp.PermissionsRead && fp.PermissionsEdit);
            }
        }
    }

    @isTest
    static void testSetPermissionInvalidProfileId() {
        FieldPermissionsHandler.FieldPermissionsInfo testPermissions = new FieldPermissionsHandler.FieldPermissionsInfo(
            'CleanStatus',
            true,
            true
        );

        try {
            FieldPermissionsHandler.setPermissions('000000000000001', 'Account', JSON.serialize(testPermissions));
            Assert.fail('An exception was expected.');
        } catch (Exception e) {
            Assert.areEqual('System.AuraHandledException', e.getTypeName());
        }
    }

    @isTest
    static void testGetFieldPermissions() {
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Test profile' LIMIT 1].Id;

        String sobjectName = 'Account';

        Test.startTest();
        Map<String, Map<String, Boolean>> result = FieldPermissionsHandler.getFieldPermissions(sobjectName, profileId);
        Test.stopTest();

        Assert.isTrue(
            areValidFields(sobjectName, new List<String>(result.keySet())),
            'Map keys should be permissionable fields.'
        );
        Assert.isTrue(areValidPermissions(result.values()), 'Permissions should be Readable or Editable.');
    }

    @isTest
    static void testGetFieldPermissionsInvalidProfile() {
        try {
            FieldPermissionsHandler.getFieldPermissions('Account', '000000000000001');
            Assert.fail('An exception was expected');
        } catch (Exception e) {
            Assert.areEqual('System.AuraHandledException', e.getTypeName());
        }
    }

    static Boolean areValidFields(String sobjectName, List<String> mapFields) {
        List<String> validFields = SObjectHandler.getFields(sobjectName);

        validFields.sort();
        mapFields.sort();

        return validFields.equals(mapFields);
    }

    static Boolean areValidPermissions(List<Map<String, Boolean>> fieldPermissions) {
        for (Map<String, Boolean> permissions : fieldPermissions) {
            for (String permissionName : permissions.keySet()) {
                if (permissionName != 'Readable' && permissionName != 'Editable') {
                    return false;
                }
            }
        }

        return true;
    }
}
