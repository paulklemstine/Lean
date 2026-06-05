#!/usr/bin/env python3
"""
Algorithms for Tangled Hierarchies in Provability Logic

Type-hinted implementations of key algorithms from the formalized theory.
"""

from dataclasses import dataclass, field
from typing import Optional, Callable
from enum import Enum, auto


# ============================================================
# Core Data Structures
# ============================================================

class FormulaKind(Enum):
    VAR = auto()
    BOT = auto()
    IMP = auto()
    BOX = auto()


@dataclass(frozen=True)
class MFormula:
    """Immutable modal formula."""
    kind: FormulaKind
    var_name: str = ""
    left: Optional['MFormula'] = None
    right: Optional['MFormula'] = None
    inner: Optional['MFormula'] = None

    @staticmethod
    def var(name: str) -> 'MFormula':
        return MFormula(FormulaKind.VAR, var_name=name)

    @staticmethod
    def bot() -> 'MFormula':
        return MFormula(FormulaKind.BOT)

    @staticmethod
    def imp(a: 'MFormula', b: 'MFormula') -> 'MFormula':
        return MFormula(FormulaKind.IMP, left=a, right=b)

    @staticmethod
    def box(a: 'MFormula') -> 'MFormula':
        return MFormula(FormulaKind.BOX, inner=a)

    @staticmethod
    def neg(a: 'MFormula') -> 'MFormula':
        return MFormula.imp(a, MFormula.bot())

    @staticmethod
    def con() -> 'MFormula':
        return MFormula.neg(MFormula.box(MFormula.bot()))


@dataclass
class GLFrame:
    """Finite GL frame with n worlds."""
    n: int
    adj: list[list[bool]]

    def successors(self, w: int) -> list[int]:
        """Return all worlds accessible from w."""
        return [v for v in range(self.n) if self.adj[w][v]]

    def predecessors(self, w: int) -> list[int]:
        """Return all worlds that access w."""
        return [v for v in range(self.n) if self.adj[v][w]]


# ============================================================
# Algorithm 1: Modal Depth Computation
# ============================================================

def modal_depth(phi: MFormula) -> int:
    """
    Compute the modal depth of a formula.

    Pseudocode:
        depth(var(p)) = 0
        depth(⊥) = 0
        depth(φ → ψ) = max(depth(φ), depth(ψ))
        depth(□φ) = depth(φ) + 1

    Time complexity: O(|φ|) where |φ| is the formula size.
    """
    if phi.kind == FormulaKind.VAR:
        return 0
    elif phi.kind == FormulaKind.BOT:
        return 0
    elif phi.kind == FormulaKind.IMP:
        assert phi.left is not None and phi.right is not None
        return max(modal_depth(phi.left), modal_depth(phi.right))
    elif phi.kind == FormulaKind.BOX:
        assert phi.inner is not None
        return modal_depth(phi.inner) + 1
    return 0


# ============================================================
# Algorithm 2: Forcing Evaluation
# ============================================================

def evaluate_forcing(
    frame: GLFrame,
    valuation: dict[str, set[int]],
    world: int,
    phi: MFormula
) -> bool:
    """
    Evaluate whether world ⊩ φ in the given frame.

    Pseudocode:
        force(w, var(p)) = p ∈ V(w)
        force(w, ⊥) = false
        force(w, φ → ψ) = ¬force(w, φ) ∨ force(w, ψ)
        force(w, □φ) = ∀v. wRv → force(v, φ)

    Time complexity: O(|φ| * n) where n = |W|.
    """
    if phi.kind == FormulaKind.VAR:
        return world in valuation.get(phi.var_name, set())
    elif phi.kind == FormulaKind.BOT:
        return False
    elif phi.kind == FormulaKind.IMP:
        assert phi.left is not None and phi.right is not None
        left_val = evaluate_forcing(frame, valuation, world, phi.left)
        if not left_val:
            return True
        return evaluate_forcing(frame, valuation, world, phi.right)
    elif phi.kind == FormulaKind.BOX:
        assert phi.inner is not None
        return all(
            evaluate_forcing(frame, valuation, v, phi.inner)
            for v in frame.successors(world)
        )
    return False


# ============================================================
# Algorithm 3: k-Soundness Verification
# ============================================================

def generate_formulas_up_to_depth(
    k: int,
    variables: list[str]
) -> list[MFormula]:
    """
    Generate all formulas of modal depth ≤ k over the given variables.
    (For finite variable sets, this is finite but exponential in k.)

    For practical purposes, we generate a representative sample.
    """
    if k < 0:
        return []

    # Base formulas (depth 0)
    base: list[MFormula] = [MFormula.bot()] + [MFormula.var(v) for v in variables]

    if k == 0:
        # Add implications of base formulas
        result = list(base)
        for a in base:
            for b in base:
                result.append(MFormula.imp(a, b))
        return result

    # Recursive: get formulas of depth ≤ k-1
    prev = generate_formulas_up_to_depth(k - 1, variables)

    result = list(prev)
    # Add boxes (increases depth by 1)
    for phi in prev:
        result.append(MFormula.box(phi))

    # Add some representative implications
    sample = prev[:min(len(prev), 8)]
    for a in sample:
        for b in sample:
            f = MFormula.imp(a, b)
            if modal_depth(f) <= k:
                result.append(f)

    return result


def check_k_soundness(
    frame: GLFrame,
    valuation: dict[str, set[int]],
    world: int,
    k: int,
    variables: list[str]
) -> tuple[bool, Optional[MFormula]]:
    """
    Check if a world is k-sound. Returns (is_sound, counterexample).

    Pseudocode:
        for each formula φ with depth(φ) ≤ k:
            if force(w, □φ) and ¬force(w, φ):
                return (false, φ)
        return (true, None)
    """
    formulas = generate_formulas_up_to_depth(k, variables)

    for phi in formulas:
        if modal_depth(phi) <= k:
            box_phi = MFormula.box(phi)
            if evaluate_forcing(frame, valuation, world, box_phi):
                if not evaluate_forcing(frame, valuation, world, phi):
                    return (False, phi)

    return (True, None)


# ============================================================
# Algorithm 4: Soundness Defect Computation
# ============================================================

def compute_soundness_defect(
    frame: GLFrame,
    valuation: dict[str, set[int]],
    world: int,
    k: int,
    variables: list[str]
) -> list[MFormula]:
    """
    Compute the soundness defect D_k(w): the set of formulas of depth ≤ k
    for which soundness fails at w.

    Returns: list of formulas in the defect set.
    """
    formulas = generate_formulas_up_to_depth(k, variables)
    defect: list[MFormula] = []

    for phi in formulas:
        if modal_depth(phi) <= k:
            box_phi = MFormula.box(phi)
            if evaluate_forcing(frame, valuation, world, box_phi):
                if not evaluate_forcing(frame, valuation, world, phi):
                    defect.append(phi)

    return defect


# ============================================================
# Algorithm 5: Canonical GL Frame Construction
# ============================================================

def build_canonical_frame(n: int) -> GLFrame:
    """
    Construct the canonical GL frame on n+1 worlds.

    Pseudocode:
        W = {0, 1, ..., n}
        R(i, j) = (i < j)

    Properties:
        - Transitive (< is transitive)
        - Irreflexive
        - Converse well-founded (finite)
        - Maximal chain length = n
    """
    size = n + 1
    adj = [[i < j for j in range(size)] for i in range(size)]
    return GLFrame(size, adj)


# ============================================================
# Algorithm 6: Iterated Consistency Formula
# ============================================================

def iterated_consistency(n: int) -> MFormula:
    """
    Build the n-th iterated consistency formula.

    Pseudocode:
        Con_0 = ⊥
        Con_{n+1} = □Con_n → Con_n

    Property: modal_depth(Con_n) = n
    """
    if n == 0:
        return MFormula.bot()
    prev = iterated_consistency(n - 1)
    return MFormula.imp(MFormula.box(prev), prev)


# ============================================================
# Algorithm 7: Tangling Gap Detection
# ============================================================

def detect_tangling_gap(
    frame: GLFrame,
    valuation: dict[str, set[int]],
    world: int
) -> Optional[MFormula]:
    """
    Find a formula witnessing the tangling gap at world w.
    Returns a formula φ such that w ⊩ □φ → φ but w ⊭ □(□φ → φ).

    By the Fundamental Tangling Theorem, ⊥ always works at consistent
    worlds that satisfy □⊥ → ⊥.
    """
    phi = MFormula.bot()
    soundness_phi = MFormula.imp(MFormula.box(phi), phi)

    # Check w ⊩ □φ → φ
    if not evaluate_forcing(frame, valuation, world, soundness_phi):
        return None  # World is not sound for φ

    # Check w ⊭ □(□φ → φ)
    box_soundness = MFormula.box(soundness_phi)
    if evaluate_forcing(frame, valuation, world, box_soundness):
        return None  # No gap (should be impossible if consistent)

    return phi


# ============================================================
# Algorithm 8: Reflective Hierarchy Construction
# ============================================================

@dataclass
class ReflectiveHierarchy:
    """A reflective hierarchy of depth n."""
    frame: GLFrame
    valuation: dict[str, set[int]]
    worlds: list[int]  # chain of worlds
    depth: int

    def verify_chain(self) -> bool:
        """Verify the R-chain property."""
        for i in range(len(self.worlds) - 1):
            if not self.frame.adj[self.worlds[i]][self.worlds[i + 1]]:
                return False
        return True


def build_reflective_hierarchy(n: int) -> ReflectiveHierarchy:
    """
    Construct a reflective hierarchy of depth n using the canonical frame.

    The canonical frame on n+1 worlds, with chain 0 → 1 → ... → n,
    provides a natural reflective hierarchy.
    """
    frame = build_canonical_frame(n)
    worlds = list(range(n + 1))
    return ReflectiveHierarchy(
        frame=frame,
        valuation={},
        worlds=worlds,
        depth=n
    )


if __name__ == "__main__":
    # Quick self-test
    print("Testing algorithms...")

    # Test modal depth
    p = MFormula.var("p")
    assert modal_depth(p) == 0
    assert modal_depth(MFormula.box(p)) == 1
    assert modal_depth(MFormula.box(MFormula.box(p))) == 2
    assert modal_depth(MFormula.con()) == 1

    # Test iterated consistency depth
    for n in range(6):
        assert modal_depth(iterated_consistency(n)) == n, f"Con_{n} depth mismatch"

    # Test canonical frame
    frame = build_canonical_frame(4)
    assert frame.n == 5
    assert frame.adj[0][1] == True
    assert frame.adj[1][0] == False
    assert frame.adj[3][3] == False

    # Test tangling gap
    frame = build_canonical_frame(3)
    gap = detect_tangling_gap(frame, {}, 0)
    assert gap is not None, "Expected tangling gap at world 0"

    print("All tests passed!")
