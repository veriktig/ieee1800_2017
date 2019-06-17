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

package examples;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.List;
import java.util.regex.Pattern;
import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.misc.Utils;
import org.antlr.v4.runtime.tree.ParseTree;
import org.antlr.v4.runtime.tree.ParseTreeWalker;
import org.antlr.v4.runtime.tree.Tree;
import org.antlr.v4.runtime.tree.Trees;

import com.veriktig.scandium.ieee1800_2017.IEEE1800_2017TextMacros;

import examples.extractors.IEEE1800_2017ModuleExtractor;
import examples.extractors.IEEE1800_2017ParameterExtractor;
import examples.extractors.IEEE1800_2017PortExtractor;
import examples.linter.Linter;
import examples.object_model.SVModule;
import examples.parse_tree.SVParseTree;
import examples.preprocessor.Preprocessor;

public class Example {
    private static int level = 0;
	private static final String Eol = System.lineSeparator();
    private static boolean leavesOnly = false;

    public static void main(String args[]) {
        IEEE1800_2017TextMacros macros = new IEEE1800_2017TextMacros();
        boolean createPreprocessedFile = false;
        boolean reportSymbols = true;
        boolean printParseTree = false;
        boolean lint = true;
        boolean printModules = true;

        for (String filename : args) {
            Path path = Paths.get(filename).toAbsolutePath();
            if (!Files.exists(path)) {
                System.err.println("ERROR: " + filename + " not found.\n");
                System.exit(-1);
            }
            System.out.println(path.toString());
            Preprocessor pp = new Preprocessor(macros, reportSymbols, createPreprocessedFile);
            CharStream cs = pp.createStream(filename);
            if (cs == null) {
            }
            SVParseTree st = new SVParseTree(cs);
            ParseTree svtree = st.createTree();

            // Output pretty tree
            if (printParseTree) {
                List<String> ruleNamesList = Arrays.asList(st.svparser.getRuleNames());
                String strTree = convertToStringTree(svtree, ruleNamesList);
                System.out.println(strTree);
            }

            if (lint) {
                Linter svlinter = new Linter(st.ts);
                svlinter.ansiWarning = true;
                svlinter.genericInterfaceWarning = true;
                svlinter.implicitMethod = true;
                svlinter.implicitWarnings = true;
                svlinter.importWarning = true;
                svlinter.netTypeWarning = true;
                svlinter.newParendsWarning = true;
                svlinter.nonStandardTFWarning = true;
                svlinter.nullArgument = true;
                svlinter.noPortDirectionWarning = true;
                ParseTreeWalker.DEFAULT.walk(svlinter, svtree);
            }


            if (printModules) {
                IEEE1800_2017ModuleExtractor me = new IEEE1800_2017ModuleExtractor();
                ParseTreeWalker.DEFAULT.walk(me, svtree);
                List<SVModule> modules = me.getModules();
                IEEE1800_2017PortExtractor pe = new IEEE1800_2017PortExtractor(modules);
                ParseTreeWalker.DEFAULT.walk(pe, svtree);
                IEEE1800_2017ParameterExtractor pme = new IEEE1800_2017ParameterExtractor(modules);
                ParseTreeWalker.DEFAULT.walk(pme, svtree);
                for (SVModule module : modules) {
                    module.prettyPrint();
                }
            }
        }
    }

	private static String convertToStringTree(ParseTree tree, List<String> ruleNamesList) {
        String completeString = toPrettyTree(tree, ruleNamesList);
        String findString = new String("^.* " + Eol);
        String replaceString = new String("");
        if (leavesOnly) {
            completeString = Pattern.compile(findString, Pattern.MULTILINE).matcher(completeString).replaceAll(replaceString);
        }
        findString = new String("^.*bit_select null_bit_select\n");
        completeString = Pattern.compile(findString, Pattern.MULTILINE).matcher(completeString).replaceAll(replaceString);
        findString = new String("^.*constant_bit_select null_constant_bit_select\n");
        completeString = Pattern.compile(findString, Pattern.MULTILINE).matcher(completeString).replaceAll(replaceString);
		return completeString;
	}

	private static String toPrettyTree(final Tree t, final List<String> ruleNames) {
		level = 0;
		return process(t, ruleNames).replaceAll("(?m)^\\s+$", "").replaceAll("\\r?\\n\\r?\\n", Eol);
	}

	private static String process(final Tree t, final List<String> ruleNames) {
		if (t.getChildCount() == 0) return Utils.escapeWhitespace(Trees.getNodeText(t, ruleNames), false);
		StringBuilder sb = new StringBuilder();
		sb.append(lead(level));
		level++;
		String s = Utils.escapeWhitespace(Trees.getNodeText(t, ruleNames), false);
		sb.append(level);
		sb.append(": ");
		sb.append(s);
		sb.append(' ');
		for (int i = 0; i < t.getChildCount(); i++) {
			sb.append(process(t.getChild(i), ruleNames));
		}
		level--;
		sb.append(lead(level));
		return sb.toString();
	}

	private static String lead(int level) {
		StringBuilder sb = new StringBuilder();
		if (level > 0) {
			sb.append(Eol);
			for (int cnt = 0; cnt < level; cnt++) {
				sb.append(getIndents());
			}
		}
		return sb.toString();
	}

	private static String getIndents() {
        return new String(" ");
    }
}
