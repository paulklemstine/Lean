#!/usr/bin/env python3
"""
applications.py — Real-world applications of ABC conjecture theory

Demonstrates:
1. Cryptographic key analysis via radical structure
2. Error-correcting code design using squarefree characterization
3. Number-theoretic optimization using radical bounds
"""

from math import gcd, log, prod, factorial, isqrt
from typing import Dict, List, Tuple, Set


def factorize(n: int) -> Dict[int, int]:
    """Prime factorization of n."""
    if n <= 1:
        return {}
    factors: Dict[int, int] = {}
    d = 2
    temp = abs(n)
    while d * d <= temp:
        while temp % d == 0:
            factors[d] = factors.get(d, 0) + 1
            temp //= d
        d += 1
    if temp > 1:
        factors[temp] = 1
    return factors


def radical(n: int) -> int:
    """Product of distinct prime factors."""
    if n <= 1:
        return 1
    return prod(factorize(n).keys())


def is_squarefree(n: int) -> bool:
    """Check if n is squarefree (equivalent to rad(n) == n for n >= 1)."""
    return radical(n) == n


# ─── Application 1: Cryptographic Key Quality Analysis ────────────────────

def key_quality_score(n: int) -> Dict[str, float]:
    """
    Analyze the 'quality' of a number as a cryptographic modulus.

    Numbers with high radical (close to n itself) are squarefree and have
    many distinct prime factors — desirable for RSA-like schemes.
    Numbers with low radical relative to n have repeated prime factors,
    making them vulnerable to factoring attacks.

    Returns quality metrics based on radical theory.
    """
    r = radical(n)
    factors = factorize(n)

    return {
        "radical": r,
        "redundancy": n / r if r > 0 else float('inf'),
        "squarefree": r == n,
        "distinct_primes": len(factors),
        "max_exponent": max(factors.values()) if factors else 0,
        "security_score": log(r) / log(n) if n > 1 else 0.0,
    }


# ─── Application 2: Diophantine Feasibility Testing ──────────────────────

def check_abc_feasibility(target_c: int, epsilon: float = 0.5) -> List[Tuple[int, int, float]]:
    """
    Given a target c, find all (a, b) with a + b = c, gcd(a,b) = 1,
    and check if the ABC quality exceeds 1 + epsilon.

    This has applications in testing Diophantine equations: if the
    ABC conjecture holds, equations producing high-quality triples
    can have only finitely many solutions.
    """
    results = []
    for a in range(1, (target_c + 1) // 2):
        b = target_c - a
        if gcd(a, b) != 1:
            continue
        r = radical(a * b * target_c)
        if r <= 1:
            continue
        quality = log(target_c) / log(r)
        if quality > 1 + epsilon:
            results.append((a, b, quality))
    return results


# ─── Application 3: Smooth Number Detection ──────────────────────────────

def smoothness_analysis(n: int) -> Dict[str, any]:
    """
    Analyze the 'smoothness' of n using radical theory.

    B-smooth numbers (all prime factors ≤ B) are important in:
    - Quadratic sieve factoring
    - Discrete logarithm computation
    - Elliptic curve factoring

    The radical gives a quick smoothness indicator.
    """
    factors = factorize(n)
    if not factors:
        return {"is_smooth": True, "smoothness_bound": 1, "radical": 1}

    max_prime = max(factors.keys())
    r = radical(n)

    return {
        "smoothness_bound": max_prime,
        "radical": r,
        "is_powersmooth": all(p ** e <= max_prime for p, e in factors.items()),
        "distinct_primes": len(factors),
        "total_prime_power": sum(factors.values()),
    }


# ─── Application 4: Primorial Bounds and Information Theory ──────────────

def information_content(n: int) -> Dict[str, float]:
    """
    Compute information-theoretic quantities related to n's factorization.

    The 'radical entropy' framework connects:
    - log(rad(n)): 'essential' information content
    - log(n): total information
    - log(n) - log(rad(n)): 'redundant' information (from repeated factors)

    In the ABC framework, the conjecture bounds how much redundancy
    can exist in a + b = c relationships.
    """
    r = radical(n)
    factors = factorize(n)

    if n <= 1:
        return {"total_bits": 0, "essential_bits": 0, "redundant_bits": 0,
                "efficiency": 1.0}

    total = log(n, 2)
    essential = log(r, 2) if r > 1 else 0
    redundant = total - essential

    return {
        "total_bits": total,
        "essential_bits": essential,
        "redundant_bits": redundant,
        "efficiency": essential / total if total > 0 else 1.0,
        "factors": factors,
    }


def main():
    print("=" * 70)
    print("APPLICATIONS OF ABC CONJECTURE THEORY")
    print("=" * 70)

    # App 1: Key quality
    print("\n--- Application 1: Cryptographic Key Quality ---")
    test_keys = [
        2**10 * 3**5,        # Very redundant
        2 * 3 * 5 * 7 * 11,  # Squarefree
        2**16,                # Pure power
        15485863 * 32452843,  # Two large primes (RSA-like)
    ]
    for n in test_keys:
        quality = key_quality_score(n)
        print(f"\n  n = {n}")
        for k, v in quality.items():
            print(f"    {k}: {v}")

    # App 2: Diophantine feasibility
    print("\n\n--- Application 2: Diophantine Feasibility ---")
    for c in [81, 243, 1024, 6561]:
        results = check_abc_feasibility(c, 0.3)
        print(f"\n  c = {c}: {len(results)} high-quality decompositions")
        for a, b, q in results[:5]:
            print(f"    {a} + {b} = {c}, quality = {q:.4f}")

    # App 3: Smoothness
    print("\n\n--- Application 3: Smooth Number Analysis ---")
    for n in [720720, 2**20, 30030, 223092870]:
        analysis = smoothness_analysis(n)
        print(f"\n  n = {n}: {analysis}")

    # App 4: Information content
    print("\n\n--- Application 4: Information-Theoretic Analysis ---")
    for n in [360, 2310, 65536, 720720, 9699690]:
        info = information_content(n)
        print(f"\n  n = {n}:")
        print(f"    Total bits: {info['total_bits']:.2f}")
        print(f"    Essential bits: {info['essential_bits']:.2f}")
        print(f"    Redundant bits: {info['redundant_bits']:.2f}")
        print(f"    Efficiency: {info['efficiency']:.4f}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
demo.py — Demonstrations of ABC Conjecture Concepts

Concrete numerical examples illustrating the radical function,
ABC triples, quality measures, and consequences for Fermat-like equations.
"""

from math import gcd, log, prod
from typing import List, Tuple


def radical(n: int) -> int:
    """Compute the radical of n: the product of distinct prime factors."""
    if n <= 1:
        return 1
    factors = set()
    d = 2
    temp = abs(n)
    while d * d <= temp:
        if temp % d == 0:
            factors.add(d)
            while temp % d == 0:
                temp //= d
        d += 1
    if temp > 1:
        factors.add(temp)
    return prod(factors) if factors else 1


def prime_omega(n: int) -> int:
    """Count distinct prime factors of n."""
    if n <= 1:
        return 0
    count = 0
    d = 2
    temp = abs(n)
    while d * d <= temp:
        if temp % d == 0:
            count += 1
            while temp % d == 0:
                temp //= d
        d += 1
    if temp > 1:
        count += 1
    return count


def redundancy(n: int) -> float:
    """Compute n / rad(n), measuring prime factor 'redundancy'."""
    r = radical(n)
    return n / r if r > 0 else float('inf')


def abc_quality(a: int, b: int, c: int) -> float:
    """Compute the quality of an ABC triple: log(c) / log(rad(abc))."""
    r = radical(a * b * c)
    if r <= 1:
        return float('inf')
    return log(c) / log(r)


def find_abc_triples(limit: int, min_quality: float = 1.0) -> List[Tuple[int, int, int, float]]:
    """Find ABC triples (a, b, c) with a + b = c, gcd(a,b) = 1, and quality > min_quality."""
    triples = []
    for c in range(3, limit + 1):
        for a in range(1, c):
            b = c - a
            if a >= b:
                continue
            if gcd(a, b) != 1:
                continue
            q = abc_quality(a, b, c)
            if q > min_quality:
                triples.append((a, b, c, q))
    return sorted(triples, key=lambda x: -x[3])


def main():
    print("=" * 70)
    print("ABC CONJECTURE — NUMERICAL DEMONSTRATIONS")
    print("=" * 70)

    # Demo 1: Radical function
    print("\n--- Demo 1: The Radical Function ---")
    print(f"{'n':>8} {'rad(n)':>8} {'omega(n)':>10} {'redundancy':>12}")
    print("-" * 42)
    for n in [1, 2, 6, 8, 12, 30, 36, 60, 72, 100, 360, 1000, 2310]:
        r = radical(n)
        o = prime_omega(n)
        red = redundancy(n)
        print(f"{n:>8} {r:>8} {o:>10} {red:>12.2f}")

    # Demo 2: Radical of prime powers
    print("\n--- Demo 2: Radical of Prime Powers ---")
    print("rad(p^k) = p for all k >= 1:")
    for p in [2, 3, 5, 7, 11]:
        for k in [1, 2, 3, 4, 5]:
            r = radical(p ** k)
            print(f"  rad({p}^{k}) = rad({p**k}) = {r}")

    # Demo 3: Multiplicativity for coprimes
    print("\n--- Demo 3: Radical Multiplicativity for Coprimes ---")
    pairs = [(3, 4), (5, 8), (7, 9), (11, 13), (6, 35)]
    for a, b in pairs:
        assert gcd(a, b) == 1
        print(f"  rad({a}*{b}) = rad({a*b}) = {radical(a*b)}, "
              f"rad({a})*rad({b}) = {radical(a)}*{radical(b)} = {radical(a)*radical(b)}")

    # Demo 4: ABC triples with high quality
    print("\n--- Demo 4: ABC Triples with Quality > 1 (up to c=1000) ---")
    print(f"{'a':>6} {'b':>6} {'c':>6} {'rad(abc)':>10} {'quality':>10}")
    print("-" * 42)
    triples = find_abc_triples(1000, 1.0)
    for a, b, c, q in triples[:15]:
        r = radical(a * b * c)
        print(f"{a:>6} {b:>6} {c:>6} {r:>10} {q:>10.4f}")

    # Demo 5: Famous ABC triple examples
    print("\n--- Demo 5: Famous ABC Triples ---")
    famous = [
        (1, 8, 9, "1 + 2^3 = 3^2"),
        (5, 27, 32, "5 + 3^3 = 2^5"),
        (1, 80, 81, "1 + 2^4*5 = 3^4"),
        (32, 49, 81, "2^5 + 7^2 = 3^4"),
        (2, 6436341, 6436343, "2 + 3^10*23^5 = 109*59051"),
    ]
    for a, b, c, desc in famous:
        r = radical(a * b * c)
        q = abc_quality(a, b, c)
        print(f"  {desc}")
        print(f"    a={a}, b={b}, c={c}, rad(abc)={r}, quality={q:.4f}")
        print(f"    c > rad(abc)? {'YES' if c > r else 'NO'}")
        print()

    # Demo 6: Radical of factorials
    print("--- Demo 6: Radical of Factorials (rad(n!) >= n) ---")
    from math import factorial
    for n in range(2, 21):
        f = factorial(n)
        r = radical(f)
        print(f"  rad({n}!) = rad({f}) = {r} {'≥' if r >= n else '<'} {n}")

    # Demo 7: Fermat-like bounds
    print("\n--- Demo 7: Fermat Radical Bounds ---")
    print("For x^n + y^n = z^n hypothetically, rad(x^n * y^n * z^n) ≤ xyz:")
    for x, y, n in [(3, 4, 3), (5, 7, 4), (2, 3, 5)]:
        val = x**n * y**n
        # z doesn't satisfy Fermat, but we can show the radical bound
        r = radical(x**n * y**n)
        print(f"  rad({x}^{n}*{y}^{n}) = rad({x**n * y**n}) = {r} ≤ {x}*{y} = {x*y}? {'YES' if r <= x*y else 'NO'}")

    # Demo 8: Squarefree characterization
    print("\n--- Demo 8: Squarefree ↔ rad(n) = n ---")
    for n in range(1, 31):
        r = radical(n)
        is_sqfree = (r == n)
        print(f"  n={n:>3}, rad(n)={r:>3}, squarefree={is_sqfree}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization 1: ABC Triple Quality Distribution

Visualizes the quality q(a,b,c) = log(c)/log(rad(abc)) for ABC triples
with c up to a given limit. The ABC conjecture predicts that triples with
quality > 1+ε are finite for any ε > 0. This plot shows the distribution
of qualities, highlighting the "quality barrier" near 1.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import gcd, log, prod


def factorize(n):
    if n <= 1:
        return {}
    factors = {}
    d = 2
    temp = abs(n)
    while d * d <= temp:
        while temp % d == 0:
            factors[d] = factors.get(d, 0) + 1
            temp //= d
        d += 1
    if temp > 1:
        factors[temp] = 1
    return factors


def radical(n):
    if n <= 1:
        return 1
    return prod(factorize(n).keys())


def abc_quality(a, b, c):
    r = radical(a * b * c)
    if r <= 1:
        return float('inf')
    return log(c) / log(r)


# Find ABC triples
limit = 5000
qualities = []
cs = []

for c in range(3, limit + 1):
    for a in range(1, (c + 1) // 2):
        b = c - a
        if gcd(a, b) != 1:
            continue
        q = abc_quality(a, b, c)
        if q > 0.8:
            qualities.append(q)
            cs.append(c)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Scatter plot of quality vs c
ax1 = axes[0]
colors = ['#2ecc71' if q <= 1.0 else '#e74c3c' if q > 1.4 else '#f39c12'
          for q in qualities]
ax1.scatter(cs, qualities, c=colors, alpha=0.3, s=3, edgecolors='none')
ax1.axhline(y=1.0, color='#e74c3c', linestyle='--', linewidth=2,
            label='Quality = 1 (ABC threshold)')
ax1.axhline(y=1.5, color='#9b59b6', linestyle=':', linewidth=1.5,
            label='Quality = 1.5')
ax1.set_xlabel('c', fontsize=12)
ax1.set_ylabel('Quality q(a,b,c)', fontsize=12)
ax1.set_title(f'ABC Triple Quality Distribution (c ≤ {limit})', fontsize=13)
ax1.legend(fontsize=10)
ax1.set_ylim(0.8, max(qualities) + 0.1)

# Right: Histogram of qualities
ax2 = axes[1]
high_q = [q for q in qualities if q > 1.0]
low_q = [q for q in qualities if q <= 1.0]

ax2.hist(low_q, bins=50, alpha=0.7, color='#2ecc71', label=f'q ≤ 1 ({len(low_q)} triples)')
ax2.hist(high_q, bins=30, alpha=0.7, color='#e74c3c', label=f'q > 1 ({len(high_q)} triples)')
ax2.axvline(x=1.0, color='black', linestyle='--', linewidth=2)
ax2.set_xlabel('Quality q(a,b,c)', fontsize=12)
ax2.set_ylabel('Count', fontsize=12)
ax2.set_title('Distribution of ABC Triple Qualities', fontsize=13)
ax2.legend(fontsize=10)

plt.tight_layout()
plt.savefig('abc_quality_distribution.png', dpi=150, bbox_inches='tight')
print(f"Saved abc_quality_distribution.png")
print(f"Total triples found: {len(qualities)}")
print(f"Triples with quality > 1: {len(high_q)}")
if high_q:
    print(f"Maximum quality: {max(high_q):.4f}")


#!/usr/bin/env python3
"""
Visualization 3: Fermat Radical Bounds and the ABC-FLT Connection

Visualizes the key inequality rad(x^n * y^n * z^n) ≤ xyz that connects
the ABC conjecture to Fermat's Last Theorem. Shows how the radical
'collapses' exponential growth, creating a tension that (assuming ABC)
makes Fermat-type equations impossible for large exponents.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import prod, log


def factorize(n):
    if n <= 1:
        return {}
    factors = {}
    d = 2
    temp = abs(n)
    while d * d <= temp:
        while temp % d == 0:
            factors[d] = factors.get(d, 0) + 1
            temp //= d
        d += 1
    if temp > 1:
        factors[temp] = 1
    return factors


def radical(n):
    if n <= 1:
        return 1
    f = factorize(n)
    return prod(f.keys()) if f else 1


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: rad(x^n * y^n) vs xy for fixed x,y, varying n
ax1 = axes[0]
pairs = [(2, 3), (3, 5), (5, 7), (6, 7)]
ns = list(range(1, 16))

for x, y in pairs:
    rads = [radical(x**n * y**n) for n in ns]
    xy_bound = x * y
    ax1.plot(ns, rads, 'o-', markersize=4, label=f'rad({x}^n·{y}^n)')
    ax1.axhline(y=xy_bound, linestyle='--', alpha=0.4)

ax1.set_xlabel('Exponent n', fontsize=11)
ax1.set_ylabel('rad(x^n · y^n)', fontsize=11)
ax1.set_title('Radical Collapse of Powers', fontsize=12)
ax1.legend(fontsize=8)

# Panel 2: The ABC tension — log(z^n) vs log(rad(x^n y^n z^n)) for near-Fermat
ax2 = axes[1]
# For x^n + y^n, compute z^n (not exact Fermat, but z ≈ (x^n+y^n)^(1/n))
x_vals = [2, 3, 4, 5]
for x in x_vals:
    y = x + 1
    n_range = list(range(2, 12))
    log_zn = []
    log_rad = []
    for n in n_range:
        zn = x**n + y**n
        r = radical(x**n * y**n * zn)
        log_zn.append(log(zn))
        log_rad.append(log(r))

    ax2.plot(n_range, [lz / lr if lr > 0 else 0 for lz, lr in zip(log_zn, log_rad)],
             'o-', markersize=4, label=f'x={x}, y={y}')

ax2.axhline(y=1.0, color='red', linestyle='--', linewidth=2, alpha=0.7,
            label='Quality = 1 (ABC barrier)')
ax2.set_xlabel('Exponent n', fontsize=11)
ax2.set_ylabel('log(x^n+y^n) / log(rad(x^n·y^n·(x^n+y^n)))', fontsize=11)
ax2.set_title('ABC Quality Growth with Exponent', fontsize=12)
ax2.legend(fontsize=8)

# Panel 3: Heatmap of rad(x^n * y^n) / (xy) for various x, y at n=3
ax3 = axes[2]
size = 15
data = np.zeros((size, size))
for i in range(size):
    for j in range(size):
        x = i + 2
        y = j + 2
        n = 3
        r = radical(x**n * y**n)
        data[i, j] = r / (x * y)

im = ax3.imshow(data, cmap='RdYlGn_r', aspect='auto',
                origin='lower', vmin=0, vmax=1.1)
ax3.set_xlabel('y (offset by 2)', fontsize=11)
ax3.set_ylabel('x (offset by 2)', fontsize=11)
ax3.set_title('rad(x³·y³) / (x·y) — Always ≤ 1', fontsize=12)
plt.colorbar(im, ax=ax3, label='Ratio')

plt.tight_layout()
plt.savefig('fermat_radical_bounds.png', dpi=150, bbox_inches='tight')
print("Saved fermat_radical_bounds.png")


#!/usr/bin/env python3
"""
Visualization 2: The Radical Function and Information Compression

Shows how the radical function 'compresses' numbers by stripping exponents.
Plots rad(n) vs n, highlighting squarefree numbers (where rad(n) = n)
and highly composite numbers (where rad(n) << n). Also shows the
'compression ratio' log(rad(n))/log(n) as a measure of information efficiency.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import log, prod


def factorize(n):
    if n <= 1:
        return {}
    factors = {}
    d = 2
    temp = abs(n)
    while d * d <= temp:
        while temp % d == 0:
            factors[d] = factors.get(d, 0) + 1
            temp //= d
        d += 1
    if temp > 1:
        factors[temp] = 1
    return factors


def radical(n):
    if n <= 1:
        return 1
    f = factorize(n)
    return prod(f.keys()) if f else 1


N = 500
ns = list(range(1, N + 1))
rads = [radical(n) for n in ns]
is_sqfree = [r == n for r, n in zip(rads, ns)]
compression = [log(r) / log(n) if n > 1 and r > 0 else 1.0 for r, n in zip(rads, ns)]

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Top-left: rad(n) vs n
ax1 = axes[0, 0]
sqfree_x = [n for n, s in zip(ns, is_sqfree) if s]
sqfree_y = [r for r, s in zip(rads, is_sqfree) if s]
nonsqfree_x = [n for n, s in zip(ns, is_sqfree) if not s]
nonsqfree_y = [r for r, s in zip(rads, is_sqfree) if not s]

ax1.scatter(sqfree_x, sqfree_y, s=4, alpha=0.6, c='#2ecc71',
            label='Squarefree (rad=n)')
ax1.scatter(nonsqfree_x, nonsqfree_y, s=4, alpha=0.6, c='#e74c3c',
            label='Non-squarefree (rad<n)')
ax1.plot([1, N], [1, N], 'k--', alpha=0.3, linewidth=1, label='y = x')
ax1.set_xlabel('n', fontsize=11)
ax1.set_ylabel('rad(n)', fontsize=11)
ax1.set_title('Radical Function: rad(n) vs n', fontsize=12)
ax1.legend(fontsize=9)

# Top-right: Compression ratio
ax2 = axes[0, 1]
ax2.scatter(ns[1:], compression[1:], s=3, alpha=0.5, c='#3498db')
ax2.axhline(y=1.0, color='#2ecc71', linestyle='--', linewidth=1.5,
            label='Perfect efficiency (squarefree)', alpha=0.7)
ax2.set_xlabel('n', fontsize=11)
ax2.set_ylabel('log(rad(n)) / log(n)', fontsize=11)
ax2.set_title('Information Compression Ratio', fontsize=12)
ax2.set_ylim(0, 1.1)
ax2.legend(fontsize=9)

# Bottom-left: Redundancy n/rad(n)
ax3 = axes[1, 0]
redundancies = [n / r if r > 0 else 0 for n, r in zip(ns, rads)]
ax3.scatter(ns, redundancies, s=4, alpha=0.5,
            c=['#e74c3c' if r > 2 else '#f39c12' if r > 1 else '#2ecc71'
               for r in redundancies])
ax3.set_xlabel('n', fontsize=11)
ax3.set_ylabel('n / rad(n)', fontsize=11)
ax3.set_title('Redundancy: n / rad(n)', fontsize=12)
ax3.set_yscale('log')

# Bottom-right: Prime powers highlighted
ax4 = axes[1, 1]
# Show rad(n!) vs n (our proved theorem: rad(n!) >= n)
from math import factorial
fact_ns = list(range(2, 25))
fact_rads = [radical(factorial(n)) for n in fact_ns]
ax4.semilogy(fact_ns, fact_rads, 'o-', color='#9b59b6', markersize=5,
             label='rad(n!)')
ax4.semilogy(fact_ns, fact_ns, 's--', color='#e74c3c', markersize=4,
             label='n (lower bound)')
ax4.semilogy(fact_ns, [factorial(n) for n in fact_ns], '^:', color='#95a5a6',
             markersize=4, alpha=0.5, label='n!')
ax4.set_xlabel('n', fontsize=11)
ax4.set_ylabel('Value (log scale)', fontsize=11)
ax4.set_title('Radical of Factorials: rad(n!) ≥ n', fontsize=12)
ax4.legend(fontsize=9)

plt.tight_layout()
plt.savefig('radical_function_analysis.png', dpi=150, bbox_inches='tight')
print("Saved radical_function_analysis.png")
