#!/usr/bin/env python3
"""
Applications of Certificate Density Theory

Shows practical applications of the certificate density framework:
1. Random generation probability for GL_n(𝔽_q)
2. Cryptographic key generation bounds
3. Error-correcting code design via Singer cycles
"""

from fractions import Fraction
from algorithms import (
    irreducible_count, certificate_density_exact,
    certificate_density_asymptotic, gl_order, moebius, divisors
)


def random_generation_probability(q: int, n: int, k: int = 2) -> float:
    """
    Lower bound on Pr[k random elements of GL_n(𝔽_q) generate GL_n(𝔽_q)].

    Uses the certificate density framework:
    If at least one of k random elements has irreducible charpoly (a Singer cycle),
    the probability of generation is high.

    Pr[at least one Singer cycle in k draws] = 1 - (1 - δ_n(q))^k

    Args:
        q: field size
        n: matrix dimension
        k: number of random elements drawn

    Returns:
        Lower bound on generation probability
    """
    delta = float(certificate_density_exact(q, n))
    return 1 - (1 - delta) ** k


def min_draws_for_target(q: int, n: int, target: float = 0.99) -> int:
    """
    Minimum number of random draws from GL_n(𝔽_q) to achieve
    target probability of including a Singer cycle.

    k ≥ log(1 - target) / log(1 - δ_n(q))
    """
    import math
    delta = float(certificate_density_exact(q, n))
    if delta >= 1:
        return 1
    return math.ceil(math.log(1 - target) / math.log(1 - delta))


def singer_cycle_period(q: int, n: int) -> int:
    """
    The order of a Singer cycle in GL_n(𝔽_q).
    A Singer cycle has order q^n - 1 (it generates 𝔽_{q^n}^×).
    """
    return q**n - 1


def linear_feedback_shift_register_period(q: int, n: int) -> int:
    """
    Maximum period of an LFSR over 𝔽_q with n stages.
    This equals q^n - 1, achieved when the characteristic
    polynomial is a primitive polynomial (a special case of
    irreducible polynomials).
    """
    return q**n - 1


def cyclic_code_parameters(q: int, n: int) -> dict:
    """
    Parameters of cyclic codes constructible from irreducible polynomials
    of degree n over 𝔽_q.

    An irreducible polynomial of degree n gives a cyclic code of:
    - Length: q^n - 1 (or its divisors)
    - Dimension: q^n - 1 - n (for single generator)
    - Minimum distance: ≥ n + 1 (BCH bound for narrow-sense codes)
    """
    return {
        'field_size': q,
        'extension_degree': n,
        'code_length': q**n - 1,
        'code_dimension': q**n - 1 - n,
        'min_distance_lower_bound': n + 1,
        'num_irreducible_polynomials': int(irreducible_count(q, n))
    }


def main():
    print("=" * 72)
    print("APPLICATIONS OF CERTIFICATE DENSITY THEORY")
    print("=" * 72)

    # Application 1: Random generation
    print("\n--- Application 1: Random Generation of GL_n(𝔽_q) ---")
    print(f"{'n':>3} {'q':>3} {'δ_n(q)':>10} {'Pr[gen|k=2]':>12} {'Pr[gen|k=3]':>12} {'k for 99%':>10}")
    print("-" * 55)
    for n in [2, 3, 4, 5, 6, 8]:
        for q in [2, 3, 5]:
            delta = float(certificate_density_exact(q, n))
            p2 = random_generation_probability(q, n, 2)
            p3 = random_generation_probability(q, n, 3)
            k99 = min_draws_for_target(q, n, 0.99)
            print(f"{n:>3} {q:>3} {delta:>10.6f} {p2:>12.6f} {p3:>12.6f} {k99:>10d}")

    # Application 2: Cryptographic LFSR design
    print("\n--- Application 2: LFSR Design with Irreducible Polynomials ---")
    print(f"{'q':>3} {'n':>3} {'I(q,n)':>8} {'Max period':>12} {'Choices':>8}")
    print("-" * 40)
    for q in [2, 3]:
        for n in [4, 8, 16, 32]:
            count = int(irreducible_count(q, n))
            period = linear_feedback_shift_register_period(q, n)
            print(f"{q:>3} {n:>3} {count:>8} {period:>12} {count:>8}")

    # Application 3: Cyclic code construction
    print("\n--- Application 3: Cyclic Code Parameters ---")
    for q in [2, 3]:
        for n in [3, 4, 5, 6, 8]:
            params = cyclic_code_parameters(q, n)
            print(f"GF({q}), deg={n}: [{params['code_length']}, "
                  f"{params['code_dimension']}, ≥{params['min_distance_lower_bound']}] "
                  f"code, {params['num_irreducible_polynomials']} generators available")

    # Application 4: Convergence to 1/n
    print("\n--- Application 4: Convergence of δ_n(q) to 1/n as q → ∞ ---")
    print(f"{'n':>3}  ", end="")
    for q in [2, 3, 5, 7, 11, 101, 1009]:
        print(f"q={q:<5}", end="  ")
    print("  1/n")
    print("-" * 80)
    for n in [2, 3, 4, 6, 8]:
        print(f"{n:>3}  ", end="")
        for q in [2, 3, 5, 7, 11, 101, 1009]:
            d = float(irreducible_count(q, n)) / q**n
            print(f"{d:<7.5f}", end="  ")
        print(f"  {1/n:.5f}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Certificate Density Demo: Computing δ_n(q) for GL_n(𝔽_q)

Demonstrates the certificate density — the proportion of elements in GL_n(𝔽_q)
whose characteristic polynomial is irreducible — for various n and q.
Compares exact values against the 1/n asymptotic and tests the higher-order conjecture.
"""

import math
from fractions import Fraction


def moebius(n: int) -> int:
    """Compute the Möbius function μ(n)."""
    if n <= 0:
        return 0
    if n == 1:
        return 1
    # Factor n and check for square factors
    factors = []
    temp = n
    d = 2
    while d * d <= temp:
        if temp % d == 0:
            factors.append(d)
            temp //= d
            if temp % d == 0:
                return 0  # n has a squared prime factor
        d += 1
    if temp > 1:
        factors.append(temp)
    return (-1) ** len(factors)


def divisors(n: int) -> list:
    """Return the list of positive divisors of n."""
    divs = []
    for d in range(1, n + 1):
        if n % d == 0:
            divs.append(d)
    return divs


def necklace_sum(q: int, n: int) -> int:
    """Compute the necklace sum: Σ_{d|n} μ(n/d) · q^d."""
    return sum(moebius(n // d) * q**d for d in divisors(n))


def necklace_count(q: int, n: int) -> Fraction:
    """Compute I(q,n) = (1/n) Σ_{d|n} μ(n/d) q^d — the exact count of
    irreducible monic polynomials of degree n over 𝔽_q."""
    return Fraction(necklace_sum(q, n), n)


def certificate_density(q: int, n: int) -> Fraction:
    """Compute δ_n(q) = I(q,n) / (q^n - 1), the certificate density."""
    return necklace_count(q, n) / (q**n - 1)


def main():
    print("=" * 72)
    print("CERTIFICATE DENSITY ASYMPTOTICS FOR GL_n(𝔽_q)")
    print("=" * 72)

    # Table 1: Necklace counts I(q,n)
    print("\n--- Table 1: Number of irreducible monic polynomials I(q,n) ---")
    print(f"{'n':>4}", end="")
    for q in [2, 3, 5, 7]:
        print(f"  q={q:>2}", end="")
    print()
    print("-" * 36)
    for n in range(1, 9):
        print(f"{n:>4}", end="")
        for q in [2, 3, 5, 7]:
            count = necklace_count(q, n)
            print(f"  {int(count):>4}", end="")
        print()

    # Table 2: Certificate density δ_n(q) vs 1/n
    print("\n--- Table 2: Certificate density δ_n(q) = I(q,n)/(q^n - 1) ---")
    print(f"{'n':>4}  {'1/n':>8}", end="")
    for q in [2, 3, 5, 7]:
        print(f"  q={q:>2}      ", end="")
    print()
    print("-" * 72)
    for n in range(2, 9):
        one_over_n = 1.0 / n
        print(f"{n:>4}  {one_over_n:>8.5f}", end="")
        for q in [2, 3, 5, 7]:
            density = float(certificate_density(q, n))
            print(f"  {density:>10.6f}", end="")
        print()

    # Table 3: Error |δ_n(q) - 1/n| vs bound 1/q^(n/2)
    print("\n--- Table 3: Error analysis ---")
    print(f"{'n':>4}  {'q':>3}  {'|error|':>12}  {'bound 1/q^(n/2)':>16}  {'ratio':>8}  {'ok?':>4}")
    print("-" * 60)
    all_ok = True
    for n in range(2, 9):
        for q in [2, 3, 5, 7]:
            density = float(necklace_count(q, n)) / q**n
            error = abs(density - 1.0 / n)
            bound = 1.0 / q**(n // 2)
            ratio = error / bound if bound > 0 else 0
            ok = error <= bound + 1e-15
            if not ok:
                all_ok = False
            print(f"{n:>4}  {q:>3}  {error:>12.8f}  {bound:>16.8f}  {ratio:>8.4f}  {'✓' if ok else '✗':>4}")

    print(f"\nAll bounds satisfied: {'YES ✓' if all_ok else 'NO ✗'}")

    # Test higher-order conjecture
    print("\n--- Table 4: Higher-order conjecture test ---")
    print("Conjecture: |c₁| = |n · q^(n/2) · (I(q,n)/q^n - 1/n)| ≤ 1.1")
    print(f"{'n':>4}  {'q':>3}  {'c₁':>12}  {'|c₁| ≤ 1.1?':>14}")
    print("-" * 40)
    conj_ok = True
    for n in range(2, 21):
        for q in [2, 3, 5, 7, 11]:
            density_over_qn = float(necklace_count(q, n)) / q**n
            c1 = n * q**(n // 2) * (density_over_qn - 1.0 / n)
            ok = abs(c1) <= 1.1
            if not ok:
                conj_ok = False
            if n <= 8 or not ok:
                print(f"{n:>4}  {q:>3}  {c1:>12.6f}  {'✓' if ok else '✗':>14}")

    print(f"\nHigher-order conjecture holds: {'YES ✓' if conj_ok else 'NO ✗'}")

    # Specific test: n=6, q=2
    print("\n--- Specific test: n=6, q=2 ---")
    ns = necklace_sum(2, 6)
    nc = necklace_count(2, 6)
    print(f"necklaceSum(2, 6) = {ns}")
    print(f"necklaceCount(2, 6) = {nc} = {int(nc)}")
    print(f"Exact density = {nc}/64 = {float(nc)/64:.6f}")
    print(f"1/6 = {1/6:.6f}")
    print(f"Error = {abs(float(nc)/64 - 1/6):.6f}")
    print(f"Bound 1/2^3 = {1/8:.6f}")
    print(f"Bound satisfied: {'YES ✓' if abs(float(nc)/64 - 1/6) <= 1/8 else 'NO ✗'}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Certificate Density Convergence to 1/n

Shows how δ_n(q) = I(q,n)/q^n converges to 1/n as q increases,
for various values of n. The convergence rate is O(q^{-n/2}),
reflecting the function-field Riemann hypothesis.
"""

import matplotlib.pyplot as plt
import numpy as np


def moebius(n):
    if n <= 0:
        return 0
    if n == 1:
        return 1
    factors = []
    temp = n
    d = 2
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
    divs = []
    d = 1
    while d * d <= n:
        if n % d == 0:
            divs.append(d)
            if d != n // d:
                divs.append(n // d)
        d += 1
    return sorted(divs)


def necklace_count(q, n):
    return sum(moebius(n // d) * q**d for d in divisors(n)) / n


def density_over_qn(q, n):
    return necklace_count(q, n) / q**n


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: density vs q for various n
ax1 = axes[0]
q_values = list(range(2, 51))
colors = plt.cm.viridis(np.linspace(0.1, 0.9, 6))

for i, n in enumerate([2, 3, 4, 5, 6, 8]):
    densities = [density_over_qn(q, n) for q in q_values]
    ax1.plot(q_values, densities, '-o', color=colors[i], markersize=2,
             label=f'n={n}', linewidth=1.5)
    ax1.axhline(y=1/n, color=colors[i], linestyle='--', alpha=0.3, linewidth=0.8)

ax1.set_xlabel('Field size q', fontsize=12)
ax1.set_ylabel('I(q,n) / q^n', fontsize=12)
ax1.set_title('Certificate Density Convergence to 1/n', fontsize=13)
ax1.legend(loc='upper right', fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.set_ylim(0, 0.55)

# Right panel: log error vs n for various q
ax2 = axes[1]
n_values = list(range(2, 16))

for q, color, marker in [(2, '#e74c3c', 'o'), (3, '#3498db', 's'),
                           (5, '#2ecc71', '^'), (7, '#9b59b6', 'D')]:
    errors = [abs(density_over_qn(q, n) - 1/n) for n in n_values]
    bounds = [1/q**(n//2) for n in n_values]
    ax2.semilogy(n_values, errors, f'-{marker}', color=color, markersize=4,
                 label=f'|error|, q={q}', linewidth=1.5)
    ax2.semilogy(n_values, bounds, '--', color=color, alpha=0.4,
                 linewidth=1, label=f'bound, q={q}')

ax2.set_xlabel('Degree n', fontsize=12)
ax2.set_ylabel('|I(q,n)/q^n - 1/n|', fontsize=12)
ax2.set_title('Error Bound: Function-Field PNT', fontsize=13)
ax2.legend(loc='upper right', fontsize=8, ncol=2)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('density_convergence.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved density_convergence.png")


#!/usr/bin/env python3
"""
Visualization: Error Term Structure

Shows the normalized error c₁(n,q) = n · q^(n/2) · (I(q,n)/q^n - 1/n)
as a function of n for various q, revealing the dependence on the
divisor structure of n. The testable prediction |c₁| ≤ 1 is falsified
for n with large proper divisors (e.g., n=6).
"""

import matplotlib.pyplot as plt
import numpy as np


def moebius(n):
    if n <= 0:
        return 0
    if n == 1:
        return 1
    factors = []
    temp = n
    d = 2
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
    divs = []
    d = 1
    while d * d <= n:
        if n % d == 0:
            divs.append(d)
            if d != n // d:
                divs.append(n // d)
        d += 1
    return sorted(divs)


def necklace_count(q, n):
    return sum(moebius(n // d) * q**d for d in divisors(n)) / n


def normalized_error(q, n):
    """c₁(n,q) = n · q^(n//2) · (I(q,n)/q^n - 1/n)"""
    density = necklace_count(q, n) / q**n
    return n * q**(n // 2) * (density - 1.0/n)


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: c₁ vs n for various q
ax1 = axes[0]
n_values = list(range(2, 25))

for q, color, ls in [(2, '#e74c3c', '-'), (3, '#3498db', '-'),
                      (5, '#2ecc71', '-'), (7, '#9b59b6', '-')]:
    c1_values = [normalized_error(q, n) for n in n_values]
    ax1.plot(n_values, c1_values, f'{ls}o', color=color, markersize=3,
             label=f'q={q}', linewidth=1.2)

ax1.axhline(y=1, color='gray', linestyle='--', alpha=0.5, label='|c₁| = 1')
ax1.axhline(y=-1, color='gray', linestyle='--', alpha=0.5)
ax1.axhline(y=0, color='black', linewidth=0.5)

# Mark primes, prime powers, and composite n
for n in n_values:
    is_prime = all(n % d != 0 for d in range(2, n))
    if is_prime and n >= 2:
        ax1.axvline(x=n, color='green', alpha=0.1, linewidth=8)

ax1.set_xlabel('Degree n', fontsize=12)
ax1.set_ylabel('c₁(n,q) = n·q^(n/2)·(I/q^n - 1/n)', fontsize=11)
ax1.set_title('Normalized Error: Divisor Structure Effect', fontsize=13)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.set_ylim(-2, 0.5)
ax1.annotate('Green bands = prime n\n(error small)',
             xy=(0.02, 0.02), xycoords='axes fraction', fontsize=8,
             color='green', alpha=0.7)

# Right: |c₁| vs number of divisors of n
ax2 = axes[1]
for q, color in [(2, '#e74c3c'), (3, '#3498db'), (5, '#2ecc71'), (7, '#9b59b6')]:
    nd_values = [(len(divisors(n)), abs(normalized_error(q, n)))
                 for n in range(2, 31)]
    nd_x = [x[0] for x in nd_values]
    nd_y = [x[1] for x in nd_values]
    ax2.scatter(nd_x, nd_y, color=color, alpha=0.5, s=15, label=f'q={q}')

# Reference lines
d_range = np.linspace(1, 10, 100)
ax2.plot(d_range, d_range - 1, 'k--', alpha=0.3, label='d(n) - 1')
ax2.plot(d_range, np.ones_like(d_range), 'gray', linestyle=':', alpha=0.5)

ax2.set_xlabel('Number of divisors d(n)', fontsize=12)
ax2.set_ylabel('|c₁(n,q)|', fontsize=12)
ax2.set_title('Error vs Divisor Count', fontsize=13)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)
ax2.set_xlim(1, 10)
ax2.set_ylim(0, 3)

plt.tight_layout()
plt.savefig('error_structure.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved error_structure.png")


#!/usr/bin/env python3
"""
Visualization: Certificate Density Heatmap

Heatmap of I(q,n)/q^n across different (q, n) values,
showing how the density approaches 1/n uniformly.
The color represents the ratio δ_n(q) / (1/n) = n · I(q,n) / q^n,
which converges to 1.
"""

import matplotlib.pyplot as plt
import numpy as np


def moebius(n):
    if n <= 0:
        return 0
    if n == 1:
        return 1
    factors = []
    temp = n
    d = 2
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
    divs = []
    d = 1
    while d * d <= n:
        if n % d == 0:
            divs.append(d)
            if d != n // d:
                divs.append(n // d)
        d += 1
    return sorted(divs)


def necklace_count(q, n):
    return sum(moebius(n // d) * q**d for d in divisors(n)) / n


# Compute the ratio n * I(q,n) / q^n for each (q, n)
q_values = [2, 3, 4, 5, 7, 8, 9, 11, 13, 16, 17, 19, 23, 25, 27, 29, 31, 37, 41, 43, 47]
n_values = list(range(2, 13))

data = np.zeros((len(n_values), len(q_values)))
for i, n in enumerate(n_values):
    for j, q in enumerate(q_values):
        data[i, j] = n * necklace_count(q, n) / q**n

fig, ax = plt.subplots(figsize=(12, 6))

im = ax.imshow(data, aspect='auto', cmap='RdYlGn',
               vmin=0.5, vmax=1.05,
               interpolation='nearest')

ax.set_xticks(range(len(q_values)))
ax.set_xticklabels(q_values, fontsize=8)
ax.set_yticks(range(len(n_values)))
ax.set_yticklabels(n_values, fontsize=10)

ax.set_xlabel('Field size q', fontsize=12)
ax.set_ylabel('Degree n', fontsize=12)
ax.set_title('Certificate Density Ratio: n · I(q,n) / q^n → 1', fontsize=13)

# Add text annotations
for i in range(len(n_values)):
    for j in range(len(q_values)):
        val = data[i, j]
        color = 'white' if val < 0.7 else 'black'
        ax.text(j, i, f'{val:.2f}', ha='center', va='center',
                fontsize=6, color=color)

plt.colorbar(im, ax=ax, label='n · I(q,n) / q^n', shrink=0.8)
plt.tight_layout()
plt.savefig('density_heatmap.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved density_heatmap.png")
