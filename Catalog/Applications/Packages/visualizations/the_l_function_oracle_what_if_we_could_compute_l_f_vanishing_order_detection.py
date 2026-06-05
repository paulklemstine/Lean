def detect_vanishing_order(oracle, max_depth=100, tol=1e-12):
    for n in range(max_depth):
        if abs(oracle(n)) > tol:
            return n
    return max_depth