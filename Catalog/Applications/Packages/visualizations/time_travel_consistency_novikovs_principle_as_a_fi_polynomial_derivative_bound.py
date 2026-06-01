def polynomial_deriv_bound(coeffs, r):
    return sum(i * abs(a) * r**(i-1) for i, a in enumerate(coeffs) if i > 0)