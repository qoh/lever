function SimObject::clone(%this) {
    %name = %this.getName();
    %this.setName("CloneTarget");
    %clone = new (%this.getClassName())(%name : CloneTarget);
    %this.setName(%name);
    return %clone;
}

function SimObject::isMethod(%this, %name) {
	%className = %this.getClassName();

	if (%className $= "ScriptObject" || %className $= "ScriptGroup") {
		if (%this.class !$= "" && isFunction(%this.class, %name)) {
			return 1;
        }

		if (%this.superClass !$= "" && isFunction(%this.superClass, %name)) {
			return 1;
        }
	}

    // This could be improved a lot (with proper class hierarchy tests)
	return isFunction(%className, %name) || isFunction("SimObject", %name);
}

function SimObject::call(%this, %name,
	%a,%b,%c,%d,%e,%f,%g,%h,%i,%j,%k,%l,%m,%n,%o,%p,%q,%r)
{
	return eval("return %this." @ %name @
		"(%a,%b,%c,%d,%e,%f,%g,%h,%i,%j,%k,%l,%m,%n,%o,%p,%q,%r);");
}


function SimObject::_get_array(%this, %name) {
    switch (stripos("_abcdefghijklmnopqrstuvwxyz", getSubStr(%name, 0, 1))) {
        case  0: return %this._[getSubStr(%name, 1, strlen(%name))];
        case  1: return %this.a[getSubStr(%name, 1, strlen(%name))];
        case  2: return %this.b[getSubStr(%name, 1, strlen(%name))];
        case  3: return %this.c[getSubStr(%name, 1, strlen(%name))];
        case  4: return %this.d[getSubStr(%name, 1, strlen(%name))];
        case  5: return %this.e[getSubStr(%name, 1, strlen(%name))];
        case  6: return %this.f[getSubStr(%name, 1, strlen(%name))];
        case  7: return %this.g[getSubStr(%name, 1, strlen(%name))];
        case  8: return %this.h[getSubStr(%name, 1, strlen(%name))];
        case  9: return %this.i[getSubStr(%name, 1, strlen(%name))];
        case 10: return %this.j[getSubStr(%name, 1, strlen(%name))];
        case 11: return %this.k[getSubStr(%name, 1, strlen(%name))];
        case 12: return %this.l[getSubStr(%name, 1, strlen(%name))];
        case 13: return %this.m[getSubStr(%name, 1, strlen(%name))];
        case 14: return %this.n[getSubStr(%name, 1, strlen(%name))];
        case 15: return %this.o[getSubStr(%name, 1, strlen(%name))];
        case 16: return %this.p[getSubStr(%name, 1, strlen(%name))];
        case 17: return %this.q[getSubStr(%name, 1, strlen(%name))];
        case 18: return %this.r[getSubStr(%name, 1, strlen(%name))];
        case 19: return %this.s[getSubStr(%name, 1, strlen(%name))];
        case 20: return %this.t[getSubStr(%name, 1, strlen(%name))];
        case 21: return %this.u[getSubStr(%name, 1, strlen(%name))];
        case 22: return %this.v[getSubStr(%name, 1, strlen(%name))];
        case 23: return %this.w[getSubStr(%name, 1, strlen(%name))];
        case 24: return %this.x[getSubStr(%name, 1, strlen(%name))];
        case 25: return %this.y[getSubStr(%name, 1, strlen(%name))];
        case 26: return %this.z[getSubStr(%name, 1, strlen(%name))];
    }

    return "";
}

function SimObject::_set_array(%this, %name, %value) {
    switch (stripos("_abcdefghijklmnopqrstuvwxyz", getSubStr(%name, 0, 1))) {
        case  0: %this._[getSubStr(%name, 1, strlen(%name))] = %value;
        case  1: %this.a[getSubStr(%name, 1, strlen(%name))] = %value;
        case  2: %this.b[getSubStr(%name, 1, strlen(%name))] = %value;
        case  3: %this.c[getSubStr(%name, 1, strlen(%name))] = %value;
        case  4: %this.d[getSubStr(%name, 1, strlen(%name))] = %value;
        case  5: %this.e[getSubStr(%name, 1, strlen(%name))] = %value;
        case  6: %this.f[getSubStr(%name, 1, strlen(%name))] = %value;
        case  7: %this.g[getSubStr(%name, 1, strlen(%name))] = %value;
        case  8: %this.h[getSubStr(%name, 1, strlen(%name))] = %value;
        case  9: %this.i[getSubStr(%name, 1, strlen(%name))] = %value;
        case 10: %this.j[getSubStr(%name, 1, strlen(%name))] = %value;
        case 11: %this.k[getSubStr(%name, 1, strlen(%name))] = %value;
        case 12: %this.l[getSubStr(%name, 1, strlen(%name))] = %value;
        case 13: %this.m[getSubStr(%name, 1, strlen(%name))] = %value;
        case 14: %this.n[getSubStr(%name, 1, strlen(%name))] = %value;
        case 15: %this.o[getSubStr(%name, 1, strlen(%name))] = %value;
        case 16: %this.p[getSubStr(%name, 1, strlen(%name))] = %value;
        case 17: %this.q[getSubStr(%name, 1, strlen(%name))] = %value;
        case 18: %this.r[getSubStr(%name, 1, strlen(%name))] = %value;
        case 19: %this.s[getSubStr(%name, 1, strlen(%name))] = %value;
        case 20: %this.t[getSubStr(%name, 1, strlen(%name))] = %value;
        case 21: %this.u[getSubStr(%name, 1, strlen(%name))] = %value;
        case 22: %this.v[getSubStr(%name, 1, strlen(%name))] = %value;
        case 23: %this.w[getSubStr(%name, 1, strlen(%name))] = %value;
        case 24: %this.x[getSubStr(%name, 1, strlen(%name))] = %value;
        case 25: %this.y[getSubStr(%name, 1, strlen(%name))] = %value;
        case 26: %this.z[getSubStr(%name, 1, strlen(%name))] = %value;
    }

    return %value;
}

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
