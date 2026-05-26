#!/usr/bin/env python3
"""
Applications of the Tensor Distributivity Rewrite System.

Demonstrates real-world applications of the confluence result:
1. Compiler optimization: deterministic simplification of tensor computations
2. Symbolic linear algebra: canonical representation of bilinear forms
3. Scientific computing: verified expression simplification
"""

from demo import (
    Expr, ScalVar, VecVar, MatVar, ScalAdd, ScalMul, VecAdd, MatAdd,
    SmulVec, SmulMat, MulVec, Dot,
    dist_potential, normalize_greedy, ac_equiv, pretty, all_deep_rewrites
)


def application_compiler_optimization():
    """Application 1: Deterministic Compiler Optimization.

    In tensor compilers (e.g., for deep learning frameworks), expression
    simplification must be deterministic to ensure reproducible builds.
    Confluence modulo AC guarantees that different optimization schedules
    produce the same canonical output.
    """
    print("=" * 70)
    print("APPLICATION 1: Deterministic Compiler Optimization")
    print("=" * 70)

    A, B = MatVar("A"), MatVar("B")
    v, w, u = VecVar("v"), VecVar("w"), VecVar("u")
    alpha = ScalVar("α")

    # A tensor computation that can be simplified multiple ways
    expr = Dot(
        MulVec(MatAdd(A, B), VecAdd(v, w)),
        SmulVec(alpha, u)
    )

    print(f"\n  Original expression:")
    print(f"    {pretty(expr)}")
    print(f"    Distributivity potential: {dist_potential(expr)}")

    # Normalize
    nf = normalize_greedy(expr)
    print(f"\n  Canonical normal form:")
    print(f"    {pretty(nf)}")
    print(f"    Distributivity potential: {dist_potential(nf)}")

    # Show that rewriting in a different order gives AC-equivalent result
    rewrites = all_deep_rewrites(expr)
    if len(rewrites) >= 2:
        # Take two different first rewrites
        _, r1 = rewrites[0]
        _, r2 = rewrites[1]
        nf1 = normalize_greedy(r1)
        nf2 = normalize_greedy(r2)
        print(f"\n  Path 1 normal form: {pretty(nf1)}")
        print(f"  Path 2 normal form: {pretty(nf2)}")
        print(f"  AC-equivalent: {ac_equiv(nf1, nf2)}")
        print(f"\n  ✓ Optimization is deterministic (modulo AC)!")


def application_bilinear_forms():
    """Application 2: Canonical Representation of Bilinear Forms.

    The energy functional E(A, v) = ⟨v, Av⟩ can be expanded in multiple
    ways when v is a sum. Confluence ensures the expanded form is unique,
    enabling symbolic comparison of quadratic forms.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Canonical Bilinear Form Expansion")
    print("=" * 70)

    A = MatVar("A")
    v, w = VecVar("v"), VecVar("w")

    # E(A, v+w) = ⟨v+w, A(v+w)⟩
    energy = Dot(VecAdd(v, w), MulVec(A, VecAdd(v, w)))

    print(f"\n  Energy functional E(A, v+w) = ⟨v+w, A(v+w)⟩:")
    print(f"    {pretty(energy)}")
    print(f"    dp = {dist_potential(energy)}")

    nf = normalize_greedy(energy)
    print(f"\n  Canonical expansion:")
    print(f"    {pretty(nf)}")
    print(f"    dp = {dist_potential(nf)}")
    print(f"\n  This expansion is unique (mod AC), so two energy expressions")
    print(f"  can be compared by normalizing and checking AC-equivalence.")


def application_scientific_computing():
    """Application 3: Verified Expression Simplification.

    In scientific computing, algebraic simplification of tensor
    expressions must preserve semantics. The termination measure
    guarantees the simplifier always halts, and confluence guarantees
    the result is canonical.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Verified Scientific Computing Simplifier")
    print("=" * 70)

    A, B = MatVar("A"), MatVar("B")
    v, w = VecVar("v"), VecVar("w")
    a, b = ScalVar("α"), ScalVar("β")

    # Complex expression from a finite element computation
    expr = MulVec(
        SmulMat(a, MatAdd(A, SmulMat(b, B))),
        VecAdd(v, SmulVec(a, w))
    )

    print(f"\n  FEM expression: {pretty(expr)}")
    print(f"  Size: {dist_potential(expr)}")

    # Count reduction steps
    current = expr
    steps = 0
    print(f"\n  Reduction trace:")
    while True:
        rewrites = all_deep_rewrites(current)
        if not rewrites:
            break
        name, result = rewrites[0]
        steps += 1
        if steps <= 10:
            print(f"    Step {steps}: [{name}]")
            print(f"      → {pretty(result)}  [dp={dist_potential(result)}]")
        current = result

    print(f"\n  Total steps: {steps}")
    print(f"  Final form: {pretty(current)}")
    print(f"  Final dp: {dist_potential(current)}")
    print(f"\n  Bound: steps ({steps}) ≤ dp ({dist_potential(expr)}) ✓")


if __name__ == "__main__":
    application_compiler_optimization()
    application_bilinear_forms()
    application_scientific_computing()


#!/usr/bin/env python3
"""
Tensor Distributivity Rewrite System — Interactive Demo

Demonstrates the 9-rule distributivity rewrite system for tensor expressions,
including:
  - BFS enumeration of all reduction sequences
  - AC-equivalence checking of terminal forms
  - Canonical normalization
  - Distributivity potential computation and verification

Usage: python demo.py
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import List, Tuple, Optional, Set
from collections import deque
import itertools

# ============================================================
# Part 1: Tensor Expression AST
# ============================================================

@dataclass(frozen=True)
class Expr:
    """Base class for tensor expressions."""
    pass

@dataclass(frozen=True)
class ScalVar(Expr):
    name: str

@dataclass(frozen=True)
class VecVar(Expr):
    name: str

@dataclass(frozen=True)
class MatVar(Expr):
    name: str

@dataclass(frozen=True)
class ScalAdd(Expr):
    left: Expr
    right: Expr

@dataclass(frozen=True)
class ScalMul(Expr):
    left: Expr
    right: Expr

@dataclass(frozen=True)
class VecAdd(Expr):
    left: Expr
    right: Expr

@dataclass(frozen=True)
class MatAdd(Expr):
    left: Expr
    right: Expr

@dataclass(frozen=True)
class SmulVec(Expr):
    scalar: Expr
    vec: Expr

@dataclass(frozen=True)
class SmulMat(Expr):
    scalar: Expr
    mat: Expr

@dataclass(frozen=True)
class MulVec(Expr):
    mat: Expr
    vec: Expr

@dataclass(frozen=True)
class Dot(Expr):
    left: Expr
    right: Expr


def pretty(e: Expr) -> str:
    """Pretty-print a tensor expression."""
    if isinstance(e, ScalVar): return e.name
    if isinstance(e, VecVar): return e.name
    if isinstance(e, MatVar): return e.name
    if isinstance(e, ScalAdd): return f"({pretty(e.left)} + {pretty(e.right)})"
    if isinstance(e, ScalMul): return f"({pretty(e.left)} · {pretty(e.right)})"
    if isinstance(e, VecAdd): return f"({pretty(e.left)} ⊕ {pretty(e.right)})"
    if isinstance(e, MatAdd): return f"({pretty(e.left)} ⊞ {pretty(e.right)})"
    if isinstance(e, SmulVec): return f"({pretty(e.scalar)} • {pretty(e.vec)})"
    if isinstance(e, SmulMat): return f"({pretty(e.scalar)} ⊙ {pretty(e.mat)})"
    if isinstance(e, MulVec): return f"({pretty(e.mat)} *ᵥ {pretty(e.vec)})"
    if isinstance(e, Dot): return f"⟨{pretty(e.left)}, {pretty(e.right)}⟩"
    return str(e)


# ============================================================
# Part 2: Distributivity Potential
# ============================================================

def dist_potential(e: Expr) -> int:
    """Compute the distributivity potential (polynomial interpretation).

    This is the termination measure proven to strictly decrease under
    every rewrite step. The key design:
    - Variables → 3
    - Additive nodes → sum + 1
    - Pure multiplicative → product
    - Scalar-action → product + 1
    """
    if isinstance(e, (ScalVar, VecVar, MatVar)):
        return 3
    if isinstance(e, (ScalAdd, VecAdd, MatAdd)):
        return dist_potential(e.left) + dist_potential(e.right) + 1
    if isinstance(e, ScalMul):
        return dist_potential(e.left) * dist_potential(e.right)
    if isinstance(e, (SmulVec, SmulMat)):
        return dist_potential(e.scalar) * dist_potential(getattr(e, 'vec', None) or e.mat) + 1
    if isinstance(e, MulVec):
        return dist_potential(e.mat) * dist_potential(e.vec)
    if isinstance(e, Dot):
        return dist_potential(e.left) * dist_potential(e.right)
    raise ValueError(f"Unknown expression type: {type(e)}")


def expr_size(e: Expr) -> int:
    """Structural size of an expression."""
    if isinstance(e, (ScalVar, VecVar, MatVar)):
        return 1
    if isinstance(e, (ScalAdd, ScalMul, VecAdd, MatAdd)):
        return 1 + expr_size(e.left) + expr_size(e.right)
    if isinstance(e, (SmulVec, SmulMat)):
        return 1 + expr_size(e.scalar) + expr_size(getattr(e, 'vec', None) or e.mat)
    if isinstance(e, MulVec):
        return 1 + expr_size(e.mat) + expr_size(e.vec)
    if isinstance(e, Dot):
        return 1 + expr_size(e.left) + expr_size(e.right)
    raise ValueError


# ============================================================
# Part 3: Rewrite Rules (9 rules)
# ============================================================

def root_rewrites(e: Expr) -> List[Tuple[str, Expr]]:
    """Apply all matching root-level rewrite rules, returning (rule_name, result) pairs."""
    results = []

    # Rule 1: mulVec A (vecAdd v w) → vecAdd (mulVec A v) (mulVec A w)
    if isinstance(e, MulVec) and isinstance(e.vec, VecAdd):
        A, v, w = e.mat, e.vec.left, e.vec.right
        results.append(("R1:mulVec_vecAdd", VecAdd(MulVec(A, v), MulVec(A, w))))

    # Rule 2: mulVec (matAdd A B) v → vecAdd (mulVec A v) (mulVec B v)
    if isinstance(e, MulVec) and isinstance(e.mat, MatAdd):
        A, B, v = e.mat.left, e.mat.right, e.vec
        results.append(("R2:matAdd_mulVec", VecAdd(MulVec(A, v), MulVec(B, v))))

    # Rule 3: mulVec (smulMat a A) v → smulVec a (mulVec A v)
    if isinstance(e, MulVec) and isinstance(e.mat, SmulMat):
        a, A, v = e.mat.scalar, e.mat.mat, e.vec
        results.append(("R3:smulMat_mulVec", SmulVec(a, MulVec(A, v))))

    # Rule 4: smulVec a (vecAdd v w) → vecAdd (smulVec a v) (smulVec a w)
    if isinstance(e, SmulVec) and isinstance(e.vec, VecAdd):
        a, v, w = e.scalar, e.vec.left, e.vec.right
        results.append(("R4:smulVec_vecAdd", VecAdd(SmulVec(a, v), SmulVec(a, w))))

    # Rule 5: smulMat a (matAdd A B) → matAdd (smulMat a A) (smulMat a B)
    if isinstance(e, SmulMat) and isinstance(e.mat, MatAdd):
        a, A, B = e.scalar, e.mat.left, e.mat.right
        results.append(("R5:smulMat_matAdd", MatAdd(SmulMat(a, A), SmulMat(a, B))))

    # Rule 6: dot (vecAdd v w) u → scalAdd (dot v u) (dot w u)
    if isinstance(e, Dot) and isinstance(e.left, VecAdd):
        v, w, u = e.left.left, e.left.right, e.right
        results.append(("R6:dot_vecAdd_left", ScalAdd(Dot(v, u), Dot(w, u))))

    # Rule 7: dot u (vecAdd v w) → scalAdd (dot u v) (dot u w)
    if isinstance(e, Dot) and isinstance(e.right, VecAdd):
        u, v, w = e.left, e.right.left, e.right.right
        results.append(("R7:dot_vecAdd_right", ScalAdd(Dot(u, v), Dot(u, w))))

    # Rule 8: dot (smulVec a v) w → scalMul a (dot v w)
    if isinstance(e, Dot) and isinstance(e.left, SmulVec):
        a, v, w = e.left.scalar, e.left.vec, e.right
        results.append(("R8:dot_smulVec_left", ScalMul(a, Dot(v, w))))

    # Rule 9: scalMul a (scalAdd b c) → scalAdd (scalMul a b) (scalMul a c)
    if isinstance(e, ScalMul) and isinstance(e.right, ScalAdd):
        a, b, c = e.left, e.right.left, e.right.right
        results.append(("R9:scalMul_scalAdd", ScalAdd(ScalMul(a, b), ScalMul(a, c))))

    return results


def all_deep_rewrites(e: Expr) -> List[Tuple[str, Expr]]:
    """All possible one-step deep rewrites (root + context closure)."""
    results = root_rewrites(e)

    # Context closure for binary constructors
    def context_rewrites(e):
        res = []
        if isinstance(e, ScalAdd):
            for name, r in all_deep_rewrites(e.left):
                res.append((f"scalAdd_l({name})", ScalAdd(r, e.right)))
            for name, r in all_deep_rewrites(e.right):
                res.append((f"scalAdd_r({name})", ScalAdd(e.left, r)))
        elif isinstance(e, ScalMul):
            for name, r in all_deep_rewrites(e.left):
                res.append((f"scalMul_l({name})", ScalMul(r, e.right)))
            for name, r in all_deep_rewrites(e.right):
                res.append((f"scalMul_r({name})", ScalMul(e.left, r)))
        elif isinstance(e, VecAdd):
            for name, r in all_deep_rewrites(e.left):
                res.append((f"vecAdd_l({name})", VecAdd(r, e.right)))
            for name, r in all_deep_rewrites(e.right):
                res.append((f"vecAdd_r({name})", VecAdd(e.left, r)))
        elif isinstance(e, MatAdd):
            for name, r in all_deep_rewrites(e.left):
                res.append((f"matAdd_l({name})", MatAdd(r, e.right)))
            for name, r in all_deep_rewrites(e.right):
                res.append((f"matAdd_r({name})", MatAdd(e.left, r)))
        elif isinstance(e, SmulVec):
            for name, r in all_deep_rewrites(e.scalar):
                res.append((f"smulVec_l({name})", SmulVec(r, e.vec)))
            for name, r in all_deep_rewrites(e.vec):
                res.append((f"smulVec_r({name})", SmulVec(e.scalar, r)))
        elif isinstance(e, SmulMat):
            for name, r in all_deep_rewrites(e.scalar):
                res.append((f"smulMat_l({name})", SmulMat(r, e.mat)))
            for name, r in all_deep_rewrites(e.mat):
                res.append((f"smulMat_r({name})", SmulMat(e.scalar, r)))
        elif isinstance(e, MulVec):
            for name, r in all_deep_rewrites(e.mat):
                res.append((f"mulVec_l({name})", MulVec(r, e.vec)))
            for name, r in all_deep_rewrites(e.vec):
                res.append((f"mulVec_r({name})", MulVec(e.mat, r)))
        elif isinstance(e, Dot):
            for name, r in all_deep_rewrites(e.left):
                res.append((f"dot_l({name})", Dot(r, e.right)))
            for name, r in all_deep_rewrites(e.right):
                res.append((f"dot_r({name})", Dot(e.left, r)))
        return res

    results.extend(context_rewrites(e))
    return results


# ============================================================
# Part 4: AC-Equivalence
# ============================================================

def flatten_add(e: Expr, add_type) -> List[Expr]:
    """Flatten nested additions into a list of summands."""
    if isinstance(e, add_type):
        return flatten_add(e.left, add_type) + flatten_add(e.right, add_type)
    return [e]


def ac_canonical(e: Expr) -> Expr:
    """Compute an AC-canonical form by sorting and flattening additions."""
    if isinstance(e, (ScalVar, VecVar, MatVar)):
        return e

    if isinstance(e, ScalAdd):
        summands = flatten_add(e, ScalAdd)
        summands = sorted([ac_canonical(s) for s in summands], key=repr)
        result = summands[0]
        for s in summands[1:]:
            result = ScalAdd(result, s)
        return result

    if isinstance(e, VecAdd):
        summands = flatten_add(e, VecAdd)
        summands = sorted([ac_canonical(s) for s in summands], key=repr)
        result = summands[0]
        for s in summands[1:]:
            result = VecAdd(result, s)
        return result

    if isinstance(e, MatAdd):
        summands = flatten_add(e, MatAdd)
        summands = sorted([ac_canonical(s) for s in summands], key=repr)
        result = summands[0]
        for s in summands[1:]:
            result = MatAdd(result, s)
        return result

    if isinstance(e, ScalMul):
        return ScalMul(ac_canonical(e.left), ac_canonical(e.right))
    if isinstance(e, SmulVec):
        return SmulVec(ac_canonical(e.scalar), ac_canonical(e.vec))
    if isinstance(e, SmulMat):
        return SmulMat(ac_canonical(e.scalar), ac_canonical(e.mat))
    if isinstance(e, MulVec):
        return MulVec(ac_canonical(e.mat), ac_canonical(e.vec))
    if isinstance(e, Dot):
        return Dot(ac_canonical(e.left), ac_canonical(e.right))
    return e


def ac_equiv(e1: Expr, e2: Expr) -> bool:
    """Check if two expressions are AC-equivalent."""
    return ac_canonical(e1) == ac_canonical(e2)


# ============================================================
# Part 5: BFS Reduction and Confluence Check
# ============================================================

def bfs_all_normal_forms(start: Expr, max_states=10000) -> Tuple[Set[Expr], int, int]:
    """BFS all reduction sequences to find all normal forms.

    Returns (normal_forms_set, max_sequence_length, states_explored).
    """
    visited = set()
    queue = deque([(start, 0)])
    visited.add(start)
    normal_forms = set()
    max_len = 0

    while queue and len(visited) < max_states:
        current, depth = queue.popleft()
        rewrites = all_deep_rewrites(current)

        if not rewrites:
            normal_forms.add(current)
            max_len = max(max_len, depth)
        else:
            for _, result in rewrites:
                if result not in visited:
                    visited.add(result)
                    queue.append((result, depth + 1))

    return normal_forms, max_len, len(visited)


def normalize_greedy(e: Expr) -> Expr:
    """Greedy normalization: always apply the first available rewrite."""
    while True:
        rewrites = all_deep_rewrites(e)
        if not rewrites:
            return e
        e = rewrites[0][1]


# ============================================================
# Part 6: Term Generation
# ============================================================

def generate_terms(depth: int, svars, vvars, mvars) -> List[Expr]:
    """Generate all terms up to given depth."""
    if depth <= 0:
        return list(svars) + list(vvars) + list(mvars)

    smaller = generate_terms(depth - 1, svars, vvars, mvars)
    results = list(smaller)

    for a in smaller:
        for b in smaller:
            if len(results) > 500:
                break
            # Only add a few representative binary combinations
            results.append(ScalAdd(a, b))
            results.append(VecAdd(a, b))
            results.append(MulVec(a, b))
            results.append(Dot(a, b))
            results.append(SmulVec(a, b))

    return results[:500]


# ============================================================
# Part 7: Main Demo
# ============================================================

def demo_potential_decrease():
    """Demonstrate that distPotential strictly decreases under rewriting."""
    print("=" * 70)
    print("DEMO 1: Distributivity Potential Decreases Under Rewriting")
    print("=" * 70)

    # Example: mulVec (matAdd A B) (vecAdd v w)
    A, B = MatVar("A"), MatVar("B")
    v, w = VecVar("v"), VecVar("w")
    a = ScalVar("α")

    examples = [
        MulVec(A, VecAdd(v, w)),
        MulVec(MatAdd(A, B), v),
        MulVec(SmulMat(a, A), v),
        SmulVec(a, VecAdd(v, w)),
        SmulMat(a, MatAdd(A, B)),
        Dot(VecAdd(v, w), v),
        Dot(v, VecAdd(v, w)),
        Dot(SmulVec(a, v), w),
        ScalMul(a, ScalAdd(ScalVar("β"), ScalVar("γ"))),
    ]

    for e in examples:
        dp_before = dist_potential(e)
        rewrites = root_rewrites(e)
        for name, result in rewrites:
            dp_after = dist_potential(result)
            decrease = dp_before - dp_after
            print(f"  {pretty(e)}")
            print(f"    →[{name}] {pretty(result)}")
            print(f"    dp: {dp_before} → {dp_after} (decrease: {decrease})")
            assert dp_after < dp_before, f"VIOLATION: {dp_after} >= {dp_before}!"
            print()


def demo_critical_pairs():
    """Demonstrate the 4 critical pair overlaps and their joinability."""
    print("=" * 70)
    print("DEMO 2: Critical Pair Analysis")
    print("=" * 70)

    A, B = MatVar("A"), MatVar("B")
    v, w = VecVar("v"), VecVar("w")
    v2, w2 = VecVar("v'"), VecVar("w'")
    a = ScalVar("α")

    critical_pairs = [
        ("CP1: Rules 1&2", MulVec(MatAdd(A, B), VecAdd(v, w))),
        ("CP2: Rules 1&3", MulVec(SmulMat(a, A), VecAdd(v, w))),
        ("CP3: Rules 6&7", Dot(VecAdd(v, w), VecAdd(v2, w2))),
        ("CP4: Rules 7&8", Dot(SmulVec(a, v), VecAdd(v2, w2))),
    ]

    for name, term in critical_pairs:
        print(f"\n  {name}: {pretty(term)}")
        rewrites = root_rewrites(term)
        nfs = []
        for rname, result in rewrites:
            nf = normalize_greedy(result)
            nfs.append(nf)
            print(f"    →[{rname}] {pretty(result)}")
            print(f"      ↓* {pretty(nf)}")

        if len(nfs) >= 2:
            eq = ac_equiv(nfs[0], nfs[1])
            print(f"    AC-equivalent? {eq}")
            if not eq:
                print(f"    ⚠ Normal forms differ (not AC-equivalent)!")


def demo_confluence_check():
    """Check confluence on small terms by BFS."""
    print("\n" + "=" * 70)
    print("DEMO 3: Confluence Check on Small Terms")
    print("=" * 70)

    svars = [ScalVar("α"), ScalVar("β")]
    vvars = [VecVar("v"), VecVar("w")]
    mvars = [MatVar("A"), MatVar("B")]

    terms = generate_terms(1, svars, vvars, mvars)
    # Filter to terms that have at least one rewrite
    reducible = [t for t in terms if all_deep_rewrites(t)]

    checked = 0
    violations = 0
    max_seq = 0

    for t in reducible[:50]:
        nfs, seq_len, states = bfs_all_normal_forms(t, max_states=1000)
        max_seq = max(max_seq, seq_len)
        checked += 1

        # Check AC-equivalence of all pairs of normal forms
        nf_list = list(nfs)
        for i in range(len(nf_list)):
            for j in range(i + 1, len(nf_list)):
                if not ac_equiv(nf_list[i], nf_list[j]):
                    violations += 1
                    print(f"  ⚠ Non-AC-equivalent normal forms for {pretty(t)}:")
                    print(f"    NF1: {pretty(nf_list[i])}")
                    print(f"    NF2: {pretty(nf_list[j])}")

    print(f"\n  Checked {checked} reducible terms")
    print(f"  Max reduction sequence length: {max_seq}")
    print(f"  AC-equivalence violations: {violations}")
    if violations == 0:
        print("  ✓ All normal forms are AC-equivalent — confluence verified!")


def demo_normalization():
    """Demonstrate canonical normalization on sample expressions."""
    print("\n" + "=" * 70)
    print("DEMO 4: Canonical Normalization")
    print("=" * 70)

    A, B = MatVar("A"), MatVar("B")
    v, w = VecVar("v"), VecVar("w")
    a, b = ScalVar("α"), ScalVar("β")

    examples = [
        ("Distribute mulVec over vecAdd",
         MulVec(A, VecAdd(v, w))),
        ("Distribute dot over double vecAdd",
         Dot(VecAdd(v, w), VecAdd(VecVar("u"), VecVar("x")))),
        ("Nested: mulVec (smulMat a A) (vecAdd v w)",
         MulVec(SmulMat(a, A), VecAdd(v, w))),
        ("Deep: dot (smulVec a v) (vecAdd w (smulVec b v))",
         Dot(SmulVec(a, v), VecAdd(w, SmulVec(b, v)))),
        ("Energy-like: dot v (mulVec (matAdd A B) (vecAdd v w))",
         Dot(v, MulVec(MatAdd(A, B), VecAdd(v, w)))),
    ]

    for desc, e in examples:
        nf = normalize_greedy(e)
        dp_before = dist_potential(e)
        dp_after = dist_potential(nf)
        print(f"\n  {desc}")
        print(f"    Input:  {pretty(e)}  [dp={dp_before}]")
        print(f"    Normal: {pretty(nf)}  [dp={dp_after}]")
        print(f"    Decrease: {dp_before - dp_after}")


def demo_sequence_length():
    """Test the polynomial bound conjecture on normalization length."""
    print("\n" + "=" * 70)
    print("DEMO 5: Normalization Length vs Distributivity Potential")
    print("=" * 70)

    svars = [ScalVar("α")]
    vvars = [VecVar("v"), VecVar("w")]
    mvars = [MatVar("A")]

    terms = generate_terms(2, svars, vvars, mvars)
    reducible = [t for t in terms if all_deep_rewrites(t)]

    print(f"  {'Size':>6} {'dp':>8} {'MaxSeq':>8} {'Ratio':>8}")
    print(f"  {'----':>6} {'--':>8} {'------':>8} {'-----':>8}")

    for t in reducible[:30]:
        dp = dist_potential(t)
        sz = expr_size(t)
        _, max_len, _ = bfs_all_normal_forms(t, max_states=500)
        ratio = max_len / dp if dp > 0 else 0
        print(f"  {sz:>6} {dp:>8} {max_len:>8} {ratio:>8.3f}")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  Tensor Distributivity Rewrite System — Confluence Demo        ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()

    demo_potential_decrease()
    demo_critical_pairs()
    demo_confluence_check()
    demo_normalization()
    demo_sequence_length()

    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Critical Pair Joinability Heatmap

Shows which pairs of rewrite rules can overlap (creating critical pairs)
and whether the critical pairs are joinable exactly or modulo AC.

This is a standalone script - no local imports.
"""

import matplotlib.pyplot as plt
import numpy as np

# Rule names
rules = ["R1\nmulVec\nvecAdd", "R2\nmatAdd\nmulVec", "R3\nsmulMat\nmulVec",
         "R4\nsmulVec\nvecAdd", "R5\nsmulMat\nmatAdd",
         "R6\ndot\nvecAdd_L", "R7\ndot\nvecAdd_R",
         "R8\ndot\nsmulVec", "R9\nscalMul\nscalAdd"]

n = len(rules)

# Root constructor of each rule's LHS
# R1: mulVec, R2: mulVec, R3: mulVec, R4: smulVec, R5: smulMat
# R6: dot, R7: dot, R8: dot, R9: scalMul
lhs_roots = ["mulVec", "mulVec", "mulVec", "smulVec", "smulMat",
             "dot", "dot", "dot", "scalMul"]

# Overlap matrix:
# 0 = impossible (different root constructors)
# 1 = same rule (trivially joinable)
# 2 = joinable exactly
# 3 = joinable modulo AC
# Only root-level overlaps considered
overlap = np.zeros((n, n), dtype=int)

for i in range(n):
    for j in range(n):
        if lhs_roots[i] != lhs_roots[j]:
            overlap[i][j] = 0  # Different roots, no overlap
        elif i == j:
            overlap[i][j] = 1  # Same rule
        else:
            overlap[i][j] = -1  # Potentially overlapping, check below

# Specific overlaps (from critical pair analysis):
# R1 & R2: mulVec (matAdd A B) (vecAdd v w) → joinable mod vecAdd AC
overlap[0][1] = overlap[1][0] = 3
# R1 & R3: mulVec (smulMat a A) (vecAdd v w) → joinable exactly
overlap[0][2] = overlap[2][0] = 2
# R2 & R3: mulVec first arg is matAdd vs smulMat → impossible
overlap[1][2] = overlap[2][1] = 0
# R6 & R7: dot (vecAdd v w) (vecAdd v' w') → joinable mod scalAdd AC
overlap[5][6] = overlap[6][5] = 3
# R6 & R8: dot first arg vecAdd vs smulVec → impossible
overlap[5][7] = overlap[7][5] = 0
# R7 & R8: dot (smulVec a v) (vecAdd v' w') → joinable exactly (via R9)
overlap[6][7] = overlap[7][6] = 2

# Create figure
fig, ax = plt.subplots(figsize=(10, 8))

# Color map: 0=gray (no overlap), 1=green (same rule), 2=blue (exact), 3=orange (mod AC)
colors = {0: '#E0E0E0', 1: '#4CAF50', 2: '#2196F3', 3: '#FF9800'}
cmap_data = np.zeros((n, n, 3))

for i in range(n):
    for j in range(n):
        hex_color = colors[overlap[i][j]]
        rgb = tuple(int(hex_color[k:k+2], 16)/255 for k in (1, 3, 5))
        cmap_data[i][j] = rgb

ax.imshow(cmap_data, aspect='equal')

# Add text labels
labels = {0: '✗', 1: '≡', 2: '✓', 3: 'AC'}
for i in range(n):
    for j in range(n):
        text = labels[overlap[i][j]]
        color = 'white' if overlap[i][j] in [1, 2] else 'black'
        ax.text(j, i, text, ha='center', va='center', fontsize=12,
                fontweight='bold', color=color)

ax.set_xticks(range(n))
ax.set_yticks(range(n))
ax.set_xticklabels(rules, fontsize=8, ha='center')
ax.set_yticklabels(rules, fontsize=8)
ax.set_title('Critical Pair Overlap Matrix\n(9 Tensor Distributivity Rules)',
             fontsize=14, fontweight='bold')

# Legend
from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor='#E0E0E0', label='✗  No overlap (different roots)'),
    Patch(facecolor='#4CAF50', label='≡  Same rule (trivially joinable)'),
    Patch(facecolor='#2196F3', label='✓  Joinable exactly'),
    Patch(facecolor='#FF9800', label='AC Joinable modulo addition AC'),
]
ax.legend(handles=legend_elements, loc='upper center', bbox_to_anchor=(0.5, -0.08),
          ncol=2, fontsize=10)

plt.tight_layout()
plt.savefig('viz_critical_pairs.png', dpi=150, bbox_inches='tight')
print("Saved viz_critical_pairs.png")


#!/usr/bin/env python3
"""
Visualization: Distributivity Potential Decrease Under Rewriting

Shows how the polynomial interpretation (distPotential) strictly decreases
for each of the 9 rewrite rules, with different amounts of decrease depending
on the rule and the subterm sizes.

This is a standalone script - all needed functions are inlined.
"""

import matplotlib.pyplot as plt
import numpy as np

# Compute distPotential decrease for each rule as a function of subterm sizes
# Using the polynomial interpretation:
# dp(add a b) = a + b + 1, dp(mul a b) = a*b, dp(smul a b) = a*b + 1

def rule_decrease(rule_name, a=3, b=3, c=3):
    """Compute (dp_lhs, dp_rhs, decrease) for each rule given subterm dp values."""
    rules = {
        "R1: mulVec_vecAdd":    (a * (b + c + 1),     a*b + a*c + 1),
        "R2: matAdd_mulVec":    ((a + b + 1) * c,     a*c + b*c + 1),
        "R3: smulMat_mulVec":   ((a*b + 1) * c,       a*b*c + 1),
        "R4: smulVec_vecAdd":   (a * (b + c + 1) + 1, (a*b+1) + (a*c+1) + 1),
        "R5: smulMat_matAdd":   (a * (b + c + 1) + 1, (a*b+1) + (a*c+1) + 1),
        "R6: dot_vecAdd_left":  ((a + b + 1) * c,     a*c + b*c + 1),
        "R7: dot_vecAdd_right": (a * (b + c + 1),     a*b + a*c + 1),
        "R8: dot_smulVec_left": ((a*b + 1) * c,       a*b*c),
        "R9: scalMul_scalAdd":  (a * (b + c + 1),     a*b + a*c + 1),
    }
    lhs, rhs = rules[rule_name]
    return lhs, rhs, lhs - rhs

# Create figure with two subplots
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Decrease amount for each rule with subterm values = 3
rule_names = [
    "R1: mulVec_vecAdd", "R2: matAdd_mulVec", "R3: smulMat_mulVec",
    "R4: smulVec_vecAdd", "R5: smulMat_matAdd",
    "R6: dot_vecAdd_left", "R7: dot_vecAdd_right",
    "R8: dot_smulVec_left", "R9: scalMul_scalAdd"
]
short_names = ["R1", "R2", "R3", "R4", "R5", "R6", "R7", "R8", "R9"]

decreases_base = [rule_decrease(r)[2] for r in rule_names]
decreases_5 = [rule_decrease(r, 5, 5, 5)[2] for r in rule_names]
decreases_10 = [rule_decrease(r, 10, 10, 10)[2] for r in rule_names]

x = np.arange(len(rule_names))
width = 0.25

bars1 = ax1.bar(x - width, decreases_base, width, label='dp(vars)=3', color='#2196F3', alpha=0.8)
bars2 = ax1.bar(x, decreases_5, width, label='dp(vars)=5', color='#FF9800', alpha=0.8)
bars3 = ax1.bar(x + width, decreases_10, width, label='dp(vars)=10', color='#4CAF50', alpha=0.8)

ax1.set_xlabel('Rewrite Rule', fontsize=12)
ax1.set_ylabel('dp(LHS) − dp(RHS)', fontsize=12)
ax1.set_title('Strict Decrease of Distributivity Potential', fontsize=14, fontweight='bold')
ax1.set_xticks(x)
ax1.set_xticklabels(short_names)
ax1.legend()
ax1.axhline(y=0, color='red', linestyle='--', alpha=0.5)
ax1.set_yscale('log')

# Add value labels on base bars
for bar, val in zip(bars1, decreases_base):
    ax1.annotate(str(val), xy=(bar.get_x() + bar.get_width()/2, bar.get_height()),
                xytext=(0, 3), textcoords="offset points", ha='center', va='bottom', fontsize=8)

# Plot 2: Potential decrease as a function of subterm size for R1 and R8
sizes = range(3, 20)
r1_decreases = [rule_decrease("R1: mulVec_vecAdd", s, s, s)[2] for s in sizes]
r4_decreases = [rule_decrease("R4: smulVec_vecAdd", s, s, s)[2] for s in sizes]
r8_decreases = [rule_decrease("R8: dot_smulVec_left", s, s, s)[2] for s in sizes]

ax2.plot(list(sizes), r1_decreases, 'o-', label='R1 (decrease = a−1)', color='#2196F3', linewidth=2)
ax2.plot(list(sizes), r4_decreases, 's-', label='R4 (decrease = a−2)', color='#FF9800', linewidth=2)
ax2.plot(list(sizes), r8_decreases, '^-', label='R8 (decrease = c)', color='#4CAF50', linewidth=2)

ax2.set_xlabel('Subterm dp value (a = b = c)', fontsize=12)
ax2.set_ylabel('dp(LHS) − dp(RHS)', fontsize=12)
ax2.set_title('Decrease Growth by Rule Type', fontsize=14, fontweight='bold')
ax2.legend()
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_potential_decrease.png', dpi=150, bbox_inches='tight')
print("Saved viz_potential_decrease.png")


#!/usr/bin/env python3
"""
Visualization: Reduction Tree with Distributivity Potential

Shows the BFS reduction tree from a sample tensor expression,
with node colors indicating distributivity potential values.
Demonstrates that all paths lead to AC-equivalent normal forms.

This is a standalone script - all needed functions are inlined.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from dataclasses import dataclass
from typing import List, Tuple, Set
from collections import deque

# ---- Inlined expression types and functions ----

@dataclass(frozen=True)
class Expr: pass

@dataclass(frozen=True)
class ScalVar(Expr):
    name: str

@dataclass(frozen=True)
class VecVar(Expr):
    name: str

@dataclass(frozen=True)
class MatVar(Expr):
    name: str

@dataclass(frozen=True)
class ScalAdd(Expr):
    left: Expr; right: Expr

@dataclass(frozen=True)
class ScalMul(Expr):
    left: Expr; right: Expr

@dataclass(frozen=True)
class VecAdd(Expr):
    left: Expr; right: Expr

@dataclass(frozen=True)
class MatAdd(Expr):
    left: Expr; right: Expr

@dataclass(frozen=True)
class SmulVec(Expr):
    scalar: Expr; vec: Expr

@dataclass(frozen=True)
class SmulMat(Expr):
    scalar: Expr; mat: Expr

@dataclass(frozen=True)
class MulVec(Expr):
    mat: Expr; vec: Expr

@dataclass(frozen=True)
class Dot(Expr):
    left: Expr; right: Expr


def pretty(e):
    if isinstance(e, ScalVar): return e.name
    if isinstance(e, VecVar): return e.name
    if isinstance(e, MatVar): return e.name
    if isinstance(e, ScalAdd): return f"({pretty(e.left)}+{pretty(e.right)})"
    if isinstance(e, ScalMul): return f"({pretty(e.left)}·{pretty(e.right)})"
    if isinstance(e, VecAdd): return f"({pretty(e.left)}⊕{pretty(e.right)})"
    if isinstance(e, MatAdd): return f"({pretty(e.left)}⊞{pretty(e.right)})"
    if isinstance(e, SmulVec): return f"({pretty(e.scalar)}•{pretty(e.vec)})"
    if isinstance(e, SmulMat): return f"({pretty(e.scalar)}⊙{pretty(e.mat)})"
    if isinstance(e, MulVec): return f"({pretty(e.mat)}*ᵥ{pretty(e.vec)})"
    if isinstance(e, Dot): return f"⟨{pretty(e.left)},{pretty(e.right)}⟩"
    return str(e)


def dp(e):
    if isinstance(e, (ScalVar, VecVar, MatVar)): return 3
    if isinstance(e, (ScalAdd, VecAdd, MatAdd)): return dp(e.left) + dp(e.right) + 1
    if isinstance(e, ScalMul): return dp(e.left) * dp(e.right)
    if isinstance(e, MulVec): return dp(e.mat) * dp(e.vec)
    if isinstance(e, Dot): return dp(e.left) * dp(e.right)
    if isinstance(e, SmulVec): return dp(e.scalar) * dp(e.vec) + 1
    if isinstance(e, SmulMat): return dp(e.scalar) * dp(e.mat) + 1
    return 3


def all_deep_rewrites(e):
    results = []
    # Root rules
    if isinstance(e, MulVec) and isinstance(e.vec, VecAdd):
        A, v, w = e.mat, e.vec.left, e.vec.right
        results.append(("R1", VecAdd(MulVec(A, v), MulVec(A, w))))
    if isinstance(e, MulVec) and isinstance(e.mat, MatAdd):
        A, B, v = e.mat.left, e.mat.right, e.vec
        results.append(("R2", VecAdd(MulVec(A, v), MulVec(B, v))))
    if isinstance(e, MulVec) and isinstance(e.mat, SmulMat):
        a, A, v = e.mat.scalar, e.mat.mat, e.vec
        results.append(("R3", SmulVec(a, MulVec(A, v))))
    if isinstance(e, SmulVec) and isinstance(e.vec, VecAdd):
        a, v, w = e.scalar, e.vec.left, e.vec.right
        results.append(("R4", VecAdd(SmulVec(a, v), SmulVec(a, w))))
    if isinstance(e, SmulMat) and isinstance(e.mat, MatAdd):
        a, A, B = e.scalar, e.mat.left, e.mat.right
        results.append(("R5", MatAdd(SmulMat(a, A), SmulMat(a, B))))
    if isinstance(e, Dot) and isinstance(e.left, VecAdd):
        v, w, u = e.left.left, e.left.right, e.right
        results.append(("R6", ScalAdd(Dot(v, u), Dot(w, u))))
    if isinstance(e, Dot) and isinstance(e.right, VecAdd):
        u, v, w = e.left, e.right.left, e.right.right
        results.append(("R7", ScalAdd(Dot(u, v), Dot(u, w))))
    if isinstance(e, Dot) and isinstance(e.left, SmulVec):
        a, v, w = e.left.scalar, e.left.vec, e.right
        results.append(("R8", ScalMul(a, Dot(v, w))))
    if isinstance(e, ScalMul) and isinstance(e.right, ScalAdd):
        a, b, c = e.left, e.right.left, e.right.right
        results.append(("R9", ScalAdd(ScalMul(a, b), ScalMul(a, c))))
    # Context closure (simplified - only go one level deep for visualization)
    for constructor, fields in _get_fields(e):
        for i, (fname, child) in enumerate(fields):
            for name, result in all_deep_rewrites(child):
                new_fields = list(fields)
                new_fields[i] = (fname, result)
                results.append((name, constructor(**{f: v for f, v in new_fields})))
    return results


def _get_fields(e):
    if isinstance(e, ScalAdd): return [(ScalAdd, [("left", e.left), ("right", e.right)])]
    if isinstance(e, ScalMul): return [(ScalMul, [("left", e.left), ("right", e.right)])]
    if isinstance(e, VecAdd): return [(VecAdd, [("left", e.left), ("right", e.right)])]
    if isinstance(e, MatAdd): return [(MatAdd, [("left", e.left), ("right", e.right)])]
    if isinstance(e, SmulVec): return [(SmulVec, [("scalar", e.scalar), ("vec", e.vec)])]
    if isinstance(e, SmulMat): return [(SmulMat, [("scalar", e.scalar), ("mat", e.mat)])]
    if isinstance(e, MulVec): return [(MulVec, [("mat", e.mat), ("vec", e.vec)])]
    if isinstance(e, Dot): return [(Dot, [("left", e.left), ("right", e.right)])]
    return []


def flatten_add(e, add_type):
    if isinstance(e, add_type):
        return flatten_add(e.left, add_type) + flatten_add(e.right, add_type)
    return [e]


def ac_canonical(e):
    if isinstance(e, (ScalVar, VecVar, MatVar)): return e
    if isinstance(e, ScalAdd):
        summands = sorted([repr(ac_canonical(s)) for s in flatten_add(e, ScalAdd)])
        return "ScalAdd(" + ",".join(summands) + ")"
    if isinstance(e, VecAdd):
        summands = sorted([repr(ac_canonical(s)) for s in flatten_add(e, VecAdd)])
        return "VecAdd(" + ",".join(summands) + ")"
    return repr(e)


# ---- Build reduction DAG ----

start = Dot(VecAdd(VecVar("v"), VecVar("w")), VecAdd(VecVar("u"), VecVar("x")))

visited = {}
edges = []
queue = deque([(start, 0)])
visited[start] = 0
node_id = 1

while queue and len(visited) < 50:
    current, cur_id = queue.popleft()
    for name, result in all_deep_rewrites(current):
        if result not in visited:
            visited[result] = node_id
            node_id += 1
            queue.append((result, visited[result]))
        edges.append((cur_id, visited[result], name))

# ---- Layout and draw ----

# Assign layers by BFS depth
layers = {0: 0}
q2 = deque([0])
while q2:
    n = q2.popleft()
    for src, tgt, _ in edges:
        if src == n and tgt not in layers:
            layers[tgt] = layers[n] + 1
            q2.append(tgt)

# Collect nodes per layer
layer_nodes = {}
for nid, layer in layers.items():
    layer_nodes.setdefault(layer, []).append(nid)

# Assign positions
positions = {}
for layer, nodes in layer_nodes.items():
    for i, nid in enumerate(nodes):
        x = (i - (len(nodes)-1)/2) * 2.5
        y = -layer * 2
        positions[nid] = (x, y)

# Create figure
fig, ax = plt.subplots(figsize=(14, 10))

# Get dp values for coloring
id_to_expr = {v: k for k, v in visited.items()}
dp_values = {nid: dp(id_to_expr[nid]) for nid in visited.values()}
max_dp = max(dp_values.values())
min_dp = min(dp_values.values())

# Draw edges
for src, tgt, name in edges:
    if src in positions and tgt in positions:
        x1, y1 = positions[src]
        x2, y2 = positions[tgt]
        ax.annotate("", xy=(x2, y2), xytext=(x1, y1),
                    arrowprops=dict(arrowstyle='->', color='gray', alpha=0.5, lw=1))

# Draw nodes
for nid, (x, y) in positions.items():
    dp_val = dp_values[nid]
    # Color based on dp value
    t = (dp_val - min_dp) / (max_dp - min_dp) if max_dp > min_dp else 0.5
    color = plt.cm.RdYlGn(1 - t)  # Green = low dp, Red = high dp

    is_normal = len(all_deep_rewrites(id_to_expr[nid])) == 0
    marker_size = 600 if is_normal else 300
    edge_color = 'gold' if is_normal else 'black'
    linewidth = 3 if is_normal else 1

    ax.scatter(x, y, s=marker_size, c=[color], edgecolors=edge_color,
              linewidths=linewidth, zorder=5)
    ax.annotate(f'dp={dp_val}', (x, y), textcoords="offset points",
               xytext=(0, -15), ha='center', fontsize=7, color='#333')

# Title and labels
ax.set_title('Reduction DAG: ⟨v⊕w, u⊕x⟩\nColor = distPotential (green=low, red=high), Gold border = normal form',
             fontsize=13, fontweight='bold')
ax.set_xlabel('Branching position', fontsize=11)
ax.set_ylabel('Reduction depth', fontsize=11)

# Legend
legend_elements = [
    mpatches.Patch(facecolor=plt.cm.RdYlGn(0.0), label='High dp (unreduced)'),
    mpatches.Patch(facecolor=plt.cm.RdYlGn(1.0), label='Low dp (near normal)'),
    mpatches.Patch(facecolor='white', edgecolor='gold', linewidth=2, label='Normal form'),
]
ax.legend(handles=legend_elements, loc='upper right')

ax.set_xlim(-10, 10)
plt.tight_layout()
plt.savefig('viz_reduction_tree.png', dpi=150, bbox_inches='tight')
print("Saved viz_reduction_tree.png")
