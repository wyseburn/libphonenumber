package com.google.i18n.phonenumbers
{
    public class PhoneNumberDesc
    {
        protected var _hasNationalNumberPattern:Boolean = false;
        protected var _nationalNumberPattern:String = "";
        protected var _hasPossibleNumberPattern:Boolean = false;
        protected var _possibleNumberPattern:String = "";
        protected var _hasExampleNumber:Boolean = false;
        protected var _exampleNumber:String = "";

        public function PhoneNumberDesc(data:Array = null)
        {
            if(data != null)
                setData(data);
        }

        public function setData(data:Array):void
        {
            for(var key:String in data) {
                if(data.hasOwnProperty(key) && data[key]) {
                    switch(key) {
                        case '2': //national_number_pattern
                            setNationalNumberPattern(data[key]);
                            break;
                        case '3': //possible_number_pattern
                            setPossibleNumberPattern(data[key]);
                            break;
                        case '6': //example_number
                            setExampleNumber(data[key]);
                            break;
                        case '7': //national_number_matcher_data
                            break;
                        case '8': //possible_number_matcher_data
                            break;
                    }
                }
            }
        }

        public function hasNationalNumberPattern():Boolean
        {
            return _hasNationalNumberPattern;
        }

        public function getNationalNumberPattern():String
        {
            return _nationalNumberPattern;
        }

        public function setNationalNumberPattern(value:String):void
        {
            _hasNationalNumberPattern = true;
            _nationalNumberPattern = value;
        }

        public function hasPossibleNumberPattern():Boolean
        {
            return _hasPossibleNumberPattern;
        }

        public function getPossibleNumberPattern():String
        {
            return _possibleNumberPattern;
        }

        public function setPossibleNumberPattern(value:String):void
        {
            _hasPossibleNumberPattern = true;
            _possibleNumberPattern = value;
        }

        public function hasExampleNumber():Boolean
        {
            return _hasExampleNumber;
        }

        public function getExampleNumber():String
        {
            return _exampleNumber;
        }

        public function setExampleNumber(value:String):void
        {
            _hasExampleNumber = true;
            _exampleNumber = value;
        }
    }
}
