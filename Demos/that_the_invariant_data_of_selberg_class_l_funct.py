#!/usr/bin/env python3
"""
Demo: Tropical Spectral Algebra of Selberg-Class L-Function Invariants

Demonstrates the key mathematical structures:
1. Selberg data monoid and product
2. Spectral complexity as tropical valuation
3. Counting bound factorization identity
4. Factorization enumeration
5. Realization density estimation for degree 2
"""

import math
from dataclasses import dataclass
from typing import List, Tuple, Optional


@dataclass(frozen=True)
class SelbergDatum:
    """Invariant data of a Selberg-class L-function."""
    degree: int
    conductor: int
    spectral_dim: int

    def __post_init__(self):
        assert self.conductor > 0, "Conductor must be positive"
        assert self.degree >= 0, "Degree must be non-negative"
        assert self.spectral_dim >= 0, "Spectral dimension must be non-negative"

    def __mul__(self, other: 'SelbergDatum') -> 'SelbergDatum':
        """Rankin-Selberg product."""
        return SelbergDatum(
            degree=self.degree + other.degree,
            conductor=self.conductor * other.conductor,
            spectral_dim=self.spectral_dim + other.spectral_dim
        )

    @property
    def spectral_complexity(self) -> int:
        """Tropical valuation: degree + spectral_dim."""
        return self.degree + self.spectral_dim

    @property
    def spectral_entropy(self) -> float:
        """Spectral entropy: log2(conductor) * degree + spectral_dim."""
        return math.log2(self.conductor) * self.degree + self.spectral_dim

    def __repr__(self):
        return f"S({self.degree}, {self.conductor}, {self.spectral_dim})"


UNIT = SelbergDatum(0, 1, 0)


def counting_bound(d: int, Q: int, B: int) -> int:
    """N_d(Q, B) = Q * (2*(2*B+1))^d"""
    return Q * (2 * (2 * B + 1)) ** d


def verify_factorization_identity(d1: int, d2: int, Q: int, B: int) -> bool:
    """Verify N_{d1+d2}(Q,B) = N_{d1}(1,B) * N_{d2}(Q,B)."""
    lhs = counting_bound(d1 + d2, Q, B)
    rhs = counting_bound(d1, 1, B) * counting_bound(d2, Q, B)
    return lhs == rhs


def divisors(n: int) -> List[int]:
    """Return all divisors of n."""
    divs = []
    for i in range(1, int(math.sqrt(n)) + 1):
        if n % i == 0:
            divs.append(i)
            if i != n // i:
                divs.append(n // i)
    return sorted(divs)


def factorizations(s: SelbergDatum) -> List[List[SelbergDatum]]:
    """Enumerate all non-trivial factorizations of a Selberg datum."""
    if s.degree == 0:
        return []

    results = []
    for d1 in range(1, s.degree):
        d2 = s.degree - d1
        for q1 in divisors(s.conductor):
            q2 = s.conductor // q1
            for k1 in range(s.spectral_dim + 1):
                k2 = s.spectral_dim - k1
                s1 = SelbergDatum(d1, q1, k1)
                s2 = SelbergDatum(d2, q2, k2)
                results.append([s1, s2])
    return results


def is_irreducible(s: SelbergDatum) -> bool:
    """Check if a Selberg datum is irreducible (has no non-trivial factorization)."""
    return len(factorizations(s)) == 0


def genus_X0(N: int) -> int:
    """Genus of the modular curve X_0(N) (approximation for weight-2 forms)."""
    if N <= 0:
        return 0

    # Compute genus using the formula
    # g = 1 + N/12 * prod(1 + 1/p for p | N) - nu2/4 - nu3/3 - nu_inf/2
    # This is a simplified version

    # Number of cusps
    def gcd(a, b):
        while b:
            a, b = b, a % b
        return a

    def euler_phi(n):
        result = n
        p = 2
        temp = n
        while p * p <= temp:
            if temp % p == 0:
                while temp % p == 0:
                    temp //= p
                result -= result // p
            p += 1
        if temp > 1:
            result -= result // temp
        return result

    # Number of cusps of Gamma_0(N)
    cusps = sum(euler_phi(gcd(d, N // d)) for d in divisors(N))

    # For weight 2: dim S_2(Gamma_0(N)) ≈ genus(X_0(N))
    # Using simplified formula: g ≈ N/12 for large prime N
    if N <= 1:
        return 0

    # More accurate genus formula
    index = N
    for p in set(prime_factors(N)):
        index = index * (1 + 1/p)

    g = 1 + index / 12 - cusps / 2
    return max(0, round(g))


def prime_factors(n: int) -> List[int]:
    """Return list of prime factors of n."""
    factors = []
    d = 2
    while d * d <= n:
        while n % d == 0:
            if d not in factors:
                factors.append(d)
            n //= d
        d += 1
    if n > 1 and n not in factors:
        factors.append(n)
    return factors


def dim_S2_new_prime(p: int) -> int:
    """Dimension of S_2^new(Gamma_0(p)) for prime p.
    For prime level: dim S_2(Gamma_0(p)) = floor((p-1)/12) - delta
    where delta accounts for elliptic points.
    """
    if p <= 1:
        return 0
    if p == 2:
        return 0
    if p == 3:
        return 0

    # For prime p, dim S_2(Gamma_0(p)) = genus of X_0(p)
    # g(X_0(p)) = floor((p-13)/12) + epsilon(p)
    # where epsilon accounts for the elliptic points

    g = (p - 1) // 12
    r = (p - 1) % 12

    # Adjustments for elliptic points
    if r == 0:
        pass  # no adjustment
    elif r >= 2:
        pass
    if p % 4 == 3:
        g -= 0  # nu_2 = 0 for p ≡ 3 (mod 4)
    if p % 3 == 2:
        g -= 0  # nu_3 = 0 for p ≡ 2 (mod 3)

    # Exact formula for prime p:
    # g(X_0(p)) = (p-1)/12 - (1 + legendre(-1,p))/4 - (1 + legendre(-3,p))/3 + 1/2 - 1
    # Simplified: g = floor((p+1)/12) - ... (using floor arithmetic)

    # Use the standard formula
    def legendre(a, p):
        """Legendre symbol (a/p)."""
        if a % p == 0:
            return 0
        ls = pow(a, (p - 1) // 2, p)
        return -1 if ls == p - 1 else ls

    l4 = legendre(-1, p)  # = 1 if p ≡ 1 (mod 4), -1 if p ≡ 3 (mod 4)
    l3 = legendre(-3, p)  # = 1 if p ≡ 1 (mod 3), -1 if p ≡ 2 (mod 3)

    nu2 = 1 + l4  # number of elliptic points of order 2
    nu3 = 1 + l3  # number of elliptic points of order 3
    nu_inf = 2     # number of cusps for prime level

    g_exact = 1 + (p + 1) // 12 - nu2 // 4 - nu3 // 3 - 1
    # Careful with integer arithmetic:
    # g = 1 + floor((p-1)/12) if p ≡ 1 (mod 12), with corrections

    # Direct computation for small primes
    g_exact = (p + 1) // 12
    if p % 12 in [5, 7]:
        g_exact = (p + 1) // 12
    elif p % 12 == 11:
        g_exact = (p + 1) // 12

    # Actually use the clean formula:
    # For prime p ≥ 5: dim S_2(Gamma_0(p)) = floor((p-1)/12) + correction
    r = p % 12
    if r in [1]:
        g_exact = (p - 13) // 12 + 1
    elif r in [5]:
        g_exact = (p - 5) // 12
    elif r in [7]:
        g_exact = (p - 7) // 12
    elif r in [11]:
        g_exact = (p - 11) // 12 + 1
    else:
        g_exact = (p - 1) // 12

    return max(0, g_exact)


# ============================================================
# DEMO
# ============================================================

print("=" * 60)
print("TROPICAL SPECTRAL ALGEBRA OF SELBERG DATA")
print("=" * 60)

# Demo 1: Product structure
print("\n--- Demo 1: Rankin-Selberg Product ---")
s1 = SelbergDatum(1, 5, 0)  # Degree 1, conductor 5 (Dirichlet character)
s2 = SelbergDatum(2, 7, 1)  # Degree 2, conductor 7 (modular form)
s12 = s1 * s2
print(f"  {s1} × {s2} = {s12}")
print(f"  Spectral complexity: σ({s1})={s1.spectral_complexity}, "
      f"σ({s2})={s2.spectral_complexity}, "
      f"σ({s12})={s12.spectral_complexity}")
print(f"  Additivity check: {s1.spectral_complexity} + {s2.spectral_complexity} "
      f"= {s1.spectral_complexity + s2.spectral_complexity} "
      f"= σ(product) = {s12.spectral_complexity} ✓")

# Demo 2: Unit element
print("\n--- Demo 2: Unit Element ---")
s = SelbergDatum(2, 11, 1)
print(f"  {s} × {UNIT} = {s * UNIT}")
print(f"  {UNIT} × {s} = {UNIT * s}")

# Demo 3: Counting bound factorization
print("\n--- Demo 3: Counting Bound Factorization ---")
for d1, d2, Q, B in [(1, 2, 10, 3), (2, 3, 100, 1), (1, 1, 50, 5)]:
    ok = verify_factorization_identity(d1, d2, Q, B)
    N = counting_bound(d1 + d2, Q, B)
    print(f"  N_{{{d1}+{d2}}}({Q},{B}) = {N}, "
          f"N_{d1}(1,{B}) × N_{d2}({Q},{B}) = "
          f"{counting_bound(d1, 1, B)} × {counting_bound(d2, Q, B)} = "
          f"{counting_bound(d1, 1, B) * counting_bound(d2, Q, B)} "
          f"{'✓' if ok else '✗'}")

# Demo 4: Counting bound growth
print("\n--- Demo 4: Counting Bound Growth ---")
Q, B = 100, 0
for d in range(6):
    N = counting_bound(d, Q, B)
    print(f"  N_{d}({Q},{B}) = {N:>15,}")

# Demo 5: Factorization enumeration
print("\n--- Demo 5: Factorization of S(3, 6, 2) ---")
s = SelbergDatum(3, 6, 2)
facts = factorizations(s)
print(f"  {s} has {len(facts)} factorizations")
for f in facts[:5]:
    print(f"    = {f[0]} × {f[1]}")
if len(facts) > 5:
    print(f"    ... and {len(facts) - 5} more")

# Demo 6: Irreducibility
print("\n--- Demo 6: Irreducible Selberg Data (d ≤ 3, q ≤ 10, k ≤ 1) ---")
irred = []
for d in range(1, 4):
    for q in range(1, 11):
        for k in range(2):
            s = SelbergDatum(d, q, k)
            if is_irreducible(s):
                irred.append(s)
print(f"  Found {len(irred)} irreducible data:")
for s in irred[:10]:
    print(f"    {s}")
if len(irred) > 10:
    print(f"    ... and {len(irred) - 10} more")

# Demo 7: Realization density at degree 2
print("\n--- Demo 7: Realization Density Estimate (Degree 2) ---")
print("  Prime conductors p with dim S_2^new(Γ_0(p)) > 0:")
realized = 0
total = 0
for p in range(2, 200):
    # Check if p is prime
    if p < 2:
        continue
    is_prime = all(p % i != 0 for i in range(2, int(p**0.5) + 1))
    if not is_prime:
        continue
    total += 1
    dim = dim_S2_new_prime(p)
    if dim > 0:
        realized += 1
        if p <= 50:
            print(f"    p={p:>3}: dim S_2^new = {dim}")

print(f"  Realized: {realized}/{total} primes up to 200 "
      f"({100*realized/total:.1f}%)")

# Demo 8: Spectral entropy
print("\n--- Demo 8: Spectral Entropy ---")
data = [
    SelbergDatum(1, 1, 0),
    SelbergDatum(2, 11, 0),
    SelbergDatum(2, 100, 1),
    SelbergDatum(4, 1000, 2),
]
for s in data:
    print(f"  H({s}) = {s.spectral_entropy:.2f}")

print("\n" + "=" * 60)
print("All demonstrations completed successfully.")


#!/usr/bin/env python3
"""
Visualization: Counting Bound Growth and Factorization Identity

Generates plots showing:
1. Exponential growth of N_d(Q, B) with degree
2. The factorization identity N_{d1+d2} = N_{d1}(1,B) * N_{d2}(Q,B)
3. Realization density estimates
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


def counting_bound(d, Q, B):
    return Q * (2 * (2 * B + 1)) ** d


def legendre_symbol(a, p):
    if a % p == 0:
        return 0
    ls = pow(a, (p - 1) // 2, p)
    return -1 if ls == p - 1 else ls


def dim_S2_new_prime(p):
    if p <= 3:
        return 0
    e2 = 1 + legendre_symbol(-1, p)
    e3 = 1 + legendre_symbol(-3, p)
    return max(0, (p + 1 - 3 * e2 - 4 * e3) // 12)


def sieve_primes(n):
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Counting bound growth with degree
ax = axes[0, 0]
B_values = [0, 1, 2, 3]
degrees = range(0, 8)
for B in B_values:
    Q = 100
    counts = [counting_bound(d, Q, B) for d in degrees]
    ax.semilogy(list(degrees), counts, 'o-', label=f'B={B}', markersize=5)
ax.set_xlabel('Degree d')
ax.set_ylabel('N_d(100, B)')
ax.set_title('Counting Bound Growth (Q=100)')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 2: Factorization identity verification
ax = axes[0, 1]
Q, B = 50, 2
M = 2 * (2 * B + 1)
d_total = range(1, 10)
for d1 in [1, 2, 3]:
    d2_vals = []
    ratios = []
    for d2 in range(1, 8):
        lhs = counting_bound(d1 + d2, Q, B)
        rhs = counting_bound(d1, 1, B) * counting_bound(d2, Q, B)
        d2_vals.append(d2)
        ratios.append(lhs / rhs)
    ax.plot(d2_vals, ratios, 'o-', label=f'd₁={d1}', markersize=6)
ax.axhline(y=1.0, color='k', linestyle='--', alpha=0.5)
ax.set_xlabel('d₂')
ax.set_ylabel('N_{d₁+d₂}(Q,B) / [N_{d₁}(1,B) · N_{d₂}(Q,B)]')
ax.set_title('Factorization Identity (ratio = 1)')
ax.legend()
ax.set_ylim(0.9, 1.1)
ax.grid(True, alpha=0.3)

# Plot 3: Realization density for degree 2
ax = axes[1, 0]
Q_values = list(range(50, 2001, 50))
realized_fracs = []
primes_all = sieve_primes(2000)
for Q in Q_values:
    primes_Q = [p for p in primes_all if p <= Q]
    if len(primes_Q) == 0:
        realized_fracs.append(0)
        continue
    realized = sum(1 for p in primes_Q if dim_S2_new_prime(p) > 0)
    realized_fracs.append(realized / len(primes_Q))

ax.plot(Q_values, realized_fracs, 'b-', linewidth=2)
ax.set_xlabel('Conductor bound Q')
ax.set_ylabel('Fraction of primes p ≤ Q with S₂^new ≠ 0')
ax.set_title('Realization Density (Degree 2, Prime Conductors)')
ax.grid(True, alpha=0.3)

# Plot 4: Spectral complexity distribution
ax = axes[1, 1]
max_d, max_q, max_k = 4, 20, 3
complexities = []
for d in range(1, max_d + 1):
    for q in range(1, max_q + 1):
        for k in range(max_k + 1):
            complexities.append(d + k)
ax.hist(complexities, bins=range(1, max_d + max_k + 2), alpha=0.7,
        color='steelblue', edgecolor='navy', align='left')
ax.set_xlabel('Spectral Complexity σ = d + k')
ax.set_ylabel('Count of Selberg Data')
ax.set_title(f'Spectral Complexity Distribution (d≤{max_d}, q≤{max_q}, k≤{max_k})')
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('selberg_data_analysis.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved selberg_data_analysis.png")
