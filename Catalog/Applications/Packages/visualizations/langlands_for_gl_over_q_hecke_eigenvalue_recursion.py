def hecke_eigenvalue_recursion(a_p, weight, p, max_power):
    coeffs = [1.0, a_p]
    pk = float(p ** (weight - 1))
    for r in range(1, max_power):
        coeffs.append(a_p * coeffs[r] - pk * coeffs[r - 1])
    return coeffs