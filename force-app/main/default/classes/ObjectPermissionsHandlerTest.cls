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

    @isTest
    static void testSetPermissionsProfileHadPermissions() {
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Test profile' LIMIT 1].Id;

        Map<String, Boolean> permissions = new Map<String, Boolean>{
            'Read' => true,
            'Create' => false,
            'Edit' => true,
            'Delete' => false,
            'ViewAll' => false,
            'ModifyAll' => false
        };

        String sobjectName = 'Account';

        Test.startTest();
        ObjectPermissionsHandler.setPermissions(sobjectName, profileId, JSON.serialize(permissions));
        Test.stopTest();

        List<ObjectPermissions> ops = [
            SELECT
                PermissionsRead,
                PermissionsCreate,
                PermissionsEdit,
                PermissionsDelete,
                PermissionsViewAllRecords,
                PermissionsModifyAllRecords
            FROM ObjectPermissions
            WHERE Parent.ProfileId = :profileId AND SobjectType = :sobjectName
        ];

        Assert.isTrue(ops.size() == 1);

        ObjectPermissions result = ops[0];

        Assert.isTrue(result.PermissionsRead && result.PermissionsEdit, 'Read and Edit permissions should be true,');
        Assert.isFalse(
            result.PermissionsCreate ||
                result.PermissionsDelete ||
                result.PermissionsViewAllRecords ||
                result.PermissionsModifyAllRecords,
            'Create, Delete, View All and Modify All permissions should be false.'
        );
    }

    @isTest
    static void testSetPermissionsProfileWithoutPermissions() {
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Test profile' LIMIT 1].Id;

        Map<String, Boolean> permissions = new Map<String, Boolean>{
            'Read' => true,
            'Create' => false,
            'Edit' => true,
            'Delete' => true,
            'ViewAll' => true,
            'ModifyAll' => true
        };

        String sobjectName = 'Lead';

        Test.startTest();
        ObjectPermissionsHandler.setPermissions(sobjectName, profileId, JSON.serialize(permissions));
        Test.stopTest();

        List<ObjectPermissions> ops = [
            SELECT
                PermissionsRead,
                PermissionsCreate,
                PermissionsEdit,
                PermissionsDelete,
                PermissionsViewAllRecords,
                PermissionsModifyAllRecords
            FROM ObjectPermissions
            WHERE Parent.ProfileId = :profileId AND SobjectType = :sobjectName
        ];

        Assert.isTrue(ops.size() == 1);

        ObjectPermissions result = ops[0];

        Assert.isTrue(
            result.PermissionsRead &&
                result.PermissionsEdit &&
                result.PermissionsDelete &&
                result.PermissionsViewAllRecords &&
                result.PermissionsModifyAllRecords,
            'Read, Edit, Delete, View All and Modify All permissions should be true,'
        );
        Assert.isFalse(result.PermissionsCreate, 'Create permission should be false.');
    }

    @isTest
    static void testSetPermissionsInvalidProfile() {
        try {
            ObjectPermissionsHandler.setPermissions('Account', '000000000000001', 'permissionJSON');
            Assert.fail('An exception was expected');
        } catch (Exception e) {
            Assert.areEqual(
                'System.AuraHandledException',
                e.getTypeName(),
                'A System.AuraHandledException was expected.'
            );
        }
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

    @isTest
    static void testGetObjectPermissions() {
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Test profile' LIMIT 1].Id;

        Test.startTest();
        Map<String, Boolean> actualResult = ObjectPermissionsHandler.getObjectPermissions('Account', profileId);
        Test.stopTest();

        Assert.isTrue(areValidKeys(actualResult.keySet(), true), 'Permissions should be Create, Read, Edit or Delete');
    }

    @isTest
    static void testGetObjectPermissionsProfileWithoutPermissions() {
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Test profile' LIMIT 1].Id;

        Test.startTest();
        Map<String, Boolean> actualResult = ObjectPermissionsHandler.getObjectPermissions('Lead', profileId);
        Test.stopTest();

        Assert.isTrue(areValidKeys(actualResult.keySet(), true), 'Permissions should be Create, Read, Edit or Delete');
        for (String key : actualResult.keySet()) {
            if (key != 'isCustom') {
                Assert.isFalse(actualResult.get(key), 'The permission should be false.');
            }
        }
    }

    @isTest
    static void testGetObjectPermissionsInvalidProfileId() {
        try {
            Map<String, Boolean> actualResult = ObjectPermissionsHandler.getObjectPermissions(
                'Lead',
                '000000000000001'
            );
            Assert.fail('An exception was expected.');
        } catch (Exception e) {
            Assert.areEqual('System.AuraHandledException', e.getTypeName());
        }
    }

    static Boolean areValidSObjects(List<String> actualSObjects) {
        List<String> expectedSObjects = new List<String>(SObjectHandler.getSObjects().keySet());
        expectedSObjects.sort();
        actualSObjects.sort();

        return expectedSObjects.equals(actualSObjects);
    }

    static Boolean areValidPermissions(List<Map<String, Boolean>> objectPermissions) {
        Boolean result;

        for (Map<String, Boolean> permissions : objectPermissions) {
            result = areValidKeys(permissions.keySet(), false);
        }

        return result;
    }

    static Boolean areValidKeys(Set<String> keys, Boolean hasCustomKey) {
        for (String key : keys) {
            if (!VALID_PERMISSIONS.contains(key) && hasCustomKey && key != 'isCustom') {
                return false;
            }
        }

        return true;
    }
}
