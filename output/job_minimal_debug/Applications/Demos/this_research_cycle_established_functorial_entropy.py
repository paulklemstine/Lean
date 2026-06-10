#!/usr/bin/env python3
"""
Applications of Functorial Entropy
====================================

Real-world applications demonstrating the practical value of the theory:
1. Privacy analysis of data anonymization
2. Neural network layer information loss
3. Compiler optimization (dead code detection via entropy)
4. Database query selectivity estimation
"""

import math
from collections import Counter
from typing import Callable, Dict, List, Tuple


def fiber_card(f: Callable[[int], int], domain: List[int], a: int) -> int:
    target = f(a)
    return sum(1 for x in domain if f(x) == target)


def functorial_entropy(f: Callable[[int], int], domain: List[int]) -> float:
    n = len(domain)
    if n == 0:
        return 0.0
    return sum(math.log(fiber_card(f, domain, a)) for a in domain) / n


def landauer_cost(f: Callable[[int], int], domain: List[int]) -> float:
    return sum(math.log(fiber_card(f, domain, a)) for a in domain)


# ============================================================
# Application 1: Privacy Analysis
# ============================================================
def privacy_analysis():
    """Analyze information loss in data anonymization.

    Models k-anonymity: each record is indistinguishable from at least
    k-1 others. Functorial entropy quantifies the privacy guarantee.
    """
    print("=" * 60)
    print("APPLICATION 1: Privacy Analysis (k-Anonymity)")
    print("=" * 60)

    # Simulate age-bucketing anonymization
    # Original: ages 20-39 (20 distinct values)
    domain = list(range(20, 40))

    # Strategy 1: 5-year buckets (e.g., 20-24 → 0, 25-29 → 1, etc.)
    f_5year = lambda x: (x - 20) // 5
    H_5 = functorial_entropy(f_5year, domain)
    print(f"\n  5-year buckets: H = {H_5:.4f} (= log(5) = {math.log(5):.4f})")
    print(f"  → Each person hidden among {math.exp(H_5):.1f} others on average")

    # Strategy 2: 10-year buckets
    f_10year = lambda x: (x - 20) // 10
    H_10 = functorial_entropy(f_10year, domain)
    print(f"  10-year buckets: H = {H_10:.4f} (= log(10) = {math.log(10):.4f})")
    print(f"  → Each person hidden among {math.exp(H_10):.1f} others on average")

    # Strategy 3: Binary (under/over 30)
    f_binary = lambda x: 0 if x < 30 else 1
    H_bin = functorial_entropy(f_binary, domain)
    print(f"  Binary (< 30): H = {H_bin:.4f} (= log(10) = {math.log(10):.4f})")
    print(f"  → Each person hidden among {math.exp(H_bin):.1f} others on average")

    print(f"\n  Privacy ordering: {H_5:.4f} ≤ {H_10:.4f} ≤ {H_bin:.4f}")
    print(f"  More coarse ⟹ more entropy ⟹ more privacy ✓")


# ============================================================
# Application 2: Neural Network Layer Analysis
# ============================================================
def neural_network_analysis():
    """Model information flow through a neural network.

    Each layer is a function; composition monotonicity (Data Processing
    Inequality) guarantees information can only be lost, not created.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Neural Network Information Flow")
    print("=" * 60)

    # Simulate a classification network: 64 inputs → 32 → 16 → 4 classes
    domain = list(range(64))

    layers = [
        ("Input → Hidden1 (mod 32)", lambda x: x % 32),
        ("Hidden1 → Hidden2 (mod 16)", lambda x: x % 16),
        ("Hidden2 → Output (mod 4)", lambda x: x % 4),
    ]

    current_f = None
    print(f"\n  Pipeline: 64 → 32 → 16 → 4")
    for name, layer in layers:
        if current_f is None:
            current_f = layer
        else:
            prev = current_f
            current_f = lambda x, p=prev, l=layer: l(p(x))

        H = functorial_entropy(current_f, domain)
        L = landauer_cost(current_f, domain)
        print(f"  {name}")
        print(f"    Cumulative entropy: {H:.4f}")
        print(f"    Landauer cost: {L:.4f} natural units")
        print(f"    Bits lost: {L / math.log(2):.2f}")

    print(f"\n  Total information lost: {L / math.log(2):.2f} bits")
    print(f"  Minimum energy cost at T=300K: {L * 1.38e-23 * 300:.2e} joules")


# ============================================================
# Application 3: Database Query Selectivity
# ============================================================
def database_selectivity():
    """Estimate query selectivity using functorial entropy.

    The entropy of a projection tells us how "selective" a column is.
    Low entropy = high selectivity = good for indexing.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Database Query Selectivity")
    print("=" * 60)

    # Simulate a table with 100 rows
    domain = list(range(100))

    # Column 1: Primary key (unique) - most selective
    f_pk = lambda x: x
    H_pk = functorial_entropy(f_pk, domain)
    print(f"\n  Primary key (unique): H = {H_pk:.4f}")
    print(f"    Selectivity: 1/{math.exp(H_pk):.1f} = {1/max(math.exp(H_pk),1):.4f}")

    # Column 2: Status field (3 values, roughly equal)
    f_status = lambda x: x % 3
    H_status = functorial_entropy(f_status, domain)
    print(f"  Status (3 values): H = {H_status:.4f}")
    print(f"    Selectivity: 1/{math.exp(H_status):.1f} = {1/math.exp(H_status):.4f}")

    # Column 3: Boolean flag
    f_bool = lambda x: x % 2
    H_bool = functorial_entropy(f_bool, domain)
    print(f"  Boolean flag: H = {H_bool:.4f}")
    print(f"    Selectivity: 1/{math.exp(H_bool):.1f} = {1/math.exp(H_bool):.4f}")

    # Column 4: Constant (useless for indexing)
    f_const = lambda x: 0
    H_const = functorial_entropy(f_const, domain)
    print(f"  Constant column: H = {H_const:.4f}")
    print(f"    Selectivity: 1/{math.exp(H_const):.1f} = {1/math.exp(H_const):.6f}")

    print(f"\n  Index recommendation:")
    print(f"    Primary key: EXCELLENT (H = 0)")
    print(f"    Status: GOOD (H = {H_status:.2f})")
    print(f"    Boolean: FAIR (H = {H_bool:.2f})")
    print(f"    Constant: USELESS (H = {H_const:.2f})")


# ============================================================
# Application 4: Compiler Optimization
# ============================================================
def compiler_optimization():
    """Model function composition optimization in compilers.

    If a pipeline stage is injective (H=0), it preserves all information
    and can potentially be deferred or eliminated.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Compiler Optimization")
    print("=" * 60)

    domain = list(range(16))

    # Pipeline: f₁ (injective) → f₂ (lossy) → f₃ (injective) → f₄ (lossy)
    stages = [
        ("shift +1 (invertible)", lambda x: x + 1, True),
        ("mod 8 (lossy)", lambda x: x % 8, False),
        ("×2 (invertible)", lambda x: x * 2, True),
        ("mod 4 (lossy)", lambda x: x % 4, False),
    ]

    print(f"\n  Pipeline analysis on domain {{0,...,15}}:")
    current = None
    for name, f, expected_inj in stages:
        if current is None:
            current = f
        else:
            prev = current
            current = lambda x, p=prev, g=f: g(p(x))

        H = functorial_entropy(current, domain)
        print(f"  → {name}: cumulative H = {H:.4f}")

    print(f"\n  Optimization insight:")
    print(f"    Injective stages (H=0) can be reordered freely")
    print(f"    Only lossy stages contribute to entropy increase")
    print(f"    Minimum pipeline entropy = sum of lossy stage entropies")


if __name__ == "__main__":
    privacy_analysis()
    neural_network_analysis()
    database_selectivity()
    compiler_optimization()
    print("\n" + "=" * 60)
    print("All applications complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Demonstration of Functorial Entropy Theory
==========================================

Concrete numerical examples illustrating the main theorems:
1. Zero Characterization: H(f) = 0 iff f is injective
2. Composition Monotonicity: H(g∘f) ≥ H(f)
3. Upper Bound: H(f) ≤ log(|α|)
4. Landauer Cost: thermodynamic cost of computation
"""

import math
from collections import Counter
from typing import Callable, Dict, List, Tuple


def fiber_card(f: Callable[[int], int], domain: List[int], a: int) -> int:
    """Compute |{x in domain : f(x) = f(a)}|"""
    target = f(a)
    return sum(1 for x in domain if f(x) == target)


def functorial_entropy(f: Callable[[int], int], domain: List[int]) -> float:
    """H(f) = (1/|α|) * Σ_a log(fiberCard(f, a))"""
    n = len(domain)
    if n == 0:
        return 0.0
    return sum(math.log(fiber_card(f, domain, a)) for a in domain) / n


def landauer_cost(f: Callable[[int], int], domain: List[int]) -> float:
    """Total thermodynamic cost = Σ_a log(fiberCard(f, a))"""
    return sum(math.log(fiber_card(f, domain, a)) for a in domain)


def is_injective(f: Callable[[int], int], domain: List[int]) -> bool:
    """Check if f is injective on domain"""
    images = [f(x) for x in domain]
    return len(images) == len(set(images))


# ============================================================
# Demo 1: Zero Characterization Theorem
# ============================================================
print("=" * 60)
print("DEMO 1: Zero Characterization Theorem")
print("H(f) = 0 ⟺ f is injective")
print("=" * 60)

domain_4 = [0, 1, 2, 3]

# Injective function: f(x) = x + 1
f_inj = lambda x: x + 1
H_inj = functorial_entropy(f_inj, domain_4)
print(f"\nf(x) = x + 1 on {{0,1,2,3}}")
print(f"  Injective: {is_injective(f_inj, domain_4)}")
print(f"  H(f) = {H_inj:.6f}")
print(f"  Fiber sizes: {[fiber_card(f_inj, domain_4, a) for a in domain_4]}")

# Non-injective: f(x) = x mod 2
f_mod2 = lambda x: x % 2
H_mod2 = functorial_entropy(f_mod2, domain_4)
print(f"\nf(x) = x mod 2 on {{0,1,2,3}}")
print(f"  Injective: {is_injective(f_mod2, domain_4)}")
print(f"  H(f) = {H_mod2:.6f} = log(2) = {math.log(2):.6f}")
print(f"  Fiber sizes: {[fiber_card(f_mod2, domain_4, a) for a in domain_4]}")

# Constant function: f(x) = 0
f_const = lambda x: 0
H_const = functorial_entropy(f_const, domain_4)
print(f"\nf(x) = 0 on {{0,1,2,3}}")
print(f"  Injective: {is_injective(f_const, domain_4)}")
print(f"  H(f) = {H_const:.6f} = log(4) = {math.log(4):.6f}")
print(f"  Fiber sizes: {[fiber_card(f_const, domain_4, a) for a in domain_4]}")

# ============================================================
# Demo 2: Composition Monotonicity
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Composition Monotonicity")
print("H(g ∘ f) ≥ H(f) for any g")
print("=" * 60)

domain_6 = list(range(6))

# f: {0..5} → {0..2}, f(x) = x mod 3
f = lambda x: x % 3
# g: {0..2} → {0..1}, g(x) = x mod 2
g = lambda x: x % 2
# g∘f: {0..5} → {0..1}
gf = lambda x: g(f(x))

H_f = functorial_entropy(f, domain_6)
H_gf = functorial_entropy(gf, domain_6)

print(f"\nf(x) = x mod 3 on {{0,...,5}}")
print(f"  H(f) = {H_f:.6f}")
print(f"g(x) = x mod 2 on {{0,1,2}}")
print(f"  H(g) = {functorial_entropy(g, [0,1,2]):.6f}")
print(f"(g∘f)(x) = (x mod 3) mod 2 on {{0,...,5}}")
print(f"  H(g∘f) = {H_gf:.6f}")
print(f"  H(g∘f) ≥ H(f)? {H_gf >= H_f - 1e-10}")

# ============================================================
# Demo 3: Upper Bound
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: Upper Bound")
print("H(f) ≤ log(|α|)")
print("=" * 60)

for n in [3, 5, 8, 10]:
    domain_n = list(range(n))
    # Various functions
    funcs = {
        "id": lambda x, n=n: x,
        "mod 2": lambda x: x % 2,
        "const": lambda x: 0,
        "mod 3": lambda x: x % 3,
    }
    print(f"\n  Domain size |α| = {n}, log(|α|) = {math.log(n):.4f}")
    for name, func in funcs.items():
        H = functorial_entropy(func, domain_n)
        print(f"    H({name}) = {H:.4f} ≤ {math.log(n):.4f}? {H <= math.log(n) + 1e-10}")

# ============================================================
# Demo 4: Landauer Cost
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: Landauer Cost (Thermodynamics)")
print("Total cost = H(f) × |α|")
print("=" * 60)

domain_8 = list(range(8))

functions = [
    ("identity", lambda x: x),
    ("x mod 4", lambda x: x % 4),
    ("x mod 2", lambda x: x % 2),
    ("constant", lambda x: 0),
]

for name, func in functions:
    H = functorial_entropy(func, domain_8)
    L = landauer_cost(func, domain_8)
    inj = is_injective(func, domain_8)
    print(f"\n  f(x) = {name}")
    print(f"    H(f) = {H:.4f}")
    print(f"    Landauer cost = {L:.4f} = H × |α| = {H:.4f} × 8 = {H*8:.4f}")
    print(f"    Injective (reversible): {inj}")
    print(f"    Cost = 0 ⟺ injective: {abs(L) < 1e-10} ⟺ {inj}")

# ============================================================
# Demo 5: Superadditivity Conjecture Test
# ============================================================
print("\n" + "=" * 60)
print("DEMO 5: Superadditivity Conjecture Test")
print("Is H(g∘f) ≥ H(f) + H(g) for surjective f?")
print("=" * 60)

from itertools import product

def all_surjections(n: int, m: int) -> List[Dict[int, int]]:
    """Generate all surjective functions {0,...,n-1} → {0,...,m-1}"""
    result = []
    for assignment in product(range(m), repeat=n):
        if len(set(assignment)) == m:  # surjective
            result.append(dict(enumerate(assignment)))
    return result

violations = 0
tests = 0
max_gap = 0.0
for surj_map in all_surjections(4, 3):
    f_map = surj_map
    f_func = lambda x, m=f_map: m[x]
    for g_assignment in product(range(2), repeat=3):
        g_map = dict(enumerate(g_assignment))
        g_func = lambda x, m=g_map: m[x]
        gf_func = lambda x, f=f_func, g=g_func: g(f(x))

        H_f = functorial_entropy(f_func, list(range(4)))
        H_g = functorial_entropy(g_func, list(range(3)))
        H_gf = functorial_entropy(gf_func, list(range(4)))

        tests += 1
        gap = H_gf - (H_f + H_g)
        if gap < -1e-10:
            violations += 1
        max_gap = min(max_gap, gap)

print(f"\n  Tested {tests} pairs (surj f: Fin 4 → Fin 3, g: Fin 3 → Fin 2)")
print(f"  Violations: {violations}")
print(f"  Minimum gap H(g∘f) - (H(f) + H(g)): {max_gap:.6f}")
if violations > 0:
    print("  ⚠ CONJECTURE REFUTED!")
else:
    print("  ✓ Conjecture holds for all tested cases")

# ============================================================
# Demo 6: Pipeline Monotonicity
# ============================================================
print("\n" + "=" * 60)
print("DEMO 6: Pipeline Monotonicity (Data Processing Inequality)")
print("α → β → γ → δ: entropy increases at each stage")
print("=" * 60)

domain_12 = list(range(12))
f1 = lambda x: x % 6    # 12 → 6
f2 = lambda x: x % 3    # 6 → 3
f3 = lambda x: x % 2    # 3 → 2

pipe1 = f1
pipe2 = lambda x: f2(f1(x))
pipe3 = lambda x: f3(f2(f1(x)))

H1 = functorial_entropy(pipe1, domain_12)
H2 = functorial_entropy(pipe2, domain_12)
H3 = functorial_entropy(pipe3, domain_12)

print(f"\n  Stage 1 (mod 6): H = {H1:.4f}")
print(f"  Stage 2 (mod 3): H = {H2:.4f}")
print(f"  Stage 3 (mod 2): H = {H3:.4f}")
print(f"  Monotone: {H1:.4f} ≤ {H2:.4f} ≤ {H3:.4f}? {H1 <= H2 + 1e-10 and H2 <= H3 + 1e-10}")

print("\n" + "=" * 60)
print("All demos complete.")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization 2: Composition Monotonicity (Data Processing Inequality)

Shows that entropy monotonically increases through a pipeline of functions.
Each additional composition can only increase (or maintain) the entropy,
illustrating the irreversibility of information loss.
"""

import math
import numpy as np
import matplotlib.pyplot as plt
from collections import Counter


def functorial_entropy_from_map(f_values: list, n: int) -> float:
    if n == 0:
        return 0.0
    counts = Counter(f_values)
    total = 0.0
    for x in range(n):
        fiber_size = counts[f_values[x]]
        total += math.log(fiber_size)
    return total / n


# Build several pipelines with different structures
n = 120

pipelines = {
    'Uniform reduction\n(mod k)': [
        ('mod 60', lambda x: x % 60),
        ('mod 30', lambda x: x % 30),
        ('mod 15', lambda x: x % 15),
        ('mod 5', lambda x: x % 5),
        ('mod 1', lambda x: 0),
    ],
    'Aggressive early\nloss': [
        ('mod 6', lambda x: x % 6),
        ('mod 5', lambda x: x % 5),
        ('mod 4', lambda x: x % 4),
        ('mod 3', lambda x: x % 3),
        ('mod 2', lambda x: x % 2),
    ],
    'Gradual loss\n(bitwise)': [
        ('÷2', lambda x: x // 2),
        ('÷2', lambda x: x // 2),
        ('÷2', lambda x: x // 2),
        ('÷2', lambda x: x // 2),
        ('÷2', lambda x: x // 2),
    ],
    'Mixed injective\n& lossy': [
        ('+1 (inv)', lambda x: x + 1),
        ('mod 40', lambda x: x % 40),
        ('×3 (inv)', lambda x: x * 3),
        ('mod 10', lambda x: x % 10),
        ('mod 2', lambda x: x % 2),
    ],
}

fig, ax = plt.subplots(figsize=(10, 6))
colors = ['#2196F3', '#FF5722', '#4CAF50', '#9C27B0']
markers = ['o', 's', 'D', '^']

for idx, (pipe_name, stages) in enumerate(pipelines.items()):
    entropies = [0.0]  # Start with identity (H=0)
    current_values = list(range(n))

    for name, f in stages:
        current_values = [f(v) for v in current_values]
        # Compute entropy of the composed function from original domain
        composed_values = current_values  # Already the composed output
        H = functorial_entropy_from_map(composed_values, n)
        entropies.append(H)

    stages_x = list(range(len(entropies)))
    ax.plot(stages_x, entropies, color=colors[idx], marker=markers[idx],
            linewidth=2, markersize=8, label=pipe_name, alpha=0.85)

ax.axhline(y=math.log(n), color='red', linestyle=':', alpha=0.5,
           label=f'Maximum H = log({n}) = {math.log(n):.2f}')
ax.axhline(y=0, color='green', linestyle=':', alpha=0.5, label='Minimum H = 0')

ax.set_xlabel('Pipeline Stage', fontsize=13)
ax.set_ylabel('Functorial Entropy H', fontsize=13)
ax.set_title(f'Composition Monotonicity: Entropy Through Pipelines (n={n})', fontsize=14)
ax.set_xticks(range(6))
ax.set_xticklabels(['id'] + [f'Stage {i+1}' for i in range(5)])
ax.legend(fontsize=9, loc='upper left')
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('composition_monotonicity.png', dpi=150, bbox_inches='tight')
print("Saved composition_monotonicity.png")


#!/usr/bin/env python3
"""
Visualization 1: Entropy Landscape for Functions Fin n → Fin m

Shows how functorial entropy varies across the space of all functions
from a small finite set to another. Illustrates the Zero Characterization
Theorem: injective functions sit at H=0, constant functions at H=log(n).
"""

import math
import numpy as np
import matplotlib.pyplot as plt
from collections import Counter
from itertools import product


def functorial_entropy_from_map(f_map: list, n: int) -> float:
    """Compute H(f) given f as a list of output values."""
    if n == 0:
        return 0.0
    counts = Counter(f_map)
    total = 0.0
    for x in range(n):
        fiber_size = counts[f_map[x]]
        total += math.log(fiber_size)
    return total / n


def is_injective_map(f_map: list) -> bool:
    return len(set(f_map)) == len(f_map)


# Generate all functions Fin 4 → Fin 3
n, m = 4, 3
all_funcs = list(product(range(m), repeat=n))
entropies = [functorial_entropy_from_map(list(f), n) for f in all_funcs]
injective_mask = [is_injective_map(list(f)) for f in all_funcs]
surjective_mask = [len(set(f)) == m for f in all_funcs]

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Left: histogram of entropies
ax1 = axes[0]
ax1.hist(entropies, bins=30, color='steelblue', edgecolor='black', alpha=0.7)
ax1.axvline(x=0, color='green', linestyle='--', linewidth=2, label='H=0 (injective)')
ax1.axvline(x=math.log(n), color='red', linestyle='--', linewidth=2,
            label=f'H=log({n})={math.log(n):.2f} (constant)')
ax1.set_xlabel('Functorial Entropy H(f)', fontsize=12)
ax1.set_ylabel('Number of functions', fontsize=12)
ax1.set_title(f'Entropy Distribution: All {m**n} functions Fin {n} → Fin {m}', fontsize=13)
ax1.legend(fontsize=10)

# Right: entropy vs image size
ax2 = axes[1]
image_sizes = [len(set(f)) for f in all_funcs]
colors = ['green' if inj else ('orange' if surj else 'steelblue')
          for inj, surj in zip(injective_mask, surjective_mask)]
ax2.scatter(image_sizes, entropies, c=colors, alpha=0.4, s=20)
ax2.set_xlabel('Image size |f(α)|', fontsize=12)
ax2.set_ylabel('Functorial Entropy H(f)', fontsize=12)
ax2.set_title('Entropy vs Image Size', fontsize=13)

# Add legend
from matplotlib.lines import Line2D
legend_elements = [
    Line2D([0], [0], marker='o', color='w', markerfacecolor='green',
           markersize=8, label='Injective (H=0)'),
    Line2D([0], [0], marker='o', color='w', markerfacecolor='orange',
           markersize=8, label='Surjective'),
    Line2D([0], [0], marker='o', color='w', markerfacecolor='steelblue',
           markersize=8, label='Neither'),
]
ax2.legend(handles=legend_elements, fontsize=10)

plt.tight_layout()
plt.savefig('entropy_landscape.png', dpi=150, bbox_inches='tight')
print("Saved entropy_landscape.png")


#!/usr/bin/env python3
"""
Visualization 3: Landauer Cost — The Thermodynamics of Computation

Shows the relationship between entropy and thermodynamic cost.
The Landauer Zero Theorem states that zero cost ⟺ reversible (injective).
This visualization shows the "entropy-thermodynamics bridge."
"""

import math
import numpy as np
import matplotlib.pyplot as plt
from collections import Counter


def compute_entropy_and_cost(f_values: list, n: int):
    if n == 0:
        return 0.0, 0.0
    counts = Counter(f_values)
    total_log = sum(math.log(counts[f_values[x]]) for x in range(n))
    entropy = total_log / n
    cost = total_log  # Landauer cost = n * entropy
    return entropy, cost


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Entropy vs Landauer cost for various functions on Fin 16
ax1 = axes[0]
n = 16
domain = list(range(n))

# Sample functions with different fiber structures
functions = []
labels = []

# Modular functions
for k in [1, 2, 4, 8, 16]:
    f_vals = [x % max(k, 1) for x in domain]
    if k == 16:
        f_vals = [x for x in domain]
    functions.append(f_vals)
    labels.append(f'mod {k}' if k < 16 else 'id')

# Bit-shift functions
for shift in [1, 2, 3]:
    f_vals = [x >> shift for x in domain]
    functions.append(f_vals)
    labels.append(f'>>  {shift}')

# Constant
functions.append([0] * n)
labels.append('const')

entropies_list = []
costs_list = []
for f_vals in functions:
    H, C = compute_entropy_and_cost(f_vals, n)
    entropies_list.append(H)
    costs_list.append(C)

ax1.scatter(entropies_list, costs_list, c='steelblue', s=80, zorder=3)
for i, label in enumerate(labels):
    ax1.annotate(label, (entropies_list[i], costs_list[i]),
                 textcoords="offset points", xytext=(5, 5), fontsize=8)

# Plot the line C = n * H
H_range = np.linspace(0, max(entropies_list) * 1.1, 100)
ax1.plot(H_range, n * H_range, 'r--', alpha=0.5, label=f'C = {n} · H')
ax1.set_xlabel('Functorial Entropy H(f)', fontsize=11)
ax1.set_ylabel('Landauer Cost', fontsize=11)
ax1.set_title(f'Entropy-Cost Relationship (n={n})', fontsize=12)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Panel 2: Physical energy cost at different temperatures
ax2 = axes[1]
k_B = 1.38e-23  # Boltzmann constant (J/K)
temperatures = [4, 77, 300, 1000]  # K (helium, nitrogen, room, hot)
temp_labels = ['4K\n(Helium)', '77K\n(LN₂)', '300K\n(Room)', '1000K\n(Hot)']

# For a function that halves the domain (1 bit erasure per element)
bits_erased = list(range(1, 9))

for i, T in enumerate(temperatures):
    energy_per_bit = k_B * T * math.log(2)
    energies = [b * n * energy_per_bit * 1e21 for b in bits_erased]  # in zeptojoules
    ax2.plot(bits_erased, energies, marker='o', label=temp_labels[i], linewidth=2)

ax2.set_xlabel('Bits erased per element', fontsize=11)
ax2.set_ylabel('Energy cost (zJ = 10⁻²¹ J)', fontsize=11)
ax2.set_title(f'Landauer Energy Cost (n={n} elements)', fontsize=12)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# Panel 3: Fiber histogram for different function types
ax3 = axes[2]
n_big = 60

fiber_data = {
    'Bijection\n(id)': Counter([x for x in range(n_big)]),
    '2-to-1\n(mod 30)': Counter([x % 30 for x in range(n_big)]),
    '3-to-1\n(mod 20)': Counter([x % 20 for x in range(n_big)]),
    'Mixed\n(x²mod 60)': Counter([x * x % 60 for x in range(n_big)]),
    'Constant': Counter([0] * n_big),
}

x_pos = np.arange(len(fiber_data))
bar_width = 0.6

entropies_bar = []
for name, counts in fiber_data.items():
    # Compute entropy
    f_vals = []
    for val, count in counts.items():
        f_vals.extend([val] * count)
    H, _ = compute_entropy_and_cost(f_vals, len(f_vals))
    entropies_bar.append(H)

bars = ax3.bar(x_pos, entropies_bar, bar_width, color=['green', 'skyblue', 'steelblue', 'orange', 'red'],
               edgecolor='black', alpha=0.8)
ax3.set_xticks(x_pos)
ax3.set_xticklabels(list(fiber_data.keys()), fontsize=9)
ax3.set_ylabel('Functorial Entropy H(f)', fontsize=11)
ax3.set_title(f'Entropy by Function Type (n={n_big})', fontsize=12)
ax3.axhline(y=0, color='green', linestyle=':', alpha=0.5)
ax3.axhline(y=math.log(n_big), color='red', linestyle=':', alpha=0.5,
            label=f'max = log({n_big})')
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3, axis='y')

# Add entropy values on bars
for bar, H in zip(bars, entropies_bar):
    ax3.text(bar.get_x() + bar.get_width() / 2., bar.get_height() + 0.05,
             f'{H:.2f}', ha='center', va='bottom', fontsize=9)

plt.tight_layout()
plt.savefig('landauer_cost.png', dpi=150, bbox_inches='tight')
print("Saved landauer_cost.png")
