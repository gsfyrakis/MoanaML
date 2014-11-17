%token <string> STRING
%token <string> VAR
%token LEFT_BRACE
%token RIGHT_BRACE
%token COMMA

%token MAP
%token START
%token END

%token EOF

%start <Config.tuple option> parse_tuple
%% 


parse_tuple:
  | t = tpl { Some (t) }
  | EOF       { None }
  ;
	
tpl:  LEFT_BRACE; s = elem; COMMA; p = elem; COMMA; o = elem; COMMA; c  = elem; RIGHT_BRACE 
{{Config.subj = s; Config.pred = p; Config.obj = o; Config.ctxt = c; Config.time_stp = None; Config.sign = None}}  ;

elem:
 | v = VAR {Variable v}
 | c = STRING {Constant c} 
