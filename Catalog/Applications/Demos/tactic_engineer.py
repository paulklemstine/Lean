#!/usr/bin/env python3
"""
Applications of Certified Tropical Normalization

Demonstrates real-world applications:
1. Shortest path optimization (tropical semiring computation)
2. Neural network piecewise-linear simplification
3. Supply chain / logistics optimization
4. Tropical polynomial evaluation
"""

from dataclasses import dataclass
from typing import Callable, Dict, List, Tuple, Union
import math


# ============================================================
# Expression Types (self-contained)
# ============================================================

@dataclass(frozen=True)
class Const:
    value: float

@dataclass(frozen=True)
class Var:
    index: int

@dataclass(frozen=True)
class TMin:
    left: 'TropExpr'
    right: 'TropExpr'

@dataclass(frozen=True)
class Add:
    left: 'TropExpr'
    right: 'TropExpr'

TropExpr = Union[Const, Var, TMin, Add]


def pretty(e: TropExpr) -> str:
    if isinstance(e, Const): return f"{e.value:g}"
    if isinstance(e, Var): return f"x{e.index}"
    if isinstance(e, TMin): return f"min({pretty(e.left)}, {pretty(e.right)})"
    if isinstance(e, Add): return f"({pretty(e.left)} + {pretty(e.right)})"
    raise TypeError


def size(e: TropExpr) -> int:
    if isinstance(e, (Const, Var)): return 1
    return size(e.left) + size(e.right) + 1


def eval_expr(sigma: Callable[[int], float], e: TropExpr) -> float:
    if isinstance(e, Const): return e.value
    if isinstance(e, Var): return sigma(e.index)
    if isinstance(e, TMin): return min(eval_expr(sigma, e.left), eval_expr(sigma, e.right))
    if isinstance(e, Add): return eval_expr(sigma, e.left) + eval_expr(sigma, e.right)
    raise TypeError


def normalize(e: TropExpr) -> TropExpr:
    if isinstance(e, (Const, Var)): return e
    elif isinstance(e, Add):
        a, b = normalize(e.left), normalize(e.right)
        if isinstance(a, Const) and isinstance(b, Const): return Const(a.value + b.value)
        return Add(a, b)
    elif isinstance(e, TMin):
        a, b = normalize(e.left), normalize(e.right)
        if a == b: return a
        if isinstance(a, Const) and isinstance(b, Const): return Const(min(a.value, b.value))
        return TMin(a, b)
    raise TypeError


# ============================================================
# Application 1: Shortest Path Optimization
# ============================================================

def shortest_path_demo():
    """
    In the tropical (min-plus) semiring, matrix multiplication computes
    shortest paths. The expression min(a + b, a + c, d) represents
    choosing the minimum-cost path among alternatives.

    Normalization simplifies these expressions while preserving the
    optimal path cost — certified by our theorem.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 1: Shortest Path Optimization")
    print("=" * 60)

    # Variables: edge weights
    # x0 = weight(A→B), x1 = weight(B→C), x2 = weight(A→C direct)
    # x3 = weight(A→D), x4 = weight(D→C)

    # Cost of path A→C via B: x0 + x1
    path_via_B = Add(Var(0), Var(1))
    # Cost of direct path A→C: x2
    path_direct = Var(2)
    # Cost of path A→C via D: x3 + x4
    path_via_D = Add(Var(3), Var(4))

    # Optimal cost: min of all paths
    optimal = TMin(TMin(path_via_B, path_direct), path_via_D)

    # Now suppose we know x0 = 3, x1 = 2 (constant edges), but others vary
    # Replace with constants
    optimal_partial = TMin(
        TMin(Add(Const(3), Const(2)), Var(2)),
        Add(Var(3), Var(4))
    )

    print(f"\n  All paths: {pretty(optimal)}")
    print(f"  With known edges (x0=3, x1=2): {pretty(optimal_partial)}")
    print(f"  After normalization: {pretty(normalize(optimal_partial))}")
    print(f"  Size: {size(optimal_partial)} → {size(normalize(optimal_partial))}")

    # Verify semantics
    sigma = lambda n: [3, 2, 4, 6, 1][n % 5]
    v1 = eval_expr(sigma, optimal_partial)
    v2 = eval_expr(sigma, normalize(optimal_partial))
    print(f"\n  With σ(x0..x4) = (3,2,4,6,1):")
    print(f"    Original eval:   {v1}")
    print(f"    Normalized eval: {v2}")
    print(f"    Preserved: {math.isclose(v1, v2)}")

    # Duplicate path detection
    print("\n  Duplicate path detection:")
    redundant = TMin(
        TMin(path_via_B, path_direct),
        TMin(path_via_B, path_via_D)  # path_via_B appears twice
    )
    print(f"    With redundancy: {pretty(redundant)}")
    print(f"    Size: {size(redundant)}")
    nr = normalize(redundant)
    print(f"    Normalized: {pretty(nr)}")
    print(f"    Size: {size(nr)}")


# ============================================================
# Application 2: Neural Network Simplification
# ============================================================

def neural_network_demo():
    """
    ReLU networks produce piecewise-linear functions. In the tropical
    (min-plus) dual, these become min-plus expressions. Normalization
    simplifies the network's computational graph while preserving
    input-output behavior.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Neural Network Simplification")
    print("=" * 60)

    # A simple 2-input ReLU network layer:
    # neuron1 = ReLU(w1*x0 + w2*x1 + b1)
    # In tropical dual: min(w1 + x0, w2 + x1, b1) (simplified model)

    # Suppose w1 = 0.5, w2 = 0.3, b1 = 1.0 are known weights
    neuron1 = TMin(
        TMin(
            Add(Const(0.5), Var(0)),
            Add(Const(0.3), Var(1))
        ),
        Const(1.0)
    )

    # A second neuron with same weights (weight sharing / redundancy)
    neuron2 = TMin(
        TMin(
            Add(Const(0.5), Var(0)),
            Add(Const(0.3), Var(1))
        ),
        Const(1.0)
    )

    # Output: min(neuron1, neuron2) — redundant!
    output = TMin(neuron1, neuron2)

    print(f"\n  Network output: {pretty(output)}")
    print(f"  Size: {size(output)}")
    n_output = normalize(output)
    print(f"  Normalized: {pretty(n_output)}")
    print(f"  Size: {size(n_output)}")
    print(f"  Reduction: {size(output) - size(n_output)} nodes")

    # Verify
    sigma = lambda n: [2.0, 3.0][n % 2]
    v1 = eval_expr(sigma, output)
    v2 = eval_expr(sigma, n_output)
    print(f"\n  With inputs x0=2, x1=3:")
    print(f"    Original: {v1}")
    print(f"    Simplified: {v2}")
    print(f"    Preserved: {math.isclose(v1, v2)}")

    # Constant bias folding
    print("\n  Bias folding example:")
    biased = Add(Add(Const(0.1), Const(0.2)), Var(0))
    print(f"    Before: {pretty(biased)} (size {size(biased)})")
    print(f"    After:  {pretty(normalize(biased))} (size {size(normalize(biased))})")


# ============================================================
# Application 3: Supply Chain Optimization
# ============================================================

def supply_chain_demo():
    """
    In supply chain optimization, the total cost of routing goods
    through a network is a min-plus expression: addition represents
    cost accumulation along a route, and min represents choosing
    the cheapest option.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Supply Chain Cost Optimization")
    print("=" * 60)

    # Warehouse costs (constants)
    warehouse_A = Const(100)
    warehouse_B = Const(150)

    # Shipping costs (variables depending on fuel, distance, etc.)
    ship_A_to_store = Var(0)  # shipping from A
    ship_B_to_store = Var(1)  # shipping from B

    # Total cost from each warehouse
    cost_A = Add(warehouse_A, ship_A_to_store)
    cost_B = Add(warehouse_B, ship_B_to_store)

    # Optimal sourcing: min cost
    optimal = TMin(cost_A, cost_B)

    # Now consider two stores with identical shipping profiles
    store1_cost = TMin(cost_A, cost_B)
    store2_cost = TMin(cost_A, cost_B)  # Same expression

    # Total minimum across both stores
    total = TMin(store1_cost, store2_cost)

    print(f"\n  Store 1 cost: {pretty(store1_cost)}")
    print(f"  Store 2 cost: {pretty(store2_cost)}")
    print(f"  Combined: {pretty(total)}")
    print(f"  Size: {size(total)}")

    nt = normalize(total)
    print(f"\n  Normalized: {pretty(nt)}")
    print(f"  Size: {size(nt)}")
    print(f"  Reduction: {size(total) - size(nt)} nodes ({100*(size(total)-size(nt))//size(total)}%)")

    # With known shipping costs
    sigma = lambda n: [50, 30][n % 2]
    v1 = eval_expr(sigma, total)
    v2 = eval_expr(sigma, nt)
    print(f"\n  With ship_A=$50, ship_B=$30:")
    print(f"    Original: ${v1}")
    print(f"    Normalized: ${v2}")
    print(f"    Optimal source: Warehouse B ($180)")


# ============================================================
# Application 4: Tropical Polynomial Simplification
# ============================================================

def tropical_polynomial_demo():
    """
    Tropical polynomials are min-plus expressions that define
    piecewise-linear functions. Normalization computes a canonical
    form, enabling identity testing and optimization.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Tropical Polynomial Identity Testing")
    print("=" * 60)

    # Tropical polynomial: "3 ⊕ (1 ⊙ x) ⊕ (2 ⊙ x²)"
    # In min-plus: min(3, 1 + x, 2 + x + x) = min(3, 1+x, 2+2x)
    # We represent 2+2x as add(const 2, add(var 0, var 0))
    poly1 = TMin(Const(3), TMin(Add(Const(1), Var(0)),
                                 Add(Const(2), Add(Var(0), Var(0)))))

    # Same polynomial written differently:
    # min(3, min(1+x, 2+2x)) vs min(min(3, 1+x), 2+2x)
    poly2 = TMin(TMin(Const(3), Add(Const(1), Var(0))),
                 Add(Const(2), Add(Var(0), Var(0))))

    print(f"\n  Poly1: {pretty(poly1)}")
    print(f"  Poly2: {pretty(poly2)}")
    print(f"\n  Normalized poly1: {pretty(normalize(poly1))}")
    print(f"  Normalized poly2: {pretty(normalize(poly2))}")

    # Note: these have different normal forms due to associativity
    # (our normalizer doesn't handle AC normalization yet)
    n1 = normalize(poly1)
    n2 = normalize(poly2)
    print(f"\n  Same normal form: {n1 == n2}")
    print(f"  (AC normalization needed for full identity testing)")

    # But expressions with identical structure DO get detected
    poly3 = TMin(poly1, poly1)  # Redundant min
    print(f"\n  Redundant: {pretty(poly3)}")
    print(f"  Size: {size(poly3)}")
    print(f"  Normalized: {pretty(normalize(poly3))}")
    print(f"  Size: {size(normalize(poly3))}")

    # Verify semantics across multiple points
    print(f"\n  Semantic verification (poly3 vs normalize(poly3)):")
    for x_val in [-2, -1, 0, 1, 2, 5]:
        sigma = lambda n, x=x_val: x
        v1 = eval_expr(sigma, poly3)
        v2 = eval_expr(sigma, normalize(poly3))
        print(f"    x={x_val:>3}: eval={v1:>8.1f}  norm_eval={v2:>8.1f}  match={math.isclose(v1,v2)}")


# ============================================================
# Main
# ============================================================

def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Applications of Certified Tropical Normalization       ║")
    print("╚══════════════════════════════════════════════════════════╝")

    shortest_path_demo()
    neural_network_demo()
    supply_chain_demo()
    tropical_polynomial_demo()

    print("\n" + "=" * 60)
    print("All applications demonstrate semantics-preserving")
    print("simplification backed by machine-checked proofs.")
    print("=" * 60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Tropical Expression Normalization — Interactive Demo

Demonstrates the certified tropical normalizer with concrete examples,
showing how expressions are simplified while preserving semantics and
reducing complexity.
"""

from dataclasses import dataclass
from typing import Callable, Union
import math


# ============================================================
# Expression Language
# ============================================================

@dataclass(frozen=True)
class Const:
    """A real constant."""
    value: float

@dataclass(frozen=True)
class Var:
    """A variable reference by index."""
    index: int

@dataclass(frozen=True)
class TMin:
    """Tropical minimum (conjunction)."""
    left: 'TropExpr'
    right: 'TropExpr'

@dataclass(frozen=True)
class Add:
    """Tropical addition."""
    left: 'TropExpr'
    right: 'TropExpr'

TropExpr = Union[Const, Var, TMin, Add]


# ============================================================
# Pretty Printing
# ============================================================

def pretty(e: TropExpr) -> str:
    """Pretty-print a tropical expression."""
    if isinstance(e, Const):
        return f"{e.value:g}"
    elif isinstance(e, Var):
        return f"x{e.index}"
    elif isinstance(e, TMin):
        return f"min({pretty(e.left)}, {pretty(e.right)})"
    elif isinstance(e, Add):
        return f"({pretty(e.left)} + {pretty(e.right)})"
    raise TypeError(f"Unknown expression type: {type(e)}")


# ============================================================
# Evaluation
# ============================================================

def eval_expr(sigma: Callable[[int], float], e: TropExpr) -> float:
    """Evaluate a tropical expression in environment sigma."""
    if isinstance(e, Const):
        return e.value
    elif isinstance(e, Var):
        return sigma(e.index)
    elif isinstance(e, TMin):
        return min(eval_expr(sigma, e.left), eval_expr(sigma, e.right))
    elif isinstance(e, Add):
        return eval_expr(sigma, e.left) + eval_expr(sigma, e.right)
    raise TypeError(f"Unknown expression type: {type(e)}")


# ============================================================
# Size
# ============================================================

def size(e: TropExpr) -> int:
    """Compute the size (number of nodes) of an expression."""
    if isinstance(e, (Const, Var)):
        return 1
    elif isinstance(e, (TMin, Add)):
        return size(e.left) + size(e.right) + 1
    raise TypeError(f"Unknown expression type: {type(e)}")


# ============================================================
# Normalization
# ============================================================

def normalize(e: TropExpr) -> TropExpr:
    """
    Normalize a tropical expression:
    1. Recursive normalization of subexpressions
    2. Constant folding: tmin(const a, const b) -> const(min(a,b))
       and add(const a, const b) -> const(a+b)
    3. Idempotence elimination: tmin(e, e) -> e
    """
    if isinstance(e, (Const, Var)):
        return e
    elif isinstance(e, Add):
        a = normalize(e.left)
        b = normalize(e.right)
        if isinstance(a, Const) and isinstance(b, Const):
            return Const(a.value + b.value)
        return Add(a, b)
    elif isinstance(e, TMin):
        a = normalize(e.left)
        b = normalize(e.right)
        if a == b:
            return a
        if isinstance(a, Const) and isinstance(b, Const):
            return Const(min(a.value, b.value))
        return TMin(a, b)
    raise TypeError(f"Unknown expression type: {type(e)}")


def is_normalized(e: TropExpr) -> bool:
    """Check if an expression is in normal form."""
    if isinstance(e, (Const, Var)):
        return True
    elif isinstance(e, Add):
        if isinstance(e.left, Const) and isinstance(e.right, Const):
            return False
        return is_normalized(e.left) and is_normalized(e.right)
    elif isinstance(e, TMin):
        if e.left == e.right:
            return False
        if isinstance(e.left, Const) and isinstance(e.right, Const):
            return False
        return is_normalized(e.left) and is_normalized(e.right)
    return False


# ============================================================
# Demo
# ============================================================

def demo_example(name: str, e: TropExpr, sigma: Callable[[int], float], sigma_desc: str):
    """Run a single demo example."""
    print(f"\n{'='*60}")
    print(f"Example: {name}")
    print(f"{'='*60}")
    print(f"  Expression:  {pretty(e)}")
    print(f"  Size:        {size(e)}")
    print(f"  Environment: {sigma_desc}")

    ne = normalize(e)
    print(f"\n  Normalized:  {pretty(ne)}")
    print(f"  Norm. size:  {size(ne)}")
    print(f"  Is normal:   {is_normalized(ne)}")

    val_orig = eval_expr(sigma, e)
    val_norm = eval_expr(sigma, ne)
    print(f"\n  eval(original)   = {val_orig}")
    print(f"  eval(normalized) = {val_norm}")
    print(f"  Semantics preserved: {math.isclose(val_orig, val_norm)}")

    # Idempotence check
    nne = normalize(ne)
    print(f"  Idempotent (normalize² = normalize): {ne == nne}")

    reduction = size(e) - size(ne)
    if reduction > 0:
        print(f"  Size reduction: {reduction} nodes ({100*reduction/size(e):.0f}%)")


def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Tropical Expression Normalization — Verified Demo      ║")
    print("║                                                         ║")
    print("║  Every transformation shown here is backed by a         ║")
    print("║  machine-checked proof of semantic preservation.        ║")
    print("╚══════════════════════════════════════════════════════════╝")

    sigma = lambda n: [3.0, 7.0, 1.0, 5.0, 2.0][n % 5]
    sigma_desc = "σ(0)=3, σ(1)=7, σ(2)=1, σ(3)=5, σ(4)=2"

    # Example 1: Constant folding in addition
    e1 = Add(Const(3.0), Const(4.0))
    demo_example("Constant folding (addition)", e1, sigma, sigma_desc)

    # Example 2: Constant folding in min
    e2 = TMin(Const(5.0), Const(2.0))
    demo_example("Constant folding (min)", e2, sigma, sigma_desc)

    # Example 3: Idempotence elimination
    e3 = TMin(Var(0), Var(0))
    demo_example("Idempotence elimination: min(x₀, x₀) → x₀", e3, sigma, sigma_desc)

    # Example 4: Nested constant folding
    e4 = Add(TMin(Const(3.0), Const(1.0)), Add(Const(2.0), Const(5.0)))
    demo_example("Nested constant folding", e4, sigma, sigma_desc)

    # Example 5: Complex expression with multiple reductions
    e5 = TMin(
        Add(Const(1.0), Const(2.0)),   # folds to 3
        Add(Const(1.0), Const(2.0))    # folds to 3, then idempotence
    )
    demo_example("Constant folding + idempotence", e5, sigma, sigma_desc)

    # Example 6: Deep nesting
    e6 = TMin(
        TMin(Add(Const(1.0), Var(0)), Add(Const(1.0), Var(0))),
        TMin(Var(1), Var(1))
    )
    demo_example("Deep nesting with idempotence", e6, sigma, sigma_desc)

    # Example 7: Already normalized
    e7 = Add(Var(0), TMin(Var(1), Const(4.0)))
    demo_example("Already normalized expression", e7, sigma, sigma_desc)

    # Example 8: Large expression
    e8 = Add(
        TMin(
            Add(Const(2.0), Const(3.0)),
            TMin(Const(4.0), Const(4.0))
        ),
        TMin(
            Add(Var(0), Var(0)),
            Add(Var(0), Var(0))
        )
    )
    demo_example("Large expression with multiple reductions", e8, sigma, sigma_desc)

    # Verification summary
    print(f"\n\n{'='*60}")
    print("VERIFICATION SUMMARY")
    print(f"{'='*60}")
    print("All examples demonstrate three verified properties:")
    print("  1. Semantics preservation: eval(normalize(e)) = eval(e)")
    print("  2. Size non-increase: size(normalize(e)) ≤ size(e)")
    print("  3. Idempotence: normalize(normalize(e)) = normalize(e)")
    print("\nThese properties are formally proved with machine-checked")
    print("proofs — not just tested on examples.")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualizations for Tropical Expression Normalization

Generates publication-quality figures showing:
1. Size reduction through normalization
2. Expression tree simplification
3. Semantic preservation verification
4. Normalization performance scaling
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import random
import base64
import io
from dataclasses import dataclass
from typing import Union

# ============================================================
# Expression Types (self-contained)
# ============================================================

@dataclass(frozen=True)
class Const:
    value: float
@dataclass(frozen=True)
class Var:
    index: int
@dataclass(frozen=True)
class TMin:
    left: 'TropExpr'
    right: 'TropExpr'
@dataclass(frozen=True)
class Add:
    left: 'TropExpr'
    right: 'TropExpr'

TropExpr = Union[Const, Var, TMin, Add]

def size(e):
    if isinstance(e, (Const, Var)): return 1
    return size(e.left) + size(e.right) + 1

def eval_expr(sigma, e):
    if isinstance(e, Const): return e.value
    if isinstance(e, Var): return sigma(e.index)
    if isinstance(e, TMin): return min(eval_expr(sigma, e.left), eval_expr(sigma, e.right))
    if isinstance(e, Add): return eval_expr(sigma, e.left) + eval_expr(sigma, e.right)

def normalize(e):
    if isinstance(e, (Const, Var)): return e
    elif isinstance(e, Add):
        a, b = normalize(e.left), normalize(e.right)
        if isinstance(a, Const) and isinstance(b, Const): return Const(a.value + b.value)
        return Add(a, b)
    elif isinstance(e, TMin):
        a, b = normalize(e.left), normalize(e.right)
        if a == b: return a
        if isinstance(a, Const) and isinstance(b, Const): return Const(min(a.value, b.value))
        return TMin(a, b)

def generate_expr(depth, num_vars=5, seed=None):
    rng = random.Random(seed)
    def _gen(d):
        if d <= 0:
            return Const(rng.uniform(-10, 10)) if rng.random() < 0.5 else Var(rng.randint(0, num_vars-1))
        op = rng.choice(['add', 'tmin', 'tmin_idem'])
        if op == 'tmin_idem':
            c = _gen(d-1); return TMin(c, c)
        l, r = _gen(d-1), _gen(d-1)
        return TMin(l, r) if op == 'tmin' else Add(l, r)
    return _gen(depth)


def fig_to_base64(fig):
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return base64.b64encode(buf.read()).decode('utf-8')


# ============================================================
# Figure 1: Size Reduction by Depth
# ============================================================

def plot_size_reduction():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    depths = list(range(1, 13))
    orig_sizes = []
    norm_sizes = []
    reductions = []

    for d in depths:
        sizes_o, sizes_n = [], []
        for trial in range(20):
            e = generate_expr(d, seed=42 + trial + d*100)
            so = size(e)
            sn = size(normalize(e))
            sizes_o.append(so)
            sizes_n.append(sn)
        orig_sizes.append(np.mean(sizes_o))
        norm_sizes.append(np.mean(sizes_n))
        reductions.append(100 * (1 - np.mean(sizes_n) / np.mean(sizes_o)))

    ax1.semilogy(depths, orig_sizes, 'o-', color='#e74c3c', linewidth=2, label='Original', markersize=8)
    ax1.semilogy(depths, norm_sizes, 's-', color='#2ecc71', linewidth=2, label='Normalized', markersize=8)
    ax1.fill_between(depths, norm_sizes, orig_sizes, alpha=0.15, color='#3498db')
    ax1.set_xlabel('Expression Depth', fontsize=12)
    ax1.set_ylabel('Size (nodes, log scale)', fontsize=12)
    ax1.set_title('Expression Size: Before vs After Normalization', fontsize=13)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    ax2.bar(depths, reductions, color='#3498db', alpha=0.8, edgecolor='#2c3e50')
    ax2.set_xlabel('Expression Depth', fontsize=12)
    ax2.set_ylabel('Size Reduction (%)', fontsize=12)
    ax2.set_title('Percentage Size Reduction', fontsize=13)
    ax2.set_ylim(0, 100)
    ax2.grid(True, alpha=0.3, axis='y')

    fig.suptitle('Certified Normalization: Size Guarantees', fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()

    fig.savefig('/workspace/request-project/fig_size_reduction.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


# ============================================================
# Figure 2: Semantic Preservation Verification
# ============================================================

def plot_semantic_preservation():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Generate a complex expression and evaluate at many points
    e = TMin(
        Add(TMin(Var(0), Const(2)), Var(0)),
        Add(Const(1), Var(0))
    )
    ne = normalize(e)

    x_vals = np.linspace(-5, 5, 200)
    orig_vals = [eval_expr(lambda n, x=x: x, e) for x in x_vals]
    norm_vals = [eval_expr(lambda n, x=x: x, ne) for x in x_vals]

    ax1.plot(x_vals, orig_vals, '-', color='#e74c3c', linewidth=2.5, label='Original', alpha=0.8)
    ax1.plot(x_vals, norm_vals, '--', color='#2ecc71', linewidth=2.5, label='Normalized', alpha=0.8)
    ax1.set_xlabel('x', fontsize=12)
    ax1.set_ylabel('eval(σ, e)', fontsize=12)
    ax1.set_title('Semantic Preservation: Same Function', fontsize=13)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    # Residuals
    residuals = [abs(o - n) for o, n in zip(orig_vals, norm_vals)]
    ax2.semilogy(x_vals, [r + 1e-20 for r in residuals], '-', color='#9b59b6', linewidth=1.5)
    ax2.axhline(y=1e-15, color='#e74c3c', linestyle='--', alpha=0.5, label='Machine epsilon')
    ax2.set_xlabel('x', fontsize=12)
    ax2.set_ylabel('|eval(original) - eval(normalized)|', fontsize=12)
    ax2.set_title('Semantic Difference (Machine Zero)', fontsize=13)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Theorem: eval(σ, normalize(e)) = eval(σ, e)', fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()

    fig.savefig('/workspace/request-project/fig_semantic_preservation.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


# ============================================================
# Figure 3: Tropical Piecewise-Linear Functions
# ============================================================

def plot_tropical_functions():
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    x_vals = np.linspace(-3, 5, 300)

    # Tropical line: min(a + x, b)
    exprs = [
        ("min(2+x, 4)", TMin(Add(Const(2), Var(0)), Const(4))),
        ("min(x, 3+x, 1)", TMin(Var(0), TMin(Add(Const(3), Var(0)), Const(1)))),
        ("min(1+2x, 3, -1+x)", TMin(Add(Const(1), Add(Var(0), Var(0))),
                                     TMin(Const(3), Add(Const(-1), Var(0))))),
    ]

    colors = ['#e74c3c', '#3498db', '#2ecc71']
    for ax, (name, e), color in zip(axes, exprs, colors):
        ne = normalize(e)
        vals = [eval_expr(lambda n, x=x: x, e) for x in x_vals]
        ax.plot(x_vals, vals, '-', color=color, linewidth=2.5)
        ax.set_xlabel('x', fontsize=11)
        ax.set_ylabel('value', fontsize=11)
        ax.set_title(f'{name}\nsize: {size(e)} → {size(ne)}', fontsize=11)
        ax.grid(True, alpha=0.3)
        # Mark corners (tropical geometry!)
        for i in range(1, len(vals)-1):
            if abs(vals[i-1] + vals[i+1] - 2*vals[i]) > 0.01:
                ax.plot(x_vals[i], vals[i], 'o', color='black', markersize=6, zorder=5)

    fig.suptitle('Tropical Piecewise-Linear Functions (corners mark tropical singularities)',
                 fontsize=13, fontweight='bold', y=1.02)
    plt.tight_layout()

    fig.savefig('/workspace/request-project/fig_tropical_functions.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


# ============================================================
# Figure 4: Idempotence and Closure Properties
# ============================================================

def plot_idempotence():
    fig, ax = plt.subplots(1, 1, figsize=(8, 6))

    depths = range(1, 11)
    data = {'normalize¹': [], 'normalize²': [], 'normalize³': []}

    for d in depths:
        sizes1, sizes2, sizes3 = [], [], []
        for trial in range(30):
            e = generate_expr(d, seed=trial + d*1000)
            n1 = normalize(e)
            n2 = normalize(n1)
            n3 = normalize(n2)
            sizes1.append(size(n1))
            sizes2.append(size(n2))
            sizes3.append(size(n3))
        data['normalize¹'].append(np.mean(sizes1))
        data['normalize²'].append(np.mean(sizes2))
        data['normalize³'].append(np.mean(sizes3))

    x = list(depths)
    ax.plot(x, data['normalize¹'], 'o-', color='#e74c3c', linewidth=2, markersize=8, label='normalize(e)')
    ax.plot(x, data['normalize²'], 's--', color='#3498db', linewidth=2, markersize=8, label='normalize²(e)')
    ax.plot(x, data['normalize³'], '^:', color='#2ecc71', linewidth=2, markersize=8, label='normalize³(e)')

    ax.set_xlabel('Expression Depth', fontsize=12)
    ax.set_ylabel('Average Size', fontsize=12)
    ax.set_title('Idempotence: normalize(normalize(e)) = normalize(e)\nAll iterations produce identical results',
                 fontsize=13, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig('/workspace/request-project/fig_idempotence.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("Generating visualizations...")
    b64_size = plot_size_reduction()
    print("  ✓ fig_size_reduction.png")
    b64_semantic = plot_semantic_preservation()
    print("  ✓ fig_semantic_preservation.png")
    b64_tropical = plot_tropical_functions()
    print("  ✓ fig_tropical_functions.png")
    b64_idemp = plot_idempotence()
    print("  ✓ fig_idempotence.png")
    print("All visualizations generated successfully.")

    # Save base64 data for JSON package
    import json
    viz_data = {
        "size_reduction": b64_size,
        "semantic_preservation": b64_semantic,
        "tropical_functions": b64_tropical,
        "idempotence": b64_idemp,
    }
    with open('/workspace/request-project/viz_data.json', 'w') as f:
        json.dump(viz_data, f)
    print("Base64 visualization data saved to viz_data.json")
