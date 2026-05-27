#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for tensor expression normalization

Implements the canonical normalization algorithm for the 9-rule distributivity
fragment on sorted tensor expressions. Includes:
- Distributivity potential computation
- Greedy and exhaustive normalization
- AC-canonical form computation
- Critical pair analysis

Keywords: term rewriting, canonical normal forms, tensor algebra,
symbolic optimization, compiler correctness
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import List, Tuple, Optional, Dict
from collections import Counter
import itertools


# ─────────────────────────────────────────────────────────────────
# Expression types (same as demo.py, inlined for self-containment)
# ─────────────────────────────────────────────────────────────────

@dataclass(frozen=True)
class Expr:
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


# ─────────────────────────────────────────────────────────────────
# Algorithm 1: Distributivity Potential
# ─────────────────────────────────────────────────────────────────

def dist_potential(t: Expr) -> int:
    """
    Compute the distributivity potential (polynomial interpretation).

    Design:
    - Variables → 3 (ensures dp ≥ 3 everywhere)
    - Additive nodes → sum + 1 (overhead consumed by distribution)
    - Multiplicative nodes → product
    - Action nodes → product + 1 (handles extraction rules)

    Time complexity: O(n) where n = expr_size(t)
    Space complexity: O(depth(t)) stack
    """
    if isinstance(t, (ScalVar, VecVar, MatVar)):
        return 3
    elif isinstance(t, ScalAdd):
        return dist_potential(t.left) + dist_potential(t.right) + 1
    elif isinstance(t, ScalMul):
        return dist_potential(t.left) * dist_potential(t.right)
    elif isinstance(t, VecAdd):
        return dist_potential(t.left) + dist_potential(t.right) + 1
    elif isinstance(t, MatAdd):
        return dist_potential(t.left) + dist_potential(t.right) + 1
    elif isinstance(t, SmulVec):
        return dist_potential(t.scalar) * dist_potential(t.vec) + 1
    elif isinstance(t, SmulMat):
        return dist_potential(t.scalar) * dist_potential(t.mat) + 1
    elif isinstance(t, MulVec):
        return dist_potential(t.mat) * dist_potential(t.vec)
    elif isinstance(t, Dot):
        return dist_potential(t.left) * dist_potential(t.right)
    return 3


# ─────────────────────────────────────────────────────────────────
# Algorithm 2: One-Step Root Normalization
# ─────────────────────────────────────────────────────────────────

def norm_once(t: Expr) -> Tuple[Optional[str], Expr]:
    """
    Apply one root-level rewrite rule if possible.

    Returns (rule_name, result) or (None, t) if no rule applies.

    Time complexity: O(1) pattern matching
    Space complexity: O(1) (creates new nodes)
    """
    # Rule 1: mulVec A (vecAdd v w) → vecAdd (mulVec A v) (mulVec A w)
    if isinstance(t, MulVec) and isinstance(t.vec, VecAdd):
        A, v, w = t.mat, t.vec.left, t.vec.right
        return ("R1", VecAdd(MulVec(A, v), MulVec(A, w)))

    # Rule 2: mulVec (matAdd A B) v → vecAdd (mulVec A v) (mulVec B v)
    if isinstance(t, MulVec) and isinstance(t.mat, MatAdd):
        A, B, v = t.mat.left, t.mat.right, t.vec
        return ("R2", VecAdd(MulVec(A, v), MulVec(B, v)))

    # Rule 3: mulVec (smulMat a A) v → smulVec a (mulVec A v)
    if isinstance(t, MulVec) and isinstance(t.mat, SmulMat):
        a, A, v = t.mat.scalar, t.mat.mat, t.vec
        return ("R3", SmulVec(a, MulVec(A, v)))

    # Rule 4: smulVec a (vecAdd v w) → vecAdd (smulVec a v) (smulVec a w)
    if isinstance(t, SmulVec) and isinstance(t.vec, VecAdd):
        a, v, w = t.scalar, t.vec.left, t.vec.right
        return ("R4", VecAdd(SmulVec(a, v), SmulVec(a, w)))

    # Rule 5: smulMat a (matAdd A B) → matAdd (smulMat a A) (smulMat a B)
    if isinstance(t, SmulMat) and isinstance(t.mat, MatAdd):
        a, A, B = t.scalar, t.mat.left, t.mat.right
        return ("R5", MatAdd(SmulMat(a, A), SmulMat(a, B)))

    # Rule 6: dot (vecAdd v w) u → scalAdd (dot v u) (dot w u)
    if isinstance(t, Dot) and isinstance(t.left, VecAdd):
        v, w, u = t.left.left, t.left.right, t.right
        return ("R6", ScalAdd(Dot(v, u), Dot(w, u)))

    # Rule 7: dot u (vecAdd v w) → scalAdd (dot u v) (dot u w)
    if isinstance(t, Dot) and isinstance(t.right, VecAdd):
        u, v, w = t.left, t.right.left, t.right.right
        return ("R7", ScalAdd(Dot(u, v), Dot(u, w)))

    # Rule 8: dot (smulVec a v) w → scalMul a (dot v w)
    if isinstance(t, Dot) and isinstance(t.left, SmulVec):
        a, v, w = t.left.scalar, t.left.vec, t.right
        return ("R8", ScalMul(a, Dot(v, w)))

    # Rule 9: scalMul a (scalAdd b c) → scalAdd (scalMul a b) (scalMul a c)
    if isinstance(t, ScalMul) and isinstance(t.right, ScalAdd):
        a, b, c = t.left, t.right.left, t.right.right
        return ("R9", ScalAdd(ScalMul(a, b), ScalMul(a, c)))

    return (None, t)


# ─────────────────────────────────────────────────────────────────
# Algorithm 3: Deep Normalization (Bottom-Up)
# ─────────────────────────────────────────────────────────────────

def normalize_deep(t: Expr) -> Expr:
    """
    Normalize bottom-up: first normalize subterms, then apply root rules
    repeatedly until no more rules apply.

    Time complexity: O(dp(t)) where dp is distributivity potential
    Space complexity: O(depth(t) * dp(t))
    """
    # Step 1: Normalize subterms recursively
    if isinstance(t, ScalAdd):
        t = ScalAdd(normalize_deep(t.left), normalize_deep(t.right))
    elif isinstance(t, ScalMul):
        t = ScalMul(normalize_deep(t.left), normalize_deep(t.right))
    elif isinstance(t, VecAdd):
        t = VecAdd(normalize_deep(t.left), normalize_deep(t.right))
    elif isinstance(t, MatAdd):
        t = MatAdd(normalize_deep(t.left), normalize_deep(t.right))
    elif isinstance(t, SmulVec):
        t = SmulVec(normalize_deep(t.scalar), normalize_deep(t.vec))
    elif isinstance(t, SmulMat):
        t = SmulMat(normalize_deep(t.scalar), normalize_deep(t.mat))
    elif isinstance(t, MulVec):
        t = MulVec(normalize_deep(t.mat), normalize_deep(t.vec))
    elif isinstance(t, Dot):
        t = Dot(normalize_deep(t.left), normalize_deep(t.right))

    # Step 2: Apply root rules repeatedly
    while True:
        rule, t_new = norm_once(t)
        if rule is None:
            break
        # After root rule, need to re-normalize new subterms
        t = normalize_deep(t_new)

    return t


# ─────────────────────────────────────────────────────────────────
# Algorithm 4: AC-Canonical Form
# ─────────────────────────────────────────────────────────────────

def flatten_add(t: Expr, add_cls) -> List[Expr]:
    """Flatten nested additions into a list of summands."""
    if isinstance(t, add_cls):
        return flatten_add(t.left, add_cls) + flatten_add(t.right, add_cls)
    return [t]


def ac_sort_key(t: Expr) -> str:
    """Generate a sort key for AC canonicalization."""
    if isinstance(t, ScalVar): return f"0s{t.name}"
    if isinstance(t, VecVar): return f"0v{t.name}"
    if isinstance(t, MatVar): return f"0m{t.name}"
    if isinstance(t, ScalAdd): return f"1+{ac_sort_key(t.left)},{ac_sort_key(t.right)}"
    if isinstance(t, ScalMul): return f"2*{ac_sort_key(t.left)},{ac_sort_key(t.right)}"
    if isinstance(t, VecAdd): return f"3+{ac_sort_key(t.left)},{ac_sort_key(t.right)}"
    if isinstance(t, MatAdd): return f"4+{ac_sort_key(t.left)},{ac_sort_key(t.right)}"
    if isinstance(t, SmulVec): return f"5s{ac_sort_key(t.scalar)},{ac_sort_key(t.vec)}"
    if isinstance(t, SmulMat): return f"6s{ac_sort_key(t.scalar)},{ac_sort_key(t.mat)}"
    if isinstance(t, MulVec): return f"7m{ac_sort_key(t.mat)},{ac_sort_key(t.vec)}"
    if isinstance(t, Dot): return f"8d{ac_sort_key(t.left)},{ac_sort_key(t.right)}"
    return repr(t)


def rebuild_add(summands: List[Expr], add_cls) -> Expr:
    """Rebuild a right-associated addition from sorted summands."""
    assert len(summands) > 0
    if len(summands) == 1:
        return summands[0]
    return add_cls(summands[0], rebuild_add(summands[1:], add_cls))


def ac_canonicalize(t: Expr) -> Expr:
    """
    Canonicalize addition nodes: flatten, sort, right-associate.

    This is the AC-normalization step that makes normal forms unique.

    Time complexity: O(n log n) where n = expr_size(t)
    Space complexity: O(n)
    """
    # First recursively canonicalize subterms
    if isinstance(t, ScalAdd):
        summands = flatten_add(t, ScalAdd)
        summands = [ac_canonicalize(s) for s in summands]
        summands.sort(key=ac_sort_key)
        return rebuild_add(summands, ScalAdd)
    elif isinstance(t, VecAdd):
        summands = flatten_add(t, VecAdd)
        summands = [ac_canonicalize(s) for s in summands]
        summands.sort(key=ac_sort_key)
        return rebuild_add(summands, VecAdd)
    elif isinstance(t, MatAdd):
        summands = flatten_add(t, MatAdd)
        summands = [ac_canonicalize(s) for s in summands]
        summands.sort(key=ac_sort_key)
        return rebuild_add(summands, MatAdd)
    elif isinstance(t, ScalMul):
        return ScalMul(ac_canonicalize(t.left), ac_canonicalize(t.right))
    elif isinstance(t, SmulVec):
        return SmulVec(ac_canonicalize(t.scalar), ac_canonicalize(t.vec))
    elif isinstance(t, SmulMat):
        return SmulMat(ac_canonicalize(t.scalar), ac_canonicalize(t.mat))
    elif isinstance(t, MulVec):
        return MulVec(ac_canonicalize(t.mat), ac_canonicalize(t.vec))
    elif isinstance(t, Dot):
        return Dot(ac_canonicalize(t.left), ac_canonicalize(t.right))
    return t


# ─────────────────────────────────────────────────────────────────
# Algorithm 5: Full Canonical Normalization
# ─────────────────────────────────────────────────────────────────

def normalize_canon(t: Expr) -> Expr:
    """
    Full canonical normalization: apply distributivity rules to saturation,
    then AC-canonicalize.

    This is the main algorithm. Its output is a canonical representative
    of the AC-equivalence class of the normal form.

    Time complexity: O(dp(t) · n log n) where n is the final size
    Space complexity: O(n)
    """
    nf = normalize_deep(t)
    return ac_canonicalize(nf)


# ─────────────────────────────────────────────────────────────────
# Algorithm 6: Critical Pair Enumeration
# ─────────────────────────────────────────────────────────────────

def enumerate_critical_pairs() -> List[dict]:
    """
    Enumerate all critical pairs among the 9 rewrite rules.

    A critical pair arises when two rules can apply to the same term
    at the root position. Returns analysis of each overlap.
    """
    pairs = []

    # Rules 1 & 2: mulVec (matAdd A B) (vecAdd v w)
    A, B, v, w = MatVar("A"), MatVar("B"), VecVar("v"), VecVar("w")
    t = MulVec(MatAdd(A, B), VecAdd(v, w))
    r1 = VecAdd(MulVec(MatAdd(A, B), v), MulVec(MatAdd(A, B), w))
    r2 = VecAdd(MulVec(A, VecAdd(v, w)), MulVec(B, VecAdd(v, w)))
    nf1 = normalize_canon(r1)
    nf2 = normalize_canon(r2)
    pairs.append({
        "rules": "1 & 2",
        "overlap_term": t,
        "result_1": r1,
        "result_2": r2,
        "nf_1": nf1,
        "nf_2": nf2,
        "joinable": nf1 == nf2,
        "needs_ac": repr(normalize_deep(r1)) != repr(normalize_deep(r2))
    })

    # Rules 1 & 3: mulVec (smulMat a A) (vecAdd v w)
    a = ScalVar("a")
    t = MulVec(SmulMat(a, A), VecAdd(v, w))
    r1 = VecAdd(MulVec(SmulMat(a, A), v), MulVec(SmulMat(a, A), w))
    r3 = SmulVec(a, MulVec(A, VecAdd(v, w)))
    nf1 = normalize_canon(r1)
    nf3 = normalize_canon(r3)
    pairs.append({
        "rules": "1 & 3",
        "overlap_term": t,
        "result_1": r1,
        "result_3": r3,
        "nf_1": nf1,
        "nf_3": nf3,
        "joinable": nf1 == nf3,
        "needs_ac": False
    })

    # Rules 6 & 7: dot (vecAdd v w) (vecAdd u x)
    u, x = VecVar("u"), VecVar("x")
    t = Dot(VecAdd(v, w), VecAdd(u, x))
    r6 = ScalAdd(Dot(v, VecAdd(u, x)), Dot(w, VecAdd(u, x)))
    r7 = ScalAdd(Dot(VecAdd(v, w), u), Dot(VecAdd(v, w), x))
    nf6 = normalize_canon(r6)
    nf7 = normalize_canon(r7)
    pairs.append({
        "rules": "6 & 7",
        "overlap_term": t,
        "result_6": r6,
        "result_7": r7,
        "nf_6": nf6,
        "nf_7": nf7,
        "joinable": nf6 == nf7,
        "needs_ac": repr(normalize_deep(r6)) != repr(normalize_deep(r7))
    })

    # Rules 7 & 8: dot (smulVec a v) (vecAdd u x)
    t = Dot(SmulVec(a, v), VecAdd(u, x))
    r7 = ScalAdd(Dot(SmulVec(a, v), u), Dot(SmulVec(a, v), x))
    r8 = ScalMul(a, Dot(v, VecAdd(u, x)))
    nf7 = normalize_canon(r7)
    nf8 = normalize_canon(r8)
    pairs.append({
        "rules": "7 & 8",
        "overlap_term": t,
        "result_7": r7,
        "result_8": r8,
        "nf_7": nf7,
        "nf_8": nf8,
        "joinable": nf7 == nf8,
        "needs_ac": False
    })

    return pairs


# ─────────────────────────────────────────────────────────────────
# Main: demonstrate algorithms
# ─────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Tensor Normalization Algorithms")
    print("=" * 50)

    # Example terms
    A, B = MatVar("A"), MatVar("B")
    v, w, u = VecVar("v"), VecVar("w"), VecVar("u")
    a = ScalVar("a")

    examples = [
        ("Matrix-vector dist", MulVec(A, VecAdd(v, w))),
        ("Double dist", MulVec(MatAdd(A, B), VecAdd(v, w))),
        ("Scalar extraction", MulVec(SmulMat(a, A), v)),
        ("Dot bilinearity", Dot(VecAdd(v, w), VecAdd(u, VecVar("x")))),
        ("Scalar over sum", ScalMul(a, ScalAdd(Dot(v, w), Dot(u, v)))),
    ]

    for name, t in examples:
        nf = normalize_canon(t)
        dp = dist_potential(t)
        dp_nf = dist_potential(nf)
        print(f"\n{name}:")
        print(f"  Input:  {t}")
        print(f"  Normal: {nf}")
        print(f"  dp: {dp} → {dp_nf} (reduction: {dp - dp_nf})")

    print("\n" + "=" * 50)
    print("Critical Pair Analysis")
    print("=" * 50)
    for cp in enumerate_critical_pairs():
        print(f"\n  Rules {cp['rules']}:")
        print(f"    Overlap: {cp.get('overlap_term', '?')}")
        print(f"    Joinable: {'✓' if cp['joinable'] else '✗'}")
        print(f"    Needs AC: {'yes' if cp.get('needs_ac') else 'no'}")
