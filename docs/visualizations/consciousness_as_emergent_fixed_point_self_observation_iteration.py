def iterate_self_observation(observe, x0, max_iter=100):
    x = x0
    for i in range(1, max_iter + 1):
        x_new = observe(x)
        if x_new == x:
            return x_new, i
        x = x_new
    return x, max_iter