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
	Vec.methodName[Vec.methodCount] = "onAdd";
	Vec.methodCount++;
}
function Vec::onAdd(%this) {
%this.length = 0;
}

if (!Vec.isMethodclear) {
	Vec.isMethodclear = 1;
	Vec.methodArgsclear = "";
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
	Vec.methodName[Vec.methodCount] = "map";
	Vec.methodCount++;
}
function Vec::map(%this, %func) {
for (%i = 0; %i < %this.length; %i++) {
if (isObject(%_t = %func) && %_t $= %_t.getID()) %_t._call(); else call(%_t);
%thing = (isObject(%_t = %func) && %_t $= %_t.getID() ? %_t._call("foo", "bar") : call(%_t, "foo", "bar"));
%value = (isObject(%_t = %func) && %_t $= %_t.getID() ? %_t._call(%this.value[%i]) : call(%_t, %this.value[%i]));
%this.value[%i] = %value;
}
}

