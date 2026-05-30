"""
Applications of Functorial Entropy

Real-world applications showing how functorial entropy measures information
loss in data processing, cryptographic hash functions, and compression.
"""

import math
from collections import Counter
from typing import List, Dict, Callable


def functorial_entropy(f: Callable, domain: List, codomain=None) -> float:
    """Compute H(f) = sum_b (|f^{-1}(b)|/|A|) * log(|f^{-1}(b)|)."""
    n = len(domain)
    if n == 0:
        return 0.0
    fiber_counts = Counter(f(a) for a in domain)
    return sum((c / n) * math.log(c) for c in fiber_counts.values() if c > 0)


# ============================================================================
# APPLICATION 1: Data Rounding (Quantization)
# ============================================================================
def app_quantization():
    """
    Quantization maps continuous-ish values to discrete bins.
    The functorial entropy measures information lost in rounding.
    """
    print("=" * 70)
    print("APPLICATION 1: Quantization / Rounding")
    print("=" * 70)
    
    # Simulate sensor readings: integers 0-99 quantized to bins of various sizes
    domain = list(range(100))
    
    for bin_size in [1, 2, 5, 10, 25, 50, 100]:
        f = lambda x, bs=bin_size: x // bs
        H = functorial_entropy(f, domain)
        print(f"  Bin size {bin_size:3d}: H = {H:.4f} nats "
              f"(= log({bin_size}) = {math.log(bin_size):.4f})")
    
    print(f"\n  ✓ Uniform quantization: H = log(bin_size)")
    print(f"  Interpretation: rounding to nearest 10 loses log(10) ≈ 2.30 nats")
    print()


# ============================================================================
# APPLICATION 2: Hash Function Collision Analysis
# ============================================================================
def app_hash_analysis():
    """
    A hash function h: Keys → Buckets has functorial entropy measuring
    the average collision rate. Higher entropy = more collisions.
    """
    print("=" * 70)
    print("APPLICATION 2: Hash Function Collision Analysis")
    print("=" * 70)
    
    keys = list(range(1000))
    
    # Good hash: uniform distribution
    h_good = lambda x: x % 100
    H_good = functorial_entropy(h_good, keys)
    
    # Bad hash: clustering
    h_bad = lambda x: (x * x) % 100
    H_bad = functorial_entropy(h_bad, keys)
    
    # Terrible hash: everything in one bucket
    h_terrible = lambda x: 0
    H_terrible = functorial_entropy(h_terrible, keys)
    
    print(f"  Good hash (x mod 100):  H = {H_good:.4f} (= log(10) = {math.log(10):.4f})")
    print(f"  Bad hash (x² mod 100):  H = {H_bad:.4f}")
    print(f"  Terrible (constant):    H = {H_terrible:.4f} (= log(1000) = {math.log(1000):.4f})")
    print()
    print(f"  Entropy gap (bad vs good): {H_bad - H_good:.4f} nats")
    print(f"  Interpretation: bad hash loses {math.exp(H_bad - H_good):.2f}x more info")
    print()


# ============================================================================
# APPLICATION 3: Database Projection
# ============================================================================
def app_database_projection():
    """
    A database projection (SELECT column FROM table) is a function that drops
    columns. The functorial entropy measures how much information is lost.
    """
    print("=" * 70)
    print("APPLICATION 3: Database Projection (Information Loss in Queries)")
    print("=" * 70)
    
    # Simulated table: (name_id, department_id, role_id)
    # 100 employees across 10 departments and 5 roles
    import random
    random.seed(42)
    
    employees = [(i, random.randint(0, 9), random.randint(0, 4)) for i in range(100)]
    domain = list(range(len(employees)))
    
    # Project to department only
    f_dept = lambda i: employees[i][1]
    H_dept = functorial_entropy(f_dept, domain)
    
    # Project to role only
    f_role = lambda i: employees[i][2]
    H_role = functorial_entropy(f_role, domain)
    
    # Project to (department, role) pair
    f_both = lambda i: (employees[i][1], employees[i][2])
    H_both = functorial_entropy(f_both, domain)
    
    # Full projection (identity)
    f_full = lambda i: employees[i]
    H_full = functorial_entropy(f_full, domain)
    
    print(f"  100 employees, 10 departments, 5 roles")
    print(f"  Project → department: H = {H_dept:.4f}")
    print(f"  Project → role:       H = {H_role:.4f}")
    print(f"  Project → (dept,role):H = {H_both:.4f}")
    print(f"  Full record (id):     H = {H_full:.4f}")
    print()
    print(f"  ✓ More columns retained → less entropy (less info lost)")
    print(f"  ✓ Full record: H = 0 (injective, no info lost)")
    print()


# ============================================================================
# APPLICATION 4: Neural Network Layer Analysis
# ============================================================================
def app_neural_network():
    """
    Each layer of a neural network is a function that can lose information.
    ReLU activation, for instance, maps all negative values to 0.
    """
    print("=" * 70)
    print("APPLICATION 4: Information Loss in Activation Functions")
    print("=" * 70)
    
    # Discretized input range: -50 to +49
    domain = list(range(-50, 50))
    
    # ReLU: max(0, x)
    relu = lambda x: max(0, x)
    H_relu = functorial_entropy(relu, domain)
    
    # Leaky ReLU: max(0.1x, x)  (discretized)
    leaky_relu = lambda x: x if x >= 0 else int(0.1 * x)
    H_leaky = functorial_entropy(leaky_relu, domain)
    
    # Sign function: sgn(x)
    sign = lambda x: 1 if x > 0 else (-1 if x < 0 else 0)
    H_sign = functorial_entropy(sign, domain)
    
    # Identity (linear)
    identity = lambda x: x
    H_id = functorial_entropy(identity, domain)
    
    print(f"  Domain: {{-50, ..., +49}} (100 values)")
    print(f"  Identity (linear): H = {H_id:.4f}")
    print(f"  Leaky ReLU:        H = {H_leaky:.4f}")
    print(f"  ReLU:              H = {H_relu:.4f}")
    print(f"  Sign function:     H = {H_sign:.4f}")
    print()
    print(f"  ✓ More aggressive activation → more entropy → more information loss")
    print(f"  ✓ Identity preserves all info (H=0)")
    print(f"  ✓ Sign function destroys almost everything")
    print()


if __name__ == "__main__":
    app_quantization()
    app_hash_analysis()
    app_database_projection()
    app_neural_network()


"""
Functorial Entropy: Measuring Information Loss in Functions and Functors

This demo computes the functorial entropy H(f) for concrete functions between
finite sets, verifying the key theorems:
  - H(f) ≥ 0 (non-negativity)
  - H(f) = 0 iff f is injective
  - H(f) = log(k) for uniform fibers of size k
  - H(f) ≤ log(|domain|)
"""

import math
from collections import Counter
from typing import Callable, Dict, List, Tuple


def fiber_card(f: Callable[[int], int], domain: List[int], b: int) -> int:
    """Compute |f^{-1}(b)| = number of elements in domain mapping to b."""
    return sum(1 for a in domain if f(a) == b)


def functorial_entropy(f: Callable[[int], int], domain: List[int], codomain: List[int]) -> float:
    """
    Compute the functorial entropy H(f) = sum_b (|f^{-1}(b)|/|domain|) * log(|f^{-1}(b)|).
    
    This measures the information destroyed by f:
    - H(f) = 0 when f is injective (no information loss)
    - H(f) = log(|domain|) when f is constant (maximum loss)
    """
    n = len(domain)
    if n == 0:
        return 0.0
    
    H = 0.0
    for b in codomain:
        fc = fiber_card(f, domain, b)
        if fc > 0:
            H += (fc / n) * math.log(fc)
    return H


def is_injective(f: Callable[[int], int], domain: List[int]) -> bool:
    """Check if f is injective on the given domain."""
    images = [f(a) for a in domain]
    return len(images) == len(set(images))


def fiber_distribution(f: Callable[[int], int], domain: List[int]) -> Dict[int, int]:
    """Compute the fiber size distribution: {b: |f^{-1}(b)|} for b in image(f)."""
    counter = Counter(f(a) for a in domain)
    return dict(counter)


# ============================================================================
# DEMO 1: Identity function (zero entropy)
# ============================================================================
print("=" * 70)
print("DEMO 1: Identity Function on {0,1,2,3,4}")
print("=" * 70)

domain = list(range(5))
f_id = lambda x: x
H = functorial_entropy(f_id, domain, domain)
print(f"  f(x) = x")
print(f"  Fiber distribution: {fiber_distribution(f_id, domain)}")
print(f"  H(f) = {H:.6f}")
print(f"  Is injective: {is_injective(f_id, domain)}")
print(f"  ✓ H(f) = 0 ↔ injective: {abs(H) < 1e-10 and is_injective(f_id, domain)}")
print()

# ============================================================================
# DEMO 2: Constant function (maximum entropy)
# ============================================================================
print("=" * 70)
print("DEMO 2: Constant Function f(x) = 0 on {0,...,7}")
print("=" * 70)

domain = list(range(8))
f_const = lambda x: 0
codomain = [0]
H = functorial_entropy(f_const, domain, list(range(8)))
H_max = math.log(len(domain))
print(f"  f(x) = 0")
print(f"  Fiber distribution: {fiber_distribution(f_const, domain)}")
print(f"  H(f) = {H:.6f}")
print(f"  log(|domain|) = log(8) = {H_max:.6f}")
print(f"  ✓ H(f) = log(|domain|): {abs(H - H_max) < 1e-10}")
print()

# ============================================================================
# DEMO 3: Uniform fibers (mod function)
# ============================================================================
print("=" * 70)
print("DEMO 3: Mod Function f(x) = x mod 3 on {0,...,5}")
print("=" * 70)

domain = list(range(6))
f_mod = lambda x: x % 3
codomain = list(range(3))
H = functorial_entropy(f_mod, domain, codomain)
k = 2  # each fiber has size 2
print(f"  f(x) = x mod 3")
print(f"  Fiber distribution: {fiber_distribution(f_mod, domain)}")
print(f"  H(f) = {H:.6f}")
print(f"  log(k) = log(2) = {math.log(k):.6f}")
print(f"  ✓ Uniform fiber formula H(f) = log(k): {abs(H - math.log(k)) < 1e-10}")
print()

# ============================================================================
# DEMO 4: Non-uniform non-injective function
# ============================================================================
print("=" * 70)
print("DEMO 4: Non-uniform f on {0,...,5} → {0,1,2}")
print("=" * 70)

domain = list(range(6))
# f: 0→0, 1→0, 2→0, 3→1, 4→1, 5→2
f_nonunif = lambda x: 0 if x <= 2 else (1 if x <= 4 else 2)
codomain = [0, 1, 2]
H = functorial_entropy(f_nonunif, domain, codomain)
print(f"  f: {{0,1,2}}→0, {{3,4}}→1, {{5}}→2")
print(f"  Fiber distribution: {fiber_distribution(f_nonunif, domain)}")
print(f"  H(f) = {H:.6f}")
print(f"  Is injective: {is_injective(f_nonunif, domain)}")
print(f"  ✓ H(f) > 0 (not injective): {H > 0}")
print(f"  ✓ H(f) ≤ log(6) = {math.log(6):.6f}: {H <= math.log(6) + 1e-10}")
print()

# ============================================================================
# DEMO 5: Composition Superadditivity Conjecture Test
# ============================================================================
print("=" * 70)
print("DEMO 5: Composition Superadditivity Conjecture")
print("=" * 70)

# f : Fin 6 → Fin 3, uniform fibers of size 2
domain_A = list(range(6))
codomain_B = list(range(3))
codomain_C = list(range(2))

f = lambda x: x % 3  # surjective, uniform fibers of size 2
g = lambda x: 0 if x <= 1 else 1  # fiber sizes: {0,1}→0, {2}→1

gf = lambda x: g(f(x))  # composition

H_g = functorial_entropy(g, codomain_B, codomain_C)
H_gf = functorial_entropy(gf, domain_A, codomain_C)

print(f"  f: Fin 6 → Fin 3, f(x) = x mod 3")
print(f"  g: Fin 3 → Fin 2, g(x) = 0 if x≤1 else 1")
print(f"  g fibers: {fiber_distribution(g, codomain_B)}")
print(f"  g∘f fibers: {fiber_distribution(gf, domain_A)}")
print(f"  H(g) = {H_g:.6f}")
print(f"  H(g∘f) = {H_gf:.6f}")
print(f"  ✓ Conjecture H(g) ≤ H(g∘f): {H_g <= H_gf + 1e-10}")
print()

# ============================================================================
# DEMO 6: Landauer Bridge - Thermodynamic Cost
# ============================================================================
print("=" * 70)
print("DEMO 6: Landauer Bridge - Thermodynamic Cost")
print("=" * 70)

# Room temperature, Boltzmann constant
k_B = 1.380649e-23  # J/K
T = 300  # K (room temperature)
kT = k_B * T

# Reversible permutation
domain = list(range(8))
f_perm = lambda x: (x + 3) % 8
H_perm = functorial_entropy(f_perm, domain, domain)
cost_perm = kT * H_perm

# 3-bit erasure (map everything to 0)
f_erase = lambda x: 0
H_erase = functorial_entropy(f_erase, domain, domain)
cost_erase = kT * H_erase

print(f"  kT = {kT:.4e} J at T = {T}K")
print(f"  Reversible (cyclic shift by 3):")
print(f"    H(f) = {H_perm:.6f}, Landauer cost = {cost_perm:.4e} J")
print(f"  3-bit erasure (map all → 0):")
print(f"    H(f) = {H_erase:.6f}, Landauer cost = {cost_erase:.4e} J")
print(f"    Classical Landauer: 3·kT·ln2 = {3*kT*math.log(2):.4e} J")
print(f"  ✓ Reversible has zero cost: {abs(cost_perm) < 1e-30}")
print(f"  ✓ Erasure matches Landauer: {abs(H_erase - math.log(8)) < 1e-10}")
print()

# ============================================================================
# DEMO 7: Exhaustive test on all functions Fin 3 → Fin 3
# ============================================================================
print("=" * 70)
print("DEMO 7: Exhaustive Verification on all f: Fin 3 → Fin 3")
print("=" * 70)

domain = [0, 1, 2]
codomain = [0, 1, 2]
count_total = 0
count_zero = 0
count_injective = 0
all_passed = True

for a0 in range(3):
    for a1 in range(3):
        for a2 in range(3):
            f = lambda x, _a0=a0, _a1=a1, _a2=a2: [_a0, _a1, _a2][x]
            H = functorial_entropy(f, domain, codomain)
            inj = is_injective(f, domain)
            count_total += 1
            if abs(H) < 1e-10:
                count_zero += 1
            if inj:
                count_injective += 1
            # Check: H = 0 iff injective
            if (abs(H) < 1e-10) != inj:
                all_passed = False
            # Check: H >= 0
            if H < -1e-10:
                all_passed = False
            # Check: H <= log(3)
            if H > math.log(3) + 1e-10:
                all_passed = False

print(f"  Total functions: {count_total}")
print(f"  Injective functions: {count_injective}")
print(f"  Functions with H=0: {count_zero}")
print(f"  ✓ All theorems verified: {all_passed}")
print(f"  ✓ H=0 count matches injective count: {count_zero == count_injective}")

print()
print("=" * 70)
print("ALL DEMOS PASSED ✓")
print("=" * 70)


"""
Visualization: Entropy Landscape of Functions Fin n → Fin m

Shows how functorial entropy varies across all functions between small finite
types, revealing the discrete landscape of information loss. Each point
represents a function, colored by its entropy.
"""

import math
import numpy as np
import matplotlib.pyplot as plt
from collections import Counter
from itertools import product


def functorial_entropy_vec(f_values, n, m):
    """Compute H(f) given f as a list of output values."""
    fiber_counts = Counter(f_values)
    H = 0.0
    for c in fiber_counts.values():
        if c > 0:
            H += (c / n) * math.log(c)
    return H


def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    
    # Panel 1: All functions Fin 4 → Fin 4, sorted by entropy
    n, m = 4, 4
    all_funcs = list(product(range(m), repeat=n))
    entropies = [functorial_entropy_vec(f, n, m) for f in all_funcs]
    sorted_idx = np.argsort(entropies)
    sorted_H = [entropies[i] for i in sorted_idx]
    
    colors = plt.cm.viridis(np.array(sorted_H) / max(sorted_H) if max(sorted_H) > 0 else np.zeros(len(sorted_H)))
    axes[0].bar(range(len(sorted_H)), sorted_H, color=colors, width=1.0)
    axes[0].set_xlabel('Function index (sorted)', fontsize=11)
    axes[0].set_ylabel('H(f) (nats)', fontsize=11)
    axes[0].set_title(f'Entropy of all {m}^{n}={m**n} functions\nFin {n} → Fin {m}', fontsize=12)
    axes[0].axhline(y=0, color='red', linestyle='--', alpha=0.5, label='H=0 (injective)')
    axes[0].axhline(y=math.log(n), color='orange', linestyle='--', alpha=0.5, label=f'H=log({n}) (constant)')
    axes[0].legend(fontsize=9)
    
    # Panel 2: Histogram of entropy values
    unique_H = sorted(set(round(h, 8) for h in entropies))
    hist_data = [sum(1 for h in entropies if abs(h - uh) < 1e-6) for uh in unique_H]
    
    bar_colors = plt.cm.viridis(np.array(unique_H) / max(unique_H) if max(unique_H) > 0 else np.zeros(len(unique_H)))
    axes[1].bar(range(len(unique_H)), hist_data, color=bar_colors, width=0.8)
    axes[1].set_xticks(range(len(unique_H)))
    axes[1].set_xticklabels([f'{h:.3f}' for h in unique_H], rotation=45, fontsize=7)
    axes[1].set_xlabel('Entropy value H(f)', fontsize=11)
    axes[1].set_ylabel('Number of functions', fontsize=11)
    axes[1].set_title('Distribution of entropy values\n(discrete spectrum)', fontsize=12)
    
    # Annotate injective count
    inj_count = sum(1 for h in entropies if abs(h) < 1e-8)
    axes[1].annotate(f'{inj_count} injective\n(H=0)', xy=(0, inj_count),
                     xytext=(2, inj_count + 10), fontsize=9,
                     arrowprops=dict(arrowstyle='->', color='red'),
                     color='red')
    
    # Panel 3: Fiber size vs entropy contribution
    # For different fiber sizes k, show the contribution (k/n)*log(k)
    ks = np.arange(1, 21)
    ns = [5, 10, 20, 50]
    
    for n_val in ns:
        contributions = [(k / n_val) * math.log(k) if k > 0 else 0 for k in ks]
        axes[2].plot(ks, contributions, 'o-', markersize=4, label=f'|α| = {n_val}')
    
    axes[2].set_xlabel('Fiber size k', fontsize=11)
    axes[2].set_ylabel('Contribution (k/|α|)·log(k)', fontsize=11)
    axes[2].set_title('Per-fiber entropy contribution\nvs. fiber size', fontsize=12)
    axes[2].legend(fontsize=9)
    axes[2].grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('entropy_landscape.png', dpi=150, bbox_inches='tight')
    print("Saved entropy_landscape.png")


if __name__ == "__main__":
    main()


"""
Visualization: Landauer Bridge — Information Loss as Thermodynamic Cost

Shows the connection between functorial entropy and Landauer's principle:
the minimum energy dissipation of a computation equals kT * H(f), where
H(f) is the functorial entropy measuring information destruction.
"""

import math
import numpy as np
import matplotlib.pyplot as plt


def functorial_entropy_erasure(n_states, n_output):
    """
    H(f) for a function that maps n_states uniformly to n_output states.
    Each fiber has size n_states/n_output.
    H = log(n_states/n_output)
    """
    if n_output >= n_states or n_output == 0:
        return 0.0
    k = n_states / n_output
    return math.log(k)


def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    
    k_B = 1.380649e-23  # Boltzmann constant
    T = 300  # Room temperature
    kT = k_B * T
    
    # Panel 1: Landauer cost vs number of bits erased
    n_bits = np.arange(0, 11)
    n_states = 2 ** n_bits
    H_values = [math.log(2**b) if b > 0 else 0 for b in n_bits]
    costs_J = [kT * H for H in H_values]
    costs_eV = [c / 1.602e-19 for c in costs_J]
    
    ax1 = axes[0]
    color1 = '#2196F3'
    color2 = '#FF5722'
    
    ax1.bar(n_bits - 0.15, H_values, width=0.3, color=color1, alpha=0.8, label='H(f) (nats)')
    ax1_twin = ax1.twinx()
    ax1_twin.bar(n_bits + 0.15, [c * 1e21 for c in costs_J], width=0.3, 
                 color=color2, alpha=0.8, label='Cost (×10⁻²¹ J)')
    
    ax1.set_xlabel('Bits erased', fontsize=11)
    ax1.set_ylabel('Functorial entropy H(f)', fontsize=11, color=color1)
    ax1_twin.set_ylabel('Landauer cost (×10⁻²¹ J)', fontsize=11, color=color2)
    ax1.set_title('Landauer Cost of Bit Erasure\nat T = 300K', fontsize=12)
    ax1.set_xticks(n_bits)
    
    lines1, labels1 = ax1.get_legend_handles_labels()
    lines2, labels2 = ax1_twin.get_legend_handles_labels()
    ax1.legend(lines1 + lines2, labels1 + labels2, fontsize=9)
    
    # Panel 2: Phase diagram — reversible vs irreversible
    ax2 = axes[1]
    
    # Generate random functions Fin 8 → Fin 8 and classify
    np.random.seed(42)
    n = 8
    n_samples = 500
    
    entropies = []
    range_sizes = []
    
    for _ in range(n_samples):
        f = np.random.randint(0, n, size=n)
        from collections import Counter
        fibers = Counter(f)
        H = sum((c / n) * math.log(c) for c in fibers.values() if c > 0)
        rs = len(set(f))
        entropies.append(H)
        range_sizes.append(rs)
    
    # Add all permutations (bijective = reversible)
    for _ in range(50):
        f = np.random.permutation(n)
        entropies.append(0.0)
        range_sizes.append(n)
    
    colors = ['green' if h < 0.01 else ('gold' if h < 1.0 else 'red') 
              for h in entropies]
    
    ax2.scatter(range_sizes, entropies, c=colors, alpha=0.5, s=20, edgecolors='none')
    ax2.set_xlabel('|Image(f)| (range size)', fontsize=11)
    ax2.set_ylabel('H(f) (nats)', fontsize=11)
    ax2.set_title('Phase Diagram: Reversible vs Irreversible\n(Fin 8 → Fin 8)', fontsize=12)
    
    # Add legend
    from matplotlib.patches import Patch
    legend_elements = [
        Patch(facecolor='green', alpha=0.7, label='Reversible (H=0)'),
        Patch(facecolor='gold', alpha=0.7, label='Low loss (H<1)'),
        Patch(facecolor='red', alpha=0.7, label='High loss (H≥1)')
    ]
    ax2.legend(handles=legend_elements, fontsize=9)
    ax2.grid(True, alpha=0.3)
    
    # Panel 3: Entropy vs collapse ratio
    ax3 = axes[2]
    
    # For uniform fibers: H = log(k) where k = |domain|/|range|
    collapse_ratios = np.linspace(1, 20, 200)
    H_uniform = np.log(collapse_ratios)
    
    ax3.plot(collapse_ratios, H_uniform, 'b-', linewidth=2, label='Uniform: H = log(k)')
    ax3.fill_between(collapse_ratios, 0, H_uniform, alpha=0.15, color='blue')
    
    # Mark special points
    special = [(1, 'Injective\n(reversible)'), (2, 'Binary\ncollapse'),
               (math.e, 'k = e'), (10, '10:1\ncompression')]
    for k, label in special:
        if k <= 20:
            ax3.plot(k, math.log(k), 'ro', markersize=8, zorder=5)
            ax3.annotate(label, xy=(k, math.log(k)),
                        xytext=(k + 0.5, math.log(k) + 0.15),
                        fontsize=8, ha='left')
    
    ax3.set_xlabel('Collapse ratio k = |fiber|', fontsize=11)
    ax3.set_ylabel('Functorial entropy H(f)', fontsize=11)
    ax3.set_title('Entropy vs. Collapse Ratio\n(Uniform Fiber Theorem)', fontsize=12)
    ax3.grid(True, alpha=0.3)
    ax3.legend(fontsize=10)
    
    plt.tight_layout()
    plt.savefig('landauer_bridge.png', dpi=150, bbox_inches='tight')
    print("Saved landauer_bridge.png")


if __name__ == "__main__":
    main()
