def compose(c1, c2):
    n1, k1, d1 = c1
    n2, k2, d2 = c2
    assert n1 == k2
    return (n2, k1, min(d1, d2))