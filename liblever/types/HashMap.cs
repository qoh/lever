function HashMap() {
    return new ScriptObject() {
        class = "HashMap";
        keyCount = 0;
    };
}

function HashMap::_add_pair(%this ,%key, %value) {
    // Yes, I'm being a terrible person by copying _set_array
    // Go away
    %hash = sha1(%key);

    if (%this.keyIndex[%hash] $= "") {
        %this.keyIndex[%hash] = %this.keyCount;
        %this.keyName[%this.keyCount] = %key;
        %this.keyCount++;
    }

    %this.value[%hash] = %value;
    return %this;
}

function HashMap::_get_array(%this, %key) {
    return %this.value[sha1(%key)];
}

function HashMap::_set_array(%this, %key, %value) {
    %hash = sha1(%key);

    if (%this.keyIndex[%hash] $= "") {
        %this.keyIndex[%hash] = %this.keyCount;
        %this.keyName[%this.keyCount] = %key;
        %this.keyCount++;
    }

    %this.value[%hash] = %value;
    return %value;
}

function HashMap::copy(%this) {
    %copy = new ScriptObject() {
        class = "HashMap";
        keyCount = 0;
    };

    for (%i = 0; %i < %this.keyCount; %i++) {
        %key = %this.keyName[%i];
        %hash = sha1(%key);

        %copy.keyName[%i] = %key;
        %copy.keyIndex[%hash] = %i;
        %copy.value[%hash] = %this.value[%hash];
    }

    return %copy;
}

function HashMap::clear(%this) {
    for (%i = 0; %i < %this.keyCount; %i++) {
        %key = %this.keyName[%i];
        %hash = sha1(%key);

        %this.keyName[%i] = "";
        %this.keyIndex[%hash] = "";
        %this.value[%hash] = "";
    }

    %this.keyCount = 0;
    return %this;
}

function HashMap::exists(%this, %key) {
    return %this.keyIndex[sha1(%key)] !$= "";
}

function HashMap::remove(%this, %key) {
    %hash = sha1(%key);
    %index = %this.keyIndex[%hash];

    if (%index !$= "") {
        %this.value[%hash] = "";

        %this.keyName[%index] = %this.keyName[%this.keyCount--];
        %this.keyIndex[sha1(%this.keyName[%index])] = %index;
        %this.keyName[%this.keyCount] = "";
    }

    return %this;
}

// Write all key/value pairs from %map into %this
function HashMap::patch(%this, %map) {
    for (%i = 0; %i < %map.keyCount; %i++) {
        %key = %map.keyName[%i];
        %this._set_array(%key, %map.value[sha1(%key)]);
    }
}

// Write the key/value pairs from %map into %this with undefined keys here
function HashMap::patch_into(%this, %map) {
    for (%i = 0; %i < %map.keyCount; %i++) {
        %key = %map.keyName[%i];
        %hash = sha1(%key);

        if (%this.keyIndex[%hash] $= "") {
            %this.keyIndex[%hash] = %this.keyCount;
            %this.keyName[%this.keyCount] = %key;
            %this.keyCount++;

            %this.value[%hash] = %value;
        }
    }
}

// Iterate over (key, value) pairs
function HashMap::pairs(%this) {
    //
}

// Iterate over keys of pairs
function HashMap::keys(%this) {
    %id = iter_new("array_iter_next", "array_iter_drop");
    $iter_index[%id] = 0;
    $iter_length[%id] = %this.keyCount;

    for (%i = 0; %i < %this.keyCount; %i++) {
        $iter_value[%id, %i] = %this.keyName[%i];
    }

    return %id;
}

// Iterate over values of pairs
function HashMap::values(%this) {
    %id = iter_new("array_iter_next", "array_iter_drop");
    $iter_index[%id] = 0;
    $iter_length[%id] = %this.keyCount;

    for (%i = 0; %i < %this.keyCount; %i++) {
        $iter_value[%id, %i] = %this.value[sha1(%this.keyName[%i])];
    }

    return %id;
}
