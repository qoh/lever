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

    // supposed to be:
    // sum = users.iter().map(u -> u["age"]).fold(0, (a, b) -> a + b);
    //sum = users.iter().map(fn(u) { return (u["age"]); }).fold(0, fn(a, b) { return a + b; });
    echo("Average age: " @ ages / users.length);

    for index, user in iter_enumerate(users.into_iter(), 1) {
        echo("User #" @ index);
        for key in user.keys() {
            echo("  " @ key @ ": " @ user[key]);
        }
        user.delete();
    }
}
