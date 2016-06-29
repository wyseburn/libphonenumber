package com.google.i18n.phonenumbers
{
    public class PhoneNumber
    {
        protected var countryCode:Number = 0;
        protected var nationalNumber:Number = 0;
        protected var extension:String;
        protected var italianLeadingZero:Boolean = false;
        protected var rawInput:String;
        protected var countryCodeSource:Number = 0;
        protected var preferredDomesticCarrierCode:String;
        protected var numberOfLeadingZeros:Number = 0;

        public function PhoneNumber()
        {
        }

        public function hasCountryCode():Boolean { return countryCode != 0; }
        public function getCountryCode():Number { return countryCode; }
        public function setCountryCode(value:Number):void { countryCode = value; }
        public function clearCountryCode():void { countryCode = 0; }

        public function hasNationalNumber():Boolean { return nationalNumber != 0; }
        public function getNationalNumber():Number { return nationalNumber; }
        public function setNationalNumber(value:Number):void { nationalNumber = value; }
        public function clearNationalNumber():void { nationalNumber = 0; }

        public function hasExtension():Boolean { return extension != null; }
        public function getExtension():String { return extension; }
        public function setExtension(value:String):void { extension = value; }
        public function clearExtension():void { extension = null; }

        public function hasItalianLeadingZero():Boolean { return true; }
        public function getItalianLeadingZero():Boolean { return italianLeadingZero; }
        public function setItalianLeadingZero(value:Boolean):void { italianLeadingZero = value; }
        public function clearItalianLeadingZero():void { italianLeadingZero = false; }

        public function hasNumberOfLeadingZeros():Boolean { return numberOfLeadingZeros != 0; }
        public function getNumberOfLeadingZeros():Number { return numberOfLeadingZeros; }
        public function setNumberOfLeadingZeros(value:Number):void { numberOfLeadingZeros = value; }
        public function clearNumberOfLeadingZeros():void { numberOfLeadingZeros = 0; }

        public function hasRawInput():Boolean { return rawInput != null; }
        public function getRawInput():String { return rawInput; }
        public function setRawInput(value:String):void { rawInput = value; }
        public function clearRawInput():void { rawInput = null; }

        public function hasCountryCodeSource():Boolean { return countryCodeSource != 0; }
        public function getCountryCodeSource():Number { return countryCodeSource; }
        public function setCountryCodeSource(value:Number):void { countryCodeSource = value; }
        public function clearCountryCodeSource():void { countryCodeSource = 0; }

        public function hasPreferredDomesticCarrierCode():Boolean { return preferredDomesticCarrierCode != null; }
        public function getPreferredDomesticCarrierCode():String { return preferredDomesticCarrierCode; }
        public function setPreferredDomesticCarrierCode(value:String):void { preferredDomesticCarrierCode = value; }
        public function clearPreferredDomesticCarrierCode():void { preferredDomesticCarrierCode = null; }

        public static const CountryCodeSource:Object = {
            FROM_NUMBER_WITH_PLUS_SIGN: 1,
            FROM_NUMBER_WITH_IDD: 5,
            FROM_NUMBER_WITHOUT_PLUS_SIGN: 10,
            FROM_DEFAULT_COUNTRY: 20
        };

        public function equals(other:PhoneNumber):Boolean
        {
            var sameCountry:Boolean = hasCountryCode() == other.hasCountryCode() && (!hasCountryCode() || getCountryCode() == other.getCountryCode());
            var sameNational:Boolean = hasNationalNumber() == other.hasNationalNumber() && (!hasNationalNumber() || getNationalNumber() == other.getNationalNumber());
            var sameExt:Boolean = hasExtension() == other.hasExtension() && (!hasExtension() || hasExtension() == other.hasExtension());
            var sameLead:Boolean = hasItalianLeadingZero() == other.hasItalianLeadingZero() && (!hasItalianLeadingZero() || getItalianLeadingZero() == other.getItalianLeadingZero());
            var sameZeros:Boolean = getNumberOfLeadingZeros() == other.getNumberOfLeadingZeros();
            var sameRaw:Boolean = hasRawInput() == other.hasRawInput() && (!hasRawInput() || getRawInput() == other.getRawInput());
            var sameCountrySource:Boolean = hasCountryCodeSource() == other.hasCountryCodeSource() && (!hasCountryCodeSource() || getCountryCodeSource() == other.getCountryCodeSource());
            var samePrefCar:Boolean = hasPreferredDomesticCarrierCode() == other.hasPreferredDomesticCarrierCode() && (!hasPreferredDomesticCarrierCode() || getPreferredDomesticCarrierCode( ) == other.getPreferredDomesticCarrierCode());
            return sameCountry && sameNational && sameExt && sameLead && sameZeros && sameRaw && sameCountrySource && samePrefCar;
        }
    }
}
