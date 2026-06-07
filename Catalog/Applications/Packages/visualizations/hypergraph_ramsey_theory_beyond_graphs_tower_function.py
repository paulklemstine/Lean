def tower(k: int, n: int) -> int:
    if k == 0:
        return n
    return 2 ** tower(k - 1, n)