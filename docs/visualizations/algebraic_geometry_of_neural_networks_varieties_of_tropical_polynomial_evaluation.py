def tropical_polynomial_eval(coeffs, x):
    return max(c + i * x for i, c in enumerate(coeffs))