Regex
Random
MD5

Object squareBrackets := method(call message argsEvaluatedIn(call sender))
Object curlyBrackets := method( 
    map := Map clone
    call message arguments foreach(
      pair, map atPut(pair name, call sender doMessage(pair last))) )

Map merge := method(new, new foreach(k, v, self atPut(k,v)) ; self)



Iota := Object clone

Iota Session := Object clone
Iota Session key := "pandas mak3 Delightful compani0ns"
Iota Session sessions := Map clone
Iota Session createSession := method(
    newKey := generateSessionId
    writeln("Creating a session, dammit!")
    sessions atPut(newKey, Map clone)
    newKey 
)
Iota Session handle_cookies := method(cookies,
  if(sessions at(cookies at("session") asString) isNil, 
    cookies atPut("session", createSession))
  cookies
)
Iota Session get := method(cookies, sessions at( cookies at("session") ) )
Iota Session generateSessionId := method( 
  m := MD5 clone 
  m appendSeq(Date asNumber asString .. Random value asString .. key) 
  m md5String
)

Iota Router := Object clone do( routes := List clone )
Iota Router route := method(path, httpMethod, controller,
    routes append({path;path, httpMethod;httpMethod, controller;controller, action;(call argAt(3))}) 
)

Iota Router scan := method(url, meth,
    cr := block(obj, obj at("path") asRegex matchesIn(url) next)
    route := routes detect(v, cr call(v) and v at("httpMethod") == meth )
    if(route isNil, return(nil))
    route params := Map clone
    md := cr call(route) 
    md names map(i, name, 
      if(name, route params atPut(name, md captures at(i))))
    route
)

Iota Router dispatch := method(request, response,
    route := scan(request resource, request httpMethod)
    if(route isNil, return(fail(request, response)))
  
    cookies := Iota Session handle_cookies(request cookies)
    session := Iota Session get(request cookies)

    controller := route at("controller") clone
    controller request := request
    controller response := response
    controller params := request params merge(route params)
    controller cookies := cookies
    controller session := session

    controller perform(route at("action"))
    handleResponse( controller )
) 

Iota Router handleResponse := method(controller,
    if(controller cookies size > 0,
      cks := controller response headers at("Set-Cookie")
      cks = if(cks isNil, list, cks)
      controller cookies foreach(k, v, cks append( "#{k}=#{v}; path=/" interpolate ))
      controller response headers atPut("Set-Cookie", cks)
    )
    Iota Session sessions atPut(controller cookies at("session"), controller session)
    controller response
)

Iota Router fail := method(request, response,
    response body = "The page you requested (#{request resource}) was not found." interpolate
    response status = 404
    response reason = "Not Found"
    response 
)



Iota Controller := Object clone
Iota Controller init := method( self viewVars := Map clone )
Iota Controller setVar := method( self viewVars atPut(call argAt(0) name, call evalArgAt(1)) )
Iota Controller redirect := method(url,
    self response status = 302
    self response reason = "Found"
    self response headers atPut("Location", url) )
Iota Controller render := method(
    view := self View clone
    viewVars foreach(k,v, view setSlot(k,v))
    self response body = view perform(call argAt(0)) )

Iota Controller View := Object clone
Iota Controller View forward := method(
    inner := ""

    np := parseTag(call message name)
    tagName := np at("tag")

    if(call hasArgs,
      res := call message argsEvaluatedIn(self)
      attrs := res detect(v, v hasProto(Map))
      inner = inner .. res remove(attrs) join)
    
    attrs := if(attrs isNil, Map clone, attrs)
    if(np at("class"), attrs atPut("class", np at("class")))
    if(np at("id"), attrs atPut("id", np at("id")))

    attrStr := ""
    if(attrs, attrs foreach(k, v, attrStr = attrStr .. " #{k}=\"#{v}\"" interpolate))

    "<#{tagName}#{attrStr}>#{inner}</#{tagName}>" interpolate )

Iota Controller View parseTag := method(name,
  rx := "[^:.]+" asRegex
  out := Map clone
  mchs := rx matchesIn(name)
  mchs all foreach(i, m,
    ss := mchs splitString at(i)
    if(ss == "",
      out atPut("tag", m),
      if(ss == ".",
        l := if(out hasKey("class"), out at("class"), "")
        if(l == "", l = m asString, l append(" " .. m asString))
        out atPut("class", l),
        out atPut("id",m)
      )
    )
  )
  out
)
Iota Controller View html := method( call message argsEvaluatedIn(self) join )


Iota Model := Object clone do(
    table := nil
    primaryKey := "id"
    connection := MySQL connect("localhost","root","","ioblog",nil,"/var/run/mysqld/mysqld.sock") )

Iota Model setup := method(table,
    model := self clone
    model table := table
    model columns := List clone
    connection query("describe #{table}" interpolate) foreach(i, col,
      model columns append(col first)
      if(col at(3) == "PRI", model primaryKey := col first)
      model setSlot(col first, method( self fields at(call message asString) ) ) )
    model )

Iota Model query_one := method(sql, query_many(sql) first)
  Iota Model query_many := method(sql,
      query(sql) map (row,
        new := self clone 
        new fields := row 
        new ) )
Iota Model query := method(sql, writeln(sql); self connection queryThenMap(sql))

Iota Model escape := method(sql, sql matchesOfRegex("([\'\"])") replaceAllWith("\\$1") )

Iota Model new := method( self clone do( fields := Map clone ) )

Iota Model insert := method(
    res := query("INSERT INTO `#{escape(self table)}` 
      (" interpolate  .. fields map(k,v,k) join(",") .. ") VALUES 
      (" .. fields map(k,v, "'#{escape(v)}'" interpolate) join(",") .. ")")
    if(res != 1, return(false))
    self fields atPut("id", connection lastInsertRowId);
    true )
Iota Model update := method( 
    query("UPDATE `#{escape(self table)}` 
      SET " interpolate .. fields map(k, v, 
      "`#{escape(k)}`='#{escape(v asString)}'" interpolate
      ) join(",") .. "
      WHERE `#{primaryKey}`='#{escape(fields at(primaryKey))}'" interpolate) == 1 )
Iota Model save := method( if( self fields at( self primaryKey ), update, insert) )

Iota Model at := method(id, 
    query_one("SELECT * 
      FROM `#{escape(self table)}` 
      WHERE 
      `#{escape(self primaryKey)}`='#{escape(id asString)}'" interpolate) )
Iota Model find := method( where, query_many("SELECT * FROM `#{escape(table)}` WHERE #{where}" interpolate) )
Iota Model all := method( query_many("SELECT * FROM `#{escape(table)}`" interpolate) )

