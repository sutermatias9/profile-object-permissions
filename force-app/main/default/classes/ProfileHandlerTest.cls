@isTest
public with sharing class ProfileHandlerTest {
    @isTest
    static void testGetProfiles() {
        Integer numberOfProfiles = [SELECT COUNT() FROM Profile];

        Test.startTest();
        Map<Id, String> actualProfiles = ProfileHandler.getProfiles();
        Test.stopTest();

        Assert.areEqual(
            numberOfProfiles,
            actualProfiles.size(),
            'actualProfiles should match the number of profiles in the org.'
        );
    }
}
