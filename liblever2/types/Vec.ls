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

    fn push_all(Iterator iter) {
        for value in iter {
            `%this.value[%this.length] = %value`;
            this.length++;
        }
    }

    fn pop() {
        if this.length == 0 {
            return "";
        }

        value = `%this.value[%this.length--]`;
        `%this.value[%this.length] = ""`;
        return value;
    }

    fn map(callable func) {
        for i in 0..this.length {
            value = func!(`%this.value[%i]`);
            `%this.value[%i] = %value`;
        }
    }
}
