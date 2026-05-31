def substitute(outer, inner):
    if isinstance(outer, VarNode): return inner
    if isinstance(outer, ConstNode): return ConstNode(outer.value)
    if isinstance(outer, AddNode): return AddNode(substitute(outer.left, inner), substitute(outer.right, inner))
    if isinstance(outer, MulNode): return MulNode(substitute(outer.left, inner), substitute(outer.right, inner))
    if isinstance(outer, EmlOpNode): return EmlOpNode(substitute(outer.coeff, inner), substitute(outer.exponent, inner))
    raise TypeError(f'Unknown: {type(outer)}')