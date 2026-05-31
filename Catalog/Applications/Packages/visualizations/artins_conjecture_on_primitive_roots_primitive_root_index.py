def primitive_root_index(a, p):
    ord_a = multiplicative_order(a % p, p)
    return (p - 1) // ord_a