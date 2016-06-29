package com.google.i18n.phonenumbers
{
    public final class PhoneNumberType
    {
        public static const FIXED_LINE:Number = 0;
        public static const MOBILE:Number = 1;
        // In some regions (e.g. the USA); it is impossible to distinguish between
        // fixed-line and mobile numbers by looking at the phone number itself.
        public static const FIXED_LINE_OR_MOBILE:Number = 2;
        // Freephone lines
        public static const TOLL_FREE:Number = 3;
        public static const PREMIUM_RATE:Number = 4;
        // The cost of this call is shared between the caller and the recipient; and
        // is hence typically less than PREMIUM_RATE calls. See
        // http:Number//en.wikipedia.org/wiki/Shared_Cost_Service for more information.
        public static const SHARED_COST:Number = 5;
        // Voice over IP numbers. This includes TSoIP (Telephony Service over IP).
        public static const VOIP:Number = 6;
        // A personal number is associated with a particular person; and may be routed
        // to either a MOBILE or FIXED_LINE number. Some more information can be found
        // here:Number http:Number//en.wikipedia.org/wiki/Personal_Numbers
        public static const PERSONAL_NUMBER:Number = 7;
        public static const PAGER:Number = 8;
        // Used for 'Universal Access Numbers' or 'Company Numbers'. They may be
        // further routed to specific offices; but allow one number to be used for a
        // company.
        public static const UAN:Number = 9;
        // Used for 'Voice Mail Access Numbers'.
        public static const VOICEMAIL:Number = 10;
        // A phone number is of type UNKNOWN when it does not fit any of the known
        // patterns for a specific region.
        public static const UNKNOWN:Number = -1;
    }
}
