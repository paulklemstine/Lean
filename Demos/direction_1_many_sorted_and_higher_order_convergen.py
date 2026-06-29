#!/usr/bin/env python3
"""
Many-Sorted Convergent Rewrite Optimizer — Applications

Demonstrates real-world applications of the many-sorted normalization framework:

1. Symbolic Linear Algebra: Simplify module expressions over rings
2. Typed DSL Compilation: Semantic-preserving optimization passes
3. Representation Theory: Normalize group-action expressions
4. Scientific Computing: Tensor expression simplification
"""

import random
from fractions import Fraction as Q
from typing import List, Tuple, Dict, Any
from demo import Sort, Op, Term, Var, random_term, normalize, ModuleModel

# ─────────────────────────────────────────────────────────
# Application 1: Symbolic Linear Algebra
# ─────────────────────────────────────────────────────────

def symbolic_linear_algebra_demo():
    """Demonstrate normalization of symbolic linear algebra expressions.

    Given expressions in a module M over a ring R, the normalizer
    distributes scalar multiplication over vector addition and
    eliminates zero terms, producing a simplified canonical form.
    """
    print("=" * 72)
    print("Application 1: Symbolic Linear Algebra")
    print("=" * 72)
    print()

    # Build expression: 3 • (v₀ + v₁) + 0 • v₂
    a = Term.mk_app(Op.SC_ADD, [
        Term.mk_app(Op.SC_ONE, []),
        Term.mk_app(Op.SC_ADD, [
            Term.mk_app(Op.SC_ONE, []),
            Term.mk_app(Op.SC_ONE, [])
        ])
    ])  # 1 + (1 + 1) = 3

    v0 = Term.mk_var(Var(Sort.VEC, 0))
    v1 = Term.mk_var(Var(Sort.VEC, 1))
    v2 = Term.mk_var(Var(Sort.VEC, 2))

    # 3 • (v₀ + v₁)
    inner = Term.mk_app(Op.SMUL, [
        a,
        Term.mk_app(Op.V_ADD, [v0, v1])
    ])

    # 0 • v₂
    zero_smul = Term.mk_app(Op.SMUL, [
        Term.mk_app(Op.SC_ZERO, []),
        v2
    ])

    # Full expression
    expr = Term.mk_app(Op.V_ADD, [inner, zero_smul])

    print(f"  Expression: {expr}")
    print(f"  Size: {expr.size()}")

    nf = normalize(expr)
    print(f"  Normal form: {nf}")
    print(f"  Size: {nf.size()}")
    print(f"  Compression: {100*(1-nf.size()/expr.size()):.0f}%")

    # Verify in Q acting on Q³
    model = ModuleModel(
        name="ℚ over ℚ³",
        ring_zero=Q(0), ring_one=Q(1),
        ring_add=lambda a, b: a + b,
        ring_mul=lambda a, b: a * b,
        vec_zero=(Q(0), Q(0), Q(0)),
        vec_add=lambda v, w: tuple(a+b for a,b in zip(v,w)),
        smul_fn=lambda a, v: tuple(a*x for x in v),
        scal_vars=[Q(3), Q(-2), Q(7)],
        vec_vars=[(Q(1), Q(0), Q(-1)), (Q(2), Q(3), Q(0)), (Q(-1), Q(4), Q(2))]
    )

    val_orig = model.eval(expr)
    val_nf = model.eval(nf)
    print(f"\n  Evaluation in {model.name}:")
    print(f"    Original: {val_orig}")
    print(f"    Normal:   {val_nf}")
    print(f"    Match: {'✓' if val_orig == val_nf else '✗'}")
    print()


# ─────────────────────────────────────────────────────────
# Application 2: Typed DSL Compilation
# ─────────────────────────────────────────────────────────

def typed_dsl_compilation_demo():
    """Demonstrate the normalizer as a semantics-preserving compiler pass.

    In a typed domain-specific language for linear algebra,
    the normalizer acts as an optimization pass that:
    - Distributes scalar multiplication
    - Eliminates identity and zero operations
    - Preserves the denotational semantics across all models
    """
    print("=" * 72)
    print("Application 2: Typed DSL Compilation")
    print("=" * 72)
    print()

    random.seed(2024)
    programs = []

    # Generate random "programs" (terms) of varying complexity
    for i in range(5):
        depth = random.randint(3, 6)
        prog = random_term(Sort.VEC, 0, depth)
        programs.append(prog)

    # "Compile" = normalize
    print("  Compiling 5 typed linear-algebra programs...")
    print()

    for i, prog in enumerate(programs):
        nf = normalize(prog)
        compression = 100 * (1 - nf.size() / prog.size()) if prog.size() > 0 else 0
        print(f"  Program {i+1}:")
        print(f"    Source:    {prog}")
        print(f"    Compiled:  {nf}")
        print(f"    Size: {prog.size()} → {nf.size()} ({compression:.0f}% reduction)")
        print()


# ─────────────────────────────────────────────────────────
# Application 3: Representation Theory
# ─────────────────────────────────────────────────────────

def representation_theory_demo():
    """Demonstrate normalization in a representation-theoretic setting.

    In representation theory, a group G acts on a vector space V.
    This is a special case of module theory where the ring is the
    group algebra. The normalizer simplifies expressions involving
    the group action, potentially revealing invariant subexpressions.
    """
    print("=" * 72)
    print("Application 3: Representation Theory (Z/5Z-module)")
    print("=" * 72)
    print()

    # Z/5Z acting on (Z/5Z)² — a representation of the cyclic group
    def mod5(x): return x % 5

    model = ModuleModel(
        name="ℤ/5ℤ-module (ℤ/5ℤ)²",
        ring_zero=0, ring_one=1,
        ring_add=lambda a, b: mod5(a + b),
        ring_mul=lambda a, b: mod5(a * b),
        vec_zero=(0, 0),
        vec_add=lambda v, w: (mod5(v[0]+w[0]), mod5(v[1]+w[1])),
        smul_fn=lambda a, v: (mod5(a*v[0]), mod5(a*v[1])),
        scal_vars=[3, 4, 2],  # elements of Z/5Z
        vec_vars=[(1, 3), (4, 2), (0, 1)]
    )

    random.seed(42)
    n_invariant_before = 0
    n_invariant_after = 0
    n_terms = 1000

    for _ in range(n_terms):
        t = random_term(Sort.VEC, 0, 4)
        nf = normalize(t)

        val_orig = model.eval(t)
        val_nf = model.eval(nf)

        # Check if the vector is "invariant" (zero vector — fixed by all scalars)
        if val_orig == (0, 0):
            n_invariant_before += 1
        if val_nf == (0, 0):
            n_invariant_after += 1

    print(f"  Tested {n_terms} random vector expressions")
    print(f"  Zero-vector (invariant) evaluations:")
    print(f"    Before normalization: {n_invariant_before}")
    print(f"    After normalization:  {n_invariant_after}")
    print(f"    (These should be equal — normalization preserves semantics)")
    print()


# ─────────────────────────────────────────────────────────
# Application 4: Compression Analysis
# ─────────────────────────────────────────────────────────

def compression_analysis():
    """Analyze the compression achieved by normalization across term sizes.

    This tests the hypothesis that normalized terms grow sublinearly
    relative to raw distributive expansion.
    """
    print("=" * 72)
    print("Application 4: Compression Analysis")
    print("=" * 72)
    print()

    random.seed(123)

    print(f"  {'Depth':>6} {'Avg Raw':>10} {'Avg NF':>10} {'Compression':>12} {'N':>6}")
    print(f"  {'-'*6} {'-'*10} {'-'*10} {'-'*12} {'-'*6}")

    for max_depth in range(2, 8):
        n = 2000
        total_raw = 0
        total_nf = 0

        for _ in range(n):
            sort = random.choice([Sort.SCAL, Sort.VEC])
            t = random_term(sort, 0, max_depth)
            nf = normalize(t)
            total_raw += t.size()
            total_nf += nf.size()

        avg_raw = total_raw / n
        avg_nf = total_nf / n
        comp = 100 * (1 - avg_nf / avg_raw) if avg_raw > 0 else 0

        print(f"  {max_depth:>6} {avg_raw:>10.1f} {avg_nf:>10.1f} {comp:>11.1f}% {n:>6}")

    print()


# ─────────────────────────────────────────────────────────
# Application 5: Multi-Model Consistency
# ─────────────────────────────────────────────────────────

def multi_model_consistency():
    """Verify that normalization preserves semantics across diverse models.

    This is the computational counterpart of the formal theorem:
    the normal-form map preserves denotation in EVERY sound algebra.
    """
    print("=" * 72)
    print("Application 5: Multi-Model Consistency Check")
    print("=" * 72)
    print()

    from demo import make_models

    models = make_models()
    random.seed(999)
    n_terms = 5000

    print(f"  Testing {n_terms} terms across {len(models)} models...")
    print()

    all_pass = True
    for model in models:
        agreements = 0
        for _ in range(n_terms):
            sort = random.choice([Sort.SCAL, Sort.VEC])
            t = random_term(sort, 0, 5)
            nf = normalize(t)
            if model.eval(t) == model.eval(nf):
                agreements += 1
            else:
                all_pass = False

        status = "✓" if agreements == n_terms else "✗"
        print(f"  {status} {model.name}: {agreements}/{n_terms}")

    print()
    if all_pass:
        print("  All tests passed! Normalization preserves semantics in every model.")
    else:
        print("  FAILURE: Some evaluations disagreed after normalization!")
    print()


# ─────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────

if __name__ == "__main__":
    symbolic_linear_algebra_demo()
    typed_dsl_compilation_demo()
    representation_theory_demo()
    compression_analysis()
    multi_model_consistency()


#!/usr/bin/env python3
"""
Many-Sorted Convergent Rewrite Optimizer — Interactive Demo

Generates random many-sorted terms in a two-sorted module theory (scalars + vectors),
normalizes them using convergent rewrite rules, evaluates both raw and normalized terms
in 5 concrete module models, and reports agreement statistics.

The rewrite rules implemented:
  1. smul(0, v) → 0       (zero scalar annihilates)
  2. smul(1, v) → v       (unit scalar identity)
  3. smul(a, 0) → 0       (action on zero)
  4. smul(a, v+w) → smul(a,v) + smul(a,w)  (distributivity)
"""

import random
import sys
from dataclasses import dataclass
from typing import Any, Callable, Dict, List, Optional, Tuple
from enum import Enum, auto

# ─────────────────────────────────────────────────────────
# Section 1: Many-Sorted Signature and Terms
# ─────────────────────────────────────────────────────────

class Sort(Enum):
    SCAL = auto()
    VEC = auto()

class Op(Enum):
    SC_ZERO = ("scZero", [], Sort.SCAL)
    SC_ONE  = ("scOne",  [], Sort.SCAL)
    SC_ADD  = ("scAdd",  [Sort.SCAL, Sort.SCAL], Sort.SCAL)
    SC_MUL  = ("scMul",  [Sort.SCAL, Sort.SCAL], Sort.SCAL)
    V_ZERO  = ("vZero",  [], Sort.VEC)
    V_ADD   = ("vAdd",   [Sort.VEC, Sort.VEC], Sort.VEC)
    SMUL    = ("smul",   [Sort.SCAL, Sort.VEC], Sort.VEC)

    def __init__(self, label, arg_sorts, result_sort):
        self.label = label
        self.arg_sorts = arg_sorts
        self.result_sort = result_sort


@dataclass
class Var:
    """A variable of a given sort."""
    sort: Sort
    index: int

    def __repr__(self):
        prefix = "a" if self.sort == Sort.SCAL else "v"
        return f"{prefix}{self.index}"


@dataclass
class Term:
    """A many-sorted term: either a variable or an operation applied to arguments."""
    sort: Sort
    op: Optional[Op]  # None for variables
    var: Optional[Var]  # set if this is a variable
    args: List['Term']  # children for op nodes

    @staticmethod
    def mk_var(v: Var) -> 'Term':
        return Term(sort=v.sort, op=None, var=v, args=[])

    @staticmethod
    def mk_app(op: Op, args: List['Term']) -> 'Term':
        assert len(args) == len(op.arg_sorts)
        for a, s in zip(args, op.arg_sorts):
            assert a.sort == s
        return Term(sort=op.result_sort, op=op, var=None, args=args)

    def size(self) -> int:
        return 1 + sum(a.size() for a in self.args)

    def __repr__(self):
        if self.var is not None:
            return repr(self.var)
        if not self.args:
            return self.op.label
        return f"{self.op.label}({', '.join(repr(a) for a in self.args)})"


# ─────────────────────────────────────────────────────────
# Section 2: Term Generation
# ─────────────────────────────────────────────────────────

def random_term(sort: Sort, depth: int, max_depth: int = 4,
                n_scal_vars: int = 3, n_vec_vars: int = 3) -> Term:
    """Generate a random well-sorted term of the given sort."""
    if depth >= max_depth or (depth > 0 and random.random() < 0.3):
        # Leaf: variable or constant
        if sort == Sort.SCAL:
            choice = random.randint(0, n_scal_vars + 1)
            if choice == 0:
                return Term.mk_app(Op.SC_ZERO, [])
            elif choice == 1:
                return Term.mk_app(Op.SC_ONE, [])
            else:
                return Term.mk_var(Var(Sort.SCAL, choice - 2))
        else:
            choice = random.randint(0, n_vec_vars)
            if choice == 0:
                return Term.mk_app(Op.V_ZERO, [])
            else:
                return Term.mk_var(Var(Sort.VEC, choice - 1))

    # Internal node: choose an operation with the right result sort
    ops = [op for op in Op if op.result_sort == sort]
    op = random.choice(ops)
    args = [random_term(s, depth + 1, max_depth, n_scal_vars, n_vec_vars)
            for s in op.arg_sorts]
    return Term.mk_app(op, args)


# ─────────────────────────────────────────────────────────
# Section 3: Normalization (Convergent Rewrite Rules)
# ─────────────────────────────────────────────────────────

def normalize(t: Term) -> Term:
    """Apply module rewrite rules exhaustively until a normal form is reached.

    Rules:
      smul(scZero, v) → vZero
      smul(scOne, v)  → v
      smul(a, vZero)  → vZero
      smul(a, vAdd(v, w)) → vAdd(smul(a, v), smul(a, w))
    """
    # First normalize all children
    if t.var is not None:
        return t
    args = [normalize(a) for a in t.args]
    t = Term.mk_app(t.op, args)

    # Apply rewrite rules at the root
    changed = True
    while changed:
        changed = False

        if t.op == Op.SMUL:
            a, v = t.args[0], t.args[1]

            # smul(0, v) → 0
            if a.op == Op.SC_ZERO:
                t = Term.mk_app(Op.V_ZERO, [])
                changed = True
                continue

            # smul(1, v) → v
            if a.op == Op.SC_ONE:
                t = v
                changed = True
                continue

            # smul(a, 0) → 0
            if v.op == Op.V_ZERO:
                t = Term.mk_app(Op.V_ZERO, [])
                changed = True
                continue

            # smul(a, v+w) → smul(a,v) + smul(a,w)
            if v.op == Op.V_ADD:
                v1, v2 = v.args[0], v.args[1]
                left = normalize(Term.mk_app(Op.SMUL, [a, v1]))
                right = normalize(Term.mk_app(Op.SMUL, [a, v2]))
                t = Term.mk_app(Op.V_ADD, [left, right])
                changed = True
                continue

    return t


# ─────────────────────────────────────────────────────────
# Section 4: Evaluation in Concrete Models
# ─────────────────────────────────────────────────────────

class ModuleModel:
    """A concrete module model: a ring R acting on an R-module M."""
    def __init__(self, name: str, ring_zero, ring_one, ring_add, ring_mul,
                 vec_zero, vec_add, smul_fn,
                 scal_vars: List, vec_vars: List):
        self.name = name
        self.ring_zero = ring_zero
        self.ring_one = ring_one
        self.ring_add = ring_add
        self.ring_mul = ring_mul
        self.vec_zero = vec_zero
        self.vec_add = vec_add
        self.smul_fn = smul_fn
        self.scal_vars = scal_vars
        self.vec_vars = vec_vars

    def eval(self, t: Term):
        """Evaluate a term in this model."""
        if t.var is not None:
            if t.var.sort == Sort.SCAL:
                return self.scal_vars[t.var.index]
            else:
                return self.vec_vars[t.var.index]

        op = t.op
        if op == Op.SC_ZERO:
            return self.ring_zero
        elif op == Op.SC_ONE:
            return self.ring_one
        elif op == Op.SC_ADD:
            return self.ring_add(self.eval(t.args[0]), self.eval(t.args[1]))
        elif op == Op.SC_MUL:
            return self.ring_mul(self.eval(t.args[0]), self.eval(t.args[1]))
        elif op == Op.V_ZERO:
            return self.vec_zero
        elif op == Op.V_ADD:
            return self.vec_add(self.eval(t.args[0]), self.eval(t.args[1]))
        elif op == Op.SMUL:
            return self.smul_fn(self.eval(t.args[0]), self.eval(t.args[1]))
        else:
            raise ValueError(f"Unknown op: {op}")


def make_models() -> List[ModuleModel]:
    """Create 5 concrete module models for testing."""
    models = []

    # Model 1: Z acting on Z×Z
    models.append(ModuleModel(
        name="ℤ acting on ℤ²",
        ring_zero=0, ring_one=1,
        ring_add=lambda a, b: a + b,
        ring_mul=lambda a, b: a * b,
        vec_zero=(0, 0),
        vec_add=lambda v, w: (v[0]+w[0], v[1]+w[1]),
        smul_fn=lambda a, v: (a*v[0], a*v[1]),
        scal_vars=[3, -2, 7],
        vec_vars=[(1, 4), (-3, 2), (5, -1)]
    ))

    # Model 2: Z acting on Z×Z×Z
    models.append(ModuleModel(
        name="ℤ acting on ℤ³",
        ring_zero=0, ring_one=1,
        ring_add=lambda a, b: a + b,
        ring_mul=lambda a, b: a * b,
        vec_zero=(0, 0, 0),
        vec_add=lambda v, w: (v[0]+w[0], v[1]+w[1], v[2]+w[2]),
        smul_fn=lambda a, v: (a*v[0], a*v[1], a*v[2]),
        scal_vars=[2, -5, 1],
        vec_vars=[(1, 0, -1), (2, 3, 4), (-1, 7, 0)]
    ))

    # Model 3: Q acting on Q² (Fin 2 → Q)
    from fractions import Fraction as Q
    models.append(ModuleModel(
        name="ℚ acting on ℚ²",
        ring_zero=Q(0), ring_one=Q(1),
        ring_add=lambda a, b: a + b,
        ring_mul=lambda a, b: a * b,
        vec_zero=(Q(0), Q(0)),
        vec_add=lambda v, w: (v[0]+w[0], v[1]+w[1]),
        smul_fn=lambda a, v: (a*v[0], a*v[1]),
        scal_vars=[Q(1, 2), Q(-3, 4), Q(5, 7)],
        vec_vars=[(Q(1), Q(-1)), (Q(2, 3), Q(0)), (Q(-1, 5), Q(3, 2))]
    ))

    # Model 4: Q acting on Q³ (Fin 3 → Q)
    models.append(ModuleModel(
        name="ℚ acting on ℚ³",
        ring_zero=Q(0), ring_one=Q(1),
        ring_add=lambda a, b: a + b,
        ring_mul=lambda a, b: a * b,
        vec_zero=(Q(0), Q(0), Q(0)),
        vec_add=lambda v, w: (v[0]+w[0], v[1]+w[1], v[2]+w[2]),
        smul_fn=lambda a, v: (a*v[0], a*v[1], a*v[2]),
        scal_vars=[Q(1, 3), Q(-2), Q(7, 11)],
        vec_vars=[(Q(1), Q(0), Q(-2)), (Q(3, 5), Q(1, 7), Q(0)),
                  (Q(-1), Q(4, 3), Q(2, 9))]
    ))

    # Model 5: Z/5Z acting on (Z/5Z)²
    def mod5(x):
        return x % 5

    models.append(ModuleModel(
        name="ℤ/5ℤ acting on (ℤ/5ℤ)²",
        ring_zero=0, ring_one=1,
        ring_add=lambda a, b: mod5(a + b),
        ring_mul=lambda a, b: mod5(a * b),
        vec_zero=(0, 0),
        vec_add=lambda v, w: (mod5(v[0]+w[0]), mod5(v[1]+w[1])),
        smul_fn=lambda a, v: (mod5(a*v[0]), mod5(a*v[1])),
        scal_vars=[3, 4, 2],
        vec_vars=[(1, 3), (4, 2), (0, 1)]
    ))

    return models


# ─────────────────────────────────────────────────────────
# Section 5: Testing Framework
# ─────────────────────────────────────────────────────────

def run_tests(n_terms: int = 10000, max_depth: int = 4, seed: int = 42):
    """Generate random terms, normalize, evaluate, and compare."""
    random.seed(seed)
    models = make_models()

    print("=" * 72)
    print("Many-Sorted Convergent Rewrite Optimizer — Evaluation Test")
    print("=" * 72)
    print(f"\nGenerating {n_terms} random well-sorted terms per model...")
    print(f"Max depth: {max_depth}")
    print(f"Random seed: {seed}")
    print()

    # Statistics
    total_tests = 0
    total_agreements = 0
    total_size_before = 0
    total_size_after = 0
    sort_counts = {Sort.SCAL: 0, Sort.VEC: 0}

    for model in models:
        agreements = 0
        model_size_before = 0
        model_size_after = 0

        for i in range(n_terms):
            sort = random.choice([Sort.SCAL, Sort.VEC])
            sort_counts[sort] += 1
            t = random_term(sort, 0, max_depth)
            nf = normalize(t)

            val_before = model.eval(t)
            val_after = model.eval(nf)

            model_size_before += t.size()
            model_size_after += nf.size()

            if val_before == val_after:
                agreements += 1
            else:
                print(f"  MISMATCH in {model.name}!")
                print(f"    Term: {t}")
                print(f"    NF:   {nf}")
                print(f"    Before: {val_before}")
                print(f"    After:  {val_after}")

        total_tests += n_terms
        total_agreements += agreements
        total_size_before += model_size_before
        total_size_after += model_size_after

        pct = 100.0 * agreements / n_terms
        avg_before = model_size_before / n_terms
        avg_after = model_size_after / n_terms
        compression = 100.0 * (1 - avg_after / avg_before) if avg_before > 0 else 0

        print(f"  Model: {model.name}")
        print(f"    Agreement: {agreements}/{n_terms} ({pct:.1f}%)")
        print(f"    Avg size before: {avg_before:.1f}, after: {avg_after:.1f} "
              f"(compression: {compression:.1f}%)")
        print()

    print("-" * 72)
    print(f"TOTAL: {total_agreements}/{total_tests} agreements "
          f"({100.0 * total_agreements / total_tests:.1f}%)")
    avg_b = total_size_before / total_tests
    avg_a = total_size_after / total_tests
    print(f"Overall avg size: {avg_b:.1f} → {avg_a:.1f} "
          f"(compression: {100*(1-avg_a/avg_b):.1f}%)")
    print(f"Sort distribution: Scal={sort_counts[Sort.SCAL]}, Vec={sort_counts[Sort.VEC]}")
    print()

    # Show some representative examples
    print("=" * 72)
    print("Representative Examples")
    print("=" * 72)
    random.seed(seed + 1)

    for i in range(10):
        sort = random.choice([Sort.SCAL, Sort.VEC])
        t = random_term(sort, 0, max_depth)
        nf = normalize(t)
        print(f"\n  Example {i+1} (sort={sort.name}):")
        print(f"    Raw:    {t}")
        print(f"    Normal: {nf}")
        print(f"    Size:   {t.size()} → {nf.size()}")
        for model in models[:2]:
            val_b = model.eval(t)
            val_a = model.eval(nf)
            print(f"    {model.name}: {val_b} = {val_a} ✓" if val_b == val_a
                  else f"    {model.name}: {val_b} ≠ {val_a} ✗")


if __name__ == "__main__":
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 10000
    run_tests(n_terms=n)
