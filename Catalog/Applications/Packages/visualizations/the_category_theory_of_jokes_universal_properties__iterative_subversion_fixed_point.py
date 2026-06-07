def iterate_subversion(f, x0, tol=1e-10, max_iter=100):
    x = x0
    for _ in range(max_iter):
        x_new = f(x)
        if abs(x_new - x) < tol:
            return x_new
        x = x_new
    return x