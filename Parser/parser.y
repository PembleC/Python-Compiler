%{
  // This is a Bison parser
  #include <iostream>
  #include <vector>
  #include <algorithm>
  #include <stdio.h>

  std::vector<std::string> statements;
  std::vector<std::string> variables;
  std::vector<std::string> var;

  void yyerror(const char* err);

  extern int yylineno;
  extern int yylex();

%}

/* %define api.value.type {std::string*}    This would declare all as strings*/

%define api.pure full
%define api.push-pull push
%define parse.error verbose

/* Like a struct but you can only assign value to one field */
%union{
  std::string* str;
  //float num;
  //bool bo;
  int category;
}

/* Terminals */
%token <str> IDENTIFIER
%token <str> INTEGER
%token <str> FLOAT
%token <str> BOOLEAN
%token <category> AND BREAK DEF ELIF ELSE FOR IF NOT OR RETURN WHILE
%token <category> ASSIGN PLUS MINUS TIMES DIVIDEDBY EQ NEQ GT GTE LT LTE
%token <category> LPAREN RPAREN COMMA COLON
%token <category> NEWLINE
%token <category> INDENT DEDENT


/* Left most opperations */
%left PLUS MINUS
%left TIMES DIVIDEDBY
/* Higher precedence the lower */


/* Non-Terminals */
%type <str> expr stmt cond comp


/* Goal Symbol */
%start prgrm


%%

/* Get string the c++ translation of python code */
prgrm
  : prgrm stmt  { statements.push_back(*$2); }
  | prgrm cond  { statements.push_back(*$2); }
  | stmt        { statements.push_back(*$1); }
  ;

stmt
  : IDENTIFIER ASSIGN expr NEWLINE {
        std::string assigned = std::string("double " + *$1 + ";");
        if(std::find(variables.begin(), variables.end(), assigned) != variables.end()){
          // nothing if the variable has already been declared
          } else { variables.push_back(assigned); var.push_back(*$1);}
        $$ = new std::string(*$1 + " = " + *$3 + ";");
        }
  | INDENT  {$$ = new std::string("{");}
  | DEDENT  {$$ = new std::string("}");}
  ;

cond
  : IF comp COLON NEWLINE INDENT    {$$ = new std::string("if(" + *$2 + ")" + "{");}
  | ELIF comp COLON NEWLINE INDENT  {$$ = new std::string("else if(" + *$2 + ")" + "{");}
  | ELSE COLON NEWLINE INDENT       {$$ = new std::string("else {");}
  | WHILE comp COLON NEWLINE INDENT {$$ = new std::string("while(" + *$2 + ")" + "{");}
  | BREAK NEWLINE                   {$$ = new std::string("break;");}
  ;

comp
  : expr EQ expr          { $$ = new std::string(*$1 + "==" + *$3); }
  | expr NEQ expr         { $$ = new std::string(*$1 + "!=" + *$3); }
  | expr GT expr          { $$ = new std::string(*$1 + ">" + *$3);  }
  | expr GTE expr         { $$ = new std::string(*$1 + ">=" + *$3); }
  | expr LT expr          { $$ = new std::string(*$1 + "<" + *$3);  }
  | expr LTE expr         { $$ = new std::string(*$1 + "<=" + *$3); }
  | expr AND expr         { $$ = new std::string(*$1 + "&&" + *$3); }
  | expr OR expr          { $$ = new std::string(*$1 + "||" + *$3); }
  | NOT expr              { $$ = new std::string("!" + *$2); }
  | expr                  { $$ = $1; }
  ;

expr
  : LPAREN expr RPAREN    { $$ = new std::string("(" + *$2 + ")");  }
  | expr PLUS expr        { $$ = new std::string(*$1 + "+" + *$3);  }
  | expr MINUS expr       { $$ = new std::string(*$1 + "-" + *$3);  }
  | expr TIMES expr       { $$ = new std::string(*$1 + "*" + *$3);  }
  | expr DIVIDEDBY expr   { $$ = new std::string(*$1 + "/" + *$3);  }
  | FLOAT                 { $$ = $1; }
  | INTEGER               { $$ = $1; }
  | BOOLEAN               { $$ = $1; }
  | IDENTIFIER            { $$ = new std::string(*$1); delete $1;}
  ;


%%

void yyerror(const char* err){
  std::cerr << "Error: " << err << " on line " << yylineno << std::endl;
}



int main(){

  if (!yylex()) {

    std::cout << "#include <iostream>" << std::endl;
    std::cout << "int main() {" << std::endl << std::endl;

    for (int i=0; i<variables.size(); i++){
      std::cout << variables.at(i) << std::endl;
    }

    std::cout << std::endl;

    for (int i=0; i<statements.size(); i++){
      std::cout << statements.at(i) << std::endl;
    }

    std::cout << std::endl;

    for (int i=0; i<var.size(); i++){
      std::cout << "std::cout << \"" << var.at(i) << ": \" << " << var.at(i) << " << std::endl;" << std::endl;
    }

    std::cout << std::endl << "}" << std::endl;

    return 0;
  }else{
    return 1;
  }

}
