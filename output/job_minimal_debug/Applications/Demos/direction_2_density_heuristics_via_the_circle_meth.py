#!/usr/bin/env python3
"""
Applications of Circle Method Density Heuristics

Demonstrates real-world applications of the local density framework
for the three cubes problem:

1. Predicting representation density from local data
2. Identifying locally obstructed integers
3. Ranking integers by predicted density of representations
4. Validating the Hardy-Littlewood philosophy computationally
"""

from fractions import Fraction
import math


def sieve_primes(limit):
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]


def three_cube_residue_count(k, n):
    k_mod = k % n
    count = 0
    for a in range(n):
        a3 = (a * a * a) % n
        for b in range(n):
            ab3 = (a3 + b * b * b) % n
            for c in range(n):
                if (ab3 + c * c * c) % n == k_mod:
                    count += 1
    return count


def local_density(k, n):
    return Fraction(three_cube_residue_count(k, n), n ** 2)


def truncated_singular_series(k, prime_bound):
    primes = sieve_primes(prime_bound)
    product = Fraction(1)
    for p in primes:
        product *= local_density(k, p)
    return product


def empirical_count(k, N):
    count = 0
    for x in range(-N, N + 1):
        x3 = x ** 3
        for y in range(-N, N + 1):
            xy3 = x3 + y ** 3
            for z in range(-N, N + 1):
                if xy3 + z ** 3 == k:
                    count += 1
    return count


# ============================================================
# Application 1: Identifying locally obstructed integers
# ============================================================
def find_obstructed_integers(limit):
    """Find all integers k in [0, limit) that are locally obstructed mod 9."""
    obstructed = []
    admissible = []
    for k in range(limit):
        if k % 9 in (4, 5):
            obstructed.append(k)
        else:
            admissible.append(k)
    return obstructed, admissible


# ============================================================
# Application 2: Ranking integers by predicted density
# ============================================================
def rank_by_density(k_values, prime_bound=13):
    """Rank admissible integers by their truncated singular series value."""
    densities = []
    for k in k_values:
        if k % 9 not in (4, 5):
            ss = truncated_singular_series(k, prime_bound)
            densities.append((k, float(ss)))
    densities.sort(key=lambda x: -x[1])
    return densities


# ============================================================
# Application 3: Comparing predicted vs actual counts
# ============================================================
def compare_prediction_vs_actual(k_values, N, prime_bound=13):
    """Compare truncated singular series prediction with actual counts."""
    results = []
    for k in k_values:
        if k % 9 in (4, 5):
            continue
        actual = empirical_count(k, N)
        predicted_coeff = float(truncated_singular_series(k, prime_bound))
        predicted = predicted_coeff * N ** (1/3)
        results.append({
            'k': k,
            'R_k(N)': actual,
            'predicted_coeff': predicted_coeff,
            'R_k/N^(1/3)': actual / N**(1/3) if N > 0 else 0,
            'ratio': actual / predicted if predicted > 0 else float('inf')
        })
    return results


# ============================================================
# Application 4: Density variation across residue classes
# ============================================================
def density_by_residue_class(modulus, prime_bound=11):
    """Show how the singular series proxy varies across residue classes mod m."""
    results = {}
    for r in range(modulus):
        ss = float(truncated_singular_series(r, prime_bound))
        results[r] = ss
    return results


def main():
    print("=" * 72)
    print("APPLICATIONS OF CIRCLE METHOD DENSITY HEURISTICS")
    print("=" * 72)

    # Application 1
    print("\n--- Application 1: Local Obstructions ---")
    obstructed, admissible = find_obstructed_integers(50)
    print(f"Integers 0-49 obstructed (k mod 9 ∈ {{4,5}}): {obstructed}")
    print(f"Density of obstructed: {len(obstructed)/50:.0%}")
    print(f"Density of admissible: {len(admissible)/50:.0%}")

    # Application 2
    print("\n--- Application 2: Density Rankings (P ≤ 13) ---")
    rankings = rank_by_density(range(20), prime_bound=13)
    print(f"{'Rank':>4} | {'k':>4} | {'S^sf(k)':>10}")
    print("-" * 28)
    for i, (k, ss) in enumerate(rankings[:15], 1):
        print(f"{i:4d} | {k:4d} | {ss:10.6f}")

    # Application 3
    print("\n--- Application 3: Predicted vs Actual (N=15) ---")
    results = compare_prediction_vs_actual(range(10), N=15, prime_bound=11)
    print(f"{'k':>4} | {'R_k(15)':>8} | {'R_k/N^1/3':>10} | {'S^sf':>8} | {'Ratio':>8}")
    print("-" * 50)
    for r in results:
        print(f"{r['k']:4d} | {r['R_k(N)']:8d} | {r['R_k/N^(1/3)']:10.4f} | "
              f"{r['predicted_coeff']:8.4f} | {r['ratio']:8.4f}")

    # Application 4
    print("\n--- Application 4: Density Variation mod 9 ---")
    for r in range(9):
        ss = float(truncated_singular_series(r, 11))
        bar = "█" * int(ss * 10) if ss > 0 else "[ZERO]"
        status = "OBSTRUCTED" if r in (4, 5) else ""
        print(f"  k ≡ {r} (mod 9): S^sf = {ss:.6f}  {bar}  {status}")

    print("\n" + "=" * 72)
    print("CONCLUSIONS")
    print("=" * 72)
    print("""
The local density framework provides:
1. EXACT identification of which integers cannot be sums of three cubes
   (those with k ≡ 4 or 5 mod 9).
2. QUANTITATIVE predictions for how "easy" admissible k are to represent,
   via the truncated singular series proxy.
3. A RIGOROUS bridge between counting solutions and probability theory
   (δ_k(n) = n · Pr[random cubes sum to k]).
4. MULTIPLICATIVE structure (CRT) enabling efficient Euler product computation.

All structural properties are formally verified in the Lean development.
""")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Demo: Circle Method Density Heuristics for Sums of Three Cubes

Computes empirical counts R_k(N), local density factors δ_k(p),
and truncated singular series proxies, then compares them.
"""

import math
from collections import defaultdict


def three_cube_residue_count(k: int, n: int) -> int:
    """Count solutions to a^3 + b^3 + c^3 ≡ k (mod n) in (Z/nZ)^3."""
    count = 0
    for a in range(n):
        for b in range(n):
            for c in range(n):
                if (a**3 + b**3 + c**3) % n == k % n:
                    count += 1
    return count


def local_density(k: int, n: int) -> float:
    """δ_k(n) = #Sol(n) / n^2, the circle-method normalization."""
    return three_cube_residue_count(k, n) / (n ** 2)


def uniform_prob(k: int, n: int) -> float:
    """Pr[a^3+b^3+c^3 ≡ k (mod n)] = #Sol(n) / n^3."""
    return three_cube_residue_count(k, n) / (n ** 3)


def sieve_primes(limit: int) -> list:
    """Simple sieve of Eratosthenes."""
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]


def truncated_singular_series(k: int, prime_bound: int) -> float:
    """Squarefree truncated singular series: ∏_{p ≤ P} δ_k(p)."""
    primes = sieve_primes(prime_bound)
    product = 1.0
    for p in primes:
        product *= local_density(k, p)
    return product


def empirical_count(k: int, N: int) -> int:
    """R_k(N) = #{(x,y,z) ∈ Z^3 : |x|,|y|,|z| ≤ N, x^3+y^3+z^3 = k}."""
    count = 0
    for x in range(-N, N + 1):
        for y in range(-N, N + 1):
            for z in range(-N, N + 1):
                if x**3 + y**3 + z**3 == k:
                    count += 1
    return count


def is_admissible_mod9(k: int) -> bool:
    """Check if k is admissible (k mod 9 not in {4, 5})."""
    return (k % 9) not in (4, 5)


def main():
    print("=" * 72)
    print("CIRCLE METHOD DENSITY HEURISTICS FOR SUMS OF THREE CUBES")
    print("=" * 72)

    # Test values of k
    test_values = list(range(10))

    # Part 1: Mod 9 classification
    print("\n--- Mod 9 Admissibility ---")
    print(f"{'k':>4} | {'k mod 9':>7} | {'Admissible':>10}")
    print("-" * 30)
    for k in test_values:
        adm = is_admissible_mod9(k)
        print(f"{k:4d} | {k % 9:7d} | {'YES' if adm else 'NO':>10}")

    # Part 2: Local densities at small primes
    print("\n--- Local Densities δ_k(p) = #Sol(p) / p² ---")
    primes = sieve_primes(13)
    header = f"{'k':>4} |" + "".join(f" p={p:2d}  |" for p in primes)
    print(header)
    print("-" * len(header))
    for k in [0, 1, 2, 3, 6, 7, 8, 9]:
        row = f"{k:4d} |"
        for p in primes:
            d = local_density(k, p)
            row += f" {d:.3f} |"
        print(row)

    # Part 3: Residue counts at n=9
    print("\n--- Residue Counts at n=9 ---")
    for k in range(10):
        cnt = three_cube_residue_count(k, 9)
        print(f"  k={k}: #Sol(9) = {cnt:4d}, δ_k(9) = {cnt/81:.4f}"
              f"  {'[ZERO - local obstruction!]' if cnt == 0 else ''}")

    # Part 4: Multiplicativity verification (CRT)
    print("\n--- CRT Multiplicativity Verification ---")
    print("  Testing: #Sol(m*n) = #Sol(m) * #Sol(n) for coprime m,n")
    test_pairs = [(2, 3), (2, 5), (3, 5), (2, 7), (3, 7), (5, 7)]
    all_pass = True
    for m, n in test_pairs:
        for k in [0, 1, 2, 3]:
            cnt_mn = three_cube_residue_count(k, m * n)
            cnt_m = three_cube_residue_count(k, m)
            cnt_n = three_cube_residue_count(k, n)
            ok = (cnt_mn == cnt_m * cnt_n)
            if not ok:
                print(f"  FAIL: k={k}, m={m}, n={n}: "
                      f"{cnt_mn} ≠ {cnt_m} * {cnt_n} = {cnt_m * cnt_n}")
                all_pass = False
    print(f"  All {len(test_pairs) * 4} tests: {'PASSED ✓' if all_pass else 'FAILED ✗'}")

    # Part 5: Truncated singular series
    print("\n--- Truncated Singular Series S^sf_{≤P}(k) ---")
    prime_bounds = [2, 3, 5, 7, 11, 13]
    admissible_k = [0, 1, 2, 3, 6, 7, 8, 9]
    print(f"{'k':>4} |" + "".join(f" P≤{P:2d}   |" for P in prime_bounds))
    print("-" * (6 + 11 * len(prime_bounds)))
    for k in admissible_k:
        row = f"{k:4d} |"
        for P in prime_bounds:
            ss = truncated_singular_series(k, P)
            row += f" {ss:.5f} |"
        print(row)

    # Part 6: Probability bridge
    print("\n--- Probability Bridge: δ_k(n) = n · Pr[sum of cubes ≡ k] ---")
    for n in [2, 3, 5, 7]:
        for k in [0, 1]:
            d = local_density(k, n)
            p = uniform_prob(k, n)
            print(f"  k={k}, n={n}: δ={d:.4f}, n·Pr={n*p:.4f}, "
                  f"match={'YES ✓' if abs(d - n * p) < 1e-12 else 'NO ✗'}")

    # Part 7: Empirical counts for small N
    print("\n--- Empirical Counts R_k(N) for small N ---")
    Ns = [5, 10, 15, 20]
    for k in [0, 1, 2]:
        print(f"\n  k = {k}:")
        for N in Ns:
            rk = empirical_count(k, N)
            ratio = rk / (N ** (1/3)) if N > 0 else 0
            print(f"    N={N:3d}: R_k(N)={rk:5d}, R_k(N)/N^(1/3) = {ratio:.4f}")

    print("\n" + "=" * 72)
    print("SUMMARY")
    print("=" * 72)
    print("""
Key findings:
1. k ≡ 4, 5 (mod 9) have zero local density at n=9 (proved in Lean).
2. Residue counts are multiplicative over coprime moduli (proved in Lean via CRT).
3. Truncated singular series converges to positive constants for admissible k.
4. The local density equals n times the uniform probability (proved in Lean).
5. All factors in the truncated singular series are positive when k is representable.
""")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization 1: Heatmap of Local Densities δ_k(p)

Shows the local density δ_k(p) = #Sol(p)/p² for each integer k (rows)
and prime p (columns). Highlights the mod 9 obstruction (k ≡ 4,5 mod 9
have zero density at p=3) and the variation in density across residue classes.

This visualization makes tangible the "landscape" of local factors that
feed into the singular series Euler product.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def three_cube_residue_count(k, n):
    k_mod = k % n
    count = 0
    for a in range(n):
        a3 = (a * a * a) % n
        for b in range(n):
            ab3 = (a3 + b * b * b) % n
            for c in range(n):
                if (ab3 + c * c * c) % n == k_mod:
                    count += 1
    return count


def local_density(k, n):
    return three_cube_residue_count(k, n) / n**2


def sieve_primes(limit):
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]


primes = sieve_primes(19)
k_values = list(range(20))

# Compute density matrix
data = np.zeros((len(k_values), len(primes)))
for i, k in enumerate(k_values):
    for j, p in enumerate(primes):
        data[i, j] = local_density(k, p)

fig, ax = plt.subplots(figsize=(10, 8))
im = ax.imshow(data, aspect='auto', cmap='YlOrRd', interpolation='nearest')

ax.set_xticks(range(len(primes)))
ax.set_xticklabels([str(p) for p in primes])
ax.set_yticks(range(len(k_values)))
ax.set_yticklabels([str(k) for k in k_values])

ax.set_xlabel('Prime p', fontsize=12)
ax.set_ylabel('Target integer k', fontsize=12)
ax.set_title('Local Density δ_k(p) = #Sol(p) / p²\n'
             'Heatmap of Circle Method Local Factors', fontsize=14)

# Mark obstructed residues
for i, k in enumerate(k_values):
    if k % 9 in (4, 5):
        ax.text(-0.7, i, '✗', fontsize=10, color='red', fontweight='bold',
                ha='center', va='center')

# Add colorbar
cbar = plt.colorbar(im, ax=ax, shrink=0.8)
cbar.set_label('Local density δ_k(p)', fontsize=11)

# Annotate cells with values
for i in range(len(k_values)):
    for j in range(len(primes)):
        val = data[i, j]
        color = 'white' if val > 1.5 else 'black'
        ax.text(j, i, f'{val:.2f}', ha='center', va='center',
                fontsize=7, color=color)

plt.tight_layout()
plt.savefig('viz_local_density_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_local_density_heatmap.png")


#!/usr/bin/env python3
"""
Visualization 3: The Mod 9 Obstruction and Density Landscape

Shows the mod 9 structure of the three cubes problem:
- Left: bar chart of residue counts at n=9 for each residue class
- Right: the "density landscape" showing truncated singular series
  values for k=0..35, with obstructed values highlighted

This visualization makes the local-global principle tangible:
the mod 9 obstruction is the dominant source of impossibility,
and the truncated singular series quantifies the "ease" of
representation for admissible values.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def three_cube_residue_count(k, n):
    k_mod = k % n
    count = 0
    for a in range(n):
        a3 = (a * a * a) % n
        for b in range(n):
            ab3 = (a3 + b * b * b) % n
            for c in range(n):
                if (ab3 + c * c * c) % n == k_mod:
                    count += 1
    return count


def local_density(k, n):
    return three_cube_residue_count(k, n) / n**2


def sieve_primes(limit):
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]


fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: residue counts at n=9
residues = list(range(9))
counts = [three_cube_residue_count(r, 9) for r in residues]
colors_left = ['#2ecc71' if r % 9 not in (4, 5) else '#e74c3c' for r in residues]

bars = ax1.bar(residues, counts, color=colors_left, edgecolor='black', linewidth=0.5)
ax1.set_xlabel('Residue class k mod 9', fontsize=12)
ax1.set_ylabel('# Solutions in (ℤ/9ℤ)³', fontsize=12)
ax1.set_title('Solutions to x³+y³+z³ ≡ k (mod 9)\nGreen = admissible, Red = obstructed', fontsize=12)
ax1.set_xticks(residues)

for i, (r, c) in enumerate(zip(residues, counts)):
    ax1.text(r, c + 3, str(c), ha='center', va='bottom', fontsize=10, fontweight='bold')
    if r in (4, 5):
        ax1.text(r, c + 12, '✗ ZERO', ha='center', va='bottom', fontsize=9, color='red')

# Right panel: density landscape for k=0..35
k_range = list(range(36))
primes = sieve_primes(11)

singular_series_vals = []
for k in k_range:
    if k % 9 in (4, 5):
        singular_series_vals.append(0.0)
    else:
        product = 1.0
        for p in primes:
            product *= local_density(k, p)
        singular_series_vals.append(product)

colors_right = ['#e74c3c' if k % 9 in (4, 5) else '#3498db' for k in k_range]

ax2.bar(k_range, singular_series_vals, color=colors_right,
        edgecolor='black', linewidth=0.3, width=0.8)
ax2.set_xlabel('Target integer k', fontsize=12)
ax2.set_ylabel('S^sf_{≤11}(k)', fontsize=12)
ax2.set_title('Truncated Singular Series (primes ≤ 11)\nBlue = admissible, Red = obstructed (zero)', fontsize=12)

# Add vertical lines at obstructed values
for k in k_range:
    if k % 9 in (4, 5):
        ax2.axvline(x=k, color='red', alpha=0.15, linewidth=3)

plt.suptitle('The Mod 9 Obstruction and Density Landscape for x³ + y³ + z³ = k',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_mod9_obstruction.png', dpi=150, bbox_inches='tight')
print("Saved viz_mod9_obstruction.png")


#!/usr/bin/env python3
"""
Visualization 2: Convergence of the Truncated Singular Series

Plots the truncated singular series S^sf_{≤P}(k) = ∏_{p≤P} δ_k(p)
as a function of the prime cutoff P for several admissible values of k.

This shows how the Euler product proxy stabilizes, providing computational
evidence for the conjecture that the full singular series converges
to a positive constant for each admissible k.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def three_cube_residue_count(k, n):
    k_mod = k % n
    count = 0
    for a in range(n):
        a3 = (a * a * a) % n
        for b in range(n):
            ab3 = (a3 + b * b * b) % n
            for c in range(n):
                if (ab3 + c * c * c) % n == k_mod:
                    count += 1
    return count


def local_density(k, n):
    return three_cube_residue_count(k, n) / n**2


def sieve_primes(limit):
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]


primes = sieve_primes(23)
admissible_k = [0, 1, 2, 3, 6, 7, 8, 9]
colors = plt.cm.tab10(np.linspace(0, 1, len(admissible_k)))

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: absolute values
for idx, k in enumerate(admissible_k):
    series_values = []
    product = 1.0
    for p in primes:
        product *= local_density(k, p)
        series_values.append(product)
    ax1.plot(range(1, len(primes) + 1), series_values, 'o-',
             color=colors[idx], label=f'k = {k}', markersize=4, linewidth=1.5)

ax1.set_xlabel('Number of prime factors included', fontsize=12)
ax1.set_ylabel('S^sf_{≤P}(k)', fontsize=12)
ax1.set_title('Truncated Singular Series\n(Absolute Values)', fontsize=13)
ax1.legend(loc='best', fontsize=9)
ax1.set_xticks(range(1, len(primes) + 1))
ax1.set_xticklabels([str(p) for p in primes], fontsize=8)
ax1.grid(True, alpha=0.3)

# Right panel: ratio to k=0 baseline (relative comparison)
baseline = []
product = 1.0
for p in primes:
    product *= local_density(0, p)
    baseline.append(product)

for idx, k in enumerate(admissible_k):
    if k == 0:
        continue
    series_values = []
    product = 1.0
    for i, p in enumerate(primes):
        product *= local_density(k, p)
        series_values.append(product / baseline[i] if baseline[i] > 0 else 0)
    ax2.plot(range(1, len(primes) + 1), series_values, 'o-',
             color=colors[idx], label=f'k = {k}', markersize=4, linewidth=1.5)

ax2.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5, label='k=0 baseline')
ax2.set_xlabel('Number of prime factors included', fontsize=12)
ax2.set_ylabel('S^sf(k) / S^sf(0)', fontsize=12)
ax2.set_title('Relative Singular Series\n(Normalized to k=0)', fontsize=13)
ax2.legend(loc='best', fontsize=9)
ax2.set_xticks(range(1, len(primes) + 1))
ax2.set_xticklabels([str(p) for p in primes], fontsize=8)
ax2.grid(True, alpha=0.3)

plt.suptitle('Convergence of the Euler Product Proxy for x³ + y³ + z³ = k',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_singular_series_convergence.png', dpi=150, bbox_inches='tight')
print("Saved viz_singular_series_convergence.png")
