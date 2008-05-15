Object curlyBrackets := method(
  nm := Map clone
  call message arguments foreach(arg,
    p := arg asString split(":")
    nm atPut(p first asMessage doInContext(call sender), p last asMessage doInContext(call sender)))
  nm
)
