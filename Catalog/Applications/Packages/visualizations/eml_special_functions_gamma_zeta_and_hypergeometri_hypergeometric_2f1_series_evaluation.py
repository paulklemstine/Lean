def hypergeometric_2F1(a, b, c, z, tol=1e-15, max_terms=500):
    total, term = 0.0, 1.0
    for n in range(max_terms):
        total += term
        if abs(term) < tol * abs(total) and n > 0: break
        term *= (a + n) * (b + n) / ((c + n) * (n + 1)) * z
    return total