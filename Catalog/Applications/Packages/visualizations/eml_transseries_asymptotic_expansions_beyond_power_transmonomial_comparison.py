def compare_transmonomials(g1, g2):
    if g1.depth != g2.depth:
        return -1 if g1.depth < g2.depth else 1
    if g1.exponent != g2.exponent:
        return -1 if g1.exponent < g2.exponent else 1
    return 0