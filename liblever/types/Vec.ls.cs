if (!isObject(Vec)) {
	new ScriptObject(Vec) {
		class = "Class";
		____inst = 0;
		parent = "";
		methodCount = 0;
	};
}
function Vec(%a,%b,%c,%d,%e,%f,%g,%h,%i,%j,%k,%l,%m,%n,%o,%p,%q,%r,%s) {
	%_ = new ScriptObject() {
		class = "Vec";
		superClass = "Class";
		____inst = 1;
	};
	if(isFunction("Vec", "onNew")) {
		%_.onNew(%a,%b,%c,%d,%e,%f,%g,%h,%i,%j,%k,%l,%m,%n,%o,%p,%q,%r,%s);
	}
	return %_;
}

if (!Vec.isMethodonAdd) {
	Vec.isMethodonAdd = 1;
	Vec.methodArgsonAdd = "";
	Vec.methodTypeonAdd = "";
	Vec.methodName[Vec.methodCount] = "onAdd";
	Vec.methodCount++;
}
function Vec::onAdd(%this) {
%this.length = 0;
}

if (!Vec.isMethodclear) {
	Vec.isMethodclear = 1;
	Vec.methodArgsclear = "";
	Vec.methodTypeclear = "";
	Vec.methodName[Vec.methodCount] = "clear";
	Vec.methodCount++;
}
function Vec::clear(%this) {
for (%i = 0; %i < %this.length; %i++) {
%this.value[%i] = "";
}
%this.length = 0;
}

if (!Vec.isMethodpush) {
	Vec.isMethodpush = 1;
	Vec.methodArgspush = "value";
	Vec.methodTypepush = "";
	Vec.methodName[Vec.methodCount] = "push";
	Vec.methodCount++;
}
function Vec::push(%this, %value) {
%this.value[%this.length] = %value;
%this.length++;
}

if (!Vec.isMethodmap) {
	Vec.isMethodmap = 1;
	Vec.methodArgsmap = "func";
	Vec.methodTypemap = "";
	Vec.methodName[Vec.methodCount] = "map";
	Vec.methodCount++;
}
function Vec::map(%this, %func) {
for (%i = 0; %i < %this.length; %i++) {
%value = (isObject(%_t = %func) && %_t $= %_t.getID() ? %_t._call(%this.value[%i]) : call(%_t, %this.value[%i]));
%this.value[%i] = %value;
}
}

if (!Vec.isMethodany) {
	Vec.isMethodany = 1;
	Vec.methodArgsany = "callable predicate";
	Vec.methodTypeany = "boolean";
	Vec.methodName[Vec.methodCount] = "any";
	Vec.methodCount++;
}
function Vec::any(%this, %predicate) {
if (isObject(%predicate) && %predicate $= %predicate.getID() ? !%predicate.isMethod("_call") : !isFunction(%predicate)) {
	error("ERROR: Argument 'predicate' must be of type callable");
	return "";
}
for (%i = 0; %i < %this.length; %i++) {
%value = %this.value[%i];
if ((isObject(%_t = %predicate) && %_t $= %_t.getID() ? %_t._call(%value) : call(%_t, %value))) {
return 1;
}
}
return 0;
}

