def inverse_anti_fib(k: int):
    if k <= 0 or k % 3 == 0:
        return None
    r = k % 3
    j = (k - r) // 3
    return 2 * j if r == 1 else 2 * j + 1