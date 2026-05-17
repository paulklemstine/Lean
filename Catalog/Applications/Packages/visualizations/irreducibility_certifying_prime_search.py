#!/usr/bin/env python3
"""
Algorithms for polynomial irreducibility testing via modular transfer.

Implements the complete pipeline:
1. Polynomial arithmetic over finite fields GF(p)
2. Irreducibility testing over GF(p) by exhaustive factorization
3. Modular transfer: irreducible mod p + monic → irreducible over ℤ
4. Multi-prime search for certifying primes

Time complexity analysis:
- Root check over GF(p): O(p · d) where d = degree
- Exhaustive divisor check over GF(p): O(p^(d/2) · d²) 
- Finding a certifying prime: expected O(1) primes suffice for random polynomials
"""

from typing import Optional
from itertools import product
from math import gcd
from functools import reduce


class PolyGFp:
    """Polynomial over GF(p), represented as a list of coefficients mod p.
    
    coeffs[i] is the coefficient of x^i. The list is normalized so the last
    element is nonzero (except for the zero polynomial, represented as [0]).
    """
    
    def __init__(self, coeffs: list[int], p: int):
        self.p = p
        self.coeffs = [c % p for c in coeffs]
        self._normalize()
    
    def _normalize(self):
        while len(self.coeffs) > 1 and self.coeffs[-1] == 0:
            self.coeffs.pop()
    
    @property
    def degree(self) -> int:
        if self.coeffs == [0]:
            return -1
        return len(self.coeffs) - 1
    
    @property
    def is_zero(self) -> bool:
        return self.coeffs == [0]
    
    @property
    def is_monic(self) -> bool:
        return not self.is_zero and self.coeffs[-1] == 1
    
    @property
    def leading_coeff(self) -> int:
        return self.coeffs[-1]
    
    def __add__(self, other: 'PolyGFp') -> 'PolyGFp':
        assert self.p == other.p
        n = max(len(self.coeffs), len(other.coeffs))
        a = self.coeffs + [0] * (n - len(self.coeffs))
        b = other.coeffs + [0] * (n - len(other.coeffs))
        return PolyGFp([(a[i] + b[i]) % self.p for i in range(n)], self.p)
    
    def __sub__(self, other: 'PolyGFp') -> 'PolyGFp':
        assert self.p == other.p
        n = max(len(self.coeffs), len(other.coeffs))
        a = self.coeffs + [0] * (n - len(self.coeffs))
        b = other.coeffs + [0] * (n - len(other.coeffs))
        return PolyGFp([(a[i] - b[i]) % self.p for i in range(n)], self.p)
    
    def __mul__(self, other: 'PolyGFp') -> 'PolyGFp':
        assert self.p == other.p
        if self.is_zero or other.is_zero:
            return PolyGFp([0], self.p)
        n = len(self.coeffs) + len(other.coeffs) - 1
        result = [0] * n
        for i, a in enumerate(self.coeffs):
            for j, b in enumerate(other.coeffs):
                result[i + j] = (result[i + j] + a * b) % self.p
        return PolyGFp(result, self.p)
    
    def scalar_mul(self, c: int) -> 'PolyGFp':
        return PolyGFp([x * c for x in self.coeffs], self.p)
    
    def __mod__(self, other: 'PolyGFp') -> 'PolyGFp':
        """Polynomial remainder."""
        assert self.p == other.p and not other.is_zero
        r = list(self.coeffs)
        d = other.degree
        lc_inv = pow(other.leading_coeff, -1, self.p)
        while len(r) > d:
            if r[-1] == 0:
                r.pop()
                continue
            coeff = (r[-1] * lc_inv) % self.p
            shift = len(r) - 1 - d
            for i in range(len(other.coeffs)):
                r[i + shift] = (r[i + shift] - coeff * other.coeffs[i]) % self.p
            r.pop()
        if not r:
            r = [0]
        return PolyGFp(r, self.p)
    
    def __floordiv__(self, other: 'PolyGFp') -> 'PolyGFp':
        """Polynomial quotient."""
        assert self.p == other.p and not other.is_zero
        r = list(self.coeffs)
        d = other.degree
        lc_inv = pow(other.leading_coeff, -1, self.p)
        q = []
        while len(r) > d:
            if r[-1] == 0:
                r.pop()
                q.append(0)
                continue
            coeff = (r[-1] * lc_inv) % self.p
            q.append(coeff)
            shift = len(r) - 1 - d
            for i in range(len(other.coeffs)):
                r[i + shift] = (r[i + shift] - coeff * other.coeffs[i]) % self.p
            r.pop()
        q.reverse()
        if not q:
            q = [0]
        return PolyGFp(q, self.p)
    
    def divides(self, other: 'PolyGFp') -> bool:
        """Check if self divides other."""
        return (other % self).is_zero
    
    def eval(self, x: int) -> int:
        """Evaluate at x in GF(p)."""
        result = 0
        xi = 1
        for c in self.coeffs:
            result = (result + c * xi) % self.p
            xi = (xi * x) % self.p
        return result
    
    def __eq__(self, other) -> bool:
        if not isinstance(other, PolyGFp):
            return False
        return self.p == other.p and self.coeffs == other.coeffs
    
    def __repr__(self) -> str:
        terms = []
        for i in range(len(self.coeffs) - 1, -1, -1):
            c = self.coeffs[i]
            if c == 0:
                continue
            if i == 0:
                terms.append(str(c))
            elif i == 1:
                terms.append(f"{c}x" if c != 1 else "x")
            else:
                terms.append(f"{c}x^{i}" if c != 1 else f"x^{i}")
        return " + ".join(terms) if terms else "0"


def enumerate_monic_polys(degree: int, p: int) -> list[PolyGFp]:
    """Enumerate all monic polynomials of given degree over GF(p).
    
    Returns p^degree polynomials.
    
    Time: O(p^degree)
    Space: O(p^degree · degree)
    """
    if degree < 0:
        return []
    if degree == 0:
        return [PolyGFp([1], p)]
    polys = []
    for coeffs in product(range(p), repeat=degree):
        poly = PolyGFp(list(coeffs) + [1], p)
        polys.append(poly)
    return polys


def is_irreducible_gfp(f: PolyGFp) -> bool:
    """Test irreducibility of a polynomial over GF(p) by exhaustive search.
    
    Algorithm:
    1. Check that f has positive degree and is not a unit.
    2. For each degree d from 1 to deg(f)/2, enumerate all monic polys
       of degree d and check divisibility.
    3. If no proper divisor found, f is irreducible.
    
    Time complexity: O(p^(d/2) · d²) where d = deg(f)
    Space complexity: O(p^(d/2) · d)
    
    This is practical for small p and d. For large parameters,
    use probabilistic algorithms (Berlekamp, Cantor-Zassenhaus).
    """
    d = f.degree
    if d <= 0:
        return False
    if d == 1:
        return True
    
    # Check all possible factor degrees
    for factor_deg in range(1, d // 2 + 1):
        for g in enumerate_monic_polys(factor_deg, f.p):
            if g.divides(f):
                return False
    return True


def find_certifying_prime(coeffs_z: list[int], max_prime: int = 100) -> Optional[int]:
    """Find a prime p such that f mod p is irreducible.
    
    Algorithm:
    1. For each prime p ≤ max_prime:
       a. Check that p does not divide the leading coefficient.
       b. Reduce f mod p.
       c. Test irreducibility over GF(p).
    2. Return the first certifying prime, or None.
    
    For a random irreducible polynomial of degree d, the Chebotarev density
    theorem implies that a proportion 1/d of primes are certifying, so
    we expect to find one within the first O(d) primes.
    
    Args:
        coeffs_z: Coefficients of f over ℤ (coeffs_z[i] = coeff of x^i)
        max_prime: Upper bound on primes to try
    
    Returns:
        A certifying prime p, or None if no prime ≤ max_prime works
    """
    def is_prime(n):
        if n < 2:
            return False
        for i in range(2, int(n**0.5) + 1):
            if n % i == 0:
                return False
        return True
    
    leading = coeffs_z[-1]
    
    for p in range(2, max_prime + 1):
        if not is_prime(p):
            continue
        # Skip if p divides leading coefficient (degree drops)
        if leading % p == 0:
            continue
        f_mod_p = PolyGFp(coeffs_z, p)
        if f_mod_p.degree != len(coeffs_z) - 1:
            continue  # degree dropped
        if is_irreducible_gfp(f_mod_p):
            return p
    return None


def is_primitive_poly_z(coeffs: list[int]) -> bool:
    """Check if an integer polynomial is primitive (GCD of coefficients is 1)."""
    return reduce(gcd, coeffs) == 1


def prove_irreducible_z(coeffs_z: list[int], verbose: bool = True) -> dict:
    """Attempt to prove a monic integer polynomial is irreducible.
    
    Uses the modular transfer pipeline:
    1. Verify the polynomial is monic.
    2. Search for a certifying prime.
    3. Verify irreducibility over GF(p).
    4. Apply the transfer theorem.
    
    Args:
        coeffs_z: Coefficients [a₀, a₁, ..., aₙ] of f = a₀ + a₁x + ... + aₙxⁿ
        verbose: Print progress information
    
    Returns:
        Dictionary with:
          'irreducible': bool — whether irreducibility was proved
          'certifying_prime': int or None
          'polynomial': string representation
          'method': description of proof method
    """
    if not coeffs_z or coeffs_z[-1] != 1:
        return {
            'irreducible': None,
            'certifying_prime': None,
            'polynomial': str(coeffs_z),
            'method': 'NOT MONIC — transfer theorem requires monicity'
        }
    
    degree = len(coeffs_z) - 1
    
    # Build string representation
    terms = []
    for i in range(degree, -1, -1):
        if coeffs_z[i] == 0:
            continue
        if i == degree:
            terms.append(f"x^{i}" if i > 1 else ("x" if i == 1 else "1"))
        elif coeffs_z[i] == 1:
            terms.append(f"x^{i}" if i > 1 else ("x" if i == 1 else "1"))
        elif coeffs_z[i] == -1:
            terms.append(f"-x^{i}" if i > 1 else ("-x" if i == 1 else "-1"))
        else:
            terms.append(f"{coeffs_z[i]}x^{i}" if i > 1 
                        else (f"{coeffs_z[i]}x" if i == 1 else str(coeffs_z[i])))
    poly_str = " + ".join(terms).replace("+ -", "- ")
    
    if verbose:
        print(f"Attempting to prove irreducibility of f(x) = {poly_str}")
        print(f"Degree: {degree}")
    
    p = find_certifying_prime(coeffs_z)
    
    if p is None:
        if verbose:
            print("  No certifying prime found (polynomial may be reducible)")
        return {
            'irreducible': False,
            'certifying_prime': None,
            'polynomial': poly_str,
            'method': 'No certifying prime found among first 100 primes'
        }
    
    if verbose:
        print(f"  Certifying prime found: p = {p}")
        f_mod_p = PolyGFp(coeffs_z, p)
        print(f"  f mod {p} = {f_mod_p}")
        print(f"  f mod {p} is irreducible over GF({p}): True")
        print(f"  f is monic: True")
        print(f"  ∴ By modular transfer theorem, f is IRREDUCIBLE over ℤ (and ℚ)")
    
    return {
        'irreducible': True,
        'certifying_prime': p,
        'polynomial': poly_str,
        'method': f'Modular transfer via GF({p})'
    }


# ============================================================
# Example usage and demonstrations
# ============================================================

if __name__ == "__main__":
    print("=" * 70)
    print("POLYNOMIAL IRREDUCIBILITY CERTIFICATION VIA MODULAR TRANSFER")
    print("=" * 70)
    print()
    
    # Test cases: monic integer polynomials
    test_cases = [
        # [a₀, a₁, ..., aₙ] for f = a₀ + a₁x + ... + aₙxⁿ
        ([1, 1, 0, 0, 1], "x^4 + x + 1"),
        ([1, 0, 1, 0, 1], "x^4 + x^2 + 1 (reducible!)"),
        ([1, 1, 1], "x^2 + x + 1"),
        ([2, 0, 0, 0, 1], "x^4 + 2 (Eisenstein at 2)"),
        ([1, 1, 0, 1], "x^3 + x + 1"),
        ([3, 0, 0, 0, 0, 1], "x^5 + 3"),
        ([-1, 0, 1], "x^2 - 1 (reducible!)"),
        ([1, 0, 0, 0, 0, 1, 0, 0, 1], "x^8 + x^5 + 1"),
    ]
    
    for coeffs, name in test_cases:
        print(f"\n{'─' * 60}")
        print(f"Testing: {name}")
        print(f"{'─' * 60}")
        result = prove_irreducible_z(coeffs)
        print()
    
    # Demonstrate the enumeration of irreducible polynomials over GF(2)
    print(f"\n{'=' * 70}")
    print("ALL IRREDUCIBLE POLYNOMIALS OVER GF(2) UP TO DEGREE 5")
    print(f"{'=' * 70}")
    for d in range(1, 6):
        irreds = []
        for poly in enumerate_monic_polys(d, 2):
            if is_irreducible_gfp(poly):
                irreds.append(poly)
        print(f"\n  Degree {d}: {len(irreds)} irreducible polynomial(s)")
        for poly in irreds:
            print(f"    {poly}")
    
    print(f"\n{'=' * 70}")
    print("CERTIFYING PRIMES FOR CYCLOTOMIC-LIKE POLYNOMIALS")
    print(f"{'=' * 70}")
    # For each polynomial, find ALL certifying primes up to 50
    polys_to_check = [
        [1, 1, 0, 0, 1],    # x^4 + x + 1
        [1, 1, 1],           # x^2 + x + 1
        [1, 1, 0, 1],        # x^3 + x + 1
    ]
    for coeffs in polys_to_check:
        f_str = PolyGFp(coeffs, 2).__repr__().replace("x", "X")
        certifying = []
        for p in range(2, 51):
            def is_prime(n):
                if n < 2: return False
                for i in range(2, int(n**0.5)+1):
                    if n % i == 0: return False
                return True
            if not is_prime(p):
                continue
            fp = PolyGFp(coeffs, p)
            if fp.degree == len(coeffs) - 1 and is_irreducible_gfp(fp):
                certifying.append(p)
        print(f"\n  f = {f_str}")
        print(f"  Certifying primes ≤ 50: {certifying}")
        print(f"  Density: {len(certifying)}/{len([p for p in range(2,51) if is_prime(p)])}")
