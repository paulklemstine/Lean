from typing import List, Tuple

Ranking = Tuple[int, ...]
Profile = List[Ranking]


def prefers(r: Ranking, a: int, b: int) -> bool:
    return r.index(a) < r.index(b)


def is_single_peaked_at(r: Ranking, p: int, n: int) -> bool:
    """Single-peakedness at peak `p` on the axis 0 < 1 < ... < n-1:
    (1) peak is top, (2) left-monotone below p, (3) right-monotone above p."""
    if any(not prefers(r, p, a) for a in range(n) if a != p):
        return False
    for b in range(n):
        for a in range(b):
            if b <= p and not prefers(r, b, a):
                return False
    for a in range(n):
        for b in range(a + 1, n):
            if p <= a and not prefers(r, a, b):
                return False
    return True


def is_single_peaked(profile: Profile, n: int) -> bool:
    """Every voter is single-peaked at some axis position."""
    return all(any(is_single_peaked_at(r, p, n) for p in range(n)) for r in profile)
