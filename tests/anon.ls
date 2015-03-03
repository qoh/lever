fn anon() {
    vec = [1, 2, 3];

    for num in vec.iter().map(n => n*2) {
        echo(num);
    }

    vec.delete();
}

/*
    $ node main.js tests/anon.ls

    ==>exec("config/lever/tests/anon.ls.cs");
    ==>anon();
    2
    4
    6
*/
