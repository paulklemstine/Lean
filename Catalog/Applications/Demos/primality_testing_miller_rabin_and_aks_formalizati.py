#!/usr/bin/env python3
"""
Applications: Primality Testing in Practice

Demonstrates real-world applications of Miller-Rabin and AKS primality testing
in cryptography, random number generation, and computational number theory.
"""

import math
import random
import time
from typing import List, Tuple, Optional
from algorithms import (
    miller_rabin, miller_rabin_single_round, decompose_twos,
    euler_totient, all_miller_rabin_liars, jacobi_symbol,
    solovay_strassen, aks_primality_test, find_strong_pseudoprimes,
    is_perfect_power
)


# ============================================================
# CRYPTOGRAPHIC KEY GENERATION
# ============================================================

def generate_probable_prime(bits: int, rounds: int = 40) -> int:
    """
    Generate a probable prime of given bit length using Miller-Rabin.
    
    This mirrors what real cryptographic libraries do (e.g., OpenSSL).
    
    Expected attempts: O(bits) by the Prime Number Theorem
    Each attempt: O(rounds · bits²) for Miller-Rabin
    """
    while True:
        # Generate random odd number of correct bit length
        n = random.getrandbits(bits)
        n |= (1 << (bits - 1)) | 1  # Set MSB and LSB
        
        result = miller_rabin(n, k=rounds)
        if result.is_probable_prime:
            return n


def generate_safe_prime(bits: int, rounds: int = 40) -> int:
    """
    Generate a safe prime p where (p-1)/2 is also prime.
    
    Safe primes are important for Diffie-Hellman and related protocols.
    """
    while True:
        q = generate_probable_prime(bits - 1, rounds)
        p = 2 * q + 1
        if miller_rabin(p, k=rounds).is_probable_prime:
            return p


def rsa_key_generation_demo(bits: int = 64) -> dict:
    """
    Demonstrate RSA key generation using Miller-Rabin primality testing.
    """
    print(f"\n  Generating {bits}-bit RSA key pair...")
    
    start = time.time()
    p = generate_probable_prime(bits // 2)
    q = generate_probable_prime(bits // 2)
    while p == q:
        q = generate_probable_prime(bits // 2)
    
    n = p * q
    phi = (p - 1) * (q - 1)
    e = 65537
    while math.gcd(e, phi) != 1:
        e += 2
    d = pow(e, -1, phi)
    elapsed = time.time() - start
    
    # Test encryption/decryption
    message = random.randint(2, n - 1)
    ciphertext = pow(message, e, n)
    decrypted = pow(ciphertext, d, n)
    
    result = {
        'p': p, 'q': q, 'n': n, 'e': e, 'd': d,
        'message': message, 'ciphertext': ciphertext,
        'decrypted': decrypted, 'correct': message == decrypted,
        'time': elapsed
    }
    
    print(f"    p = {p}")
    print(f"    q = {q}")
    print(f"    n = {n}")
    print(f"    e = {e}")
    print(f"    Message: {message}")
    print(f"    Encrypted: {ciphertext}")
    print(f"    Decrypted: {decrypted}")
    print(f"    Correct: {result['correct']}")
    print(f"    Time: {elapsed:.4f}s")
    
    return result


# ============================================================
# PSEUDOPRIME ANALYSIS
# ============================================================

def carmichael_number_check(n: int) -> bool:
    """Check if n is a Carmichael number (composite and a^(n-1) ≡ 1 for all coprime a)."""
    if n < 4:
        return False
    # Check composite
    if all(n % i != 0 for i in range(2, int(n**0.5) + 1)):
        return False
    # Check Korselt's criterion
    for a in range(2, n):
        if math.gcd(a, n) == 1:
            if pow(a, n - 1, n) != 1:
                return False
    return True


def find_carmichael_numbers(limit: int) -> List[int]:
    """Find Carmichael numbers up to limit using Korselt's criterion."""
    result = []
    for n in range(3, limit, 2):
        # Quick composite check
        if all(n % i != 0 for i in range(2, min(int(n**0.5) + 1, 100))):
            continue
        if is_perfect_power(n) is not None:
            continue
        # Korselt's criterion: n is Carmichael iff
        # n is squarefree and (p-1) | (n-1) for all prime p | n
        factors = []
        temp = n
        p = 2
        is_squarefree = True
        while p * p <= temp:
            count = 0
            while temp % p == 0:
                temp //= p
                count += 1
            if count > 1:
                is_squarefree = False
                break
            if count == 1:
                factors.append(p)
            p += 1
        if temp > 1:
            factors.append(temp)
        
        if not is_squarefree or len(factors) < 3:
            continue
        
        if all((n - 1) % (p - 1) == 0 for p in factors):
            result.append(n)
    
    return result


def pseudoprime_statistics(limit: int = 1000) -> None:
    """Analyze pseudoprime statistics for various bases."""
    print(f"\n  Strong pseudoprimes to various bases up to {limit}:")
    
    for base in [2, 3, 5, 7, 11, 13]:
        spsp = find_strong_pseudoprimes(base, limit)
        print(f"    Base {base:>2}: {len(spsp)} strong pseudoprimes — {spsp[:5]}{'...' if len(spsp) > 5 else ''}")
    
    # Multi-base strong pseudoprimes
    print(f"\n  Numbers that fool multiple bases simultaneously:")
    multi_base_fools = {}
    for n in range(9, limit, 2):
        if all(n % i != 0 for i in range(2, int(n**0.5) + 1)):
            continue
        bases_fooled = []
        for b in [2, 3, 5, 7, 11, 13]:
            if miller_rabin_single_round(n, b):
                bases_fooled.append(b)
        if len(bases_fooled) >= 2:
            multi_base_fools[n] = bases_fooled
    
    for n, bases in sorted(multi_base_fools.items())[:10]:
        print(f"    n={n}: fools bases {bases}")


# ============================================================
# PERFORMANCE COMPARISON
# ============================================================

def benchmark_primality_tests() -> None:
    """Compare performance of different primality tests."""
    print("\n  Performance Comparison:")
    print(f"  {'Method':>20} | {'10-digit':>10} | {'15-digit':>10} | {'20-digit':>10}")
    print(f"  {'-'*20}-+-{'-'*10}-+-{'-'*10}-+-{'-'*10}")
    
    test_numbers = {
        '10-digit': 1000000007,
        '15-digit': 100000000000031,
        '20-digit': 10000000000000000051,
    }
    
    for method_name, method in [
        ('Miller-Rabin (k=1)', lambda n: miller_rabin(n, k=1).is_probable_prime),
        ('Miller-Rabin (k=10)', lambda n: miller_rabin(n, k=10).is_probable_prime),
        ('Miller-Rabin (k=40)', lambda n: miller_rabin(n, k=40).is_probable_prime),
        ('Solovay-Strassen', lambda n: solovay_strassen(n, k=20)),
    ]:
        times = {}
        for label, n in test_numbers.items():
            start = time.time()
            for _ in range(100):
                method(n)
            elapsed = (time.time() - start) / 100
            times[label] = f"{elapsed*1000:.3f}ms"
        
        print(f"  {method_name:>20} | {times['10-digit']:>10} | {times['15-digit']:>10} | {times['20-digit']:>10}")


# ============================================================
# INTERACTIVE DEMOS
# ============================================================

def demo_cryptographic_application():
    """Full demonstration of cryptographic primality testing."""
    print("=" * 60)
    print("APPLICATION: RSA Key Generation")
    print("=" * 60)
    rsa_key_generation_demo(64)


def demo_pseudoprime_landscape():
    """Explore the pseudoprime landscape."""
    print("\n" + "=" * 60)
    print("APPLICATION: Pseudoprime Landscape Analysis")
    print("=" * 60)
    
    print("\n  Carmichael numbers up to 10000:")
    carmichaels = find_carmichael_numbers(10000)
    for c in carmichaels:
        # Factor it
        factors = []
        temp = c
        p = 2
        while p * p <= temp:
            while temp % p == 0:
                factors.append(p)
                temp //= p
            p += 1
        if temp > 1:
            factors.append(temp)
        liars = all_miller_rabin_liars(c)
        print(f"    {c} = {'×'.join(map(str, factors))}, "
              f"MR liars: {len(liars)}/{c-1} = {len(liars)/(c-1):.4f}")
    
    pseudoprime_statistics()


def demo_performance():
    """Performance benchmarks."""
    print("\n" + "=" * 60)
    print("APPLICATION: Performance Benchmarks")
    print("=" * 60)
    benchmark_primality_tests()


def demo_prime_generation():
    """Prime generation for various applications."""
    print("\n" + "=" * 60)
    print("APPLICATION: Prime Number Generation")
    print("=" * 60)
    
    for bits in [16, 32, 64, 128]:
        start = time.time()
        p = generate_probable_prime(bits)
        elapsed = time.time() - start
        print(f"\n  {bits}-bit probable prime: {p}")
        print(f"    Time: {elapsed:.4f}s")
        print(f"    Digits: {len(str(p))}")
    
    print("\n  Safe prime generation:")
    for bits in [16, 32]:
        start = time.time()
        p = generate_safe_prime(bits)
        q = (p - 1) // 2
        elapsed = time.time() - start
        print(f"    {bits}-bit safe prime: p={p}, q=(p-1)/2={q}")
        print(f"    Time: {elapsed:.4f}s")


if __name__ == "__main__":
    print("\n" + "█" * 60)
    print("  PRIMALITY TESTING: Real-World Applications")
    print("█" * 60)
    
    demo_cryptographic_application()
    demo_pseudoprime_landscape()
    demo_prime_generation()
    demo_performance()
    
    print("\nAll application demos complete!")


#!/usr/bin/env python3
"""
Demo: Miller-Rabin and AKS Primality Testing

Demonstrates the key mathematical concepts behind randomized and
deterministic primality testing with concrete numerical examples.
"""

import math
import random
from typing import List, Tuple, Optional


def decompose_twos(m: int) -> Tuple[int, int]:
    """Decompose m = 2^s * d with d odd."""
    s = 0
    d = m
    while d % 2 == 0:
        d //= 2
        s += 1
    return s, d


def is_strong_pseudoprime_base(n: int, a: int) -> bool:
    """Check if a is a strong pseudoprime base for n (Miller-Rabin liar)."""
    if math.gcd(a, n) != 1:
        return False
    s, d = decompose_twos(n - 1)
    x = pow(a, d, n)
    if x == 1 or x == n - 1:
        return True
    for _ in range(s - 1):
        x = pow(x, 2, n)
        if x == n - 1:
            return True
    return False


def miller_rabin_liars(n: int) -> List[int]:
    """Find all Miller-Rabin liars for n in {1, ..., n-1}."""
    return [a for a in range(1, n) if is_strong_pseudoprime_base(n, a)]


def miller_rabin_test(n: int, k: int = 20) -> bool:
    """Miller-Rabin primality test with k rounds."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0:
        return False
    for _ in range(k):
        a = random.randint(2, n - 2)
        if not is_strong_pseudoprime_base(n, a):
            return False
    return True


def aks_polynomial_congruence(n: int, r: int, a: int) -> bool:
    """Check (X + a)^n ≡ X^n + a (mod n, X^r - 1) using polynomial arithmetic."""
    # Work with polynomials mod (n, X^r - 1)
    # Represent polynomial as list of coefficients mod n, length r
    
    # Start with (X + a) mod (n, X^r - 1)
    base = [0] * r
    base[0] = a % n  # constant term
    if r > 1:
        base[1] = 1  # X term
    elif r == 1:
        base[0] = (base[0] + 1) % n
    
    # Compute base^n mod (n, X^r - 1) by repeated squaring
    result = [0] * r
    result[0] = 1  # start with 1
    
    exp = n
    b = base[:]
    while exp > 0:
        if exp % 2 == 1:
            result = poly_mul_mod(result, b, n, r)
        b = poly_mul_mod(b, b, n, r)
        exp //= 2
    
    # Compute X^n + a mod (n, X^r - 1)
    target = [0] * r
    target[n % r] = (target[n % r] + 1) % n
    target[0] = (target[0] + a) % n
    
    return result == target


def poly_mul_mod(p1: List[int], p2: List[int], n: int, r: int) -> List[int]:
    """Multiply two polynomials mod (n, X^r - 1)."""
    result = [0] * r
    for i in range(r):
        if p1[i] == 0:
            continue
        for j in range(r):
            if p2[j] == 0:
                continue
            idx = (i + j) % r
            result[idx] = (result[idx] + p1[i] * p2[j]) % n
    return result


def order_mod(n: int, r: int) -> int:
    """Compute the multiplicative order of n modulo r."""
    if math.gcd(n, r) != 1:
        return 0
    order = 1
    current = n % r
    while current != 1:
        current = (current * n) % r
        order += 1
    return order


def euler_totient(n: int) -> int:
    """Compute Euler's totient function φ(n)."""
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


def is_perfect_power(n: int) -> bool:
    """Check if n is a perfect power (n = a^b, b ≥ 2)."""
    if n <= 3:
        return False
    for b in range(2, int(math.log2(n)) + 1):
        a = round(n ** (1.0 / b))
        for candidate in [a - 1, a, a + 1]:
            if candidate >= 2 and candidate ** b == n:
                return True
    return False


def aks_test(n: int) -> bool:
    """Simplified AKS primality test."""
    if n <= 1:
        return False
    if n <= 3:
        return True
    
    # Check perfect power
    if is_perfect_power(n):
        return False
    
    # Find suitable r
    max_k = int(math.log2(n)) ** 2
    r = 2
    while r < n:
        if math.gcd(n, r) > 1:
            if r == n:
                return True
            r += 1
            continue
        if order_mod(n, r) > max_k:
            break
        r += 1
    
    # Check for small factors
    for a in range(2, min(r + 1, n)):
        if n % a == 0:
            return n == a
    
    if n <= r:
        return True
    
    # Polynomial congruence checks
    bound = int(math.sqrt(euler_totient(r)) * math.log2(n))
    for a in range(1, bound + 1):
        if not aks_polynomial_congruence(n, r, a):
            return False
    
    return True


# ============================================================
# DEMONSTRATIONS
# ============================================================

def demo_two_adic_decomposition():
    """Show two-adic decompositions for various numbers."""
    print("=" * 60)
    print("TWO-ADIC DECOMPOSITION: m = 2^s · d (d odd)")
    print("=" * 60)
    for m in [1, 2, 3, 4, 6, 12, 24, 100, 1000, 340]:
        s, d = decompose_twos(m)
        print(f"  {m:>5} = 2^{s} × {d}")
    print()


def demo_miller_rabin_liars():
    """Demonstrate Miller-Rabin liars for small composites."""
    print("=" * 60)
    print("MILLER-RABIN LIARS FOR SMALL ODD COMPOSITES")
    print("=" * 60)
    composites = [9, 15, 21, 25, 27, 33, 35, 45, 49, 51, 55, 63, 65, 75, 77, 91]
    for n in composites:
        liars = miller_rabin_liars(n)
        ratio = len(liars) / (n - 1)
        quarter = (n - 1) / 4
        print(f"  n={n:>3}: liars={len(liars):>3}/{n-1}, "
              f"ratio={ratio:.4f}, bound=(n-1)/4={quarter:.1f}, "
              f"≤1/4? {'YES' if len(liars) <= quarter else 'NO'}")
    print()


def demo_carmichael_numbers():
    """Demonstrate Carmichael numbers - where Fermat test fails but MR succeeds."""
    print("=" * 60)
    print("CARMICHAEL NUMBERS: Fermat vs Miller-Rabin")
    print("=" * 60)
    carmichaels = [561, 1105, 1729, 2465, 2821, 6601]
    for n in carmichaels:
        # Fermat liars: a with a^(n-1) ≡ 1 (mod n) and gcd(a,n) = 1
        fermat_liars = sum(1 for a in range(1, n) 
                          if math.gcd(a, n) == 1 and pow(a, n-1, n) == 1)
        mr_liars_list = miller_rabin_liars(n)
        mr_count = len(mr_liars_list)
        euler_tot = euler_totient(n)
        
        print(f"  n={n}: φ(n)={euler_tot}, "
              f"Fermat liars={fermat_liars} ({fermat_liars/euler_tot*100:.1f}% of units), "
              f"MR liars={mr_count} ({mr_count/(n-1)*100:.1f}% of {n-1})")
    print()
    print("  Observation: Fermat liars = ALL units for Carmichael numbers!")
    print("  But MR liars are always ≤ (n-1)/4 for composites.\n")


def demo_aks_congruence():
    """Demonstrate the AKS polynomial congruence."""
    print("=" * 60)
    print("AKS POLYNOMIAL CONGRUENCE: (X+a)^n ≡ X^n+a mod (n, X^r-1)")
    print("=" * 60)
    
    # For primes, congruence always holds
    print("\n  Primes (should all pass):")
    for p in [2, 3, 5, 7, 11, 13]:
        results = []
        for r in [2, 3, 5]:
            for a in range(1, 4):
                results.append(aks_polynomial_congruence(p, r, a))
        print(f"    p={p:>2}: all pass? {all(results)}")
    
    # For composites, congruence fails for some a
    print("\n  Composites (should fail for some a):")
    for n in [4, 6, 9, 15, 21]:
        r = 3
        results = [(a, aks_polynomial_congruence(n, r, a)) for a in range(1, 6)]
        failures = [a for a, passed in results if not passed]
        print(f"    n={n:>2}, r={r}: failures at a={failures}")
    print()


def demo_error_amplification():
    """Demonstrate error amplification with repeated rounds."""
    print("=" * 60)
    print("ERROR AMPLIFICATION: k rounds → error ≤ (1/4)^k")
    print("=" * 60)
    print(f"\n  {'k rounds':>10} | {'Max error prob':>15} | {'Decimal':>15} | {'Bits of security':>18}")
    print(f"  {'-'*10}-+-{'-'*15}-+-{'-'*15}-+-{'-'*18}")
    for k in [1, 2, 5, 10, 20, 40, 64, 128]:
        error = (1/4) ** k
        bits = 2 * k
        if error > 1e-300:
            print(f"  {k:>10} | {'(1/4)^' + str(k):>15} | {error:>15.2e} | {bits:>18}")
        else:
            print(f"  {k:>10} | {'(1/4)^' + str(k):>15} | {'< 10^-300':>15} | {bits:>18}")
    print()


def demo_primality_testing():
    """Compare Miller-Rabin and AKS on various inputs."""
    print("=" * 60)
    print("PRIMALITY TESTING COMPARISON")
    print("=" * 60)
    
    test_numbers = [
        (2, "smallest prime"),
        (7, "small prime"),
        (15, "composite (3×5)"),
        (17, "prime"),
        (561, "Carmichael number"),
        (1009, "prime"),
        (1729, "Carmichael (Hardy-Ramanujan)"),
        (7919, "1000th prime"),
        (10007, "prime"),
        (10009, "prime"),
        (10201, "101²"),
    ]
    
    print(f"\n  {'n':>8} | {'MR result':>10} | {'AKS result':>10} | {'Actually prime?':>15} | Note")
    print(f"  {'-'*8}-+-{'-'*10}-+-{'-'*10}-+-{'-'*15}-+------")
    
    from sympy import isprime
    
    for n, note in test_numbers:
        mr = miller_rabin_test(n, k=20)
        try:
            ak = aks_test(n)
        except Exception:
            ak = "timeout"
        actual = isprime(n)
        match = "✓" if mr == actual else "✗"
        print(f"  {n:>8} | {str(mr):>10} | {str(ak):>10} | {str(actual):>15} | {note} {match}")
    print()


def demo_witness_density():
    """Show that witness density is always > 3/4 for composites."""
    print("=" * 60)
    print("WITNESS DENSITY: Always > 3/4 for odd composites")
    print("=" * 60)
    
    max_ratio = 0
    worst_n = 0
    
    for n in range(3, 500, 2):
        if all(n % i != 0 for i in range(2, int(n**0.5) + 1)):
            continue  # skip primes
        if n < 3:
            continue
        liars = miller_rabin_liars(n)
        ratio = len(liars) / (n - 1)
        if ratio > max_ratio:
            max_ratio = ratio
            worst_n = n
    
    print(f"\n  Worst case among odd composites 3..499:")
    print(f"    n = {worst_n}")
    print(f"    Liar ratio = {max_ratio:.6f}")
    print(f"    ≤ 1/4 = 0.25? {'YES' if max_ratio <= 0.25 else 'NO'}")
    
    liars = miller_rabin_liars(worst_n)
    s, d = decompose_twos(worst_n - 1)
    print(f"    {worst_n} - 1 = 2^{s} × {d}")
    print(f"    Liars: {liars}")
    print()


if __name__ == "__main__":
    print("\n" + "█" * 60)
    print("  PRIMALITY TESTING: Miller-Rabin & AKS Demonstration")
    print("█" * 60 + "\n")
    
    demo_two_adic_decomposition()
    demo_miller_rabin_liars()
    demo_carmichael_numbers()
    demo_aks_congruence()
    demo_error_amplification()
    demo_witness_density()
    
    # Only run full comparison if sympy available
    try:
        import sympy
        demo_primality_testing()
    except ImportError:
        print("(Skipping full comparison - sympy not installed)")
    
    print("Demo complete!")


#!/usr/bin/env python3
"""
Visualizations: Primality Testing

Generates publication-quality visualizations of Miller-Rabin liar densities,
pseudoprime distributions, error amplification, and AKS polynomial congruences.
"""

import math
import random
import base64
import io
from typing import List, Tuple, Dict

# Use Agg backend for headless rendering
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def decompose_twos(m: int) -> Tuple[int, int]:
    s, d = 0, m
    while d % 2 == 0:
        d //= 2
        s += 1
    return s, d


def miller_rabin_single_round(n: int, a: int) -> bool:
    if n < 2 or a % n == 0:
        return n >= 2
    s, d = decompose_twos(n - 1)
    x = pow(a, d, n)
    if x == 1 or x == n - 1:
        return True
    for _ in range(s - 1):
        x = pow(x, 2, n)
        if x == n - 1:
            return True
        if x == 1:
            return False
    return False


def all_liars(n: int) -> List[int]:
    return [a for a in range(1, n) if miller_rabin_single_round(n, a)]


def is_prime(n: int) -> bool:
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0: return False
    for i in range(3, int(n**0.5) + 1, 2):
        if n % i == 0:
            return False
    return True


def euler_totient(n: int) -> int:
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


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def viz_liar_density():
    """Visualize Miller-Rabin liar density for odd composites."""
    composites = []
    densities = []
    
    for n in range(9, 500, 2):
        if is_prime(n):
            continue
        liars = all_liars(n)
        density = len(liars) / (n - 1)
        composites.append(n)
        densities.append(density)
    
    fig, ax = plt.subplots(1, 1, figsize=(12, 6))
    
    ax.scatter(composites, densities, s=15, alpha=0.7, c='steelblue', edgecolors='none')
    ax.axhline(y=0.25, color='red', linestyle='--', linewidth=2, label='1/4 bound')
    ax.set_xlabel('Composite number n', fontsize=13)
    ax.set_ylabel('Liar density |L(n)| / (n-1)', fontsize=13)
    ax.set_title('Miller-Rabin Liar Density for Odd Composites', fontsize=15, fontweight='bold')
    ax.legend(fontsize=12)
    ax.set_ylim(-0.02, 0.35)
    ax.grid(True, alpha=0.3)
    
    return fig_to_base64(fig)


def viz_carmichael_vs_fermat():
    """Compare Fermat liars vs Miller-Rabin liars for Carmichael numbers."""
    carmichaels = [561, 1105, 1729, 2465, 2821]
    
    fermat_ratios = []
    mr_ratios = []
    labels = []
    
    for n in carmichaels:
        fermat_liars = sum(1 for a in range(1, n)
                          if math.gcd(a, n) == 1 and pow(a, n-1, n) == 1)
        mr_liars = len(all_liars(n))
        phi = euler_totient(n)
        
        fermat_ratios.append(fermat_liars / (n - 1))
        mr_ratios.append(mr_liars / (n - 1))
        labels.append(str(n))
    
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    
    x = np.arange(len(labels))
    width = 0.35
    
    bars1 = ax.bar(x - width/2, fermat_ratios, width, label='Fermat liars / (n-1)',
                   color='#e74c3c', alpha=0.8)
    bars2 = ax.bar(x + width/2, mr_ratios, width, label='MR liars / (n-1)',
                   color='#2ecc71', alpha=0.8)
    
    ax.axhline(y=0.25, color='orange', linestyle='--', linewidth=2, label='1/4 bound')
    ax.set_xlabel('Carmichael Number', fontsize=13)
    ax.set_ylabel('Liar Ratio', fontsize=13)
    ax.set_title('Fermat vs Miller-Rabin: Carmichael Numbers', fontsize=15, fontweight='bold')
    ax.set_xticks(x)
    ax.set_xticklabels(labels)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3, axis='y')
    
    return fig_to_base64(fig)


def viz_error_amplification():
    """Visualize error probability decay with repeated rounds."""
    ks = list(range(1, 65))
    errors = [(1/4)**k for k in ks]
    
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    
    ax.semilogy(ks, errors, 'b-', linewidth=2, label='Error ≤ (1/4)^k')
    
    # Mark interesting points
    interesting = {1: '25%', 5: '~10⁻³', 10: '~10⁻⁶',
                   20: '~10⁻¹²', 40: '~10⁻²⁴', 64: '~10⁻³⁹'}
    for k, label in interesting.items():
        if k <= 64:
            ax.plot(k, (1/4)**k, 'ro', markersize=8)
            ax.annotate(f'k={k}: {label}', (k, (1/4)**k),
                       textcoords="offset points", xytext=(10, 10),
                       fontsize=9, color='red')
    
    ax.set_xlabel('Number of rounds k', fontsize=13)
    ax.set_ylabel('Error probability upper bound', fontsize=13)
    ax.set_title('Miller-Rabin Error Amplification', fontsize=15, fontweight='bold')
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 66)
    
    return fig_to_base64(fig)


def viz_liar_heatmap():
    """Create a heatmap showing which bases are liars for which composites."""
    composites = [n for n in range(9, 100, 2) if not is_prime(n)]
    bases = list(range(2, 20))
    
    data = np.zeros((len(composites), len(bases)))
    for i, n in enumerate(composites):
        for j, a in enumerate(bases):
            if a < n and miller_rabin_single_round(n, a):
                data[i, j] = 1
    
    fig, ax = plt.subplots(1, 1, figsize=(10, 12))
    
    im = ax.imshow(data, aspect='auto', cmap='RdYlGn', interpolation='nearest')
    ax.set_xticks(range(len(bases)))
    ax.set_xticklabels(bases, fontsize=9)
    ax.set_yticks(range(0, len(composites), 2))
    ax.set_yticklabels([composites[i] for i in range(0, len(composites), 2)], fontsize=8)
    ax.set_xlabel('Base a', fontsize=13)
    ax.set_ylabel('Composite n', fontsize=13)
    ax.set_title('Miller-Rabin Liar Heatmap\n(Green = liar, Red = witness)', 
                 fontsize=14, fontweight='bold')
    
    return fig_to_base64(fig)


def viz_pseudoprime_distribution():
    """Show distribution of strong pseudoprimes to base 2."""
    limit = 5000
    spsp_2 = []
    
    for n in range(3, limit, 2):
        if is_prime(n):
            continue
        if miller_rabin_single_round(n, 2):
            spsp_2.append(n)
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    # Distribution plot
    ax1.hist(spsp_2, bins=50, color='steelblue', alpha=0.7, edgecolor='navy')
    ax1.set_xlabel('n', fontsize=12)
    ax1.set_ylabel('Count', fontsize=12)
    ax1.set_title(f'Strong Pseudoprimes to Base 2\n(up to {limit})', fontsize=13, fontweight='bold')
    ax1.grid(True, alpha=0.3)
    
    # Cumulative count
    counts = list(range(1, len(spsp_2) + 1))
    ax2.plot(spsp_2, counts, 'b-', linewidth=1.5)
    ax2.set_xlabel('n', fontsize=12)
    ax2.set_ylabel('Cumulative count', fontsize=12)
    ax2.set_title(f'Cumulative Strong Pseudoprimes\n(base 2, total: {len(spsp_2)})',
                  fontsize=13, fontweight='bold')
    ax2.grid(True, alpha=0.3)
    
    fig.tight_layout()
    return fig_to_base64(fig)


def viz_squaring_chain():
    """Visualize the squaring chain for Miller-Rabin test."""
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    
    examples = [
        (561, 2, "Composite: 561, base 2 (witness)"),
        (561, 50, "Composite: 561, base 50 (liar)"),
        (17, 3, "Prime: 17, base 3"),
        (1729, 2, "Carmichael: 1729, base 2"),
    ]
    
    for ax, (n, a, title) in zip(axes.flat, examples):
        s, d = decompose_twos(n - 1)
        chain = []
        x = pow(a, d, n)
        chain.append(x)
        for _ in range(s):
            x = pow(x, 2, n)
            chain.append(x)
        
        colors = []
        for val in chain:
            if val == 1:
                colors.append('#2ecc71')  # green for 1
            elif val == n - 1:
                colors.append('#f39c12')  # orange for n-1
            else:
                colors.append('#e74c3c')  # red for other
        
        bars = ax.bar(range(len(chain)), chain, color=colors, edgecolor='black', linewidth=0.5)
        ax.set_xticks(range(len(chain)))
        labels = [f'a^(d·2^{i})' if i > 0 else 'a^d' for i in range(len(chain))]
        ax.set_xticklabels(labels, fontsize=8, rotation=30)
        ax.set_ylabel('Value mod n', fontsize=10)
        ax.set_title(title, fontsize=11, fontweight='bold')
        ax.axhline(y=1, color='green', linestyle=':', alpha=0.5)
        ax.axhline(y=n-1, color='orange', linestyle=':', alpha=0.5)
        
        is_liar = miller_rabin_single_round(n, a)
        verdict = "LIAR" if is_liar else "WITNESS"
        ax.text(0.98, 0.95, verdict, transform=ax.transAxes,
                fontsize=12, fontweight='bold',
                color='green' if is_liar else 'red',
                ha='right', va='top',
                bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))
    
    fig.suptitle('Miller-Rabin Squaring Chains', fontsize=15, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig)


def generate_all_visualizations() -> Dict[str, str]:
    """Generate all visualizations and return as dict of name -> base64 URI."""
    print("Generating visualizations...")
    
    vizs = {}
    
    print("  1/5: Liar density scatter plot...")
    vizs['liar_density'] = viz_liar_density()
    
    print("  2/5: Carmichael comparison...")
    vizs['carmichael_comparison'] = viz_carmichael_vs_fermat()
    
    print("  3/5: Error amplification...")
    vizs['error_amplification'] = viz_error_amplification()
    
    print("  4/5: Pseudoprime distribution...")
    vizs['pseudoprime_distribution'] = viz_pseudoprime_distribution()
    
    print("  5/5: Squaring chains...")
    vizs['squaring_chains'] = viz_squaring_chain()
    
    print("All visualizations generated!")
    return vizs


if __name__ == "__main__":
    vizs = generate_all_visualizations()
    
    # Save individual PNGs for convenience
    for name, data_uri in vizs.items():
        # Extract base64 data
        b64_data = data_uri.split(',')[1]
        img_bytes = base64.b64decode(b64_data)
        filename = f"viz_{name}.png"
        with open(filename, 'wb') as f:
            f.write(img_bytes)
        print(f"Saved {filename}")
