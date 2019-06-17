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
//
package examples.linter;

import java.util.List;

import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.Token;

import com.veriktig.scandium.ieee1800_2017.grammar.IEEE1800_2017Lexer;
import com.veriktig.scandium.ieee1800_2017.grammar.IEEE1800_2017Parser;
import com.veriktig.scandium.ieee1800_2017.grammar.IEEE1800_2017ParserBaseListener;

public class Linter extends IEEE1800_2017ParserBaseListener {
    private CommonTokenStream tokens;
    private String current_file = new String("");
    private String previous_file = new String("");
    private Integer line_number = new Integer(1);

    public boolean implicitMethod;
    public boolean implicitWarnings;
    public boolean implicitDataWarning;
    public boolean importWarning;
    public boolean ansiWarning;
    public boolean nonStandardTFWarning;
    public boolean netTypeWarning;
    public boolean genericInterfaceWarning;
    public boolean newParendsWarning;
    public boolean nullArgument;
    public boolean noPortDirectionWarning;

    public Linter(CommonTokenStream tokens) {
        this.tokens = tokens;
    }

	@Override
    public void enterEveryRule(ParserRuleContext ctx) {
        Token semi = ctx.getStart();
        if (semi != null) {
            int ii = semi.getTokenIndex();
            List<Token> ltokens = tokens.getHiddenTokensToLeft(ii, IEEE1800_2017Lexer.LINE_CHANNEL);
            if (ltokens != null) {
                int size = ltokens.size();
                Token token = ltokens.get(size - 3);
                if (token != null) {
                    line_number = new Integer(token.getText());
                }
                token = ltokens.get(size - 2);
                if (token != null) {
                    String filename = token.getText();
                    filename = filename.replaceAll("\"", "");
                    current_file = filename;
                }
            }
        }
    }
    private void display(String msg) {
        if (!current_file.equals(previous_file)) {
            System.out.println(current_file);
            previous_file = current_file;
        }
        System.out.println("    Line " + line_number + ": " + msg);
    }

	@Override public void exitModuleNonansiHeaderPostPackageImport(IEEE1800_2017Parser.ModuleNonansiHeaderPostPackageImportContext ctx) {
        if (importWarning)
            display("package_import_declaration should be after module_identifier.");
    }
	@Override public void exitModuleAnsiHeaderPostPackageImport(IEEE1800_2017Parser.ModuleAnsiHeaderPostPackageImportContext ctx) {
        if (importWarning)
            display("package_import_declaration should be after module_identifier.");
    }
	@Override public void exitListOfPortDeclarationsNonansi(IEEE1800_2017Parser.ListOfPortDeclarationsNonansiContext ctx) {
        if (ansiWarning)
            display("Missing data_type on ansi_port_declaration: " + ctx.getText());
    }
	@Override public void exitNetPortHeaderImplicit(IEEE1800_2017Parser.NetPortHeaderImplicitContext ctx) {
        if (noPortDirectionWarning)
            display("No port_direction specified: " + ctx.getText());
    }
	@Override public void exitInterfacePortHeaderInterface(IEEE1800_2017Parser.InterfacePortHeaderInterfaceContext ctx) {
        if (genericInterfaceWarning)
            display("Generic interface reference: " + ctx.getText());
    }
	@Override public void exitLocalParameterDeclarationImplicit(IEEE1800_2017Parser.LocalParameterDeclarationImplicitContext ctx) {
        if (implicitWarnings)
            display("Implicit data_type on localparam: " + ctx.getText());
    }
	@Override public void exitParameterDeclarationImplicit(IEEE1800_2017Parser.ParameterDeclarationImplicitContext ctx) {
        if (implicitWarnings)
            display("Implicit data_type on parameter: " + ctx.getText());
    }
	@Override public void exitInoutDeclarationImplicit(IEEE1800_2017Parser.InoutDeclarationImplicitContext ctx) {
        if (implicitWarnings)
            display("Implicit net_port_type on inout port: " + ctx.getText());
    }
	@Override public void exitInputDeclarationImplicit(IEEE1800_2017Parser.InputDeclarationImplicitContext ctx) {
        if (implicitWarnings)
            display("Implicit net_port_type on input port: " + ctx.getText());
    }
	@Override public void exitOutputDeclarationImplicit(IEEE1800_2017Parser.OutputDeclarationImplicitContext ctx) {
        if (implicitWarnings)
            display("Implicit net_port_type on output port: " + ctx.getText());
    }
	@Override public void exitDataDeclarationImport(IEEE1800_2017Parser.DataDeclarationImportContext ctx) {
        if (implicitDataWarning)
            display("Implicit data_declaration: " + ctx.getText());
    }
	@Override public void exitNetDeclarationImplicit(IEEE1800_2017Parser.NetDeclarationImplicitContext ctx) {
        if (implicitWarnings)
            display("Implicit data_type on net_declaration: " + ctx.getText());
    }
	@Override public void exitNetDeclarationInterconnectNoSize(IEEE1800_2017Parser.NetDeclarationInterconnectNoSizeContext ctx) {
        if (implicitWarnings)
            display("Implicit data_type on interconnect: " + ctx.getText());
    }
	@Override public void exitNetPortTypeNull(IEEE1800_2017Parser.NetPortTypeNullContext ctx) {
        if (implicitWarnings)
            display("Implicit data_type on net_port_type.");
    }
	@Override public void exitNetPortTypeDataOrImplicitNetType(IEEE1800_2017Parser.NetPortTypeDataOrImplicitNetTypeContext ctx) {
        if (netTypeWarning)
            display("net_type on port: " + ctx.getText());
    }
	@Override public void exitNetPortTypeInterconnectNoSize(IEEE1800_2017Parser.NetPortTypeInterconnectNoSizeContext ctx) {
        if (implicitWarnings)
            display("Implicit data_type on interconnect.");
    }
	@Override public void exitVarDataTypeVar(IEEE1800_2017Parser.VarDataTypeVarContext ctx) {
        if (implicitWarnings)
            display("Implicit data_type on var_data_type.");
    }
	@Override public void exitClassNewVoid(IEEE1800_2017Parser.ClassNewVoidContext ctx) {
        if (newParendsWarning)
            display("class_new does not require parends: " + ctx.getText());
    }
	@Override public void exitFunctionBodyDeclarationImplicit(IEEE1800_2017Parser.FunctionBodyDeclarationImplicitContext ctx) {
        if (implicitWarnings)
            display("Implicit data_type on function_body_declaration.");
    }
	@Override public void exitFunctionBodyDeclarationPortImplicit(IEEE1800_2017Parser.FunctionBodyDeclarationPortImplicitContext ctx) {
        if (implicitWarnings)
            display("Implicit data_type on function_body_declaration.");
    }
	@Override public void exitTfPortItemImplicit(IEEE1800_2017Parser.TfPortItemImplicitContext ctx) {
        if (implicitWarnings)
            display("Implicit data_type on tf_port_item: " + ctx.getText());
    }
	@Override public void exitTfPortDeclarationImplicit(IEEE1800_2017Parser.TfPortDeclarationImplicitContext ctx) {
        if (implicitWarnings)
            display("Implicit data_type on tf_port_declaration: " + ctx.getText());
    }
	@Override public void exitPropertyListOfArgsNull(IEEE1800_2017Parser.PropertyListOfArgsNullContext ctx) {
        if (nullArgument)
            display("Null property_actual_arg: " + ctx.getText());
    }
	@Override public void exitPropertyPortItemImplicit(IEEE1800_2017Parser.PropertyPortItemImplicitContext ctx) {
        if (implicitWarnings)
            display("Implicit data_type on property_port_item: " + ctx.getText());
    }
	@Override public void exitSequencePortItemImplicit(IEEE1800_2017Parser.SequencePortItemImplicitContext ctx) {
        if (implicitWarnings)
            display("Implicit sequence_formal_type on sequence_port_item: " + ctx.getText());
    }
	@Override public void exitSequenceFormalTypeImplicit(IEEE1800_2017Parser.SequenceFormalTypeImplicitContext ctx) {
        if (implicitWarnings)
            display("Implicit data_type on sequence_formal_type.");
    }
	@Override public void exitSequenceListOfArgsNull(IEEE1800_2017Parser.SequenceListOfArgsNullContext ctx) {
        if (nullArgument)
            display("Null sequence_actual_arg: " + ctx.getText());
    }
	@Override public void exitLetPortItemImplicit(IEEE1800_2017Parser.LetPortItemImplicitContext ctx) {
        if (implicitWarnings)
            display("Implicit data_type on let_port_item: " + ctx.getText());
    }
	@Override public void exitLetFormalTypeImplicit(IEEE1800_2017Parser.LetFormalTypeImplicitContext ctx) {
        if (implicitWarnings)
            display("Implicit data_type on let_formal_type: " + ctx.getText());
    }
	@Override public void exitLetListOfArgumentsNull(IEEE1800_2017Parser.LetListOfArgumentsNullContext ctx) {
        if (nullArgument)
            display("Null let_actual_arg: " + ctx.getText());
    }
	@Override public void exitCoverPointNull(IEEE1800_2017Parser.CoverPointNullContext ctx) {
        if (implicitWarnings)
            display("No bins_or_empty on cover_point: " + ctx.getText());
    }
	@Override public void exitOrderedPortConnectionNull(IEEE1800_2017Parser.OrderedPortConnectionNullContext ctx) {
        if (nullArgument)
            display("Null expression in ordered_port_connection: " + ctx.getText());
    }
	@Override public void exitOrderedCheckerPortConnectionNull(IEEE1800_2017Parser.OrderedCheckerPortConnectionNullContext ctx) {
        if (nullArgument)
            display("Null property_actual_arg: " + ctx.getText());
    }
	@Override public void exitListOfArgumentsNull(IEEE1800_2017Parser.ListOfArgumentsNullContext ctx) {
        if (nullArgument)
            display("Null argument: " + ctx.getText());
    }
	@Override public void exitMethodCallImplicit(IEEE1800_2017Parser.MethodCallImplicitContext ctx) {
        if (implicitMethod)
            display("Implicit method_call: " + ctx.getText());
    }

}
