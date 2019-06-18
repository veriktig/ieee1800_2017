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

package com.veriktig.scandium.ieee1800_2017;

import java.io.Serializable;
import java.util.LinkedList;
import java.util.Queue;

public class IEEE1800_2017TextMacroDefinition implements Serializable {
    private static final long serialVersionUID = 1L;

    // Inner class for arguments
    public class Argument implements Serializable {
        private static final long serialVersionUID = 1L;
        private String identifier;
        private String default_text;

        public Argument(String identifier) {
            this.identifier = new String(identifier);
        }
        public String getName() {
            return identifier;
        }
        public void setDefault(String inbound) {
            this.default_text = new String(inbound);
        }
        public String getDefault() {
            return default_text;
        }
        public boolean hasDefault() {
            return (default_text == null) ? false : true;
        }
    }

    private String name;
    private Queue<Argument> arguments = new LinkedList<Argument>();
    private String macro_text;

    public IEEE1800_2017TextMacroDefinition(String name) {
        this.name = new String(name);
    }
    public String getName() {
        return name;
    }
    public void addArgument(Argument arg) {
        arguments.add(arg);
    }
    public Queue<Argument> getArguments() {
        Queue<Argument> temp = new LinkedList<Argument>(arguments);
        return temp;
    }
    public boolean hasArguments() {
        return (arguments.size() == 0) ? false : true;
    }
    public void setText(String inbound) {
        this.macro_text = new String(inbound);
    }
    public String getText() {
        return macro_text;
    }
    public boolean hasText() {
        return (macro_text == null) ? false : true;
    }
}
