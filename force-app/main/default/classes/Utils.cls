public with sharing class Utils {
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
