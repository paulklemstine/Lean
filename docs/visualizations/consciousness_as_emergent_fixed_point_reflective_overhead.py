def reflective_overhead(n):
    if n <= 1: return max(n, 0)
    return n ** (n - 1)