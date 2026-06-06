def detect_period(orbit, tol=1e-8):
    n = len(orbit)
    start = n // 2
    tail = orbit[start:]
    for p in range(1, len(tail) // 2 + 1):
        is_periodic = all(abs(tail[i] - tail[i-p]) < tol for i in range(p, len(tail)))
        if is_periodic:
            return p
    return None