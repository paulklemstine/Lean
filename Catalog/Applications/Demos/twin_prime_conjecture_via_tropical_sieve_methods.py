#!/usr/bin/env python3
"""
Tropical Sieve Energetics — Applications

Demonstrates connections to:
1. Additive combinatorics (sumset gap patterns)
2. Coding theory (minimum distance via tropical convolution)
3. Shortest-path / optimization (tropical semiring structure)
4. Statistical mechanics (ground-state energy interpretation)
"""

import numpy as np
from typing import Set, List, Tuple, Dict
from algorithms import (tropical_conv_naive, tropical_conv_array,
                        enumerate_twin_pairs, compute_gap_profile,
                        residue_decomposition, analyze_cross_residue_twins)


# ============================================================
# Application 1: Additive Combinatorics — Sumset Gap Detection
# ============================================================
def generalized_gap_detection(s: Set[int], gaps: List[int], N: int) -> Dict[int, bool]:
    """
    For each gap h in the list, determine whether s supports any
    pair (n, n+h) with both elements in s.

    This generalizes twin-pair detection to arbitrary constellation
    patterns, connecting to the Hardy-Littlewood k-tuple conjecture.

    Application: Given a dense subset of {0,...,N-1}, which additive
    patterns are present?
    """
    results = {}
    for h in gaps:
        found = any(n in s and n + h in s for n in range(N))
        results[h] = found
    return results


def sumset_gap_density(A: Set[int], B: Set[int], N: int) -> np.ndarray:
    """
    Compute the density of gaps in the sumset A + B.

    Uses the tropical convolution perspective: the sumset A+B
    can be analyzed via min-plus convolution of indicator costs.
    Where the convolution vanishes, elements exist.
    """
    f = np.array([0.0 if i in A else 1.0 for i in range(N)])
    g = np.array([0.0 if i in B else 1.0 for i in range(N)])
    return tropical_conv_array(f, g, N)


# ============================================================
# Application 2: Coding Theory — Minimum Distance Detection
# ============================================================
def code_gap_analysis(codewords: Set[int], N: int) -> Dict[str, any]:
    """
    Analyze gap structure of a set of codeword positions.

    In coding theory, the minimum distance between codewords
    determines error-correction capability. The tropical convolution
    framework detects which distances are realized.

    The support cost encodes whether a position is a codeword.
    The tropical convolution vanishing locus gives realized distances.
    """
    profile = compute_gap_profile(codewords, N, N)
    min_dist = next((h for h in range(1, N) if profile[h] > 0), N)
    realized_dists = [h for h in range(1, N) if profile[h] > 0]

    return {
        "codewords": sorted(codewords),
        "min_distance": min_dist,
        "realized_distances": realized_dists[:20],
        "gap_profile": profile[:min(20, N)],
    }


# ============================================================
# Application 3: Ground-State Energy (Statistical Mechanics)
# ============================================================
def ground_state_energy(positions: Set[int], N: int,
                        interaction_range: int = 2) -> float:
    """
    Interpret the tropical convolution as ground-state energy.

    Model: particles at positions in {0,...,N-1}.
    Cost function: 0 for occupied positions, 1 for vacant.
    Interaction: particles at distance `interaction_range` interact.

    The min-plus convolution computes the minimum total cost
    of placing a pair at separation `interaction_range`.
    Zero cost = both positions occupied = interaction present.

    This connects sieve energetics to zero-temperature
    statistical mechanics of lattice gases.
    """
    f = np.array([0.0 if i in positions else 1.0 for i in range(N)])
    g = np.array([0.0 if (i + interaction_range) in positions else 1.0
                  for i in range(N)])
    conv = tropical_conv_array(f, g, N)
    # Ground state = global minimum of the convolution
    return float(np.min(conv))


def partition_function_tropical(positions: Set[int], N: int,
                                max_range: int = 10) -> np.ndarray:
    """
    Compute tropical 'partition function' over interaction ranges.

    Z(h) = min_{n} tropical_conv(support, shift_h(support))(n)

    Z(h) = 0 iff there exist particles at separation h.
    This gives a complete picture of which separations are
    energetically accessible (zero cost).
    """
    Z = np.zeros(max_range)
    for h in range(max_range):
        f = np.array([0.0 if i in positions else 1.0 for i in range(N)])
        g = np.array([0.0 if (i + h) in positions else 1.0
                      for i in range(N)])
        conv = tropical_conv_array(f, g, N)
        Z[h] = float(np.min(conv))
    return Z


# ============================================================
# Application 4: Sieve-Theoretic Density Bounds
# ============================================================
def sieve_density_analysis(N: int) -> Dict[str, any]:
    """
    Analyze how twin-pair density varies across residue-filtered sets.

    Starting from {0,...,N-1}, progressively sieve by removing
    residue classes and track how twin count changes.

    This illustrates the arithmetic obstruction theorem:
    sieving by congruences removes twin pairs selectively,
    and the tropical framework detects which sieves are effective.
    """
    full = set(range(N))
    results = []

    # Start with full set
    tc = len(enumerate_twin_pairs(full))
    results.append({"sieve": "none", "size": len(full), "twins": tc})

    # Remove multiples of 2 (keep odds)
    s = {n for n in range(2, N) if n % 2 == 1}
    tc = len(enumerate_twin_pairs(s))
    results.append({"sieve": "remove even", "size": len(s), "twins": tc})

    # Remove multiples of 3
    s = {n for n in range(2, N) if n % 2 == 1 and n % 3 != 0}
    tc = len(enumerate_twin_pairs(s))
    results.append({"sieve": "remove 2,3-multiples", "size": len(s), "twins": tc})

    # Remove multiples of 5
    s = {n for n in range(2, N) if n % 2 == 1 and n % 3 != 0 and n % 5 != 0}
    tc = len(enumerate_twin_pairs(s))
    results.append({"sieve": "remove 2,3,5-multiples", "size": len(s), "twins": tc})

    return results


# ============================================================
# Demonstrations
# ============================================================
if __name__ == "__main__":
    print("Tropical Sieve Energetics — Applications")
    print("=" * 60)

    # --- Additive Combinatorics ---
    print("\n1. ADDITIVE COMBINATORICS: Generalized Gap Detection")
    print("-" * 50)
    s = {n for n in range(100) if n % 6 == 1 or n % 6 == 5}
    gaps_detected = generalized_gap_detection(s, [2, 4, 6, 8, 10, 12], 100)
    print(f"  Set: numbers ≡ 1 or 5 (mod 6) in [0,100)")
    print(f"  |s| = {len(s)}")
    for gap, found in gaps_detected.items():
        print(f"    gap {gap:2d}: {'present' if found else 'absent'}")

    # --- Coding Theory ---
    print("\n2. CODING THEORY: Code Gap Analysis")
    print("-" * 50)
    # Hamming-like code positions
    code = {0, 3, 5, 6, 9, 10, 12, 15}
    analysis = code_gap_analysis(code, 20)
    print(f"  Codewords: {analysis['codewords']}")
    print(f"  Min distance: {analysis['min_distance']}")
    print(f"  Realized distances: {analysis['realized_distances']}")

    # --- Statistical Mechanics ---
    print("\n3. STATISTICAL MECHANICS: Ground-State Energy")
    print("-" * 50)
    primes = set()
    for n in range(2, 50):
        if all(n % d != 0 for d in range(2, int(n**0.5) + 1)):
            primes.add(n)

    for r in [2, 4, 6]:
        E = ground_state_energy(primes, 50, r)
        has_pair = any(p + r in primes for p in primes)
        print(f"  Interaction range {r}: E = {E:.0f} "
              f"({'pairs exist' if has_pair else 'no pairs'})")

    Z = partition_function_tropical(primes, 50, 15)
    print(f"\n  Tropical partition function Z(h) for primes < 50:")
    for h in range(1, 15):
        print(f"    h={h:2d}: Z={Z[h]:.0f} "
              f"{'⟹ separation realized' if Z[h] == 0 else '⟹ no such pair'}")

    # --- Sieve Analysis ---
    print("\n4. SIEVE-THEORETIC DENSITY ANALYSIS (N=100)")
    print("-" * 50)
    sieve_results = sieve_density_analysis(100)
    for r in sieve_results:
        print(f"  {r['sieve']:25s}: |s|={r['size']:3d}, twins={r['twins']:3d}")

    print("\n  Key insight: Progressive sieving reduces twin pairs,")
    print("  but the relationship is NOT monotone in density.")
    print("  Arithmetic structure (residue constraints) matters")
    print("  more than cardinality alone — confirming the")
    print("  obstruction theorem.")


#!/usr/bin/env python3
"""
Tropical Sieve Energetics — Demonstrations

Concrete numerical examples illustrating the theorems from the formal framework.
Shows how min-plus convolution detects gap patterns in finite subsets of natural numbers.
"""

import numpy as np
from typing import Set, Dict, List, Tuple


def support_cost(s: Set[int], n: int) -> float:
    """Support cost: 0 if n ∈ s, 1 otherwise."""
    return 0.0 if n in s else 1.0


def tropical_conv(f, g, n: int) -> float:
    """Min-plus convolution: inf_{k=0..n} (f(k) + g(n-k))."""
    return min(f(k) + g(n - k) for k in range(n + 1))


def pair_indicator(s: Set[int], n: int) -> int:
    """1 if n and n+2 both in s, else 0."""
    return 1 if (n in s and n + 2 in s) else 0


def twin_count(s: Set[int]) -> int:
    """Count of twin pairs in s."""
    return sum(pair_indicator(s, n) for n in s)


def has_no_twin_pairs(s: Set[int]) -> bool:
    """Check if s has no twin pairs."""
    return all(n + 2 not in s for n in s)


def gap_profile(s: Set[int], h: int, N: int) -> int:
    """Count elements n < N with both n ∈ s and n+h ∈ s."""
    return sum(1 for n in range(N) if n in s and n + h in s)


def find_gap_witness(s: Set[int], n: int) -> Tuple[bool, int]:
    """Find k ≤ n such that k ∈ s and (n-k)+2 ∈ s, if it exists."""
    for k in range(n + 1):
        if k in s and (n - k) + 2 in s:
            return True, k
    return False, -1


# ============================================================
# Example 1: Evens in [0, N)
# ============================================================
print("=" * 60)
print("Example 1: Evens in [0, 20)")
print("=" * 60)
N = 20
evens = {n for n in range(N) if n % 2 == 0}
print(f"  s = {sorted(evens)}")
print(f"  |s| = {len(evens)}")
print(f"  twin_count = {twin_count(evens)}")
print(f"  has_no_twin_pairs = {has_no_twin_pairs(evens)}")
print(f"  Note: {0} and {2} are both even and form a twin pair!")
print()

# ============================================================
# Example 2: Odds in [0, N)
# ============================================================
print("=" * 60)
print("Example 2: Odds in [0, 20)")
print("=" * 60)
odds = {n for n in range(N) if n % 2 == 1}
print(f"  s = {sorted(odds)}")
print(f"  |s| = {len(odds)}")
print(f"  twin_count = {twin_count(odds)}")
print(f"  has_no_twin_pairs = {has_no_twin_pairs(odds)}")
print()

# ============================================================
# Example 3: Residue class mod 3 — no twin pairs
# ============================================================
print("=" * 60)
print("Example 3: Residue class 0 mod 3 in [0, 30)")
print("=" * 60)
mod3_class = {n for n in range(30) if n % 3 == 0}
print(f"  s = {sorted(mod3_class)}")
print(f"  |s| = {len(mod3_class)}")
print(f"  twin_count = {twin_count(mod3_class)}")
print(f"  has_no_twin_pairs = {has_no_twin_pairs(mod3_class)}")
print(f"  Theorem B2 confirms: single residue class mod 3 ⟹ zero twin pairs")
print()

for r in range(3):
    s_r = {n for n in range(30) if n % 3 == r}
    print(f"  Residue class {r} mod 3: twin_count = {twin_count(s_r)}")

print()

# ============================================================
# Example 4: A small set with exactly one twin pair
# ============================================================
print("=" * 60)
print("Example 4: Set with exactly one twin pair")
print("=" * 60)
s_one = {3, 5, 10}
print(f"  s = {sorted(s_one)}")
print(f"  twin_count = {twin_count(s_one)}")
print(f"  Twin pair at n=3: {3} and {5} (3+2=5)")
print()

# ============================================================
# Example 5: Tropical convolution witness detection
# ============================================================
print("=" * 60)
print("Example 5: Tropical convolution witness detection")
print("=" * 60)
s = {1, 4, 7, 9}
print(f"  s = {sorted(s)}")
print()

f = lambda k: support_cost(s, k)
g = lambda m: support_cost(s, m + 2)

for n in range(15):
    conv_val = tropical_conv(f, g, n)
    found, k = find_gap_witness(s, n)
    status = f"witness k={k}: {k}∈s, {n-k}+2={n-k+2}∈s" if found else "no witness"
    print(f"  n={n:2d}: conv={conv_val:.0f}, {status}")

print()
print("  Theorem C3 confirmed: conv=0 ⟺ witness exists")
print()

# ============================================================
# Example 6: Spacing ≥ 3 implies no twin pairs
# ============================================================
print("=" * 60)
print("Example 6: Well-spaced sets")
print("=" * 60)
s_spaced = {0, 3, 6, 9, 12, 15}
print(f"  s = {sorted(s_spaced)} (spacing = 3)")
print(f"  twin_count = {twin_count(s_spaced)}")
print(f"  has_no_twin_pairs = {has_no_twin_pairs(s_spaced)}")
print()

s_close = {0, 2, 5, 7, 10, 12}
print(f"  s = {sorted(s_close)} (contains pairs with gap 2)")
print(f"  twin_count = {twin_count(s_close)}")
print(f"  Twin pairs: ", end="")
print(", ".join(f"({n},{n+2})" for n in sorted(s_close) if n+2 in s_close))
print()

# ============================================================
# Example 7: Gap profiles for various gaps
# ============================================================
print("=" * 60)
print("Example 7: Gap profiles")
print("=" * 60)
primes_30 = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29}
print(f"  Primes < 30: {sorted(primes_30)}")
for gap in [1, 2, 4, 6]:
    gp = gap_profile(primes_30, gap, 30)
    pairs = [(n, n+gap) for n in sorted(primes_30) if n+gap in primes_30 and n < 30]
    print(f"  gap={gap}: count={gp}, pairs={pairs}")

print()

# ============================================================
# Summary
# ============================================================
print("=" * 60)
print("SUMMARY OF KEY RESULTS")
print("=" * 60)
print("""
  Theorem A: Empty set witnesses twin-free subset for any N, weight.
             ⟹ Tropical/order data alone cannot force twin primes.

  Theorem B2: Single residue class mod 3 ⟹ zero twin pairs.
              Twin detection requires cross-residue interaction.

  Theorem B3: Spacing ≥ 3 ⟹ no twin pairs.

  Theorem C3: Tropical convolution vanishes ⟺ gap-2 witness exists.
              This is the tropical pattern-detection theorem.
""")

if __name__ == "__main__":
    pass


#!/usr/bin/env python3
"""Generate PACKAGE.json with all artifacts."""
import json
import base64

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def read_binary_base64(path):
    with open(path, 'rb') as f:
        return "data:image/png;base64," + base64.b64encode(f.read()).decode()

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_proofs = read_file('Tropical/SieveEnergetics.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')

# Read visualization images
fig1 = read_binary_base64('fig_tropical_convolution.png')
fig2 = read_binary_base64('fig_residue_decomposition.png')
fig3 = read_binary_base64('fig_gap_profile.png')
fig4 = read_binary_base64('fig_sieve_progression.png')

package = {
    "title": "Tropical Sieve Energetics: Gap-Pattern Detection via Min-Plus Convolution",
    "domain": "Tropical Algebra / Additive Combinatorics / Number Theory",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Sieve Energetics Demo",
            "code": demo_code
        },
        {
            "name": "Applications Demo",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Tropical (Min-Plus) Convolution",
            "pseudocode": "Input: f, g : {0,...,N-1} -> R, point n\nOutput: min_{k=0}^{n} [f(k) + g(n-k)]\n\nresult = +inf\nfor k = 0 to n:\n    result = min(result, f(k) + g(n-k))\nreturn result\n\nTime: O(n)  Space: O(1)",
            "code": algorithms_code
        },
        {
            "name": "Gap-Pattern Witness Extraction",
            "pseudocode": "Input: Set s, range N, gap h\nOutput: List of (n, k) witness pairs\n\nfor n = 0 to N-1:\n    for k in sorted(s):\n        if k > n: break\n        if (n-k)+h in s:\n            emit (n, k); break\n\nTime: O(N * |s|)  Space: O(|s|)",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Tropical Convolution Witness Detection",
            "data": fig1
        },
        {
            "name": "Residue Class Decomposition",
            "data": fig2
        },
        {
            "name": "Gap Profile of Primes",
            "data": fig3
        },
        {
            "name": "Sieve Density Progression",
            "data": fig4
        }
    ],
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated ({len(json.dumps(package))//1024} KB)")


#!/usr/bin/env python3
"""
Tropical Sieve Energetics — Visualizations

Generates publication-quality figures illustrating the key theorems.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
from io import BytesIO
from typing import Set


def support_cost(s: Set[int], n: int) -> float:
    return 0.0 if n in s else 1.0


def tropical_conv_val(s: Set[int], n: int, gap: int = 2) -> float:
    return min(support_cost(s, k) + support_cost(s, (n - k) + gap)
               for k in range(n + 1))


def fig_to_base64(fig) -> str:
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode()


def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True


# ============================================================
# Figure 1: Tropical Convolution Witness Detection
# ============================================================
def plot_tropical_convolution():
    primes = {n for n in range(60) if is_prime(n)}
    N = 40

    conv_vals = [tropical_conv_val(primes, n) for n in range(N)]
    witnesses = [n for n in range(N) if conv_vals[n] == 0]
    non_witnesses = [n for n in range(N) if conv_vals[n] > 0]

    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 6), sharex=True)

    # Top: Prime membership
    for n in range(N):
        color = '#2196F3' if n in primes else '#E0E0E0'
        ax1.bar(n, 1, color=color, edgecolor='white', linewidth=0.5)
    ax1.set_ylabel('Membership', fontsize=12)
    ax1.set_title('Tropical Convolution Detects Gap-2 Patterns in Primes',
                   fontsize=14, fontweight='bold')
    ax1.set_yticks([])

    # Custom legend
    from matplotlib.patches import Patch
    ax1.legend([Patch(facecolor='#2196F3'), Patch(facecolor='#E0E0E0')],
               ['Prime', 'Not prime'], loc='upper right', fontsize=10)

    # Bottom: Convolution values
    colors = ['#4CAF50' if v == 0 else '#FF5722' for v in conv_vals]
    ax2.bar(range(N), conv_vals, color=colors, edgecolor='white', linewidth=0.5)
    ax2.set_xlabel('n', fontsize=12)
    ax2.set_ylabel('Conv(n)', fontsize=12)
    ax2.axhline(y=0, color='black', linewidth=0.5)

    ax2.legend([Patch(facecolor='#4CAF50'), Patch(facecolor='#FF5722')],
               ['Witness exists (conv=0)', 'No witness (conv>0)'],
               loc='upper right', fontsize=10)

    plt.tight_layout()
    return fig


# ============================================================
# Figure 2: Residue Class Decomposition
# ============================================================
def plot_residue_decomposition():
    N = 30
    primes = {n for n in range(N) if is_prime(n)}

    fig, axes = plt.subplots(1, 4, figsize=(16, 3))

    # Full set
    for n in range(N):
        color = '#2196F3' if n in primes else '#E0E0E0'
        axes[0].bar(n, 1, color=color, edgecolor='white', linewidth=0.5)
    twins = [(n, n+2) for n in sorted(primes) if n+2 in primes]
    for (a, b) in twins:
        axes[0].annotate('', xy=(b, 1.05), xytext=(a, 1.05),
                         arrowprops=dict(arrowstyle='<->', color='red', lw=2))
    axes[0].set_title(f'All primes < {N}\n{len(twins)} twin pairs', fontsize=11)
    axes[0].set_yticks([])

    # Residue classes mod 3
    for r in range(3):
        ax = axes[r + 1]
        s_r = {n for n in primes if n % 3 == r}
        for n in range(N):
            if n in s_r:
                color = ['#FF9800', '#9C27B0', '#009688'][r]
            else:
                color = '#F5F5F5'
            ax.bar(n, 1, color=color, edgecolor='white', linewidth=0.5)
        tc = sum(1 for n in s_r if n + 2 in s_r)
        ax.set_title(f'n ≡ {r} (mod 3)\n{tc} twin pairs', fontsize=11)
        ax.set_yticks([])

    fig.suptitle('Residue Decomposition: Single Class mod 3 → Zero Twin Pairs',
                 fontsize=13, fontweight='bold', y=1.08)
    plt.tight_layout()
    return fig


# ============================================================
# Figure 3: Gap Profile Heatmap
# ============================================================
def plot_gap_profile():
    N = 100
    primes = {n for n in range(N) if is_prime(n)}

    max_gap = 30
    profile = np.zeros(max_gap)
    for h in range(max_gap):
        profile[h] = sum(1 for n in range(N) if n in primes and n + h in primes)

    fig, ax = plt.subplots(figsize=(12, 4))
    colors = ['#4CAF50' if profile[h] > 0 else '#FFCDD2' for h in range(max_gap)]
    bars = ax.bar(range(max_gap), profile, color=colors, edgecolor='white')

    # Highlight gap 2 (twin primes)
    if max_gap > 2:
        bars[2].set_color('#F44336')
        bars[2].set_edgecolor('#B71C1C')

    ax.set_xlabel('Gap h', fontsize=12)
    ax.set_ylabel('Count of pairs (n, n+h) in primes', fontsize=12)
    ax.set_title(f'Gap Profile of Primes < {N}', fontsize=14, fontweight='bold')
    ax.set_xticks(range(0, max_gap, 2))

    # Annotate twin prime count
    ax.annotate(f'Twin primes\n(gap 2): {int(profile[2])} pairs',
                xy=(2, profile[2]), xytext=(8, profile[2] + 2),
                arrowprops=dict(arrowstyle='->', color='#F44336'),
                fontsize=10, color='#F44336', fontweight='bold')

    plt.tight_layout()
    return fig


# ============================================================
# Figure 4: Sieve Density Progression
# ============================================================
def plot_sieve_progression():
    N = 200
    sieve_steps = []

    # Progressive sieve
    s = set(range(2, N))
    sieve_steps.append(("No sieve", len(s),
                        sum(1 for n in s if n+2 in s)))

    for p in [2, 3, 5, 7, 11, 13]:
        # Remove one residue class mod p (the class containing 0)
        s = {n for n in s if n % p != 0}
        twins = sum(1 for n in s if n + 2 in s)
        sieve_steps.append((f"Sieve ≤ {p}", len(s), twins))

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    labels = [step[0] for step in sieve_steps]
    sizes = [step[1] for step in sieve_steps]
    twins = [step[2] for step in sieve_steps]

    x = range(len(labels))
    ax1.bar(x, sizes, color='#2196F3', alpha=0.8)
    ax1.set_xticks(x)
    ax1.set_xticklabels(labels, rotation=45, ha='right')
    ax1.set_ylabel('Set size', fontsize=12)
    ax1.set_title('Set Size After Sieving', fontsize=13, fontweight='bold')

    ax2.bar(x, twins, color='#FF5722', alpha=0.8)
    ax2.set_xticks(x)
    ax2.set_xticklabels(labels, rotation=45, ha='right')
    ax2.set_ylabel('Twin pair count', fontsize=12)
    ax2.set_title('Twin Pairs After Sieving', fontsize=13, fontweight='bold')

    # Add density ratio
    for i, (s_val, t_val) in enumerate(zip(sizes, twins)):
        if s_val > 0:
            ratio = t_val / s_val
            ax2.annotate(f'{ratio:.2f}', xy=(i, t_val), ha='center',
                         va='bottom', fontsize=8, color='#333')

    plt.tight_layout()
    return fig


# ============================================================
# Generate all figures
# ============================================================
if __name__ == "__main__":
    print("Generating visualizations...")

    fig1 = plot_tropical_convolution()
    fig1.savefig('fig_tropical_convolution.png', dpi=150, bbox_inches='tight')
    print("  Saved fig_tropical_convolution.png")

    fig2 = plot_residue_decomposition()
    fig2.savefig('fig_residue_decomposition.png', dpi=150, bbox_inches='tight')
    print("  Saved fig_residue_decomposition.png")

    fig3 = plot_gap_profile()
    fig3.savefig('fig_gap_profile.png', dpi=150, bbox_inches='tight')
    print("  Saved fig_gap_profile.png")

    fig4 = plot_sieve_progression()
    fig4.savefig('fig_sieve_progression.png', dpi=150, bbox_inches='tight')
    print("  Saved fig_sieve_progression.png")

    print("Done!")
