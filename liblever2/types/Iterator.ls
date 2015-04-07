class Iterator {
    // Core iteration methods
    fn next() -> boolean {
        return false;
    }

    fn next_back() -> boolean {
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
        status, value = this.iter.next();
        if status {
            value = this.func!(value);
        }
        return status, value;
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
            this.value = (this.iter.value);
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
