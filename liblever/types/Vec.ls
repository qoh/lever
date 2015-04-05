class Vec {
    fn onAdd() {
        this.length = 0;
    }

    fn clear() {
        for i in 0..this.length {
            `%this.value[%i] = ""`;
        }
        this.length = 0;
    }

    fn push(value) {
        `%this.value[%this.length] = %value`;
        this.length++;
    }

    fn map(func) {
        for i in 0..this.length {
            value = func!(`%this.value[%i]`);
            `%this.value[%i] = %value`;
        }
    }

    // Return type test
    fn any(callable predicate) -> boolean {
        for i in 0..this.length {
            `%value = %this.value[%i]`;
            if predicate!(value) {
                return true;
            }
        }
        return false;
    }
}
