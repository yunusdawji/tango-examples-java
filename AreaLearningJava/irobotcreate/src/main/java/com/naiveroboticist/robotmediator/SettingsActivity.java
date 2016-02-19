package com.naiveroboticist.robotmediator;


import android.os.Bundle;
import android.preference.PreferenceActivity;

/**
 * The activity that sets up the application settings.
 * 
 * @author dsieh
 *
 */
public class SettingsActivity extends PreferenceActivity {

    @SuppressWarnings("deprecation")
    @Override
    public void onCreate(Bundle savedInstanceState) {
      super.onCreate(savedInstanceState);
      addPreferencesFromResource(R.xml.mediator_preferences);
    }
}
