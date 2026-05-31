def fixed_point_delay(f, start, n):
    current = start
    for k in range(n):
        next_val = f(current)
        if current == next_val:
            return k
        current = next_val
    return None