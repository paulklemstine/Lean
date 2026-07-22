from __future__ import annotations


def gl_order(n: int, q: int = 2) -> int:
    """Exact order |GL(n,q)| = prod_{i=0}^{n-1} (q^n - q^i)."""
    order: int = 1
    for i in range(n):
        order *= q**n - q**i
    return order
