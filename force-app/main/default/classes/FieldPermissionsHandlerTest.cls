@isTest
public with sharing class FieldPermissionsHandlerTest {
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
