def check_poincare_duality(betti):
    codim = len(betti) - 1
    if codim % 2 != 0: return True
    k = codim // 2
    chi = sum((-1)**i * b for i, b in enumerate(betti))
    return chi % 2 == betti[k] % 2