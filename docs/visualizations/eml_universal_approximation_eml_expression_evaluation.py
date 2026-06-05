def evaluate(node, x):
    if isinstance(node, ConstNode): return node.value
    elif isinstance(node, VarNode): return x
    elif isinstance(node, AddNode): return evaluate(node.left, x) + evaluate(node.right, x)
    elif isinstance(node, MulNode): return evaluate(node.left, x) * evaluate(node.right, x)
    elif isinstance(node, ExpNode): return math.exp(min(evaluate(node.child, x), 700))
    elif isinstance(node, LogNode): v = evaluate(node.child, x); return math.log(v) if v > 0 else 0.0