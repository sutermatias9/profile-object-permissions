@isTest
public with sharing class SObjectHandlerTest {
    @isTest
    static void testGetSObjects() {
        Map<String, String> objects = SObjectHandler.getSObjects();

        Assert.isNotNull(objects, 'returned value should not be null.');
        Assert.isTrue(objects.containsKey('Contact'), 'returned map should contains Contact key.');
        Assert.areEqual('Product', objects.get('Product2'));
    }

    @isTest
    static void testGetFieldsValidSobject() {
        List<String> fields = SObjectHandler.getFields('Contact');

        Assert.isTrue(fields.size() > 0);
        Assert.isTrue(fields.contains('Birthdate'));
    }

    @isTest
    static void testGetFieldsInvalidSobject() {
        try {
            List<String> fields = SObjectHandler.getFields('Invalid');
            Assert.fail('An exception was expected');
        } catch (Exception e) {
            Assert.isTrue(e.getMessage().contains('Invalid SObject Name'));
        }
    }
}
