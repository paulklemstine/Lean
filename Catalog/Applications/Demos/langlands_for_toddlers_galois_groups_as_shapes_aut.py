#!/usr/bin/env python3
"""
Langlands Mirror Demo: Shape-Color Duality in Arithmetic

Demonstrates the quadratic Langlands correspondence:
  Shape (quadratic field Q(√d)) ↔ Color (Kronecker character χ_D)

The trace function is the Jacobi symbol J(d, n), which encodes
whether primes split, are inert, or ramify in Q(√d).
"""

from math import gcd, isqrt
from typing import List, Tuple, Dict


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


def legendre_symbol(a: int, p: int) -> int:
    """Compute the Legendre symbol (a/p) for odd prime p."""
    if p == 2:
        raise ValueError("p must be odd prime")
    a = a % p
    if a == 0:
        return 0
    # Euler's criterion: (a/p) = a^((p-1)/2) mod p
    result = pow(a, (p - 1) // 2, p)
    return result if result <= 1 else -1


def jacobi_symbol(a: int, n: int) -> int:
    """Compute the Jacobi symbol (a/n) for odd positive n."""
    if n <= 0 or n % 2 == 0:
        if n == 1:
            return 1
        if n == 0:
            return 0
        raise ValueError(f"n must be positive odd, got {n}")
    if n == 1:
        return 1
    a = a % n
    if a == 0:
        return 0 if n > 1 else 1

    result = 1
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a = a % n
    return result if n == 1 else 0


def kronecker_symbol(d: int, n: int) -> int:
    """Compute the Kronecker symbol (d/n) for any integer d and positive n.
    
    This extends the Jacobi symbol to handle n=2 and even n.
    """
    if n == 0:
        return 1 if abs(d) == 1 else 0
    if n == 1:
        return 1

    result = 1
    # Handle sign of n
    if n < 0:
        n = -n
        if d < 0:
            result = -result

    # Factor out powers of 2
    v = 0
    while n % 2 == 0:
        v += 1
        n //= 2

    if v > 0:
        if d % 2 == 0:
            result *= 0
            return 0
        if v % 2 == 1:
            # (d/2) depends on d mod 8
            if d % 8 in (3, 5):
                result *= -1

    if n == 1:
        return result

    return result * jacobi_symbol(d, n)


def quad_discriminant(d: int) -> int:
    """Fundamental discriminant of Q(√d).
    D = d if d ≡ 1 (mod 4), else D = 4d.
    """
    if d % 4 == 1:
        return d
    return 4 * d


def primes_up_to(n: int) -> List[int]:
    """List of primes up to n via sieve."""
    if n < 2:
        return []
    sieve = [True] * (n + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, isqrt(n) + 1):
        if sieve[i]:
            for j in range(i*i, n + 1, i):
                sieve[j] = False
    return [i for i in range(n + 1) if sieve[i]]


def demonstrate_shape_color_matching():
    """Demonstrate the shape-color correspondence for small quadratic fields."""
    print("=" * 70)
    print("LANGLANDS MIRROR: Shape-Color Correspondence for Quadratic Fields")
    print("=" * 70)

    squarefree_d = [-3, -2, -1, 2, 3, 5, 6, 7, -5, -7, 13, -11]
    primes = primes_up_to(30)

    for d in squarefree_d:
        D = quad_discriminant(d)
        print(f"\n{'─' * 60}")
        print(f"Shape: Q(√{d})  |  Discriminant D = {D}")
        print(f"{'─' * 60}")

        split = []
        inert = []
        ramified = []

        for p in primes:
            val = kronecker_symbol(d, p)
            if val == 1:
                split.append(p)
            elif val == -1:
                inert.append(p)
            else:
                ramified.append(p)

        print(f"  Color χ_D at primes: {[kronecker_symbol(d, p) for p in primes[:10]]}")
        print(f"  Split primes (χ=+1):   {split}")
        print(f"  Inert primes (χ=-1):   {inert}")
        print(f"  Ramified primes (χ=0): {ramified}")


def verify_reciprocity():
    """Verify quadratic reciprocity: J(p,q)·J(q,p) = (-1)^((p-1)/2·(q-1)/2)."""
    print("\n" + "=" * 70)
    print("MIRROR RECIPROCITY: Quadratic Reciprocity Verification")
    print("=" * 70)

    odd_primes = [p for p in primes_up_to(30) if p > 2]
    all_pass = True

    for i, p in enumerate(odd_primes):
        for q in odd_primes[i+1:]:
            jp_q = jacobi_symbol(p, q)
            jq_p = jacobi_symbol(q, p)
            product = jp_q * jq_p
            expected = (-1) ** (((p - 1) // 2) * ((q - 1) // 2))

            if product != expected:
                print(f"  FAIL: p={p}, q={q}: J(p,q)·J(q,p) = {product} ≠ {expected}")
                all_pass = False

    if all_pass:
        print(f"  ✓ Quadratic reciprocity verified for all pairs of odd primes ≤ 30")


def verify_multiplicativity():
    """Verify complete multiplicativity of the Kronecker character."""
    print("\n" + "=" * 70)
    print("MULTIPLICATIVITY: J(d, mn) = J(d, m) · J(d, n)")
    print("=" * 70)

    test_d = [-1, 2, -3, 5, 7]
    all_pass = True

    for d in test_d:
        for m in range(1, 20):
            for n in range(1, 20):
                lhs = kronecker_symbol(d, m * n)
                rhs = kronecker_symbol(d, m) * kronecker_symbol(d, n)
                if lhs != rhs:
                    print(f"  FAIL: d={d}, m={m}, n={n}: J(d,mn)={lhs} ≠ J(d,m)·J(d,n)={rhs}")
                    all_pass = False

    if all_pass:
        print(f"  ✓ Multiplicativity verified for d ∈ {test_d}, m,n ∈ [1,19]")


def character_sum_demo():
    """Demonstrate character sum cancellation and the Pólya–Vinogradov phenomenon."""
    print("\n" + "=" * 70)
    print("CHARACTER SUMS: ∑ χ_d(n) for n = 1 to N")
    print("=" * 70)

    test_cases = [(-1, "Q(i)"), (2, "Q(√2)"), (-3, "Q(√-3)"), (5, "Q(√5)")]

    for d, name in test_cases:
        D = quad_discriminant(d)
        partial_sums = []
        running_sum = 0
        N = 100

        for n in range(1, N + 1):
            running_sum += kronecker_symbol(d, n)
            partial_sums.append(running_sum)

        max_sum = max(abs(s) for s in partial_sums)
        bound = abs(D) ** 0.5
        print(f"\n  {name} (D={D}):")
        print(f"    Partial sums S(d, N) for N=1..{N}:")
        print(f"    First 20: {partial_sums[:20]}")
        print(f"    Max |S(d,N)| = {max_sum}")
        print(f"    √|D| = {bound:.2f}")
        print(f"    Pólya–Vinogradov bound ≈ √|D|·log|D| = {bound * (abs(D)**0.3 if abs(D) > 1 else 1):.2f}")


def class_number_formula_test():
    """Test Dirichlet's class number formula for imaginary quadratic fields.
    h(d) = -(1/D) · ∑_{a=1}^{|D|-1} a · χ_D(a)  for D < 0
    """
    print("\n" + "=" * 70)
    print("CLASS NUMBER FORMULA: h(d) = -(1/D) · ∑ a·χ_D(a)")
    print("=" * 70)

    # Known class numbers for imaginary quadratic fields
    known_class_numbers = {
        -1: 1, -2: 1, -3: 1, -5: 2, -6: 2, -7: 1,
        -10: 2, -11: 1, -13: 2, -14: 4, -15: 2
    }

    for d, expected_h in sorted(known_class_numbers.items()):
        D = quad_discriminant(d)
        # Compute -(1/D) · ∑_{a=1}^{|D|-1} a · χ_D(a)
        char_sum = sum(a * kronecker_symbol(D, a) for a in range(1, abs(D)))
        # h = |char_sum| / |D| for D < -4; adjust by w for D = -3, -4
        w = 6 if D == -3 else (4 if D == -4 else 2)
        computed_h = w * abs(char_sum) / (2 * abs(D))

        status = "✓" if abs(computed_h - expected_h) < 0.001 else "✗"
        print(f"  {status} d={d:>3}, D={D:>4}: h = {computed_h:.0f} (expected {expected_h})  [Σa·χ(a) = {char_sum}]")



def prime_density_demo():
    """Demonstrate that split primes have density 1/2 (Chebotarev for quadratic case)."""
    print("\n" + "=" * 70)
    print("PRIME DENSITY: Split primes have density 1/2")
    print("=" * 70)

    test_d = [-1, 2, -3, 5]
    N = 10000

    all_primes = primes_up_to(N)

    for d in test_d:
        D = quad_discriminant(d)
        # Exclude ramified primes (those dividing D)
        good_primes = [p for p in all_primes if D % p != 0]
        split_count = sum(1 for p in good_primes if kronecker_symbol(d, p) == 1)
        total = len(good_primes)
        ratio = split_count / total if total > 0 else 0

        print(f"  d={d:>3} (D={D:>4}): {split_count}/{total} = {ratio:.4f} split "
              f"(deviation from 1/2: {abs(ratio - 0.5):.4f})")


if __name__ == "__main__":
    demonstrate_shape_color_matching()
    verify_reciprocity()
    verify_multiplicativity()
    character_sum_demo()
    class_number_formula_test()
    prime_density_demo()


#!/usr/bin/env python3
"""
Visualization: The Quadratic Langlands Mirror

Generates a heatmap of Kronecker character values J(d, p) for
squarefree d vs. primes p, showing the "fingerprint" of each
quadratic field.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np
from math import gcd, isqrt


def jacobi_symbol(a: int, n: int) -> int:
    if n <= 0 or n % 2 == 0:
        return 1 if n == 1 else 0
    if n == 1:
        return 1
    a = a % n
    if a == 0:
        return 0 if n > 1 else 1
    result = 1
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a = a % n
    return result if n == 1 else 0


def kronecker_symbol(d: int, n: int) -> int:
    if n == 0:
        return 1 if abs(d) == 1 else 0
    if n == 1:
        return 1
    result = 1
    v = 0
    temp_n = n
    while temp_n % 2 == 0:
        v += 1
        temp_n //= 2
    if v > 0:
        if d % 2 == 0:
            return 0
        if v % 2 == 1:
            if d % 8 in (3, 5):
                result = -1
    if temp_n == 1:
        return result
    return result * jacobi_symbol(d, temp_n)


def sieve_primes(n: int):
    if n < 2:
        return []
    sieve = [True] * (n + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, isqrt(n) + 1):
        if sieve[i]:
            for j in range(i*i, n + 1, i):
                sieve[j] = False
    return [i for i in range(n + 1) if sieve[i]]


def is_squarefree(n: int) -> bool:
    if n == 0:
        return False
    n = abs(n)
    for p in range(2, isqrt(n) + 1):
        if n % (p * p) == 0:
            return False
    return True


def main():
    # Select squarefree integers
    d_values = sorted([d for d in range(-20, 21) if d != 0 and is_squarefree(d)])
    primes = sieve_primes(60)

    # Build the character matrix
    matrix = np.zeros((len(d_values), len(primes)))
    for i, d in enumerate(d_values):
        for j, p in enumerate(primes):
            matrix[i, j] = kronecker_symbol(d, p)

    # Create the heatmap
    fig, ax = plt.subplots(figsize=(14, 10))

    cmap = mcolors.ListedColormap(['#d32f2f', '#ffffff', '#1976d2'])
    bounds = [-1.5, -0.5, 0.5, 1.5]
    norm = mcolors.BoundaryNorm(bounds, cmap.N)

    im = ax.imshow(matrix, cmap=cmap, norm=norm, aspect='auto', interpolation='nearest')

    ax.set_xticks(range(len(primes)))
    ax.set_xticklabels([str(p) for p in primes], fontsize=7, rotation=45)
    ax.set_yticks(range(len(d_values)))
    ax.set_yticklabels([f"Q(√{d})" for d in d_values], fontsize=7)

    ax.set_xlabel("Prime p (probe)", fontsize=12)
    ax.set_ylabel("Quadratic field Q(√d) (shape)", fontsize=12)
    ax.set_title("The Langlands Mirror: Shape-Color Fingerprints\n"
                 "Blue = split (+1), White = ramified (0), Red = inert (−1)",
                 fontsize=14)

    cbar = plt.colorbar(im, ax=ax, ticks=[-1, 0, 1], shrink=0.8)
    cbar.ax.set_yticklabels(['Inert (−1)', 'Ramified (0)', 'Split (+1)'])

    plt.tight_layout()
    plt.savefig('langlands_mirror_heatmap.png', dpi=150, bbox_inches='tight')
    print("Saved: langlands_mirror_heatmap.png")

    # Second plot: character sums
    fig2, axes = plt.subplots(2, 2, figsize=(12, 10))

    test_fields = [(-1, "Q(i)"), (2, "Q(√2)"), (-3, "Q(√−3)"), (5, "Q(√5)")]
    N = 200

    for ax, (d, name) in zip(axes.flat, test_fields):
        partial_sums = []
        running = 0
        for n in range(1, N + 1):
            running += kronecker_symbol(d, n)
            partial_sums.append(running)

        D = d if d % 4 == 1 else 4 * d
        bound = abs(D) ** 0.5

        ax.plot(range(1, N + 1), partial_sums, 'b-', linewidth=0.8, alpha=0.8)
        ax.axhline(y=bound, color='r', linestyle='--', alpha=0.5, label=f'√|D| = {bound:.1f}')
        ax.axhline(y=-bound, color='r', linestyle='--', alpha=0.5)
        ax.axhline(y=0, color='gray', linestyle='-', alpha=0.3)
        ax.set_title(f"{name} (D={D})", fontsize=12)
        ax.set_xlabel("N")
        ax.set_ylabel("∑ χ_D(n)")
        ax.legend(fontsize=9)

    fig2.suptitle("Character Sum Cancellation: ∑ χ_D(n) stays bounded", fontsize=14)
    plt.tight_layout()
    plt.savefig('character_sums.png', dpi=150, bbox_inches='tight')
    print("Saved: character_sums.png")


if __name__ == "__main__":
    main()
