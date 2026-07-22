from __future__ import annotations


def escape_capacity(targets: list[int]) -> int:
    """Total escape capacity C(s) = sum_i (s_i - 1)."""
    return sum(s - 1 for s in targets)


def arrows(n: int, targets: list[int]) -> bool:
    """Decide whether K_n vertex-arrows (K_{s_1}, ..., K_{s_r})."""
    return escape_capacity(targets) < n


def vertex_ramsey_number(targets: list[int]) -> int:
    """Least n with K_n arrowing: N(s) = 1 + sum_i (s_i - 1)."""
    return 1 + escape_capacity(targets)
