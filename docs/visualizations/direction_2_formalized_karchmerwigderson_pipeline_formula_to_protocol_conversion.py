def formula_to_protocol(F):
    if F.type == VAR: return Leaf(F.index)
    elif F.type == AND: return BobNode(F.left.eval, convert(F.left), convert(F.right))
    else: return AliceNode(lambda x: not F.left.eval(x), convert(F.left), convert(F.right))