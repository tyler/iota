Post := Iota Model setup("posts")
Post top := method(i,
  find("1=1 ORDER BY ID DESC LIMIT #{i}" interpolate) )
