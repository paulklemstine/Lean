from math import gcd

def lcm(a: int, b: int) -> int:
    return a // gcd(a, b) * b if a and b else 0

def fib_rank(m: int) -> int:
    if m == 1:
        return 1
    a, b, k = 0, 1, 0
    while True:
        a, b = b, (a + b) % m
        k += 1
        if a == 0:
            return k

def rank_of_lcm(a: int, b: int) -> int:
    """Compute rank(lcm(a,b)) using the join law
       rank(lcm(a,b)) = lcm(rank(a), rank(b)),  for a,b >= 1.
    This avoids ever forming F_{lcm(a,b)} directly."""
    return lcm(fib_rank(a), fib_rank(b))
