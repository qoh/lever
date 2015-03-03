fn add(a, b) {
    return a + b;
}

fn test() {
    vec = [1 + 5, 2 + 5, 3 + 2, 4 + 2, 5 + 3];

    echo("We have a Vec with " @ vec.length @ " elements");
    echo("Sum: " @ vec.fold(0, "add"));

    for i in 0..(vec.length) {
        echo("Number #" @ (i+1) @ " is " @ vec[i]);
    }

    parts = ["Hello ", "world, ", "this ", "is ", "evil "];
    
    for part in parts.iter() {
        s = s @ part;
    }

    parts.delete();
    echo(s);

    return vec;
}
