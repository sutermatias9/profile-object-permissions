public with sharing class Utils {
    public static List<String> getFieldsAsString(List<Schema.SObjectField> fieldList) {
        List<String> fields = new List<String>();

        for (Schema.SObjectField field : fieldList) {
            fields.add(field.getDescribe().getName());
        }

        return fields;
    }

    public static Boolean isAddressComponent(String field) {
        List<String> components = new List<String>{
            'Street',
            'City',
            'State',
            'PostalCode',
            'Country',
            'Latitude',
            'Longitude',
            'GeocodeAccuracy'
        };

        for (String c : components) {
            if (field.contains(c)) {
                return true;
            }
        }
        return false;
    }
}
