"""
demo.py — Proof Phase Transitions III: Monotonicity & Barriers for
Multi-Premise (Hypergraph) Implicational Theories.

Self-contained numerical companion to the formalized results. Every function is
inlined; the only dependency is the Python standard library.

The code mirrors the formal objects:

    * ImplTheory       : a binary relation on atoms (single-conclusion axioms a -> b)
    * Derivable        : reflexive-transitive closure (graph reachability)
    * HyperTheory      : a set of multi-premise rules (premises, conclusion)
    * HDeriv           : the forward (least-fixed-point) hypergraph closure
    * barrier checks   : forward-closed cuts certifying non-derivability
    * chain theory     : the minimal-density extremal witness
    * criticality      : every chain axiom has criticality index 1
    * threshold        : empirical sharp-threshold curve for random theories

Run:  python3 demo.py
"""

from __future__ import annotations

import random
from collections import deque
from typing import Dict, FrozenSet, Iterable, List, Set, Tuple

Atom = int
Edge = Tuple[Atom, Atom]
Rule = Tuple[Tuple[Atom, ...], Atom]  # (premises, conclusion)


# ---------------------------------------------------------------------------
# 1. Single-premise model: Derivable = reachability
# ---------------------------------------------------------------------------
def derivable(edges: Set[Edge], a: Atom, b: Atom) -> bool:
    """Decide `Derivable T a b`: is there a directed path a -> ... -> b?

    Implements the reflexive-transitive closure by breadth-first search.
    Runs in O(V + E). The set of visited nodes is the *minimal forward-closed
    set containing a* (the tightest barrier of Theorem 2.5).
    """
    if a == b:
        return True
    adj: Dict[Atom, List[Atom]] = {}
    for (x, y) in edges:
        adj.setdefault(x, []).append(y)
    seen: Set[Atom] = {a}
    queue: deque[Atom] = deque([a])
    while queue:
        x = queue.popleft()
        for y in adj.get(x, ()):
            if y not in seen:
                if y == b:
                    return True
                seen.add(y)
                queue.append(y)
    return False


def forward_closure(edges: Set[Edge], sources: Iterable[Atom]) -> Set[Atom]:
    """The smallest forward-closed set containing `sources` (the canonical barrier)."""
    adj: Dict[Atom, List[Atom]] = {}
    for (x, y) in edges:
        adj.setdefault(x, []).append(y)
    seen: Set[Atom] = set(sources)
    queue: deque[Atom] = deque(seen)
    while queue:
        x = queue.popleft()
        for y in adj.get(x, ()):
            if y not in seen:
                seen.add(y)
                queue.append(y)
    return seen


def is_barrier(edges: Set[Edge], cut: Set[Atom]) -> bool:
    """Check that `cut` is forward-closed: every axiom out of `cut` lands in `cut`."""
    return all(y in cut for (x, y) in edges if x in cut)


# ---------------------------------------------------------------------------
# 2. The chain theory (minimal-density extremal witness)
# ---------------------------------------------------------------------------
def chain_edges(n: int) -> Set[Edge]:
    """The chain theory on {0,...,n}: axioms k -> k+1."""
    return {(k, k + 1) for k in range(n)}


def chain_minus(n: int, m: int) -> Set[Edge]:
    """The punctured chain with the single axiom m -> m+1 deleted."""
    return {(k, k + 1) for k in range(n) if k != m}


def chain_path(n: int) -> List[Atom]:
    """The explicit derivation 0 -> 1 -> ... -> n; length n (n+1 atoms)."""
    return list(range(n + 1))


# ---------------------------------------------------------------------------
# 3. Multi-premise (hypergraph) model: HDeriv = least fixed point
# ---------------------------------------------------------------------------
def hderiv(rules: Set[Rule], assumptions: Set[Atom]) -> Set[Atom]:
    """Compute the full hypergraph closure `HDeriv R S` as a least fixed point.

    Forward-chaining: repeatedly fire any rule all of whose premises are derived,
    until no new atom appears.
    """
    derived: Set[Atom] = set(assumptions)
    changed = True
    while changed:
        changed = False
        for (prems, concl) in rules:
            if concl not in derived and all(p in derived for p in prems):
                derived.add(concl)
                changed = True
    return derived


def hderiv_holds(rules: Set[Rule], assumptions: Set[Atom], target: Atom) -> bool:
    """`HDeriv R S target`."""
    return target in hderiv(rules, assumptions)


def is_hyper_barrier(rules: Set[Rule], cut: Set[Atom]) -> bool:
    """Theorem 3.5 hypothesis: closed under every rule whose premises lie in `cut`."""
    return all(concl in cut for (prems, concl) in rules if all(p in cut for p in prems))


def to_hyper(edges: Set[Edge]) -> Set[Rule]:
    """The single-premise embedding: each axiom a -> b becomes rule ([a], b)."""
    return {((a,), b) for (a, b) in edges}


# ---------------------------------------------------------------------------
# 4. Criticality (backbone) analysis
# ---------------------------------------------------------------------------
def critical_edges(edges: Set[Edge], a: Atom, b: Atom) -> Set[Edge]:
    """Return all axioms whose removal destroys `Derivable T a b` (the backbone)."""
    if not derivable(edges, a, b):
        return set()
    out: Set[Edge] = set()
    for e in edges:
        if not derivable(edges - {e}, a, b):
            out.add(e)
    return out


# ---------------------------------------------------------------------------
# 5. Empirical sharp-threshold experiment
# ---------------------------------------------------------------------------
def random_theory(n: int, p: float, rng: random.Random) -> Set[Edge]:
    """Random theory on n atoms: each directed edge present independently w.p. p."""
    return {
        (i, j)
        for i in range(n)
        for j in range(n)
        if i != j and rng.random() < p
    }


def empirical_reachability_prob(
    n: int, p: float, trials: int, rng: random.Random
) -> float:
    """Monte-Carlo estimate of Pr[Derivable T 0 (n-1)] for the random theory."""
    hits = 0
    for _ in range(trials):
        T = random_theory(n, p, rng)
        if derivable(T, 0, n - 1):
            hits += 1
    return hits / trials


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_chain_boundary() -> None:
    print("=" * 70)
    print("1. SHARP BOUNDARY  (Theorem 2.7):  Derivable chainT a b  <->  a <= b")
    print("=" * 70)
    n = 6
    E = chain_edges(n)
    ok = True
    for a in range(n + 1):
        for b in range(n + 1):
            if derivable(E, a, b) != (a <= b):
                ok = False
    print(f"chain on 0..{n}; checked all (a,b): derivable == (a<=b) ?  {ok}")
    print(f"  0 derives {n}? {derivable(E, 0, n)}   (forward)")
    print(f"  {n} derives 0? {derivable(E, n, 0)}   (no backward derivation)")
    print(f"  explicit path 0->...->{n}: {chain_path(n)}  (length {n})")
    print()


def demo_barrier() -> None:
    print("=" * 70)
    print("2. BARRIER METHOD  (Theorems 2.5 / 3.5):  forward-closed cut = certificate")
    print("=" * 70)
    n = 6
    E = chain_edges(n)
    cut = {k for k in range(n + 1) if k <= 3}  # downward-closed prefix {0..3}
    # remove the escaping axiom 3->4 so the cut is genuinely forward-closed
    E_blocked = E - {(3, 4)}
    print(f"cut S = {{k <= 3}} = {sorted(cut)}")
    print(f"  is S forward-closed in the punctured theory (3->4 deleted)? "
          f"{is_barrier(E_blocked, cut)}")
    print(f"  => target 5 outside S is unreachable: derivable(.,0,5) = "
          f"{derivable(E_blocked, 0, 5)}")
    print(f"  tightest barrier (forward closure of 0) in punctured theory: "
          f"{sorted(forward_closure(E_blocked, [0]))}")
    print()


def demo_criticality() -> None:
    print("=" * 70)
    print("3. CRITICALITY INDEX 1  (Theorem 2.9):  every chain axiom is critical")
    print("=" * 70)
    n = 6
    E = chain_edges(n)
    crit = critical_edges(E, 0, n)
    print(f"chain on 0..{n}; critical axioms for 0 |- {n}: {sorted(crit)}")
    print(f"  every one of the {len(E)} axioms is critical? {crit == E}")
    for m in range(n):
        broken = not derivable(chain_minus(n, m), 0, n)
        print(f"  delete {m}->{m+1}: 0 derives {n}? "
              f"{not broken}  (restorable: full chain derives {n}? "
              f"{derivable(E, 0, n)})")
    print()


def demo_hypergraph_bridge() -> None:
    print("=" * 70)
    print("4. CONSERVATIVITY  (Theorem 3.7):  HDeriv(toHyper T){a} b  <->  Derivable T a b")
    print("=" * 70)
    n = 5
    E = chain_edges(n)
    R = to_hyper(E)
    ok = all(
        hderiv_holds(R, {a}, b) == derivable(E, a, b)
        for a in range(n + 1)
        for b in range(n + 1)
    )
    print(f"single-premise hypergraph matches binary derivability on all pairs? {ok}")

    # A genuinely multi-premise rule: (a AND b) -> c
    print("\n  Genuine multi-premise example:")
    rules: Set[Rule] = {((0,), 1), ((0,), 2), ((1, 2), 3), ((3,), 4)}
    print(f"  rules = (0)->1, (0)->2, (1 & 2)->3, (3)->4")
    print(f"  HDeriv from {{0}}: {sorted(hderiv(rules, {0}))}")
    print(f"  HDeriv from {{1}}: {sorted(hderiv(rules, {1}))}  "
          f"(rule (1&2)->3 cannot fire: premise 2 missing)")
    print(f"  rule monotonicity: HDeriv subset under adding ((0,),5)? "
          f"{hderiv(rules, {0}).issubset(hderiv(rules | {((0,), 5)}, {0}))}")
    print(f"  assumption monotonicity: HDeriv({{0}}) subset HDeriv({{0,2}})? "
          f"{hderiv(rules, {0}).issubset(hderiv(rules, {0, 2}))}")
    cut = {0, 1, 2}  # closed? (1&2)->3 escapes, so NOT a barrier
    print(f"  is {{0,1,2}} a hyper-barrier? {is_hyper_barrier(rules, cut)} "
          f"(rule (1&2)->3 escapes)")
    print()


def demo_threshold() -> None:
    print("=" * 70)
    print("5. EMPIRICAL SHARP THRESHOLD (Direction 1):  Pr[Derivable T 0 (n-1)]")
    print("=" * 70)
    rng = random.Random(20240607)
    for n in (20, 40, 80):
        scale = (n / __import__("math").log(n))  # p* ~ log n / n  =>  c = p * n / log n
        print(f"\n  n = {n}   (conjectured p* ~ log n / n = "
              f"{__import__('math').log(n) / n:.4f})")
        print("    c=p*n/log n   p        Pr[0 ~> n-1]")
        for c in (0.4, 0.7, 1.0, 1.3, 1.8, 2.5):
            p = c * __import__("math").log(n) / n
            prob = empirical_reachability_prob(n, p, trials=120, rng=rng)
            bar = "#" * int(round(prob * 30))
            print(f"    {c:>4.1f}        {p:.4f}   {prob:5.2f}  {bar}")
    print("\n  The probability rises sharply through c = 1, the hallmark of a")
    print("  phase transition near p* = log n / n (the connectivity threshold).")
    print()


def main() -> None:
    demo_chain_boundary()
    demo_barrier()
    demo_criticality()
    demo_hypergraph_bridge()
    demo_threshold()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
