package com.google.i18n.phonenumbers
{
    public class Exception extends Error
    {
        public static const INVALID_COUNTRY_CODE:String = 'Invalid country calling code';
        // This generally indicates the string passed in had less than 3 digits in it.
        // More specifically, the number failed to match the regular expression
        // VALID_PHONE_NUMBER.
        public static const NOT_A_NUMBER:String = 'The string supplied did not seem to be a phone number';
        // This indicates the string started with an international dialing prefix, but
        // after this was stripped from the number, had less digits than any valid
        // phone number (including country calling code) could have.
        public static const TOO_SHORT_AFTER_IDD:String = 'Phone number too short after IDD';
        // This indicates the string, after any country calling code has been
        // stripped, had less digits than any valid phone number could have.
        public static const TOO_SHORT_NSN:String = 'The string supplied is too short to be a phone number';
        // This indicates the string had more digits than any valid phone number could
        // have.
        public static const TOO_LONG:String = 'The string supplied is too long to be a phone number';

        public function Exception(msg:String)
        {
            super(msg);
        }
    }
}
