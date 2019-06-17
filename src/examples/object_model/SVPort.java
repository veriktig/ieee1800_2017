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

package examples.object_model;

public class SVPort {
    private PortDirection direction;
    private String type;
    private String identifier;

    public enum PortDirection {
        IN("input"),
        INOUT("inout"),
        OUT("output"),
        INTERFACE("");

        String name;
        PortDirection(String name) { this.name = name; }
        public String toString() { return name; }
    };

    public SVPort(PortDirection direction, String type, String identifier) {
        this.direction = direction;
        this.type = type;
        this.identifier = identifier;
    }
    public SVPort(String ifname, String modport, String identifier) {
        this.direction = PortDirection.INTERFACE;
        if (!modport.equals("")) {
            this.type = new String(ifname + "." + modport);
        } else {
            this.type = new String(ifname);
        }
        this.identifier = identifier;
    }
    public String toString() {
        if (direction == PortDirection.INTERFACE) {
            return new String(type + " " + identifier);
        } else {
            return new String(direction.toString() + " " + type + " " + identifier);
        }
    }
}
