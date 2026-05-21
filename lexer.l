%option noyywrap

%{
   #include <stdlib.h> 
   #include <iostream>
   #include <string>
   #include "parser.tab.h"

   double parse_superscript(const char* text) {
       std::string str(text);
       std::string ascii_str = "";
       for (size_t i = 0; i < str.length();) {
           if (str.compare(i, 3, "⁰") == 0) { ascii_str += "0"; i += 3; }
           else if (str.compare(i, 2, "¹") == 0) { ascii_str += "1"; i += 2; }
           else if (str.compare(i, 2, "²") == 0) { ascii_str += "2"; i += 2; }
           else if (str.compare(i, 2, "³") == 0) { ascii_str += "3"; i += 2; }
           else if (str.compare(i, 3, "⁴") == 0) { ascii_str += "4"; i += 3; }
           else if (str.compare(i, 3, "⁵") == 0) { ascii_str += "5"; i += 3; }
           else if (str.compare(i, 3, "⁶") == 0) { ascii_str += "6"; i += 3; }
           else if (str.compare(i, 3, "⁷") == 0) { ascii_str += "7"; i += 3; }
           else if (str.compare(i, 3, "⁸") == 0) { ascii_str += "8"; i += 3; }
           else if (str.compare(i, 3, "⁹") == 0) { ascii_str += "9"; i += 3; }
           else { ++i; } // Skip unexpected characters
       }
       return atof(ascii_str.c_str());
   }
   double parse_subscript(const char* text, int skip) {
       std::string str(text + skip);
       std::string ascii_str = "";
       for (size_t i = 0; i < str.length();) {
           if (str.compare(i, 3, "₀") == 0) { ascii_str += "0"; i += 3; }
           else if (str.compare(i, 3, "₁") == 0) { ascii_str += "1"; i += 3; }
           else if (str.compare(i, 3, "₂") == 0) { ascii_str += "2"; i += 3; }
           else if (str.compare(i, 3, "₃") == 0) { ascii_str += "3"; i += 3; }
           else if (str.compare(i, 3, "₄") == 0) { ascii_str += "4"; i += 3; }
           else if (str.compare(i, 3, "₅") == 0) { ascii_str += "5"; i += 3; }
           else if (str.compare(i, 3, "₆") == 0) { ascii_str += "6"; i += 3; }
           else if (str.compare(i, 3, "₇") == 0) { ascii_str += "7"; i += 3; }
           else if (str.compare(i, 3, "₈") == 0) { ascii_str += "8"; i += 3; }
           else if (str.compare(i, 3, "₉") == 0) { ascii_str += "9"; i += 3; }
           else { ++i; } // Skip unexpected characters
       }
       return atof(ascii_str.c_str());
   }
%}

SUPERSCRIPT_DIGIT ("⁰"|"¹"|"²"|"³"|"⁴"|"⁵"|"⁶"|"⁷"|"⁸"|"⁹")
SUBSCRIPT_DIGIT ("₀"|"₁"|"₂"|"₃"|"₄"|"₅"|"₆"|"₇"|"₈"|"₉")

%%

[0-9]+(\.[0-9]+)?       { yylval = atof(yytext); return NUM; }
{SUPERSCRIPT_DIGIT}     { yylval = parse_superscript(yytext); return SUPERSCRIPT_NUM; }
{SUBSCRIPT_DIGIT}       { yylval = parse_subscript(yytext, 0); return SUBSCRIPT_NUM; }

"B"            { return BERNOULLI; }
"log"          { return LOG_BASE; }

"π"            { return PI; }
"ɸ"            { return PHI; }

"e"            { return NATURAL_LOGARITHM_BASE; }
"ᵉ"            { return SUPERSCRIPT_NATURAL_LOGARITHM_BASE; }
"ₑ"            { return SUBSCRIPT_NATURAL_LOGARITHM_BASE; }

"("            { return LEFT_PARENTHESES; }
")"            { return RIGHT_PARENTHESES; }

"⁽"            { return SUPERSCRIPT_LEFT_PARENTHESES; }
"⁾"            { return SUPERSCRIPT_RIGHT_PARENTHESES; }

"₍"            { return SUBSCRIPT_LEFT_PARENTHESES; }
"₎"            { return SUBSCRIPT_RIGHT_PARENTHESES; }

"+"            { return PLUS; }
"-"            { return MINUS; }

"⁺"            { return SUPERSCRIPT_PLUS; }
"⁻"            { return SUPERSCRIPT_MINUS; }

"₊"            { return SUBSCRIPT_PLUS; }
"₋"            { return SUBSCRIPT_MINUS; }

"×"            { return MUL; }
"·"            { return MUL; }
"/"            { return DIV; }
"√"            { return SQRT; }

"sgn"          { return SGN; }

"|"            { return MODULUS; }

"⌊"            { return LEFT_FLOOR; }
"⌋"            { return RIGHT_FLOOR; }
"⌈"            { return LEFT_CEIL; }
"⌉"            { return RIGHT_CEIL; }

"int"          { return INT; }
"frac"         { return FRAC; }

"!"            { return FACTORIAL; }

"exp"          { return EXPONENTIAL;}

"ln"           { return LN; }
"lg"           { return LG; }
"lb"           { return LB; }

"sin"          { return SIN; }
"cos"          { return COS; }
"tan"          { return TAN; }
"cot"          { return COT; }
"sec"          { return SEC; }
"csc"          { return CSC; }
"arcsin"       { return ARCSIN; }
"arccos"       { return ARCCOS; }
"arctan"       { return ARCTAN; }
"arccot"       { return ARCCOT; }
"arcsec"       { return ARCSEC; }
"arccsc"       { return ARCCSC; }

"sinh"         { return SINH; }
"cosh"         { return COSH; }
"tanh"         { return TANH; }
"coth"         { return COTH; }
"sech"         { return SECH; }
"csch"         { return CSCH; }
"arsinh"       { return ARSINH; }
"arcosh"       { return ARCOSH; }
"artanh"       { return ARTANH; }
"arcoth"       { return ARCOTH; }
"arsech"       { return ARSECH; }
"arcsch"       { return ARCSCH; }

"i"            { return IMAGINARY_UNIT; }

"Re"           { return REAL_PART; }
"Im"           { return IMAGINARY_PART; }
"arg"          { return ARGUMENT_OF_COMPLEX_NUM; }



"∧"            { return LOGICAL_AND; }
"∨"            { return LOGICAL_OR; }
"¬"            { return NOT_SIGN; }

"="            { return EQUAL; }
"≠"            { return NOT_EQUAL; }
"≈"            { return APPROXIMATELY_EQUAL; }
"<"            { return LESS_THAN; }
">"            { return GREATER_THAN; }

"≪"            { return MUCH_LESS_THAN; }
"≫"            { return MUCH_GREATER_THAN; }

"≤"            { return LESS_THAN_OR_EQUAL; }
"≥"            { return GREATER_THAN_OR_EQUAL; }

"⇒"            { return LEFT_IMPLIES_RIGHT; }
"⇐"            { return RIGHT_IMPLIES_LEFT; }
"⇔"            { return EQUIVALENCE; }

\n             { return '\n'; }
[ ]+         ; /* ignore spaces */
.              { std::cout << "Wrong char: " << yytext << std::endl; }
              
%%