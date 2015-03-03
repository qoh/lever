if ($_iter_nextid $= "") {
    $_iter_nextid = -1;
}

if ($_iter_proto $= "") {
    $_iter_proto = new ScriptObject() {
        class = "IteratorProto";
    };
}

function iter_new(%next, %drop) {
    %id = $_iter_proto SPC ($_iter_nextid = ($_iter_nextid + 1) | 0);
    $_iter_next[%id] = %next;
    $_iter_drop[%id] = %drop;
    return %id;
}

function iter_drop(%id) {
    call($_iter_drop[%id], %id);
    $_iter_next[%id] = "";
    $_iter_drop[%id] = "";
    $iter_value[%id] = "";
}

function iter_next(%id) {
    return call($_iter_next[%id], %id);
}

// ======
// IteratorProto methods
function iter_proto_map_next(%id) {
    if (iter_next($iter_take[%id])) {
        $iter_value[%id] = call($iter_func[%id],
            $iter_value[$iter_take[%id]]);
        return 1;
    }

    return 0;
}

function iter_proto_map_drop(%id) {
    iter_drop($iter_take[%id]);
    $iter_take[%id] = "";
    $iter_func[%id] = "";
}

function IteratorProto::map(%take, %func) {
    %id = iter_new("iter_proto_map_next", "iter_proto_map_drop");
    $iter_take[%id] = %take;
    $iter_func[%id] = %func;
    return %id;
}

function IteratorProto::apply(%id, %func) {
    while (iter_next(%id)) {
        call(%func, $iter_value[%id]);
    }

    iter_drop(%id);
}

function IteratorProto::fold(%id, %init, %func) {
    while (iter_next(%id)) {
        %init = call(%func, %init, $iter_value[%id]);
    }

    iter_drop(%id);
    return %init;
}

function IteratorProto::collect(%id) {
    %vec = new ScriptObject() {
        class = "Vec";
        length = 0;
    };

    while (iter_next(%id)) {
        %vec.push($iter_value[%id]);
    }

    iter_drop(%id);
    return %vec;
}

function IteratorProto::first(%id) {
    if (iter_next(%id)) {
        %value = $iter_value[%id];
    }

    iter_drop(%id);
    return %value;
}

function IteratorProto::first(%id) {
    while (iter_next(%id)) {
        %value = $iter_value[%id];
    }

    iter_drop(%id);
    return %value;
}

// ======
// Global iterator sources
function range_iter_next(%id) {
    if ($iter_curr[%id] < $iter_max[%id]) {
        $iter_value[%id] = $iter_curr[%id];
        $iter_curr[%id] += $iter_step[%id];
        return 1;
    }

    return 0;
}

function range_iter_drop(%id) {
    $iter_max[%id] = "";
    $iter_curr[%id] = "";
    $iter_step[%id] = "";
}

function range(%min, %max, %step) {
    %id = iter_new("range_iter_next", "range_iter_drop");
    $iter_max[%id] = %max;
    $iter_curr[%id] = %min;
    $iter_step[%id] = %step $= "" ? 1 : %step;
    return %id;
}
