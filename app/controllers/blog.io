BlogController := Iota Controller clone do (
                    index := method(
                      setVar(posts, Post top(7))
                      render(index) )

                    show := method(
                      setVar(post, Post at( params at("id") ))
                      render(show) )
                  )

BlogController View do (
  index := method(
            html(
              head( title("Tyler's Io Blog") ),
              body({style;"font-family:sans-serif"},
                h1.title("CodeHallow"),
                p( "this might be problematic..." ),
                posts map(post,
                  ( div( h2( a({href;("/post/#{post id}" interpolate)}, post title)), 
                         div(post body) ) ) ) join,
                b:id( "Thanks for stopping by." ))))

  create := method( "blah" )

  show := method( 
            html(
              head( title( post title ) ),
              body(
                h1( a({href;("/post/#{post id}" interpolate)}, post title ) ),
                p( post body ) ) ) ) )

