fn data() {
    users = [
        { name: "Foo", age: 17 },
        { name: "Bar", age: 13 }
    ];

    for user in users.iter() {
        n = n + 1;
        echo("User #" @ n);
        for key in user.keys() {
            echo("  " @ key @ ": " @ user[key]);
        }
        user.delete();
    }
}
