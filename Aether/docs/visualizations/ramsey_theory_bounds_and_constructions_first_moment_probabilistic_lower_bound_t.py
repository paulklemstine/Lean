from math import comb


def first_moment_threshold(k: int, r: int = 2) -> int:
    """Largest n with 2*C(n,k) < 2^C(k,r); certifies R_r(k,k) > n."""
    bound = 2 ** comb(k, r)
    n = k
    while 2 * comb(n + 1, k) < bound:
        n += 1
    return n
