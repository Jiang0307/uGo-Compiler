// Definition section
%{
    #include "compiler_hw_common.h" //Extern variables that communicate with lex
    // #define YYDEBUG 1
    // int yydebug = 1;

    extern int yylineno;
    extern int yylex();
    extern FILE *yyin;

    int yylex_destroy ();
    void yyerror (char const *s)
    {
        printf("error:%d: %s\n", yylineno, s);
    }

    extern int yylineno;
    extern int yylex();
    extern FILE *yyin;

    // Symbol table function - you can add new functions if needed.
    // parameters and return type can be changed
    struct symbol_node
    {
        int index;
        int addr;
        int lineno;
        char *func_sig;
        char *name;
        char *type;
        struct symbol_node *next_node;
    };

    struct symbol_table
    {
        int scope;
        struct symbol_table *next_table;
        struct symbol_node* symbol_node;
    };

    struct symbol_table* table_head = NULL; 
    struct symbol_node* lookup_node = NULL;

    char func_name[50];
    char func_parameter[50];
    char func_signature[50];
    char *print_type;

    static void create_symbol();
    static void insert_symbol(char* Symbolname, char* Symboltype, char* FuncSignature);
    static void lookup_symbol();
    static void dump_symbol();

    int scope_now = -1;
    int address_now = -1;
    bool symbol_find_or_not = false;
    bool insert_parameter = false;

    /* Global variables */
    bool HAS_ERROR = false;
%}

%error-verbose

/* Use variable or self-defined structure to represent */
/* nonterminal and token type */
/* - you can add new fields if needed. */

%union 
{
    int i_val;
    float f_val;
    char *s_val;
    char *type;
    char *operand;
    int is_literal
}

/* Token without return */
%token VAR NEWLINE
%token TRUE FALSE
%token INT FLOAT BOOL STRING
%token INC DEC GEQ LEQ EQL NEQ LOR LAND LSS GTR
%token ASSIGN ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN QUO_ASSIGN REM_ASSIGN
%token IF ELSE FOR FUNC PACKAGE RETURN SWITCH CASE DEFAULT
%token PRINT PRINTLN

/* Token with return, which need to sepcify type */
%token <i_val> INT_LIT
%token <f_val> FLOAT_LIT
%token <s_val> STRING_LIT
%token <s_val> IDENT

/* Nonterminal with return, which need to sepcify type */


/* Yacc will start at this nonterminal */
%start Program

/* Grammar section */
%%

Program
    : { create_symbol(); } GlobalStatementList { dump_symbol(); }
;

GlobalStatementList 
    : GlobalStatementList GlobalStatement
    | GlobalStatement
;

GlobalStatement
    : PackageStmt NEWLINE
    | FunctionDeclStmt
    | NEWLINE
;

PackageStmt
    : PACKAGE IDENT { printf("package: %s\n", $<s_val>2); }
;

FunctionDeclStmt
    : FUNC IDENT { strcpy(func_name, $<s_val>2); printf("func: %s\n", func_name); create_symbol(); } '(' ParameterList ')' ReturnType FuncBlock { dump_symbol(); }
;

ParameterList
    : IDENT ParaType 
    {
        printf("param ");
        if( $<type>2[0]=='i' && $<type>2[1]=='n' && $<type>2[2]=='t' && $<type>2[3]=='3' && $<type>2[4]=='2' )
            printf("%s, type: I\n", $<s_val>1);
        else if( $<type>2[0]=='f' && $<type>2[1]=='l' && $<type>2[2]=='o' && $<type>2[3]=='a' && $<type>2[4]=='t' && $<type>2[5]=='3' && $<type>2[6]=='2' )
            printf("%s, type: F\n", $<s_val>1);
        else if( $<type>2[0]=='b' && $<type>2[1]=='o' && $<type>2[2]=='o' && $<type>2[3]=='l' )
            printf("%s, type: B\n", $<s_val>1);
        else if( $<type>2[0]=='s' && $<type>2[1]=='t' && $<type>2[2]=='r' && $<type>2[3]=='i' && $<type>2[4]=='n' && $<type>2[5]=='g' )
            printf("%s, type: S\n", $<s_val>1);
        
        insert_parameter = true;
        insert_symbol($1, $<type>2, "-");
    }
    | ParameterList ',' IDENT ParaType 
    {
        printf("param ");
        if( $<type>4[0]=='i' && $<type>4[1]=='n' && $<type>4[2]=='t' && $<type>4[3]=='3' && $<type>4[4]=='2' )
            printf("%s, type: I\n", $<s_val>3);
        else if( $<type>4[0]=='f' && $<type>4[1]=='l' && $<type>4[2]=='o' && $<type>4[3]=='a' && $<type>4[4]=='t' && $<type>4[5]=='3' && $<type>4[6]=='2' )
            printf("%s, type: F\n", $<s_val>3);
        else if( $<type>4[0]=='b' && $<type>4[1]=='o' && $<type>4[2]=='o' && $<type>4[3]=='l' )
            printf("%s, type: B\n", $<s_val>3);
        else if( $<type>4[0]=='s' && $<type>4[1]=='t' && $<type>4[2]=='r' && $<type>4[3]=='i' && $<type>4[4]=='n' && $<type>4[5]=='g' )
            printf("%s, type: S\n", $<s_val>3);
        
        insert_parameter = true;
        insert_symbol($3, $<type>4, "-");
    }
    | 
;
ParaType
    : INT 
    {
        strcat(func_parameter, "I");
        $<type>$ = "int32";
    }
    | FLOAT 
    {
        strcat(func_parameter, "F");
        $<type>$ = "float32";
    }
    | STRING 
    {
        strcat(func_parameter, "S");
        $<type>$ = "string";
    }
    | BOOL 
    {
        strcat(func_parameter, "B");
        $<type>$ = "bool";
    }
;

ReturnType
    : INT 
    {
        printf("func_signature: (%s)I\n", func_parameter);

        memset(func_signature , 0 ,50);
        strcat(func_signature, "(");
        strcat(func_signature, func_parameter);
        strcat(func_signature, ")I");
        memset(func_parameter , 0 ,50);

        insert_parameter = false;
        insert_symbol(func_name, "func", func_signature);

    }
    | FLOAT 
    { 
        printf("func_signature: (%s)F\n", func_parameter);

        memset(func_signature , 0 ,50);
        strcat(func_signature, "(");
        strcat(func_signature, func_parameter);
        strcat(func_signature, ")F");
        memset(func_parameter , 0 ,50);

        insert_parameter = false;
        insert_symbol(func_name, "func", func_signature);

    }
    | STRING 
    {
        printf("func_signature: (%s)S\n", func_parameter);

        memset(func_signature , 0 ,50);
        strcat(func_signature, "(");
        strcat(func_signature, func_parameter);
        strcat(func_signature, ")S");
        memset(func_parameter , 0 ,50);

        insert_parameter = false;
        insert_symbol(func_name, "func", func_signature);

    }
    | BOOL 
    { 
        printf("func_signature: (%s)B\n", func_parameter);

        memset(func_signature , 0 ,50);
        strcat(func_signature, "(");
        strcat(func_signature, func_parameter);
        strcat(func_signature, ")B");
        memset(func_parameter , 0 ,50);

        insert_parameter = false;
        insert_symbol(func_name, "func", func_signature);

    }
    | 
    {
        printf("func_signature: (%s)V\n", func_parameter);

        memset(func_signature , 0 ,50);
        strcat(func_signature, "(");
        strcat(func_signature, func_parameter);
        strcat(func_signature, ")V");
        memset(func_parameter , 0 ,50);

        insert_parameter = false;
        insert_symbol(func_name, "func", func_signature);

    }
;

FuncBlock
    : '{' Statementlist '}'
;

Statementlist
    : Statementlist Statement
    | 
;


/* the section of Statement */
Statement
    : FunctionCall NEWLINE 
    | DeclarationStmt NEWLINE
    | SimpleStmt NEWLINE
    | PrintStmt NEWLINE
    | ReturnStmt NEWLINE
    | Block
    | IfStmt
    | ForStmt
    | SwitchStmt
    | CaseStmt
    | NEWLINE
;

FunctionCall
    : IDENT '(' ParaList ')'
    {
        lookup_symbol($<s_val>1);
        if(symbol_find_or_not)
            printf("call: %s%s\n" , lookup_node->name , lookup_node->func_sig);
    }
;
ParaList
    : Expression
    | ParaList ',' Expression
    |
;

DeclarationStmt
    : VAR IDENT DeclarationType
    {
        insert_parameter = false;
        insert_symbol($<s_val>2, $<type>3, "-");
    }
    | VAR IDENT DeclarationType ASSIGN Expression
    {
        insert_parameter = false;
        insert_symbol($<s_val>2, $<type>3, "-");
    }
;

DeclarationType
    : INT { $<type>$ = "int32"; }
    | FLOAT { $<type>$ = "float32"; }
    | STRING { $<type>$ = "string"; }
    | BOOL { $<type>$ = "bool"; }
;

SimpleStmt
    : AssignmentStmt
    | ExpressionStmt
    | InDecStmt
;

AssignmentStmt
    : Expression ASSIGN Expression
    {
        if(strcmp($<type>1, $<type>3) == 0)
        {   $<type>$ = $<type>1;
            printf("ASSIGN\n");
        }
        else
            printf("error:%d: invalid operation: ASSIGN (mismatched types %s and %s)\nASSIGN\n" , yylineno, $<type>1 , $<type>3);
    }
    | Expression ADD_ASSIGN Expression
    {
        if(strcmp($<type>1, $<type>3) == 0)
        {
            $<type>$ = $<type>1;
            printf("ADD\n");
        }
        else
            printf("error:%d: invalid operation: ADD (mismatched types %s and %s)\nADD\n" , yylineno, $<type>1 , $<type>3);
    }
    | Expression SUB_ASSIGN Expression
    {
        if(strcmp($<type>1, $<type>3) == 0)
        {
            $<type>$ = $<type>1;
            printf("SUB\n");
        }
        else
            printf("error:%d: invalid operation: SUB (mismatched types %s and %s)\nSUB\n" , yylineno, $<type>1 , $<type>3);
    }
    | Expression MUL_ASSIGN Expression
    {
        if(strcmp($<type>1, $<type>3) == 0)
        {
            $<type>$ = $<type>1;
            printf("MUL\n");
        }
        else
            printf("error:%d: invalid operation: MUL (mismatched types %s and %s)\nMUL\n" , yylineno, $<type>1 , $<type>3);
    }
    | Expression QUO_ASSIGN Expression
    {
        if(strcmp($<type>1, $<type>3) == 0)
        {
            $<type>$ = $<type>1;
            printf("QUO\n");
        }
        else
            printf("error:%d: invalid operation: QUO (mismatched types %s and %s)\nQUO\n" , yylineno, $<type>1 , $<type>3);
    }
    | Expression REM_ASSIGN Expression
    {
        if(strcmp($<type>1, $<type>3) == 0)
        {
            $<type>$ = $<type>1;
            printf("REM\n");
        }  
        else
            printf("error:%d: invalid operation: REM (mismatched types %s and %s)\nREM\n" , yylineno, $<type>1 , $<type>3);
    }
;


ExpressionStmt
    : Expression
;

InDecStmt
    : Expression INC { printf("INC\n"); }
    | Expression DEC { printf("DEC\n"); }
;

Block
    : '{' { create_symbol(); } Statementlist '}' { dump_symbol(); }
;

IfStmt
    : IF Condition Block
    | IF Condition Block ELSE IfStmt
    | IF Condition Block ELSE Block
;


ForStmt
    : FOR Condition Block
    | FOR SimpleStmt ';' Condition ';' SimpleStmt Block
;


SwitchStmt
    : SWITCH Expression Block
;

CaseStmt
    : CASE INT_LIT { printf("case %d\n", $<i_val>2); } ':' Block
    | DEFAULT { } ':' Block
;

PrintStmt
    : PRINT '(' Expression ')'
    {
        printf("PRINT ");
        if(print_type[0]=='i' && print_type[1]=='n' && print_type[2]=='t' && print_type[3]=='3' && print_type[4]=='2')
            printf("int32\n");
        else if(print_type[0]=='f' && print_type[1]=='l' && print_type[2]=='o' && print_type[3]=='a' && print_type[4]=='t' && print_type[5]=='3' && print_type[6]=='2')
            printf("float32\n");
        else if(print_type[0]=='b' && print_type[1]=='o' && print_type[2]=='o' && print_type[3]=='l')
            printf("bool\n");
        else if(print_type[0]=='s' && print_type[1]=='t' && print_type[2]=='r' && print_type[3]=='i' && print_type[4]=='n' && print_type[5]=='g')
            printf("string\n");
    }
    | PRINTLN '(' Expression ')'
    {
        printf("PRINTLN ");
        if(print_type[0]=='i' && print_type[1]=='n' && print_type[2]=='t' && print_type[3]=='3' && print_type[4]=='2')
            printf("int32\n");
        else if(print_type[0]=='f' && print_type[1]=='l' && print_type[2]=='o' && print_type[3]=='a' && print_type[4]=='t' && print_type[5]=='3' && print_type[6]=='2')
            printf("float32\n");
        else if(print_type[0]=='b' && print_type[1]=='o' && print_type[2]=='o' && print_type[3]=='l')
            printf("bool\n");
        else if(print_type[0]=='s' && print_type[1]=='t' && print_type[2]=='r' && print_type[3]=='i' && print_type[4]=='n' && print_type[5]=='g')
            printf("string\n");
    }
;


ReturnStmt
    : RETURN ReturnExpr
;

ReturnExpr
    : Expression
    {
        if($<type>1[0]=='i' && $<type>1[1]=='n' && $<type>1[2]=='t' && $<type>1[3]=='3' && $<type>1[4]=='2')
            printf("i");
        else if($<type>1[0]=='f' && $<type>1[1]=='l' && $<type>1[2]=='o' && $<type>1[3]=='a' && $<type>1[4]=='t' && $<type>1[5]=='3' && $<type>1[6]=='2')
            printf("f");
        else if($<type>1[0]=='b' && $<type>1[1]=='o' && $<type>1[2]=='o' && $<type>1[3]=='l')
            printf("b");
        else if($<type>1[0]=='s' && $<type>1[1]=='t' && $<type>1[2]=='r' && $<type>1[3]=='i' && $<type>1[4]=='n' && $<type>1[5]=='g')
            printf("s");
        printf("return\n");
    }
    | {printf("return\n");}
;




Condition
    :Expression
    {
        $<type>$ = $<type>1;
        if(strcmp($<type>1 , "bool") != 0 )
        {
            HAS_ERROR = true;
            yylineno++;
            printf("error:%d: non-bool (type %s) used as for condition\n" , yylineno , $<type>1);
            yylineno--;
        }
    }
;

/* the section of Expression */
Expression
    : LANDExpression 
    { 
        $<type>$ = $<type>1; 
    }
    | Expression LOR LANDExpression
    {
        if(strcmp($<type>1,"bool") != 0)
        {
            HAS_ERROR = true;
            printf("error:%d: invalid operation: (operator LOR not defined on %s)\n", yylineno, $<type>1);
        }
        if(strcmp($<type>3,"bool") != 0)
        {
            HAS_ERROR = true;
            printf("error:%d: invalid operation: (operator LOR not defined on %s)\n", yylineno, $<type>3);
        }
        printf("LOR\n");
        $<type>$ = "bool";
    }
    | FunctionCall
;
LANDExpression
    :CmpExpression { $<type>$ = $<type>1; }
    |LANDExpression LAND CmpExpression
    {
        if(strcmp($<type>1,"bool")!=0)
        {
            HAS_ERROR = true;
            printf("error:%d: invalid operation: (operator LAND not defined on %s)\n", yylineno, $<type>1);
        }
        if(strcmp($<type>3,"bool")!=0)
        {
            HAS_ERROR = true;
            printf("error:%d: invalid operation: (operator LAND not defined on %s)\n", yylineno, $<type>3);
        }
        printf("LAND\n");
        $<type>$ = "bool";
    }
;
CmpExpression
    :AddExpression { $<type>$ = $<type>1; }
    |CmpExpression cmp_op AddExpression
    {
        if(strcmp($<type>1, $<type>3) != 0)
        {   
            HAS_ERROR = true;
            yylineno++;
            printf("error:%d: invalid operation: %s (mismatched types %s and %s)\n", yylineno, $<operand>2, $<type>1, $<type>3);
            yylineno--;
        }
        printf("%s\n", $<operand>2);
        $<type>$ = "bool";
    }
;
AddExpression
    :MulExpression { $<type>$ = $<type>1; }
    |AddExpression add_op MulExpression
    {
        if(strcmp($<type>1, $<type>3) != 0)
        {
            HAS_ERROR = true;
            printf("error:%d: invalid operation: %s (mismatched types %s and %s)\n", yylineno, $<operand>2, $<s_val>1, $<s_val>3);
        }
        if(strcmp($<type>1 , "bool") == 0)
        {
            HAS_ERROR = true;
            printf("error:%d: invalid operation: (operator %s not defined on %s)\n", yylineno, $<operand>2, $<type>1);
        }
        if(strcmp($<type>3 , "bool") == 0)
        {
            HAS_ERROR = true;
            printf("error:%d: invalid operation: (operator %s not defined on %s)\n", yylineno, $<operand>2, $<type>3);
        }
        printf("%s\n", $<operand>2);
        $<type>$ = $<type>1;
    }
;
MulExpression
    :UnaryExpr { $<type>$=$<type>1; }
    |MulExpression mul_op UnaryExpr
    {
        if(strcmp($<operand>2, "REM") == 0 && strcmp($<type>1, "int32") != 0)
        {
            HAS_ERROR = true;
            yylineno++;
            printf("error:%d: invalid operation: (operator REM not defined on %s)\n", yylineno, $<type>1);
            yylineno--;
        }
        if(strcmp($<operand>2, "REM") == 0 && strcmp($<type>3, "int32") != 0)
        {
            HAS_ERROR = true;
            yylineno++;
            printf("error:%d: invalid operation: (operator REM not defined on %s)\n", yylineno, $<type>3);
            yylineno--;
        }
        if((strcmp($<operand>2 , "MUL") == 0 || strcmp($<operand>2 , "QUO") == 0) && strcmp($<type>1 , "bool") == 0 )
        {
            HAS_ERROR = true;
            printf("error:%d: invalid operation: (operator %s not defined on %s)\n" , yylineno, $<operand>2, $<type>1);
        }
        if((strcmp($<operand>2 , "MUL") == 0 || strcmp($<operand>2 , "QUO") == 0) && strcmp($<type>3 , "bool") == 0 )
        {
            HAS_ERROR = true;
            printf("error:%d: invalid operation: (operator %s not defined on %s)\n" , yylineno, $<operand>2, $<type>3);
        }
        if((strcmp($<operand>2 , "MUL") == 0 || strcmp($<operand>2 , "QUO") == 0) && strcmp($<type>1 , $<type>3) != 0)
        {
            HAS_ERROR = true;
            printf("error:%d: invalid operation: %s (mismatched types %s and %s)\n" , yylineno, $<operand>2, $<type>1, $<type>3);
        }
        printf("%s\n", $<operand>2);
        $<type>$=$<type>1;
    }
;

binary_op
    : LOR { $<operand>$ = "LOR"; }
    | LAND { $<operand>$ = "LAND"; }
    | cmp_op
    | add_op
    | mul_op
;

cmp_op
    : EQL { $<operand>$ = "EQL"; }
    | NEQ { $<operand>$ = "NEQ"; }
    | LSS { $<operand>$ = "LSS"; }
    | LEQ { $<operand>$ = "LEQ"; }
    | GTR { $<operand>$ = "GTR"; }
    | GEQ { $<operand>$ = "GEQ"; }
;
add_op
    : '+' { $<operand>$ = "ADD"; }
    | '-' { $<operand>$ = "SUB"; }
;
mul_op
    : '*' { $<operand>$ = "MUL"; }
    | '/' { $<operand>$ = "QUO"; }
    | '%' { $<operand>$ = "REM"; }
;

UnaryExpr
    : PrimaryExpr 
    { 
        $<type>$ = $<type>1; 
    }
    | '+' UnaryExpr
    {
        $<type>$ = $<type>2;
        printf("POS\n");
    }
    | '-' UnaryExpr
    {
        $<type>$ = $<type>2;
        printf("NEG\n");
    }
    | '!' UnaryExpr
    {
        $<type>$ = $<type>2;
        printf("NOT\n");
    }
;

PrimaryExpr
    : Operand { $<type>$ = $<type>1; }
    | ConversionExpr { $<type>$ = $<type>1; }
;

Operand
    : INT_LIT
    {
        printf("INT_LIT %d\n",$<i_val>1);
        print_type = "int32";
        $<type>$ = "int32";
    }
    | FLOAT_LIT
    {
        printf("FLOAT_LIT %f\n",$<f_val>1);
        print_type = "float32";
        $<type>$ = "float32";
    }
    | STRING_LIT
    {
        printf("STRING_LIT %s\n",$<s_val>1);
        print_type = "string";
        $<type>$ = "string";
    }
    | TRUE
    {
        printf("TRUE 1\n");
        print_type = "bool";
        $<type>$ = "bool";
    }
    | FALSE
    {
        printf("FALSE 0\n");
        print_type = "bool";
        $<type>$ = "bool";
    }
    | IDENT
    {
        lookup_symbol($<s_val>1);
        if(symbol_find_or_not)
        {
            $<type>$ = lookup_node->type;
            print_type = lookup_node->type;
            printf("IDENT (name=%s, address=%d)\n", $<s_val>1, lookup_node->addr);
        }
        else
        {
            $<type>$ = "ERROR";
            HAS_ERROR = true;
            printf("error:%d: undefined: %s\n", yylineno+1 , $<s_val>1);
        }
    }
    | '(' Expression ')'
    {
        $<type>$ = $<type>2;
    }
;

ConversionExpr
    : ConversionType '(' Expression ')'
    {
        $<type>$ = $<type>1;
        // i2f
        if( ($<type>3[0]=='i' && $<type>3[1]=='n' && $<type>3[2]=='t' && $<type>3[3]=='3' && $<type>3[4]=='2')  && ($<type>1[0]=='f' && $<type>1[1]=='l' && $<type>1[2]=='o' && $<type>1[3]=='a' && $<type>1[4]=='t' && $<type>1[5]=='3' && $<type>1[6]=='2') )
            printf("i2f\n");
        // f2i
        else if( ($<type>3[0]=='f' && $<type>3[1]=='l' && $<type>3[2]=='o' && $<type>3[3]=='a' && $<type>3[4]=='t' && $<type>3[5]=='3' && $<type>3[6]=='2')  && ($<type>1[0]=='i' && $<type>1[1]=='n' && $<type>1[2]=='t' && $<type>1[3]=='3' && $<type>1[4]=='2') )
            printf("f2i\n");
    }
;

ConversionType
    : INT { $<type>$ = "int32"; }
    | FLOAT { $<type>$ = "float32"; }
    | STRING { $<type>$ = "string"; }
    | BOOL { $<type>$ = "bool"; }
;

%%

/* C code section */
int main(int argc, char *argv[])
{
    if (argc == 2) 
        yyin = fopen(argv[1], "r");
    else 
        yyin = stdin;

    yylineno = 0;
    yyparse();

	printf("Total lines: %d\n", yylineno);
    fclose(yyin);
    return 0;
}

static void create_symbol()
{
    struct symbol_table* new_table = (struct symbol_table*)malloc(sizeof(struct symbol_table));
    new_table->scope = scope_now + 1;
    new_table->next_table = NULL;
    new_table->symbol_node = NULL;

    if(table_head == NULL)
        table_head = new_table;
    else
    {
        struct symbol_table* current_table = table_head;
        while(current_table->next_table != NULL)
            current_table = current_table->next_table;
        current_table->next_table = new_table;
    }
    scope_now++;
    printf("> Create symbol table (scope level %d)\n", scope_now);
}

static void insert_symbol(char* SymbolName, char* SymbolType, char* FuncSignature) 
{
    // malloc出記憶體位置
    struct symbol_node* new_symbol_node = malloc(sizeof(struct symbol_node));
    new_symbol_node->index = 0;
    new_symbol_node->addr = -1;
    new_symbol_node->lineno = yylineno;
    new_symbol_node->func_sig = strdup(FuncSignature);
    new_symbol_node->name = strdup(SymbolName);
    new_symbol_node->type = strdup(SymbolType);
    new_symbol_node->next_node = NULL;

    // 找到要insert的table
    struct symbol_table* table_to_insert;
    if( SymbolType[0]=='f' && SymbolType[1]=='u' && SymbolType[2]=='n' && SymbolType[3]=='c' ) // 遇到func要把symbol插入至倒數第二個table的最下面
    {
        struct symbol_table* previous = NULL;
        struct symbol_table* current = table_head;
        while(current->next_table != NULL)
        {
            previous = current;
            current = current->next_table;
        }
        table_to_insert = previous;
    }
    else
    {
        struct symbol_table* current = table_head;
        while(current->next_table != NULL)
            current = current->next_table;
        table_to_insert = current;
    }

    // 找table_to_insert有沒有已經宣告過的
    struct symbol_node* temp_node = table_to_insert->symbol_node;
    while(temp_node != NULL)
    {
        if(strcmp(temp_node->name , SymbolName) == 0)
            printf("error:%d: %s redeclared in this block. previous declaration at line %d\n" , yylineno , SymbolName, temp_node->lineno);
        temp_node = temp_node->next_node;
    }

    // 插入symbol至table_to_insert
    if(table_to_insert->symbol_node == NULL) // table_to_insert沒有symbol
    {
        if(SymbolType[0]=='f' && SymbolType[1]=='u' && SymbolType[2]=='n' && SymbolType[3]=='c')
        {
            new_symbol_node->addr     = -1;
            new_symbol_node->lineno   = yylineno + 1;
        }
        else
        {
            address_now++;
            new_symbol_node->addr     = address_now;
            new_symbol_node->lineno   = yylineno;
        }
        table_to_insert->symbol_node = new_symbol_node;
    }
    else // table_to_insert有symbol
    {
        struct symbol_node* current_symbol_node = table_to_insert->symbol_node;
        while(current_symbol_node->next_node != NULL)
            current_symbol_node = current_symbol_node->next_node;

        new_symbol_node->index = current_symbol_node->index + 1;
        current_symbol_node->next_node = new_symbol_node;

        if(FuncSignature[0] == '-')
        {
            address_now++;
            new_symbol_node->addr     = address_now;
            new_symbol_node->lineno   = yylineno;
        }
        else
        {
            new_symbol_node->addr     = -1;
            new_symbol_node->lineno   = yylineno + 1;
        }
    }

    if(insert_parameter)
        new_symbol_node->lineno++;
    
    printf("> Insert `%s` (addr: %d) to scope level %d\n", new_symbol_node->name, new_symbol_node->addr, table_to_insert->scope);
    fflush(stdout);

}

static void lookup_symbol(char* SymbolName) 
{
    symbol_find_or_not = false;
    struct symbol_table* current_table = table_head;
    while(current_table != NULL)
    {
        struct symbol_node* current_symbol_node = current_table->symbol_node;
        while(current_symbol_node != NULL)
        {
            if(strcmp(current_symbol_node->name, SymbolName) == 0)
            {
                symbol_find_or_not = true;
                lookup_node = current_symbol_node;
            }
            current_symbol_node = current_symbol_node->next_node;
        }
        current_table = current_table->next_table;
    }
}

static void dump_symbol() 
{
    printf("\n> Dump symbol table (scope level: %d)\n", scope_now);
    scope_now--;
    printf("%-10s%-10s%-10s%-10s%-10s%-10s\n", "Index", "Name", "Type", "Addr", "Lineno", "Func_sig");

    struct symbol_table* previous_table = NULL;
    struct symbol_table* current_table = table_head;
    // 找到最後一個table
    while(current_table->next_table != NULL)
    {
        previous_table = current_table;
        current_table = current_table->next_table;
    }
    // 把最後一個table印出來
    struct symbol_node* current_symbol_node = current_table->symbol_node;
    while(current_symbol_node != NULL)
    {
        printf("%-10d%-10s%-10s%-10d%-10d%-10s\n", current_symbol_node->index, current_symbol_node->name, current_symbol_node->type, current_symbol_node->addr, current_symbol_node->lineno, current_symbol_node->func_sig);
        current_symbol_node = current_symbol_node->next_node;
    }
    if(previous_table!= NULL)
        previous_table->next_table = NULL;
    printf("\n");
}