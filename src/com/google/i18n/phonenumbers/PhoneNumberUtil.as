package com.google.i18n.phonenumbers
{
    import mx.utils.StringUtil;

    import org.as3commons.lang.ObjectUtils;
    import org.as3commons.lang.StringBuffer;
    import org.as3commons.lang.StringUtils;

    public class PhoneNumberUtil
    {
        private static var _instance:PhoneNumberUtil;

        public static function getInstance():PhoneNumberUtil
        {
            if(_instance == null) {
                _instance = new PhoneNumberUtil();
            }
            return _instance;
        }

        private var regionToMetadataMap:Object = {};

        /**
         * @const
         * @type {Number}
         * @private
         */
        private static const NANPA_COUNTRY_CODE_:Number = 1;


        /**
         * The minimum length of the national significant number.
         *
         * @const
         * @type {Number}
         * @private
         */
        private static const MIN_LENGTH_FOR_NSN_:Number = 2;


        /**
         * The ITU says the maximum length should be 15, but we have found longer
         * numbers in Germany.
         *
         * @const
         * @type {Number}
         * @private
         */
        private static const MAX_LENGTH_FOR_NSN_:Number = 17;


        /**
         * The maximum length of the country calling code.
         *
         * @const
         * @type {Number}
         * @private
         */
        private static const MAX_LENGTH_COUNTRY_CODE_:Number = 3;


        /**
         * We don't allow input strings for parsing to be longer than 250 chars. This
         * prevents malicious input from consuming CPU.
         *
         * @const
         * @type {Number}
         * @private
         */
        private static const MAX_INPUT_STRING_LENGTH_:Number = 250;


        /**
         * Region-code for the unknown region.
         *
         * @const
         * @type {String}
         * @private
         */
        private static const UNKNOWN_REGION_:String = 'ZZ';


        /**
         * The prefix that needs to be inserted in front of a Colombian landline number
         * when dialed from a mobile phone in Colombia.
         *
         * @const
         * @type {String}
         * @private
         */
        private static const COLOMBIA_MOBILE_TO_FIXED_LINE_PREFIX_:String = '3';


        /**
         * Map of country calling codes that use a mobile token before the area code.
         * One example of when this is relevant is when determining the length of the
         * national destination code, which should be the length of the area code plus
         * the length of the mobile token.
         *
         * @const
         * @type {!Object.<int, String>}
         * @private
         */
        private static const MOBILE_TOKEN_MAPPINGS_:Object = {
            52: '1', 54: '9'
        };


        /**
         * Set of country calling codes that have geographically assigned mobile
         * numbers. This may not be complete; we add calling codes case by case, as we
         * find geographical mobile numbers or hear from user reports.
         *
         * @const
         * @type {!Array.<int>}
         * @private
         */
        private static const GEO_MOBILE_COUNTRIES_:Object = [52,  // Mexico
            54,  // Argentina
            55  // Brazil
        ];


        /**
         * The PLUS_SIGN signifies the international prefix.
         *
         * @const
         * @type {String}
         */
        public static const PLUS_SIGN:String = '+';


        /**
         * @const
         * @type {String}
         * @private
         */
        private static const STAR_SIGN_:String = '*';


        /**
         * The RFC 3966 format for extensions.
         *
         * @const
         * @type {String}
         * @private
         */
        private static const RFC3966_EXTN_PREFIX_:String = ';ext=';


        /**
         * @const
         * @type {String}
         * @private
         */
        private static const RFC3966_PREFIX_:String = 'tel:';


        /**
         * @const
         * @type {String}
         * @private
         */
        private static const RFC3966_PHONE_CONTEXT_:String = ';phone-context=';


        /**
         * @const
         * @type {String}
         * @private
         */
        private static const RFC3966_ISDN_SUBADDRESS_:String = ';isub=';


        /**
         * These mappings map a character (key) to a specific digit that should replace
         * it for normalization purposes. Non-European digits that may be used in phone
         * numbers are mapped to a European equivalent.
         *
         * @const
         * @type {!Object.<String, String>}
         */
        public static const DIGIT_MAPPINGS:Object = {
            '0': '0', '1': '1', '2': '2', '3': '3', '4': '4', '5': '5', '6': '6', '7': '7', '8': '8', '9': '9', '\uFF10': '0', // Fullwidth digit 0
            '\uFF11': '1', // Fullwidth digit 1
            '\uFF12': '2', // Fullwidth digit 2
            '\uFF13': '3', // Fullwidth digit 3
            '\uFF14': '4', // Fullwidth digit 4
            '\uFF15': '5', // Fullwidth digit 5
            '\uFF16': '6', // Fullwidth digit 6
            '\uFF17': '7', // Fullwidth digit 7
            '\uFF18': '8', // Fullwidth digit 8
            '\uFF19': '9', // Fullwidth digit 9
            '\u0660': '0', // Arabic-indic digit 0
            '\u0661': '1', // Arabic-indic digit 1
            '\u0662': '2', // Arabic-indic digit 2
            '\u0663': '3', // Arabic-indic digit 3
            '\u0664': '4', // Arabic-indic digit 4
            '\u0665': '5', // Arabic-indic digit 5
            '\u0666': '6', // Arabic-indic digit 6
            '\u0667': '7', // Arabic-indic digit 7
            '\u0668': '8', // Arabic-indic digit 8
            '\u0669': '9', // Arabic-indic digit 9
            '\u06F0': '0', // Eastern-Arabic digit 0
            '\u06F1': '1', // Eastern-Arabic digit 1
            '\u06F2': '2', // Eastern-Arabic digit 2
            '\u06F3': '3', // Eastern-Arabic digit 3
            '\u06F4': '4', // Eastern-Arabic digit 4
            '\u06F5': '5', // Eastern-Arabic digit 5
            '\u06F6': '6', // Eastern-Arabic digit 6
            '\u06F7': '7', // Eastern-Arabic digit 7
            '\u06F8': '8', // Eastern-Arabic digit 8
            '\u06F9': '9'  // Eastern-Arabic digit 9
        };


        /**
         * A map that contains characters that are essential when dialling. That means
         * any of the characters in this map must not be removed from a number when
         * dialling, otherwise the call will not reach the intended destination.
         *
         * @const
         * @type {!Object.<String, String>}
         * @private
         */
        private static const DIALLABLE_CHAR_MAPPINGS_:Object = {
            '0': '0', '1': '1', '2': '2', '3': '3', '4': '4', '5': '5', '6': '6', '7': '7', '8': '8', '9': '9', '+': PLUS_SIGN, '*': '*'
        };


        /**
         * Only upper-case variants of alpha characters are stored.
         *
         * @const
         * @type {!Object.<String, String>}
         * @private
         */
        private static const ALPHA_MAPPINGS_:Object = {
            'A': '2',
            'B': '2',
            'C': '2',
            'D': '3',
            'E': '3',
            'F': '3',
            'G': '4',
            'H': '4',
            'I': '4',
            'J': '5',
            'K': '5',
            'L': '5',
            'M': '6',
            'N': '6',
            'O': '6',
            'P': '7',
            'Q': '7',
            'R': '7',
            'S': '7',
            'T': '8',
            'U': '8',
            'V': '8',
            'W': '9',
            'X': '9',
            'Y': '9',
            'Z': '9'
        };


        /**
         * For performance reasons, amalgamate both into one map.
         *
         * @const
         * @type {!Object.<String, String>}
         * @private
         */
        private static const ALL_NORMALIZATION_MAPPINGS_:Object = {
            '0': '0',
            '1': '1',
            '2': '2',
            '3': '3',
            '4': '4',
            '5': '5',
            '6': '6',
            '7': '7',
            '8': '8',
            '9': '9',
            '\uFF10': '0', // Fullwidth digit 0
            '\uFF11': '1', // Fullwidth digit 1
            '\uFF12': '2', // Fullwidth digit 2
            '\uFF13': '3', // Fullwidth digit 3
            '\uFF14': '4', // Fullwidth digit 4
            '\uFF15': '5', // Fullwidth digit 5
            '\uFF16': '6', // Fullwidth digit 6
            '\uFF17': '7', // Fullwidth digit 7
            '\uFF18': '8', // Fullwidth digit 8
            '\uFF19': '9', // Fullwidth digit 9
            '\u0660': '0', // Arabic-indic digit 0
            '\u0661': '1', // Arabic-indic digit 1
            '\u0662': '2', // Arabic-indic digit 2
            '\u0663': '3', // Arabic-indic digit 3
            '\u0664': '4', // Arabic-indic digit 4
            '\u0665': '5', // Arabic-indic digit 5
            '\u0666': '6', // Arabic-indic digit 6
            '\u0667': '7', // Arabic-indic digit 7
            '\u0668': '8', // Arabic-indic digit 8
            '\u0669': '9', // Arabic-indic digit 9
            '\u06F0': '0', // Eastern-Arabic digit 0
            '\u06F1': '1', // Eastern-Arabic digit 1
            '\u06F2': '2', // Eastern-Arabic digit 2
            '\u06F3': '3', // Eastern-Arabic digit 3
            '\u06F4': '4', // Eastern-Arabic digit 4
            '\u06F5': '5', // Eastern-Arabic digit 5
            '\u06F6': '6', // Eastern-Arabic digit 6
            '\u06F7': '7', // Eastern-Arabic digit 7
            '\u06F8': '8', // Eastern-Arabic digit 8
            '\u06F9': '9', // Eastern-Arabic digit 9
            'A': '2',
            'B': '2',
            'C': '2',
            'D': '3',
            'E': '3',
            'F': '3',
            'G': '4',
            'H': '4',
            'I': '4',
            'J': '5',
            'K': '5',
            'L': '5',
            'M': '6',
            'N': '6',
            'O': '6',
            'P': '7',
            'Q': '7',
            'R': '7',
            'S': '7',
            'T': '8',
            'U': '8',
            'V': '8',
            'W': '9',
            'X': '9',
            'Y': '9',
            'Z': '9'
        };


        /**
         * Separate map of all symbols that we wish to retain when formatting alpha
         * numbers. This includes digits, ASCII letters and number grouping symbols such
         * as '-' and ' '.
         *
         * @const
         * @type {!Object.<String, String>}
         * @private
         */
        private static const ALL_PLUS_NUMBER_GROUPING_SYMBOLS_:Object = {
            '0': '0',
            '1': '1',
            '2': '2',
            '3': '3',
            '4': '4',
            '5': '5',
            '6': '6',
            '7': '7',
            '8': '8',
            '9': '9',
            'A': 'A',
            'B': 'B',
            'C': 'C',
            'D': 'D',
            'E': 'E',
            'F': 'F',
            'G': 'G',
            'H': 'H',
            'I': 'I',
            'J': 'J',
            'K': 'K',
            'L': 'L',
            'M': 'M',
            'N': 'N',
            'O': 'O',
            'P': 'P',
            'Q': 'Q',
            'R': 'R',
            'S': 'S',
            'T': 'T',
            'U': 'U',
            'V': 'V',
            'W': 'W',
            'X': 'X',
            'Y': 'Y',
            'Z': 'Z',
            'a': 'A',
            'b': 'B',
            'c': 'C',
            'd': 'D',
            'e': 'E',
            'f': 'F',
            'g': 'G',
            'h': 'H',
            'i': 'I',
            'j': 'J',
            'k': 'K',
            'l': 'L',
            'm': 'M',
            'n': 'N',
            'o': 'O',
            'p': 'P',
            'q': 'Q',
            'r': 'R',
            's': 'S',
            't': 'T',
            'u': 'U',
            'v': 'V',
            'w': 'W',
            'x': 'X',
            'y': 'Y',
            'z': 'Z',
            '-': '-',
            '\uFF0D': '-',
            '\u2010': '-',
            '\u2011': '-',
            '\u2012': '-',
            '\u2013': '-',
            '\u2014': '-',
            '\u2015': '-',
            '\u2212': '-',
            '/': '/',
            '\uFF0F': '/',
            ' ': ' ',
            '\u3000': ' ',
            '\u2060': ' ',
            '.': '.',
            '\uFF0E': '.'
        };


        /**
         * Pattern that makes it easy to distinguish whether a region has a unique
         * international dialing prefix or not. If a region has a unique international
         * prefix (e.g. 011 in USA), it will be represented as a string that contains a
         * sequence of ASCII digits. If there are multiple available international
         * prefixes in a region, they will be represented as a regex string that always
         * contains character(s) other than ASCII digits. Note this regex also includes
         * tilde, which signals waiting for the tone.
         *
         * @const
         * @type {!RegExp}
         * @private
         */
        private static const UNIQUE_INTERNATIONAL_PREFIX_:RegExp = /[\d]+(?:[~\u2053\u223C\uFF5E][\d]+)?/;


        /**
         * Regular expression of acceptable punctuation found in phone numbers. This
         * excludes punctuation found as a leading character only. This consists of dash
         * characters, white space characters, full stops, slashes, square brackets,
         * parentheses and tildes. It also includes the letter 'x' as that is found as a
         * placeholder for carrier information in some phone numbers. Full-width
         * variants are also present.
         *
         * @const
         * @type {String}
         */
        public static const VALID_PUNCTUATION:String = '-x\u2010-\u2015\u2212\u30FC\uFF0D-\uFF0F \u00A0\u00AD\u200B\u2060\u3000' + '()\uFF08\uFF09\uFF3B\uFF3D.\\[\\]/~\u2053\u223C\uFF5E';


        /**
         * Digits accepted in phone numbers (ascii, fullwidth, arabic-indic, and eastern
         * arabic digits).
         *
         * @const
         * @type {String}
         * @private
         */
        private static const VALID_DIGITS_:String = '0-9\uFF10-\uFF19\u0660-\u0669\u06F0-\u06F9';


        /**
         * We accept alpha characters in phone numbers, ASCII only, upper and lower
         * case.
         *
         * @const
         * @type {String}
         * @private
         */
        private static const VALID_ALPHA_:String = 'A-Za-z';


        /**
         * @const
         * @type {String}
         * @private
         */
        private static const PLUS_CHARS_:String = '+\uFF0B';


        /**
         * @const
         * @type {!RegExp}
         */
        public static const PLUS_CHARS_PATTERN:RegExp = new RegExp('[' + PLUS_CHARS_ + ']+');


        /**
         * @const
         * @type {!RegExp}
         * @private
         */
        private static const LEADING_PLUS_CHARS_PATTERN_:RegExp = new RegExp('^[' + PLUS_CHARS_ + ']+');


        /**
         * @const
         * @type {String}
         * @private
         */
        private static const SEPARATOR_PATTERN_:String = '[' + VALID_PUNCTUATION + ']+';


        /**
         * @const
         * @type {!RegExp}
         */
        public static const CAPTURING_DIGIT_PATTERN:RegExp = new RegExp('([' + VALID_DIGITS_ + '])');


        /**
         * Regular expression of acceptable characters that may start a phone number for
         * the purposes of parsing. This allows us to strip away meaningless prefixes to
         * phone numbers that may be mistakenly given to us. This consists of digits,
         * the plus symbol and arabic-indic digits. This does not contain alpha
         * characters, although they may be used later in the number. It also does not
         * include other punctuation, as this will be stripped later during parsing and
         * is of no information value when parsing a number.
         *
         * @const
         * @type {!RegExp}
         * @private
         */
        private static const VALID_START_CHAR_PATTERN_:RegExp = new RegExp('[' + PLUS_CHARS_ + VALID_DIGITS_ + ']');


        /**
         * Regular expression of characters typically used to start a second phone
         * number for the purposes of parsing. This allows us to strip off parts of the
         * number that are actually the start of another number, such as for:
         * (530) 583-6985 x302/x2303 -> the second extension here makes this actually
         * two phone numbers, (530) 583-6985 x302 and (530) 583-6985 x2303. We remove
         * the second extension so that the first number is parsed correctly.
         *
         * @const
         * @type {!RegExp}
         * @private
         */
        private static const SECOND_NUMBER_START_PATTERN_:RegExp = /[\\\/] *x/;


        /**
         * Regular expression of trailing characters that we want to remove. We remove
         * all characters that are not alpha or numerical characters. The hash character
         * is retained here, as it may signify the previous block was an extension.
         *
         * @const
         * @type {!RegExp}
         * @private
         */
        private static const UNWANTED_END_CHAR_PATTERN_:RegExp = new RegExp('[^' + VALID_DIGITS_ + VALID_ALPHA_ + '#]+$');


        /**
         * We use this pattern to check if the phone number has at least three letters
         * in it - if so, then we treat it as a number where some phone-number digits
         * are represented by letters.
         *
         * @const
         * @type {!RegExp}
         * @private
         */
        private static const VALID_ALPHA_PHONE_PATTERN_:RegExp = /(?:.*?[A-Za-z]){3}.*/;


        /**
         * Regular expression of viable phone numbers. This is location independent.
         * Checks we have at least three leading digits, and only valid punctuation,
         * alpha characters and digits in the phone number. Does not include extension
         * data. The symbol 'x' is allowed here as valid punctuation since it is often
         * used as a placeholder for carrier codes, for example in Brazilian phone
         * numbers. We also allow multiple '+' characters at the start.
         * Corresponds to the following:
         * [digits]{minLengthNsn}|
         * plus_sign*
         * (([punctuation]|[star])*[digits]){3,}([punctuation]|[star]|[digits]|[alpha])*
         *
         * The first reg-ex is to allow short numbers (two digits long) to be parsed if
         * they are entered as "15" etc, but only if there is no punctuation in them.
         * The second expression restricts the number of digits to three or more, but
         * then allows them to be in international form, and to have alpha-characters
         * and punctuation. We split up the two reg-exes here and combine them when
         * creating the reg-ex VALID_PHONE_NUMBER_PATTERN_ itself so we can prefix it
         * with ^ and append $ to each branch.
         *
         * Note VALID_PUNCTUATION starts with a -, so must be the first in the range.
         *
         * @const
         * @type {String}
         * @private
         */
        private static const MIN_LENGTH_PHONE_NUMBER_PATTERN_:String = '[' + VALID_DIGITS_ + ']{' + MIN_LENGTH_FOR_NSN_ + '}';


        /**
         * See MIN_LENGTH_PHONE_NUMBER_PATTERN_ for a full description of this reg-exp.
         *
         * @const
         * @type {String}
         * @private
         */
        private static const VALID_PHONE_NUMBER_:String = '[' + PLUS_CHARS_ + ']*(?:[' + VALID_PUNCTUATION + STAR_SIGN_ + ']*[' + VALID_DIGITS_ + ']){3,}[' + VALID_PUNCTUATION + STAR_SIGN_ + VALID_ALPHA_ + VALID_DIGITS_ + ']*';


        /**
         * Default extension prefix to use when formatting. This will be put in front of
         * any extension component of the number, after the main national number is
         * formatted. For example, if you wish the default extension formatting to be
         * ' extn: 3456', then you should specify ' extn: ' here as the default
         * extension prefix. This can be overridden by region-specific preferences.
         *
         * @const
         * @type {String}
         * @private
         */
        private static const DEFAULT_EXTN_PREFIX_:String = ' ext. ';


        /**
         * Pattern to capture digits used in an extension.
         * Places a maximum length of '7' for an extension.
         *
         * @const
         * @type {String}
         * @private
         */
        private static const CAPTURING_EXTN_DIGITS_:String = '([' + VALID_DIGITS_ + ']{1,7})';


        /**
         * Regexp of all possible ways to write extensions, for use when parsing. This
         * will be run as a case-insensitive regexp match. Wide character versions are
         * also provided after each ASCII version. There are three regular expressions
         * here. The first covers RFC 3966 format, where the extension is added using
         * ';ext='. The second more generic one starts with optional white space and
         * ends with an optional full stop (.), followed by zero or more spaces/tabs and
         * then the numbers themselves. The other one covers the special case of
         * American numbers where the extension is written with a hash at the end, such
         * as '- 503#'. Note that the only capturing groups should be around the digits
         * that you want to capture as part of the extension, or else parsing will fail!
         * We allow two options for representing the accented o - the character itself,
         * and one in the unicode decomposed form with the combining acute accent.
         *
         * @const
         * @type {String}
         * @private
         */
        private static const EXTN_PATTERNS_FOR_PARSING_:String = RFC3966_EXTN_PREFIX_ + CAPTURING_EXTN_DIGITS_ + '|' + '[ \u00A0\\t,]*' + '(?:e?xt(?:ensi(?:o\u0301?|\u00F3))?n?|\uFF45?\uFF58\uFF54\uFF4E?|' + '[,x\uFF58#\uFF03~\uFF5E]|int|anexo|\uFF49\uFF4E\uFF54)' + '[:\\.\uFF0E]?[ \u00A0\\t,-]*' + CAPTURING_EXTN_DIGITS_ + '#?|' + '[- ]+([' + VALID_DIGITS_ + ']{1,5})#';


        /**
         * Regexp of all known extension prefixes used by different regions followed by
         * 1 or more valid digits, for use when parsing.
         *
         * @const
         * @type {!RegExp}
         * @private
         */
        private static const EXTN_PATTERN_:RegExp = new RegExp('(?:' + EXTN_PATTERNS_FOR_PARSING_ + ')$', 'i');


        /**
         * We append optionally the extension pattern to the end here, as a valid phone
         * number may have an extension prefix appended, followed by 1 or more digits.
         *
         * @const
         * @type {!RegExp}
         * @private
         */
        private static const VALID_PHONE_NUMBER_PATTERN_:RegExp = new RegExp('^' + MIN_LENGTH_PHONE_NUMBER_PATTERN_ + '$|' + '^' + VALID_PHONE_NUMBER_ + '(?:' + EXTN_PATTERNS_FOR_PARSING_ + ')?' + '$', 'i');


        /**
         * @const
         * @type {!RegExp}
         * @private
         */
        private static const NON_DIGITS_PATTERN_:RegExp = /\D+/;


        /**
         * This was originally set to $1 but there are some countries for which the
         * first group is not used in the national pattern (e.g. Argentina) so the $1
         * group does not match correctly.  Therefore, we use \d, so that the first
         * group actually used in the pattern will be matched.
         * @const
         * @type {!RegExp}
         * @private
         */
        private static const FIRST_GROUP_PATTERN_:RegExp = /(\$\d)/;


        /**
         * @const
         * @type {!RegExp}
         * @private
         */
        private static const NP_PATTERN_:RegExp = /\$NP/;


        /**
         * @const
         * @type {!RegExp}
         * @private
         */
        private static const FG_PATTERN_:RegExp = /\$FG/;


        /**
         * @const
         * @type {!RegExp}
         * @private
         */
        private static const CC_PATTERN_:RegExp = /\$CC/;


        /**
         * A pattern that is used to determine if the national prefix formatting rule
         * has the first group only, i.e., does not start with the national prefix.
         * Note that the pattern explicitly allows for unbalanced parentheses.
         * @const
         * @type {!RegExp}
         * @private
         */
        private static const FIRST_GROUP_ONLY_PREFIX_PATTERN_:RegExp = /^\(?\$1\)?$/;


        /**
         * @const
         * @type {String}
         */
        public static const REGION_CODE_FOR_NON_GEO_ENTITY:String = '001';

        public static const MatchType:Object = {
            NOT_A_NUMBER: 0, NO_MATCH: 1, SHORT_NSN_MATCH: 2, NSN_MATCH: 3, EXACT_MATCH: 4
        };

        public static const ValidationResult:Object = {
            IS_POSSIBLE: 0, INVALID_COUNTRY_CODE: 1, TOO_SHORT: 2, TOO_LONG: 3
        };

        public function PhoneNumberUtil()
        {

        }

        /**
         * Attempts to extract a possible number from the string passed in. This
         * currently strips all leading characters that cannot be used to start a phone
         * number. Characters that can be used to start a phone number are defined in
         * the VALID_START_CHAR_PATTERN. If none of these characters are found in the
         * number passed in, an empty string is returned. This function also attempts to
         * strip off any alternative extensions or endings if two or more are present,
         * such as in the case of: (530) 583-6985 x302/x2303. The second extension here
         * makes this actually two phone numbers, (530) 583-6985 x302 and (530) 583-6985
         * x2303. We remove the second extension so that the first number is parsed
         * correctly.
         *
         * @param {String} number the string that might contain a phone number.
         * @return {String} the number, stripped of any non-phone-number prefix (such as
         *     'Tel:') or an empty string if no character used to start phone numbers
         *     (such as + or any digit) is found in the number.
         */
        public static function extractPossibleNumber(number:String):String
        {
            var possibleNumber:String;
            var start:Number = number.search(VALID_START_CHAR_PATTERN_);
            if(start >= 0) {
                possibleNumber = number.substring(start);
                // Remove trailing non-alpha non-numerical characters.
                possibleNumber = possibleNumber.replace(UNWANTED_END_CHAR_PATTERN_, '');

                // Check for extra numbers at the end.
                var secondNumberStart:Number = possibleNumber.search(SECOND_NUMBER_START_PATTERN_);
                if(secondNumberStart >= 0) {
                    possibleNumber = possibleNumber.substring(0, secondNumberStart);
                }
            } else {
                possibleNumber = '';
            }
            return possibleNumber;
        }

        /**
         * Checks to see if the string of characters could possibly be a phone number at
         * all. At the moment, checks to see that the string begins with at least 2
         * digits, ignoring any punctuation commonly found in phone numbers. This method
         * does not require the number to be normalized in advance - but does assume
         * that leading non-number symbols have been removed, such as by the method
         * extractPossibleNumber.
         *
         * @param {String} number string to be checked for viability as a phone number.
         * @return {Boolean} true if the number could be a phone number of some sort,
         *     otherwise false.
         */
        public static function isViablePhoneNumber(number:String):Boolean
        {
            if(number.length < MIN_LENGTH_FOR_NSN_) {
                return false;
            }
            return matchesEntirely_(VALID_PHONE_NUMBER_PATTERN_, number);
        }

        /**
         * Normalizes a string of characters representing a phone number. This performs
         * the following conversions:
         *   Punctuation is stripped.
         *   For ALPHA/VANITY numbers:
         *   Letters are converted to their numeric representation on a telephone
         *       keypad. The keypad used here is the one defined in ITU Recommendation
         *       E.161. This is only done if there are 3 or more letters in the number,
         *       to lessen the risk that such letters are typos.
         *   For other numbers:
         *   Wide-ascii digits are converted to normal ASCII (European) digits.
         *   Arabic-Indic numerals are converted to European numerals.
         *   Spurious alpha characters are stripped.
         *
         * @param {String} number a string of characters representing a phone number.
         * @return {String} the normalized string version of the phone number.
         */
        public static function normalize(number:String):String
        {
            if(matchesEntirely_(VALID_ALPHA_PHONE_PATTERN_, number)) {
                return normalizeHelper_(number, ALL_NORMALIZATION_MAPPINGS_, true);
            } else {
                return normalizeDigitsOnly(number);
            }
        }

        /**
         * Normalizes a string of characters representing a phone number. This is a
         * wrapper for normalize(String number) but does in-place normalization of the
         * StringBuffer provided.
         *
         * @param {StringBuffer} number a StringBuffer of characters
         *     representing a phone number that will be normalized in place.
         * @private
         */
        private static function normalizeSB_(number:StringBuffer):void
        {
            var normalizedNumber:String = normalize(number.toString());
            number.clear();
            number.append(normalizedNumber);
        }

        /**
         * Normalizes a string of characters representing a phone number. This converts
         * wide-ascii and arabic-indic numerals to European numerals, and strips
         * punctuation and alpha characters.
         *
         * @param {String} number a string of characters representing a phone number.
         * @return {String} the normalized string version of the phone number.
         */
        public static function normalizeDigitsOnly(number:String):String
        {
            return normalizeHelper_(number, DIGIT_MAPPINGS, true);
        }

        /**
         * Converts all alpha characters in a number to their respective digits on a
         * keypad, but retains existing formatting. Also converts wide-ascii digits to
         * normal ascii digits, and converts Arabic-Indic numerals to European numerals.
         *
         * @param {String} number a string of characters representing a phone number.
         * @return {String} the normalized string version of the phone number.
         */
        public static function convertAlphaCharactersInNumber(number:String):String
        {
            return normalizeHelper_(number, ALL_NORMALIZATION_MAPPINGS_, false);
        }

        /**
         * Gets the length of the geographical area code from the
         * {@code national_number} field of the PhoneNumber object passed in, so that
         * clients could use it to split a national significant number into geographical
         * area code and subscriber number. It works in such a way that the resultant
         * subscriber number should be diallable, at least on some devices. An example
         * of how this could be used:
         *
         * <pre>
         * var phoneUtil = getInstance();
         * var number = phoneUtil.parse('16502530000', 'US');
         * var nationalSignificantNumber =
         *     phoneUtil.getNationalSignificantNumber(number);
         * var areaCode;
         * var subscriberNumber;
         *
         * var areaCodeLength = phoneUtil.getLengthOfGeographicalAreaCode(number);
         * if (areaCodeLength > 0) {
         *   areaCode = nationalSignificantNumber.substring(0, areaCodeLength);
         *   subscriberNumber = nationalSignificantNumber.substring(areaCodeLength);
         * } else {
         *   areaCode = '';
         *   subscriberNumber = nationalSignificantNumber;
         * }
         * </pre>
         *
         * N.B.: area code is a very ambiguous concept, so the I18N team generally
         * recommends against using it for most purposes, but recommends using the more
         * general {@code national_number} instead. Read the following carefully before
         * deciding to use this method:
         * <ul>
         *  <li> geographical area codes change over time, and this method honors those
         *    changes; therefore, it doesn't guarantee the stability of the result it
         *    produces.
         *  <li> subscriber numbers may not be diallable from all devices (notably
         *    mobile devices, which typically requires the full national_number to be
         *    dialled in most regions).
         *  <li> most non-geographical numbers have no area codes, including numbers
         *    from non-geographical entities.
         *  <li> some geographical numbers have no area codes.
         * </ul>
         *
         * @param {PhoneNumber} number the PhoneNumber object for
         *     which clients want to know the length of the area code.
         * @return {Number} the length of area code of the PhoneNumber object passed in.
         */
        public function getLengthOfGeographicalAreaCode(number:PhoneNumber):Number
        {
            var metadata:PhoneMetadata = this.getMetadataForRegion(this.getRegionCodeForNumber(number));
            if(metadata == null) {
                return 0;
            }
            // If a country doesn't use a national prefix, and this number doesn't have
            // an Italian leading zero, we assume it is a closed dialling plan with no
            // area codes.
            if(!metadata.hasNationalPrefix() && !number.hasItalianLeadingZero()) {
                return 0;
            }

            if(!this.isNumberGeographical(number)) {
                return 0;
            }

            return this.getLengthOfNationalDestinationCode(number);
        }

        /**
         * Gets the length of the national destination code (NDC) from the PhoneNumber
         * object passed in, so that clients could use it to split a national
         * significant number into NDC and subscriber number. The NDC of a phone number
         * is normally the first group of digit(s) right after the country calling code
         * when the number is formatted in the international format, if there is a
         * subscriber number part that follows. An example of how this could be used:
         *
         * <pre>
         * var phoneUtil = getInstance();
         * var number = phoneUtil.parse('18002530000', 'US');
         * var nationalSignificantNumber =
         *     phoneUtil.getNationalSignificantNumber(number);
         * var nationalDestinationCode;
         * var subscriberNumber;
         *
         * var nationalDestinationCodeLength =
         *     phoneUtil.getLengthOfNationalDestinationCode(number);
         * if (nationalDestinationCodeLength > 0) {
         *   nationalDestinationCode =
         *       nationalSignificantNumber.substring(0, nationalDestinationCodeLength);
         *   subscriberNumber =
         *       nationalSignificantNumber.substring(nationalDestinationCodeLength);
         * } else {
         *   nationalDestinationCode = '';
         *   subscriberNumber = nationalSignificantNumber;
         * }
         * </pre>
         *
         * Refer to the unittests to see the difference between this function and
         * {@link #getLengthOfGeographicalAreaCode}.
         *
         * @param {PhoneNumber} number the PhoneNumber object for
         *     which clients want to know the length of the NDC.
         * @return {Number} the length of NDC of the PhoneNumber object passed in.
         */
        public function getLengthOfNationalDestinationCode(number:PhoneNumber):Number
        {
            var copiedProto:PhoneNumber;
            if(number.hasExtension()) {
                // We don't want to alter the proto given to us, but we don't want to
                // include the extension when we format it, so we copy it and clear the
                // extension here.
                copiedProto = ObjectUtils.clone(number);
                copiedProto.clearExtension();
            } else {
                copiedProto = number;
            }

            var nationalSignificantNumber:String = this.format(copiedProto, PhoneNumberFormat.INTERNATIONAL);
            var numberGroups:Array = nationalSignificantNumber.split(NON_DIGITS_PATTERN_);
            // The pattern will start with '+COUNTRY_CODE ' so the first group will always
            // be the empty string (before the + symbol) and the second group will be the
            // country calling code. The third group will be area code if it is not the
            // last group.
            // NOTE: On IE the first group that is supposed to be the empty string does
            // not appear in the array of number groups... so make the result on non-IE
            // browsers to be that of IE.
            if(numberGroups[0].length == 0) {
                numberGroups.shift();
            }
            if(numberGroups.length <= 2) {
                return 0;
            }

            if(this.getNumberType(number) == PhoneNumberType.MOBILE) {
                // For example Argentinian mobile numbers, when formatted in the
                // international format, are in the form of +54 9 NDC XXXX.... As a result,
                // we take the length of the third group (NDC) and add the length of the
                // mobile token, which also forms part of the national significant number.
                // This assumes that the mobile token is always formatted separately from
                // the rest of the phone number.
                var mobileToken:String = getCountryMobileToken(number.getCountryCode());
                if(mobileToken != '') {
                    return numberGroups[2].length + mobileToken.length;
                }
            }
            return numberGroups[1].length;
        }

        /**
         * Returns the mobile token for the provided country calling code if it has
         * one, otherwise returns an empty string. A mobile token is a number inserted
         * before the area code when dialing a mobile number from that country from
         * abroad.
         *
         * @param {Number} countryCallingCode the country calling code for which we
         *     want the mobile token.
         * @return {String} the mobile token for the given country calling code.
         */
        public static function getCountryMobileToken(countryCallingCode:Number):String
        {
            return MOBILE_TOKEN_MAPPINGS_[countryCallingCode] || '';
        }

        /**
         * Convenience method to get a list of what regions the library has metadata
         * for.
         * @return {!Array.<String>} region codes supported by the library.
         */
        public function getSupportedRegions():Array
        {
            var keys:Array = [];
            for(var key:String in Metadata.countryToMetadata) {
                if(Metadata.countryToMetadata.hasOwnProperty(key))
                    keys.push(key);
            }
            return keys.filter(function (regionCode:String):Boolean
            {
                return isNaN(Number(regionCode));
            });
        }

        /**
         * Convenience method to get a list of what global network calling codes the
         * library has metadata for.
         * @return {!Array.<int>} global network calling codes supported by the
         *     library.
         */
        public function getSupportedGlobalNetworkCallingCodes():Array
        {
            var keys:Array = [];
            for(var key:String in Metadata.countryToMetadata) {
                if(Metadata.countryToMetadata.hasOwnProperty(key))
                    keys.push(key);
            }
            var callingCodesAsStrings:Array = keys.filter(function (regionCode:String):Boolean
            {
                return !isNaN(Number(regionCode));
            });
            return callingCodesAsStrings.map(function (callingCode:String):Boolean
            {
                return !isNaN(Number(callingCode));
            });
        }

        /**
         * Normalizes a string of characters representing a phone number by replacing
         * all characters found in the accompanying map with the values therein, and
         * stripping all other characters if removeNonMatches is true.
         *
         * @param {String} number a string of characters representing a phone number.
         * @param {!Object.<String, String>} normalizationReplacements a mapping of
         *     characters to what they should be replaced by in the normalized version
         *     of the phone number.
         * @param {Boolean} removeNonMatches indicates whether characters that are not
         *     able to be replaced should be stripped from the number. If this is false,
         *     they will be left unchanged in the number.
         * @return {String} the normalized string version of the phone number.
         * @private
         */
        private static function normalizeHelper_(number:String, normalizationReplacements:Object, removeNonMatches:Boolean):String
        {
            var normalizedNumber:StringBuffer = new StringBuffer();
            var character:String;
            var newDigit:String;
            var numberLength:Number = number.length;
            for(var i:Number = 0; i < numberLength; ++i) {
                character = number.charAt(i);
                newDigit = normalizationReplacements[character.toUpperCase()];
                if(newDigit != null) {
                    normalizedNumber.append(newDigit);
                } else
                    if(!removeNonMatches) {
                        normalizedNumber.append(character);
                    }
            }
            return normalizedNumber.toString();
        }

        /**
         * Helper function to check if the national prefix formatting rule has the first
         * group only, i.e., does not start with the national prefix.
         *
         * @param {String} nationalPrefixFormattingRule The formatting rule for the
         *     national prefix.
         * @return {Boolean} true if the national prefix formatting rule has the first
         *     group only.
         */
        public function formattingRuleHasFirstGroupOnly(nationalPrefixFormattingRule:String):Boolean
        {
            return nationalPrefixFormattingRule.length == 0 || FIRST_GROUP_ONLY_PREFIX_PATTERN_.test(nationalPrefixFormattingRule);
        }

        /**
         * Tests whether a phone number has a geographical association. It checks if
         * the number is associated to a certain region in the country where it belongs
         * to. Note that this doesn't verify if the number is actually in use.
         *
         * @param {PhoneNumber} phoneNumber The phone number to test.
         * @return {Boolean} true if the phone number has a geographical association.
         */
        public function isNumberGeographical(phoneNumber:PhoneNumber):Boolean
        {
            var numberType:Number = this.getNumberType(phoneNumber);

            return numberType == PhoneNumberType.FIXED_LINE || numberType == PhoneNumberType.FIXED_LINE_OR_MOBILE || (GEO_MOBILE_COUNTRIES_.hasOwnProperty(phoneNumber.getCountryCode().toString()) && numberType == PhoneNumberType.MOBILE);
        }

        /**
         * Helper function to check region code is not unknown or null.
         *
         * @param {?String} regionCode the ISO 3166-1 two-letter region code.
         * @return {Boolean} true if region code is valid.
         * @private
         */
        private static function isValidRegionCode_(regionCode:String):Boolean
        {
            // In Java we check whether the regionCode is contained in supportedRegions
            // that is built out of all the values of countryCallingCodeToRegionCodeMap
            // (countryCodeToRegionCodeMap in JS) minus REGION_CODE_FOR_NON_GEO_ENTITY.
            // In JS we check whether the regionCode is contained in the keys of
            // countryToMetadata but since for non-geographical country calling codes
            // (e.g. +800) we use the country calling codes instead of the region code as
            // key in the map we have to make sure regionCode is not a number to prevent
            // returning true for non-geographical country calling codes.
            return regionCode != null && isNaN(Number(regionCode)) && regionCode.toUpperCase() in Metadata.countryToMetadata;
        }

        /**
         * Helper function to check the country calling code is valid.
         *
         * @param {Number} countryCallingCode the country calling code.
         * @return {Boolean} true if country calling code code is valid.
         * @private
         */
        private static function hasValidCountryCallingCode_(countryCallingCode:Number):Boolean
        {
            return countryCallingCode in Metadata.countryCodeToRegionCodeMap;
        }

        /**
         * Formats a phone number in the specified format using default rules. Note that
         * this does not promise to produce a phone number that the user can dial from
         * where they are - although we do format in either 'national' or
         * 'international' format depending on what the client asks for, we do not
         * currently support a more abbreviated format, such as for users in the same
         * 'area' who could potentially dial the number without area code. Note that if
         * the phone number has a country calling code of 0 or an otherwise invalid
         * country calling code, we cannot work out which formatting rules to apply so
         * we return the national significant number with no formatting applied.
         *
         * @param {PhoneNumber} number the phone number to be
         *     formatted.
         * @param {PhoneNumberFormat} numberFormat the format the
         *     phone number should be formatted into.
         * @return {String} the formatted phone number.
         */
        public function format(number:PhoneNumber, numberFormat:Number):String
        {
            if(number.getNationalNumber() == 0 && number.hasRawInput()) {
                // Unparseable numbers that kept their raw input just use that.
                // This is the only case where a number can be formatted as E164 without a
                // leading '+' symbol (but the original number wasn't parseable anyway).
                // TODO: Consider removing the 'if' above so that unparseable strings
                // without raw input format to the empty string instead of "+00"
                var rawInput:String = number.getRawInput();
                if(rawInput.length > 0) {
                    return rawInput;
                }
            }
            var countryCallingCode:Number = number.getCountryCode();
            var nationalSignificantNumber:String = getNationalSignificantNumber(number);
            if(numberFormat == PhoneNumberFormat.E164) {
                // Early exit for E164 case (even if the country calling code is invalid)
                // since no formatting of the national number needs to be applied.
                // Extensions are not formatted.
                return prefixNumberWithCountryCallingCode_(countryCallingCode, PhoneNumberFormat.E164, nationalSignificantNumber, '');
            }
            if(!hasValidCountryCallingCode_(countryCallingCode)) {
                return nationalSignificantNumber;
            }
            // Note getRegionCodeForCountryCode() is used because formatting information
            // for regions which share a country calling code is contained by only one
            // region for performance reasons. For example, for NANPA regions it will be
            // contained in the metadata for US.
            var regionCode:String = getRegionCodeForCountryCode(countryCallingCode);

            // Metadata cannot be null because the country calling code is valid (which
            // means that the region code cannot be ZZ and must be one of our supported
            // region codes).
            var metadata:PhoneMetadata = this.getMetadataForRegionOrCallingCode_(countryCallingCode, regionCode);
            var formattedExtension:String = maybeGetFormattedExtension_(number, metadata, numberFormat);
            var formattedNationalNumber:String = formatNsn_(nationalSignificantNumber, metadata, numberFormat);
            return prefixNumberWithCountryCallingCode_(countryCallingCode, numberFormat, formattedNationalNumber, formattedExtension);
        }

        /**
         * Formats a phone number in the specified format using client-defined
         * formatting rules. Note that if the phone number has a country calling code of
         * zero or an otherwise invalid country calling code, we cannot work out things
         * like whether there should be a national prefix applied, or how to format
         * extensions, so we return the national significant number with no formatting
         * applied.
         *
         * @param {PhoneNumber} number the phone  number to be
         *     formatted.
         * @param {PhoneNumberFormat} numberFormat the format the
         *     phone number should be formatted into.
         * @param {Array.<NumberFormat>} userDefinedFormats formatting
         *     rules specified by clients.
         * @return {String} the formatted phone number.
         */
        public function formatByPattern(number:PhoneNumber, numberFormat:Number, userDefinedFormats:Array):String
        {
            var countryCallingCode:Number = number.getCountryCode();
            var nationalSignificantNumber:String = getNationalSignificantNumber(number);
            if(!hasValidCountryCallingCode_(countryCallingCode)) {
                return nationalSignificantNumber;
            }
            // Note getRegionCodeForCountryCode() is used because formatting information
            // for regions which share a country calling code is contained by only one
            // region for performance reasons. For example, for NANPA regions it will be
            // contained in the metadata for US.
            var regionCode:String = getRegionCodeForCountryCode(countryCallingCode);
            // Metadata cannot be null because the country calling code is valid
            var metadata:PhoneMetadata = this.getMetadataForRegionOrCallingCode_(countryCallingCode, regionCode);
            var formattedNumber:String = '';
            var formattingPattern:NumberFormat = chooseFormattingPatternForNumber_(userDefinedFormats, nationalSignificantNumber);
            if(formattingPattern == null) {
                // If no pattern above is matched, we format the number as a whole.
                formattedNumber = nationalSignificantNumber;
            } else {
                // Before we do a replacement of the national prefix pattern $NP with the
                // national prefix, we need to copy the rule so that subsequent replacements
                // for different numbers have the appropriate national prefix.
                var numFormatCopy:NumberFormat = ObjectUtils.clone(formattingPattern);
                var nationalPrefixFormattingRule:String = formattingPattern.getNationalPrefixFormattingRule();
                if(nationalPrefixFormattingRule.length > 0) {
                    var nationalPrefix:String = metadata.getNationalPrefix();
                    if(nationalPrefix.length > 0) {
                        // Replace $NP with national prefix and $FG with the first group ($1).
                        nationalPrefixFormattingRule = nationalPrefixFormattingRule
                            .replace(NP_PATTERN_, nationalPrefix)
                            .replace(FG_PATTERN_, '$1');
                        numFormatCopy.setNationalPrefixFormattingRule(nationalPrefixFormattingRule);
                    } else {
                        // We don't want to have a rule for how to format the national prefix if
                        // there isn't one.
                        numFormatCopy.clearNationalPrefixFormattingRule();
                    }
                }
                formattedNumber = formatNsnUsingPattern_(nationalSignificantNumber, numFormatCopy, numberFormat);
            }

            var formattedExtension:String = maybeGetFormattedExtension_(number, metadata, numberFormat);
            return prefixNumberWithCountryCallingCode_(countryCallingCode, numberFormat, formattedNumber, formattedExtension);
        }

        /**
         * Formats a phone number in national format for dialing using the carrier as
         * specified in the {@code carrierCode}. The {@code carrierCode} will always be
         * used regardless of whether the phone number already has a preferred domestic
         * carrier code stored. If {@code carrierCode} contains an empty string, returns
         * the number in national format without any carrier code.
         *
         * @param {PhoneNumber} number the phone number to be
         *     formatted.
         * @param {String} carrierCode the carrier selection code to be used.
         * @return {String} the formatted phone number in national format for dialing
         *     using the carrier as specified in the {@code carrierCode}.
         */
        public function formatNationalNumberWithCarrierCode(number:PhoneNumber, carrierCode:String):String
        {
            var countryCallingCode:Number = number.getCountryCode();
            var nationalSignificantNumber:String = getNationalSignificantNumber(number);
            if(!hasValidCountryCallingCode_(countryCallingCode)) {
                return nationalSignificantNumber;
            }

            // Note getRegionCodeForCountryCode() is used because formatting information
            // for regions which share a country calling code is contained by only one
            // region for performance reasons. For example, for NANPA regions it will be
            // contained in the metadata for US.
            var regionCode:String = getRegionCodeForCountryCode(countryCallingCode);
            // Metadata cannot be null because the country calling code is valid.
            var metadata:PhoneMetadata = this.getMetadataForRegionOrCallingCode_(countryCallingCode, regionCode);
            var formattedExtension:String = maybeGetFormattedExtension_(number, metadata, PhoneNumberFormat.NATIONAL);
            var formattedNationalNumber:String = formatNsn_(nationalSignificantNumber, metadata, PhoneNumberFormat.NATIONAL, carrierCode);
            return prefixNumberWithCountryCallingCode_(countryCallingCode, PhoneNumberFormat.NATIONAL, formattedNationalNumber, formattedExtension);
        }

        /**
         * @param {Number} countryCallingCode
         * @param {?String} regionCode
         * @return {PhoneMetadata}
         * @private
         */
        private function getMetadataForRegionOrCallingCode_(countryCallingCode:Number, regionCode:String):PhoneMetadata
        {
            return REGION_CODE_FOR_NON_GEO_ENTITY == regionCode ? this.getMetadataForNonGeographicalRegion(countryCallingCode) : this.getMetadataForRegion(regionCode);
        }

        /**
         * Formats a phone number in national format for dialing using the carrier as
         * specified in the preferred_domestic_carrier_code field of the PhoneNumber
         * object passed in. If that is missing, use the {@code fallbackCarrierCode}
         * passed in instead. If there is no {@code preferred_domestic_carrier_code},
         * and the {@code fallbackCarrierCode} contains an empty string, return the
         * number in national format without any carrier code.
         *
         * <p>Use {@link #formatNationalNumberWithCarrierCode} instead if the carrier
         * code passed in should take precedence over the number's
         * {@code preferred_domestic_carrier_code} when formatting.
         *
         * @param {PhoneNumber} number the phone number to be
         *     formatted.
         * @param {String} fallbackCarrierCode the carrier selection code to be used, if
         *     none is found in the phone number itself.
         * @return {String} the formatted phone number in national format for dialing
         *     using the number's preferred_domestic_carrier_code, or the
         *     {@code fallbackCarrierCode} passed in if none is found.
         */
        public function formatNationalNumberWithPreferredCarrierCode(number:PhoneNumber, fallbackCarrierCode:String):String
        {
            return this.formatNationalNumberWithCarrierCode(number, number.hasPreferredDomesticCarrierCode() ? number.getPreferredDomesticCarrierCode() : fallbackCarrierCode);
        }

        /**
         * Returns a number formatted in such a way that it can be dialed from a mobile
         * phone in a specific region. If the number cannot be reached from the region
         * (e.g. some countries block toll-free numbers from being called outside of the
         * country), the method returns an empty string.
         *
         * @param {PhoneNumber} number the phone number to be
         *     formatted.
         * @param {String} regionCallingFrom the region where the call is being placed.
         * @param {Boolean} withFormatting whether the number should be returned with
         *     formatting symbols, such as spaces and dashes.
         * @return {String} the formatted phone number.
         */
        public function formatNumberForMobileDialing(number:PhoneNumber, regionCallingFrom:String, withFormatting:Boolean):String
        {
            var countryCallingCode:Number = number.getCountryCode();
            if(!hasValidCountryCallingCode_(countryCallingCode)) {
                return number.hasRawInput() ? number.getRawInput() : '';
            }

            var formattedNumber:String = '';
            // Clear the extension, as that part cannot normally be dialed together with
            // the main number.
            var numberNoExt:PhoneNumber = ObjectUtils.clone(number);
            numberNoExt.clearExtension();
            var regionCode:String = getRegionCodeForCountryCode(countryCallingCode);
            var numberType:Number = this.getNumberType(numberNoExt);
            var isValidNumber:Boolean = (numberType != PhoneNumberType.UNKNOWN);
            if(regionCallingFrom == regionCode) {
                var isFixedLineOrMobile:Boolean = (numberType == PhoneNumberType.FIXED_LINE) || (numberType == PhoneNumberType.MOBILE) || (numberType == PhoneNumberType.FIXED_LINE_OR_MOBILE);
                // Carrier codes may be needed in some countries. We handle this here.
                if(regionCode == 'CO' && numberType == PhoneNumberType.FIXED_LINE) {
                    formattedNumber = this.formatNationalNumberWithCarrierCode(numberNoExt, COLOMBIA_MOBILE_TO_FIXED_LINE_PREFIX_);
                } else
                    if(regionCode == 'BR' && isFixedLineOrMobile) {
                        formattedNumber = numberNoExt.hasPreferredDomesticCarrierCode() ? this.formatNationalNumberWithPreferredCarrierCode(numberNoExt, '') : // Brazilian fixed line and mobile numbers need to be dialed with a
                            // carrier code when called within Brazil. Without that, most of the
                            // carriers won't connect the call. Because of that, we return an
                            // empty string here.
                            '';
                    } else
                        if(isValidNumber && regionCode == 'HU') {
                            // The national format for HU numbers doesn't contain the national prefix,
                            // because that is how numbers are normally written down. However, the
                            // national prefix is obligatory when dialing from a mobile phone. As a
                            // result, we add it back here if it is a valid regular length phone
                            // number.
                            formattedNumber = this.getNddPrefixForRegion(regionCode, true /* strip non-digits */) + ' ' + this.format(numberNoExt, PhoneNumberFormat.NATIONAL);
                        } else
                            if(countryCallingCode == NANPA_COUNTRY_CODE_) {
                                // For NANPA countries, we output international format for numbers that
                                // can be dialed internationally, since that always works, except for
                                // numbers which might potentially be short numbers, which are always
                                // dialled in national format.
                                var regionMetadata:PhoneMetadata = this.getMetadataForRegion(regionCallingFrom);
                                if(this.canBeInternationallyDialled(numberNoExt) && !isShorterThanPossibleNormalNumber_(regionMetadata, getNationalSignificantNumber(numberNoExt))) {
                                    formattedNumber = this.format(numberNoExt, PhoneNumberFormat.INTERNATIONAL);
                                } else {
                                    formattedNumber = this.format(numberNoExt, PhoneNumberFormat.NATIONAL);
                                }
                            } else {
                                // For non-geographical countries, Mexican and Chilean fixed line and
                                // mobile numbers, we output international format for numbers that can be
                                // dialed internationally, as that always works.
                                if((regionCode == REGION_CODE_FOR_NON_GEO_ENTITY || // MX fixed line and mobile numbers should always be formatted in
                                    // international format, even when dialed within MX. For national
                                    // format to work, a carrier code needs to be used, and the correct
                                    // carrier code depends on if the caller and callee are from the
                                    // same local area. It is trickier to get that to work correctly than
                                    // using international format, which is tested to work fine on all
                                    // carriers.
                                    // CL fixed line numbers need the national prefix when dialing in the
                                    // national format, but don't have it when used for display. The
                                    // reverse is true for mobile numbers. As a result, we output them in
                                    // the international format to make it work.
                                    ((regionCode == 'MX' || regionCode == 'CL') && isFixedLineOrMobile)) && this.canBeInternationallyDialled(numberNoExt)) {
                                    formattedNumber = this.format(numberNoExt, PhoneNumberFormat.INTERNATIONAL);
                                } else {
                                    formattedNumber = this.format(numberNoExt, PhoneNumberFormat.NATIONAL);
                                }
                            }
            } else
                if(isValidNumber && this.canBeInternationallyDialled(numberNoExt)) {
                    // We assume that short numbers are not diallable from outside their region,
                    // so if a number is not a valid regular length phone number, we treat it as
                    // if it cannot be internationally dialled.
                    return withFormatting ? this.format(numberNoExt, PhoneNumberFormat.INTERNATIONAL) : this.format(numberNoExt, PhoneNumberFormat.E164);
                }
            return withFormatting ? formattedNumber : normalizeHelper_(formattedNumber, DIALLABLE_CHAR_MAPPINGS_, true);
        }

        /**
         * Formats a phone number for out-of-country dialing purposes. If no
         * regionCallingFrom is supplied, we format the number in its INTERNATIONAL
         * format. If the country calling code is the same as that of the region where
         * the number is from, then NATIONAL formatting will be applied.
         *
         * <p>If the number itself has a country calling code of zero or an otherwise
         * invalid country calling code, then we return the number with no formatting
         * applied.
         *
         * <p>Note this function takes care of the case for calling inside of NANPA and
         * between Russia and Kazakhstan (who share the same country calling code). In
         * those cases, no international prefix is used. For regions which have multiple
         * international prefixes, the number in its INTERNATIONAL format will be
         * returned instead.
         *
         * @param {PhoneNumber} number the phone number to be
         *     formatted.
         * @param {String} regionCallingFrom the region where the call is being placed.
         * @return {String} the formatted phone number.
         */
        public function formatOutOfCountryCallingNumber(number:PhoneNumber, regionCallingFrom:String):String
        {
            if(!isValidRegionCode_(regionCallingFrom)) {
                return this.format(number, PhoneNumberFormat.INTERNATIONAL);
            }
            var countryCallingCode:Number = number.getCountryCode();
            var nationalSignificantNumber:String = getNationalSignificantNumber(number);
            if(!hasValidCountryCallingCode_(countryCallingCode)) {
                return nationalSignificantNumber;
            }
            if(countryCallingCode == NANPA_COUNTRY_CODE_) {
                if(isNANPACountry(regionCallingFrom)) {
                    // For NANPA regions, return the national format for these regions but
                    // prefix it with the country calling code.
                    return countryCallingCode + ' ' + this.format(number, PhoneNumberFormat.NATIONAL);
                }
            } else
                if(countryCallingCode == this.getCountryCodeForValidRegion_(regionCallingFrom)) {
                    // If regions share a country calling code, the country calling code need
                    // not be dialled. This also applies when dialling within a region, so this
                    // if clause covers both these cases. Technically this is the case for
                    // dialling from La Reunion to other overseas departments of France (French
                    // Guiana, Martinique, Guadeloupe), but not vice versa - so we don't cover
                    // this edge case for now and for those cases return the version including
                    // country calling code. Details here:
                    // http://www.petitfute.com/voyage/225-info-pratiques-reunion
                    return this.format(number, PhoneNumberFormat.NATIONAL);
                }
            // Metadata cannot be null because we checked 'isValidRegionCode()' above.
            var metadataForRegionCallingFrom:PhoneMetadata = this.getMetadataForRegion(regionCallingFrom);
            var internationalPrefix:String = metadataForRegionCallingFrom.getInternationalPrefix();

            // For regions that have multiple international prefixes, the international
            // format of the number is returned, unless there is a preferred international
            // prefix.
            var internationalPrefixForFormatting:String = '';
            if(matchesEntirely_(UNIQUE_INTERNATIONAL_PREFIX_, internationalPrefix)) {
                internationalPrefixForFormatting = internationalPrefix;
            } else
                if(metadataForRegionCallingFrom.hasPreferredInternationalPrefix()) {
                    internationalPrefixForFormatting = metadataForRegionCallingFrom.getPreferredInternationalPrefix();
                }

            var regionCode:String = getRegionCodeForCountryCode(countryCallingCode);
            // Metadata cannot be null because the country calling code is valid.
            var metadataForRegion:PhoneMetadata = this.getMetadataForRegionOrCallingCode_(countryCallingCode, regionCode);
            var formattedNationalNumber:String = formatNsn_(nationalSignificantNumber, metadataForRegion, PhoneNumberFormat.INTERNATIONAL);
            var formattedExtension:String = maybeGetFormattedExtension_(number, metadataForRegion, PhoneNumberFormat.INTERNATIONAL);
            return internationalPrefixForFormatting.length > 0 ? internationalPrefixForFormatting + ' ' + countryCallingCode + ' ' + formattedNationalNumber + formattedExtension : prefixNumberWithCountryCallingCode_(countryCallingCode, PhoneNumberFormat.INTERNATIONAL, formattedNationalNumber, formattedExtension);
        }

        /**
         * Formats a phone number using the original phone number format that the number
         * is parsed from. The original format is embedded in the country_code_source
         * field of the PhoneNumber object passed in. If such information is missing,
         * the number will be formatted into the NATIONAL format by default. When the
         * number contains a leading zero and this is unexpected for this country, or we
         * don't have a formatting pattern for the number, the method returns the raw
         * input when it is available.
         *
         * Note this method guarantees no digit will be inserted, removed or modified as
         * a result of formatting.
         *
         * @param {PhoneNumber} number the phone number that needs to
         *     be formatted in its original number format.
         * @param {String} regionCallingFrom the region whose IDD needs to be prefixed
         *     if the original number has one.
         * @return {String} the formatted phone number in its original number format.
         */
        public function formatInOriginalFormat(number:PhoneNumber, regionCallingFrom:String):String
        {
            if(number.hasRawInput() && (this.hasUnexpectedItalianLeadingZero_(number) || !this.hasFormattingPatternForNumber_(number))) {
                // We check if we have the formatting pattern because without that, we might
                // format the number as a group without national prefix.
                return number.getRawInput();
            }
            if(!number.hasCountryCodeSource()) {
                return this.format(number, PhoneNumberFormat.NATIONAL);
            }
            var formattedNumber:String;
            switch(number.getCountryCodeSource()) {
                case PhoneNumber.CountryCodeSource.FROM_NUMBER_WITH_PLUS_SIGN:
                    formattedNumber = this.format(number, PhoneNumberFormat.INTERNATIONAL);
                    break;
                case PhoneNumber.CountryCodeSource.FROM_NUMBER_WITH_IDD:
                    formattedNumber = this.formatOutOfCountryCallingNumber(number, regionCallingFrom);
                    break;
                case PhoneNumber.CountryCodeSource.FROM_NUMBER_WITHOUT_PLUS_SIGN:
                    formattedNumber = this.format(number, PhoneNumberFormat.INTERNATIONAL).substring(1);
                    break;
                case PhoneNumber.CountryCodeSource.FROM_DEFAULT_COUNTRY:
                // Fall-through to default case.
                default:
                    var regionCode:String = getRegionCodeForCountryCode(number.getCountryCode());
                    // We strip non-digits from the NDD here, and from the raw input later,
                    // so that we can compare them easily.
                    var nationalPrefix:String = this.getNddPrefixForRegion(regionCode, true);
                    var nationalFormat:String = this.format(number, PhoneNumberFormat.NATIONAL);
                    if(nationalPrefix == null || nationalPrefix.length == 0) {
                        // If the region doesn't have a national prefix at all, we can safely
                        // return the national format without worrying about a national prefix
                        // being added.
                        formattedNumber = nationalFormat;
                        break;
                    }
                    // Otherwise, we check if the original number was entered with a national
                    // prefix.
                    if(this.rawInputContainsNationalPrefix_(number.getRawInput(), nationalPrefix, regionCode)) {
                        // If so, we can safely return the national format.
                        formattedNumber = nationalFormat;
                        break;
                    }
                    // Metadata cannot be null here because getNddPrefixForRegion() (above)
                    // returns null if there is no metadata for the region.
                    var metadata:PhoneMetadata = this.getMetadataForRegion(regionCode);
                    var nationalNumber:String = getNationalSignificantNumber(number);
                    var formatRule:NumberFormat = chooseFormattingPatternForNumber_(metadata.numberFormatArray(), nationalNumber);
                    // The format rule could still be null here if the national number was 0
                    // and there was no raw input (this should not be possible for numbers
                    // generated by the phonenumber library as they would also not have a
                    // country calling code and we would have exited earlier).
                    if(formatRule == null) {
                        formattedNumber = nationalFormat;
                        break;
                    }
                    // When the format we apply to this number doesn't contain national
                    // prefix, we can just return the national format.
                    // TODO: Refactor the code below with the code in
                    // isNationalPrefixPresentIfRequired.
                    var candidateNationalPrefixRule:String = formatRule.getNationalPrefixFormattingRule();
                    // We assume that the first-group symbol will never be _before_ the
                    // national prefix.
                    var indexOfFirstGroup:Number = candidateNationalPrefixRule.indexOf('$1');
                    if(indexOfFirstGroup <= 0) {
                        formattedNumber = nationalFormat;
                        break;
                    }
                    candidateNationalPrefixRule = candidateNationalPrefixRule.substring(0, indexOfFirstGroup);
                    candidateNationalPrefixRule = normalizeDigitsOnly(candidateNationalPrefixRule);
                    if(candidateNationalPrefixRule.length == 0) {
                        // National prefix not used when formatting this number.
                        formattedNumber = nationalFormat;
                        break;
                    }
                    // Otherwise, we need to remove the national prefix from our output.
                    var numFormatCopy:NumberFormat = ObjectUtils.clone(formatRule);
                    numFormatCopy.clearNationalPrefixFormattingRule();
                    formattedNumber = this.formatByPattern(number, PhoneNumberFormat.NATIONAL, [numFormatCopy]);
                    break;
            }
            var rawInput:String = number.getRawInput();
            // If no digit is inserted/removed/modified as a result of our formatting, we
            // return the formatted phone number; otherwise we return the raw input the
            // user entered.
            if(formattedNumber != null && rawInput.length > 0) {
                var normalizedFormattedNumber:String = normalizeHelper_(formattedNumber, DIALLABLE_CHAR_MAPPINGS_, true /* remove non matches */);
                var normalizedRawInput:String = normalizeHelper_(rawInput, DIALLABLE_CHAR_MAPPINGS_, true /* remove non matches */);
                if(normalizedFormattedNumber != normalizedRawInput) {
                    formattedNumber = rawInput;
                }
            }
            return formattedNumber;
        }

        /**
         * Check if rawInput, which is assumed to be in the national format, has a
         * national prefix. The national prefix is assumed to be in digits-only form.
         * @param {String} rawInput
         * @param {String} nationalPrefix
         * @param {String} regionCode
         * @return {Boolean}
         * @private
         */
        private function rawInputContainsNationalPrefix_(rawInput:String, nationalPrefix:String, regionCode:String):Boolean
        {
            var normalizedNationalNumber:String = normalizeDigitsOnly(rawInput);
            if(normalizedNationalNumber.lastIndexOf(nationalPrefix) == 0) {
                try {
                    // Some Japanese numbers (e.g. 00777123) might be mistaken to contain the
                    // national prefix when written without it (e.g. 0777123) if we just do
                    // prefix matching. To tackle that, we check the validity of the number if
                    // the assumed national prefix is removed (777123 won't be valid in
                    // Japan).
                    return this.isValidNumber(this.parse(normalizedNationalNumber.substring(nationalPrefix.length), regionCode));
                } catch(e:Exception) {
                    return false;
                }
            }
            return false;
        }

        /**
         * Returns true if a number is from a region whose national significant number
         * couldn't contain a leading zero, but has the italian_leading_zero field set
         * to true.
         * @param {PhoneNumber} number
         * @return {Boolean}
         * @private
         */
        private function hasUnexpectedItalianLeadingZero_(number:PhoneNumber):Boolean
        {
            return number.hasItalianLeadingZero() && !this.isLeadingZeroPossible(number.getCountryCode());
        }

        /**
         * @param {PhoneNumber} number
         * @return {Boolean}
         * @private
         */
        private function hasFormattingPatternForNumber_(number:PhoneNumber):Boolean
        {
            var countryCallingCode:Number = number.getCountryCode();
            var phoneNumberRegion:String = getRegionCodeForCountryCode(countryCallingCode);
            var metadata:PhoneMetadata = this.getMetadataForRegionOrCallingCode_(countryCallingCode, phoneNumberRegion);
            if(metadata == null) {
                return false;
            }
            var nationalNumber:String = getNationalSignificantNumber(number);
            var formatRule:NumberFormat = chooseFormattingPatternForNumber_(metadata.numberFormatArray(), nationalNumber);
            return formatRule != null;
        }

        /**
         * Formats a phone number for out-of-country dialing purposes.
         *
         * Note that in this version, if the number was entered originally using alpha
         * characters and this version of the number is stored in raw_input, this
         * representation of the number will be used rather than the digit
         * representation. Grouping information, as specified by characters such as '-'
         * and ' ', will be retained.
         *
         * <p><b>Caveats:</b></p>
         * <ul>
         * <li>This will not produce good results if the country calling code is both
         * present in the raw input _and_ is the start of the national number. This is
         * not a problem in the regions which typically use alpha numbers.
         * <li>This will also not produce good results if the raw input has any grouping
         * information within the first three digits of the national number, and if the
         * function needs to strip preceding digits/words in the raw input before these
         * digits. Normally people group the first three digits together so this is not
         * a huge problem - and will be fixed if it proves to be so.
         * </ul>
         *
         * @param {PhoneNumber} number the phone number that needs to
         *     be formatted.
         * @param {String} regionCallingFrom the region where the call is being placed.
         * @return {String} the formatted phone number.
         */

        public function formatOutOfCountryKeepingAlphaChars(number:PhoneNumber, regionCallingFrom:String):String
        {
            var rawInput:String = number.getRawInput();
            // If there is no raw input, then we can't keep alpha characters because there
            // aren't any. In this case, we return formatOutOfCountryCallingNumber.
            if(rawInput.length == 0) {
                return this.formatOutOfCountryCallingNumber(number, regionCallingFrom);
            }
            var countryCode:Number = number.getCountryCode();
            if(!hasValidCountryCallingCode_(countryCode)) {
                return rawInput;
            }
            // Strip any prefix such as country calling code, IDD, that was present. We do
            // this by comparing the number in raw_input with the parsed number. To do
            // this, first we normalize punctuation. We retain number grouping symbols
            // such as ' ' only.
            rawInput = normalizeHelper_(rawInput, ALL_PLUS_NUMBER_GROUPING_SYMBOLS_, true);
            // Now we trim everything before the first three digits in the parsed number.
            // We choose three because all valid alpha numbers have 3 digits at the start
            // - if it does not, then we don't trim anything at all. Similarly, if the
            // national number was less than three digits, we don't trim anything at all.
            var nationalNumber:String = getNationalSignificantNumber(number);
            if(nationalNumber.length > 3) {
                var firstNationalNumberDigit:Number = rawInput.indexOf(nationalNumber.substring(0, 3));
                if(firstNationalNumberDigit != -1) {
                    rawInput = rawInput.substring(firstNationalNumberDigit);
                }
            }
            var metadataForRegionCallingFrom:PhoneMetadata = this.getMetadataForRegion(regionCallingFrom);
            if(countryCode == NANPA_COUNTRY_CODE_) {
                if(isNANPACountry(regionCallingFrom)) {
                    return countryCode + ' ' + rawInput;
                }
            } else
                if(metadataForRegionCallingFrom != null && countryCode == this.getCountryCodeForValidRegion_(regionCallingFrom)) {
                    var formattingPattern:NumberFormat = chooseFormattingPatternForNumber_(metadataForRegionCallingFrom.numberFormatArray(), nationalNumber);
                    if(formattingPattern == null) {
                        // If no pattern above is matched, we format the original input.
                        return rawInput;
                    }
                    var newFormat:NumberFormat = ObjectUtils.clone(formattingPattern);
                    // The first group is the first group of digits that the user wrote
                    // together.
                    newFormat.setPattern('(\\d+)(.*)');
                    // Here we just concatenate them back together after the national prefix
                    // has been fixed.
                    newFormat.setFormat('$1$2');
                    // Now we format using this pattern instead of the default pattern, but
                    // with the national prefix prefixed if necessary.
                    // This will not work in the cases where the pattern (and not the leading
                    // digits) decide whether a national prefix needs to be used, since we have
                    // overridden the pattern to match anything, but that is not the case in the
                    // metadata to date.
                    return formatNsnUsingPattern_(rawInput, newFormat, PhoneNumberFormat.NATIONAL);
                }
            var internationalPrefixForFormatting:String = '';
            // If an unsupported region-calling-from is entered, or a country with
            // multiple international prefixes, the international format of the number is
            // returned, unless there is a preferred international prefix.
            if(metadataForRegionCallingFrom != null) {
                var internationalPrefix:String = metadataForRegionCallingFrom.getInternationalPrefix();
                internationalPrefixForFormatting = matchesEntirely_(UNIQUE_INTERNATIONAL_PREFIX_, internationalPrefix) ? internationalPrefix : metadataForRegionCallingFrom.getPreferredInternationalPrefix();
            }
            var regionCode:String = getRegionCodeForCountryCode(countryCode);
            // Metadata cannot be null because the country calling code is valid.
            var metadataForRegion:PhoneMetadata = this.getMetadataForRegionOrCallingCode_(countryCode, regionCode);
            var formattedExtension:String = maybeGetFormattedExtension_(number, metadataForRegion, PhoneNumberFormat.INTERNATIONAL);
            if(internationalPrefixForFormatting.length > 0) {
                return internationalPrefixForFormatting + ' ' + countryCode + ' ' + rawInput + formattedExtension;
            } else {
                // Invalid region entered as country-calling-from (so no metadata was found
                // for it) or the region chosen has multiple international dialling
                // prefixes.
                return prefixNumberWithCountryCallingCode_(countryCode, PhoneNumberFormat.INTERNATIONAL, rawInput, formattedExtension);
            }
        }

        /**
         * Gets the national significant number of the a phone number. Note a national
         * significant number doesn't contain a national prefix or any formatting.
         *
         * @param {PhoneNumber} number the phone number for which the
         *     national significant number is needed.
         * @return {String} the national significant number of the PhoneNumber object
         *     passed in.
         */
        public static function getNationalSignificantNumber(number:PhoneNumber):String
        {
            // If leading zero(s) have been set, we prefix this now. Note this is not a
            // national prefix.
            var nationalNumber:String = number.getNationalNumber().toString();
            if(number.hasItalianLeadingZero() && number.getItalianLeadingZero()) {
                return StringUtil.repeat('0', number.getNumberOfLeadingZeros() + 1) + nationalNumber;
            }
            return nationalNumber;
        }

        /**
         * A helper function that is used by format and formatByPattern.
         *
         * @param {Number} countryCallingCode the country calling code.
         * @param {PhoneNumberFormat} numberFormat the format the
         *     phone number should be formatted into.
         * @param {String} formattedNationalNumber
         * @param {String} formattedExtension
         * @return {String} the formatted phone number.
         * @private
         */
        private static function prefixNumberWithCountryCallingCode_(countryCallingCode:Number, numberFormat:Number, formattedNationalNumber:String, formattedExtension:String):String
        {
            switch(numberFormat) {
                case PhoneNumberFormat.E164:
                    return PLUS_SIGN + countryCallingCode + formattedNationalNumber + formattedExtension;
                case PhoneNumberFormat.INTERNATIONAL:
                    return PLUS_SIGN + countryCallingCode + ' ' + formattedNationalNumber + formattedExtension;
                case PhoneNumberFormat.RFC3966:
                    return RFC3966_PREFIX_ + PLUS_SIGN + countryCallingCode + '-' + formattedNationalNumber + formattedExtension;
                case PhoneNumberFormat.NATIONAL:
                default:
                    return formattedNationalNumber + formattedExtension;
            }
        }

        /**
         * Note in some regions, the national number can be written in two completely
         * different ways depending on whether it forms part of the NATIONAL format or
         * INTERNATIONAL format. The numberFormat parameter here is used to specify
         * which format to use for those cases. If a carrierCode is specified, this will
         * be inserted into the formatted string to replace $CC.
         *
         * @param {String} number a string of characters representing a phone number.
         * @param {PhoneMetadata} metadata the metadata for the
         *     region that we think this number is from.
         * @param {PhoneNumberFormat} numberFormat the format the
         *     phone number should be formatted into.
         * @param {String=} opt_carrierCode
         * @return {String} the formatted phone number.
         * @private
         */
        private static function formatNsn_(number:String, metadata:PhoneMetadata, numberFormat:Number, opt_carrierCode:String = null):String
        {
            // When the intlNumberFormats exists, we use that to format national number
            // for the INTERNATIONAL format instead of using the numberDesc.numberFormats.
            var availableFormats:Array = (metadata.intlNumberFormatSize() == 0 || numberFormat == PhoneNumberFormat.NATIONAL) ? metadata.numberFormatArray() : metadata.intlNumberFormatArray();
            var formattingPattern:NumberFormat = chooseFormattingPatternForNumber_(availableFormats, number);
            return (formattingPattern == null) ? number : formatNsnUsingPattern_(number, formattingPattern, numberFormat, opt_carrierCode);
        }

        /**
         * @param {Array.<NumberFormat>} availableFormats the
         *     available formats the phone number could be formatted into.
         * @param {String} nationalNumber a string of characters representing a phone
         *     number.
         * @return {NumberFormat}
         * @private
         */
        private static function chooseFormattingPatternForNumber_(availableFormats:Array, nationalNumber:String):NumberFormat
        {
            var numFormat:NumberFormat;
            var l:Number = availableFormats.length;
            for(var i:Number = 0; i < l; ++i) {
                numFormat = availableFormats[i];
                var size:Number = numFormat.leadingDigitsPatternCount();
                if(size == 0 || // We always use the last leading_digits_pattern, as it is the most
                    // detailed.
                    nationalNumber
                        .search(numFormat.getLeadingDigitsPattern(size - 1)) == 0) {
                    var patternToMatch:RegExp = new RegExp(numFormat.getPattern());
                    if(matchesEntirely_(patternToMatch, nationalNumber)) {
                        return numFormat;
                    }
                }
            }
            return null;
        }

        /**
         * Note that carrierCode is optional - if null or an empty string, no carrier
         * code replacement will take place.
         *
         * @param {String} nationalNumber a string of characters representing a phone
         *     number.
         * @param {NumberFormat} formattingPattern the formatting rule
         *     the phone number should be formatted into.
         * @param {PhoneNumberFormat} numberFormat the format the
         *     phone number should be formatted into.
         * @param {String=} opt_carrierCode
         * @return {String} the formatted phone number.
         * @private
         */
        private static function formatNsnUsingPattern_(nationalNumber:String, formattingPattern:NumberFormat, numberFormat:Number, opt_carrierCode:String = null):String
        {
            var numberFormatRule:String = formattingPattern.getFormat();
            var patternToMatch:RegExp = new RegExp(formattingPattern.getPattern());
            var domesticCarrierCodeFormattingRule:String = formattingPattern.getDomesticCarrierCodeFormattingRule();
            var formattedNationalNumber:String = '';
            if(numberFormat == PhoneNumberFormat.NATIONAL && opt_carrierCode != null && opt_carrierCode.length > 0 && domesticCarrierCodeFormattingRule.length > 0) {
                // Replace the $CC in the formatting rule with the desired carrier code.
                var carrierCodeFormattingRule:String = domesticCarrierCodeFormattingRule
                    .replace(CC_PATTERN_, opt_carrierCode);
                // Now replace the $FG in the formatting rule with the first group and
                // the carrier code combined in the appropriate way.
                numberFormatRule = numberFormatRule.replace(FIRST_GROUP_PATTERN_, carrierCodeFormattingRule);
                formattedNationalNumber = nationalNumber.replace(patternToMatch, numberFormatRule);
            } else {
                // Use the national prefix formatting rule instead.
                var nationalPrefixFormattingRule:String = formattingPattern.getNationalPrefixFormattingRule();
                if(numberFormat == PhoneNumberFormat.NATIONAL && nationalPrefixFormattingRule != null && nationalPrefixFormattingRule.length > 0) {
                    formattedNationalNumber = nationalNumber.replace(patternToMatch, numberFormatRule.replace(FIRST_GROUP_PATTERN_, nationalPrefixFormattingRule));
                } else {
                    formattedNationalNumber = nationalNumber.replace(patternToMatch, numberFormatRule);
                }
            }
            if(numberFormat == PhoneNumberFormat.RFC3966) {
                // Strip any leading punctuation.
                formattedNationalNumber = formattedNationalNumber.replace(new RegExp('^' + SEPARATOR_PATTERN_), '');
                // Replace the rest with a dash between each number group.
                formattedNationalNumber = formattedNationalNumber.replace(new RegExp(SEPARATOR_PATTERN_, 'g'), '-');
            }
            return formattedNationalNumber;
        }

        /**
         * Gets a valid number for the specified region.
         *
         * @param {String} regionCode the region for which an example number is needed.
         * @return {PhoneNumber} a valid fixed-line number for the
         *     specified region. Returns null when the metadata does not contain such
         *     information, or the region 001 is passed in. For 001 (representing non-
         *     geographical numbers), call {@link #getExampleNumberForNonGeoEntity}
         *     instead.
         */
        public function getExampleNumber(regionCode:String):PhoneNumber
        {
            return this.getExampleNumberForType(regionCode, PhoneNumberType.FIXED_LINE);
        }

        /**
         * Gets a valid number for the specified region and number type.
         *
         * @param {String} regionCode the region for which an example number is needed.
         * @param {PhoneNumberType} type the type of number that is
         *     needed.
         * @return {PhoneNumber} a valid number for the specified
         *     region and type. Returns null when the metadata does not contain such
         *     information or if an invalid region or region 001 was entered.
         *     For 001 (representing non-geographical numbers), call
         *     {@link #getExampleNumberForNonGeoEntity} instead.
         */
        public function getExampleNumberForType(regionCode:String, type:Number):PhoneNumber
        {
            // Check the region code is valid.
            if(!isValidRegionCode_(regionCode)) {
                return null;
            }
            var desc:PhoneNumberDesc = getNumberDescByType_(this.getMetadataForRegion(regionCode), type);
            try {
                if(desc.hasExampleNumber()) {
                    return this.parse(desc.getExampleNumber(), regionCode);
                }
            } catch(e:Exception) {
            }
            return null;
        }

        /**
         * Gets a valid number for the specified country calling code for a
         * non-geographical entity.
         *
         * @param {Number} countryCallingCode the country calling code for a
         *     non-geographical entity.
         * @return {PhoneNumber} a valid number for the
         *     non-geographical entity. Returns null when the metadata does not contain
         *     such information, or the country calling code passed in does not belong
         *     to a non-geographical entity.
         */
        public function getExampleNumberForNonGeoEntity(countryCallingCode:Number):PhoneNumber
        {
            var metadata:PhoneMetadata = this.getMetadataForNonGeographicalRegion(countryCallingCode);
            if(metadata != null) {
                var desc:PhoneNumberDesc = metadata.getGeneralDesc();
                try {
                    if(desc.hasExampleNumber()) {
                        return this.parse('+' + countryCallingCode + desc.getExampleNumber(), 'ZZ');
                    }
                } catch(e:Exception) {
                }
            }
            return null;
        }

        /**
         * Gets the formatted extension of a phone number, if the phone number had an
         * extension specified. If not, it returns an empty string.
         *
         * @param {PhoneNumber} number the PhoneNumber that might have
         *     an extension.
         * @param {PhoneMetadata} metadata the metadata for the
         *     region that we think this number is from.
         * @param {PhoneNumberFormat} numberFormat the format the
         *     phone number should be formatted into.
         * @return {String} the formatted extension if any.
         * @private
         */
        private static function maybeGetFormattedExtension_(number:PhoneNumber, metadata:PhoneMetadata, numberFormat:Number):String
        {
            if(!number.hasExtension() || number.getExtension().length == 0) {
                return '';
            } else {
                if(numberFormat == PhoneNumberFormat.RFC3966) {
                    return RFC3966_EXTN_PREFIX_ + number.getExtension();
                } else {
                    if(metadata.hasPreferredExtnPrefix()) {
                        return metadata.getPreferredExtnPrefix() + number.getExtension();
                    } else {
                        return DEFAULT_EXTN_PREFIX_ + number.getExtension();
                    }
                }
            }
        }

        /**
         * @param {PhoneMetadata} metadata
         * @param {PhoneNumberType} type
         * @return {PhoneNumberDesc}
         * @private
         */
        private static function getNumberDescByType_(metadata:PhoneMetadata, type:Number):PhoneNumberDesc
        {
            switch(type) {
                case PhoneNumberType.PREMIUM_RATE:
                    return metadata.getPremiumRate();
                case PhoneNumberType.TOLL_FREE:
                    return metadata.getTollFree();
                case PhoneNumberType.MOBILE:
                    return metadata.getMobile();
                case PhoneNumberType.FIXED_LINE:
                case PhoneNumberType.FIXED_LINE_OR_MOBILE:
                    return metadata.getFixedLine();
                case PhoneNumberType.SHARED_COST:
                    return metadata.getSharedCost();
                case PhoneNumberType.VOIP:
                    return metadata.getVoip();
                case PhoneNumberType.PERSONAL_NUMBER:
                    return metadata.getPersonalNumber();
                case PhoneNumberType.PAGER:
                    return metadata.getPager();
                case PhoneNumberType.UAN:
                    return metadata.getUan();
                case PhoneNumberType.VOICEMAIL:
                    return metadata.getVoicemail();
                default:
                    return metadata.getGeneralDesc();
            }
        }

        /**
         * Gets the type of a phone number.
         *
         * @param {PhoneNumber} number the phone number that we want
         *     to know the type.
         * @return {PhoneNumberType} the type of the phone number.
         */
        public function getNumberType(number:PhoneNumber):Number
        {
            var regionCode:String = this.getRegionCodeForNumber(number);
            var metadata:PhoneMetadata = this.getMetadataForRegionOrCallingCode_(number.getCountryCode(), regionCode);
            if(metadata == null) {
                return PhoneNumberType.UNKNOWN;
            }
            var nationalSignificantNumber:String = getNationalSignificantNumber(number);
            return getNumberTypeHelper_(nationalSignificantNumber, metadata);
        }

        /**
         * @param {String} nationalNumber
         * @param {PhoneMetadata} metadata
         * @return {PhoneNumberType}
         * @private
         */
        private static function getNumberTypeHelper_(nationalNumber:String, metadata:PhoneMetadata):Number
        {
            if(!isNumberMatchingDesc_(nationalNumber, metadata.getGeneralDesc())) {
                return PhoneNumberType.UNKNOWN;
            }

            if(isNumberMatchingDesc_(nationalNumber, metadata.getPremiumRate())) {
                return PhoneNumberType.PREMIUM_RATE;
            }
            if(isNumberMatchingDesc_(nationalNumber, metadata.getTollFree())) {
                return PhoneNumberType.TOLL_FREE;
            }
            if(isNumberMatchingDesc_(nationalNumber, metadata.getSharedCost())) {
                return PhoneNumberType.SHARED_COST;
            }
            if(isNumberMatchingDesc_(nationalNumber, metadata.getVoip())) {
                return PhoneNumberType.VOIP;
            }
            if(isNumberMatchingDesc_(nationalNumber, metadata.getPersonalNumber())) {
                return PhoneNumberType.PERSONAL_NUMBER;
            }
            if(isNumberMatchingDesc_(nationalNumber, metadata.getPager())) {
                return PhoneNumberType.PAGER;
            }
            if(isNumberMatchingDesc_(nationalNumber, metadata.getUan())) {
                return PhoneNumberType.UAN;
            }
            if(isNumberMatchingDesc_(nationalNumber, metadata.getVoicemail())) {
                return PhoneNumberType.VOICEMAIL;
            }

            var isFixedLine:Boolean = isNumberMatchingDesc_(nationalNumber, metadata.getFixedLine());
            if(isFixedLine) {
                if(metadata.getSameMobileAndFixedLinePattern()) {
                    return PhoneNumberType.FIXED_LINE_OR_MOBILE;
                } else
                    if(isNumberMatchingDesc_(nationalNumber, metadata.getMobile())) {
                        return PhoneNumberType.FIXED_LINE_OR_MOBILE;
                    }
                return PhoneNumberType.FIXED_LINE;
            }
            // Otherwise, test to see if the number is mobile. Only do this if certain
            // that the patterns for mobile and fixed line aren't the same.
            if(!metadata.getSameMobileAndFixedLinePattern() && isNumberMatchingDesc_(nationalNumber, metadata.getMobile())) {
                return PhoneNumberType.MOBILE;
            }
            return PhoneNumberType.UNKNOWN;
        }

        /**
         * Returns the metadata for the given region code or {@code null} if the region
         * code is invalid or unknown.
         *
         * @param {?String} regionCode
         * @return {PhoneMetadata}
         */
        public function getMetadataForRegion(regionCode:String):PhoneMetadata
        {
            if(regionCode == null) {
                return null;
            }
            regionCode = regionCode.toUpperCase();
            var metadata:PhoneMetadata = this.regionToMetadataMap[regionCode];
            if(metadata == null) {
                var metadataSerialized:Array = Metadata.countryToMetadata[regionCode];
                if (metadataSerialized == null) {
                    return null;
                }
                metadata = new PhoneMetadata(metadataSerialized);
                this.regionToMetadataMap[regionCode] = metadata;
            }
            return metadata;
        }

        /**
         * @param {Number} countryCallingCode
         * @return {PhoneMetadata}
         */
        public function getMetadataForNonGeographicalRegion(countryCallingCode:Number):PhoneMetadata
        {
            return this.getMetadataForRegion(countryCallingCode.toString());
        }

        /**
         * @param {String} nationalNumber
         * @param {PhoneNumberDesc} numberDesc
         * @return {Boolean}
         * @private
         */
        private static function isNumberMatchingDesc_(nationalNumber:String, numberDesc:PhoneNumberDesc):Boolean
        {
            return matchesEntirely_(numberDesc.getPossibleNumberPattern(), nationalNumber) && matchesEntirely_(numberDesc.getNationalNumberPattern(), nationalNumber);
        }

        /**
         * Tests whether a phone number matches a valid pattern. Note this doesn't
         * verify the number is actually in use, which is impossible to tell by just
         * looking at a number itself.
         *
         * @param {PhoneNumber} number the phone number that we want
         *     to validate.
         * @return {Boolean} a boolean that indicates whether the number is of a valid
         *     pattern.
         */
        public function isValidNumber(number:PhoneNumber):Boolean
        {
            var regionCode:String = this.getRegionCodeForNumber(number);
            return this.isValidNumberForRegion(number, regionCode);
        }

        /**
         * Tests whether a phone number is valid for a certain region. Note this doesn't
         * verify the number is actually in use, which is impossible to tell by just
         * looking at a number itself. If the country calling code is not the same as
         * the country calling code for the region, this immediately exits with false.
         * After this, the specific number pattern rules for the region are examined.
         * This is useful for determining for example whether a particular number is
         * valid for Canada, rather than just a valid NANPA number.
         * Warning: In most cases, you want to use {@link #isValidNumber} instead. For
         * example, this method will mark numbers from British Crown dependencies such
         * as the Isle of Man as invalid for the region "GB" (United Kingdom), since it
         * has its own region code, "IM", which may be undesirable.
         *
         * @param {PhoneNumber} number the phone number that we want
         *     to validate.
         * @param {?String} regionCode the region that we want to validate the phone
         *     number for.
         * @return {Boolean} a boolean that indicates whether the number is of a valid
         *     pattern.
         */
        public function isValidNumberForRegion(number:PhoneNumber, regionCode:String):Boolean
        {
            var countryCode:Number = number.getCountryCode();
            var metadata:PhoneMetadata = this.getMetadataForRegionOrCallingCode_(countryCode, regionCode);
            if(metadata == null || (REGION_CODE_FOR_NON_GEO_ENTITY != regionCode && countryCode != this.getCountryCodeForValidRegion_(regionCode))) {
                // Either the region code was invalid, or the country calling code for this
                // number does not match that of the region code.
                return false;
            }
            var nationalSignificantNumber:String = getNationalSignificantNumber(number);

            return getNumberTypeHelper_(nationalSignificantNumber, metadata) != PhoneNumberType.UNKNOWN;
        }

        /**
         * Returns the region where a phone number is from. This could be used for
         * geocoding at the region level.
         *
         * @param {PhoneNumber} number the phone number whose origin
         *     we want to know.
         * @return {?String} the region where the phone number is from, or null
         *     if no region matches this calling code.
         */
        public function getRegionCodeForNumber(number:PhoneNumber):String
        {
            if(number == null) {
                return null;
            }
            var countryCode:Number = number.getCountryCode();
            var regions:Array = Metadata.countryCodeToRegionCodeMap[countryCode];
            if(regions == null) {
                return null;
            }
            if(regions.length == 1) {
                return regions[0];
            } else {
                return this.getRegionCodeForNumberFromRegionList_(number, regions);
            }
        }

        /**
         * @param {PhoneNumber} number
         * @param {Array.<String>} regionCodes
         * @return {?String}
         * @private
         */
        private function getRegionCodeForNumberFromRegionList_(number:PhoneNumber, regionCodes:Array):String
        {
            var nationalNumber:String = getNationalSignificantNumber(number);
            var regionCode:String;
            var regionCodesLength:Number = regionCodes.length;
            for(var i:Number = 0; i < regionCodesLength; i++) {
                regionCode = regionCodes[i];
                // If leadingDigits is present, use this. Otherwise, do full validation.
                // Metadata cannot be null because the region codes come from the country
                // calling code map.
                /** @type {PhoneMetadata} */
                var metadata:PhoneMetadata = this.getMetadataForRegion(regionCode);
                if(metadata.hasLeadingDigits()) {
                    if(nationalNumber.search(metadata.getLeadingDigits()) == 0) {
                        return regionCode;
                    }
                } else
                    if(getNumberTypeHelper_(nationalNumber, metadata) != PhoneNumberType.UNKNOWN) {
                        return regionCode;
                    }
            }
            return null;
        }

        /**
         * Returns the region code that matches the specific country calling code. In
         * the case of no region code being found, ZZ will be returned. In the case of
         * multiple regions, the one designated in the metadata as the 'main' region for
         * this calling code will be returned.
         *
         * @param {Number} countryCallingCode the country calling code.
         * @return {String}
         */
        public static function getRegionCodeForCountryCode(countryCallingCode:Number):String
        {
            var regionCodes:Array = Metadata.countryCodeToRegionCodeMap[countryCallingCode];
            return regionCodes == null ? UNKNOWN_REGION_ : regionCodes[0];
        }

        /**
         * Returns a list with the region codes that match the specific country calling
         * code. For non-geographical country calling codes, the region code 001 is
         * returned. Also, in the case of no region code being found, an empty list is
         * returned.
         *
         * @param {Number} countryCallingCode the country calling code.
         * @return {Array.<String>}
         */
        public function getRegionCodesForCountryCode(countryCallingCode:Number):Array
        {
            var regionCodes:Array = Metadata.countryCodeToRegionCodeMap[countryCallingCode];
            return regionCodes == null ? [] : regionCodes;
        }


        /**
         * Returns the country calling code for a specific region. For example, this
         * would be 1 for the United States, and 64 for New Zealand.
         *
         * @param {?String} regionCode the region that we want to get the country
         *     calling code for.
         * @return {Number} the country calling code for the region denoted by
         *     regionCode.
         */
        public function getCountryCodeForRegion(regionCode:String):Number
        {

            if(!isValidRegionCode_(regionCode)) {
                return 0;
            }
            return this.getCountryCodeForValidRegion_(regionCode);
        }


        /**
         * Returns the country calling code for a specific region. For example, this
         * would be 1 for the United States, and 64 for New Zealand. Assumes the region
         * is already valid.
         *
         * @param {?String} regionCode the region that we want to get the country
         *     calling code for.
         * @return {Number} the country calling code for the region denoted by
         *     regionCode.
         * @throws {String} if the region is invalid
         * @private
         */
        private function getCountryCodeForValidRegion_(regionCode:String):Number
        {
            var metadata:PhoneMetadata = this.getMetadataForRegion(regionCode);
            if(metadata == null) {
                throw 'Invalid region code: ' + regionCode;
            }
            return metadata.getCountryCode();
        }

        /**
         * Returns the national dialling prefix for a specific region. For example, this
         * would be 1 for the United States, and 0 for New Zealand. Set stripNonDigits
         * to true to strip symbols like '~' (which indicates a wait for a dialling
         * tone) from the prefix returned. If no national prefix is present, we return
         * null.
         *
         * <p>Warning: Do not use this method for do-your-own formatting - for some
         * regions, the national dialling prefix is used only for certain types of
         * numbers. Use the library's formatting functions to prefix the national prefix
         * when required.
         *
         * @param {?String} regionCode the region that we want to get the dialling
         *     prefix for.
         * @param {Boolean} stripNonDigits true to strip non-digits from the national
         *     dialling prefix.
         * @return {?String} the dialling prefix for the region denoted by
         *     regionCode.
         */
        public function getNddPrefixForRegion(regionCode:String, stripNonDigits:Boolean):String
        {
            var metadata:PhoneMetadata = this.getMetadataForRegion(regionCode);
            if(metadata == null) {
                return null;
            }
            var nationalPrefix:String = metadata.getNationalPrefix();
            // If no national prefix was found, we return null.
            if(nationalPrefix.length == 0) {
                return null;
            }
            if(stripNonDigits) {
                // Note: if any other non-numeric symbols are ever used in national
                // prefixes, these would have to be removed here as well.
                nationalPrefix = nationalPrefix.replace('~', '');
            }
            return nationalPrefix;
        }


        /**
         * Checks if this is a region under the North American Numbering Plan
         * Administration (NANPA).
         *
         * @param {?String} regionCode the ISO 3166-1 two-letter region code.
         * @return {Boolean} true if regionCode is one of the regions under NANPA.
         */
        public static function isNANPACountry(regionCode:String):Boolean
        {
            return regionCode != null && Metadata.countryCodeToRegionCodeMap[NANPA_COUNTRY_CODE_].hasOwnProperty(regionCode.toUpperCase());
        }

        /**
         * Checks whether countryCode represents the country calling code from a region
         * whose national significant number could contain a leading zero. An example of
         * such a region is Italy. Returns false if no metadata for the country is
         * found.
         *
         * @param {Number} countryCallingCode the country calling code.
         * @return {Boolean}
         */
        public function isLeadingZeroPossible(countryCallingCode:Number):Boolean
        {
            var mainMetadataForCallingCode:PhoneMetadata = this.getMetadataForRegionOrCallingCode_(countryCallingCode, getRegionCodeForCountryCode(countryCallingCode));
            return mainMetadataForCallingCode != null && mainMetadataForCallingCode.getLeadingZeroPossible();
        }


        /**
         * Checks if the number is a valid vanity (alpha) number such as 800 MICROSOFT.
         * A valid vanity number will start with at least 3 digits and will have three
         * or more alpha characters. This does not do region-specific checks - to work
         * out if this number is actually valid for a region, it should be parsed and
         * methods such as {@link #isPossibleNumberWithReason} and
         * {@link #isValidNumber} should be used.
         *
         * @param {String} number the number that needs to be checked.
         * @return {Boolean} true if the number is a valid vanity number.
         */
        public function isAlphaNumber(number:String):Boolean
        {
            if(!isViablePhoneNumber(number)) {
                // Number is too short, or doesn't match the basic phone number pattern.
                return false;
            }
            var strippedNumber:StringBuffer = new StringBuffer(number);
            maybeStripExtension(strippedNumber);
            return matchesEntirely_(VALID_ALPHA_PHONE_PATTERN_, strippedNumber.toString());
        }


        /**
         * Convenience wrapper around {@link #isPossibleNumberWithReason}. Instead of
         * returning the reason for failure, this method returns a boolean value.
         *
         * @param {PhoneNumber} number the number that needs to be
         *     checked.
         * @return {Boolean} true if the number is possible.
         */
        public function isPossibleNumber(number:PhoneNumber):Boolean
        {
            return this.isPossibleNumberWithReason(number) == ValidationResult.IS_POSSIBLE;
        }


        /**
         * Helper method to check a number against a particular pattern and determine
         * whether it matches, or is too short or too long. Currently, if a number
         * pattern suggests that numbers of length 7 and 10 are possible, and a number
         * in between these possible lengths is entered, such as of length 8, this will
         * return TOO_LONG.
         *
         * @param {String} numberPattern
         * @param {String} number
         * @return {ValidationResult}
         * @private
         */
        private static function testNumberLengthAgainstPattern_(numberPattern:String, number:String):Number
        {
            if(matchesEntirely_(new RegExp(numberPattern), number)) {
                return ValidationResult.IS_POSSIBLE;
            }
            if(number.search(numberPattern) == 0) {
                return ValidationResult.TOO_LONG;
            } else {
                return ValidationResult.TOO_SHORT;
            }
        }


        /**
         * Helper method to check whether a number is too short to be a regular length
         * phone number in a region.
         *
         * @param {PhoneMetadata} regionMetadata
         * @param {String} number
         * @return {Boolean}
         * @private
         */
        private static function isShorterThanPossibleNormalNumber_(regionMetadata:PhoneMetadata, number:String):Boolean
        {
            var possibleNumberPattern:String = regionMetadata.getGeneralDesc().getPossibleNumberPattern();
            return testNumberLengthAgainstPattern_(possibleNumberPattern, number) == ValidationResult.TOO_SHORT;
        }


        /**
         * Check whether a phone number is a possible number. It provides a more lenient
         * check than {@link #isValidNumber} in the following sense:
         * <ol>
         * <li>It only checks the length of phone numbers. In particular, it doesn't
         * check starting digits of the number.
         * <li>It doesn't attempt to figure out the type of the number, but uses general
         * rules which applies to all types of phone numbers in a region. Therefore, it
         * is much faster than isValidNumber.
         * <li>For fixed line numbers, many regions have the concept of area code, which
         * together with subscriber number constitute the national significant number.
         * It is sometimes okay to dial the subscriber number only when dialing in the
         * same area. This function will return true if the subscriber-number-only
         * version is passed in. On the other hand, because isValidNumber validates
         * using information on both starting digits (for fixed line numbers, that would
         * most likely be area codes) and length (obviously includes the length of area
         * codes for fixed line numbers), it will return false for the
         * subscriber-number-only version.
         * </ol>
         *
         * @param {PhoneNumber} number the number that needs to be
         *     checked.
         * @return {ValidationResult} a
         *     ValidationResult object which indicates whether the number is possible.
         */
        public function isPossibleNumberWithReason(number:PhoneNumber):Number
        {
            var nationalNumber:String = getNationalSignificantNumber(number);
            var countryCode:Number = number.getCountryCode();
            // Note: For Russian Fed and NANPA numbers, we just use the rules from the
            // default region (US or Russia) since the getRegionCodeForNumber will not
            // work if the number is possible but not valid. This would need to be
            // revisited if the possible number pattern ever differed between various
            // regions within those plans.
            if(!hasValidCountryCallingCode_(countryCode)) {
                return ValidationResult.INVALID_COUNTRY_CODE;
            }
            var regionCode:String = getRegionCodeForCountryCode(countryCode);
            // Metadata cannot be null because the country calling code is valid.
            var metadata:PhoneMetadata = this.getMetadataForRegionOrCallingCode_(countryCode, regionCode);
            var possibleNumberPattern:String = metadata.getGeneralDesc().getPossibleNumberPattern();
            return testNumberLengthAgainstPattern_(possibleNumberPattern, nationalNumber);
        }


        /**
         * Check whether a phone number is a possible number given a number in the form
         * of a string, and the region where the number could be dialed from. It
         * provides a more lenient check than {@link #isValidNumber}. See
         * {@link #isPossibleNumber} for details.
         *
         * <p>This method first parses the number, then invokes
         * {@link #isPossibleNumber} with the resultant PhoneNumber object.
         *
         * @param {String} number the number that needs to be checked, in the form of a
         *     string.
         * @param {String} regionDialingFrom the region that we are expecting the number
         *     to be dialed from.
         *     Note this is different from the region where the number belongs.
         *     For example, the number +1 650 253 0000 is a number that belongs to US.
         *     When written in this form, it can be dialed from any region. When it is
         *     written as 00 1 650 253 0000, it can be dialed from any region which uses
         *     an international dialling prefix of 00. When it is written as
         *     650 253 0000, it can only be dialed from within the US, and when written
         *     as 253 0000, it can only be dialed from within a smaller area in the US
         *     (Mountain View, CA, to be more specific).
         * @return {Boolean} true if the number is possible.
         */
        public function isPossibleNumberString(number:String, regionDialingFrom:String):Boolean
        {
            try {
                return this.isPossibleNumber(this.parse(number, regionDialingFrom));
            } catch(e:Exception) {
                return false;
            }
        }


        /**
         * Attempts to extract a valid number from a phone number that is too long to be
         * valid, and resets the PhoneNumber object passed in to that valid version. If
         * no valid number could be extracted, the PhoneNumber object passed in will not
         * be modified.
         * @param {PhoneNumber} number a PhoneNumber object which
         *     contains a number that is too long to be valid.
         * @return {Boolean} true if a valid phone number can be successfully extracted.
         */
        public function truncateTooLongNumber(number:PhoneNumber):Boolean
        {

            if(this.isValidNumber(number)) {
                return true;
            }
            var numberCopy:PhoneNumber = ObjectUtils.clone(number);
            var nationalNumber:Number = number.getNationalNumber();
            do {
                nationalNumber = Math.floor(nationalNumber / 10);
                numberCopy.setNationalNumber(nationalNumber);
                if(nationalNumber == 0 || this.isPossibleNumberWithReason(numberCopy) == ValidationResult.TOO_SHORT) {
                    return false;
                }
            } while(!this.isValidNumber(numberCopy));
            number.setNationalNumber(nationalNumber);
            return true;
        }


        /**
         * Extracts country calling code from fullNumber, returns it and places the
         * remaining number in nationalNumber. It assumes that the leading plus sign or
         * IDD has already been removed. Returns 0 if fullNumber doesn't start with a
         * valid country calling code, and leaves nationalNumber unmodified.
         *
         * @param {!StringBuffer} fullNumber
         * @param {!StringBuffer} nationalNumber
         * @return {Number}
         */
        public static function extractCountryCode(fullNumber:StringBuffer, nationalNumber:StringBuffer):Number
        {
            var fullNumberStr:String = fullNumber.toString();
            if((fullNumberStr.length == 0) || (fullNumberStr.charAt(0) == '0')) {
                // Country codes do not begin with a '0'.
                return 0;
            }
            var potentialCountryCode:Number;
            var numberLength:Number = fullNumberStr.length;
            for(var i:Number = 1; i <= MAX_LENGTH_COUNTRY_CODE_ && i <= numberLength; ++i) {
                potentialCountryCode = Number(fullNumberStr.substring(0, i));
                if(potentialCountryCode in Metadata.countryCodeToRegionCodeMap) {
                    nationalNumber.append(fullNumberStr.substring(i));
                    return potentialCountryCode;
                }
            }
            return 0;
        }


        /**
         * Tries to extract a country calling code from a number. This method will
         * return zero if no country calling code is considered to be present. Country
         * calling codes are extracted in the following ways:
         * <ul>
         * <li>by stripping the international dialing prefix of the region the person is
         * dialing from, if this is present in the number, and looking at the next
         * digits
         * <li>by stripping the '+' sign if present and then looking at the next digits
         * <li>by comparing the start of the number and the country calling code of the
         * default region. If the number is not considered possible for the numbering
         * plan of the default region initially, but starts with the country calling
         * code of this region, validation will be reattempted after stripping this
         * country calling code. If this number is considered a possible number, then
         * the first digits will be considered the country calling code and removed as
         * such.
         * </ul>
         *
         * It will throw a Error if the number starts with a '+' but
         * the country calling code supplied after this does not match that of any known
         * region.
         *
         * @param {String} number non-normalized telephone number that we wish to
         *     extract a country calling code from - may begin with '+'.
         * @param {PhoneMetadata} defaultRegionMetadata metadata
         *     about the region this number may be from.
         * @param {!StringBuffer} nationalNumber a string buffer to store
         *     the national significant number in, in the case that a country calling
         *     code was extracted. The number is appended to any existing contents. If
         *     no country calling code was extracted, this will be left unchanged.
         * @param {Boolean} keepRawInput true if the country_code_source and
         *     preferred_carrier_code fields of phoneNumber should be populated.
         * @param {PhoneNumber} phoneNumber the PhoneNumber object
         *     where the country_code and country_code_source need to be populated.
         *     Note the country_code is always populated, whereas country_code_source is
         *     only populated when keepCountryCodeSource is true.
         * @return {Number} the country calling code extracted or 0 if none could be
         *     extracted.
         * @throws {Exception}
         */
        public function maybeExtractCountryCode(number:String, defaultRegionMetadata:PhoneMetadata, nationalNumber:StringBuffer, keepRawInput:Boolean, phoneNumber:PhoneNumber):Number
        {
            if(number.length == 0) {
                return 0;
            }
            var fullNumber:StringBuffer = new StringBuffer(number);
            // Set the default prefix to be something that will never match.
            var possibleCountryIddPrefix:String;
            if(defaultRegionMetadata != null) {
                possibleCountryIddPrefix = defaultRegionMetadata.getInternationalPrefix();
            }
            if(possibleCountryIddPrefix == null) {
                possibleCountryIddPrefix = 'NonMatch';
            }

            /** @type {PhoneNumber.CountryCodeSource} */
            var countryCodeSource:Number = maybeStripInternationalPrefixAndNormalize(fullNumber, possibleCountryIddPrefix);
            if(keepRawInput) {
                phoneNumber.setCountryCodeSource(countryCodeSource);
            }
            if(countryCodeSource != PhoneNumber.CountryCodeSource.FROM_DEFAULT_COUNTRY) {
                if(fullNumber.getLength() <= MIN_LENGTH_FOR_NSN_) {
                    throw new Exception(Exception.TOO_SHORT_AFTER_IDD);
                }
                var potentialCountryCode:Number = extractCountryCode(fullNumber, nationalNumber);
                if(potentialCountryCode != 0) {
                    phoneNumber.setCountryCode(potentialCountryCode);
                    return potentialCountryCode;
                }

                // If this fails, they must be using a strange country calling code that we
                // don't recognize, or that doesn't exist.
                throw new Exception(Exception.INVALID_COUNTRY_CODE);
            } else
                if(defaultRegionMetadata != null) {
                    // Check to see if the number starts with the country calling code for the
                    // default region. If so, we remove the country calling code, and do some
                    // checks on the validity of the number before and after.
                    var defaultCountryCode:Number = defaultRegionMetadata.getCountryCode();
                    var defaultCountryCodeString:String = defaultCountryCode.toString();
                    var normalizedNumber:String = fullNumber.toString();
                    if(StringUtils.startsWith(normalizedNumber, defaultCountryCodeString)) {
                        var potentialNationalNumber:StringBuffer = new StringBuffer(normalizedNumber.substring(defaultCountryCodeString.length));
                        var generalDesc:PhoneNumberDesc = defaultRegionMetadata.getGeneralDesc();
                        var validNumberPattern:RegExp = new RegExp(generalDesc.getNationalNumberPattern());
                        // Passing null since we don't need the carrier code.
                        maybeStripNationalPrefixAndCarrierCode(potentialNationalNumber, defaultRegionMetadata, null);
                        var potentialNationalNumberStr:String = potentialNationalNumber.toString();
                        var possibleNumberPattern:String = generalDesc.getPossibleNumberPattern();
                        // If the number was not valid before but is valid now, or if it was too
                        // long before, we consider the number with the country calling code
                        // stripped to be a better result and keep that instead.
                        if((!matchesEntirely_(validNumberPattern, fullNumber.toString()) && matchesEntirely_(validNumberPattern, potentialNationalNumberStr)) || testNumberLengthAgainstPattern_(possibleNumberPattern, fullNumber.toString()) == ValidationResult.TOO_LONG) {
                            nationalNumber.append(potentialNationalNumberStr);
                            if(keepRawInput) {
                                phoneNumber.setCountryCodeSource(PhoneNumber.CountryCodeSource.FROM_NUMBER_WITHOUT_PLUS_SIGN);
                            }
                            phoneNumber.setCountryCode(defaultCountryCode);
                            return defaultCountryCode;
                        }
                    }
                }
            // No country calling code present.
            phoneNumber.setCountryCode(0);
            return 0;
        }


        /**
         * Strips the IDD from the start of the number if present. Helper function used
         * by maybeStripInternationalPrefixAndNormalize.
         *
         * @param {!RegExp} iddPattern the regular expression for the international
         *     prefix.
         * @param {!StringBuffer} number the phone number that we wish to
         *     strip any international dialing prefix from.
         * @return {Boolean} true if an international prefix was present.
         * @private
         */
        private static function parsePrefixAsIdd_(iddPattern:RegExp, number:StringBuffer):Boolean
        {
            var numberStr:String = number.toString();
            if(numberStr.search(iddPattern) == 0) {
                var matchEnd:Number = numberStr.match(iddPattern)[0].length;
                var matchedGroups:Array = numberStr.substring(matchEnd).match(CAPTURING_DIGIT_PATTERN);
                if(matchedGroups && matchedGroups[1] != null && matchedGroups[1].length > 0) {
                    var normalizedGroup:String = normalizeDigitsOnly(matchedGroups[1]);
                    if(normalizedGroup == '0') {
                        return false;
                    }
                }
                number.clear();
                number.append(numberStr.substring(matchEnd));
                return true;
            }
            return false;
        }


        /**
         * Strips any international prefix (such as +, 00, 011) present in the number
         * provided, normalizes the resulting number, and indicates if an international
         * prefix was present.
         *
         * @param {!StringBuffer} number the non-normalized telephone number
         *     that we wish to strip any international dialing prefix from.
         * @param {String} possibleIddPrefix the international direct dialing prefix
         *     from the region we think this number may be dialed in.
         * @return {PhoneNumber.CountryCodeSource} the corresponding
         *     CountryCodeSource if an international dialing prefix could be removed
         *     from the number, otherwise CountryCodeSource.FROM_DEFAULT_COUNTRY if
         *     the number did not seem to be in international format.
         */
        public static function maybeStripInternationalPrefixAndNormalize(number:StringBuffer, possibleIddPrefix:String):Number
        {
            var numberStr:String = number.toString();
            if(numberStr.length == 0) {
                return PhoneNumber.CountryCodeSource.FROM_DEFAULT_COUNTRY;
            }
            // Check to see if the number begins with one or more plus signs.
            if(LEADING_PLUS_CHARS_PATTERN_
                    .test(numberStr)) {
                numberStr = numberStr.replace(LEADING_PLUS_CHARS_PATTERN_, '');
                // Can now normalize the rest of the number since we've consumed the '+'
                // sign at the start.
                number.clear();
                number.append(normalize(numberStr));
                return PhoneNumber.CountryCodeSource.FROM_NUMBER_WITH_PLUS_SIGN;
            }
            // Attempt to parse the first digits as an international prefix.
            var iddPattern:RegExp = new RegExp(possibleIddPrefix);
            normalizeSB_(number);
            return parsePrefixAsIdd_(iddPattern, number) ? PhoneNumber.CountryCodeSource.FROM_NUMBER_WITH_IDD : PhoneNumber.CountryCodeSource.FROM_DEFAULT_COUNTRY;
        }


        /**
         * Strips any national prefix (such as 0, 1) present in the number provided.
         *
         * @param {!StringBuffer} number the normalized telephone number
         *     that we wish to strip any national dialing prefix from.
         * @param {PhoneMetadata} metadata the metadata for the
         *     region that we think this number is from.
         * @param {StringBuffer} carrierCode a place to insert the carrier
         *     code if one is extracted.
         * @return {Boolean} true if a national prefix or carrier code (or both) could
         *     be extracted.
         */
        public static function maybeStripNationalPrefixAndCarrierCode(number:StringBuffer, metadata:PhoneMetadata, carrierCode:StringBuffer):Boolean
        {
            var numberStr:String = number.toString();
            var numberLength:Number = numberStr.length;
            var possibleNationalPrefix:String = metadata.getNationalPrefixForParsing();
            if(numberLength == 0 || possibleNationalPrefix == null || possibleNationalPrefix.length == 0) {
                // Early return for numbers of zero length.
                return false;
            }
            // Attempt to parse the first digits as a national prefix.
            var prefixPattern:RegExp = new RegExp('^(?:' + possibleNationalPrefix + ')');
            var prefixMatcher:Array = prefixPattern.exec(numberStr);
            if(prefixMatcher) {
                var nationalNumberRule:RegExp = new RegExp(metadata.getGeneralDesc().getNationalNumberPattern());
                // Check if the original number is viable.
                var isViableOriginalNumber:Boolean = matchesEntirely_(nationalNumberRule, numberStr);
                // prefixMatcher[numOfGroups] == null implies nothing was captured by the
                // capturing groups in possibleNationalPrefix; therefore, no transformation
                // is necessary, and we just remove the national prefix.
                var numOfGroups:Number = prefixMatcher.length - 1;
                var transformRule:String = metadata.getNationalPrefixTransformRule();
                var noTransform:Boolean = transformRule == null || transformRule.length == 0 || prefixMatcher[numOfGroups] == null || prefixMatcher[numOfGroups].length == 0;
                if(noTransform) {
                    // If the original number was viable, and the resultant number is not,
                    // we return.
                    if(isViableOriginalNumber && !matchesEntirely_(nationalNumberRule, numberStr.substring(prefixMatcher[0].length))) {
                        return false;
                    }
                    if(carrierCode != null && numOfGroups > 0 && prefixMatcher[numOfGroups] != null) {
                        carrierCode.append(prefixMatcher[1]);
                    }
                    number.reset(numberStr.substring(prefixMatcher[0].length));
                    return true;
                } else {
                    // Check that the resultant number is still viable. If not, return. Check
                    // this by copying the string buffer and making the transformation on the
                    // copy first.
                    var transformedNumber:String;
                    transformedNumber = numberStr.replace(prefixPattern, transformRule);
                    if(isViableOriginalNumber && !matchesEntirely_(nationalNumberRule, transformedNumber)) {
                        return false;
                    }
                    if(carrierCode != null && numOfGroups > 0) {
                        carrierCode.append(prefixMatcher[1]);
                    }
                    number.reset(transformedNumber);
                    return true;
                }
            }
            return false;
        }


        /**
         * Strips any extension (as in, the part of the number dialled after the call is
         * connected, usually indicated with extn, ext, x or similar) from the end of
         * the number, and returns it.
         *
         * @param {!StringBuffer} number the non-normalized telephone number
         *     that we wish to strip the extension from.
         * @return {String} the phone extension.
         */
        public static function maybeStripExtension(number:StringBuffer):String
        {
            var numberStr:String = number.toString();
            var mStart:Number = numberStr.search(EXTN_PATTERN_);
            // If we find a potential extension, and the number preceding this is a viable
            // number, we assume it is an extension.
            if(mStart >= 0 && isViablePhoneNumber(numberStr.substring(0, mStart))) {
                // The numbers are captured into groups in the regular expression.
                var matchedGroups:Array = numberStr.match(EXTN_PATTERN_);
                var matchedGroupsLength:Number = matchedGroups.length;
                for(var i:Number = 1; i < matchedGroupsLength; ++i) {
                    if(matchedGroups[i] != null && matchedGroups[i].length > 0) {
                        // We go through the capturing groups until we find one that captured
                        // some digits. If none did, then we will return the empty string.
                        number.clear();
                        number.append(numberStr.substring(0, mStart));
                        return matchedGroups[i];
                    }
                }
            }
            return '';
        }


        /**
         * Checks to see that the region code used is valid, or if it is not valid, that
         * the number to parse starts with a + symbol so that we can attempt to infer
         * the region from the number.
         * @param {String} numberToParse number that we are attempting to parse.
         * @param {?String} defaultRegion region that we are expecting the number to be
         *     from.
         * @return {Boolean} false if it cannot use the region provided and the region
         *     cannot be inferred.
         * @private
         */
        private static function checkRegionForParsing_(numberToParse:String, defaultRegion:String):Boolean
        {
            // If the number is null or empty, we can't infer the region.
            return isValidRegionCode_(defaultRegion) || (numberToParse != null && numberToParse.length > 0 && LEADING_PLUS_CHARS_PATTERN_.test(numberToParse));
        }


        /**
         * Parses a string and returns it as a phone number in proto buffer format. The
         * method is quite lenient and looks for a number in the input text (raw input)
         * and does not check whether the string is definitely only a phone number. To
         * do this, it ignores punctuation and white-space, as well as any text before
         * the number (e.g. a leading “Tel: ”) and trims the non-number bits.  It will
         * accept a number in any format (E164, national, international etc), assuming
         * it can be interpreted with the defaultRegion supplied. It also attempts to
         * convert any alpha characters into digits if it thinks this is a vanity number
         * of the type "1800 MICROSOFT".
         *
         * This method will throw a {@link Exception} if the number is not
         * considered to be a possible number. Note that validation of whether the
         * number is actually a valid number for a particular region is not performed.
         * This can be done separately with {@link #isValidNumber}.
         *
         * @param {?String} numberToParse number that we are attempting to parse. This
         *     can contain formatting such as +, ( and -, as well as a phone number
         *     extension. It can also be provided in RFC3966 format.
         * @param {?String} defaultRegion region that we are expecting the number to be
         *     from. This is only used if the number being parsed is not written in
         *     international format. The country_code for the number in this case would
         *     be stored as that of the default region supplied. If the number is
         *     guaranteed to start with a '+' followed by the country calling code, then
         *     'ZZ' or null can be supplied.
         * @return {PhoneNumber} a phone number proto buffer filled
         *     with the parsed number.
         * @throws {Exception} if the string is not considered to be a
         *     viable phone number (e.g. too few or too many digits) or if no default
         *     region was supplied and the number is not in international format (does
         *     not start with +).
         */
        public function parse(numberToParse:String, defaultRegion:String):PhoneNumber
        {
            return this.parseHelper_(numberToParse, defaultRegion, false, true);
        }


        /**
         * Parses a string and returns it in proto buffer format. This method differs
         * from {@link #parse} in that it always populates the raw_input field of the
         * protocol buffer with numberToParse as well as the country_code_source field.
         *
         * @param {String} numberToParse number that we are attempting to parse. This
         *     can contain formatting such as +, ( and -, as well as a phone number
         *     extension.
         * @param {?String} defaultRegion region that we are expecting the number to be
         *     from. This is only used if the number being parsed is not written in
         *     international format. The country calling code for the number in this
         *     case would be stored as that of the default region supplied.
         * @return {PhoneNumber} a phone number proto buffer filled
         *     with the parsed number.
         * @throws {Exception} if the string is not considered to be a
         *     viable phone number or if no default region was supplied.
         */
        public function parseAndKeepRawInput(numberToParse:String, defaultRegion:String):PhoneNumber
        {
            if(!isValidRegionCode_(defaultRegion)) {
                if(numberToParse.length > 0 && numberToParse.charAt(0) != PLUS_SIGN) {
                    throw Exception.INVALID_COUNTRY_CODE;
                }
            }
            return this.parseHelper_(numberToParse, defaultRegion, true, true);
        }


        /**
         * A helper function to set the values related to leading zeros in a
         * PhoneNumber.
         *
         * @param {String} nationalNumber the number we are parsing.
         * @param {PhoneNumber} phoneNumber a phone number proto
         *     buffer to fill in.
         * @private
         */
        private static function setItalianLeadingZerosForPhoneNumber_(nationalNumber:String, phoneNumber:PhoneNumber):void
        {
            if(nationalNumber.length > 1 && nationalNumber.charAt(0) == '0') {
                phoneNumber.setItalianLeadingZero(true);
                var numberOfLeadingZeros:Number = 1;
                // Note that if the national number is all "0"s, the last "0" is not counted
                // as a leading zero.
                while(numberOfLeadingZeros < nationalNumber.length - 1 && nationalNumber.charAt(numberOfLeadingZeros) == '0') {
                    numberOfLeadingZeros++;
                }
                if(numberOfLeadingZeros != 1) {
                    phoneNumber.setNumberOfLeadingZeros(numberOfLeadingZeros);
                }
            }
        }


        /**
         * Parses a string and returns it in proto buffer format. This method is the
         * same as the public {@link #parse} method, with the exception that it allows
         * the default region to be null, for use by {@link #isNumberMatch}.
         *
         * @param {?String} numberToParse number that we are attempting to parse. This
         *     can contain formatting such as +, ( and -, as well as a phone number
         *     extension.
         * @param {?String} defaultRegion region that we are expecting the number to be
         *     from. This is only used if the number being parsed is not written in
         *     international format. The country calling code for the number in this
         *     case would be stored as that of the default region supplied.
         * @param {Boolean} keepRawInput whether to populate the raw_input field of the
         *     phoneNumber with numberToParse.
         * @param {Boolean} checkRegion should be set to false if it is permitted for
         *     the default coregion to be null or unknown ('ZZ').
         * @return {PhoneNumber} a phone number proto buffer filled
         *     with the parsed number.
         * @throws {Exception}
         * @private
         */
        private function parseHelper_(numberToParse:String, defaultRegion:String, keepRawInput:Boolean, checkRegion:Boolean):PhoneNumber
        {
            if(numberToParse == null) {
                throw new Exception(Exception.NOT_A_NUMBER);
            } else if(numberToParse.length > MAX_INPUT_STRING_LENGTH_) {
                throw new Exception(Exception.TOO_LONG);
            }

            var nationalNumber:StringBuffer = new StringBuffer();
            buildNationalNumberForParsing_(numberToParse, nationalNumber);

            if(!isViablePhoneNumber(nationalNumber.toString())) {
                throw Exception.NOT_A_NUMBER;
            }

            // Check the region supplied is valid, or that the extracted number starts
            // with some sort of + sign so the number's region can be determined.
            if(checkRegion && !checkRegionForParsing_(nationalNumber.toString(), defaultRegion)) {
                throw Exception.INVALID_COUNTRY_CODE;
            }

            var phoneNumber:PhoneNumber = new PhoneNumber();
            if(keepRawInput) {
                phoneNumber.setRawInput(numberToParse);
            }
            // Attempt to parse extension first, since it doesn't require region-specific
            // data and we want to have the non-normalised number here.
            var extension:String = maybeStripExtension(nationalNumber);
            if(extension.length > 0) {
                phoneNumber.setExtension(extension);
            }

            var regionMetadata:PhoneMetadata = this.getMetadataForRegion(defaultRegion);
            // Check to see if the number is given in international format so we know
            // whether this number is from the default region or not.
            var normalizedNationalNumber:StringBuffer = new StringBuffer();
            var countryCode:Number = 0;
            var nationalNumberStr:String = nationalNumber.toString();
            try {
                countryCode = this.maybeExtractCountryCode(nationalNumberStr, regionMetadata, normalizedNationalNumber, keepRawInput, phoneNumber);
            } catch(e:Exception) {
                if(e.message == Exception.INVALID_COUNTRY_CODE && LEADING_PLUS_CHARS_PATTERN_
                        .test(nationalNumberStr)) {
                    // Strip the plus-char, and try again.
                    nationalNumberStr = nationalNumberStr.replace(LEADING_PLUS_CHARS_PATTERN_, '');
                    countryCode = this.maybeExtractCountryCode(nationalNumberStr, regionMetadata, normalizedNationalNumber, keepRawInput, phoneNumber);
                    if(countryCode == 0) {
                        throw e;
                    }
                } else {
                    throw e;
                }
            }
            if(countryCode != 0) {
                var phoneNumberRegion:String = getRegionCodeForCountryCode(countryCode);
                if(phoneNumberRegion != defaultRegion) {
                    // Metadata cannot be null because the country calling code is valid.
                    regionMetadata = this.getMetadataForRegionOrCallingCode_(countryCode, phoneNumberRegion);
                }
            } else {
                // If no extracted country calling code, use the region supplied instead.
                // The national number is just the normalized version of the number we were
                // given to parse.
                normalizeSB_(nationalNumber);
                normalizedNationalNumber.append(nationalNumber.toString());
                if(defaultRegion != null) {
                    countryCode = regionMetadata.getCountryCode();
                    phoneNumber.setCountryCode(countryCode);
                } else
                    if(keepRawInput) {
                        phoneNumber.clearCountryCodeSource();
                    }
            }
            if(normalizedNationalNumber.getLength() < MIN_LENGTH_FOR_NSN_) {
                throw Exception.TOO_SHORT_NSN;
            }

            if(regionMetadata != null) {
                var carrierCode:StringBuffer = new StringBuffer();
                var potentialNationalNumber:StringBuffer = new StringBuffer(normalizedNationalNumber.toString());
                maybeStripNationalPrefixAndCarrierCode(potentialNationalNumber, regionMetadata, carrierCode);
                if(!isShorterThanPossibleNormalNumber_(regionMetadata, potentialNationalNumber.toString())) {
                    normalizedNationalNumber = potentialNationalNumber;
                    if(keepRawInput) {
                        phoneNumber.setPreferredDomesticCarrierCode(carrierCode.toString());
                    }
                }
            }
            var normalizedNationalNumberStr:String = normalizedNationalNumber.toString();
            var lengthOfNationalNumber:Number = normalizedNationalNumberStr.length;
            if(lengthOfNationalNumber < MIN_LENGTH_FOR_NSN_) {
                throw Exception.TOO_SHORT_NSN;
            }
            if(lengthOfNationalNumber > MAX_LENGTH_FOR_NSN_) {
                throw Exception.TOO_LONG;
            }
            setItalianLeadingZerosForPhoneNumber_(normalizedNationalNumberStr, phoneNumber);
            phoneNumber.setNationalNumber(Number(normalizedNationalNumberStr));
            return phoneNumber;
        }


        /**
         * Converts numberToParse to a form that we can parse and write it to
         * nationalNumber if it is written in RFC3966; otherwise extract a possible
         * number out of it and write to nationalNumber.
         *
         * @param {?String} numberToParse number that we are attempting to parse. This
         *     can contain formatting such as +, ( and -, as well as a phone number
         *     extension.
         * @param {!StringBuffer} nationalNumber a string buffer for storing
         *     the national significant number.
         * @private
         */
        private static function buildNationalNumberForParsing_(numberToParse:String, nationalNumber:StringBuffer):void
        {
            var indexOfPhoneContext:Number = numberToParse.indexOf(RFC3966_PHONE_CONTEXT_);
            if(indexOfPhoneContext > 0) {
                var phoneContextStart:Number = indexOfPhoneContext + RFC3966_PHONE_CONTEXT_.length;
                // If the phone context contains a phone number prefix, we need to capture
                // it, whereas domains will be ignored.
                if(numberToParse.charAt(phoneContextStart) == PLUS_SIGN) {
                    // Additional parameters might follow the phone context. If so, we will
                    // remove them here because the parameters after phone context are not
                    // important for parsing the phone number.
                    var phoneContextEnd:Number = numberToParse.indexOf(';', phoneContextStart);
                    if(phoneContextEnd > 0) {
                        nationalNumber.append(numberToParse.substring(phoneContextStart, phoneContextEnd));
                    } else {
                        nationalNumber.append(numberToParse.substring(phoneContextStart));
                    }
                }

                // Now append everything between the "tel:" prefix and the phone-context.
                // This should include the national number, an optional extension or
                // isdn-subaddress component. Note we also handle the case when "tel:" is
                // missing, as we have seen in some of the phone number inputs.
                // In that case, we append everything from the beginning.
                var indexOfRfc3966Prefix:Number = numberToParse.indexOf(RFC3966_PREFIX_);
                var indexOfNationalNumber:Number = (indexOfRfc3966Prefix >= 0) ? indexOfRfc3966Prefix + RFC3966_PREFIX_.length : 0;
                nationalNumber.append(numberToParse.substring(indexOfNationalNumber, indexOfPhoneContext));
            } else {
                // Extract a possible number from the string passed in (this strips leading
                // characters that could not be the start of a phone number.)
                nationalNumber.append(extractPossibleNumber(numberToParse));
            }

            // Delete the isdn-subaddress and everything after it if it is present.
            // Note extension won't appear at the same time with isdn-subaddress
            // according to paragraph 5.3 of the RFC3966 spec,
            var nationalNumberStr:String = nationalNumber.toString();
            var indexOfIsdn:Number = nationalNumberStr.indexOf(RFC3966_ISDN_SUBADDRESS_);
            if(indexOfIsdn > 0) {
                nationalNumber.clear();
                nationalNumber.append(nationalNumberStr.substring(0, indexOfIsdn));
            }
            // If both phone context and isdn-subaddress are absent but other
            // parameters are present, the parameters are left in nationalNumber. This
            // is because we are concerned about deleting content from a potential
            // number string when there is no strong evidence that the number is
            // actually written in RFC3966.
        }


        /**
         * Takes two phone numbers and compares them for equality.
         *
         * <p>Returns EXACT_MATCH if the country_code, NSN, presence of a leading zero
         * for Italian numbers and any extension present are the same. Returns NSN_MATCH
         * if either or both has no region specified, and the NSNs and extensions are
         * the same. Returns SHORT_NSN_MATCH if either or both has no region specified,
         * or the region specified is the same, and one NSN could be a shorter version
         * of the other number. This includes the case where one has an extension
         * specified, and the other does not. Returns NO_MATCH otherwise. For example,
         * the numbers +1 345 657 1234 and 657 1234 are a SHORT_NSN_MATCH. The numbers
         * +1 345 657 1234 and 345 657 are a NO_MATCH.
         *
         * @param {PhoneNumber|String} firstNumberIn first number to
         *     compare. If it is a string it can contain formatting, and can have
         *     country calling code specified with + at the start.
         * @param {PhoneNumber|String} secondNumberIn second number to
         *     compare. If it is a string it can contain formatting, and can have
         *     country calling code specified with + at the start.
         * @return {MatchType} NOT_A_NUMBER, NO_MATCH,
         *     SHORT_NSN_MATCH, NSN_MATCH or EXACT_MATCH depending on the level of
         *     equality of the two numbers, described in the method definition.
         */
        public function isNumberMatch(firstNumberIn:*, secondNumberIn:*):Number
        {

            // If the input arguements are strings parse them to a proto buffer format.
            // Else make copies of the phone numbers so that the numbers passed in are not
            // edited.
            var firstNumber:PhoneNumber;
            var secondNumber:PhoneNumber;
            if(typeof firstNumberIn == 'string') {
                // First see if the first number has an implicit country calling code, by
                // attempting to parse it.
                try {
                    firstNumber = this.parse(firstNumberIn, UNKNOWN_REGION_);
                } catch(e:Exception) {
                    if(e.message != Exception.INVALID_COUNTRY_CODE) {
                        return MatchType.NOT_A_NUMBER;
                    }
                    // The first number has no country calling code. EXACT_MATCH is no longer
                    // possible. We parse it as if the region was the same as that for the
                    // second number, and if EXACT_MATCH is returned, we replace this with
                    // NSN_MATCH.
                    if(typeof secondNumberIn != 'string') {
                        var secondNumberRegion:String = getRegionCodeForCountryCode(secondNumberIn.getCountryCode());
                        if(secondNumberRegion != UNKNOWN_REGION_) {
                            try {
                                firstNumber = this.parse(firstNumberIn, secondNumberRegion);
                            } catch(e2:Exception) {
                                return MatchType.NOT_A_NUMBER;
                            }
                            var match:Number = this.isNumberMatch(firstNumber, secondNumberIn);
                            if(match == MatchType.EXACT_MATCH) {
                                return MatchType.NSN_MATCH;
                            }
                            return match;
                        }
                    }
                    // If the second number is a string or doesn't have a valid country
                    // calling code, we parse the first number without country calling code.
                    try {
                        firstNumber = this.parseHelper_(firstNumberIn, null, false, false);
                    } catch(e2:Exception) {
                        return MatchType.NOT_A_NUMBER;
                    }
                }
            } else {
                firstNumber = ObjectUtils.clone(firstNumberIn);
            }
            if(typeof secondNumberIn == 'string') {
                try {
                    secondNumber = this.parse(secondNumberIn, UNKNOWN_REGION_);
                    return this.isNumberMatch(firstNumberIn, secondNumber);
                } catch(e:Exception) {
                    if(e.message != Exception.INVALID_COUNTRY_CODE) {
                        return MatchType.NOT_A_NUMBER;
                    }
                    return this.isNumberMatch(secondNumberIn, firstNumber);
                }
            } else {
                secondNumber = ObjectUtils.clone(secondNumberIn);
            }
            // First clear raw_input, country_code_source and
            // preferred_domestic_carrier_code fields and any empty-string extensions so
            // that we can use the proto-buffer equality method.
            firstNumber.clearRawInput();
            firstNumber.clearCountryCodeSource();
            firstNumber.clearPreferredDomesticCarrierCode();
            secondNumber.clearRawInput();
            secondNumber.clearCountryCodeSource();
            secondNumber.clearPreferredDomesticCarrierCode();
            if(firstNumber.hasExtension() && firstNumber.getExtension().length == 0) {
                firstNumber.clearExtension();
            }
            if(secondNumber.hasExtension() && secondNumber.getExtension().length == 0) {
                secondNumber.clearExtension();
            }

            // Early exit if both had extensions and these are different.
            if(firstNumber.hasExtension() && secondNumber.hasExtension() && firstNumber.getExtension() != secondNumber.getExtension()) {
                return MatchType.NO_MATCH;
            }
            var firstNumberCountryCode:Number = firstNumber.getCountryCode();
            var secondNumberCountryCode:Number = secondNumber.getCountryCode();
            // Both had country_code specified.
            if(firstNumberCountryCode != 0 && secondNumberCountryCode != 0) {
                if(firstNumber.equals(secondNumber)) {
                    return MatchType.EXACT_MATCH;
                } else
                    if(firstNumberCountryCode == secondNumberCountryCode && isNationalNumberSuffixOfTheOther_(firstNumber, secondNumber)) {
                        // A SHORT_NSN_MATCH occurs if there is a difference because of the
                        // presence or absence of an 'Italian leading zero', the presence or
                        // absence of an extension, or one NSN being a shorter variant of the
                        // other.
                        return MatchType.SHORT_NSN_MATCH;
                    }
                // This is not a match.
                return MatchType.NO_MATCH;
            }
            // Checks cases where one or both country_code fields were not specified. To
            // make equality checks easier, we first set the country_code fields to be
            // equal.
            firstNumber.setCountryCode(0);
            secondNumber.setCountryCode(0);
            // If all else was the same, then this is an NSN_MATCH.
            if(firstNumber.equals(secondNumber)) {
                return MatchType.NSN_MATCH;
            }
            if(isNationalNumberSuffixOfTheOther_(firstNumber, secondNumber)) {
                return MatchType.SHORT_NSN_MATCH;
            }
            return MatchType.NO_MATCH;
        }


        /**
         * Returns true when one national number is the suffix of the other or both are
         * the same.
         *
         * @param {PhoneNumber} firstNumber the first PhoneNumber
         *     object.
         * @param {PhoneNumber} secondNumber the second PhoneNumber
         *     object.
         * @return {Boolean} true if one PhoneNumber is the suffix of the other one.
         * @private
         */
        private static function isNationalNumberSuffixOfTheOther_(firstNumber:PhoneNumber, secondNumber:PhoneNumber):Boolean
        {
            var firstNumberNationalNumber:String = firstNumber.getNationalNumber().toString();
            var secondNumberNationalNumber:String = secondNumber.getNationalNumber().toString();
            // Note that endsWith returns true if the numbers are equal.
            return StringUtils.endsWith(firstNumberNationalNumber, secondNumberNationalNumber) || StringUtils.endsWith(secondNumberNationalNumber, firstNumberNationalNumber);
        }


        /**
         * Returns true if the number can be dialled from outside the region, or
         * unknown. If the number can only be dialled from within the region, returns
         * false. Does not check the number is a valid number.
         * TODO: Make this method public when we have enough metadata to make it
         * worthwhile. Currently visible for testing purposes only.
         *
         * @param {PhoneNumber} number the phone-number for which we
         *     want to know whether it is diallable from outside the region.
         * @return {Boolean} true if the number can only be dialled from within the
         *     country.
         */
        public function canBeInternationallyDialled(number:PhoneNumber):Boolean
        {
            var metadata:PhoneMetadata = this.getMetadataForRegion(this.getRegionCodeForNumber(number));
            if(metadata == null) {
                // Note numbers belonging to non-geographical entities (e.g. +800 numbers)
                // are always internationally diallable, and will be caught here.
                return true;
            }
            var nationalSignificantNumber:String = getNationalSignificantNumber(number);
            return !isNumberMatchingDesc_(nationalSignificantNumber, metadata.getNoInternationalDialling());
        }

        /**
         * Check whether the entire input sequence can be matched against the regular
         * expression.
         *
         * @param {!RegExp|String} regex the regular expression to match against.
         * @param {String} str the string to test.
         * @return {Boolean} true if str can be matched entirely against regex.
         * @private
         */
        private static function matchesEntirely_(regex:*, str:String):Boolean
        {
            var matchedGroups:Array = (typeof regex == 'string') ? str.match('^(?:' + regex + ')$') : str.match(regex);
            return!!(matchedGroups && matchedGroups[0].length == str.length);
        }
    }
}
