# Lever

Lever is a tool designed to make Blockland development better. It consists of three things:

* The original Lever - a transpiler that generates TorqueScript from a nicer language,
* liblever, a TorqueScript support library enabling the additional features of the Lever syntax, and
* A CLI for leveraging the Lever transpiler, which also integrates some tools to streamline development.

## Getting Set Up

1. Install [NodeJS](https://nodejs.org).
2. Get the code - Clone this repository or use the Download ZIP button above.
3. Install the package:
    Extract the ZIP if necessary, then call `npm install -g` from the lever directory. You will probably need administrative privileges to do this (Right click cmd -> Launch as Administrator, or `sudo`)

### Basic Usage



## Syntax

### Basic Syntax

Local variables do not have `%` prepended to them - they are plain. `client` is the same as `%client` in raw TorqueScript. Lever also uses the same standard operands as TorqueScript - including the Torque-specific string catenation operands `@` `SPC` `TAB` and `NL`.

### Functions

The following are equivalent:

    fn myFunc {
        echo("Hello world!");
    }

    fn myFunc() {
        echo("Hello world!");
    }

Arguments are supplied much as in normal TorqueScript:

    fn myFunc(a, b) {
        echo(a @ " " @ b @ "!");
    }

Lever also supports anonymous functions:

    schedule(1000, 0, fn(a) { echo(a); }, "Hello world!");

### Packages

    package MyPackage {
    
    };

Prepending `active` will activate the package by default:

    active package MyPackage {
    
    };

Parenting is done by simply calling `Parent` regardless of the function:

    active package MyPackage {
        fn myFunc(a, b) {
            Parent("Hello", "world");
        }
    };

## API

Lever can also be required as a Node module.

//TODO: Write usage documentation (and improve API).