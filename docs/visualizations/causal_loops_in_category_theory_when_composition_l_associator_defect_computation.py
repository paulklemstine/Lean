def assoc_defect(op, a, b, c):
    return op(op(a, b), c) - op(a, op(b, c))