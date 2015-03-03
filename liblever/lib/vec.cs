function Vec::_get_array(%this, %index) {
    return %this.value[%index];
}

function Vec::_set_array(%this, %index, %value) {
    // Also check if index is integer
    if (%index >= 0 && %index < %this.length) {
        %this.value[%index] = %value;
    }
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

function Vec::pop(%this) {
    if (%this.length < 1) {
        return "";
    }

    %value = %this.value[%this.length--];
    %this.value[%this.length] = "";
    return %value;
}

// insert(index, value) in O(n)
// remove(index) -> value in O(n)
// insert_swap(index, value) in O(1)
// remove_swap(index) -> value in O(1)

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
    $iter_index[%id] = "";
    $iter_vec[%id] = "";
}

function Vec::iter(%this) {
    %id = iter_new("vec_iter_next", "vec_iter_drop");
    $iter_index[%id] = 0;
    $iter_vec[%id] = %this;
    return %id;
}
