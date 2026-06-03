#!/usr/bin/env python3
"""
Mandelbrot Number Theory Demo
============================

Demonstrates the connection between Mandelbrot iteration z_{n+1} = z_n^2 + c
and number theory: orbit periodicity, GCD structure, and dynatomic degrees.
"""

def mandelbrot_iter(c, n, ring=None):
    """Compute z_n = f_c^n(0) where f_c(z) = z^2 + c.
    
    If ring is an integer > 0, compute modulo ring.
    """
    z = 0
    for _ in range(n):
        z = z * z + c
        if ring and ring > 0:
            z = z % ring
    return z


def orbit(c, length, modulus=None):
    """Return the first `length` values of the Mandelbrot orbit of 0."""
    z = 0
    result = [z]
    for _ in range(length - 1):
        z = z * z + c
        if modulus:
            z = z % modulus
        result.append(z)
    return result


def find_period(c, max_iter=100, modulus=None):
    """Find the minimal period of the orbit (return to 0)."""
    z = 0
    for n in range(1, max_iter + 1):
        z = z * z + c
        if modulus:
            z = z % modulus
        if z == 0:
            return n
    return None


def orbit_multiplier(c, q):
    """Compute the orbit multiplier: product of 2*z_i for i=0..q-1."""
    product = 1
    z = 0
    for _ in range(q):
        product *= 2 * z
        z = z * z + c
    return product


def mandelbrot_polynomial_roots_mod_p(p, n):
    """Count c in Z/pZ with f_c^n(0) = 0 mod p."""
    count = 0
    for c in range(p):
        if mandelbrot_iter(c, n, ring=p) == 0:
            count += 1
    return count


def moebius(n):
    """Compute the Möbius function μ(n)."""
    if n == 1:
        return 1
    factors = []
    d = 2
    temp = n
    while d * d <= temp:
        if temp % d == 0:
            count = 0
            while temp % d == 0:
                temp //= d
                count += 1
            if count > 1:
                return 0
            factors.append(d)
        d += 1
    if temp > 1:
        factors.append(temp)
    return (-1) ** len(factors)


def divisors(n):
    """Return all divisors of n."""
    divs = []
    for d in range(1, n + 1):
        if n % d == 0:
            divs.append(d)
    return divs


def dynat_degree(n):
    """Compute the dynatomic degree via Möbius inversion."""
    return sum(moebius(n // d) * 2**(d - 1) for d in divisors(n))


from math import gcd

print("=" * 60)
print("MANDELBROT NUMBER THEORY: DEMONSTRATION")
print("=" * 60)

# Demo 1: Orbit Shift Theorem
print("\n--- Demo 1: Orbit Shift Theorem ---")
print("If f^m(0) = 0, then f^{m+k}(0) = f^k(0)")
for c in [-1, 0]:
    period = find_period(c)
    if period:
        print(f"\nc = {c}, period = {period}")
        orb = orbit(c, 2 * period + 3)
        print(f"  Orbit: {orb}")
        for k in range(4):
            val_mk = mandelbrot_iter(c, period + k)
            val_k = mandelbrot_iter(c, k)
            print(f"  f^{{{period}+{k}}}(0) = {val_mk} = f^{k}(0) = {val_k}  ✓" 
                  if val_mk == val_k else f"  MISMATCH!")

# Demo 2: GCD Theorem
print("\n--- Demo 2: Mandelbrot GCD Theorem ---")
print("If f^m(0) = 0 and f^n(0) = 0, then f^{gcd(m,n)}(0) = 0")
# Use modular arithmetic for interesting examples
for p in [5, 7, 11, 13]:
    print(f"\nmod {p}:")
    returns = []
    for n in range(1, 30):
        for c in range(p):
            if mandelbrot_iter(c, n, ring=p) == 0 and c != 0:
                returns.append((c, n))
    # Check GCD theorem
    if len(returns) >= 2:
        c0, m = returns[0]
        c1, n = returns[1]
        if c0 == c1:
            g = gcd(m, n)
            val = mandelbrot_iter(c0, g, ring=p)
            print(f"  c={c0}: f^{m}=0, f^{n}=0, f^gcd({m},{n})=f^{g}={val}  {'✓' if val == 0 else '✗'}")

# Demo 3: Orbit Multiplier
print("\n--- Demo 3: Orbit Multiplier (Superattracting) ---")
print("orbitMultiplier(c, q) = 0 for all q ≥ 1 (factor 2·z_0 = 0)")
for c in [0, -1, -2, 0.25]:
    for q in [1, 2, 3, 5]:
        mult = orbit_multiplier(c, q)
        print(f"  c={c:5}, q={q}: multiplier = {mult}")

# Demo 4: Period-2 Classification
print("\n--- Demo 4: Exact Period-2 Classification ---")
print("f²(0) = 0 and f(0) ≠ 0 iff c = -1")
for c in range(-5, 5):
    f1 = mandelbrot_iter(c, 1)
    f2 = mandelbrot_iter(c, 2)
    if f2 == 0 and f1 != 0:
        print(f"  c = {c}: exact period 2 ✓")

# Demo 5: Dynatomic Degrees
print("\n--- Demo 5: Dynatomic Degrees ---")
print("dynatDegree(n) = Σ_{d|n} μ(n/d) · 2^{d-1}")
print(f"{'n':>4} | {'dynatDegree(n)':>15} | {'Σ_{d|n} dynatDeg(d)':>20} | {'2^{n-1}':>10}")
print("-" * 60)
for n in range(1, 13):
    dd = dynat_degree(n)
    total = sum(dynat_degree(d) for d in divisors(n))
    expected = 2 ** (n - 1)
    check = "✓" if total == expected else "✗"
    print(f"{n:4d} | {dd:15d} | {total:20d} | {expected:10d}  {check}")

# Demo 6: Root counts mod p
print("\n--- Demo 6: Mandelbrot Polynomial Roots mod p ---")
print("Number of c ∈ 𝔽_p with P_n(c) = 0")
primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
for n in range(1, 6):
    print(f"\nn = {n} (deg P_n = {2**(n-1)}):")
    for p in primes:
        roots = mandelbrot_polynomial_roots_mod_p(p, n)
        print(f"  p={p:3d}: {roots} roots", end="")
    print()

print("\n" + "=" * 60)
print("All demonstrations complete.")


#!/usr/bin/env python3
"""
Visualization: Mandelbrot Orbit Period Structure
=================================================

Shows the period structure of Mandelbrot orbits modulo various primes,
illustrating the GCD theorem and dynatomic degree decomposition.
"""

import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np


def mandelbrot_iter_mod(c, n, modulus):
    z = 0
    for _ in range(n):
        z = (z * z + c) % modulus
    return z


def find_period_mod(c, modulus, max_iter=200):
    z = 0
    for n in range(1, max_iter + 1):
        z = (z * z + c) % modulus
        if z == 0:
            return n
    return 0


def moebius(n):
    if n == 1:
        return 1
    num_factors = 0
    d = 2
    temp = n
    while d * d <= temp:
        if temp % d == 0:
            count = 0
            while temp % d == 0:
                temp //= d
                count += 1
            if count > 1:
                return 0
            num_factors += 1
        d += 1
    if temp > 1:
        num_factors += 1
    return (-1) ** num_factors


def divisors(n):
    return [d for d in range(1, n + 1) if n % d == 0]


def dynat_degree(n):
    return sum(moebius(n // d) * (2 ** (d - 1)) for d in divisors(n))


fig, axes = plt.subplots(2, 2, figsize=(14, 12))

# Plot 1: Period heatmap — period of Mandelbrot orbit mod p for each c
ax1 = axes[0, 0]
primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
max_p = max(primes)
period_data = np.zeros((len(primes), max_p))
period_data[:] = np.nan

for i, p in enumerate(primes):
    for c in range(p):
        period_data[i, c] = find_period_mod(c, p)

cmap = plt.cm.viridis.copy()
cmap.set_bad('white')
im = ax1.imshow(period_data, aspect='auto', cmap=cmap, interpolation='nearest')
ax1.set_yticks(range(len(primes)))
ax1.set_yticklabels(primes)
ax1.set_xlabel('c (parameter mod p)')
ax1.set_ylabel('Prime p')
ax1.set_title('Mandelbrot Orbit Period mod p')
plt.colorbar(im, ax=ax1, label='Period')

# Plot 2: Root count vs prime — how many c ∈ F_p have P_n(c) = 0
ax2 = axes[0, 1]
test_primes = [p for p in range(3, 100) if all(p % d != 0 for d in range(2, int(p**0.5) + 1))]

for n in range(1, 6):
    root_counts = []
    for p in test_primes:
        count = sum(1 for c in range(p) if mandelbrot_iter_mod(c, n, p) == 0)
        root_counts.append(count)
    ax2.plot(test_primes, root_counts, 'o-', markersize=3, label=f'n={n} (deg={2**(n-1)})')
    ax2.axhline(y=2**(n-1), color='gray', linestyle='--', alpha=0.3)

ax2.set_xlabel('Prime p')
ax2.set_ylabel('Number of roots of P_n mod p')
ax2.set_title('Mandelbrot Polynomial Root Counts')
ax2.legend(fontsize=8)
ax2.grid(True, alpha=0.3)

# Plot 3: Dynatomic degrees — Möbius inversion
ax3 = axes[1, 0]
ns = list(range(1, 21))
dds = [dynat_degree(n) for n in ns]
cumulative = [sum(dynat_degree(d) for d in divisors(n)) for n in ns]
expected = [2**(n-1) for n in ns]

ax3.bar([n - 0.2 for n in ns], dds, width=0.4, label='dynatDegree(n)', color='steelblue')
ax3.plot(ns, expected, 'r-o', markersize=4, label='2^{n-1} = deg(P_n)')
ax3.set_xlabel('Period n')
ax3.set_ylabel('Degree')
ax3.set_title('Dynatomic Degrees via Möbius Inversion')
ax3.legend()
ax3.set_yscale('log')
ax3.grid(True, alpha=0.3)

# Plot 4: GCD theorem verification — visual proof
ax4 = axes[1, 1]
p = 23
verified = []
for c in range(p):
    returns = []
    for n in range(1, 50):
        if mandelbrot_iter_mod(c, n, p) == 0:
            returns.append(n)
    if len(returns) >= 2:
        for i in range(min(len(returns), 5)):
            for j in range(i + 1, min(len(returns), 5)):
                m, n = returns[i], returns[j]
                from math import gcd
                g = gcd(m, n)
                fg = mandelbrot_iter_mod(c, g, p)
                verified.append((c, m, n, g, fg == 0))

if verified:
    cs = [v[0] for v in verified]
    gs = [v[3] for v in verified]
    colors = ['green' if v[4] else 'red' for v in verified]
    ax4.scatter(cs, gs, c=colors, alpha=0.6, s=20)

ax4.set_xlabel('Parameter c (mod 23)')
ax4.set_ylabel('gcd(m, n)')
ax4.set_title(f'GCD Theorem Verification (mod {p})\nGreen = f^gcd=0 ✓')
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('mandelbrot_number_theory.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved mandelbrot_number_theory.png")
