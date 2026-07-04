"""Numerical demonstrations for the generalized Honeymoon Oberwolfach problem.

This self-contained script models a single night's seating as a graph on 2n
vertices, verifies that

  * the couple map is a fixed-point-free involution,
  * every couple is an edge,
  * deleting the couples leaves exactly the prescribed round-table cycles,
  * round-table seats have degree 3 and small-table seats degree 1,

and it checks the adjacency balance law  N * sum(m_i) = 2 n (n-1)  which fixes
the number of nights N.

Seats are encoded as tuples:
  round-table seat i, residue a  -->  ("R", i, a)   with a in Z / (2 m_i)
  small-table seat  p, bit b     -->  ("S", p, b)   with b in {0, 1}
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, List, Set, Tuple

Seat = Tuple


def seats(m: List[int], s: int) -> List[Seat]:
    """All 2n seats for the profile with round tables `m` and `s` small tables."""
    out: List[Seat] = []
    for i, mi in enumerate(m):
        for a in range(2 * mi):
            out.append(("R", i, a))
    for p in range(s):
        for b in (0, 1):
            out.append(("S", p, b))
    return out


def partner(v: Seat, m: List[int]) -> Seat:
    """The spouse map: antipode on a round table, bit flip on a small table."""
    if v[0] == "R":
        _, i, a = v
        return ("R", i, (a + m[i]) % (2 * m[i]))
    _, p, b = v
    return ("S", p, 1 - b)


def edges(m: List[int], s: int) -> Set[frozenset]:
    """Undirected edge set of the one-night graph G."""
    E: Set[frozenset] = set()
    for i, mi in enumerate(m):
        n2 = 2 * mi
        for a in range(n2):
            E.add(frozenset({("R", i, a), ("R", i, (a + 1) % n2)}))  # successor
            E.add(frozenset({("R", i, a), ("R", i, (a + mi) % n2)}))  # antipode
    for p in range(s):
        E.add(frozenset({("S", p, 0), ("S", p, 1)}))  # couple edge
    return E


def couple_edges(m: List[int], s: int) -> Set[frozenset]:
    return {frozenset({v, partner(v, m)}) for v in seats(m, s)}


def degrees(m: List[int], s: int) -> Dict[Seat, int]:
    deg: Dict[Seat, int] = {v: 0 for v in seats(m, s)}
    for e in edges(m, s):
        for v in e:
            deg[v] += 1
    return deg


def cycle_lengths_of_noncouples(m: List[int], s: int) -> List[int]:
    """Lengths of the connected components of (edges minus couples)."""
    non_couple = edges(m, s) - couple_edges(m, s)
    adj: Dict[Seat, Set[Seat]] = {v: set() for v in seats(m, s)}
    for e in non_couple:
        u, w = tuple(e)
        adj[u].add(w)
        adj[w].add(u)
    seen: Set[Seat] = set()
    lengths: List[int] = []
    for v in seats(m, s):
        if v in seen or not adj[v]:
            continue
        comp, stack = 0, [v]
        while stack:
            x = stack.pop()
            if x in seen:
                continue
            seen.add(x)
            comp += 1
            stack.extend(adj[x])
        lengths.append(comp)
    return sorted(lengths)


def verify_profile(m: List[int], s: int) -> Dict[str, object]:
    n = s + sum(m)
    V = seats(m, s)
    assert len(V) == 2 * n

    # partner is a fixed-point-free involution
    involutive = all(partner(partner(v, m), m) == v for v in V)
    fixed_free = all(partner(v, m) != v for v in V)

    # every couple is an edge
    E = edges(m, s)
    couples_are_edges = couple_edges(m, s) <= E

    # deleting couples leaves the prescribed cycles
    got_cycles = cycle_lengths_of_noncouples(m, s)
    want_cycles = sorted(2 * mi for mi in m)

    # degree profile
    deg = degrees(m, s)
    round_deg_ok = all(deg[v] == 3 for v in V if v[0] == "R")
    small_deg_ok = all(deg[v] == 1 for v in V if v[0] == "S")

    return {
        "n": n,
        "num_vertices": len(V),
        "involutive": involutive,
        "fixed_point_free": fixed_free,
        "couples_are_edges": couples_are_edges,
        "noncouple_cycle_lengths": got_cycles,
        "expected_cycle_lengths": want_cycles,
        "decomposition_ok": got_cycles == want_cycles,
        "round_seats_cubic": round_deg_ok,
        "small_seats_degree_1": small_deg_ok,
        "cubic_overall": round_deg_ok and s == 0,
    }


def balance_law(m: List[int], s: int) -> Dict[str, object]:
    """Check divisibility and return the forced number of nights, if defined."""
    n = s + sum(m)
    total_pairs = 2 * n * (n - 1)
    per_night = sum(m)
    each_divides = all(total_pairs % mi == 0 for mi in m)
    sum_divides = per_night != 0 and total_pairs % per_night == 0
    nights = total_pairs // per_night if sum_divides else None
    return {
        "non_spouse_pairs": total_pairs,
        "per_night_budget_sum_m": per_night,
        "each_m_divides_2n(n-1)": each_divides,
        "sum_m_divides_2n(n-1)": sum_divides,
        "forced_number_of_nights_N": nights,
    }


def _report(title: str, m: List[int], s: int) -> None:
    print("=" * 68)
    print(title)
    print(f"  round tables of sizes {[2 * mi for mi in m]} (m = {m}), "
          f"{s} small tables")
    v = verify_profile(m, s)
    for k, val in v.items():
        print(f"    {k:26s}: {val}")
    b = balance_law(m, s)
    for k, val in b.items():
        print(f"    {k:26s}: {val}")


if __name__ == "__main__":
    # A pure cubic instance (s = 0): two round tables, sizes 4 and 6.
    _report("Example 1 - cubic, two round tables (m = [2, 3], s = 0)",
            m=[2, 3], s=0)

    # A mixed instance with small tables.
    _report("Example 2 - mixed (m = [2, 2], s = 2)", m=[2, 2], s=2)

    # A larger single-table instance.
    _report("Example 3 - single big round table (m = [6], s = 0)",
            m=[6], s=0)

    # An instance where the divisibility conditions are satisfied.
    _report("Example 4 - three round tables (m = [2, 3, 4], s = 1)",
            m=[2, 3, 4], s=1)

    print("=" * 68)
    print("All structural invariants verified for the examples above.")
