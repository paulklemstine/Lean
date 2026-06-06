def kleene_iterate(f, bot=0.0, tol=1e-12, max_iter=10000):
    x = bot
    for i in range(max_iter):
        x_new = f(x)
        if abs(x_new - x) < tol:
            return x_new, i+1
        x = x_new
    return x, max_iter