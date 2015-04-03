if (%type $= "") {
    %type = $TypeMarker::type[%data];

    if (%type $= "float" || %type $= "integer") {
        %type = "number";
    }
}

%data = $TypeMarker::data[%data];

if ($TypeMarker::nextId $= "") {
    $TypeMarker::nextId = 0;
}

function TypeMarker(%type, %data) {
    %id = ($TypeMarker::nextId = ($TypeMarker::nextId + 1) | 0);
    $TypeMarker::type[%id] = %type;
    $TypeMarker::data[%id] = %data;
    return "\x02" @ %id;
}

function TypeMarker::drop(%n) {
    $TypeMarker::type[%n] = "";
    $TypeMarker::data[%n] = "";
}

function TypeMarker::test(%n) {
    return getSubStr(%n, 0, 1) $= "\x02" && isInteger(getSubStr(%n, 1, strlen(%n)));
}
