fn for_opt_test() {
    for i=0; i<5; i++ {
        echo(i);
    }
    
    // This shouldn't use the iterator protocol
    for i in 0..9 {
        echo(i);
    }

    for i in 0...9 { // inclusive should use <=
        echo(i);
    }

    for item in test.iter() { // normal iters should be as they usually are
        echo(item);

        if item == "foo" {
            return;
        } else if item == "bar" {
            return "return test";
        }
    }
}
