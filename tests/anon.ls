// fn anon() {
//     vec = [1, 2, 3];
//
//     vec.iter().map(n => n*2).each("echo");
//
//     vec.delete();
//
//     // =====
//     cb = () => {
//         echo("Hey! This is an anonymous function.");
//     };
//
//     ["foo", "bar"].into_iter().map(cb);
// }
//
// fn stats(who) {
//     echo("Stats triggered by " @ who.getPlayerName());
//
//     @ClientGroup.iter().each(cl => {
//         echo(cl.getPlayerName() @ " has ping " @ cl.getPing());
//     });
// }
//
// fn /stats {
//     if client.isAdmin {
//         stats(client);
//     }
//
//     for cl in @ClientGroup.iter() {
//         client.chatMessage(cl.getPlayerName() @ " has ping " @ cl.getPing());
//     }
// }

fn /start {
    if !@ClientGroup.iter().all(c => c.isReady) {
        client.chatMessage("Some players are not ready yet");
    }
}

// active package TestPac {
//     fn /MessageSent (text) {
//         parent::serverCmdMessageSent(client, text);
//         echo("What's this -> " @ text);
//     }
// }
