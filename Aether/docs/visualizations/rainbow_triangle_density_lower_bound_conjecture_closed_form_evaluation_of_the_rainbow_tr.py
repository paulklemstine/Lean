from math import comb

def truncated_sub(a: int, b: int) -> int:
    """Natural-number (truncated) subtraction max(a-b, 0)."""
    return a - b if a > b else 0

def rt_bound(n: int) -> int:
    """ceil((n-1)(n-3)/8) encoded over the naturals.

    Models the conjectured rainbow-triangle floor rtBound(n). O(1) time.
    Satisfies (n-1)(n-3) <= 8*rt_bound(n) < (n-1)(n-3)+8 (rtBound_ceil),
    rt_bound(n)==0 iff n<=3 (rtBound_zero_iff), is monotone (rtBound_mono),
    and rt_bound(n) <= C(n,3) (rtBound_le_choose).
    """
    prod: int = truncated_sub(n, 1) * truncated_sub(n, 3)
    return (prod + 7) // 8

def dominates_check(n_max: int) -> bool:
    """Verify rt_bound(n) <= C(n,3) for all 0 <= n <= n_max."""
    return all(rt_bound(n) <= comb(n, 3) for n in range(n_max + 1))
