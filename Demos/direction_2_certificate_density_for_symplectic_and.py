#!/usr/bin/env python3
"""
Applications of Self-Reciprocal Polynomial Theory

Demonstrates real-world applications of certificate density theory:
1. Random generation in symplectic groups
2. Quantum stabilizer code analysis
3. Linear feedback shift register (LFSR) design with palindromic constraints
"""

import numpy as np
from typing import List, Tuple
from algorithms import (
    make_self_reciprocal,
    is_irreducible_gf,
    enumerate_self_reciprocal_irreducibles,
    symplectic_certificate_density,
    symplectic_group_order,
    necklace_count,
)


# ============================================================================
# Application 1: Random Generation in Sp_{2n}(F_q)
# ============================================================================

def random_generation_probability(q: int, n: int, k: int = 2) -> float:
    """
    Estimate the probability that k random elements generate Sp_{2n}(F_q),
    assuming at least one has an irreducible self-reciprocal characteristic
    polynomial (is a certificate element).

    The certificate density δ ≈ 1/(2n) gives a lower bound on the probability
    that a random element is a certificate. With k random elements, the probability
    that at least one is a certificate is:
        1 - (1 - δ)^k

    Args:
        q: Field size.
        n: Rank (group is Sp_{2n}).
        k: Number of random elements drawn.

    Returns:
        Lower bound on probability of finding at least one certificate.
    """
    delta = symplectic_certificate_density(q, n)
    return 1 - (1 - delta) ** k


def expected_draws_for_certificate(q: int, n: int) -> float:
    """
    Expected number of random draws from Sp_{2n}(F_q) needed to find
    a certificate element (one with irreducible self-reciprocal charpoly).

    This is 1/δ ≈ 2n.

    Args:
        q: Field size.
        n: Rank.

    Returns:
        Expected number of draws.
    """
    delta = symplectic_certificate_density(q, n)
    return 1.0 / delta if delta > 0 else float('inf')


# ============================================================================
# Application 2: Symplectic Form over F_2 (Quantum Stabilizer Codes)
# ============================================================================

def standard_symplectic_form(n: int) -> np.ndarray:
    """
    Construct the standard 2n × 2n symplectic form matrix over F_2:
        J = [[0, I_n], [-I_n, 0]] = [[0, I_n], [I_n, 0]] (mod 2)

    In quantum information, this encodes the commutation relations of
    n-qubit Pauli operators.

    Args:
        n: Number of qubits.

    Returns:
        2n × 2n numpy array over F_2.
    """
    J = np.zeros((2 * n, 2 * n), dtype=int)
    for i in range(n):
        J[i, i + n] = 1
        J[i + n, i] = 1
    return J


def is_symplectic_f2(A: np.ndarray, n: int) -> bool:
    """
    Check if a matrix A is symplectic over F_2: A^T J A = J (mod 2).

    Args:
        A: 2n × 2n matrix.
        n: Number of qubits.

    Returns:
        True if A preserves the symplectic form mod 2.
    """
    J = standard_symplectic_form(n)
    product = (A.T @ J @ A) % 2
    return np.array_equal(product, J)


def symplectic_form_value(v: np.ndarray, w: np.ndarray, n: int) -> int:
    """
    Compute the symplectic form ω(v, w) = v^T J w (mod 2).

    In quantum information, ω(v, w) = 1 means the Pauli operators
    corresponding to v and w anticommute; ω(v, w) = 0 means they commute.

    Args:
        v, w: Vectors in F_2^{2n}.
        n: Number of qubits.

    Returns:
        0 or 1.
    """
    J = standard_symplectic_form(n)
    return int(v @ J @ w) % 2


def verify_commutation_preservation(A: np.ndarray, n: int, num_tests: int = 100) -> bool:
    """
    Verify that a symplectic matrix preserves the commutation form
    (Theorem: symplectic_certificate_preserves_commutation_form).

    Tests ω(Av, Aw) = ω(v, w) for random vectors v, w.

    Args:
        A: 2n × 2n matrix over F_2.
        n: Number of qubits.
        num_tests: Number of random pairs to test.

    Returns:
        True if all tests pass.
    """
    for _ in range(num_tests):
        v = np.random.randint(0, 2, 2 * n)
        w = np.random.randint(0, 2, 2 * n)
        Av = (A @ v) % 2
        Aw = (A @ w) % 2
        if symplectic_form_value(Av, Aw, n) != symplectic_form_value(v, w, n):
            return False
    return True


# ============================================================================
# Application 3: LFSR Design with Palindromic Feedback
# ============================================================================

def lfsr_sequence(coeffs: List[int], q: int, length: int) -> List[int]:
    """
    Generate a linear feedback shift register sequence using a self-reciprocal
    polynomial as the feedback polynomial.

    Self-reciprocal feedback polynomials produce sequences with time-reversal
    symmetry: reading the period backwards gives a shifted version of the
    same sequence. This is useful in communication systems where the receiver
    doesn't know the start of transmission.

    Args:
        coeffs: Feedback polynomial coefficients [a_0, ..., a_d].
        q: Field size.
        length: Desired sequence length.

    Returns:
        LFSR sequence as list of integers mod q.
    """
    d = len(coeffs) - 1
    state = [0] * d
    state[0] = 1  # nonzero initial state

    sequence = []
    for _ in range(length):
        sequence.append(state[-1])
        # Compute feedback
        feedback = 0
        for i in range(d):
            feedback = (feedback - coeffs[i] * state[i]) % q
        feedback = (feedback * pow(coeffs[d], q - 2, q)) % q
        state = [feedback] + state[:-1]

    return sequence


# ============================================================================
# Main demonstration
# ============================================================================

if __name__ == "__main__":
    print("=" * 72)
    print("APPLICATIONS OF SELF-RECIPROCAL POLYNOMIAL THEORY")
    print("=" * 72)
    print()

    # Application 1: Random generation
    print("APPLICATION 1: Random Generation in Sp_{2n}(F_q)")
    print("-" * 50)
    print()
    print("Expected draws to find a certificate element:")
    for n in [1, 2, 3, 4]:
        for q in [3, 5, 7]:
            draws = expected_draws_for_certificate(q, n)
            prob2 = random_generation_probability(q, n, k=2)
            print(f"  Sp_{2*n}(F_{q}): expected draws = {draws:.2f} "
                  f"(theoretical ≈ {2*n}), "
                  f"P(cert in 2 draws) = {prob2:.4f}")
        print()

    # Application 2: Quantum stabilizer codes
    print()
    print("APPLICATION 2: Quantum Stabilizer Code Analysis")
    print("-" * 50)
    print()

    n = 2  # 2-qubit system
    print(f"Working with {n}-qubit system (Sp_{2*n}(F_2) symmetry)")
    print()

    J = standard_symplectic_form(n)
    print("Standard symplectic form J (2-qubit):")
    print(J)
    print()

    # Example symplectic matrix
    A = np.array([
        [1, 1, 0, 0],
        [0, 1, 0, 0],
        [0, 0, 1, 0],
        [0, 0, 1, 1]
    ])

    print("Example symplectic matrix A (CNOT gate):")
    print(A)
    print(f"  Is symplectic: {is_symplectic_f2(A, n)}")
    print(f"  Preserves commutation: {verify_commutation_preservation(A, n)}")
    print()

    # Test with specific vectors
    v = np.array([1, 0, 0, 0])  # X on qubit 1
    w = np.array([0, 0, 1, 0])  # Z on qubit 1

    print(f"  v = {v} (X₁ operator)")
    print(f"  w = {w} (Z₁ operator)")
    print(f"  ω(v, w) = {symplectic_form_value(v, w, n)} (anticommute? {symplectic_form_value(v, w, n) == 1})")

    Av = (A @ v) % 2
    Aw = (A @ w) % 2
    print(f"  Av = {Av}")
    print(f"  Aw = {Aw}")
    print(f"  ω(Av, Aw) = {symplectic_form_value(Av, Aw, n)} "
          f"= ω(v, w) ✓" if symplectic_form_value(Av, Aw, n) == symplectic_form_value(v, w, n)
          else f"  ω(Av, Aw) ≠ ω(v, w) ✗")
    print()

    # Application 3: LFSR
    print()
    print("APPLICATION 3: LFSR with Self-Reciprocal Feedback")
    print("-" * 50)
    print()

    q = 3
    # Use a self-reciprocal irreducible polynomial over GF(3) of degree 4
    sri_polys = enumerate_self_reciprocal_irreducibles(q, 2)
    if sri_polys:
        fb = sri_polys[0]
        print(f"Feedback polynomial (GF(3)): {fb}")
        print(f"  Self-reciprocal: {fb == fb[::-1]}")
        print(f"  Irreducible: True (by construction)")
        print()

        seq = lfsr_sequence(fb, q, 30)
        print(f"  LFSR sequence (first 30 terms): {seq}")
        print(f"  Period divides q^{len(fb)-1} - 1 = {q**(len(fb)-1) - 1}")
    print()

    # Summary statistics
    print()
    print("=" * 72)
    print("SUMMARY: Certificate Density vs Group Size")
    print("=" * 72)
    print()
    print(f"{'Group':>15} {'|G|':>20} {'cert density':>15} {'≈ 1/(2n)':>10}")
    print("-" * 65)
    for q in [3, 5, 7]:
        for n in [1, 2]:
            order = symplectic_group_order(q, n)
            density = symplectic_certificate_density(q, n)
            print(f"{'Sp_'+str(2*n)+'(F_'+str(q)+')':>15} {order:>20} {density:>15.6f} {1/(2*n):>10.6f}")


#!/usr/bin/env python3
"""
Demo: Self-Reciprocal Irreducible Polynomials over Finite Fields

Computes the number of monic irreducible self-reciprocal polynomials of degree 2n
over GF(q) for small values of q and n, and compares to the asymptotic prediction
SRI(q,n) ≈ q^n / (2n).

Usage:
    python demo.py
"""

from itertools import product as cart_product


# ============================================================
# Polynomial arithmetic over GF(q) (q prime)
# ============================================================

def poly_mul(a, b, q):
    """Multiply polynomials over GF(q)."""
    if not a or not b:
        return []
    r = [0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        for j, bj in enumerate(b):
            r[i + j] = (r[i + j] + ai * bj) % q
    while len(r) > 1 and r[-1] == 0:
        r.pop()
    return r


def poly_mod(a, b, q):
    """Compute a mod b over GF(q)."""
    a = list(a)
    while len(a) >= len(b) and a:
        if a[-1] == 0:
            a.pop()
            continue
        c = (a[-1] * pow(b[-1], q - 2, q)) % q
        s = len(a) - len(b)
        for i in range(len(b)):
            a[s + i] = (a[s + i] - c * b[i]) % q
        while a and a[-1] == 0:
            a.pop()
    return a if a else [0]


def poly_pow_mod(base, exp, mod, q):
    """Compute base^exp mod 'mod' over GF(q)."""
    result = [1]
    base = poly_mod(base, mod, q)
    while exp > 0:
        if exp & 1:
            result = poly_mod(poly_mul(result, base, q), mod, q)
        base = poly_mod(poly_mul(base, base, q), mod, q)
        exp >>= 1
    return result


def poly_gcd(a, b, q):
    """GCD of polynomials over GF(q)."""
    while b and b != [0]:
        a, b = b, poly_mod(a, b, q)
    if not a:
        return [0]
    inv = pow(a[-1], q - 2, q)
    return [(c * inv) % q for c in a]


def is_irreducible(f, q):
    """Rabin irreducibility test over GF(q)."""
    n = len(f) - 1
    if n <= 0:
        return False
    if n == 1:
        return True
    x = [0, 1]
    # Check x^{q^n} = x mod f
    xqn = poly_pow_mod(x, q ** n, f, q)
    diff = list(xqn)
    if len(diff) < 2:
        diff.extend([0] * (2 - len(diff)))
    diff[1] = (diff[1] - 1) % q
    rem = poly_mod(diff, f, q)
    if rem != [0] and any(c != 0 for c in rem):
        return False
    # Check gcd(x^{q^{n/p}} - x, f) = 1 for each prime p | n
    primes = set()
    t = n
    for p in range(2, int(t ** 0.5) + 2):
        while t % p == 0:
            primes.add(p)
            t //= p
    if t > 1:
        primes.add(t)
    for p in primes:
        m = n // p
        xqm = poly_pow_mod(x, q ** m, f, q)
        d2 = list(xqm)
        if len(d2) < 2:
            d2.extend([0] * (2 - len(d2)))
        d2[1] = (d2[1] - 1) % q
        while d2 and d2[-1] == 0:
            d2.pop()
        if not d2:
            d2 = [0]
        g = poly_gcd(d2, f, q)
        if len(g) > 1:
            return False
    return True


def count_sri(q, n):
    """Count monic irreducible self-reciprocal polynomials of degree 2n over GF(q)."""
    if n == 0:
        return 0
    count = 0
    for params in cart_product(range(q), repeat=n):
        # half = [1, a_1, ..., a_n], full palindrome
        half = [1] + list(params)
        full = list(half) + list(reversed(half[:-1]))
        full = [c % q for c in full]
        if is_irreducible(full, q):
            count += 1
    return count


def mobius(n):
    if n == 1:
        return 1
    factors = {}
    t = n
    for p in range(2, int(t ** 0.5) + 2):
        while t % p == 0:
            factors[p] = factors.get(p, 0) + 1
            t //= p
    if t > 1:
        factors[t] = 1
    if any(e > 1 for e in factors.values()):
        return 0
    return (-1) ** len(factors)


def necklace_count(q, n):
    """Number of monic irreducible polynomials of degree n over GF(q)."""
    if n == 0:
        return 0
    total = 0
    for d in range(1, n + 1):
        if n % d == 0:
            total += mobius(n // d) * q ** d
    return total // n


def main():
    print("=" * 72)
    print("SELF-RECIPROCAL IRREDUCIBLE POLYNOMIAL COUNTING")
    print("Certificate Density for Symplectic Groups Sp_{2n}(F_q)")
    print("=" * 72)
    print()
    print("Asymptotic prediction: SRI(q,n) ≈ q^n / (2n)")
    print()
    print("-" * 72)
    print(f"{'q':>4} {'n':>4} {'deg':>5} {'SRI(q,n)':>10} {'q^n/(2n)':>12} {'ratio':>10} {'deviation':>12}")
    print("-" * 72)

    test_cases = [
        (2, 1), (2, 2), (2, 3),
        (3, 1), (3, 2), (3, 3),
        (5, 1), (5, 2), (5, 3),
        (7, 1), (7, 2), (7, 3),
    ]

    results = []
    for q, n in test_cases:
        sri = count_sri(q, n)
        predicted = q ** n / (2 * n)
        ratio = sri / predicted if predicted > 0 else float('inf')
        deviation = sri - predicted
        results.append((q, n, sri, predicted, ratio, deviation))
        print(f"{q:>4} {n:>4} {2 * n:>5} {sri:>10} {predicted:>12.2f} {ratio:>10.4f} {deviation:>12.2f}")

    print("-" * 72)
    print()

    # Sp_4 focus
    print("=" * 72)
    print("FOCUS: Sp_4(F_q) Certificate Density (n=2, degree 4)")
    print("=" * 72)
    print()
    for q, n, sri, predicted, ratio, deviation in results:
        if n == 2:
            density = sri / q ** n if q ** n > 0 else 0
            print(f"  q = {q}:")
            print(f"    Self-reciprocal irreducibles of degree 4: {sri}")
            print(f"    Total monic self-reciprocal of degree 4:  {q ** n}")
            print(f"    Predicted SRI(q,2) = q²/4:                {predicted:.2f}")
            print(f"    Actual/Predicted ratio:                    {ratio:.4f}")
            print(f"    Certificate density ~ SRI/q^n:             {density:.4f}")
            print(f"    Predicted density ~ 1/(2n) = 1/4:          0.2500")
            print()

    # Dimension halving
    print("=" * 72)
    print("DIMENSION HALVING: Self-Reciprocal Coefficient Compression")
    print("=" * 72)
    print()
    print("A monic polynomial of degree 2n has 2n free coefficients.")
    print("A monic SELF-RECIPROCAL polynomial of degree 2n has only n free coefficients.")
    print()
    print(f"{'degree':>8} {'generic coeffs':>16} {'self-recip coeffs':>20} {'compression':>14}")
    print("-" * 62)
    for n in range(1, 8):
        print(f"{2 * n:>8} {2 * n:>16} {n:>20} {n / (2 * n):>14.0%}")
    print()

    # Conjecture test
    print("=" * 72)
    print("CONJECTURE TEST: |SRI(q,n) - q^n/(2n)| ≤ q^(n/2)")
    print("=" * 72)
    print()
    for q, n, sri, predicted, ratio, deviation in results:
        bound = q ** (n / 2)
        holds = abs(deviation) <= bound
        status = "✓ HOLDS" if holds else "✗ FAILS"
        print(f"  q={q}, n={n}: |deviation| = {abs(deviation):.2f}, "
              f"bound q^(n/2) = {bound:.2f}  {status}")

    print()

    # GL vs Sp comparison
    print("=" * 72)
    print("GL vs Sp CERTIFICATE DENSITY COMPARISON")
    print("=" * 72)
    print()
    print(f"{'q':>4} {'n':>4} {'GL_n density':>14} {'1/n':>8} {'Sp_{2n} density':>16} {'1/(2n)':>8}")
    print("-" * 56)
    for q in [3, 5, 7]:
        for n in [1, 2, 3]:
            gl_d = necklace_count(q, n) / q ** n
            sri = count_sri(q, n)
            sp_d = sri / q ** n
            print(f"{q:>4} {n:>4} {gl_d:>14.4f} {1 / n:>8.4f} {sp_d:>16.4f} {1 / (2 * n):>8.4f}")

    print()

    # Examples
    print("=" * 72)
    print("EXAMPLES: Self-Reciprocal Irreducible Polynomials over GF(3), degree 4")
    print("=" * 72)
    print()
    q, n = 3, 2
    count = 0
    for params in cart_product(range(q), repeat=n):
        half = [1] + list(params)
        full = list(half) + list(reversed(half[:-1]))
        if is_irreducible(full, q):
            terms = []
            for i, c in enumerate(full):
                if c == 0:
                    continue
                if i == 0:
                    terms.append(str(c))
                elif i == 1:
                    terms.append(f"{c}x" if c != 1 else "x")
                else:
                    terms.append(f"{c}x^{i}" if c != 1 else f"x^{i}")
            poly_str = " + ".join(reversed(terms))
            print(f"  {poly_str}")
            count += 1

    print(f"\nTotal: {count} irreducible self-reciprocal polynomials of degree 4 over GF(3)")


if __name__ == "__main__":
    main()


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


#!/usr/bin/env python3
"""
Visualization: Palindromic Coefficient Structure of Self-Reciprocal Polynomials

Illustrates the coefficient symmetry property (Theorem 1: self_reciprocal_iff_coeff_symmetry)
and the dimension halving phenomenon (Theorem 2: self_reciprocal_determined_by_first_half).

Shows how the palindromic constraint reduces the parameter space from 2n to n dimensions.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def make_self_reciprocal(half, q):
    full = list(half) + list(reversed(half[:-1]))
    return [c % q for c in full]


fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Palindromic Structure of Self-Reciprocal Polynomials',
             fontsize=16, fontweight='bold')

# Panel 1: Coefficient mirror symmetry visualization
ax1 = axes[0, 0]
# Example: degree 8 polynomial with palindromic coefficients
coeffs = [1, 3, 0, 2, 5, 2, 0, 3, 1]  # palindromic
n = len(coeffs)
colors = []
for i in range(n):
    if i < n // 2:
        colors.append('#3498db')  # blue for free
    elif i == n // 2:
        colors.append('#e74c3c')  # red for middle
    else:
        colors.append('#95a5a6')  # gray for determined
bars = ax1.bar(range(n), coeffs, color=colors, edgecolor='white', linewidth=1.5)

# Draw mirror arrows
for i in range(n // 2):
    j = n - 1 - i
    ax1.annotate('', xy=(j, coeffs[j] + 0.3), xytext=(i, coeffs[i] + 0.3),
                arrowprops=dict(arrowstyle='<->', color='#2c3e50', lw=1.5, alpha=0.6))

ax1.set_xlabel('Coefficient index $i$', fontsize=12)
ax1.set_ylabel('$a_i$', fontsize=12)
ax1.set_title('Palindromic Coefficients: $a_i = a_{d-i}$')
ax1.set_xticks(range(n))
ax1.set_xticklabels([f'$a_{i}$' for i in range(n)])

# Legend
free_patch = mpatches.Patch(color='#3498db', label='Free coefficients')
middle_patch = mpatches.Patch(color='#e74c3c', label='Middle coefficient')
det_patch = mpatches.Patch(color='#95a5a6', label='Determined by symmetry')
ax1.legend(handles=[free_patch, middle_patch, det_patch], fontsize=9)
ax1.grid(True, alpha=0.3, axis='y')

# Panel 2: Parameter space size comparison
ax2 = axes[0, 1]
q_vals = [2, 3, 5, 7, 11]
n_vals = [1, 2, 3, 4]

x = np.arange(len(n_vals))
width = 0.15

for idx, q in enumerate(q_vals[:4]):
    generic_sizes = [q**(2*n) for n in n_vals]
    sr_sizes = [q**n for n in n_vals]
    offset = (idx - 1.5) * width
    ax2.bar(x + offset, [np.log10(s) for s in sr_sizes], width,
            label=f'$q={q}$ self-recip', alpha=0.8)

ax2.set_xlabel('Half-degree $n$', fontsize=12)
ax2.set_ylabel('$\\log_{10}$(parameter space size)', fontsize=12)
ax2.set_title('Search Space Compression: $q^{2n} \\to q^n$')
ax2.set_xticks(x)
ax2.set_xticklabels([f'$n={n}$' for n in n_vals])
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3, axis='y')

# Panel 3: Root inverse pairing on the unit circle
ax3 = axes[1, 0]
ax3.set_aspect('equal')

theta = np.linspace(0, 2 * np.pi, 200)
ax3.plot(np.cos(theta), np.sin(theta), 'k-', alpha=0.2, linewidth=1)

# Example roots: paired as z and z^{-1}
angles = [np.pi/6, np.pi/3, 2*np.pi/3, 5*np.pi/6]
for angle in angles:
    r = 1.3  # radius (not on unit circle for visibility)
    z = r * np.exp(1j * angle)
    z_inv = 1/z

    ax3.plot(z.real, z.imag, 'o', color='#3498db', markersize=10, zorder=5)
    ax3.plot(z_inv.real, z_inv.imag, 's', color='#e74c3c', markersize=10, zorder=5)

    # Draw pairing line
    ax3.plot([z.real, z_inv.real], [z.imag, z_inv.imag],
             '--', color='#95a5a6', alpha=0.5, linewidth=1)

    # Labels
    ax3.annotate(f'$z$', (z.real, z.imag), textcoords="offset points",
                xytext=(10, 5), fontsize=9, color='#3498db')
    ax3.annotate(f'$z^{{-1}}$', (z_inv.real, z_inv.imag), textcoords="offset points",
                xytext=(10, -10), fontsize=9, color='#e74c3c')

ax3.set_xlim(-2, 2)
ax3.set_ylim(-2, 2)
ax3.axhline(y=0, color='k', linewidth=0.5)
ax3.axvline(x=0, color='k', linewidth=0.5)
ax3.set_title('Root Inverse Pairing: $z \\leftrightarrow z^{-1}$')
ax3.set_xlabel('Re', fontsize=11)
ax3.set_ylabel('Im', fontsize=11)

root_patch = mpatches.Patch(color='#3498db', label='Root $z$')
inv_patch = mpatches.Patch(color='#e74c3c', label='Inverse root $z^{-1}$')
ax3.legend(handles=[root_patch, inv_patch], fontsize=10, loc='upper right')
ax3.grid(True, alpha=0.2)

# Panel 4: Irreducibility fraction among self-reciprocal polys
ax4 = axes[1, 1]

def count_sri_fast(q, n):
    """Count self-reciprocal irreducibles of degree 2n over GF(q)."""
    from itertools import product as cart_product
    count = 0
    for params in cart_product(range(q), repeat=n):
        half = [1] + list(params)
        full = list(half) + list(reversed(half[:-1]))
        full = [c % q for c in full]
        # Quick irreducibility via Rabin
        deg = len(full) - 1
        if deg <= 0:
            continue
        if deg == 1:
            count += 1
            continue
        # Use simplified test
        x_poly = [0, 1]
        from functools import reduce

        def pmul(a, b):
            if not a or not b:
                return []
            r = [0] * (len(a) + len(b) - 1)
            for i2, ai in enumerate(a):
                for j, bj in enumerate(b):
                    r[i2 + j] = (r[i2 + j] + ai * bj) % q
            while len(r) > 1 and r[-1] == 0:
                r.pop()
            return r

        def pmod(a, b):
            a = list(a)
            while len(a) >= len(b) and a:
                if a[-1] == 0:
                    a.pop()
                    continue
                c = (a[-1] * pow(b[-1], q - 2, q)) % q
                s = len(a) - len(b)
                for i2 in range(len(b)):
                    a[s + i2] = (a[s + i2] - c * b[i2]) % q
                while a and a[-1] == 0:
                    a.pop()
            return a if a else [0]

        def ppow(base, exp, mod):
            result = [1]
            base = pmod(base, mod)
            while exp > 0:
                if exp % 2 == 1:
                    result = pmod(pmul(result, base), mod)
                base = pmod(pmul(base, base), mod)
                exp //= 2
            return result

        def pgcd(a, b):
            while b and b != [0]:
                a, b = b, pmod(a, b)
            if not a:
                return [0]
            lc_inv = pow(a[-1], q - 2, q)
            return [(c * lc_inv) % q for c in a]

        xqn = ppow(x_poly, q**deg, full, q)
        diff = list(xqn)
        if len(diff) < 2:
            diff.extend([0] * (2 - len(diff)))
        diff[1] = (diff[1] - 1) % q
        rem = pmod(diff, full, q)
        if rem != [0] and any(c != 0 for c in rem):
            continue

        irred = True
        temp = deg
        prime_divs = set()
        for p in range(2, int(temp**0.5) + 2):
            while temp % p == 0:
                prime_divs.add(p)
                temp //= p
        if temp > 1:
            prime_divs.add(temp)
        for p in prime_divs:
            m = deg // p
            xqm = ppow(x_poly, q**m, full, q)
            d2 = list(xqm)
            if len(d2) < 2:
                d2.extend([0] * (2 - len(d2)))
            d2[1] = (d2[1] - 1) % q
            while d2 and d2[-1] == 0:
                d2.pop()
            if not d2:
                d2 = [0]
            g = pgcd(d2, full)
            if len(g) > 1:
                irred = False
                break
        if irred:
            count += 1
    return count


q_range = [2, 3, 5, 7, 11, 13]
for n in [1, 2, 3]:
    fractions = []
    qs_plot = []
    for q in q_range:
        if q**n <= 2000:
            sri = count_sri_fast(q, n)
            total = q**n
            fractions.append(sri / total)
            qs_plot.append(q)
    if qs_plot:
        ax4.plot(qs_plot, fractions, 'o-', label=f'$n={n}$', markersize=6)
        ax4.axhline(y=1/(2*n), color=ax4.get_lines()[-1].get_color(),
                    linestyle='--', alpha=0.4)

ax4.set_xlabel('Field size $q$', fontsize=12)
ax4.set_ylabel('Fraction irreducible', fontsize=12)
ax4.set_title('Irreducibility Rate Among Self-Reciprocal Polys')
ax4.legend(fontsize=10)
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('palindromic_structure_visualization.png', dpi=150, bbox_inches='tight')
print("Saved palindromic_structure_visualization.png")


#!/usr/bin/env python3
"""
Visualization: Symplectic Structure and Certificate Elements

Illustrates the symplectic form, its preservation by symplectic matrices,
and the connection between certificate density in GL_n and Sp_{2n}.
Shows the "half-density" phenomenon: Sp_{2n} certificates have density
~1/(2n) compared to GL_n's ~1/n.
"""

import matplotlib.pyplot as plt
import numpy as np


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


fig = plt.figure(figsize=(16, 12))

# Panel 1: Symplectic form matrix heatmap
ax1 = fig.add_subplot(2, 2, 1)
n = 4
J = np.zeros((2*n, 2*n))
for i in range(n):
    J[i, i+n] = 1
    J[i+n, i] = -1

im = ax1.imshow(J, cmap='RdBu_r', vmin=-1, vmax=1, aspect='equal')
ax1.set_title(f'Standard Symplectic Form $J_{{2 \\times {n}}}$', fontsize=13)
ax1.set_xlabel('Column index')
ax1.set_ylabel('Row index')
for i in range(2*n):
    for j in range(2*n):
        val = int(J[i,j])
        if val != 0:
            ax1.text(j, i, str(val), ha='center', va='center',
                    fontsize=11, fontweight='bold',
                    color='white' if abs(val) > 0.5 else 'black')
plt.colorbar(im, ax=ax1, shrink=0.8)

# Panel 2: Density comparison across group families
ax2 = fig.add_subplot(2, 2, 2)
n_range = np.arange(1, 16)

gl_density = [1/n for n in n_range]
sp_density = [1/(2*n) for n in n_range]
orth_density = [1/(2*n) for n in n_range]  # same asymptotic for orthogonal

ax2.plot(n_range, gl_density, 'o-', color='#3498db', label='$GL_n$: $\\delta \\approx 1/n$',
         markersize=5, linewidth=2)
ax2.plot(n_range, sp_density, 's-', color='#e74c3c', label='$Sp_{2n}$: $\\delta \\approx 1/(2n)$',
         markersize=5, linewidth=2)
ax2.fill_between(n_range, gl_density, sp_density, alpha=0.1, color='purple')

ax2.set_xlabel('Parameter $n$', fontsize=12)
ax2.set_ylabel('Certificate density $\\delta$', fontsize=12)
ax2.set_title('Certificate Density: $GL_n$ vs $Sp_{2n}$ vs $O_{2n}$')
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)
ax2.set_yscale('log')

# Annotate the gap
ax2.annotate('Self-reciprocal\nconstraint halves\nthe density',
            xy=(5, 1/(2*5)), xytext=(8, 0.3),
            arrowprops=dict(arrowstyle='->', color='purple', lw=1.5),
            fontsize=10, color='purple', ha='center')

# Panel 3: Irreducible polynomial count: standard vs self-reciprocal
ax3 = fig.add_subplot(2, 2, 3)
q = 5

n_range_count = range(1, 9)
standard_counts = [necklace_count(q, n) for n in n_range_count]
# SRI count ≈ necklace_count(q, n) / 2 for the self-reciprocal constraint
# More precisely, SRI(q,n) = (1/(2n)) * Σ_{d|n} μ(n/d) q^d
sri_formula = []
for n in n_range_count:
    total = 0
    for d in range(1, n + 1):
        if n % d == 0:
            total += mobius(n // d) * q**d
    sri_formula.append(total / (2*n))

qn_over_n = [q**n / n for n in n_range_count]
qn_over_2n = [q**n / (2*n) for n in n_range_count]

ax3.semilogy(list(n_range_count), standard_counts, 'o-', color='#3498db',
             label='Irreducible deg-$n$ (standard)', linewidth=2)
ax3.semilogy(list(n_range_count), sri_formula, 's-', color='#e74c3c',
             label='Self-reciprocal irred. deg-$2n$', linewidth=2)
ax3.semilogy(list(n_range_count), qn_over_n, '--', color='#3498db',
             alpha=0.4, label='$q^n/n$')
ax3.semilogy(list(n_range_count), qn_over_2n, '--', color='#e74c3c',
             alpha=0.4, label='$q^n/(2n)$')

ax3.set_xlabel('$n$', fontsize=12)
ax3.set_ylabel('Count', fontsize=12)
ax3.set_title(f'Irreducible Polynomial Counts over $\\mathbb{{F}}_{{{q}}}$')
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

# Panel 4: The self-reciprocal compression ratio
ax4 = fig.add_subplot(2, 2, 4)

# For several field sizes, show how the ratio SRI(q,n) * 2n / q^n converges to 1
q_values = [3, 5, 7, 11]
colors = ['#2ecc71', '#9b59b6', '#e67e22', '#1abc9c']

for q, color in zip(q_values, colors):
    ratios = []
    ns = []
    for n in range(1, 8):
        total = 0
        for d in range(1, n + 1):
            if n % d == 0:
                total += mobius(n // d) * q**d
        sri = total / (2 * n)
        ratio = sri * (2 * n) / q**n
        ratios.append(ratio)
        ns.append(n)
    ax4.plot(ns, ratios, 'o-', color=color, label=f'$q={q}$', markersize=6, linewidth=2)

ax4.axhline(y=1, color='black', linestyle='--', alpha=0.5, linewidth=1)
ax4.set_xlabel('$n$', fontsize=12)
ax4.set_ylabel('$SRI(q,n) \\cdot 2n \\, / \\, q^n$', fontsize=12)
ax4.set_title('Convergence: $SRI(q,n) \\cdot 2n / q^n \\to 1$')
ax4.legend(fontsize=10)
ax4.grid(True, alpha=0.3)
ax4.set_ylim(0.5, 1.5)

plt.tight_layout()
plt.savefig('symplectic_structure_visualization.png', dpi=150, bbox_inches='tight')
print("Saved symplectic_structure_visualization.png")
