# linter-javac

This package will lint your `.java` opened files in Atom through [javac](http://docs.oracle.com/javase/7/docs/technotes/tools/windows/javac.html).

## Installation

### Install Java
* Install [java](http://www.java.com/).

### Install Linter
    $ apm install linter #(if you don't have [AtomLinter/Linter](https://github.com/AtomLinter/Linter) installed).
 
### Install Linter Javac (apm)

    $ apm install linter-javac

### Install Linter Javac (git)
    $ cd ~/.atom/packages
    $ git clone <this repository>
    $ npm install
    
## Settings
You can configure linter-javac by editing ~/.atom/config.cson (choose Open Your Config in Atom menu):

    'linter-javac':
      'javaExecutablePath': null # java path. run 'which javac' to find the path

## Other available linters
There are other linters available - take a look at the linters [mainpage](https://github.com/AtomLinter/Linter).

## Shell Script Example
Below is an example script for project based java linting.

    #!/bin/bash

    DIR="$( cd "$( dirname "$0" )" && pwd )"

    cd $DIR

    mkdir -p .linter-javac/build

    javac -cp war/WEB-INF/lib/'*'\
    :~/Documents/workspace/tools/appengine-java-sdk-1.9.5/lib/shared/servlet-api.jar\
    :~/Documents/workspace/tools/appengine-java-sdk-1.9.5/lib/appengine-tools-api.jar\
    :~/Documents/workspace/tools/appengine-java-sdk-1.9.5/lib/impl/appengine-api-labs.jar\
    :~/Documents/workspace/tools/appengine-java-sdk-1.9.5/lib/impl/appengine-api-stubs.jar\
    :~/Documents/workspace/tools/appengine-java-sdk-1.9.5/lib/impl/appengine-api.jar\
    :~/Documents/workspace/tools/appengine-java-sdk-1.9.5/lib/testing/appengine-testing.jar\
     -sourcepath src/java\
     -d .linter-javac/build\
     -Xlint\
     $1
