def symbolic_derivative(node):
    if isinstance(node, ConstNode): return ConstNode(0)
    elif isinstance(node, VarNode): return ConstNode(1)
    elif isinstance(node, AddNode): return AddNode(symbolic_derivative(node.left), symbolic_derivative(node.right))
    elif isinstance(node, MulNode): return AddNode(MulNode(symbolic_derivative(node.left), node.right), MulNode(node.left, symbolic_derivative(node.right)))
    elif isinstance(node, ExpNode): return MulNode(ExpNode(node.child), symbolic_derivative(node.child))
    elif isinstance(node, LogNode): return MulNode(symbolic_derivative(node.child), ExpNode(MulNode(ConstNode(-1), LogNode(node.child))))