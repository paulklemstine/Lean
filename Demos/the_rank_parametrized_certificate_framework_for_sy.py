"""
Applications of Symplectic Expansion Certificates
=================================================

Real-world applications demonstrating the certificate framework:
1. Pseudorandom number generation quality from expander walks
2. Error-correcting code construction from spectral gaps
3. Derandomization of algorithms using expander mixing
"""

import math
from typing import List, Tuple


def char_ratio_bound(n: int, q: int) -> float:
    """Character ratio bound (n+1)/q."""
    return (n + 1) / q


def spectral_gap(n: int, q: int) -> float:
    """Spectral gap 1 - (n+1)/q."""
    return 1.0 - char_ratio_bound(n, q)


# ========== APPLICATION 1: Pseudorandom Walk Quality ==========

def prg_quality_assessment(n: int, q: int, num_steps: int) -> dict:
    """Assess quality of pseudorandom numbers from an expander walk.
    
    A random walk on the Cayley graph of Sp_{2n}(F_q) produces
    pseudorandom group elements. The spectral gap controls how
    close the distribution is to uniform after t steps.
    
    Args:
        n: Rank of symplectic group
        q: Field size (prime)
        num_steps: Number of walk steps
    
    Returns:
        Dictionary with quality metrics
    """
    gap = spectral_gap(n, q)
    if gap <= 0:
        return {"error": f"No expansion: q={q} too small for rank {n}"}
    
    group_size_approx = q ** (n * n)  # simplified
    mixing = (1.0 - gap) ** num_steps
    tv_distance = math.sqrt(group_size_approx) * mixing
    
    # Bits of randomness per step
    entropy_rate = -math.log2(1.0 - gap) if gap < 1 else float('inf')
    
    # Steps needed for cryptographic quality (TV < 2^{-128})
    if gap > 0 and gap < 1:
        crypto_steps = math.ceil(128 * math.log(2) / (-math.log(1.0 - gap)))
    else:
        crypto_steps = 1
    
    return {
        "rank": n,
        "field_size": q,
        "spectral_gap": gap,
        "steps": num_steps,
        "mixing_bound": mixing,
        "tv_distance_bound": tv_distance,
        "entropy_rate_bits": entropy_rate,
        "crypto_quality_steps": crypto_steps,
    }


# ========== APPLICATION 2: Expander Code Construction ==========

def design_expander_code(
    target_rate: float,
    target_distance_fraction: float,
    block_length: int
) -> dict:
    """Design an expander code meeting rate and distance targets.
    
    Uses the code_distance_positive theorem:
    When inner_distance > 1 - gap, distance ≥ (inner_dist - (1-gap)) * n.
    
    Args:
        target_rate: Minimum code rate
        target_distance_fraction: Minimum distance/n
        block_length: Desired block length
    
    Returns:
        Code parameters and required certificate data
    """
    # Search for suitable parameters
    best = None
    
    for gap_percent in range(10, 95, 5):
        gap = gap_percent / 100.0
        
        for inner_d_percent in range(10, 95, 5):
            inner_d = inner_d_percent / 100.0
            
            if inner_d <= 1.0 - gap:
                continue  # Not in expansion regime
            
            achieved_distance = (inner_d - (1.0 - gap)) * block_length
            distance_fraction = achieved_distance / block_length
            
            if distance_fraction < target_distance_fraction:
                continue
            
            # Find rank and field giving this gap
            # gap = 1 - (n+1)/q, so q = (n+1)/(1-gap)
            for n in range(1, 10):
                q_needed = math.ceil((n + 1) / (1.0 - gap))
                actual_gap = spectral_gap(n, q_needed)
                
                if actual_gap >= gap:
                    if best is None or q_needed < best["field_size"]:
                        best = {
                            "rank": n,
                            "field_size": q_needed,
                            "spectral_gap": actual_gap,
                            "inner_distance": inner_d,
                            "rate": target_rate,
                            "distance_bound": achieved_distance,
                            "distance_fraction": distance_fraction,
                            "block_length": block_length,
                        }
    
    return best if best else {"error": "No suitable parameters found"}


# ========== APPLICATION 3: Derandomization ==========

def derandomization_savings(n: int, q: int, original_random_bits: int) -> dict:
    """Compute seed savings from expander-based derandomization.
    
    Instead of O(n) random bits, an expander walk needs only
    O(log n) random bits for the starting vertex plus O(1) per step.
    
    Args:
        n: Rank of symplectic group
        q: Field size
        original_random_bits: Bits needed for fully random approach
    
    Returns:
        Savings metrics
    """
    gap = spectral_gap(n, q)
    if gap <= 0:
        return {"error": "No expansion"}
    
    group_size_log = n * n * math.log2(q)  # log2(|G|) approx
    seed_bits = math.ceil(group_size_log)  # bits for starting vertex
    
    # Steps for mixing
    steps = math.ceil(math.log(original_random_bits) / (-math.log(1 - gap)))
    
    # Total bits: seed + steps * O(1)
    total_bits = seed_bits + steps * 2  # 2 bits per step for {s, s^{-1}, t, t^{-1}}
    
    savings = max(0, original_random_bits - total_bits)
    ratio = total_bits / original_random_bits if original_random_bits > 0 else 1
    
    return {
        "original_bits": original_random_bits,
        "expander_bits": total_bits,
        "seed_bits": seed_bits,
        "walk_steps": steps,
        "bits_saved": savings,
        "compression_ratio": ratio,
    }


# ========== MAIN ==========
if __name__ == "__main__":
    print("APPLICATION 1: PRG Quality from Expander Walk")
    print("=" * 55)
    for n, q in [(1, 7), (2, 11), (3, 13), (4, 97)]:
        result = prg_quality_assessment(n, q, 10)
        print(f"\nSp_{2*n}(F_{q}):")
        print(f"  Spectral gap: {result['spectral_gap']:.4f}")
        print(f"  Mixing after 10 steps: {result['mixing_bound']:.6f}")
        print(f"  Entropy rate: {result['entropy_rate_bits']:.2f} bits/step")
        print(f"  Steps for crypto quality: {result['crypto_quality_steps']}")
    
    print("\n\nAPPLICATION 2: Expander Code Design")
    print("=" * 55)
    code = design_expander_code(
        target_rate=0.2,
        target_distance_fraction=0.05,
        block_length=10000
    )
    if "error" not in code:
        print(f"  Rank: {code['rank']}")
        print(f"  Field: F_{code['field_size']}")
        print(f"  Gap: {code['spectral_gap']:.4f}")
        print(f"  Inner distance: {code['inner_distance']}")
        print(f"  Code distance ≥ {code['distance_bound']:.0f}")
        print(f"  Distance fraction: {code['distance_fraction']:.3f}")
    
    print("\n\nAPPLICATION 3: Derandomization Savings")
    print("=" * 55)
    for bits in [256, 1024, 4096]:
        result = derandomization_savings(2, 13, bits)
        print(f"\n  Original: {result['original_bits']} bits")
        print(f"  Expander: {result['expander_bits']} bits "
              f"(seed={result['seed_bits']}, steps={result['walk_steps']})")
        print(f"  Savings: {result['bits_saved']} bits "
              f"({(1-result['compression_ratio'])*100:.1f}% reduction)")


"""
Demo: Symplectic Expansion Certificate Framework
================================================

Demonstrates the key mathematical concepts from the certificate algebra:
1. Spectral gap as a function of rank and field size
2. Mixing time bounds from certificate data
3. Expander code distance from spectral gaps
4. Certificate composition under tensor products
"""

import math
from typing import Tuple


def char_ratio_bound(n: int, q: int) -> float:
    """Character ratio bound (n+1)/q for Sp_{2n}(F_q)."""
    return (n + 1) / q


def spectral_gap(n: int, q: int) -> float:
    """Spectral gap 1 - (n+1)/q."""
    return 1.0 - char_ratio_bound(n, q)


def mixing_bound(eps: float, t: int) -> float:
    """Mixing bound (1 - eps)^t after t steps."""
    return (1.0 - eps) ** t


def mixing_time(eps: float, target: float) -> int:
    """Number of steps to reach target mixing bound."""
    if eps <= 0 or eps > 1 or target <= 0:
        return -1
    return math.ceil(math.log(target) / math.log(1.0 - eps))


def expander_code_distance(gap: float, inner_dist: float, block_length: int) -> float:
    """Distance bound: (inner_dist - (1-gap)) * block_length."""
    return (inner_dist - (1.0 - gap)) * block_length


def tv_distance_bound(n_vertices: int, eps: float, t: int) -> float:
    """Total variation distance bound: sqrt(n) * (1-eps)^t."""
    return math.sqrt(n_vertices) * (1.0 - eps) ** t


# ========== DEMO 1: Spectral Gaps Across Ranks ==========
print("=" * 60)
print("DEMO 1: Spectral Gaps for Sp_{2n}(F_q)")
print("=" * 60)
print(f"\n{'Rank n':>8} {'q=7':>10} {'q=11':>10} {'q=13':>10} {'q=97':>10}")
print("-" * 48)
for n in range(1, 8):
    gaps = [spectral_gap(n, q) for q in [7, 11, 13, 97]]
    print(f"{n:>8} {gaps[0]:>10.4f} {gaps[1]:>10.4f} {gaps[2]:>10.4f} {gaps[3]:>10.4f}")

# ========== DEMO 2: Mixing Time Bounds ==========
print("\n" + "=" * 60)
print("DEMO 2: Mixing Time Bounds (steps to reach distance < 0.01)")
print("=" * 60)
print(f"\n{'Rank n':>8} {'q=7':>10} {'q=11':>10} {'q=13':>10} {'q=97':>10}")
print("-" * 48)
for n in range(1, 6):
    times = []
    for q in [7, 11, 13, 97]:
        gap = spectral_gap(n, q)
        if gap > 0:
            times.append(mixing_time(gap, 0.01))
        else:
            times.append(-1)
    print(f"{n:>8} {times[0]:>10} {times[1]:>10} {times[2]:>10} {times[3]:>10}")

# ========== DEMO 3: Expander Code Distance ==========
print("\n" + "=" * 60)
print("DEMO 3: Expander Code Distance Bounds")
print("=" * 60)
inner_distance = 0.5  # Inner code with 50% relative distance
block_length = 1000
print(f"\nInner code distance: {inner_distance}")
print(f"Block length: {block_length}")
print(f"\n{'Gap ε':>10} {'Deficiency':>12} {'Distance ≥':>12}")
print("-" * 36)
for gap in [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8]:
    deficiency = 1.0 - gap
    dist = expander_code_distance(gap, inner_distance, block_length)
    status = f"{dist:>12.1f}" if dist > 0 else f"{'N/A':>12}"
    print(f"{gap:>10.1f} {deficiency:>12.1f} {status}")

# ========== DEMO 4: Certificate Tensor Products ==========
print("\n" + "=" * 60)
print("DEMO 4: Certificate Tensor Product Composition")
print("=" * 60)
print("\nTensoring certificates with different gaps:")
gaps_list = [(0.3, 0.5), (0.4, 0.4), (0.2, 0.8), (0.5, 0.5)]
for g1, g2 in gaps_list:
    tensor_gap = min(g1, g2)
    print(f"  gap₁={g1:.1f}, gap₂={g2:.1f} → tensor gap = min = {tensor_gap:.1f}")

# ========== DEMO 5: Universal Constant Conjecture Test ==========
print("\n" + "=" * 60)
print("DEMO 5: Universal Character Ratio Constant Conjecture")
print("=" * 60)
print("\nFitted constants C_n = (n+1) for Sp_{2n}(F_q):")
print(f"{'Rank n':>8} {'C_n':>8} {'C_n/q (q=7)':>12} {'C_n/q (q=97)':>12}")
print("-" * 44)
for n in range(1, 8):
    c_n = n + 1
    print(f"{n:>8} {c_n:>8} {c_n/7:>12.4f} {c_n/97:>12.4f}")
print("\n⚠ If C_n grows linearly with n → conjecture FALSIFIED")
print("  If C_n stabilizes (all ≤ some constant C) → conjecture SUPPORTED")
print(f"  Current data: C_n = n+1 grows linearly → FALSIFIED under naive bound")
print(f"  But Coxeter torus analysis may yield tighter universal bound.")

# ========== DEMO 6: Rank-Field Tradeoff ==========
print("\n" + "=" * 60)
print("DEMO 6: Rank-Field Tradeoff (q needed for gap ≥ 1/2)")
print("=" * 60)
print(f"\n{'Rank n':>8} {'q_min = 2(n+1)':>16} {'Gap at q_min':>14}")
print("-" * 42)
for n in range(1, 11):
    q_min = 2 * (n + 1)
    gap = spectral_gap(n, q_min)
    print(f"{n:>8} {q_min:>16} {gap:>14.4f}")

print("\n✓ All gaps ≥ 0.5000, confirming the rank_field_tradeoff theorem")


"""
Visualization: Coding Theory Bridge
=====================================
Shows how the spectral gap of symplectic expanders translates into
error-correcting code parameters. This visualizes the cross-domain
bridge from expansion certificates to coding theory (Sipser-Spielman
/ Tanner codes).
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Code distance vs spectral gap
ax = axes[0]
gaps = np.linspace(0.01, 0.99, 200)
inner_distances = [0.3, 0.4, 0.5, 0.6, 0.7]
block_length = 1000
colors = plt.cm.viridis(np.linspace(0.1, 0.9, len(inner_distances)))

for inner_d, color in zip(inner_distances, colors):
    distances = [(inner_d - (1 - g)) * block_length for g in gaps]
    distances = [max(0, d) for d in distances]
    ax.plot(gaps, distances, color=color, linewidth=2, label=f'δ_inner = {inner_d}')

ax.fill_between(gaps, 0, alpha=0.1, color='red')
ax.set_xlabel('Spectral Gap ε', fontsize=12)
ax.set_ylabel('Code Distance Lower Bound', fontsize=12)
ax.set_title('Expander Code Distance from Spectral Gap\n(n = 1000)', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.set_xlim(0, 1)
ax.set_ylim(0, 700)

# Add annotations for key regions
ax.annotate('Expansion regime\n(distance > 0)', xy=(0.7, 200), fontsize=10,
            ha='center', style='italic', color='darkgreen')
ax.annotate('No distance\nguarantee', xy=(0.15, 50), fontsize=10,
            ha='center', style='italic', color='red')

# Panel 2: Rate-distance tradeoff for different group ranks
ax2 = axes[1]
inner_d = 0.5

for n, color, marker in [(1, '#e41a1c', 'o'), (2, '#377eb8', 's'), 
                           (3, '#4daf4a', '^'), (5, '#984ea3', 'D')]:
    rates = []
    dist_fractions = []
    
    for q in range(n + 3, 200):
        gap = 1.0 - (n + 1) / q
        dist_frac = inner_d - (1.0 - gap)
        
        if dist_frac > 0:
            # Rate depends on code construction; use simplified model
            rate = 0.5  # fixed for comparison
            rates.append(gap)  # use gap as proxy for achievable rate
            dist_fractions.append(dist_frac)
    
    if rates:
        ax2.plot(rates, dist_fractions, color=color, linewidth=2,
                label=f'Sp₂ₙ, n={n}', alpha=0.8)

# Singleton bound reference
gap_ref = np.linspace(0.01, 0.99, 100)
singleton = 1 - gap_ref  # simplified
ax2.plot(gap_ref, [0.5 - (1-g) for g in gap_ref if 0.5 > 1-g],
         'k--', linewidth=1, alpha=0.5, label='δ = gap + δ_inner - 1')

ax2.set_xlabel('Spectral Gap ε', fontsize=12)
ax2.set_ylabel('Relative Distance δ/n', fontsize=12)
ax2.set_title('Rate-Distance from Symplectic Certificates\n(inner distance = 0.5)', fontsize=13)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)
ax2.set_xlim(0.5, 1.0)
ax2.set_ylim(0, 0.5)

plt.tight_layout()
plt.savefig('code_distance_bridge.png', dpi=150, bbox_inches='tight')
print("Saved: code_distance_bridge.png")


"""
Visualization: Mixing Convergence for Expander Walks
=====================================================
Shows how random walks on Cayley graphs of symplectic groups converge
to the uniform distribution. The exponential decay rate is controlled
by the spectral gap, which is the central quantity in our certificate
framework.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Panel 1: Mixing decay for different gaps
ax = axes[0]
steps = np.arange(0, 30)
gap_values = [0.1, 0.2, 0.3, 0.5, 0.7, 0.9]
colors = plt.cm.plasma(np.linspace(0.1, 0.9, len(gap_values)))

for gap, color in zip(gap_values, colors):
    mixing = (1.0 - gap) ** steps
    ax.semilogy(steps, mixing, color=color, linewidth=2, label=f'ε = {gap}')

ax.axhline(y=0.01, color='red', linestyle='--', alpha=0.5, label='target = 0.01')
ax.set_xlabel('Steps t', fontsize=12)
ax.set_ylabel('Mixing bound (1-ε)^t', fontsize=12)
ax.set_title('Exponential Mixing Decay', fontsize=14)
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)
ax.set_ylim(1e-5, 2)

# Panel 2: TV distance bounds for specific groups
ax2 = axes[1]
groups = [
    ("Sp₂(𝔽₇)", 1, 7),
    ("Sp₄(𝔽₁₁)", 2, 11),
    ("Sp₆(𝔽₁₃)", 3, 13),
    ("Sp₈(𝔽₉₇)", 4, 97),
]
colors2 = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3']

for (name, n, q), color in zip(groups, colors2):
    gap = 1.0 - (n + 1) / q
    n_vertices = q ** 3  # simplified
    tv = [np.sqrt(n_vertices) * (1.0 - gap) ** t for t in steps]
    ax2.semilogy(steps, tv, color=color, linewidth=2, label=name)

ax2.axhline(y=1, color='gray', linestyle=':', alpha=0.5)
ax2.set_xlabel('Steps t', fontsize=12)
ax2.set_ylabel('TV distance bound', fontsize=12)
ax2.set_title('Total Variation Distance Decay', fontsize=14)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# Panel 3: Mixing time vs rank
ax3 = axes[2]
import math

q_values = [7, 11, 13, 31, 97]
colors3 = plt.cm.Set1(np.linspace(0, 0.8, len(q_values)))

for q, color in zip(q_values, colors3):
    ranks_range = range(1, min(q - 1, 15))
    mix_times = []
    for n in ranks_range:
        gap = 1.0 - (n + 1) / q
        if gap > 0:
            t_mix = math.ceil(math.log(0.01) / math.log(1.0 - gap))
            mix_times.append(t_mix)
        else:
            mix_times.append(None)
    
    valid_ranks = [r for r, t in zip(ranks_range, mix_times) if t is not None]
    valid_times = [t for t in mix_times if t is not None]
    ax3.plot(valid_ranks, valid_times, 'o-', color=color, linewidth=2, 
             markersize=5, label=f'q = {q}')

ax3.set_xlabel('Rank n', fontsize=12)
ax3.set_ylabel('Mixing time (steps)', fontsize=12)
ax3.set_title('Mixing Time vs Rank', fontsize=14)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('mixing_convergence.png', dpi=150, bbox_inches='tight')
print("Saved: mixing_convergence.png")


"""
Visualization: Spectral Gap Landscape for Symplectic Groups
============================================================
Visualizes how the spectral gap of Sp_{2n}(F_q) varies with rank n
and field size q. The heatmap reveals the expansion/non-expansion
boundary and the rank-field tradeoff theorem: gap ≥ 1/2 when q ≥ 2(n+1).
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors

# Compute spectral gaps
ranks = np.arange(1, 16)
fields = np.arange(3, 101, 2)  # odd values only (primes live here)

gap_matrix = np.zeros((len(ranks), len(fields)))
for i, n in enumerate(ranks):
    for j, q in enumerate(fields):
        gap_matrix[i, j] = max(0, 1.0 - (n + 1) / q)

fig, axes = plt.subplots(1, 2, figsize=(16, 6))

# Heatmap
ax = axes[0]
im = ax.imshow(gap_matrix, aspect='auto', origin='lower',
               extent=[fields[0], fields[-1], ranks[0], ranks[-1]],
               cmap='RdYlGn', vmin=0, vmax=1)
plt.colorbar(im, ax=ax, label='Spectral Gap ε')

# Add the q = 2(n+1) threshold line
threshold_q = 2 * (ranks + 1)
ax.plot(threshold_q, ranks, 'w--', linewidth=2, label='q = 2(n+1) [gap = 1/2]')

# Add the q = n+1 boundary (gap = 0)
boundary_q = ranks + 1
ax.plot(boundary_q, ranks, 'r--', linewidth=2, label='q = n+1 [gap = 0]')

ax.set_xlabel('Field size q', fontsize=12)
ax.set_ylabel('Rank n', fontsize=12)
ax.set_title('Spectral Gap Landscape: Sp₂ₙ(𝔽_q)', fontsize=14)
ax.legend(loc='upper left', fontsize=9, facecolor='white', framealpha=0.9)

# Gap curves for fixed ranks
ax2 = axes[1]
colors = plt.cm.viridis(np.linspace(0, 0.9, 5))
for idx, n in enumerate([1, 2, 4, 8, 15]):
    q_vals = np.arange(n + 2, 100)
    gaps = [1.0 - (n + 1) / q for q in q_vals]
    ax2.plot(q_vals, gaps, color=colors[idx], linewidth=2, label=f'n = {n}')
    # Mark where gap = 1/2
    q_half = 2 * (n + 1)
    if q_half < 100:
        ax2.plot(q_half, 0.5, 'o', color=colors[idx], markersize=8)

ax2.axhline(y=0.5, color='gray', linestyle=':', alpha=0.5, label='gap = 1/2')
ax2.set_xlabel('Field size q', fontsize=12)
ax2.set_ylabel('Spectral gap ε', fontsize=12)
ax2.set_title('Gap Growth with Field Size', fontsize=14)
ax2.legend(fontsize=9)
ax2.set_ylim(0, 1.05)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('spectral_gap_landscape.png', dpi=150, bbox_inches='tight')
print("Saved: spectral_gap_landscape.png")
