AdminController  := Iota Controller clone do (
                      showLogin := method( render(showLogin) )
                      login := method(
                        if(User login(params),
                          session atPut("admin", true)
                          redirect("/admin"),
                          redirect("/login") ) )

                      control := method(
                        if(session at("admin") != true, 
                          redirect("/login"),
                          setVar(posts, Post all)
                          render(control) ) )

                      create := method(
                        if(session at ("admin") != true,
                          redirect("/login"),
                          p := Post new
                          p fields atPut("title", params at("title") )
                          p fields atPut("body", params at("body") )
                          p save
                          redirect("/admin") ) ) )

AdminController View do (
    showLogin := method(
      html(
        head( title("Login") ),
        body(
          h1( "Login" ),
          form({method;"post",action;"/login"},
            div(
              label( "Name" ),
              input({type;"text", name;"name"}) ),
            div(
              label( "Password" ),
              input({type;"text", name;"password"}) ),
            input({type;"submit"}) ) ) ) )

  control := method(
    html(
      head( title("Admin") ),
      body(
        h1( "Post" ),
        form({method;"post",action;"/admin/post"},
          div(
            label( "Title" ),
            input({type;"text", name;"title"}) ),
          div(
            label( "Body" ),
            textarea({name;"body"}) ),
          input({type;"submit"}) ) ) ) )

  )

