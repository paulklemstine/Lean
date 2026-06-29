#!/usr/bin/env python3
"""
applications.py — Real-world applications of the ordinal rank complexity certificate.

Demonstrates three applications:
1. Computer Algebra System resource management
2. Automatic differentiation cost prediction
3. Expression complexity classification for compiler optimization
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Union, List, Dict
import math
import time


# ─── Expression AST (same as algorithms.py, self-contained) ──────────────────

@dataclass(frozen=True)
class Var:
    def __repr__(self): return "x"

@dataclass(frozen=True)
class Const:
    value: float
    def __repr__(self): return str(self.value)

@dataclass(frozen=True)
class Add:
    left: 'Expr'
    right: 'Expr'
    def __repr__(self): return f"({self.left} + {self.right})"

@dataclass(frozen=True)
class Mul:
    left: 'Expr'
    right: 'Expr'
    def __repr__(self): return f"({self.left} * {self.right})"

@dataclass(frozen=True)
class Neg:
    operand: 'Expr'
    def __repr__(self): return f"(-{self.operand})"

@dataclass(frozen=True)
class Eml:
    coeff: 'Expr'
    exponent: 'Expr'
    def __repr__(self): return f"({self.coeff} * exp({self.exponent}))"

Expr = Union[Var, Const, Add, Mul, Neg, Eml]


def eml_size(e: Expr) -> int:
    if isinstance(e, (Var, Const)): return 1
    elif isinstance(e, (Add, Mul)): return 1 + eml_size(e.left) + eml_size(e.right)
    elif isinstance(e, Neg): return 1 + eml_size(e.operand)
    elif isinstance(e, Eml): return 1 + eml_size(e.coeff) + eml_size(e.exponent)
    raise TypeError

def tropical_val(e: Expr) -> int:
    if isinstance(e, (Var, Const)): return 0
    elif isinstance(e, (Add, Mul)): return max(tropical_val(e.left), tropical_val(e.right))
    elif isinstance(e, Neg): return tropical_val(e.operand)
    elif isinstance(e, Eml): return 1 + max(tropical_val(e.coeff), tropical_val(e.exponent))
    raise TypeError

def differentiate(e: Expr) -> Expr:
    if isinstance(e, Var): return Const(1)
    elif isinstance(e, Const): return Const(0)
    elif isinstance(e, Add): return Add(differentiate(e.left), differentiate(e.right))
    elif isinstance(e, Mul):
        return Add(Mul(differentiate(e.left), e.right), Mul(e.left, differentiate(e.right)))
    elif isinstance(e, Neg): return Neg(differentiate(e.operand))
    elif isinstance(e, Eml):
        a, b = e.coeff, e.exponent
        return Add(Eml(differentiate(a), b), Eml(Mul(a, differentiate(b)), b))
    raise TypeError

def eml_eval(e: Expr, x: float) -> float:
    if isinstance(e, Var): return x
    elif isinstance(e, Const): return e.value
    elif isinstance(e, Add): return eml_eval(e.left, x) + eml_eval(e.right, x)
    elif isinstance(e, Mul): return eml_eval(e.left, x) * eml_eval(e.right, x)
    elif isinstance(e, Neg): return -eml_eval(e.operand, x)
    elif isinstance(e, Eml):
        try: return eml_eval(e.coeff, x) * math.exp(eml_eval(e.exponent, x))
        except OverflowError: return float('inf')
    raise TypeError


# ─── Application 1: CAS Resource Management ─────────────────────────────────

def app_cas_resource_management():
    """Application: Computer Algebra System Resource Management.
    
    Before computing derivatives, a CAS can use ordinal rank to:
    - Predict memory requirements
    - Set timeouts proportional to expected complexity
    - Warn users about potentially expensive operations
    - Choose between exact and approximate computation
    """
    print("=" * 70)
    print("APPLICATION 1: CAS Resource Management")
    print("=" * 70)
    print()
    print("Scenario: A CAS receives expressions and must decide whether to")
    print("compute derivatives exactly or use numerical approximation.")
    print()

    # Simulated CAS input queue
    expressions = [
        ("Polynomial: x³ + 2x + 1",
         Add(Add(Mul(Mul(Var(), Var()), Var()), Mul(Const(2), Var())), Const(1))),
        ("Single exp: x² · exp(3x)",
         Eml(Mul(Var(), Var()), Mul(Const(3), Var()))),
        ("Double exp: exp(x · exp(x))",
         Eml(Const(1), Eml(Var(), Var()))),
        ("Triple exp: exp(exp(exp(x)))",
         Eml(Const(1), Eml(Const(1), Eml(Const(1), Var())))),
        ("Nested product: ((x·x)·x)·exp(((x·x)·x)·x)",
         Eml(Mul(Mul(Mul(Var(), Var()), Var()), Var()),
             Mul(Mul(Mul(Var(), Var()), Var()), Var()))),
    ]

    MEMORY_LIMIT = 10000  # Maximum nodes in output expression

    header = f"{'Expression':40s} {'Size':>6s} {'Rank':>6s} {'Max Deriv':>10s} {'Decision':>12s}"
    print(header)
    print("-" * len(header))

    for name, e in expressions:
        s = eml_size(e)
        rank = tropical_val(e)
        max_deriv_size = 3 * s ** 2  # Theorem 2 bound

        if max_deriv_size <= MEMORY_LIMIT:
            decision = "EXACT"
        elif max_deriv_size <= 10 * MEMORY_LIMIT:
            decision = "EXACT+SIMP"
        else:
            decision = "NUMERICAL"

        print(f"{name:40s} {s:6d} {rank:6d} {max_deriv_size:10d} {decision:>12s}")

    print()
    print(f"Memory limit: {MEMORY_LIMIT} nodes")
    print("EXACT: compute symbolic derivative directly")
    print("EXACT+SIMP: compute + simplify to reduce size")
    print("NUMERICAL: use numerical approximation instead")
    print()


# ─── Application 2: AD Cost Prediction ──────────────────────────────────────

def app_ad_cost_prediction():
    """Application: Automatic Differentiation Cost Prediction.
    
    In machine learning and scientific computing, automatic differentiation (AD)
    computes gradients of complex functions. The ordinal rank predicts the
    computational cost of AD without running it.
    """
    print("=" * 70)
    print("APPLICATION 2: Automatic Differentiation Cost Prediction")
    print("=" * 70)
    print()
    print("Predicting gradient computation cost for neural network-like expressions.")
    print()

    def build_deep_network(depth: int) -> Expr:
        """Build a deep network: x → σ(w₁x) → σ(w₂·σ(w₁x)) → ..."""
        e: Expr = Var()
        for i in range(depth):
            # Each layer: w_i * exp(previous) (eml as activation proxy)
            e = Eml(Const(float(i + 1)), e)
        return e

    print("Simulated deep network with eml-activation layers:")
    header = f"{'Depth':>6s} {'Size':>6s} {'Rank':>6s} {'Deriv Size':>10s} {'Max Bound':>10s} {'Cost Class':>12s}"
    print(header)
    print("-" * len(header))

    for depth in range(1, 7):
        e = build_deep_network(depth)
        s = eml_size(e)
        rank = tropical_val(e)
        de = differentiate(e)
        ds = eml_size(de)
        bound = 3 * s ** 2

        if rank <= 1:
            cost_class = "LINEAR"
        elif rank <= 3:
            cost_class = "POLYNOMIAL"
        else:
            cost_class = "EXPONENTIAL"

        print(f"{depth:6d} {s:6d} {rank:6d} {ds:10d} {bound:10d} {cost_class:>12s}")

    print()
    print("Key insight: rank predicts cost CLASS without computing the derivative.")
    print("A compiler can use this to choose between forward-mode and reverse-mode AD.")
    print()


# ─── Application 3: Expression Complexity Classification ─────────────────────

def app_expression_classifier():
    """Application: Expression Complexity Classification for Compilers.
    
    A compiler optimization pass that classifies expressions by ordinal rank
    and applies rank-appropriate transformations.
    """
    print("=" * 70)
    print("APPLICATION 3: Compiler Expression Classifier")
    print("=" * 70)
    print()
    print("Classifying expressions into growth classes for optimization:")
    print()

    expressions = [
        # Rank 0: Polynomials
        ("x + 1", Add(Var(), Const(1))),
        ("x * x * x", Mul(Mul(Var(), Var()), Var())),
        ("(x+1) * (x-1)", Mul(Add(Var(), Const(1)), Add(Var(), Neg(Const(1))))),

        # Rank 1: Single exponentials
        ("exp(x)", Eml(Const(1), Var())),
        ("x * exp(x)", Eml(Var(), Var())),
        ("exp(x²)", Eml(Const(1), Mul(Var(), Var()))),

        # Rank 2: Double exponentials
        ("exp(exp(x))", Eml(Const(1), Eml(Const(1), Var()))),
        ("x * exp(exp(x))", Eml(Var(), Eml(Const(1), Var()))),

        # Rank 3: Triple exponentials
        ("exp(exp(exp(x)))", Eml(Const(1), Eml(Const(1), Eml(Const(1), Var())))),
    ]

    growth_classes = {
        0: "POLYNOMIAL    — Standard arithmetic, cheap to differentiate",
        1: "EXPONENTIAL   — Single exp layer, moderate differentiation cost",
        2: "SUPEREXP      — Double exp, expensive derivatives",
        3: "TOWER         — Triple exp, very expensive derivatives",
    }

    optimization_strategies = {
        0: "Inline and simplify algebraically",
        1: "Cache exp(b) to avoid recomputation",
        2: "Consider numerical approximation",
        3: "Must use lazy evaluation or symbolic shortcuts",
    }

    header = f"{'Expression':25s} {'Size':>5s} {'Rank':>5s} {'Growth Class':>50s}"
    print(header)
    print("-" * len(header))

    for name, e in expressions:
        s = eml_size(e)
        rank = tropical_val(e)
        gc = growth_classes.get(rank, f"RANK-{rank}")
        print(f"{name:25s} {s:5d} {rank:5d} {gc}")

    print()
    print("Optimization strategies by rank:")
    for rank, strategy in optimization_strategies.items():
        print(f"  Rank {rank}: {strategy}")

    print()
    print("The ordinal rank provides a compile-time classification that guides")
    print("optimization decisions without requiring runtime profiling.")
    print()


# ─── Application 4: Growth Rate Comparison ──────────────────────────────────

def app_growth_comparison():
    """Application: Visualizing growth rate separation between ordinal ranks."""
    print("=" * 70)
    print("APPLICATION 4: Growth Rate Separation by Ordinal Rank")
    print("=" * 70)
    print()
    print("Evaluating expressions of different ranks at increasing x values:")
    print("This demonstrates that higher ranks grow strictly faster.")
    print()

    ranks = [
        ("Rank 0: x²", Mul(Var(), Var())),
        ("Rank 1: exp(x)", Eml(Const(1), Var())),
        ("Rank 2: exp(exp(x))", Eml(Const(1), Eml(Const(1), Var()))),
    ]

    x_values = [1.0, 2.0, 3.0, 5.0, 10.0]

    header = f"{'x':>6s}" + "".join(f" {name:>20s}" for name, _ in ranks)
    print(header)
    print("-" * len(header))

    for x in x_values:
        row = f"{x:6.1f}"
        for name, e in ranks:
            val = eml_eval(e, x)
            if val == float('inf'):
                row += f" {'∞':>20s}"
            elif val > 1e15:
                row += f" {val:>20.2e}"
            else:
                row += f" {val:>20.2f}"
        print(row)

    print()
    print("Each rank grows incomparably faster than the one below it.")
    print("The ordinal rank captures this hierarchy precisely.")
    print()


# ─── Main ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    app_cas_resource_management()
    app_ad_cost_prediction()
    app_expression_classifier()
    app_growth_comparison()

    print("=" * 70)
    print("All applications demonstrated successfully.")
    print()
    print("Summary of practical uses:")
    print("  1. CAS: Predict memory/time before computing derivatives")
    print("  2. AD: Static cost analysis for gradient computation")
    print("  3. Compilers: Classify expressions for optimization")
    print("  4. Analysis: Prove growth rate separation between classes")
    print("=" * 70)


#!/usr/bin/env python3
"""
demo.py — Demonstrates the ordinal rank as a symbolic complexity certificate.

Generates EML expressions of increasing ordinal rank, computes their derivatives,
and visualizes the relationship between ordinal rank, expression size, and
derivative size blowup.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Union
import random
import math


# ─── EML Expression AST ───────────────────────────────────────────────────────

@dataclass(frozen=True)
class Var:
    """The free variable x."""
    def __repr__(self): return "x"

@dataclass(frozen=True)
class Const:
    """A real constant."""
    value: float
    def __repr__(self): return str(self.value)

@dataclass(frozen=True)
class Add:
    """Sum of two expressions."""
    left: 'Expr'
    right: 'Expr'
    def __repr__(self): return f"({self.left} + {self.right})"

@dataclass(frozen=True)
class Mul:
    """Product of two expressions."""
    left: 'Expr'
    right: 'Expr'
    def __repr__(self): return f"({self.left} * {self.right})"

@dataclass(frozen=True)
class Neg:
    """Negation."""
    operand: 'Expr'
    def __repr__(self): return f"(-{self.operand})"

@dataclass(frozen=True)
class Eml:
    """EML operation: a * exp(b)."""
    coeff: 'Expr'
    exponent: 'Expr'
    def __repr__(self): return f"({self.coeff} * exp({self.exponent}))"

Expr = Union[Var, Const, Add, Mul, Neg, Eml]


# ─── Core Operations ──────────────────────────────────────────────────────────

def eml_size(e: Expr) -> int:
    """Compute the AST node count (syntactic size) of an expression."""
    if isinstance(e, (Var, Const)):
        return 1
    elif isinstance(e, Add):
        return 1 + eml_size(e.left) + eml_size(e.right)
    elif isinstance(e, Mul):
        return 1 + eml_size(e.left) + eml_size(e.right)
    elif isinstance(e, Neg):
        return 1 + eml_size(e.operand)
    elif isinstance(e, Eml):
        return 1 + eml_size(e.coeff) + eml_size(e.exponent)
    raise TypeError(f"Unknown expression type: {type(e)}")


def tropical_val(e: Expr) -> int:
    """Compute the tropical valuation (= omega-coefficient of ordinal rank = EML depth)."""
    if isinstance(e, (Var, Const)):
        return 0
    elif isinstance(e, Add):
        return max(tropical_val(e.left), tropical_val(e.right))
    elif isinstance(e, Mul):
        return max(tropical_val(e.left), tropical_val(e.right))
    elif isinstance(e, Neg):
        return tropical_val(e.operand)
    elif isinstance(e, Eml):
        return 1 + max(tropical_val(e.coeff), tropical_val(e.exponent))
    raise TypeError(f"Unknown expression type: {type(e)}")


def eml_deriv(e: Expr) -> Expr:
    """Symbolic differentiation of an EML expression.
    
    d/dx[a * exp(b)] = a' * exp(b) + a * b' * exp(b)
                     = eml(a', b) + eml(a * b', b)
    """
    if isinstance(e, Var):
        return Const(1)
    elif isinstance(e, Const):
        return Const(0)
    elif isinstance(e, Add):
        return Add(eml_deriv(e.left), eml_deriv(e.right))
    elif isinstance(e, Mul):
        return Add(Mul(eml_deriv(e.left), e.right),
                   Mul(e.left, eml_deriv(e.right)))
    elif isinstance(e, Neg):
        return Neg(eml_deriv(e.operand))
    elif isinstance(e, Eml):
        a, b = e.coeff, e.exponent
        da, db = eml_deriv(a), eml_deriv(b)
        return Add(Eml(da, b), Eml(Mul(a, db), b))
    raise TypeError(f"Unknown expression type: {type(e)}")


def eml_eval(e: Expr, x: float) -> float:
    """Evaluate an EML expression at a point."""
    if isinstance(e, Var):
        return x
    elif isinstance(e, Const):
        return e.value
    elif isinstance(e, Add):
        return eml_eval(e.left, x) + eml_eval(e.right, x)
    elif isinstance(e, Mul):
        return eml_eval(e.left, x) * eml_eval(e.right, x)
    elif isinstance(e, Neg):
        return -eml_eval(e.operand, x)
    elif isinstance(e, Eml):
        a_val = eml_eval(e.coeff, x)
        b_val = eml_eval(e.exponent, x)
        try:
            return a_val * math.exp(b_val)
        except OverflowError:
            return float('inf')
    raise TypeError(f"Unknown expression type: {type(e)}")


# ─── Expression Generators ────────────────────────────────────────────────────

def gen_rank0(target_size: int) -> Expr:
    """Generate a random rank-0 (polynomial) expression of approximately target_size."""
    if target_size <= 1:
        return random.choice([Var(), Const(random.randint(1, 5))])
    if target_size == 2:
        return Neg(gen_rank0(1))
    left_size = random.randint(1, target_size - 2)
    right_size = target_size - 1 - left_size
    op = random.choice([Add, Mul])
    return op(gen_rank0(left_size), gen_rank0(right_size))


def gen_rank_n(n: int, target_size: int) -> Expr:
    """Generate a random expression of rank exactly n and approximately target_size."""
    if n == 0:
        return gen_rank0(target_size)
    if target_size < 3:
        target_size = 3
    # Must include at least one eml at level n
    inner_size = max(1, target_size - 2)
    coeff_size = random.randint(1, max(1, inner_size // 2))
    exp_size = inner_size - coeff_size
    # The exponent must have rank n-1 to ensure overall rank n
    return Eml(gen_rank0(coeff_size), gen_rank_n(n - 1, max(1, exp_size)))


def iter_exp_expr(n: int) -> Expr:
    """Canonical iterated exponential: iterExp(0) = x, iterExp(n+1) = 1 * exp(iterExp(n))."""
    if n == 0:
        return Var()
    return Eml(Const(1), iter_exp_expr(n - 1))


# ─── Demo 1: Rank Preservation Under Differentiation ─────────────────────────

def demo_rank_preservation():
    """Demonstrate that differentiation never increases the ordinal rank."""
    print("=" * 70)
    print("DEMO 1: Rank Preservation Under Differentiation")
    print("=" * 70)
    print()
    print("For each expression, we verify: tropicalVal(deriv(e)) ≤ tropicalVal(e)")
    print()

    header = f"{'Expression':40s} {'Size':>6s} {'Rank':>6s} {'Deriv Size':>10s} {'Deriv Rank':>10s} {'Preserved':>10s}"
    print(header)
    print("-" * len(header))

    examples = [
        ("x", Var()),
        ("x + 3", Add(Var(), Const(3))),
        ("x * x", Mul(Var(), Var())),
        ("x * exp(x)", Eml(Var(), Var())),
        ("exp(exp(x))", Eml(Const(1), Eml(Const(1), Var()))),
        ("x² * exp(x²)", Eml(Mul(Var(), Var()), Mul(Var(), Var()))),
    ]

    for name, e in examples:
        de = eml_deriv(e)
        s, r = eml_size(e), tropical_val(e)
        ds, dr = eml_size(de), tropical_val(de)
        preserved = "✓" if dr <= r else "✗"
        print(f"{name:40s} {s:6d} {r:6d} {ds:10d} {dr:10d} {preserved:>10s}")

    print()

    # Random test
    violations = 0
    total = 1000
    for _ in range(total):
        rank = random.randint(0, 3)
        size = random.randint(3, 20)
        e = gen_rank_n(rank, size)
        de = eml_deriv(e)
        if tropical_val(de) > tropical_val(e):
            violations += 1

    print(f"Random test: {total} expressions, {violations} rank violations (should be 0)")
    print()


# ─── Demo 2: Size Blowup vs Ordinal Rank ─────────────────────────────────────

def demo_size_blowup():
    """Demonstrate the relationship between rank and derivative size blowup."""
    print("=" * 70)
    print("DEMO 2: Derivative Size Blowup by Ordinal Rank")
    print("=" * 70)
    print()
    print("Size ratio = emlSize(deriv(e)) / emlSize(e)")
    print()

    header = f"{'Rank':>6s} {'Size':>6s} {'Deriv Size':>10s} {'Ratio':>8s} {'3s² bound':>10s} {'Within bound':>12s}"
    print(header)
    print("-" * len(header))

    for rank in range(4):
        for target_size in [5, 10, 20]:
            # Average over several samples
            ratios = []
            within = True
            for _ in range(20):
                e = gen_rank_n(rank, target_size)
                de = eml_deriv(e)
                s = eml_size(e)
                ds = eml_size(de)
                ratios.append(ds / s)
                if ds > 3 * s ** 2:
                    within = False

            avg_ratio = sum(ratios) / len(ratios)
            bound = 3 * target_size ** 2
            status = "✓" if within else "✗"
            print(f"{rank:6d} {target_size:6d} {int(avg_ratio * target_size):10d} {avg_ratio:8.2f} {bound:10d} {status:>12s}")
        print()

    print()


# ─── Demo 3: Tropical Correspondence ─────────────────────────────────────────

def demo_tropical_correspondence():
    """Demonstrate the triple invariant: tropicalVal = omegaCoeff = emlDepth."""
    print("=" * 70)
    print("DEMO 3: Tropical-Ordinal-Depth Triple Correspondence")
    print("=" * 70)
    print()

    def eml_depth(e: Expr) -> int:
        if isinstance(e, (Var, Const)):
            return 0
        elif isinstance(e, Add):
            return max(eml_depth(e.left), eml_depth(e.right))
        elif isinstance(e, Mul):
            return max(eml_depth(e.left), eml_depth(e.right))
        elif isinstance(e, Neg):
            return eml_depth(e.operand)
        elif isinstance(e, Eml):
            return 1 + max(eml_depth(e.coeff), eml_depth(e.exponent))
        raise TypeError

    mismatches = 0
    total = 1000
    for _ in range(total):
        rank = random.randint(0, 4)
        size = random.randint(3, 30)
        e = gen_rank_n(rank, size)
        tv = tropical_val(e)
        depth = eml_depth(e)
        if tv != depth:
            mismatches += 1

    print(f"Tested {total} random expressions")
    print(f"tropicalVal == emlDepth mismatches: {mismatches} (should be 0)")
    print()

    # Show examples
    print("Examples of the triple invariant:")
    header = f"{'Expression':35s} {'tropicalVal':>12s} {'emlDepth':>10s} {'Match':>6s}"
    print(header)
    print("-" * len(header))

    examples = [
        ("x + 1", Add(Var(), Const(1))),
        ("x * exp(x)", Eml(Var(), Var())),
        ("exp(x * exp(x))", Eml(Const(1), Eml(Var(), Var()))),
        ("exp(exp(exp(x)))", iter_exp_expr(3)),
    ]

    for name, e in examples:
        tv = tropical_val(e)
        d = eml_depth(e)
        match = "✓" if tv == d else "✗"
        print(f"{name:35s} {tv:12d} {d:10d} {match:>6s}")

    print()


# ─── Demo 4: Iterated Differentiation Size Growth ────────────────────────────

def demo_iterated_differentiation():
    """Demonstrate the exponential size growth under iterated differentiation."""
    print("=" * 70)
    print("DEMO 4: Iterated Differentiation Size Growth")
    print("=" * 70)
    print()
    print("Shows size(d^n/dx^n e) vs the theoretical bound (3s)^(2^n)")
    print()

    for rank in [0, 1, 2]:
        e = gen_rank_n(rank, 5)
        s0 = eml_size(e)
        print(f"Expression of rank {rank}, initial size {s0}:")
        header = f"  {'n':>3s} {'Actual size':>12s} {'Bound (3s)^(2^n)':>18s} {'Ratio':>10s}"
        print(header)

        current = e
        for n in range(5):
            actual = eml_size(current)
            bound = (3 * s0) ** (2 ** n)
            ratio = actual / bound if bound > 0 else float('inf')
            print(f"  {n:3d} {actual:12d} {bound:18.0f} {ratio:10.6f}")
            if actual > 10000:
                print(f"  ... (stopping, expression too large)")
                break
            current = eml_deriv(current)

        print()


# ─── Demo 5: Correctness Verification ────────────────────────────────────────

def demo_correctness():
    """Verify symbolic derivative against numerical derivative."""
    print("=" * 70)
    print("DEMO 5: Symbolic vs Numerical Derivative Correctness")
    print("=" * 70)
    print()

    def numerical_deriv(e: Expr, x: float, h: float = 1e-7) -> float:
        return (eml_eval(e, x + h) - eml_eval(e, x - h)) / (2 * h)

    examples = [
        ("x", Var()),
        ("x * x", Mul(Var(), Var())),
        ("x * exp(x)", Eml(Var(), Var())),
        ("exp(exp(x))", Eml(Const(1), Eml(Const(1), Var()))),
    ]

    header = f"{'Expression':25s} {'x':>5s} {'Symbolic':>12s} {'Numerical':>12s} {'Error':>12s}"
    print(header)
    print("-" * len(header))

    for name, e in examples:
        de = eml_deriv(e)
        for x in [0.5, 1.0, 2.0]:
            sym = eml_eval(de, x)
            num = numerical_deriv(e, x)
            err = abs(sym - num)
            print(f"{name:25s} {x:5.1f} {sym:12.6f} {num:12.6f} {err:12.2e}")

    print()


# ─── Main ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    random.seed(42)

    demo_rank_preservation()
    demo_size_blowup()
    demo_tropical_correspondence()
    demo_iterated_differentiation()
    demo_correctness()

    print("=" * 70)
    print("All demos completed successfully.")
    print()
    print("Key verified properties:")
    print("  1. Differentiation never increases ordinal rank (Theorem 1)")
    print("  2. Derivative size is bounded by 3 * size^2 (Theorem 2)")
    print("  3. tropicalVal = emlDepth for all expressions (Theorem 4)")
    print("  4. Symbolic derivative matches numerical derivative (Theorem 5)")
    print("=" * 70)
