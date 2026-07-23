from math import comb

def first_moment_no_mono(n: int, r: int, k: int) -> bool:
    """True iff 2*C(n,k) < 2**C(k,r); then R_r(k,k) > n."""
    if not (r <= k <= n):
        return False
    return 2 * comb(n, k) < 2 ** comb(k, r)

def best_lower_bound(r: int, k: int, n_max: int = 50000) -> int:
    """Largest n <= n_max certified by the first moment (so R_r(k,k) >= n+1)."""
    best: int = 0
    for n in range(k, n_max + 1):
        if first_moment_no_mono(n, r, k):
            best = n
    return best