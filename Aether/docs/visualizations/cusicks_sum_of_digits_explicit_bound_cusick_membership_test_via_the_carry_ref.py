def s2(n: int) -> int:
    return bin(n).count("1")

def carries(t: int, n: int) -> int:
    """Carry count via the conservation identity (O(log) bit ops)."""
    return s2(t) + s2(n) - s2(n + t)

def cusick_member(t: int, n: int) -> bool:
    """Decide n in G_t = { n : s2(n) <= s2(n+t) }.

    By the reformulation this is exactly carries(t,n) <= s2(t).
    """
    return carries(t, n) <= s2(t)
