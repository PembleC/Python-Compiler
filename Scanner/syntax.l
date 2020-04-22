%{
  // C Comments work in header
  #include <iostream>
  int global_indent_cntr = 1;
  int global_cur_indent_cntr = 1;
  bool have_error = 0;

%}


%option yylineno
%option noyywrap


%%

#[" "|""].*\n   {/* Ignore Comments */}
\/\/.*\n        {/* Ignore Comments */}
\/\*.*\*\/      {/* Ignore Comments */}

and     {std::cout << "AND:          " << yytext << std::endl;}
break   {std::cout << "BREAK:        " << yytext << std::endl;}
def     {std::cout << "DEF:          " << yytext << std::endl;}
elif    {std::cout << "ELIF:         " << yytext << std::endl;}
else    {std::cout << "ELSE:         " << yytext << std::endl;}
for     {std::cout << "FOR:          " << yytext << std::endl;}
if      {std::cout << "IF:           " << yytext << std::endl;}
not     {std::cout << "NOT:          " << yytext << std::endl;}
or      {std::cout << "OR:           " << yytext << std::endl;}
return  {std::cout << "RETURN:       " << yytext << std::endl;}
while   {std::cout << "WHILE:        " << yytext << std::endl;}

\=      {std::cout << "ASSIGN:       " << yytext << std::endl;}
\+      {std::cout << "PLUS:         " << yytext << std::endl;}
\-      {std::cout << "MINUS:        " << yytext << std::endl;}
\*      {std::cout << "TIMES:        " << yytext << std::endl;}
\/      {std::cout << "DIVIDEDBY:    " << yytext << std::endl;}
\=\=    {std::cout << "EQ:           " << yytext << std::endl;}
\!\=    {std::cout << "NEQ:          " << yytext << std::endl;}
\>      {std::cout << "GT:           " << yytext << std::endl;}
\>\=    {std::cout << "GTE:          " << yytext << std::endl;}
\<      {std::cout << "LT:           " << yytext << std::endl;}
\<\=    {std::cout << "LTE:          " << yytext << std::endl;}

\(      {std::cout << "LPAREN:       " << yytext << std::endl;}
\)      {std::cout << "RPAREN:       " << yytext << std::endl;}
,       {std::cout << "COMMA:        " << yytext << std::endl;}
:       {std::cout << "COLON:        " << yytext << std::endl;}

True    {std::cout << "BOOLEAN:      " << 1 << std::endl;}
False   {std::cout << "BOOLEAN:      " << 0 << std::endl;}


(-|"")[0-9]*"."[0-9][0-9]*  {std::cout << "FLOAT:        " << atof(yytext) << std::endl;}

(-|"")[0-9]*                {std::cout << "INTEGER:      " << atoi(yytext) << std::endl;}

[a-zA-Z0-9_]*               {std::cout << "IDENTIFIER:   " << yytext << std::endl;}



[ ] {/* Ignore spaces*/}


[ \t\n]*  {/* space or tab or newline*/ global_cur_indent_cntr = yyleng;

            if(global_cur_indent_cntr == global_indent_cntr){
              std::cout << "NEWLINE" << std::endl;
            }

            if(global_cur_indent_cntr > global_indent_cntr){
              std::cout << "NEWLINE" << std::endl;
              int dif = (global_cur_indent_cntr - global_indent_cntr)/4;
              //std::cout << "indent dif = " << dif << std::endl;
              for(int i=0; i<dif; i++){
                std::cout << "INDENT" << std::endl;
              }
              global_indent_cntr = global_cur_indent_cntr;}

            if(global_cur_indent_cntr < global_indent_cntr){
              std::cout << "NEWLINE" << std::endl;
              int dif = (global_indent_cntr-global_cur_indent_cntr+1)/4;
              //std::cout << "dedent dif = " << dif << std::endl;
              for(int i=0; i<dif; i++){
                std::cout << "DEDENT" << std::endl;
              }
              global_indent_cntr = global_cur_indent_cntr;
            }
          }


<<EOF>> { /* end of file */
          if(have_error){std::cout << "Encountered Errors!" << std::endl; return 1;}
          else{yyterminate();}}

. {std::cout << "Invalid Character:" << yytext << std::endl; have_error = 1;}


%%

int main(){
  yylex();
 return 0;
}
