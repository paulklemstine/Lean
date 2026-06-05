def fixed_point_iteration(a, c, x0, tol=1e-12):
    import math
    x = x0
    while True:
        x_new = math.exp(a) * math.log(x + c)
        if abs(x_new - x) < tol:
            return x_new
        x = x_new