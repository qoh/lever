fn add(a, b) {
    return a + b;
}

fn test() {
    echo("This is a test!");
    vec = [1 + 5, 2 + 5, 3 + 2, 4 + 2, 5 + 3];
    echo("We have a Vec with " @ vec.length @ " elements");

    echo("Sum: " @ vec.fold(0, "add"));

    for i in 0..(vec.length) {
        echo("Number #" @ (i+1) @ " is " @ vec[i]);
    }

    return vec;
}

/*
    $ node main.js tests/vec.ls

    ==>exec("config/lever/tests/vec.ls.cs");
    ==>$v = test();
    This is a test!
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
