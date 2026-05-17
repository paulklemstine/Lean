def artin_map(a: int, n: int) -> int:
    from math import gcd
    assert gcd(a, n) == 1
    return a % n