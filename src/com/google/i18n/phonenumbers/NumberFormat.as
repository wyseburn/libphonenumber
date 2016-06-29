package com.google.i18n.phonenumbers
{
    public class NumberFormat
    {
        protected var pattern:String;
        public function hasPattern():Boolean { return pattern != null; }
        public function getPattern():String { return pattern; }
        public function setPattern(value:String):void { pattern = value; }

        protected var format:String;
        public function hasFormat():Boolean { return format != null; }
        public function getFormat():String { return format; }
        public function setFormat(value:String):void { format = value; }

        protected var leadingDigitsPattern:Array = [];
        public function leadingDigitPatterns():Array { return leadingDigitsPattern; }
        public function leadingDigitsPatternSize():Number { return leadingDigitsPattern.length; }
        public function getLeadingDigitsPattern(index:Number):String { return leadingDigitsPattern[index]; }
        public function addLeadingDigitsPattern(value:String):void { leadingDigitsPattern.push(value); }
        public function leadingDigitsPatternArray():Array {return leadingDigitsPattern;}
        public function hasLeadingDigitsPattern():Boolean {return leadingDigitsPattern.length > 0;}
        public function leadingDigitsPatternCount():Number {return leadingDigitsPattern.length;}

        protected var nationalPrefixFormattingRule:String;
        public function hasNationalPrefixFormattingRule():Boolean { return nationalPrefixFormattingRule != null; }
        public function getNationalPrefixFormattingRule():String { return nationalPrefixFormattingRule; }
        public function setNationalPrefixFormattingRule(value:String):void { nationalPrefixFormattingRule = value; }
        public function clearNationalPrefixFormattingRule():void { nationalPrefixFormattingRule = null; }

        protected var domesticCarrierCodeFormattingRule:String;
        public function hasDomesticCarrierCodeFormattingRule():Boolean { return domesticCarrierCodeFormattingRule != null; }
        public function getDomesticCarrierCodeFormattingRule():String { return domesticCarrierCodeFormattingRule; }
        public function setDomesticCarrierCodeFormattingRule(value:String):void { domesticCarrierCodeFormattingRule = value; }

        public function NumberFormat(data:Array = null):void
        {
            if(data != null)
                setData(data);
        }

        public function setData(data:Array):void
        {
            for(var key:String in data) {
                if(data.hasOwnProperty(key) && data[key]) {
                    switch(key) {
                        case '1':
                            setPattern(data[key]);
                            break;
                        case '2':
                            setFormat(data[key]);
                            break;
                        case '3':
                            addLeadingDigitsPattern(data[key]);
                            break;
                        case '4':
                            setNationalPrefixFormattingRule(data[key]);
                            break;
                        case '5':
                            setDomesticCarrierCodeFormattingRule(data[key]);
                            break;
                        case '6':
                            //national_prefix_optional_when_formatting
                            break;
                    }
                }
            }
        }
    }
}
