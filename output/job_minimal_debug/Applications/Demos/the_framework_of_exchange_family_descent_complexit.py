#!/usr/bin/env python3
"""
Applications of Exchange Family Descent Complexity

Demonstrates real-world applications of the theoretical framework:
1. Simplex method analysis
2. Matroid optimization
3. Local search in combinatorial optimization
"""

import math
from typing import List, Dict, Tuple


class SimplexDescentAnalysis:
    """
    Application 1: Analyzing simplex method complexity through exchange families.

    The simplex method for linear programming can be modeled as descent in an
    exchange family where:
    - States = basic feasible solutions
    - Measure = negative of objective value (mapped to naturals)
    - Dimension = number of variables
    - Pivots = exchange operations
    """

    def __init__(self, num_vars: int, num_constraints: int):
        self.num_vars = num_vars
        self.num_constraints = num_constraints
        self.dim = num_vars

    def theoretical_upper_bound(self, k: int = 1) -> int:
        """Upper bound from depth_k_power_bound: WDL ≤ dim^k."""
        return self.dim ** k

    def klee_minty_bound(self) -> int:
        """Klee-Minty worst case: 2^n - 1 pivots."""
        return 2 ** self.num_vars - 1

    def certificate_analysis(self) -> Dict[str, any]:
        """Analyze certificate depth for the simplex family."""
        km = self.klee_minty_bound()
        results = {
            "dimension": self.dim,
            "klee_minty_bound": km,
        }
        for k in range(1, self.dim + 1):
            bound = self.dim ** k
            if km <= bound:
                results["certificate_depth"] = k
                results["gap"] = bound - km
                results["gap_ratio"] = km / bound
                break
        return results

    def product_amplification(self, copies: int) -> Dict[str, int]:
        """
        Demonstrate product tensorization: n copies of a simplex instance.
        By product_worstCase_additive, WDL grows linearly.
        """
        single_wdl = self.klee_minty_bound()
        return {
            "copies": copies,
            "single_wdl": single_wdl,
            "product_wdl": copies * single_wdl,
            "product_dim": copies * self.dim,
        }


class MatroidExchangeAnalysis:
    """
    Application 2: Matroid basis exchange complexity.

    Matroid basis exchange is a natural exchange family where:
    - States = bases of the matroid
    - Measure = some weight function on bases
    - Exchanges = single-element swaps between bases
    """

    def __init__(self, n: int, rank: int):
        """
        Args:
            n: size of the ground set
            rank: rank of the matroid
        """
        self.n = n
        self.rank = rank
        self.dim = rank

    def num_bases_upper_bound(self) -> int:
        """Upper bound on number of bases: C(n, rank)."""
        return math.comb(self.n, self.rank)

    def entropy_bound(self) -> float:
        """
        By entropy_lower_bound_descent: if measures are injective,
        card(State) ≤ WDL + 1.
        So WDL ≥ card(State) - 1 = C(n,r) - 1.
        """
        return self.num_bases_upper_bound() - 1

    def exchange_distance_bound(self) -> int:
        """
        Maximum exchange distance between any two bases.
        By matroid theory, this is at most rank.
        By descentChain_length_bound, bounded by starting measure.
        """
        return self.rank

    def analyze(self) -> Dict[str, any]:
        return {
            "ground_set_size": self.n,
            "rank": self.rank,
            "max_bases": self.num_bases_upper_bound(),
            "entropy_lower_bound": self.entropy_bound(),
            "exchange_distance_bound": self.exchange_distance_bound(),
            "certificate_depth_1_bound": self.dim,
        }


class LocalSearchAnalysis:
    """
    Application 3: Local search in combinatorial optimization.

    Models local search as an exchange family where:
    - States = feasible solutions
    - Measure = objective value (for minimization, inverted)
    - Neighborhood = local modifications
    """

    def __init__(self, solution_space_size: int, max_objective: int):
        self.N = solution_space_size
        self.max_obj = max_objective

    def descent_bound(self) -> int:
        """
        By strict_descent_length_bound: any descent terminates in ≤ m+1 steps.
        """
        return self.max_obj + 1

    def analyze_convergence(self, improvement_rate: float = 1.0) -> Dict:
        """
        Analyze convergence of local search with guaranteed improvement.

        If each step improves by at least `improvement_rate`:
        - Number of steps ≤ max_objective / improvement_rate
        """
        steps = int(self.max_obj / improvement_rate) if improvement_rate > 0 else float("inf")
        return {
            "solution_space_size": self.N,
            "max_objective": self.max_obj,
            "improvement_rate": improvement_rate,
            "max_steps": steps,
            "descent_bound": self.descent_bound(),
        }


if __name__ == "__main__":
    print("=" * 60)
    print("APPLICATION 1: Simplex Method Analysis")
    print("=" * 60)

    simplex = SimplexDescentAnalysis(num_vars=5, num_constraints=10)
    cert = simplex.certificate_analysis()
    print(f"\n  {cert}")

    amp = simplex.product_amplification(3)
    print(f"  Product amplification: {amp}")

    print("\n" + "=" * 60)
    print("APPLICATION 2: Matroid Basis Exchange")
    print("=" * 60)

    matroid = MatroidExchangeAnalysis(n=10, rank=4)
    analysis = matroid.analyze()
    print(f"\n  {analysis}")

    print("\n" + "=" * 60)
    print("APPLICATION 3: Local Search Convergence")
    print("=" * 60)

    local = LocalSearchAnalysis(solution_space_size=1000, max_objective=50)
    conv = local.analyze_convergence(improvement_rate=2.0)
    print(f"\n  {conv}")

    print("\n" + "=" * 60)
    print("All applications demonstrated successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Demo: Exchange Family Descent Complexity

Demonstrates the key theorems about exchange families with concrete examples,
including product tensorization, descent chains, and complexity classification.
"""

import itertools
from dataclasses import dataclass
from typing import List, Tuple, Callable


@dataclass
class ExchangeFamily:
    """A finite exchange family with states, dimensions, and measures."""
    name: str
    dim: int
    states: List[str]
    measure: dict  # state -> natural number

    @property
    def worst_descent_length(self) -> int:
        return max(self.measure.values()) if self.measure else 0

    def has_certificate_depth(self, k: int) -> bool:
        return all(m <= self.dim ** k for m in self.measure.values())

    def certificate_depth(self) -> int:
        """Find the minimum k such that all measures ≤ dim^k."""
        for k in range(self.dim + 1):
            if self.has_certificate_depth(k):
                return k
        return self.dim

    def branching_factor(self, s: str) -> int:
        m = self.measure[s]
        return sum(1 for t in self.states if self.measure[t] < m)

    def max_branching(self) -> int:
        return max(self.branching_factor(s) for s in self.states)

    def in_polynomial_class(self, p: int) -> bool:
        return self.worst_descent_length <= self.dim ** p

    def amplification_profile(self, k: int) -> int:
        bound = self.dim ** k
        filtered = [m for m in self.measure.values() if m <= bound]
        return max(filtered) if filtered else 0


def product_family(F: ExchangeFamily, G: ExchangeFamily) -> ExchangeFamily:
    """Construct the product of two exchange families."""
    states = [f"({s},{t})" for s in F.states for t in G.states]
    measure = {}
    for s in F.states:
        for t in G.states:
            measure[f"({s},{t})"] = F.measure[s] + G.measure[t]
    return ExchangeFamily(
        name=f"{F.name}⊗{G.name}",
        dim=F.dim + G.dim,
        states=states,
        measure=measure,
    )


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Example 1: Simple 3-state family (matroid-like)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

F1 = ExchangeFamily(
    name="Matroid3",
    dim=3,
    states=["a", "b", "c"],
    measure={"a": 5, "b": 3, "c": 1},
)

F2 = ExchangeFamily(
    name="Simplex4",
    dim=4,
    states=["x", "y", "z", "w"],
    measure={"x": 8, "y": 4, "z": 2, "w": 0},
)


def demo_basic():
    print("=" * 60)
    print("DEMO 1: Basic Exchange Family Properties")
    print("=" * 60)

    for F in [F1, F2]:
        print(f"\nFamily: {F.name}")
        print(f"  Dimension: {F.dim}")
        print(f"  States: {F.states}")
        print(f"  Measures: {F.measure}")
        print(f"  Worst descent length: {F.worst_descent_length}")
        print(f"  Certificate depth: {F.certificate_depth()}")
        print(f"  Max branching: {F.max_branching()}")

        for p in range(1, 4):
            print(f"  In polynomial class {p}: {F.in_polynomial_class(p)}")


def demo_product():
    print("\n" + "=" * 60)
    print("DEMO 2: Product Tensorization (Theorem 1)")
    print("=" * 60)

    P = product_family(F1, F2)
    print(f"\nProduct: {P.name}")
    print(f"  Dimension: {P.dim} = {F1.dim} + {F2.dim}")
    print(f"  States: {len(P.states)}")
    print(f"  WDL: {P.worst_descent_length}")
    print(f"  = WDL({F1.name}) + WDL({F2.name}) = {F1.worst_descent_length} + {F2.worst_descent_length}")
    print(f"  ✓ Product additivity verified: {P.worst_descent_length == F1.worst_descent_length + F2.worst_descent_length}")


def demo_descent_chain():
    print("\n" + "=" * 60)
    print("DEMO 3: Descent Chain Length Bound (Theorem 2)")
    print("=" * 60)

    chain = ["a", "b", "c"]  # 5 > 3 > 1
    measures = [F1.measure[s] for s in chain]
    print(f"\nChain in {F1.name}: {chain}")
    print(f"  Measures: {measures}")
    print(f"  Chain length (steps): {len(chain) - 1}")
    print(f"  Starting measure: {measures[0]}")
    print(f"  ✓ Length ≤ starting measure: {len(chain) - 1} ≤ {measures[0]}: {len(chain) - 1 <= measures[0]}")


def demo_strict_descent():
    print("\n" + "=" * 60)
    print("DEMO 4: Strict Descent Length Bound (Theorem 7)")
    print("=" * 60)

    # A strictly decreasing sequence starting at m has at most m+1 elements
    for m in [3, 5, 10]:
        seq = list(range(m, -1, -1))  # [m, m-1, ..., 0]
        print(f"\n  Starting at m={m}: sequence length = {len(seq)}")
        print(f"  ✓ n ≤ m + 1: {len(seq)} ≤ {m + 1}: {len(seq) <= m + 1}")


def demo_amplification():
    print("\n" + "=" * 60)
    print("DEMO 5: Amplification Profile (Theorem 4)")
    print("=" * 60)

    print(f"\nFamily: {F2.name} (dim={F2.dim})")
    for k in range(4):
        profile = F2.amplification_profile(k)
        print(f"  Profile at depth {k}: {profile} (bound: dim^k = {F2.dim**k})")

    print(f"\n  ✓ Profile is monotone: {all(F2.amplification_profile(k) <= F2.amplification_profile(k+1) for k in range(3))}")


def demo_entropy_bridge():
    print("\n" + "=" * 60)
    print("DEMO 6: Entropy-Complexity Bridge (Theorem 5)")
    print("=" * 60)

    # With injective measures
    F_inj = ExchangeFamily(
        name="Injective5",
        dim=5,
        states=["s0", "s1", "s2", "s3", "s4"],
        measure={"s0": 0, "s1": 1, "s2": 2, "s3": 3, "s4": 4},
    )
    N = len(F_inj.states)
    L = F_inj.worst_descent_length
    print(f"\nFamily: {F_inj.name} (injective measures)")
    print(f"  card(State) = {N}")
    print(f"  WDL = {L}")
    print(f"  ✓ card(State) ≤ WDL + 1: {N} ≤ {L + 1}: {N <= L + 1}")


def demo_iterated_product():
    print("\n" + "=" * 60)
    print("DEMO 7: Iterated Product Dimension (Theorem 9)")
    print("=" * 60)

    F_small = ExchangeFamily(
        name="Small",
        dim=2,
        states=["a", "b"],
        measure={"a": 3, "b": 1},
    )

    F_curr = F_small
    for n in range(1, 5):
        F_curr = product_family(F_small, F_curr) if n > 1 else F_small
        expected_dim = n * F_small.dim if n > 1 else F_small.dim
        print(f"  n={n}: dim = {F_curr.dim}, expected n*dim = {n * F_small.dim}")


def demo_complexity_class():
    print("\n" + "=" * 60)
    print("DEMO 8: Complexity Classification")
    print("=" * 60)

    families = [
        ExchangeFamily("Linear", 5, [f"s{i}" for i in range(5)],
                       {f"s{i}": i for i in range(5)}),
        ExchangeFamily("Quadratic", 4, [f"s{i}" for i in range(10)],
                       {f"s{i}": i**2 for i in range(10)}),
        ExchangeFamily("Exponential", 3, [f"s{i}" for i in range(8)],
                       {f"s{i}": 2**i for i in range(8)}),
    ]

    for F in families:
        print(f"\n  {F.name} (dim={F.dim}, WDL={F.worst_descent_length}):")
        for p in range(1, 6):
            if F.in_polynomial_class(p):
                print(f"    In polynomial class {p}: WDL={F.worst_descent_length} ≤ {F.dim}^{p}={F.dim**p}")
                break


if __name__ == "__main__":
    demo_basic()
    demo_product()
    demo_descent_chain()
    demo_strict_descent()
    demo_amplification()
    demo_entropy_bridge()
    demo_iterated_product()
    demo_complexity_class()
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Descent Complexity Classification

Shows the three complexity regimes (polynomial, exponential, factorial)
and how exchange families fall into different classes based on their
worst-case descent length relative to dimension.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

fig, axes = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle("Descent Complexity Classification", fontsize=16, fontweight='bold')

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Panel 1: Complexity regime boundaries
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ax1 = axes[0]

d = np.linspace(2, 10, 100)

# Three regimes
poly1 = d
poly2 = d ** 2
poly3 = d ** 3
exp2 = 2 ** d
factorial = np.array([np.math.factorial(int(x)) for x in np.floor(d)])

ax1.semilogy(d, poly1, '-', color='#2ecc71', linewidth=2.5, label='Polynomial(1): d')
ax1.semilogy(d, poly2, '-', color='#27ae60', linewidth=2.5, label='Polynomial(2): d²')
ax1.semilogy(d, poly3, '-', color='#1e8449', linewidth=2.5, label='Polynomial(3): d³')
ax1.semilogy(d, exp2, '--', color='#e74c3c', linewidth=2.5, label='Exponential(2): 2^d')
ax1.semilogy(np.floor(d), factorial, ':', color='#8e44ad', linewidth=2.5, label='Factorial: d!')

# Shade regions
ax1.fill_between(d, 1, poly2, alpha=0.05, color='green')
ax1.fill_between(d, poly2, exp2, alpha=0.05, color='orange')
ax1.fill_between(d, exp2, 1e8, alpha=0.05, color='red')

# Example families as points
examples = [
    (3, 3, "Matroid\nbasis", '#2ecc71'),
    (5, 20, "Greedy\nsearch", '#27ae60'),
    (4, 50, "LP\nrelaxation", '#f39c12'),
    (6, 200, "SAT\nlocal", '#e74c3c'),
    (5, 120, "Klee-\nMinty", '#8e44ad'),
]

for dx, wdl, name, color in examples:
    ax1.plot(dx, wdl, 'o', color=color, markersize=12, zorder=5,
             markeredgecolor='black', markeredgewidth=1.5)
    ax1.annotate(name, (dx, wdl), textcoords="offset points",
                 xytext=(12, 0), fontsize=9, ha='left',
                 fontweight='bold')

ax1.set_xlabel('Dimension d', fontsize=12)
ax1.set_ylabel('Worst Descent Length (log)', fontsize=12)
ax1.set_title('Complexity Regime Boundaries', fontsize=13)
ax1.legend(fontsize=9, loc='upper left')
ax1.set_ylim(1, 1e6)
ax1.grid(True, alpha=0.3)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Panel 2: Gap ratio heatmap
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ax2 = axes[1]

dims = np.arange(2, 11)
depths = np.arange(0, 6)

# Compute WDL / d^k ratios for hypothetical families
# Assume WDL ~ 0.5 * d^(d/3) for illustration
gap_ratios = np.zeros((len(depths), len(dims)))
for i, k in enumerate(depths):
    for j, d in enumerate(dims):
        wdl = int(0.5 * d ** (d / 3.0))
        bound = d ** k if k > 0 else 1
        ratio = min(wdl / bound, 1.0) if bound > 0 else 0
        gap_ratios[i, j] = ratio

im = ax2.imshow(gap_ratios, aspect='auto', cmap='RdYlGn_r', vmin=0, vmax=1,
                origin='lower')
ax2.set_xticks(range(len(dims)))
ax2.set_xticklabels(dims)
ax2.set_yticks(range(len(depths)))
ax2.set_yticklabels(depths)
ax2.set_xlabel('Dimension d', fontsize=12)
ax2.set_ylabel('Certificate Depth k', fontsize=12)
ax2.set_title('Gap Ratio: WDL / d^k', fontsize=13)

cbar = fig.colorbar(im, ax=ax2, shrink=0.8)
cbar.set_label('Ratio (closer to 0 = larger gap)', fontsize=10)

# Annotate with values
for i in range(len(depths)):
    for j in range(len(dims)):
        val = gap_ratios[i, j]
        color = 'white' if val > 0.5 else 'black'
        ax2.text(j, i, f'{val:.2f}', ha='center', va='center',
                 fontsize=7, color=color, fontweight='bold')

plt.tight_layout()
plt.savefig("complexity_classes.png", dpi=150, bbox_inches='tight')
print("Saved complexity_classes.png")


#!/usr/bin/env python3
"""
Visualization: Exchange Family Descent Landscape

Visualizes the descent complexity landscape across different exchange families,
showing how worst-case descent length scales with dimension and certificate depth.
This illustrates the core gap phenomenon between theoretical bounds and actual complexity.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle("Exchange Family Descent Complexity Landscape", fontsize=16, fontweight='bold')

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Panel 1: Theoretical upper bounds d^k for various k
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ax1 = axes[0, 0]
dims = np.arange(2, 12)
for k in range(1, 5):
    bounds = dims ** k
    ax1.semilogy(dims, bounds, 'o-', label=f'k={k}: d^{k}', linewidth=2, markersize=5)

ax1.set_xlabel('Dimension d', fontsize=12)
ax1.set_ylabel('Upper Bound (log scale)', fontsize=12)
ax1.set_title('Certificate Depth Bounds: d^k', fontsize=13)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Panel 2: Product tensorization — WDL grows linearly
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ax2 = axes[0, 1]
n_copies = np.arange(1, 11)
base_wdl_values = [3, 5, 8, 12]
colors = plt.cm.viridis(np.linspace(0.2, 0.8, len(base_wdl_values)))

for wdl, color in zip(base_wdl_values, colors):
    product_wdl = n_copies * wdl
    ax2.plot(n_copies, product_wdl, 's-', color=color, label=f'WDL₀={wdl}',
             linewidth=2, markersize=6)

ax2.set_xlabel('Number of Copies n', fontsize=12)
ax2.set_ylabel('Product WDL', fontsize=12)
ax2.set_title('Product Additivity: WDL(F^n) = n · WDL(F)', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Panel 3: Amplification profile — monotone step function
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ax3 = axes[1, 0]

# Simulate amplification profiles for different families
dim = 4
depths = np.arange(0, 6)

# Family 1: measures = [1, 4, 16, 64]
measures_1 = [1, 4, 16, 64]
profile_1 = []
for k in depths:
    bound = dim ** k
    filtered = [m for m in measures_1 if m <= bound]
    profile_1.append(max(filtered) if filtered else 0)

# Family 2: measures = [0, 2, 5, 10]
measures_2 = [0, 2, 5, 10]
profile_2 = []
for k in depths:
    bound = dim ** k
    filtered = [m for m in measures_2 if m <= bound]
    profile_2.append(max(filtered) if filtered else 0)

ax3.step(depths, profile_1, where='post', linewidth=2.5, label='High complexity family',
         color='crimson', marker='D', markersize=6)
ax3.step(depths, profile_2, where='post', linewidth=2.5, label='Low complexity family',
         color='steelblue', marker='o', markersize=6)
ax3.fill_between(depths, 0, profile_1, alpha=0.1, color='crimson', step='post')
ax3.fill_between(depths, 0, profile_2, alpha=0.1, color='steelblue', step='post')

ax3.set_xlabel('Certificate Depth k', fontsize=12)
ax3.set_ylabel('Amplification Profile', fontsize=12)
ax3.set_title('Certificate Amplification Profiles', fontsize=13)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Panel 4: Entropy-complexity bridge
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ax4 = axes[1, 1]

# For injective measures: card(State) ≤ WDL + 1
wdl_range = np.arange(1, 25)
max_states = wdl_range + 1

ax4.fill_between(wdl_range, 0, max_states, alpha=0.2, color='green',
                 label='Feasible region')
ax4.plot(wdl_range, max_states, 'g-', linewidth=2.5, label='Bound: N ≤ WDL + 1')

# Example families
examples = [
    (5, 4, "Matroid"),
    (8, 8, "Simplex"),
    (15, 10, "Max states"),
    (3, 3, "Tight"),
    (20, 20, "Identity"),
]
for wdl, n, name in examples:
    color = 'darkgreen' if n <= wdl + 1 else 'red'
    ax4.plot(wdl, n, 'o', color=color, markersize=10, zorder=5)
    ax4.annotate(name, (wdl, n), textcoords="offset points",
                 xytext=(8, 5), fontsize=9)

ax4.set_xlabel('Worst Descent Length (WDL)', fontsize=12)
ax4.set_ylabel('Number of States N', fontsize=12)
ax4.set_title('Entropy Bridge: N ≤ WDL + 1 (injective)', fontsize=13)
ax4.legend(fontsize=10, loc='upper left')
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("descent_landscape.png", dpi=150, bbox_inches='tight')
print("Saved descent_landscape.png")


#!/usr/bin/env python3
"""
Visualization: Product Tensorization and Complexity Growth

Shows how exchange family complexity grows under iterated products,
demonstrating the additive behavior of worst-case descent length and
the multiplicative growth of state space.
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

fig = plt.figure(figsize=(16, 6))
fig.suptitle("Product Tensorization: Complexity Amplification", fontsize=16, fontweight='bold')

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Panel 1: 3D surface — WDL as function of (dim_F, dim_G)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ax1 = fig.add_subplot(131, projection='3d')

d1 = np.arange(1, 8)
d2 = np.arange(1, 8)
D1, D2 = np.meshgrid(d1, d2)

# WDL of product = WDL(F) + WDL(G)
# Assume WDL(F) ~ d^2 for illustration
WDL_product = D1**2 + D2**2

surf = ax1.plot_surface(D1, D2, WDL_product, cmap='viridis', alpha=0.8, edgecolor='k', linewidth=0.3)
ax1.set_xlabel('dim(F)')
ax1.set_ylabel('dim(G)')
ax1.set_zlabel('WDL(F⊗G)')
ax1.set_title('Product WDL Surface')
fig.colorbar(surf, ax=ax1, shrink=0.5, pad=0.1)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Panel 2: Iterated product dimension and WDL growth
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ax2 = fig.add_subplot(132)

n_range = np.arange(1, 11)
base_dims = [2, 3, 4, 5]
colors = plt.cm.plasma(np.linspace(0.2, 0.8, len(base_dims)))

for d, color in zip(base_dims, colors):
    wdl_base = d ** 2  # Example: WDL ~ d²
    dims = n_range * d
    wdls = n_range * wdl_base

    ax2.plot(n_range, wdls, 'o-', color=color, linewidth=2,
             label=f'd₀={d}, WDL₀={wdl_base}', markersize=5)

ax2.set_xlabel('Number of Copies n', fontsize=12)
ax2.set_ylabel('WDL(F^⊗n)', fontsize=12)
ax2.set_title('Linear Growth: WDL(F^⊗n) = n·WDL(F)', fontsize=13)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Panel 3: State space explosion vs linear WDL
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ax3 = fig.add_subplot(133)

n_range2 = np.arange(1, 9)
base_states = 4  # |State| for base family
base_wdl = 5

state_counts = base_states ** n_range2  # Multiplicative growth
wdl_values = n_range2 * base_wdl  # Additive growth

ax3_twin = ax3.twinx()

line1, = ax3.semilogy(n_range2, state_counts, 'rs-', linewidth=2.5,
                       markersize=8, label='|State^⊗n| (exponential)')
line2, = ax3_twin.plot(n_range2, wdl_values, 'b^-', linewidth=2.5,
                        markersize=8, label='WDL(F^⊗n) (linear)')

ax3.set_xlabel('Number of Copies n', fontsize=12)
ax3.set_ylabel('State Space Size (log)', fontsize=12, color='red')
ax3_twin.set_ylabel('Worst Descent Length', fontsize=12, color='blue')
ax3.set_title('State Explosion vs Linear WDL', fontsize=13)

lines = [line1, line2]
labels = [l.get_label() for l in lines]
ax3.legend(lines, labels, fontsize=9, loc='center left')
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("product_growth.png", dpi=150, bbox_inches='tight')
print("Saved product_growth.png")
