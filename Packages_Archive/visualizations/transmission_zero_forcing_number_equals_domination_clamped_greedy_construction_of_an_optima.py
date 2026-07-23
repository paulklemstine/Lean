from typing import FrozenSet


def gamma_closed_form(n: int) -> int:
    """gamma(P_n) = ceil(n/3) = (n + 2) // 3."""
    return (n + 2) // 3


def dom_construction(n: int) -> FrozenSet[int]:
    """Linear-time optimal dominating set of P_n.

    Places a guard at min(3k+1, n-1) for each k < ceil(n/3): one guard near the
    centre of each consecutive triple of vertices, with the final guard clamped
    to vertex n-1 so it never overshoots the path. Returns a set of size at most
    ceil(n/3) that provably dominates P_n."""
    if n == 0:
        return frozenset()
    return frozenset(min(3 * k + 1, n - 1) for k in range(gamma_closed_form(n)))
