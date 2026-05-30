"""
Applications of Prime-Sensitive Torsion Echoes

Demonstrates real-world applications:
1. Cryptographic key generation analysis via torsion profiles
2. Network topology classification using sensitivity indices
3. Data structure fingerprinting through prime-based hashing
"""

from math import gcd, comb
from typing import List, Dict, Tuple, Set
from collections import Counter
import random


def padic_val(p: int, n: int) -> int:
    """Compute the p-adic valuation v_p(n)."""
    if n == 0 or p < 2:
        return 0
    k = 0
    while n % p == 0:
        n //= p
        k += 1
    return k


def prime_factors(n: int) -> List[int]:
    """Return distinct prime factors of n."""
    factors = []
    d = 2
    temp = abs(n)
    while d * d <= temp:
        if temp % d == 0:
            factors.append(d)
            while temp % d == 0:
                temp //= d
        d += 1
    if temp > 1:
        factors.append(temp)
    return factors


# ============================================================
# Application 1: Cryptographic Modulus Analysis
# ============================================================

def analyze_rsa_modulus(n: int, analysis_primes: List[int] = None) -> Dict:
    """
    Analyze an RSA-like modulus through its torsion echo signature.

    In RSA, n = p * q for large primes. The torsion profile of n
    reveals structural information about the factorization that
    could be relevant for side-channel analysis.

    This is a pedagogical demonstration, not an attack.
    """
    if analysis_primes is None:
        analysis_primes = [2, 3, 5, 7, 11, 13]

    profile = {p: padic_val(p, n) for p in analysis_primes}
    pf = prime_factors(n)
    is_semiprime = len(pf) == 2

    # Sensitivity: how many distinct valuations appear
    distinct_vals = len(set(profile.values()))

    return {
        'modulus': n,
        'profile': profile,
        'prime_factors': pf,
        'is_semiprime': is_semiprime,
        'sensitivity_index': distinct_vals,
        'max_valuation': max(profile.values()),
        'nonzero_primes': [p for p, v in profile.items() if v > 0],
    }


# ============================================================
# Application 2: Graph Topology Classification
# ============================================================

def classify_graph_topology(adjacency: List[List[int]]) -> Dict:
    """
    Classify graph topology using torsion-echo-inspired invariants.

    The idea: compute edge count, triangle count, and higher face counts,
    then analyze their prime structure to create a topological fingerprint.
    """
    n = len(adjacency)
    edge_count = sum(adjacency[i][j] for i in range(n) for j in range(i+1, n))
    
    # Count triangles
    triangle_count = 0
    for i in range(n):
        for j in range(i+1, n):
            if adjacency[i][j]:
                for k in range(j+1, n):
                    if adjacency[i][k] and adjacency[j][k]:
                        triangle_count += 1

    # Euler characteristic (simplified)
    euler_char = n - edge_count + triangle_count

    # Torsion profile of the face vector
    primes = [2, 3, 5, 7]
    edge_profile = {p: padic_val(p, max(edge_count, 1)) for p in primes}
    tri_profile = {p: padic_val(p, max(triangle_count, 1)) for p in primes}

    return {
        'vertices': n,
        'edges': edge_count,
        'triangles': triangle_count,
        'euler_characteristic': euler_char,
        'edge_torsion_profile': edge_profile,
        'triangle_torsion_profile': tri_profile,
        'topology_class': 'tree-like' if triangle_count == 0 else
                         'sparse' if triangle_count < n else
                         'dense'
    }


# ============================================================
# Application 3: Data Fingerprinting via Prime Echoes
# ============================================================

def prime_echo_fingerprint(data: List[int], primes: List[int] = None) -> Dict:
    """
    Create a fingerprint of numerical data using prime echo analysis.

    This uses the distribution of p-adic valuations across the data
    to create a characteristic signature that is invariant under
    certain transformations.
    """
    if primes is None:
        primes = [2, 3, 5, 7, 11]

    # Compute valuation distribution for each prime
    val_distributions = {}
    for p in primes:
        vals = [padic_val(p, abs(x)) for x in data if x != 0]
        counter = Counter(vals)
        total = len(vals) if vals else 1
        val_distributions[p] = {
            'mean': sum(vals) / total if vals else 0,
            'max': max(vals) if vals else 0,
            'distribution': dict(counter),
        }

    # Compute pairwise sensitivity
    sensitivity_pairs = {}
    for i, p in enumerate(primes):
        for q in primes[i+1:]:
            # How often do v_p and v_q agree across the dataset?
            agreements = sum(
                1 for x in data if x != 0 and padic_val(p, abs(x)) == padic_val(q, abs(x))
            )
            total = sum(1 for x in data if x != 0)
            sensitivity_pairs[(p, q)] = agreements / total if total > 0 else 0

    return {
        'data_size': len(data),
        'nonzero_count': sum(1 for x in data if x != 0),
        'valuation_distributions': val_distributions,
        'pairwise_agreement': sensitivity_pairs,
    }


# ============================================================
# Main: Run Applications
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Application 1: Cryptographic Modulus Analysis")
    print("=" * 60)

    # Small RSA-like moduli for demonstration
    test_moduli = [
        15,     # 3 * 5
        35,     # 5 * 7
        77,     # 7 * 11
        143,    # 11 * 13
        221,    # 13 * 17
        323,    # 17 * 19
        1073,   # 29 * 37
        2021,   # 43 * 47
    ]

    for n in test_moduli:
        result = analyze_rsa_modulus(n)
        print(f"\n  n = {n} = {'×'.join(map(str, result['prime_factors']))}")
        print(f"    Profile: {result['profile']}")
        print(f"    Sensitivity Index: {result['sensitivity_index']}")
        print(f"    Is semiprime: {result['is_semiprime']}")

    print("\n" + "=" * 60)
    print("Application 2: Graph Topology Classification")
    print("=" * 60)

    # Example graphs
    graphs = {
        'path_4': [
            [0,1,0,0],
            [1,0,1,0],
            [0,1,0,1],
            [0,0,1,0],
        ],
        'cycle_4': [
            [0,1,0,1],
            [1,0,1,0],
            [0,1,0,1],
            [1,0,1,0],
        ],
        'complete_4': [
            [0,1,1,1],
            [1,0,1,1],
            [1,1,0,1],
            [1,1,1,0],
        ],
    }

    for name, adj in graphs.items():
        result = classify_graph_topology(adj)
        print(f"\n  Graph: {name}")
        print(f"    V={result['vertices']}, E={result['edges']}, "
              f"T={result['triangles']}, χ={result['euler_characteristic']}")
        print(f"    Edge profile: {result['edge_torsion_profile']}")
        print(f"    Class: {result['topology_class']}")

    print("\n" + "=" * 60)
    print("Application 3: Data Fingerprinting")
    print("=" * 60)

    # Test datasets
    datasets = {
        'powers_of_2': [2**k for k in range(1, 20)],
        'factorials': [1, 2, 6, 24, 120, 720, 5040, 40320],
        'fibonacci': [1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233],
        'random': [random.randint(1, 1000) for _ in range(20)],
    }

    for name, data in datasets.items():
        fp = prime_echo_fingerprint(data, [2, 3, 5])
        print(f"\n  Dataset: {name}")
        for p in [2, 3, 5]:
            dist = fp['valuation_distributions'][p]
            print(f"    v_{p}: mean={dist['mean']:.2f}, max={dist['max']}")
        print(f"    Pairwise agreement rates:")
        for (p, q), rate in fp['pairwise_agreement'].items():
            print(f"      ({p},{q}): {rate:.2%}")

    print("\nAll applications complete.")


"""
Demo: Prime-Sensitive Torsion Echoes in Random Flag Complexes

Demonstrates the core mathematical results:
1. p-adic valuation profiles differ across primes for non-square-free numbers
2. Sensitivity index computation for torsion echo signatures
3. Euler characteristic via alternating binomial sums
4. The prime torsion echo bridge: composite ↔ multi-prime divisibility
"""

from math import comb, gcd
from collections import Counter
from typing import List, Dict, Tuple


def padic_val(p: int, n: int) -> int:
    """Compute the p-adic valuation v_p(n): largest k such that p^k divides n."""
    if n == 0 or p < 2:
        return 0
    k = 0
    while n % p == 0:
        n //= p
        k += 1
    return k


def padic_val_profile(n: int, primes: List[int]) -> List[int]:
    """Compute the p-adic valuation profile of n across a list of primes."""
    return [padic_val(p, n) for p in primes]


def sensitivity_index(n: int, primes: List[int]) -> int:
    """Compute the torsion sensitivity index: number of distinct valuations."""
    vals = set(padic_val(p, n) for p in primes)
    return len(vals)


def is_prime_power(n: int) -> Tuple[bool, int, int]:
    """Check if n is a prime power. Returns (is_pp, prime, exponent)."""
    if n < 2:
        return False, 0, 0
    for p in range(2, int(n**0.5) + 1):
        if n % p == 0:
            k = 0
            m = n
            while m % p == 0:
                m //= p
                k += 1
            if m == 1:
                return True, p, k
            return False, 0, 0
    return True, n, 1  # n is prime


def alternating_binom_sum(n: int) -> int:
    """Compute sum_{k=0}^{n} (-1)^k * C(n,k). Should be 0 for n >= 1."""
    return sum((-1)**k * comb(n, k) for k in range(n + 1))


def prime_factors(n: int) -> List[int]:
    """Return the list of distinct prime factors of n."""
    factors = []
    d = 2
    temp = n
    while d * d <= temp:
        if temp % d == 0:
            factors.append(d)
            while temp % d == 0:
                temp //= d
        d += 1
    if temp > 1:
        factors.append(temp)
    return factors


# ============================================================
# DEMO 1: Prime Sensitivity Witness
# ============================================================
print("=" * 60)
print("DEMO 1: Prime Sensitivity Witness")
print("=" * 60)
print()
print("For p^k with p prime and k >= 1, v_p(p^k) != v_q(p^k) for q != p")
print()

for p in [2, 3, 5, 7]:
    for k in [1, 2, 3]:
        n = p**k
        primes = [2, 3, 5, 7]
        profile = padic_val_profile(n, primes)
        si = sensitivity_index(n, primes)
        print(f"  n = {p}^{k} = {n}")
        print(f"    Profile [v_2, v_3, v_5, v_7] = {profile}")
        print(f"    Sensitivity index = {si}")
        print()

# ============================================================
# DEMO 2: Sensitivity Index Classification
# ============================================================
print("=" * 60)
print("DEMO 2: Sensitivity Index for Various Numbers")
print("=" * 60)
print()

primes_23 = [2, 3]
for n in range(2, 37):
    si = sensitivity_index(n, primes_23)
    pp, base, exp = is_prime_power(n)
    pf = prime_factors(n)
    profile = padic_val_profile(n, primes_23)
    marker = "UNIVERSAL" if si == 1 else "NON-UNIVERSAL"
    print(f"  n={n:3d}  factors={pf}  v_2={profile[0]} v_3={profile[1]}  "
          f"SI={si}  [{marker}]  prime_power={pp}")

# ============================================================
# DEMO 3: Alternating Binomial Sum Identity
# ============================================================
print()
print("=" * 60)
print("DEMO 3: Alternating Binomial Sum = 0 for n >= 1")
print("=" * 60)
print()

for n in range(0, 16):
    s = alternating_binom_sum(n)
    print(f"  n={n:2d}: sum_{{k=0}}^{n} (-1)^k * C({n},k) = {s}")

# ============================================================
# DEMO 4: Prime Torsion Echo Bridge
# ============================================================
print()
print("=" * 60)
print("DEMO 4: Bridge Theorem Verification")
print("=" * 60)
print()
print("n > 1 has >= 2 distinct prime divisors ↔ n is NOT a prime power")
print()

for n in range(2, 50):
    pf = prime_factors(n)
    has_two_primes = len(pf) >= 2
    pp, _, _ = is_prime_power(n)
    bridge_holds = (has_two_primes == (not pp))
    if not bridge_holds:
        print(f"  COUNTEREXAMPLE at n={n}!")
    if n <= 20 or not pp:
        print(f"  n={n:3d}: prime_factors={pf}, is_prime_power={pp}, "
              f"has_two_primes={has_two_primes}, bridge_holds={bridge_holds}")

# ============================================================
# DEMO 5: Persistence Conjecture Verification
# ============================================================
print()
print("=" * 60)
print("DEMO 5: Prime Sensitivity Persistence Conjecture")
print("=" * 60)
print()
print("For n >= 6, exists m with 1 < m <= C(n,2) and v_2(m) != v_3(m)")
print()

for n in range(6, 25):
    cn2 = comb(n, 2)
    witness = None
    for m in range(2, cn2 + 1):
        if padic_val(2, m) != padic_val(3, m):
            witness = m
            break
    print(f"  n={n:2d}, C(n,2)={cn2:4d}, smallest witness m={witness}, "
          f"v_2({witness})={padic_val(2, witness)}, v_3({witness})={padic_val(3, witness)}")

# ============================================================
# DEMO 6: Coprime Product Profile Decomposition
# ============================================================
print()
print("=" * 60)
print("DEMO 6: Coprime Product Valuation Decomposition")
print("=" * 60)
print()

coprime_pairs = [(8, 9), (25, 12), (7, 15), (4, 27), (11, 36)]
primes_test = [2, 3, 5, 7, 11]

for a, b in coprime_pairs:
    assert gcd(a, b) == 1, f"{a} and {b} are not coprime"
    n = a * b
    print(f"  a={a}, b={b}, a*b={n}, gcd={gcd(a,b)}")
    for p in primes_test:
        va = padic_val(p, a)
        vb = padic_val(p, b)
        vn = padic_val(p, n)
        check = "✓" if vn == va + vb else "✗"
        print(f"    v_{p}({n}) = {vn} = v_{p}({a}) + v_{p}({b}) = {va} + {vb} {check}")
    print()

print("All demos complete.")


"""
Visualization: Prime Torsion Echo Bridge Diagram

Shows the bridge theorem in action: numbers are classified by their
prime power status and sensitivity index. The diagram illustrates that
prime powers (single-prime-divisor numbers) are exactly those with
trivial torsion echo, while composite numbers with multiple prime
factors exhibit rich prime-sensitive structure.

Also plots the persistence conjecture: for each n, the fraction of
m ≤ C(n,2) that exhibit non-universal torsion across {2, 3}.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb


def padic_val(p: int, n: int) -> int:
    """Compute the p-adic valuation v_p(n)."""
    if n == 0 or p < 2:
        return 0
    k = 0
    while n % p == 0:
        n //= p
        k += 1
    return k


def is_prime_power(n: int) -> bool:
    """Check if n is a prime power."""
    if n < 2:
        return False
    for p in range(2, int(n**0.5) + 1):
        if n % p == 0:
            m = n
            while m % p == 0:
                m //= p
            return m == 1
    return True  # n is prime (prime^1)


def count_prime_factors(n: int) -> int:
    """Count distinct prime factors."""
    count = 0
    d = 2
    temp = n
    while d * d <= temp:
        if temp % d == 0:
            count += 1
            while temp % d == 0:
                temp //= d
        d += 1
    if temp > 1:
        count += 1
    return count


def sensitivity_index(n: int, primes: list) -> int:
    """Number of distinct p-adic valuations."""
    return len(set(padic_val(p, n) for p in primes))


# ============================================================
# Figure with 3 subplots
# ============================================================
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# --- Subplot 1: Classification scatter ---
N = 150
primes_full = [2, 3, 5, 7, 11]
x_pp, y_pp = [], []
x_comp, y_comp = [], []

for n in range(2, N + 1):
    si = sensitivity_index(n, primes_full)
    npf = count_prime_factors(n)
    if is_prime_power(n):
        x_pp.append(n)
        y_pp.append(si)
    else:
        x_comp.append(n)
        y_comp.append(si)

axes[0].scatter(x_pp, y_pp, c='#3498db', s=15, alpha=0.7, label='Prime powers', zorder=5)
axes[0].scatter(x_comp, y_comp, c='#e74c3c', s=15, alpha=0.7, label='Composites (≥2 prime factors)', zorder=5)
axes[0].set_xlabel('n')
axes[0].set_ylabel('Sensitivity Index')
axes[0].set_title('Bridge Theorem:\nPrime Powers vs Composites', fontweight='bold')
axes[0].legend(fontsize=8)
axes[0].set_xlim(0, N)

# --- Subplot 2: Prime factor count vs sensitivity ---
for n in range(2, N + 1):
    si = sensitivity_index(n, primes_full)
    npf = count_prime_factors(n)
    color = '#3498db' if is_prime_power(n) else '#e74c3c'
    axes[1].scatter(npf, si, c=color, s=12, alpha=0.4)

axes[1].set_xlabel('Number of Distinct Prime Factors')
axes[1].set_ylabel('Sensitivity Index')
axes[1].set_title('Prime Factor Count\nvs Sensitivity', fontweight='bold')

# --- Subplot 3: Persistence conjecture ---
max_n = 30
n_values = list(range(3, max_n + 1))
fractions = []

for n in n_values:
    cn2 = comb(n, 2)
    if cn2 < 2:
        fractions.append(0)
        continue
    count_nonuniv = sum(1 for m in range(2, cn2 + 1)
                        if padic_val(2, m) != padic_val(3, m))
    fractions.append(count_nonuniv / (cn2 - 1))

axes[2].plot(n_values, fractions, 'o-', color='#2ecc71', markersize=4, linewidth=1.5)
axes[2].axhline(y=0.5, color='gray', linestyle='--', alpha=0.5, label='50% threshold')
axes[2].fill_between(n_values, fractions, alpha=0.2, color='#2ecc71')
axes[2].set_xlabel('Number of vertices n')
axes[2].set_ylabel('Fraction of m with v₂(m) ≠ v₃(m)')
axes[2].set_title('Persistence Conjecture:\nNon-Universal Fraction', fontweight='bold')
axes[2].legend(fontsize=8)
axes[2].set_ylim(0, 1)

plt.tight_layout()
plt.savefig('viz_bridge_diagram.png', dpi=150, bbox_inches='tight')
print("Saved viz_bridge_diagram.png")


"""
Visualization: Torsion Echo Landscape

A 3D-style surface plot showing how the p-adic valuation landscape changes
across different primes and group orders. Each "ridge" in the landscape
corresponds to multiples of a prime power, creating a characteristic
pattern unique to each prime — the "echo" of that prime in the torsion
structure.

This visualization makes tangible the key insight: the landscape of
v_p(n) is qualitatively different for different primes p.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap


def padic_val(p: int, n: int) -> int:
    """Compute the p-adic valuation v_p(n)."""
    if n == 0 or p < 2:
        return 0
    k = 0
    while n % p == 0:
        n //= p
        k += 1
    return k


# Parameters
N = 200
primes = [2, 3, 5, 7, 11, 13]
orders = np.arange(1, N + 1)

fig, axes = plt.subplots(3, 2, figsize=(14, 10))
fig.suptitle('Torsion Echo Landscapes: Each Prime Leaves a Unique Fingerprint',
             fontsize=14, fontweight='bold')

for idx, p in enumerate(primes):
    ax = axes[idx // 2, idx % 2]
    vals = [padic_val(p, int(n)) for n in orders]

    # Create colored bar plot
    colors_map = {0: '#e8e8e8', 1: '#3498db', 2: '#2ecc71',
                  3: '#e67e22', 4: '#e74c3c', 5: '#9b59b6'}
    colors = [colors_map.get(v, '#2c3e50') for v in vals]

    ax.bar(orders, vals, color=colors, width=1.0, edgecolor='none')
    ax.set_title(f'v_{p}(n): Echo of prime {p}', fontsize=11, fontweight='bold')
    ax.set_xlabel('n')
    ax.set_ylabel(f'v_{p}(n)')
    ax.set_xlim(0, N)

    # Annotate key features
    max_val = max(vals)
    if max_val > 0:
        max_idx = vals.index(max_val)
        ax.annotate(f'v_{p}({orders[max_idx]})={max_val}',
                    xy=(orders[max_idx], max_val),
                    xytext=(orders[max_idx] + 15, max_val),
                    fontsize=8, color='red',
                    arrowprops=dict(arrowstyle='->', color='red', lw=0.8))

    # Show periodicity: mark multiples of p
    for mult in range(p, N + 1, p):
        ax.axvline(x=mult, color='gray', alpha=0.05, linewidth=0.5)

plt.tight_layout()
plt.savefig('viz_echo_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_echo_landscape.png")


"""
Visualization: Torsion Sensitivity Heatmap

Displays a heatmap of the sensitivity index (number of distinct p-adic
valuations) across different group orders and prime sets. Highlights
the boundary between universal and non-universal torsion behavior.

The x-axis represents group orders (integers from 2 to N), and each row
represents a different prime used for the p-adic valuation. The color
intensity shows the valuation value, making it visually apparent where
different primes "see" the same vs. different structure in a number.
"""

import numpy as np
import matplotlib.pyplot as plt


def padic_val(p: int, n: int) -> int:
    """Compute the p-adic valuation v_p(n)."""
    if n == 0 or p < 2:
        return 0
    k = 0
    while n % p == 0:
        n //= p
        k += 1
    return k


def sensitivity_index(n: int, primes: list) -> int:
    """Number of distinct p-adic valuations across primes."""
    return len(set(padic_val(p, n) for p in primes))


# Parameters
N = 120
primes = [2, 3, 5, 7, 11]
orders = list(range(2, N + 1))

# Build valuation matrix
val_matrix = np.zeros((len(primes), len(orders)))
for i, p in enumerate(primes):
    for j, n in enumerate(orders):
        val_matrix[i, j] = padic_val(p, n)

# Compute sensitivity indices
si_values = [sensitivity_index(n, primes) for n in orders]

# Create figure
fig, axes = plt.subplots(2, 1, figsize=(14, 8), gridspec_kw={'height_ratios': [3, 1]})

# Heatmap of valuations
im = axes[0].imshow(val_matrix, aspect='auto', cmap='YlOrRd',
                     extent=[2, N, len(primes) - 0.5, -0.5])
axes[0].set_yticks(range(len(primes)))
axes[0].set_yticklabels([f'v_{p}' for p in primes])
axes[0].set_xlabel('Group Order n')
axes[0].set_title('p-adic Valuation Profiles: The Arithmetic Fingerprint of Torsion',
                   fontsize=13, fontweight='bold')
plt.colorbar(im, ax=axes[0], label='Valuation v_p(n)')

# Highlight prime powers with markers
for n in orders:
    # Check if prime power
    is_pp = False
    for p in range(2, n + 1):
        if p > int(n**0.5) + 1 and n > 1:
            # n itself is prime
            is_pp = True
            break
        k = 0
        m = n
        while m % p == 0:
            m //= p
            k += 1
        if m == 1 and k >= 1:
            is_pp = True
            break
    if is_pp and n <= 50:
        axes[0].axvline(x=n, color='cyan', alpha=0.15, linewidth=1)

# Sensitivity index bar chart
colors = ['#2ecc71' if s == 1 else '#e74c3c' if s >= 3 else '#f39c12'
          for s in si_values]
axes[1].bar(orders, si_values, color=colors, width=1.0, edgecolor='none')
axes[1].set_xlabel('Group Order n')
axes[1].set_ylabel('Sensitivity\nIndex')
axes[1].set_title('Torsion Sensitivity Index (1 = universal, >1 = prime-dependent)',
                   fontsize=11)
axes[1].set_xlim(2, N)

# Legend
from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor='#2ecc71', label='SI = 1 (Universal)'),
    Patch(facecolor='#f39c12', label='SI = 2'),
    Patch(facecolor='#e74c3c', label='SI ≥ 3 (Highly sensitive)'),
]
axes[1].legend(handles=legend_elements, loc='upper right', fontsize=8)

plt.tight_layout()
plt.savefig('viz_sensitivity_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_sensitivity_heatmap.png")
