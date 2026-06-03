def find_roots(coeffs, x_min=-1000, x_max=1000):
    roots = []
    prev = trop_eval(coeffs, x_min+1) - trop_eval(coeffs, x_min)
    for x in range(x_min+1, x_max):
        curr = trop_eval(coeffs, x+1) - trop_eval(coeffs, x)
        if curr < prev - 1e-10:
            roots.append((x, prev - curr))
        prev = curr
    return roots