## Packages

    package MyPac {
        fn quit {
            parent::quit();
        }
    }

Translates into:

    package MyPac{function quit(){parent::quit();}};

Prefix the package with `active` to automatically append `activatePackage(MyPac);`

## Classes

    class Foo {
        author = "RoboCop";

        constructor(n) {
            this.n = n;
        }

        fn inc {
            this.n++;
        }
    }

    x = Foo::create();
    x.inc();

Translates into:

    new ScriptObject(Foo){author=" RoboCop";};
    function Foo::create(%n){
        %this = new ScriptObject(){class="Foo";};
        %this.n = %n;
        return %this;
    }
    function Foo::inc(%this){%this.n++;}
    %x = Foo::create();
    %x.inc();

## Image states

    data ShapeBaseImageData MyImage {
        state Activate {
            sound = EquipWeaponSound;
            timeoutValue = 0.25;
            transitionOnTimeout = "Ready";
        }
        state Ready {
            ...
        }
        ...
    }

...

## Overloaded "array" access

Instead of being equivalent to `xy`, `x[y]` translates to `x.__getItem(y)`. See below if array access is needed.

## Fenced TorqueScript code

    for i in 0..mg.numMembers {
        `%mb = %mg.member[%i];`
        mb.delete();
    }

## Sugar for collection types

    a = ["x", 6, foo];
    echo(a[1]);
    for v in a.iter() { echo(v); }

Translates into:

    %a = new ScriptObject() {
        class = "Vec"; // should be namespaced more
        length = 3;
        value0 = "x";
        value1 = 6;
        value2 = %foo;
    };
    echo(%a.__getItem(1));
    // ...
