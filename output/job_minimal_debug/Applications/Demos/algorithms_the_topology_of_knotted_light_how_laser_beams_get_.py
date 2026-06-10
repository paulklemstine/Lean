#!/usr/bin/env python3
"""
Algorithms for Knotted Light Topology

Type-hinted implementations of the core algorithms for computing
knot invariants and OAM spectra.
"""

import numpy as np
from typing import List, Tuple, Dict, Callable, Optional


# --- Polynomial Representation ---

class KnotPolynomial:
    """
    Represents a knot's Alexander polynomial as a list of integer coefficients.
    coeffs[i] is the coefficient of t^i.
    """
    
    def __init__(self, coeffs: List[int], name: str = ""):
        self.coeffs = coeffs
        self.name = name
        self.degree = len(coeffs) - 1
    
    def eval(self, t: complex) -> complex:
        """Evaluate the polynomial at a complex value t."""
        return sum(c * t**i for i, c in enumerate(self.coeffs))
    
    def determinant(self) -> int:
        """Compute the knot determinant |Δ(-1)|."""
        return abs(round(self.eval(-1).real))
    
    def fox_value(self) -> int:
        """Compute Δ(1) (Fox normalization)."""
        return round(self.eval(1).real)
    
    def is_palindromic(self) -> bool:
        """Check if the polynomial is palindromic (coefficients read same both ways)."""
        n = len(self.coeffs)
        return all(self.coeffs[i] == self.coeffs[n - 1 - i] for i in range(n // 2 + 1))
    
    def seifert_genus(self) -> int:
        """Compute the Seifert genus (= degree / 2 for Alexander polynomials)."""
        return self.degree // 2
    
    def discriminant(self) -> Optional[int]:
        """Compute discriminant for quadratic polynomials only."""
        if self.degree != 2:
            return None
        a, b, c = self.coeffs[2], self.coeffs[1], self.coeffs[0]
        return b**2 - 4 * a * c
    
    def __mul__(self, other: 'KnotPolynomial') -> 'KnotPolynomial':
        """Multiply two polynomials (connected sum of knots)."""
        n = len(self.coeffs)
        m = len(other.coeffs)
        result = [0] * (n + m - 1)
        for i in range(n):
            for j in range(m):
                result[i + j] += self.coeffs[i] * other.coeffs[j]
        return KnotPolynomial(result, f"{self.name}#{other.name}")
    
    def __repr__(self) -> str:
        terms = []
        for i, c in enumerate(self.coeffs):
            if c == 0:
                continue
            if i == 0:
                terms.append(str(c))
            elif i == 1:
                terms.append(f"{c}t" if c != 1 else "t")
            else:
                terms.append(f"{c}t^{i}" if c != 1 else f"t^{i}")
        return " + ".join(terms) if terms else "0"


# --- Predefined Knot Polynomials ---

UNKNOT = KnotPolynomial([1], "unknot")
TREFOIL = KnotPolynomial([1, -1, 1], "trefoil")
FIGURE_EIGHT = KnotPolynomial([1, -3, 1], "figure-eight")
CINQUEFOIL = KnotPolynomial([1, -1, 1, -1, 1], "cinquefoil")


# --- OAM Spectrum Algorithm ---

def compute_oam_spectrum(
    poly: KnotPolynomial,
    N: int,
    tolerance: float = 1e-10
) -> List[int]:
    """
    Compute the OAM spectrum of a knotted light beam.
    
    For a knot K with Alexander polynomial Δ_K and parameter N,
    returns {l ∈ [0, N) : |Δ_K(e^{2πil/N})| < tolerance}.
    
    Args:
        poly: Alexander polynomial of the knot
        N: Period parameter (related to crossing number or knot symmetry)
        tolerance: Numerical tolerance for root detection
    
    Returns:
        List of integers l where the polynomial vanishes at the N-th root of unity
    """
    spectrum: List[int] = []
    for l in range(N):
        root_of_unity = np.exp(2j * np.pi * l / N)
        value = poly.eval(root_of_unity)
        if abs(value) < tolerance:
            spectrum.append(l)
    return spectrum


def classify_root_structure(poly: KnotPolynomial) -> str:
    """
    Classify whether roots lie on the unit circle (crystalline OAM spectrum)
    or off it (metallic/continuous).
    
    For palindromic quadratics t^2 + bt + 1:
    - |b| < 2: all roots on unit circle (crystalline)
    - |b| = 2: degenerate (roots at ±1)
    - |b| > 2: real roots off unit circle (metallic)
    """
    if not poly.is_palindromic():
        return "non-palindromic (general)"
    
    disc = poly.discriminant()
    if disc is None:
        # Higher degree: check numerically
        roots_on_circle = True
        for l in range(360):
            t = np.exp(2j * np.pi * l / 360)
            if abs(poly.eval(t)) < 1e-8:
                continue
        # Check all roots numerically
        coeffs = poly.coeffs[::-1]
        roots = np.roots(coeffs)
        all_unit = all(abs(abs(r) - 1) < 1e-8 for r in roots)
        return "crystalline (all roots on unit circle)" if all_unit else "metallic (roots off unit circle)"
    
    if disc < 0:
        return "crystalline (negative discriminant, roots on unit circle)"
    elif disc == 0:
        return "degenerate (discriminant = 0)"
    else:
        return "metallic (positive discriminant, real roots)"


def find_cyclotomic_match(poly: KnotPolynomial, max_n: int = 100) -> Optional[int]:
    """
    Check if the polynomial matches a cyclotomic polynomial Φ_n for n ≤ max_n.
    
    Uses the fact that Φ_n has roots at primitive n-th roots of unity.
    """
    from numpy.polynomial import polynomial as P
    
    for n in range(1, max_n + 1):
        # Compute cyclotomic polynomial Φ_n
        cyclotomic_coeffs = compute_cyclotomic(n)
        if len(cyclotomic_coeffs) != len(poly.coeffs):
            continue
        if all(abs(a - b) < 1e-10 for a, b in zip(cyclotomic_coeffs, poly.coeffs)):
            return n
    return None


def compute_cyclotomic(n: int) -> List[int]:
    """
    Compute the n-th cyclotomic polynomial coefficients.
    Uses the formula Φ_n(x) = Π_{d|n} (x^d - 1)^{μ(n/d)}
    """
    def mobius(k: int) -> int:
        if k == 1:
            return 1
        factors = []
        temp = k
        for p in range(2, k + 1):
            if temp % p == 0:
                count = 0
                while temp % p == 0:
                    temp //= p
                    count += 1
                if count > 1:
                    return 0
                factors.append(p)
        return (-1) ** len(factors)
    
    def divisors(k: int) -> List[int]:
        return [d for d in range(1, k + 1) if k % d == 0]
    
    # Start with polynomial 1
    result = np.array([1.0])
    
    for d in divisors(n):
        mu = mobius(n // d)
        if mu == 0:
            continue
        # x^d - 1
        xd_minus_1 = np.zeros(d + 1)
        xd_minus_1[0] = -1
        xd_minus_1[d] = 1
        
        if mu == 1:
            result = np.polymul(result, xd_minus_1)
        elif mu == -1:
            result, remainder = np.polydiv(result, xd_minus_1)
    
    return [int(round(c)) for c in result[::-1]]


def connected_sum_spectrum(
    poly1: KnotPolynomial,
    poly2: KnotPolynomial,
    N: int
) -> Tuple[List[int], List[int], List[int]]:
    """
    Compute OAM spectra of individual knots and their connected sum.
    
    Returns (spectrum1, spectrum2, spectrum_sum) where spectrum_sum
    is the union of spectrum1 and spectrum2 (since product polynomial
    vanishes where either factor does).
    """
    s1 = compute_oam_spectrum(poly1, N)
    s2 = compute_oam_spectrum(poly2, N)
    product = poly1 * poly2
    s_sum = compute_oam_spectrum(product, N)
    return s1, s2, s_sum


def knot_invariant_table(polys: List[KnotPolynomial]) -> List[Dict]:
    """Generate a table of knot invariants."""
    results = []
    for p in polys:
        result = {
            'name': p.name,
            'polynomial': repr(p),
            'degree': p.degree,
            'determinant': p.determinant(),
            'fox_value': p.fox_value(),
            'palindromic': p.is_palindromic(),
            'seifert_genus': p.seifert_genus(),
            'root_type': classify_root_structure(p),
        }
        cyc = find_cyclotomic_match(p)
        if cyc is not None:
            result['cyclotomic'] = f"Φ_{cyc}"
        results.append(result)
    return results


if __name__ == "__main__":
    print("=== Knot Invariant Table ===")
    table = knot_invariant_table([UNKNOT, TREFOIL, FIGURE_EIGHT, CINQUEFOIL])
    for entry in table:
        print(f"\n{entry['name'].upper()}:")
        for k, v in entry.items():
            if k != 'name':
                print(f"  {k}: {v}")
    
    print("\n=== OAM Spectra ===")
    for poly in [TREFOIL, FIGURE_EIGHT, CINQUEFOIL]:
        for N in [6, 10, 12, 30]:
            spec = compute_oam_spectrum(poly, N)
            if spec:
                print(f"  {poly.name} mod {N}: {spec}")
    
    print("\n=== Connected Sum ===")
    s1, s2, s_sum = connected_sum_spectrum(TREFOIL, TREFOIL, 6)
    print(f"  Trefoil spectrum mod 6: {s1}")
    print(f"  Granny knot spectrum mod 6: {s_sum}")
    
    print("\n=== Root Classification ===")
    for b in range(-4, 5):
        p = KnotPolynomial([1, b, 1], f"t²+{b}t+1")
        print(f"  b={b:+d}: {classify_root_structure(p)}")
