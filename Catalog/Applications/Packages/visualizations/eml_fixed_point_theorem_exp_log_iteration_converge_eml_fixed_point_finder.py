def eml_fixed_point(a, b, c, x0=1.0, tol=1e-15, max_iter=10000):
    import math
    x = x0
    for i in range(max_iter):
        x_new = math.exp(a) * math.log(b * x + c)
        if abs(x_new - x) < tol:
            return x_new, i + 1
        x = x_new
    return x, max_iter