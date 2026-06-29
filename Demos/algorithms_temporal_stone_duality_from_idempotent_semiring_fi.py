#!/usr/bin/env python3
"""
Algorithms for Temporal Stone Duality

Implements the core algorithms derived from the theorems:
1. Greatest fixpoint computation via Kleene iteration
2. Model checking for the □-fragment
3. Behavioral equivalence computation via dual points
4. Definable predicate lattice construction
"""

from typing import Dict, List, Set, FrozenSet, Tuple, Optional
from dataclasses import dataclass
from itertools import combinations


@dataclass
class FiniteTransitionSystem:
    """A finite labeled transition system.

    Attributes:
        states: list of state names
        transitions: successor function s → {successors}
        labels: valuation function: proposition → {states where it holds}
    """
    states: List[str]
    transitions: Dict[str, Set[str]]
    labels: Dict[str, Set[str]]

    @property
    def n_states(self) -> int:
        return len(self.states)


def box_operator(fts: FiniteTransitionSystem, X: Set[str]) -> Set[str]:
    """Universal predecessor: □X = {s | ∀t. s→t ⟹ t∈X}.

    Time complexity: O(|S| · max_outdegree)
    Space complexity: O(|S|)
    """
    return {s for s in fts.states if fts.transitions[s].issubset(X)}


def diamond_operator(fts: FiniteTransitionSystem, X: Set[str]) -> Set[str]:
    """Existential predecessor: ◇X = {s | ∃t. s→t ∧ t∈X}.

    Time complexity: O(|S| · max_outdegree)
    Space complexity: O(|S|)
    """
    return {s for s in fts.states if fts.transitions[s] & X}


def greatest_fixpoint(fts: FiniteTransitionSystem, P: Set[str]) -> Tuple[Set[str], int]:
    """Compute the greatest fixpoint of the safety operator F(X) = P ∩ □X.

    This is the set of states from which all reachable states remain in P.

    Algorithm: Descending Kleene iteration starting from P.
    - Guaranteed to terminate in at most |S| steps (finite_gfp_stabilizes).
    - Each iteration removes states that can reach outside P.

    Time complexity: O(|S|² · max_outdegree)
    Space complexity: O(|S|)

    Returns: (fixpoint set, number of iterations)
    """
    current = P.copy()
    iterations = 0
    while True:
        next_set = P & box_operator(fts, current)
        iterations += 1
        if next_set == current:
            return current, iterations
        current = next_set


def model_check_safety(fts: FiniteTransitionSystem, prop: str, state: str) -> bool:
    """Check if a state satisfies the safety property 'always prop'.

    Uses greatest fixpoint computation (Theorem C).

    Time complexity: O(|S|² · max_outdegree)

    Args:
        fts: the transition system
        prop: name of the atomic proposition
        state: the state to check

    Returns:
        True iff from state, all reachable states satisfy prop
    """
    P = fts.labels.get(prop, set())
    gfp, _ = greatest_fixpoint(fts, P)
    return state in gfp


# ──────────────────────────────────────────────────────────────────
# Temporal Formula Language
# ──────────────────────────────────────────────────────────────────

class TFormula:
    """Base class for temporal formulas."""
    pass

class TAtom(TFormula):
    def __init__(self, name: str): self.name = name
    def __repr__(self): return self.name
    def __eq__(self, o): return isinstance(o, TAtom) and self.name == o.name
    def __hash__(self): return hash(("a", self.name))

class TTop(TFormula):
    def __repr__(self): return "⊤"
    def __eq__(self, o): return isinstance(o, TTop)
    def __hash__(self): return hash("T")

class TBot(TFormula):
    def __repr__(self): return "⊥"
    def __eq__(self, o): return isinstance(o, TBot)
    def __hash__(self): return hash("B")

class TNeg(TFormula):
    def __init__(self, f): self.f = f
    def __repr__(self): return f"¬{self.f}"
    def __eq__(self, o): return isinstance(o, TNeg) and self.f == o.f
    def __hash__(self): return hash(("n", self.f))

class TConj(TFormula):
    def __init__(self, l, r): self.l, self.r = l, r
    def __repr__(self): return f"({self.l}∧{self.r})"
    def __eq__(self, o): return isinstance(o, TConj) and self.l == o.l and self.r == o.r
    def __hash__(self): return hash(("c", self.l, self.r))

class TDisj(TFormula):
    def __init__(self, l, r): self.l, self.r = l, r
    def __repr__(self): return f"({self.l}∨{self.r})"
    def __eq__(self, o): return isinstance(o, TDisj) and self.l == o.l and self.r == o.r
    def __hash__(self): return hash(("d", self.l, self.r))

class TBox(TFormula):
    def __init__(self, f): self.f = f
    def __repr__(self): return f"□{self.f}"
    def __eq__(self, o): return isinstance(o, TBox) and self.f == o.f
    def __hash__(self): return hash(("b", self.f))

class TDiamond(TFormula):
    def __init__(self, f): self.f = f
    def __repr__(self): return f"◇{self.f}"
    def __eq__(self, o): return isinstance(o, TDiamond) and self.f == o.f
    def __hash__(self): return hash(("m", self.f))


def evaluate(fts: FiniteTransitionSystem, state: str, phi: TFormula) -> bool:
    """Evaluate formula satisfaction: fts, state ⊨ φ.

    Time complexity: O(|φ| · |S| · max_outdegree) in the worst case.
    """
    if isinstance(phi, TAtom):
        return state in fts.labels.get(phi.name, set())
    elif isinstance(phi, TTop):
        return True
    elif isinstance(phi, TBot):
        return False
    elif isinstance(phi, TNeg):
        return not evaluate(fts, state, phi.f)
    elif isinstance(phi, TConj):
        return evaluate(fts, state, phi.l) and evaluate(fts, state, phi.r)
    elif isinstance(phi, TDisj):
        return evaluate(fts, state, phi.l) or evaluate(fts, state, phi.r)
    elif isinstance(phi, TBox):
        return all(evaluate(fts, t, phi.f) for t in fts.transitions[state])
    elif isinstance(phi, TDiamond):
        return any(evaluate(fts, t, phi.f) for t in fts.transitions[state])
    raise TypeError(f"Unknown formula: {type(phi)}")


def semantic_extension(fts: FiniteTransitionSystem, phi: TFormula) -> FrozenSet[str]:
    """Compute ⟦φ⟧ = {s ∈ S | fts, s ⊨ φ}."""
    return frozenset(s for s in fts.states if evaluate(fts, s, phi))


# ──────────────────────────────────────────────────────────────────
# Behavioral Equivalence (Theorem B)
# ──────────────────────────────────────────────────────────────────

def generate_formulas(props: List[str], depth: int = 3) -> List[TFormula]:
    """Generate all formulas up to a given modal depth.

    For finite systems, depth = |S| suffices for completeness.
    """
    if depth == 0:
        return [TTop(), TBot()] + [TAtom(p) for p in props]

    sub = generate_formulas(props, depth - 1)
    result = list(sub)
    for f in sub:
        result.append(TNeg(f))
        result.append(TBox(f))
        result.append(TDiamond(f))
    for i, f in enumerate(sub):
        for g in sub[i:]:
            result.append(TConj(f, g))
            result.append(TDisj(f, g))
    return result


def compute_behavioral_equivalence(
    fts: FiniteTransitionSystem,
    depth: int = 2
) -> Dict[str, FrozenSet[str]]:
    """Compute behavioral equivalence classes.

    Two states are equivalent iff they satisfy exactly the same formulas.
    By the temporal duality theorem, this equals having the same dual point.

    Returns: mapping from state to its equivalence class.
    """
    props = list(fts.labels.keys())
    formulas = generate_formulas(props, depth)

    # Compute theory for each state
    theories: Dict[str, FrozenSet] = {}
    for s in fts.states:
        th = frozenset(i for i, phi in enumerate(formulas) if evaluate(fts, s, phi))
        theories[s] = th

    # Group by theory
    classes: Dict[FrozenSet, List[str]] = {}
    for s, th in theories.items():
        classes.setdefault(th, []).append(s)

    return {s: frozenset(classes[theories[s]]) for s in fts.states}


def compute_dual_points(
    fts: FiniteTransitionSystem,
    depth: int = 2
) -> Dict[str, FrozenSet[FrozenSet[str]]]:
    """Compute dual points for all states.

    The dual point of state s is the set of definable predicates containing s.
    By temporal_duality_equiv, equal dual points ⟺ behavioral equivalence.

    Returns: mapping from state to its dual point.
    """
    props = list(fts.labels.keys())
    formulas = generate_formulas(props, depth)

    # Compute semantic extensions
    extensions = {phi: semantic_extension(fts, phi) for phi in formulas}

    # Dual point = set of extensions containing s
    return {
        s: frozenset(ext for ext in extensions.values() if s in ext)
        for s in fts.states
    }


def compute_definable_lattice(
    fts: FiniteTransitionSystem,
    depth: int = 2
) -> Set[FrozenSet[str]]:
    """Compute the lattice of definable predicates.

    This is a finite distributive lattice (Boolean algebra) whose
    Birkhoff dual recovers the behavioral equivalence classes.

    Returns: set of all distinct definable predicates.
    """
    props = list(fts.labels.keys())
    formulas = generate_formulas(props, depth)
    return {semantic_extension(fts, phi) for phi in formulas}


def verify_boolean_algebra(
    fts: FiniteTransitionSystem,
    predicates: Set[FrozenSet[str]]
) -> Dict[str, bool]:
    """Verify that a set of predicates forms a Boolean subalgebra.

    Checks closure under ∩, ∪, complement, and □.
    """
    all_states = frozenset(fts.states)
    results = {
        "contains_top": all_states in predicates,
        "contains_bot": frozenset() in predicates,
        "closed_complement": all(
            frozenset(s for s in fts.states if s not in p) in predicates
            for p in predicates
        ),
        "closed_intersection": all(
            p1 & p2 in predicates for p1 in predicates for p2 in predicates
        ),
        "closed_union": all(
            p1 | p2 in predicates for p1 in predicates for p2 in predicates
        ),
        "closed_box": all(
            frozenset(box_operator(fts, set(p))) in predicates
            for p in predicates
        ),
    }
    return results


# ──────────────────────────────────────────────────────────────────
# Example usage
# ──────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    # Construct a finite transition system
    fts = FiniteTransitionSystem(
        states=["s0", "s1", "s2", "s3"],
        transitions={
            "s0": {"s1", "s2"},
            "s1": {"s1"},
            "s2": {"s3"},
            "s3": {"s3"},
        },
        labels={"safe": {"s0", "s1", "s2"}, "target": {"s1"}}
    )

    print("=== Greatest Fixpoint Computation ===")
    safe = fts.labels["safe"]
    gfp, iters = greatest_fixpoint(fts, safe)
    print(f"Safe states: {sorted(safe)}")
    print(f"GFP (always safe): {sorted(gfp)}")
    print(f"Iterations: {iters}")
    print()

    print("=== Model Checking ===")
    for s in fts.states:
        result = model_check_safety(fts, "safe", s)
        print(f"  {s} ⊨ □safe? {result}")
    print()

    print("=== Behavioral Equivalence ===")
    equiv = compute_behavioral_equivalence(fts)
    seen = set()
    for s in fts.states:
        cls = equiv[s]
        if cls not in seen:
            print(f"  Class: {sorted(cls)}")
            seen.add(cls)
    print()

    print("=== Dual Points ===")
    dps = compute_dual_points(fts)
    for s in fts.states:
        print(f"  DualPoint({s}): {len(dps[s])} predicates")
    for i, s in enumerate(fts.states):
        for t in fts.states[i+1:]:
            print(f"  DualPoint({s}) == DualPoint({t})? {dps[s] == dps[t]}")
    print()

    print("=== Definable Predicate Lattice ===")
    lattice = compute_definable_lattice(fts)
    print(f"  Size: {len(lattice)}")
    checks = verify_boolean_algebra(fts, lattice)
    for name, ok in checks.items():
        print(f"  {name}: {'✓' if ok else '✗'}")
