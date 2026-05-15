def rectangle_bound(W, R, n):
    """Evaluate cycle-systolic rectangle bound."""
    g = int(W.min())
    return g * (R // n)