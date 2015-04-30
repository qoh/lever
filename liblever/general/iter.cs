if ($_iter_id $= "") $_iter_id = -1;

function _iter_new() { return $_iter_id = ($_iter_id + 1) | 0; }
function _iter_drop(%id) { call($_iter_drop[%id], %id); }

function iter_map_next(%id) {
    if (call($_iter_next[$iter_iter[%id]], %id)) {
        $_ret0 = call($iter_func[%id], $_ret0);
        return 1;
    }
    return 0;
}
function iter_map_prev(%id) {
    if (call($_iter_prev[$iter_iter[%id]], %id)) {
        $_ret0 = call($iter_func[%id], $_ret0);
        return 1;
    }
    return 0;
}
function iter_map_drop(%id) {
    _iter_drop($iter_iter[%id]);
}
function iter_map($iter, %func) {
    %id = _iter_new();
    $_iter_next[%id] = "iter_map_next";
    $_iter_prev[%id] = "iter_map_prev";
    $_iter_drop[%id] = "iter_map_drop";
    $iter_iter[%id] = %iter;
    $iter_func[%id] = %func;
    return %id;
}

function iter_filter_next(%id) {
    while (call($_iter_next[$iter_iter[%id]], %id)) {
        if (call($iter_pred[%id], $_ret0)) {
            return 1;
        }
    }
    return 0;
}
function iter_filter_prev(%id) {
    while (call($_iter_prev[$iter_iter[%id]], %id)) {
        if (call($iter_pred[%id], $_ret0)) {
            return 1;
        }
    }
    return 0;
}
function iter_filter_drop(%id) {
    _iter_drop($iter_iter[%id]);
}
function iter_filter(%iter, %predicate) {
    %id = _iter_new();
    $_iter_next[%id] = "iter_filter_next";
    $_iter_prev[%id] = "iter_filter_prev";
    $_iter_drop[%id] = "iter_filter_drop";
    $iter_iter[%id] = %iter;
    $iter_pred[%id] = %predicate;
    return %id;
}

// TODO: support 'prev' for enumerate() somehow?
function iter_enumerate_next(%id) {
    if (call($_iter_next[$iter_iter[%id]], %id)) {
        $_ret1 = $_ret0;
        $_ret0 = ($iter_index[%id] = ($iter_index[%id] + 1) | 0);
        return 1;
    }
    return 0;
}
function iter_enumerate_drop(%id) {
    _iter_drop($iter_iter[%id]);
}
function iter_enumerate(%iter, %start) {
    %id = _iter_new();
    $_iter_next[%id] = "iter_enumerate_next";
    $_iter_drop[%id] = "iter_enumerate_drop";
    $iter_iter[%id] = %iter;
    $iter_index[%id] = (%start - 1) | 0;
    return %id;
}

function iter_reverse_next(%id) { return call($_iter_prev[$iter_iter[%id]], %id); }
function iter_reverse_prev(%id) { return call($_iter_next[$iter_iter[%id]], %id); }
function iter_reverse_drop(%id) { _iter_drop($iter_iter[%id]); }
function iter_reverse(%iter) {
    %id = _iter_new();
    $_iter_next[%id] = "iter_reverse_next";
    $_iter_prev[%id] = "iter_reverse_prev";
    $_iter_drop[%id] = "iter_reverse_drop";
    $iter_iter[%id] = %iter;
    return %id;
}

function iter_collect(%id) {
    %vec = new ScriptObject() {
        class = "Vec";
        length = 0;
    };
    while (call($_iter_next[%id], %id)) {
        %vec.push($_ret0);
    }
    _iter_drop(%id);
    return %vec;
}

function iter_fold(%id, %init, %func) {
    while (call($_iter_next[%id], %id)) {
        %init = call(%func, %init, $_ret0);
    }
    _iter_drop(%id);
    return %init;
}

function iter_each(%id, %func) {
    while (call($_iter_next[%id], %id)) {
        call(%func, $_ret0);
    }
    _iter_drop(%id);
}

function iter_all(%id, %predicate) {
    while (call($_iter_next[%id], %id)) {
        if (!call(%predicate, $_ret0)) {
            _iter_drop(%id);
            return 0;
        }
    }
    _iter_drop(%id);
    return 1;
}

function iter_any(%id, %predicate) {
    while (call($_iter_next[%id], %id)) {
        if (call(%predicate, $_ret0)) {
            _iter_drop(%id);
            return 1;
        }
    }
    _iter_drop(%id);
    return 0;
}

function iter_find(%id, %predicate) {
    while (call($_iter_next[%id], %id)) {
        if (call(%predicate, $_ret0)) {
            _iter_drop(%id);
            return $_ret0;
        }
    }

    _iter_drop(%id);
    return "";
}

function iter_max(%id) {
    if (call($_iter_next[%id], %id)) {
        %max = $_ret0;
    }
    while (call($_iter_next[%id], %id)) {
        %max = getMax(%max, $_ret0);
    }
    _iter_drop(%id);
    return %max;
}

function iter_min(%id) {
    if (call($_iter_next[%id], %id)) {
        %min = $_ret0;
    }
    while (call($_iter_next[%id], %id)) {
        %min = getMin(%min, $_ret0);
    }
    _iter_drop(%id);
    return %min;
}

function iter_sample(%id, %count) {
	if (%count == 1) {
		%visited = 0;

		while (call($_iter_next[%id], %id)) {
			if (getRandom(%visited) == 0) {
				%value = $_ret0;
            }

			%visited++;
		}

        _iter_drop(%id);
		return %value;
	}
}

function range_iter_next(%id) {
    if ($iter_i[%id] < $iter_j[%id]) {
        $_ret0 = $iter_i[%id];
        $iter_i[%id] += $iter_step[%id];
        return 1;
    }

    return 0;
}
function range_iter_prev(%id) {
    if ($iter_j[%id] > $iter_i[%id]) {
        $_ret0 = $iter_j[%id];
        $iter_j[%id] -= $iter_step[%id];
        return 1;
    }

    return 0;
}
function range(%i, %j, %step) {
    %id = _iter_new();
    $_iter_next[%id] = "range_iter_next";
    $_iter_prev[%id] = "range_iter_prev";
    $iter_i[%id] = %i;
    $iter_j[%id] = %j;
    $iter_step[%id] = %step $= "" ? 1 : %step;
    return %id;
}

function array_iter_next(%id) {
    if ($iter_i[%id] <= $iter_j[%id]) {
        $_ret0 = $iter_values[%id, $iter_i[%id]];
        $iter_i[%id]++;
        return 1;
    }
    return 0;
}
function array_iter_prev(%id) {
    if ($iter_j[%id] >= $iter_j[%id]) {
        $_ret0 = $iter_values[%id, $iter_j[%id]];
        $iter_j[%id]--;
        return 1;
    }
    return 0;
}
