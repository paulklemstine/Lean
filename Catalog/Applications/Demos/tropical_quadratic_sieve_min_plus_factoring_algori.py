#!/usr/bin/env python3
"""
Tropical Quadratic Sieve: Real-World Applications

Demonstrates applications of tropical smoothness cost theory to:
1. Factoring small composites via tropical QS
2. Adaptive factor base design using monotonicity
3. Relation scoring and candidate filtering
4. Cryptographic security estimation
"""

import math
from typing import Dict, Set, List, Tuple
from collections import defaultdict


def factorize(n: int) -> Dict[int, int]:
    """Prime factorization of n."""
    if n <= 1:
        return {}
    factors: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def smooth_cost(P: Set[int], n: int) -> float:
    """Tropical smoothness cost."""
    if n == 0:
        return float('inf')
    factors = factorize(n)
    return sum(e for p, e in factors.items() if p not in P)


def primes_up_to(B: int) -> List[int]:
    """Sieve of Eratosthenes."""
    if B < 2:
        return []
    sieve = [True] * (B + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(B**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, B + 1, i):
                sieve[j] = False
    return [i for i in range(2, B + 1) if sieve[i]]


def gcd(a: int, b: int) -> int:
    """Greatest common divisor."""
    while b:
        a, b = b, a % b
    return a


# ============================================================
# Application 1: Factor a composite via tropical QS
# ============================================================

def tropical_factor(N: int, B: int = 50, R_half: int = 2000) -> Tuple[int, int]:
    """
    Factor N using tropical quadratic sieve.

    Uses smooth cost = 0 detection (Theorem 1) for relation collection,
    then combines relations via GF(2) linear algebra.

    This is a simplified version for demonstration — full QS uses
    more sophisticated linear algebra and large-prime variations.
    """
    if N % 2 == 0:
        return (2, N // 2)

    P_primes = [p for p in primes_up_to(B)
                if p == 2 or pow(N % p, (p - 1) // 2, p) <= 1]
    P = set(P_primes)

    sqrt_N = int(math.isqrt(N))
    if sqrt_N * sqrt_N < N:
        sqrt_N += 1

    # Collect smooth relations using tropical cost = 0 criterion
    relations = []
    for x in range(sqrt_N, sqrt_N + R_half + 1):
        Q = x * x - N
        if Q <= 0:
            continue
        if smooth_cost(P, Q) == 0:
            relations.append((x, Q, factorize(Q)))

    # Try to find a non-trivial factor from pairs of relations
    # Simple approach: look for pairs whose product is a perfect square
    for i in range(len(relations)):
        for j in range(i + 1, len(relations)):
            x1, q1, f1 = relations[i]
            x2, q2, f2 = relations[j]

            # Combine exponent vectors
            combined: Dict[int, int] = defaultdict(int)
            for p, e in f1.items():
                combined[p] += e
            for p, e in f2.items():
                combined[p] += e

            # Check if all exponents are even
            if all(e % 2 == 0 for e in combined.values()):
                # q1 * q2 is a perfect square
                y_sq = q1 * q2
                y = int(math.isqrt(y_sq))
                if y * y == y_sq:
                    x_prod = (x1 * x2) % N
                    g = gcd(abs(x_prod - y), N)
                    if 1 < g < N:
                        return (g, N // g)

    # Try combining three relations
    for i in range(len(relations)):
        for j in range(i + 1, min(len(relations), i + 20)):
            x1, q1, f1 = relations[i]
            x2, q2, f2 = relations[j]
            combined_ij: Dict[int, int] = defaultdict(int)
            for p, e in f1.items():
                combined_ij[p] += e
            for p, e in f2.items():
                combined_ij[p] += e
            # Find what's needed
            needed = {p: e % 2 for p, e in combined_ij.items() if e % 2 != 0}
            if not needed:
                continue
            for k in range(j + 1, len(relations)):
                x3, q3, f3 = relations[k]
                combined = dict(combined_ij)
                for p, e in f3.items():
                    combined[p] = combined.get(p, 0) + e
                if all(e % 2 == 0 for e in combined.values()):
                    y_sq = q1 * q2 * q3
                    y = int(math.isqrt(y_sq))
                    if y * y == y_sq:
                        x_prod = (x1 * x2 * x3) % N
                        g = gcd(abs(x_prod - y), N)
                        if 1 < g < N:
                            return (g, N // g)

    return (N, 1)  # Failed


# ============================================================
# Application 2: Adaptive Factor Base Design
# ============================================================

def adaptive_factor_base(N: int, target_smooth: int = 20, R_half: int = 500) -> Set[int]:
    """
    Design an optimal factor base using tropical cost monotonicity (Theorem 3).

    Greedy algorithm: iteratively add the prime that maximally reduces
    total smooth cost across the sieve interval. By Theorem 3, each
    addition is guaranteed to not increase any individual cost.
    """
    sqrt_N = int(math.isqrt(N))
    if sqrt_N * sqrt_N < N:
        sqrt_N += 1

    # Compute Q_N values
    Q_values = []
    for x in range(sqrt_N, sqrt_N + R_half + 1):
        Q = x * x - N
        if Q > 0:
            Q_values.append(Q)

    candidates = primes_up_to(100)
    P: Set[int] = set()

    print(f"  Starting adaptive factor base design for N={N}")
    print(f"  Sieve interval size: {len(Q_values)}")

    for step in range(15):
        best_prime = None
        best_reduction = 0
        best_smooth_count = 0

        for p in candidates:
            if p in P:
                continue
            P_new = P | {p}
            reduction = sum(smooth_cost(P, q) - smooth_cost(P_new, q)
                           for q in Q_values[:200])  # Sample for speed
            sc = sum(1 for q in Q_values if smooth_cost(P_new, q) == 0)
            if reduction > best_reduction:
                best_reduction = reduction
                best_prime = p
                best_smooth_count = sc

        if best_prime is None:
            break

        P.add(best_prime)
        smooth_count = sum(1 for q in Q_values if smooth_cost(P, q) == 0)
        print(f"  Step {step+1}: Added prime {best_prime:>3}, "
              f"smooth relations: {smooth_count:>4}, "
              f"cost reduction: {best_reduction:.0f}")

        if smooth_count >= target_smooth:
            break

    return P


# ============================================================
# Application 3: Cryptographic Security Estimation
# ============================================================

def estimate_qs_security(key_bits: int) -> Dict[str, float]:
    """
    Estimate the security of an RSA key against quadratic sieve attack.

    Uses the tropical framework to compute:
    - Optimal factor base size B
    - Expected sieve interval size R
    - Total tropical kernel work R × B
    - Estimated operations (using L-notation)
    """
    N_log = key_bits * math.log(2)
    N_loglog = math.log(N_log)

    # Classical QS parameters
    # B ≈ exp(√(log N · log log N))
    # R ≈ exp(√(log N · log log N))
    L = math.exp(math.sqrt(N_log * N_loglog))

    B_optimal = L
    R_optimal = L

    # Tropical kernel work = R × B (Theorem: complexity transport)
    kernel_work = R_optimal * B_optimal

    # Convert to log2 for interpretability
    log2_work = math.log2(kernel_work)

    return {
        "key_bits": key_bits,
        "optimal_B": B_optimal,
        "optimal_R": R_optimal,
        "kernel_work_log2": log2_work,
        "L_exponent": math.sqrt(N_log * N_loglog) / N_log,
        "classical_equivalent": log2_work,
    }


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("=" * 70)
    print("TROPICAL QUADRATIC SIEVE: APPLICATIONS")
    print("=" * 70)

    # Application 1: Factor composites
    print("\n--- Application 1: Tropical Factoring ---")
    test_composites = [
        (143, "Small"),
        (1073, "Medium"),
        (10403, "Larger"),
        (15347, "Demo value"),
        (100127, "5-digit"),
    ]

    for N, label in test_composites:
        p, q = tropical_factor(N, B=50, R_half=3000)
        status = "✓" if p * q == N and p > 1 and q > 1 else "✗"
        print(f"  {label:>10}: N = {N:>7} = {p} × {q}  {status}")

    # Application 2: Adaptive factor base
    print("\n--- Application 2: Adaptive Factor Base Design ---")
    P_opt = adaptive_factor_base(15347, target_smooth=15, R_half=500)
    print(f"  Final factor base: {sorted(P_opt)}")

    # Application 3: Security estimation
    print("\n--- Application 3: RSA Security vs Tropical QS ---")
    print(f"  {'Key bits':>10} | {'B (optimal)':>15} | {'R (optimal)':>15} | {'Work (log₂)':>12} | {'Security':>10}")
    print("  " + "-" * 70)
    for bits in [512, 768, 1024, 2048, 3072, 4096]:
        est = estimate_qs_security(bits)
        security = "BROKEN" if est["kernel_work_log2"] < 80 else (
            "WEAK" if est["kernel_work_log2"] < 128 else "SECURE")
        print(f"  {bits:>10} | {est['optimal_B']:>15.2e} | {est['optimal_R']:>15.2e} | "
              f"{est['kernel_work_log2']:>12.1f} | {security:>10}")

    print("\n  Note: The tropical kernel work R×B matches the classical QS work")
    print("  by the complexity transport theorem (Theorem 5).")

    # Application 4: Smooth number distribution
    print("\n--- Application 4: Smooth Number Distribution ---")
    for B in [5, 10, 20, 50]:
        P = set(primes_up_to(B))
        counts = {}
        for N_bound in [100, 1000, 10000]:
            count = sum(1 for n in range(1, N_bound + 1) if smooth_cost(P, n) == 0)
            counts[N_bound] = count

        print(f"  B={B:>3}: ", end="")
        for N_bound, count in counts.items():
            pct = 100 * count / N_bound
            print(f"Ψ({N_bound},{B})={count:>5} ({pct:>5.1f}%)  ", end="")
        print()

    print("\n" + "=" * 70)
    print("All applications completed.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Quadratic Sieve: Demonstration of Core Theorems

This script demonstrates the three main theorems with concrete numerical examples:
1. smoothCost = 0 ↔ B-smooth (Theorem 1)
2. smoothCost(a*b) = smoothCost(a) + smoothCost(b) (Theorem 2)
3. smoothCost monotonicity under factor base enlargement (Theorem 3)
"""

from collections import Counter
from typing import Dict, Set, Optional
import math


def factorize(n: int) -> Dict[int, int]:
    """Return prime factorization of n as {prime: exponent}."""
    if n <= 1:
        return {}
    factors: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def smooth_cost(P: Set[int], n: int) -> Optional[int]:
    """
    Compute the tropical smoothness cost of n relative to factor base P.
    Returns None for n=0 (representing ⊤), otherwise the sum of valuations
    at primes outside P.
    """
    if n == 0:
        return None  # ⊤
    factors = factorize(n)
    return sum(e for p, e in factors.items() if p not in P)


def is_bsmooth(P: Set[int], n: int) -> bool:
    """Check if n is P-smooth (all prime factors in P)."""
    if n <= 0:
        return False
    factors = factorize(n)
    return all(p in P for p in factors)


# ============================================================
# Demo 1: Theorem 1 — smoothCost = 0 ↔ B-smooth
# ============================================================
print("=" * 70)
print("THEOREM 1: smoothCost(P, n) = 0 ↔ n is P-smooth")
print("=" * 70)

P = {2, 3, 5, 7}
print(f"\nFactor base P = {P}")
print(f"\n{'n':>6} | {'factorization':>20} | {'smoothCost':>10} | {'P-smooth?':>9} | {'Match?':>6}")
print("-" * 70)

test_numbers = [1, 2, 6, 12, 30, 42, 60, 77, 100, 210, 360, 385, 1000, 2310]
for n in test_numbers:
    factors = factorize(n)
    factor_str = " × ".join(f"{p}^{e}" if e > 1 else str(p) for p, e in sorted(factors.items()))
    if not factor_str:
        factor_str = "1"
    cost = smooth_cost(P, n)
    smooth = is_bsmooth(P, n)
    match = (cost == 0) == smooth
    print(f"{n:>6} | {factor_str:>20} | {cost:>10} | {str(smooth):>9} | {'✓' if match else '✗':>6}")

# Count smooth numbers
smooth_count = sum(1 for n in range(1, 1001) if smooth_cost(P, n) == 0)
print(f"\nNumbers in [1, 1000] with smoothCost = 0: {smooth_count}")
print(f"Numbers in [1, 1000] that are {P}-smooth: {sum(1 for n in range(1, 1001) if is_bsmooth(P, n))}")

# ============================================================
# Demo 2: Theorem 2 — Multiplicative Additivity
# ============================================================
print("\n" + "=" * 70)
print("THEOREM 2: smoothCost(P, a·b) = smoothCost(P, a) + smoothCost(P, b)")
print("=" * 70)

P = {2, 3, 5}
print(f"\nFactor base P = {P}")
print(f"\n{'a':>5} | {'b':>5} | {'a*b':>8} | {'cost(a)':>7} | {'cost(b)':>7} | {'cost(a*b)':>9} | {'sum':>5} | {'Equal?':>6}")
print("-" * 70)

pairs = [(6, 10), (7, 11), (12, 35), (30, 77), (1, 100), (8, 27), (13, 17), (100, 100)]
for a, b in pairs:
    ca = smooth_cost(P, a)
    cb = smooth_cost(P, b)
    cab = smooth_cost(P, a * b)
    s = ca + cb
    print(f"{a:>5} | {b:>5} | {a*b:>8} | {ca:>7} | {cb:>7} | {cab:>9} | {s:>5} | {'✓' if cab == s else '✗':>6}")

# Exhaustive verification
print("\nExhaustive verification for a, b ∈ [1, 100]...")
violations = 0
for a in range(1, 101):
    for b in range(1, 101):
        if smooth_cost(P, a * b) != smooth_cost(P, a) + smooth_cost(P, b):
            violations += 1
print(f"Violations: {violations} / 10000")

# ============================================================
# Demo 3: Theorem 3 — Factor Base Monotonicity
# ============================================================
print("\n" + "=" * 70)
print("THEOREM 3: P ⊆ Q ⟹ smoothCost(Q, n) ≤ smoothCost(P, n)")
print("=" * 70)

bases = [
    {2},
    {2, 3},
    {2, 3, 5},
    {2, 3, 5, 7},
    {2, 3, 5, 7, 11},
    {2, 3, 5, 7, 11, 13},
]

test_ns = [60, 77, 210, 385, 1001, 2310, 5005]
print(f"\n{'n':>6}", end="")
for P in bases:
    label = ",".join(str(p) for p in sorted(P))
    print(f" | P={{{label}}}".rjust(16), end="")
print()
print("-" * (6 + 16 * len(bases) + len(bases) * 3))

for n in test_ns:
    print(f"{n:>6}", end="")
    prev_cost = float('inf')
    for P in bases:
        cost = smooth_cost(P, n)
        arrow = "≤" if cost <= prev_cost else "!!"
        print(f" | {cost:>10} {arrow:>3}", end="")
        prev_cost = cost
    print()

# Exhaustive monotonicity check
print("\nExhaustive monotonicity check for n ∈ [1, 5000]...")
mono_violations = 0
for n in range(1, 5001):
    costs = [smooth_cost(P, n) for P in bases]
    for i in range(len(costs) - 1):
        if costs[i + 1] > costs[i]:
            mono_violations += 1
print(f"Monotonicity violations: {mono_violations}")

# ============================================================
# Demo 4: No-Go Theorem — Idempotent groups are trivial
# ============================================================
print("\n" + "=" * 70)
print("THEOREM 4: Idempotent additive group ⟹ trivial")
print("=" * 70)
print("\nIf a + a = a for all a in a group G, then a = 0 for all a.")
print("Proof: a + a = a = a + 0, so by cancellation, a = 0.")
print("\nThis means GF(2) linear algebra (where 1+1=0 ≠ 1) CANNOT be tropical:")
print("  In GF(2): 1 + 1 = 0 ≠ 1, so addition is NOT idempotent.")
print("  Tropical addition (min) IS idempotent: min(a, a) = a.")
print("  ⟹ The QS parity-solving stage resists tropicalization.")

# ============================================================
# Demo 5: Quadratic Sieve Application
# ============================================================
print("\n" + "=" * 70)
print("APPLICATION: Tropical Sieve Scoring for N = 15347")
print("=" * 70)

N = 15347
M = int(math.isqrt(N)) + 1  # Start of sieve interval
R = 100
P = {2, 3, 5, 7, 11, 13}
print(f"\nN = {N}, sieve interval [{M}, {M+R}), factor base P = {P}")
print(f"\n{'x':>5} | {'Q_N(x)':>10} | {'cost':>5} | {'smooth?':>7} | factorization")
print("-" * 70)

smooth_found = []
for x in range(M, M + R):
    qn = x * x - N
    if qn <= 0:
        continue
    cost = smooth_cost(P, qn)
    if cost <= 2:  # Show candidates with low cost
        factors = factorize(qn)
        factor_str = " × ".join(f"{p}^{e}" if e > 1 else str(p) for p, e in sorted(factors.items()))
        smooth_label = "YES" if cost == 0 else "almost"
        print(f"{x:>5} | {qn:>10} | {cost:>5} | {smooth_label:>7} | {factor_str}")
        if cost == 0:
            smooth_found.append((x, qn))

print(f"\nSmooth relations found: {len(smooth_found)}")
for x, qn in smooth_found:
    print(f"  x={x}: {x}² - {N} = {qn} = {factorize(qn)}")

print("\n" + "=" * 70)
print("All demonstrations completed successfully.")
print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Quadratic Sieve: Visualizations

Generates publication-quality figures illustrating the core theorems
and their applications to the quadratic sieve.
"""

import math
import base64
import io
from typing import Dict, Set, List

# Use Agg backend for headless rendering
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np


def factorize(n: int) -> Dict[int, int]:
    if n <= 1:
        return {}
    factors: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def smooth_cost(P: Set[int], n: int) -> float:
    if n == 0:
        return float('inf')
    factors = factorize(n)
    return sum(e for p, e in factors.items() if p not in P)


def primes_up_to(B: int) -> List[int]:
    if B < 2:
        return []
    sieve = [True] * (B + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(B**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, B + 1, i):
                sieve[j] = False
    return [i for i in range(2, B + 1) if sieve[i]]


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


# ============================================================
# Figure 1: Smooth Cost Landscape
# ============================================================

def plot_smooth_cost_landscape():
    """Visualize smoothCost over [1, 200] for different factor bases."""
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Tropical Smoothness Cost Landscape', fontsize=16, fontweight='bold')

    bases = [
        ({2}, '{2}'),
        ({2, 3}, '{2, 3}'),
        ({2, 3, 5}, '{2, 3, 5}'),
        ({2, 3, 5, 7}, '{2, 3, 5, 7}'),
    ]

    N = 200
    ns = list(range(1, N + 1))

    for ax, (P, label) in zip(axes.flat, bases):
        costs = [smooth_cost(P, n) for n in ns]
        colors = ['#2ecc71' if c == 0 else '#e74c3c' if c >= 3 else '#f39c12' for c in costs]
        ax.bar(ns, costs, color=colors, width=1.0, edgecolor='none')
        ax.set_title(f'P = {label}', fontsize=13)
        ax.set_xlabel('n')
        ax.set_ylabel('smoothCost(P, n)')
        ax.set_ylim(0, max(costs) + 1)

        zero_count = sum(1 for c in costs if c == 0)
        ax.annotate(f'{zero_count} smooth', xy=(0.95, 0.95),
                   xycoords='axes fraction', ha='right', va='top',
                   fontsize=11, color='#2ecc71', fontweight='bold',
                   bbox=dict(boxstyle='round,pad=0.3', facecolor='white', alpha=0.8))

    plt.tight_layout()
    return fig_to_base64(fig)


# ============================================================
# Figure 2: Multiplicative Additivity Verification
# ============================================================

def plot_multiplicative_additivity():
    """Scatter plot verifying smoothCost(ab) = smoothCost(a) + smoothCost(b)."""
    fig, ax = plt.subplots(figsize=(8, 8))

    P = {2, 3, 5}
    points_x = []
    points_y = []

    for a in range(1, 81):
        for b in range(a, 81):
            cost_ab = smooth_cost(P, a * b)
            cost_sum = smooth_cost(P, a) + smooth_cost(P, b)
            points_x.append(cost_sum)
            points_y.append(cost_ab)

    ax.scatter(points_x, points_y, alpha=0.3, s=10, c='#3498db', edgecolors='none')
    max_val = max(max(points_x), max(points_y)) + 1
    ax.plot([0, max_val], [0, max_val], 'r-', linewidth=2, label='y = x (perfect equality)')
    ax.set_xlabel('smoothCost(P, a) + smoothCost(P, b)', fontsize=12)
    ax.set_ylabel('smoothCost(P, a·b)', fontsize=12)
    ax.set_title('Theorem 2: Multiplicative Additivity\nsmoothCost(P, a·b) = smoothCost(P, a) + smoothCost(P, b)',
                fontsize=14, fontweight='bold')
    ax.legend(fontsize=12)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    return fig_to_base64(fig)


# ============================================================
# Figure 3: Factor Base Monotonicity
# ============================================================

def plot_monotonicity():
    """Visualize how smooth cost decreases as factor base grows."""
    fig, ax = plt.subplots(figsize=(12, 6))

    bases = [
        {2},
        {2, 3},
        {2, 3, 5},
        {2, 3, 5, 7},
        {2, 3, 5, 7, 11},
        {2, 3, 5, 7, 11, 13},
    ]
    labels = ['{2}', '{2,3}', '{2,3,5}', '{2,3,5,7}', '{2,..,11}', '{2,..,13}']

    N = 500
    ns = list(range(1, N + 1))

    colors = plt.cm.viridis(np.linspace(0.1, 0.9, len(bases)))

    for P, label, color in zip(bases, labels, colors):
        # Compute running average of smooth cost
        costs = [smooth_cost(P, n) for n in ns]
        window = 20
        avg = [sum(costs[max(0,i-window):i+1]) / min(i+1, window+1) for i in range(len(costs))]
        ax.plot(ns, avg, label=f'P = {label}', color=color, linewidth=2)

    ax.set_xlabel('n', fontsize=12)
    ax.set_ylabel('Smoothness Cost (running average)', fontsize=12)
    ax.set_title('Theorem 3: Factor Base Monotonicity\nLarger factor base → lower cost (curves never cross upward)',
                fontsize=14, fontweight='bold')
    ax.legend(fontsize=10, loc='upper left')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    return fig_to_base64(fig)


# ============================================================
# Figure 4: QS Sieve Scoring
# ============================================================

def plot_sieve_scoring():
    """Visualize tropical sieve scores for a specific N."""
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(14, 8), gridspec_kw={'height_ratios': [2, 1]})
    fig.suptitle('Tropical Sieve Scoring for N = 15347', fontsize=16, fontweight='bold')

    N = 15347
    P = set(primes_up_to(20))
    sqrt_N = int(math.isqrt(N)) + 1

    xs = list(range(sqrt_N, sqrt_N + 150))
    Qs = [x * x - N for x in xs]
    costs = [smooth_cost(P, q) if q > 0 else float('inf') for q in Qs]

    # Cap infinity for display
    max_display = 10
    costs_display = [min(c, max_display) for c in costs]

    colors = ['#2ecc71' if c == 0 else '#3498db' if c <= 2 else '#e74c3c' for c in costs]

    ax1.bar(xs, costs_display, color=colors, width=1.0, edgecolor='none')
    ax1.set_ylabel('smoothCost(P, Q_N(x))', fontsize=12)
    ax1.set_xlabel('x', fontsize=12)
    ax1.axhline(y=0, color='green', linestyle='--', alpha=0.5)

    # Annotate smooth values
    for x, c in zip(xs, costs):
        if c == 0:
            ax1.annotate('smooth', xy=(x, 0.3), fontsize=7, ha='center',
                        color='#27ae60', fontweight='bold', rotation=90)

    ax1.set_title(f'P = primes ≤ 20, sieve interval [{xs[0]}, {xs[-1]}]', fontsize=12)
    ax1.legend(['Cost = 0 (smooth)', 'Cost 1-2 (almost smooth)', 'Cost ≥ 3'],
              loc='upper right', fontsize=10)

    # Bottom plot: Q_N values (log scale)
    ax2.semilogy(xs, [abs(q) for q in Qs], color='#8e44ad', linewidth=1)
    for x, c, q in zip(xs, costs, Qs):
        if c == 0 and q > 0:
            ax2.plot(x, q, 'go', markersize=8)
    ax2.set_ylabel('|Q_N(x)| = |x² - N|', fontsize=12)
    ax2.set_xlabel('x', fontsize=12)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    return fig_to_base64(fig)


# ============================================================
# Figure 5: Smooth Number Density
# ============================================================

def plot_smooth_density():
    """Visualize the density of smooth numbers Ψ(x, B) / x."""
    fig, ax = plt.subplots(figsize=(10, 6))

    B_values = [5, 10, 20, 50, 100]
    N_max = 5000
    ns = list(range(1, N_max + 1))

    colors = plt.cm.plasma(np.linspace(0.1, 0.9, len(B_values)))

    for B, color in zip(B_values, colors):
        P = set(primes_up_to(B))
        # Cumulative count of smooth numbers
        cum_count = 0
        densities = []
        sample_points = list(range(50, N_max + 1, 50))

        for n in ns:
            if smooth_cost(P, n) == 0:
                cum_count += 1
            if n in sample_points:
                densities.append((n, cum_count / n))

        xs_plot = [d[0] for d in densities]
        ys_plot = [d[1] for d in densities]
        ax.plot(xs_plot, ys_plot, color=color, linewidth=2, label=f'B = {B}')

    ax.set_xlabel('N', fontsize=12)
    ax.set_ylabel('Ψ(N, B) / N  (smooth number density)', fontsize=12)
    ax.set_title('Density of B-Smooth Numbers\n(Numbers with tropical cost = 0)',
                fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 1)

    plt.tight_layout()
    return fig_to_base64(fig)


# ============================================================
# Generate all figures
# ============================================================

if __name__ == "__main__":
    print("Generating visualizations...")

    print("  Figure 1: Smooth cost landscape...")
    uri1 = plot_smooth_cost_landscape()
    print(f"    Generated ({len(uri1)} chars)")

    print("  Figure 2: Multiplicative additivity...")
    uri2 = plot_multiplicative_additivity()
    print(f"    Generated ({len(uri2)} chars)")

    print("  Figure 3: Factor base monotonicity...")
    uri3 = plot_monotonicity()
    print(f"    Generated ({len(uri3)} chars)")

    print("  Figure 4: QS sieve scoring...")
    uri4 = plot_sieve_scoring()
    print(f"    Generated ({len(uri4)} chars)")

    print("  Figure 5: Smooth number density...")
    uri5 = plot_smooth_density()
    print(f"    Generated ({len(uri5)} chars)")

    # Save URIs for PACKAGE.json consumption
    import json
    viz_data = [
        {"name": "Smooth Cost Landscape", "data": uri1},
        {"name": "Multiplicative Additivity Verification", "data": uri2},
        {"name": "Factor Base Monotonicity", "data": uri3},
        {"name": "Quadratic Sieve Scoring", "data": uri4},
        {"name": "Smooth Number Density", "data": uri5},
    ]
    with open("viz_data.json", "w") as f:
        json.dump(viz_data, f)

    print("\nAll visualizations generated successfully.")
    print("Data saved to viz_data.json")
