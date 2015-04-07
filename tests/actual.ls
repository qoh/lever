for i in 0..10 {
    echo(i);
}

(0..3).apply("echo");

fn foo {}
fn foo -> int {}
fn foo() {}
fn foo() -> int {}

test!(3, 5);
