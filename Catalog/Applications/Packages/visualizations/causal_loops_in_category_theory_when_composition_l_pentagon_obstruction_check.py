def pentagon_check(op, a, b, c, d):
    D = lambda x,y,z: assoc_defect(op, x, y, z)
    lhs = D(a,b,c) + D(a, op(b,c), d) + D(b,c,d)
    rhs = D(op(a,b), c, d) + D(a, b, op(c,d))
    return lhs - rhs