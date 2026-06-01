def fixed_point_iteration(f, x0, K, epsilon=1e-10, max_iter=10000):
    x = x0
    for i in range(max_iter):
        fx = f(x)
        if abs(x - fx) < epsilon:
            return fx, i + 1, abs(x - fx)
        x = fx
    return x, max_iter, abs(x - f(x))