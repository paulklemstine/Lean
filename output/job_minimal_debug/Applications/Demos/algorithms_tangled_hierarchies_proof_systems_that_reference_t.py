#!/usr/bin/env python3
"""
Tangled Hierarchies: Algorithms
================================

Type-hinted implementations of key algorithms for GL frame analysis,
model checking, and tangling detection.
"""

from dataclasses import dataclass, field
from typing import Callable, Optional


# ============================================================
# Data Structures
# ============================================================

@dataclass
class GLFrame:
    """A Gödel-Löb frame: worlds with transitive, acyclic accessibility."""
    worlds: list[int]
    edges: set[tuple[int, int]]

    def successors(self, w: int) -> list[int]:
        """All worlds accessible from w."""
        return [v for v in self.worlds if (w, v) in self.edges]

    def predecessors(self, w: int) -> list[int]:
        """All worlds that can access w."""
        return [v for v in self.worlds if (v, w) in self.edges]


class MFormula:
    """Base class for modal formulas."""
    pass

@dataclass
class Var(MFormula):
    name: str

@dataclass
class Bot(MFormula):
    pass

@dataclass
class Imp(MFormula):
    left: MFormula
    right: MFormula

@dataclass
class BoxF(MFormula):
    inner: MFormula


def neg(phi: MFormula) -> MFormula:
    return Imp(phi, Bot())

def top() -> MFormula:
    return neg(Bot())

def con() -> MFormula:
    return neg(BoxF(Bot()))

def loeb_formula(phi: MFormula) -> MFormula:
    return Imp(BoxF(Imp(BoxF(phi), phi)), BoxF(phi))


# ============================================================
# Algorithm 1: GL Frame Verification
# ============================================================

def verify_gl_frame(frame: GLFrame) -> tuple[bool, str]:
    """
    Verify that a frame is a valid GL frame.

    Checks:
    1. Irreflexivity: no self-loops
    2. Transitivity: R(u,v) ∧ R(v,w) → R(u,w)
    3. Acyclicity: no directed cycles (equivalent to converse well-foundedness)

    Returns (is_valid, reason).
    Time complexity: O(n³) for transitivity, O(n + |E|) for acyclicity.
    """
    # 1. Irreflexivity
    for w in frame.worlds:
        if (w, w) in frame.edges:
            return False, f"Self-loop at world {w}"

    # 2. Transitivity
    for u in frame.worlds:
        for v in frame.worlds:
            if (u, v) not in frame.edges:
                continue
            for w in frame.worlds:
                if (v, w) in frame.edges and (u, w) not in frame.edges:
                    return False, f"Transitivity fails: R({u},{v}) and R({v},{w}) but not R({u},{w})"

    # 3. Acyclicity (topological sort)
    in_degree = {w: 0 for w in frame.worlds}
    for (u, v) in frame.edges:
        in_degree[v] += 1

    queue = [w for w in frame.worlds if in_degree[w] == 0]
    processed = 0

    while queue:
        w = queue.pop(0)
        processed += 1
        for v in frame.successors(w):
            in_degree[v] -= 1
            if in_degree[v] == 0:
                queue.append(v)

    if processed != len(frame.worlds):
        return False, "Frame contains a cycle (not converse well-founded)"

    return True, "Valid GL frame"


# ============================================================
# Algorithm 2: Model Checking
# ============================================================

def model_check(
    frame: GLFrame,
    valuation: Callable[[str, int], bool],
    w: int,
    phi: MFormula
) -> bool:
    """
    Check whether world w forces formula phi.

    Implements the recursive Kripke forcing relation:
    - w ⊩ p     iff V(p)(w)
    - w ⊩ ⊥     iff False
    - w ⊩ φ→ψ   iff (w ⊩ φ) implies (w ⊩ ψ)
    - w ⊩ □φ    iff ∀v, R(w,v) → v ⊩ φ

    Time complexity: O(|W| · |φ|) where |φ| is formula size.
    """
    if isinstance(phi, Var):
        return valuation(phi.name, w)
    elif isinstance(phi, Bot):
        return False
    elif isinstance(phi, Imp):
        left_val = model_check(frame, valuation, w, phi.left)
        if not left_val:
            return True  # False → anything is True
        return model_check(frame, valuation, w, phi.right)
    elif isinstance(phi, BoxF):
        return all(
            model_check(frame, valuation, v, phi.inner)
            for v in frame.successors(w)
        )
    raise ValueError(f"Unknown formula type: {type(phi)}")


# ============================================================
# Algorithm 3: Tangling Depth Computation
# ============================================================

def compute_rdepth(frame: GLFrame, w: int, memo: Optional[dict[int, int]] = None) -> int:
    """
    Compute the R-depth (tangling depth) of world w.

    The depth is the length of the longest R-chain from w.
    Terminal worlds have depth 0.

    Uses memoization for efficiency.
    Time complexity: O(|W| + |E|) with memoization.
    """
    if memo is None:
        memo = {}
    if w in memo:
        return memo[w]

    succs = frame.successors(w)
    if not succs:
        memo[w] = 0
        return 0

    depth = 1 + max(compute_rdepth(frame, v, memo) for v in succs)
    memo[w] = depth
    return depth


# ============================================================
# Algorithm 4: Tangling Dichotomy Detection
# ============================================================

def detect_tangling(
    frame: GLFrame,
    w: int
) -> tuple[str, Optional[str]]:
    """
    Determine the tangling status of world w.

    Returns:
    - ("TERMINAL", None) if w has no successors
    - ("TANGLED", explanation) if w has successors and therefore
      must have unprovable soundness formulas

    This implements the tangling dichotomy theorem.
    """
    succs = frame.successors(w)
    if not succs:
        return "TERMINAL", None

    # World has successors → it's tangled
    # Verify by checking that □(□⊥ → ⊥) fails under trivial valuation
    V_false: Callable[[str, int], bool] = lambda name, w: False
    box_con = BoxF(Imp(BoxF(Bot()), Bot()))
    can_prove_con = model_check(frame, V_false, w, box_con)

    if not can_prove_con:
        return "TANGLED", (
            f"World {w} has successors {succs} and cannot prove □(□⊥→⊥) "
            f"(second incompleteness theorem)"
        )
    else:
        # This shouldn't happen for a consistent world in a GL frame
        return "TANGLED", (
            f"World {w} has successors {succs}. Under trivial valuation, "
            f"it proves □(□⊥→⊥) but this means it proves □⊥ by Löb, "
            f"i.e., it is inconsistent."
        )


# ============================================================
# Algorithm 5: Iterated Consistency Hierarchy
# ============================================================

def build_iter_con(n: int) -> MFormula:
    """Build the iterated consistency formula Con^n."""
    if n == 0:
        return top()
    return neg(BoxF(neg(build_iter_con(n - 1))))


def analyze_consistency_hierarchy(
    frame: GLFrame,
    w: int,
    max_level: int = 10
) -> list[tuple[int, bool]]:
    """
    Analyze which levels of the iterated consistency hierarchy
    world w satisfies.

    Returns list of (level, satisfies) pairs.
    """
    V_false: Callable[[str, int], bool] = lambda name, w: False
    results = []
    for n in range(max_level):
        formula = build_iter_con(n)
        result = model_check(frame, V_false, w, formula)
        results.append((n, result))
        if not result:
            break  # Higher levels will also fail
    return results


# ============================================================
# Algorithm 6: Disjoint Union Construction
# ============================================================

def disjoint_union(frame1: GLFrame, frame2: GLFrame, offset: int = 1000) -> GLFrame:
    """
    Construct the disjoint union of two GL frames.

    Worlds from frame2 are offset to avoid collision.
    No cross-edges are added.
    """
    worlds2 = [w + offset for w in frame2.worlds]
    edges2 = {(u + offset, v + offset) for (u, v) in frame2.edges}

    return GLFrame(
        worlds=frame1.worlds + worlds2,
        edges=frame1.edges | edges2
    )


# ============================================================
# Main: Run all algorithms
# ============================================================

if __name__ == "__main__":
    # Create test frame
    frame = GLFrame(
        worlds=[0, 1, 2, 3, 4],
        edges={(i, j) for i in range(5) for j in range(i + 1, 5)}
    )

    print("=" * 50)
    print("GL Frame Verification")
    print("=" * 50)
    valid, reason = verify_gl_frame(frame)
    print(f"Valid: {valid}, Reason: {reason}")

    print("\n" + "=" * 50)
    print("Tangling Depth")
    print("=" * 50)
    memo: dict[int, int] = {}
    for w in frame.worlds:
        d = compute_rdepth(frame, w, memo)
        print(f"  rdepth({w}) = {d}")

    print("\n" + "=" * 50)
    print("Tangling Dichotomy")
    print("=" * 50)
    for w in frame.worlds:
        status, explanation = detect_tangling(frame, w)
        print(f"  World {w}: {status}")
        if explanation:
            print(f"    {explanation}")

    print("\n" + "=" * 50)
    print("Consistency Hierarchy at World 0")
    print("=" * 50)
    hierarchy = analyze_consistency_hierarchy(frame, 0)
    for level, satisfies in hierarchy:
        print(f"  Con^{level}: {'✓' if satisfies else '✗'}")

    print("\n" + "=" * 50)
    print("Disjoint Union")
    print("=" * 50)
    frame_a = GLFrame(worlds=[0, 1], edges={(0, 1)})
    frame_b = GLFrame(worlds=[0, 1, 2], edges={(0, 1), (0, 2), (1, 2)})
    union = disjoint_union(frame_a, frame_b)
    valid, reason = verify_gl_frame(union)
    print(f"Union valid: {valid}")
    print(f"Union worlds: {union.worlds}")
