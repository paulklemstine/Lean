#!/usr/bin/env python3
"""
Weyl Algebra Algorithms

Implements:
1. Normal ordering for Weyl algebra elements (PBW basis computation)
2. Symbol map computation for filtered endomorphisms
3. Jacobian determinant computation and Keller condition checking

All algorithms correspond to formally verified Lean theorems.
"""

from fractions import Fraction
from typing import Dict, Tuple, List, Optional
import itertools

# Type aliases
WeylElement = Dict[Tuple[int, int], Fraction]


class WeylAlgebra:
    """
    The first Weyl algebra A₁(K) over ℚ.

    Elements are represented in PBW normal form as finite sums
    ∑ c_{ij} x^i d^j, stored as dictionaries {(i,j): c}.

    The multiplication rule is determined by the canonical commutation
    relation d·x - x·d = 1, which is the algebraic form of the
    Heisenberg uncertainty principle.

    Complexity:
    - Addition: O(max(|a|, |b|)) where |·| is number of monomials
    - Scalar multiplication: O(|a|)
    - Multiplication: O(|a| · |b| · min_deg) due to commutation rewriting
    - Normal ordering of word of length n: O(n · max_monomials)
    """

    @staticmethod
    def zero() -> WeylElement:
        """The zero element."""
        return {}

    @staticmethod
    def one() -> WeylElement:
        """The identity element 1 = x^0 d^0."""
        return {(0, 0): Fraction(1)}

    @staticmethod
    def x_gen() -> WeylElement:
        """The generator x."""
        return {(1, 0): Fraction(1)}

    @staticmethod
    def d_gen() -> WeylElement:
        """The generator d."""
        return {(0, 1): Fraction(1)}

    @staticmethod
    def monomial(c, i: int, j: int) -> WeylElement:
        """The monomial c · x^i · d^j."""
        c = Fraction(c)
        if c == 0:
            return {}
        return {(i, j): c}

    @staticmethod
    def add(a: WeylElement, b: WeylElement) -> WeylElement:
        """Sum of two Weyl elements. O(max(|a|, |b|))."""
        result = dict(a)
        for key, val in b.items():
            result[key] = result.get(key, Fraction(0)) + val
            if result[key] == 0:
                del result[key]
        return result

    @staticmethod
    def neg(a: WeylElement) -> WeylElement:
        """Negation of a Weyl element."""
        return {k: -v for k, v in a.items()}

    @staticmethod
    def sub(a: WeylElement, b: WeylElement) -> WeylElement:
        """Difference of two Weyl elements."""
        return WeylAlgebra.add(a, WeylAlgebra.neg(b))

    @staticmethod
    def scale(c, a: WeylElement) -> WeylElement:
        """Scalar multiplication. O(|a|)."""
        c = Fraction(c)
        if c == 0:
            return {}
        return {k: c * v for k, v in a.items() if c * v != 0}

    @staticmethod
    def mul_monomial(c1, i1: int, j1: int,
                     c2, i2: int, j2: int) -> WeylElement:
        """
        Multiply two monomials: (c1 · x^i1 · d^j1) · (c2 · x^i2 · d^j2).

        Uses the formula:
        d^b · x^c = ∑_{k=0}^{min(b,c)} C(b,k) · C(c,k) · k! · x^{c-k} · d^{b-k}

        So x^i1 · d^j1 · x^i2 · d^j2 = x^i1 · (d^j1 · x^i2) · d^j2

        Complexity: O(min(j1, i2))
        """
        c1, c2 = Fraction(c1), Fraction(c2)
        if c1 == 0 or c2 == 0:
            return {}

        result: WeylElement = {}
        # d^j1 · x^i2 = ∑_k binom(j1,k) · binom(i2,k) · k! · x^{i2-k} · d^{j1-k}
        from math import comb, factorial
        for k in range(min(j1, i2) + 1):
            coeff = Fraction(comb(j1, k) * comb(i2, k) * factorial(k))
            new_i = i1 + i2 - k
            new_j = j1 - k + j2
            val = c1 * c2 * coeff
            if val != 0:
                key = (new_i, new_j)
                result[key] = result.get(key, Fraction(0)) + val
                if result[key] == 0:
                    del result[key]
        return result

    @staticmethod
    def mul(a: WeylElement, b: WeylElement) -> WeylElement:
        """
        Multiply two Weyl elements in normal form.

        Complexity: O(|a| · |b| · max_degree)
        """
        result: WeylElement = {}
        for (i1, j1), c1 in a.items():
            for (i2, j2), c2 in b.items():
                term = WeylAlgebra.mul_monomial(c1, i1, j1, c2, i2, j2)
                result = WeylAlgebra.add(result, term)
        return result

    @staticmethod
    def commutator(a: WeylElement, b: WeylElement) -> WeylElement:
        """Lie bracket [a, b] = a·b - b·a."""
        return WeylAlgebra.sub(WeylAlgebra.mul(a, b), WeylAlgebra.mul(b, a))

    @staticmethod
    def total_degree(a: WeylElement) -> int:
        """Maximum total degree of monomials in support."""
        if not a:
            return -1  # Convention for zero element
        return max(i + j for (i, j) in a.keys())

    @staticmethod
    def normal_order_word(word: str) -> WeylElement:
        """
        Normal-order a Weyl word (string of 'x' and 'd').

        Algorithm: Process right-to-left, multiplying each generator
        on the LEFT of the accumulated normal form.

        For 'x': x · (∑ c_{ij} x^i d^j) = ∑ c_{ij} x^{i+1} d^j
        For 'd': d · (∑ c_{ij} x^i d^j) = ∑ c_{ij} (x^i d^{j+1} + i·x^{i-1} d^j)

        Correctness: Formally verified in Lean (deriv_comm_pow theorem).

        Complexity: O(n · M) where n = word length, M = max monomials
        """
        result = WeylAlgebra.one()

        for ch in reversed(word):
            if ch == 'x':
                new_result = {}
                for (i, j), c in result.items():
                    new_result[(i + 1, j)] = c
                result = new_result
            elif ch == 'd':
                new_result: WeylElement = {}
                for (i, j), c in result.items():
                    # d · x^i d^j = x^i d^{j+1} + i · x^{i-1} d^j
                    key1 = (i, j + 1)
                    new_result[key1] = new_result.get(key1, Fraction(0)) + c
                    if i > 0:
                        key2 = (i - 1, j)
                        new_result[key2] = new_result.get(key2, Fraction(0)) + c * i
                result = {k: v for k, v in new_result.items() if v != 0}

        return result

    @staticmethod
    def display(a: WeylElement) -> str:
        """Pretty-print a Weyl element."""
        if not a:
            return "0"
        terms = []
        for (i, j), c in sorted(a.items()):
            if c == 0:
                continue
            parts = []
            if c != 1 or (i == 0 and j == 0):
                parts.append(str(c))
            if i > 0:
                parts.append(f"x^{i}" if i > 1 else "x")
            if j > 0:
                parts.append(f"d^{j}" if j > 1 else "d")
            terms.append("·".join(parts) if parts else "1")
        return " + ".join(terms) if terms else "0"


class SymbolMap:
    """
    Symbol map computation for filtered Weyl endomorphisms.

    Given a filtered endomorphism φ of A₁(K) with:
      φ(x) = a·x + b·d + c
      φ(d) = a'·x + b'·d + c'

    The induced map on gr(A₁) ≅ K[x, ξ] is:
      x ↦ a·x + b·ξ
      ξ ↦ a'·x + b'·ξ

    with Jacobian matrix [[a, b], [a', b']].
    """

    @staticmethod
    def jacobian_det(a, b, ap, bp) -> Fraction:
        """
        Compute the Jacobian determinant of the induced symbol map.

        For the map x ↦ ax + bξ, ξ ↦ a'x + b'ξ, the Jacobian is:
        det [[a, b], [a', b']] = a·b' - b·a'

        Theorem (deg1_weyl_end_jacobian): If a'·b - b'·a = 1, then
        a·b' - b·a' = -1. Formally verified in Lean.

        Complexity: O(1)
        """
        return Fraction(a) * Fraction(bp) - Fraction(b) * Fraction(ap)

    @staticmethod
    def is_keller(a, b, ap, bp) -> bool:
        """
        Check the Keller condition: Jacobian determinant is a nonzero constant.

        For linear maps, this is simply det ≠ 0.

        Theorem (deg1_weyl_end_is_keller): All degree-1 Weyl endomorphisms
        satisfying the CCR are Keller. Formally verified in Lean.

        Complexity: O(1)
        """
        return SymbolMap.jacobian_det(a, b, ap, bp) != 0

    @staticmethod
    def check_weyl_relation(a, b, ap, bp) -> bool:
        """Check a'b - b'a = 1."""
        return Fraction(ap) * Fraction(b) - Fraction(bp) * Fraction(a) == 1

    @staticmethod
    def find_weyl_partners(a, b) -> List[Tuple[Fraction, Fraction]]:
        """
        Find all (a', b') such that a'b - b'a = 1.

        The solution set is a 1-parameter family:
        If b ≠ 0: a' = (1 + b'·a) / b for any b'
        If a ≠ 0: b' = (a'·b - 1) / a for any a'

        Returns a few representative solutions.
        """
        a, b = Fraction(a), Fraction(b)
        solutions = []
        if b != 0:
            for bp in range(-3, 4):
                bp = Fraction(bp)
                ap = (1 + bp * a) / b
                solutions.append((ap, bp))
        elif a != 0:
            for ap in range(-3, 4):
                ap = Fraction(ap)
                bp = (ap * b - 1) / a
                solutions.append((ap, bp))
        return solutions


def example_usage():
    """Demonstrate the algorithms."""
    W = WeylAlgebra

    print("=== WeylAlgebra Multiplication ===")
    x = W.x_gen()
    d = W.d_gen()
    dx = W.mul(d, x)
    print(f"d · x = {W.display(dx)}")

    xd = W.mul(x, d)
    print(f"x · d = {W.display(xd)}")

    comm = W.commutator(d, x)
    print(f"[d, x] = {W.display(comm)}")

    print("\n=== Normal Ordering ===")
    for word in ["dxdx", "ddxx", "dddxxx", "dxdxdx"]:
        nf = W.normal_order_word(word)
        print(f"  {word} = {W.display(nf)} (degree {W.total_degree(nf)})")

    print("\n=== Commutator Degree Drop ===")
    for a_deg in range(1, 5):
        for b_deg in range(1, 5):
            a_word = "x" * a_deg
            b_word = "d" * b_deg
            a_elem = W.normal_order_word(a_word)
            b_elem = W.normal_order_word(b_word)
            comm = W.commutator(a_elem, b_elem)
            if comm:
                print(f"  deg([x^{a_deg}, d^{b_deg}]) = {W.total_degree(comm)} "
                      f"< {a_deg + b_deg} = deg(x^{a_deg}) + deg(d^{b_deg})")

    print("\n=== Symbol Map ===")
    # Check that Weyl relation forces det = -1
    for a, b in [(1, 1), (2, 3), (0, 1), (1, 0)]:
        partners = SymbolMap.find_weyl_partners(a, b)
        for ap, bp in partners[:2]:
            det = SymbolMap.jacobian_det(a, b, ap, bp)
            print(f"  a={a}, b={b}, a'={ap}, b'={bp}: det = {det}")


if __name__ == "__main__":
    example_usage()
