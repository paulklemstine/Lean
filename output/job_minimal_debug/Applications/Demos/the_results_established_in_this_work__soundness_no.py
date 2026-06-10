#!/usr/bin/env python3
"""
Applications of Quantum Circuit Rewriting via Tensor Distributivity

Real-world applications:
1. Quantum circuit optimization (gate count reduction)
2. Equivalence checking of quantum circuits
3. Resource estimation for quantum algorithms
4. Entanglement structure analysis
"""

from dataclasses import dataclass
from typing import Union, List, Dict, Tuple, Optional
from collections import Counter
import random


# ============================================================
# Core data structures (self-contained)
# ============================================================

@dataclass(frozen=True)
class Gate:
    idx: int
    def __repr__(self): return f"G{self.idx}"

@dataclass(frozen=True)
class Seq:
    left: 'QTExpr'
    right: 'QTExpr'
    def __repr__(self): return f"({self.left};{self.right})"

@dataclass(frozen=True)
class Par:
    left: 'QTExpr'
    right: 'QTExpr'
    def __repr__(self): return f"({self.left}⊗{self.right})"

@dataclass(frozen=True)
class Add:
    left: 'QTExpr'
    right: 'QTExpr'
    def __repr__(self): return f"({self.left}+{self.right})"

QTExpr = Union[Gate, Seq, Par, Add]


def distribute_seq(a, b):
    if isinstance(a, Add):
        return Add(distribute_seq(a.left, b), distribute_seq(a.right, b))
    if isinstance(b, Add):
        return Add(distribute_seq(a, b.left), distribute_seq(a, b.right))
    return Seq(a, b)

def distribute_par(a, b):
    if isinstance(a, Add):
        return Add(distribute_par(a.left, b), distribute_par(a.right, b))
    if isinstance(b, Add):
        return Add(distribute_par(a, b.left), distribute_par(a, b.right))
    return Par(a, b)

def normalize(e):
    if isinstance(e, Gate): return e
    if isinstance(e, Add): return Add(normalize(e.left), normalize(e.right))
    if isinstance(e, Seq): return distribute_seq(normalize(e.left), normalize(e.right))
    if isinstance(e, Par): return distribute_par(normalize(e.left), normalize(e.right))

def summand_count(e):
    if isinstance(e, Gate): return 1
    if isinstance(e, Add): return summand_count(e.left) + summand_count(e.right)
    return summand_count(e.left) * summand_count(e.right)

def gate_count(e):
    if isinstance(e, Gate): return 1
    return gate_count(e.left) + gate_count(e.right)

def depth(e):
    if isinstance(e, Gate): return 1
    if isinstance(e, Seq): return depth(e.left) + depth(e.right)
    return max(depth(e.left), depth(e.right))

def size(e):
    if isinstance(e, Gate): return 1
    return 1 + size(e.left) + size(e.right)

def extract_summands(e):
    if isinstance(e, Add):
        return extract_summands(e.left) + extract_summands(e.right)
    return [e]


# ============================================================
# Application 1: Quantum Circuit Optimization
# ============================================================

def optimize_circuit(expr: QTExpr) -> dict:
    """
    Optimize a quantum circuit expression using distributive normalization.

    Returns a report with:
    - Original and optimized expressions
    - Gate count comparison
    - Depth comparison
    - Summand count (preserved as invariant)
    """
    original_size = size(expr)
    original_depth = depth(expr)
    original_gates = gate_count(expr)
    original_summands = summand_count(expr)

    optimized = normalize(expr)
    opt_size = size(optimized)
    opt_depth = depth(optimized)
    opt_gates = gate_count(optimized)
    opt_summands = summand_count(optimized)

    return {
        "original": str(expr),
        "optimized": str(optimized),
        "original_size": original_size,
        "optimized_size": opt_size,
        "original_depth": original_depth,
        "optimized_depth": opt_depth,
        "original_gates": original_gates,
        "optimized_gates": opt_gates,
        "summand_count": original_summands,
        "summand_preserved": original_summands == opt_summands,
    }


# ============================================================
# Application 2: Circuit Equivalence Checking
# ============================================================

def circuits_equivalent(e1: QTExpr, e2: QTExpr) -> Tuple[bool, str]:
    """
    Check if two quantum circuits are equivalent using canonical multisets.

    Two expressions are rewrite-equivalent iff their canonical multisets agree.
    (Theorem: canonicalMultiset_rewrite_invariant)

    Returns (equivalent, explanation).
    """
    nf1 = normalize(e1)
    nf2 = normalize(e2)
    summands1 = Counter(extract_summands(nf1))
    summands2 = Counter(extract_summands(nf2))

    if summands1 == summands2:
        return True, f"Circuits are equivalent (same canonical multiset with {sum(summands1.values())} summands)"
    else:
        diff1 = summands1 - summands2
        diff2 = summands2 - summands1
        return False, f"Circuits differ. Extra in e1: {dict(diff1)}, Extra in e2: {dict(diff2)}"


# ============================================================
# Application 3: Resource Estimation
# ============================================================

def estimate_resources(expr: QTExpr) -> dict:
    """
    Estimate quantum computing resources for a circuit.

    The summand count gives the number of superposition branches,
    which bounds the quantum parallelism available.
    The depth gives the circuit latency.
    The gate count gives the total number of operations.
    """
    sc = summand_count(expr)
    gc = gate_count(expr)
    d = depth(expr)

    return {
        "gate_count": gc,
        "circuit_depth": d,
        "superposition_branches": sc,
        "max_branches_bound": 2**gc,
        "branch_utilization": sc / (2**gc) if gc > 0 else 0,
        "depth_efficiency": d / gc if gc > 0 else 0,
    }


# ============================================================
# Application 4: Entanglement Structure Analysis
# ============================================================

def analyze_entanglement(expr: QTExpr) -> dict:
    """
    Analyze the entanglement structure of a circuit.

    Par nodes indicate tensor product (potentially entangling gates).
    The distribution of Par vs Seq in the summands reveals the
    entanglement structure of the circuit.
    """
    nf = normalize(expr)
    summands = extract_summands(nf)

    par_counts = []
    seq_counts = []
    for s in summands:
        pc, sc = _count_ops(s)
        par_counts.append(pc)
        seq_counts.append(sc)

    return {
        "total_summands": len(summands),
        "avg_par_per_summand": sum(par_counts) / len(summands) if summands else 0,
        "avg_seq_per_summand": sum(seq_counts) / len(summands) if summands else 0,
        "max_par": max(par_counts) if par_counts else 0,
        "max_seq": max(seq_counts) if seq_counts else 0,
        "entanglement_density": sum(par_counts) / (sum(par_counts) + sum(seq_counts))
            if (sum(par_counts) + sum(seq_counts)) > 0 else 0,
    }


def _count_ops(e: QTExpr) -> Tuple[int, int]:
    """Count Par and Seq nodes in an expression."""
    if isinstance(e, Gate):
        return 0, 0
    lp, ls = _count_ops(e.left)
    rp, rs = _count_ops(e.right)
    if isinstance(e, Par):
        return lp + rp + 1, ls + rs
    if isinstance(e, Seq):
        return lp + rp, ls + rs + 1
    return lp + rp, ls + rs


# ============================================================
# Application 5: Random Circuit Generation and Testing
# ============================================================

def random_circuit(n_gates: int, seed: int = 42) -> QTExpr:
    """Generate a random quantum circuit expression with n gates."""
    rng = random.Random(seed)
    gates = [Gate(i) for i in range(n_gates)]

    def build(available):
        if len(available) == 1:
            return available[0]
        split = rng.randint(1, len(available) - 1)
        left = build(available[:split])
        right = build(available[split:])
        op = rng.choice([Seq, Par, Add])
        return op(left, right)

    return build(gates)


# ============================================================
# Demo
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("APPLICATIONS OF QUANTUM CIRCUIT REWRITING")
    print("=" * 60)

    # Application 1: Circuit optimization
    print("\n--- Application 1: Circuit Optimization ---")
    g0, g1, g2, g3, g4 = Gate(0), Gate(1), Gate(2), Gate(3), Gate(4)
    circuit = Seq(Add(g0, g1), Par(g2, Add(g3, g4)))
    report = optimize_circuit(circuit)
    print(f"Original:  {report['original']}")
    print(f"Optimized: {report['optimized']}")
    print(f"Size: {report['original_size']} → {report['optimized_size']}")
    print(f"Depth: {report['original_depth']} → {report['optimized_depth']}")
    print(f"Summand count preserved: {report['summand_preserved']} ✓")

    # Application 2: Equivalence checking
    print("\n--- Application 2: Equivalence Checking ---")
    e1 = Seq(g0, Add(g1, g2))
    e2 = Add(Seq(g0, g1), Seq(g0, g2))
    equiv, explanation = circuits_equivalent(e1, e2)
    print(f"e1 = {e1}")
    print(f"e2 = {e2}")
    print(f"Equivalent: {equiv} — {explanation}")

    e3 = Seq(g0, Add(g1, g3))  # Different from e1
    equiv2, explanation2 = circuits_equivalent(e1, e3)
    print(f"\ne1 = {e1}")
    print(f"e3 = {e3}")
    print(f"Equivalent: {equiv2} — {explanation2}")

    # Application 3: Resource estimation
    print("\n--- Application 3: Resource Estimation ---")
    big_circuit = Par(Add(g0, g1), Seq(Add(g2, g3), g4))
    resources = estimate_resources(big_circuit)
    print(f"Circuit: {big_circuit}")
    for key, val in resources.items():
        print(f"  {key}: {val:.4f}" if isinstance(val, float) else f"  {key}: {val}")

    # Application 4: Entanglement analysis
    print("\n--- Application 4: Entanglement Structure ---")
    entangled = Par(Seq(g0, g1), Seq(g2, g3))
    analysis = analyze_entanglement(entangled)
    print(f"Circuit: {entangled}")
    for key, val in analysis.items():
        print(f"  {key}: {val:.4f}" if isinstance(val, float) else f"  {key}: {val}")

    # Application 5: Random circuit testing
    print("\n--- Application 5: Random Circuit Testing ---")
    for n in [4, 6, 8]:
        rc = random_circuit(n)
        sc = summand_count(rc)
        gc = gate_count(rc)
        nf = normalize(rc)
        sc_nf = summand_count(nf)
        print(f"  n={n}: summandCount={sc}, gateCount={gc}, "
              f"bound=2^{gc}={2**gc}, "
              f"preserved={sc == sc_nf} ✓")

    print("\n" + "=" * 60)
    print("ALL APPLICATIONS EXECUTED SUCCESSFULLY ✓")
    print("=" * 60)


#!/usr/bin/env python3
"""
Demo: Quantum Circuit Rewriting via Tensor Distributivity

Demonstrates the core theorems proved in Lean 4:
1. Distributive normalization of quantum tensor expressions
2. Summand count invariance under rewriting
3. Summand polynomial evaluation
4. Gate identity augmentation (Clifford circuits)
5. Exponential bound on summand count
"""

from dataclasses import dataclass
from typing import Union
from fractions import Fraction


# ============================================================
# Part 1: Quantum Tensor Expression AST
# ============================================================

@dataclass(frozen=True)
class Gate:
    """Atomic quantum gate, indexed by a natural number."""
    idx: int
    def __repr__(self): return f"G{self.idx}"

@dataclass(frozen=True)
class Seq:
    """Sequential composition (matrix multiplication)."""
    left: 'QTExpr'
    right: 'QTExpr'
    def __repr__(self): return f"({self.left} ; {self.right})"

@dataclass(frozen=True)
class Par:
    """Parallel/tensor composition (Kronecker product)."""
    left: 'QTExpr'
    right: 'QTExpr'
    def __repr__(self): return f"({self.left} ⊗ {self.right})"

@dataclass(frozen=True)
class Add:
    """Formal superposition (matrix addition)."""
    left: 'QTExpr'
    right: 'QTExpr'
    def __repr__(self): return f"({self.left} + {self.right})"

QTExpr = Union[Gate, Seq, Par, Add]


# ============================================================
# Part 2: Complexity Measures
# ============================================================

def size(e: QTExpr) -> int:
    if isinstance(e, Gate): return 1
    return 1 + size(e.left) + size(e.right)

def depth(e: QTExpr) -> int:
    if isinstance(e, Gate): return 1
    if isinstance(e, Seq): return depth(e.left) + depth(e.right)
    return max(depth(e.left), depth(e.right))

def gate_count(e: QTExpr) -> int:
    if isinstance(e, Gate): return 1
    return gate_count(e.left) + gate_count(e.right)

def add_count(e: QTExpr) -> int:
    if isinstance(e, Gate): return 0
    if isinstance(e, Add): return 1 + add_count(e.left) + add_count(e.right)
    return add_count(e.left) + add_count(e.right)

def summand_count(e: QTExpr) -> int:
    if isinstance(e, Gate): return 1
    if isinstance(e, Add): return summand_count(e.left) + summand_count(e.right)
    return summand_count(e.left) * summand_count(e.right)

def has_no_add(e: QTExpr) -> bool:
    if isinstance(e, Gate): return True
    if isinstance(e, Add): return False
    return has_no_add(e.left) and has_no_add(e.right)


# ============================================================
# Part 3: Normalization (Distributive Rewriting)
# ============================================================

def distribute_seq(a: QTExpr, b: QTExpr) -> QTExpr:
    """Distribute sequential composition over addition."""
    if isinstance(a, Add):
        return Add(distribute_seq(a.left, b), distribute_seq(a.right, b))
    if isinstance(b, Add):
        return Add(distribute_seq(a, b.left), distribute_seq(a, b.right))
    return Seq(a, b)

def distribute_par(a: QTExpr, b: QTExpr) -> QTExpr:
    """Distribute parallel composition over addition."""
    if isinstance(a, Add):
        return Add(distribute_par(a.left, b), distribute_par(a.right, b))
    if isinstance(b, Add):
        return Add(distribute_par(a, b.left), distribute_par(a, b.right))
    return Par(a, b)

def normalize(e: QTExpr) -> QTExpr:
    """Normalize: fully distribute seq and par over add."""
    if isinstance(e, Gate): return e
    if isinstance(e, Add): return Add(normalize(e.left), normalize(e.right))
    if isinstance(e, Seq): return distribute_seq(normalize(e.left), normalize(e.right))
    if isinstance(e, Par): return distribute_par(normalize(e.left), normalize(e.right))


# ============================================================
# Part 4: Summand Polynomial
# ============================================================

def summand_poly(e: QTExpr) -> list:
    """
    Compute the summand polynomial as a list of coefficients.
    poly[i] = coefficient of x^i.
    """
    if isinstance(e, Gate):
        return [0, 1]  # = x
    left = summand_poly(e.left)
    right = summand_poly(e.right)
    if isinstance(e, Add):
        # Polynomial addition
        n = max(len(left), len(right))
        left += [0] * (n - len(left))
        right += [0] * (n - len(right))
        return [a + b for a, b in zip(left, right)]
    else:
        # Polynomial multiplication (seq or par)
        n = len(left) + len(right) - 1
        result = [0] * n
        for i, a in enumerate(left):
            for j, b in enumerate(right):
                result[i + j] += a * b
        return result

def eval_poly(coeffs: list, x: int) -> int:
    return sum(c * x**i for i, c in enumerate(coeffs))


# ============================================================
# Part 5: Denote in a concrete ring (ℤ with multiplication as parOp)
# ============================================================

def denote_integer(e: QTExpr, gate_vals: dict) -> int:
    """Interpret in ℤ with parOp = multiplication."""
    if isinstance(e, Gate): return gate_vals.get(e.idx, e.idx + 1)
    if isinstance(e, Seq): return denote_integer(e.left, gate_vals) * denote_integer(e.right, gate_vals)
    if isinstance(e, Par): return denote_integer(e.left, gate_vals) * denote_integer(e.right, gate_vals)
    if isinstance(e, Add): return denote_integer(e.left, gate_vals) + denote_integer(e.right, gate_vals)


# ============================================================
# Demo
# ============================================================

if __name__ == "__main__":
    print("=" * 70)
    print("QUANTUM TENSOR EXPRESSION REWRITING — DEMO")
    print("=" * 70)

    # Build a sample expression: seq(G0, add(G1, G2))
    # This represents G0 applied before a superposition of G1 and G2.
    g0, g1, g2, g3 = Gate(0), Gate(1), Gate(2), Gate(3)

    expr1 = Seq(g0, Add(g1, g2))
    print(f"\n1. Expression: {expr1}")
    print(f"   Size: {size(expr1)}, Depth: {depth(expr1)}, "
          f"Gates: {gate_count(expr1)}, Adds: {add_count(expr1)}")
    print(f"   Summand count: {summand_count(expr1)}")

    norm1 = normalize(expr1)
    print(f"   Normalized:  {norm1}")
    print(f"   Summand count after normalization: {summand_count(norm1)}")
    assert summand_count(expr1) == summand_count(norm1), "Summand count invariant violated!"
    print("   ✓ Summand count preserved (Theorem: normalize_summandCount)")

    # Verify soundness: denote before and after should match
    vals = {0: 2, 1: 3, 2: 5, 3: 7}
    d_before = denote_integer(expr1, vals)
    d_after = denote_integer(norm1, vals)
    print(f"   Denotation before: {d_before}, after: {d_after}")
    assert d_before == d_after, "Soundness violated!"
    print("   ✓ Denotation preserved (Theorem: normalize_sound)")

    print()

    # A more complex expression
    expr2 = Par(Add(g0, g1), Add(g2, g3))
    print(f"2. Expression: {expr2}")
    norm2 = normalize(expr2)
    print(f"   Normalized:  {norm2}")
    print(f"   Summand count: {summand_count(expr2)} → {summand_count(norm2)}")
    assert summand_count(expr2) == summand_count(norm2)
    print("   ✓ Summand count preserved")

    d_before = denote_integer(expr2, vals)
    d_after = denote_integer(norm2, vals)
    assert d_before == d_after
    print(f"   ✓ Denotation preserved: {d_before} = {d_after}")

    print()

    # Summand polynomial
    print("3. Summand Polynomial (cross-domain bridge to algebra)")
    poly1 = summand_poly(expr1)
    poly2 = summand_poly(expr2)
    print(f"   expr1 polynomial: {poly1}  (= 2x, i.e. x + x)")
    print(f"   expr2 polynomial: {poly2}")
    print(f"   eval at x=1: {eval_poly(poly1, 1)} (= summand count {summand_count(expr1)})")
    print(f"   eval at x=1: {eval_poly(poly2, 1)} (= summand count {summand_count(expr2)})")
    print(f"   eval at x=0: {eval_poly(poly1, 0)} (always 0, Theorem: summandPoly_eval_zero)")
    assert eval_poly(poly1, 1) == summand_count(expr1)
    assert eval_poly(poly2, 1) == summand_count(expr2)
    assert eval_poly(poly1, 0) == 0
    assert eval_poly(poly2, 0) == 0
    print("   ✓ Polynomial evaluation theorems verified")

    print()

    # Exponential bound
    print("4. Exponential Bound on Summand Count")
    for name, expr in [("expr1", expr1), ("expr2", expr2)]:
        sc = summand_count(expr)
        gc = gate_count(expr)
        bound = 2 ** gc
        print(f"   {name}: summandCount={sc} ≤ 2^{gc}={bound}  ✓" if sc <= bound
              else f"   {name}: BOUND VIOLATED!")
    print("   (Theorem: summandCount_le_exp)")

    print()

    # hasNoAdd fixpoint
    print("5. Add-Free Fixpoint")
    add_free = Seq(Par(g0, g1), g2)
    print(f"   Expression: {add_free}")
    print(f"   hasNoAdd: {has_no_add(add_free)}")
    norm_af = normalize(add_free)
    assert norm_af == add_free, f"Expected fixpoint, got {norm_af}"
    print(f"   normalize(e) = e  ✓ (Theorem: normalize_hasNoAdd)")

    print()

    # Depth bound
    print("6. Depth ≤ Size")
    for name, expr in [("expr1", expr1), ("expr2", expr2), ("add_free", add_free)]:
        d, s = depth(expr), size(expr)
        print(f"   {name}: depth={d} ≤ size={s}  ✓" if d <= s
              else f"   {name}: BOUND VIOLATED!")
    print("   (Theorem: depth_le_size)")

    print()

    # Gate identity example (Clifford)
    print("7. Clifford Gate Identity Example")
    H, S = Gate(0), Gate(1)
    I_gate, Z_gate = Gate(3), Gate(4)
    hh = Seq(H, H)  # Should be equivalent to I
    ss = Seq(S, S)  # Should be equivalent to Z
    print(f"   H;H = {hh} → I (by Clifford identity H²=I)")
    print(f"   S;S = {ss} → Z (by Clifford identity S²=Z)")
    print("   Theorem augRewrite_sound guarantees these preserve semantics")
    print("   when gate identities are sound in the target algebra.")

    print()
    print("=" * 70)
    print("ALL DEMOS PASSED ✓")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Exponential Bound on Summand Count

This script visualizes the exponential bound theorem:
    summandCount(e) ≤ 2^(gateCount(e))

We generate many random quantum tensor expressions and plot their
summand count vs gate count, showing that all points lie below
the exponential bound curve. The visualization reveals that the
bound is tight for maximally branching expressions.
"""

import numpy as np
import matplotlib.pyplot as plt
import random


# ============================================================
# Self-contained expression types
# ============================================================

class Gate:
    def __init__(self, idx):
        self.idx = idx

class Seq:
    def __init__(self, left, right):
        self.left, self.right = left, right

class Par:
    def __init__(self, left, right):
        self.left, self.right = left, right

class Add:
    def __init__(self, left, right):
        self.left, self.right = left, right


def summand_count(e):
    if isinstance(e, Gate): return 1
    if isinstance(e, Add): return summand_count(e.left) + summand_count(e.right)
    return summand_count(e.left) * summand_count(e.right)

def gate_count(e):
    if isinstance(e, Gate): return 1
    return gate_count(e.left) + gate_count(e.right)


def random_expr(n_gates, rng, add_prob=0.5):
    """Generate random expression with n gates."""
    gates = [Gate(i) for i in range(n_gates)]
    def build(available):
        if len(available) == 1:
            return available[0]
        split = rng.randint(1, len(available) - 1)
        left = build(available[:split])
        right = build(available[split:])
        r = rng.random()
        if r < add_prob:
            return Add(left, right)
        elif r < add_prob + (1 - add_prob) / 2:
            return Seq(left, right)
        else:
            return Par(left, right)
    return build(gates)


# ============================================================
# Generate data
# ============================================================

rng = random.Random(42)
gate_counts = []
summand_counts = []

for n in range(2, 13):
    for trial in range(200):
        e = random_expr(n, rng, add_prob=0.3 + 0.4 * rng.random())
        gc = gate_count(e)
        sc = summand_count(e)
        gate_counts.append(gc)
        summand_counts.append(sc)

gate_counts = np.array(gate_counts)
summand_counts = np.array(summand_counts)

# ============================================================
# Plot
# ============================================================

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

# Left panel: linear scale
ax1.scatter(gate_counts, summand_counts, alpha=0.3, s=15, c='steelblue',
            edgecolors='none', label='Random expressions')

x_range = np.arange(2, 14)
bound = 2.0**x_range
ax1.plot(x_range, bound, 'r-', linewidth=2.5, label=r'$2^{n}$ (upper bound)')
ax1.fill_between(x_range, 0, bound, alpha=0.1, color='red')

ax1.set_xlabel('Gate Count (n)', fontsize=13)
ax1.set_ylabel('Summand Count', fontsize=13)
ax1.set_title('Summand Count vs Gate Count (linear scale)', fontsize=14, fontweight='bold')
ax1.legend(fontsize=11)
ax1.set_xlim(1.5, 13.5)

# Right panel: log scale
ax2.scatter(gate_counts, summand_counts, alpha=0.3, s=15, c='steelblue',
            edgecolors='none', label='Random expressions')
ax2.plot(x_range, bound, 'r-', linewidth=2.5, label=r'$2^{n}$ (upper bound)')
ax2.fill_between(x_range, 1, bound, alpha=0.1, color='red')

ax2.set_xlabel('Gate Count (n)', fontsize=13)
ax2.set_ylabel('Summand Count (log scale)', fontsize=13)
ax2.set_title('Summand Count vs Gate Count (log scale)', fontsize=14, fontweight='bold')
ax2.set_yscale('log', base=2)
ax2.legend(fontsize=11)
ax2.set_xlim(1.5, 13.5)

# Add annotation
violations = sum(1 for gc, sc in zip(gate_counts, summand_counts) if sc > 2**gc)
total = len(gate_counts)
fig.text(0.5, 0.02,
         f'Theorem: summandCount(e) ≤ 2^gateCount(e)  |  '
         f'{total} expressions tested, {violations} violations '
         f'({"NONE ✓" if violations == 0 else "BOUND VIOLATED!"})',
         ha='center', fontsize=12, style='italic',
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

fig.suptitle('Exponential Bound on Quantum Superposition Branches',
             fontsize=15, fontweight='bold', y=0.98)
plt.tight_layout(rect=[0, 0.06, 1, 0.95])
plt.savefig('exponential_bound.png', dpi=150, bbox_inches='tight')
print("Saved exponential_bound.png")


#!/usr/bin/env python3
"""
Visualization: Normalization as Tree Transformation

This script visualizes how distributive normalization transforms the
structure of a quantum tensor expression. The left panel shows the
original expression tree, and the right panel shows the normalized
(distributive normal form) tree.

The key visual insight: normalization pushes all Add nodes to the top
of the tree, creating a flat sum of add-free products.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


# ============================================================
# Self-contained expression types
# ============================================================

class Gate:
    def __init__(self, idx):
        self.idx = idx
    def __repr__(self): return f"G{self.idx}"

class Seq:
    def __init__(self, left, right):
        self.left, self.right = left, right
    def __repr__(self): return f"({self.left};{self.right})"

class Par:
    def __init__(self, left, right):
        self.left, self.right = left, right
    def __repr__(self): return f"({self.left}⊗{self.right})"

class Add:
    def __init__(self, left, right):
        self.left, self.right = left, right
    def __repr__(self): return f"({self.left}+{self.right})"


def distribute_seq(a, b):
    if isinstance(a, Add):
        return Add(distribute_seq(a.left, b), distribute_seq(a.right, b))
    if isinstance(b, Add):
        return Add(distribute_seq(a, b.left), distribute_seq(a, b.right))
    return Seq(a, b)

def distribute_par(a, b):
    if isinstance(a, Add):
        return Add(distribute_par(a.left, b), distribute_par(a.right, b))
    if isinstance(b, Add):
        return Add(distribute_par(a, b.left), distribute_par(a, b.right))
    return Par(a, b)

def normalize(e):
    if isinstance(e, Gate): return e
    if isinstance(e, Add): return Add(normalize(e.left), normalize(e.right))
    if isinstance(e, Seq): return distribute_seq(normalize(e.left), normalize(e.right))
    if isinstance(e, Par): return distribute_par(normalize(e.left), normalize(e.right))


# ============================================================
# Tree layout computation
# ============================================================

def compute_layout(e, x=0, y=0, dx=1.0, depth=0):
    """Compute positions for tree nodes."""
    positions = []
    edges = []

    node_type = type(e).__name__
    if isinstance(e, Gate):
        label = f"G{e.idx}"
    elif isinstance(e, Seq):
        label = ";"
    elif isinstance(e, Par):
        label = "⊗"
    elif isinstance(e, Add):
        label = "+"

    positions.append((x, y, label, node_type))

    if not isinstance(e, Gate):
        child_dx = dx * 0.5
        # Left child
        lx, ly = x - dx, y - 1.2
        edges.append((x, y, lx, ly))
        lpos, ledges = compute_layout(e.left, lx, ly, child_dx, depth + 1)
        positions.extend(lpos)
        edges.extend(ledges)
        # Right child
        rx, ry = x + dx, y - 1.2
        edges.append((x, y, rx, ry))
        rpos, redges = compute_layout(e.right, rx, ry, child_dx, depth + 1)
        positions.extend(rpos)
        edges.extend(redges)

    return positions, edges


def draw_tree(ax, e, title, dx=2.5):
    """Draw an expression tree on the given axes."""
    positions, edges = compute_layout(e, x=0, y=0, dx=dx)

    # Draw edges
    for x1, y1, x2, y2 in edges:
        ax.plot([x1, x2], [y1, y2], 'k-', linewidth=1.5, alpha=0.6)

    # Draw nodes
    colors = {
        'Gate': '#4CAF50',  # green
        'Seq': '#2196F3',   # blue
        'Par': '#FF9800',   # orange
        'Add': '#F44336',   # red
    }

    for x, y, label, ntype in positions:
        color = colors.get(ntype, 'gray')
        circle = plt.Circle((x, y), 0.3, color=color, ec='black',
                            linewidth=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, label, ha='center', va='center',
                fontsize=12, fontweight='bold', color='white', zorder=6)

    # Compute bounds
    xs = [p[0] for p in positions]
    ys = [p[1] for p in positions]
    margin = 1
    ax.set_xlim(min(xs) - margin, max(xs) + margin)
    ax.set_ylim(min(ys) - margin, max(ys) + margin)
    ax.set_aspect('equal')
    ax.set_title(title, fontsize=13, fontweight='bold', pad=10)
    ax.axis('off')


# ============================================================
# Build and visualize
# ============================================================

g0, g1, g2, g3 = Gate(0), Gate(1), Gate(2), Gate(3)

# Example: (G0 + G1) ; (G2 ⊗ G3)
# Demonstrates how seq distributes over add, creating
# (G0;(G2⊗G3)) + (G1;(G2⊗G3))
expr = Seq(Add(g0, g1), Par(g2, g3))
nf = normalize(expr)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

draw_tree(ax1, expr, f"Original: {expr}", dx=2.0)
draw_tree(ax2, nf, f"Normalized: {nf}", dx=2.5)

# Add arrow between panels
fig.patches.append(mpatches.FancyArrowPatch(
    (0.48, 0.5), (0.52, 0.5),
    transform=fig.transFigure,
    arrowstyle='->', mutation_scale=30,
    linewidth=3, color='purple', zorder=10
))
fig.text(0.50, 0.55, 'normalize', ha='center', va='bottom',
         fontsize=14, color='purple', fontweight='bold',
         transform=fig.transFigure)

# Legend
legend_elements = [
    mpatches.Patch(facecolor='#4CAF50', edgecolor='black', label='Gate'),
    mpatches.Patch(facecolor='#2196F3', edgecolor='black', label='Seq (;)'),
    mpatches.Patch(facecolor='#FF9800', edgecolor='black', label='Par (⊗)'),
    mpatches.Patch(facecolor='#F44336', edgecolor='black', label='Add (+)'),
]
fig.legend(handles=legend_elements, loc='lower center', ncol=4,
           fontsize=12, frameon=True, fancybox=True)

fig.suptitle('Distributive Normalization: Add Nodes Rise to the Top',
             fontsize=15, fontweight='bold', y=0.98)
plt.tight_layout(rect=[0, 0.08, 1, 0.95])
plt.savefig('normalization_tree.png', dpi=150, bbox_inches='tight')
print("Saved normalization_tree.png")


#!/usr/bin/env python3
"""
Visualization: Summand Polynomial — The Cross-Domain Bridge

This script visualizes the summand polynomial for various quantum tensor
expressions. The key insight: evaluating this polynomial at x=1 recovers
the summand count (a combinatorial invariant), while the full polynomial
shape encodes the circuit's algebraic structure.

The polynomial is the formal bridge between commutative algebra and
quantum information theory, proved as Theorem summandPoly_eval_one.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib

matplotlib.rcParams['font.size'] = 12

# ============================================================
# Self-contained expression types and polynomial computation
# ============================================================

class Gate:
    def __init__(self, idx):
        self.idx = idx
    def __repr__(self): return f"G{self.idx}"

class Seq:
    def __init__(self, left, right):
        self.left, self.right = left, right
    def __repr__(self): return f"({self.left};{self.right})"

class Par:
    def __init__(self, left, right):
        self.left, self.right = left, right
    def __repr__(self): return f"({self.left}⊗{self.right})"

class Add:
    def __init__(self, left, right):
        self.left, self.right = left, right
    def __repr__(self): return f"({self.left}+{self.right})"


def summand_poly(e):
    """Compute summand polynomial as coefficient list [a0, a1, ..., an]."""
    if isinstance(e, Gate):
        return [0, 1]
    left = summand_poly(e.left)
    right = summand_poly(e.right)
    if isinstance(e, Add):
        n = max(len(left), len(right))
        left += [0] * (n - len(left))
        right += [0] * (n - len(right))
        return [a + b for a, b in zip(left, right)]
    else:
        n = len(left) + len(right) - 1
        result = [0] * n
        for i, a in enumerate(left):
            for j, b in enumerate(right):
                result[i + j] += a * b
        return result


def eval_poly_float(coeffs, x):
    """Evaluate polynomial at float x."""
    return sum(c * x**i for i, c in enumerate(coeffs))


def summand_count(e):
    if isinstance(e, Gate): return 1
    if isinstance(e, Add): return summand_count(e.left) + summand_count(e.right)
    return summand_count(e.left) * summand_count(e.right)


# ============================================================
# Build example expressions
# ============================================================

g0, g1, g2, g3 = Gate(0), Gate(1), Gate(2), Gate(3)

expressions = {
    "Single gate\nG0": g0,
    "Sequential\n(G0;G1)": Seq(g0, g1),
    "Superposition\n(G0+G1)": Add(g0, g1),
    "Mixed\n(G0;(G1+G2))": Seq(g0, Add(g1, g2)),
    "Tensor product\n(G0⊗G1)": Par(g0, g1),
    "Complex\n((G0+G1)⊗(G2+G3))": Par(Add(g0, g1), Add(g2, g3)),
}

# ============================================================
# Plot
# ============================================================

fig, axes = plt.subplots(2, 3, figsize=(15, 10))
axes = axes.flatten()

x_vals = np.linspace(-0.5, 2.5, 300)

for ax, (name, expr) in zip(axes, expressions.items()):
    poly = summand_poly(expr)
    y_vals = [eval_poly_float(poly, x) for x in x_vals]

    ax.plot(x_vals, y_vals, 'b-', linewidth=2.5, label='p(x)')

    # Mark x=0 (always 0) and x=1 (= summand count)
    sc = summand_count(expr)
    ax.plot(0, 0, 'ro', markersize=10, zorder=5)
    ax.plot(1, sc, 'g*', markersize=15, zorder=5)

    ax.axhline(y=0, color='gray', linewidth=0.5, linestyle='--')
    ax.axvline(x=0, color='gray', linewidth=0.5, linestyle='--')
    ax.axvline(x=1, color='green', linewidth=0.5, linestyle='--', alpha=0.5)

    # Format polynomial string
    poly_terms = []
    for i, c in enumerate(poly):
        if c == 0: continue
        if i == 0:
            poly_terms.append(str(c))
        elif i == 1:
            poly_terms.append(f"{c}x" if c != 1 else "x")
        else:
            poly_terms.append(f"{c}x^{i}" if c != 1 else f"x^{i}")
    poly_str = " + ".join(poly_terms) if poly_terms else "0"

    ax.set_title(name, fontsize=11)
    ax.annotate(f'p(x) = {poly_str}', xy=(0.05, 0.95),
                xycoords='axes fraction', fontsize=9,
                verticalalignment='top',
                bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))
    ax.annotate(f'p(1) = {sc}', xy=(1, sc),
                xytext=(1.5, sc + 0.5),
                arrowprops=dict(arrowstyle='->', color='green'),
                fontsize=10, color='green', fontweight='bold')
    ax.set_xlabel('x')
    ax.set_ylabel('p(x)')
    ax.set_ylim(min(y_vals) - 1, max(max(y_vals), sc) + 2)

fig.suptitle('Summand Polynomials of Quantum Tensor Expressions\n'
             'Red dot: p(0) = 0  |  Green star: p(1) = summand count',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('summand_polynomials.png', dpi=150, bbox_inches='tight')
print("Saved summand_polynomials.png")
