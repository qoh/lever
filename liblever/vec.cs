function Vec::__getItem(%this, %index) {
    return %this.value[%index];
}

function Vec::__getItem(%this, %index, %value) {
    // Also check if index is integer
    if (%index >= 0 && %index < %this.length) {
        %this.value[%index] = %value;
    }
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
