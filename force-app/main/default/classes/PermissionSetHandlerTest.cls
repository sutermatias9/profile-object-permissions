@isTest
public with sharing class PermissionSetHandlerTest {
    @isTest
    static void testGetPermissionSetWithStandardProfile() {
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id;

        User u = createUser(profileId);
        PermissionSet ps = createPermissionSet(profileId);
        PermissionSetAssignment psa = createPermissionSetAssignment(u.Id, ps.Id);

        Test.startTest();
        PermissionSet result = PermissionSetHandler.getPermissionSet(profileId);
        Test.stopTest();

        Assert.isNotNull(result, 'A Permission Set record should be returned.');
        Assert.isFalse(result.isCustom, 'The profile should be Standard.');
    }

    @isTest
    static void testGetPermissionSetWithCustomProfile() {
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Test profile' LIMIT 1].Id;

        User u = createUser(profileId);
        PermissionSet ps = createPermissionSet(profileId);
        PermissionSetAssignment psa = createPermissionSetAssignment(u.Id, ps.Id);

        Test.startTest();
        PermissionSet result = PermissionSetHandler.getPermissionSet(profileId);
        Test.stopTest();
        System.debug(result);

        Assert.isNotNull(result, 'A Permission Set record should be returned.');
        Assert.isTrue(result.isCustom, 'The profile should be custom.');
    }

    static PermissionSet createPermissionSet(Id profileId) {
        PermissionSet pm = new PermissionSet();
        pm.Name = 'Test_PM_' + profileId;
        pm.Label = 'Test';
        insert pm;
        return pm;
    }

    static User createUser(Id profileId) {
        User u = new user();
        u.LastName = 'Test User';
        u.Email = 'suter@gmail.com';
        u.Alias = 'Tuser';
        u.Username = 'suter@gmail.com';
        u.CommunityNickname = 'testU213';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileID = profileId;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';

        insert u;
        return u;
    }

    static PermissionSetAssignment createPermissionSetAssignment(Id userId, Id psId) {
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = userId;
        psa.PermissionSetId = psId;

        insert psa;
        return psa;
    }
}
