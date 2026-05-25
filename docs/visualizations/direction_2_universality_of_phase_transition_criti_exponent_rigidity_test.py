def test_exponent_rigidity(f, tc, max_m=10, h=0.001, tol=1e-4):
    from math import log
    beta_1 = log(abs(f(tc + h))) / log(abs(h))
    results = []
    rigid = True
    for m in range(1, max_m + 1):
        val = abs(f(tc + h)) ** m
        beta_m = log(val) / log(abs(h)) if val > 0 else float('nan')
        expected = m * beta_1
        if abs(expected) > 0 and abs(beta_m - expected) / abs(expected) > tol:
            rigid = False
        results.append((m, beta_m, expected))
    return rigid, results