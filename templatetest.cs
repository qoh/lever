function ____tod_template_24(%_d) {
  %_r=%_r@"<!DOCTYPE html>\r\n<html lang=\"en-US\">\r\n  <head>\r\n    <title>Hello</title>\r\n    <link rel=\"stylesheet\" href=\"https://cdnjs.cloudflare.com/ajax/libs/materialize/0.95.3/css/materialize.min.css\">\r\n    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no\">\r\n  </head>\r\n  <body>\r\n    <nav>\r\n      <div class=\"nav-wrapper\">\r\n        <div class=\"container\">\r\n          <a href=\"#\" class=\"brand-logo\">TGE HTTPServer</a>\r\n          <span class=\"right\">Version 0.0.1</span>\r\n        </div>\r\n      </div>\r\n    </nav>\r\n\r\n    <div class=\"container\">\r\n      <h1>Hey there</h1>\r\n      <p>This page is served from Blockland but the server isn\'t written in TorqueScript.</p>\r\n      <p>\r\n        <a class=\"waves-effect waves-light btn modal-trigger\" href=\"#modal1\">See request data</a><br>\r\n        <a class=\"waves-effect waves-light btn modal-trigger\" href=\"#modal2\">See server data</a>\r\n      </p>\r\n      <p><a class=\"waves-effect waves-light btn\" href=\"/raw\">Raw template</a></p>\r\n    </div>\r\n\r\n    <div id=\"modal1\" class=\"modal\">\r\n      <div class=\"modal-content\">\r\n        <h4>Request data</h4>\r\n        <dl>\r\n          <dt>Request method</dt>\r\n          <dd><code>";
  %_r=%_r@____tod_escape(%_d.method);
  %_r=%_r@"</code></dd>\r\n          <dt>Full path</dt>\r\n          <dd><code>";
  %_r=%_r@____tod_escape(%_d.path);
  %_r=%_r@"</code></dd>\r\n          <dt>Protocol version</dt>\r\n          <dd><code>";
  %_r=%_r@____tod_escape(%_d.protocol);
  %_r=%_r@"</code></dd>\r\n        </dl>\r\n        <h5>Headers</h5>\r\n        <!-- This is ugly - haven\'t added foreach keyword yet -->\r\n        <dl>\r\n        ";
  %_i0=%_d.headers.keys()while(iter_next(%_i0)){%key=$iter_value[%_i0];
  %_r=%_r@"\r\n          <dt>";
  %_r=%_r@____tod_escape(%key);
  %_r=%_r@"</dt>\r\n          <dd><code>";
  %_r=%_r@____tod_escape(%_d.headers.get(%key));
  %_r=%_r@"</code></dd>\r\n        ";
  }iter_drop(%_i0)
  %_r=%_r@"\r\n        <!-- ";
  for(%i = 0; %i < %_d.headers.keys.length; %i++){
  %_r=%_r@"\r\n          <dt>";
  %_r=%_r@____tod_escape(%_d.headers.keys.value[%i]);
  %_r=%_r@"</dt>\r\n          <dd><code>";
  %_r=%_r@____tod_escape(%_d.headers.value[sha1(%_d.headers.keys.value[%i])]);
  %_r=%_r@"</code></dd>\r\n        ";
  }
  %_r=%_r@" -->\r\n        </dl>\r\n      </div>\r\n      <div class=\"modal-footer\">\r\n        <a href=\"#\" class=\"waves-effect waves-green btn-flat modal-action modal-close\">Dismiss</a>\r\n      </div>\r\n    </div>\r\n\r\n    <div id=\"modal2\" class=\"modal\">\r\n      <div class=\"modal-content\">\r\n        <h4>Server data</h4>\r\n        <dl>\r\n          <dt>Blockland version</dt>\r\n          <dd>v";
  %_r=%_r@____tod_escape($version);
  %_r=%_r@"r";
  %_r=%_r@____tod_escape(getWord(MM_Version.getValue(), 1));
  %_r=%_r@"</dd>\r\n          <dt>Engine time</dt>\r\n          <dd>";
  %_r=%_r@____tod_escape(getSimTime());
  %_r=%_r@"</dd>\r\n          <dt>Real time</dt>\r\n          <dd>";
  %_r=%_r@____tod_escape(getRealTime());
  %_r=%_r@"</dd>\r\n        </dl>\r\n      </div>\r\n      <div class=\"modal-footer\">\r\n        <a href=\"#\" class=\"waves-effect waves-green btn-flat modal-action modal-close\">Dismiss</a>\r\n      </div>\r\n    </div>\r\n\r\n    <script src=\"https://code.jquery.com/jquery-2.1.1.min.js\"></script>\r\n    <script src=\"https://cdnjs.cloudflare.com/ajax/libs/materialize/0.95.3/js/materialize.min.js\"></script>\r\n\r\n    <script>\r\n    $(document).ready(function(){\r\n      $(\'.modal-trigger\').leanModal();\r\n    });\r\n    </script>\r\n  </body>\r\n</html>\r\n";

  return %_r;
}
