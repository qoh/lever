function liblever_exec(%file) {
    if (isFile(%file)) {
        if (strPos(%file, "*") > -1) {
            for (%i = findFirstFile(%file); isFile(%i); %i = findNextFile(%file)) {
                exec(%i);
            }
        }
        else {
            exec(%file);
        }
    }
}
