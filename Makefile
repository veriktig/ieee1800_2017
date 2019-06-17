# Copyright 2019 Fred Gotwald.  All rights reserved.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

all:: ieee1800_2017

ieee1800_2017:
	cd src; $(MAKE)

clean::
	cd src; $(MAKE) clean

clobber:: clean
	cd src; $(MAKE) clobber
	cd bin; $(RM) -r *
	cd bin; touch .gitignore
