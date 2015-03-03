class Acc {
    fn onNew(name, age, xp) {
        this.name = name;
        this.age = age;
        this.xp = xp;
    }

    fn getLevel {
        return 1 + mFloor(this.xp / 50);
    }
}

fn test {
    players = [
        Acc("Foo", 17,  390),
        Acc("Bar", 13, 2964),
        Acc("Cat",  2,    0)
    ];

    for player in players.into_iter() {
        echo(player.name @ " is level " @ player.getLevel());
        player.delete();
    }
}
