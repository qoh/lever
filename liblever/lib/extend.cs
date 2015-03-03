function simset_iter_next(%id) {
    %set = $iter_set[%id];

    if ($iter_owner[%id]) {
        if (%set.getCount()) {
            $iter_value[%id] = %set.getObject(0);
            %set.remove($iter_value[%id]); // could be faster
            return 1;
        }
    } else {
        if ($iter_index[%id] < %set.getCount()) {
            $iter_value[%id] = %set.getObject($iter_index[%id]);
            $iter_index[%id]++;
            return 1;
        }
    }

    return 0;
}

function simset_iter_drop(%id) {
    if ($iter_owner[%id] && isObject($iter_set[%id])) {
        $iter_set[%id].clear(); // don't delete the members (TODO: revisit)
        $iter_set[%id].delete();
    }

    $iter_index[%id] = "";
    $iter_owner[%id] = "";
    $iter_set[%id] = "";
}

function SimSet::iter(%this) {
    %id = iter_new("simset_iter_next", "simset_iter_drop");
    $iter_index[%id] = 0;
    $iter_set[%id] = %this;
    $iter_owner[%id] = 0;
    return %id;
}
