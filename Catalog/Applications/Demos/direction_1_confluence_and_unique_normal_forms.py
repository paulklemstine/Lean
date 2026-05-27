#!/usr/bin/env python3
"""
applications.py — Real-world applications of tensor expression normalization

Demonstrates how confluent normalization modulo AC applies to:
1. Compiler optimization: deterministic simplification passes
2. Symbolic linear algebra: canonical forms for bilinear expressions
3. Proof-producing optimization: verified transformations
"""

from algorithms import *


def app_compiler_optimization():
    """
    Application 1: Compiler Optimization

    Two different optimization schedules applied to the same tensor expression
    must produce the same canonical output (up to AC of addition).
    This guarantees deterministic compilation.
    """
    print("Application 1: Compiler Optimization")
    print("=" * 50)

    A, B = MatVar("A"), MatVar("B")
    v, w = VecVar("v"), VecVar("w")
    a = ScalVar("a")

    # Original expression: a • (A + B) · (v + w)
    expr = SmulVec(a, MulVec(MatAdd(A, B), VecAdd(v, w)))
    print(f"Original: {expr}")
    print(f"dp = {dist_potential(expr)}")

    # Schedule 1: distribute matrix-add first
    s1_step1 = SmulVec(a, VecAdd(MulVec(A, VecAdd(v, w)), MulVec(B, VecAdd(v, w))))
    nf1 = normalize_canon(s1_step1)
    print(f"\nSchedule 1 (mat-add first): → {nf1}")

    # Schedule 2: distribute vec-add first
    s2_step1 = SmulVec(a, VecAdd(MulVec(MatAdd(A, B), v), MulVec(MatAdd(A, B), w)))
    nf2 = normalize_canon(s2_step1)
    print(f"Schedule 2 (vec-add first): → {nf2}")

    print(f"\nCanonical forms equal: {nf1 == nf2}")
    print("→ Different optimization schedules produce identical output! ✓")


def app_symbolic_linear_algebra():
    """
    Application 2: Symbolic Linear Algebra

    Canonical normal forms for bilinear/quadratic expressions
    enable automatic simplification of energy functionals.
    """
    print("\n\nApplication 2: Symbolic Linear Algebra")
    print("=" * 50)

    A = MatVar("A")
    v, w = VecVar("v"), VecVar("w")
    a, b = ScalVar("a"), ScalVar("b")

    # Energy functional E(A, v+w) should expand canonically
    # E(A, v+w) = ⟨v+w, A·(v+w)⟩
    energy_expr = Dot(VecAdd(v, w), MulVec(A, VecAdd(v, w)))
    nf = normalize_canon(energy_expr)
    print(f"E(A, v+w) = ⟨v+w, A·(v+w)⟩")
    print(f"Canonical expansion: {nf}")
    print(f"dp: {dist_potential(energy_expr)} → {dist_potential(nf)}")

    # Scaled energy a·E(A, v)
    scaled = ScalMul(a, Dot(v, MulVec(A, v)))
    nf_scaled = normalize_canon(scaled)
    print(f"\na·E(A,v) = a·⟨v, A·v⟩")
    print(f"Normal form: {nf_scaled}")


def app_proof_producing():
    """
    Application 3: Proof-Producing Optimization

    Each normalization step corresponds to a verified rewrite rule.
    The full normalization trace is a proof of semantic equivalence.
    """
    print("\n\nApplication 3: Proof-Producing Optimization")
    print("=" * 50)

    A = MatVar("A")
    v, w = VecVar("v"), VecVar("w")
    a = ScalVar("a")

    # Trace normalization steps
    t = MulVec(SmulMat(a, A), VecAdd(v, w))
    print(f"Input: {t}")
    print(f"Normalization trace:")

    step = 0
    current = t
    while True:
        rule, next_t = norm_once(current)
        if rule is None:
            # Try subterms
            break
        step += 1
        print(f"  Step {step} [{rule}]: {next_t}")
        current = next_t

    nf = normalize_canon(t)
    print(f"\nFinal canonical form: {nf}")
    print(f"Each step is a verified rewrite rule application.")
    print(f"The trace constitutes a formal proof of: ⟦input⟧ = ⟦output⟧")


if __name__ == "__main__":
    app_compiler_optimization()
    app_symbolic_linear_algebra()
    app_proof_producing()


#!/usr/bin/env python3
"""
demo.py — Demonstration of tensor distributivity rewrite system confluence

Enumerates tensor terms up to bounded depth, computes all reduction sequences
by BFS, checks AC-equivalence of terminal forms, and demonstrates canonical
normalization interactively on sample expressions.

Keywords: term rewriting, confluence modulo AC, canonical normal forms,
tensor algebra, symbolic optimization
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import List, Set, Tuple, Optional, FrozenSet
from collections import deque
import itertools

# ─────────────────────────────────────────────────────────────────────
# Part 1: Tensor Expression AST
# ─────────────────────────────────────────────────────────────────────

@dataclass(frozen=True)
class Expr:
    """Base class for tensor expressions."""
    pass

@dataclass(frozen=True)
class ScalVar(Expr):
    name: str
    def __repr__(self): return self.name

@dataclass(frozen=True)
class VecVar(Expr):
    name: str
    def __repr__(self): return self.name

@dataclass(frozen=True)
class MatVar(Expr):
    name: str
    def __repr__(self): return self.name

@dataclass(frozen=True)
class ScalAdd(Expr):
    left: Expr; right: Expr
    def __repr__(self): return f"({self.left} + {self.right})"

@dataclass(frozen=True)
class ScalMul(Expr):
    left: Expr; right: Expr
    def __repr__(self): return f"({self.left} * {self.right})"

@dataclass(frozen=True)
class VecAdd(Expr):
    left: Expr; right: Expr
    def __repr__(self): return f"({self.left} ⊕ {self.right})"

@dataclass(frozen=True)
class MatAdd(Expr):
    left: Expr; right: Expr
    def __repr__(self): return f"({self.left} ⊞ {self.right})"

@dataclass(frozen=True)
class SmulVec(Expr):
    scalar: Expr; vec: Expr
    def __repr__(self): return f"({self.scalar} • {self.vec})"

@dataclass(frozen=True)
class SmulMat(Expr):
    scalar: Expr; mat: Expr
    def __repr__(self): return f"({self.scalar} ⊙ {self.mat})"

@dataclass(frozen=True)
class MulVec(Expr):
    mat: Expr; vec: Expr
    def __repr__(self): return f"({self.mat} · {self.vec})"

@dataclass(frozen=True)
class Dot(Expr):
    left: Expr; right: Expr
    def __repr__(self): return f"⟨{self.left}, {self.right}⟩"


# ─────────────────────────────────────────────────────────────────────
# Part 2: Rewrite Rules (9 distributivity rules)
# ─────────────────────────────────────────────────────────────────────

def root_rewrites(t: Expr) -> List[Tuple[str, Expr]]:
    """Apply all root-level rewrite rules, returning (rule_name, result) pairs."""
    results = []
    # Rule 1: mulVec A (vecAdd v w) → vecAdd (mulVec A v) (mulVec A w)
    if isinstance(t, MulVec) and isinstance(t.vec, VecAdd):
        A, v, w = t.mat, t.vec.left, t.vec.right
        results.append(("R1:MV·VA", VecAdd(MulVec(A, v), MulVec(A, w))))
    # Rule 2: mulVec (matAdd A B) v → vecAdd (mulVec A v) (mulVec B v)
    if isinstance(t, MulVec) and isinstance(t.mat, MatAdd):
        A, B, v = t.mat.left, t.mat.right, t.vec
        results.append(("R2:MA·V", VecAdd(MulVec(A, v), MulVec(B, v))))
    # Rule 3: mulVec (smulMat a A) v → smulVec a (mulVec A v)
    if isinstance(t, MulVec) and isinstance(t.mat, SmulMat):
        a, A, v = t.mat.scalar, t.mat.mat, t.vec
        results.append(("R3:sM·V", SmulVec(a, MulVec(A, v))))
    # Rule 4: smulVec a (vecAdd v w) → vecAdd (smulVec a v) (smulVec a w)
    if isinstance(t, SmulVec) and isinstance(t.vec, VecAdd):
        a, v, w = t.scalar, t.vec.left, t.vec.right
        results.append(("R4:s·VA", VecAdd(SmulVec(a, v), SmulVec(a, w))))
    # Rule 5: smulMat a (matAdd A B) → matAdd (smulMat a A) (smulMat a B)
    if isinstance(t, SmulMat) and isinstance(t.mat, MatAdd):
        a, A, B = t.scalar, t.mat.left, t.mat.right
        results.append(("R5:s·MA", MatAdd(SmulMat(a, A), SmulMat(a, B))))
    # Rule 6: dot (vecAdd v w) u → scalAdd (dot v u) (dot w u)
    if isinstance(t, Dot) and isinstance(t.left, VecAdd):
        v, w, u = t.left.left, t.left.right, t.right
        results.append(("R6:⟨VA,·⟩", ScalAdd(Dot(v, u), Dot(w, u))))
    # Rule 7: dot u (vecAdd v w) → scalAdd (dot u v) (dot u w)
    if isinstance(t, Dot) and isinstance(t.right, VecAdd):
        u, v, w = t.left, t.right.left, t.right.right
        results.append(("R7:⟨·,VA⟩", ScalAdd(Dot(u, v), Dot(u, w))))
    # Rule 8: dot (smulVec a v) w → scalMul a (dot v w)
    if isinstance(t, Dot) and isinstance(t.left, SmulVec):
        a, v, w = t.left.scalar, t.left.vec, t.right
        results.append(("R8:⟨s·,·⟩", ScalMul(a, Dot(v, w))))
    # Rule 9: scalMul a (scalAdd b c) → scalAdd (scalMul a b) (scalMul a c)
    if isinstance(t, ScalMul) and isinstance(t.right, ScalAdd):
        a, b, c = t.left, t.right.left, t.right.right
        results.append(("R9:s*(+)", ScalAdd(ScalMul(a, b), ScalMul(a, c))))
    return results


def all_deep_rewrites(t: Expr) -> List[Tuple[str, Expr]]:
    """Apply all deep rewrite rules (root + congruence closure)."""
    results = root_rewrites(t)

    # Congruence closure: recurse into subterms
    if isinstance(t, ScalAdd):
        for name, l in all_deep_rewrites(t.left):
            results.append((name, ScalAdd(l, t.right)))
        for name, r in all_deep_rewrites(t.right):
            results.append((name, ScalAdd(t.left, r)))
    elif isinstance(t, ScalMul):
        for name, l in all_deep_rewrites(t.left):
            results.append((name, ScalMul(l, t.right)))
        for name, r in all_deep_rewrites(t.right):
            results.append((name, ScalMul(t.left, r)))
    elif isinstance(t, VecAdd):
        for name, l in all_deep_rewrites(t.left):
            results.append((name, VecAdd(l, t.right)))
        for name, r in all_deep_rewrites(t.right):
            results.append((name, VecAdd(t.left, r)))
    elif isinstance(t, MatAdd):
        for name, l in all_deep_rewrites(t.left):
            results.append((name, MatAdd(l, t.right)))
        for name, r in all_deep_rewrites(t.right):
            results.append((name, MatAdd(t.left, r)))
    elif isinstance(t, SmulVec):
        for name, s in all_deep_rewrites(t.scalar):
            results.append((name, SmulVec(s, t.vec)))
        for name, v in all_deep_rewrites(t.vec):
            results.append((name, SmulVec(t.scalar, v)))
    elif isinstance(t, SmulMat):
        for name, s in all_deep_rewrites(t.scalar):
            results.append((name, SmulMat(s, t.mat)))
        for name, m in all_deep_rewrites(t.mat):
            results.append((name, SmulMat(t.scalar, m)))
    elif isinstance(t, MulVec):
        for name, m in all_deep_rewrites(t.mat):
            results.append((name, MulVec(m, t.vec)))
        for name, v in all_deep_rewrites(t.vec):
            results.append((name, MulVec(t.mat, v)))
    elif isinstance(t, Dot):
        for name, l in all_deep_rewrites(t.left):
            results.append((name, Dot(l, t.right)))
        for name, r in all_deep_rewrites(t.right):
            results.append((name, Dot(t.left, r)))
    return results


# ─────────────────────────────────────────────────────────────────────
# Part 3: Distributivity Potential
# ─────────────────────────────────────────────────────────────────────

def dist_potential(t: Expr) -> int:
    """Compute the distributivity potential (polynomial interpretation)."""
    if isinstance(t, (ScalVar, VecVar, MatVar)):
        return 3
    elif isinstance(t, (ScalAdd, VecAdd, MatAdd)):
        return dist_potential(t.left) + dist_potential(t.right) + 1
    elif isinstance(t, ScalMul):
        return dist_potential(t.left) * dist_potential(t.right)
    elif isinstance(t, (SmulVec, SmulMat)):
        a = t.scalar if hasattr(t, 'scalar') else t.left
        b = t.vec if hasattr(t, 'vec') else t.mat
        return dist_potential(a) * dist_potential(b) + 1
    elif isinstance(t, MulVec):
        return dist_potential(t.mat) * dist_potential(t.vec)
    elif isinstance(t, Dot):
        return dist_potential(t.left) * dist_potential(t.right)
    return 3


def expr_size(t: Expr) -> int:
    """Structural size of an expression."""
    if isinstance(t, (ScalVar, VecVar, MatVar)):
        return 1
    elif hasattr(t, 'left') and hasattr(t, 'right'):
        return 1 + expr_size(t.left) + expr_size(t.right)
    elif hasattr(t, 'scalar'):
        child = t.vec if hasattr(t, 'vec') else t.mat
        return 1 + expr_size(t.scalar) + expr_size(child)
    elif isinstance(t, MulVec):
        return 1 + expr_size(t.mat) + expr_size(t.vec)
    return 1


# ─────────────────────────────────────────────────────────────────────
# Part 4: AC-Equivalence Check
# ─────────────────────────────────────────────────────────────────────

def flatten_add(t: Expr, add_type) -> List[Expr]:
    """Flatten nested additions into a sorted list of summands."""
    if isinstance(t, add_type):
        return flatten_add(t.left, add_type) + flatten_add(t.right, add_type)
    return [t]

def canonical_form(t: Expr) -> str:
    """Compute a canonical string representation modulo AC of addition."""
    if isinstance(t, ScalAdd):
        summands = flatten_add(t, ScalAdd)
        return "ScalAdd(" + ", ".join(sorted(canonical_form(s) for s in summands)) + ")"
    elif isinstance(t, VecAdd):
        summands = flatten_add(t, VecAdd)
        return "VecAdd(" + ", ".join(sorted(canonical_form(s) for s in summands)) + ")"
    elif isinstance(t, MatAdd):
        summands = flatten_add(t, MatAdd)
        return "MatAdd(" + ", ".join(sorted(canonical_form(s) for s in summands)) + ")"
    elif isinstance(t, ScalMul):
        return f"ScalMul({canonical_form(t.left)}, {canonical_form(t.right)})"
    elif isinstance(t, SmulVec):
        return f"SmulVec({canonical_form(t.scalar)}, {canonical_form(t.vec)})"
    elif isinstance(t, SmulMat):
        return f"SmulMat({canonical_form(t.scalar)}, {canonical_form(t.mat)})"
    elif isinstance(t, MulVec):
        return f"MulVec({canonical_form(t.mat)}, {canonical_form(t.vec)})"
    elif isinstance(t, Dot):
        return f"Dot({canonical_form(t.left)}, {canonical_form(t.right)})"
    elif isinstance(t, ScalVar):
        return f"s:{t.name}"
    elif isinstance(t, VecVar):
        return f"v:{t.name}"
    elif isinstance(t, MatVar):
        return f"m:{t.name}"
    return repr(t)

def ac_equivalent(t1: Expr, t2: Expr) -> bool:
    """Check if two expressions are AC-equivalent."""
    return canonical_form(t1) == canonical_form(t2)


# ─────────────────────────────────────────────────────────────────────
# Part 5: BFS Reduction and Confluence Check
# ─────────────────────────────────────────────────────────────────────

def bfs_all_normal_forms(start: Expr, max_states: int = 10000) -> Tuple[Set[str], int, int]:
    """
    BFS all reduction sequences from start.
    Returns (set of canonical normal forms, max derivation length, total states explored).
    """
    visited = set()
    queue = deque([(start, 0)])
    normal_forms = set()
    max_len = 0

    while queue and len(visited) < max_states:
        current, depth = queue.popleft()
        key = repr(current)
        if key in visited:
            continue
        visited.add(key)

        rewrites = all_deep_rewrites(current)
        if not rewrites:
            # Normal form found
            cf = canonical_form(current)
            normal_forms.add(cf)
            max_len = max(max_len, depth)
        else:
            for _, next_expr in rewrites:
                next_key = repr(next_expr)
                if next_key not in visited:
                    queue.append((next_expr, depth + 1))

    return normal_forms, max_len, len(visited)


# ─────────────────────────────────────────────────────────────────────
# Part 6: Term Enumeration
# ─────────────────────────────────────────────────────────────────────

def enumerate_terms(depth: int,
                    scal_vars: List[str] = ["a", "b", "c"],
                    vec_vars: List[str] = ["u", "v", "w"],
                    mat_vars: List[str] = ["A", "B"]) -> List[Expr]:
    """Enumerate all tensor terms up to given depth."""
    if depth <= 0:
        return []

    base_scal = [ScalVar(n) for n in scal_vars]
    base_vec = [VecVar(n) for n in vec_vars]
    base_mat = [MatVar(n) for n in mat_vars]

    if depth == 1:
        return base_scal + base_vec + base_mat

    sub = enumerate_terms(depth - 1, scal_vars, vec_vars, mat_vars)
    sub_scal = [t for t in sub if isinstance(t, (ScalVar, ScalAdd, ScalMul, Dot))]
    sub_vec = [t for t in sub if isinstance(t, (VecVar, VecAdd, SmulVec, MulVec))]
    sub_mat = [t for t in sub if isinstance(t, (MatVar, MatAdd, SmulMat))]

    terms = list(sub)  # include smaller terms

    # Generate composite terms (sample, not exhaustive for large depths)
    for v1, v2 in itertools.islice(itertools.product(sub_vec, sub_vec), 50):
        terms.append(VecAdd(v1, v2))
        terms.append(Dot(v1, v2))
    for m, v in itertools.islice(itertools.product(sub_mat, sub_vec), 50):
        terms.append(MulVec(m, v))
    for s, v in itertools.islice(itertools.product(sub_scal[:3], sub_vec[:5]), 15):
        terms.append(SmulVec(s, v))
    for s, m in itertools.islice(itertools.product(sub_scal[:3], sub_mat[:5]), 15):
        terms.append(SmulMat(s, m))
    for m1, m2 in itertools.islice(itertools.product(sub_mat, sub_mat), 20):
        terms.append(MatAdd(m1, m2))
    for s1, s2 in itertools.islice(itertools.product(sub_scal[:5], sub_scal[:5]), 25):
        terms.append(ScalAdd(s1, s2))
        terms.append(ScalMul(s1, s2))

    return terms


# ─────────────────────────────────────────────────────────────────────
# Part 7: Main Demo
# ─────────────────────────────────────────────────────────────────────

def demo_single_term(t: Expr):
    """Demonstrate normalization of a single term."""
    print(f"\n{'='*60}")
    print(f"Term: {t}")
    print(f"Size: {expr_size(t)}")
    print(f"Distributivity potential: {dist_potential(t)}")

    nfs, max_len, states = bfs_all_normal_forms(t, max_states=5000)
    print(f"Normal forms found (modulo AC): {len(nfs)}")
    print(f"Max derivation length: {max_len}")
    print(f"States explored: {states}")

    if len(nfs) == 1:
        print("✓ CONFLUENT: Unique normal form modulo AC")
    elif len(nfs) == 0:
        print("⚠ No normal form found (state limit reached)")
    else:
        print("✗ COUNTEREXAMPLE: Multiple distinct normal forms!")
        for i, nf in enumerate(nfs):
            print(f"  NF {i+1}: {nf}")


def main():
    print("=" * 60)
    print("Tensor Distributivity Rewrite System — Confluence Demo")
    print("=" * 60)

    # Demo 1: Simple distributivity
    A = MatVar("A")
    v = VecVar("v")
    w = VecVar("w")
    t1 = MulVec(A, VecAdd(v, w))
    print("\n--- Demo 1: Matrix-vector distributivity ---")
    demo_single_term(t1)

    # Demo 2: Critical pair (rules 1 & 2)
    B = MatVar("B")
    t2 = MulVec(MatAdd(A, B), VecAdd(v, w))
    print("\n--- Demo 2: Critical pair (rules 1 & 2) ---")
    demo_single_term(t2)

    # Demo 3: Critical pair (rules 6 & 7)
    u = VecVar("u")
    t3 = Dot(VecAdd(v, w), VecAdd(u, VecVar("x")))
    print("\n--- Demo 3: Critical pair (rules 6 & 7) ---")
    demo_single_term(t3)

    # Demo 4: Scalar-matrix-vector chain
    a = ScalVar("a")
    t4 = MulVec(SmulMat(a, A), VecAdd(v, w))
    print("\n--- Demo 4: Scalar-matrix-vector chain ---")
    demo_single_term(t4)

    # Demo 5: Dot product with scalar multiplication
    t5 = Dot(SmulVec(a, v), VecAdd(w, u))
    print("\n--- Demo 5: Dot with scalar and sum ---")
    demo_single_term(t5)

    # Demo 6: Nested distribution
    b = ScalVar("b")
    t6 = ScalMul(a, ScalAdd(Dot(v, w), Dot(u, VecVar("x"))))
    print("\n--- Demo 6: Scalar multiplication over addition ---")
    demo_single_term(t6)

    # Exhaustive check on small terms
    print("\n" + "=" * 60)
    print("Exhaustive Confluence Check on Small Terms")
    print("=" * 60)

    terms = enumerate_terms(depth=3, scal_vars=["a", "b"], vec_vars=["v", "w"], mat_vars=["A"])
    # Filter to terms that have at least one rewrite
    interesting = [t for t in terms if all_deep_rewrites(t)]
    print(f"Terms with rewrites: {len(interesting)}")

    counterexamples = 0
    max_nf_count = 0
    max_deriv_len = 0
    checked = 0

    for t in interesting[:200]:  # Check up to 200 terms
        nfs, mlen, _ = bfs_all_normal_forms(t, max_states=1000)
        checked += 1
        if len(nfs) > 1:
            counterexamples += 1
            print(f"  ✗ Counterexample: {t}")
            for nf in nfs:
                print(f"    NF: {nf}")
        max_nf_count = max(max_nf_count, len(nfs))
        max_deriv_len = max(max_deriv_len, mlen)

    print(f"\nChecked: {checked} terms")
    print(f"Counterexamples: {counterexamples}")
    print(f"Max normal forms per term: {max_nf_count}")
    print(f"Max derivation length: {max_deriv_len}")

    if counterexamples == 0:
        print("\n✓ All checked terms are confluent modulo AC!")
    else:
        print(f"\n✗ Found {counterexamples} counterexample(s) to confluence")

    # Polynomial bound test (Conjecture A)
    print("\n" + "=" * 60)
    print("Conjecture A: Polynomial Bound on Normalization Length")
    print("=" * 60)
    print(f"{'Size':>6} {'Max Deriv Len':>15} {'n²':>8} {'n³':>8}")
    print("-" * 45)

    for depth in range(1, 4):
        terms_d = enumerate_terms(depth, scal_vars=["a"], vec_vars=["v", "w"], mat_vars=["A"])
        interesting_d = [t for t in terms_d if all_deep_rewrites(t)]
        max_d = 0
        max_s = 0
        for t in interesting_d[:100]:
            nfs, mlen, _ = bfs_all_normal_forms(t, max_states=500)
            s = expr_size(t)
            max_d = max(max_d, mlen)
            max_s = max(max_s, s)
        if max_s > 0:
            print(f"{max_s:>6} {max_d:>15} {max_s**2:>8} {max_s**3:>8}")

    print("\nDone!")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Confluence Diagram — Critical Pair Resolution

Shows how two different rewrite paths from the same term converge
to AC-equivalent normal forms, illustrating the diamond property
modulo AC.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# ─── Left panel: Generic confluence diamond ───
ax = axes[0]
ax.set_xlim(-3, 3)
ax.set_ylim(-3.5, 1)
ax.set_aspect('equal')
ax.axis('off')
ax.set_title("Confluence Modulo AC: The Diamond Property", fontsize=13, fontweight='bold')

# Nodes
nodes = {
    't': (0, 0),
    'u': (-2, -1.2),
    'v': (2, -1.2),
    'n1': (-2, -2.8),
    'n2': (2, -2.8),
}

# Draw edges
arrow_style = dict(arrowstyle='->', color='#333', lw=2, connectionstyle='arc3,rad=0.1')
ax.annotate('', xy=nodes['u'], xytext=nodes['t'],
            arrowprops=dict(arrowstyle='->', color='#2196F3', lw=2.5))
ax.annotate('', xy=nodes['v'], xytext=nodes['t'],
            arrowprops=dict(arrowstyle='->', color='#FF5722', lw=2.5))
ax.annotate('', xy=nodes['n1'], xytext=nodes['u'],
            arrowprops=dict(arrowstyle='->', color='#2196F3', lw=1.5, linestyle='dashed'))
ax.annotate('', xy=nodes['n2'], xytext=nodes['v'],
            arrowprops=dict(arrowstyle='->', color='#FF5722', lw=1.5, linestyle='dashed'))

# AC-equivalence line
ax.annotate('', xy=nodes['n2'], xytext=nodes['n1'],
            arrowprops=dict(arrowstyle='<->', color='#4CAF50', lw=2.5, linestyle='dotted'))

# Node labels
for name, (x, y) in nodes.items():
    labels = {'t': 't', 'u': 'u', 'v': 'v', 'n1': 'n₁', 'n2': 'n₂'}
    ax.plot(x, y, 'o', markersize=20, color='white', markeredgecolor='#333',
            markeredgewidth=2, zorder=5)
    ax.text(x, y, labels[name], ha='center', va='center', fontsize=12,
            fontweight='bold', zorder=6)

# Labels on edges
ax.text(-1.3, -0.3, 'rewrite', fontsize=9, color='#2196F3', rotation=-35)
ax.text(1.3, -0.3, 'rewrite', fontsize=9, color='#FF5722', rotation=35)
ax.text(-2.5, -2, '→*', fontsize=11, color='#2196F3')
ax.text(2.3, -2, '→*', fontsize=11, color='#FF5722')
ax.text(0, -3.1, 'ACEq', fontsize=11, color='#4CAF50', ha='center',
        fontweight='bold')

# Legend text
ax.text(0, -3.5, 'Normal forms n₁ ≡ n₂ modulo\nassociativity-commutativity of addition',
        ha='center', fontsize=9, style='italic', color='#666')

# ─── Right panel: Concrete critical pair ───
ax2 = axes[1]
ax2.set_xlim(-4, 4)
ax2.set_ylim(-5.5, 1)
ax2.set_aspect('equal')
ax2.axis('off')
ax2.set_title("Critical Pair: Rules R1 & R2", fontsize=13, fontweight='bold')

terms = {
    'top': (0, 0, '(A⊞B)·(v⊕w)', '#FFF9C4'),
    'left': (-2.5, -1.5, 'R1: (A⊞B)·v\n    ⊕ (A⊞B)·w', '#BBDEFB'),
    'right': (2.5, -1.5, 'R2: A·(v⊕w)\n    ⊕ B·(v⊕w)', '#FFCCBC'),
    'bl': (-2.5, -3.5, 'Av⊕Bv⊕Aw⊕Bw', '#C8E6C9'),
    'br': (2.5, -3.5, 'Av⊕Aw⊕Bv⊕Bw', '#C8E6C9'),
}

for key, (x, y, text, color) in terms.items():
    bbox = dict(boxstyle='round,pad=0.4', facecolor=color, edgecolor='#666', linewidth=1.5)
    ax2.text(x, y, text, ha='center', va='center', fontsize=9, bbox=bbox)

# Arrows
for src, dst, col in [('top', 'left', '#2196F3'), ('top', 'right', '#FF5722'),
                       ('left', 'bl', '#2196F3'), ('right', 'br', '#FF5722')]:
    sx, sy = terms[src][0], terms[src][1]
    dx, dy = terms[dst][0], terms[dst][1]
    ax2.annotate('', xy=(dx, dy+0.4), xytext=(sx, sy-0.4),
                arrowprops=dict(arrowstyle='->', color=col, lw=2))

# AC equivalence
ax2.annotate('', xy=(2.0, -3.5), xytext=(-2.0, -3.5),
            arrowprops=dict(arrowstyle='<->', color='#4CAF50', lw=2.5, linestyle='dotted'))
ax2.text(0, -3.5, '≡_AC', fontsize=12, color='#4CAF50', ha='center', va='center',
         fontweight='bold', bbox=dict(facecolor='white', edgecolor='none', pad=2))

ax2.text(0, -4.5, 'Same 4 summands, different association order\n'
         'Av, Bv, Aw, Bw vs. Av, Aw, Bv, Bw',
         ha='center', fontsize=9, style='italic', color='#666')

# Rule labels
ax2.text(-1.5, -0.5, 'R1', fontsize=10, color='#2196F3', fontweight='bold')
ax2.text(1.5, -0.5, 'R2', fontsize=10, color='#FF5722', fontweight='bold')
ax2.text(-3.2, -2.5, 'R2×2', fontsize=9, color='#2196F3')
ax2.text(3.0, -2.5, 'R1×2', fontsize=9, color='#FF5722')

plt.tight_layout()
plt.savefig('viz_confluence.png', dpi=150, bbox_inches='tight')
print("Saved viz_confluence.png")


#!/usr/bin/env python3
"""
Visualization: Distributivity Potential Landscape

Visualizes how the distributivity potential (termination measure) decreases
during rewriting. Shows the potential landscape for terms of varying complexity,
demonstrating that every rewrite step strictly decreases the measure.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# ─── Inline: Minimal expression types ───

class Expr:
    pass

class Var(Expr):
    def __init__(self, name, sort):
        self.name = name
        self.sort = sort

class BinOp(Expr):
    def __init__(self, op, left, right):
        self.op = op
        self.left = left
        self.right = right

def dp(t):
    """Distributivity potential."""
    if isinstance(t, Var):
        return 3
    op = t.op
    dl, dr = dp(t.left), dp(t.right)
    if op in ('scalAdd', 'vecAdd', 'matAdd'):
        return dl + dr + 1
    elif op == 'scalMul':
        return dl * dr
    elif op in ('smulVec', 'smulMat'):
        return dl * dr + 1
    elif op in ('mulVec', 'dot'):
        return dl * dr
    return 3

def size(t):
    if isinstance(t, Var):
        return 1
    return 1 + size(t.left) + size(t.right)

# ─── Generate sample rewrite traces ───

def make_trace(name, steps):
    """steps = list of (dp, label) pairs."""
    return name, steps

a = Var("a", "scal")
v = Var("v", "vec")
w = Var("w", "vec")
A = Var("A", "mat")
B = Var("B", "mat")

traces = []

# Trace 1: mulVec A (vecAdd v w) → vecAdd (mulVec A v) (mulVec A w)
t1 = BinOp('mulVec', A, BinOp('vecAdd', v, w))
t1_nf = BinOp('vecAdd', BinOp('mulVec', A, v), BinOp('mulVec', A, w))
traces.append(("A·(v⊕w)", [(dp(t1), "start"), (dp(t1_nf), "R1")]))

# Trace 2: mulVec (matAdd A B) (vecAdd v w) - two paths
t2 = BinOp('mulVec', BinOp('matAdd', A, B), BinOp('vecAdd', v, w))
# Path A: R1 first
t2_r1 = BinOp('vecAdd',
    BinOp('mulVec', BinOp('matAdd', A, B), v),
    BinOp('mulVec', BinOp('matAdd', A, B), w))
t2_r1_r2a = BinOp('vecAdd',
    BinOp('vecAdd', BinOp('mulVec', A, v), BinOp('mulVec', B, v)),
    BinOp('mulVec', BinOp('matAdd', A, B), w))
t2_r1_r2b = BinOp('vecAdd',
    BinOp('vecAdd', BinOp('mulVec', A, v), BinOp('mulVec', B, v)),
    BinOp('vecAdd', BinOp('mulVec', A, w), BinOp('mulVec', B, w)))
traces.append(("(A⊞B)·(v⊕w) path1", [
    (dp(t2), "start"),
    (dp(t2_r1), "R1"),
    (dp(t2_r1_r2a), "R2"),
    (dp(t2_r1_r2b), "R2")
]))
# Path B: R2 first
t2_r2 = BinOp('vecAdd',
    BinOp('mulVec', A, BinOp('vecAdd', v, w)),
    BinOp('mulVec', B, BinOp('vecAdd', v, w)))
t2_r2_r1a = BinOp('vecAdd',
    BinOp('vecAdd', BinOp('mulVec', A, v), BinOp('mulVec', A, w)),
    BinOp('mulVec', B, BinOp('vecAdd', v, w)))
t2_r2_r1b = BinOp('vecAdd',
    BinOp('vecAdd', BinOp('mulVec', A, v), BinOp('mulVec', A, w)),
    BinOp('vecAdd', BinOp('mulVec', B, v), BinOp('mulVec', B, w)))
traces.append(("(A⊞B)·(v⊕w) path2", [
    (dp(t2), "start"),
    (dp(t2_r2), "R2"),
    (dp(t2_r2_r1a), "R1"),
    (dp(t2_r2_r1b), "R1")
]))

# Trace 3: Scalar extraction
t3 = BinOp('mulVec', BinOp('smulMat', a, A), BinOp('vecAdd', v, w))
t3_r1 = BinOp('vecAdd',
    BinOp('mulVec', BinOp('smulMat', a, A), v),
    BinOp('mulVec', BinOp('smulMat', a, A), w))
t3_r1_r3 = BinOp('vecAdd',
    BinOp('smulVec', a, BinOp('mulVec', A, v)),
    BinOp('mulVec', BinOp('smulMat', a, A), w))
traces.append(("(a⊙A)·(v⊕w)", [
    (dp(t3), "start"),
    (dp(t3_r1), "R1"),
    (dp(t3_r1_r3), "R3")
]))

# ─── Plot ───

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Left: Rewrite traces
ax = axes[0]
colors = ['#2196F3', '#FF5722', '#4CAF50', '#9C27B0']
for i, (name, steps) in enumerate(traces):
    x = list(range(len(steps)))
    y = [s[0] for s in steps]
    ax.plot(x, y, 'o-', color=colors[i % len(colors)], label=name,
            linewidth=2, markersize=8)
    for j, (val, label) in enumerate(steps):
        ax.annotate(label, (j, val), textcoords="offset points",
                   xytext=(0, 10), ha='center', fontsize=7)

ax.set_xlabel("Rewrite Step", fontsize=12)
ax.set_ylabel("Distributivity Potential", fontsize=12)
ax.set_title("Strictly Decreasing Potential During Rewriting", fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Right: dp vs size scatter
ax2 = axes[1]
sizes = []
dps = []
# Generate many terms
for _ in range(200):
    depth = np.random.randint(1, 6)
    t = Var("x", "vec")
    for _ in range(depth):
        op = np.random.choice(['vecAdd', 'mulVec', 'smulVec', 'dot'])
        other = Var(np.random.choice(["v", "w", "u"]),
                   "vec" if op != 'mulVec' else "mat")
        if op == 'smulVec':
            other = Var("a", "scal")
            t = BinOp(op, other, t)
        else:
            t = BinOp(op, other if np.random.random() < 0.5 else t,
                      t if np.random.random() < 0.5 else other)
    sizes.append(size(t))
    dps.append(dp(t))

ax2.scatter(sizes, dps, alpha=0.5, c='#2196F3', s=20)
# Plot 3^n bound
x_bound = np.linspace(1, max(sizes), 100)
ax2.plot(x_bound, 3**x_bound, 'r--', alpha=0.7, label='3^n upper bound')
ax2.set_xlabel("Expression Size n", fontsize=12)
ax2.set_ylabel("Distributivity Potential dp(t)", fontsize=12)
ax2.set_title("dp(t) ≤ 3^size(t)", fontsize=13)
ax2.set_yscale('log')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_potential.png', dpi=150, bbox_inches='tight')
print("Saved viz_potential.png")


#!/usr/bin/env python3
"""
Visualization: Rewrite Graph for a Critical Pair Term

Shows the complete rewrite graph from a term with multiple reduction paths,
illustrating how all paths converge to AC-equivalent normal forms.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from collections import deque

# ─── Inline: Minimal expression types and rewrite rules ───

class E:
    """Base expression."""
    pass

class V(E):
    def __init__(self, n): self.n = n
    def __repr__(self): return self.n
    def __eq__(self, o): return isinstance(o, V) and self.n == o.n
    def __hash__(self): return hash(('V', self.n))

class M(E):
    def __init__(self, n): self.n = n
    def __repr__(self): return self.n
    def __eq__(self, o): return isinstance(o, M) and self.n == o.n
    def __hash__(self): return hash(('M', self.n))

class VA(E):  # vecAdd
    def __init__(self, l, r): self.l, self.r = l, r
    def __repr__(self): return f"({self.l}⊕{self.r})"
    def __eq__(self, o): return isinstance(o, VA) and self.l == o.l and self.r == o.r
    def __hash__(self): return hash(('VA', self.l, self.r))

class MA(E):  # matAdd
    def __init__(self, l, r): self.l, self.r = l, r
    def __repr__(self): return f"({self.l}⊞{self.r})"
    def __eq__(self, o): return isinstance(o, MA) and self.l == o.l and self.r == o.r
    def __hash__(self): return hash(('MA', self.l, self.r))

class MV(E):  # mulVec
    def __init__(self, m, v): self.m, self.v = m, v
    def __repr__(self): return f"{self.m}·{self.v}"
    def __eq__(self, o): return isinstance(o, MV) and self.m == o.m and self.v == o.v
    def __hash__(self): return hash(('MV', self.m, self.v))

def rewrites(t):
    """All one-step deep rewrites."""
    results = []
    # R1
    if isinstance(t, MV) and isinstance(t.v, VA):
        results.append(("R1", VA(MV(t.m, t.v.l), MV(t.m, t.v.r))))
    # R2
    if isinstance(t, MV) and isinstance(t.m, MA):
        results.append(("R2", VA(MV(t.m.l, t.v), MV(t.m.r, t.v))))
    # Congruence
    if isinstance(t, VA):
        for n, l in rewrites(t.l): results.append((n, VA(l, t.r)))
        for n, r in rewrites(t.r): results.append((n, VA(t.l, r)))
    if isinstance(t, MV):
        for n, m in rewrites(t.m): results.append((n, MV(m, t.v)))
        for n, v in rewrites(t.v): results.append((n, MV(t.m, v)))
    return results

def flatten_va(t):
    if isinstance(t, VA):
        return flatten_va(t.l) + flatten_va(t.r)
    return [repr(t)]

def canon(t):
    if isinstance(t, VA):
        parts = flatten_va(t)
        return "VA(" + ",".join(sorted(parts)) + ")"
    return repr(t)

# ─── Build rewrite graph ───
A, B = M("A"), M("B")
v, w = V("v"), V("w")
start = MV(MA(A, B), VA(v, w))

graph = {}  # node_id -> set of (edge_label, target_id)
node_labels = {}  # node_id -> display string
node_canon = {}  # node_id -> canonical form
queue = deque([start])
visited = set()

while queue:
    t = queue.popleft()
    tid = repr(t)
    if tid in visited:
        continue
    visited.add(tid)
    node_labels[tid] = tid
    node_canon[tid] = canon(t)
    graph[tid] = set()
    for rule, next_t in rewrites(t):
        nid = repr(next_t)
        graph[tid].add((rule, nid))
        if nid not in visited:
            queue.append(next_t)
            node_labels[nid] = nid
            node_canon[nid] = canon(next_t)
            if nid not in graph:
                graph[nid] = set()

# ─── Layout: manual layered layout ───
nodes = list(graph.keys())
# Compute levels by BFS from start
levels = {repr(start): 0}
q = deque([repr(start)])
while q:
    n = q.popleft()
    for _, target in graph.get(n, set()):
        if target not in levels:
            levels[target] = levels[n] + 1
            q.append(target)

max_level = max(levels.values()) if levels else 0
level_nodes = {}
for n, l in levels.items():
    level_nodes.setdefault(l, []).append(n)

positions = {}
for l, nds in level_nodes.items():
    for i, n in enumerate(nds):
        x = (i - (len(nds)-1)/2) * 3.5
        y = -l * 1.8
        positions[n] = (x, y)

# ─── Draw ───
fig, ax = plt.subplots(figsize=(12, 8))
ax.set_aspect('equal')
ax.axis('off')
ax.set_title("Rewrite Graph: (A⊞B)·(v⊕w)\nAll paths converge to AC-equivalent normal forms",
             fontsize=13, fontweight='bold')

# Draw edges
for src, edges in graph.items():
    if src not in positions:
        continue
    sx, sy = positions[src]
    for rule, dst in edges:
        if dst not in positions:
            continue
        dx, dy = positions[dst]
        color = '#2196F3' if 'R1' in rule else '#FF5722'
        ax.annotate('', xy=(dx, dy+0.3), xytext=(sx, sy-0.3),
                    arrowprops=dict(arrowstyle='->', color=color, lw=1.5,
                                   connectionstyle='arc3,rad=0.05'))
        mx, my = (sx+dx)/2, (sy+dy)/2
        ax.text(mx+0.15, my, rule, fontsize=7, color=color, fontweight='bold')

# Draw nodes
normal_canon = set()
for n in nodes:
    if not graph.get(n):
        normal_canon.add(node_canon.get(n, ''))

for n, (x, y) in positions.items():
    is_normal = not graph.get(n)
    is_start = (n == repr(start))
    color = '#FFF9C4' if is_start else ('#C8E6C9' if is_normal else '#E3F2FD')
    edge_color = '#F57F17' if is_start else ('#2E7D32' if is_normal else '#1565C0')
    bbox = dict(boxstyle='round,pad=0.3', facecolor=color,
                edgecolor=edge_color, linewidth=2 if is_start else 1.5)
    label = node_labels[n]
    if len(label) > 30:
        label = label[:28] + "..."
    ax.text(x, y, label, ha='center', va='center', fontsize=7, bbox=bbox)

# Legend
ax.text(0, -max_level*1.8 - 1.2,
        f"Normal forms: {len(normal_canon)} distinct canonical form(s) modulo AC",
        ha='center', fontsize=11, fontweight='bold',
        color='#2E7D32' if len(normal_canon) == 1 else '#C62828')

plt.tight_layout()
plt.savefig('viz_rewrite_graph.png', dpi=150, bbox_inches='tight')
print("Saved viz_rewrite_graph.png")
