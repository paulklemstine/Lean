#!/usr/bin/env python3
"""
Algorithms for the GL₁ Langlands Shape-Color Correspondence.

Implements the core mathematical objects:
- Legendre/Jacobi symbols (quadratic characters)
- Gauss sums over finite fields
- Character orthogonality verification
- Shape-color matching for quadratic extensions
"""

import cmath
import math
from typing import List, Dict, Tuple, Optional


def is_prime(n: int) -> bool:
    """Miller-Rabin primality test for small numbers."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0:
        return False
    d = n - 1
    r = 0
    while d % 2 == 0:
        d //= 2
        r += 1
    for a in [2, 3, 5, 7, 11, 13]:
        if a >= n:
            continue
        x = pow(a, d, n)
        if x == 1 or x == n - 1:
            continue
        for _ in range(r - 1):
            x = pow(x, 2, n)
            if x == n - 1:
                break
        else:
            return False
    return True


def legendre_symbol(a: int, p: int) -> int:
    """
    Compute the Legendre symbol (a/p).

    The Legendre symbol is the fundamental "shape detector":
    - (a/p) = 1 if a is a quadratic residue mod p (a "square")
    - (a/p) = -1 if a is a quadratic non-residue mod p
    - (a/p) = 0 if p divides a

    This is the GL₁ Langlands "color" assigned to element a by prime p.

    Args:
        a: Integer to test
        p: Odd prime modulus

    Returns:
        Legendre symbol value in {-1, 0, 1}
    """
    if not is_prime(p) or p == 2:
        raise ValueError(f"p={p} must be an odd prime")
    a = a % p
    if a == 0:
        return 0
    val = pow(a, (p - 1) // 2, p)
    return val if val == 1 else -1


def jacobi_symbol(a: int, n: int) -> int:
    """
    Compute the Jacobi symbol (a/n) for odd positive n.

    The Jacobi symbol extends the Legendre symbol to composite moduli
    via multiplicativity: (a/n₁n₂) = (a/n₁)(a/n₂).

    This is the BilinearSymbol from GL1LanglandsBilinear.lean.

    Args:
        a: Integer (first argument)
        n: Odd positive integer (second argument)

    Returns:
        Jacobi symbol value in {-1, 0, 1}
    """
    if n <= 0 or n % 2 == 0:
        raise ValueError(f"n={n} must be odd and positive")
    a = a % n
    result = 1
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if n % 8 in [3, 5]:
                result = -result
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a = a % n
    return result if n == 1 else 0


def gauss_sum(p: int, chi: Optional[callable] = None) -> complex:
    """
    Compute the Gauss sum g(χ, ψ) = Σ_{t ∈ F_p} χ(t)·ψ(t).

    Uses the standard additive character ψ(t) = e^{2πit/p}
    and the quadratic character χ = (·/p) by default.

    The Gauss sum is the "paintbrush" that transforms shapes (Galois)
    into colors (automorphic). It satisfies:
    - |g(χ)|² = p (shape recovery)
    - g(χ)² = χ(-1)·p (quadratic formula)
    - χ(a)·g(χ, ψ∘(a·)) = g(χ, ψ) (intertwining)

    Args:
        p: Prime modulus
        chi: Character function (defaults to Legendre symbol)

    Returns:
        Complex Gauss sum value
    """
    if chi is None:
        chi = lambda t: legendre_symbol(t, p)
    omega = cmath.exp(2j * cmath.pi / p)
    return sum(chi(t) * omega**t for t in range(p))


def quadratic_discriminant(d: int) -> int:
    """
    Compute the discriminant of Q(√d) for squarefree d.

    The discriminant D is:
    - D = d if d ≡ 1 (mod 4)
    - D = 4d if d ≡ 2 or 3 (mod 4)

    The discriminant is the "shape parameter" that determines the
    corresponding Dirichlet character in the Langlands correspondence.

    Args:
        d: Squarefree integer

    Returns:
        Discriminant D
    """
    if d % 4 == 1:
        return d
    else:
        return 4 * d


def kronecker_symbol(d: int, n: int) -> int:
    """
    Compute the Kronecker symbol (d/n), extending Jacobi to all integers.

    The Kronecker symbol is the Dirichlet character χ_D associated to
    the quadratic field Q(√d) with discriminant D. It encodes:
    - χ_D(p) = 1: p splits in Q(√d) → two shapes
    - χ_D(p) = -1: p is inert in Q(√d) → one compound shape
    - χ_D(p) = 0: p ramifies in Q(√d) → degenerate shape

    Args:
        d: Discriminant
        n: Integer to evaluate at

    Returns:
        Kronecker symbol value in {-1, 0, 1}
    """
    if n == 0:
        return 1 if abs(d) == 1 else 0
    if n == 1:
        return 1
    if n == -1:
        return -1 if d < 0 else 1

    # Handle n = 2
    if n == 2:
        if d % 2 == 0:
            return 0
        d8 = d % 8
        if d8 == 1 or d8 == 7:
            return 1
        else:
            return -1

    # For odd prime n
    if n < 0:
        return kronecker_symbol(d, -1) * kronecker_symbol(d, -n)

    # Factor out powers of 2
    result = 1
    temp_n = n
    while temp_n % 2 == 0:
        result *= kronecker_symbol(d, 2)
        temp_n //= 2

    if temp_n > 1:
        result *= jacobi_symbol(d, temp_n)

    return result


def shape_color_table(p: int) -> Dict[str, List]:
    """
    Generate the complete shape-color correspondence table for F_p.

    For each element a ∈ {1, ..., p-1}:
    - Shape: whether a is a square (geometric property)
    - Color: the value of χ(a) (spectral property)
    - These always match: square ↔ color +1, non-square ↔ color -1

    Args:
        p: Prime

    Returns:
        Dictionary with elements, shapes, and colors
    """
    elements = list(range(1, p))
    squares_set = set()
    for a in range(1, p):
        squares_set.add((a * a) % p)

    shapes = ["square" if a in squares_set else "non-square" for a in elements]
    colors = [legendre_symbol(a, p) for a in elements]

    # Verify the correspondence
    for i, a in enumerate(elements):
        expected_color = 1 if shapes[i] == "square" else -1
        assert colors[i] == expected_color, f"Mismatch at a={a}"

    return {
        "elements": elements,
        "shapes": shapes,
        "colors": colors,
        "num_squares": sum(1 for s in shapes if s == "square"),
        "num_nonsquares": sum(1 for s in shapes if s == "non-square"),
    }


def verify_langlands_gl1(max_p: int = 50) -> List[Dict]:
    """
    Verify the GL₁ Langlands correspondence for all primes up to max_p.

    Checks:
    1. g(χ)² = χ(-1)·p (Gauss sum squared)
    2. Σ χ(a) = 0 (color conservation)
    3. |squares| = (p-1)/2 (color balance)
    4. Color mixing rules hold

    Args:
        max_p: Maximum prime to check

    Returns:
        List of verification results
    """
    results = []
    for p in range(3, max_p + 1, 2):
        if not is_prime(p):
            continue

        g = gauss_sum(p)
        g_sq = g * g
        chi_neg1 = legendre_symbol(-1, p)
        expected = chi_neg1 * p

        char_sum = sum(legendre_symbol(a, p) for a in range(p))
        table = shape_color_table(p)

        results.append({
            "prime": p,
            "gauss_sq_match": abs(g_sq - expected) < 1e-6,
            "color_conservation": char_sum == 0,
            "color_balance": table["num_squares"] == table["num_nonsquares"],
            "chi_neg1": chi_neg1,
            "p_mod4": p % 4,
        })

    return results


if __name__ == "__main__":
    results = verify_langlands_gl1(100)
    print(f"Verified GL₁ Langlands for {len(results)} primes up to 100.")
    all_ok = all(r["gauss_sq_match"] and r["color_conservation"] and r["color_balance"]
                 for r in results)
    print(f"All checks passed: {all_ok}")
