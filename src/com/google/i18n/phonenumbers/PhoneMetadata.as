package com.google.i18n.phonenumbers
{
    public class PhoneMetadata
    {
        protected var id:String;
        public function hasId():Boolean { return id != null; }
        public function getId():String { return id; }
        public function setId(value:String):void { id = value; }

        protected var countryCode:Number = -1;
        public function hasCountryCode():Boolean { return countryCode != -1; }
        public function getCountryCode():Number { return countryCode; }
        public function setCountryCode(value:Number):void { countryCode = value; }

        protected var leadingDigits:Number = -1;
        public function hasLeadingDigits():Boolean { return leadingDigits != -1; }
        public function getLeadingDigits():Number { return leadingDigits; }
        public function setLeadingDigits(value:Number):void { leadingDigits = value; }

        protected var internationalPrefix:String;
        public function hasInternationalPrefix():Boolean { return internationalPrefix != null; }
        public function getInternationalPrefix():String { return internationalPrefix; }
        public function setInternationalPrefix(value:String):void { internationalPrefix = value; }

        protected var preferredInternationalPrefix:String;
        public function hasPreferredInternationalPrefix():Boolean { return preferredInternationalPrefix != null; }
        public function getPreferredInternationalPrefix():String { return preferredInternationalPrefix; }
        public function setPreferredInternationalPrefix(value:String):void { preferredInternationalPrefix = value; }

        protected var nationalPrefixForParsing:String;
        public function hasNationalPrefixForParsing():Boolean { return nationalPrefixForParsing != null; }
        public function getNationalPrefixForParsing():String { return nationalPrefixForParsing; }
        public function setNationalPrefixForParsing(value:String):void { nationalPrefixForParsing = value; }

        protected var nationalPrefixTransformRule:String;
        public function hasNationalPrefixTransformRule():Boolean { return nationalPrefixTransformRule != null; }
        public function getNationalPrefixTransformRule():String { return nationalPrefixTransformRule; }
        public function setNationalPrefixTransformRule(value:String):void { nationalPrefixTransformRule = value; }

        protected var nationalPrefix:String;
        public function hasNationalPrefix():Boolean { return nationalPrefix != null; }
        public function getNationalPrefix():String { return nationalPrefix; }
        public function setNationalPrefix(value:String):void { nationalPrefix = value; }

        protected var preferredExtnPrefix:String;
        public function hasPreferredExtnPrefix():Boolean { return preferredExtnPrefix != null; }
        public function getPreferredExtnPrefix():String { return preferredExtnPrefix; }
        public function setPreferredExtnPrefix(value:String):void { preferredExtnPrefix = value; }

        protected var mainCountryForCode:Boolean = false;
        public function hasMainCountryForCode():Boolean { return true; }
        public function getMainCountryForCode():Boolean { return mainCountryForCode; }
        public function setMainCountryForCode(value:Boolean):void { mainCountryForCode = value; }

        protected var leadingZeroPossible:Boolean = false;
        public function hasLeadingZeroPossible():Boolean { return true; }
        public function getLeadingZeroPossible():Boolean { return leadingZeroPossible; }
        public function setLeadingZeroPossible(value:Boolean):void { leadingZeroPossible = value; }

        protected var mobileNumberPortableRegion:Boolean = false;
        public function hasMobileNumberPortableRegion():Boolean { return true; }
        public function isMobileNumberPortableRegion():Boolean { return mobileNumberPortableRegion; }
        public function setMobileNumberPortableRegion(value:Boolean):void { mobileNumberPortableRegion = value; }

        protected var generalDesc:PhoneNumberDesc;
        public function hasGeneralDesc():Boolean { return generalDesc != null; }
        public function getGeneralDesc():PhoneNumberDesc { return generalDesc; }
        public function setGeneralDesc(value:PhoneNumberDesc):void { generalDesc = value; }

        protected var mobile:PhoneNumberDesc;
        public function hasMobile():Boolean { return mobile != null; }
        public function getMobile():PhoneNumberDesc { return mobile; }
        public function setMobile(value:PhoneNumberDesc):void { mobile = value; }

        protected var premiumRate:PhoneNumberDesc;
        public function hasPremiumRate():Boolean { return premiumRate != null; }
        public function getPremiumRate():PhoneNumberDesc { return premiumRate; }
        public function setPremiumRate(value:PhoneNumberDesc):void { premiumRate = value; }


        protected var fixedLine:PhoneNumberDesc;
        public function hasFixedLine():Boolean { return fixedLine != null; }
        public function getFixedLine():PhoneNumberDesc { return fixedLine; }
        public function setFixedLine(value:PhoneNumberDesc):void { fixedLine = value; }

        protected var sameMobileAndFixedLinePattern:Boolean = false;
        public function hasSameMobileAndFixedLinePattern():Boolean { return true; }
        public function isSameMobileAndFixedLinePattern():Boolean { return sameMobileAndFixedLinePattern; }
        public function setSameMobileAndFixedLinePattern(value:Boolean):void { sameMobileAndFixedLinePattern = value; }
        public function getSameMobileAndFixedLinePattern():Boolean {return sameMobileAndFixedLinePattern;}

        protected var numberFormat:Array = [];
        public function numberFormatArray():Array { return numberFormat; }
        public function numberFormatSize():Number { return numberFormat.length; }
        public function getNumberFormat(index:Number):NumberFormat { return numberFormat[index]; }
        public function addNumberFormat(value:NumberFormat):void { numberFormat.push(value); }

        protected var tollFree:PhoneNumberDesc;
        public function hasTollFree():Boolean { return tollFree != null; }
        public function getTollFree():PhoneNumberDesc { return tollFree; }
        public function setTollFree(value:PhoneNumberDesc):void { tollFree = value; }

        protected var sharedCost:PhoneNumberDesc;
        public function hasSharedCost():Boolean { return sharedCost != null; }
        public function getSharedCost():PhoneNumberDesc { return sharedCost; }
        public function setSharedCost(value:PhoneNumberDesc):void { sharedCost = value; }

        protected var personalNumber:PhoneNumberDesc;
        public function hasPersonalNumber():Boolean { return personalNumber != null; }
        public function getPersonalNumber():PhoneNumberDesc { return personalNumber; }
        public function setPersonalNumber(value:PhoneNumberDesc):void { personalNumber = value; }

        protected var voip:PhoneNumberDesc;
        public function hasVoip():Boolean { return voip != null; }
        public function getVoip():PhoneNumberDesc { return voip; }
        public function setVoip(value:PhoneNumberDesc):void { voip = value; }

        protected var pager:PhoneNumberDesc;
        public function hasPager():Boolean { return pager != null; }
        public function getPager():PhoneNumberDesc { return pager; }
        public function setPager(value:PhoneNumberDesc):void { pager = value; }

        protected var uan:PhoneNumberDesc;
        public function hasUan():Boolean { return uan != null; }
        public function getUan():PhoneNumberDesc { return uan; }
        public function setUan(value:PhoneNumberDesc):void { uan = value; }

        protected var emergency:PhoneNumberDesc;
        public function hasEmergency():Boolean { return emergency != null; }
        public function getEmergency():PhoneNumberDesc { return emergency; }
        public function setEmergency(value:PhoneNumberDesc):void { emergency = value; }

        protected var voicemail:PhoneNumberDesc;
        public function hasVoicemail():Boolean { return voicemail != null; }
        public function getVoicemail():PhoneNumberDesc { return voicemail; }
        public function setVoicemail(value:PhoneNumberDesc):void { voicemail = value; }

        protected var shortCode:PhoneNumberDesc;
        public function hasShortCode():Boolean { return shortCode != null; }
        public function getShortCode():PhoneNumberDesc { return shortCode; }
        public function setShortCode(value:PhoneNumberDesc):void { shortCode = value; }

        protected var standardRate:PhoneNumberDesc;
        public function hasStandardRate():Boolean { return standardRate != null; }
        public function getStandardRate():PhoneNumberDesc { return standardRate; }
        public function setStandardRate(value:PhoneNumberDesc):void { standardRate = value; }

        protected var carrierSpecific:PhoneNumberDesc;
        public function hasCarrierSpecific():Boolean { return carrierSpecific != null; }
        public function getCarrierSpecific():PhoneNumberDesc { return carrierSpecific; }
        public function setCarrierSpecific(value:PhoneNumberDesc):void { carrierSpecific = value; }

        protected var noInternationalDialling:PhoneNumberDesc;
        public function hasNoInternationalDialling():Boolean { return noInternationalDialling != null; }
        public function getNoInternationalDialling():PhoneNumberDesc { return noInternationalDialling; }
        public function setNoInternationalDialling(value:PhoneNumberDesc):void { noInternationalDialling = value; }

        protected var intlNumberFormat:Array = [];
        public function intlNumberFormatArray():Array { return intlNumberFormat; }
        public function intlNumberFormatSize():Number { return intlNumberFormat.length; }
        public function getIntlNumberFormat(index:Number):NumberFormat { return intlNumberFormat[index]; }
        public function addIntlNumberFormat(value:NumberFormat):void { intlNumberFormat.push(value); }
        public function clearIntlNumberFormat():void { intlNumberFormat = []; }



        public function PhoneMetadata(data:Array = null):void
        {
            if(data != null)
                setData(data);
        }

        public function setData(data:Array):void
        {
            for (var key:String in data) {
                if(data.hasOwnProperty(key) && data[key]) {
                    switch(key) {
                        case '1': //[, , "007\\d{9,11}|[1-7]\\d{3,9}|8\\d{8}", "\\d{4,14}"]
                            setGeneralDesc(new PhoneNumberDesc(data[key]));
                            break;
                        case '2': //[, , "(?:2|3[1-3]|[46][1-4]|5[1-5])(?:1\\d{2,3}|[1-9]\\d{6,7})", "\\d{4,10}", , , "22123456"],
                            setFixedLine(new PhoneNumberDesc(data[key]));
                            break;
                        case '3': //[, , "1[0-26-9]\\d{7,8}", "\\d{9,10}", , , "1000000000"],
                            setMobile(new PhoneNumberDesc(data[key]));
                            break;
                        case '4': //[, , "(?:00798\\d{0,2}|80)\\d{7}", "\\d{9,14}", , , "801234567"],
                            setTollFree(new PhoneNumberDesc(data[key]));
                            break;
                        case '5': //[, , "60[2-9]\\d{6}", "\\d{9}", , , "602345678"],
                            setPremiumRate(new PhoneNumberDesc(data[key]));
                            break;
                        case '6': //[, , "NA", "NA"],
                            setSharedCost(new PhoneNumberDesc(data[key]));
                            break;
                        case '7': //[, , "50\\d{8}", "\\d{10}", , , "5012345678"],
                            setPersonalNumber(new PhoneNumberDesc(data[key]));
                            break;
                        case '8': //[, , "70\\d{8}", "\\d{10}", , , "7012345678"],
                            setVoip(new PhoneNumberDesc(data[key]));
                            break;
                        case '21': //[, , "15\\d{7,8}", "\\d{9,10}", , , "1523456789"]
                            setPager(new PhoneNumberDesc(data[key]));
                            break;
                        case '25': //[, , "1(?:5(?:44|66|77|88|99)|6(?:00|44|6[16]|70|88)|8(?:00|55|77|99))\\d{4}", "\\d{8}", , , "15441234"],
                            setUan(new PhoneNumberDesc(data[key]));
                            break;
                        case '27': //
                            setEmergency(new PhoneNumberDesc(data[key]));
                            break;
                        case '28': //[, , "NA", "NA"]
                            setVoicemail(new PhoneNumberDesc(data[key]));
                            break;
                        case '24': //[, , "00798\\d{7,9}", "\\d{12,14}", , , "007981234567"],
                            setNoInternationalDialling(new PhoneNumberDesc(data[key]));
                            break;
                        case '9': //"KR",
                            setId(data[key]);
                            break;
                        case '10': //82,
                            setCountryCode(data[key]);
                            break;
                        case '11': //"00(?:[124-68]|3\\d{2}|7(?:[0-8]\\d|9[0-79]))",
                            setInternationalPrefix(data[key]);
                            break;
                        case '12': //"0",
                            setNationalPrefix(data[key]);
                            break;
                        case '13': //
                            setPreferredExtnPrefix(data[key]);
                            break;
                        case '15': //"0(8[1-46-8]|85\\d{2})?",
                            setNationalPrefixForParsing(data[key]);
                            break;
                        case '16': //
                            setNationalPrefixTransformRule(data[key]);
                            break;
                        case '17': //
                            setPreferredInternationalPrefix(data[key]);
                            break;
                        case '18': //
                            setSameMobileAndFixedLinePattern(data[key]);
                            break;
                        case '19': //[[, "(\\d{5})(\\d{3,4})(\\d{4})", "$1 $2 $3", ["00798"], "$1", "0$CC-$1"],[, "(\\d{3})(\\d)(\\d{4})", "$1-$2-$3", ["131", "1312"], "0$1", "0$CC-$1"]]
                            addNumberFormat(new NumberFormat(data[key]));
                            break;
                        case '20': //[[, "(\\d{3})(\\d)(\\d{4})", "$1-$2-$3", ["131", "1312"], "0$1", "0$CC-$1"],[, "(\\d)(\\d{3,4})", "$1-$2", ["21[0-46-9]"], "0$1", "0$CC-$1"]]
                            addIntlNumberFormat(new NumberFormat(data[key]));
                            break;
                        case '22': //
                            setMainCountryForCode(data[key]);
                            break;
                        case '23': //
                            setLeadingDigits(data[key]);
                            break;
                        case '26': //
                            setLeadingZeroPossible(data[key]);
                            break;
                    }
                }
            }
        }
    }
}
