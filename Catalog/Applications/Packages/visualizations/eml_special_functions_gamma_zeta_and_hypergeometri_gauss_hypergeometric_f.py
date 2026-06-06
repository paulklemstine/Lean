def hypergeometric_2F1(a, b, c, z, N=200, tol=1e-15):
    result = 0; term = 1
    for n in range(N):
        result += term
        if abs(term) < tol and n > 0: break
        term *= (a + n) * (b + n) / ((c + n) * (n + 1)) * z
    return result