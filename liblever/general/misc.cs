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
