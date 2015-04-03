class Acc {
    fn onNew(name) {
        this.name = name;
    }
}

static class GameManager {
    fn reset() {
        for client in ClientGroup.iter() {
            client.instantRespawn();
        }
    }
}
