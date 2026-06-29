"""
Sheaf-Theoretic Data Integration: numerical demonstrations.

This self-contained script demonstrates, with concrete examples, the main
theorems of the accompanying paper:

  * Overlap-consistency as the merge criterion         (Consistent)
  * The two-table merge / JOIN                          (exists_unique_merge_two)
  * Gluing of an arbitrary cover into a unique whole     (exists_unique_glue)
  * Integrability <=> consistency                        (exists_glue_iff_consistent)
  * Connected-schema rigidity (one value -> all values)  (H0_eq_const_of_connected,
                                                          globalSections_eval_injective_of_connected)
  * The conjectured feasibility law P(sheaf) = (1-r)^C   (Monte-Carlo check)

A "database over a set of keys U" is modeled as a dict {key: value}. A "key" is
any hashable label (e.g. ("row3", "email")). Restriction is dict projection.

Run:  python demo.py
"""

from __future__ import annotations

import random
from collections import deque
from itertools import combinations
from typing import Dict, Hashable, Iterable, List, Optional, Sequence, Tuple

Key = Hashable
Value = Hashable
Record = Dict[Key, Value]


# --------------------------------------------------------------------------- #
# Section 2-3: records, restriction, and overlap-consistency
# --------------------------------------------------------------------------- #
def restrict(record: Record, keys: Iterable[Key]) -> Record:
    """Restriction of a record to a subset of keys (presheaf restriction)."""
    keyset = set(keys)
    return {k: v for k, v in record.items() if k in keyset}


def is_consistent(records: Sequence[Record]) -> bool:
    """Overlap-consistency: every pair agrees on its shared keys.

    This is the `Consistent` predicate; by `exists_glue_iff_consistent` it is
    exactly the condition for the family to admit a (unique) global merge.
    """
    for r_i, r_j in combinations(records, 2):
        for k in set(r_i) & set(r_j):
            if r_i[k] != r_j[k]:
                return False
    return True


# --------------------------------------------------------------------------- #
# Section 3-4: gluing and the two-table merge
# --------------------------------------------------------------------------- #
def glue(records: Sequence[Record]) -> Optional[Record]:
    """Glue a family of records into the unique global record over their union.

    Returns the merged record if the family is overlap-consistent (Theorem
    `exists_unique_glue`), otherwise None (no consistent integration exists).
    The construction mirrors the constructive proof: for each key pick any
    record containing it; consistency makes the choice irrelevant.
    """
    if not is_consistent(records):
        return None
    merged: Record = {}
    for r in records:
        merged.update(r)
    return merged


def merge_two(r0: Record, r1: Record) -> Optional[Record]:
    """Two-table merge (relational JOIN/UNION), `exists_unique_merge_two`."""
    return glue([r0, r1])


# --------------------------------------------------------------------------- #
# Section 5: schema graph, H0, and connected rigidity
# --------------------------------------------------------------------------- #
Graph = Dict[Hashable, List[Hashable]]


def connected_components(graph: Graph) -> List[List[Hashable]]:
    """Connected components of an undirected schema graph (BFS)."""
    seen: set = set()
    comps: List[List[Hashable]] = []
    for start in graph:
        if start in seen:
            continue
        comp: List[Hashable] = []
        q = deque([start])
        seen.add(start)
        while q:
            v = q.popleft()
            comp.append(v)
            for w in graph[v]:
                if w not in seen:
                    seen.add(w)
                    q.append(w)
        comps.append(comp)
    return comps


def is_global_section(graph: Graph, f: Dict[Hashable, Value]) -> bool:
    """Membership in H0 of the constant sheaf: f constant along every edge."""
    for v in graph:
        for w in graph[v]:
            if f[v] != f[w]:
                return False
    return True


def h0_dimension(graph: Graph) -> int:
    """dim H0(G) = number of connected components
    (`finrank_H0_eq_card_connectedComponent`)."""
    return len(connected_components(graph))


def propagate_from_vertex(graph: Graph, base: Hashable, value: Value
                          ) -> Dict[Hashable, Value]:
    """Connected rigidity: on a connected graph a global section is determined
    by its value at one vertex (`globalSections_eval_injective_of_connected`).
    Propagates `value` to the whole component of `base`."""
    f: Dict[Hashable, Value] = {}
    q = deque([base])
    f[base] = value
    while q:
        v = q.popleft()
        for w in graph[v]:
            if w not in f:
                f[w] = value
                q.append(w)
    return f


# --------------------------------------------------------------------------- #
# Section 6: Monte-Carlo check of P(sheaf) = (1-r)^C
# --------------------------------------------------------------------------- #
def empirical_feasibility(num_constraints: int, missing_rate: float,
                          trials: int = 100_000, seed: int = 0) -> float:
    """Estimate the probability that all `num_constraints` independent overlap
    constraints survive (each present w.p. 1-r). The feasibility law predicts
    this equals (1-r)^num_constraints."""
    rng = random.Random(seed)
    survived = 0
    for _ in range(trials):
        if all(rng.random() >= missing_rate for _ in range(num_constraints)):
            survived += 1
    return survived / trials


def predicted_feasibility(num_constraints: int, missing_rate: float) -> float:
    """P(sheaf) = (1-r)^C."""
    return (1.0 - missing_rate) ** num_constraints


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_two_table_merge() -> None:
    print("=" * 70)
    print("DEMO 1  Two-table merge (exists_unique_merge_two)")
    print("=" * 70)
    emails: Record = {("alice", "email"): "a@x.com",
                      ("bob", "email"): "b@x.com"}
    phones: Record = {("bob", "phone"): "555-2",
                      ("carol", "phone"): "555-3"}
    merged = merge_two(emails, phones)
    print("  emails :", emails)
    print("  phones :", phones)
    print("  shared keys:", set(emails) & set(phones), "(disjoint -> consistent)")
    print("  MERGE  :", merged)

    # A conflicting overlap: same key, different values -> no merge.
    t0: Record = {("bob", "email"): "b@x.com"}
    t1: Record = {("bob", "email"): "b@OTHER.com"}
    print("  conflicting tables on ('bob','email'):", merge_two(t0, t1),
          "(None = no consistent integration)")
    print()


def demo_cover_gluing() -> None:
    print("=" * 70)
    print("DEMO 2  Gluing an arbitrary cover (exists_unique_glue)")
    print("=" * 70)
    a: Record = {1: "x", 2: "y"}
    b: Record = {2: "y", 3: "z"}
    c: Record = {3: "z", 4: "w"}
    print("  cover pieces:", a, b, c)
    print("  consistent?", is_consistent([a, b, c]))
    g = glue([a, b, c])
    print("  unique glue:", g)
    # Verify the universal property: restrictions reproduce the pieces.
    ok = all(restrict(g, piece.keys()) == piece for piece in (a, b, c))
    print("  restrictions reproduce each piece:", ok)
    print()


def demo_integrability_iff_consistency() -> None:
    print("=" * 70)
    print("DEMO 3  Integrability <=> consistency (exists_glue_iff_consistent)")
    print("=" * 70)
    good = [{1: "a", 2: "b"}, {2: "b", 3: "c"}]
    bad = [{1: "a", 2: "b"}, {2: "DIFFERENT", 3: "c"}]
    for name, fam in (("consistent", good), ("inconsistent", bad)):
        cons = is_consistent(fam)
        glued = glue(fam)
        print(f"  {name:12s}: consistent={cons}, "
              f"glue exists={glued is not None}  (must match)")
    print()


def demo_connected_rigidity() -> None:
    print("=" * 70)
    print("DEMO 4  Connected rigidity (H0_eq_const_of_connected)")
    print("=" * 70)
    connected: Graph = {"A": ["B"], "B": ["A", "C"], "C": ["B", "D"], "D": ["C"]}
    disconnected: Graph = {"A": ["B"], "B": ["A"], "C": ["D"], "D": ["C"]}
    print("  connected schema   : dim H0 =", h0_dimension(connected),
          "(one shared value forced)")
    f = propagate_from_vertex(connected, "A", 42)
    print("    set A=42 -> whole DB:", f, "is_section:",
          is_global_section(connected, f))
    print("  disconnected schema: dim H0 =", h0_dimension(disconnected),
          "(islands carry independent values)")
    print()


def demo_feasibility_law() -> None:
    print("=" * 70)
    print("DEMO 5  Feasibility law  P(sheaf) = (1-r)^C")
    print("=" * 70)
    print(f"  {'C':>3} {'r':>5} {'predicted':>12} {'empirical':>12}")
    for C in (1, 4, 10):
        for r in (0.1, 0.3):
            pred = predicted_feasibility(C, r)
            emp = empirical_feasibility(C, r, trials=40_000, seed=C * 100 + int(r * 10))
            print(f"  {C:>3} {r:>5.2f} {pred:>12.5f} {emp:>12.5f}")
    print("  -> exponential decay in the number of overlap constraints C")
    print()


def main() -> None:
    demo_two_table_merge()
    demo_cover_gluing()
    demo_integrability_iff_consistency()
    demo_connected_rigidity()
    demo_feasibility_law()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
