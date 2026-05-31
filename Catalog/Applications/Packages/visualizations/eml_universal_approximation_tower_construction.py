def build_tower(n):
    expr = VarNode()
    for _ in range(n):
        expr = EmlOpNode(ConstNode(1.0), expr)
    return expr