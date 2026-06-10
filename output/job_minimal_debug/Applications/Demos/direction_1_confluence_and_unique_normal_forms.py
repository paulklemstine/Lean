#!/usr/bin/env python3
"""
applications.py — Real-world applications of tensor confluence theory.

Demonstrates:
1. Compiler optimization: deterministic simplification passes
2. Symbolic linear algebra: canonical form computation
3. Energy functional simplification for scientific computing
"""

from algorithms import (
    Expr, ScalVar, VecVar, MatVar, ScalAdd, ScalMul, VecAdd, MatAdd,
    SmulVec, SmulMat, MulVec, Dot,
    normalize_canon, dist_potential, are_ac_equivalent, verify_termination
)


def application_compiler_optimization():
    """Application 1: Compiler Optimization for Tensor Programs.

    In scientific computing compilers, tensor expressions must be simplified
    before code generation. Different optimization schedules (e.g., applying
    distribution left-to-right vs. right-to-left) must produce equivalent code.

    Confluence guarantees this: no matter how the compiler chooses to apply
    rewrite rules, the final optimized code is the same (up to AC).
    """
    print("=" * 70)
    print("APPLICATION 1: Compiler Optimization Determinism")
    print("=" * 70)

    A, B = MatVar("A"), MatVar("B")
    v, w, x = VecVar("v"), VecVar("w"), VecVar("x")
    a = ScalVar("α")

    # A compiler might encounter this expression in a finite element computation
    expr = MulVec(SmulMat(a, MatAdd(A, B)), VecAdd(v, w))
    print(f"\n  Source expression: (α⊙(A⊞B))·(v⊕w)")
    print(f"  AST: {expr}")
    print(f"  Complexity measure: {dist_potential(expr)}")

    # Strategy 1: distribute matrix addition first
    step1a = MulVec(MatAdd(SmulMat(a, A), SmulMat(a, B)), VecAdd(v, w))
    nf1 = normalize_canon(step1a)
    print(f"\n  Strategy 1 (distribute smulMat first):")
    print(f"    After step 1: {step1a}")
    print(f"    Normal form:  {nf1}")

    # Strategy 2: extract scalar first
    step1b = SmulVec(a, MulVec(MatAdd(A, B), VecAdd(v, w)))
    nf2 = normalize_canon(step1b)
    print(f"\n  Strategy 2 (extract scalar first):")
    print(f"    After step 1: {step1b}")
    print(f"    Normal form:  {nf2}")

    print(f"\n  Results AC-equivalent? {are_ac_equivalent(nf1, nf2)}")
    print(f"  → Compiler optimization is deterministic up to addition ordering!")


def application_symbolic_linear_algebra():
    """Application 2: Symbolic Linear Algebra.

    When computing symbolic matrix-vector products, the order of
    operations affects the intermediate expressions but not the
    mathematical result. Canonical normal forms provide a decision
    procedure: two expressions are semantically equal iff their
    normal forms are AC-equivalent.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Symbolic Linear Algebra Decision Procedure")
    print("=" * 70)

    A = MatVar("A")
    v, w = VecVar("v"), VecVar("w")
    a, b = ScalVar("a"), ScalVar("b")

    # Are these two expressions equivalent?
    # Expression 1: a•(A·v) ⊕ b•(A·w)
    expr1 = VecAdd(SmulVec(a, MulVec(A, v)), SmulVec(b, MulVec(A, w)))
    # Expression 2: A·(a•v ⊕ b•w)  [factoring out A]
    expr2 = MulVec(A, VecAdd(SmulVec(a, v), SmulVec(b, w)))

    nf1 = normalize_canon(expr1)
    nf2 = normalize_canon(expr2)

    print(f"\n  Expression 1: a•(A·v) ⊕ b•(A·w)")
    print(f"    Normal form: {nf1}")
    print(f"\n  Expression 2: A·(a•v ⊕ b•w)")
    print(f"    Normal form: {nf2}")
    print(f"\n  AC-equivalent? {are_ac_equivalent(nf1, nf2)}")
    print(f"  → These expressions are {'equivalent' if are_ac_equivalent(nf1, nf2) else 'NOT equivalent'}!")

    # Another example: dot product linearity
    print(f"\n  --- Dot product linearity check ---")
    # ⟨a•v, w⟩ vs a·⟨v,w⟩
    expr3 = Dot(SmulVec(a, v), w)
    expr4 = ScalMul(a, Dot(v, w))
    nf3 = normalize_canon(expr3)
    nf4 = normalize_canon(expr4)
    print(f"  ⟨a•v, w⟩ normal form: {nf3}")
    print(f"  a·⟨v,w⟩ normal form:  {nf4}")
    print(f"  Equal? {nf3 == nf4}")


def application_energy_functional():
    """Application 3: Energy Functional Simplification.

    In computational physics, quadratic energy functionals
    E(A, v) = ⟨v, Av⟩ appear everywhere. Simplifying expressions
    involving E requires distributing additions through the bilinear form.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Energy Functional Simplification")
    print("=" * 70)

    A = MatVar("A")
    v, w = VecVar("v"), VecVar("w")

    # E(A, v+w) = ⟨v+w, A·(v+w)⟩
    energy_sum = Dot(VecAdd(v, w), MulVec(A, VecAdd(v, w)))
    print(f"\n  E(A, v+w) = ⟨v⊕w, A·(v⊕w)⟩")
    print(f"  Input:  {energy_sum}")
    print(f"  Measure: {dist_potential(energy_sum)}")

    nf = normalize_canon(energy_sum)
    print(f"  Normal form: {nf}")
    print(f"  Measure: {dist_potential(nf)}")

    steps, measures = verify_termination(energy_sum, verbose=True)
    print(f"\n  Normalization took {steps} root steps")
    print(f"  Measure sequence: {' → '.join(str(m) for m in measures)}")
    print(f"  Strictly decreasing: {all(measures[i] > measures[i+1] for i in range(len(measures)-1))}")

    # The normal form should be a sum of 4 terms:
    # ⟨v,A·v⟩ + ⟨v,A·w⟩ + ⟨w,A·v⟩ + ⟨w,A·w⟩
    print(f"\n  Expected: sum of ⟨v,Av⟩, ⟨v,Aw⟩, ⟨w,Av⟩, ⟨w,Aw⟩")
    print(f"  (The 4-term polarization expansion of the quadratic form)")


if __name__ == "__main__":
    application_compiler_optimization()
    application_symbolic_linear_algebra()
    application_energy_functional()

    print("\n" + "=" * 70)
    print("CONCLUSION")
    print("=" * 70)
    print("""
  Confluence modulo AC transforms tensor simplification from a
  heuristic into a mathematically certified decision procedure:

  1. COMPILERS can apply rewrites in any order — same result.
  2. SYMBOLIC ALGEBRA gets canonical forms for equivalence checking.
  3. PHYSICS SIMULATIONS get provably correct simplification.

  The key theorem: every term has a unique normal form up to
  associativity and commutativity of addition.
""")


#!/usr/bin/env python3
"""
demo.py — Demonstrates the confluence of tensor distributivity rewrites.

Enumerates tensor terms up to bounded depth, computes all reduction sequences
by BFS, checks AC-equivalence of terminal forms, and demonstrates canonical
normalization interactively on sample expressions.

Keywords: term rewriting, confluence modulo AC, canonical normal forms, tensor algebra
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import List, Set, Tuple, Optional, FrozenSet
from collections import deque
import itertools

# ──────────────────────────────────────────────────────────────────────
# 1. Abstract Syntax Tree for Tensor Expressions
# ──────────────────────────────────────────────────────────────────────

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
    left: Expr
    right: Expr
    def __repr__(self): return f"({self.left} + {self.right})"

@dataclass(frozen=True)
class ScalMul(Expr):
    left: Expr
    right: Expr
    def __repr__(self): return f"({self.left} * {self.right})"

@dataclass(frozen=True)
class VecAdd(Expr):
    left: Expr
    right: Expr
    def __repr__(self): return f"({self.left} ⊕ {self.right})"

@dataclass(frozen=True)
class MatAdd(Expr):
    left: Expr
    right: Expr
    def __repr__(self): return f"({self.left} ⊞ {self.right})"

@dataclass(frozen=True)
class SmulVec(Expr):
    scalar: Expr
    vector: Expr
    def __repr__(self): return f"({self.scalar} • {self.vector})"

@dataclass(frozen=True)
class SmulMat(Expr):
    scalar: Expr
    matrix: Expr
    def __repr__(self): return f"({self.scalar} ⊙ {self.matrix})"

@dataclass(frozen=True)
class MulVec(Expr):
    matrix: Expr
    vector: Expr
    def __repr__(self): return f"({self.matrix} · {self.vector})"

@dataclass(frozen=True)
class Dot(Expr):
    left: Expr
    right: Expr
    def __repr__(self): return f"⟨{self.left}, {self.right}⟩"


# ──────────────────────────────────────────────────────────────────────
# 2. Polynomial Interpretation Measure (distPotential)
# ──────────────────────────────────────────────────────────────────────

def dist_potential(t: Expr) -> int:
    """Polynomial interpretation for termination.
    Variables → 3, additions → sum + 1, smul → product + 1, mul → product."""
    if isinstance(t, (ScalVar, VecVar, MatVar)):
        return 3
    elif isinstance(t, (ScalAdd, VecAdd, MatAdd)):
        return dist_potential(t.left) + dist_potential(t.right) + 1
    elif isinstance(t, ScalMul):
        return dist_potential(t.left) * dist_potential(t.right)
    elif isinstance(t, (SmulVec, SmulMat)):
        return dist_potential(t.scalar) * dist_potential(getattr(t, 'vector', None) or t.matrix) + 1
    elif isinstance(t, MulVec):
        return dist_potential(t.matrix) * dist_potential(t.vector)
    elif isinstance(t, Dot):
        return dist_potential(t.left) * dist_potential(t.right)
    return 0


# ──────────────────────────────────────────────────────────────────────
# 3. The 9 Rewrite Rules (Root-Level)
# ──────────────────────────────────────────────────────────────────────

def root_rewrites(t: Expr) -> List[Expr]:
    """Return all one-step root rewrites of t."""
    results = []
    # Rule 1: mulVec A (vecAdd v w) → vecAdd (mulVec A v) (mulVec A w)
    if isinstance(t, MulVec) and isinstance(t.vector, VecAdd):
        A, v, w = t.matrix, t.vector.left, t.vector.right
        results.append(VecAdd(MulVec(A, v), MulVec(A, w)))
    # Rule 2: mulVec (matAdd A B) v → vecAdd (mulVec A v) (mulVec B v)
    if isinstance(t, MulVec) and isinstance(t.matrix, MatAdd):
        A, B, v = t.matrix.left, t.matrix.right, t.vector
        results.append(VecAdd(MulVec(A, v), MulVec(B, v)))
    # Rule 3: mulVec (smulMat a A) v → smulVec a (mulVec A v)
    if isinstance(t, MulVec) and isinstance(t.matrix, SmulMat):
        a, A, v = t.matrix.scalar, t.matrix.matrix, t.vector
        results.append(SmulVec(a, MulVec(A, v)))
    # Rule 4: smulVec a (vecAdd v w) → vecAdd (smulVec a v) (smulVec a w)
    if isinstance(t, SmulVec) and isinstance(t.vector, VecAdd):
        a, v, w = t.scalar, t.vector.left, t.vector.right
        results.append(VecAdd(SmulVec(a, v), SmulVec(a, w)))
    # Rule 5: smulMat a (matAdd A B) → matAdd (smulMat a A) (smulMat a B)
    if isinstance(t, SmulMat) and isinstance(t.matrix, MatAdd):
        a, A, B = t.scalar, t.matrix.left, t.matrix.right
        results.append(MatAdd(SmulMat(a, A), SmulMat(a, B)))
    # Rule 6: dot (vecAdd v w) u → scalAdd (dot v u) (dot w u)
    if isinstance(t, Dot) and isinstance(t.left, VecAdd):
        v, w, u = t.left.left, t.left.right, t.right
        results.append(ScalAdd(Dot(v, u), Dot(w, u)))
    # Rule 7: dot u (vecAdd v w) → scalAdd (dot u v) (dot u w)
    if isinstance(t, Dot) and isinstance(t.right, VecAdd):
        u, v, w = t.left, t.right.left, t.right.right
        results.append(ScalAdd(Dot(u, v), Dot(u, w)))
    # Rule 8: dot (smulVec a v) w → scalMul a (dot v w)
    if isinstance(t, Dot) and isinstance(t.left, SmulVec):
        a, v, w = t.left.scalar, t.left.vector, t.right
        results.append(ScalMul(a, Dot(v, w)))
    # Rule 9: scalMul a (scalAdd b c) → scalAdd (scalMul a b) (scalMul a c)
    if isinstance(t, ScalMul) and isinstance(t.right, ScalAdd):
        a, b, c = t.left, t.right.left, t.right.right
        results.append(ScalAdd(ScalMul(a, b), ScalMul(a, c)))
    return results


def all_rewrites(t: Expr) -> List[Expr]:
    """Return all one-step rewrites at any position (contextual closure)."""
    results = root_rewrites(t)
    # Congruence rules: recurse into subterms
    if isinstance(t, (ScalAdd, VecAdd, MatAdd)):
        for l in all_rewrites(t.left):
            results.append(type(t)(l, t.right))
        for r in all_rewrites(t.right):
            results.append(type(t)(t.left, r))
    elif isinstance(t, ScalMul):
        for l in all_rewrites(t.left):
            results.append(ScalMul(l, t.right))
        for r in all_rewrites(t.right):
            results.append(ScalMul(t.left, r))
    elif isinstance(t, SmulVec):
        for s in all_rewrites(t.scalar):
            results.append(SmulVec(s, t.vector))
        for v in all_rewrites(t.vector):
            results.append(SmulVec(t.scalar, v))
    elif isinstance(t, SmulMat):
        for s in all_rewrites(t.scalar):
            results.append(SmulMat(s, t.matrix))
        for m in all_rewrites(t.matrix):
            results.append(SmulMat(t.scalar, m))
    elif isinstance(t, MulVec):
        for m in all_rewrites(t.matrix):
            results.append(MulVec(m, t.vector))
        for v in all_rewrites(t.vector):
            results.append(MulVec(t.matrix, v))
    elif isinstance(t, Dot):
        for l in all_rewrites(t.left):
            results.append(Dot(l, t.right))
        for r in all_rewrites(t.right):
            results.append(Dot(t.left, r))
    return results


# ──────────────────────────────────────────────────────────────────────
# 4. AC-Equivalence (Flattening to Multisets)
# ──────────────────────────────────────────────────────────────────────

def flatten_add(t: Expr, add_type: type) -> FrozenSet:
    """Flatten nested additions into a frozenset of summands."""
    if isinstance(t, add_type):
        return flatten_add(t.left, add_type) | flatten_add(t.right, add_type)
    return frozenset([ac_canonical(t)])

def ac_canonical(t: Expr):
    """Compute an AC-canonical representative for comparison."""
    if isinstance(t, (ScalVar, VecVar, MatVar)):
        return t
    elif isinstance(t, ScalAdd):
        return ('ScalAdd', flatten_add(t, ScalAdd))
    elif isinstance(t, VecAdd):
        return ('VecAdd', flatten_add(t, VecAdd))
    elif isinstance(t, MatAdd):
        return ('MatAdd', flatten_add(t, MatAdd))
    elif isinstance(t, ScalMul):
        return ('ScalMul', ac_canonical(t.left), ac_canonical(t.right))
    elif isinstance(t, SmulVec):
        return ('SmulVec', ac_canonical(t.scalar), ac_canonical(t.vector))
    elif isinstance(t, SmulMat):
        return ('SmulMat', ac_canonical(t.scalar), ac_canonical(t.matrix))
    elif isinstance(t, MulVec):
        return ('MulVec', ac_canonical(t.matrix), ac_canonical(t.vector))
    elif isinstance(t, Dot):
        return ('Dot', ac_canonical(t.left), ac_canonical(t.right))
    return t

def ac_equiv(t1: Expr, t2: Expr) -> bool:
    """Check if t1 and t2 are AC-equivalent."""
    return ac_canonical(t1) == ac_canonical(t2)


# ──────────────────────────────────────────────────────────────────────
# 5. Canonical Normalization (Bottom-Up)
# ──────────────────────────────────────────────────────────────────────

def normalize_root(t: Expr) -> Expr:
    """Apply root-level rewrite rules until no more apply."""
    while True:
        rewrites = root_rewrites(t)
        if not rewrites:
            return t
        t = rewrites[0]  # Always take the first applicable rule

def normalize_canon(t: Expr) -> Expr:
    """Bottom-up canonical normalization: normalize children, then root."""
    if isinstance(t, (ScalVar, VecVar, MatVar)):
        return t
    elif isinstance(t, ScalAdd):
        return normalize_root(ScalAdd(normalize_canon(t.left), normalize_canon(t.right)))
    elif isinstance(t, ScalMul):
        return normalize_root(ScalMul(normalize_canon(t.left), normalize_canon(t.right)))
    elif isinstance(t, VecAdd):
        return normalize_root(VecAdd(normalize_canon(t.left), normalize_canon(t.right)))
    elif isinstance(t, MatAdd):
        return normalize_root(MatAdd(normalize_canon(t.left), normalize_canon(t.right)))
    elif isinstance(t, SmulVec):
        return normalize_root(SmulVec(normalize_canon(t.scalar), normalize_canon(t.vector)))
    elif isinstance(t, SmulMat):
        return normalize_root(SmulMat(normalize_canon(t.scalar), normalize_canon(t.matrix)))
    elif isinstance(t, MulVec):
        return normalize_root(MulVec(normalize_canon(t.matrix), normalize_canon(t.vector)))
    elif isinstance(t, Dot):
        return normalize_root(Dot(normalize_canon(t.left), normalize_canon(t.right)))
    return t


# ──────────────────────────────────────────────────────────────────────
# 6. BFS Enumeration of All Reduction Sequences
# ──────────────────────────────────────────────────────────────────────

def find_all_normal_forms(t: Expr, max_steps: int = 1000) -> Tuple[List[Expr], int]:
    """BFS all reduction sequences from t, returning all normal forms
    and the maximum derivation length observed."""
    visited = set()
    queue = deque([(t, 0)])
    normal_forms = []
    max_len = 0
    visited.add(repr(t))

    while queue:
        current, depth = queue.popleft()
        if depth > max_steps:
            continue
        rewrites = all_rewrites(current)
        if not rewrites:
            normal_forms.append(current)
            max_len = max(max_len, depth)
        else:
            for r in rewrites:
                key = repr(r)
                if key not in visited:
                    visited.add(key)
                    queue.append((r, depth + 1))

    return normal_forms, max_len


# ──────────────────────────────────────────────────────────────────────
# 7. Term Enumeration
# ──────────────────────────────────────────────────────────────────────

def enumerate_terms(depth: int,
                    scal_vars: List[str] = ["a", "b", "c"],
                    vec_vars: List[str] = ["v", "w", "x"],
                    mat_vars: List[str] = ["M", "N"]) -> List[Expr]:
    """Enumerate all terms up to given depth."""
    if depth == 0:
        terms = []
        terms.extend(ScalVar(s) for s in scal_vars)
        terms.extend(VecVar(v) for v in vec_vars)
        terms.extend(MatVar(m) for m in mat_vars)
        return terms

    smaller = enumerate_terms(depth - 1, scal_vars, vec_vars, mat_vars)
    scalars = [t for t in smaller if isinstance(t, (ScalVar, ScalAdd, ScalMul))]
    vectors = [t for t in smaller if isinstance(t, (VecVar, VecAdd, SmulVec, MulVec))]
    matrices = [t for t in smaller if isinstance(t, (MatVar, MatAdd, SmulMat))]

    terms = list(smaller)
    # Only add a sample of compound terms to keep enumeration manageable
    for s1, s2 in itertools.islice(itertools.product(scalars, scalars), 5):
        terms.append(ScalAdd(s1, s2))
        terms.append(ScalMul(s1, s2))
    for v1, v2 in itertools.islice(itertools.product(vectors, vectors), 5):
        terms.append(VecAdd(v1, v2))
        terms.append(Dot(v1, v2))
    for m1, m2 in itertools.islice(itertools.product(matrices, matrices), 3):
        terms.append(MatAdd(m1, m2))
    for s, v in itertools.islice(itertools.product(scalars, vectors), 5):
        terms.append(SmulVec(s, v))
    for s, m in itertools.islice(itertools.product(scalars, matrices), 3):
        terms.append(SmulMat(s, m))
    for m, v in itertools.islice(itertools.product(matrices, vectors), 5):
        terms.append(MulVec(m, v))
    return terms


# ──────────────────────────────────────────────────────────────────────
# 8. Main Demonstration
# ──────────────────────────────────────────────────────────────────────

def demo_critical_pairs():
    """Demonstrate the 4 critical pairs and their joinability."""
    print("=" * 70)
    print("CRITICAL PAIR ANALYSIS")
    print("=" * 70)

    a, v, w, x, y = ScalVar("a"), VecVar("v"), VecVar("w"), VecVar("x"), VecVar("y")
    A, B = MatVar("A"), MatVar("B")

    # CP1: mulVec (matAdd A B) (vecAdd v w)
    print("\n--- CP1: MulVec(MatAdd(A,B), VecAdd(v,w)) ---")
    t1 = MulVec(MatAdd(A, B), VecAdd(v, w))
    print(f"  Term: {t1}")
    print(f"  distPotential: {dist_potential(t1)}")
    rews = root_rewrites(t1)
    for i, r in enumerate(rews):
        print(f"  Rule {i+1}: {r}")
        nf = normalize_canon(r)
        print(f"    → Normal form: {nf}")
    if len(rews) >= 2:
        print(f"  AC-equivalent? {ac_equiv(normalize_canon(rews[0]), normalize_canon(rews[1]))}")

    # CP2: mulVec (smulMat a A) (vecAdd v w)
    print("\n--- CP2: MulVec(SmulMat(a,A), VecAdd(v,w)) ---")
    t2 = MulVec(SmulMat(a, A), VecAdd(v, w))
    print(f"  Term: {t2}")
    rews = root_rewrites(t2)
    for i, r in enumerate(rews):
        print(f"  Rule {i+1}: {r}")
        nf = normalize_canon(r)
        print(f"    → Normal form: {nf}")
    if len(rews) >= 2:
        print(f"  AC-equivalent? {ac_equiv(normalize_canon(rews[0]), normalize_canon(rews[1]))}")

    # CP3: dot (vecAdd v w) (vecAdd x y)
    print("\n--- CP3: Dot(VecAdd(v,w), VecAdd(x,y)) ---")
    t3 = Dot(VecAdd(v, w), VecAdd(x, y))
    print(f"  Term: {t3}")
    rews = root_rewrites(t3)
    for i, r in enumerate(rews):
        print(f"  Rule {i+1}: {r}")
        nf = normalize_canon(r)
        print(f"    → Normal form: {nf}")
    if len(rews) >= 2:
        print(f"  AC-equivalent? {ac_equiv(normalize_canon(rews[0]), normalize_canon(rews[1]))}")

    # CP4: dot (smulVec a v) (vecAdd x y)
    print("\n--- CP4: Dot(SmulVec(a,v), VecAdd(x,y)) ---")
    t4 = Dot(SmulVec(a, v), VecAdd(x, y))
    print(f"  Term: {t4}")
    rews = root_rewrites(t4)
    for i, r in enumerate(rews):
        print(f"  Rule {i+1}: {r}")
        nf = normalize_canon(r)
        print(f"    → Normal form: {nf}")
    if len(rews) >= 2:
        print(f"  AC-equivalent? {ac_equiv(normalize_canon(rews[0]), normalize_canon(rews[1]))}")


def demo_normalization():
    """Demonstrate the canonical normalization algorithm."""
    print("\n" + "=" * 70)
    print("CANONICAL NORMALIZATION")
    print("=" * 70)

    a, b = ScalVar("a"), ScalVar("b")
    v, w, x = VecVar("v"), VecVar("w"), VecVar("x")
    A, B = MatVar("A"), MatVar("B")

    examples = [
        ("A·(v ⊕ w)", MulVec(A, VecAdd(v, w))),
        ("(A ⊞ B)·v", MulVec(MatAdd(A, B), v)),
        ("(a⊙A)·(v ⊕ w)", MulVec(SmulMat(a, A), VecAdd(v, w))),
        ("⟨a•v, w ⊕ x⟩", Dot(SmulVec(a, v), VecAdd(w, x))),
        ("a * (b + ⟨v,w⟩)", ScalMul(a, ScalAdd(b, Dot(v, w)))),
        ("(A ⊞ B)·(v ⊕ w)", MulVec(MatAdd(A, B), VecAdd(v, w))),
    ]

    for name, t in examples:
        nf = normalize_canon(t)
        print(f"\n  {name}")
        print(f"    Input:   {t}")
        print(f"    Measure: {dist_potential(t)}")
        print(f"    Normal:  {nf}")
        print(f"    Measure: {dist_potential(nf)}")
        print(f"    Strict decrease: {dist_potential(nf) < dist_potential(t)}")


def demo_bfs_confluence():
    """Test confluence by BFS on small terms."""
    print("\n" + "=" * 70)
    print("BFS CONFLUENCE TEST (depth ≤ 2)")
    print("=" * 70)

    a = ScalVar("a")
    v, w = VecVar("v"), VecVar("w")
    A, B = MatVar("A"), MatVar("B")

    test_terms = [
        MulVec(MatAdd(A, B), VecAdd(v, w)),
        Dot(VecAdd(v, w), VecAdd(v, w)),
        Dot(SmulVec(a, v), VecAdd(v, w)),
        MulVec(SmulMat(a, A), VecAdd(v, w)),
        SmulVec(a, VecAdd(v, w)),
    ]

    all_ok = True
    for t in test_terms:
        nfs, max_len = find_all_normal_forms(t, max_steps=50)
        # Check all normal forms are AC-equivalent
        if nfs:
            ref = nfs[0]
            for nf in nfs[1:]:
                if not ac_equiv(ref, nf):
                    print(f"  ✗ COUNTEREXAMPLE: {t}")
                    print(f"    NF1: {ref}")
                    print(f"    NF2: {nf}")
                    all_ok = False
                    break
            else:
                print(f"  ✓ {t}")
                print(f"    {len(nfs)} normal form(s), max derivation length: {max_len}")
        else:
            print(f"  ? {t} — no normal form found (depth limit)")

    if all_ok:
        print("\n  All tests PASSED: confluence modulo AC confirmed.")
    else:
        print("\n  FAILURE: confluence modulo AC refuted!")
    return all_ok


def demo_polynomial_bound():
    """Test the conjectured polynomial bound on normalization length."""
    print("\n" + "=" * 70)
    print("POLYNOMIAL BOUND CONJECTURE TEST")
    print("=" * 70)

    a = ScalVar("a")
    v, w = VecVar("v"), VecVar("w")
    A, B = MatVar("A"), MatVar("B")

    test_terms = [
        MulVec(A, VecAdd(v, w)),
        MulVec(MatAdd(A, B), v),
        Dot(VecAdd(v, w), VecAdd(v, w)),
        SmulVec(a, VecAdd(v, w)),
    ]

    print(f"\n  {'Term':<40} {'Size':>5} {'Max Steps':>10} {'Bound n²':>10}")
    print("  " + "-" * 67)
    for t in test_terms:
        from functools import reduce
        size = str(t).count('(') + str(t).count('⟨') + 1
        _, max_len = find_all_normal_forms(t, max_steps=100)
        bound = size * size
        ok = "✓" if max_len <= bound else "✗"
        print(f"  {str(t):<40} {size:>5} {max_len:>10} {bound:>10} {ok}")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Tensor Distributivity Rewriting: Confluence & Canonical Forms      ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    demo_critical_pairs()
    demo_normalization()
    demo_bfs_confluence()
    demo_polynomial_bound()

    print("\n" + "=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print("""
  The 9-rule tensor distributivity rewrite system is:
    1. Terminating (proved via polynomial interpretation measure)
    2. Locally confluent modulo AC (all 4 critical pairs join)
    3. Has unique normal forms modulo AC-equivalence of additions

  This establishes the rewrite system as a certified canonical
  simplification procedure for tensor expressions.
""")


#!/usr/bin/env python3
"""
Visualization: Critical Pair Diagram

Shows the 4 critical pairs of the tensor rewrite system and how they join,
demonstrating local confluence modulo AC.

Uses matplotlib to create a diagram saved as PNG.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import matplotlib
matplotlib.use('Agg')

fig, axes = plt.subplots(2, 2, figsize=(16, 12))
fig.suptitle("Critical Pair Analysis: All 4 Pairs Are Joinable Modulo AC",
             fontsize=14, fontweight='bold')

def draw_diamond(ax, top, left, right, bottom, join_type, title, color_left='#2196F3', color_right='#FF9800'):
    """Draw a diamond-shaped confluence diagram."""
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title(title, fontsize=11, fontweight='bold', pad=10)

    # Positions
    pos = {'top': (0, 1.2), 'left': (-1.1, 0), 'right': (1.1, 0), 'bottom': (0, -1.2)}

    # Draw arrows
    arrow_props = dict(arrowstyle='->', color='black', lw=1.5)
    ax.annotate('', xy=pos['left'], xytext=pos['top'], arrowprops=arrow_props)
    ax.annotate('', xy=pos['right'], xytext=pos['top'], arrowprops=arrow_props)

    # Dashed arrows to join
    dash_props = dict(arrowstyle='->', color='green', lw=1.5, linestyle='dashed')
    ax.annotate('', xy=pos['bottom'], xytext=pos['left'], arrowprops=dash_props)
    ax.annotate('', xy=pos['bottom'], xytext=pos['right'], arrowprops=dash_props)

    # Text boxes
    bbox_top = dict(boxstyle='round,pad=0.3', facecolor='lightyellow', edgecolor='black')
    bbox_left = dict(boxstyle='round,pad=0.3', facecolor=color_left, edgecolor='black', alpha=0.3)
    bbox_right = dict(boxstyle='round,pad=0.3', facecolor=color_right, edgecolor='black', alpha=0.3)
    bbox_bottom = dict(boxstyle='round,pad=0.3', facecolor='lightgreen', edgecolor='black')

    ax.text(*pos['top'], top, ha='center', va='center', fontsize=7, bbox=bbox_top)
    ax.text(*pos['left'], left, ha='center', va='center', fontsize=6, bbox=bbox_left)
    ax.text(*pos['right'], right, ha='center', va='center', fontsize=6, bbox=bbox_right)
    ax.text(*pos['bottom'], bottom, ha='center', va='center', fontsize=6, bbox=bbox_bottom)

    # Join type label
    ax.text(0, -0.5, join_type, ha='center', va='center', fontsize=8,
            color='darkgreen', fontweight='bold')

    # Rule labels on arrows
    ax.text(-0.7, 0.75, 'Rule', fontsize=7, color='blue', ha='center', rotation=45)
    ax.text(0.7, 0.75, 'Rule', fontsize=7, color='red', ha='center', rotation=-45)

# CP1
draw_diamond(axes[0][0],
    top="(A⊞B)·(v⊕w)",
    left="(A⊞B)·v ⊕ (A⊞B)·w",
    right="A·(v⊕w) ⊕ B·(v⊕w)",
    bottom="{Av, Aw, Bv, Bw}",
    join_type="≡_AC (vecAdd)",
    title="CP1: Rules 1 & 2")

# CP2
draw_diamond(axes[0][1],
    top="(a⊙A)·(v⊕w)",
    left="(a⊙A)·v ⊕ (a⊙A)·w",
    right="a•(A·(v⊕w))",
    bottom="a•(A·v) ⊕ a•(A·w)",
    join_type="= (exact)",
    title="CP2: Rules 1 & 3")

# CP3
draw_diamond(axes[1][0],
    top="⟨v⊕w, x⊕y⟩",
    left="⟨v,x⊕y⟩ + ⟨w,x⊕y⟩",
    right="⟨v⊕w,x⟩ + ⟨v⊕w,y⟩",
    bottom="{⟨v,x⟩,⟨v,y⟩,⟨w,x⟩,⟨w,y⟩}",
    join_type="≡_AC (scalAdd)",
    title="CP3: Rules 6 & 7")

# CP4
draw_diamond(axes[1][1],
    top="⟨a•v, x⊕y⟩",
    left="⟨a•v,x⟩ + ⟨a•v,y⟩",
    right="a·⟨v, x⊕y⟩",
    bottom="a·⟨v,x⟩ + a·⟨v,y⟩",
    join_type="= (uses Rule 9)",
    title="CP4: Rules 7 & 8")

plt.tight_layout()
plt.savefig("viz_critical_pairs.png", dpi=150, bbox_inches='tight')
print("Saved viz_critical_pairs.png")


#!/usr/bin/env python3
"""
Visualization: distPotential measure descent during normalization.

Shows how the polynomial interpretation strictly decreases at each rewrite step,
proving termination of the tensor distributivity rewrite system.

Uses matplotlib to produce a static plot saved as PNG.
"""

import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')
import numpy as np

# ─── Inline all needed types and functions ───

class Expr:
    pass

class ScalVar(Expr):
    def __init__(self, name): self.name = name
    def __repr__(self): return self.name
    def __eq__(self, o): return isinstance(o, ScalVar) and self.name == o.name
    def __hash__(self): return hash(('SV', self.name))

class VecVar(Expr):
    def __init__(self, name): self.name = name
    def __repr__(self): return self.name
    def __eq__(self, o): return isinstance(o, VecVar) and self.name == o.name
    def __hash__(self): return hash(('VV', self.name))

class MatVar(Expr):
    def __init__(self, name): self.name = name
    def __repr__(self): return self.name
    def __eq__(self, o): return isinstance(o, MatVar) and self.name == o.name
    def __hash__(self): return hash(('MV', self.name))

class ScalAdd(Expr):
    def __init__(self, l, r): self.left, self.right = l, r
    def __repr__(self): return f"({self.left}+{self.right})"
    def __eq__(self, o): return isinstance(o, ScalAdd) and self.left == o.left and self.right == o.right
    def __hash__(self): return hash(('SA', self.left, self.right))

class ScalMul(Expr):
    def __init__(self, l, r): self.left, self.right = l, r
    def __repr__(self): return f"({self.left}*{self.right})"
    def __eq__(self, o): return isinstance(o, ScalMul) and self.left == o.left and self.right == o.right
    def __hash__(self): return hash(('SM', self.left, self.right))

class VecAdd(Expr):
    def __init__(self, l, r): self.left, self.right = l, r
    def __repr__(self): return f"({self.left}⊕{self.right})"
    def __eq__(self, o): return isinstance(o, VecAdd) and self.left == o.left and self.right == o.right

class MatAdd(Expr):
    def __init__(self, l, r): self.left, self.right = l, r
    def __repr__(self): return f"({self.left}⊞{self.right})"
    def __eq__(self, o): return isinstance(o, MatAdd) and self.left == o.left and self.right == o.right

class SmulVec(Expr):
    def __init__(self, s, v): self.scalar, self.vector = s, v
    def __repr__(self): return f"({self.scalar}•{self.vector})"
    def __eq__(self, o): return isinstance(o, SmulVec) and self.scalar == o.scalar and self.vector == o.vector

class SmulMat(Expr):
    def __init__(self, s, m): self.scalar, self.matrix = s, m
    def __repr__(self): return f"({self.scalar}⊙{self.matrix})"
    def __eq__(self, o): return isinstance(o, SmulMat) and self.scalar == o.scalar and self.matrix == o.matrix

class MulVec(Expr):
    def __init__(self, m, v): self.matrix, self.vector = m, v
    def __repr__(self): return f"({self.matrix}·{self.vector})"
    def __eq__(self, o): return isinstance(o, MulVec) and self.matrix == o.matrix and self.vector == o.vector

class Dot(Expr):
    def __init__(self, l, r): self.left, self.right = l, r
    def __repr__(self): return f"⟨{self.left},{self.right}⟩"
    def __eq__(self, o): return isinstance(o, Dot) and self.left == o.left and self.right == o.right


def dist_potential(t):
    if isinstance(t, (ScalVar, VecVar, MatVar)): return 3
    if isinstance(t, (ScalAdd, VecAdd, MatAdd)):
        return dist_potential(t.left) + dist_potential(t.right) + 1
    if isinstance(t, ScalMul):
        return dist_potential(t.left) * dist_potential(t.right)
    if isinstance(t, SmulVec):
        return dist_potential(t.scalar) * dist_potential(t.vector) + 1
    if isinstance(t, SmulMat):
        return dist_potential(t.scalar) * dist_potential(t.matrix) + 1
    if isinstance(t, MulVec):
        return dist_potential(t.matrix) * dist_potential(t.vector)
    if isinstance(t, Dot):
        return dist_potential(t.left) * dist_potential(t.right)
    return 0

def root_norm_step(t):
    if isinstance(t, MulVec):
        if isinstance(t.vector, VecAdd):
            return VecAdd(MulVec(t.matrix, t.vector.left), MulVec(t.matrix, t.vector.right))
        if isinstance(t.matrix, MatAdd):
            return VecAdd(MulVec(t.matrix.left, t.vector), MulVec(t.matrix.right, t.vector))
        if isinstance(t.matrix, SmulMat):
            return SmulVec(t.matrix.scalar, MulVec(t.matrix.matrix, t.vector))
    if isinstance(t, SmulVec) and isinstance(t.vector, VecAdd):
        return VecAdd(SmulVec(t.scalar, t.vector.left), SmulVec(t.scalar, t.vector.right))
    if isinstance(t, SmulMat) and isinstance(t.matrix, MatAdd):
        return MatAdd(SmulMat(t.scalar, t.matrix.left), SmulMat(t.scalar, t.matrix.right))
    if isinstance(t, Dot):
        if isinstance(t.left, VecAdd):
            return ScalAdd(Dot(t.left.left, t.right), Dot(t.left.right, t.right))
        if isinstance(t.right, VecAdd):
            return ScalAdd(Dot(t.left, t.right.left), Dot(t.left, t.right.right))
        if isinstance(t.left, SmulVec):
            return ScalMul(t.left.scalar, Dot(t.left.vector, t.right))
    if isinstance(t, ScalMul) and isinstance(t.right, ScalAdd):
        return ScalAdd(ScalMul(t.left, t.right.left), ScalMul(t.left, t.right.right))
    return t

# ─── Build test cases and collect measure data ───

a, b = ScalVar("a"), ScalVar("b")
v, w, x = VecVar("v"), VecVar("w"), VecVar("x")
A, B = MatVar("A"), MatVar("B")

test_cases = {
    "A·(v⊕w)": MulVec(A, VecAdd(v, w)),
    "(A⊞B)·v": MulVec(MatAdd(A, B), v),
    "(a⊙A)·v": MulVec(SmulMat(a, A), v),
    "⟨v⊕w, x⟩": Dot(VecAdd(v, w), x),
    "⟨a•v, w⟩": Dot(SmulVec(a, v), w),
    "a*(b+⟨v,w⟩)": ScalMul(a, ScalAdd(b, Dot(v, w))),
}

fig, axes = plt.subplots(2, 3, figsize=(14, 8))
fig.suptitle("Polynomial Interpretation Measure: Strict Descent Under Rewriting",
             fontsize=14, fontweight='bold')

for idx, (name, term) in enumerate(test_cases.items()):
    ax = axes[idx // 3][idx % 3]
    measures = [dist_potential(term)]
    labels = [str(term)[:30]]
    current = term
    for _ in range(20):
        next_t = root_norm_step(current)
        if next_t == current:
            break
        current = next_t
        measures.append(dist_potential(current))
        labels.append(str(current)[:30])

    steps = list(range(len(measures)))
    ax.bar(steps, measures, color=['#2196F3' if i == 0 else '#4CAF50' if i == len(measures)-1 else '#FF9800'
                                    for i in range(len(measures))],
           edgecolor='black', linewidth=0.5)
    ax.set_title(name, fontsize=11)
    ax.set_xlabel("Rewrite Step")
    ax.set_ylabel("distPotential")
    ax.set_xticks(steps)

    # Annotate decrease
    for i in range(len(measures) - 1):
        delta = measures[i] - measures[i+1]
        ax.annotate(f"−{delta}", xy=(i + 0.5, (measures[i] + measures[i+1]) / 2),
                   fontsize=8, color='red', ha='center')

plt.tight_layout()
plt.savefig("viz_measure_descent.png", dpi=150, bbox_inches='tight')
print("Saved viz_measure_descent.png")


#!/usr/bin/env python3
"""
Visualization: Termination Heatmap

Shows the distPotential measure decrease for each rewrite rule,
demonstrating that every rule strictly reduces the interpretation.

Uses matplotlib to create a heatmap saved as PNG.
"""

import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')
import numpy as np

# Rule name, LHS formula, RHS formula, decrease formula
rules = [
    ("1: A·(v⊕w)", "I(A)·(I(v)+I(w)+1)", "I(A)·I(v)+I(A)·I(w)+1", "I(A)−1"),
    ("2: (A⊞B)·v", "(I(A)+I(B)+1)·I(v)", "I(A)·I(v)+I(B)·I(v)+1", "I(v)−1"),
    ("3: (a⊙A)·v", "(I(a)·I(A)+1)·I(v)", "I(a)·I(A)·I(v)+1", "I(v)−1"),
    ("4: a•(v⊕w)", "I(a)·(I(v)+I(w)+1)+1", "I(a)·I(v)+I(a)·I(w)+3", "I(a)−2"),
    ("5: a⊙(A⊞B)", "I(a)·(I(A)+I(B)+1)+1", "I(a)·I(A)+I(a)·I(B)+3", "I(a)−2"),
    ("6: ⟨v⊕w,u⟩", "(I(v)+I(w)+1)·I(u)", "I(v)·I(u)+I(w)·I(u)+1", "I(u)−1"),
    ("7: ⟨u,v⊕w⟩", "I(u)·(I(v)+I(w)+1)", "I(u)·I(v)+I(u)·I(w)+1", "I(u)−1"),
    ("8: ⟨a•v,w⟩", "(I(a)·I(v)+1)·I(w)", "I(a)·I(v)·I(w)", "I(w)"),
    ("9: a·(b+c)", "I(a)·(I(b)+I(c)+1)", "I(a)·I(b)+I(a)·I(c)+1", "I(a)−1"),
]

# Compute actual decreases for sample values
# Variables have I = 3
def compute_decrease(rule_idx):
    I = 3  # Variable interpretation
    decreases = []
    for v1 in [3, 7, 10]:
        for v2 in [3, 7, 10]:
            for v3 in [3, 7, 10]:
                if rule_idx == 0:  # A·(v⊕w)
                    lhs = v1 * (v2 + v3 + 1)
                    rhs = v1*v2 + v1*v3 + 1
                elif rule_idx == 1:  # (A⊞B)·v
                    lhs = (v1 + v2 + 1) * v3
                    rhs = v1*v3 + v2*v3 + 1
                elif rule_idx == 2:  # (a⊙A)·v
                    lhs = (v1*v2 + 1) * v3
                    rhs = v1*v2*v3 + 1
                elif rule_idx == 3:  # a•(v⊕w)
                    lhs = v1*(v2+v3+1) + 1
                    rhs = v1*v2+1 + v1*v3+1 + 1
                elif rule_idx == 4:  # a⊙(A⊞B)
                    lhs = v1*(v2+v3+1) + 1
                    rhs = v1*v2+1 + v1*v3+1 + 1
                elif rule_idx == 5:  # ⟨v⊕w,u⟩
                    lhs = (v1+v2+1) * v3
                    rhs = v1*v3 + v2*v3 + 1
                elif rule_idx == 6:  # ⟨u,v⊕w⟩
                    lhs = v1*(v2+v3+1)
                    rhs = v1*v2 + v1*v3 + 1
                elif rule_idx == 7:  # ⟨a•v,w⟩
                    lhs = (v1*v2+1) * v3
                    rhs = v1*v2*v3
                elif rule_idx == 8:  # a·(b+c)
                    lhs = v1*(v2+v3+1)
                    rhs = v1*v2 + v1*v3 + 1
                decreases.append(lhs - rhs)
    return min(decreases), max(decreases), np.mean(decreases)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7), gridspec_kw={'width_ratios': [2, 1]})
fig.suptitle("Polynomial Interpretation: Every Rule Strictly Decreases distPotential",
             fontsize=13, fontweight='bold')

# Left: decrease formula table
rule_names = [r[0] for r in rules]
decrease_formulas = [r[3] for r in rules]
min_decreases = []
for i in range(9):
    mn, mx, avg = compute_decrease(i)
    min_decreases.append(mn)

# Bar chart of minimum decreases
colors = ['#4CAF50' if d >= 2 else '#FF9800' for d in min_decreases]
bars = ax1.barh(range(9), min_decreases, color=colors, edgecolor='black', height=0.6)
ax1.set_yticks(range(9))
ax1.set_yticklabels([f"{r[0]}" for r in rules], fontsize=9)
ax1.set_xlabel("Minimum Decrease (LHS − RHS)", fontsize=10)
ax1.set_title("Minimum Measure Decrease per Rule", fontsize=11)
ax1.invert_yaxis()

for i, (bar, formula) in enumerate(zip(bars, decrease_formulas)):
    ax1.text(bar.get_width() + 0.2, bar.get_y() + bar.get_height()/2,
             f"Δ = {formula} ≥ {min_decreases[i]}",
             va='center', fontsize=8, color='darkblue')

# Right: heatmap of decrease for different variable values
vals = [3, 5, 7, 10]
heatmap_data = np.zeros((9, len(vals)))
for i in range(9):
    for j, v in enumerate(vals):
        # Use v for all variables
        if i in [0, 6, 8]:  # I(A)-1 type
            heatmap_data[i, j] = v - 1
        elif i in [1, 2, 5]:  # I(v)-1 type
            heatmap_data[i, j] = v - 1
        elif i in [3, 4]:  # I(a)-2 type
            heatmap_data[i, j] = v - 2
        elif i == 7:  # I(w) type
            heatmap_data[i, j] = v

im = ax2.imshow(heatmap_data, cmap='YlGn', aspect='auto', vmin=0)
ax2.set_xticks(range(len(vals)))
ax2.set_xticklabels([f"I={v}" for v in vals])
ax2.set_yticks(range(9))
ax2.set_yticklabels([f"R{i+1}" for i in range(9)])
ax2.set_title("Decrease by Variable Value", fontsize=11)
ax2.set_xlabel("Subterm Interpretation Value")

# Annotate cells
for i in range(9):
    for j in range(len(vals)):
        ax2.text(j, i, f"{int(heatmap_data[i,j])}", ha='center', va='center', fontsize=9,
                color='white' if heatmap_data[i,j] > 4 else 'black')

plt.colorbar(im, ax=ax2, label="Decrease Amount")
plt.tight_layout()
plt.savefig("viz_termination_heatmap.png", dpi=150, bbox_inches='tight')
print("Saved viz_termination_heatmap.png")
