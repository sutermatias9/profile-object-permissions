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

    public static Map<String, Map<String, Boolean>> sortMapByKeys(Map<String, Map<String, Boolean>> unordered) {
        Map<String, Map<String, Boolean>> ordered = new Map<String, Map<String, Boolean>>();
        List<String> keys = new List<String>(unordered.keySet());

        keys.sort();

        for (String key : keys) {
            ordered.put(key, unordered.get(key));
        }

        return ordered;
    }
}
