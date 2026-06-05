#!/usr/bin/env python3
"""
Algorithms for Tangled Hierarchy Analysis

Type-hinted implementations of the core algorithms used in the
tangled hierarchy depth theory.
"""

from typing import Dict, FrozenSet, List, Optional, Set, Tuple
from dataclasses import dataclass, field
from enum import Enum


class Formula:
    """Base class for modal formulas."""
    pass


class Var(Formula):
    def __init__(self, name: str):
        self.name = name

    def __repr__(self) -> str:
        return self.name


class Bot(Formula):
    def __repr__(self) -> str:
        return "⊥"


class Imp(Formula):
    def __init__(self, left: Formula, right: Formula):
        self.left = left
        self.right = right

    def __repr__(self) -> str:
        return f"({self.left} → {self.right})"


class Box(Formula):
    def __init__(self, inner: Formula):
        self.inner = inner

    def __repr__(self) -> str:
        return f"□{self.inner}"


def neg(phi: Formula) -> Formula:
    """Negation: ¬φ = φ → ⊥"""
    return Imp(phi, Bot())


def con() -> Formula:
    """Consistency formula: Con = □⊥ → ⊥"""
    return neg(Box(Bot()))


def iter_box(n: int, phi: Formula) -> Formula:
    """n-fold iteration of □."""
    result = phi
    for _ in range(n):
        result = Box(result)
    return result


def con_n(n: int) -> Formula:
    """n-th iterated consistency: Con_n = □ⁿ⊥ → ⊥"""
    return Imp(iter_box(n, Bot()), Bot())


@dataclass
class GLFrame:
    """A GL frame with worlds and accessibility relation."""
    worlds: List[str]
    edges: Set[Tuple[str, str]]

    def successors(self, w: str) -> Set[str]:
        """Get all R-successors of world w."""
        return {v for (u, v) in self.edges if u == w}

    def is_valid_gl(self) -> Tuple[bool, str]:
        """Verify GL frame conditions: transitivity and irreflexivity."""
        # Check irreflexivity
        for w in self.worlds:
            if (w, w) in self.edges:
                return False, f"Reflexive: {w} R {w}"

        # Check transitivity
        for (u, v) in self.edges:
            for w in self.successors(v):
                if (u, w) not in self.edges:
                    return False, f"Not transitive: {u}R{v} and {v}R{w} but not {u}R{w}"

        return True, "Valid GL frame"

    def depth(self, w: str, _visited: Optional[Set[str]] = None) -> int:
        """Compute tangling depth via well-founded recursion."""
        visited = _visited or set()
        if w in visited:
            return -1  # Cycle detected (shouldn't happen in valid GL)
        visited.add(w)
        succs = self.successors(w)
        if not succs:
            return 0
        return 1 + max(self.depth(v, visited.copy()) for v in succs)


def evaluate_forcing(
    frame: GLFrame,
    valuation: Dict[str, Set[str]],  # var_name -> set of worlds where true
    world: str,
    formula: Formula
) -> bool:
    """
    Evaluate forcing: does world force formula under valuation?

    Algorithm: Recursive evaluation following Kripke semantics.
    Time complexity: O(|W| * |formula|) in the worst case.
    """
    if isinstance(formula, Var):
        return world in valuation.get(formula.name, set())
    elif isinstance(formula, Bot):
        return False
    elif isinstance(formula, Imp):
        left_val = evaluate_forcing(frame, valuation, world, formula.left)
        right_val = evaluate_forcing(frame, valuation, world, formula.right)
        return (not left_val) or right_val
    elif isinstance(formula, Box):
        return all(
            evaluate_forcing(frame, valuation, v, formula.inner)
            for v in frame.successors(world)
        )
    else:
        raise ValueError(f"Unknown formula type: {type(formula)}")


def check_loeb(
    frame: GLFrame,
    valuation: Dict[str, Set[str]],
    phi: Formula
) -> bool:
    """
    Verify Löb's axiom □(□φ → φ) → □φ at all worlds.

    Algorithm: Enumerate all worlds, check the axiom at each.
    This serves as a computational verification of the theorem.
    """
    loeb_formula = Imp(Box(Imp(Box(phi), phi)), Box(phi))
    return all(
        evaluate_forcing(frame, valuation, w, loeb_formula)
        for w in frame.worlds
    )


def find_unprovable_truths(
    frame: GLFrame,
    valuation: Dict[str, Set[str]],
    world: str,
    formulas: List[Formula]
) -> List[Tuple[Formula, bool, bool]]:
    """
    Find formulas that are true but unprovable at a world.

    Returns: List of (formula, is_true, is_provable) triples.
    An unprovable truth has is_true=True, is_provable=False.
    """
    results = []
    for phi in formulas:
        is_true = evaluate_forcing(frame, valuation, world, phi)
        is_provable = evaluate_forcing(frame, valuation, world, Box(phi))
        results.append((phi, is_true, is_provable))
    return results


def compute_tangling_hierarchy(frame: GLFrame) -> Dict[str, int]:
    """
    Compute the tangling depth for all worlds.

    Algorithm: Bottom-up computation starting from dead-end worlds.
    Time complexity: O(|W| + |E|).
    """
    depths: Dict[str, int] = {}

    # Topological sort (reverse of R-order)
    remaining = set(frame.worlds)
    order: List[str] = []

    while remaining:
        # Find worlds with no successors in remaining
        leaves = {w for w in remaining
                  if not frame.successors(w).intersection(remaining)}
        if not leaves:
            break  # Shouldn't happen in a valid GL frame
        for w in leaves:
            depths[w] = 0 if not frame.successors(w) else \
                1 + max(depths[v] for v in frame.successors(w) if v in depths)
        order.extend(leaves)
        remaining -= leaves

    return depths


@dataclass
class ProvabilityLattice:
    """A concrete provability lattice on a finite set."""
    elements: List[str]
    leq: Set[Tuple[str, str]]  # (a, b) means a ≤ b
    box: Dict[str, str]  # box operator
    bot: str
    top: str

    def is_provable(self, a: str) -> bool:
        """a is provable iff □a = ⊤."""
        return self.box[a] == self.top

    def meet(self, a: str, b: str) -> str:
        """Greatest lower bound (simplified for demo)."""
        if a == self.bot or b == self.bot:
            return self.bot
        if a == self.top:
            return b
        if b == self.top:
            return a
        return a  # Simplified

    def join(self, a: str, b: str) -> str:
        """Least upper bound (simplified for demo)."""
        if a == self.top or b == self.top:
            return self.top
        if a == self.bot:
            return b
        if b == self.bot:
            return a
        return a  # Simplified


def verify_goedel_independence(
    lattice: ProvabilityLattice,
    g: str
) -> Tuple[bool, str]:
    """
    Verify that an element g is a Gödel element (independent).

    Checks:
    1. g ⊓ □g = ⊥ (self-refuting)
    2. g ⊔ □g = ⊤ (self-affirming)
    3. □g ≠ ⊤ (not provable)
    4. g ≠ ⊥ (not refutable)
    5. g ≠ ⊤ (not trivially true)
    """
    box_g = lattice.box[g]

    checks = []
    sr = lattice.meet(g, box_g) == lattice.bot
    checks.append(f"Self-refuting (g ⊓ □g = ⊥): {sr}")

    sa = lattice.join(g, box_g) == lattice.top
    checks.append(f"Self-affirming (g ⊔ □g = ⊤): {sa}")

    not_prov = box_g != lattice.top
    checks.append(f"Not provable (□g ≠ ⊤): {not_prov}")

    not_ref = g != lattice.bot
    checks.append(f"Not refutable (g ≠ ⊥): {not_ref}")

    not_triv = g != lattice.top
    checks.append(f"Not trivial (g ≠ ⊤): {not_triv}")

    is_independent = sr and sa and not_prov and not_ref and not_triv
    report = "\n".join(checks)

    return is_independent, report


if __name__ == "__main__":
    # Example: verify Löb's axiom on a concrete frame
    frame = GLFrame(
        worlds=["w0", "w1", "w2"],
        edges={("w0", "w1"), ("w0", "w2"), ("w1", "w2")}
    )

    print("GL Frame validation:", frame.is_valid_gl())
    print()

    # Check Löb's axiom for a simple variable
    val = {"p": {"w2"}}  # p is true only at w2
    phi = Var("p")
    print(f"Löb's axiom valid for p: {check_loeb(frame, val, phi)}")
    print()

    # Compute tangling hierarchy
    depths = compute_tangling_hierarchy(frame)
    print("Tangling depths:", depths)
    print()

    # Find unprovable truths
    formulas = [con(), con_n(1), con_n(2)]
    results = find_unprovable_truths(frame, val, "w0", formulas)
    print("Unprovable truth analysis at w0:")
    for formula, is_true, is_provable in results:
        status = "UNPROVABLE TRUTH" if is_true and not is_provable else \
                 "provable" if is_provable else "false"
        print(f"  {formula}: true={is_true}, provable={is_provable} [{status}]")
