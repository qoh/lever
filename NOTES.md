## Packages

    package MyPac {
        fn quit() {
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
