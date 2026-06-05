def escape_time(c, max_iter=1000):
    z = 0.0
    for n in range(1, max_iter + 1):
        z = z * z + c
        if abs(z) > 2:
            return n
    return None