def holographic_reconstruct_additive(boundary_data, n):
    if n == 1: return 0.0
    factors = factorize(n)
    return sum(exp * boundary_data.get(p, 0.0) for p, exp in factors.items())