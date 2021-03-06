class Foo {
    fn firstTest(foo, bar) {}
    fn secondTest(spam) {}
}

class Bar : Foo {
    fn firstTest(foo, bar) {}
    fn thirdTest() {}
}

static class GameManager {
    key = "value";

    fn reset() {
        for client in ClientGroup.iter() {
            client.instantRespawn();
        }
    }
}

static class FooBar {
  fn testOne(foo, bar) {}
}

static class BarFoo : FooBar {
  fn testTwo(bar, foo) {}
}