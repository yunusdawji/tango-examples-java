package com.naiveroboticist.robotmediator;

import android.annotation.SuppressLint;

/**
 * This class provides handy string utilities.
 * 
 * @author dsieh
 *
 */
public class StringUtils {

    /**
     * Perform a camel case operation on a string. This will
     * take a string like "a_class_name" and transform it to
     * "AClassName".
     * 
     * @param st the string to be camel-cased.
     * 
     * @return the camel-cased string.
     */
    @SuppressLint("DefaultLocale")
    public static String camelCase(String st) {
        boolean firstLetter = true;
        StringBuilder sb = new StringBuilder();
        for (int i=0; i<st.length(); i++) {
            String l = st.substring(i, i+1);
            if (firstLetter) {
                sb.append(l.toUpperCase());
                firstLetter = false;
            } else if (l.equals("_")) {
                firstLetter = true;
            } else {
                sb.append(l.toLowerCase());
            }
        }
        
        return sb.toString();
    }
}
