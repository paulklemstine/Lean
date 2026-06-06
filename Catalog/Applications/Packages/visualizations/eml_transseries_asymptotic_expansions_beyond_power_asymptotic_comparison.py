def asymptotic_compare(f, g):
    h = f - g
    if not h.terms:
        return 0
    lc = h.leading_coeff()
    return -1 if lc < 0 else 1