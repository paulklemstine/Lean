def collatz_hash(a: int, m: int, n: int) -> int:
    return collatz_owf(a, n) % m