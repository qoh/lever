function liblever_exec(%file) {
    if (isFile(%file)) {
        if (strPos(%file, "*") > -1) {
            // Test: Does findFirstFile/findNextFile support ./?
            for (%i = findFirstFile(%file); isFile(%i); %i = findNextFile(%file)) {
                exec(%i);
            }
        }
        else {
            exec(%file);
        }
    }
}
