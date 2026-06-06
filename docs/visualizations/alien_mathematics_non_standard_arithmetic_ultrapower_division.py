def ultrapower_division(f, g):
    q = lambda i: f(i) // g(i) if g(i) > 0 else 0
    r = lambda i: f(i) % g(i) if g(i) > 0 else f(i)
    return q, r