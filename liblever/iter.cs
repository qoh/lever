if ($_iter_nextid $= "") {
    $_iter_nextid = -1;
}

function iter_new(%next, %drop) {
    %id = "_iter_" @ ($_iter_nextid = ($_iter_nextid + 1) | 0);
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
