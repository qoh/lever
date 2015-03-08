if ($tod::nextid $= "") {
    $tod::nextid = 0;
}

function ____tod_escape(%input) {
    %length = strlen(%input);

    for (%i = 0; %i < %length; %i++) {
        %char = getSubStr(%input, %i, 1);

        // Not perfectly safe yet - doesn't escape the following:
        // ! @ $ % ( ) + { } [ ]
        switch$ (%char) {
            case "&": %output = %output @ "&amp;";
            case "<": %output = %output @ "&lt;";
            case ">": %output = %output @ "&gt;";
            case "\"": %output = %output @ "&quot;";
            case "'": %output = %output @ "&apos;";
            case "`": %output = %output @ "&#96;";
            case " ": %output = %output @ "&nbsp;";
            case "=": %output = %output @ "&#61;";

            default: %output = %output @ %char;
        }
    }

    return %output;
}

function tod::load_template(%filename) {
    if (isFunction($tod::cached_func[%filename])) {
        %time = getFileModifiedSortTime(%filename);
        %test = (%time | 0) <= ($tod::cached_time[%filename] | 0);

        if (%test) {
            return $tod::cached_func[%filename];
        }
    }

    %file = new FileObject();

    if (!%file.openForRead(%filename)) {
        error("ERROR: Cannot open template file '" @ %filename @ "' for reading");
        %file.delete();
        return "";
    }

    while (!%file.isEOF()) {
        %template = %template @ %file.readLine() @ "\r\n";
    }

    %file.close();
    %file.delete();

    %func = tod::compile(%template);

    if (%func $= "") {
        warn(%filename @ ": Template compilation failed...");
        return "";
    }

    $tod::cached_func[%filename] = %func;
    $tod::cached_time[%filename] = getFileModifiedSortTime(%filename);

    return %func;
}

function tod::compile(%template) {
    %index = 0;
    %length = strlen(%template);
    %using_stack = 0;

    while (1) {
        %start = strpos(%template, "{{", %index);

        if (%start == -1) {
            %start = %length;
        }

        if (%start > %index) {
            %text = expandEscape(getSubStr(%template, %index, %start - %index));
            %code = %code @ "\n  ";
            %code = %code @ "%_r=%_r@\"" @ %text @ "\";";
        }

        if (%start >= %length) {
            break;
        }

        %hair = "";
        %in_string = false;
        %end = -1;

        for (%i = %start + 2; %i < %length; %i++) {
            if (%in_string) {
                %char = getSubStr(%template, %i, 1);
                %hair = %hair @ %char;

                if (!%in_escape && %char $= "\"") {
                    %in_string = false;
                } else {
                    %in_escape = %char $= "\\";
                }
            } else {
                %char = getSubStr(%template, %i, 1);

                if (%char $= "}" && getSubStr(%template, %i + 1, 1) $= "}") {
                    %end = %i;
                    break;
                }

                if (%char $= "#") {
                    %hair = %hair @ "%_d.";
                } else {
                    if (%char $= "\"") {
                        %in_string = true;
                    }

                    %hair = %hair @ %char;
                }
            }
        }

        if (%end == -1) {
            error("ERROR: Unclosed {{ at " @ %start);
            return "";
        }

        %hair = trim(%hair);

        if (%hair $= "") {
            error("ERROR: Empty {{ expression }} at " @ %start);
            return "";
        }

        %code = %code @ "\n  ";

        if (getSubStr(%hair, 0, 1) $= ":") {
            %fun = getSubStr(firstWord(%hair), 1, strlen(%hair));
            %arg = restWords(%hair);

            switch$ (%fun) {
                case "ts": %code = %code @ %arg;
                case "raw": %code = %code @ "%_r=%_r@" @ %hair @ ";";

                case "break":
                    if (%using_stack > 0) {
                        %ref = %using_stack[%using_stack--];
                        %using_stack[%using_stack] = "";
                        %code = %code @ "\n  ";
                        %code = %code @ %ref;
                    }

                    %code = %code @ "break;";

                case "end":
                    %code = %code @ "}";

                    if (%using_stack > 0) {
                        %ref = %using_stack[%using_stack--];
                        %using_stack[%using_stack] = "";
                        %code = %code @ "\n  ";
                        %code = %code @ %ref;
                    }

                case "if": %code = %code @ "if(" @ %arg @ "){";
                case "for": %code = %code @ "for(" @ %arg @ "){";
                case "while": %code = %code @ "raw(" @ %arg @ "){";
                case "each":
                    %ref = "%_i" @ %using_stack;

                    %using_stack[%using_stack] = "iter_drop(" @ %ref @ ");";
                    %using_stack++;

                    %code = %code @ %ref @ "=" @ restWords(%arg) @ ";";
                    %code = %code @ "\n  ";
                    %code = %code @ "while(iter_next(" @ %ref @ ")) {";
                    %code = %code @ "\n  ";
                    %code = %code @ firstWord(%arg) @ "=$iter_value[" @ %ref @ "];";

                default:
                    error("ERROR: Unknown {{ :function }} at " @ %start);
                    return "";
            }
        } else {
            %code = %code @ "%_r=%_r@____tod_escape(" @ %hair @ ");";
        }

        %index = %end + 2;
    }

    %name = "____tod_template_" @ $tod::nextid;

    setclipboard("function " @ %name @ "(%_d) {" @ %code @ "\n\n  return %_r;\n}");
    eval("function " @ %name @ "(%_d){" @ %code @ "return %_r;}");

    if (!isFunction(%name)) {
        error("ERROR: Failed to compile template");
        return "";
    }

    $tod::nextid = ($tod::nextid + 1) | 0;
    return %name;
}
