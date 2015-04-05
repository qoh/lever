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
}
