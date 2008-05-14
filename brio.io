CGI

Request := Object clone do(
             raw := nil
             resource := nil
             httpVersion := nil
             httpMethod := nil
             headers := nil
             body := nil
             params := nil
             body_params := nil
             url_params := nil)

Request parse :=  method(data,
                    self raw = data

                    requestLines := data split("\n")
                    statusParts := requestLines at(0) split

                    self httpMethod = statusParts at(0)
                    self resource = statusParts at(1)
                    self httpVersion = statusParts at(2)

                    headerLines := requestLines slice(1, requestLines indexOf("") - 1)
                    self headers = headerLines map(v, v split(": "))

                    ch := headers detect(v, v first == "Cookie")
                    self cookies := if(ch,
                                      cs := ch last split("; ")
                                      cmap := Map clone
                                      cs foreach(v, 
                                           p := v split("=")
                                           cmap atPut(p first strip, p last strip) )
                                      cmap,
                                      Map clone)
                                      

                    self body = requestLines slice( headerLines size + 1 ) join("\n")
                    self body_params := Map clone
                    self body split("&") foreach(r, 
                      r = r split("=")
                      self body_params atPut(CGI decodeUrlParam(r first), CGI decodeUrlParam(r last)))
                    
                    self params := self body_params clone

                    self url_params := Map clone
                    s := self resource split("?") last 
                    if(s != self resource,
                      s split("&") foreach(r,
                        r = r split("=")
                        self url_params atPut(CGI decodeUrlParam(r first), CGI decodeUrlParam(r last))
                        self params atPut(r first, r last))) )


Response := Object clone do(
              status := 200
              reason := "OK"
              headers := nil
              body := nil
              init := method( headers = Map clone atPut("Content-Type", "text/html") ) )

Response assemble := method(
                      lines := List clone

                      lines append("HTTP/1.1 #{status} #{reason}" interpolate)
                      ah := block(k,v, lines append("#{k}: #{v}" interpolate))
                      headers foreach(k, v, 
                        if(v isKindOf(List),
                          v foreach(t, ah call(k,t)),
                          ah call(k,v)
                        )
                      )
                      lines append("")
                      lines append(body)

                      lines join("\n") )


Brio := Server clone

Brio handleSocket := method(socket, 
                socket streamReadNextChunk
                data := socket readBuffer

                response := Response clone
                request := Request clone
                request parse(data)

                writeln("Request:")
                writeln(data)

                writeln(request params asList)
                writeln(request body_params asList)
                writeln(request url_params asList)


                response = self handler call(request, response)

                writeln(response assemble)

                socket streamWrite(response assemble)
                socket close)

Brio run := method(port, handler,
                  writeln("Starting Brio on port #{port}." interpolate)
                  self setPort(port)
                  self handler := handler
                  self start)
