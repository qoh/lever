function Vec() {
    return new ScriptObject() {
        class = "Vec";
        length = 0;
    };
}

function Vec::_add_item(%this, %value) {
    %this.value[%this.length] = %value;
    %this.length++;
    return %this;
}

function Vec::_get_array(%this, %index) {
    return %this.value[%index];
}

function Vec::_set_array(%this, %index, %value) {
    // Also check if index is integer
    if (%index >= 0 && %index < %this.length) {
        %this.value[%index] = %value;
    }
}

function Vec::delete_owned(%this) {
    for (%i = 0; %i < %this.length; %i++) {
        if (isObject(%this.value[%i])) {
            %this.value[%i].delete();
        }
    }

    %this.delete();
}

function Vec::copy(%this) {
    %copy = new ScriptObject() {
        class = "Vec";
        length = %this.length;
    };

    for (%i = 0; %i < %this.length; %i++) {
        %copy.value[%i] = %this.value[%i];
    }

    return %copy;
}

function Vec::clear(%this) {
    for (%i = 0; %i < %this.length; %i++) {
        %this.value[%i] = "";
    }

    %this.length = 0;
}

function Vec::push(%this, %value) {
    %this.value[%this.length] = %value;
    %this.length++;
}

function Vec::push_all(%this, %iter) {
    while (iter_next(%iter)) {
        %this.push($iter_value[%iter]);
    }

    iter_drop(%iter);
}

function Vec::pop(%this) {
    if (%this.length < 1) {
        return "";
    }

    %value = %this.value[%this.length--];
    %this.value[%this.length] = "";
    return %value;
}

function Vec::insert(%this, %index, %value) {
    if (%index !$= mFloor(%index) || %index < 0 || %index > %this.length) {
        error("ERROR: Not a valid index");
        return "";
    }

    for (%i = %this.length; %i > %index; %i--) {
        %this.value[%i] = %this.value[%i - 1];
    }

    %this.value[%index] = %value;
    %this.length++;
}

function Vec::remove(%this, %index) {
    if (%index !$= mFloor(%index) || %index < 0 || %index >= %this.length) {
        error("ERROR: Not a valid index");
        return "";
    }

    %value = %this.value[%index];
    %this.length--;

    for (%i = %index; %i < %this.length; %i++) {
        %this.value[%i] = %this.value[%i + 1];
    }

    %this.value[%this.length] = "";
    return %value;
}

function Vec::insert_swap(%this, %index, %value) {
    if (%index !$= mFloor(%index) || %index < 0 || %index > %this.length) {
        error("ERROR: Not a valid index");
        return "";
    }

    %this.push(%value);
    %this.swap(%this.length - 1, %index);
}

function Vec::remove_swap(%this, %index) {
    if (%index !$= mFloor(%index) || %index < 0 || %index >= %this.length) {
        error("ERROR: Not a valid index");
        return "";
    }

    %value = %this.value[%index];

    %this.value[%index] = %this.value[%this.length--];
    %this.value[%this.length] = "";

    return %value;
}

function Vec::swap(%this, %i, %j) {
    %t = %this.value[%i];

    %this.value[%i] = %this.value[%j];
    %this.value[%j] = %t;
}

function Vec::join(%this, %sep) {
    for (%i = 0; %i < %this.length; %i++) {
        %str = %str @ (%i > 0 ? %sep : "") @ %this.value[%i];
    }

    return %str;
}

function Vec::is_empty(%this) {
    return %this.length < 1;
}

function Vec::reverse(%this) {
    %max = (%this.length - 2) >> 1;

    for (%i = 0; %i < %max; %i++) {
        %this.swap(%i, %this.length - 1 - %i);
    }
}

function Vec::shuffle(%this) {
    for (%i = 0; %i < %this.length; %i++) {
        %this.swap(getRandom(%i, %this.length - 1), %i);
    }
}

function Vec::map(%this, %func) {
    for (%i = 0; %i < %this.length; %i++) {
        %this.value[%i] = call(%func, %this.value[%i]);
    }
}

function Vec::apply(%this, %func) {
    for (%i = 0; %i < %this.length; %i++) {
        call(%func, %this.value[%i]);
    }
}

function Vec::fold(%this, %init, %func) {
    for (%i = 0; %i < %this.length; %i++) {
        %init = call(%func, %init, %this.value[%i]);
    }

    return %init;
}

// Vec::filter(func)

function vec_iter_next(%id) {
    if ($iter_index[%id] < $iter_vec[%id].length) {
        $iter_value[%id] = $iter_vec[%id].value[$iter_index[%id]];
        $iter_index[%id]++;
        return 1;
    }

    return 0;
}

function vec_iter_drop(%id) {
    if ($iter_own[%id] && isObject($iter_vec[%id])) {
        $iter_vec[%id].delete();
    }

    $iter_index[%id] = "";
    $iter_own[%id] = "";
    $iter_vec[%id] = "";
}

function Vec::iter(%this) {
    %id = iter_new("vec_iter_next", "vec_iter_drop");
    $iter_index[%id] = 0;
    $iter_vec[%id] = %this;
    $iter_own[%id] = 0;
    return %id;
}

function Vec::into_iter(%this) {
    %id = iter_new("vec_iter_next", "vec_iter_drop");
    $iter_index[%id] = 0;
    $iter_vec[%id] = %this;
    $iter_own[%id] = 1;
    return %id;
}
