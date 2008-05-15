#!/usr/bin/env io

Regex

doFile("vendor/iota/iota.io")

doFile("app/controllers/blog.io")
doFile("app/controllers/admin.io")

doFile("app/models/user.io")
doFile("app/models/post.io")

doFile("config/routes.io")

doFile("vendor/iota/brio.io")

Brio run( 2013, block(request, response, Iota Router dispatch (request,response) ) )

