def bridge_certificate(p, coeffs, gens):
    n = len(gens[0])
    combo = [sum(c*g[j] for c,g in zip(coeffs,gens)) for j in range(n)]
    actual = [padic_valuation(p,x) for x in combo]
    v_c = [padic_valuation(p,c) for c in coeffs]
    bound = [min(v_c[i]+padic_valuation(p,gens[i][j]) for i in range(len(coeffs))) for j in range(n)]
    return all(a >= b for a,b in zip(actual, bound)), actual, bound