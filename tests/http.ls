if $HTTPServer_DefaultConfig $= "" {
    $HTTPServer_DefaultConfig = {
        port: 8080,
        traffic_timeout: 60,
        request_timeout: 180
    };
}

class HTTPServer {
    fn onNew(config) {
        if config $= "" {
            config = {};
        }

        this.config = config;
        this.config.patch_into($HTTPServer_DefaultConfig);

        this.clients = [];

        this.socket = new TCPObject("HTTPServerTCP");
        this.socket.server = this;
        this.socket.listen(this.config["port"]);
    }

    fn onRemove {
        this.socket.delete();
        this.clients.into_iter().each(fn (cl) { cl.delete(); });
    }

    fn log(type, message) {
        echo(getDateTime() @ " [" @ type @ "] " @ message);
    }
}

class HTTPServerClient {
    fn onNew(server, address, fd) {
        this.server = server;
        this.address = address;

        this.socket = new TCPObject("HTTPServerClientTCP", fd);
        this.socket.client = this;

        this.req_prelude = false;
        this.req_headers = {};

        this.on_connect();
    }

    fn onRemove {
        this.current_headers.delete();
        this.socket.delete();
    }

    fn reset_traffic_timeout {
        cancel(this.timeout_traffic_schedule);

        this.timeout_request_schedule = this.schedule(
            this.server.config["traffic_timeout"] * 1000, "disconnect",
            "No data sent/received for " @ this.server.config["traffic_timeout"] @ " seconds");
    }

    fn reset_request_timeout {
        cancel(this.timeout_request_schedule);

        this.timeout_request_schedule = this.schedule(
            this.server.config["request_timeout"] * 1000, "disconnect",
            "No HTTP request for " @ this.server.config["request_timeout"] @ " seconds");

        this.reset_traffic_timeout();
    }

    fn disconnect(message) {
        this.socket.disconnect();
        this.on_disconnect(message);
    }

    fn send(data) {
        this.socket.send(data);
        this.server.log("data", this.address @ " <-- " @ data);
        this.reset_traffic_timeout();
    }

    fn serve_test(method, path, protocol, headers) {
        body = "<!DOCTYPE html><html lang=en-US><head></head><body>";
        body = body @ "<h3>HTTP Request (served from TGE HTTPServer 1.0)</h3>";
        body = body @ "<dl>";
        body = body @ "<dt>Request pethod</dt><dd>" @ method @ "</dd>";
        body = body @ "<dt>Full path</dt><dd>" @ path @ "</dd>";
        body = body @ "<dt>Protocol type</dt><dd>" @ protocol @ "</dd>";
        body = body @ "</dl>";
        body = body @ "<h3>Headers</h3>";
        body = body @ "<dl>";

        for key in headers.keys() {
            body = body @ "<dt>" @ key @ "</dt>";
            body = body @ "<dd>" @ (headers[key]) @ "</dd>";
        }

        body = body @ "</dl></body></html>";
        this.send_response("200 OK", {"Content-Type": "text/html"}, body);
    }

    fn serve_file(filename, content_type, headers) {
        file = new FileObject();

        if !file.openForRead(filename) {
            return false;
            file.delete();
        }

        while !file.isEOF() {
            body = body @ file.readLine() @ "\r\n";
        }

        for key in headers.keys() {
            ht = ht @ "<dt>" @ key @ "</dt>";
            ht = ht @ "<dd><code>" @ (headers[key]) @ "</code></dd>";
        }

        ht = "<dl>" @ ht @ "</dl>";

        body = strReplace(body, "${REQUEST_HEADER_DL}", ht);
        this.send_response("200 OK", {"Content-Type": content_type}, body);

        file.close();
        file.delete();
        return true;
    }

    fn process_request(method, path, protocol, headers, body) {
        // Try to serve static file
        this.server.log("request", method @ " " @ path @ " " @ protocol);

        if getSubStr(path, 0, 1) !$= "/" || strpos(path, "..") != -1 {
            this.send_error("404 Not Found");
            headers.delete();
            return;
        }

        path = "config/www" @ path;
        content_type = "text/html";

        if !this.serve_file(path, content_type, headers) {
            if getSubStr(path, strlen(path) - 1, 1) !$= "/" {
                path = path @ "/";
            }

            if !this.serve_file(path @ "index.html", content_type, headers) {
                this.send_error("404 Not Found");
            }
        }

        headers.delete();
    }

    fn send_response(status, headers, body) {
        headers["Server"] = "TGE HTTPServer 1.0";

        if !headers.exists("Content-Length") {
            headers["Content-Length"] = strlen(body);
        }

        for key in headers.keys() {
            joined = joined @ key @ ": " @ (headers[key]) @ "\r\n";
        }

        headers.delete();
        protocol = "HTTP/1.1";

        this.send(protocol @ " " @ status @ "\r\n" @ joined @ "\r\n" @ body @ "\r\n");
        this.disconnect("Response sent");
    }

    fn send_error(what) {
        this.req_prelude = false;
        this.req_headers.clear();

        this.send_response(what,
            {"Content-Type": "text/html"},
            "<h1>" @ what @ "</h1>");
    }

    fn on_connect {
        this.server.log("connect", this.address @ " connected");
        this.reset_request_timeout();
    }

    fn on_disconnect(message) {
        if message !$= "" {
            this.server.log("connect", this.address @ " disconnected: " @ message);
        } else {
            this.server.log("connect", this.address @ " disconnected");
        }
    }

    fn on_line(line) {
        this.server.log("data", this.address @ " --> " @ line);
        this.reset_traffic_timeout();

        if !this.req_prelude {
            count = getWordCount(line);

            if count < 3 {
                this.send_error("400 Bad Request");
                return;
            }

            this.req_method = getWord(line, 0);
            this.req_path = getWords(line, 1, count - 2);
            this.req_protocol = getWord(line, count - 1);
            this.req_prelude = true;
        } else {
            if line $= "" {
                this.reset_request_timeout();

                headers = this.req_headers.copy();

                this.req_prelude = false;
                this.req_headers.clear();

                this.process_request(
                    this.req_method,
                    this.req_path,
                    this.req_protocol,
                    headers,
                    ""
                );

                return;
            }

            pos = strpos(line, ": ");

            if pos < 1 {
                this.send_error("400 Bad Request");
                return;
            }

            key = getSubStr(line, 0, pos);
            value = getSubStr(line, pos + 2, strlen(line));

            this.req_headers[key] = value;
        }
    }
}

fn HTTPServerTCP::onConnectRequest(this, address, fd) {
    new class HTTPServerClient(this.server, address, fd);
}

fn HTTPServerClientTCP::onDisconnect(this) {
    this.client.on_disconnect();
}

fn HTTPServerClientTCP::onLine(this, line) {
    this.client.on_line(line);
}
