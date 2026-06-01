def refine_spectral_bounds(growth, max_n):
    exponents = [growth.growth_exponent(n) for n in range(1, max_n + 1)]
    return min(exponents), max(exponents)