// Copyright 2019 Fred Gotwald.  All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

lexer grammar IEEE1800_2017Lexer;

channels {
    DEFAULT_CHANNEL,
    HIDDEN_CHANNEL,
    WHITESPACE,
    COMMENTS,
    INCLUDE,
    BACK_TICK,
    SYNOPSYS,
    IGNORED,
    IF_SKIP,
    SKIP_TRASH,
    VARIABLE_RUN,
    LINE_CHANNEL
}

@header {
package com.veriktig.scandium.ieee1800_2017.grammar;

import java.util.LinkedList;
import java.util.Queue;
}

@members {
public boolean reportSynopsys;

private boolean startLine;
}

DPI_C	 : '"DPI-C"' ;
DPI	 : '"DPI"' ;

//StringLiteral : DQ .*? DQ ;
StringLiteral: DQ (Esc|.)*? DQ ;
fragment Esc : '\\"' | '\\\\' ; // 2-char sequences \" and \\

// Implicit tokens from parser
BANG    : '!' ;
BANGE    : '!=' ;
CARET_NOT	 : '^~' ;
CARET_EQUALS	 : '^=' ;
CARET	 : '^' ;
NOT_CARET	 : '~^' ;
NOT_OR	 : '~|' ;
NOT_AND	 : '~&' ;
NOT	 : '~' ;
LS3E	 : '<<<=' ;
LS3	 : '<<<' ;
LS2E	 : '<<=' ;
LS2	 : '<<' ;
LE  : '<=' ;
LT  : '<' ;
LMG	 : '<->' ;
E3	 : '===' ;
E2Q	 : '==?' ;
EQUALS_GT	 : '=>' ;
E2  : '==' ;
ASSIGN	 : '=' ;
RS3E	 : '>>>=' ;
RS3	 : '>>>' ;
RS2E	 : '>>=' ;
RS2	 : '>>' ;
OEG	 : '|=>' ;
OR_EQUALS	 : '|=' ;
ODGG	 : '|->>' ;
ODG	 : '|->' ;
OR2 : '||' ;
OR	 : '|' ;
MINUS_COLON : '-:' ;
MINUS_EQUALS	 : '-=' ;
MINUS_GT	 : '->' ;
MINUS2	 : '--' ;
MINUS	 : '-' ;
COMMA	 : ',' ;
SEMICOLON	 : ';' ;
COLON_EQUALS	 : ':=' ;
COLON2	 : '::' ;
CS : '/*' ;
CE : '*/' ;
COLON_SLASH	 : ':/' ;
COLON	 : ':' ;
BEE	 : '!==' ;
BEQ	 : '!=?' ;
QUESTION_MARK	 : '?' ;
SLASH_EQUALS	 : '/=' ;
SLASH	 : '/' ;
DOT_STAR	 : '.*' ;
DOT	 : '.' ;
PSTARP	 : '(*)' ;
PSTAR	 : '(*' ;
RSR	 : '[*]' ;
LB_EQUALS	 : '[=' ;
LB_STAR	 : '[*' ;
RPR	 : '[+]' ;
RDG	 : '[–>' ;
LB	 : '[' ;
RB	 : ']' ;
LS	 : '{' ;
RS	 : '}' ;
AT2	 : '@@' ;
AT_STAR	 : '@*' ;
AT	 : '@' ;
STAR_EQUALS	 : '*=' ;
STAR_GT	 : '*>' ;
SDCS	 : '*::*' ;
STARP	 : '*)' ;
STAR2	 : '**' ;
STAR    : '*' ;
TICK_S	 : '\'{' ;
TICK	 : '\'' ;
AND3	 : '&&&' ;
AND_EQUALS	 : '&=' ;
AND2	 : '&&' ;
AND	 : '&' ;
PEP	 : '#=#' ;
PMP	 : '#-#' ;
SHARP2	 : '##' ;
SHARP	 : '#' ;
MODULO_EQUALS	 : '%=' ;
MODULO	 : '%' ;
PLUS_EQUALS	 : '+=' ;
PLUS_COLON	 : '+:' ;
PLUS2	 : '++' ;
PLUS	 : '+' ;
US2	 : '––' ;
US	 : '–' ;
STEP1	 : '1step' ;
ACCEPT_ON	 : 'accept_on' ;
ALIAS	 : 'alias' ;
ALWAYS_LATCH	 : 'always_latch' ;
ALWAYS_COMB	 : 'always_comb' ;
ALWAYS_FF	 : 'always_ff' ;
ALWAYS	 : 'always' ;
LAND	 : 'and' ;
ASSERT	 : 'assert' ;
LASSIGN	 : 'assign' ;
ASSUME	 : 'assume' ;
AUTOMATIC	 : 'automatic' ;
BEFORE	 : 'before' ;
BEGIN	 : 'begin' ;
BIND	 : 'bind' ;
BINSOF	 : 'binsof' ;
BINS	 : 'bins' ;
BIT	 : 'bit' ;
BREAK	 : 'break' ;
BUFIF0	 : 'bufif0' ;
BUFIF1	 : 'bufif1' ;
BUF	 : 'buf' ;
BYTE	 : 'byte' ;
CASEX	 : 'casex' ;
CASEZ	 : 'casez' ;
CASE	 : 'case' ;
CELL	 : 'cell' ;
CHANDLE	 : 'chandle' ;
CHECKER	 : 'checker' ;
CLASS	 : 'class' ;
CLOCKING	 : 'clocking' ;
CMOS	 : 'cmos' ;
CONFIG	 : 'config' ;
CONSTRAINT	 : 'constraint' ;
CONST	 : 'const' ;
CONTEXT	 : 'context' ;
CONTINUE	 : 'continue' ;
COVERGROUP	 : 'covergroup' ;
COVERPOINT	 : 'coverpoint' ;
COVER	 : 'cover' ;
CROSS	 : 'cross' ;
DEASSIGN	 : 'deassign' ;
DEFPARAM	 : 'defparam' ;
LDEFAULT : 'default' ;
DESIGN	 : 'design' ;
DISABLE	 : 'disable' ;
DIST	 : 'dist' ;
DO	 : 'do' ;
DQ  : '"' ;
EDGE	 : 'edge' ;
ELSE     : 'else' ;
ENDPRIMITIVE : 'endprimitive' ;
ENDINTERFACE : 'endinterface' ;
ENDSEQUENCE	 : 'endsequence' ;
ENDPROPERTY	 : 'endproperty' ;
ENDGENERATE	 : 'endgenerate' ;
ENDFUNCTION	 : 'endfunction' ;
ENDCLOCKING	 : 'endclocking' ;
ENDSPECIFY	 : 'endspecify' ;
ENDPROGRAM	 : 'endprogram' ;
ENDPACKAGE	 : 'endpackage' ;
ENDCHECKER	 : 'endchecker' ;
ENDMODULE	 : 'endmodule' ;
ENDCONFIG	 : 'endconfig' ;
ENDCLASS	 : 'endclass' ;
ENDGROUP	 : 'endgroup' ;
ENDTABLE	 : 'endtable' ;
ENDCASE 	 : 'endcase' ;
ENDTASK 	 : 'endtask' ;
END	        : 'end' ;
ENUM	 : 'enum' ;
EVENTUALLY  : 'eventually' ;
EVENT	    : 'event' ;
EXPECT	 : 'expect' ;
EXPORT	 : 'export' ;
EXTENDS	 : 'extends' ;
EXTERN	 : 'extern' ;
FINAL	 : 'final' ;
FIRST_MATCH	 : 'first_match' ;
FORCE	 : 'force' ;
FOREACH	 : 'foreach' ;
FOREVER	 : 'forever' ;
FORKJOIN	 : 'forkjoin' ;
FORK	 : 'fork' ;
FOR	 : 'for' ;
FUNCTION_SAMPLE	 : 'function sample' ;
FUNCTION	 : 'function' ;
GENERATE	 : 'generate' ;
GENVAR	 : 'genvar' ;
GLOBAL	 : 'global' ;
HIGHZ0	 : 'highz0' ;
HIGHZ1	 : 'highz1' ;
IFF	 : 'iff' ;
IF	 : 'if' ;
IFNONE	 : 'ifnone' ;
IGNORE_BINS	 : 'ignore_bins' ;
ILLEGAL_BINS	 : 'illegal_bins' ;
IMPLEMENTS	 : 'implements' ;
IMPLIES	 : 'implies' ;
IMPORT	 : 'import' ;
INITIAL	 : 'initial' ;
INOUT	 : 'inout' ;
INPUT	 : 'input' ;
INSIDE	 : 'inside' ;
INSTANCE	 : 'instance' ;
INTERCONNECT	 : 'interconnect' ;
INTERFACE	 : 'interface' ;
INTERSECT	 : 'intersect' ;
INTEGER	 : 'integer' ;
INT	 : 'int' ;
JOIN_NONE	 : 'join_none' ;
JOIN_ANY	 : 'join_any' ;
JOIN	 : 'join' ;
LARGE	 : 'large' ;
LET	 : 'let' ;
LIBLIST	 : 'liblist' ;
LOCALPARAM	 : 'localparam' ;
LOCAL	 : 'local' ;
LOGIC	 : 'logic' ;
LONGINT	 : 'longint' ;
MACROMODULE	 : 'macromodule' ;
MATCHES	 : 'matches' ;
MEDIUM	 : 'medium' ;
MODPORT	 : 'modport' ;
MODULE	 : 'module' ;
NAND	 : 'nand' ;
NEGEDGE	 : 'negedge' ;
NETTYPE	 : 'nettype' ;
NEW	 : 'new' ;
NEXTTIME	 : 'nexttime' ;
NMOS	 : 'nmos' ;
NOR	 : 'nor' ;
NOSHOWCANCELLED	 : 'noshowcancelled' ;
NOTIF0	 : 'notif0' ;
NOTIF1	 : 'notif1' ;
LNOT	 : 'not' ;
NULL	 : 'null' ;
OPTION	 : 'option.' ;
LOR	 : 'or' ;
OUTPUT	 : 'output' ;
PACKAGE	 : 'package' ;
PACKED	 : 'packed' ;
PARAMETER	 : 'parameter' ;
PATHPULSE	 : 'PATHPULSE$' ;
PMOS	 : 'pmos' ;
POSEDGE	 : 'posedge' ;
PRIMITIVE	 : 'primitive' ;
PRIORITY	 : 'priority' ;
PROGRAM	 : 'program' ;
PROPERTY	 : 'property' ;
PROTECTED	 : 'protected' ;
PULLDOWN	 : 'pulldown' ;
PULLUP	 : 'pullup' ;
PULL0	 : 'pull0' ;
PULL1	 : 'pull1' ;
PULSESTYLE_ONDETECT	 : 'pulsestyle_ondetect' ;
PULSESTYLE_ONEVENT	 : 'pulsestyle_onevent' ;
PURE	 : 'pure' ;
RANDSEQUENCE	 : 'randsequence' ;
RANDOMIZE	 : 'randomize' ;
RANDCASE	 : 'randcase' ;
RANDC	 : 'randc' ;
RAND	 : 'rand' ;
RCMOS	 : 'rcmos' ;
REAL	 : 'real' ;
REALTIME	 : 'realtime' ;
REF	 : 'ref' ;
REG	 : 'reg' ;
REJECT_ON	 : 'reject_on' ;
RELEASE	 : 'release' ;
REPEAT	 : 'repeat' ;
RESTRICT	 : 'restrict' ;
RETURN	 : 'return' ;
RNMOS	 : 'rnmos' ;
LP       : '(' ;
RP      : ')' ;
RPMOS	 : 'rpmos' ;
RTRAN	 : 'rtran' ;
RTRANIF0	 : 'rtranif0' ;
RTRANIF1	 : 'rtranif1' ;
S_UNTIL_WITH	 : 's_until_with' ;
S_EVENTUALLY	 : 's_eventually' ;
S_NEXTTIME	 : 's_nexttime' ;
S_ALWAYS	 : 's_always' ;
S_UNTIL	 : 's_until' ;
SCALARED	 : 'scalared' ;
SEQUENCE	 : 'sequence' ;
SHORTREAL	 : 'shortreal' ;
SHORTINT	 : 'shortint' ;
SHOWCANCELLED	 : 'showcancelled' ;
SIGNED	 : 'signed' ;
SMALL	 : 'small' ;
SOFT	 : 'soft' ;
SOLVE	 : 'solve' ;
SPECIFY	 : 'specify' ;
SPECPARAM	 : 'specparam' ;
STATIC	 : 'static' ;
STD 	 : 'std' ;
STRING	 : 'string' ;
STRONG0	 : 'strong0' ;
STRONG1	 : 'strong1' ;
STRONG	 : 'strong' ;
STRUCT	 : 'struct' ;
SUPER	 : 'super' ;
SUPPLY0	 : 'supply0' ;
SUPPLY1	 : 'supply1' ;
SYNC_ACCEPT_ON	 : 'sync_accept_on' ;
SYNC_REJECT_ON	 : 'sync_reject_on' ;
TABLE	 : 'table' ;
TAGGED	 : 'tagged' ;
TASK	 : 'task' ;
THIS	 : 'this' ;
THROUGHOUT	 : 'throughout' ;
TIMEPRECISION	 : 'timeprecision' ;
TIMEUNIT	 : 'timeunit' ;
TIME	 : 'time' ;
TRANIF0	 : 'tranif0' ;
TRANIF1	 : 'tranif1' ;
TRAN	 : 'tran' ;
TRIREG	 : 'trireg' ;
TRIAND	 : 'triand' ;
TRI0	 : 'tri0' ;
TRI1	 : 'tri1' ;
TRIOR	 : 'trior' ;
TRI	 : 'tri' ;
TYPE_OPTION	 : 'type_option.' ;
TYPEDEF	 : 'typedef' ;
TYPE	 : 'type' ;
UNION	 : 'union' ;
UNSIGNED	 : 'unsigned' ;
UNTIL_WITH	 : 'until_with' ;
UNTIL	 : 'until' ;
UNTYPED	 : 'untyped' ;
USE	 : 'use' ;
UWIRE	 : 'uwire' ;
VAR	 : 'var' ;
VECTORED	 : 'vectored' ;
VIRTUAL	 : 'virtual' ;
VOID	 : 'void' ;
WAIT_ORDER	 : 'wait_order' ;
WAIT	 : 'wait' ;
WAND	 : 'wand' ;
WEAK0	 : 'weak0' ;
WEAK1	 : 'weak1' ;
WEAK	 : 'weak' ;
WHILE	 : 'while' ;
WILDCARD	 : 'wildcard' ;
WIRE	 : 'wire' ;
WITHIN	 : 'within' ;
WITH	 : 'with' ;
WOR	 : 'wor' ;
XNOR	 : 'xnor' ;
XOR	 : 'xor' ;
GE  : '>=' ;
GT  : '>' ;

FULLSKEW	 : '$fullskew' ;
HOLD	 : '$hold' ;
NOCHANGE	 : '$nochange' ;
PERIOD	 : '$period' ;
RECOVERY	 : '$recovery' ;
RECREM	 : '$recrem' ;
REMOVAL	 : '$removal' ;
ROOT	 : '$root' ;
SETUPHOLD	 : '$setuphold' ;
SETUP	 : '$setup' ;
SKEW	 : '$skew' ;
TIMESKEW	 : '$timeskew' ;
UNIT	 : '$unit' ;
WIDTH	 : '$width' ;

// 18.13 Random number system functions and methods
SF_URANDOM_RANGE : '$urandom_range' ;
SF_URANDOM       : '$urandom' ;

// Simulation control tasks (20.2)
SF_FINISH   : '$finish' ;
SF_STOP     : '$stop' ;
SF_EXIT     : '$exit' ;
// Simulation time functions (20.3)
SF_REALTIME     : '$realtime' ;
SF_STIME        : '$stime' ;
SF_TIME         : '$time' ;
// Timescale tasks (20.4)
SF_PRINTTIMESCALE   : '$printtimescale' ;
SF_TIMEFORMAT       : '$timeformat' ;
// Conversion functions (20.5)
SF_SHORTREALTOBITS  : '$shortrealtobits' ;
SF_BITSTOSHORTREAL  : '$bitstoshortreal' ;
SF_REALTOBITS       : '$realtobits' ;
SF_BITSTOREAL       : '$bitstoreal' ;
SF_UNSIGNED         : '$unsigned' ;
SF_SIGNED           : '$signed' ;
SF_RTOI             : '$rtoi' ;
SF_ITOR             : '$itor' ;
SF_CAST             : '$cast' ;
// Data query functions (20.6)
SF_ISUNBOUNDED  : '$isunbounded' ;
SF_TYPENAME     : '$typename' ;
SF_BITS         : '$bits' ;
// Array query functions (20.7)
SF_UNPACKED_DIMENSIONS  : '$unpacked_dimensions' ;
SF_DIMENSIONS           : '$dimensions' ;
SF_INCREMENT            : '$increment' ;
SF_RIGHT                : '$right' ;
SF_LEFT                 : '$left' ;
SF_SIZE                 : '$size' ;
SF_HIGH                 : '$high' ;
SF_LOW                  : '$low' ;
// Math functions
SF_LOG10    : '$log10' ;
SF_HYPOT    : '$hypot' ;
SF_FLOOR    : '$floor' ;
SF_CLOG2    : '$clog2' ;
SF_ASINH    : '$asinh' ;
SF_ACOSH    : '$acosh' ;
SF_ATANH    : '$atanh' ;
SF_ATAN2    : '$atan2' ;
SF_SQRT     : '$sqrt' ;
SF_CEIL     : '$ceil' ;
SF_SINH     : '$sinh' ;
SF_COSH     : '$cosh' ;
SF_TANH     : '$tanh' ;
SF_ATAN     : '$atan' ;
SF_ASIN     : '$asin' ;
SF_ACOS     : '$acos' ;
SF_TAN      : '$tan' ;
SF_POW      : '$pow' ;
SF_SIN      : '$sin' ;
SF_COS      : '$cos' ;
SF_EXP      : '$exp' ;
SF_LN       : '$ln' ;
// Bit vector system functions (20.9)
SF_ISUNKNOWN    : '$isunknown' ;
SF_COUNTONES    : '$countones' ;
SF_COUNTBITS    : '$countbits' ;
SF_ONEHOT0      : '$onehot0' ;
SF_ONEHOT       : '$onehot' ;
// Severity tasks (20.10)
SF_WARNING  : '$warning' ;
SF_FATAL    : '$fatal' ;
SF_ERROR    : '$error' ;
SF_INFO     : '$info' ;
// Elaboration system tasks (20.11) In Parser
// Assertion control tasks (20.12)
SF_ASSERTNONVACUOUSON : '$assertnonvacuouson' ;
SF_ASSERTVACUOUSOFF : '$assertvacuousoff' ;
SF_ASSERTKILL       : '$assertkill' ;
SF_ASSERTPASSON     : '$assertpasson' ;
SF_ASSERTFAILON     : '$assertfailon' ;
SF_ASSERTCONTROL    : '$assertcontrol' ;
SF_ASSERTPASSOFF    : '$assertpassoff' ;
SF_ASSERTFAILOFF    : '$assertfailoff' ;
SF_ASSERTOFF        : '$assertoff' ;
SF_ASSERTON        : '$asserton' ;
// Sampled value system functions (20.13)
SF_CHANGING_GCLK    : '$changing_gclk' ;
SF_FALLING_GCLK     : '$falling_gclk' ;
SF_CHANGED_GCLK     : '$changed_gclk' ;
SF_STEADY_GCLK      : '$steady_gclk' ;
SF_STABLE_GCLK      : '$stable_gclk' ;
SF_RISING_GCLK      : '$rising_gclk' ;
SF_FUTURE_GCLK      : '$future_gclk' ;
SF_PAST_GCLK        : '$past_gclk' ;
SF_ROSE_GCLK        : '$rose_gclk' ;
SF_FELL_GCLK        : '$fell_gclk' ;
SF_SAMPLED          : '$sampled' ;
SF_CHANGED          : '$changed' ;
SF_STABLE           : '$stable' ;
SF_ROSE             : '$rose' ;
SF_PAST             : '$past' ;
SF_FELL             : '$fell' ;
// Coverage control functions (20.14)
SF_SET_COVERAGE_DB_NAME : '$set_coverage_db_name' ;
SF_LOAD_COVERAGE_DB     : '$load_coverage_db' ;
SF_GET_COVERAGE         : '$get_coverage' ;
SF_COVERAGE_GET_MAX     : '$coverage_get_max' ;
SF_COVERAGE_CONTROL     : '$coverage_control' ;
SF_COVERAGE_MERGE       : '$coverage_merge' ;
SF_COVERAGE_SAVE        : '$coverage_save' ;
SF_COVERAGE_GET         : '$coverage_get' ;
// Probabilistic distribution functions (20.15)
SF_RANDOM           : '$random' ;
SF_DIST_EXPONENTIAL : '$dist_exponential' ;
SF_DIST_CHI_SQUARE  : '$dist_chi_square' ;
SF_DIST_UNIFORM     : '$dist_uniform' ;
SF_DIST_POISSON     : '$dist_poisson' ;
SF_DIST_NORMAL      : '$dist_normal' ;
SF_DIST_ERLANG      : '$dist_erlang' ;
SF_DIST_T           : '$dist_t' ;
// Stochastic analysis tasks and functions (20.16)
SF_Q_INITIALIZE : '$q_initialize' ;
SF_Q_REMOVE : '$q_remove' ;
SF_Q_FULL : '$q_full' ;
SF_Q_EXAM : '$q_exam' ;
SF_Q_ADD : '$q_add' ;
// PLA modeling tasks (20.17)
SF_ASYNC_NAND_PLANE : '$async$nand$plane' ;
SF_ASYNC_NAND_ARRAY : '$async$nand$array' ;
SF_ASYNC_NOR_PLANE  : '$async$nor$plane' ;
SF_ASYNC_NOR_ARRAY  : '$async$nor$array' ;
SF_ASYNC_AND_PLANE  : '$async$and$plane' ;
SF_ASYNC_AND_ARRAY  : '$async$and$array' ;
SF_SYNC_NAND_PLANE  : '$sync$nand$plane' ;
SF_SYNC_NAND_ARRAY  : '$sync$nand$array' ;
SF_SYNC_NOR_PLANE   : '$sync$nor$plane' ;
SF_SYNC_NOR_ARRAY   : '$sync$nor$array' ;
SF_SYNC_AND_PLANE   : '$sync$and$plane' ;
SF_SYNC_AND_ARRAY   : '$sync$and$array' ;
SF_ASYNC_OR_PLANE   : '$async$or$plane' ;
SF_ASYNC_OR_ARRAY   : '$async$or$array' ;
SF_SYNC_OR_PLANE    : '$sync$or$plane' ;
SF_SYNC_OR_ARRAY    : '$sync$or$array' ;
// Miscellaneous tasks and functions (20.18)
SF_SYSTEM : '$system' ;
// Display tasks (21.2)
SF_MONITOROFF   : '$monitoroff' ;
SF_MONITORON    : '$monitoron' ;
SF_MONITORO     : '$monitoro' ;
SF_MONITORH     : '$monitorh' ;
SF_MONITORB     : '$monitorb' ;
SF_DISPLAYO     : '$displayo' ;
SF_DISPLAYH     : '$displayh' ;
SF_DISPLAYB     : '$displayb' ;
SF_STROBEO      : '$strobeo' ;
SF_STROBEH      : '$strobeh' ;
SF_STROBEB      : '$strobeb' ;
SF_MONITOR      : '$monitor' ;
SF_DISPLAY      : '$display' ;
SF_WRITEO       : '$writeo' ;
SF_WRITEH       : '$writeh' ;
SF_WRITEB       : '$writeb' ;
SF_STROBE       : '$strobe' ;
SF_WRITE        : '$write' ;
// File I/O tasks and functions (21.3)
SF_FMONITORO     : '$fmonitoro' ;
SF_FMONITORH     : '$fmonitorh' ;
SF_FMONITORB     : '$fmonitorb' ;
SF_FDISPLAYO    : '$fdisplayo' ;
SF_FDISPLAYH    : '$fdisplayh' ;
SF_FDISPLAYB    : '$fdisplayb' ;
SF_FMONITOR      : '$fmonitor' ;
SF_FDISPLAY     : '$fdisplay' ;
SF_FSTROBEO     : '$fstrobeo' ;
SF_FSTROBEH     : '$fstrobeh' ;
SF_FSTROBEB     : '$fstrobeb' ;
SF_SFORMATF     : '$sformatf' ;
SF_SWRITEO      : '$swriteo' ;
SF_SWRITEH      : '$swriteh' ;
SF_SWRITEB      : '$swriteb' ;
SF_SFORMAT      : '$sformat' ;
SF_FWRITEO      : '$fwriteo' ;
SF_FWRITEH      : '$fwriteh' ;
SF_FWRITEB      : '$fwriteb' ;
SF_FSTROBE      : '$fstrobe' ;
SF_UNGETC       : '$ungetc' ;
SF_SWRITE       : '$swrite' ;
SF_SSCANF       : '$sscanf' ;
SF_REWIND       : '$rewind' ;
SF_FWRITE       : '$fwrite' ;
SF_FSCANF       : '$fscanf' ;
SF_FFLUSH       : '$fflush' ;
SF_FERROR       : '$ferror' ;
SF_FCLOSE       : '$fclose' ;
SF_FTELL        : '$ftell' ;
SF_FSEEK        : '$fseek' ;
SF_FOPEN        : '$fopen' ;
SF_FREAD        : '$fread' ;
SF_FGETS        : '$fgets' ;
SF_FGETC        : '$fgetc' ;
SF_FEOF         : '$feof' ;
// Memory load tasks (21.4)
SF_READMEMH : '$readmemh' ;
SF_READMEMB : '$readmemb' ;
// Memory dump tasks (21.5)
SF_WRITEMEMH : '$writememh' ;
SF_WRITEMEMB : '$writememb' ;
// Command line input (21.6)
SF_VALUE_PLUSARGS : '$value$plusargs' ;
SF_TEST_PLUSARGS  : '$test$plusargs' ;
// VCD tasks (21.7)
SF_DUMPPORTSLIMIT   : '$dumpportslimit' ;
SF_DUMPPORTSFLUSH   : '$dumpportsflush' ;
SF_DUMPPORTSOFF     : '$dumpportsoff' ;
SF_DUMPPORTSALL     : '$dumpportsall' ;
SF_DUMPPORTSON      : '$dumpportson' ;
SF_DUMPPORTS        : '$dumpports' ;
SF_DUMPLIMIT        : '$dumplimit' ;
SF_DUMPFLUSH        : '$dumpflush' ;
SF_DUMPVARS         : '$dumpvars' ;
SF_DUMPFILE         : '$dumpfile' ;
SF_DUMPOFF          : '$dumpoff' ;
SF_DUMPALL          : '$dumpall' ;
SF_DUMPON           : '$dumpon' ;

// Non-standard
SF_PSPRINTF : '$psprintf' ;
SF_PCIE_ACCESS : '$pcie_access' ;
SF_VCDPLUSFILE : '$vcdplusfile' ;
SF_VCDPLUSON : '$vcdpluson' ;
SF_VCDPLUSMEMON : '$vcdplusmemon' ;
SF_MMSOMASET : '$mmsomaset' ;

// 7.12 Array manipulation methods
UNIQUE_INDEX    : 'unique_index' ;
UNIQUE0	 : 'unique0' ;
UNIQUE	 : 'unique' ;

MIN    : 'min' ;
MAX    : 'max' ;
RSORT    : 'rsort' ;
SORT    : 'sort' ;
SUM    : 'sum' ;
PRODUCT    : 'product' ;
REVERSE    : 'reverse' ;
SHUFFLE    : 'shuffle' ;
FIND_FIRST_INDEX    : 'find_first_index' ;
FIND_LAST_INDEX    : 'find_last_index' ;
FIND_FIRST    : 'find_first' ;
FIND_INDEX    : 'find_index' ;
FIND_LAST    : 'find_last' ;
FIND    : 'find' ;

Time_Identifier : (Unsigned_Number | Fixed_Point_Number) [munpf]* [s] ;

Unsigned_Number : Decimal_Digit ('_' | Decimal_Digit)* ;

Decimal_Number
    : (Size)? Decimal_Base Unsigned_Number
    | (Size)? Decimal_Base X_Digit ('_')*
    | (Size)? Decimal_Base Z_Digit ('_')*
    ;

Binary_Number : (Size)? Binary_Base Binary_Value ;

Octal_Number : (Size)? Octal_Base Octal_Value ;

Hex_Number : (Size)? Hex_Base Hex_Value ;

Sign : [+-] ;

fragment Size : Non_Zero_Unsigned_Number ;

fragment Non_Zero_Unsigned_Number : Non_Zero_Decimal_Digit ('_' | Decimal_Digit)* ;

Real_Number
    : Fixed_Point_Number
    | Unsigned_Number ('.' Unsigned_Number)? [eE] ([+-])? Unsigned_Number
    ;

Fixed_Point_Number : Unsigned_Number '.' Unsigned_Number ;

fragment Binary_Value : Binary_Digit ('_' | Binary_Digit)* ;

fragment Octal_Value : Octal_Digit ('_' | Octal_Digit)* ;

fragment Hex_Value : Hex_Digit ('_' | Hex_Digit)* ;

fragment Decimal_Base : '\'' [sS]? [dD] ;

fragment Binary_Base : '\'' [sS]? [bB] ;

fragment Octal_Base : '\'' [sS]? [oO] ;

fragment Hex_Base : '\'' [sS]? [hH] ;

fragment Non_Zero_Decimal_Digit : [1-9] ;

fragment Decimal_Digit : [0-9] ;

fragment Binary_Digit
    : X_Digit | Z_Digit | [01]
    ;

fragment Octal_Digit
    : X_Digit | Z_Digit | [0-7]
    ;

fragment Hex_Digit
    : X_Digit | Z_Digit | [0-9a-fA-F]
    ;

fragment X_Digit : [xX] ;

fragment Z_Digit : [zZ?] ;

Unbased_Unsized_Literal
    : '\'0'
    | '\'1'
    | '\'z'
    | '\'Z'
    | '\'x'
    | '\'X'
    ;

Single_Bit_Zero : '1\'b0' | '1\'B0' ;

Single_Bit_One : '1\'b1' | '1\'B1' ;

Single_Bit_X : '1\'bx' | '1\'BX' ;

All_Binary_Zero : '\'b0' | '\'B0' ;

All_Binary_One : '\'b1' | '\'B1' ;

Synopsys_Comment
   : [ \t]* Synopsys .*? New_Line [ \t]* Synopsys .*? New_Line
{
if (reportSynopsys)
    System.out.println("Line " + _tokenStartLine + ": " + getText());
setChannel(SYNOPSYS);
}
   ;

Block_Comment : CS .*? CE -> channel(COMMENTS) ;

One_Line_Comment : Single_Line_Comment ~[\r\n]* -> channel(COMMENTS);

// Line_Continuation : LC .*? New_Line -> channel(DEFAULT_CHANNEL), mode(DEFAULT_MODE) ;


Simple_Identifier : First_Part (Second_Part | DS)* ;

Instance_Identifier : DS First_Part ((DOT)? Second_Part)* ;

DS : '$' ;

First_Part : [a-zA-Z_] ;

Second_Part : [a-zA-Z0-9_] ;

Escaped_Identifier : '\\' ('\u0021'..'\u007E')+ ~[ \r\t\n]* ;

Zero : '0' ;

One : '1' ;

Two : '2' ;

Three : '3' ;

Edge_Descriptor
    : Rising_Edge
    | Falling_Edge
    | X_Rising_Edge
    | X_Falling_Edge
    ;

Rising_Edge : '01' ;

Falling_Edge : '10' ;

X_Rising_Edge : 'x0' | 'x1' | 'X0' | 'X1' | 'z0' | 'z1' | 'Z0' | 'Z1' ;

X_Falling_Edge : '0x' | '1x' | '0X' | '1X' | '0z' | '1z' | '0Z' | '1Z' ;

// A.9.4 White space

White_Space : (' ' | '\t' | New_Line)+ -> channel(WHITESPACE) ;

// Compiler Directives

fragment Synopsys : '//synopsys' ;

fragment Single_Line_Comment : '//' ;

Back_Tick_S1 : '``' ;
Back_Tick_S2 : '`\\`"' ;
Back_Tick_S3 : '`"' ;

Ignored : Ignored_Compiler_Directives .*? New_Line -> channel(IGNORED) ;

fragment Ignored_Compiler_Directives
    // From IEEE1364-2005
    : ('`begin_keywords'
    | '`celldefine'
    | '`default_nettype'
    | '`end_keywords'
    | '`endcelldefine'
    | '`nounconnected_drive'
    | '`pragma'
    | '`resetall'
    | '`unconnected_drive'
    // Synopsys
    | '`delay_mode_path'
    | '`delay_mode_distributed'
    | '`delay_mode_unit'
    | '`delay_mode_zero'
    | '`vcs_mipdexpand'
    | '`vcs_mipdnoexpand'
    | '`endprotect'
    | '`endprotected'
    | '`protect'
    | '`protected'
    | '`noportcoerce'
    | '`portcoerce'
    | '`uselib'
    // Broadcom
    | '`suppress_faults')
    ;

TIMESCALE : '`timescale' ;
LINE : '`line' 
{
startLine = true;
}
-> channel(HIDDEN_CHANNEL), mode(LineMode);

//Text_Macro : '`' (Simple_Identifier | Escaped_Identifier) ;
Text_Macro : '`' Simple_Identifier ;

fragment LC : '\\' ;

fragment New_Line : '\r'? '\n' ;

X	 : [xX] ;
B	 : [bB] ;
R	 : [rR] ;
F	 : [fF] ;
P	 : [pP] ;
N	 : [nN] ;

mode LineMode;

LINE_MODE_NUMBER: (Decimal_Digit)+ 
{
if (startLine) {
    Integer line_number = new Integer(getText());
    setLine(line_number);
    startLine = false;
}
}
-> channel(LINE_CHANNEL);
LINE_MODE_STRING: StringLiteral
{
    String current_file = getText();
    current_file = current_file.replaceAll("\"", "");
    setFile(current_file);
}
-> channel(LINE_CHANNEL);
LINE_MODE_NEW_LINE: '\r'? '\n' -> channel(HIDDEN_CHANNEL), mode(DEFAULT_MODE);
LINE_MODE_WHITE_SPACE: [ \t]+ -> channel(HIDDEN_CHANNEL) ;
LINE_MODE: ~["0-9\r\n]+ -> channel(HIDDEN_CHANNEL);
