from __future__ import annotations
from typing import List, Tuple

Matrix = List[List[int]]
Divisor = Tuple[int, ...]

def dhar_q_reduced(adj: Matrix, D: List[int], q: int) -> Tuple[int, ...]:
    """Dhar's burning algorithm: return the unique q-reduced divisor linearly
    equivalent to D. A divisor is q-reduced when D(v) >= 0 for all v != q and no
    nonempty subset S of V\{q} can legally fire. The class is winnable iff the
    result has D(q) >= 0."""
    n = len(adj)
    D = list(D)

    def make_nonneg_off_q() -> None:
        # Fire the complement of {q} until no non-q vertex is in debt.
        changed = True
        while changed:
            changed = False
            for v in range(n):
                if v != q and D[v] < 0:
                    # borrow at v: pull one chip along each incident edge
                    for w in range(n):
                        for _ in range(adj[v][w]):
                            D[v] += 1
                            D[w] -= 1
                    changed = True

    make_nonneg_off_q()
    while True:
        burnt = [False] * n
        burnt[q] = True
        # burn outward: v ignites when burnt-neighbor edges exceed its chips
        changed = True
        while changed:
            changed = False
            for v in range(n):
                if not burnt[v]:
                    fire_pressure = sum(adj[v][w] for w in range(n) if burnt[w])
                    if fire_pressure > D[v]:
                        burnt[v] = True
                        changed = True
        if all(burnt):
            return tuple(D)
        # fire the unburnt set U once
        U = [v for v in range(n) if not burnt[v]]
        for v in U:
            out = sum(adj[v][w] for w in range(n) if burnt[w])
            D[v] -= out
            for w in range(n):
                if burnt[w]:
                    D[w] += adj[v][w]

def is_winnable_via_dhar(adj: Matrix, D: List[int], q: int = 0) -> bool:
    """D is winnable iff its q-reduced form is non-negative at q."""
    red = dhar_q_reduced(adj, D, q)
    return red[q] >= 0
