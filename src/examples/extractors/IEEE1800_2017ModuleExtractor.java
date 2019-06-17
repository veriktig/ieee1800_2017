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

public class IEEE1800_2017ModuleExtractor extends IEEE1800_2017ParserBaseListener {
    // Module
    private SVModule module;
    private List<SVModule> modules = new ArrayList<SVModule>();
    private boolean firstModule;

	@Override public void enterModuleDeclarationNonansi(IEEE1800_2017Parser.ModuleDeclarationNonansiContext ctx) {
        firstModule = true;
    }
	@Override public void enterModuleDeclarationAnsi(IEEE1800_2017Parser.ModuleDeclarationAnsiContext ctx) {
        firstModule = true;
    }
	
	@Override public void enterModuleIdentifier(IEEE1800_2017Parser.ModuleIdentifierContext ctx) {
        if (firstModule) {
            String moduleString = ctx.getText();
            module = new SVModule(moduleString);
            firstModule = false;
        }
    }

	@Override public void enterEndModuleKeyword(IEEE1800_2017Parser.EndModuleKeywordContext ctx) {
        modules.add(module);
    }

    public List<SVModule> getModules() {
        return modules;
    }
}
