
%option noyywrap
%option yylineno


%{
  // C Comments work in header
  #include <iostream>
  #include <vector>
  #include <stack>
  #include <cstdlib>

  #include "parser.hpp"


  YYSTYPE yylval;  //Need the local variable
  yypstate* pstate = yypstate_new();  //Maintain the state in the parser

  #define PUSH_TOKEN(category) do {                           \
    int status = yypush_parse(pstate, category, &yylval);     \
    if(status != YYPUSH_MORE){                                \
      yypstate_delete(pstate);                                \
      return status;                                          \
    }                                                         \
  } while (0)

  std::stack<int> _indent_stack;
  bool have_error = false;


%}


%%

%{
  /*
   * These lines go at the top of the lexing function.  We only want to
   * initialize the indentation level stack once by pushing a 0 onto it (the
   * indentation stack should never be empty, except immediately after it is
   * created).
   */
  if (_indent_stack.empty()) {
    _indent_stack.push(0);
  }
%}

#[" "|""].*\n   {/* Ignore Comments */}
\/\/.*\n        {/* Ignore Comments */}
\/\*.*\*\/      {/* Ignore Comments */}


^[ \t]*\r?\n    { /* Skip blank lines */ }

^[ \t]*#.*\r?\n    { /* Skip whole-line comments. */ }

#.*$            { /* Skip comments on the same line as a statement. */ }

^[ \t]+       {
                /*
                 * Handle indentation as described in Python docs linked above.
                 * Note that this pattern treats leading spaces and leading tabs
                 * equivalently, which could cause some unexpected behavior
                 * (compared to normal Python indentation behavior) if they're
                 * combined in a single line.  For the purposes of this project,
                 * that's OK.
                 */
                if (_indent_stack.top() < yyleng) {
                  /*
                   * If the current indentation level is greater than the
                   * previous indentation level (stored at the top of the stack),
                   * then emit an INDENT and push the new indentation level onto
                   * the stack.
                   */
                  //std::cout << "INDENT" << std::endl;
                  yylval.category = INDENT; PUSH_TOKEN( INDENT );
                  _indent_stack.push(yyleng);
                } else {
                  /*
                   * If the current indentation level is less than or equal to
                   * the previous indentation level, pop indentation levels off
                   * the stack until the top is equal to the current indentation
                   * level.  Emit a DEDENT for each element popped from the stack.
                   */
                  while (!_indent_stack.empty() && _indent_stack.top() != yyleng) {
                    _indent_stack.pop();
                    //std::cout << "DEDENT" << std::endl;
                    yylval.category = DEDENT; PUSH_TOKEN( DEDENT );
                  }

                  /*
                   * If we popped everything off the stack, that means the
                   * current indentation level didn't match any on the stack,
                   * which is an indentation error.
                   */
                  if (_indent_stack.empty()) {
                    std::cerr << "Error: Incorrect indentation on line "
                      << yylineno << std::endl;
                    return 1;
                  }
                }
              }

^[^ \t\r\n]+  {
                /*
                 * If we find a line that's not indented, pop all indentation
                 * levels off the stack, and emit a DEDENT for each one.  Then,
                 * call REJECT, so the next rule matching this token is also
                 * applied.
                 */
                while (_indent_stack.top() != 0) {
                  _indent_stack.pop();
                  //std::cout << "DEDENT" << std::endl;
                  yylval.category = DEDENT; PUSH_TOKEN( DEDENT );
                }
                REJECT;
              }

\r?\n         {
                /*
                 * This rule will apply only to endlines that some after a
                 * statement.  Endlines assocuated with empty lines and
                 * comments are handled above.
                 */
                //std::cout << "NEWLINE" << std::endl;
                yylval.category = NEWLINE; PUSH_TOKEN( NEWLINE );
              }

<<EOF>>     { /* end of file */
                while (_indent_stack.top() != 0) {
                  _indent_stack.pop();
                  //std::cout << "DEDENT" << std::endl;
                  yylval.category = DEDENT; PUSH_TOKEN( DEDENT );
                }
              int status = yypush_parse(pstate, 0, NULL);
              yypstate_delete(pstate);  // Clean up garbage
              return status;
            }

[ \t]         { /* Ignore spaces that haven't been handled above. */ }


"and"     {//std::cout << "AND:          " << yytext << std::endl;
            yylval.category = AND; PUSH_TOKEN( AND );}

"break"   {//std::cout << "BREAK:        " << yytext << std::endl;
            yylval.category = BREAK; PUSH_TOKEN( BREAK );}

"def"     {//std::cout << "DEF:          " << yytext << std::endl;
            yylval.category = DEF; PUSH_TOKEN( DEF );}

"elif"    {//std::cout << "ELIF:         " << yytext << std::endl;
            yylval.category = ELIF; PUSH_TOKEN( ELIF );}

"else"    {//std::cout << "ELSE:         " << yytext << std::endl;
            yylval.category = ELSE; PUSH_TOKEN( ELSE );}

"for"     {//std::cout << "FOR:          " << yytext << std::endl;
            yylval.category = FOR; PUSH_TOKEN( FOR );}

"if"      {//std::cout << "IF:           " << yytext << std::endl;
            yylval.category = IF; PUSH_TOKEN( IF );}

"not"     {//std::cout << "NOT:          " << yytext << std::endl;
            yylval.category = NOT; PUSH_TOKEN( NOT );}

"or"      {//std::cout << "OR:           " << yytext << std::endl;
            yylval.category = OR; PUSH_TOKEN( OR );}

"return"  {//std::cout << "return:       " << yytext << std::endl;
            yylval.category = RETURN; PUSH_TOKEN( RETURN );}

"while"   {//std::cout << "WHILE:        " << yytext << std::endl;
            yylval.category = WHILE; PUSH_TOKEN( WHILE );}



"="       {//std::cout << "ASSIGN:       " << yytext << std::endl;
            yylval.category = ASSIGN; PUSH_TOKEN( ASSIGN );}

"+"       {//std::cout << "PLUS:         " << yytext << std::endl;
            yylval.category = PLUS; PUSH_TOKEN( PLUS) ;}

"-"       {//std::cout << "MINUS:        " << yytext << std::endl;
            yylval.category = MINUS; PUSH_TOKEN( MINUS );}

"*"       {//std::cout << "TIMES:        " << yytext << std::endl;
            yylval.category = TIMES; PUSH_TOKEN( TIMES );}

"/"       {//std::cout << "DIVIDEDBY:    " << yytext << std::endl;
            yylval.category = DIVIDEDBY; PUSH_TOKEN( DIVIDEDBY );}

"=="      {//std::cout << "EQ:           " << yytext << std::endl;
            yylval.category = EQ; PUSH_TOKEN( EQ );}

"!="      {//std::cout << "NEQ:          " << yytext << std::endl;
            yylval.category = NEQ; PUSH_TOKEN( NEQ );}

">"       {//std::cout << "GT:           " << yytext << std::endl;
            yylval.category = GT; PUSH_TOKEN( GT );}

">="      {//std::cout << "GTE:          " << yytext << std::endl;
            yylval.category = GTE; PUSH_TOKEN( GTE );}

"<"       {//std::cout << "LT:           " << yytext << std::endl;
            yylval.category = LT; PUSH_TOKEN( LT );}

"<="      {//std::cout << "LTE:          " << yytext << std::endl;
            yylval.category = LTE; PUSH_TOKEN( LTE );}



"("       {//std::cout << "LPAREN:       " << yytext << std::endl;
            yylval.category = LPAREN; PUSH_TOKEN( LPAREN );}

")"       {//std::cout << "RPAREN:       " << yytext << std::endl;
            yylval.category = RPAREN; PUSH_TOKEN( RPAREN );}

","       {//std::cout << "COMMA:        " << yytext << std::endl;
            yylval.category = COMMA; PUSH_TOKEN( COMMA );}

":"       {//std::cout << "COLON:        " << yytext << std::endl;
            yylval.category = COLON; PUSH_TOKEN( COLON );}



True    {//std::cout << "BOOLEAN:      " << 1 << std::endl;
          yylval.str = new std::string("1"); PUSH_TOKEN( BOOLEAN );}

False   {//std::cout << "BOOLEAN:      " << 0 << std::endl;
          yylval.str = new std::string("0"); PUSH_TOKEN( BOOLEAN );}



(-|"")[0-9]*"."[0-9][0-9]*  {//std::cout << "FLOAT:        " << atof(yytext) << std::endl;
                              yylval.str = new std::string(yytext, yyleng);
                              PUSH_TOKEN( FLOAT );
                            }

(-|"")[0-9]*                {//std::cout << "INTEGER:      " << atoi(yytext) << std::endl;
                              yylval.str = new std::string(yytext, yyleng);
                              PUSH_TOKEN( INTEGER );
                            }

[a-zA-Z0-9_]*               {//std::cout << "IDENTIFIER:   " << yytext << std::endl;
                              yylval.str = new std::string(yytext, yyleng);
                              PUSH_TOKEN( IDENTIFIER );
                            }


.     {//std::cout << "Invalid Character:" << yytext << std::endl;
        have_error = 1;
        yylval.category = yytext[0];
        PUSH_TOKEN( yytext[0] );
      }


%%

// Main
