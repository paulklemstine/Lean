from math import comb

def first_moment_threshold_holds(n: int, k: int, r: int = 3) -> bool:
    """True iff 2*C(n,k) < 2^C(k,r): the first-moment lower-bound condition.
    When True, R_r(k,k) > n is certified (a coloring with no mono k-clique exists)."""
    return 2 * comb(n, k) < 2 ** comb(k, r)

def best_probabilistic_lower_bound(k: int, r: int = 3, n_max: int = 100000) -> int:
    """Largest n with 2*C(n,k) < 2^C(k,r), i.e. the strongest certified R_r(k,k) > n."""
    best: int = k
    for n in range(k, n_max + 1):
        if first_moment_threshold_holds(n, k, r):
            best = n
        else:
            break
    return best
