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

parser grammar IEEE1800_2017Parser;

options {
    tokenVocab = IEEE1800_2017Lexer;
}

@header {
package com.veriktig.scandium.ieee1800_2017.grammar;
}

// A.1 Source text
// A.1.1 Library source text
/*
library_text
    : (library_description)*
    ;

library_description
    : library_declaration
    | include_statement
    | config_declaration
    | SEMICOLON
    ;

library_declaration
    : 'library' library_identifier File_Path_Spec (COMMA File_Path_Spec )* ('-incdir' File_Path_Spec (COMMA File_Path_Spec )*)? SEMICOLON
    ;

include_statement
    : 'include' File_Path_Spec SEMICOLON
    ;
*/
// A.1.2 SystemVerilog source text

source_text
    : (timeunits_declaration)? (top)* EOF
    ;

top
    : module_declaration                        # topModuleDeclaration
    | udp_declaration                           # topUdpDeclaration
    | interface_declaration                     # topInterfaceDeclaration
    | program_declaration                       # topProgramDeclaration
    | package_declaration                       # topPackageDeclaration
    | (attribute_instance)* package_item        # topPackageItem
    | (attribute_instance)* bind_directive      # topBindDirective
    | config_declaration                        # topConfigDeclaration
    | system_functions                          # topSystemFunctions
    ;

// FRED - VCS allows package_import_declaration after ports
module_nonansi_header
    : (attribute_instance)* module_keyword (lifetime)? module_identifier (package_import_declaration)* (parameter_port_list)? list_of_ports module_header_end                           # moduleNonansiHeader
    | (attribute_instance)* module_keyword (lifetime)? module_identifier (parameter_port_list)? list_of_ports module_header_end (package_import_declaration)*                           # moduleNonansiHeaderPostPackageImport
    ;

module_ansi_header
    : (attribute_instance)* module_keyword (lifetime)? module_identifier (package_import_declaration)* (parameter_port_list)? (list_of_port_declarations)? module_header_end            # moduleAnsiHeader
    | (attribute_instance)* module_keyword (lifetime)? module_identifier (parameter_port_list)? (list_of_port_declarations)? module_header_end (package_import_declaration)*            # moduleAnsiHeaderPostPackageImport
    ;

module_header_end
    : SEMICOLON         # moduleHeaderEnd
    ;

module_declaration
    : module_nonansi_header (timeunits_declaration)? (module_item)* end_module_keyword (COLON module_identifier)?       # moduleDeclarationNonansi
    | module_ansi_header (timeunits_declaration)? (non_port_module_item)* end_module_keyword (COLON module_identifier)? # moduleDeclarationAnsi
    | (attribute_instance)* module_keyword (lifetime)? module_identifier LP DOT STAR RP SEMICOLON (timeunits_declaration)? (module_item)* end_module_keyword (COLON module_identifier)?  # moduleDeclarationNoHeader
    | EXTERN module_nonansi_header  # moduleDeclarationExternNonansiHeader
    | EXTERN module_ansi_header     # moduleDeclarationExternAnsiHeader
    ;

module_keyword
    : MODULE        # moduleKeyword
    | MACROMODULE   # macroModuleKeyword
    ;

end_module_keyword
    : ENDMODULE     # endModuleKeyword
    ;

interface_declaration
    : interface_nonansi_header (timeunits_declaration)? (interface_item)* ENDINTERFACE (COLON interface_identifier)?    # iterfaceDeclarationNonansi
    | interface_ansi_header (timeunits_declaration)? (non_port_interface_item)* ENDINTERFACE (COLON interface_identifier)? # interfaceDeclarationAnsi
    | (attribute_instance)* INTERFACE interface_identifier LP DOT STAR RP SEMICOLON (timeunits_declaration)? (interface_item)* ENDINTERFACE (COLON interface_identifier)?   # interfaceDeclarationNoHeader
    | EXTERN interface_nonansi_header   # interfaceDeclarationExternNonansi
    | EXTERN interface_ansi_header      # interfaceDeclarationExternAnsi
    ;

interface_nonansi_header
    : (attribute_instance)* INTERFACE (lifetime)? interface_identifier (package_import_declaration)* (parameter_port_list)? list_of_ports SEMICOLON     # interfaceNonansiHeader
    ;

interface_ansi_header
    : (attribute_instance)* INTERFACE (lifetime)? interface_identifier (package_import_declaration)* (parameter_port_list)? (list_of_port_declarations)? SEMICOLON      # interfaceAnsiHeader
    ;

program_declaration
    : program_nonansi_header (timeunits_declaration)? (program_item)* ENDPROGRAM (COLON program_identifier)?    # programDeclarationNonansi
    | program_ansi_header (timeunits_declaration)? (non_port_program_item)* ENDPROGRAM (COLON program_identifier)? # programDeclarationAnsi
    | (attribute_instance)* PROGRAM program_identifier LP DOT STAR RP SEMICOLON (timeunits_declaration)? (program_item)* ENDPROGRAM (COLON program_identifier)?         # programDeclarationNoHeader
    | EXTERN program_nonansi_header # programDeclarationExternNonansi
    | EXTERN program_ansi_header    # programDeclarationExternAnsi
    ;

program_nonansi_header
    : (attribute_instance)* PROGRAM (lifetime)? program_identifier (package_import_declaration)* (parameter_port_list)? list_of_ports SEMICOLON # programNonansiHeader
    ;

program_ansi_header
    : (attribute_instance)* PROGRAM (lifetime)? program_identifier (package_import_declaration)* (parameter_port_list)? (list_of_port_declarations)? SEMICOLON # programAnsiHeader
    ;

checker_declaration
    : CHECKER checker_identifier (LP (checker_port_list)? RP)? SEMICOLON ((attribute_instance)* checker_or_generate_item)* ENDCHECKER (COLON checker_identifier)? # checkerDeclaration
    ;

class_declaration
    : (VIRTUAL)? CLASS (lifetime)? class_identifier (parameter_port_list)?  (EXTENDS class_type (LP list_of_arguments RP)?)?  (IMPLEMENTS interface_class_type (COMMA interface_class_type )*)? SEMICOLON (class_item)* ENDCLASS (COLON class_identifier)? # classDeclaration
    ;

interface_class_type
    : ps_class_identifier (parameter_value_assignment)? # interfaceClassType
    ;

interface_class_declaration
    : INTERFACE CLASS class_identifier (parameter_port_list)?  (EXTENDS interface_class_type (COMMA interface_class_type)*)? SEMICOLON (interface_class_item)* ENDCLASS (COLON class_identifier)? # interfaceClassDeclaration
    ;

interface_class_item
    : type_declaration                              # interfaceClassItemTypeDecl
    | (attribute_instance)* interface_class_method  # interfaceClassItemMethod
    | local_parameter_declaration SEMICOLON         # interfaceClassItemLocalParam
    | parameter_declaration SEMICOLON               # interfaceClassItemParam
    | SEMICOLON                                     # interfaceClassItemEmpty
    ;

interface_class_method
    : PURE VIRTUAL method_prototype SEMICOLON       # interfaceClassMethod
    ;

package_declaration
    : (attribute_instance)* PACKAGE (lifetime)? package_identifier SEMICOLON (timeunits_declaration)? ((attribute_instance)* package_item)* ENDPACKAGE (COLON package_identifier)?      # packageDeclaration
    ;

// FRED timescale allowed in preprocessor
timeunits_declaration
    : timescale_statement                                                   # timeunitsDeclarationTimescale
    | TIMEUNIT time_literal (SLASH time_literal)? SEMICOLON                 # timeunitsDeclarationUnit
    | TIMEPRECISION time_literal SEMICOLON                                  # timeunitsDeclarationPrecision
    | TIMEUNIT time_literal SEMICOLON TIMEPRECISION time_literal SEMICOLON  # timeunitsDeclarationUnitPrecision
    | TIMEPRECISION time_literal SEMICOLON TIMEUNIT time_literal SEMICOLON  # timeunitsDeclarationPrecisionUnit
    ;

// A.1.3 Module parameters and ports

parameter_port_list
    : SHARP LP list_of_param_assignments (COMMA parameter_port_declaration)* RP     # parameterPortListAssign
    | SHARP LP parameter_port_declaration (COMMA parameter_port_declaration)* RP    # parameterPortListDecl
    | SHARP LP RP                                                                   # parameterPortListEmpty
    ;

parameter_port_declaration
    : parameter_declaration                 # parameterPortDeclarationParam
    | local_parameter_declaration           # parameterPortDeclarationLocalParam
    | data_type list_of_param_assignments   # parameterPortDeclarationList
    | TYPE list_of_type_assignments         # parameterPortDeclarationTypeList
    ;

list_of_ports
    : LP port (COMMA port)* RP      # listOfPorts
    ;

list_of_port_declarations
    : LP ((attribute_instance)* ansi_port_declaration (COMMA (attribute_instance)* ansi_port_declaration)*)? RP  # listOfPortDeclarationsAnsi
    | LP port_declaration (',' port_declaration)* RP    # listOfPortDeclarationsNonansi
    ;

port_declaration
    : (attribute_instance)* inout_declaration           # portDeclarationInout
    | (attribute_instance)* input_declaration           # portDeclarationIn
    | (attribute_instance)* output_declaration          # portDeclarationOut
    | (attribute_instance)* ref_declaration             # portDeclarationRef
    | (attribute_instance)* interface_port_declaration  # portDeclarationInterface
    ;

port
    : (port_expression)?                                # portExpr
    | DOT port_identifier LP (port_expression)? RP      # portList
    ;

port_expression
    : port_reference                                # portExpressionRef
    | LS port_reference (COMMA port_reference)* RS  # portExpressionRefList
    ;

port_reference
    : port_identifier constant_select   # portReference
    ;

port_direction
    : INPUT     # portDirectionIn
    | OUTPUT    # portDirectionOut
    | INOUT     # portDirectionInout
    | REF       # portDirectionRef
    ;

net_port_header
    : port_direction net_port_type   # netPortHeader
    | net_port_type                  # netPortHeaderImplicit
    ;

variable_port_header
    : (port_direction)? variable_port_type  # variablePortHeader
    ;

interface_port_header
    : interface_identifier (DOT modport_identifier)?    # interfacePortHeaderIdent
    | INTERFACE (DOT modport_identifier)?               # interfacePortHeaderInterface
    ;

ansi_port_declaration
    : (net_port_header | interface_port_header)? port_identifier (unpacked_dimension)* (ASSIGN constant_expression)? # ansiPortDeclarationNet
    | (variable_port_header)? port_identifier (variable_dimension)* (ASSIGN constant_expression)?   # ansiPortDeclarationVariable
    | (port_direction)? DOT port_identifier LP (expression)? RP         # ansiPortDeclarationIdentifier
    ;

// A.1.4 Module items

elaboration_system_task
    : SF_FATAL (LP finish_number (COMMA list_of_arguments)? RP)? SEMICOLON  # elaborationSystemTaskFatal
    | SF_ERROR (LP (list_of_arguments)? RP)? SEMICOLON                      # elaborationSystemTaskError
    | SF_WARNING (LP (list_of_arguments)? RP)? SEMICOLON                    # elaborationSystemTaskWarning
    | SF_INFO (LP (list_of_arguments)? RP)? SEMICOLON                       # elaborationSystemTaskInfo
    ;

finish_number
    : Zero  # finishNumber0
    | One   # finishNumber1
    | Two   # finishNumber2
    ;

module_common_item
    : module_or_generate_item_declaration   # moduleCommonItemDeclaration
    | interface_instantiation               # moduleCommonItemInterface
    | program_instantiation                 # moduleCommonItemProgram
    | assertion_item                        # moduleCommonItemAssertion
    | bind_directive                        # moduleCommonItemBind
    | continuous_assign                     # moduleCommonItemContinuousAssign
    | net_alias                             # moduleCommonItemNet
    | initial_construct                     # moduleCommonItemInitial
    | final_construct                       # moduleCommonItemFinal
    | always_construct                      # moduleCommonItemAlways
    | loop_generate_construct               # moduleCommonItemLoop
    | conditional_generate_construct        # moduleCommonItemGenerate
    | elaboration_system_task               # moduleCommonItemElaboration
    ;

module_item
    : port_declaration SEMICOLON            # moduleItemPortDecl
    | non_port_module_item                  # moduleItemNonPortItem
    ;

module_or_generate_item
    : (attribute_instance)* parameter_override      # moduleOrGenerateItemParamOverride
    | (attribute_instance)* gate_instantiation      # moduleOrGenerateItemGateInst
    | (attribute_instance)* udp_instantiation       # moduleOrGenerateItemUdpInst
    | (attribute_instance)* module_instantiation    # moduleOrGenerateItemInst
    | (attribute_instance)* module_common_item      # moduleOrGenerateItemCommon
    ;

module_or_generate_item_declaration
    : package_or_generate_item_declaration                  # moduleOrGenerateItemDeclarationPackageDecl
    | genvar_declaration                                    # moduleOrGenerateItemDeclarationGenvar
    | clocking_declaration                                  # moduleOrGenerateItemDeclarationClocking
    | LDEFAULT CLOCKING clocking_identifier SEMICOLON       # moduleOrGenerateItemDeclarationClockId
    | LDEFAULT DISABLE IFF expression_or_dist SEMICOLON     # moduleOrGenerateItemDeclarationExpr
    ;

non_port_module_item
    : generate_region                               # nonPortModuleItemGenerate
    | module_or_generate_item                       # nonPortModuleItemModOrGenerate
    | specify_block                                 # nonPortModuleItemSpecify
    | (attribute_instance)* specparam_declaration   # nonPortModuleItemSpecparam
    | program_declaration                           # nonPortModuleItemProgramDecl
    | module_declaration                            # nonPortModuleItemModuleDecl
    | interface_declaration                         # nonPortModuleItemInterfaceDecl
    | timeunits_declaration                         # nonPortModuleItemTimeunits
    ;

parameter_override
    : DEFPARAM list_of_defparam_assignments SEMICOLON   # parameterOverride
    ;

// FRED semicolon not required
bind_directive
//    : BIND bind_target_scope (COLON bind_target_instance_list)? bind_instantiation SEMICOLON
    : BIND bind_target_scope (COLON bind_target_instance_list)? bind_instantiation  # bindDirectiveScope
    | BIND bind_target_instance bind_instantiation SEMICOLON                        # bindDirectiveTarget
    ;

bind_target_scope
    : module_identifier         # bindTargetScopeModule
    | interface_identifier      # bindTargetScopeInterface
    ;

bind_target_instance
    : hierarchical_identifier constant_bit_select   # bindTargetInstance
    ;

bind_target_instance_list
    : bind_target_instance (COMMA bind_target_instance)*    # bindTargetInstanceList
    ;

bind_instantiation
    : program_instantiation     # bindInstantiationProgram
    | module_instantiation      # bindInstantiationModule
    | interface_instantiation   # bindInstantiationInterface
    | checker_instantiation     # bindInstantiationChecker
    ;

// A.1.5 Configuration source text

config_declaration
    : CONFIG config_identifier SEMICOLON (local_parameter_declaration SEMICOLON)* design_statement (config_rule_statement)* ENDCONFIG (COLON config_identifier)?    # configDeclaration
    ;

design_statement
    : DESIGN ((library_identifier DOT)? cell_identifier)* SEMICOLON     # designStatement
    ;

config_rule_statement
    : default_clause liblist_clause SEMICOLON   # configRuleStatementDefault
    | inst_clause liblist_clause SEMICOLON      # configRuleStatementInstLiblist
    | inst_clause use_clause SEMICOLON          # configRuleStatementInstUse
    | cell_clause liblist_clause SEMICOLON      # configRuleStatementCellLiblist
    | cell_clause use_clause SEMICOLON          # configRuleStatementCellUse
    ;

default_clause
    : LDEFAULT      # defaultClause
    ;

inst_clause
    : INSTANCE inst_name    # instClause
    ;

inst_name
    : topmodule_identifier (DOT instance_identifier)*   # instName
    ;

cell_clause
    : CELL (library_identifier DOT)? cell_identifier    # cellClause
    ;

liblist_clause
    : LIBLIST library_identifier*       # liblistClause
    ;

use_clause
    : USE ( library_identifier DOT)? cell_identifier (COLON CONFIG)?    # useClauseCell
    | USE named_parameter_assignment (COMMA named_parameter_assignment)* (COLON CONFIG)?    # useClauseParam
    | USE (library_identifier DOT)? cell_identifier named_parameter_assignment (COMMA named_parameter_assignment)* (COLON CONFIG)?      # useClauseCellParam
    ;

// A.1.6 Interface items

interface_or_generate_item
    : (attribute_instance)* module_common_item          # interfaceOrGenerateItemCommon
    | (attribute_instance)* extern_tf_declaration       # interfaceOrGenerateTfDecl
    ;

extern_tf_declaration
    : EXTERN method_prototype SEMICOLON                 # externTfDeclarationMethod
    | EXTERN FORKJOIN task_prototype SEMICOLON          # externTfDeclarationTask
    ;

interface_item
    : port_declaration SEMICOLON                        # interfaceItemPort
    | non_port_interface_item                           # interfaceItemNonPort
    ;

non_port_interface_item
    : generate_region                   # nonPortInterfaceItemGenerate
    | interface_or_generate_item        # nonPortInterfaceItemInteraceOrGenerate
    | program_declaration               # nonPortInterfaceItemProgram
    | modport_declaration               # nonPortInterfaceModport
    | interface_declaration             # nonPortInterfaceItemInterface
    | timeunits_declaration             # nonPortInterfaceItemTimeunits
    ;

// A.1.7 Program items

program_item
    : port_declaration SEMICOLON        # programItemPort
    | non_port_program_item             # programItemNonPort
    ;

non_port_program_item
    : (attribute_instance)* continuous_assign                       # nonPortProgramItemAssign
    | (attribute_instance)* module_or_generate_item_declaration     # nonPortProgramItemModuleOrGenerate
    | (attribute_instance)* initial_construct                       # nonPortProgramItemInitial
    | (attribute_instance)* final_construct                         # nonPortProgramItemFinal
    | (attribute_instance)* concurrent_assertion_item               # nonPortProgramItemAssert
    | timeunits_declaration                                         # nonPortProgramItemTimeunits
    | program_generate_item                                         # nonPortProgramItemGenerate
    ;

program_generate_item
    : loop_generate_construct               # programGenerateItemLoop
    | conditional_generate_construct        # programGenerateItemConditional
    | generate_region                       # programGenerateItemRegion
    | elaboration_system_task               # programGenerateItemElabTask
    ;

// A.1.8 Checker items

checker_port_list
    : checker_port_item (COMMA checker_port_item)*      # checkerPortList
    ;

checker_port_item
    : (attribute_instance)* (checker_port_direction)? property_formal_type formal_port_identifier (variable_dimension)* (ASSIGN property_actual_arg)?       # checkerPortItem
    ;

checker_port_direction
    : INPUT             # checkerPortIn
    | OUTPUT            # checkerPortOut
    ;

checker_or_generate_item
    : checker_or_generate_item_declaration      # checkerOrGenerateItemDecl
    | initial_construct                         # checkerOrGenerateItemInitial
    | always_construct                          # checkerOrGenerateItemAlways
    | final_construct                           # checkerOrGenerateItemFinal
    | assertion_item                            # checkerOrGenerateItemAssertion
    | continuous_assign                         # checkerOrGenerateItemContinuous
    | checker_generate_item                     # checkerOrGenerateItemGenerate
    ;

checker_or_generate_item_declaration
    : (RAND)? data_declaration                          # checkerOrGenerateItemDeclarationData
    | function_declaration                              # checkerOrGenerateItemDeclarationFunction
    | checker_declaration                               # checkerOrGenerateItemDeclarationChecker
    | assertion_item_declaration                        # checkerOrGenerateItemDeclarationAssertion
    | covergroup_declaration                            # checkerOrGenerateItemDeclarationCovergroup
    | genvar_declaration                                # checkerOrGenerateItemDeclarationGenvar
    | clocking_declaration                              # checkerOrGenerateItemDeclarationClocking
    | LDEFAULT CLOCKING clocking_identifier SEMICOLON   # checkerOrGenerateItemDeclarationClockingId
    | LDEFAULT DISABLE IFF expression_or_dist SEMICOLON # checkerOrGenerateItemDeclarationExpr
    | SEMICOLON                                         # checkerOrGenerateItemDeclarationEmpty
    ;

checker_generate_item
    : loop_generate_construct           # checkerGenerateItemLoop
    | conditional_generate_construct    # checkerGenerateItemConditional
    | generate_region                   # checkerGenerateItemGenerate
    | elaboration_system_task           # checkerGenerateItemElabTask
    ;

// A.1.9 Class items

class_item
    : (attribute_instance)* class_property              # classItemProperty
    | (attribute_instance)* class_method                # classItemMethod
    | (attribute_instance)* class_constraint            # classItemConstraint
    | (attribute_instance)* class_declaration           # classItemDecl
    | (attribute_instance)* covergroup_declaration      # classItemCovergroup
    | local_parameter_declaration SEMICOLON             # classItemLocalParam
    | parameter_declaration SEMICOLON                   # classItemParam
    | SEMICOLON                                         # classItemEmpty
    ;

class_property
    : (property_qualifier)* data_declaration    # classPropertyData
    | CONST (class_item_qualifier)* data_type const_identifier (ASSIGN constant_expression)? SEMICOLON  # classPropertyConstData
    ;

class_method
    : (method_qualifier)* task_declaration                              # classMethodTask
    | (method_qualifier)* function_declaration                          # classMethodFunction
    | PURE VIRTUAL (class_item_qualifier)* method_prototype SEMICOLON   # classMethodPureMethod
    | EXTERN (method_qualifier)* method_prototype SEMICOLON             # classMethodExternMethod
    | (method_qualifier)* class_constructor_declaration                 # classMethodConstructor
    | EXTERN (method_qualifier)* class_constructor_prototype            # classMethodExternConstructor
    ;

class_constructor_prototype
    : FUNCTION NEW (LP (tf_port_list)? RP)? SEMICOLON       # classConstructorPrototype
    ;

class_constraint
    : constraint_prototype      # classConstraintProto
    | constraint_declaration    # classConstraintDecl
    ;

class_item_qualifier
    : STATIC        # classItemQualifierStatic
    | PROTECTED     # classItemQualifierProtected
    | LOCAL         # classItemQualifierLocal
    ;

property_qualifier
    : random_qualifier          # propertyQualifierRandom
    | class_item_qualifier      # propertyQualifierClassItem
    ;

random_qualifier
    : RAND              # randomQualifierRand
    | RANDC             # randomQualifierRandc
    ;

method_qualifier
    : (PURE)? VIRTUAL           # methodQualifierVirtual
    | class_item_qualifier      # methodQualifierClassItem
    ;

method_prototype
    : task_prototype            # methodPrototypeTask
    | function_prototype        # methodPrototypeFunction
    ;

// FRED list_of_arguments optional?
class_constructor_declaration
    : FUNCTION (class_scope)? NEW (LP (tf_port_list)? RP)? SEMICOLON (block_item_declaration)* (SUPER DOT NEW (LP (list_of_arguments)? RP)? SEMICOLON)? (function_statement_or_null)* ENDFUNCTION (COLON NEW)?   # classConstructorDeclaration
    ;

// A.1.10 Constraints

constraint_declaration
    : (STATIC)? CONSTRAINT constraint_identifier constraint_block       # constraintDeclaration
    ;

constraint_block
    : LS (constraint_block_item)* RS        # constraintBlock
    ;

constraint_block_item
    : SOLVE solve_before_list BEFORE solve_before_list SEMICOLON    # constraintBlockItemSolve
    | constraint_expression                                         # constraintBlockItemExpr
    ;

solve_before_list
    : constraint_primary (COMMA constraint_primary)*    # solveBeforeList
    ;

constraint_primary
    : (implicit_class_handle DOT | class_scope)? hierarchical_identifier select     # constraintPrimary
    ;

constraint_expression
    : (SOFT)? expression_or_dist SEMICOLON      # constraintExpressionExprOrDist
    | uniqueness_constraint                     # constraintExpressionUniqueness
    | expression MINUS_GT constraint_set        # constraintExpressionExpr
    | IF LP expression RP constraint_set (ELSE constraint_set)?     # constraintExpressionIf
    | FOREACH LP ps_or_hierarchical_array_identifier LB loop_variables RB RP constraint_set # constraintExpressionForEach
    | DISABLE SOFT constraint_primary SEMICOLON # constraintExpressionDisable
    ;

uniqueness_constraint
    : UNIQUE LS open_range_list RS      # uniquenessConstraint
    ;

constraint_set
    : constraint_expression             # constraintSetExpr
    | LS (constraint_expression)* RS    # constraintSetExprParends
    ;

dist_list
    : dist_item (COMMA dist_item)*      # distList
    ;

dist_item
    : (value_range dist_weight)?        # distItem
    ;

dist_weight
    : COLON_EQUALS expression           # distWeightEquals
    | COLON_SLASH expression            # distWeightSlash
    ;

constraint_prototype
    : (constraint_prototype_qualifier)? (STATIC)? CONSTRAINT constraint_identifier SEMICOLON    # constraintPrototype
    ;

constraint_prototype_qualifier
    : EXTERN            # constraintPrototypeQualifierExtern
    | PURE              # constraintPrototypeQualifierPure
    ;

extern_constraint_declaration
    : (STATIC)?  CONSTRAINT class_scope constraint_identifier constraint_block  # externConstraintDeclaration
    ;

identifier_list
    : identifier (COMMA identifier)*    # identifierList
    ;

// A.1.11 Package items

package_item
    : package_or_generate_item_declaration      # packageItemPackageOrGenerateItem
    | anonymous_program                         # packageItemAnonymousProgram
    | package_export_declaration                # packageItemExport
    | timeunits_declaration                     # packageItemTimeunits
    ;

package_or_generate_item_declaration
    : net_declaration                           # packageOrGenerateItemDeclarationNet
    | data_declaration                          # packageOrGenerateItemDeclarationData
    | task_declaration                          # packageOrGenerateItemDeclarationTask
    | function_declaration                      # packageOrGenerateItemDeclarationFunction
    | checker_declaration                       # packageOrGenerateItemDeclarationChecker
    | dpi_import_export                         # packageOrGenerateItemDeclarationDpi
    | extern_constraint_declaration             # packageOrGenerateItemDeclarationExtern
    | class_declaration                         # packageOrGenerateItemDeclarationClassDecl
    | class_constructor_declaration             # packageOrGenerateItemDeclarationClassConstructorDecl
    | local_parameter_declaration SEMICOLON     # packageOrGenerateItemDeclarationLocalParam
    | parameter_declaration SEMICOLON           # packageOrGenerateItemDeclarationParam
    | covergroup_declaration                    # packageOrGenerateItemDeclarationCovergroup
    | assertion_item_declaration                # packageOrGenerateItemDeclarationAssert
    | SEMICOLON                                 # packageOrGenerateItemDeclarationEmpty
    ;

anonymous_program
    : PROGRAM SEMICOLON (anonymous_program_item)* ENDPROGRAM    # anonymousProgram
    ;

anonymous_program_item
    : task_declaration                  # anonymousProgramItemTask
    | function_declaration              # anonymousProgramItemFunction
    | class_declaration                 # anonymousProgramItemClass
    | covergroup_declaration            # anonymousProgramItemCovergroup
    | class_constructor_declaration     # anonymousProgramItemClassConstructor
    | SEMICOLON                         # anonymousProgramItemEmpty
    ;

// A.2 Declarations
// A.2.1 Declaration types
// A.2.1.1 Module parameter declarations

// FRED 6.20.2 Infer type from value
local_parameter_declaration
    : LOCALPARAM data_type_or_implicit list_of_param_assignments    # localParameterDeclaration
    | LOCALPARAM list_of_param_assignments                          # localParameterDeclarationImplicit
    | LOCALPARAM TYPE list_of_type_assignments                      # localParameterDeclarationType
    ;

// FRED 6.20.2 Infer type from value
parameter_declaration
    : PARAMETER data_type_or_implicit list_of_param_assignments # parameterDeclaration
    | PARAMETER list_of_param_assignments                       # parameterDeclarationImplicit
    | PARAMETER TYPE list_of_type_assignments                   # parameterDeclarationType
    ;

specparam_declaration
    : SPECPARAM (packed_dimension)? list_of_specparam_assignments SEMICOLON     # specparamDeclaration
    ;

// A.2.1.2 Port declarations

// FRED 23.2.2.1
inout_declaration
    : INOUT net_port_type list_of_port_identifiers      # inoutDeclaration
    | INOUT list_of_port_identifiers                    # inoutDeclarationImplicit
    ;

// FRED 23.2.2.1
input_declaration
    : INPUT net_port_type list_of_port_identifiers          # inputDeclaration
    | INPUT list_of_port_identifiers                        # inputDeclarationImplicit
    | INPUT variable_port_type list_of_variable_identifiers # inputDeclarationVar
    ;

// FRED 23.2.2.1
output_declaration
    : OUTPUT net_port_type list_of_port_identifiers                 # outputDeclaration
    | OUTPUT list_of_port_identifiers                               # outputDeclarationImplicit
    | OUTPUT variable_port_type list_of_variable_port_identifiers   # outputDeclarationVar
    ;

interface_port_declaration
    : interface_identifier list_of_interface_identifiers        # interfacePortDeclaration
    | interface_identifier DOT modport_identifier list_of_interface_identifiers # interfacePortDeclarationHier
    ;

ref_declaration
    : REF variable_port_type  list_of_variable_identifiers  # refDeclaration
    ;

// A.2.1.3 Type declarations

data_declaration
    : (CONST)? (VAR)? (lifetime)? data_type_or_implicit list_of_variable_decl_assignments SEMICOLON # dataDeclarationData
    | (CONST)? (VAR)? (lifetime)? list_of_variable_decl_assignments SEMICOLON                       # dataDeclarationImplicit
    | type_declaration                                                                              # dataDeclarationType
    | package_import_declaration                                                                    # dataDeclarationImport
    | net_type_declaration                                                                          # dataDeclarationNetType
    ;

package_import_declaration
    : IMPORT package_import_item (COMMA package_import_item)* SEMICOLON     # packageImportDeclaration
    ;

package_import_item
    : package_identifier COLON2 identifier  # packageImportItem
    | package_identifier COLON2 STAR        # packageImportItemAll
    ;

package_export_declaration
    : EXPORT SDCS SEMICOLON                                                 # packageExportDeclarationAll
    | EXPORT package_import_item (COMMA package_import_item)* SEMICOLON     # packageExportDeclarationItem
    ;

genvar_declaration
    : GENVAR list_of_genvar_identifiers SEMICOLON   # genvarDeclaration
    ;

/*
 * FRED data_type_or_implicit is optional
 * 6.7.1 If a data type is not specified in the net declaration or if only a range and/or signing is specified,
 * then the data type of the net is implicitly declared as logic .
 */
net_declaration
    : net_type (drive_strength | charge_strength)? (VECTORED | SCALARED)? data_type_or_implicit (delay3)? list_of_net_decl_assignments SEMICOLON    # netDeclaration
    | net_type (drive_strength | charge_strength)? (VECTORED | SCALARED)? (delay3)? list_of_net_decl_assignments SEMICOLON  # netDeclarationImplicit
    | net_type_identifier (delay_control)?  list_of_net_decl_assignments SEMICOLON # netDeclarationList
    | INTERCONNECT implicit_data_type (SHARP delay_value)?  net_identifier (unpacked_dimension)* (COMMA (net_identifier unpacked_dimension)*)? SEMICOLON    # netDeclarationInterconnect
    | INTERCONNECT (SHARP delay_value)?  net_identifier (unpacked_dimension)* (COMMA (net_identifier unpacked_dimension)*)? SEMICOLON # netDeclarationInterconnectNoSize
    ;

type_declaration
    : TYPEDEF data_type (type_identifier (variable_dimension)*)* SEMICOLON      # typeDeclarationData
    | TYPEDEF interface_instance_identifier constant_bit_select DOT type_identifier type_identifier SEMICOLON # typeDeclarationInterface
    | TYPEDEF (ENUM | STRUCT | UNION | CLASS | INTERFACE CLASS)? type_identifier SEMICOLON # typeDeclarationOther
    ;

net_type_declaration
    : NETTYPE data_type net_type_identifier (WITH (package_scope | class_scope)? tf_identifier )? SEMICOLON # netTypeDeclarationData
    | NETTYPE (package_scope | class_scope)? net_type_identifier net_type_identifier SEMICOLON # netTypeDeclarationNetType
    ;

lifetime
    : STATIC        # lifetimeStatic
    | AUTOMATIC     # lifetimeAutomatic
    ;

// A.2.2 Declaration data types
// A.2.2.1 Net and variable types

casting_type
    : simple_type           # castingTypeSimple
    | constant_primary      # castingTypeConstantPrimary
    | signing               # castingTypeSigning
    | STRING                # castingTypeString
    | CONST                 # castingTypeConst
    ;

data_type
    : integer_vector_type (signing)? (packed_dimension)*    # dataTypeVector
    | integer_atom_type (signing)?                          # dataTypeInteger
    | non_integer_type                                      # dataTypeNonInteger
    | struct_union (PACKED (signing)?)? LS struct_union_member (struct_union_member)* RS (packed_dimension)* # dataTypeUnion
    | ENUM (enum_base_type)? LS enum_name_declaration (COMMA enum_name_declaration)* RS (packed_dimension)* # dataTypeEnum
    | STRING        # dataTypeString
    | CHANDLE       # dataTypeCHandle
    | VIRTUAL (INTERFACE)? interface_identifier (parameter_value_assignment)? (DOT modport_identifier)? # dataTypeInterface
    | (class_scope | package_scope)? type_identifier (packed_dimension)*        # dataTypeTypeId
    | class_type                    # dataTypeClassType
    | EVENT                         # dataTypeEvent
    | ps_covergroup_identifier      # dataTypeCovergroupId
    | type_reference                # dataTypeTypeReference
    ;

data_type_or_implicit
    : data_type             # dataTypeOrImplicitData
    | implicit_data_type    # dataTypeOrImplicitImplicit
    ;

// FRED 23.2.2.3 signing AND/OR packed dimensions. Spec matches empty string?
implicit_data_type
//    : (signing)? (packed_dimension)*
    : signing (packed_dimension)*       # implicitDataTypeSigning
    | (packed_dimension)+               # implicitDataTypePackedDimension
    ;

enum_base_type
    : integer_atom_type (signing)?                          # enumBaseTypeInteger
    | integer_vector_type (signing)? (packed_dimension)?    # enumBaseTypeVector
    | type_identifier (packed_dimension)?                   # enumBaseTypeTypeId
    ;

enum_name_declaration
    : enum_identifier (LB integral_number (COLON integral_number)? RB)? (ASSIGN constant_expression)? # enumNameDeclaration
    ;

class_scope
    : class_type COLON2     # classScope
    ;

class_type
    : ps_class_identifier (parameter_value_assignment)?  (COLON2 class_identifier (parameter_value_assignment)? )* # classType
    ;

integer_type
    : integer_vector_type   # integerTypeVector
    | integer_atom_type     # integerTypeInteger
    ;

integer_atom_type
    : BYTE              # integerAtomTypeByte
    | SHORTINT          # integerAtomTypeShortint
    | INT               # integerAtomTypeInt
    | LONGINT           # integerAtomTypeLongint
    | INTEGER           # integerAtomTypeInteger
    | TIME              # integerAtomTypeTime
    ;

integer_vector_type
    : BIT               # integerVectorTypeBit
    | LOGIC             # integerVectorTypeLogic
    | REG               # integerVectorTypeReg
    ;

non_integer_type
    : SHORTREAL         # nonIntegerTypeShortreal
    | REAL              # nonIntegerTypeReal
    | REALTIME          # nonIntegerTypeRealtime
    ;

net_type
    : SUPPLY0       # netTypeSupply0
    | SUPPLY1       # netTypeSupply1
    | TRI           # netTypeTri
    | TRIAND        # netTypeTriAnd
    | TRIOR         # netTypeTriOr
    | TRIREG        # netTypeTriReg
    | TRI0          # netTypeTri0
    | TRI1          # netTypeTri1
    | UWIRE         # netTypeUwire
    | WIRE          # netTypeWire
    | WAND          # netTypeWand
    | WOR           # netTypeWor
    ;

net_port_type
    :                                       # netPortTypeNull
    | data_type_or_implicit                 # netPortTypeDataOrImplicit
    | net_type data_type_or_implicit        # netPortTypeDataOrImplicitNetType
    | net_type_identifier                   # netPortTypeId
    | INTERCONNECT implicit_data_type       # netPortTypeInterconnect
    | INTERCONNECT                          # netPortTypeInterconnectNoSize
    ;

variable_port_type
    : var_data_type         # variablePortType
    ;

var_data_type
    : data_type                     # varDataTypeData
    | VAR data_type_or_implicit     # varDataTypeVar
    | VAR                           # varDataTypeVar
    ;

signing
    : SIGNED        # signingSigned
    | UNSIGNED      # signingUnsigned
    ;

simple_type
    : integer_type                  # simpleTypeInteger
    | non_integer_type              # simpleTypeNonInteger
    | ps_type_identifier            # simpleTypeType
    | ps_parameter_identifier       # simpleTypeParam
    ;

struct_union_member
    : (attribute_instance)* (random_qualifier)? data_type_or_void list_of_variable_decl_assignments SEMICOLON # structUnionMember
    ;

data_type_or_void
    : data_type         # dataTypeOrVoidData
    | VOID              # dataTypeOrVoidVoid
    ;

struct_union
    : STRUCT            # structUnionStruct
    | UNION (TAGGED)?   # structUnionUnion
    ;

type_reference
    : TYPE LP expression RP     # typeReferenceExpr
    | TYPE LP data_type RP      # typeReferenceData
    ;

// A.2.2.2 Strengths

drive_strength
    : LP strength0 COMMA strength1 RP   # driveStrength01
    | LP strength1 COMMA strength0 RP   # driveStrength10
    | LP strength0 COMMA HIGHZ1 RP      # driveStrength0Z
    | LP strength1 COMMA HIGHZ0 RP      # driveStrength1Z
    | LP HIGHZ0 COMMA strength1 RP      # driveStrengthZ1
    | LP HIGHZ1 COMMA strength0 RP      # driveStrengthZ0
    ;

strength0
    : SUPPLY0   # strength0Supply0
    | STRONG0   # strength0Strong0
    | PULL0     # strength0Pull0
    | WEAK0     # strength0Weak0
    ;

strength1
    : SUPPLY1   # strength1Supply1
    | STRONG1   # strength1Strong1
    | PULL1     # strength1Pull1
    | WEAK1     # strength1Weak1
    ;

charge_strength
    : LP SMALL RP       # chargeStrengthSmall
    | LP MEDIUM RP      # chargeStrengthMedium
    | LP LARGE RP       # chargeStrengthLarge
    ;

// A.2.2.3 Delays

delay3
    : SHARP delay_value     # delay3Value
    | SHARP LP mintypmax_expression (COMMA mintypmax_expression (COMMA mintypmax_expression)?)? RP  # delay3Expr
    ;

delay2
    : SHARP delay_value     # delay2Value
    | SHARP LP mintypmax_expression (COMMA mintypmax_expression)? RP    # delay2Expr
    ;

delay_value
    : Unsigned_Number       # delayValueUnsigned
    | Real_Number           # delayValueReal
    | ps_identifier         # delayValuePsIdent
    | time_literal          # delayValueTime
    | STEP1                 # delayValueStep1
    | ps_or_hierarchical_array_identifier # delayValueHierarchical      // XXX FRED
    ;

// A.2.3 Declaration lists

list_of_defparam_assignments
    : defparam_assignment (COMMA defparam_assignment)*      # listOfDefparamAssignments
    ;

list_of_genvar_identifiers
    : genvar_identifier (COMMA genvar_identifier)*      # listOfGenvarIdentifiers
    ;

list_of_interface_identifiers
    : interface_identifier (unpacked_dimension)* (COMMA interface_identifier (unpacked_dimension)*)* # listOfInterfaceIdentifiers
    ;

list_of_net_decl_assignments
    : net_decl_assignment (COMMA net_decl_assignment)*  # listOfNelDeclAssignments
    ;

list_of_param_assignments
    : param_assignment (COMMA param_assignment)*        # listOfParamAssignments
    ;

list_of_port_identifiers
    : port_identifier (unpacked_dimension)* (COMMA port_identifier (unpacked_dimension)*)*  # listOfPortIdentifiers
    ;

list_of_udp_port_identifiers
    : port_identifier (COMMA port_identifier)*  # listOfUdpPortIdentifiers
    ;

list_of_specparam_assignments
    : specparam_assignment (COMMA specparam_assignment)*    # listOfSpecparamAssignments
    ;

list_of_tf_variable_identifiers
    : port_identifier (variable_dimension)* (ASSIGN expression)?  (COMMA port_identifier (variable_dimension)* (ASSIGN expression)? )* # listOfTfVarIdentifiers
    ;

list_of_type_assignments
    : type_assignment (COMMA type_assignment)*      # listOfTypeAssignments
    ;

list_of_variable_decl_assignments
    : variable_decl_assignment (COMMA variable_decl_assignment)*    # listOfVariableDeclAssignments
    ;

list_of_variable_identifiers
    : variable_identifier (variable_dimension)* (COMMA variable_identifier (variable_dimension)*)*  # listIfVariableIdentifiers
    ;

list_of_variable_port_identifiers
    : port_identifier (variable_dimension)* (ASSIGN constant_expression )?  (COMMA port_identifier (variable_dimension)* (ASSIGN constant_expression )? )* # listOfVariablePortIdentifiers
    ;

// A.2.4 Declaration assignments

defparam_assignment
    : hierarchical_parameter_identifier ASSIGN constant_mintypmax_expression    # defparamAssignment
    ;

net_decl_assignment
    : net_identifier (unpacked_dimension)* (ASSIGN expression)?     # netDeclAssignment
    ;

param_assignment
    : parameter_identifier (unpacked_dimension)* (ASSIGN constant_param_expression)?    # paramAssignment
    ;

specparam_assignment
    : specparam_identifier ASSIGN constant_mintypmax_expression     # specParamAssignmentExpr
    | pulse_control_specparam                                       # specParamAssignmentPulse
    ;

type_assignment
    : type_identifier (ASSIGN data_type)?   # typeAssignment
    ;

pulse_control_specparam
    : PATHPULSE ASSIGN LP reject_limit_value (COMMA error_limit_value )? RP # pulseControlSpecparamReject
    | PATHPULSE specify_input_terminal_descriptor DS specify_output_terminal_descriptor ASSIGN LP reject_limit_value (COMMA error_limit_value)? RP  # pulseControlSpecparamSpecify
    ;

error_limit_value
    : limit_value       # errorLimitValue
    ;

reject_limit_value
    : limit_value       # rejectLimitValue
    ;

limit_value
    : constant_mintypmax_expression # limitValue
    ;

variable_decl_assignment
    : variable_identifier (variable_dimension)* (ASSIGN expression)? # variableDeclAssignmentVariable
    | dynamic_array_variable_identifier unsized_dimension (variable_dimension)* (ASSIGN dynamic_array_new)? # variableDeclAssignmentDynamicArray
    | class_variable_identifier (ASSIGN class_new)? # variableDeclAssignmentClassVariable
    ;

// XXX FRED Add Void for empty parends
class_new
    : (class_scope)? NEW (LP list_of_arguments RP)?   # classNew
    | (class_scope)? NEW LP RP                        # classNewVoid
    | NEW expression                                  # classNewExpr
    ;

dynamic_array_new
    : NEW LB expression RB (LP expression RP)?  # dynamicArrayNew
    ;

// A.2.5 Declaration ranges

unpacked_dimension
    : LB constant_range RB          # unpackedDimensionRange
    | LB constant_expression RB     # unpackedDimensionExpr
    ;

packed_dimension
    : LB constant_range RB          # packedDimensionRange
    | unsized_dimension             # packedDimensionUnsized
    ;

associative_dimension
    : LB data_type RB               # associativeDimensionType
    | LB STAR RB                    # associativeDimensionStar
    ;

variable_dimension
    : unsized_dimension             # variableDimensionUnsized
    | unpacked_dimension            # variableDimensionUnpacked
    | associative_dimension         # variableDimensionAssociative
    | queue_dimension               # variableDimensionQueue
    ;

queue_dimension
    : LB DS (COLON constant_expression)? RB     # queueDimension
    ;

unsized_dimension
    : LB RB             # unsizedDimension
    ;

// A.2.6 Function declarations

function_data_type_or_implicit
    : data_type_or_void             # functionDataTypeOrImplicitData
    | implicit_data_type            # functionDataTypeOrImplicitImplicit
    ;

function_declaration
    : FUNCTION (lifetime)? function_body_declaration
    ;

// FRED allow implicit
function_body_declaration
    : function_data_type_or_implicit ( interface_identifier DOT | class_scope )? function_identifier SEMICOLON (tf_item_declaration)* (function_statement_or_null)* ENDFUNCTION (COLON function_identifier)?    # functionBodyDeclaration
    | ( interface_identifier DOT | class_scope )? function_identifier SEMICOLON (tf_item_declaration)* (function_statement_or_null)* ENDFUNCTION (COLON function_identifier)?  # functionBodyDeclarationImplicit
    | function_data_type_or_implicit ( interface_identifier DOT | class_scope )? function_identifier LP (tf_port_list)? RP SEMICOLON (block_item_declaration)* (function_statement_or_null)* ENDFUNCTION (COLON function_identifier)? # functionBodyDeclarationPort
    | ( interface_identifier DOT | class_scope )? function_identifier LP (tf_port_list)? RP SEMICOLON (block_item_declaration)* (function_statement_or_null)* ENDFUNCTION (COLON function_identifier)?  # functionBodyDeclarationPortImplicit
    ;

function_prototype
    : FUNCTION data_type_or_void function_identifier (LP (tf_port_list)? RP)?   # functionPrototype
    ;

dpi_import_export
    : IMPORT dpi_spec_string (dpi_function_import_property)? ( c_identifier ASSIGN)? dpi_function_proto SEMICOLON   # dpiImportExportImportFunction
    | IMPORT dpi_spec_string (dpi_task_import_property)? ( c_identifier ASSIGN)? dpi_task_proto SEMICOLON           # dpiImportExportImportTask
    | EXPORT dpi_spec_string ( c_identifier ASSIGN)? FUNCTION function_identifier SEMICOLON                         # dpiImportExportExportFunction
    | EXPORT dpi_spec_string ( c_identifier ASSIGN)? TASK task_identifier SEMICOLON                                 # dpiImportExportExportTask
    ;

dpi_spec_string
    : DPI_C         # dpiSpecStringC
    | DPI           # dpiSpecString
    ;

dpi_function_import_property
    : CONTEXT       # dpiFunctionImportPropertyContext
    | PURE          # dpiFunctionImportPropertyPure
    ;

dpi_task_import_property
    : CONTEXT       # dpiTaskImportProperty
    ;

dpi_function_proto
    : function_prototype    # dpiFunctionProto
    ;

dpi_task_proto
    : task_prototype        # dpiTaskProto
    ;

// A.2.7 Task declarations

task_declaration
    : TASK (lifetime)? task_body_declaration        # taskDeclaration
    ;

task_body_declaration
    : ( interface_identifier DOT | class_scope )? task_identifier SEMICOLON (tf_item_declaration)* (statement_or_null)* ENDTASK (COLON task_identifier)?        # taskBodyDeclaration
    | ( interface_identifier DOT | class_scope )? task_identifier LP (tf_port_list)? RP SEMICOLON (block_item_declaration)* (statement_or_null)* ENDTASK (COLON task_identifier)? # taskBodyDeclarationPorts
    ;

tf_item_declaration
    : block_item_declaration        # tfItemDeclarationBlock
    | tf_port_declaration           # tfItemDeclarationPort
    ;

tf_port_list
    : tf_port_item (COMMA tf_port_item)*    # tfPortList
    ;

// XXX FRED
tf_port_item
    : (attribute_instance)* (tf_port_direction)? (VAR)? data_type_or_implicit (port_identifier (variable_dimension)* (ASSIGN expression)?)? # tfPortItem
    | (attribute_instance)* (tf_port_direction)? (VAR)? port_identifier (variable_dimension)* (ASSIGN expression)? # tfPortItemImplicit
    ;

tf_port_direction
    : port_direction    # tfPortDirection
    | CONST REF         # tfPortDirectionRef
    ;

tf_port_declaration
    : (attribute_instance)* tf_port_direction (VAR)? data_type_or_implicit list_of_tf_variable_identifiers SEMICOLON # tfPortDeclaration
    | (attribute_instance)* tf_port_direction (VAR)? list_of_tf_variable_identifiers SEMICOLON # tfPortDeclarationImplicit
    ;

task_prototype
    : TASK task_identifier (LP(tf_port_list)?RP)?   # taskPrototype
    ;

// A.2.8 Block item declarations

block_item_declaration
    : (attribute_instance)* data_declaration                        # blockItemDeclarationData
    | (attribute_instance)* local_parameter_declaration SEMICOLON   # blockItemDeclarationLocalParam
    | (attribute_instance)* parameter_declaration SEMICOLON         # blockItemDeclarationParam
    | (attribute_instance)* let_declaration                         # blockItemDeclarationLet
    ;

// A.2.9 Interface declarations

modport_declaration
    : MODPORT modport_item (COMMA modport_item)* SEMICOLON      # modportDeclaration
    ;

modport_item
    : modport_identifier LP modport_ports_declaration (COMMA modport_ports_declaration)* RP     # modportItem
    ;

modport_ports_declaration
    : (attribute_instance)* modport_simple_ports_declaration    # modportsDeclarationSimple
    | (attribute_instance)* modport_tf_ports_declaration        # modportsDeclarationTF
    | (attribute_instance)* modport_clocking_declaration        # modportsDeclarationClocking
    ;

modport_clocking_declaration
    : CLOCKING clocking_identifier      # modportClockingDeclaration
    ;

modport_simple_ports_declaration
    : port_direction modport_simple_port (COMMA modport_simple_port)*   # modportSimplePortsDeclaration
    ;

modport_simple_port
    : port_identifier       # modportSimplePortIdentifier
    | DOT port_identifier LP (expression)? RP   # modportSimplePortExpression
    ;

modport_tf_ports_declaration
    : import_export modport_tf_port (COMMA modport_tf_port)*    # modportTfPortsDeclaration
    ;

modport_tf_port
    : method_prototype      # modportTfPortProto
    | tf_identifier         # modportTfPortIdentifier
    ;

import_export
    : IMPORT    # importExportImport
    | EXPORT    # importExportExport
    ;

// A.2.10 Assertion declarations

concurrent_assertion_item
    : ( block_identifier COLON)? concurrent_assertion_statement     # concurrentAssertionItem
    | checker_instantiation                                         # concurrentAssertionItemChecker
    ;

concurrent_assertion_statement
    : assert_property_statement         # concurrentAssertionStatementAssert
    | assume_property_statement         # concurrentAssertionStatementAssume
    | cover_property_statement          # concurrentAssertionStatementCover
    | cover_sequence_statement          # concurrentAssertionStatementCoverSequence
    | restrict_property_statement       # concurrentAssertionStatementRestrict
    ;

assert_property_statement
    : ASSERT PROPERTY LP property_spec RP action_block  # assertPropertyStatement
    ;

assume_property_statement
    : ASSUME PROPERTY LP property_spec RP action_block  # assumePropertyStatement
    ;

cover_property_statement
    : COVER PROPERTY LP property_spec RP statement_or_null  # coverPropertyStatement
    ;

expect_property_statement
    : EXPECT LP property_spec RP action_block   # expectPropertyStatement
    ;

cover_sequence_statement
    : COVER SEQUENCE LP (clocking_event)? (DISABLE IFF LP expression_or_dist RP)?  sequence_expr RP statement_or_null   # coverSequenceStatement
    ;

restrict_property_statement
    : RESTRICT PROPERTY LP property_spec RP SEMICOLON   # restrictPropertyStatement
    ;

property_instance
    : ps_or_hierarchical_property_identifier (LP (property_list_of_arguments)? RP)?     # propertyInstance
    ;

// FRED 16.12 First property_actual_arg not optional?
property_list_of_arguments
    : property_actual_arg (COMMA (property_actual_arg)?)? (COMMA DOT identifier LP (property_actual_arg)? RP)* # propertyListOfArgs
    | (COMMA (property_actual_arg)?)? (COMMA DOT identifier LP (property_actual_arg)? RP)*              # propertyListOfArgsNull
    | DOT identifier LP (property_actual_arg)? RP (COMMA DOT identifier LP (property_actual_arg)? RP)*  # propertyListOfArgsDot
    ;

property_actual_arg
    : property_expr         # propertyActualArgExpr
    | sequence_actual_arg   # propertyActualArgSequence
    ;

assertion_item_declaration
    : property_declaration      # assertionItemDeclarationProperty
    | sequence_declaration      # assertionItemDeclarationSequence
    | let_declaration           # assertionItemDeclarationLet
    ;

property_declaration
    : PROPERTY property_identifier (LP (property_port_list)? RP)? SEMICOLON (assertion_variable_declaration)* property_spec (SEMICOLON)?  ENDPROPERTY (COLON property_identifier )?     # propertyDeclaration
    ;

property_port_list
    : property_port_item (COMMA property_port_item)*    # propertyPortList
    ;

property_port_item
    : (attribute_instance)* (LOCAL (property_lvar_port_direction)?)? property_formal_type formal_port_identifier (variable_dimension)* (ASSIGN property_actual_arg)?    # propertyPortItem
    | (attribute_instance)* (LOCAL (property_lvar_port_direction)?)? formal_port_identifier (variable_dimension)* (ASSIGN property_actual_arg)?  # propertyPortItemImplicit
    ;

property_lvar_port_direction
    : INPUT         # propertyLvarPortDirection
    ;

property_formal_type
    : sequence_formal_type      # propertyFormalTypeSequence
    | PROPERTY                  # propertyFormalTypeProperty
    ;

property_spec
    : (clocking_event)? (DISABLE IFF LP expression_or_dist RP)? property_expr       # propertySpec
    ;

property_expr
    : sequence_expr                 # propertyExprSequence
    | STRONG LP sequence_expr RP    # propertyExprStrong
    | WEAK LP sequence_expr RP      # propertyExprWeak
    | LP property_expr RP           # propertyExprParends
    | LNOT property_expr            # propertyExprNot
    | property_expr LOR property_expr   # propertyExprOr
    | property_expr LAND property_expr  # propertyExprAnd
    | sequence_expr ODG property_expr   # propertyExprOverlappedImplication
    | sequence_expr OEG property_expr   # propertyExprNonoverlappedImplication
    | IF LP expression_or_dist RP property_expr (ELSE property_expr)?   # propertyExprIf
    | CASE LP expression_or_dist RP property_case_item (property_case_item)* ENDCASE    # propertyExprCase
    | sequence_expr PMP property_expr   # propertyExprOverlapped
    | sequence_expr PEP property_expr   # propertyExprNonoverlapped
    | NEXTTIME property_expr            # propertyExprNexttime
    | NEXTTIME (constant_expression)? property_expr # propertyExprNexttimeConst
    | S_NEXTTIME property_expr          # propertyExprSNexttime
    | S_NEXTTIME (constant_expression)? property_expr   # propertyExprSNexttimeConst
    | ALWAYS property_expr              # propertyExprAlways
    | ALWAYS (cycle_delay_const_range_expression)? property_expr    # propertyExprAlwaysDelay
    | S_ALWAYS constant_range? property_expr    # propertyExprSAlways
    | S_EVENTUALLY property_expr                # propertyExprSEventually
    | EVENTUALLY constant_range? property_expr  # propertyExprEventually
    | S_EVENTUALLY (cycle_delay_const_range_expression)? property_expr  # propertyExprSEventuallyDelay
    | property_expr UNTIL property_expr     # propertyExprUntil
    | property_expr S_UNTIL property_expr   # propertyExprSUntil
    | property_expr UNTIL_WITH property_expr    # propertyExprUntilWith
    | property_expr S_UNTIL_WITH property_expr  # propertyExprSUntilWith
    | property_expr IMPLIES property_expr       # propertyExprImplies
    | property_expr IFF property_expr           # propertyExprIff
    | ACCEPT_ON LP expression_or_dist RP property_expr  # propertyExprAcceptOn
    | REJECT_ON LP expression_or_dist RP property_expr  # propertyExprRejectOn
    | SYNC_ACCEPT_ON LP expression_or_dist RP property_expr # propertyExprSyncAcceptOn
    | SYNC_REJECT_ON LP expression_or_dist RP property_expr # propertyExprSyncRejectOn
    | property_instance     # propertyExprInstance
    | clocking_event property_expr  # propertyExprSyncClockingEvent
    ;

property_case_item
    : expression_or_dist (COMMA expression_or_dist)* COLON property_expr SEMICOLON   # propertyCaseItem
    | LDEFAULT (COLON)? property_expr SEMICOLON  # propertyCaseItemLDefault
    ;

sequence_declaration
    : SEQUENCE sequence_identifier (LP (sequence_port_list)? RP)? SEMICOLON (assertion_variable_declaration)* sequence_expr (SEMICOLON)?  ENDSEQUENCE (COLON sequence_identifier)?  # sequenceDeclaration
    ;

sequence_port_list
    : sequence_port_item (COMMA sequence_port_item)*    # sequencePortList
    ;

sequence_port_item
    : (attribute_instance)* (LOCAL (sequence_lvar_port_direction)?)? sequence_formal_type formal_port_identifier (variable_dimension)* (ASSIGN sequence_actual_arg)? # sequencePortItem
    | (attribute_instance)* (LOCAL (sequence_lvar_port_direction)?)? formal_port_identifier (variable_dimension)* (ASSIGN sequence_actual_arg)?  # sequencePortItemImplicit
    ;

sequence_lvar_port_direction
    : INPUT         # sequenceLvarPortDirectionInput
    | INOUT         # sequenceLvarPortDirectionInout
    | OUTPUT        # sequenceLvarPortDirectionOutput
    ;

sequence_formal_type
    :                           # sequenceFormalTypeImplicit
    | data_type_or_implicit     # sequenceFormalTypeData
    | SEQUENCE                  # sequenceFormalTypeSequence
    | UNTYPED                   # sequenceFormalTypeUntyped
    ;

sequence_expr
    : cycle_delay_range sequence_expr (cycle_delay_range sequence_expr)*    # sequenceExpr
    | sequence_expr cycle_delay_range sequence_expr (cycle_delay_range sequence_expr)*  # sequenceExprDelay
    | expression_or_dist (boolean_abbrev)?  # sequenceExprDist
    | sequence_instance (sequence_abbrev)?  # sequenceExprInstance
    | LP sequence_expr (COMMA sequence_match_item)* RP (sequence_abbrev)?   # sequenceExprParends
    | sequence_expr LAND sequence_expr  # sequenceExprAnd
    | sequence_expr INTERSECT sequence_expr # sequenceExprIntersect
    | sequence_expr LOR sequence_expr  # sequenceExprOr 
    | FIRST_MATCH LP sequence_expr (COMMA sequence_match_item)* RP  # sequenceExprFirstMatch
    | expression_or_dist THROUGHOUT sequence_expr   # sequenceExprThroughout
    | sequence_expr WITHIN sequence_expr    # sequenceExprWithin
    | clocking_event sequence_expr      # sequenceExprClockingEvent
    ;

cycle_delay_range
    : SHARP2 constant_primary       # cycleDelayRangeConstant
    | SHARP2 LB cycle_delay_const_range_expression RB       # cycleDelayRangeExpr
    | SHARP2 RSR        # cycleDelayRangeStar
    | SHARP2 RPR        # cycleDelayRangePlus
    ;

sequence_method_call
    : sequence_instance DOT method_identifier   # sequenceMethodCall
    ;

sequence_match_item
    : operator_assignment       # sequenceMatchItemOp
    | inc_or_dec_expression     # sequenceMatchItemExpr
    | subroutine_call           # sequenceMatchItemSubroutine
    ;

sequence_instance
    : ps_or_hierarchical_sequence_identifier (LP (sequence_list_of_arguments)? RP)?     # sequenceInstance
    ;

// FRED 16.12.1 First sequence_actual_arg not optional?
sequence_list_of_arguments
    : sequence_actual_arg (COMMA (sequence_actual_arg)? )* (COMMA DOT identifier LP (sequence_actual_arg)? RP)* # sequenceListOfArgs
    | (COMMA (sequence_actual_arg)? )* (COMMA DOT identifier LP (sequence_actual_arg)? RP)*             # sequenceListOfArgsNull
    | DOT identifier LP (sequence_actual_arg)? RP (COMMA DOT identifier LP (sequence_actual_arg)? RP)*  # sequenceListOfArgsDot
    ;

sequence_actual_arg
    : event_expression  # sequenceActualArgEvent
    | sequence_expr     # sequenceActualArgExpr
    ;

boolean_abbrev
    : consecutive_repetition        # booleanAbbrevConsecutive
    | non_consecutive_repetition    # booleanAbbrevNonconsecutive
    | goto_repetition               # booleanAbbrevGoto
    ;

sequence_abbrev
    : consecutive_repetition        # sequenceAbbrev
    ;

consecutive_repetition
    : LB_STAR const_or_range_expression RB  # consecutiveRepetitionExpr
    | RSR                                   # consecutiveRepetitionRsr
    | RPR                                   # consecutiveRepetitionRpr
    ;

non_consecutive_repetition
    : LB ASSIGN const_or_range_expression RB    # nonConsecutiveRepetition
    ;

goto_repetition
    : LB MINUS_GT const_or_range_expression RB  # gotoRepetition
    ;

const_or_range_expression
    : constant_expression                   # constOrRangeExpressionExpr
    | cycle_delay_const_range_expression    # constOrRangeExpressionDelay
    ;

cycle_delay_const_range_expression
    : constant_expression COLON constant_expression # cycleDelayConstRangeExpressionColon
    | constant_expression COLON DS  # cycleDelayConstRangeExpressionDollarSign
    ;

expression_or_dist
    : expression (DIST LS dist_list RS)?    # expressionOrDist
    ;

assertion_variable_declaration
    : var_data_type list_of_variable_decl_assignments SEMICOLON     # assertionVariableDeclaration
    ;

// A.2.11 Covergroup declarations

covergroup_declaration
    : COVERGROUP covergroup_identifier (LP (tf_port_list)? RP)? (coverage_event)? SEMICOLON (coverage_spec_or_option)* ENDGROUP (COLON covergroup_identifier)?      # covergroupDeclaration
    ;

coverage_spec_or_option
    : (attribute_instance)* coverage_spec               # coverageSpecOrOptionSpec
    | (attribute_instance)* coverage_option SEMICOLON   # coverageSpecOrOptionOption
    ;

coverage_option
    : OPTION member_identifier ASSIGN expression        # coverageOptionExpr
    | TYPE_OPTION member_identifier ASSIGN constant_expression      # coverageOptionConstant
    ;

coverage_spec
    : cover_point       # coverageSpecCoverPoint
    | cover_cross       # coverageSpecCoverCross
    ;

// FRED sample should be a reserved word?
coverage_event
    : clocking_event        # coverageEventClocking
    | WITH FUNCTION_SAMPLE LP (tf_port_list)? RP    # coverageEventFunction
    | AT2 LP block_event_expression RP  # coverageEventAt2
    ;

block_event_expression
    : block_event_expression LOR block_event_expression # blockEventExpression
    | BEGIN hierarchical_btf_identifier # blockEventExpressionBegin
    | END hierarchical_btf_identifier   # blockEventExpressionEnd
    ;

hierarchical_btf_identifier
    : hierarchical_tf_identifier    # hierarchicalBtfIdentifierTf
    | hierarchical_block_identifier # hierarchicalBtfIdentifierBlock
    | (hierarchical_identifier DOT | class_scope)? method_identifier    # hierarchicalBtfIdentifierMethod
    ;

cover_point
    : ((data_type_or_implicit)? cover_point_identifier COLON)? COVERPOINT expression (IFF LP expression RP)?  bins_or_empty # coverPoint
    | ((data_type_or_implicit)? cover_point_identifier COLON)? COVERPOINT expression (IFF LP expression RP)?  # coverPointNull
    ;

bins_or_empty
    : LS (attribute_instance)* (bins_or_options SEMICOLON)* RS  # binsOrEmptyBins
    | SEMICOLON     # binsOrEmptyEmpty
    ;

bins_or_options
    : coverage_option   # binsOrOptionsCoverage
    | (WILDCARD)? bins_keyword bin_identifier (LB (covergroup_expression)? RB)? ASSIGN LS covergroup_range_list RS (WITH LP with_covergroup_expression RP)?  (IFF LP expression RP)?    # binsOrOptionsCoverGroup
    | (WILDCARD)? bins_keyword bin_identifier (LB (covergroup_expression)? RB)? ASSIGN cover_point_identifier (WITH LP with_covergroup_expression RP)? (IFF LP expression RP)?  # binsOrOptionsCoverPoint
    | (WILDCARD)? bins_keyword bin_identifier (LB (covergroup_expression)? RB)? ASSIGN set_covergroup_expression (IFF LP expression RP)? # binsOrOptionsCoverGroupExpr
    | (WILDCARD)? bins_keyword  bin_identifier (LB RB)? ASSIGN trans_list (IFF LP expression RP)?   # binsOrOptionsTransList
    | bins_keyword bin_identifier (LB (covergroup_expression)? RB)? ASSIGN LDEFAULT (IFF LP expression RP)? # binsOrOptionsAssign
    | bins_keyword bin_identifier ASSIGN LDEFAULT SEQUENCE (IFF LP expression RP)?  # binsOrOptionsSequence
    ;

bins_keyword
    : BINS              # binsKeywordBins
    | ILLEGAL_BINS      # binsKeywordIllegalBins
    | IGNORE_BINS       # binsKeywordIgnoreBins
    ;

trans_list
    : LP trans_set RP (COMMA LP trans_set RP)*      # transList
    ;

trans_set
    : trans_range_list (EQUALS_GT trans_range_list )*   # transSet
    ;

trans_range_list
    : trans_item                            # transRangeListItem
    | trans_item LB_STAR repeat_range RB    # transRangeListStar
    | trans_item RDG repeat_range RB        # transRangeListRdg
    | trans_item LB_EQUALS repeat_range RB  # transRangeListEquals
    ;

trans_item
    : covergroup_range_list     # transItem
    ;

repeat_range
    : covergroup_expression     # repeatRange
    | covergroup_expression COLON covergroup_expression # repeatRangeColon
    ;

cover_cross
    : (cross_identifier COLON)? CROSS list_of_cross_items (IFF LP expression RP)? cross_body    # coverCross
    ;

list_of_cross_items
    : cross_item COMMA cross_item (COMMA cross_item)*   # listOfCrossItems
    ;

cross_item
    : cover_point_identifier    # crossItemCoverPoint
    | variable_identifier       # crossItemVariable
    ;

cross_body
    : LS (cross_body_item SEMICOLON)* RS    # crossBody
    | SEMICOLON                             # crossBodyEmpty
    ;

// FRED extra SEMICOLON on bins_selection_or_option
cross_body_item
    : function_declaration          # crossBodyItemFunction
    | bins_selection_or_option      # crossBodyItemBins
    ;

bins_selection_or_option
    : (attribute_instance)* coverage_option     # binsSelectionOrOptionCoverage
    | (attribute_instance)* bins_selection ASSIGN select_expression (IFF LP expression RP)? # binsSelectionOrOptionBins
    ;

bins_selection
    : bins_keyword bin_identifier   # binsSelection
    ;

select_expression
    : select_condition      # selectExpression
    | BANG select_condition # selectExpressionNot
    | select_expression AND2 select_expression  # selectExpressionAnd
    | select_expression OR2 select_expression   # selectExpressionOr
    | LP select_expression RP   # selectExpressionParends
    | select_expression WITH LP with_covergroup_expression RP (MATCHES integer_covergroup_expression)?  # selectExpressionWith
    | cross_identifier  # selectExpressionCrossIdentifier
    | cross_set_expression (MATCHES integer_covergroup_expression)? # selectExpressionCrossSet
    ;

select_condition
    : BINSOF LP bins_expression RP (INTERSECT LS covergroup_range_list RS)?     # selectCondition
    ;

bins_expression
    : variable_identifier       # binsExpressionVariable
    | cover_point_identifier (DOT bin_identifier)?  # binsExpressionCoverPoint
    ;

covergroup_range_list
    : covergroup_value_range (COMMA covergroup_value_range)*    # covergroupRangeList
    ;

covergroup_value_range
    : covergroup_expression     # covergroupValueRange
    | LB covergroup_expression COLON covergroup_expression RB   # covergroupValueRangeColon
    ;

with_covergroup_expression
    : covergroup_expression     # withCovergroupExpression
    ;

set_covergroup_expression
    : covergroup_expression     # setCovergroupExpression
    ;

integer_covergroup_expression
    : covergroup_expression     # integerCovergroupExpression
    ;

cross_set_expression
    : covergroup_expression     # crossSetExpression
    ;

covergroup_expression
    : expression                # covergroupExpression
    ;

// A.2.12 Let declarations

let_declaration
    : LET let_identifier (LP let_port_list? RP)? ASSIGN expression SEMICOLON    # letDeclaration
    ;

let_identifier
    : identifier    # letIdentifier
    ;

let_port_list
    : let_port_item (COMMA let_port_item)*      # letPortList
    ;

let_port_item
    : (attribute_instance)* let_formal_type formal_port_identifier (variable_dimension)* (ASSIGN expression)?   # letPortItem
    | (attribute_instance)* formal_port_identifier (variable_dimension)* (ASSIGN expression)?       # letPortItemImplicit
    ;

let_formal_type
    :                           # letFormalTypeImplicit
    | data_type_or_implicit     # letFormalTypeData
    | UNTYPED                   # letFormalTypeUntyped
    ;

let_expression
    : (package_scope)? let_identifier (LP(let_list_of_arguments)?RP)?   # letExpression
    ;

// FRED 11.13 First let_actual_arg not optional?
let_list_of_arguments
    : let_actual_arg (COMMA (let_actual_arg)? )* (COMMA DOT identifier LP (let_actual_arg)? RP)*    # letListOfArguments
    | (COMMA (let_actual_arg)? )* (COMMA DOT identifier LP (let_actual_arg)? RP)*               # letListOfArgumentsNull
    | DOT identifier LP (let_actual_arg)? RP (COMMA DOT identifier LP (let_actual_arg)? RP)*    # letListOfArgumentsDot
    ;

let_actual_arg
    : expression        # letActualArg
    ;

// A.3 Primitive instances
// A.3.1 Primitive instantiation and instances

gate_instantiation
    : cmos_switchtype (delay3)? cmos_switch_instance (COMMA cmos_switch_instance)* SEMICOLON    # gateInstantiationCmos
    | enable_gatetype (drive_strength)? (delay3)? enable_gate_instance (COMMA enable_gate_instance)* SEMICOLON  # gateInstantiationEnable
    | mos_switchtype (delay3)? mos_switch_instance (COMMA mos_switch_instance)* SEMICOLON   # gateInstantiationMos
    | n_input_gatetype (drive_strength)? (delay2)? n_input_gate_instance (COMMA n_input_gate_instance)* SEMICOLON   # gateInstantiationNInput
    | n_output_gatetype (drive_strength)? (delay2)? n_output_gate_instance (COMMA n_output_gate_instance)* SEMICOLON    # gateInstantiationNOutput
    | pass_en_switchtype (delay2)? pass_enable_switch_instance (COMMA pass_enable_switch_instance)* SEMICOLON   # gateInstantiationPassEn
    | pass_switchtype pass_switch_instance (COMMA pass_switch_instance)* SEMICOLON  # gateInstantiationPass
    | PULLDOWN (pulldown_strength)? pull_gate_instance (COMMA pull_gate_instance)* SEMICOLON    # gateInstantiationPulldown
    | PULLUP (pullup_strength)? pull_gate_instance (COMMA pull_gate_instance)* SEMICOLON    # gateInstantiationPullup
    ;

cmos_switch_instance
    : (name_of_instance)? LP output_terminal COMMA input_terminal COMMA ncontrol_terminal COMMA pcontrol_terminal RP    # cmosSwitchInstance
    ;

enable_gate_instance
    : (name_of_instance)? LP output_terminal COMMA input_terminal COMMA enable_terminal RP  # enableGateInstance
    ;

mos_switch_instance
    : (name_of_instance)? LP output_terminal COMMA input_terminal COMMA enable_terminal RP  # mosSwitchInstance
    ;

n_input_gate_instance
    : (name_of_instance)? LP output_terminal COMMA input_terminal (COMMA input_terminal)* RP    # nInputGateInstance
    ;

n_output_gate_instance
    : (name_of_instance)? LP output_terminal (COMMA output_terminal)* COMMA input_terminal RP   # nOutputGateInstance
    ;

pass_switch_instance
    : (name_of_instance)? LP inout_terminal COMMA inout_terminal RP # passSwitchInstance
    ;

pass_enable_switch_instance
    : (name_of_instance)? LP inout_terminal COMMA inout_terminal COMMA enable_terminal RP   # passEnableSwitchInstance
    ;

pull_gate_instance
    : (name_of_instance)? LP output_terminal RP     # pullGateInstance
    ;

// A.3.2 Primitive strengths

pulldown_strength
    : LP strength0 COMMA strength1 RP   # pulldownStrength01
    | LP strength1 COMMA strength0 RP   # pulldownStrength10
    | LP strength0 RP                   # pulldownStrength0
    ;

pullup_strength
    : LP strength0 COMMA strength1 RP   # pullupStrength01
    | LP strength1 COMMA strength0 RP   # pullupStrength10
    | LP strength1 RP                   # pullupStrength1
    ;

// A.3.3 Primitive terminals

enable_terminal
    : expression    # enableTerminal
    ;

inout_terminal
    : net_lvalue    # inoutTerminal
    ;

input_terminal
    : expression    # inputTerminal
    ;

ncontrol_terminal
    : expression    # ncontrolTerminal
    ;

output_terminal
    : net_lvalue    # outputTerminal
    ;

pcontrol_terminal
    : expression    # pcontrolTerminal
    ;

// A.3.4 Primitive gate and switch types

cmos_switchtype
    : CMOS      # cmosSwitchTypeCmos
    | RCMOS     # cmosSwitchTypeRcmos
    ;

enable_gatetype
    : BUFIF0    # enableGatetypeBuf0
    | BUFIF1    # enableGatetypeBuf1
    | NOTIF0    # enableGatetypeNot0
    | NOTIF1    # enableGatetypeNot1
    ;

mos_switchtype
    : NMOS      # mostSwitchTypeNmos
    | PMOS      # mostSwitchTypePmos
    | RNMOS     # mostSwitchTypeRnmos
    | RPMOS     # mostSwitchTypeRpmos
    ;

n_input_gatetype
    : LAND      # nInputGatetypeAnd
    | NAND      # nInputGatetypeNand
    | LOR       # nInputGatetypeOr
    | NOR       # nInputGatetypeNor
    | XOR       # nInputGatetypeXor
    | XNOR      # nInputGatetypeXnor
    ;

n_output_gatetype
    : BUF       # nOutputGatetypeBuf
    | LNOT      # nOutputGatetypeNot
    ;

pass_en_switchtype
    : TRANIF0   # passEnSwitchTypeTran0
    | TRANIF1   # passEnSwitchTypeTran1
    | RTRANIF0  # passEnSwitchTypeRtran0
    | RTRANIF1  # passEnSwitchTypeRtran1
    ;

pass_switchtype
    : TRAN      # passSwitchtypeTran
    | RTRAN     # passSwitchtypeRtran
    ;

// A.4 Instantiations
// A.4.1 Instantiation
// A.4.1.1 Module instantiation

module_instantiation
    : module_identifier (parameter_value_assignment)? hierarchical_instance (COMMA hierarchical_instance)* SEMICOLON    # moduleInstantiation
    ;

parameter_value_assignment
    : SHARP LP (list_of_parameter_assignments)? RP      # parameterValueAssignment
    ;

list_of_parameter_assignments
    : ordered_parameter_assignment (COMMA ordered_parameter_assignment)*    # listOfParameterAssignmentsOrdered
    | named_parameter_assignment (COMMA named_parameter_assignment)*        # listOfParameterAssignmentsNamed
    ;

ordered_parameter_assignment
    : param_expression          # orderedParameterAssignment
    ;

named_parameter_assignment
    : DOT parameter_identifier LP (param_expression)? RP    # namedParameterAssignment
    ;

hierarchical_instance
    : name_of_instance LP (list_of_port_connections)? RP    # hierarchicalInstance
    ;

name_of_instance
    : instance_identifier (unpacked_dimension)*         # nameOfInstance
    ;

list_of_port_connections
    : ordered_port_connection (COMMA ordered_port_connection)*  # listOfPortConnectionsOrdered
    | named_port_connection (COMMA named_port_connection)*      # listOfPortConnectionsNamed
    ;

// FRED 23.3.2.1 expression not optional?
ordered_port_connection
    : (attribute_instance)* expression  # orderedPortConnection
    | (attribute_instance)*             # orderedPortConnectionNull
    ;

named_port_connection
    : (attribute_instance)* DOT port_identifier (LP (expression)? RP)?  # namedPortConnectionId
    | (attribute_instance)* DOT_STAR                                    # namedPortConnectionAll
    ;

// A.4.1.2 Interface instantiation
interface_instantiation
    : interface_identifier (parameter_value_assignment)? hierarchical_instance (COMMA hierarchical_instance)* SEMICOLON # interfaceInstantiation
    ;

// A.4.1.3 Program instantiation

program_instantiation
    : program_identifier (parameter_value_assignment)? hierarchical_instance (COMMA hierarchical_instance)* SEMICOLON   # programInstantiation
    ;

// A.4.1.4 Checker instantiation

checker_instantiation
    : ps_checker_identifier name_of_instance LP (list_of_checker_port_connections)? RP SEMICOLON    # checkerInstantiation
    ;

list_of_checker_port_connections
    : ordered_checker_port_connection (COMMA ordered_checker_port_connection)*      # listOfCheckerPortConnectionsOrdered
        | named_checker_port_connection (COMMA named_checker_port_connection)*      # listOfCheckerPortConnectionsNamed
    ;

// FRED 17.3 Is property_actual_arg optional?
ordered_checker_port_connection
    : (attribute_instance)* property_actual_arg # orderedCheckerPortConnection
    | (attribute_instance)*                     # orderedCheckerPortConnectionNull
    ;

named_checker_port_connection
    : (attribute_instance)* DOT formal_port_identifier (LP (property_actual_arg)? RP)?  # namedCheckerPortConnectionIdentifier
    | (attribute_instance)* DOT_STAR        # namedCheckerPortConnectionStar
    ;

// A.4.2 Generated instantiation

generate_region
    : GENERATE (generate_item)* ENDGENERATE     # generateRegion
    ;

loop_generate_construct
    : FOR LP genvar_initialization SEMICOLON genvar_expression SEMICOLON genvar_iteration RP generate_block     # loopGenerateConstruct
    ;

genvar_initialization
    : (GENVAR)? genvar_identifier ASSIGN constant_expression    # genvarInitialization
    ;

genvar_iteration
    : genvar_identifier assignment_operator genvar_expression   # genvarIterationAssign
    | inc_or_dec_operator genvar_identifier                     # genvarIterationPreIncOrDec
    | genvar_identifier inc_or_dec_operator                     # genvarIterationPostIncOrDec
    ;

conditional_generate_construct
    : if_generate_construct         # conditionalGenerateConstructIf
    | case_generate_construct       # conditionalGenerateConstructCase
    ;

if_generate_construct
    : IF LP constant_expression RP generate_block (ELSE generate_block)?    # ifGenerateConstruct
    ;

case_generate_construct
    : CASE LP constant_expression RP case_generate_item (case_generate_item)* ENDCASE   # caseGenerateConstruct
    ;

case_generate_item
    : constant_expression (COMMA constant_expression)* COLON generate_block     # caseGenerateItemExpression
    | LDEFAULT (COLON)? generate_block          # caseGenerateItemBlock
    ;

generate_block
    : generate_item     # generateBlockItem
    | (generate_block_identifier COLON)? BEGIN (COLON generate_block_identifier)? (generate_item)* END (COLON generate_block_identifier)? # generateBlockItemBegin
    ;

generate_item
    : module_or_generate_item       # generateItemModuleOrGenerate
    | interface_or_generate_item    # generateItemInterfaceOrGenerate
    | checker_or_generate_item      # generateItemCheckerOrGenerate
    ;

// A.5 UDP declaration and instantiation
// A.5.1 UDP declaration

udp_nonansi_declaration
    : (attribute_instance)* PRIMITIVE udp_identifier LP udp_port_list RP SEMICOLON  # udpNonansiDeclaration
    ;

udp_ansi_declaration
    : (attribute_instance)* PRIMITIVE udp_identifier LP udp_declaration_port_list RP SEMICOLON  # udpAnsiDeclaration
    ;

udp_declaration
    : udp_nonansi_declaration udp_port_declaration (udp_port_declaration)* udp_body ENDPRIMITIVE (COLON udp_identifier)?    # udpDeclarationNonansi
    | udp_ansi_declaration udp_body ENDPRIMITIVE (COLON udp_identifier)?    # udpDeclarationAnsi
    | EXTERN udp_nonansi_declaration    # udpDeclarationExternNonansi
    | EXTERN udp_ansi_declaration   # udpDeclarationExternAnsi
    | (attribute_instance)* PRIMITIVE udp_identifier LP DOT_STAR RP SEMICOLON (udp_port_declaration)* udp_body ENDPRIMITIVE (COLON udp_identifier)? # udpDeclarationStar
    ;

// A.5.2 UDP ports

udp_port_list
    : output_port_identifier COMMA input_port_identifier (COMMA input_port_identifier)* # udpPortList
    ;

udp_declaration_port_list
    : udp_output_declaration COMMA udp_input_declaration (COMMA udp_input_declaration)* # udpDeclarationPortList
    ;

udp_port_declaration
    : udp_output_declaration SEMICOLON      # udpPortDeclarationOutput
    | udp_input_declaration SEMICOLON       # udpPortDeclarationInput
    | udp_reg_declaration SEMICOLON         # udpPortDeclarationReg
    ;

udp_output_declaration
    : (attribute_instance)* OUTPUT port_identifier      # udpOutputDeclarationOut
    | (attribute_instance)* OUTPUT REG port_identifier (ASSIGN constant_expression)?    # udpOutputDeclarationOutReg
    ;

udp_input_declaration
    : (attribute_instance)* INPUT list_of_udp_port_identifiers  # udpInputDeclaration
    ;

udp_reg_declaration
    : (attribute_instance)* REG variable_identifier # udpRegDeclaration
    ;

// A.5.3 UDP body

udp_body
    : combinational_body    # udpBodyCombination
    | sequential_body       # udpBodySequential
    ;

combinational_body
    : TABLE combinational_entry (combinational_entry)* ENDTABLE     # combinationalBody
    ;

combinational_entry
    : level_input_list COLON output_symbol SEMICOLON    # combinationalEntry
    ;

sequential_body
    : udp_initial_statement? TABLE sequential_entry (sequential_entry)* ENDTABLE    # sequentialBody
    ;

udp_initial_statement
    : INITIAL output_port_identifier ASSIGN init_val SEMICOLON  # udpInitialStatement
    ;

init_val
    : Single_Bit_Zero   # initValBit0
    | Single_Bit_One    # initValBit1
    | Single_Bit_X      # initValBitX
    | Zero              # initVal0
    | One               # initVal1
    ;

sequential_entry
    : seq_input_list COLON current_state COLON next_state SEMICOLON     # sequentialEntry
    ;

seq_input_list
    : level_input_list  # seqInputListLevel
    | edge_input_list   # seqInputListEdge
    ;

level_input_list
    : level_symbol (level_symbol)*  # levelInputList
    ;

edge_input_list
    : (level_symbol)* edge_indicator (level_symbol)*    # edgeInputList
    ;

edge_indicator
    : LP level_symbol level_symbol RP   # edgeIndicatorLevel
    | edge_symbol                       # edgeIndicatorEdge
    ;

current_state
    : level_symbol      # currentState
    ;

next_state
    : output_symbol     # nextStateSymbol
    | MINUS             # nextStateMinus
    ;

output_symbol
    : Zero          # outputSymbol0
    | One           # outputSymbol1
    | X             # outputSymbolX
    ;

binary_symbol
    : B             # binarySymbol
    ;

level_symbol
    : output_symbol # levelSymbolOutput
    | binary_symbol # levelSymbolBinary
    | QUESTION_MARK # levelSymbolQuestionMark
    ;

edges_symbol
    : R     # edgesSymbolRising
    | F     # edgesSymbolFalling
    | P     # edgesSymbolPositive
    | N     # edgesSymbolNegative
    ;

edge_symbol
    : STAR  # edgeSymbolStar
    ;

// A.5.4 UDP instantiation
udp_instantiation
    : udp_identifier (drive_strength)? (delay2)? udp_instance (COMMA udp_instance)* SEMICOLON   # udpInstantiation
    ;

udp_instance
    : (name_of_instance)? LP output_terminal COMMA input_terminal (COMMA input_terminal)* RP    # udpInstance
    ;

// A.6 Behavioral statements
// A.6.1 Continuous assignment and net alias statements

continuous_assign
    : LASSIGN (drive_strength)? (delay3)? list_of_net_assignments SEMICOLON     # continuousAssignNet
    | LASSIGN (delay_control)? list_of_variable_assignments SEMICOLON           # continuousAssignVariable
    ;

list_of_net_assignments
    : net_assignment (COMMA net_assignment)*    # listOfNetAssignments
    ;

list_of_variable_assignments
    : variable_assignment (COMMA variable_assignment)*  # listOfVariableAssignments
    ;

net_alias
    : ALIAS net_lvalue ASSIGN net_lvalue (ASSIGN net_lvalue)* SEMICOLON     # netAlias
    ;

net_assignment
    : net_lvalue ASSIGN expression  # netAssignment
    ;

// A.6.2 Procedural blocks and assignments

initial_construct
    : INITIAL statement_or_null     # initialConstruct
    ;

always_construct
    : always_keyword statement      # alwaysConstruct
    ;

always_keyword
    : ALWAYS            # alwaysKeyword
    | ALWAYS_COMB       # alwaysKeywordComb
    | ALWAYS_LATCH      # alwaysKeywordLatch
    | ALWAYS_FF         # alwaysKeywordFlipFlop
    ;

final_construct
    : FINAL function_statement  # finalConstruct
    ;

// FRED 10.4.1 delay_or_event_control is optional
blocking_assignment
    : variable_lvalue ASSIGN (delay_or_event_control)? expression   # blockingAssignmentExpr
    | nonrange_variable_lvalue ASSIGN dynamic_array_new             # blockingAssignmentDynamicArray
    | ( implicit_class_handle DOT | class_scope | package_scope )? hierarchical_variable_identifier select ASSIGN class_new # blockingAssignmentClass
    | operator_assignment   # blockingAssignmentOperator
    ;

operator_assignment
    : variable_lvalue assignment_operator expression    # operatorAssignment
    ;

assignment_operator
    : ASSIGN            # assignmentOperator
    | PLUS_EQUALS       # assignmentOperatorPlus
    | MINUS_EQUALS      # assignmentOperatorMinus
    | STAR_EQUALS       # assignmentOperatorMultiply
    | SLASH_EQUALS      # assignmentOperatorDivide
    | MODULO_EQUALS     # assignmentOperatorModulo
    | AND_EQUALS        # assignmentOperatorAnd
    | OR_EQUALS         # assignmentOperatorOr
    | CARET_EQUALS      # assignmentOperatorXor
    | LS2E              # assignmentOperatorLogicalLeftShift
    | RS2E              # assignmentOperatorLogicalRightShift
    | LS3E              # assignmentOperatorArithmeticLeftShift
    | RS3E              # assignmentOperatorArithmeticRightShift
    ;

nonblocking_assignment
    : variable_lvalue LE (delay_or_event_control)? expression   # nonblockingAssignment
    ;

procedural_continuous_assignment
    : LASSIGN variable_assignment   # proceduralContinuousAssignment
    | DEASSIGN variable_lvalue      # proceduralContinuousAssignmentDeassign
    | FORCE variable_assignment     # proceduralContinuousAssignmentForceVariable
    | FORCE net_assignment          # proceduralContinuousAssignmentForceNet
    | RELEASE variable_lvalue       # proceduralContinuousAssignmentReleaseVariable
    | RELEASE net_lvalue            # proceduralContinuousAssignmentReleaseNet
    ;

variable_assignment
    : variable_lvalue ASSIGN expression     # variableAssignment
    ;

// A.6.3 Parallel and sequential blocks

action_block
    : statement_or_null                     # actionBlock
    | (statement)? ELSE statement_or_null   # actionBlockElse
    ;

seq_block
    : BEGIN (COLON block_identifier)? (block_item_declaration)* (statement_or_null)* END (COLON block_identifier)?  # seqBlock
    ;

par_block
    : FORK (COLON block_identifier)? (block_item_declaration)* (statement_or_null)* join_keyword (COLON block_identifier)? # parBlock
    ;

join_keyword
    : JOIN          # joinKeyword
    | JOIN_ANY      # joinKeywordAny
    | JOIN_NONE     # joinKeywordNone
    ;

// A.6.4 Statements

statement_or_null
    : statement                         # statementOrNullStatement
    | (attribute_instance)* SEMICOLON   # statementOrNullNull
    ;

statement
    : (block_identifier COLON)? (attribute_instance)* statement_item    # statementRule
    ;

statement_item
    : blocking_assignment SEMICOLON                 # statementItemBlocking
    | nonblocking_assignment SEMICOLON              # statementItemNonBlocking
    | procedural_continuous_assignment SEMICOLON    # statementItemProcedural
    | case_statement                                # statementItemCase
    | conditional_statement                         # statementItemConditional
    | inc_or_dec_expression SEMICOLON               # statementItemIncOrDec
    | subroutine_call_statement                     # statementItemSubroutine
    | disable_statement                             # statementItemDisable
    | event_trigger                                 # statementItemEvent
    | loop_statement                                # statementItemLoop
    | jump_statement                                # statementItemJump
    | par_block                                     # statementItemPar
    | procedural_timing_control_statement           # statementItemTiming
    | seq_block                                     # statementItemSeq
    | wait_statement                                # statementItemWait
    | procedural_assertion_statement                # statementItemAssert
    | clocking_drive SEMICOLON                      # statementItemClocking
    | randsequence_statement                        # statementItemRandsequence
    | randcase_statement                            # statementItemRandcase
    | expect_property_statement                     # statementItemExpect
    | (procedural_timing_control_statement)? elaboration_system_task   # statementItemElabTask    // XXX FRED
    ;

function_statement
    : statement         # functionStatement
    ;

function_statement_or_null
    : function_statement                # functionStatementOrNullFunction
    | (attribute_instance)* SEMICOLON   # functionStatementOrNullNull
    ;

variable_identifier_list
    : variable_identifier (COMMA variable_identifier)*  # variableIdentifierList
    ;

// A.6.5 Timing control statements

procedural_timing_control_statement
    : procedural_timing_control statement_or_null   # proceduralTimingControlStatement
    ;

delay_or_event_control
    : delay_control                             # delayOrEventControlDelay
    | event_control                             # delayOrEventControlEvent
    | REPEAT LP expression RP event_control     # delayOrEventControlRepeat
    ;

delay_control
    : SHARP delay_value                         # delayControl
    | SHARP LP mintypmax_expression RP          # delayControlExpr
    ;

event_control
    : AT hierarchical_event_identifier          # eventControlAt
    | AT LP event_expression RP                 # eventControlAtExpr
    | AT_STAR                                   # eventControlAtStar
    | AT PSTARP                                 # eventControlAtParendStar
    | AT ps_or_hierarchical_sequence_identifier # eventControlAtHierarhical
    ;

event_expression
    : (edge_identifier)? expression (IFF expression)?   # eventExpression
    | sequence_instance (IFF expression)?               # eventExpressionSequence
    | event_expression LOR event_expression             # eventExpressionOr
    | event_expression COMMA event_expression           # eventExpressionComma
    | LP event_expression RP                            # eventExpressionParends
    ;

procedural_timing_control
    : delay_control         # proceduralTimingControlDelay
    | event_control         # proceduralTimingControlEvent
    | cycle_delay           # proceduralTimingControlCycle
    ;

jump_statement
    : RETURN (expression)? SEMICOLON        # jumpStatementReturn
    | BREAK SEMICOLON                       # jumpStatementBreak
    | CONTINUE SEMICOLON                    # jumpstatementContinue
    ;

wait_statement
    : WAIT LP expression RP statement_or_null   # waitStatement
    | WAIT FORK SEMICOLON                       # waitStatementFork
    | WAIT_ORDER LP hierarchical_identifier (COMMA hierarchical_identifier)* RP action_block    # waitStatementOrder
    ;

event_trigger
    : MINUS_GT hierarchical_event_identifier SEMICOLON      # eventTriggerMinusGt
    | ODGG (delay_or_event_control)? hierarchical_event_identifier SEMICOLON    # eventTriggerOdgg
    ;

disable_statement
    : DISABLE hierarchical_task_identifier SEMICOLON    # disableStatementTask
    | DISABLE hierarchical_block_identifier SEMICOLON   # disableStatementBlock
    | DISABLE FORK SEMICOLON                            # disableStatementFork
    ;

// A.6.6 Conditional statements

conditional_statement
    : (unique_priority)? IF LP cond_predicate RP statement_or_null (ELSE IF LP cond_predicate RP statement_or_null)* (ELSE statement_or_null)?  # conditionalStatement
    ;

unique_priority
    : UNIQUE        # uniquePriorityUnique
    | UNIQUE0       # uniquePriorityUnique0
    | PRIORITY      # uniquePriorityPriority
    ;

cond_predicate
    : expression_or_cond_pattern (AND3 expression_or_cond_pattern)*     # condPredicate
    ;

expression_or_cond_pattern
    : expression                    # expressionOrCondPattern
    | expression MATCHES pattern    # expressionOrCondPatternMatches
    ;

cond_pattern
    : expression MATCHES pattern    # condPattern
    ;

// A.6.7 Case statements

case_statement
    : (unique_priority)? case_keyword LP case_expression RP case_item (case_item)* ENDCASE      # caseStatement
    | (unique_priority)? case_keyword LP case_expression RP MATCHES case_pattern_item (case_pattern_item)* ENDCASE # caseStatementMatches
    | (unique_priority)? CASE LP case_expression RP INSIDE case_inside_item (case_inside_item)* ENDCASE # caseStatementInside
    ;

case_keyword
    : CASE      # caseKeyword
    | CASEZ     # caseKeywordZ
    | CASEX     # caseKeywordX
    ;

case_expression
    : expression    # caseExpression
    ;

case_item
    : case_item_expression (COMMA case_item_expression)* COLON statement_or_null    # caseItem
    | LDEFAULT (COLON)? statement_or_null       # caseItemDefault
    ;

case_pattern_item
    : pattern (AND3 expression)? COLON statement_or_null    # casePatternItem
    | LDEFAULT (COLON)? statement_or_null       # casePatternItemDefault
    ;

case_inside_item
    : open_range_list COLON statement_or_null   # caseInsideItem
    | LDEFAULT (COLON)? statement_or_null       # caseInsideItemDefault
    ;

case_item_expression
    : expression        # caseItemExpression
    ;

randcase_statement
    : RANDCASE randcase_item (randcase_item)* ENDCASE   # randcaseStatement
    ;

randcase_item
    : expression COLON statement_or_null    # randcaseItem
    ;

open_range_list
    : open_value_range (COMMA open_value_range)*    # openRangeList
    ;

open_value_range
    : value_range       # openValueRange
    ;

// A.6.7.1 Patterns

pattern
    : DOT variable_identifier   # patternVariable
    | DOT_STAR                  # patternStar
    | constant_expression       # patternExpr
    | TAGGED member_identifier (pattern)?   # patternTagged
    | TICK_S  pattern (COMMA pattern)* RS   # patternTickSPattern
    | TICK_S member_identifier COLON pattern (COMMA member_identifier COLON pattern )* RS   # patternTickSMember
    ;

assignment_pattern
    : TICK_S expression (COMMA expression)* RS  # assignmentPatternExpr
    | TICK_S structure_pattern_key COLON expression (COMMA structure_pattern_key COLON expression )* RS # assignmentPatternStructure
    | TICK_S array_pattern_key COLON expression (COMMA array_pattern_key COLON expression )* RS # assignmentPatternArray
    | TICK_S constant_expression LS expression (COMMA expression)* RS RS    # assignmentPatternConstant
    ;

structure_pattern_key
    : member_identifier         # structurePatternKeyMember
    | assignment_pattern_key    # structurePatternKeyAssignment
    ;

array_pattern_key
    : constant_expression       # arrayPatternKeyConstant
    | assignment_pattern_key    # arrayPatternKeyAssignment
    ;

assignment_pattern_key
    : simple_type           # assignmentPatternKeySimple
    | LDEFAULT              # assignmentPatternKeyDefault
    ;

assignment_pattern_expression
    : (assignment_pattern_expression_type)? assignment_pattern  # assignmentPatternExpression
    ;

assignment_pattern_expression_type
    : ps_type_identifier            # assignmentPatternExpressionTypeIdentifier
    | ps_parameter_identifier       # assignmentPatternExpressionTypeParameter
    | integer_atom_type             # assignmentPatternExpressionTypeIntegerAtom
    | type_reference                # assignmentPatternExpressionTypeReference
    ;

constant_assignment_pattern_expression
    : assignment_pattern_expression     # constantAssignmentPatternExpression
    ;

assignment_pattern_net_lvalue
    : TICK_S net_lvalue (COMMA net_lvalue)* RS  # assignmentPatternNetLvalue
    ;

assignment_pattern_variable_lvalue
    : TICK_S variable_lvalue (COMMA variable_lvalue)* RS    # assignmentPatternVariableLvalue
    ;

// A.6.8 Looping statements

loop_statement
    : FOREVER statement_or_null     # loopStatementForever
    | REPEAT LP expression RP statement_or_null     # loopStatementRepeat
    | WHILE LP expression RP statement_or_null      # loopStatementWhile
    | FOR LP (for_initialization)? SEMICOLON (expression)? SEMICOLON (for_step)? RP statement_or_null   # loopStatementFor
    | DO statement_or_null WHILE LP expression RP SEMICOLON         # loopStatementDo
    | FOREACH LP ps_or_hierarchical_array_identifier LB loop_variables RB RP statement  # loopStatementForEach
    ;

for_initialization
    : list_of_variable_assignments      # forInitializationList
    | for_variable_declaration (COMMA for_variable_declaration)*    # forInitializationDecl
    ;

for_variable_declaration
    : (VAR)? data_type variable_identifier ASSIGN expression (COMMA variable_identifier ASSIGN expression)* # forVariableDeclaration
    ;

for_step
    : for_step_assignment (COMMA for_step_assignment)*      # forStep
    ;

for_step_assignment
    : operator_assignment           # forStepAssignmentOp
    | inc_or_dec_expression         # forStepAssignmentIncOrDec
    | function_subroutine_call      # forStepAssignmentFunctionSubroutine
    ;

loop_variables
    : (index_variable_identifier)? (COMMA (index_variable_identifier)? )*   # loopVariables
    ;

// A.6.9 Subroutine call statements

subroutine_call_statement
    : subroutine_call SEMICOLON     # subroutineCallStatement
    | VOID TICK LP function_subroutine_call RP SEMICOLON        # subroutineCallStatementFunction
    ;

//  A.6.10 Assertion statements

assertion_item
    : concurrent_assertion_item             # assertionItemConcurrent
    | deferred_immediate_assertion_item     # assertionItemDeferred
    ;

deferred_immediate_assertion_item
    : ( block_identifier COLON)? deferred_immediate_assertion_statement # deferredImmediateAssertionItem
    ;

procedural_assertion_statement
    : concurrent_assertion_statement    # proceduralAssertionStatementConcurrent
    | immediate_assertion_statement     # proceduralAssertionStatementImmediate
    | checker_instantiation             # proceduralAssertionStatementChecker
    ;

immediate_assertion_statement
    : simple_immediate_assertion_statement      # immediateAssertionStatementSimple
    | deferred_immediate_assertion_statement    # immediateAssertionStatementDeferred
    ;

simple_immediate_assertion_statement
    : simple_immediate_assert_statement     # simpleImmediateAssertionStatementAssert
    | simple_immediate_assume_statement     # simpleImmediateAssertionStatementAssume
    | simple_immediate_cover_statement      # simpleImmediateAssertionStatementCover
    ;

simple_immediate_assert_statement
    : ASSERT LP expression RP action_block  # simpleImmediateAssertStatement
    ;

simple_immediate_assume_statement
    : ASSUME LP expression RP action_block  # simpleImmediateAssumeStatement
    ;

simple_immediate_cover_statement
    : COVER LP expression RP statement_or_null  # simpleImmediateCoverStatement
    ;

deferred_immediate_assertion_statement
    : deferred_immediate_assert_statement   # deferredImmediateAssertionStatementAssert
    | deferred_immediate_assume_statement   # deferredImmediateAssertionStatementAssume
    | deferred_immediate_cover_statement    # deferredImmediateAssertionStatementCover
    ;

deferred_immediate_assert_statement
    : ASSERT SHARP Zero LP expression RP action_block   # deferredImmediateAssertStatement
    | ASSERT FINAL LP expression RP action_block    # deferredImmediateAssertStatementFinal
    ;

deferred_immediate_assume_statement
    : ASSUME SHARP Zero LP expression RP action_block   # deferredImmediateAssumeStatement
    | ASSUME FINAL LP expression RP action_block    # deferredImmediateAssumeStatementFinal
    ;

deferred_immediate_cover_statement
    : COVER SHARP Zero LP expression RP statement_or_null   # deferredImmediateCoverStatement
    | COVER FINAL LP expression RP statement_or_null    # deferredImmediateCoverStatementFinal
    ;

// A.6.11 Clocking block
clocking_declaration
    : (LDEFAULT)? CLOCKING (clocking_identifier)? clocking_event SEMICOLON (clocking_item)* ENDCLOCKING (COLON clocking_identifier)? # clockingDeclaration
    | GLOBAL CLOCKING (clocking_identifier)? clocking_event SEMICOLON ENDCLOCKING (COLON clocking_identifier)? # clockingDeclarationGlobal
    ;

clocking_event
    : AT identifier                 # clockingEventIdentifier
    | AT LP event_expression RP     # clockingEventExpr
    ;

clocking_item
    : LDEFAULT default_skew SEMICOLON   # clockingItemSkew
    | clocking_direction list_of_clocking_decl_assign SEMICOLON # clockingItemList
    | (attribute_instance)* assertion_item_declaration  # clockingItemAssertion
    ;

default_skew
    : INPUT clocking_skew       # defaultSkewInput
    | OUTPUT clocking_skew      # defaultSkewOutput
    | INPUT clocking_skew OUTPUT clocking_skew      # defaultSkewInputOutput
    ;

clocking_direction
    : INPUT (clocking_skew)?                            # clockingDirectionInput
    | OUTPUT (clocking_skew)?                           # clockingDirectionOutput
    | INPUT (clocking_skew)? OUTPUT (clocking_skew)?    # clockingDirectionInputOutput
    | INOUT                                             # clockingDirectionInout
    ;

list_of_clocking_decl_assign
    : clocking_decl_assign (COMMA clocking_decl_assign)*    # listOfClockingDeclAssign
    ;

clocking_decl_assign
    : signal_identifier (ASSIGN expression)?    # clockingDeclAssign
    ;

clocking_skew
    : edge_identifier (delay_control)?      # clockingSkewIdentifier
    | delay_control                         # clockingSkewDelayControl
    ;

clocking_drive
    : clockvar_expression LE (cycle_delay)? expression  # clockingDrive
    ;

cycle_delay
    : SHARP2 integral_number        # cycleDelayIntegral
    | SHARP2 identifier             # cycleDelayIdentifier
    | SHARP2 LP expression RP       # cycleDelayExpr
    ;

clockvar
    : hierarchical_identifier       # clockvarRule
    ;

clockvar_expression
    : clockvar select               # clockvarExpression
    ;

// A.6.12 Randsequence

randsequence_statement
    : RANDSEQUENCE LP (production_identifier)? RP production (production)* ENDSEQUENCE  # randsequenceStatement
    ;

production
    : (data_type_or_void)? production_identifier (LP tf_port_list RP)? COLON rs_rule (OR rs_rule)* SEMICOLON    # productionRule
    ;

rs_rule
    : rs_production_list (COLON_EQUALS weight_specification (rs_code_block)?)?  # rsRule
    ;

rs_production_list
    : rs_prod (rs_prod)*    # rsProductionList
    | RAND JOIN (LP expression RP)? production_item production_item (production_item)*  # rsProductionListRand
    ;

weight_specification
    : integral_number       # weightSpecificationIntegral
    | ps_identifier         # weightSpecificationIdentifier
    | LP expression RP      # weightSpecificationExpr
    ;

rs_code_block
    : LS (data_declaration)* (statement_or_null)* RS    # rsCodeBlock
    ;

rs_prod
    : production_item   # rsProdItem
    | rs_code_block     # rsProdCode
    | rs_if_else        # rsProdIfElse
    | rs_repeat         # rsProdRepeat
    | rs_case           # rsProdCase
    ;

production_item
    : production_identifier (LP list_of_arguments RP)?  # productionItem
    ;

rs_if_else
    : IF LP expression RP production_item (ELSE production_item)?   # rsIfElse
    ;

rs_repeat
    : REPEAT LP expression RP production_item   # rsRepeat
    ;

rs_case
    : CASE LP case_expression RP rs_case_item (rs_case_item)* ENDCASE   # rsCase
    ;

rs_case_item
    : case_item_expression (COMMA case_item_expression)* COLON production_item SEMICOLON    # rsCaseItem
    | LDEFAULT (COLON)? production_item SEMICOLON   # rsCaseItemDefault
    ;

// A.7 Specify section
// A.7.1 Specify block declaration

specify_block
    : SPECIFY (specify_item)* ENDSPECIFY    # specifyBlock
    ;

specify_item
    : specparam_declaration         # specifyItemSpecparam
    | pulsestyle_declaration        # specifyItemPulsestyle
    | showcancelled_declaration     # specifyItemShowcancelled
    | path_declaration              # specifyItemPath
    | system_timing_check           # specifyItemTimingCheck
    ;

pulsestyle_declaration
    : PULSESTYLE_ONEVENT list_of_path_outputs SEMICOLON     # pulsestyleDeclarationOnEvent
    | PULSESTYLE_ONDETECT list_of_path_outputs SEMICOLON    # pulsestyleDeclarationOnDetect
    ;

showcancelled_declaration
    : SHOWCANCELLED list_of_path_outputs SEMICOLON          # showcancelledDeclaration
    | NOSHOWCANCELLED list_of_path_outputs SEMICOLON        # showcancelledDeclarationNo
    ;

// A.7.2 Specify path declarations

path_declaration
    : simple_path_declaration SEMICOLON             # pathDeclarationSimple
    | edge_sensitive_path_declaration SEMICOLON     # pathDeclarationEdge
    | state_dependent_path_declaration SEMICOLON    # pathDeclarationState
    ;

simple_path_declaration
    : parallel_path_description ASSIGN path_delay_value     # simplePathDeclarationParallel
    | full_path_description ASSIGN path_delay_value         # simplePathDeclarationFull
    ;

parallel_path_description
    : LP specify_input_terminal_descriptor (polarity_operator)? EQUALS_GT specify_output_terminal_descriptor RP # parallelPathDescription1
    ;

full_path_description
    : LP list_of_path_inputs (polarity_operator)? STAR_GT list_of_path_outputs RP   # fullPathDescription
    ;

list_of_path_inputs
    : specify_input_terminal_descriptor (COMMA specify_input_terminal_descriptor)*  # listOfPathInputs
    ;

list_of_path_outputs
    : specify_output_terminal_descriptor (COMMA specify_output_terminal_descriptor)*    # listOfPathOutputs
    ;

// A.7.3 Specify block terminals

specify_input_terminal_descriptor
    : input_identifier (LB constant_range_expression RB)?       # specifyInputTerminalDescriptor
    ;

specify_output_terminal_descriptor
    : output_identifier (LB constant_range_expression RB)?      # specifyOutputTerminalDescriptor
    ;

input_identifier
    : input_port_identifier                     # inputIdentifierInput
    | inout_port_identifier                     # inputIdentifierInout
    | interface_identifier DOT port_identifier  # inputIdentifierInterface
    ;

output_identifier
    : output_port_identifier                    # outputIdentifierOutput
    | inout_port_identifier                     # outputIdentifierInout
    | interface_identifier DOT port_identifier  # outputIdentifierInterface
    ;

// A.7.4 Specify path delays

path_delay_value
    : list_of_path_delay_expressions            # pathDelayValue
    | LP list_of_path_delay_expressions RP      # pathDelayValueParends
    ;

list_of_path_delay_expressions
    : t_path_delay_expression   # listOfPathDelayExpressionsTPath
    | trise_path_delay_expression COMMA tfall_path_delay_expression # listOfPathDelayExpressionsTRise
    | trise_path_delay_expression COMMA tfall_path_delay_expression COMMA tz_path_delay_expression  # listOfPathDelayExpressionsTFall
    | t01_path_delay_expression COMMA t10_path_delay_expression COMMA t0z_path_delay_expression COMMA tz1_path_delay_expression COMMA t1z_path_delay_expression COMMA tz0_path_delay_expression # listOfPathDelayExpressionsT01
    | t01_path_delay_expression COMMA t10_path_delay_expression COMMA t0z_path_delay_expression COMMA tz1_path_delay_expression COMMA t1z_path_delay_expression COMMA tz0_path_delay_expression COMMA t0x_path_delay_expression COMMA tx1_path_delay_expression COMMA t1x_path_delay_expression COMMA tx0_path_delay_expression COMMA txz_path_delay_expression COMMA tzx_path_delay_expression # listOfPathDelayExpressionsT01Full
    ;

t_path_delay_expression
    : path_delay_expression     # tPathDelayExpression
    ;

trise_path_delay_expression
    : path_delay_expression     # tRisePathDelayExpression
    ;

tfall_path_delay_expression
    : path_delay_expression     # tFallPathDelayExpression
    ;

tz_path_delay_expression
    : path_delay_expression     # tzPathDelayExpression
    ;

t01_path_delay_expression
    : path_delay_expression     # t01PathDelayExpression
    ;

t10_path_delay_expression
    : path_delay_expression     # t10PathDelayExpression
    ;

t0z_path_delay_expression
    : path_delay_expression     # t0zPathDelayExpression
    ;

tz1_path_delay_expression
    : path_delay_expression     # tz1PathDelayExpression
    ;

t1z_path_delay_expression
    : path_delay_expression     # t1zPathDelayExpression
    ;

tz0_path_delay_expression
    : path_delay_expression     # tz0PathDelayExpression
    ;

t0x_path_delay_expression
    : path_delay_expression     # t0xPathDelayExpression
    ;

tx1_path_delay_expression
    : path_delay_expression     # tx1PathDelayExpression
    ;

t1x_path_delay_expression
    : path_delay_expression     # t1xPathDelayExpression
    ;

tx0_path_delay_expression
    : path_delay_expression     # tx0PathDelayExpression
    ;

txz_path_delay_expression
    : path_delay_expression     # txzPathDelayExpression
    ;

tzx_path_delay_expression
    : path_delay_expression     # tzxPathDelayExpression
    ;

path_delay_expression
    : constant_mintypmax_expression     # pathDelayExpression
    ;

edge_sensitive_path_declaration
    : parallel_edge_sensitive_path_description ASSIGN path_delay_value  # edgeSensitivePathDeclarationParallel
    | full_edge_sensitive_path_description ASSIGN path_delay_value      # edgeSensitivePathDeclarationFull
    ;

parallel_edge_sensitive_path_description
    : LP (edge_identifier)? specify_input_terminal_descriptor (polarity_operator)? EQUALS_GT LP specify_output_terminal_descriptor (polarity_operator)? COLON data_source_expression RP RP  # parallelEdgeSensitivePathDescription
    ;

full_edge_sensitive_path_description
    : LP (edge_identifier)? list_of_path_inputs (polarity_operator)? STAR_GT LP list_of_path_outputs (polarity_operator)? COLON data_source_expression RP RP    # fullEdgeSensitivePathDescription
    ;

data_source_expression
    : expression        # dataSourceExpression
    ;

edge_identifier
    : POSEDGE           # edgeIdentifierPosedge
    | NEGEDGE           # edgeIdentifierNegedge
    | EDGE              # edgeIdentifierEdge
    ;

state_dependent_path_declaration
    : IF LP module_path_expression RP simple_path_declaration           # stateDependentPathDeclarationSimple
    | IF LP module_path_expression RP edge_sensitive_path_declaration   # stateDependentPathDeclarationEdge
    | IFNONE simple_path_declaration                                    # stateDependentPathDeclarationIfnone
    ;

polarity_operator
    : Sign          # polarityOperator
    ;

// A.7.5 System timing checks
// A.7.5.1 System timing check commands

system_timing_check
    : zsetup_timing_check           # systemTimingCheckSetup
    | zhold_timing_check            # systemTimingCheckHold
    | zsetuphold_timing_check       # systemTimingCheckSetupHold
    | zrecovery_timing_check        # systemTimingCheckRecovery
    | zremoval_timing_check         # systemTimingCheckRemoval
    | zrecrem_timing_check          # systemTimingCheckRecrem
    | zskew_timing_check            # systemTimingCheckSkew
    | ztimeskew_timing_check        # systemTimingCheckTimeskew
    | zfullskew_timing_check        # systemTimingCheckFullskew
    | zperiod_timing_check          # systemTimingCheckPeriod
    | zwidth_timing_check           # systemTimingCheckWidth
    | znochange_timing_check        # systemTimingCheckNoChange
    ;

zsetup_timing_check
    : SETUP LP data_event COMMA reference_event COMMA timing_check_limit (COMMA (notifier)?)? RP SEMICOLON # zsetupTimingCheck
    ;

zhold_timing_check
    : HOLD LP reference_event COMMA data_event COMMA timing_check_limit (COMMA (notifier)?)? RP SEMICOLON   # zholdTimingCheck
    ;

zsetuphold_timing_check
    : SETUPHOLD LP reference_event COMMA data_event COMMA timing_check_limit COMMA timing_check_limit (COMMA (notifier)? (COMMA (timestamp_condition)? (COMMA (timecheck_condition)?  (COMMA (delayed_reference)? (COMMA (delayed_data)?)? )?)? )?)? RP SEMICOLON   # zsetupholdTimingCheck
    ;

zrecovery_timing_check
    : RECOVERY LP reference_event COMMA data_event COMMA timing_check_limit (COMMA (notifier)?)? RP SEMICOLON   # zrecoveryTimingCheck
    ;

zremoval_timing_check
    : REMOVAL LP reference_event COMMA data_event COMMA timing_check_limit (COMMA (notifier)?)? RP SEMICOLON    # zremovalTimingCheck
    ;

zrecrem_timing_check
    : RECREM LP reference_event COMMA data_event COMMA timing_check_limit COMMA timing_check_limit (COMMA (notifier)? (COMMA (timestamp_condition)? (COMMA timecheck_condition?  (COMMA (delayed_reference)? (COMMA delayed_data? )?)? )?)? )? RP SEMICOLON     # zrecremTimingCheck
    ;

zskew_timing_check
    : SKEW LP reference_event COMMA data_event COMMA timing_check_limit (COMMA (notifier)?)? RP SEMICOLON   # zskewTimingCheck
    ;

ztimeskew_timing_check
    : TIMESKEW LP reference_event COMMA data_event COMMA timing_check_limit (COMMA (notifier)? (COMMA event_based_flag? (COMMA (remain_active_flag)?)? )?)? RP SEMICOLON        # ztimeskewTimingCheck
    ;

zfullskew_timing_check
    : FULLSKEW LP reference_event COMMA data_event COMMA timing_check_limit COMMA timing_check_limit (COMMA (notifier)? (COMMA (event_based_flag)? (COMMA remain_active_flag? )?)? )? RP SEMICOLON  # zfullskewTimingCheck
    ;

zperiod_timing_check
    : PERIOD LP controlled_reference_event COMMA timing_check_limit (COMMA (notifier)?)? RP SEMICOLON   # zperiodTimingCheck
    ;

zwidth_timing_check
    : WIDTH LP controlled_reference_event COMMA timing_check_limit COMMA threshold (COMMA (notifier)?)? RP SEMICOLON    # zwidthTimingCheck
    ;

znochange_timing_check
    : NOCHANGE LP reference_event COMMA data_event COMMA start_edge_offset COMMA end_edge_offset (COMMA (notifier)?)? RP SEMICOLON  # znochangeTimingCheck
    ;

// A.7.5.2 System timing check command arguments

timecheck_condition
    : mintypmax_expression      # timecheckCondition
    ;

controlled_reference_event
    : controlled_timing_check_event # controlledReferenceEvent
    ;

data_event
    : timing_check_event    # dataEvent
    ;

delayed_data
    : terminal_identifier       # delayedData
    | terminal_identifier LB constant_mintypmax_expression RB       # delayedDataExpr
    ;

delayed_reference
    : terminal_identifier   # delayedReference
    | terminal_identifier LB constant_mintypmax_expression RB   # delayedReferenceExpr
    ;

end_edge_offset
    : mintypmax_expression  # endEdgeOffset
    ;

event_based_flag
    :  constant_expression  # eventBasedFlag
    ;

notifier
    : variable_identifier   # notifierRule
    ;

reference_event
    : timing_check_event    # referenceEvent
    ;

remain_active_flag
    : constant_mintypmax_expression # remainActiveFlag
    ;

timestamp_condition
    : mintypmax_expression  # timestampCondition
    ;

start_edge_offset
    : mintypmax_expression  # startEdgeOffset
    ;

threshold
    : constant_expression   # thresholdRule
    ;

timing_check_limit
    : expression        # timingCheckLimit
    ;

// A.7.5.3 System timing check event definitions

timing_check_event
    : (timing_check_event_control)? specify_terminal_descriptor (AND3 timing_check_condition )? # timingCheckEvent
    ;

controlled_timing_check_event
    : timing_check_event_control specify_terminal_descriptor (AND3 timing_check_condition )?    # controlledTimingCheckEvent
    ;

timing_check_event_control
    : POSEDGE                   # timingCheckEventControlPosedge
    | NEGEDGE                   # timingCheckEventControlNegedge
    | EDGE                      # timingCheckEventControlEdge
    | edge_control_specifier    # timingCheckEventControlSpecifier
    ;

specify_terminal_descriptor
    : specify_input_terminal_descriptor     # specifyTerminalDescriptorInput
    | specify_output_terminal_descriptor    # specifyTerminalDescriptorOutput
    ;

edge_control_specifier
    : EDGE LB Edge_Descriptor (COMMA Edge_Descriptor)* RB   # edgeControlSpecifier
    ;

timing_check_condition
    : scalar_timing_check_condition         # timingCheckCondition
    | LP scalar_timing_check_condition RP   # timingCheckConditionParends
    ;

scalar_timing_check_condition
    : expression                        # scalarTimingCheckConditionExpr
    | NOT expression                    # scalarTimingCheckConditionNotExpr
    | expression E2 scalar_constant     # scalarTimingCheckConditionLogicalEqual
    | expression E3 scalar_constant     # scalarTimingCheckConditionCaseEqual
    | expression BANGE scalar_constant  # scalarTimingCheckConditionLogicalNotEqual
    | expression BEE scalar_constant    # scalarTimingCheckConditionCaseNotEqual
    ;

scalar_constant
    : Single_Bit_Zero       # scalarConstantBit0
    | Single_Bit_One        # scalarConstantBit1
    | All_Binary_Zero       # scalarConstantAll0
    | All_Binary_One        # scalarConstantAll1
    | Zero                  # scalarConstant0
    | One                   # scalarConstant1
    ;

// A.8 Expressions
// A.8.1 Concatenations

concatenation
    : LS expression (COMMA expression)* RS      # concatenationRule
    ;

constant_concatenation
    : LS constant_expression (COMMA constant_expression)* RS    # constantConcatenation
    ;

constant_multiple_concatenation
    : LS constant_expression constant_concatenation RS  # constantMultipleConcatenation
    ;

module_path_concatenation
    : LS module_path_expression (COMMA module_path_expression)* RS  # modulePathConcatenation
    ;

module_path_multiple_concatenation
    : LS constant_expression module_path_concatenation RS   # modulePathMultipleConcatenation
    ;

multiple_concatenation
    : LS expression concatenation RS        # multipleConcatenation
    ;

streaming_concatenation
    : LS stream_operator (slice_size)? stream_concatenation RS  # streamingConcatenation
    ;

stream_operator
    : RS2           # streamOperatorRightShift
    | LS2           # streamOperatorLeftShift
    ;

slice_size
    : simple_type           # sliceSizeSimple
    | constant_expression   # sliceSizeExpr
    ;

stream_concatenation
    : LS stream_expression (COMMA stream_expression)* RS    # streamConcatenation
    ;

stream_expression
    : expression (WITH LB array_range_expression RB)?   # streamExpression
    ;

array_range_expression
    : expression                            # arrayRangeExpressionExpr
    | expression COLON expression           # arrayRangeExpressionColon
    | expression PLUS_COLON expression      # arrayRangeExpressionPlusColon
    | expression MINUS_COLON expression     # arrayRangeExpressionMinusColon
    ;

empty_unpacked_array_concatenation
    : LS RS         # emptyQueue
    ;

// A.8.2 Subroutine calls

constant_function_call
    : function_subroutine_call      # constantFunctionCall
    ;

tf_call
    : ps_or_hierarchical_tf_identifier (attribute_instance)* (LP list_of_arguments RP)?     # tfCall
    ;

system_tf_call
    : system_tf_identifier (LP list_of_arguments RP)?           # systemTfCallArguments
    | system_tf_identifier LP data_type (COMMA expression)? RP  # systemTfCallExpr
    | system_tf_identifier LP expression (COMMA (expression)?)* (COMMA (clocking_event)?)? RP   # systemTfClocking
    ;

subroutine_call
    : tf_call                   # subroutineCallTf
    | system_tf_call            # subroutineCallSystemTf
    | method_call               # subroutineCallMethod
    | (STD DC)? randomize_call   # subroutineCallRandomize
    ;

function_subroutine_call
    : subroutine_call           # functionSubroutineCall
    ;

list_of_arguments
    : expression (COMMA (expression)?)* (COMMA DOT identifier LP (expression)? RP)*     # listOfArguments
    | (COMMA (expression)?)* (COMMA DOT identifier LP (expression)? RP)*                # listOfArgumentsNull
    | DOT identifier LP (expression)? RP (COMMA DOT identifier LP (expression)? RP)*    # listOfArgumentsDot
    ;

method_call
    : method_call_root DOT method_call_body # methodCall
    | method_call_body                      # methodCallImplicit
    | class_qualifier method_call_body      # methodCallClass    // XXX FRED
    ;

// FRED Allow empty parends?
method_call_body
    : method_identifier (attribute_instance)* (LP (list_of_arguments)? RP)?     # methodCallBody
    | built_in_method_call      # methodCallBodyBuiltIn
    ;

built_in_method_call
    : array_method_call         # builtInMethodCallArrayMethod
    | array_manipulation_call   # builtInMethodCallArrayManipulation
    | randomize_call            # builtInMethodCallRandomize
    ;

array_manipulation_call
    : array_method_name (attribute_instance)* (LP list_of_arguments RP)?  (WITH LP expression RP)?  # arrayManipulationCall
    ;

randomize_call
    : RANDOMIZE (attribute_instance)* (LP (variable_identifier_list | NULL)? RP)?  (WITH (LP (identifier_list)? RP)? constraint_block)? # randomizeCall
    ;

method_call_root
    : primary                   # methodCallRootPrimary
    | implicit_class_handle     # methodCallRootImplicit
    ;

array_method_name
    : method_identifier     # arrayMethodNameMethod
    | UNIQUE                # arrayMethodNameUnique
    | LAND                  # arrayMethodNameAnd
    | LOR                   # arrayMethodNameOr
    | XOR                   # arrayMethodNameXor
    ;

// 7.12 Array manipulation methods

array_method_call
    : array_manipulation_identifier_without (attribute_instance)* (LP RP)?      # arrayMethodCallWithout
    | array_manipulation_identifier_with (attribute_instance)* (LP RP)? WITH LP expression RP       # arrayMethodCallWith
    | array_manipulation_identifier_with (attribute_instance)* LP iterator_argument RP WITH LP expression RP        # arrayMethodCallWithIterator
    ;

iterator_argument
    : identifier    # iteratorArgument
    ;

// A.8.3 Expressions

inc_or_dec_expression
    : inc_or_dec_operator (attribute_instance)* variable_lvalue     # incOrDecExpressionOp
    | variable_lvalue (attribute_instance)* inc_or_dec_operator     # incOrDecExpressionValue
    ;

conditional_expression
    : cond_predicate QUESTION_MARK (attribute_instance)* expression COLON expression    # conditionalExpression
    ;

constant_expression
    : constant_primary              # constantExpressionPrimary
    | unary_operator (attribute_instance)* constant_primary     # constantExpressionUnary
    | constant_expression binary_operator (attribute_instance)* constant_expression     # constantExpressionBinary
    | constant_expression QUESTION_MARK (attribute_instance)* constant_expression COLON constant_expression # constantExpressionConditional
    ;

constant_mintypmax_expression
    : constant_expression           # constantMintypmaxExpression
    | constant_expression COLON constant_expression COLON constant_expression   # constantMintypmaxExpressionColon
    ;

constant_param_expression
    : constant_mintypmax_expression     # constantParamExpressionMintypmax
    | data_type                         # constantParamExpressionDataType
    | DS                                # constantParamExpressionDollarSign
    ;

param_expression
    : mintypmax_expression      # paramExpressionMintypmax
    | data_type                 # paramExpressionDataType
    | DS                        # paramExpressionDollarSign
    ;

constant_range_expression
    : constant_expression           # constantRangeExpression
    | constant_part_select_range    # constantRangeExpressionPartSelect
    ;

constant_part_select_range
    : constant_range                # constantPartSelectRange
    | constant_indexed_range        # constantPartSelectRangeIndexed
    ;

constant_range
    : constant_expression COLON constant_expression # constantRange
    ;

constant_indexed_range
    : constant_expression PLUS_COLON constant_expression    # constantIndexedRangePlus
    | constant_expression MINUS_COLON constant_expression   # constantIndexedRangeMinus
    ;

expression
    : primary   # expressionPrimary
    | unary_operator (attribute_instance)* primary  # expressionUnary
    | inc_or_dec_expression         # expressionIncOrDec
    | LP operator_assignment RP     # expressionParends
    | expression binary_operator (attribute_instance)* expression   # expressionBinary
    // conditional_expression
    | expression (AND3 expression)* QUESTION_MARK (attribute_instance)* expression COLON expression    # expressionConditionalExpression
    | expression MATCHES (AND3 expression)* QUESTION_MARK (attribute_instance)* expression COLON expression    # expressionConditionalExpressionMatches
    | expression (AND3 expression MATCHES)* QUESTION_MARK (attribute_instance)* expression COLON expression # expressionConditionalExpressionAnd3Matches
    | expression MATCHES (AND3 expression MATCHES)* QUESTION_MARK (attribute_instance)* expression COLON expression # expressionConditionalExpressionMatchesAnd3
    // inside_expression
    | expression INSIDE LS open_range_list RS   # expressionInsideExpression
    | tagged_union_expression   # expressionTaggedUnionExpr
    ;

tagged_union_expression
    : TAGGED member_identifier (expression)?    # taggedUnionExpression
    ;

inside_expression
    : expression INSIDE LS open_range_list RS   # insideExpression
    ;

value_range
    : expression        # valueRangeExpr
    | LB expression COLON expression RB     # valueRangeRange
    ;

mintypmax_expression
    : expression        # mintypmaxExpression
    | expression COLON expression COLON expression      # mintypmaxExpressionColon
    ;

module_path_conditional_expression
    : module_path_expression QUESTION_MARK (attribute_instance)* module_path_expression COLON module_path_expression    # modulePathConditionalExpression
    ;

module_path_expression
    : module_path_primary   # modulePathExpressionPrimary
    | unary_module_path_operator (attribute_instance)* module_path_primary  # modulePathExpressionUnary
    | module_path_expression binary_module_path_operator (attribute_instance)* module_path_expression # modulePathExpressionBinary
    // module_path_conditional_expression
    | module_path_expression QUESTION_MARK (attribute_instance)* module_path_expression COLON module_path_expression # modulePathExpressionConditional
    ;

module_path_mintypmax_expression
    : module_path_expression    # modulePathMintypmaxExpression
    | module_path_expression COLON module_path_expression COLON module_path_expression  # modulePathMintypmaxExpressionColon
    ;

part_select_range
    : constant_range    # partSelectRangeConstant
    | indexed_range     # partSelectRangeIndexed
    ;

indexed_range
    : expression PLUS_COLON constant_expression     # indexedRangePlus
    | expression MINUS_COLON constant_expression    # indexedRangeMinus
    ;

genvar_expression
    : constant_expression       # genvarExpression
    ;

// A.8.4 Primaries

constant_primary
    : primary_literal   # constantPrimaryLiteral
    | ps_parameter_identifier constant_select   # constantPrimaryParameter
    | specparam_identifier (LB constant_range_expression RB)?   # constantPrimarySpecparam
    | genvar_identifier # constantPrimaryGenvar
    | formal_port_identifier constant_select    # constantPrimaryPort
    | ( package_scope | class_scope )? enum_identifier  # constantPrimaryEnum
    | constant_concatenation (LB constant_range_expression RB)? # constantPrimaryConstantConcat
    | constant_multiple_concatenation (LB constant_range_expression RB)?    # constantPrimaryConstantMultiConcat
//    | constant_function_call
    | tf_call   # constantPrimaryConstantFunctionTfCall
    | system_tf_call    # constantPrimaryConstantFunctionSystemTfCall
    | (STD DC)? randomize_call   # constantPrimaryConstantFunctionRandomize
//    | method_call
    | method_call_body    # constantPrimaryMethodCallBody  // XXX FRED implicitMethod
    | primary DOT method_call_body  # constantPrimaryMethodCallPrimary
    | implicit_class_handle DOT method_call_body    # constantPrimaryMethodCallImplicit
    | constant_let_expression   # constantPrimaryConstantLet
    | LP constant_mintypmax_expression RP   # constantPrimaryConstantMintypmaxExpr
//    | constant_cast
    | simple_type TICK LP constant_expression RP    # constantPrimaryConstantCastSimple
    | constant_primary TICK LP constant_expression RP   # constantPrimaryConstantCastPrimary
    | signing TICK LP constant_expression RP    # constantPrimaryConstantCastSigning
    | STRING TICK LP constant_expression RP # constantPrimaryConstantCastString
    | CONST TICK LP constant_expression RP  # constantPrimaryConstantCastConst
    | constant_assignment_pattern_expression    # constantPrimaryConstantAddignmentPatternExpr
    | type_reference    # constantPrimaryTypeReference
    | NULL              # constantPrimaryNull
    ;

module_path_primary
    : number                                    # modulePathPrimaryNumber
    | identifier                                # modulePathPrimaryIdentifier
    | module_path_concatenation                 # modulePathPrimaryConcat
    | module_path_multiple_concatenation        # modulePathPrimaryMultiConcat
    | function_subroutine_call                  # modulePathPrimaryFunctionSubroutine
    | LP module_path_mintypmax_expression RP    # modulePathPrimaryMintypmaxExpr
    ;

primary
    : primary_literal   # primaryLiteral
//    | (class_qualifier | package_scope)? hierarchical_identifier select
    | hierarchical_identifier select    # primaryHierarchical
    | class_qualifier hierarchical_identifier select    # primaryClassHierarchical
    | class_qualifier hierarchical_identifier LP (list_of_arguments)? RP    # primaryClassHierarchicalParends // XXX FRED
    | package_scope hierarchical_identifier select  # primaryPackageHierarchical
    | empty_unpacked_array_concatenation       # primaryEmptyUnpackedArrayConcat
    | concatenation (LB range_expression RB)?   # primaryConcat
    | multiple_concatenation (LB range_expression RB)?  # primaryMultiConcat
//    | function_subroutine_call
    | tf_call       # primaryFunctionTfCall
    | system_tf_call    # primaryFunctionSystemTfCall
    | (STD DC)? randomize_call   # primaryFunctionRandomize
//    | method_call
    | method_call_body     # primaryMethodCallBody // XXX FRED implicitMethod
    | primary DOT method_call_body  # primaryMethodCallPrimary
    | implicit_class_handle DOT method_call_body    # primaryMethodCallImplicit
//
    | let_expression        # primaryLetExpr
    | LP mintypmax_expression RP    # primaryMintypmaxExpr
//    | cast
    | simple_type TICK LP expression RP # primaryCastSimple
    | primary TICK LP expression RP     # primaryCastPrimary  // FRED XXX constant_primary???
    | signing TICK LP expression RP     # primaryCastSigning
    | STRING TICK LP expression RP      # primaryCastString
    | CONST TICK LP expression RP       # primaryCastConst
    | assignment_pattern_expression     # primaryAssignmentPatternExpr
    | streaming_concatenation           # primaryStreamingConcat
    | sequence_method_call              # primarySequenceMethodCall
    | THIS                              # primaryThis
    | DS                                # primaryDollarSign
    | NULL                              # primaryNull
    ;

class_qualifier
    : (LOCAL DC)? (implicit_class_handle DOT | class_scope)?     # classQualifier
    ;

range_expression
    : expression            # rangeExpressionExpr
    | part_select_range     # rangeExpressionPartSelect
    ;

primary_literal
    : number                    # primaryLiteralNumber
    | time_literal              # primaryLiteralTime
    | Unbased_Unsized_Literal   # primaryLiteralUnbased
    | StringLiteral             # primaryLiteralString
    ;

// FRED
timescale_statement
    : TIMESCALE time_literal SLASH time_literal     # timescaleStatement
    ;

time_literal
    : Time_Identifier       # timeLiteral
    ;

implicit_class_handle
    : THIS                  # implicitClassHandleThis
    | SUPER                 # implicitClassHandleSuper
    | THIS DOT SUPER        # implicitClassHandleThisDotSuper
    ;

bit_select
    : (LB expression RB)+   # bitSelect
    | null_bit_select       # bitSelectNull
    ;

null_bit_select
    :                       # nullBitSelect
    ;

select
    : ((DOT member_identifier bit_select)* DOT member_identifier)? bit_select (LB part_select_range RB)?    # selectRule
    ;

nonrange_select
    : ((DOT member_identifier bit_select)* DOT member_identifier)? bit_select   # nonrangeSelect
    ;

constant_bit_select
    : (LB constant_expression RB)+      # constantBitSelect
    | null_constant_bit_select          # constantBitSelectNull
    ;

null_constant_bit_select
    :               # nullConstantBitSelect
    ;

constant_select
    : ((DOT member_identifier constant_bit_select)* DOT member_identifier)? constant_bit_select (LB constant_part_select_range RB)? # constantSelect
    ;

constant_cast
    : casting_type TICK LP constant_expression RP   # constantCast
    ;

constant_let_expression
    : let_expression        # constantLetExpr
    ;

cast
    : casting_type TICK LP expression RP    # castRule
    ;

// A.8.5 Expression left-side values

net_lvalue
    : ps_or_hierarchical_net_identifier constant_select                     # netLvalueHierarchical
    | LS net_lvalue (COMMA net_lvalue)* RS                                  # netLvalueNet
    | (assignment_pattern_expression_type)? assignment_pattern_net_lvalue   # netLvalueAssignment
    ;

variable_lvalue
    : (implicit_class_handle DOT | package_scope)? hierarchical_variable_identifier select  # variableLvalueHierarchical
    | LS variable_lvalue (COMMA variable_lvalue)* RS                                        # variableLvalueVariable
    | (assignment_pattern_expression_type)? assignment_pattern_variable_lvalue              # variableLvalueAssignment
    | streaming_concatenation                                                               # variableLvalueConcat
    ;

nonrange_variable_lvalue
    : ( implicit_class_handle DOT | package_scope )? hierarchical_variable_identifier nonrange_select   # nonrangeVariableLvalue
    ;

// A.8.6 Operators

unary_operator
    : PLUS          # unaryOperatorPlus
    | MINUS         # unaryOperatorMinus
    | BANG          # unaryOperatorLogicalNot
    | NOT           # unaryOperatorNegation
    | AND           # unaryOperatorAnd
    | NOT_AND       # unaryOperatorNotAnd
    | OR            # unaryOperatorOr
    | NOT_OR        # unaryOperatorNotOr
    | CARET         # unaryOperatorXor
    | NOT_CARET     # unaryOperatorNotXor
    | CARET_NOT     # unaryOperatorXorNot
    ;

binary_operator
    : PLUS          # binaryOperatorPlus
    | MINUS         # binaryOperatorMinus
    | STAR          # binaryOperatorMultiply
    | SLASH         # binaryOperatorDivide
    | MODULO        # binaryOperatorModulo
    | E2            # binaryOperatorLogicalEqual
    | BANGE         # binaryOperatorLogicalNotEqual
    | E3            # binaryOperatorCaseEqual
    | BEE           # binaryOperatorCaseNotEqual
    | E2Q           # binaryOperatorCaseEqualWildcard
    | BEQ           # binaryOperatorCaseNotEqualWildcard
    | AND2          # binaryOperatorLogicalAnd
    | OR2           # binaryOperatorLogicalOr
    | STAR2         # binaryOperatorPower
    | LT            # binaryOperatorLessThan
    | LE            # binaryOperatorLessThanOrEqual
    | GT            # binaryOperatorGreaterThan
    | GE            # binaryOperatorGreaterThanOrEqual
    | AND           # binaryOperatorAnd
    | OR            # binaryOperatorOr
    | CARET         # binaryOperatorXor
    | CARET_NOT     # binaryOperatorXorNot
    | NOT_CARET     # binaryOperatorNotXor
    | RS2           # binaryOperatorLogicalRightShift
    | LS2           # binaryOperatorLogicalLeftShift
    | RS3           # binaryOperatorArithmeticRightShift
    | LS3           # binaryOperatorArithmeticLeftShift
    | MINUS_GT      # binaryOperatorImplication
    | LMG           # binaryOperatorEquivalence
    ;

inc_or_dec_operator
    : PLUS2         # incOrDecOperatorPlus
    | MINUS2        # incOrDecOperatorMinus
    ;

unary_module_path_operator
    : BANG          # unaryModulePathOperatorLogicalNot
    | NOT           # unaryModulePathOperatorNegation
    | AND           # unaryModulePathOperatorAnd
    | NOT_AND       # unaryModulePathOperatorNotAnd
    | OR            # unaryModulePathOperatorOr
    | NOT_OR        # unaryModulePathOperatorNotOr
    | CARET         # unaryModulePathOperatorXor
    | NOT_CARET     # unaryModulePathOperatorNotXor
    | CARET_NOT     # unaryModulePathOperatorXorNot
    ;

binary_module_path_operator
    : E2            # binaryModulePathOperatorEqual
    | BANGE         # binaryModulePathOperatorNotEqual
    | AND2          # binaryModulePathOperatorLogicalAnd
    | OR2           # binaryModulePathOperatorLogicalOr
    | AND           # binaryModulePathOperatorAnd
    | OR            # binaryModulePathOperatorOr
    | CARET         # binaryModulePathOperatorXor
    | CARET_NOT     # binaryModulePathOperatorXorNot
    | NOT_CARET     # binaryModulePathOperatorNotXor
    ;

// A.8.7 Numbers

number
    : integral_number   # numberIntegral
    | Real_Number       # numberReal
    ;

integral_number
    : Unsigned_Number   # integralNumberUnsigned
    | Decimal_Number    # integralNumberDecimal
    | Octal_Number      # integralNumberOctal
    | Binary_Number     # integralNumberBinary
    | Hex_Number        # integralNumberHex
    ;

// A.8.8 StringLiterals in Lexer

// A.9 General
// A.9.1 Attributes

attribute_instance
    : PSTAR attr_spec (COMMA attr_spec)* STARP      # attributeInstance
    ;

attr_spec
    : attr_name (ASSIGN constant_expression)?       # attrSpec
    ;

attr_name
    : identifier                                    # attrName
    ;

// A.9.2 Comments

comment
    : One_Line_Comment          # commentOneLine
    | Block_Comment             # commentBlock
    ;

// A.9.3 Identifiers

array_identifier
    : identifier        # arrayIdentifier
    ;

block_identifier
    : identifier        # blockIdentifier
    ;

bin_identifier
    : identifier        # binIdentifier
    ;

c_identifier
    : First_Part (Second_Part)*   # cIdentifier
    ;

cell_identifier
    : identifier        # cellIdentifier
    ;

checker_identifier
    : identifier        # checkerIdentifier
    ;

class_identifier
    : identifier        # classIdentifier
    ;

class_variable_identifier
    : variable_identifier   # classVariableIdentifier
    ;

clocking_identifier
    : identifier        # clockingIdentifier
    ;

config_identifier
    : identifier        # configIdentifier
    ;

const_identifier
    : identifier        # constIdentifier
    ;

constraint_identifier
    : identifier        # constraintIdentifier
    ;

covergroup_identifier
    : identifier        # coverGroupIdentifier
    ;

covergroup_variable_identifier
    : variable_identifier   # covergroupVariableIdentifier
    ;

cover_point_identifier
    : identifier        # coverPointIdentifier
    ;

cross_identifier
    : identifier        # crossIdentifier
    ;

dynamic_array_variable_identifier
    : variable_identifier   # dynamicArrayVariableIdentifier
    ;

enum_identifier
    : identifier        # enumIdentifier
    ;

// escaped_identifier see Escaped_identifier

formal_identifier
    : identifier        # formalIdentifier
    ;

formal_port_identifier
    : identifier        # formalPortIdentifier
    ;

function_identifier
    : identifier        # functionIdentifier
    ;

generate_block_identifier
    : identifier        # generateBlockIdentifier
    ;

genvar_identifier
    : identifier        # genvarIdentifier
    ;

hierarchical_array_identifier
    : hierarchical_identifier   # hierarchicalArrayIdentifier
    ;

hierarchical_block_identifier
    : hierarchical_identifier   # hierarchicalBlockIdentifier
    ;

hierarchical_event_identifier
    : hierarchical_identifier   # hierarchicalEventIdentifier
    ;

hierarchical_identifier
    : (ROOT DOT)? (identifier constant_bit_select DOT)* identifier  # hierarchicalIdentifier
    ;

hierarchical_net_identifier
    : hierarchical_identifier   # hierarchicalNetIdentifier
    ;

hierarchical_parameter_identifier
    : hierarchical_identifier   # hierarchicalParameterIdentifier
    ;

hierarchical_property_identifier
    : hierarchical_identifier   # hierarchicalPropertyIdentifier
    ;

hierarchical_sequence_identifier
    : hierarchical_identifier   # hierarchicalSequenceIdentifier
    ;

hierarchical_task_identifier
    : hierarchical_identifier   # hierarchicalTaskIdentifier
    ;

hierarchical_tf_identifier
    : hierarchical_identifier   # hierarchicalTfIdentifier
    ;

hierarchical_variable_identifier
    : hierarchical_identifier   # hierarchicalVariableIdentifier
    ;

identifier
    : Simple_Identifier         # identifierSimple
    | Escaped_Identifier        # identifierEscaped // XXX FRED
    | THIS                      # identifierThis // XXX FRED
    | array_manipulation_identifiers    # identifierArrayManipulation
    ;

index_variable_identifier
    : identifier        # indexVariableIdentifier
    ;

interface_identifier
    : identifier        # interfaceIdentifier
    ;

interface_instance_identifier
    : identifier        # interfaceInstanceIdentifier
    ;

inout_port_identifier
    : identifier        # inoutPortIdentifier
    ;

input_port_identifier
    : identifier        # inputPortIdentifier
    ;

instance_identifier
    : identifier        # instanceIdentifier
    ;

library_identifier
    : identifier        # libraryIdentifier
    ;

member_identifier
    : identifier        # memberIdentifier
    ;

method_identifier
    : identifier        # methodIdentifier
    ;

modport_identifier
    : identifier        # modportIdentifier
    ;

module_identifier
    : identifier        # moduleIdentifier
    ;

net_identifier
    : identifier        # netIdentifier
    ;

net_type_identifier
    : identifier        # netTypeIdentifier
    ;

output_port_identifier
    : identifier        # outputPortIdentifier
    ;

package_identifier
    : identifier        # packageIdentifier
    ;

package_scope
    : package_identifier COLON2 # packageScope
    | UNIT COLON2               # packageScopeUnit
    ;

parameter_identifier
    : identifier        # parameterIdentifier
    ;

port_identifier
    : identifier        # portIdentifier
    ;

production_identifier
    : identifier        # productionIdentifier
    ;

program_identifier
    : identifier        # programIdentifier
    ;

property_identifier
    : identifier        # propertyIdentifier
    ;

ps_class_identifier
    : (package_scope)? class_identifier         # psClassIdentifier
    ;

ps_covergroup_identifier
    : (package_scope)? covergroup_identifier    # psCovergroupIdentifier
    ;

ps_checker_identifier
    : (package_scope)? checker_identifier       # psCheckerIdentifier
    ;

ps_identifier
    : (package_scope)? identifier   # psIdentifier
    ;

ps_or_hierarchical_array_identifier
    : ( implicit_class_handle DOT | class_scope | package_scope )? hierarchical_array_identifier    # psOrHierarchicalArrayIdentifier
    ;

ps_or_hierarchical_net_identifier
    : (package_scope)? net_identifier   # psOrHierarchicalNetIdentifierPackage
    | hierarchical_net_identifier       # psOrHierarchicalNetIdentifierHierarchical
    ;

ps_or_hierarchical_property_identifier
    : (package_scope)? property_identifier  # psOrHierarchicalPropertyIdentifierPackage
    | hierarchical_property_identifier      # psOrHierarchicalPropertyIdentifierHierarchical
    ;

ps_or_hierarchical_sequence_identifier
    : (package_scope)? sequence_identifier  # psOrHierarchicalSequenceIdentifierPackage
    | hierarchical_sequence_identifier      # psOrHierarchicalSequenceIdentifierHierarchical
    ;

ps_or_hierarchical_tf_identifier
    : (package_scope)? tf_identifier        # psOrHierarchicalTfIdentifierPackage
    | hierarchical_tf_identifier            # psOrHierarchicalTfIdentifierHierarchical
    ;

ps_parameter_identifier
    : ( package_scope | class_scope )? parameter_identifier     # psParameterIdentifierPackage
    | ( generate_block_identifier (LB constant_expression RB)? DOT)* parameter_identifier       # psParameterIdentifierHierarchical
    ;

ps_type_identifier
    : (LOCAL DC | package_scope | class_scope)? type_identifier   # psTypeIdentifier
    ;

sequence_identifier
    : identifier        # sequenceIdentifier
    ;

signal_identifier
    : identifier        # signalIdentifier
    ;

specparam_identifier
    : identifier        # specparamIdentifier
    ;

system_tf_identifier
    // 18.13 Random number system functions and methods
    : SF_URANDOM_RANGE
    | SF_URANDOM
    // Simulation control tasks (20.2)
    | SF_FINISH
    | SF_STOP
    | SF_EXIT
    // Simulation time functions (20.3)
    | SF_REALTIME
    | SF_STIME
    | SF_TIME
    // Timescale tasks (20.4)
    | SF_PRINTTIMESCALE
    | SF_TIMEFORMAT
    // Conversion functions (20.5)
    | SF_SHORTREALTOBITS
	| SF_BITSTOSHORTREAL
	| SF_REALTOBITS
	| SF_BITSTOREAL
	| SF_UNSIGNED
	| SF_SIGNED
	| SF_RTOI
	| SF_ITOR
	| SF_CAST
	// Data query functions (20.6)
	| SF_ISUNBOUNDED
	| SF_TYPENAME
	| SF_BITS
	// Array query functions (20.7)
	| SF_UNPACKED_DIMENSIONS
	| SF_DIMENSIONS
	| SF_INCREMENT
	| SF_RIGHT
	| SF_LEFT
	| SF_SIZE
	| SF_HIGH
	| SF_LOW
	// Math functions
	| SF_LOG10
	| SF_HYPOT
	| SF_FLOOR
	| SF_CLOG2
	| SF_ASINH
	| SF_ACOSH
	| SF_ATANH
	| SF_ATAN2
	| SF_SQRT
	| SF_CEIL
	| SF_SINH
	| SF_COSH
	| SF_TANH
	| SF_ATAN
	| SF_ASIN
	| SF_ACOS
	| SF_TAN
	| SF_POW
	| SF_SIN
	| SF_COS
	| SF_EXP
	| SF_LN
	// Bit vector system functions (20.9)
	| SF_ISUNKNOWN
	| SF_COUNTONES
	| SF_COUNTBITS
	| SF_ONEHOT0
	| SF_ONEHOT
	// Severity tasks (20.10)
	| SF_WARNING
	| SF_FATAL
	| SF_ERROR
	| SF_INFO
	// Elaboration system tasks (20.11) In Parser
	// Assertion control tasks (20.12)
	| SF_ASSERTNONVACUOUSON
	| SF_ASSERTVACUOUSOFF
	| SF_ASSERTKILL
	| SF_ASSERTPASSON
	| SF_ASSERTFAILON
	| SF_ASSERTCONTROL
	| SF_ASSERTPASSOFF
	| SF_ASSERTFAILOFF
	| SF_ASSERTOFF
	| SF_ASSERTON
	// Sampled value system functions (20.13)
	| SF_CHANGING_GCLK
	| SF_FALLING_GCLK
	| SF_CHANGED_GCLK
	| SF_STEADY_GCLK
	| SF_STABLE_GCLK
	| SF_RISING_GCLK
	| SF_FUTURE_GCLK
	| SF_PAST_GCLK
	| SF_ROSE_GCLK
	| SF_FELL_GCLK
	| SF_SAMPLED
	| SF_CHANGED
	| SF_STABLE
	| SF_ROSE
	| SF_PAST
	| SF_FELL
	// Coverage control functions (20.14)
	| SF_SET_COVERAGE_DB_NAME
	| SF_LOAD_COVERAGE_DB
	| SF_GET_COVERAGE
	| SF_COVERAGE_GET_MAX
	| SF_COVERAGE_CONTROL
	| SF_COVERAGE_MERGE
	| SF_COVERAGE_SAVE
	| SF_COVERAGE_GET
	// Probabilistic distribution functions (20.15)
	| SF_RANDOM
	| SF_DIST_EXPONENTIAL
	| SF_DIST_CHI_SQUARE
	| SF_DIST_UNIFORM
	| SF_DIST_POISSON
	| SF_DIST_NORMAL
	| SF_DIST_ERLANG
	| SF_DIST_T
	// Stochastic analysis tasks and functions (20.16)
	| SF_Q_INITIALIZE
	| SF_Q_REMOVE
	| SF_Q_FULL
	| SF_Q_EXAM
	| SF_Q_ADD
	// PLA modeling tasks (20.17)
	| SF_ASYNC_NAND_PLANE
	| SF_ASYNC_NAND_ARRAY
	| SF_ASYNC_NOR_PLANE
	| SF_ASYNC_NOR_ARRAY
	| SF_ASYNC_AND_PLANE
	| SF_ASYNC_AND_ARRAY
	| SF_SYNC_NAND_PLANE
	| SF_SYNC_NAND_ARRAY
	| SF_SYNC_NOR_PLANE
	| SF_SYNC_NOR_ARRAY
	| SF_SYNC_AND_PLANE
	| SF_SYNC_AND_ARRAY
	| SF_ASYNC_OR_PLANE
	| SF_ASYNC_OR_ARRAY
	| SF_SYNC_OR_PLANE
	| SF_SYNC_OR_ARRAY
	// Miscellaneous tasks and functions (20.18)
	| SF_SYSTEM
	// Display tasks (21.2)
	| SF_MONITOROFF
	| SF_MONITORON
	| SF_MONITORO
	| SF_MONITORH
	| SF_MONITORB
	| SF_DISPLAYO
	| SF_DISPLAYH
	| SF_DISPLAYB
	| SF_STROBEO
	| SF_STROBEH
	| SF_STROBEB
	| SF_MONITOR
	| SF_DISPLAY
	| SF_WRITEO
	| SF_WRITEH
	| SF_WRITEB
	| SF_STROBE
	| SF_WRITE
	// File I/O tasks and functions (21.3)
	| SF_FMONITORO
	| SF_FMONITORH
	| SF_FMONITORB
	| SF_FDISPLAYO
	| SF_FDISPLAYH
	| SF_FDISPLAYB
	| SF_FMONITOR
	| SF_FDISPLAY
	| SF_FSTROBEO
	| SF_FSTROBEH
	| SF_FSTROBEB
	| SF_SFORMATF
	| SF_SWRITEO
	| SF_SWRITEH
	| SF_SWRITEB
	| SF_SFORMAT
	| SF_FWRITEO
	| SF_FWRITEH
	| SF_FWRITEB
	| SF_FSTROBE
	| SF_UNGETC
	| SF_SWRITE
	| SF_SSCANF
	| SF_REWIND
	| SF_FWRITE
	| SF_FSCANF
	| SF_FFLUSH
	| SF_FERROR
	| SF_FCLOSE
	| SF_FTELL
	| SF_FSEEK
	| SF_FOPEN
	| SF_FREAD
	| SF_FGETS
	| SF_FGETC
	| SF_FEOF
	// Memory load tasks (21.4)
	| SF_READMEMH
	| SF_READMEMB
	// Memory dump tasks (21.5)
	| SF_WRITEMEMH
	| SF_WRITEMEMB
	// Command line input (21.6)
	| SF_VALUE_PLUSARGS
	| SF_TEST_PLUSARGS
	// VCD tasks (21.7)
	| SF_DUMPPORTSLIMIT
	| SF_DUMPPORTSFLUSH
	| SF_DUMPPORTSOFF
	| SF_DUMPPORTSALL
	| SF_DUMPPORTSON
	| SF_DUMPPORTS
	| SF_DUMPLIMIT
	| SF_DUMPFLUSH
	| SF_DUMPVARS
	| SF_DUMPFILE
	| SF_DUMPOFF
	| SF_DUMPALL
	| SF_DUMPON
    // XXX Non-standard
    | SF_PSPRINTF
    | SF_PCIE_ACCESS
    | SF_VCDPLUSFILE
    | SF_VCDPLUSON
    | SF_VCDPLUSMEMON
    | SF_MMSOMASET
    ;

task_identifier
    : identifier        # taskIdentifier
    ;

tf_identifier
    : identifier        # tfIdentifier
    ;

terminal_identifier
    : identifier        # terminalIdentifier
    ;

topmodule_identifier
    : identifier        # topmoduleIdentifier
    ;

type_identifier
    : identifier        # typeIdentifier
    ;

udp_identifier
    : identifier        # udpIdentifier
    ;

variable_identifier
    : identifier        # variableIdentifier
    ;

array_manipulation_identifier_without
    : REVERSE       # arrayManipulationIdentifierWithoutReverse
    | SHUFFLE       # arrayManipulationIdentifierWithoutShuffle
    | MIN           # arrayManipulationIdentifierWithoutMin
    | MAX           # arrayManipulationIdentifierWithoutMax
    | UNIQUE_INDEX  # arrayManipulationIdentifierWithoutUniqueIndex
    | UNIQUE        # arrayManipulationIdentifierWithoutUnique
    | RSORT         # arrayManipulationIdentifierWithoutRsort
    | SORT          # arrayManipulationIdentifierWithoutSort
    | SUM           # arrayManipulationIdentifierWithoutSum
    | PRODUCT       # arrayManipulationIdentifierWithoutProduct
    | LAND          # arrayManipulationIdentifierWithoutAnd
    | LOR           # arrayManipulationIdentifierWithoutOr
    | XOR           # arrayManipulationIdentifierWithoutXor
    ;

array_manipulation_identifier_with
    : FIND_FIRST_INDEX  # arrayManipulationIdentifierWithFindFirstIndex
    | FIND_LAST_INDEX   # arrayManipulationIdentifierWithFindLastIndex
    | FIND_FIRST        # arrayManipulationIdentifierWithFindFirst
    | FIND_INDEX        # arrayManipulationIdentifierWithFindIndex
    | FIND_LAST         # arrayManipulationIdentifierWithFindLast
    | FIND              # arrayManipulationIdentifierWithFind
    | MIN               # arrayManipulationIdentifierWithMin
    | MAX               # arrayManipulationIdentifierWithMax
    | UNIQUE_INDEX      # arrayManipulationIdentifierWithUniqueIndex
    | UNIQUE            # arrayManipulationIdentifierWithUnique
    | RSORT             # arrayManipulationIdentifierWithRsort
    | SORT              # arrayManipulationIdentifierWithSort
    | SUM               # arrayManipulationIdentifierWithSum
    | PRODUCT           # arrayManipulationIdentifierWithProduct
    | LAND              # arrayManipulationIdentifierWithAnd
    | LOR               # arrayManipulationIdentifierWithOr
    | XOR               # arrayManipulationIdentifierWithXor
    ;

array_manipulation_identifiers
    : REVERSE               # arrayManipulationIdentifiersReverse
    | SHUFFLE               # arrayManipulationIdentifiersShuffle
    | FIND_FIRST_INDEX      # arrayManipulationIdentifiersFindFirstIndex
    | FIND_LAST_INDEX       # arrayManipulationIdentifiersFindLastIndex
    | FIND_FIRST            # arrayManipulationIdentifiersFindFirst
    | FIND_INDEX            # arrayManipulationIdentifiersFindIndex
    | FIND_LAST             # arrayManipulationIdentifiersFindLast
    | FIND                  # arrayManipulationIdentifiersFind
    | MIN                   # arrayManipulationIdentifiersMin
    | MAX                   # arrayManipulationIdentifiersMax
    | UNIQUE_INDEX          # arrayManipulationIdentifiersUniqueIndex
    | RSORT                 # arrayManipulationIdentifiersRsort
    | SORT                  # arrayManipulationIdentifiersSort
    | SUM                   # arrayManipulationIdentifiersSum
    | PRODUCT               # arrayManipulationIdentifiersProduct
    ;

// End of Annex A

// System functions
system_functions
    : utility_system_tasks
    | io_system_tasks
    ;

// 20. Utility system tasks and system functions
utility_system_tasks
    : simulation_control_task
    | time_function
    | timescale_tasks
    | conversion_functions
    | data_query_functions
    | array_query_function
    | math_functions
    | bit_vector_function
    | severity_message_task
    | assert_control_task
    | sampled_value_functions
    | probabilistic_functions
    | stochastic_functions
    | pla_system_task
    | system_call
    ;

// 20.2 Simulation control system tasks
simulation_control_task
    : SF_STOP ( LP finish_number RP )? SEMICOLON    # simulationControlTaskStop
    | SF_FINISH ( LP finish_number RP )? SEMICOLON  # simulationControlTaskFinish
    | SF_EXIT ( LP RP )? SEMICOLON                  # simulationControlTaskExit
    ;

// 20.3 Simulation time system functions
time_function
    : SF_TIME           # timeFunctionTime
    | SF_STIME          # timeFunctionSTime
    | SF_REALTIME       # timeFunctionRealtime
    ;

// 20.4 Timescale system tasks
timescale_tasks
    : printtimescale_task
    | timeformat_task
    ;

// 20.4.1 $printtimescale
printtimescale_task
    : SF_PRINTTIMESCALE ( LP hierarchical_identifier RP )? SEMICOLON    # printtimescaleTask
    ;

// 20.4.2 $timeformat
timeformat_task
    : SF_TIMEFORMAT ( LP units_number COMMA precision_number COMMA suffix_string COMMA minimum_field_width RP )? SEMICOLON  # timeformatTask
    ;

units_number
    : Unsigned_Number   # unitsNumber
    ;
precision_number
    : Unsigned_Number   # precisionNumber
    ;
suffix_string
    : Simple_Identifier # suffixString
    ;
minimum_field_width
    : Unsigned_Number   # minimumFieldWidth
    ;

// 20.5 Conversion functions
conversion_functions
    : real_conversion
    | bit_conversion
    | shortreal_conversion
    | int_conversion
    ;

real_conversion
    : SF_RTOI LP Real_Number RP         # realConversionRtoi
    | SF_REALTOBITS LP Real_Number RP   # realConversionRealtobits
    ;

bit_val
    : Binary_Number     # bitValBinary
    | Octal_Number      # bitValOctal
    | Hex_Number        # bitValHex
    ;

bit_conversion
    : SF_BITSTOREAL LP bit_val RP       # bitConversionBitsToReal
    | SF_BITSTOSHORTREAL LP bit_val RP  # bitConversionBitsToShortreal
    ;

shortreal_conversion
    : SF_SHORTREALTOBITS LP Real_Number RP  # shortrealConversion
    ;

int_conversion
    : SF_ITOR LP Unsigned_Number RP     # intConversion
    ;

// FRED XXX
sign_conversion
    : SF_SIGNED LP constant_primary RP      # signConversionSigned
    | SF_UNSIGNED LP constant_primary RP    # signConversionUnsigned
    ;

cast_conversion
    : SF_CAST LP constant_primary RP        # castConversion
    ;

// 20.6 Data query functions
data_query_functions
    : typename_function
    | size_function
    | range_function
    ;

// 20.6.1 Type name function
typename_function
    : SF_TYPENAME LP expression RP  # typenameFunctionExpr
    | SF_TYPENAME LP data_type RP   # typenameFunctionType
    ;

// 20.6.2 Expression size system function
size_function
    : SF_BITS LP expression RP      # sizeFunctionExpr
    | SF_BITS LP data_type RP       # sizeFunctionType
    ;

// 20.6.3 Range system function
range_function
    : SF_ISUNBOUNDED LP constant_expression RP  # rangeFunction
    ;

// 20.7 Array querying functions
array_query_function
    : array_dimension_function LP array_identifier ( COMMA dimension_expression )? RP   # arrayQueryFunctionIdentifierDimension
    | array_dimension_function LP data_type ( COMMA dimension_expression )? RP  # arrayQueryFunctionTypeDimension
    | array_dimensions_function LP array_identifier RP  # arrayQueryFunctionIdentifier
    | array_dimensions_function LP data_type RP # arrayQueryFunctionType
    ;

array_dimensions_function
    : SF_DIMENSIONS             # arrayDimensionsFunctionDimensions
    | SF_UNPACKED_DIMENSIONS    # arrayDimensionsFunctionUnpackedDimensions
    ;

array_dimension_function
    : SF_LEFT                   # arrayDimensionFunctionLeft
    | SF_RIGHT                  # arrayDimensionFunctionRight
    | SF_LOW                    # arrayDimensionFunctionLow
    | SF_HIGH                   # arrayDimensionFunctionHigh
    | SF_INCREMENT              # arrayDimensionFunctionIncrement
    | SF_SIZE                   # arrayDimensionFunctionSize
    ;

dimension_expression
    : expression                # dimensionExpression
    ;

// 20.8 Math functions
math_functions
    : math_function LP constant_expression RP   # mathFunctions
    ;

math_function
    : integer_math_function
    | real_math_function
    ;

integer_math_function
    : SF_CLOG2              # integerMathFunctionClog2
    ;

real_math_function
    : SF_LOG10              # realMathFunctionLog10
    | SF_HYPOT              # realMathFunctionHypot
    | SF_FLOOR              # realMathFunctionFloor
    | SF_ASINH              # realMathFunctionAsinh
    | SF_ACOSH              # realMathFunctionAcosh
    | SF_ATANH              # realMathFunctionAtanh
    | SF_ATAN2              # realMathFunctionAtan2
    | SF_SQRT               # realMathFunctionSort
    | SF_CEIL               # realMathFunctionCeil
    | SF_SINH               # realMathFunctionSinh
    | SF_COSH               # realMathFunctionCosh
    | SF_TANH               # realMathFunctionTanh
    | SF_ATAN               # realMathFunctionAtan
    | SF_ASIN               # realMathFunctionAsin
    | SF_ACOS               # realMathFunctionAcos
    | SF_TAN                # realMathFunctionTan
    | SF_POW                # realMathFunctionPow
    | SF_SIN                # realMathFunctionSin
    | SF_COS                # realMathFunctionCos
    | SF_EXP                # realMathFunctionExp
    | SF_LN                 # realMathFunctionLn
    ;

// 20.9 Bit vector system functions
bit_vector_function
    : SF_COUNTBITS LP expression COMMA list_of_control_bits RP  # bitVectorFunctionCountBits
    | SF_COUNTONES LP expression RP                             # bitVectorFunctionCountOnes
    | SF_ONEHOT LP expression RP                                # bitVectorFunctionOneHot
    | SF_ONEHOT0 LP expression RP                               # bitVectorFunctionOneHot0
    | SF_ISUNKNOWN LP expression RP                             # bitVectorFunctionIsUnknown
    ;

list_of_control_bits
    : control_bit ( COMMA control_bit )*        # listOfControlBits
    ;

// FRED XXX
control_bit
    : constant_primary      # controlBit
    ;

// 20.10 Severity tasks
severity_message_task
    : fatal_message_task
    | nonfatal_message_task
    ;

fatal_message_task
    : SF_FATAL ( LP finish_number ( COMMA list_of_arguments )? RP )? SEMICOLON  # fatalMessageTask
    ;

nonfatal_message_task
    : severity_task ( LP ( list_of_arguments )? RP )? SEMICOLON     # nonfatalMessageTask
    ;

severity_task
    : SF_ERROR          # severityTaskError
    | SF_WARNING        # severityTaskWarning
    | SF_INFO           # severityTaskInfo
    ;

// 20.12 Assertion control system tasks
assert_control_task
    : assert_task ( LP levels ( COMMA list_of_scopes_or_assertions )? RP )? SEMICOLON   # assertControlTaskAssert
    | assert_action_task ( LP levels ( COMMA list_of_scopes_or_assertions )? RP )? SEMICOLON    # assertControlTaskAssertAction
    | SF_ASSERTCONTROL LP control_type ( COMMA ( assertion_type )? ( COMMA ( directive_type )? ( COMMA ( levels )? ( COMMA list_of_scopes_or_assertions )? )? )? )? RP SEMICOLON    # assertControlTaskAssertControl
    ;

// FRED XXX
control_type
    : Unsigned_Number   # controlType
    ;
assertion_type
    : Unsigned_Number   # assertionType
    ;
directive_type
    : Unsigned_Number   # directiveType
    ;

// FRED XXX
levels
    : constant_expression   # levelsRule
    ;

assert_task
    : SF_ASSERTON       # assertTaskOn
    | SF_ASSERTOFF      # assertTaskOff
    | SF_ASSERTKILL     # assertTaskKill
    ;

assert_action_task
    : SF_ASSERTPASSON           # assertActionTaskPassOn
    | SF_ASSERTPASSOFF          # assertActionTaskPassOff
    | SF_ASSERTFAILON           # assertActionTaskFailOn
    | SF_ASSERTFAILOFF          # assertActionTaskFailOff
    | SF_ASSERTNONVACUOUSON     # assertActionTaskNonVacuousOn
    | SF_ASSERTVACUOUSOFF       # assertActionTaskVacuousOff
    ;
list_of_scopes_or_assertions
    : scope_or_assertion ( COMMA scope_or_assertion )*  # listOfScopesOrAssertions
    ;

scope_or_assertion
    : hierarchical_identifier   # scopeOrAssertion
    ;

// 20.13 Sampled value system functions
sampled_value_functions
    : sampled_value_function
    | global_clocking_past_function
    | global_clocking_future_function
    ;

sampled_value_function
    : SF_SAMPLED LP expression RP       # sampledValueFunctionSampled
    | SF_ROSE LP expression ( COMMA ( clocking_event )? )? RP       # sampledValueFunctionRose
    | SF_FELL LP expression ( COMMA ( clocking_event )? )? RP       # sampledValueFunctionFell
    | SF_STABLE LP expression ( COMMA ( clocking_event )? )? RP     # sampledValueFunctionStable
    | SF_CHANGED LP expression ( COMMA ( clocking_event )? )? RP        # sampledValueFunctionChanged
    | SF_PAST LP expression ( COMMA ( number_of_ticks )? ( COMMA ( expression )? ( COMMA ( clocking_event )? )? )? )? RP        # sampledValueFunctionPast
    ;

// FRED XXX
number_of_ticks
    : Unsigned_Number   # numberOfTicks
    ;

global_clocking_past_function
    : SF_PAST_GCLK LP expression RP     # globalClockingPastFunctionPast
    | SF_ROSE_GCLK LP expression RP     # globalClockingPastFunctionRose
    | SF_FELL_GCLK LP expression RP     # globalClockingPastFunctionFell
    | SF_STABLE_GCLK LP expression RP   # globalClockingPastFunctionStable
    | SF_CHANGED_GCLK LP expression RP  # globalClockingPastFunctionChanged
    ;

global_clocking_future_function
    : SF_FUTURE_GCLK LP expression RP   # globalClockingFutureFunctionFuture
    | SF_RISING_GCLK LP expression RP   # globalClockingFutureFunctionRising
    | SF_FALLING_GCLK LP expression RP  # globalClockingFutureFunctionFalling
    | SF_STEADY_GCLK LP expression RP   # globalClockingFutureFunctionSteady
    | SF_CHANGING_GCLK LP expression RP # globalClockingFutureFunctionChanging
    ;

// 20.14 Coverage system functions
control_constant
    : Zero
    | One
    | Two
    | Three
    ;

coverage_type
    : One Zero
    | One One
    ;

scope_def
    : Two Zero
    | Two One
    | Two Two
    | Two Three
    ;

modules_or_instance
    : StringLiteral
    | Instance_Identifier
    ;

coverage_control
	: SF_COVERAGE_CONTROL LP control_constant COMMA coverage_type COMMA scope_def COMMA modules_or_instance RP # coverageControl
    ;

coverage_get_max
	: SF_COVERAGE_GET_MAX LP coverage_type COMMA scope_def COMMA modules_or_instance RP # coverageGetMax
    ;

coverage_get
	: SF_COVERAGE_GET LP coverage_type COMMA scope_def COMMA modules_or_instance RP # coverageGet
    ;

coverage_merge
	: SF_COVERAGE_MERGE LP coverage_type StringLiteral RP # coverageMerge
    ;

coverage_save
	: SF_COVERAGE_SAVE LP coverage_type StringLiteral RP # coverageSave
    ;

// 19.9 Predefined coverage system tasks and system functions
set_coverage_db_name
	: SF_SET_COVERAGE_DB_NAME LP filename RP    # setCoverageDBName
    ;

load_coverage_db
	: SF_LOAD_COVERAGE_DB LP filename RP        # loadCoverageDB
    ;

get_coverage
	: SF_GET_COVERAGE LP RP                     # getCoverage
    ;

// 20.15 Probabilistic distribution functions
probabilistic_functions
    : random_function
    | dist_functions
    ;

random_function
    : SF_RANDOM ( LP seed RP )?     # randomFunction
    ;

dist_functions
    : SF_DIST_UNIFORM LP seed COMMA start_of_dist COMMA end_of_dist RP  # distFunctionsUniform
    | SF_DIST_NORMAL LP seed COMMA mean COMMA standard_deviation RP     # distFunctionsNormal
    | SF_DIST_EXPONENTIAL LP seed COMMA mean RP                         # distFunctionsExponential
    | SF_DIST_POISSON LP seed COMMA mean RP                             # distFunctionsPoisson
    | SF_DIST_CHI_SQUARE LP seed COMMA degree_of_freedom RP             # distFunctionsChiSquare
    | SF_DIST_T LP seed COMMA degree_of_freedom RP                      # distFunctionsT
    | SF_DIST_ERLANG LP seed COMMA k_stage COMMA mean RP                # distFunctionsErlang
    ;

seed
    : Unsigned_Number   # seedRule
    ;
start_of_dist
    : Unsigned_Number   # startOfDist
    ;
end_of_dist
    : Unsigned_Number   # endOfDist
    ;
mean
    : Unsigned_Number   # meanRule
    ;
standard_deviation
    : Unsigned_Number   # standardDeviation
    ;
degree_of_freedom
    : Unsigned_Number   # degreeOfFreedom
    ;
k_stage
    : Unsigned_Number   # kStage
    ;

// 20.16 Stochastic analysis tasks and functions
stochastic_functions
    : SF_Q_INITIALIZE LP q_id COMMA q_type COMMA max_length COMMA status RP SEMICOLON   # stochasticFunctionsInitialize
    | SF_Q_ADD  LP q_id COMMA job_id COMMA inform_id COMMA status RP SEMICOLON          # stochasticFunctionsAdd
    | SF_Q_REMOVE LP q_id COMMA job_id COMMA inform_id COMMA status RP SEMICOLON        # stochasticFunctionsRemove
    | SF_Q_FULL LP q_id COMMA status RP                                                 # stochasticFunctionsFull
    | SF_Q_EXAM LP q_id COMMA q_stat_code COMMA q_stat_value COMMA status RP SEMICOLON  # stochasticFunctionsExam
    ;

q_id
    : Unsigned_Number   # qId
    ;
q_type
    : Unsigned_Number   # qType
    ;
max_length
    : Unsigned_Number   # maxLength
    ;
status
    : Unsigned_Number   # statusRule
    ;
job_id
    : Unsigned_Number   # jobId
    ;
inform_id
    : Unsigned_Number   # informId
    ;
q_stat_code
    : Unsigned_Number   # qStatCode
    ;
q_stat_value
    : Unsigned_Number   # qStateValue
    ;

// 20.17 Programmable logic array modeling system tasks
pla_system_task
    : system_tasks LP memory_identifier COMMA input_terms COMMA output_terms RP SEMICOLON   # plaSystemTasks
    ;

system_tasks
    : SF_ASYNC_NAND_PLANE   # systemTasksAsyncNandPlane
    | SF_ASYNC_NAND_ARRAY   # systemTasksAsyncNandArray
    | SF_ASYNC_NOR_PLANE    # systemTasksAsyncNorPlane
    | SF_ASYNC_NOR_ARRAY    # systemTasksAsyncNorArray
    | SF_ASYNC_AND_PLANE    # systemTasksAsyncAndPlane
    | SF_ASYNC_AND_ARRAY    # systemTasksAsyncAndArray
    | SF_SYNC_NAND_PLANE    # systemTasksSyncNandPlane
    | SF_SYNC_NAND_ARRAY    # systemTasksSyncNandArray
    | SF_SYNC_NOR_PLANE     # systemTasksSyncNorPlane
    | SF_SYNC_NOR_ARRAY     # systemTasksSyncNorArray
    | SF_SYNC_AND_PLANE     # systemTasksSyncAndPlane
    | SF_SYNC_AND_ARRAY     # systemTasksSyncAndArray
    | SF_ASYNC_OR_PLANE     # systemTasksAsyncOrPlane
    | SF_ASYNC_OR_ARRAY     # systemTasksAsyncOrArray
    | SF_SYNC_OR_PLANE      # systemTasksSyncOrPlane
    | SF_SYNC_OR_ARRAY      # systemTasksSyncOrArray
    ;

memory_identifier
    : identifier    # memoryIdentifier
    ;

input_terms
    : expression    # inputTerms
    ;

output_terms
    : variable_lvalue   # outputTerms
    ;

// 20.18 Miscellaneous tasks and functions
system_call
    : SF_SYSTEM LP ( DQ terminal_command_line DQ )? RP  # systemCall
    ;

terminal_command_line
    : StringLiteral     # terminalCommandLine
    ;

// 21. Input/output system tasks and system functions
io_system_tasks
    : display_tasks
    | strobe_tasks
    | monitor_tasks
    | io_tasks
    | load_memory_tasks
    | writemem_tasks
    | command_line_input
    | vcd_tasks
    ;

// 21.2 Display system tasks
display_tasks
    : display_task_name ( LP list_of_arguments RP )? SEMICOLON  # displayTasks
    ;

display_task_name
    : SF_DISPLAYO   # displayTaskNameDisplayOctal
    | SF_DISPLAYH   # displayTaskNameDisplayHex
    | SF_DISPLAYB   # displayTaskNameDisplayBinary
    | SF_DISPLAY    # displayTaskNameDisplay
    | SF_WRITEO     # displayTaskNameWriteOctal
    | SF_WRITEH     # displayTaskNameWriteHex
    | SF_WRITEB     # displayTaskNameWriteBinary
    | SF_WRITE      # displayTaskNameWrite
    ;

// 21.2.2 Strobed monitoring
strobe_tasks
    : strobe_task_name ( LP list_of_arguments RP )? SEMICOLON   # strobeTasks
    ;

strobe_task_name
    : SF_STROBEO    # strobeTaskNameOctal
    | SF_STROBEH    # strobeTaskNameHex
    | SF_STROBEB    # strobeTaskNameBinary
    | SF_STROBE     # strobeTaskName
    ;

// 21.2.3 Continuous monitoring
monitor_tasks
    : monitor_task_name ( LP list_of_arguments RP )? SEMICOLON  # monitorTasks
    | SF_MONITORON SEMICOLON                                    # monitorTasksOn
    | SF_MONITOROFF SEMICOLON                                   # monitorTasksOff
    ;

monitor_task_name
    : SF_MONITORO       # monitorTaskNameOctal
    | SF_MONITORH       # monitorTaskNameHex
    | SF_MONITORB       # monitorTaskNameBinary
    | SF_MONITOR        # monitorTaskName
    ;

// 21.3 Input/output system tasks and system functions
io_tasks
    : file_open_function
    | file_close_task
    | file_output_tasks
    | string_output_tasks
    | variable_format_string_output_task
    | variable_format_string_output_function
    | file_read_functions
    | file_positioning_functions
    | file_flush_task
    | file_error_detect_function
    | file_eof_detect_function
    ;

// 21.3.1 Opening and closing files
file_open_function
    : multi_channel_descriptor ASSIGN SF_FOPEN LP filename RP SEMICOLON     # fileOpenFunctionMcd
    | fd ASSIGN SF_FOPEN LP filename COMMA file_type RP SEMICOLON                # fileOpenFunctionFd
    ;

file_close_task
    : SF_FCLOSE LP multi_channel_descriptor RP SEMICOLON        # fileCloseTaskMcd
    | SF_FCLOSE LP fd RP SEMICOLON                              # fileCloseTaskFd
    ;

// FRED XXX
filename
    : StringLiteral         # filenameRule
    ;
file_type
    : StringLiteral         # typeRule
    ;
multi_channel_descriptor
    : primary_literal       # multiChannelDescriptor
    ;
fd
    : primary_literal       # fdRule
    ;

// 21.3.2 File output system tasks
file_output_tasks
    : file_output_task_name LP multi_channel_descriptor ( COMMA list_of_arguments )? RP SEMICOLON   # fileOutputTasksMcd
    | file_output_task_name LP fd ( COMMA list_of_arguments )? RP SEMICOLON                         # fileOutputTasksFd
    ;

file_output_task_name
    : SF_FDISPLAYO      # fileOutputTaskNameFDisplayOctal
    | SF_FDISPLAYH      # fileOutputTaskNameFDisplayHex
    | SF_FDISPLAYB      # fileOutputTaskNameFDisplayBinary
    | SF_FDISPLAY       # fileOutputTaskNameFDisplay
    | SF_FWRITEO        # fileOutputTaskNameFWriteOctal
    | SF_FWRITEH        # fileOutputTaskNameFWriteHex
    | SF_FWRITEB        # fileOutputTaskNameFWriteBinary
    | SF_FWRITE         # fileOutputTaskNameFWrite
    | SF_FSTROBEO       # fileOutputTaskNameFStrobeOctal
    | SF_FSTROBEH       # fileOutputTaskNameFStrobeHex
    | SF_FSTROBEB       # fileOutputTaskNameFStrobeBinary
    | SF_FSTROBE        # fileOutputTaskNameFStrobe
    | SF_MONITORO       # fileOutputTaskNameMonitorOctal
    | SF_MONITORH       # fileOutputTaskNameMonitorHex
    | SF_MONITORB       # fileOutputTaskNameMonitorBinary
    | SF_MONITOR        # fileOutputTaskNameMonitor
    ;

// 21.3.3 Formatting data to a string
string_output_tasks
    : string_output_task_name LP output_var ( COMMA list_of_arguments )? RP SEMICOLON   # stringOutputTasks
    ;

string_output_task_name
    : SF_SWRITEO        # stringOutputTaskNameOctal
    | SF_SWRITEH        # stringOutputTaskNameHex
    | SF_SWRITEB        # stringOutputTaskNameBinary
    | SF_SWRITE         # stringOutputTaskName
    ;

// FRED XXX
output_var
    : primary       # outputVar
    ;
format_string
    : constant_primary  # formatString
    ;

variable_format_string_output_task
    : SF_SFORMAT LP output_var COMMA format_string ( COMMA list_of_arguments )? RP SEMICOLON    # variableFormatStringOutputTask
    ;

// XXX FRED added $psprintf
variable_format_string_output_function
    : SF_SFORMATF LP format_string ( COMMA list_of_arguments )? RP  # variableFormatStringOutputFunctionSformatf
    | SF_PSPRINTF LP format_string ( COMMA list_of_arguments )? RP  # variableFormatStringOutputFunctionPsprintf
    ;

// 21.3.4 Reading data from a file
file_read_functions
    : SF_FGETC LP fd RP                                                                 # fileReadFunctionsFgetc
    | SF_UNGETC LP character COMMA fd RP                                                # fileReadFunctionsUngetc
    | SF_FGETS LP file_str COMMA fd RP                                                       # fileReadFunctionsFgets
    | SF_FSCANF LP fd COMMA format_string COMMA list_of_arguments RP                    # fileReadFunctionsFscanf
    | SF_SSCANF LP file_str COMMA format_string COMMA list_of_arguments RP                   # fileReadFunctionsSscanf
    | SF_FREAD LP integral_var COMMA fd RP                                              # fileReadFunctionsFreadVariable
    | SF_FREAD LP mem COMMA fd ( COMMA ( start_number )? ( COMMA count_number )? )? RP  # fileReadFunctionsFreadMemory
    ;

// FRED XXX
character
    : primary   # characterRule
    ;
file_str
    : primary   # strRule
    ;
integral_var
    : primary   # integralVar
    ;
mem
    : primary   # memRule
    ;
start_number
    : Unsigned_Number   # startNumber
    ;
count_number
    : Unsigned_Number   # countNumber
    ;

// 21.3.5 File positioning
file_positioning_functions
    : SF_FTELL LP fd RP                                 # filePositioningFunctionsFtell
    | SF_FSEEK LP fd COMMA offset COMMA operation RP    # filePositioningFunctionsFseek
    | SF_REWIND LP fd RP                                # filePositioningFunctionsRewind
    ;

// FRED XXX
offset
    : constant_primary      # offsetRule
    ;
operation
    : constant_primary      # operationRule
    ;

// 21.3.6 Flushing output
file_flush_task
    : SF_FFLUSH LP ( multi_channel_descriptor | fd )? RP SEMICOLON  # fileFlushTask
    ;

// 21.3.7 I/O error status
file_error_detect_function
    : SF_FERROR LP fd COMMA file_str RP  # fileErrorDetectFunction
    ;

// 21.3.8 Detecting EOF
file_eof_detect_function
    : SF_FEOF LP fd RP      # fileEofDetectFunction
    ;

// 21.4 Loading memory array data from a file
load_memory_tasks
    : SF_READMEMB LP filename COMMA memory_name ( COMMA start_addr ( COMMA finish_addr )? )? RP SEMICOLON   # loadMemoryTasksBinary
    | SF_READMEMH LP filename COMMA memory_name ( COMMA start_addr ( COMMA finish_addr )? )? RP SEMICOLON   # loadMemoryTasksHex
    ;

// FRED XXX
memory_name
    : primary_literal   # memoryName
    ;
start_addr
    : Unsigned_Number   # startAddr
    ;
finish_addr
    : Unsigned_Number   # finishAddr
    ;

// 21.5 Writing memory array data to a file
writemem_tasks
    : SF_WRITEMEMB LP filename COMMA memory_name ( COMMA start_addr ( COMMA finish_addr )? )? RP SEMICOLON  # writememTasksBinary
    | SF_WRITEMEMH LP filename COMMA memory_name ( COMMA start_addr ( COMMA finish_addr )? )? RP SEMICOLON  # writememTasksHex
    ;

// 21.6 Command line input
command_line_input
    : SF_TEST_PLUSARGS LP test_string RP                        # commandLineInputTestPlusargs
    | SF_VALUE_PLUSARGS LP user_string COMMA user_variable RP   # commandLineInputValuePlusargs
    ;

// FRED XXX
test_string
    : StringLiteral         # testString
    ;
user_string
    : StringLiteral         # userString
    ;
user_variable
    : Simple_Identifier     # userVariable
    ;

// 21.7 Value change dump (VCD) files
vcd_tasks
    : dumpfile_task
    | dumpvars_task
    | dumpoff_task
    | dumpon_task
    | dumpall_task
    | dumplimit_task
    | dumpflush_task
    ;

dumpfile_task
    : SF_DUMPFILE LP filename RP SEMICOLON      # dumpfileTask
    ;

dumpvars_task
    : SF_DUMPVARS SEMICOLON     # dumpvarsTask
    | SF_DUMPVARS LP levels ( COMMA list_of_modules_or_variables )? RP SEMICOLON        # dumpvarsTaskParends
    ;

list_of_modules_or_variables
    : module_or_variable ( COMMA module_or_variable )*      # listOfModulesOrVariables
    ;

module_or_variable
    : module_identifier
    | variable_identifier
    ;

dumpoff_task
    : SF_DUMPOFF SEMICOLON      # dumpoffTask
    ;

dumpon_task
    : SF_DUMPON SEMICOLON       # dumponTask
    ;

dumpall_task
    : SF_DUMPALL SEMICOLON      # dumpallTask
    ;

dumplimit_task
    : SF_DUMPLIMIT LP filesize RP SEMICOLON     # dumplimitTask
    ;

// FRED XXX
filesize
    : Unsigned_Number       # filesizeRule
    ;

dumpflush_task
    : SF_DUMPFLUSH SEMICOLON    # dumpflushTask
    ;

// 21.7.2 Format of 4-state VCD file
