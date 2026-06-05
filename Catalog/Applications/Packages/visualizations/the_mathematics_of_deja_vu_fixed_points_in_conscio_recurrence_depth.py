def recurrence_depth(f, x, eps, max_iter):
    if eps <= 0: return max_iter
    curr = x
    for k in range(max_iter):
        curr = f(curr)
        if abs(curr - x) < eps: return k
    return max_iter