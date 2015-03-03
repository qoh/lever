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

/*
    $ node main.js tests/vec.ls

    ==>exec("config/lever/tests/vec.ls.cs");
    ==>$v = test();
    We have a Vec with 5 elements
    Sum: 32
    Number #1 is 6
    Number #2 is 7
    Number #3 is 5
    Number #4 is 6
    Number #5 is 8
    ==>function double(%n) { return %n*2; }
    ==>echo($v.iter().map("double").first());
    12
*/
