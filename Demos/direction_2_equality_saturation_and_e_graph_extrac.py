#!/usr/bin/env python3
"""
Applications of Tensor Expression Extraction Optimality

This module demonstrates real-world applications of the extraction optimality theorem:
1. Compiler optimization: minimizing register pressure via canonical forms
2. Symbolic computation: simplifying polynomial expressions
3. Circuit optimization: reducing gate count in linear circuits
"""

from typing import Dict, List, Set, Tuple
from dataclasses import dataclass
import random


# ─────────────────────────────────────────────────────
# AST (self-contained, no local imports)
# ─────────────────────────────────────────────────────

@dataclass(frozen=True)
class TExpr:
    pass

@dataclass(frozen=True)
class Var(TExpr):
    n: int
    def __repr__(self): return f"x{self.n}"

@dataclass(frozen=True)
class Zero(TExpr):
    def __repr__(self): return "0"

@dataclass(frozen=True)
class Add(TExpr):
    left: TExpr
    right: TExpr
    def __repr__(self): return f"({self.left} + {self.right})"

@dataclass(frozen=True)
class Smul(TExpr):
    coeff: int
    expr: TExpr
    def __repr__(self): return f"{self.coeff}·{self.expr}"


def coeff_of(e, n):
    if isinstance(e, Var): return 1 if e.n == n else 0
    if isinstance(e, Zero): return 0
    if isinstance(e, Add): return coeff_of(e.left, n) + coeff_of(e.right, n)
    if isinstance(e, Smul): return e.coeff * coeff_of(e.expr, n)

def distinct_vars(e):
    if isinstance(e, Var): return {e.n}
    if isinstance(e, Zero): return set()
    if isinstance(e, Add): return distinct_vars(e.left) | distinct_vars(e.right)
    if isinstance(e, Smul): return distinct_vars(e.expr)

def effective_support(e):
    return {v: coeff_of(e, v) for v in distinct_vars(e) if coeff_of(e, v) != 0}

def normalize_canon(e):
    support = effective_support(e)
    if not support: return Zero()
    sorted_vars = sorted(support.keys())
    terms = [(support[v], v) for v in sorted_vars]
    def build(t):
        if not t: return Zero()
        c, v = t[0]
        return Add(Smul(c, Var(v)), build(t[1:]))
    return build(terms)

def sharing_cost(e): return len(distinct_vars(e))
def tree_size(e):
    if isinstance(e, (Var, Zero)): return 1
    if isinstance(e, Add): return 1 + tree_size(e.left) + tree_size(e.right)
    if isinstance(e, Smul): return 1 + tree_size(e.expr)

def evaluate(e, rho):
    if isinstance(e, Var): return rho.get(e.n, 0)
    if isinstance(e, Zero): return 0
    if isinstance(e, Add): return evaluate(e.left, rho) + evaluate(e.right, rho)
    if isinstance(e, Smul): return e.coeff * evaluate(e.expr, rho)


# ─────────────────────────────────────────────────────
# Application 1: Compiler Optimization
# ─────────────────────────────────────────────────────

def compiler_optimization_demo():
    """
    Demonstrate how canonical normalization reduces register pressure.

    In a compiler, each distinct variable in an expression corresponds to
    a register that must be live simultaneously. Minimizing the number of
    distinct variables directly reduces register pressure.

    The extraction optimality theorem guarantees that normalizeCanon achieves
    the minimum possible register pressure for any semantically equivalent
    computation.
    """
    print("=" * 60)
    print("APPLICATION 1: Compiler Register Pressure Optimization")
    print("=" * 60)

    # Simulate a computation with redundant variable references
    # result = 2*a + 3*b - a + b - b + c - c
    # which simplifies to a + 3*b
    expr = Add(
        Add(
            Add(Smul(2, Var(0)), Smul(3, Var(1))),
            Add(Smul(-1, Var(0)), Var(1))
        ),
        Add(Smul(-1, Var(1)), Add(Var(2), Smul(-1, Var(2))))
    )

    nf = normalize_canon(expr)

    print(f"\n  Original computation: {expr}")
    print(f"  Canonical form:      {nf}")
    print(f"\n  Register pressure (original):  {sharing_cost(expr)} registers")
    print(f"  Register pressure (canonical): {sharing_cost(nf)} registers")
    print(f"  Savings: {sharing_cost(expr) - sharing_cost(nf)} registers")
    print(f"\n  Verification: both evaluate to same result")

    for trial in range(3):
        rho = {i: random.randint(-10, 10) for i in range(5)}
        v1 = evaluate(expr, rho)
        v2 = evaluate(nf, rho)
        print(f"    rho={rho}: original={v1}, canonical={v2}, match={v1==v2}")


# ─────────────────────────────────────────────────────
# Application 2: Polynomial Simplification
# ─────────────────────────────────────────────────────

def polynomial_simplification_demo():
    """
    Demonstrate canonical normalization as polynomial simplification.

    The coefficient extraction theorem (eval_indicator_eq_coeffOf) shows
    that the coefficient map is a complete invariant: two expressions are
    semantically equivalent iff they have the same coefficients.

    This means canonical normalization is a complete simplification procedure
    for linear polynomial expressions.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Polynomial Simplification")
    print("=" * 60)

    # Create polynomial with cancellations
    # 5x + 3y - 2x + y - 4y = 3x
    poly = Add(
        Add(Smul(5, Var(0)), Smul(3, Var(1))),
        Add(Smul(-2, Var(0)), Add(Var(1), Smul(-4, Var(1))))
    )

    nf = normalize_canon(poly)
    support = effective_support(poly)

    print(f"\n  Polynomial: {poly}")
    print(f"  Simplified: {nf}")
    print(f"  Effective support: {support}")
    print(f"  Variables eliminated: {distinct_vars(poly) - set(support.keys())}")

    # Another example: complete cancellation
    cancel = Add(Smul(3, Var(0)), Smul(-3, Var(0)))
    nf_cancel = normalize_canon(cancel)
    print(f"\n  Complete cancellation: {cancel}")
    print(f"  Simplified: {nf_cancel}")


# ─────────────────────────────────────────────────────
# Application 3: Circuit Optimization
# ─────────────────────────────────────────────────────

def circuit_optimization_demo():
    """
    Demonstrate how sharing cost relates to circuit complexity.

    In a linear arithmetic circuit, each distinct variable is an input wire.
    The sharing cost (number of distinct variables) gives a lower bound on
    the number of input wires needed. Canonical normalization achieves this
    lower bound.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Linear Circuit Optimization")
    print("=" * 60)

    # Generate random circuits and measure optimization
    print("\n  Generating 100 random linear circuits...\n")

    total_savings = 0
    max_savings = 0

    for i in range(100):
        # Random circuit with 3-8 variables, depth 4-6
        n_vars = random.randint(3, 8)
        expr = Var(random.randint(0, n_vars-1))
        for _ in range(random.randint(5, 15)):
            other = Var(random.randint(0, n_vars-1))
            if random.random() < 0.3:
                other = Smul(random.randint(-3, 3), other)
            expr = Add(expr, other)

        nf = normalize_canon(expr)
        saving = sharing_cost(expr) - sharing_cost(nf)
        total_savings += saving
        max_savings = max(max_savings, saving)

    print(f"  Average input wire savings: {total_savings/100:.2f}")
    print(f"  Maximum savings: {max_savings}")
    print(f"  (Savings = original_distinct_vars - canonical_distinct_vars)")


# ─────────────────────────────────────────────────────
# Application 4: Catalan Complexity Reduction
# ─────────────────────────────────────────────────────

def catalan_complexity_demo():
    """
    Demonstrate how canonical normalization reduces Catalan-scale search spaces.

    For n summands, there are C(n-1) distinct binary tree parenthesizations
    (Catalan number) and n! permutations. The total search space is
    C(n-1) · n! expressions. Canonical normalization collapses all of these
    to a single representative.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Catalan Search Space Collapse")
    print("=" * 60)

    def catalan(n):
        if n <= 1: return 1
        c = 1
        for i in range(n):
            c = c * (2*n - i) // (i + 1)
        return c // (n + 1)

    def factorial(n):
        r = 1
        for i in range(2, n+1):
            r *= i
        return r

    print(f"\n  {'n':>3} {'C(n-1)':>10} {'n!':>10} {'Search space':>15} {'Canonical':>10}")
    print("  " + "-" * 55)
    for n in range(2, 11):
        c = catalan(n - 1)
        f = factorial(n)
        space = c * f
        print(f"  {n:>3} {c:>10} {f:>10} {space:>15} {'1':>10}")

    print(f"\n  The extraction optimality theorem guarantees this collapse")
    print(f"  preserves the minimum sharing cost representative.")


# ─────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────

if __name__ == "__main__":
    random.seed(42)
    compiler_optimization_demo()
    polynomial_simplification_demo()
    circuit_optimization_demo()
    catalan_complexity_demo()


#!/usr/bin/env python3
"""
Demo: Tensor Expression Normalization vs E-Graph Extraction

This script demonstrates the core mathematical result:
canonical normalization of tensor expressions computes a minimum-sharing
representative within the semantic equivalence class.

It generates random tensor expressions, normalizes them, compares against
brute-force extraction from a bounded rewrite graph, and reports sharing
cost statistics.
"""

import random
import itertools
from collections import defaultdict
from typing import List, Tuple, Dict, Optional


# ─────────────────────────────────────────────────────
# Section 1: Expression AST
# ─────────────────────────────────────────────────────

class TExpr:
    """Base class for tensor expressions."""
    pass

class Var(TExpr):
    def __init__(self, n: int):
        self.n = n
    def __repr__(self):
        return f"x{self.n}"
    def __eq__(self, other):
        return isinstance(other, Var) and self.n == other.n
    def __hash__(self):
        return hash(("var", self.n))

class Zero(TExpr):
    def __repr__(self):
        return "0"
    def __eq__(self, other):
        return isinstance(other, Zero)
    def __hash__(self):
        return hash("zero")

class Add(TExpr):
    def __init__(self, a: TExpr, b: TExpr):
        self.a = a
        self.b = b
    def __repr__(self):
        return f"({self.a} + {self.b})"
    def __eq__(self, other):
        return isinstance(other, Add) and self.a == other.a and self.b == other.b
    def __hash__(self):
        return hash(("add", self.a, self.b))

class Smul(TExpr):
    def __init__(self, k: int, e: TExpr):
        self.k = k
        self.e = e
    def __repr__(self):
        return f"{self.k}·{self.e}"
    def __eq__(self, other):
        return isinstance(other, Smul) and self.k == other.k and self.e == other.e
    def __hash__(self):
        return hash(("smul", self.k, self.e))


# ─────────────────────────────────────────────────────
# Section 2: Core Operations
# ─────────────────────────────────────────────────────

def evaluate(e: TExpr, rho: Dict[int, int]) -> int:
    """Evaluate expression under assignment rho."""
    if isinstance(e, Var):
        return rho.get(e.n, 0)
    elif isinstance(e, Zero):
        return 0
    elif isinstance(e, Add):
        return evaluate(e.a, rho) + evaluate(e.b, rho)
    elif isinstance(e, Smul):
        return e.k * evaluate(e.e, rho)
    raise TypeError(f"Unknown expression type: {type(e)}")


def coeff_of(e: TExpr, n: int) -> int:
    """Total coefficient of variable n in expression e."""
    if isinstance(e, Var):
        return 1 if e.n == n else 0
    elif isinstance(e, Zero):
        return 0
    elif isinstance(e, Add):
        return coeff_of(e.a, n) + coeff_of(e.b, n)
    elif isinstance(e, Smul):
        return e.k * coeff_of(e.e, n)
    raise TypeError


def distinct_vars(e: TExpr) -> set:
    """Set of variables syntactically appearing in e."""
    if isinstance(e, Var):
        return {e.n}
    elif isinstance(e, Zero):
        return set()
    elif isinstance(e, Add):
        return distinct_vars(e.a) | distinct_vars(e.b)
    elif isinstance(e, Smul):
        return distinct_vars(e.e)
    raise TypeError


def sharing_cost(e: TExpr) -> int:
    """Sharing cost = number of distinct variables mentioned."""
    return len(distinct_vars(e))


def tree_size(e: TExpr) -> int:
    """Number of constructor nodes."""
    if isinstance(e, Var) or isinstance(e, Zero):
        return 1
    elif isinstance(e, Add):
        return 1 + tree_size(e.a) + tree_size(e.b)
    elif isinstance(e, Smul):
        return 1 + tree_size(e.e)
    raise TypeError


def effective_support(e: TExpr) -> dict:
    """Map from variable index to total coefficient, excluding zeros."""
    coeffs = {}
    for v in distinct_vars(e):
        c = coeff_of(e, v)
        if c != 0:
            coeffs[v] = c
    return coeffs


def normalize_canon(e: TExpr) -> TExpr:
    """Canonical normalization: extract coefficients, sort, rebuild."""
    coeffs = effective_support(e)
    if not coeffs:
        return Zero()
    sorted_vars = sorted(coeffs.keys())
    terms = [(coeffs[v], v) for v in sorted_vars]
    result = Smul(terms[-1][0], Var(terms[-1][1]))
    for c, v in reversed(terms[:-1]):
        result = Add(Smul(c, Var(v)), result)
    return result


def sem_equiv(e1: TExpr, e2: TExpr, num_tests: int = 20) -> bool:
    """Probabilistic check of semantic equivalence."""
    all_vars = distinct_vars(e1) | distinct_vars(e2)
    for _ in range(num_tests):
        rho = {v: random.randint(-100, 100) for v in all_vars}
        if evaluate(e1, rho) != evaluate(e2, rho):
            return False
    return True


# ─────────────────────────────────────────────────────
# Section 3: Bounded E-Graph Extraction
# ─────────────────────────────────────────────────────

def apply_ac_steps(e: TExpr) -> List[TExpr]:
    """Generate all one-step AC rewrites of e."""
    results = []

    if isinstance(e, Add):
        # Commutativity
        results.append(Add(e.b, e.a))
        # Associativity
        if isinstance(e.a, Add):
            results.append(Add(e.a.a, Add(e.a.b, e.b)))
        if isinstance(e.b, Add):
            results.append(Add(Add(e.a, e.b.a), e.b.b))
        # Zero elimination
        if isinstance(e.a, Zero):
            results.append(e.b)
        if isinstance(e.b, Zero):
            results.append(e.a)
        # Coefficient merging
        if (isinstance(e.a, Smul) and isinstance(e.b, Smul)
                and e.a.e == e.b.e):
            results.append(Smul(e.a.k + e.b.k, e.a.e))

    if isinstance(e, Smul):
        # Distribution
        if isinstance(e.e, Add):
            results.append(Add(Smul(e.k, e.e.a), Smul(e.k, e.e.b)))
        # Zero scalar
        if e.k == 0:
            results.append(Zero())

    return results


def extract_min_sharing(e: TExpr, fuel: int = 100) -> TExpr:
    """Bounded e-graph extraction: explore rewrites up to fuel steps,
    return the expression with minimum sharing cost."""
    visited = {e}
    frontier = [e]
    best = e
    best_cost = sharing_cost(e)

    for _ in range(fuel):
        if not frontier:
            break
        next_frontier = []
        for expr in frontier:
            for rewrite in apply_ac_steps(expr):
                if rewrite not in visited:
                    visited.add(rewrite)
                    next_frontier.append(rewrite)
                    sc = sharing_cost(rewrite)
                    if sc < best_cost or (sc == best_cost and tree_size(rewrite) < tree_size(best)):
                        best = rewrite
                        best_cost = sc
        frontier = next_frontier

    return best


# ─────────────────────────────────────────────────────
# Section 4: Random Expression Generation
# ─────────────────────────────────────────────────────

def random_expr(max_vars: int = 5, max_depth: int = 4, depth: int = 0) -> TExpr:
    """Generate a random tensor expression."""
    if depth >= max_depth or random.random() < 0.3:
        if random.random() < 0.1:
            return Zero()
        return Var(random.randint(0, max_vars - 1))

    choice = random.random()
    if choice < 0.6:
        return Add(
            random_expr(max_vars, max_depth, depth + 1),
            random_expr(max_vars, max_depth, depth + 1)
        )
    else:
        k = random.randint(-3, 3)
        return Smul(k, random_expr(max_vars, max_depth, depth + 1))


# ─────────────────────────────────────────────────────
# Section 5: Main Demo
# ─────────────────────────────────────────────────────

def run_demo():
    print("=" * 70)
    print("TENSOR EXPRESSION NORMALIZATION vs E-GRAPH EXTRACTION")
    print("Demonstrating the Extraction Optimality Theorem")
    print("=" * 70)

    # Demo 1: Specific examples
    print("\n--- Demo 1: Specific Examples ---\n")

    examples = [
        ("x0 + x0", Add(Var(0), Var(0))),
        ("x0 + (x1 + x0)", Add(Var(0), Add(Var(1), Var(0)))),
        ("2·(x0 + x1) + (-1)·x1", Add(Smul(2, Add(Var(0), Var(1))), Smul(-1, Var(1)))),
        ("x0 + ((-1)·x0 + x1)", Add(Var(0), Add(Smul(-1, Var(0)), Var(1)))),
        ("0·x2 + x0 + x1", Add(Add(Smul(0, Var(2)), Var(0)), Var(1))),
    ]

    for name, expr in examples:
        nf = normalize_canon(expr)
        extracted = extract_min_sharing(expr, fuel=50)
        print(f"  Expression: {name}")
        print(f"    Original:    {expr}")
        print(f"    Normalized:  {nf}")
        print(f"    Extracted:   {extracted}")
        print(f"    Original sharing cost:    {sharing_cost(expr)}")
        print(f"    Normalized sharing cost:  {sharing_cost(nf)}")
        print(f"    Extracted sharing cost:   {sharing_cost(extracted)}")
        print(f"    Soundness check: {sem_equiv(expr, nf)}")
        print(f"    Normalized = Extracted cost: {sharing_cost(nf) == sharing_cost(extracted)}")
        print()

    # Demo 2: Statistical test
    print("\n--- Demo 2: Statistical Test (1000 random expressions) ---\n")

    n_tests = 1000
    canon_wins = 0
    extraction_wins = 0
    ties = 0
    total_original_cost = 0
    total_canon_cost = 0

    for _ in range(n_tests):
        expr = random_expr(max_vars=5, max_depth=5)
        nf = normalize_canon(expr)
        orig_cost = sharing_cost(expr)
        canon_cost = sharing_cost(nf)

        total_original_cost += orig_cost
        total_canon_cost += canon_cost

        if canon_cost < orig_cost:
            canon_wins += 1
        elif orig_cost < canon_cost:
            extraction_wins += 1
        else:
            ties += 1

    print(f"  Tests: {n_tests}")
    print(f"  Canonical form strictly better: {canon_wins} ({100*canon_wins/n_tests:.1f}%)")
    print(f"  Original strictly better: {extraction_wins} ({100*extraction_wins/n_tests:.1f}%)")
    print(f"  Ties: {ties} ({100*ties/n_tests:.1f}%)")
    print(f"  Average original sharing cost: {total_original_cost/n_tests:.2f}")
    print(f"  Average canonical sharing cost: {total_canon_cost/n_tests:.2f}")
    print(f"  Average compression ratio: {total_canon_cost/max(total_original_cost,1):.3f}")

    # Demo 3: Catalan collapse
    print("\n\n--- Demo 3: Catalan Collapse ---")
    print("  All parenthesizations of x0+x1+x2 yield same canonical form:\n")

    leaves = [Var(0), Var(1), Var(2)]
    results = set()
    for perm in itertools.permutations(leaves):
        for split in range(1, len(perm)):
            left_part = perm[:split]
            right_part = perm[split:]

            def build_tree(parts):
                if len(parts) == 1:
                    return parts[0]
                mid = len(parts) // 2
                return Add(build_tree(parts[:mid]), build_tree(parts[mid:]))

            expr = Add(build_tree(list(left_part)), build_tree(list(right_part)))
            nf = normalize_canon(expr)
            results.add(repr(nf))
            print(f"    {expr}  →  {nf}")

    print(f"\n  Distinct canonical forms: {len(results)}")
    print(f"  (Expected: 1 — confirming Catalan collapse theorem)")

    # Demo 4: Conjecture test
    print("\n\n--- Demo 4: Conjecture Test ---")
    print("  Testing: does normalizeCanon always achieve minimum sharing cost?")
    print("  (A counterexample would disprove the conjecture)\n")

    counterexamples = 0
    for i in range(500):
        expr = random_expr(max_vars=4, max_depth=4)
        nf = normalize_canon(expr)
        extracted = extract_min_sharing(expr, fuel=30)
        if sharing_cost(extracted) < sharing_cost(nf):
            counterexamples += 1
            print(f"  COUNTEREXAMPLE: {expr}")
            print(f"    Normalized cost: {sharing_cost(nf)}, Extracted cost: {sharing_cost(extracted)}")

    if counterexamples == 0:
        print(f"  No counterexamples found in 500 tests.")
        print(f"  Consistent with the proven theorem: normalizeCanon is optimal.")
    else:
        print(f"  Found {counterexamples} counterexample(s)!")

    print("\n" + "=" * 70)
    print("CONCLUSION: The canonical form provably minimizes sharing cost")
    print("(distinct variable count) across the entire equivalence class.")
    print("=" * 70)


if __name__ == "__main__":
    random.seed(42)
    run_demo()


#!/usr/bin/env python3
"""
Visualization: Catalan Collapse under Canonical Normalization

This script visualizes how the exponentially large space of binary tree
parenthesizations collapses to a single canonical form under normalization.
It shows the Catalan number growth and the collapse ratio.
"""

import matplotlib.pyplot as plt
import numpy as np
import math


def catalan(n):
    """Compute the nth Catalan number."""
    if n <= 0:
        return 1
    c = 1
    for i in range(n):
        c = c * (2 * n - i) // (i + 1)
    return c // (n + 1)


def factorial(n):
    return math.factorial(n)


# ── Data ──

ns = list(range(2, 16))

catalan_nums = [catalan(n - 1) for n in ns]
factorials = [factorial(n) for n in ns]
search_spaces = [catalan(n - 1) * factorial(n) for n in ns]


# ── Plot ──

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Search space growth
ax1 = axes[0]
ax1.semilogy(ns, catalan_nums, 'o-', color='steelblue', linewidth=2,
             markersize=6, label='Parenthesizations C(n-1)')
ax1.semilogy(ns, factorials, 's-', color='darkorange', linewidth=2,
             markersize=6, label='Permutations n!')
ax1.semilogy(ns, search_spaces, 'D-', color='crimson', linewidth=2,
             markersize=6, label='Total search space C(n-1)·n!')
ax1.axhline(y=1, color='seagreen', linestyle='--', linewidth=3,
            label='Canonical forms (always 1)')
ax1.set_xlabel('Number of summands (n)', fontsize=13)
ax1.set_ylabel('Count (log scale)', fontsize=13)
ax1.set_title('Catalan Collapse:\nExponential Search Space → Single Canonical Form',
              fontsize=14, fontweight='bold')
ax1.legend(fontsize=10, loc='upper left')
ax1.grid(True, alpha=0.3)
ax1.set_xlim(1.5, 15.5)

# Panel 2: Compression ratio
ax2 = axes[1]
compression = [1.0 / s for s in search_spaces]
ax2.semilogy(ns, compression, 'o-', color='purple', linewidth=2, markersize=8)
ax2.fill_between(ns, compression, alpha=0.2, color='purple')
ax2.set_xlabel('Number of summands (n)', fontsize=13)
ax2.set_ylabel('Compression Ratio (1 / search space)', fontsize=13)
ax2.set_title('Compression Power of Canonical Normalization\n'
              '(lower = more expressions collapsed)',
              fontsize=14, fontweight='bold')
ax2.grid(True, alpha=0.3)

# Add annotations
for i, n in enumerate(ns):
    if n in [3, 5, 8, 12, 15]:
        ax2.annotate(f'n={n}\n{search_spaces[i]:,} → 1',
                     (n, compression[i]),
                     textcoords="offset points",
                     xytext=(10, 10),
                     fontsize=9,
                     arrowprops=dict(arrowstyle='->', color='gray'))

plt.tight_layout()
plt.savefig('catalan_collapse.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: catalan_collapse.png")


#!/usr/bin/env python3
"""
Visualization: E-Graph Extraction vs. Canonical Normalization

This script visualizes the agreement between bounded e-graph extraction
and canonical normalization, demonstrating the extraction optimality theorem.
It shows that for tensor expressions, canonical normalization directly
computes what e-graph saturation + extraction would find.
"""

import random
import matplotlib.pyplot as plt
import numpy as np
from dataclasses import dataclass
from typing import Set


# ── Self-contained expression AST and algorithms ──

@dataclass(frozen=True)
class TExpr:
    pass

@dataclass(frozen=True)
class Var(TExpr):
    n: int

@dataclass(frozen=True)
class Zero(TExpr):
    pass

@dataclass(frozen=True)
class Add(TExpr):
    left: TExpr
    right: TExpr

@dataclass(frozen=True)
class Smul(TExpr):
    coeff: int
    expr: TExpr


def coeff_of(e, n):
    if isinstance(e, Var): return 1 if e.n == n else 0
    if isinstance(e, Zero): return 0
    if isinstance(e, Add): return coeff_of(e.left, n) + coeff_of(e.right, n)
    if isinstance(e, Smul): return e.coeff * coeff_of(e.expr, n)
    return 0

def distinct_vars(e):
    if isinstance(e, Var): return {e.n}
    if isinstance(e, Zero): return set()
    if isinstance(e, Add): return distinct_vars(e.left) | distinct_vars(e.right)
    if isinstance(e, Smul): return distinct_vars(e.expr)
    return set()

def sharing_cost(e):
    return len(distinct_vars(e))

def effective_support(e):
    return {v: coeff_of(e, v) for v in distinct_vars(e) if coeff_of(e, v) != 0}

def canon_sharing_cost(e):
    return len(effective_support(e))

def tree_size(e):
    if isinstance(e, (Var, Zero)): return 1
    if isinstance(e, Add): return 1 + tree_size(e.left) + tree_size(e.right)
    if isinstance(e, Smul): return 1 + tree_size(e.expr)
    return 1

def ac_rewrites(e):
    results = []
    if isinstance(e, Add):
        results.append(Add(e.right, e.left))
        if isinstance(e.left, Add):
            results.append(Add(e.left.left, Add(e.left.right, e.right)))
        if isinstance(e.right, Add):
            results.append(Add(Add(e.left, e.right.left), e.right.right))
        if isinstance(e.left, Zero): results.append(e.right)
        if isinstance(e.right, Zero): results.append(e.left)
        if (isinstance(e.left, Smul) and isinstance(e.right, Smul)
                and e.left.expr == e.right.expr):
            c = e.left.coeff + e.right.coeff
            results.append(Zero() if c == 0 else Smul(c, e.left.expr))
    if isinstance(e, Smul):
        if isinstance(e.expr, Add):
            results.append(Add(Smul(e.coeff, e.expr.left), Smul(e.coeff, e.expr.right)))
        if e.coeff == 0:
            results.append(Zero())
    return results

def extract_min_sharing(e, fuel=50):
    visited = {e}
    frontier = [e]
    best = e
    best_sc = sharing_cost(e)
    best_ts = tree_size(e)
    for _ in range(fuel):
        if not frontier: break
        nf = []
        for expr in frontier:
            for rw in ac_rewrites(expr):
                if rw not in visited:
                    visited.add(rw)
                    nf.append(rw)
                    sc = sharing_cost(rw)
                    ts = tree_size(rw)
                    if sc < best_sc or (sc == best_sc and ts < best_ts):
                        best = rw
                        best_sc = sc
                        best_ts = ts
        frontier = nf
    return best, len(visited)

def random_expr(max_vars=5, max_depth=4, depth=0):
    if depth >= max_depth or random.random() < 0.3:
        if random.random() < 0.08: return Zero()
        return Var(random.randint(0, max_vars - 1))
    if random.random() < 0.6:
        return Add(random_expr(max_vars, max_depth, depth+1),
                   random_expr(max_vars, max_depth, depth+1))
    return Smul(random.randint(-3, 3), random_expr(max_vars, max_depth, depth+1))


# ── Generate data ──

random.seed(123)
n_samples = 300

canon_costs = []
extract_costs = []
egraph_sizes = []
original_sizes = []

for _ in range(n_samples):
    e = random_expr(max_vars=5, max_depth=4)
    cc = canon_sharing_cost(e)
    extracted, eg_size = extract_min_sharing(e, fuel=30)
    ec = sharing_cost(extracted)
    canon_costs.append(cc)
    extract_costs.append(ec)
    egraph_sizes.append(eg_size)
    original_sizes.append(tree_size(e))


# ── Plot ──

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Canonical vs Extracted sharing cost
ax1 = axes[0]
jitter = np.random.normal(0, 0.08, n_samples)
ax1.scatter(np.array(canon_costs) + jitter, np.array(extract_costs) + jitter,
            alpha=0.4, s=15, c='steelblue')
ax1.plot([0, 6], [0, 6], 'r--', linewidth=2, label='Perfect agreement')
ax1.set_xlabel('Canonical Sharing Cost', fontsize=12)
ax1.set_ylabel('E-Graph Extracted Sharing Cost', fontsize=12)
ax1.set_title('Canonical Form vs. E-Graph Extraction\n(Theorem: canonical ≤ extracted)',
              fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.set_aspect('equal')

# Count agreement
agree = sum(1 for c, e in zip(canon_costs, extract_costs) if c == e)
ax1.text(0.05, 0.95, f'Agreement: {agree}/{n_samples}\n({100*agree/n_samples:.1f}%)',
         transform=ax1.transAxes, fontsize=11, verticalalignment='top',
         bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

# Panel 2: E-graph size vs expression size
ax2 = axes[1]
ax2.scatter(original_sizes, egraph_sizes, alpha=0.4, s=15, c='darkorange')
ax2.set_xlabel('Original Tree Size', fontsize=12)
ax2.set_ylabel('E-Graph Size (explored nodes)', fontsize=12)
ax2.set_title('E-Graph Exploration Cost\n(canonical form avoids this)',
              fontsize=13, fontweight='bold')

# Panel 3: Cost comparison histogram
ax3 = axes[2]
diffs = np.array(extract_costs) - np.array(canon_costs)
bins = np.arange(min(diffs) - 0.5, max(diffs) + 1.5, 1)
colors = ['seagreen' if d == 0 else 'salmon' for d in sorted(set(diffs))]
ax3.hist(diffs, bins=bins, color='mediumpurple', edgecolor='black', alpha=0.8)
ax3.set_xlabel('Extracted - Canonical Cost', fontsize=12)
ax3.set_ylabel('Frequency', fontsize=12)
ax3.set_title('Cost Difference Distribution\n(Theorem: always ≥ 0)',
              fontsize=13, fontweight='bold')
ax3.axvline(x=0, color='red', linestyle='--', linewidth=2, label='Zero difference')
ax3.legend(fontsize=10)

plt.tight_layout()
plt.savefig('egraph_extraction_comparison.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: egraph_extraction_comparison.png")


#!/usr/bin/env python3
"""
Visualization: Sharing Cost Reduction via Canonical Normalization

This script visualizes how canonical normalization reduces the sharing cost
(number of distinct variables) compared to random equivalent expressions.
It produces a scatter plot showing original vs. canonical sharing cost for
1000 random tensor expressions, demonstrating the optimality theorem.
"""

import random
import matplotlib.pyplot as plt
import numpy as np
from dataclasses import dataclass
from typing import Dict, Set


# ── Self-contained expression AST and algorithms ──

@dataclass(frozen=True)
class TExpr:
    pass

@dataclass(frozen=True)
class Var(TExpr):
    n: int

@dataclass(frozen=True)
class Zero(TExpr):
    pass

@dataclass(frozen=True)
class Add(TExpr):
    left: TExpr
    right: TExpr

@dataclass(frozen=True)
class Smul(TExpr):
    coeff: int
    expr: TExpr


def coeff_of(e, n):
    if isinstance(e, Var): return 1 if e.n == n else 0
    if isinstance(e, Zero): return 0
    if isinstance(e, Add): return coeff_of(e.left, n) + coeff_of(e.right, n)
    if isinstance(e, Smul): return e.coeff * coeff_of(e.expr, n)
    return 0

def distinct_vars(e):
    if isinstance(e, Var): return {e.n}
    if isinstance(e, Zero): return set()
    if isinstance(e, Add): return distinct_vars(e.left) | distinct_vars(e.right)
    if isinstance(e, Smul): return distinct_vars(e.expr)
    return set()

def effective_support(e):
    return {v: coeff_of(e, v) for v in distinct_vars(e) if coeff_of(e, v) != 0}

def sharing_cost(e):
    return len(distinct_vars(e))

def canon_sharing_cost(e):
    return len(effective_support(e))

def tree_size(e):
    if isinstance(e, (Var, Zero)): return 1
    if isinstance(e, Add): return 1 + tree_size(e.left) + tree_size(e.right)
    if isinstance(e, Smul): return 1 + tree_size(e.expr)
    return 1

def random_expr(max_vars=6, max_depth=5, depth=0):
    if depth >= max_depth or random.random() < 0.3:
        if random.random() < 0.08:
            return Zero()
        return Var(random.randint(0, max_vars - 1))
    if random.random() < 0.6:
        return Add(random_expr(max_vars, max_depth, depth+1),
                   random_expr(max_vars, max_depth, depth+1))
    else:
        k = random.randint(-3, 3)
        return Smul(k, random_expr(max_vars, max_depth, depth+1))


# ── Generate data ──

random.seed(42)
n_samples = 1000

orig_costs = []
canon_costs = []
sizes = []

for _ in range(n_samples):
    e = random_expr(max_vars=6, max_depth=5)
    oc = sharing_cost(e)
    cc = canon_sharing_cost(e)
    sz = tree_size(e)
    orig_costs.append(oc)
    canon_costs.append(cc)
    sizes.append(sz)

orig_costs = np.array(orig_costs)
canon_costs = np.array(canon_costs)
sizes = np.array(sizes)

# ── Plot ──

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Original vs Canonical sharing cost
ax1 = axes[0]
jitter = np.random.normal(0, 0.1, n_samples)
ax1.scatter(orig_costs + jitter, canon_costs + jitter*0.5,
            alpha=0.3, s=10, c='steelblue')
ax1.plot([0, 7], [0, 7], 'r--', linewidth=1.5, label='y = x (no improvement)')
ax1.set_xlabel('Original Sharing Cost', fontsize=12)
ax1.set_ylabel('Canonical Sharing Cost', fontsize=12)
ax1.set_title('Sharing Cost: Original vs. Canonical', fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.set_aspect('equal')
ax1.set_xlim(-0.5, 7)
ax1.set_ylim(-0.5, 7)

# Panel 2: Histogram of savings
ax2 = axes[1]
savings = orig_costs - canon_costs
bins = np.arange(-0.5, max(savings) + 1.5, 1)
ax2.hist(savings, bins=bins, color='darkorange', edgecolor='black', alpha=0.8)
ax2.set_xlabel('Sharing Cost Reduction', fontsize=12)
ax2.set_ylabel('Frequency', fontsize=12)
ax2.set_title('Distribution of Cost Savings\n(Theorem 3: always ≥ 0)', fontsize=13, fontweight='bold')
ax2.axvline(x=0, color='red', linestyle='--', linewidth=1.5, label='Zero savings')
ax2.legend(fontsize=10)

# Panel 3: Compression ratio vs tree size
ax3 = axes[2]
ratios = canon_costs / np.maximum(orig_costs, 1)
ax3.scatter(sizes, ratios, alpha=0.3, s=10, c='seagreen')
ax3.set_xlabel('Tree Size (nodes)', fontsize=12)
ax3.set_ylabel('Compression Ratio\n(canonical/original)', fontsize=12)
ax3.set_title('Compression Ratio vs. Expression Size', fontsize=13, fontweight='bold')
ax3.axhline(y=1.0, color='red', linestyle='--', linewidth=1.5, label='Ratio = 1 (no compression)')
ax3.legend(fontsize=10)
ax3.set_ylim(-0.05, 1.5)

plt.tight_layout()
plt.savefig('sharing_cost_analysis.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: sharing_cost_analysis.png")
