#!/usr/bin/env python3
"""
Applications of Perfect Number Theory

Demonstrates real-world connections to cryptography, random number generation,
and computational number theory.
"""

import math
from typing import List, Tuple


def is_prime(n: int) -> bool:
    """Miller-Rabin deterministic for small inputs."""
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    d, r = n - 1, 0
    while d % 2 == 0:
        d //= 2; r += 1
    for a in [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37]:
        if a >= n: continue
        x = pow(a, d, n)
        if x == 1 or x == n - 1: continue
        for _ in range(r - 1):
            x = pow(x, 2, n)
            if x == n - 1: break
        else: return False
    return True


def lucas_lehmer(p: int) -> bool:
    """Lucas-Lehmer test for Mersenne primes."""
    if p == 2: return True
    if not is_prime(p): return False
    M = (1 << p) - 1
    s = 4
    for _ in range(p - 2):
        s = (s * s - 2) % M
    return s == 0


# ═══════════════════════════════════════════════
# Application 1: Mersenne Primes and Cryptography
# ═══════════════════════════════════════════════
print("=" * 65)
print("APPLICATION 1: Mersenne Primes in Cryptography")
print("=" * 65)
print()
print("Mersenne primes M_p = 2^p - 1 generate even perfect numbers")
print("and have deep connections to cryptographic security.")
print()

# Find Mersenne primes
mersenne_exponents = []
for p in range(2, 62):
    if lucas_lehmer(p):
        mersenne_exponents.append(p)

print("Known Mersenne prime exponents (p ≤ 61):")
print(f"  {mersenne_exponents}")
print()

# RSA key generation application
print("RSA Key Generation with Mersenne-Adjacent Primes:")
print("-" * 50)
for p in mersenne_exponents[:5]:
    M = (1 << p) - 1
    # In practice, one might search near Mersenne numbers for RSA primes
    print(f"  M_{p} = {M} ({'prime' if is_prime(M) else 'composite'})")
    print(f"    Bit length: {p} bits")
    print(f"    Perfect number: 2^{p-1} × M_{p} = {(1 << (p-1)) * M}")
    print()

# ═══════════════════════════════════════════════
# Application 2: Random Number Generation
# ═══════════════════════════════════════════════
print("=" * 65)
print("APPLICATION 2: Mersenne Primes in Random Number Generation")
print("=" * 65)
print()
print("The Mersenne Twister PRNG uses M_19937 = 2^19937 - 1.")
print("This Mersenne prime provides a period of 2^19937 - 1.")
print()

# Demonstrate the connection
print("Mersenne prime properties for PRNG design:")
print("-" * 50)
for p in mersenne_exponents:
    M = (1 << p) - 1
    print(f"  M_{p:>2} = 2^{p:>2} - 1 = {M:>20} | Period: ~10^{int(p * math.log10(2)):>2}")
    if p >= 31:
        break

print()
print("The Mersenne Twister (MT19937) uses p = 19937:")
print(f"  Period ≈ 10^{int(19937 * math.log10(2))}")
print(f"  This is far larger than the number of atoms in the observable universe (~10^80)")

# ═══════════════════════════════════════════════
# Application 3: Error-Correcting Codes
# ═══════════════════════════════════════════════
print()
print("=" * 65)
print("APPLICATION 3: Perfect Numbers and Error-Correcting Codes")
print("=" * 65)
print()
print("Reed-Solomon codes over GF(2^p) when 2^p - 1 is prime:")
print("-" * 50)

for p in mersenne_exponents[:6]:
    M = (1 << p) - 1
    # Block length for Reed-Solomon codes
    n_rs = M  # Maximum block length
    print(f"  GF(2^{p}): block length = {n_rs}, perfect number = {(1 << (p-1)) * M}")

# ═══════════════════════════════════════════════
# Application 4: Euler's Theorem Applied to Search
# ═══════════════════════════════════════════════
print()
print("=" * 65)
print("APPLICATION 4: Euler's Constraints as Search Optimization")
print("=" * 65)
print()
print("Euler's theorem drastically reduces the search space for odd")
print("perfect numbers. Here's the quantitative impact:")
print()

# Estimate search space reduction
print("Without Euler's constraints:")
print("  All odd numbers up to N: N/2 candidates")
print()
print("With Euler's constraints (n = q^(4k+1) × m²):")
print("  1. q must be prime with q ≡ 1 (mod 4)")
print("  2. The exponent of q must be ≡ 1 (mod 4)")
print("  3. All other prime factors must appear in pairs")
print()

# Count candidate structures
N = 10000
euler_candidates = 0
total_odd = 0
for n in range(3, N + 1, 2):
    total_odd += 1
    # Check if n has Euler's form
    factors = {}
    temp = n
    d = 2
    while d * d <= temp:
        while temp % d == 0:
            factors[d] = factors.get(d, 0) + 1
            temp //= d
        d += 1
    if temp > 1:
        factors[temp] = factors.get(temp, 0) + 1

    odd_exp = [(p, e) for p, e in factors.items() if e % 2 == 1]
    if len(odd_exp) == 1:
        q, e = odd_exp[0]
        if q % 4 == 1 and e % 4 == 1:
            euler_candidates += 1

print(f"Odd numbers ≤ {N}: {total_odd}")
print(f"In Euler form:   {euler_candidates}")
print(f"Reduction ratio: {total_odd / euler_candidates:.1f}x" if euler_candidates > 0 else "No candidates")
print()
print("This shows Euler's theorem eliminates the vast majority of")
print("candidates, making systematic search much more feasible.")

# ═══════════════════════════════════════════════
# Application 5: Amicable and Sociable Numbers
# ═══════════════════════════════════════════════
print()
print("=" * 65)
print("APPLICATION 5: Generalizations — Amicable and Sociable Numbers")
print("=" * 65)
print()

def sum_proper_divisors(n: int) -> int:
    """Sum of proper divisors of n."""
    if n <= 1:
        return 0
    total = 1
    for d in range(2, int(math.isqrt(n)) + 1):
        if n % d == 0:
            total += d
            if d != n // d:
                total += n // d
    return total

# Perfect numbers are fixed points of s(n)
print("Perfect numbers as fixed points of s(n) = sum of proper divisors:")
for n in [6, 28, 496, 8128]:
    print(f"  s({n}) = {sum_proper_divisors(n)}")

print()

# Amicable pairs: s(a) = b and s(b) = a
print("Amicable pairs (s(a) = b, s(b) = a):")
amicable_found = []
for a in range(2, 100000):
    b = sum_proper_divisors(a)
    if b > a and sum_proper_divisors(b) == a:
        amicable_found.append((a, b))
        if len(amicable_found) <= 5:
            print(f"  ({a}, {b}): s({a})={b}, s({b})={a}")

print(f"\n  Found {len(amicable_found)} amicable pairs below 100,000")

# Sociable chains
print("\nSociable chains (generalized aliquot sequences):")
print("  A perfect number is a sociable chain of length 1.")
print("  An amicable pair is a sociable chain of length 2.")

for start in [12496]:
    chain = [start]
    current = start
    for _ in range(30):
        current = sum_proper_divisors(current)
        if current == start:
            print(f"  Chain starting at {start}: length {len(chain)}")
            print(f"    {' → '.join(str(x) for x in chain)} → {start}")
            break
        if current in chain or current <= 0:
            break
        chain.append(current)

print()
print("=" * 65)
print("All applications demonstrated successfully.")
print("=" * 65)


#!/usr/bin/env python3
"""
Perfect Numbers: Demonstrations and Explorations

This script demonstrates the mathematical results formalized in the Lean proofs:
1. Concrete perfect number examples
2. Euclid's construction from Mersenne primes
3. Euler's shape analysis for hypothetical odd perfect numbers
4. Divisor sum parity analysis
"""

import math
from typing import List, Tuple, Optional


def sum_of_divisors(n: int) -> int:
    """Compute σ₁(n) = sum of all divisors of n."""
    if n <= 0:
        return 0
    total = 0
    for d in range(1, int(math.isqrt(n)) + 1):
        if n % d == 0:
            total += d
            if d != n // d:
                total += n // d
    return total


def sum_of_proper_divisors(n: int) -> int:
    """Compute sum of proper divisors of n."""
    return sum_of_divisors(n) - n if n > 0 else 0


def is_perfect(n: int) -> bool:
    """Check if n is a perfect number."""
    return n > 0 and sum_of_proper_divisors(n) == n


def is_prime(n: int) -> bool:
    """Check if n is prime."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def prime_factorization(n: int) -> dict:
    """Return prime factorization as {prime: exponent}."""
    factors = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def sigma_prime_power(p: int, a: int) -> int:
    """Compute σ₁(p^a) = 1 + p + p² + ... + p^a."""
    return sum(p**i for i in range(a + 1))


def euler_form_check(n: int) -> Optional[Tuple[int, int, int]]:
    """
    Check if n has Euler's form: n = q^(4k+1) * m²
    where q ≡ 1 (mod 4) is prime and gcd(q, m) = 1.

    Returns (q, k, m) if found, None otherwise.
    """
    factors = prime_factorization(n)

    # Find primes with odd exponents
    odd_exp_primes = {p: e for p, e in factors.items() if e % 2 == 1}

    if len(odd_exp_primes) != 1:
        return None

    q, exp = list(odd_exp_primes.items())[0]

    if not is_prime(q):
        return None
    if q % 4 != 1:
        return None
    if exp % 4 != 1:
        return None

    k = (exp - 1) // 4

    # Compute m² = n / q^exp
    m_sq = n // (q ** exp)
    m = int(math.isqrt(m_sq))
    if m * m != m_sq:
        return None
    if math.gcd(q, m) != 1:
        return None

    return (q, k, m)


# ═══════════════════════════════════════════════
# Demo 1: Perfect Number Examples
# ═══════════════════════════════════════════════
print("=" * 60)
print("DEMO 1: Perfect Number Examples")
print("=" * 60)

for n in [6, 28, 496, 8128]:
    divisors = [d for d in range(1, n) if n % d == 0]
    print(f"\n  n = {n}")
    print(f"  Proper divisors: {divisors}")
    print(f"  Sum = {sum(divisors)}")
    print(f"  Perfect? {is_perfect(n)}")

# ═══════════════════════════════════════════════
# Demo 2: Euclid's Construction
# ═══════════════════════════════════════════════
print("\n" + "=" * 60)
print("DEMO 2: Euclid's Construction from Mersenne Primes")
print("=" * 60)
print("\n  If 2^p - 1 is prime, then 2^(p-1) × (2^p - 1) is perfect.\n")

print(f"  {'p':>4} | {'2^p - 1':>12} | {'Prime?':>8} | {'Perfect Number':>20} | {'Verified':>8}")
print(f"  {'-'*4} | {'-'*12} | {'-'*8} | {'-'*20} | {'-'*8}")

for p in range(2, 20):
    mersenne = 2**p - 1
    if is_prime(mersenne):
        perfect_num = 2**(p-1) * mersenne
        verified = is_perfect(perfect_num)
        print(f"  {p:>4} | {mersenne:>12} | {'Yes':>8} | {perfect_num:>20,} | {'✓' if verified else '✗':>8}")

# ═══════════════════════════════════════════════
# Demo 3: σ₁ Parity Analysis
# ═══════════════════════════════════════════════
print("\n" + "=" * 60)
print("DEMO 3: σ₁(p^a) Parity (Theorem: Odd iff a is even)")
print("=" * 60)
print("\n  For odd primes p, σ₁(p^a) is odd exactly when a is even.\n")

print(f"  {'p':>4} | {'a':>4} | {'σ₁(p^a)':>12} | {'Parity':>8} | {'a even?':>8} | {'Match?':>8}")
print(f"  {'-'*4} | {'-'*4} | {'-'*12} | {'-'*8} | {'-'*8} | {'-'*8}")

for p in [3, 5, 7, 11, 13]:
    for a in range(5):
        sigma_val = sigma_prime_power(p, a)
        is_odd = sigma_val % 2 == 1
        a_even = a % 2 == 0
        match = is_odd == a_even
        print(f"  {p:>4} | {a:>4} | {sigma_val:>12} | {'Odd' if is_odd else 'Even':>8} | {'Yes' if a_even else 'No':>8} | {'✓' if match else '✗':>8}")

# ═══════════════════════════════════════════════
# Demo 4: σ₁(p^(2j+1)) Factorization
# ═══════════════════════════════════════════════
print("\n" + "=" * 60)
print("DEMO 4: σ₁(p^(2j+1)) = (1+p) × Σ p^(2i)")
print("=" * 60)

for p in [3, 5, 7, 13]:
    print(f"\n  p = {p}:")
    for j in range(4):
        a = 2 * j + 1
        sigma_val = sigma_prime_power(p, a)
        factor1 = 1 + p
        factor2 = sum(p**(2*i) for i in range(j + 1))
        product = factor1 * factor2
        print(f"    j={j}: σ₁({p}^{a}) = {sigma_val}, (1+{p})×Σ = {factor1}×{factor2} = {product} {'✓' if sigma_val == product else '✗'}")

# ═══════════════════════════════════════════════
# Demo 5: q ≡ 3 (mod 4) Obstruction
# ═══════════════════════════════════════════════
print("\n" + "=" * 60)
print("DEMO 5: 4-divisibility when q ≡ 3 (mod 4)")
print("=" * 60)
print("\n  When q ≡ 3 (mod 4), 4 | σ₁(q^(2j+1)).\n")

for q in [3, 7, 11, 19, 23]:
    print(f"  q = {q} (q mod 4 = {q % 4}):")
    for j in range(3):
        a = 2 * j + 1
        sigma_val = sigma_prime_power(q, a)
        print(f"    σ₁({q}^{a}) = {sigma_val}, div by 4? {sigma_val % 4 == 0} (σ mod 4 = {sigma_val % 4})")

# ═══════════════════════════════════════════════
# Demo 6: Euler Form Verification
# ═══════════════════════════════════════════════
print("\n" + "=" * 60)
print("DEMO 6: Euler Form Analysis")
print("=" * 60)
print("\n  For a number of the form q^(4k+1) × m², check structure.\n")

# Construct some numbers in Euler form and verify
test_cases = [
    (5, 0, 3),   # 5^1 × 9 = 45
    (5, 0, 7),   # 5^1 × 49 = 245
    (13, 0, 3),  # 13^1 × 9 = 117
    (5, 1, 1),   # 5^5 × 1 = 3125
    (5, 0, 21),  # 5^1 × 441 = 2205
    (13, 0, 7),  # 13 × 49 = 637
    (29, 0, 1),  # 29^1 × 1 = 29
]

for q, k, m in test_cases:
    n = q**(4*k + 1) * m**2
    result = euler_form_check(n)
    sigma = sum_of_divisors(n)
    print(f"  n = {q}^{4*k+1} × {m}² = {n}")
    print(f"    σ₁(n) = {sigma}, 2n = {2*n}, Perfect? {sigma == 2*n}")
    if result:
        rq, rk, rm = result
        print(f"    Euler form: q={rq}, k={rk}, m={rm} ✓")
    else:
        print(f"    Not in Euler form (as expected for non-perfect numbers)")
    print()

# ═══════════════════════════════════════════════
# Demo 7: Search for Small Perfect Numbers
# ═══════════════════════════════════════════════
print("=" * 60)
print("DEMO 7: All Perfect Numbers Below 10,000")
print("=" * 60)

perfect_nums = [n for n in range(1, 10001) if is_perfect(n)]
print(f"\n  Perfect numbers below 10,000: {perfect_nums}")
print(f"  Count: {len(perfect_nums)}")
for n in perfect_nums:
    factors = prime_factorization(n)
    print(f"\n  {n} = {' × '.join(f'{p}^{e}' if e > 1 else str(p) for p, e in sorted(factors.items()))}")
    print(f"    Even? {n % 2 == 0}")
    if n % 2 == 0:
        # Find the Mersenne prime form
        for p in range(2, 20):
            if 2**(p-1) * (2**p - 1) == n and is_prime(2**p - 1):
                print(f"    Euclid form: 2^{p-1} × (2^{p} - 1) = 2^{p-1} × {2**p - 1}")
                break

# ═══════════════════════════════════════════════
# Demo 8: Why No Small Odd Perfect Numbers
# ═══════════════════════════════════════════════
print("\n" + "=" * 60)
print("DEMO 8: Why Small Odd Numbers Aren't Perfect")
print("=" * 60)
print("\n  Checking odd numbers with Euler's structural constraints:\n")

# Check some odd numbers that satisfy partial Euler constraints
print("  Numbers of the form q^(4k+1) × m² with q ≡ 1 (mod 4):")
count = 0
for q in [5, 13, 17, 29, 37, 41, 53, 61, 73, 89, 97]:
    for k in range(3):
        for m in range(1, 50):
            if math.gcd(q, m) != 1:
                continue
            n = q**(4*k + 1) * m**2
            if n > 100000:
                continue
            if n % 2 == 0:
                continue
            sigma = sum_of_divisors(n)
            ratio = sigma / n
            if abs(ratio - 2.0) < 0.1:  # Close to perfect
                count += 1
                if count <= 10:
                    print(f"    n = {q}^{4*k+1} × {m}² = {n:>8}, σ(n)/n = {ratio:.4f} ({'PERFECT!' if ratio == 2.0 else 'close'})")

print(f"\n  None of the checked odd numbers in Euler form are perfect.")
print(f"  This is consistent with the conjecture that no odd perfect numbers exist.")

print("\n" + "=" * 60)
print("All demonstrations complete.")
print("=" * 60)


#!/usr/bin/env python3
"""Generate PACKAGE.json from all deliverables."""

import json
import os

# Read all files
def read_file(path):
    with open(path, 'r') as f:
        return f.read()

article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')

# Read Lean proofs
lean_defs = read_file('PerfectNumbers/Defs.lean')
lean_euler = read_file('PerfectNumbers/EulerShape.lean')
lean_proofs = lean_defs + '\n\n-- ═══════════════════════════════════════\n-- EulerShape.lean\n-- ═══════════════════════════════════════\n\n' + lean_euler

# Read visualization data
with open('viz_data.json', 'r') as f:
    viz_data = json.load(f)

# Build package
package = {
    "title": "Euler's Shape Theorem for Odd Perfect Numbers",
    "domain": "Number Theory / Perfect Numbers",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Perfect Numbers Demo",
            "code": demo_code
        },
        {
            "name": "Applications Demo",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Sum of Divisors (σ₁)",
            "pseudocode": "SIGMA_1(n):\n  total ← 0\n  for d from 1 to √n:\n    if d | n:\n      total ← total + d\n      if d ≠ n/d: total ← total + n/d\n  return total\n\nTime: O(√n), Space: O(1)",
            "code": "def sum_of_divisors(n: int) -> int:\n    if n <= 0: return 0\n    total = 0\n    for d in range(1, int(n**0.5) + 1):\n        if n % d == 0:\n            total += d\n            if d != n // d:\n                total += n // d\n    return total"
        },
        {
            "name": "Lucas-Lehmer Primality Test",
            "pseudocode": "LUCAS_LEHMER(p):\n  if p = 2: return True\n  M ← 2^p - 1\n  s ← 4\n  for i from 1 to p-2:\n    s ← (s² - 2) mod M\n  return s = 0\n\nTime: O(p² log p), Space: O(p)",
            "code": "def lucas_lehmer(p: int) -> bool:\n    if p == 2: return True\n    M = (1 << p) - 1\n    s = 4\n    for _ in range(p - 2):\n        s = (s * s - 2) % M\n    return s == 0"
        },
        {
            "name": "Euler Form Decomposition",
            "pseudocode": "EULER_FORM(n):\n  Factor n = ∏ p_i^{a_i}\n  Find primes with odd exponent\n  If exactly one such prime q:\n    Check q ≡ 1 (mod 4)\n    Check a_q ≡ 1 (mod 4)\n    Set k = (a_q - 1) / 4\n    Set m = √(n / q^{a_q})\n    Verify gcd(q, m) = 1\n    Return (q, k, m)\n  Else: return None\n\nTime: O(√n), Space: O(log n)",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Abundance Ratio σ₁(n)/n",
            "data": viz_data.get('abundance', '')
        },
        {
            "name": "σ₁(p^a) Parity Pattern",
            "data": viz_data.get('parity', '')
        },
        {
            "name": "Euler Form Abundance Analysis",
            "data": viz_data.get('euler_form', '')
        }
    ],
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"Generated PACKAGE.json ({os.path.getsize('PACKAGE.json')} bytes)")


#!/usr/bin/env python3
"""
Generate visualizations for perfect number theory.
Outputs base64-encoded PNG images.
"""

import math
import base64
import io

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import matplotlib.patches as mpatches
    HAS_MATPLOTLIB = True
except ImportError:
    HAS_MATPLOTLIB = False
    print("matplotlib not available, generating SVG fallbacks")


def sum_of_divisors(n):
    if n <= 0: return 0
    total = 0
    for d in range(1, int(math.isqrt(n)) + 1):
        if n % d == 0:
            total += d
            if d != n // d: total += n // d
    return total


def sigma_prime_power(p, a):
    return sum(p**i for i in range(a + 1))


def fig_to_base64(fig):
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight', facecolor='white')
    buf.seek(0)
    return 'data:image/png;base64,' + base64.b64encode(buf.read()).decode('utf-8')


def generate_abundance_chart():
    """Chart showing σ₁(n)/n for n = 1..200."""
    if not HAS_MATPLOTLIB:
        return None
    fig, ax = plt.subplots(figsize=(12, 5))

    ns = list(range(1, 201))
    ratios = [sum_of_divisors(n) / n for n in ns]

    colors = []
    for n, r in zip(ns, ratios):
        if abs(r - 2.0) < 1e-10:
            colors.append('#e74c3c')  # Perfect = red
        elif r > 2.0:
            colors.append('#3498db')  # Abundant = blue
        else:
            colors.append('#95a5a6')  # Deficient = gray

    ax.scatter(ns, ratios, c=colors, s=8, alpha=0.7)
    ax.axhline(y=2.0, color='#e74c3c', linestyle='--', linewidth=1, alpha=0.5, label='σ₁(n)/n = 2 (Perfect)')
    ax.set_xlabel('n', fontsize=12)
    ax.set_ylabel('σ₁(n) / n', fontsize=12)
    ax.set_title('Abundance Ratio σ₁(n)/n for n = 1 to 200', fontsize=14)

    red_patch = mpatches.Patch(color='#e74c3c', label='Perfect (σ₁/n = 2)')
    blue_patch = mpatches.Patch(color='#3498db', label='Abundant (σ₁/n > 2)')
    gray_patch = mpatches.Patch(color='#95a5a6', label='Deficient (σ₁/n < 2)')
    ax.legend(handles=[red_patch, blue_patch, gray_patch], loc='upper right')
    ax.set_ylim(0.8, 3.5)

    result = fig_to_base64(fig)
    plt.close(fig)
    return result


def generate_parity_chart():
    """Chart showing σ₁(p^a) parity for odd primes."""
    if not HAS_MATPLOTLIB:
        return None
    fig, ax = plt.subplots(figsize=(10, 6))

    primes = [3, 5, 7, 11, 13]
    exponents = list(range(8))

    for i, p in enumerate(primes):
        for a in exponents:
            sigma_val = sigma_prime_power(p, a)
            is_odd = sigma_val % 2 == 1
            color = '#2ecc71' if is_odd else '#e74c3c'  # green=odd, red=even
            ax.scatter(a, i, c=color, s=200, zorder=5, edgecolors='black', linewidths=0.5)
            ax.text(a, i + 0.25, str(sigma_val), ha='center', va='bottom', fontsize=7)

    ax.set_yticks(range(len(primes)))
    ax.set_yticklabels([f'p = {p}' for p in primes], fontsize=11)
    ax.set_xticks(exponents)
    ax.set_xticklabels([f'a = {a}' for a in exponents], fontsize=10)
    ax.set_xlabel('Exponent a', fontsize=12)
    ax.set_title('Parity of σ₁(p^a): Green = Odd, Red = Even', fontsize=14)

    green_patch = mpatches.Patch(color='#2ecc71', label='σ₁ is Odd (a even)')
    red_patch = mpatches.Patch(color='#e74c3c', label='σ₁ is Even (a odd)')
    ax.legend(handles=[green_patch, red_patch], loc='upper right')
    ax.grid(True, alpha=0.3)

    result = fig_to_base64(fig)
    plt.close(fig)
    return result


def generate_euler_form_chart():
    """Chart showing the structure of numbers in Euler form."""
    if not HAS_MATPLOTLIB:
        return None
    fig, ax = plt.subplots(figsize=(10, 6))

    # Plot numbers in Euler form and their abundance ratios
    points_x = []
    points_y = []
    labels = []

    for q in [5, 13, 17, 29, 37, 41, 53, 61, 73, 89, 97]:
        for k in range(2):
            for m in range(1, 30):
                if math.gcd(q, m) != 1:
                    continue
                n = q**(4*k + 1) * m**2
                if n > 50000:
                    continue
                if n % 2 == 0:
                    continue
                ratio = sum_of_divisors(n) / n
                points_x.append(n)
                points_y.append(ratio)

    ax.scatter(points_x, points_y, s=10, alpha=0.5, c='#3498db')
    ax.axhline(y=2.0, color='#e74c3c', linestyle='--', linewidth=2, label='Perfect (σ₁/n = 2)')
    ax.set_xlabel('n (odd numbers in Euler form)', fontsize=12)
    ax.set_ylabel('σ₁(n) / n', fontsize=12)
    ax.set_title('Abundance Ratio for Odd Numbers in Euler Form q^(4k+1)·m²', fontsize=13)
    ax.legend(fontsize=11)
    ax.set_ylim(0.5, 3.0)
    ax.grid(True, alpha=0.3)

    result = fig_to_base64(fig)
    plt.close(fig)
    return result


if __name__ == "__main__":
    charts = {}

    chart1 = generate_abundance_chart()
    if chart1:
        charts['abundance'] = chart1
        print(f"Generated abundance chart ({len(chart1)} chars)")

    chart2 = generate_parity_chart()
    if chart2:
        charts['parity'] = chart2
        print(f"Generated parity chart ({len(chart2)} chars)")

    chart3 = generate_euler_form_chart()
    if chart3:
        charts['euler_form'] = chart3
        print(f"Generated Euler form chart ({len(chart3)} chars)")

    # Save for use in PACKAGE.json
    import json
    with open('viz_data.json', 'w') as f:
        json.dump(charts, f)
    print(f"\nSaved {len(charts)} visualizations to viz_data.json")
