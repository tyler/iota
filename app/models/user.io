SHA1

User := Iota Model setup("users")
User login := method(params,
    name := params at ("name")
    writeln("name")
    s := SHA1 clone
    s appendSeq( params at ("password") .. "pandas" )
    pw := s sha1String
    if( find("name='#{name}' AND password='#{pw}'" interpolate) size > 0, true, false ) )
