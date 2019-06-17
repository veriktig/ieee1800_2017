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

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

public class SVModule {
    private String identifier;
    private List<SVParameter> parameters = new ArrayList<SVParameter>();
    private List<SVPort> ports = new ArrayList<SVPort>();
    // lifetime
    // imports
    // typedefs
    // tasks
    // functions
    // data_objects
    // instantiations
    // behavorial
    // generates

    public SVModule(String identifier) {
        this.identifier = identifier;
    }

    public void addPorts(List<SVPort> ports) {
        this.ports.addAll(ports);
    }

    public void addParameters(List<SVParameter> parameters) {
        this.parameters.addAll(parameters);
    }

    public String getIdentifier() {
        return identifier;
    }

    public void prettyPrint() {
        ports.sort((SVPort p1, SVPort p2) -> p1.toString().compareTo(p2.toString()));

        // Dump the ports
        System.out.println(" module " + identifier + " (");
        Iterator<SVPort> iter = ports.iterator();
        if (ports.size() > 0) {
            SVPort port = iter.next();
            System.out.print("    " + port.toString());
            while (iter.hasNext()) {
                System.out.println(",");
                System.out.print("    " + iter.next().toString());
            }
        }
        System.out.println("\n);");
    }

}
