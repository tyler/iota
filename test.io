Object ll := method(
    newList := List clone
    node := call argAt(0)
    while(node,
      newList append(node name)
      node = node next )
    newList )

l := ll(1 2 3)
writeln(l)
