@isTest
public with sharing class PermissionSetHandlerTest {
    @isTest
    static void testGetPermissionSetWithStandardProfile() {
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id;

        TestDataFactory.createProfilePermissionSet(profileId);

        Test.startTest();
        PermissionSet result = PermissionSetHandler.getPermissionSet(profileId);
        Test.stopTest();

        Assert.isNotNull(result, 'A Permission Set record should be returned.');
        Assert.isFalse(result.isCustom, 'The profile should be Standard.');
    }

    @isTest
    static void testGetPermissionSetWithCustomProfile() {
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Test profile' LIMIT 1].Id;

        TestDataFactory.createProfilePermissionSet(profileId);

        Test.startTest();
        PermissionSet result = PermissionSetHandler.getPermissionSet(profileId);
        Test.stopTest();

        Assert.isNotNull(result, 'A Permission Set record should be returned.');
        Assert.isTrue(result.isCustom, 'The profile should be custom.');
    }
}
