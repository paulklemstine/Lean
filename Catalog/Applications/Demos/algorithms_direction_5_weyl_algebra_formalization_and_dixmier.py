#!/usr/bin/env python3
"""
Weyl Algebra Algorithms

Implements:
1. Normal ordering algorithm for the first Weyl algebra A₁(K)
2. Symbol map computation for degree-1 endomorphisms
3. Jacobian determinant computation
4. Keller condition checking

Time complexity:
- Normal ordering of a word of length n: O(n²) swaps, each producing O(1) terms
- Symbol matrix computation: O(1)
- Keller condition: O(1)

Space complexity:
- Normal ordering: O(n²) for the resulting list of monomials
"""

from typing import Dict, Tuple, List
from fractions import Fraction
from collections import defaultdict


class WeylMonomial:
    """A normal-form monomial coeff * x^i * d^j in the Weyl algebra A₁.

    Attributes:
        coeff: Coefficient (rational number)
        x_pow: Power of x
        d_pow: Power of d (operator order)
    """

    def __init__(self, coeff: Fraction, x_pow: int, d_pow: int):
        self.coeff = Fraction(coeff)
        self.x_pow = x_pow
        self.d_pow = d_pow

    def total_degree(self) -> int:
        """Bernstein filtration degree: i + j."""
        return self.x_pow + self.d_pow

    def order(self) -> int:
        """Operator order: power of d."""
        return self.d_pow

    def __repr__(self):
        return f"WeylMonomial({self.coeff}, x^{self.x_pow}, d^{self.d_pow})"

    def __eq__(self, other):
        return (self.coeff == other.coeff and
                self.x_pow == other.x_pow and
                self.d_pow == other.d_pow)


def normal_order_word(word: List[str]) -> Dict[Tuple[int, int], Fraction]:
    """Normal-order a word in x and d using the Weyl relation dx = xd + 1.

    Algorithm:
        Start with the word as a single monomial. Scan from left to right
        for any occurrence of 'd' immediately followed by 'x'. Replace
        d·x with x·d + 1 (producing two terms). Repeat until no d
        appears before any x.

    This is equivalent to bubble-sorting d's to the right past x's,
    with each swap producing an additional correction term.

    Args:
        word: List of 'x' and 'd' characters representing a product

    Returns:
        Dictionary mapping (x_pow, d_pow) to coefficient in normal form

    Time: O(n²) where n = len(word)
    Space: O(n²) for the result dictionary

    Examples:
        >>> normal_order_word(['d', 'x'])
        {(1, 1): Fraction(1, 1), (0, 0): Fraction(1, 1)}
        >>> normal_order_word(['d', 'x', 'x'])
        {(2, 1): Fraction(1, 1), (1, 0): Fraction(2, 1)}
    """
    # Represent as dict of (x_pow, d_pow) -> coefficient
    # Start by converting word to a list of terms
    # Each term is (coefficient, list_of_generators)
    terms: List[Tuple[Fraction, List[str]]] = [(Fraction(1), list(word))]
    result: Dict[Tuple[int, int], Fraction] = defaultdict(Fraction)

    while terms:
        coeff, w = terms.pop()
        if coeff == 0:
            continue

        # Find leftmost occurrence of 'd' followed later by 'x'
        swap_pos = -1
        for i in range(len(w) - 1):
            if w[i] == 'd' and w[i + 1] == 'x':
                swap_pos = i
                break

        if swap_pos == -1:
            # Already in normal order: count x's and d's
            x_count = w.count('x')
            d_count = w.count('d')
            result[(x_count, d_count)] += coeff
        else:
            # Apply dx = xd + 1: replace w[i]w[i+1] = 'dx' with 'xd' and '1'
            # Term 1: replace dx with xd (keep rest)
            w1 = w[:swap_pos] + ['x', 'd'] + w[swap_pos + 2:]
            terms.append((coeff, w1))

            # Term 2: replace dx with 1 (remove both generators)
            w2 = w[:swap_pos] + w[swap_pos + 2:]
            terms.append((coeff, w2))

    # Remove zero entries
    return {k: v for k, v in result.items() if v != 0}


def weyl_multiply(nf1: Dict[Tuple[int, int], Fraction],
                  nf2: Dict[Tuple[int, int], Fraction]) -> Dict[Tuple[int, int], Fraction]:
    """Multiply two normal-form elements in the Weyl algebra.

    Given two elements in normal form Σ aᵢⱼ x^i d^j and Σ bₖₗ x^k d^l,
    compute their product in normal form.

    The key identity used repeatedly: d^j * x^k = Σ_{m=0}^{min(j,k)} C(j,m)C(k,m)m! x^{k-m} d^{j-m}

    Args:
        nf1, nf2: Normal-form elements as (x_pow, d_pow) -> coefficient dicts

    Returns:
        Product in normal form
    """
    result: Dict[Tuple[int, int], Fraction] = defaultdict(Fraction)

    for (i1, j1), c1 in nf1.items():
        for (i2, j2), c2 in nf2.items():
            # Compute x^i1 * d^j1 * x^i2 * d^j2
            # = x^i1 * (d^j1 * x^i2) * d^j2
            # Use the normal ordering of d^j1 * x^i2
            word = ['d'] * j1 + ['x'] * i2
            d_x_normal = normal_order_word(word) if word else {(0, 0): Fraction(1)}

            for (xp, dp), coeff in d_x_normal.items():
                # x^i1 * (coeff * x^xp * d^dp) * d^j2
                # = coeff * x^(i1+xp) * d^(dp+j2)
                result[(i1 + xp, dp + j2)] += c1 * c2 * coeff

    return {k: v for k, v in result.items() if v != 0}


def display_normal_form(nf: Dict[Tuple[int, int], Fraction]) -> str:
    """Display a normal-form element as a human-readable string.

    Args:
        nf: Normal-form element as (x_pow, d_pow) -> coefficient dict

    Returns:
        Human-readable string representation

    Example:
        >>> display_normal_form({(2, 1): Fraction(1), (1, 0): Fraction(2)})
        'x²·d + 2x'
    """
    if not nf:
        return "0"

    superscripts = {'0': '⁰', '1': '¹', '2': '²', '3': '³', '4': '⁴',
                    '5': '⁵', '6': '⁶', '7': '⁷', '8': '⁸', '9': '⁹'}

    def sup(n: int) -> str:
        if n <= 1:
            return ''
        return ''.join(superscripts[c] for c in str(n))

    # Sort by total degree descending, then x_pow descending
    sorted_terms = sorted(nf.items(), key=lambda t: (-t[0][0] - t[0][1], -t[0][0]))

    parts = []
    for (xp, dp), coeff in sorted_terms:
        if coeff == 0:
            continue

        # Build monomial string
        factors = []
        if xp > 0:
            factors.append(f"x{sup(xp)}")
        if dp > 0:
            factors.append(f"d{sup(dp)}")

        monomial = '·'.join(factors) if factors else '1'

        if coeff == 1:
            if factors:
                parts.append(monomial)
            else:
                parts.append('1')
        elif coeff == -1:
            if factors:
                parts.append(f"-{monomial}")
            else:
                parts.append('-1')
        else:
            if factors:
                parts.append(f"{coeff}{monomial}")
            else:
                parts.append(str(coeff))

    return ' + '.join(parts).replace(' + -', ' - ') if parts else '0'


def symbol_matrix_det(a: float, b: float, c: float, e: float) -> float:
    """Compute the determinant of the symbol matrix [[a,b],[c,e]].

    For a degree-1 Weyl endomorphism φ(x) = ax + bd, φ(d) = cx + ed,
    the symbol matrix is M = [[a,b],[c,e]] and det(M) = ae - bc.

    The Weyl relation forces det(M) = 1 (Keller condition).

    Args:
        a, b, c, e: Entries of the symbol matrix

    Returns:
        Determinant ae - bc
    """
    return a * e - b * c


def check_keller_condition(a: float, b: float, c: float, e: float,
                           tol: float = 1e-10) -> bool:
    """Check if a symbol matrix satisfies the Keller condition det = 1.

    Args:
        a, b, c, e: Symbol matrix entries
        tol: Numerical tolerance

    Returns:
        True if |det(M) - 1| < tol
    """
    return abs(symbol_matrix_det(a, b, c, e) - 1.0) < tol


def compute_commutator_normal_form(
    x_image: Dict[Tuple[int, int], Fraction],
    d_image: Dict[Tuple[int, int], Fraction]
) -> Dict[Tuple[int, int], Fraction]:
    """Compute [φ(d), φ(x)] = φ(d)·φ(x) - φ(x)·φ(d) in normal form.

    This verifies the Weyl relation for the images of generators.

    Args:
        x_image: Normal form of φ(x)
        d_image: Normal form of φ(d)

    Returns:
        Normal form of the commutator [φ(d), φ(x)]
    """
    # φ(d) * φ(x)
    dx = weyl_multiply(d_image, x_image)
    # φ(x) * φ(d)
    xd = weyl_multiply(x_image, d_image)

    # Commutator = dx - xd
    result: Dict[Tuple[int, int], Fraction] = defaultdict(Fraction)
    for k, v in dx.items():
        result[k] += v
    for k, v in xd.items():
        result[k] -= v

    return {k: v for k, v in result.items() if v != 0}


def verify_weyl_relation(
    x_image: Dict[Tuple[int, int], Fraction],
    d_image: Dict[Tuple[int, int], Fraction]
) -> bool:
    """Verify that [φ(d), φ(x)] = 1 for given endomorphism images.

    Args:
        x_image: Normal form of φ(x)
        d_image: Normal form of φ(d)

    Returns:
        True if the commutator equals 1
    """
    comm = compute_commutator_normal_form(x_image, d_image)
    return comm == {(0, 0): Fraction(1)}


# ─── Example usage ───────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=== Weyl Algebra Algorithms ===")
    print()

    # Normal ordering examples
    print("Normal ordering d·x:")
    print(f"  {display_normal_form(normal_order_word(['d', 'x']))}")
    print()

    print("Normal ordering d²·x²:")
    print(f"  {display_normal_form(normal_order_word(['d', 'd', 'x', 'x']))}")
    print()

    print("Normal ordering d³·x³:")
    print(f"  {display_normal_form(normal_order_word(['d', 'd', 'd', 'x', 'x', 'x']))}")
    print()

    # Verify Weyl relation for identity
    x_id = {(1, 0): Fraction(1)}  # x ↦ x
    d_id = {(0, 1): Fraction(1)}  # d ↦ d
    print(f"Identity preserves Weyl relation: {verify_weyl_relation(x_id, d_id)}")

    # Verify for a shear: x ↦ x + d, d ↦ d
    x_shear = {(1, 0): Fraction(1), (0, 1): Fraction(1)}
    d_shear = {(0, 1): Fraction(1)}
    print(f"Shear preserves Weyl relation: {verify_weyl_relation(x_shear, d_shear)}")

    # Verify for scaling: x ↦ 2x, d ↦ d/2
    x_scale = {(1, 0): Fraction(2)}
    d_scale = {(0, 1): Fraction(1, 2)}
    print(f"Scaling preserves Weyl relation: {verify_weyl_relation(x_scale, d_scale)}")
