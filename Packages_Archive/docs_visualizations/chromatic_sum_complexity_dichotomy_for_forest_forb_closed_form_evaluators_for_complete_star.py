from __future__ import annotations


def chromatic_sum_complete(n: int) -> int:
    """
    Closed form for the complete graph K_n: Sigma(K_n) = n(n+1)/2.

    Proper colourings of K_n are exactly the injective positive colourings, so
    the optimum uses the n smallest distinct positive integers 1..n, whose sum
    is the n-th triangular number. O(1) time.
    """
    return n * (n + 1) // 2


def chromatic_sum_star(n: int) -> int:
    """
    Closed form for the star K_{1,n} (centre + n leaves): Sigma = n + 2 (n >= 1).

    Optimal colouring: centre = 2, every leaf = 1. O(1) time.
    """
    assert n >= 1
    return n + 2


def chromatic_sum_edgeless(n: int) -> int:
    """Closed form for the edgeless graph on n vertices: Sigma = n."""
    return n
