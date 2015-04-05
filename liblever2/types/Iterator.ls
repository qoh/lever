class Iterator {
    // Core iteration methods
    fn next() -> boolean {
        return false;
    }

    fn next_back() -> boolean {
        return false;
    }

    fn supports_back() -> boolean {
        return false;
    }

    // Extension methods
    fn count() -> int {
        n = 0;
        while this.next() {
            n++;
        }
        return n;
    }

    fn map(callable func) -> MapIterator {
        return MapIterator(this, func);
    }

    fn reverse() -> ReverseIterator {
        if !this.supports_back() {
            error("ERROR: Iterator does not support reverse iteration");
            return 0;
        }

        return ReverseIterator(this);
    }
}

class MapIterator : Iterator {
    fn onNew(iter, func) {
        this.iter = iter;
        this.func = func;
    }

    fn onRemove() {
        this.iter.delete();
    }

    fn next() -> boolean {
        if this.iter.next() {
            this.value = this.func!(this.iter.value);
            return true;
        }

        return false;
    }

    fn next_back() -> boolean {
        if this.iter.next_back() {
            this.value = this.func!(this.iter.value);
            return true;
        }

        return false;
    }

    fn supports_back() -> boolean {
        return this.iter.supports_back();
    }
}

class ReverseIterator : Iterator {
    fn onNew(iter) {
        this.iter = iter;
    }

    fn onRemove() {
        if isObject(this.iter) {
            this.iter.delete();
        }
    }

    fn next() -> boolean {
        if this.iter.next_back() {
            //this.value = this.iter.value;
            this.value = this.value;
            return true;
        }

        return false;
    }

    fn next_back() -> boolean {
        if this.iter.next() {
            this.value = this.iter.value;
            return true;
        }

        return false;
    }

    fn supports_back() -> boolean {
        return true;
    }

    // Make things a bit more efficient
    fn reverse() -> ReverseIterator {
        iter = this.iter;
        this.iter = 0;
        return iter;
    }
}
