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
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Queue;

import com.veriktig.scandium.ieee1800_2017.grammar.IEEE1800_2017Parser;
import com.veriktig.scandium.ieee1800_2017.grammar.IEEE1800_2017ParserBaseListener;

import examples.object_model.SVModule;
import examples.object_model.SVPort;

public class IEEE1800_2017PortExtractor extends IEEE1800_2017ParserBaseListener {
    // Module
    private String moduleString;
    // Headers
    private boolean moduleHeader;
    // Ports
    private boolean AnsiPort;
    private boolean NonAnsiPort;
    private boolean NonAnsiModule;
    private boolean portActive;
    private boolean directionPresent;
    private boolean typePresent;
    private boolean firstModule = true;
    private boolean ifType;
    private SVPort.PortDirection direction;
    private Queue<String> data_type = new LinkedList<String>();
    private List<SVModule> modules;
    private List<SVPort> ports = new ArrayList<SVPort>();

    public IEEE1800_2017PortExtractor(List<SVModule> modules) {
        this.modules = modules;
    }

    // ANSI port direction
	@Override public void enterPortDirectionIn(IEEE1800_2017Parser.PortDirectionInContext ctx) {
        if (AnsiPort || NonAnsiModule) {
            direction = SVPort.PortDirection.IN;
            directionPresent = true;
        }
    }
	@Override public void enterPortDirectionOut(IEEE1800_2017Parser.PortDirectionOutContext ctx) {
        if (AnsiPort || NonAnsiModule) {
            direction = SVPort.PortDirection.OUT;
            directionPresent = true;
        }
    }
	@Override public void enterPortDirectionInout(IEEE1800_2017Parser.PortDirectionInoutContext ctx) {
        if (AnsiPort || NonAnsiModule) {
            direction = SVPort.PortDirection.INOUT;
            directionPresent = true;
        }
    }
    // Non-ANSI port direction
	@Override public void enterInputDeclaration(IEEE1800_2017Parser.InputDeclarationContext ctx) {
        if (NonAnsiPort || NonAnsiModule) {
            direction = SVPort.PortDirection.IN;
            directionPresent = true;
        }
    }
	@Override public void enterOutputDeclaration(IEEE1800_2017Parser.OutputDeclarationContext ctx) {
        if (NonAnsiPort || NonAnsiModule) {
            direction = SVPort.PortDirection.OUT;
            directionPresent = true;
        }
    }
	@Override public void enterInoutDeclaration(IEEE1800_2017Parser.InoutDeclarationContext ctx) {
        if (NonAnsiPort || NonAnsiModule) {
            direction = SVPort.PortDirection.INOUT;
            directionPresent = true;
        }
    }
    // Type
	@Override public void enterDataTypeTypeId(IEEE1800_2017Parser.DataTypeTypeIdContext ctx) {
        if (AnsiPort || NonAnsiPort || NonAnsiModule) {
            data_type.add(ctx.getText());
            typePresent = true;
        }
    }
	@Override public void enterIntegerVectorTypeBit(IEEE1800_2017Parser.IntegerVectorTypeBitContext ctx) {
        if (AnsiPort || NonAnsiPort || NonAnsiModule) {
            // XXX Replace with logic?
            data_type.add(ctx.getText());
            typePresent = true;
        }
    }
	@Override public void enterIntegerVectorTypeLogic(IEEE1800_2017Parser.IntegerVectorTypeLogicContext ctx) {
        if (AnsiPort || NonAnsiPort || NonAnsiModule) {
            data_type.add(ctx.getText());
            typePresent = true;
        }
    }
	@Override public void enterIntegerVectorTypeReg(IEEE1800_2017Parser.IntegerVectorTypeRegContext ctx) {
        if (AnsiPort || NonAnsiPort || NonAnsiModule) {
            // Replace with logic
            data_type.add("logic");
            typePresent = true;
        }
    }
	@Override public void enterNetTypeWire(IEEE1800_2017Parser.NetTypeWireContext ctx) {
        if (AnsiPort || NonAnsiPort || NonAnsiModule) {
            // Replace with logic???
            data_type.add("net");
            typePresent = true;
        }
    }
    // Range
	@Override public void enterPackedDimensionRange(IEEE1800_2017Parser.PackedDimensionRangeContext ctx) {
        if (NonAnsiPort || AnsiPort || NonAnsiModule) {
            data_type.add(ctx.getText());
        }
    }
    // Identifier
	@Override public void enterInterfaceIdentifier(IEEE1800_2017Parser.InterfaceIdentifierContext ctx) {
        if (AnsiPort) {
            data_type.add(ctx.getText());
            directionPresent = true;
            portActive = true;
            ifType = true;
        }
    }
	@Override public void enterModportIdentifier(IEEE1800_2017Parser.ModportIdentifierContext ctx) {
        if (AnsiPort) {
            if (ctx.getText() == null) {
                data_type.add(new String(""));
            } else {
                data_type.add(ctx.getText());
            }
        }
    }
	@Override public void enterPortIdentifier(IEEE1800_2017Parser.PortIdentifierContext ctx) {
        if (AnsiPort) {
            String ident = ctx.getText();
            SVPort port;
            if (ifType) {
                port = new SVPort(data_type.remove(), data_type.remove(), ident);
            } else {
                StringBuilder str = new StringBuilder();
                buildType(str);
                port = new SVPort(direction, str.toString(), ident);
            }
            // Add to ports
            ports.add(port);
        }
    }
	@Override public void exitPortIdentifier(IEEE1800_2017Parser.PortIdentifierContext ctx) {
        data_type.clear();
        portActive = false;
        directionPresent = false;
        typePresent = false;
        ifType = false;
    }
	@Override public void enterListOfPortIdentifiers(IEEE1800_2017Parser.ListOfPortIdentifiersContext ctx) {
        if (NonAnsiPort || NonAnsiModule) {
            // Split on commas, use stashed values
            String[] idents = ctx.getText().split(",");
            for (String ss : idents) {
                StringBuilder str = new StringBuilder();
                buildType(str);
                // Add to ports
                SVPort port = new SVPort(direction, str.toString(), ss);
                ports.add(port);
            }
        }
    }
    private void buildType(StringBuilder str) {
        if (data_type.size() > 0) {
            if (!typePresent) {
                str.append("logic ");
            }
            Iterator<String> iter = data_type.iterator();
            String ss = iter.next();
            str.append(ss);
            while (iter.hasNext()) {
                str.append(" ");
                str.append(iter.next());
            }
        } else {
            if (!typePresent) {
                str.append("logic");
            }
        }
    }
	@Override public void exitListOfPortIdentifiers(IEEE1800_2017Parser.ListOfPortIdentifiersContext ctx) {
        data_type.clear();
        portActive = false;
        directionPresent = false;
        typePresent = false;
        ifType = false;
    }
    // ANSI ports
	@Override public void enterListOfPortDeclarationsAnsi(IEEE1800_2017Parser.ListOfPortDeclarationsAnsiContext ctx) {
        AnsiPort = true;
        portActive = true;
    }
	@Override public void exitListOfPortDeclarationsAnsi(IEEE1800_2017Parser.ListOfPortDeclarationsAnsiContext ctx) {
        data_type.clear();
        AnsiPort = false;
        portActive = false;
        directionPresent = false;
        typePresent = false;
        ifType = false;
    }
    // Non-ANSI ports
	@Override public void enterListOfPortDeclarationsNonansi(IEEE1800_2017Parser.ListOfPortDeclarationsNonansiContext ctx) {
        NonAnsiPort = true;
        portActive = true;
    }
	@Override public void exitListOfPortDeclarationsNonansi(IEEE1800_2017Parser.ListOfPortDeclarationsNonansiContext ctx) {
        data_type.clear();
        NonAnsiPort = false;
        portActive = false;
        directionPresent = false;
        typePresent = false;
        ifType = false;
    }
	@Override public void enterModuleItemPortDecl(IEEE1800_2017Parser.ModuleItemPortDeclContext ctx) {
        NonAnsiModule = true;
        portActive = true;
    }
	@Override public void exitModuleItemPortDecl(IEEE1800_2017Parser.ModuleItemPortDeclContext ctx) {
        data_type.clear();
        NonAnsiModule = false;
        portActive = false;
        directionPresent = false;
        typePresent = false;
        ifType = false;
    }

    // Module
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

	@Override public void enterEndModuleKeyword(IEEE1800_2017Parser.EndModuleKeywordContext ctx) {
        ports.sort((SVPort p1, SVPort p2) -> p1.toString().compareTo(p2.toString()));
        if (modules.size() > 0) {
            for (SVModule mod : modules) {
                if (mod.getIdentifier().equals(moduleString)) {
                    mod.addPorts(ports);
                }
            }
        }

        // Clean-up
        data_type.clear();
        ports.clear();
        moduleString = "";
        AnsiPort = false;
        NonAnsiPort = false;
        NonAnsiModule = false;
        portActive = false;
        directionPresent = false;
        typePresent = false;
        ifType = false;
        firstModule = true;
        moduleHeader = false;
    }
}
