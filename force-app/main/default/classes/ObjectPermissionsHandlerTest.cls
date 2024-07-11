@isTest
public with sharing class ObjectPermissionsHandlerTest {
    static final List<String> VALID_PERMISSIONS = new List<String>{
        'Read',
        'Create',
        'Edit',
        'Delete',
        'ViewAll',
        'ModifyAll'
    };

    @TestSetup
    static void makeData() {
    }

    @isTest
    static void testGetAllObjectPermissionsValidProfile() {
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Test profile' LIMIT 1].Id;

        Test.startTest();
        Map<String, Map<String, Boolean>> actualResult = ObjectPermissionsHandler.getAllObjectPermissions(profileId);
        Test.stopTest();

        Assert.isTrue(areValidSObjects(new List<String>(actualResult.keySet())), 'Map keys should be valid sobjects');
        Assert.isTrue(areValidPermissions(actualResult.values()), 'Permissions should be Create, Read, Edit or Delete');
    }

    @isTest
    static void testGetAllObjectPermissionsInvalidProfile() {
        try {
            Map<String, Map<String, Boolean>> actualResult = ObjectPermissionsHandler.getAllObjectPermissions(
                '000000000000001'
            );
            Assert.fail('An exception was expected');
        } catch (Exception e) {
            Assert.areEqual(
                'System.AuraHandledException',
                e.getTypeName(),
                'A System.AuraHandledException was expected.'
            );
        }
    }

    static Boolean areValidSObjects(List<String> actualSObjects) {
        List<String> expectedSObjects = new List<String>(SObjectHandler.getSObjects().keySet());
        expectedSObjects.sort();
        actualSObjects.sort();

        return expectedSObjects.equals(actualSObjects);
    }

    static Boolean areValidPermissions(List<Map<String, Boolean>> objectPermissions) {
        for (Map<String, Boolean> permissions : objectPermissions) {
            for (String permissionName : permissions.keySet()) {
                if (!VALID_PERMISSIONS.contains(permissionName)) {
                    return false;
                }
            }
        }

        return true;
    }
}
