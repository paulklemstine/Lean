#!/usr/bin/env python3
"""
Visualization: Certificate Density for Classical Groups

Plots the certificate density δ(q,n) = SRI(q,n)/q^n for symplectic groups
Sp_{2n}(F_q) across different field sizes and ranks, comparing to the
asymptotic prediction δ ≈ 1/(2n).

Shows how certificate density converges to the theoretical value as q grows,
demonstrating the main counting theorem.
"""

import matplotlib.pyplot as plt
import numpy as np
from math import gcd


def mobius(n):
    if n == 1:
        return 1
    factors = {}
    temp = n
    for p in range(2, int(temp**0.5) + 2):
        while temp % p == 0:
            factors[p] = factors.get(p, 0) + 1
            temp //= p
    if temp > 1:
        factors[temp] = 1
    for exp in factors.values():
        if exp > 1:
            return 0
    return (-1) ** len(factors)


def necklace_count(q, n):
    if n == 0:
        return 0
    total = 0
    for d in range(1, n + 1):
        if n % d == 0:
            total += mobius(n // d) * q**d
    return total // n


def poly_mul_mod(a, b, q):
    if not a or not b:
        return []
    result = [0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        for j, bj in enumerate(b):
            result[i + j] = (result[i + j] + ai * bj) % q
    while len(result) > 1 and result[-1] == 0:
        result.pop()
    return result


def poly_mod(a, b, q):
    a = list(a)
    while len(a) >= len(b) and a:
        if a[-1] == 0:
            a.pop()
            continue
        coeff = (a[-1] * pow(b[-1], q - 2, q)) % q
        shift = len(a) - len(b)
        for i in range(len(b)):
            a[shift + i] = (a[shift + i] - coeff * b[i]) % q
        while a and a[-1] == 0:
            a.pop()
    return a if a else [0]


def poly_pow_mod(base, exp, modulus, q):
    result = [1]
    base = poly_mod(base, modulus, q)
    while exp > 0:
        if exp % 2 == 1:
            result = poly_mod(poly_mul_mod(result, base, q), modulus, q)
        base = poly_mod(poly_mul_mod(base, base, q), modulus, q)
        exp //= 2
    return result


def poly_gcd(a, b, q):
    while b and b != [0]:
        a, b = b, poly_mod(a, b, q)
    if not a:
        return [0]
    lc_inv = pow(a[-1], q - 2, q)
    return [(c * lc_inv) % q for c in a]


def is_irreducible_gf(coeffs, q):
    n = len(coeffs) - 1
    if n <= 0:
        return False
    if n == 1:
        return True
    f = coeffs
    x = [0, 1]
    xqn = poly_pow_mod(x, q**n, f, q)
    diff = list(xqn)
    if len(diff) < 2:
        diff.extend([0] * (2 - len(diff)))
    diff[1] = (diff[1] - 1) % q
    remainder = poly_mod(diff, f, q)
    if remainder != [0] and any(c != 0 for c in remainder):
        return False
    prime_divisors = set()
    temp = n
    for p in range(2, int(temp**0.5) + 2):
        while temp % p == 0:
            prime_divisors.add(p)
            temp //= p
    if temp > 1:
        prime_divisors.add(temp)
    for p in prime_divisors:
        m = n // p
        xqm = poly_pow_mod(x, q**m, f, q)
        diff2 = list(xqm)
        if len(diff2) < 2:
            diff2.extend([0] * (2 - len(diff2)))
        diff2[1] = (diff2[1] - 1) % q
        while diff2 and diff2[-1] == 0:
            diff2.pop()
        if not diff2:
            diff2 = [0]
        g = poly_gcd(diff2, f, q)
        if len(g) > 1:
            return False
    return True


def count_sri(q, n):
    """Count monic irreducible self-reciprocal polynomials of degree 2n over GF(q)."""
    if n == 0:
        return 0
    count = 0

    def iterate(params, depth):
        nonlocal count
        if depth == n:
            half = [1] + list(params)
            full = list(half) + list(reversed(half[:-1]))
            full = [c % q for c in full]
            if is_irreducible_gf(full, q):
                count += 1
            return
        for val in range(q):
            iterate(params + (val,), depth + 1)

    iterate((), 0)
    return count


# ============================================================
# Main visualization
# ============================================================

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Certificate Density for Symplectic Groups $Sp_{2n}(\\mathbb{F}_q)$',
             fontsize=16, fontweight='bold')

# Panel 1: Density vs q for fixed n
ax1 = axes[0, 0]
primes = [2, 3, 5, 7, 11, 13]
for n in [1, 2, 3]:
    densities = []
    qs_plot = []
    for q in primes:
        if q**n <= 5000:
            sri = count_sri(q, n)
            densities.append(sri / q**n)
            qs_plot.append(q)
    ax1.plot(qs_plot, densities, 'o-', label=f'$n={n}$, actual', markersize=6)
    ax1.axhline(y=1/(2*n), color=ax1.get_lines()[-1].get_color(),
                linestyle='--', alpha=0.5, label=f'$1/(2n)={1/(2*n):.3f}$')

ax1.set_xlabel('Field size $q$', fontsize=12)
ax1.set_ylabel('Certificate density $\\delta(q,n)$', fontsize=12)
ax1.set_title('Density convergence as $q \\to \\infty$')
ax1.legend(fontsize=8, ncol=2)
ax1.grid(True, alpha=0.3)

# Panel 2: Dimension halving — search space compression
ax2 = axes[0, 1]
ns = np.arange(1, 11)
generic = 2 * ns
palindromic = ns
ax2.bar(ns - 0.2, generic, 0.4, label='Generic monic (2n params)', color='#3498db', alpha=0.8)
ax2.bar(ns + 0.2, palindromic, 0.4, label='Self-reciprocal (n params)', color='#e74c3c', alpha=0.8)
ax2.set_xlabel('Half-degree $n$', fontsize=12)
ax2.set_ylabel('Free coefficients', fontsize=12)
ax2.set_title('Dimension Halving: $2n \\to n$ Parameters')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3, axis='y')

# Panel 3: SRI count vs asymptotic formula
ax3 = axes[1, 0]
q_vals = [3, 5, 7]
colors = ['#2ecc71', '#9b59b6', '#e67e22']
for q, color in zip(q_vals, colors):
    actual = []
    predicted = []
    n_range = []
    for n in range(1, 5):
        if q**n <= 5000:
            sri = count_sri(q, n)
            actual.append(sri)
            predicted.append(q**n / (2*n))
            n_range.append(n)
    ax3.plot(n_range, actual, 'o-', color=color, label=f'$q={q}$ actual')
    ax3.plot(n_range, predicted, 's--', color=color, alpha=0.5, label=f'$q={q}$, $q^n/(2n)$')

ax3.set_xlabel('Half-degree $n$', fontsize=12)
ax3.set_ylabel('Count $SRI(q,n)$', fontsize=12)
ax3.set_title('Self-Reciprocal Irreducible Count vs Prediction')
ax3.legend(fontsize=8, ncol=2)
ax3.set_yscale('log')
ax3.grid(True, alpha=0.3)

# Panel 4: GL vs Sp certificate density comparison
ax4 = axes[1, 1]
q = 7
n_range = range(1, 7)
gl_density = [necklace_count(q, n) / q**n for n in n_range]
sp_density_pred = [1 / (2*n) for n in n_range]
gl_density_pred = [1 / n for n in n_range]

# For Sp, compute actual where feasible
sp_density_actual = []
sp_n_actual = []
for n in n_range:
    if q**n <= 5000:
        sri = count_sri(q, n)
        sp_density_actual.append(sri / q**n)
        sp_n_actual.append(n)

ax4.plot(list(n_range), gl_density, 'o-', color='#3498db', label='$GL_n$ actual', markersize=6)
ax4.plot(list(n_range), gl_density_pred, '--', color='#3498db', alpha=0.5, label='$1/n$')
ax4.plot(sp_n_actual, sp_density_actual, 's-', color='#e74c3c', label='$Sp_{2n}$ actual', markersize=6)
ax4.plot(list(n_range), sp_density_pred, '--', color='#e74c3c', alpha=0.5, label='$1/(2n)$')

ax4.set_xlabel('Parameter $n$', fontsize=12)
ax4.set_ylabel('Certificate density', fontsize=12)
ax4.set_title(f'$GL_n$ vs $Sp_{{2n}}$ over $\\mathbb{{F}}_{{{q}}}$')
ax4.legend(fontsize=10)
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('certificate_density_visualization.png', dpi=150, bbox_inches='tight')
print("Saved certificate_density_visualization.png")
