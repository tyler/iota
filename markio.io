Markio := Object clone
Markio Env := Object clone


Markio makeEnv := method(params,
  env := Env clone
  params foreach(k, v, env setSlot(k, v))
  env
)

Markio Env init := method( self _out := "" asMutable )

Markio Env build := method(
  clear
  call message argsEvaluatedIn(self) join("\n")
)

Markio Env cat := method(text, _out appendSeq(text))
Markio Env clear := method(_out = "" asMutable)

Markio Env forward := method(
  parts := parseTagLine(call message name)

  attrs := if(call message argCount > 1,
    call message argAt(0) doInContext(self),
    Map clone)
            

  if(parts at(1), attrs atPut("id", parts at(1)))
  if(parts at(2), attrs atPut("class", parts at(2)))

  tag(parts at(0), attrs, call message arguments last)
)

Markio Env tag := method(name, props, children,
  attrStr := props map(k, v, "#{k}=\"#{v}\"" interpolate) join(" ")
  if(attrStr size != 0, attrStr = " " .. attrStr)

  cat("<#{name}#{attrStr}>" interpolate)
  if(children, children doInContext(self))
  cat("</#{name}>" interpolate)
)

Markio Env ctag := method(name, props
  # TODO
  # Appends a self-closing tag to _out
)

Markio Env > := method(text, cat(text))

Markio Env doctype := method(
  # TODO
  # Outputs an XHTML Transitional doctype by default, eventually
  # accepts an argument to choose between multiple
)

# Internal methods

Markio Env parseTagLine := method(line,
  rx := "[^._]+" asRegex
  mchs := rx matchesFor(line)
  mchs all foreach(i, m,
    s := m asString
    if( i == 0,
      out := list(s,nil,list()),
      if(mchs splitString at(i) == "_", 
        out atPut(1,s),
        out atPut(2, out at(2) append(s))
      )
    )
  )

  if(out at(2) size == 0,
    out atPut(2, nil),
    out atPut(2, out at(2) join(" "))
  )
  out
)

