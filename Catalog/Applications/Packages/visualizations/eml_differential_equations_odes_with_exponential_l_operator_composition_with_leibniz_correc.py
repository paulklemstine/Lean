def compose_ops(a1, a2, a2_deriv):
    p = lambda x: a1(x) + a2(x)
    q = lambda x: a2_deriv(x) + a1(x) * a2(x)
    return p, q