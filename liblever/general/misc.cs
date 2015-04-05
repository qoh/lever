function op_neg (%a)     { return -%a;           }
function op_add (%a, %b) { return  %a + %b;      }
function op_sub (%a, %b) { return  %a - %b;      }
function op_mul (%a, %b) { return  %a * %b;      }
function op_div (%a, %b) { return  %a / %b;      }
function op_mod (%a, %b) { return  %a % %b;      }
function op_iadd(%a, %b) { return (%a + %b) | 0; }
function op_isub(%a, %b) { return (%a - %b) | 0; }
function op_imul(%a, %b) { return (%a * %b) | 0; }
function op_idiv(%a, %b) { return (%a / %b) | 0; }
function op_not (%a)     { return ~%a;           }
function op_xor (%a, %b) { return  %a ^ %b;      }
function op_and (%a, %b) { return  %a & %b;      }
function op_or  (%a, %b) { return  %a | %b;      }
function op_lsh (%a, %b) { return %a << %b;      }
function op_rsh (%a, %b) { return %a >> %b;      }

function isInfinity(%n) {
	return strcmp(%n, "-1.#INF") == 0 || strcmp(%n, "1.#INF") == 0;
}

function isNaN(%n) {
	return strcmp(%n, "-1.#IND") == 0;
}

function isFloat(%n) {
	return %n $= (%n + 0);
}

function isInteger(%n) {
	return %n $= (%n | 0);
}

function isFakeInt(%n) {
	return %n $= mFloor(%n);
}

function isNumber(%n) {
	return isInteger(%n) || isFloat(%n);
}

function isExplicitObject(%n) {
	return isObject(%n) && getSubStr(%n, strlen(%n - 1), 1) $= "\x01";
}

// TODO: Get rid of this
function LeverScope(%parent) {
    return new ScriptObject() {
        class = "LeverScope";
        ________references = 1;
        ________parent = %parent; // AAAAAAAAAAA
    };
}

function LeverScope::onRemove(%this) {
    for (%i = 0; (%pair = %this.getTaggedField(%i)) !$= ""; %i++) {
        %split = strpos(%pair, "\t");
        %field = getSubStr(%pair, 0, %split);

        if (%field $= "class" || getSubStr(%field, 0, 8) !$= "________" ||
            !%this.________owned[%field]
        ) {
            %value = getSubStr(%pair, %split + 1, strlen(%pair));

            if (isObject(%value)) {
                %value.delete();
            }
        }
    }
}

function LeverScope::keep(%this) {
    %this.________references++;
}

function LeverScope::drop(%this) {
    if (%this.________references-- < 1) {
        %this.delete();
    }
}

function LeverClosure(%scope, %target) {
    %scope.keep();
    return new ScriptObject() {
        class = "LeverClosure";
        scope = %scope;
        target = %target;
    };
}

function LeverClosure::onRemove(%this) {
    %this.scope.drop();
}

function LeverClosure::call(%this, %a, %b, %c, %d, %e, %f, %g, %h, %i, %j,
    %k, %l, %m, %n, %o, %p, %q, %r) {
    return call(%this.target, %this.scope, %a, %b, %c, %d, %e, %f, %g, %h, %i,
        %j, %k, %l, %m, %n, %o, %p, %q, %r, %s);
}

// I'm so sorry
function __lever_call0(%target) {
    return isObject(%target) ? %target.call() : call(%target);
}

function __lever_call1(%target, %a) {
    return isObject(%target) ? %target.call(%a) : call(%target, %a);
}

function __lever_call2(%target, %a, %b) {
    return isObject(%target) ? %target.call(%a, %b) : call(%target, %a, %b);
}

function __lever_call3(%target, %a, %b, %c) {
    return isObject(%target) ?
        %target.call(%a, %b, %c) :
        call(%target, %a, %b, %c);
}

function __lever_call4(%target, %a, %b, %c, %d) {
    return isObject(%target) ?
        %target.call(%a, %b, %c, %d) :
        call(%target, %a, %b, %c, %d);
}

function __lever_call5(%target, %a, %b, %c, %d, %e) {
    return isObject(%target) ?
        %target.call(%a, %b, %c, %d, %e) :
        call(%target, %a, %b, %c, %d, %e);
}

function __lever_call6(%target, %a, %b, %c, %d, %e, %f) {
    return isObject(%target) ?
        %target.call(%a, %b, %c, %d, %e, %f) :
        call(%target, %a, %b, %c, %d, %e, %f);
}

function __lever_call7(%target, %a, %b, %c, %d, %e, %f, %g) {
    return isObject(%target) ?
        %target.call(%a, %b, %c, %d, %e, %f, %g) :
        call(%target, %a, %b, %c, %d, %e, %f, %g);
}

function __lever_call8(%target, %a, %b, %c, %d, %e, %f, %g, %h) {
    return isObject(%target) ?
        %target.call(%a, %b, %c, %d, %e, %f, %g, %h) :
        call(%target, %a, %b, %c, %d, %e, %f, %g, %h);
}

function __lever_call9(%target, %a, %b, %c, %d, %e, %f, %g, %h, %i) {
    return isObject(%target) ?
        %target.call(%a, %b, %c, %d, %e, %f, %g, %h, %i) :
        call(%target, %a, %b, %c, %d, %e, %f, %g, %h, %i);
}

function __lever_call10(%target, %a, %b, %c, %d, %e, %f, %g, %h, %i, %j) {
    return isObject(%target) ?
        %target.call(%a, %b, %c, %d, %e, %f, %g, %h, %i, %j) :
        call(%target, %a, %b, %c, %d, %e, %f, %g, %h, %i, %j);
}

function __lever_call11(%target, %a, %b, %c, %d, %e, %f, %g, %h, %i, %j, %k) {
    return isObject(%target) ?
        %target.call(%a, %b, %c, %d, %e, %f, %g, %h, %i, %j, %k) :
        call(%target, %a, %b, %c, %d, %e, %f, %g, %h, %i, %j, %k);
}

function __lever_call12(%target, %a, %b, %c, %d, %e, %f, %g, %h, %i, %j, %k,
    %l) {
    return isObject(%target) ?
        %target.call(%a, %b, %c, %d, %e, %f, %g, %h, %i, %j, %k, %l) :
        call(%target, %a, %b, %c, %d, %e, %f, %g, %h, %i, %j, %k, %l);
}

function __lever_call13(%target, %a, %b, %c, %d, %e, %f, %g, %h, %i, %j, %k,
    %l, %m) {
    return isObject(%target) ?
        %target.call(%a, %b, %c, %d, %e, %f, %g, %h, %i, %j, %k, %l, %m) :
        call(%target, %a, %b, %c, %d, %e, %f, %g, %h, %i, %j, %k, %l, %m);
}

function __lever_call14(%target, %a, %b, %c, %d, %e, %f, %g, %h, %i, %j, %k,
    %l, %m, %n) {
    return isObject(%target) ?
        %target.call(%a, %b, %c, %d, %e, %f, %g, %h, %i, %j, %k, %l, %m, %n) :
        call(%target, %a, %b, %c, %d, %e, %f, %g, %h, %i, %j, %k, %l, %m, %n);
}

function __lever_call15(%target, %a, %b, %c, %d, %e, %f, %g, %h, %i, %j, %k,
    %l, %m, %n, %o) {
    return isObject(%target) ?
        %target.call(%a, %b, %c, %d, %e, %f, %g, %h, %i, %j, %k, %l, %m, %n,
            %o) :
        call(%target, %a, %b, %c, %d, %e, %f, %g, %h, %i, %j, %k, %l, %m, %n,
            %o);
}

function __lever_call16(%target, %a, %b, %c, %d, %e, %f, %g, %h, %i, %j, %k,
    %l, %m, %n, %o, %p) {
    return isObject(%target) ?
        %target.call(%a, %b, %c, %d, %e, %f, %g, %h, %i, %j, %k, %l, %m, %n,
            %o, %p) :
        call(%target, %a, %b, %c, %d, %e, %f, %g, %h, %i, %j, %k, %l, %m, %n,
            %o, %p);
}

function __lever_call17(%target, %a, %b, %c, %d, %e, %f, %g, %h, %i, %j, %k,
    %l, %m, %n, %o, %p, %q) {
    return isObject(%target) ?
        %target.call(%a, %b, %c, %d, %e, %f, %g, %h, %i, %j, %k, %l, %m, %n,
            %o, %p, %q) :
        call(%target, %a, %b, %c, %d, %e, %f, %g, %h, %i, %j, %k, %l, %m, %n,
            %o, %p, %q);
}

function __lever_call18(%target, %a, %b, %c, %d, %e, %f, %g, %h, %i, %j, %k,
    %l, %m, %n, %o, %p, %q, %r) {
    return isObject(%target) ?
        %target.call(%a, %b, %c, %d, %e, %f, %g, %h, %i, %j, %k, %l, %m, %n,
            %o, %p, %q, %r) :
        call(%target, %a, %b, %c, %d, %e, %f, %g, %h, %i, %j, %k, %l, %m, %n,
            %o, %p, %q, %r);
}

function __lever_call19(%target, %a, %b, %c, %d, %e, %f, %g, %h, %i, %j, %k,
    %l, %m, %n, %o, %p, %q, %r, %s) {
    return isObject(%target) ?
        %target.call(%a, %b, %c, %d, %e, %f, %g, %h, %i, %j, %k, %l, %m, %n,
            %o, %p, %q, %r, %s) :
        call(%target, %a, %b, %c, %d, %e, %f, %g, %h, %i, %j, %k, %l, %m, %n,
            %o, %p, %q, %r, %s);
}
