from math import gcd

def lcm(a: int, b: int) -> int:
    if a == 0 or b == 0:
        return 0
    return a // gcd(a, b) * b

def apparition_count(rank: int, N: int) -> int:
    """# of indices m in {1..N} with a fixed rank-`rank` primitive divisor present.

    Counting law (Theorem 6.3): equals floor(N / rank). Closed form, O(1),
    replacing enumeration; the apparition density is 1/rank.
    """
    return N // rank

def joint_apparition_count(rank_p: int, rank_q: int, N: int) -> int:
    """Joint count for two primitive divisors (Theorem 6.4): floor(N/lcm)."""
    return N // lcm(rank_p, rank_q)
