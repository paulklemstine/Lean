def s2(n: int) -> int:
    """Binary sum-of-digits."""
    return bin(n).count("1")


def carries(t: int, n: int) -> int:
    """Number of carries when adding n and t in base 2.

    By Kummer's theorem the carry count equals v2(C(n+t, t)); the additive
    identity s2(n+t) + carries = s2(n) + s2(t) lets us compute it from three
    digit sums in O(log(n+t)), with no factorial or binomial arithmetic.
    """
    return s2(t) + s2(n) - s2(n + t)


def cusick_holds(t: int, n: int) -> bool:
    """P_t(n): adding t does not decrease the digit sum.

    Equivalent (Kummer reformulation) to carries(t, n) <= s2(t).
    """
    return carries(t, n) <= s2(t)
