from typing import Optional, Sequence


def hybrid_averaging_extract(a: Sequence[float], eps: float) -> Optional[int]:
    """
    Pigeonhole extraction. Given per-step advantages a[0..n-1] with n > 0 and a
    guarantee sum(a) >= eps, return an index i with a[i] >= eps / n.

    The argmax always satisfies the bound: if every a[i] < eps/n then the sum is
    strictly below n * (eps/n) = eps, contradicting the guarantee.
    """
    n = len(a)
    if n == 0:
        return None  # the principle is vacuous / false for n == 0
    i_star = max(range(n), key=lambda i: a[i])
    assert a[i_star] >= eps / n - 1e-12
    return i_star
