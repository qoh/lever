package ClassHelperPackage {
    function ScriptObject::dump(%this) {
        if (%this.class $= "Class") {
            %current = %this;

            while (%current !$= "") {
                if (%tree !$= "") {
                    %tree = %tree @ " <- ";
                }

                %tree = %tree @ %current;
                %current = %current.parent;
            }

            if (%tree !$= "") {
                echo("Class: " @ %tree);
            }

            echo("Methods:");

            for (%i = 0; %i < %this.methodCount; %i++) {
                %name = %this.methodName[%i];
                %line = "";

                if (%this.isInherited[%name]) {
                    %line = " - inherited from " @ %this.parent;
                } else if (%this.parent.isMethod[%name]) {
                    %line = " - overwritten version";
                }

                echo("  " @ %name @ "(" @ %this.methodArgs[%name] @ ")" @ %line);
            }
        } else if (%this.superClass $= "Class") {
            %this.class.dump();
        } else {
            Parent::dump(%this);
        }
    }
};

activatePackage("ClassHelperPackage");
