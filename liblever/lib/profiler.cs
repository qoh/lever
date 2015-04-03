if ($PROFILER_STACK $= "") {
    $PROFILER_STACK = 0;
}

function PROFILER_ENTER(%name) {
    $PROFILER_STACK_NAME[$PROFILER_STACK] = %name;
    $PROFILER_STACK_TIME[$PROFILER_STACK] = getRealTime();
    $PROFILER_STACK++;
}

function PROFILER_LEAVE() {
    if ($PROFILER_STACK) {
        $PROFILER_STACK--;

        %time = getRealTime() - $PROFILER_STACK_TIME[$PROFILER_STACK];
        %name = $PROFILER_STACK_NAME[$PROFILER_STACK];

        $PROFILER_STACK_NAME[$PROFILER_STACK] = "";
        $PROFILER_STACK_TIME[$PROFILER_STACK] = "";

        if ($PROFILER_STACK) {
            $PROFILER_STACK_TIME[$PROFILER_STACK - 1] += %time;
        }

        $PROFILER_TOTAL[%name] += %time;
    }
}
