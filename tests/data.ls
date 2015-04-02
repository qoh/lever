// not anonymous because `(a, b) => a + b` doesn't work
fn add(a, b) {
    return a + b;
}

fn data(a) {
    users = [
        { name: "Foo", age: 17 },
        { name: "Bar", age: 13, xp: 32 },
        { name: "Cat", age: 2 }
    ];

    sum = users.iter().map(u => (u["age"])).fold(0, @add);
    echo("Average age: " @ ages / users.length);

    for user in users.into_iter() {
        n = n + 1;
        echo("User #" @ n);
        for key in user.keys() {
            echo("  " @ key @ ": " @ user[key]);
        }
        user.delete();
    }
}
