"""
Viral Information Topology — numerical demonstrations.

This self-contained script instantiates the Horn-style contagion theory and
checks its central predictions on concrete networks:

  (1) Closure = Derivability  (the main theorem),
  (2) Total cascades from a singleton seed,
  (3) Compactness: every infection has a finite cause,
  (4) Synergy breaks Kuratowski additivity (K4), while simple
      (single-premise) contagion satisfies it.

A *contagion* is a set of rules, each a pair (premise, conclusion):
    rule = (frozenset of premise agents, conclusion agent).
Run with:  python demo.py
"""

from __future__ import annotations

import random
from typing import FrozenSet, Iterable, List, Optional, Set, Tuple

Agent = int
Rule = Tuple[FrozenSet[Agent], Agent]
Contagion = List[Rule]


# ----------------------------------------------------------------------
# Core operators
# ----------------------------------------------------------------------
def step_op(rules: Contagion, current: Set[Agent]) -> Set[Agent]:
    """One-step contagion operator: the 'new arrivals' from `current`.

    Returns every conclusion `v` such that some rule (P, v) has P ⊆ current.
    """
    arrivals: Set[Agent] = set()
    for premise, conclusion in rules:
        if premise <= current:
            arrivals.add(conclusion)
    return arrivals


def closure(rules: Contagion, seeds: Iterable[Agent]) -> Set[Agent]:
    """Semantic closure via forward-chaining saturation.

    Iterates T |-> T ∪ stepOp(T) from the seeds until a fixed point. On a finite
    carrier this terminates and equals the intersection of all closed supersets.
    """
    current: Set[Agent] = set(seeds)
    while True:
        nxt = current | step_op(rules, current)
        if nxt == current:
            return current
        current = nxt


def derivable_set(rules: Contagion, seeds: Iterable[Agent]) -> Set[Agent]:
    """The set of derivable agents, built bottom-up by an independent worklist.

    Mirrors the inductive definition: a seed is derivable; a conclusion is
    derivable once all its premises are derivable. Deliberately distinct from
    `closure` so their agreement is a genuine check of the main theorem.
    """
    derived: Set[Agent] = set(seeds)
    changed = True
    while changed:
        changed = False
        for premise, conclusion in rules:
            if conclusion not in derived and premise <= derived:
                derived.add(conclusion)
                changed = True
    return derived


def is_closed(rules: Contagion, seeds: Set[Agent], candidate: Set[Agent]) -> bool:
    """Check IsClosed: contains the seeds and is stable under one step."""
    return seeds <= candidate and step_op(rules, candidate) <= candidate


def extract_derivation(
    rules: Contagion, seeds: Set[Agent], target: Agent
) -> Optional[List[str]]:
    """Produce a human-readable transmission history for `target`, or None."""
    derived: Set[Agent] = set(seeds)
    fired_by: dict[Agent, Optional[Rule]] = {s: None for s in seeds}
    changed = True
    while changed:
        changed = False
        for premise, conclusion in rules:
            if conclusion not in derived and premise <= derived:
                derived.add(conclusion)
                fired_by[conclusion] = (premise, conclusion)
                changed = True
    if target not in derived:
        return None
    lines: List[str] = []

    def emit(v: Agent) -> None:
        rule = fired_by.get(v)
        if rule is None:
            lines.append(f"  {v}  (seed)")
        else:
            premise, _ = rule
            for x in sorted(premise):
                emit(x)
            lines.append(f"  {v}  <-  rule {set(premise)} -> {v}")

    emit(target)
    return lines


# ----------------------------------------------------------------------
# Demo 1 — Closure = Derivability on random contagions
# ----------------------------------------------------------------------
def random_contagion(n: int, num_rules: int, max_arity: int) -> Contagion:
    rules: Contagion = []
    for _ in range(num_rules):
        arity = random.randint(0, max_arity)
        premise = frozenset(random.sample(range(n), min(arity, n)))
        conclusion = random.randint(0, n - 1)
        rules.append((premise, conclusion))
    return rules


def demo_closure_equals_derivable(trials: int = 2000) -> None:
    print("=" * 64)
    print("DEMO 1  Closure = Derivability  (main theorem)")
    print("=" * 64)
    random.seed(1)
    for _ in range(trials):
        n = random.randint(1, 12)
        rules = random_contagion(n, random.randint(0, 20), max_arity=3)
        seeds = set(random.sample(range(n), random.randint(0, n)))
        cl = closure(rules, seeds)
        dv = derivable_set(rules, seeds)
        assert cl == dv, f"MISMATCH: {cl} vs {dv}"
        assert is_closed(rules, seeds, cl), "closure not actually closed!"
    print(f"  {trials} random contagions checked: closure == derivableSet  ✓")
    print("  (and every computed closure is genuinely closed)            ✓")
    print()


# ----------------------------------------------------------------------
# Demo 2 — Total cascade on a finite line
# ----------------------------------------------------------------------
def demo_total_cascade(n: int = 30) -> None:
    print("=" * 64)
    print("DEMO 2  Total cascade: a singleton seed infects everyone")
    print("=" * 64)
    rules: Contagion = [(frozenset({k}), k + 1) for k in range(n - 1)]
    cl = closure(rules, {0})
    print(f"  Line of {n} agents, rule k -> k+1, seed = {{0}}")
    print(f"  closure({{0}}) has size {len(cl)} (expected {n}): "
          f"{'✓' if cl == set(range(n)) else '✗'}")
    deriv = extract_derivation(rules, {0}, n - 1)
    print(f"  transmission history for agent {n - 1} (first/last shown):")
    if deriv:
        print(deriv[0])
        print("    ...")
        print(deriv[-1])
    print()


# ----------------------------------------------------------------------
# Demo 3 — Compactness: every infection has a finite cause
# ----------------------------------------------------------------------
def demo_compactness(n: int = 40) -> None:
    print("=" * 64)
    print("DEMO 3  Compactness: a finite seed subset already infects v")
    print("=" * 64)
    random.seed(7)
    # A 'wide' contagion: many seeds, finite-premise rules.
    rules: Contagion = []
    for v in range(n, 2 * n):
        premise = frozenset(random.sample(range(n), 2))
        rules.append((premise, v))
    seeds = set(range(n))
    cl = closure(rules, seeds)
    target = max(cl)
    # Find a finite (here: minimal-ish) seed subset that still infects target.
    minimal = set(seeds)
    for s in list(seeds):
        trial = minimal - {s}
        if target in closure(rules, trial):
            minimal = trial
    print(f"  full seed set size = {len(seeds)}; target agent = {target}")
    print(f"  finite seed subset of size {len(minimal)} still infects target: "
          f"{'✓' if target in closure(rules, minimal) else '✗'}")
    print(f"  witnessing subset: {sorted(minimal)}")
    print()


# ----------------------------------------------------------------------
# Demo 4 — Synergy breaks additivity (K4)
# ----------------------------------------------------------------------
def demo_synergy_breaks_additivity() -> None:
    print("=" * 64)
    print("DEMO 4  Synergy breaks Kuratowski additivity (K4)")
    print("=" * 64)
    a, b, c = 0, 1, 2

    # Synergistic contagion: c fires only when BOTH a and b are present.
    synergy: Contagion = [(frozenset({a, b}), c)]
    A, B = {a}, {b}
    cl_union = closure(synergy, A | B)
    cl_A = closure(synergy, A)
    cl_B = closure(synergy, B)
    print("  Synergy rule  {a,b} -> c :")
    print(f"    closure(A ∪ B) = {sorted(cl_union)}  (contains c)")
    print(f"    closure(A)     = {sorted(cl_A)}")
    print(f"    closure(B)     = {sorted(cl_B)}")
    print(f"    closure(A)∪closure(B) = {sorted(cl_A | cl_B)}")
    k4_fails = cl_union != (cl_A | cl_B)
    print(f"    K4 (additivity) FAILS: {'✓' if k4_fails else '✗'}")
    print()

    # Simple contagion: single-premise rules; additivity holds.
    simple: Contagion = [(frozenset({a}), c), (frozenset({b}), c)]
    cl_union = closure(simple, A | B)
    cl_A = closure(simple, A)
    cl_B = closure(simple, B)
    k4_holds = cl_union == (cl_A | cl_B)
    print("  Simple rules  {a}->c, {b}->c :")
    print(f"    closure(A ∪ B) = {sorted(cl_union)}")
    print(f"    closure(A)∪closure(B) = {sorted(cl_A | cl_B)}")
    print(f"    K4 (additivity) HOLDS: {'✓' if k4_holds else '✗'}")
    print()


if __name__ == "__main__":
    demo_closure_equals_derivable()
    demo_total_cascade()
    demo_compactness()
    demo_synergy_breaks_additivity()
    print("All demonstrations completed.")
