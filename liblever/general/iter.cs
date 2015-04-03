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
    // call() does not error on unexistant functions, checks in-engine
	// checking for "" would be slower when there's a drop func and not much faster when there isn't
    // usually there is one anyway
    call($_iter_drop[%id], %id);
    $_iter_next[%id] = "";
    $_iter_drop[%id] = "";
    $iter_value[%id] = "";
}

function iter_next(%id) {
    // see notes in iter_drop() for call()
	// there's normally always a next func and when there isn't,
	// you'll always get a falsy value, so it's fine to not check %id
    return call($_iter_next[%id], %id);
}

// ======
// IteratorProto methods
function IteratorProto::delete(%this) {}
function IteratorProto::setName(%this, %name) {}

function IteratorProto::count(%this) {
    %n = 0;

    while (iter_next(%this)) {
        %n++;
    }

    iter_drop(%this);
    return %n;
}

function IteratorProto::last(%this) {
    while (iter_next(%this)) {
        %value = $iter_value[%this];
    }

    iter_drop(%this);
    return %value;
}

function IteratorProto::first(%id) {
    if (iter_next(%id)) {
        %value = $iter_value[%id];
    }

    iter_drop(%id);
    return %value;
}

function IteratorProto::nth(%this, %n) {
    for (%i = 0; %i < %n; %i++) {
        if (!iter_next(%this)) {
            iter_drop(%this);
            return "";
        }
    }

    %value = $iter_value[%this];
    iter_drop(%this);
    return %value;
}

function IteratorProto::chain(%this, %other) {
    return "NotImplemented";
}

function iter_proto_map_next(%id) {
    if (iter_next($iter_iter[%id])) {
        $iter_value[%id] = call($iter_func[%id], $iter_value[$iter_iter[%id]]);
        return 1;
    }

    return 0;
}
function iter_proto_map_drop(%id) {
    iter_drop($iter_iter[%id]);
    $iter_iter[%id] = "";
    $iter_func[%id] = "";
}
function IteratorProto::map(%this, %func) {
    %id = iter_new("iter_proto_map_next", "iter_proto_map_drop");
    $iter_iter[%id] = %this;
    $iter_func[%id] = %func;
    return %id;
}

function iter_proto_filter_next(%id) {
    while (iter_next($iter_iter[%id])) {
        if (call($iter_pred[%id], $iter_value[$iter_iter[%id]])) {
            $iter_value[%id] = $iter_value[$iter_iter[%id]];
            return 1;
        }
    }

    return 0;
}
function iter_proto_filter_drop(%id) {
    iter_drop($iter_iter[%id]);
    $iter_iter[%id] = "";
    $iter_pred[%id] = "";
}
function IteratorProto::filter(%this, %predicate) {
    %id = iter_new("iter_proto_filter_next", "iter_proto_filter_drop");
    $iter_iter[%id] = %this;
    $iter_pred[%id] = %predicate;
    return %id;
}

function IteratorProto::enumerate(%this) {
    return "NotImplemented";
}

function IteratorProto::peekable(%this) {
    return "NotImplemented";
}

function IteratorProto::skip(%this, %n) {
    for (%i = 0; %i < %n && iter_next(%this); %i++) {}
    return %this;
}

function iter_proto_take_next(%id) {
    if ($iter_n[%id] > 0 && iter_next($iter_from[%id])) {
        $iter_n[%id]--;
        $iter_value[%id] = $iter_value[$iter_from[%id]];
        return 1;
    }

    return 0;
}
function iter_proto_take_drop(%id) {
    iter_drop($iter_from[%id]);
    $iter_from[%id] = "";
    $iter_n[%id] = "";
}
function IteratorProto::take(%this, %n) {
    %id = iter_new("iter_proto_take_next", "iter_proto_take_drop");
    $iter_from[%id] = %this;
    $iter_n[%id] = %n;
    return %id;
}

function IteratorProto::collect(%this) {
    %vec = new ScriptObject() {
        class = "Vec";
        length = 0;
    };

    while (iter_next(%this)) {
        %vec.push($iter_value[%this]);
    }

    iter_drop(%this);
    return %vec;
}

function IteratorProto::fold(%this, %init, %func) {
    while (iter_next(%this)) {
        %init = call(%func, %init, $iter_value[%this]);
    }

    iter_drop(%this);
    return %init;
}

function IteratorProto::all(%this, %predicate) {
    while (iter_next(%this)) {
        if (!call(%predicate, $iter_value[%this])) {
            iter_drop(%this);
            return 0;
        }
    }

    iter_drop(%this);
    return 1;
}

function IteratorProto::any(%this, %predicate) {
    while (iter_next(%this)) {
        if (call(%predicate, $iter_value[%this])) {
            iter_drop(%this);
            return 1;
        }
    }

    iter_drop(%this);
    return 0;
}

function IteratorProto::find(%this, %predicate) {
    while (iter_next(%this)) {
        %value = $iter_value[%this];
        if (call(%predicate, %value)) {
            iter_drop(%this);
            return %value;
        }
    }

    iter_drop(%this);
    return "";
}

function IteratorProto::max(%this) {
    if (iter_next(%this)) {
        %max = $iter_value[%this];
    }

    while (iter_next(%this)) {
        %max = getMax(%max, $iter_value[%this]);
    }

    iter_drop(%this);
    return 0;
}

function IteratorProto::min(%this) {
    if (iter_next(%this)) {
        %min = $iter_value[%this];
    }

    while (iter_next(%this)) {
        %min = getMin(%min, $iter_value[%this]);
    }

    iter_drop(%this);
    return 0;
}

function IteratorProto::each(%id, %func) {
    while (iter_next(%id)) {
        call(%func, $iter_value[%id]);
    }

    iter_drop(%id);
}

function IteratorProto::sample(%id, %count) {
	if (%count == 1) {
		%visited = 0;

		while (iter_next(%id)) {
			if (getRandom(%visited) == 0) {
				%value = $iter_value[%id];
            }

			%visited++;
		}

		return %value;
	}
}

// IteratorProto::reverse

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

// ======
// Common convenience iterator type
function array_iter_next(%id) {
    if ($iter_index[%id] < $iter_length[%id]) {
        $iter_value[%id] = $iter_values[%id, $iter_index[%id]];
        $iter_index[%id]++;
        return 1;
    }

    return 0;
}

function array_iter_drop(%id) {
    for (%i = 0; %i < $iter_length[%id]; %i++) {
        $iter_values[%id, %i] = "";
    }

    $iter_length[%id] = "";
    $iter_index[%id] = "";
}
