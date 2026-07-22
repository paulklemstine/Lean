from __future__ import annotations

def interval_simplex_vertex_count(d: int) -> int:
    """Vertices of the interval subdivision of the (d-1)-simplex."""
    if d < 0:
        raise ValueError("d must be nonnegative")
    return 3 ** d - 2 ** d

def interval_simplex_vertex_count_bruteforce(d: int) -> int:
    """Direct enumeration: count nonempty intervals [F, G], F subset G, F nonempty,
    by assigning each of the d simplex vertices one of three states."""
    count = 0
    for code in range(3 ** d):
        x, has_F = code, False
        for _ in range(d):
            if x % 3 == 2:      # state 2 == 'in F'
                has_F = True
            x //= 3
        if has_F:
            count += 1
    return count
