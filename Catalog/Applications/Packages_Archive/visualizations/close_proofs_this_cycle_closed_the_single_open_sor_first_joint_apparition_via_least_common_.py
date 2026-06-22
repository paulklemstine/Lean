from math import gcd

def lcm(a: int, b: int) -> int:
    if a == 0 or b == 0:
        return 0
    return a // gcd(a, b) * b

def first_joint_apparition(rank_p: int, rank_q: int) -> int:
    """First index n at which two primitive divisors (ranks rank_p, rank_q)
    simultaneously divide u(n).

    Join law (Theorem 6.1): both divide u(n) iff lcm(rank_p, rank_q) | n, so the
    earliest such n is exactly lcm(rank_p, rank_q). O(log) via Euclid's algorithm.
    """
    return lcm(rank_p, rank_q)
