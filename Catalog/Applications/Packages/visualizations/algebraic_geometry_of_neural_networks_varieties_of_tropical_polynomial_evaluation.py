def tropical_polynomial_eval(slopes, intercepts, x):
    return max(s * x + b for s, b in zip(slopes, intercepts))