def activation_pattern(W, b, x):
    return tuple(a > 0 for a in W @ x + b)