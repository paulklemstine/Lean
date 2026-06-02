def check_product_free(S):
    elems = sorted(s for s in S if s >= 2)
    for i, a in enumerate(elems):
        for b in elems[i:]:
            if a*b in S:
                return False, (a, b, a*b)
    return True, None