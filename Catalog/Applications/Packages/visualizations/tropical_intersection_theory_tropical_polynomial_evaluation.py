def trop_eval(coeffs, x):
    return min(coeffs[i] + i * x for i in range(len(coeffs)))