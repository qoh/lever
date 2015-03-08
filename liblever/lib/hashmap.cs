// For converted constructors
// ============
function ____newhashmap() {
    return new ScriptObject() {
        class = "HashMap";
    };
}
function HashMap::____newpair(%this, %key, %value) {
    %this.keys.push(%key);
    %this.value[sha1(%key)] = %value;
    return %this; // important
}
// ============

function HashMap::onAdd(%this) {
    %this.keys = new ScriptObject() {
        class = "Vec";
        length = 0;
    };
}

function HashMap::onRemove(%this) {
    %this.keys.delete();
}

function HashMap::_get_array(%this, %key) {
    return %this.value[sha1(%key)];
}

function HashMap::_set_array(%this, %key, %value) {
    for (%i = 0; %i < %this.keys.length; %i++) {
        if (strcmp(%key, %this.keys.value[%i]) == 0) {
            %found = 1;
            break;
        }
    }

    if (!%found) {
        %this.keys.push(%key);
    }

    %this.value[sha1(%key)] = %value;
}

function HashMap::copy(%this) {
    %copy = new ScriptObject() {
        class = "HashMap";
    };

    for (%i = 0; %i < %this.keys.length; %i++) {
        %key = %this.keys.value[%i];
        %copy._set_array(%key, %this.value[sha1(%key)]);
    }

    return %copy;
}

function HashMap::clear(%this) {
    for (%i = 0; %i < %this.keys.length; %i++) {
        %this.value[sha1(%this.keys.value[%i])] = "";
    }

    %this.keys.clear();
}

function HashMap::get(%this, %key, %default) {
    for (%i = 0; %i < %this.keys.length; %i++) {
        if (strcmp(%key, %this.keys.value[%i]) == 0) {
            return %this.value[sha1(%key)];
        }
    }

    return %default;
}

function HashMap::remove(%this, %key) {
    for (%i = 0; %i < %this.keys.length; %i++) {
        if (strcmp(%key, %this.keys.value[%i]) == 0) {
            %this.value[sha1(%key)] = "";
            %this.keys.remove_swap(%i);
            return 1;
        }
    }

    return 0;
}

function HashMap::exists(%this, %key) {
    for (%i = 0; %i < %this.keys.length; %i++) {
        if (strcmp(%key, %this.keys.value[%i]) == 0) {
            return 1;
        }
    }

    return 0;
}

function HashMap::patch(%this, %map) {
    for (%i = 0; %i < %map.keys.length; %i++) {
        %key = %map.keys.value[%i];
        %this.set(%key, %map.value[sha1(%key)]);
    }
}

function HashMap::patch_into(%this, %map) {
    for (%i = 0; %i < %map.keys.length; %i++) {
        %key = %map.keys.value[%i];

        if (!%this.exists(%key)) {
            %hash = sha1(%key);
            %this.keys.push(%key);
            %this.value[%hash] = %map.value[%hash];
        }
    }
}

function HashMap::pairs(%this) {
    //
}

function HashMap::keys(%this) {
    return %this.keys.iter();
}

function HashMap::values(%this) {
    //
}
