// TODO

// NOTE: For interoperability with external JSON implementations, it is
// recommended to call `getASCIIString` before using `JSON::parse` and
// to call `getUTFString` after using `JSON::stringify`,
// as JSON should (must, per specification) be UTF-8.

function JSON::stringify(%data, %type) {
    if (TypeMarker::test(%data)) {
        if (%type $= "") {
            %type = $TypeMarker::type[%data];

            if (%type $= "float" || %type $= "integer") {
                %type = "number";
            }
        }

        %data = $TypeMarker::data[%data];
    } else if (%type $= "") {
        // HACK: No "real" good way of detecting null/bool
        if (isExplicitObject(%data)) {
            %type = "object";
        } else if (isNumber(%data)) {
            %type = "number";
        } else {
            %type = "string";
        }
    }

    switch$ (%type) {
        case "null":
            return "null";

        case "bool":
            return %data ? "true" : "false";

        case "number":
            if (%data $= (%data | 0)) {
                return %data | 0;
            }

            return %data + 0;

        case "string": // TODO: Spec-compliant fire escapes
            return "\"" @ expandEscape(%data) @ "\"";

        case "object": // TODO: Implement SimObject::isMethod
            if (isFunction(%data.class, "__toJSON")) {
                return %data.__toJSON();
            }

            error("ERROR: Object '" @ %data @ "' does not implement __toJSON");
            return "{\"error\": \"cannot encode object\", \"type\": " @
                JSON::stringify(%data.class, "string") @ "}";

        default:
            error("ERROR: Unknown type '" @ %type @ "'");
            return "{\"error\": \"unknown type\", \"type\": " @
                JSON::stringify(%type, "string") @ "}";
    }
}

function JSON::getErrorReport(%string) {
    %length = strlen(%string);

    if ($JSON::Index < 0 || $JSON::Index >= %length) {
        return "[char " @ $JSON::Index + 1 @ "/" @
            %length @ "]: " @ $JSON::Error;
    }

    // TODO: Generate small context
    // This will also blow up with newlines
    return %string NL makePadString(" ", $JSON::Index) @ "^" NL $JSON::Error;
}

function JSON::parse(%string) {
    $JSON::Index = 0;
    $JSON::Value = "";
    $JSON::Error = "";

    if (JSON::__parse(%string)) {
        if (isExplicitObject($JSON::Value)) {
            $JSON::Value.delete();
        }

        $JSON::Value = "";
        return 1;
    }

    if ($JSON::Index < strlen(%string)) {
        // FIXME: This is really WET
        if (isExplicitObject($JSON::Value)) {
            $JSON::Value.delete();
        }

        $JSON::Value = "";
        $JSON::Error = "__parse stopped before end of string";
        return 1;
    }

    $JSON::Index = "";
    return 0;
}

function JSON::__parse(%string, %length) {
    while (strpos(" \t\r\n", getSubStr(%string, $JSON::Index, 1)) != -1) {
        $JSON::Index++;
    }

    if (strcmp(getSubStr(%string, $JSON::Index, 4), "null") == 0) {
        $JSON::Value = "";
        $JSON::Index += 4;
        return 0;
    }

    if (strcmp(getSubStr(%string, $JSON::Index, 4), "true") == 0) {
        $JSON::Value = true;
        $JSON::Index += 4;
        return 0;
    }

    if (strcmp(getSubStr(%string, $JSON::Index, 5), "false") == 0) {
        $JSON::Value = false;
        $JSON::Index += 5;
        return 0;
    }

    switch$ (getSubStr(%string, $JSON::Index, 1)) {
        case "[":
            return JSON::__parseArray(%string);

        case "{":
            return JSON::__parseMap(%string);

        case "\"":
            %start = $JSON::Index++;
            %length = strlen(%string);

            while ($JSON::Index < %length) {
                if (!%escaped) {
                    %char = getSubStr(%string, $JSON::Index, 1);

                    if (%char $= "\"") {
                        break;
                    } else if (%char $= "\\") {
                        %escaped = 1;
                    }
                } else {
                    %escaped = 0;
                }

                $JSON::Index++;
            }

            if ($JSON::Index >= %length) {
                $JSON::Error = "It's the neverending string story";
                $JSON::Index = %start;
                return 1;
            }

            // TODO: Spec-compliant fire escapes
            $JSON::Value = collapseEscape(getSubStr(%string,
                %start, $JSON::Index - %start));
            $JSON::Index++;
            return 0;

        default: // Try for a number
            %start = $JSON::Index;
            %length = strlen(%string);

            if (getSubStr(%string, %start, 1) $= "-") {
                $JSON::Index++;
            }

            while ($JSON::Index < %length) {
                %char = getSubStr(%string, %start, 1);

                if (%char $= ".") {
                    if (%radix) {
                        $JSON::Error = "Number can only contain one radix";
                        return 1;
                    }

                    if (!%first) {
                        $JSON::Error = "Number cannot start with a radix";
                        return 1;
                    }

                    %radix = 1;
                    %first = 0;
                } else if (strpos("0123456789", %char) == -1) {
                    break;
                } else {
                    %first = 1;
                }

                $JSON::Index++;
            }

            if (!%first) {
                if (%radix) {
                    $JSON::Error = "Number cannot end with a radix";
                } else {
                    $JSON::Error = "Unknown token / expected number part";
                }

                return 1;
            }

            $JSON::Value = getSubStr(%string, %start,
                $JSON::Index - %start - 1);
            return 0;
    }
}

function JSON::__parseArray(%string) {
    $JSON::Error = "TODO: __parseArray";
    return 1;
}

function JSON::__parseMap(%string) {
    $JSON::Error = "TODO: __parseArray";
    return 1;
}
