%{
	#include <cstdlib>
	#include <cstdio>
	#include <iostream>
	#include <cmath>
	#include <complex>
    
    using C = std::complex<double>;

    constexpr double constexpr_double_e   = 2.718281828459045235360287471352662497757;
    constexpr double constexpr_double_pi  = 3.141592653589793238462643383279502884197;
    constexpr double constexpr_double_phi = 1.618033988749894848204586834365638117720;

    auto Re = [](const C& z) { return std::real(z); };
    auto Im = [](const C& z) { return std::imag(z); };

    void yyerror(const char *s);
    int yylex();
    extern FILE* yyin;

    C sgn(const C x) {
        if (std::abs(x) == 0.0) return 0.0;
        return x / std::abs(x);
    }

    C int_part(const C x) {
        return sgn(x) * std::floor(std::abs(x));
    }

    C frac_part(const C x) {
        return x - int_part(x);
    }

    double calc_bernoulli(int n) {
        if (n < 0) return 0.0;
        double A[n + 1];
        for (int m = 0; m <= n; m++) {
            A[m] = 1.0 / (m + 1.0);
            for (int j = m; j > 0; j--) {
                A[j - 1] = j * (A[j - 1] - A[j]);
            }
        }
        return A[0];
    }

    void print_result(const C& z) {
        if (std::abs(Im(z)) < 1e-9) {
            std::cout << "= " << Re(z) << std::endl;
        } else if (std::abs(Re(z)) < 1e-9) {
            if (Im(z) == 1) std::cout << "= i" << std::endl;
            else if (Im(z) == -1) std::cout << "= -i" << std::endl;
            else std::cout << "= " << Im(z) << "i" << std::endl;
        } else {
            std::cout << "= " << Re(z) << (Im(z) > 0 ? " + " : " - ") << std::abs(Im(z)) << "i" << std::endl;
        }
    }
%}

%code requires {
    #include <complex>
    using C = std::complex<double>;
}

%define api.value.type {C}

%token NUM SUBSCRIPT_NUM PI EULER PHI LEFT_CEIL RIGHT_CEIL LEFT_FLOOR RIGHT_FLOOR
%token SUPERSCRIPT_NUM NATURAL_LOGARITHM_BASE SUPERSCRIPT_NATURAL_LOGARITHM_BASE SUBSCRIPT_NATURAL_LOGARITHM_BASE
%token LEFT_PARENTHESES RIGHT_PARENTHESES SUPERSCRIPT_LEFT_PARENTHESES SUPERSCRIPT_RIGHT_PARENTHESES SUBSCRIPT_LEFT_PARENTHESES SUBSCRIPT_RIGHT_PARENTHESES
%token MODULUS EXPONENTIAL
%token IMAGINARY_UNIT REAL_PART IMAGINARY_PART ARGUMENT_OF_COMPLEX_NUM
%token BERNOULLI LOG_BASE
%left EQUIVALENCE
%left LOGICAL_OR
%left LOGICAL_AND
%left LEFT_IMPLIES_RIGHT RIGHT_IMPLIES_LEFT
%left EQUAL APPROXIMATELY_EQUAL NOT_EQUAL GREATER_THAN LESS_THAN LESS_THAN_OR_EQUAL GREATER_THAN_OR_EQUAL MUCH_LESS_THAN MUCH_GREATER_THAN
%left PLUS MINUS
%left MUL DIV
%precedence NEG NOT_SIGN INT FRAC FACTORIAL SQRT SIN COS TAN COT SEC CSC ARCSIN ARCCOS ARCTAN ARCCOT ARCSEC ARCCSC SINH COSH TANH COTH SECH CSCH ARSINH ARCOSH ARTANH ARCOTH ARSECH ARCSCH LN LG LB SGN
%left SUPERSCRIPT_PLUS SUPERSCRIPT_MINUS SUBSCRIPT_PLUS SUBSCRIPT_MINUS

%%

input : %empty
      | input line
      ;

line  : '\n'
      | exp '\n'        { print_result($1); }
      | error '\n'      { yyerrok; }
      ;

exp   : NUM             { $$ = $1; }
      | exp PLUS exp    { $$ = $1 + $3; }
      | exp MINUS exp   { $$ = $1 - $3; }
      | exp MUL exp     { $$ = $1 * $3; }
      | exp DIV exp     { 
                            $$ = $1 / $3;

                            if(std::abs($3) == 0.0)  { 
                                yyerror("Dividing by zero!"); 
                            } 
                        }
      | MINUS exp %prec NEG { $$ = -$2; }
      | INT exp     { $$ = int_part($2); }
      | FRAC exp    { $$ = frac_part($2); }
      | exp sup_exp %prec SQRT { $$ = pow($1, $2); }
      | SIN exp     { $$ = std::sin($2); }
      | COS exp     { $$ = std::cos($2); }
      | TAN exp     { $$ = std::tan($2); }
      | COT exp     { $$ = 1.0 / std::tan($2); }
      | SEC exp     { $$ = 1.0 / std::cos($2); }
      | CSC exp     { $$ = 1.0 / std::sin($2); }
      | ARCSIN exp  { $$ = std::asin($2); }
      | ARCCOS exp  { $$ = std::acos($2); }
      | ARCTAN exp  { $$ = std::atan($2); }
      | ARCCOT exp  { $$ = std::acos(C(0,1) * $2) / C(0,1); $$ = constexpr_double_pi/2.0 - std::atan($2); }
      | ARCSEC exp  { $$ = std::acos(1.0 / $2); }
      | ARCCSC exp  { $$ = std::asin(1.0 / $2); }
      | SINH exp    { $$ = std::sinh($2); }
      | COSH exp    { $$ = std::cosh($2); }
      | TANH exp    { $$ = std::tanh($2); }
      | COTH exp    { $$ = 1.0 / std::tanh($2); }
      | SECH exp    { $$ = 1.0 / std::cosh($2); }
      | CSCH exp    { $$ = 1.0 / std::sinh($2); }
      | ARSINH exp  { $$ = std::asinh($2); }
      | ARCOSH exp  { $$ = std::acosh($2); }
      | ARTANH exp  { $$ = std::atanh($2); }
      | ARCOTH exp  { $$ = std::atanh(1.0 / $2); }
      | ARSECH exp  { $$ = std::acosh(1.0 / $2); }
      | ARCSCH exp  { $$ = std::asinh(1.0 / $2); }
      | SGN exp     { $$ = sgn($2); }
      | exp FACTORIAL     { $$ = tgamma(Re($1) + 1); }
      | EXPONENTIAL exp { $$ = std::exp($2); }
      | LN exp     { $$ = std::log($2); }
      | LG exp     { $$ = std::log10($2); }
      | LB exp     { $$ = std::log($2) / std::log(2.0); }
      | LOG_BASE sub_exp exp { $$ = std::log($3) / std::log($2); }
      | BERNOULLI sub_exp    { $$ = calc_bernoulli(std::round(Re($2))); }
      | PI     { $$ = constexpr_double_pi; }
      | EULER     { $$ = constexpr_double_e; }
      | NATURAL_LOGARITHM_BASE { $$ = constexpr_double_e; }
      | PHI     { $$ = constexpr_double_phi; }
      | IMAGINARY_UNIT { $$ = C(0, 1); }
      | REAL_PART exp { $$ = Re($2); }
      | IMAGINARY_PART exp { $$ = Im($2); }
      | ARGUMENT_OF_COMPLEX_NUM exp { $$ = std::arg($2); }
      | exp EQUAL exp     { $$ = C($1 == $3 ? 1.0 : 0.0); }
      | exp NOT_EQUAL exp     { $$ = C($1 == $3 ? 0.0 : 1.0); }
      | exp APPROXIMATELY_EQUAL exp     { 
                                          double max_val = std::max(std::abs($1), std::abs($3)); 
                                          $$ = C(max_val == 0.0 || std::abs($1 - $3) / max_val <= 0.1 ? 1.0 : 0.0); 
                                        }
      | exp GREATER_THAN exp  { $$ = C(Re($1) > Re($3) ? 1.0 : 0.0); }
      | exp LESS_THAN exp  { $$ = C(Re($1) < Re($3) ? 1.0 : 0.0); }
      | exp MUCH_GREATER_THAN exp { $$ = C(Re($1) > Re($3) * 10.0 ? 1.0 : 0.0); }
      | exp MUCH_LESS_THAN exp { $$ = C(Re($1) * 10.0 < Re($3) ? 1.0 : 0.0); }
      | exp GREATER_THAN_OR_EQUAL exp { $$ = C(Re($1) >= Re($3) ? 1.0 : 0.0); }
      | exp LESS_THAN_OR_EQUAL exp { $$ = C(Re($1) <= Re($3) ? 1.0 : 0.0); }
      | exp LOGICAL_AND exp { $$ = C(Re($1) != 0.0 && Re($3) != 0.0 ? 1.0 : 0.0); }
      | exp LOGICAL_OR exp { $$ = C(Re($1) != 0.0 || Re($3) != 0.0 ? 1.0 : 0.0); }
      | exp LEFT_IMPLIES_RIGHT exp { $$ = C(Re($1) == 0.0 || Re($3) != 0.0 ? 1.0 : 0.0); }
      | exp RIGHT_IMPLIES_LEFT exp { $$ = C(Re($1) != 0.0 || Re($3) == 0.0 ? 1.0 : 0.0); }
      | exp EQUIVALENCE exp { $$ = C((Re($1) != 0.0) == (Re($3) != 0.0) ? 1.0 : 0.0); }
      
      | NOT_SIGN exp { $$ = C(Re($2) == 0.0 ? 1.0 : 0.0); }
      | MODULUS exp MODULUS  { $$ = std::abs($2); }
      | SQRT exp  { $$ = std::sqrt($2); }
      | LEFT_PARENTHESES exp RIGHT_PARENTHESES     { $$ = $2; }
      | LEFT_CEIL exp RIGHT_CEIL     { $$ = C(ceil(Re($2)), ceil(Im($2))); }
      | LEFT_FLOOR exp RIGHT_FLOOR   { $$ = C(floor(Re($2)), floor(Im($2))); }

      ;
	
sup_exp : SUPERSCRIPT_NUM { $$ = $1; }
        | SUPERSCRIPT_NATURAL_LOGARITHM_BASE { $$ = constexpr_double_e; }
        | sup_exp SUPERSCRIPT_PLUS sup_exp { $$ = $1 + $3; }
        | sup_exp SUPERSCRIPT_MINUS sup_exp { $$ = $1 - $3; }
        | SUPERSCRIPT_MINUS sup_exp %prec NEG { $$ = -$2; }
        | sup_exp SUPERSCRIPT_PLUS NUM { $$ = $1 + $3; }
        | sup_exp SUPERSCRIPT_MINUS NUM { $$ = $1 - $3; }
        | SUPERSCRIPT_MINUS NUM %prec NEG { $$ = -$2; }
        | NUM SUPERSCRIPT_PLUS sup_exp { $$ = $1 + $3; }
        | NUM SUPERSCRIPT_MINUS sup_exp { $$ = $1 - $3; }
        | SUPERSCRIPT_LEFT_PARENTHESES sup_exp SUPERSCRIPT_RIGHT_PARENTHESES { $$ = $2; }
        ;
        
sub_exp : SUBSCRIPT_NUM { $$ = $1; }
        | SUBSCRIPT_NATURAL_LOGARITHM_BASE { $$ = constexpr_double_e; }
        | sub_exp SUBSCRIPT_PLUS sub_exp { $$ = $1 + $3; }
        | sub_exp SUBSCRIPT_MINUS sub_exp { $$ = $1 - $3; }
        | SUBSCRIPT_MINUS sub_exp %prec NEG { $$ = -$2; }
        | sub_exp SUBSCRIPT_PLUS NUM { $$ = $1 + $3; }
        | sub_exp SUBSCRIPT_MINUS NUM { $$ = $1 - $3; }
        | SUBSCRIPT_MINUS NUM %prec NEG { $$ = -$2; }
        | NUM SUBSCRIPT_PLUS sub_exp { $$ = $1 + $3; }
        | NUM SUBSCRIPT_MINUS sub_exp { $$ = $1 - $3; }
        | SUBSCRIPT_LEFT_PARENTHESES sub_exp SUBSCRIPT_RIGHT_PARENTHESES { $$ = $2; }
        ;

%%

void yyerror(const char *s) 
{
    fprintf(stderr, "%s\n", s);
}

int main() 
{
    std::ios_base::sync_with_stdio (false);
    yyparse();    
    return 0;
}
