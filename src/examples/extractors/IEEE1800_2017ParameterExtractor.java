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

package examples.extractors;

import java.util.ArrayList;
import java.util.List;

import com.veriktig.scandium.ieee1800_2017.grammar.IEEE1800_2017Parser;
import com.veriktig.scandium.ieee1800_2017.grammar.IEEE1800_2017ParserBaseListener;

import examples.object_model.SVModule;
import examples.object_model.SVParameter;

public class IEEE1800_2017ParameterExtractor extends IEEE1800_2017ParserBaseListener {
    // Module
    private String moduleString = new String("");
    // Headers
    private boolean moduleHeader;
    // Ports
    private boolean firstModule = true;
    private List<SVModule> modules;
    private List<SVParameter> parameters = new ArrayList<SVParameter>();

    public IEEE1800_2017ParameterExtractor(List<SVModule> modules) {
        this.modules = modules;
    }

	@Override public void enterModuleIdentifier(IEEE1800_2017Parser.ModuleIdentifierContext ctx) {
        if (firstModule && moduleHeader) {
            moduleString = ctx.getText();
            firstModule = false;
        }
    }

    // Module Headers
	@Override public void enterModuleNonansiHeader(IEEE1800_2017Parser.ModuleNonansiHeaderContext ctx) {
        moduleHeader = true;
    }
	@Override public void exitModuleNonansiHeader(IEEE1800_2017Parser.ModuleNonansiHeaderContext ctx) {
        moduleHeader = false;
    }
	@Override public void enterModuleNonansiHeaderPostPackageImport(IEEE1800_2017Parser.ModuleNonansiHeaderPostPackageImportContext ctx) {
        moduleHeader = true;
    }
	@Override public void exitModuleNonansiHeaderPostPackageImport(IEEE1800_2017Parser.ModuleNonansiHeaderPostPackageImportContext ctx) {
        moduleHeader = false;
    }
	@Override public void enterModuleAnsiHeader(IEEE1800_2017Parser.ModuleAnsiHeaderContext ctx) {
        moduleHeader = true;
    }
	@Override public void exitModuleAnsiHeader(IEEE1800_2017Parser.ModuleAnsiHeaderContext ctx) {
        moduleHeader = false;
    }
	@Override public void enterModuleAnsiHeaderPostPackageImport(IEEE1800_2017Parser.ModuleAnsiHeaderPostPackageImportContext ctx) {
        moduleHeader = true;
    }
	@Override public void exitModuleAnsiHeaderPostPackageImport(IEEE1800_2017Parser.ModuleAnsiHeaderPostPackageImportContext ctx) {
        moduleHeader = false;
    }

    // Parameter ports
	@Override public void enterParameterPortListAssign(IEEE1800_2017Parser.ParameterPortListAssignContext ctx) {
        if (!moduleHeader) return;
        System.out.println("enterParameterPortListAssign " + ctx.getText());
    }
	@Override public void exitParameterPortListAssign(IEEE1800_2017Parser.ParameterPortListAssignContext ctx) {
        if (!moduleHeader) return;
        System.out.println("exitParameterPortListAssign");
    }
	@Override public void enterParameterPortListDecl(IEEE1800_2017Parser.ParameterPortListDeclContext ctx) {
        if (!moduleHeader) return;
        System.out.println("enterParameterPortListDecl " + ctx.getText());
    }
	@Override public void exitParameterPortListDecl(IEEE1800_2017Parser.ParameterPortListDeclContext ctx) {
        if (!moduleHeader) return;
        System.out.println("exitParameterPortListDecl");
    }
	@Override public void enterParameterPortDeclarationParam(IEEE1800_2017Parser.ParameterPortDeclarationParamContext ctx) {
        if (!moduleHeader) return;
        System.out.println("enterParameterPortDeclarationParam " + ctx.getText());
    }
	@Override public void exitParameterPortDeclarationParam(IEEE1800_2017Parser.ParameterPortDeclarationParamContext ctx) {
        if (!moduleHeader) return;
        System.out.println("exitParameterPortDeclarationParam");
    }
	@Override public void enterParameterPortDeclarationLocalParam(IEEE1800_2017Parser.ParameterPortDeclarationLocalParamContext ctx) {
        if (!moduleHeader) return;
        System.out.println("enterParameterPortDeclarationLocalParam " + ctx.getText());
    }
	@Override public void exitParameterPortDeclarationLocalParam(IEEE1800_2017Parser.ParameterPortDeclarationLocalParamContext ctx) {
        if (!moduleHeader) return;
        System.out.println("exitParameterPortDeclarationLocalParam");
    }
	@Override public void enterParameterPortDeclarationList(IEEE1800_2017Parser.ParameterPortDeclarationListContext ctx) {
        if (!moduleHeader) return;
        System.out.println("enterParameterPortDeclarationList " + ctx.getText());
    }
	@Override public void exitParameterPortDeclarationList(IEEE1800_2017Parser.ParameterPortDeclarationListContext ctx) {
        if (!moduleHeader) return;
        System.out.println("exitParameterPortDeclarationList");
    }
	@Override public void enterParameterPortDeclarationTypeList(IEEE1800_2017Parser.ParameterPortDeclarationTypeListContext ctx) {
        if (!moduleHeader) return;
        System.out.println("enterParameterPortDeclarationTypeList " + ctx.getText());
    }
	@Override public void exitParameterPortDeclarationTypeList(IEEE1800_2017Parser.ParameterPortDeclarationTypeListContext ctx) {
        if (!moduleHeader) return;
        System.out.println("exitParameterPortDeclarationTypeList");
    }

	@Override public void enterLocalParameterDeclaration(IEEE1800_2017Parser.LocalParameterDeclarationContext ctx) {
        if (!moduleHeader) return;
        System.out.println("enterLocalParameterDeclaration " + ctx.getText());
    }
	@Override public void exitLocalParameterDeclaration(IEEE1800_2017Parser.LocalParameterDeclarationContext ctx) {
        if (!moduleHeader) return;
        System.out.println("exitLocalParameterDeclaration");
    }
	@Override public void enterLocalParameterDeclarationImplicit(IEEE1800_2017Parser.LocalParameterDeclarationImplicitContext ctx) {
        if (!moduleHeader) return;
        System.out.println("enterLocalParameterDeclarationImplicit " + ctx.getText());
    }
	@Override public void exitLocalParameterDeclarationImplicit(IEEE1800_2017Parser.LocalParameterDeclarationImplicitContext ctx) {
        if (!moduleHeader) return;
        System.out.println("exitLocalParameterDeclarationImplicit");
    }
	@Override public void enterLocalParameterDeclarationType(IEEE1800_2017Parser.LocalParameterDeclarationTypeContext ctx) {
        if (!moduleHeader) return;
        System.out.println("enterLocalParameterDeclarationType " + ctx.getText());
    }
	@Override public void exitLocalParameterDeclarationType(IEEE1800_2017Parser.LocalParameterDeclarationTypeContext ctx) {
        if (!moduleHeader) return;
        System.out.println("exitLocalParameterDeclarationType");
    }
	@Override public void enterParameterDeclaration(IEEE1800_2017Parser.ParameterDeclarationContext ctx) {
        if (!moduleHeader) return;
        System.out.println("enterParameterDeclaration " + ctx.getText());
    }
	@Override public void exitParameterDeclaration(IEEE1800_2017Parser.ParameterDeclarationContext ctx) {
        if (!moduleHeader) return;
        System.out.println("exitParameterDeclaration");
    }
	@Override public void enterParameterDeclarationImplicit(IEEE1800_2017Parser.ParameterDeclarationImplicitContext ctx) {
        if (!moduleHeader) return;
        System.out.println("enterParameterDeclarationImplicit " + ctx.getText());
    }
	@Override public void exitParameterDeclarationImplicit(IEEE1800_2017Parser.ParameterDeclarationImplicitContext ctx) {
        if (!moduleHeader) return;
        System.out.println("exitParameterDeclarationImplicit");
    }
	@Override public void enterParameterDeclarationType(IEEE1800_2017Parser.ParameterDeclarationTypeContext ctx) {
        if (!moduleHeader) return;
        System.out.println("enterParameterDeclarationType " + ctx.getText());
    }
	@Override public void exitParameterDeclarationType(IEEE1800_2017Parser.ParameterDeclarationTypeContext ctx) {
        if (!moduleHeader) return;
        System.out.println("exitParameterDeclarationType");
    }

	@Override public void enterParamAssignment(IEEE1800_2017Parser.ParamAssignmentContext ctx) {
        if (!moduleHeader) return;
        System.out.println("enterParamAssignment " + ctx.getText());
    }
	@Override public void exitParamAssignment(IEEE1800_2017Parser.ParamAssignmentContext ctx) {
        if (!moduleHeader) return;
        System.out.println("exitParamAssignment");
    }
	@Override public void enterParameterIdentifier(IEEE1800_2017Parser.ParameterIdentifierContext ctx) {
        if (!moduleHeader) return;
        System.out.println("enterParameterIdentifier " + ctx.getText());
    }
	@Override public void exitParameterIdentifier(IEEE1800_2017Parser.ParameterIdentifierContext ctx) {
        if (!moduleHeader) return;
        System.out.println("exitParameterIdentifier");
    }
	@Override public void enterConstantParamExpressionMintypmax(IEEE1800_2017Parser.ConstantParamExpressionMintypmaxContext ctx) {
        if (!moduleHeader) return;
        System.out.println("enterConstantParamExpressionMintypmax " + ctx.getText());
    }
	@Override public void exitConstantParamExpressionMintypmax(IEEE1800_2017Parser.ConstantParamExpressionMintypmaxContext ctx) {
        if (!moduleHeader) return;
        System.out.println("exitConstantParamExpressionMintypmax");
    }
	@Override public void enterConstantParamExpressionDataType(IEEE1800_2017Parser.ConstantParamExpressionDataTypeContext ctx) {
        if (!moduleHeader) return;
        System.out.println("enterConstantParamExpressionDataType " + ctx.getText());
    }
	@Override public void exitConstantParamExpressionDataType(IEEE1800_2017Parser.ConstantParamExpressionDataTypeContext ctx) {
        if (!moduleHeader) return;
        System.out.println("exitConstantParamExpressionDataType");
    }
	@Override public void enterConstantParamExpressionDollarSign(IEEE1800_2017Parser.ConstantParamExpressionDollarSignContext ctx) {
        if (!moduleHeader) return;
        System.out.println("enterConstantParamExpressionDollarSign " + ctx.getText());
    }
	@Override public void exitConstantParamExpressionDollarSign(IEEE1800_2017Parser.ConstantParamExpressionDollarSignContext ctx) {
        if (!moduleHeader) return;
        System.out.println("exitConstantParamExpressionDollarSign");
    }

	@Override public void enterConstantMintypmaxExpression(IEEE1800_2017Parser.ConstantMintypmaxExpressionContext ctx) {
        if (!moduleHeader) return;
        System.out.println("enterConstantMintypmaxExpression " + ctx.getText());
    }
	@Override public void exitConstantMintypmaxExpression(IEEE1800_2017Parser.ConstantMintypmaxExpressionContext ctx) {
        if (!moduleHeader) return;
        System.out.println("exitConstantMintypmaxExpression");
    }
	@Override public void enterConstantMintypmaxExpressionColon(IEEE1800_2017Parser.ConstantMintypmaxExpressionColonContext ctx) {
        if (!moduleHeader) return;
        System.out.println("enterConstantMintypmaxExpressionColon " + ctx.getText());
    }
	@Override public void exitConstantMintypmaxExpressionColon(IEEE1800_2017Parser.ConstantMintypmaxExpressionColonContext ctx) {
        if (!moduleHeader) return;
        System.out.println("exitConstantMintypmaxExpressionColon");
    }
// constant_expression
	@Override public void enterConstantExpressionPrimary(IEEE1800_2017Parser.ConstantExpressionPrimaryContext ctx) {
        if (!moduleHeader) return;
        System.out.println("enterConstantExpressionPrimary " + ctx.getText());
    }
	@Override public void exitConstantExpressionPrimary(IEEE1800_2017Parser.ConstantExpressionPrimaryContext ctx) {
        if (!moduleHeader) return;
        System.out.println("exitConstantExpressionPrimary");
    }
	@Override public void enterConstantExpressionUnary(IEEE1800_2017Parser.ConstantExpressionUnaryContext ctx) {
        if (!moduleHeader) return;
        System.out.println("enterConstantExpressionUnary " + ctx.getText());
    }
	@Override public void exitConstantExpressionUnary(IEEE1800_2017Parser.ConstantExpressionUnaryContext ctx) {
        if (!moduleHeader) return;
        System.out.println("exitConstantExpressionUnary");
    }
	@Override public void enterConstantExpressionBinary(IEEE1800_2017Parser.ConstantExpressionBinaryContext ctx) {
        if (!moduleHeader) return;
        System.out.println("enterConstantExpressionBinary " + ctx.getText());
    }
	@Override public void exitConstantExpressionBinary(IEEE1800_2017Parser.ConstantExpressionBinaryContext ctx) {
        if (!moduleHeader) return;
        System.out.println("exitConstantExpressionBinary");
    }
	@Override public void enterConstantExpressionConditional(IEEE1800_2017Parser.ConstantExpressionConditionalContext ctx) {
        if (!moduleHeader) return;
        System.out.println("enterConstantExpressionConditional " + ctx.getText());
    }
	@Override public void exitConstantExpressionConditional(IEEE1800_2017Parser.ConstantExpressionConditionalContext ctx) {
        if (!moduleHeader) return;
        System.out.println("exitConstantExpressionConditional");
    }

// constant_primary
	@Override public void enterConstantPrimaryLiteral(IEEE1800_2017Parser.ConstantPrimaryLiteralContext ctx) {
        if (!moduleHeader) return;
        System.out.println("enterConstantPrimaryLiteral " + ctx.getText());
    }
	@Override public void exitConstantPrimaryLiteral(IEEE1800_2017Parser.ConstantPrimaryLiteralContext ctx) {
        if (!moduleHeader) return;
        System.out.println("exitConstantPrimaryLiteral");
    }
	@Override public void enterConstantPrimaryParameter(IEEE1800_2017Parser.ConstantPrimaryParameterContext ctx) {
        if (!moduleHeader) return;
        System.out.println("enterConstantPrimaryParameter " + ctx.getText());
    }
	@Override public void exitConstantPrimaryParameter(IEEE1800_2017Parser.ConstantPrimaryParameterContext ctx) {
        if (!moduleHeader) return;
        System.out.println("exitConstantPrimaryParameter");
    }
    // ...

// primary_literal
	@Override public void enterPrimaryLiteralNumber(IEEE1800_2017Parser.PrimaryLiteralNumberContext ctx) {
        if (!moduleHeader) return;
        System.out.println("enterPrimaryLiteralNumber " + ctx.getText());
    }
	@Override public void exitPrimaryLiteralNumber(IEEE1800_2017Parser.PrimaryLiteralNumberContext ctx) {
        if (!moduleHeader) return;
        System.out.println("exitPrimaryLiteralNumber");
    }
	@Override public void enterPrimaryLiteralTime(IEEE1800_2017Parser.PrimaryLiteralTimeContext ctx) {
        if (!moduleHeader) return;
        System.out.println("enterPrimaryLiteralTime " + ctx.getText());
    }
	@Override public void exitPrimaryLiteralTime(IEEE1800_2017Parser.PrimaryLiteralTimeContext ctx) {
        if (!moduleHeader) return;
        System.out.println("exitPrimaryLiteralTime");
    }
	@Override public void enterPrimaryLiteralUnbased(IEEE1800_2017Parser.PrimaryLiteralUnbasedContext ctx) {
        if (!moduleHeader) return;
        System.out.println("enterPrimaryLiteralUnbased " + ctx.getText());
    }
	@Override public void exitPrimaryLiteralUnbased(IEEE1800_2017Parser.PrimaryLiteralUnbasedContext ctx) {
        if (!moduleHeader) return;
        System.out.println("exitPrimaryLiteralUnbased");
    }
	@Override public void enterPrimaryLiteralString(IEEE1800_2017Parser.PrimaryLiteralStringContext ctx) {
        if (!moduleHeader) return;
        System.out.println("enterPrimaryLiteralString " + ctx.getText());
    }
	@Override public void exitPrimaryLiteralString(IEEE1800_2017Parser.PrimaryLiteralStringContext ctx) {
        if (!moduleHeader) return;
        System.out.println("exitPrimaryLiteralString");
    }


    // Module end, so output everything
	@Override public void enterEndModuleKeyword(IEEE1800_2017Parser.EndModuleKeywordContext ctx) {
        if (modules.size() > 0) {
            for (SVModule mod : modules) {
                if (mod.getIdentifier().equals(moduleString)) {
                    mod.addParameters(parameters);
                }
            }
        }
        // Clean-up
        moduleString = "";
        firstModule = true;
        moduleHeader = false;
    }
}
