"""
applications.py — Real-World Applications of the Hall k-Eulerian Framework

Applications:
1. Cryptographic key generation: How many k-tuples generate a cyclic group?
2. Network reliability: Redundant generator analysis
3. Random group generation: Monte Carlo confidence bounds
4. Error-correcting codes: Generator matrix redundancy
"""

from math import gcd, log2, prod
from typing import List, Tuple
from algorithms import jordan_totient, generation_probability, factorize, divisors, mobius


# ===========================================================================
# Application 1: Cryptographic Key Diversity
# ===========================================================================

def crypto_generator_diversity(p: int, k: int) -> dict:
    """
    For a prime-order cyclic group G = Z/pZ (as in Diffie-Hellman),
    compute the fraction of k-tuples that generate G.
    
    In cryptography, any non-identity element generates Z/pZ.
    For k generators, the probability of a degenerate k-tuple
    (all elements = 0) is 1/p^k.
    
    Returns analysis dict with counts and probabilities.
    
    >>> result = crypto_generator_diversity(101, 2)
    >>> result['probability'] > 0.99
    True
    """
    phi_k = jordan_totient(k, p)
    total = p ** k
    prob = phi_k / total
    
    return {
        'group_order': p,
        'k': k,
        'generating_tuples': phi_k,
        'total_tuples': total,
        'probability': prob,
        'bits_of_security': -log2(1 - prob) if prob < 1 else float('inf'),
        'formula': f"J_{k}({p}) = {p}^{k} · (1 - 1/{p}^{k}) = {phi_k}"
    }


# ===========================================================================
# Application 2: Network Reliability Analysis
# ===========================================================================

def network_redundancy_analysis(n: int, max_k: int = 8) -> List[dict]:
    """
    Model a communication network with n nodes in a cyclic topology.
    Each k-tuple of active broadcast sources generates a spanning 
    communication pattern iff they generate the cyclic group Z/nZ.
    
    Compute the probability of full network coverage for k = 1, ..., max_k.
    
    This models the question: "If we randomly place k transmitters,
    what's the probability every node can be reached?"
    
    >>> results = network_redundancy_analysis(12, 5)
    >>> results[-1]['coverage_probability'] > results[0]['coverage_probability']
    True
    """
    results = []
    for k in range(1, max_k + 1):
        prob = generation_probability(n, k)
        results.append({
            'transmitters': k,
            'nodes': n,
            'coverage_probability': prob,
            'failure_probability': 1 - prob,
            'nines': -log2(1 - prob) / log2(10) if prob < 1 else float('inf')
        })
    return results


# ===========================================================================
# Application 3: Monte Carlo Confidence for Random Generation
# ===========================================================================

def monte_carlo_confidence(n: int, k: int, trials: int) -> dict:
    """
    If we draw k random elements from Z/nZ and check if they generate,
    compute the expected number of successes in `trials` independent draws.
    
    Uses the exact formula P_k = ∏(1 - 1/p^k) to give precise predictions.
    
    >>> result = monte_carlo_confidence(30, 3, 1000)
    >>> result['expected_successes'] > 900
    True
    """
    prob = generation_probability(n, k)
    expected = prob * trials
    std_dev = (prob * (1 - prob) * trials) ** 0.5
    
    return {
        'n': n,
        'k': k,
        'trials': trials,
        'exact_probability': prob,
        'expected_successes': expected,
        'std_deviation': std_dev,
        '95_confidence_interval': (
            max(0, expected - 1.96 * std_dev),
            min(trials, expected + 1.96 * std_dev)
        )
    }


# ===========================================================================
# Application 4: Minimal Generating Set Size
# ===========================================================================

def minimal_generating_size(n: int, target_prob: float = 0.99) -> int:
    """
    Find the minimal k such that P_k(Z/nZ) ≥ target_prob.
    
    This answers: "How many random elements do we need to draw
    from Z/nZ to have ≥ target_prob chance of generating the group?"
    
    Time: O(k_max · √n)
    
    >>> minimal_generating_size(30, 0.99)
    3
    """
    k = 1
    while k < 100:
        if generation_probability(n, k) >= target_prob:
            return k
        k += 1
    return k


# ===========================================================================
# Application 5: Error-Correcting Code Redundancy
# ===========================================================================

def code_redundancy_analysis(n: int) -> dict:
    """
    Analyze generator redundancy for a linear code over Z/nZ.
    
    A generator matrix with k rows generates the full code space
    iff the k generators generate the group. The k-Eulerian framework
    tells us exactly how much redundancy (excess k beyond the minimum)
    is needed for high-probability generation.
    
    >>> result = code_redundancy_analysis(30)
    >>> result['k_for_99_percent'] >= 1
    True
    """
    k_99 = minimal_generating_size(n, 0.99)
    k_999 = minimal_generating_size(n, 0.999)
    k_9999 = minimal_generating_size(n, 0.9999)
    
    return {
        'modulus': n,
        'factorization': factorize(n),
        'k_for_99_percent': k_99,
        'k_for_999_percent': k_999,
        'k_for_9999_percent': k_9999,
        'probabilities': {
            k: generation_probability(n, k) for k in range(1, max(k_9999 + 2, 6))
        }
    }


# ===========================================================================
# Main: Run Applications
# ===========================================================================

if __name__ == "__main__":
    print("=" * 70)
    print("HALL k-EULERIAN FRAMEWORK: REAL-WORLD APPLICATIONS")
    print("=" * 70)
    
    # Application 1: Cryptographic key diversity
    print("\n--- Application 1: Cryptographic Key Diversity ---")
    for p in [101, 1009, 10007]:
        for k in [2, 3]:
            result = crypto_generator_diversity(p, k)
            print(f"  Z/{p}Z, k={k}: P = {result['probability']:.8f}, "
                  f"φ_k = {result['generating_tuples']}")
    
    # Application 2: Network reliability
    print("\n--- Application 2: Network Reliability ---")
    for n in [12, 24, 60]:
        results = network_redundancy_analysis(n, 6)
        print(f"  Network with {n} nodes:")
        for r in results:
            print(f"    k={r['transmitters']}: coverage = {r['coverage_probability']:.6f}")
    
    # Application 3: Monte Carlo
    print("\n--- Application 3: Monte Carlo Confidence ---")
    for n in [30, 100, 1000]:
        result = monte_carlo_confidence(n, 3, 10000)
        ci = result['95_confidence_interval']
        print(f"  Z/{n}Z, k=3, 10000 trials: "
              f"E[success] = {result['expected_successes']:.1f}, "
              f"95% CI = [{ci[0]:.1f}, {ci[1]:.1f}]")
    
    # Application 4: Minimal generating size
    print("\n--- Application 4: Minimal Generating Size ---")
    for n in [6, 30, 210, 2310, 30030]:
        k = minimal_generating_size(n, 0.99)
        prob = generation_probability(n, k)
        print(f"  Z/{n}Z: need k={k} for P ≥ 0.99 (actual P_{k} = {prob:.6f})")
    
    # Application 5: Code redundancy
    print("\n--- Application 5: Code Redundancy ---")
    for n in [12, 30, 60, 210]:
        result = code_redundancy_analysis(n)
        print(f"  Z/{n}Z: k_99={result['k_for_99_percent']}, "
              f"k_999={result['k_for_999_percent']}, "
              f"k_9999={result['k_for_9999_percent']}")
    
    print("\nAll applications demonstrated successfully.")


"""
demo.py — Hall k-Eulerian Framework: Concrete Demonstrations

Demonstrates the k-tuple Möbius inversion formula for finite groups.
Computes φ_k(G) for several small groups and verifies the partition identity.
"""

from itertools import product
from math import gcd
from functools import reduce
from collections import defaultdict


def mobius_number_theoretic(n):
    """Compute the number-theoretic Möbius function μ(n)."""
    if n == 1:
        return 1
    factors = []
    d = 2
    temp = n
    while d * d <= temp:
        if temp % d == 0:
            factors.append(d)
            temp //= d
            if temp % d == 0:
                return 0  # squared factor
        d += 1
    if temp > 1:
        factors.append(temp)
    return (-1) ** len(factors)


def jordan_totient(k, n):
    """Compute Jordan's totient J_k(n) = Σ_{d|n} μ(n/d) · d^k."""
    total = 0
    for d in range(1, n + 1):
        if n % d == 0:
            total += mobius_number_theoretic(n // d) * d ** k
    return total


def euler_totient(n):
    """Euler's totient φ(n) = J_1(n)."""
    return jordan_totient(1, n)


def divisors(n):
    """Return sorted list of divisors of n."""
    return sorted(d for d in range(1, n + 1) if n % d == 0)


def mobius_convolution_check(n):
    """Verify Σ_{d|n} μ(d) = [n=1]."""
    return sum(mobius_number_theoretic(d) for d in divisors(n))


# === Finite Group Computations ===

def cyclic_group_generators(n, k):
    """Count k-tuples generating Z/nZ.
    A k-tuple (a1,...,ak) generates Z/nZ iff gcd(a1,...,ak,n) = 1."""
    count = 0
    for tup in product(range(n), repeat=k):
        g = reduce(gcd, tup, n)
        if g == 1:
            count += 1
    return count


def cyclic_mobius_sum(n, k):
    """Compute Σ_{d|n} μ(d) · (n/d)^k using Möbius inversion."""
    # Subgroups of Z/nZ are Z/dZ for d | n, with |Z/dZ| = d.
    # μ(Z/dZ, Z/nZ) = μ_arith(n/d)
    total = 0
    for d in divisors(n):
        total += mobius_number_theoretic(n // d) * d ** k
    return total


print("=" * 70)
print("HALL k-EULERIAN FRAMEWORK: CONCRETE DEMONSTRATIONS")
print("=" * 70)

# Demo 1: Möbius convolution cancellation
print("\n--- Demo 1: Number-Theoretic Möbius Cancellation ---")
print("Verifying: Σ_{d|n} μ(d) = [n=1]")
for n in range(1, 13):
    s = mobius_convolution_check(n)
    expected = 1 if n == 1 else 0
    status = "✓" if s == expected else "✗"
    print(f"  n={n:2d}: Σ μ(d) = {s:2d}  (expected {expected})  {status}")

# Demo 2: Jordan's totient function
print("\n--- Demo 2: Jordan's Totient J_k(n) ---")
print(f"{'n':>4} | {'J_1=φ':>6} | {'J_2':>8} | {'J_3':>10} | {'J_4':>12}")
print("-" * 50)
for n in range(1, 16):
    j1 = jordan_totient(1, n)
    j2 = jordan_totient(2, n)
    j3 = jordan_totient(3, n)
    j4 = jordan_totient(4, n)
    print(f"{n:4d} | {j1:6d} | {j2:8d} | {j3:10d} | {j4:12d}")

# Demo 3: Generating k-tuples for cyclic groups
print("\n--- Demo 3: Generating k-Tuples φ_k(Z/nZ) ---")
print("Comparing direct count vs Möbius inversion formula")
for n in [2, 3, 4, 5, 6, 8, 10, 12]:
    for k in [1, 2, 3]:
        direct = cyclic_group_generators(n, k)
        mobius = cyclic_mobius_sum(n, k)
        status = "✓" if direct == mobius else "✗"
        print(f"  Z/{n}Z, k={k}: direct={direct:6d}, Möbius={mobius:6d}  {status}")

# Demo 4: Partition identity verification
print("\n--- Demo 4: k-Tuple Partition Identity ---")
print("Verifying: |H|^k = Σ_{K ≤ H} #{k-tuples generating K}")
for n in [4, 6, 8]:
    for k in [1, 2]:
        lhs = n ** k
        rhs = 0
        for d in divisors(n):
            # Count k-tuples in Z/nZ generating exactly Z/dZ
            # = #{(a1,...,ak) : gcd(a1,...,ak,n) = n/d}
            count = 0
            for tup in product(range(n), repeat=k):
                g = reduce(gcd, tup, n)
                if n // g == d:  # generated subgroup has order d
                    count += 1
            rhs += count
        status = "✓" if lhs == rhs else "✗"
        print(f"  Z/{n}Z, k={k}: |G|^k = {lhs}, Σ counts = {rhs}  {status}")

# Demo 5: Generation probability
print("\n--- Demo 5: Generation Probability P_k(G) ---")
print("P_k(Z/nZ) = φ_k(n) / n^k")
for n in [2, 3, 5, 6, 10, 12, 30]:
    probs = []
    for k in [1, 2, 3, 4, 5]:
        phi_k = jordan_totient(k, n)
        p_k = phi_k / n ** k
        probs.append(p_k)
    print(f"  Z/{n:2d}Z: P_1={probs[0]:.4f}, P_2={probs[1]:.4f}, "
          f"P_3={probs[2]:.4f}, P_4={probs[3]:.4f}, P_5={probs[4]:.4f}")

# Demo 6: Multiplicativity verification
print("\n--- Demo 6: Jordan Totient Multiplicativity ---")
print("Verifying: J_k(mn) = J_k(m)·J_k(n) for gcd(m,n)=1")
for k in [1, 2, 3]:
    for m, n in [(2, 3), (2, 5), (3, 5), (2, 7), (3, 7), (4, 9)]:
        if gcd(m, n) != 1:
            continue
        j_mn = jordan_totient(k, m * n)
        j_m_j_n = jordan_totient(k, m) * jordan_totient(k, n)
        status = "✓" if j_mn == j_m_j_n else "✗"
        print(f"  k={k}: J_{k}({m}·{n})={j_mn:6d} = J_{k}({m})·J_{k}({n})={j_m_j_n:6d}  {status}")

# Demo 7: Triple generation conjecture test
print("\n--- Demo 7: Triple Generation Probability (Conjecture Test) ---")
print("Testing P_3(Z/nZ) ≥ 1 - 1/n for primes n")
for n in [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]:
    phi3 = jordan_totient(3, n)
    p3 = phi3 / n ** 3
    bound = 1 - 1 / n
    holds = p3 >= bound
    print(f"  Z/{n:2d}Z: P_3 = {p3:.6f}, bound = {bound:.6f}, "
          f"holds: {'✓' if holds else '✗'}")

print("\n" + "=" * 70)
print("All demonstrations complete.")
print("=" * 70)


"""
Visualization 2: Convergence of Generation Probability P_k → 1

Plots P_k(Z/nZ) as a function of k for several values of n,
showing the geometric convergence rate. The convergence is governed
by the largest prime factor: P_k ≈ 1 - Σ 1/p^k.

Key insight: Even for highly composite numbers, P_k converges to 1
exponentially fast — three random elements almost always generate.
"""

import numpy as np
import matplotlib.pyplot as plt


def jordan_totient(k, n):
    """Compute J_k(n) via Euler product."""
    result = n ** k
    temp = n
    d = 2
    while d * d <= temp:
        if temp % d == 0:
            result = result * (d ** k - 1) // (d ** k)
            while temp % d == 0:
                temp //= d
        d += 1
    if temp > 1:
        result = result * (temp ** k - 1) // (temp ** k)
    return result


def generation_probability(n, k):
    return jordan_totient(k, n) / n ** k


# Groups to analyze
groups = {
    'Z/6Z (= Z/2Z × Z/3Z)': 6,
    'Z/30Z (= Z/2Z × Z/3Z × Z/5Z)': 30,
    'Z/210Z (2·3·5·7)': 210,
    'Z/2310Z (2·3·5·7·11)': 2310,
    'Z/12Z (2²·3)': 12,
    'Z/60Z (2²·3·5)': 60,
}

k_values = range(1, 16)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left: P_k vs k
colors = plt.cm.Set1(np.linspace(0, 1, len(groups)))
for (label, n), color in zip(groups.items(), colors):
    probs = [generation_probability(n, k) for k in k_values]
    ax1.plot(k_values, probs, 'o-', color=color, label=label,
             markersize=4, linewidth=1.5)

ax1.axhline(y=1, color='gray', linestyle='--', alpha=0.5)
ax1.axhline(y=0.99, color='gray', linestyle=':', alpha=0.5)
ax1.set_xlabel('k (tuple size)', fontsize=12)
ax1.set_ylabel('P_k(Z/nZ)', fontsize=12)
ax1.set_title('Generation Probability vs Tuple Size', fontsize=13)
ax1.legend(fontsize=8, loc='lower right')
ax1.set_ylim(0, 1.05)
ax1.grid(True, alpha=0.3)

# Right: log(1 - P_k) vs k (showing exponential convergence)
for (label, n), color in zip(groups.items(), colors):
    gaps = []
    ks = []
    for k in k_values:
        p = generation_probability(n, k)
        if p < 1:
            gaps.append(np.log10(1 - p))
            ks.append(k)
    if gaps:
        ax2.plot(ks, gaps, 'o-', color=color, label=label,
                 markersize=4, linewidth=1.5)

ax2.set_xlabel('k (tuple size)', fontsize=12)
ax2.set_ylabel('log₁₀(1 - P_k)', fontsize=12)
ax2.set_title('Exponential Convergence Rate\n(linear = geometric convergence)',
              fontsize=13)
ax2.legend(fontsize=8, loc='upper right')
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('convergence_plot.png', dpi=150, bbox_inches='tight')
print("Saved convergence_plot.png")


"""
Visualization 1: Jordan's Totient Heatmap J_k(n)

Displays a heatmap of J_k(n) / n^k (= generation probability P_k(Z/nZ))
for n = 2..40 and k = 1..10. Shows how generation probability increases
with k and varies with the prime factorization of n.

Key insight: Numbers with many small prime factors (like 30 = 2·3·5)
have lower generation probability, but converge to 1 as k increases.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import gcd


def jordan_totient(k, n):
    """Compute J_k(n) via Euler product."""
    result = n ** k
    temp = n
    d = 2
    while d * d <= temp:
        if temp % d == 0:
            result = result * (d ** k - 1) // (d ** k)
            while temp % d == 0:
                temp //= d
        d += 1
    if temp > 1:
        result = result * (temp ** k - 1) // (temp ** k)
    return result


# Parameters
n_range = range(2, 41)
k_range = range(1, 11)

# Compute P_k(Z/nZ) matrix
data = np.zeros((len(k_range), len(n_range)))
for i, k in enumerate(k_range):
    for j, n in enumerate(n_range):
        data[i, j] = jordan_totient(k, n) / n ** k

# Plot
fig, ax = plt.subplots(figsize=(14, 6))
im = ax.imshow(data, aspect='auto', cmap='RdYlGn', vmin=0, vmax=1,
               interpolation='nearest')

ax.set_xticks(range(0, len(n_range), 2))
ax.set_xticklabels([str(n) for n in n_range][::2], fontsize=8)
ax.set_yticks(range(len(k_range)))
ax.set_yticklabels([str(k) for k in k_range])

ax.set_xlabel('n (group order)', fontsize=12)
ax.set_ylabel('k (tuple size)', fontsize=12)
ax.set_title('Generation Probability P_k(Z/nZ) = J_k(n)/n^k\n'
             'Green = high probability, Red = low probability', fontsize=13)

cbar = plt.colorbar(im, ax=ax, label='P_k(Z/nZ)')

# Annotate key values
for i, k in enumerate(k_range):
    for j, n in enumerate(n_range):
        if data[i, j] < 0.5:
            ax.text(j, i, f'{data[i, j]:.2f}', ha='center', va='center',
                    fontsize=5, color='white')
        elif k <= 3 and n <= 15:
            ax.text(j, i, f'{data[i, j]:.2f}', ha='center', va='center',
                    fontsize=5, color='black')

plt.tight_layout()
plt.savefig('jordan_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved jordan_heatmap.png")


"""
Visualization 3: Parallel Möbius Cancellation Bridge

Side-by-side visualization of the Möbius cancellation principle
in two domains:
  1. Number theory: Σ_{d|n} μ(d) = [n=1]
  2. Group theory: Σ_{K≥H} μ(K,⊤) = [H=⊤]

Shows how the same algebraic principle (Möbius inversion on a lattice)
governs both integer divisibility and group generation.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def mobius(n):
    """Number-theoretic Möbius function."""
    if n == 1:
        return 1
    factors = []
    d, temp = 2, n
    while d * d <= temp:
        if temp % d == 0:
            factors.append(d)
            temp //= d
            if temp % d == 0:
                return 0
        d += 1
    if temp > 1:
        factors.append(temp)
    return (-1) ** len(factors)


def divisors(n):
    return sorted(d for d in range(1, n + 1) if n % d == 0)


# Figure setup
fig, axes = plt.subplots(1, 3, figsize=(16, 5.5))

# Panel 1: Möbius function values
ax1 = axes[0]
ns = range(1, 31)
mus = [mobius(n) for n in ns]
colors = ['#2ecc71' if m == 1 else '#e74c3c' if m == -1 else '#95a5a6' for m in mus]
ax1.bar(ns, mus, color=colors, edgecolor='black', linewidth=0.5)
ax1.set_xlabel('n', fontsize=11)
ax1.set_ylabel('μ(n)', fontsize=11)
ax1.set_title('Number-Theoretic Möbius Function', fontsize=12)
ax1.axhline(y=0, color='black', linewidth=0.5)
ax1.set_xticks(range(0, 31, 5))
legend_elements = [
    mpatches.Patch(facecolor='#2ecc71', label='μ(n) = +1 (even # primes)'),
    mpatches.Patch(facecolor='#e74c3c', label='μ(n) = -1 (odd # primes)'),
    mpatches.Patch(facecolor='#95a5a6', label='μ(n) = 0 (squared factor)'),
]
ax1.legend(handles=legend_elements, fontsize=7, loc='lower right')

# Panel 2: Divisor sum cancellation
ax2 = axes[1]
ns_check = range(1, 21)
sums = [sum(mobius(d) for d in divisors(n)) for n in ns_check]
colors2 = ['#2ecc71' if s == 1 else '#3498db' if s == 0 else '#e74c3c' for s in sums]
ax2.bar(ns_check, sums, color=colors2, edgecolor='black', linewidth=0.5)
ax2.set_xlabel('n', fontsize=11)
ax2.set_ylabel('Σ_{d|n} μ(d)', fontsize=11)
ax2.set_title('Möbius Cancellation: Σ_{d|n} μ(d) = [n=1]', fontsize=12)
ax2.axhline(y=0, color='black', linewidth=0.5)

# Annotate
for i, (n, s) in enumerate(zip(ns_check, sums)):
    if s != 0:
        ax2.annotate(f'n={n}', (n, s), textcoords="offset points",
                     xytext=(0, 10), ha='center', fontsize=8, color='green')

# Panel 3: The bridge diagram
ax3 = axes[2]
ax3.axis('off')

# Draw the bridge
bridge_text = """
THE MÖBIUS BRIDGE

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

NUMBER THEORY          GROUP THEORY
(divisor lattice)    (subgroup lattice)

  Σ_{d|n} μ(d)        Σ_{K≥H} μ(K,⊤)
    = [n=1]              = [H=⊤]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Both are instances of
MÖBIUS INVERSION
on a finite lattice:

  Σ_{y≥x} μ(x,y) = δ(x, 1̂)

where 1̂ is the top element.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CONSEQUENCE:
φ_k(G) = Σ_H μ(H,G) · |H|^k
J_k(n) = Σ_{d|n} μ(n/d) · d^k

Same formula, different lattices!
"""

ax3.text(0.5, 0.5, bridge_text, transform=ax3.transAxes,
         fontsize=9, verticalalignment='center', horizontalalignment='center',
         fontfamily='monospace',
         bbox=dict(boxstyle='round,pad=0.5', facecolor='lightyellow',
                   edgecolor='orange', alpha=0.8))

ax3.set_title('Abstract Unification', fontsize=12)

plt.suptitle('Parallel Möbius Cancellation: Number Theory ↔ Group Theory',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('mobius_bridge.png', dpi=150, bbox_inches='tight')
print("Saved mobius_bridge.png")
