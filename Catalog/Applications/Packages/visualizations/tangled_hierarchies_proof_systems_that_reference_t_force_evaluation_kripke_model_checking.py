#!/usr/bin/env python3
"""
Algorithms for Tangled Hierarchies in Provability Logic

Implements core algorithms for GL frame construction, formula evaluation,
soundness spectrum computation, and tangling degree calculation.
"""

from dataclasses import dataclass, field
from typing import Dict, Set, Tuple, List, Optional, FrozenSet
from enum import Enum, auto
import itertools


# ============================================================
# Type Definitions
# ============================================================

class FType(Enum):
    """Formula node types."""
    VAR = auto()
    BOT = auto()
    IMP = auto()
    BOX = auto()


@dataclass(frozen=True)
class MFormula:
    """Immutable modal formula (hashable for use in sets/dicts)."""
    typ: FType
    var_name: str = ""
    left: Optional['MFormula'] = None
    right: Optional['MFormula'] = None

    @staticmethod
    def var(name: str) -> 'MFormula':
        return MFormula(FType.VAR, var_name=name)

    @staticmethod
    def bot() -> 'MFormula':
        return MFormula(FType.BOT)

    @staticmethod
    def imp(a: 'MFormula', b: 'MFormula') -> 'MFormula':
        return MFormula(FType.IMP, left=a, right=b)

    @staticmethod
    def box(a: 'MFormula') -> 'MFormula':
        return MFormula(FType.BOX, left=a)

    @staticmethod
    def neg(a: 'MFormula') -> 'MFormula':
        return MFormula.imp(a, MFormula.bot())

    @staticmethod
    def top() -> 'MFormula':
        return MFormula.neg(MFormula.bot())

    @staticmethod
    def con() -> 'MFormula':
        return MFormula.neg(MFormula.box(MFormula.bot()))

    @staticmethod
    def loeb(phi: 'MFormula') -> 'MFormula':
        return MFormula.imp(MFormula.box(MFormula.imp(MFormula.box(phi), phi)),
                           MFormula.box(phi))

    @staticmethod
    def soundness_formula(phi: 'MFormula') -> 'MFormula':
        return MFormula.imp(MFormula.box(phi), phi)

    def depth(self) -> int:
        """Modal depth of the formula."""
        if self.typ == FType.VAR or self.typ == FType.BOT:
            return 0
        elif self.typ == FType.IMP:
            return max(self.left.depth(), self.right.depth())
        elif self.typ == FType.BOX:
            return 1 + self.left.depth()
        return 0

    def variables(self) -> Set[str]:
        """Set of propositional variables in the formula."""
        if self.typ == FType.VAR:
            return {self.var_name}
        elif self.typ == FType.BOT:
            return set()
        elif self.typ == FType.IMP:
            return self.left.variables() | self.right.variables()
        elif self.typ == FType.BOX:
            return self.left.variables()
        return set()


@dataclass
class GLFrame:
    """GL frame with efficient successor lookup."""
    worlds: FrozenSet[int]
    _successors: Dict[int, FrozenSet[int]] = field(default_factory=dict)

    def __post_init__(self):
        for w in self.worlds:
            if w not in self._successors:
                self._successors[w] = frozenset()

    @classmethod
    def from_relation(cls, worlds: Set[int],
                      relation: Set[Tuple[int, int]]) -> 'GLFrame':
        """Construct from explicit world set and relation."""
        succ: Dict[int, Set[int]] = {w: set() for w in worlds}
        for u, v in relation:
            succ[u].add(v)
        return cls(
            worlds=frozenset(worlds),
            _successors={w: frozenset(s) for w, s in succ.items()}
        )

    def successors(self, w: int) -> FrozenSet[int]:
        return self._successors.get(w, frozenset())

    def has_edge(self, u: int, v: int) -> bool:
        return v in self._successors.get(u, frozenset())

    def relation(self) -> Set[Tuple[int, int]]:
        return {(u, v) for u in self.worlds for v in self.successors(u)}

    @classmethod
    def chain(cls, n: int) -> 'GLFrame':
        """Build a GL frame that is a chain: n-1 → n-2 → ... → 0
        with all transitive edges (reflective tower)."""
        worlds = set(range(n))
        relation = {(i, j) for i in range(n) for j in range(i)}
        return cls.from_relation(worlds, relation)


# ============================================================
# Algorithm 1: Force Evaluation (Model Checking)
# ============================================================

Valuation = Dict[str, FrozenSet[int]]


def evaluate_forces(frame: GLFrame, val: Valuation,
                    world: int, phi: MFormula) -> bool:
    """
    Evaluate forces(M, V, w, φ) — whether world w forces formula φ.

    Time complexity: O(|W| * 2^d) where d is the modal depth of φ.
    Space complexity: O(d) for recursion stack.

    Algorithm: Direct recursive evaluation following the Kripke semantics.
    """
    if phi.typ == FType.VAR:
        return world in val.get(phi.var_name, frozenset())
    elif phi.typ == FType.BOT:
        return False
    elif phi.typ == FType.IMP:
        return (not evaluate_forces(frame, val, world, phi.left) or
                evaluate_forces(frame, val, world, phi.right))
    elif phi.typ == FType.BOX:
        return all(evaluate_forces(frame, val, v, phi.left)
                   for v in frame.successors(world))
    raise ValueError(f"Unknown formula type: {phi.typ}")


# ============================================================
# Algorithm 2: Soundness Spectrum Computation
# ============================================================

def compute_soundness_spectrum(
    frame: GLFrame, val: Valuation, world: int,
    formulas: List[MFormula]
) -> List[MFormula]:
    """
    Compute the soundness spectrum of a world.

    Input: GL frame, valuation, world, candidate formulas
    Output: List of formulas φ where w ⊩ □φ → φ

    Time: O(|formulas| * |W| * 2^d_max) where d_max is the max modal depth.
    """
    spectrum = []
    for phi in formulas:
        soundness = MFormula.soundness_formula(phi)
        if evaluate_forces(frame, val, world, soundness):
            spectrum.append(phi)
    return spectrum


# ============================================================
# Algorithm 3: Tangling Degree Computation
# ============================================================

def compute_tangling_degree(frame: GLFrame, world: int,
                            memo: Optional[Dict[int, int]] = None) -> int:
    """
    Compute the tangling degree of a world via well-founded recursion.

    Input: GL frame, world
    Output: Tangling degree (length of longest R-chain from world)

    Time: O(|W|^2) in worst case (each world visited once).
    Space: O(|W|) for memoization.

    Pseudocode:
        deg(w) = 0                      if successors(w) = ∅
        deg(w) = max{deg(v) | v ∈ successors(w)} + 1  otherwise
    """
    if memo is None:
        memo = {}
    if world in memo:
        return memo[world]

    succs = frame.successors(world)
    if not succs:
        memo[world] = 0
        return 0

    max_deg = max(compute_tangling_degree(frame, v, memo) for v in succs)
    result = max_deg + 1
    memo[world] = result
    return result


# ============================================================
# Algorithm 4: GL Frame Validity Checker
# ============================================================

def check_gl_validity(frame: GLFrame, phi: MFormula,
                      var_names: Optional[List[str]] = None) -> bool:
    """
    Check whether φ is valid on a (finite) GL frame.

    Enumerates all valuations and checks all worlds.

    Input: GL frame, formula
    Output: True iff φ is valid (holds at every world under every valuation)

    Time: O(2^(|vars| * |W|) * |W| * 2^d) — exponential in variables.
    """
    if var_names is None:
        var_names = sorted(phi.variables())

    if not var_names:
        # No variables: check with empty valuation
        val: Valuation = {}
        return all(evaluate_forces(frame, val, w, phi) for w in frame.worlds)

    # Enumerate all possible valuations
    world_list = sorted(frame.worlds)
    for assignment in itertools.product(
        *[itertools.combinations(world_list, r)
          for _ in var_names
          for r in range(len(world_list) + 1)]
    ):
        # This is too expensive for large frames; use subset enumeration
        break

    # More efficient: enumerate subsets for each variable
    for combo in itertools.product(
        *[range(2 ** len(world_list)) for _ in var_names]
    ):
        val = {}
        for i, var in enumerate(var_names):
            val[var] = frozenset(
                world_list[j] for j in range(len(world_list))
                if combo[i] & (1 << j)
            )
        if not all(evaluate_forces(frame, val, w, phi) for w in frame.worlds):
            return False
    return True


# ============================================================
# Algorithm 5: Reflective Tower Constructor
# ============================================================

def build_reflective_tower(height: int) -> Tuple[GLFrame, List[int]]:
    """
    Construct a reflective tower of given height.

    Output: (GL frame, tower sequence [w_0, w_1, ..., w_{height-1}])

    The tower satisfies:
    - w_i R w_j whenever i > j
    - All worlds are distinct
    - R is transitive and converse well-founded

    Time: O(height^2) for edge construction.
    """
    frame = GLFrame.chain(height)
    tower = list(range(height))  # tower[i] = world i
    return frame, tower


# ============================================================
# Algorithm 6: Counterexample Search for Universal Soundness
# ============================================================

def find_universal_soundness_counterexample(
    frame: GLFrame, world: int, var_names: List[str]
) -> Optional[Tuple[Valuation, MFormula]]:
    """
    Find a (valuation, formula) pair witnessing failure of universal soundness.

    Uses the strategic valuation V(p, u) = (u ≠ w) from the
    Universal Tangling Collapse theorem.

    Input: GL frame, target world, variable names
    Output: (V, φ) such that w ⊮ □φ → φ, or None if world is terminal.
    """
    if not frame.successors(world):
        # Terminal world — universal soundness restricted to box-free
        # formulas might hold trivially
        return None

    if not var_names:
        return None  # Need at least one variable

    # Strategic valuation: var true everywhere except at w
    var = var_names[0]
    strategic_val: Valuation = {
        var: frozenset(w for w in frame.worlds if w != world)
    }

    phi = MFormula.var(var)
    soundness = MFormula.soundness_formula(phi)

    if not evaluate_forces(frame, strategic_val, world, soundness):
        return (strategic_val, phi)

    return None  # Should not happen if world has successors


# ============================================================
# Main: Run all algorithms on example frames
# ============================================================

if __name__ == "__main__":
    print("Tangled Hierarchies — Algorithm Demonstrations")
    print("=" * 60)

    # Build a 5-level reflective tower
    frame, tower = build_reflective_tower(5)

    print(f"\n1. Reflective Tower (height 5)")
    print(f"   Worlds: {sorted(frame.worlds)}")
    print(f"   Edges: {sorted(frame.relation())}")

    # Compute tangling degrees
    print(f"\n2. Tangling Degrees:")
    memo: Dict[int, int] = {}
    for w in sorted(frame.worlds):
        deg = compute_tangling_degree(frame, w, memo)
        print(f"   deg(w_{w}) = {deg}")

    # Verify Löb's theorem
    p = MFormula.var("p")
    loeb_p = MFormula.loeb(p)
    print(f"\n3. Löb's Theorem Validity Check:")
    is_valid = check_gl_validity(frame, loeb_p, ["p"])
    print(f"   □(□p → p) → □p is valid: {is_valid}")

    # Find universal soundness counterexamples
    print(f"\n4. Universal Soundness Counterexamples:")
    for w in sorted(frame.worlds):
        result = find_universal_soundness_counterexample(frame, w, ["p"])
        if result:
            val, phi = result
            print(f"   World {w}: Counterexample found! "
                  f"V(p) = {set(val['p'])}")
        else:
            print(f"   World {w}: Terminal (no counterexample needed)")

    # Compute soundness spectra
    print(f"\n5. Soundness Spectra:")
    test_formulas = [
        MFormula.bot(), MFormula.top(), MFormula.var("p"),
        MFormula.box(MFormula.bot()), MFormula.box(MFormula.var("p"))
    ]
    val: Valuation = {"p": frozenset({0, 2, 4})}
    for w in sorted(frame.worlds):
        spectrum = compute_soundness_spectrum(frame, val, w, test_formulas)
        print(f"   World {w}: {len(spectrum)}/{len(test_formulas)} formulas in spectrum")
