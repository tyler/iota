Iota Router do(
  route("/login", "GET", AdminController, showLogin)
  route("/login", "POST", AdminController, login)
  route("/admin", "GET", AdminController, control)
  route("/admin/post", "POST", AdminController, create)

  route("^/$", "GET", BlogController, index)
  route("^/post/(?<id>\\d+)$", "GET", BlogController, show)
)
