from math import comb


def cubic_bound_sharp(n: int, a: int, b: int, t: int) -> int:
    """Theorem KabCopies_card_le:  C(n,3) * C(t-1,b) * C(t-1,a-3)."""
    return comb(n, 3) * comb(t - 1, b) * comb(t - 1, a - 3)


def cubic_bound_on3(n: int, a: int, b: int, t: int) -> int:
    """Theorem KabCopies_cubic_of_K3tFree:  C(t-1,b) * C(t-1,a-3) * n^3."""
    return comb(t - 1, b) * comb(t - 1, a - 3) * n ** 3


def paper_threshold(b: int) -> int:
    """tau_proved(b) = 2 * max(3, ceil(b/2)) + 1, ceil(b/2) = (b+1)//2."""
    return 2 * max(3, (b + 1) // 2) + 1


def necessary_threshold(b: int) -> int:
    """tau_nec(b) = b + 1."""
    return b + 1


def cubic_constant(a: int, b: int, t: int) -> int:
    """Leading constant C(t-1,b)*C(t-1,a-3); collapses to C(b,a-3) at t=b+1."""
    return comb(t - 1, b) * comb(t - 1, a - 3)


def threshold_report(a: int, b: int) -> dict:
    """Theorems paperThreshold_eq / threshold_gap / necessary_lt_paper_iff_odd."""
    nec = necessary_threshold(b)
    proved = paper_threshold(b)
    return {
        "b": b,
        "tau_nec": nec,
        "tau_proved": proved,
        "gap": proved - nec,                          # == b % 2 for b >= 6
        "frontier_open": nec < proved,                # == (b is odd) for b >= 6
        "constant_at_threshold": cubic_constant(a, b, nec),
    }
