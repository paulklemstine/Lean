def hypergeometric_2f1(a, b, c, z, tol=1e-15, max_terms=1000):
    total = 1.0
    term = 1.0
    for n in range(max_terms):
        term *= (a + n) * (b + n) / ((c + n) * (n + 1)) * z
        total += term
        if abs(term) < tol * abs(total):
            break
    return total