@isTest
public with sharing class TestDataFactory {
    public static User createUser(Id profileId, Boolean doInsert) {
        User u = new user();
        u.LastName = 'Test User';
        u.Email = 'suter@gmail.com';
        u.Alias = 'Tuser';
        u.Username = 'suter' + System.currentTimeMillis() + '@gmail.com';
        u.CommunityNickname = 'testU213';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileID = profileId;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';

        if (doInsert) {
            insert u;
        }

        return u;
    }

    public static PermissionSet createPermissionSet(Id profileId, Boolean doInsert) {
        PermissionSet pm = new PermissionSet();
        pm.Name = 'Test_PM_' + System.currentTimeMillis();
        pm.Label = 'Test';

        if (doInsert) {
            insert pm;
        }

        return pm;
    }

    public static PermissionSetAssignment createPermissionSetAssignment(Id userId, Id psId, Boolean doInsert) {
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = userId;
        psa.PermissionSetId = psId;

        if (doInsert) {
            insert psa;
        }

        return psa;
    }

    public static PermissionSet createProfilePermissionSet(Id profileId) {
        User u = createUser(profileId, true);
        PermissionSet ps = createPermissionSet(profileId, true);
        PermissionSetAssignment psa = createPermissionSetAssignment(u.Id, ps.Id, true);

        return ps;
    }
}
