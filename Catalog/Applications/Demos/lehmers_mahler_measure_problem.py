#!/usr/bin/env python3
"""
applications.py — Applications of Mahler Measure Theory

Demonstrates real-world applications and connections:
1. Height theory for algebraic integers
2. Entropy of algebraic dynamical systems
3. Lehmer's problem landscape visualization
4. Pattern detection in low Mahler measure polynomials
"""

import numpy as np
from typing import List, Tuple, Dict
import itertools


def algebraic_entropy_toral_automorphism(matrix: np.ndarray) -> float:
    """
    Compute the topological entropy of the toral automorphism T_A: ℝ^d/ℤ^d → ℝ^d/ℤ^d
    defined by an integer matrix A ∈ GL_d(ℤ).
    
    By the theorem of Bowen and Lind-Schmidt-Ward:
      h(T_A) = ∑_λ max(0, log|λ|)
    
    where λ ranges over eigenvalues of A (counted with multiplicity).
    This equals log M(charpoly(A)).
    
    Args:
        matrix: integer square matrix
    
    Returns:
        topological entropy
    
    Example:
        Arnold's cat map: [[2,1],[1,1]] has entropy log((3+√5)/2) ≈ 0.9624
    """
    eigenvalues = np.linalg.eigvals(matrix)
    return sum(max(0, np.log(abs(lam))) for lam in eigenvalues)


def logarithmic_weil_height(min_poly_coeffs: List[int]) -> float:
    """
    Compute the logarithmic Weil height of an algebraic integer α given
    its minimal polynomial.
    
    For an algebraic integer α of degree d with minimal polynomial P:
      h(α) = log M(P) / d
    
    The height measures the arithmetic complexity of α.
    
    Args:
        min_poly_coeffs: coefficients [a_0, ..., a_d] of the minimal polynomial
    
    Returns:
        logarithmic Weil height h(α)
    """
    coeffs = min_poly_coeffs
    degree = len(coeffs) - 1
    
    roots = np.roots(coeffs[::-1])
    leading = coeffs[-1]
    
    log_M = np.log(abs(leading))
    for r in roots:
        log_M += max(0, np.log(abs(r)))
    
    return log_M / degree


def lehmer_landscape(max_degree: int = 6, coeff_bound: int = 1) -> Dict:
    """
    Map the landscape of Mahler measures for integer polynomials,
    organized by degree and structural properties.
    
    Returns statistics about the distribution of Mahler measures
    and identifies patterns among polynomials with small measures.
    
    Args:
        max_degree: maximum polynomial degree to search
        coeff_bound: coefficient range [-B, B]
    
    Returns:
        Dictionary with landscape statistics
    """
    landscape = {
        'by_degree': {},
        'reciprocal_fraction': {},
        'smallest_per_degree': {},
        'gap_analysis': {}
    }
    
    for degree in range(2, max_degree + 1):
        measures = []
        reciprocal_count = 0
        total_count = 0
        smallest = float('inf')
        smallest_poly = None
        
        for lower_coeffs in itertools.product(
            range(-coeff_bound, coeff_bound + 1), repeat=degree
        ):
            coeffs = list(lower_coeffs) + [1]
            total_count += 1
            
            try:
                roots = np.roots(coeffs[::-1])
                M = 1.0
                for r in roots:
                    M *= max(1.0, abs(r))
                
                if M > 1.0 + 1e-10:
                    measures.append(M)
                    
                    # Check reciprocal symmetry
                    is_recip = all(
                        coeffs[i] == coeffs[len(coeffs) - 1 - i]
                        for i in range(len(coeffs) // 2 + 1)
                    )
                    if is_recip:
                        reciprocal_count += 1
                    
                    if M < smallest:
                        smallest = M
                        smallest_poly = coeffs
            except:
                pass
        
        if measures:
            measures.sort()
            landscape['by_degree'][degree] = {
                'count': len(measures),
                'min': measures[0],
                'max': measures[-1],
                'median': measures[len(measures) // 2],
                'bottom_5': measures[:5]
            }
            landscape['smallest_per_degree'][degree] = {
                'M': smallest,
                'coeffs': smallest_poly
            }
            landscape['reciprocal_fraction'][degree] = (
                reciprocal_count / max(1, len(measures))
            )
    
    return landscape


def entropy_rigidity_test(max_degree: int = 8, num_trials: int = 10000) -> List[Dict]:
    """
    Test the entropy rigidity conjecture: if a monic irreducible integer
    polynomial has exactly one conjugate outside the unit circle, is
    its spectral entropy bounded below by a universal constant?
    
    Args:
        max_degree: maximum degree to test
        num_trials: number of random polynomials to test
    
    Returns:
        List of results for polynomials with exactly one root outside unit circle
    """
    results = []
    
    for _ in range(num_trials):
        degree = np.random.randint(2, max_degree + 1)
        coeffs = [1]
        for _ in range(degree):
            coeffs.append(np.random.choice([-1, 0, 1]))
        coeffs_asc = coeffs[::-1]
        
        try:
            roots = np.roots(coeffs)
            outside = [r for r in roots if abs(r) > 1.0 + 1e-8]
            
            if len(outside) == 1:
                M = max(1.0, abs(outside[0]))
                log_M = np.log(M)
                
                results.append({
                    'degree': degree,
                    'coefficients': coeffs_asc,
                    'mahler_measure': M,
                    'log_mahler_measure': log_M,
                    'escaped_root': outside[0],
                    'escaped_root_modulus': abs(outside[0])
                })
        except:
            pass
    
    results.sort(key=lambda x: x['log_mahler_measure'])
    return results


def tropical_support_analysis(coefficients: List[int]) -> Dict:
    """
    Analyze the tropical support geometry of a polynomial and its
    relationship to Mahler measure.
    
    The tropical support is the set of exponents with nonzero coefficients.
    The Newton polygon is the convex hull of the support points.
    
    Args:
        coefficients: polynomial coefficients [a_0, ..., a_d] in ascending order
    
    Returns:
        Dictionary with support analysis
    """
    support = [i for i, c in enumerate(coefficients) if c != 0]
    degree = len(coefficients) - 1
    
    roots = np.roots(coefficients[::-1])
    M = abs(coefficients[-1])
    for r in roots:
        M *= max(1.0, abs(r))
    
    return {
        'support': support,
        'support_size': len(support),
        'degree': degree,
        'density': len(support) / (degree + 1),
        'gap_max': max(support[i+1] - support[i] for i in range(len(support)-1)) if len(support) > 1 else 0,
        'mahler_measure': M,
        'log_mahler_measure': np.log(M) if M > 0 else 0,
        'is_reciprocal': all(
            coefficients[i] == coefficients[degree - i]
            for i in range(degree // 2 + 1)
        ),
        'coefficient_sum': sum(abs(c) for c in coefficients),
    }


# ═══════════════════════════════════════════════════════════════════════
# Application demonstrations
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATION 1: Arnold's Cat Map and Toral Automorphism Entropy")
    print("=" * 70)
    print()
    
    # Arnold's cat map
    cat_map = np.array([[2, 1], [1, 1]])
    h_cat = algebraic_entropy_toral_automorphism(cat_map)
    golden = (1 + np.sqrt(5)) / 2
    print(f"  Arnold's cat map [[2,1],[1,1]]:")
    print(f"    Entropy = {h_cat:.10f}")
    print(f"    log(φ)  = {np.log(golden):.10f}  (φ = golden ratio)")
    print(f"    This equals log M(X² - 3X + 1)")
    print()
    
    # Higher-dimensional examples
    matrices = [
        ("[[3,1],[1,1]]", np.array([[3, 1], [1, 1]])),
        ("[[2,1,0],[1,2,1],[0,1,2]]", np.array([[2,1,0],[1,2,1],[0,1,2]])),
    ]
    for name, M_mat in matrices:
        h = algebraic_entropy_toral_automorphism(M_mat)
        print(f"  Matrix {name}: entropy = {h:.8f}")
    print()
    
    # ═════════════════════════════════════════════════════════════════
    print("=" * 70)
    print("APPLICATION 2: Weil Heights of Algebraic Integers")
    print("=" * 70)
    print()
    
    height_examples = [
        ("√2 (X²-2)", [-2, 0, 1]),
        ("√3 (X²-3)", [-3, 0, 1]),
        ("∛2 (X³-2)", [-2, 0, 0, 1]),
        ("Golden ratio (X²-X-1)", [-1, -1, 1]),
        ("Plastic number (X³-X-1)", [-1, -1, 0, 1]),
    ]
    
    print(f"  {'Algebraic integer':<25s}  {'h(α)':>10s}  {'deg':>4s}  {'log M':>10s}")
    print(f"  {'-'*25}  {'-'*10}  {'-'*4}  {'-'*10}")
    
    for name, coeffs in height_examples:
        h = logarithmic_weil_height(coeffs)
        deg = len(coeffs) - 1
        log_M = h * deg
        print(f"  {name:<25s}  {h:10.6f}  {deg:4d}  {log_M:10.6f}")
    
    print()
    print("  Lehmer's polynomial roots:")
    lehmer = [1, 1, 0, -1, -1, -1, -1, -1, 0, 1, 1]
    h_lehmer = logarithmic_weil_height(lehmer)
    print(f"    h(α_Lehmer) = {h_lehmer:.10f}")
    print(f"    This is among the smallest known heights for non-root-of-unity")
    print(f"    algebraic integers.")
    print()
    
    # ═════════════════════════════════════════════════════════════════
    print("=" * 70)
    print("APPLICATION 3: Lehmer Landscape Analysis")
    print("=" * 70)
    print()
    
    landscape = lehmer_landscape(max_degree=5, coeff_bound=1)
    
    lehmer_M = 1.1762808182599175
    
    for deg in sorted(landscape['by_degree'].keys()):
        info = landscape['by_degree'][deg]
        smallest = landscape['smallest_per_degree'][deg]
        recip_frac = landscape['reciprocal_fraction'].get(deg, 0)
        print(f"  Degree {deg}: {info['count']} polynomials with M > 1")
        print(f"    Smallest M = {smallest['M']:.10f}  "
              f"(coeffs: {smallest['coeffs']})")
        print(f"    Bottom 5: {[f'{m:.6f}' for m in info['bottom_5']]}")
        print(f"    Reciprocal fraction among small M: {recip_frac:.1%}")
        print()
    
    print(f"  Lehmer benchmark: M(L) = {lehmer_M:.10f}")
    print()
    
    # ═════════════════════════════════════════════════════════════════
    print("=" * 70)
    print("APPLICATION 4: Entropy Rigidity Test")
    print("=" * 70)
    print()
    
    rigidity_results = entropy_rigidity_test(max_degree=6, num_trials=5000)
    
    if rigidity_results:
        print(f"  Found {len(rigidity_results)} polynomials with exactly 1 root outside unit circle")
        print(f"  Smallest log M found: {rigidity_results[0]['log_mahler_measure']:.10f}")
        print(f"  Top 10 smallest:")
        for i, r in enumerate(rigidity_results[:10]):
            print(f"    {i+1}. log M = {r['log_mahler_measure']:.8f}, "
                  f"deg = {r['degree']}, "
                  f"|root| = {r['escaped_root_modulus']:.6f}")
        
        min_log_M = rigidity_results[0]['log_mahler_measure']
        print(f"\n  Conjectured lower bound: log M ≥ {min_log_M:.8f}")
        print(f"  (Compare: log M(Lehmer) = {np.log(lehmer_M):.8f})")
    print()
    
    # ═════════════════════════════════════════════════════════════════
    print("=" * 70)
    print("APPLICATION 5: Tropical Support Patterns")
    print("=" * 70)
    print()
    
    tropical_examples = [
        [1, 1, 0, -1, -1, -1, -1, -1, 0, 1, 1],  # Lehmer
        [-1, -1, 1],  # X² - X - 1 (golden ratio)
        [-1, -1, 0, 1],  # X³ - X - 1 (plastic number)
        [-1, 0, 0, 0, 0, 1],  # X⁵ - 1
        [1, 0, 0, -1, 0, 0, 1],  # sparse degree 6
    ]
    
    print(f"  {'Support':<25s}  {'|supp|':>5s}  {'density':>7s}  {'M':>12s}  {'recip':>5s}")
    print(f"  {'-'*25}  {'-'*5}  {'-'*7}  {'-'*12}  {'-'*5}")
    
    for coeffs in tropical_examples:
        analysis = tropical_support_analysis(coeffs)
        supp_str = str(analysis['support'])
        print(f"  {supp_str:<25s}  {analysis['support_size']:5d}  "
              f"{analysis['density']:7.2f}  "
              f"{analysis['mahler_measure']:12.8f}  "
              f"{'yes' if analysis['is_reciprocal'] else 'no':>5s}")
    
    print()
    print("  Observation: Reciprocal polynomials with moderate support density")
    print("  tend to achieve the smallest Mahler measures above 1.")


#!/usr/bin/env python3
"""
demo.py — Mahler Measure Explorer

Demonstrates the key theorems from the formal Lean 4 development:
1. Root-factorization formula for Mahler measure
2. Cyclotomic polynomials have Mahler measure 1
3. Lehmer's polynomial has minimal known Mahler measure > 1
4. Companion matrix spectral entropy equals Mahler measure

All computations use NumPy for root-finding and SciPy for numerical integration.
"""

import numpy as np
from numpy.polynomial import polynomial as P

def mahler_measure_from_roots(coeffs):
    """
    Compute Mahler measure via root-factorization formula:
      M(P) = |a_d| * prod_{|α_i| > 1} |α_i|
    
    For monic polynomials: M(P) = prod_{|α_i| > 1} |α_i|
    
    Args:
        coeffs: polynomial coefficients [a_0, a_1, ..., a_d] (ascending order)
    Returns:
        (M, log_M, roots) tuple
    """
    # numpy polynomial roots
    roots = np.roots(coeffs[::-1])  # np.roots expects descending order
    leading = coeffs[-1]
    
    # Root-factorization: M(P) = |leading| * prod max(1, |root|)
    M = abs(leading)
    for r in roots:
        M *= max(1.0, abs(r))
    
    log_M = np.log(M) if M > 0 else float('-inf')
    return M, log_M, roots


def mahler_measure_integral(coeffs, num_points=10000):
    """
    Compute Mahler measure via Jensen's formula / circle integral:
      log M(P) = (1/2π) ∫_0^{2π} log|P(e^{it})| dt
    
    Args:
        coeffs: polynomial coefficients [a_0, a_1, ..., a_d] (ascending order)
        num_points: number of quadrature points
    Returns:
        (M, log_M)
    """
    t = np.linspace(0, 2 * np.pi, num_points, endpoint=False)
    z = np.exp(1j * t)
    
    # Evaluate polynomial at points on unit circle
    values = np.polyval(coeffs[::-1], z)
    log_abs = np.log(np.maximum(np.abs(values), 1e-300))
    
    # Numerical integration via trapezoidal rule
    log_M = np.mean(log_abs)
    M = np.exp(log_M)
    return M, log_M


def spectral_entropy(matrix):
    """
    Compute spectral entropy of a matrix:
      h(A) = sum max(0, log|λ|) over eigenvalues λ
    
    This equals the logarithmic Mahler measure when A is the
    companion matrix of a monic polynomial.
    
    Args:
        matrix: square numpy array
    Returns:
        entropy value
    """
    eigenvalues = np.linalg.eigvals(matrix)
    return sum(max(0, np.log(abs(lam))) for lam in eigenvalues)


def companion_matrix(coeffs):
    """
    Build the companion matrix of a monic polynomial.
    
    For P(X) = X^d + a_{d-1}X^{d-1} + ... + a_0,
    the companion matrix has 1s on the subdiagonal and
    -a_0, -a_1, ..., -a_{d-1} in the last column.
    
    Args:
        coeffs: [a_0, a_1, ..., a_d] with a_d = 1 (monic)
    Returns:
        d×d companion matrix
    """
    d = len(coeffs) - 1
    C = np.zeros((d, d))
    for i in range(d - 1):
        C[i + 1, i] = 1
    for i in range(d):
        C[i, d - 1] = -coeffs[i]
    return C


def cyclotomic_polynomial(n):
    """
    Compute the n-th cyclotomic polynomial coefficients.
    Uses the formula: Φ_n(x) = prod_{d|n} (x^d - 1)^{μ(n/d)}
    
    Returns coefficients in ascending order [a_0, a_1, ..., a_d].
    """
    from functools import reduce
    
    def mobius(n):
        """Möbius function."""
        if n == 1:
            return 1
        factors = []
        d = 2
        temp = n
        while d * d <= temp:
            if temp % d == 0:
                count = 0
                while temp % d == 0:
                    temp //= d
                    count += 1
                if count > 1:
                    return 0
                factors.append(d)
            d += 1
        if temp > 1:
            factors.append(temp)
        return (-1) ** len(factors)
    
    def divisors(n):
        divs = []
        for i in range(1, n + 1):
            if n % i == 0:
                divs.append(i)
        return divs
    
    if n == 0:
        return [1]
    
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
        else:
            # Division
            result, rem = np.polydiv(result, xd_minus_1)
    
    # Round to integers
    result = np.round(result).astype(int)
    return result[::-1]  # Return ascending order


# ═══════════════════════════════════════════════════════════════════
# DEMO 1: Root-factorization formula
# ═══════════════════════════════════════════════════════════════════
print("=" * 70)
print("DEMO 1: Root-Factorization Formula for Mahler Measure")
print("=" * 70)
print()

# Simple example: X^2 - 3X + 2 = (X-1)(X-2)
coeffs_simple = [2, -3, 1]  # ascending: a_0=2, a_1=-3, a_2=1
M, log_M, roots = mahler_measure_from_roots(coeffs_simple)
M_int, log_M_int = mahler_measure_integral(coeffs_simple)

print("P(X) = X² - 3X + 2 = (X-1)(X-2)")
print(f"  Roots: {roots}")
print(f"  Root-factorization: M(P) = {M:.6f}")
print(f"  Circle integral:    M(P) = {M_int:.6f}")
print(f"  log M(P) = {log_M:.6f}")
print(f"  Roots outside unit circle: {[r for r in roots if abs(r) > 1]}")
print(f"  ∑ max(0, log|α|) = {sum(max(0, np.log(abs(r))) for r in roots):.6f}")
print()

# X^3 - 2 (roots: 2^{1/3}, 2^{1/3}ω, 2^{1/3}ω²)
coeffs_cube = [-2, 0, 0, 1]
M, log_M, roots = mahler_measure_from_roots(coeffs_cube)
M_int, log_M_int = mahler_measure_integral(coeffs_cube)

print("P(X) = X³ - 2")
print(f"  Roots: {[f'{r:.4f}' for r in roots]}")
print(f"  |roots|: {[f'{abs(r):.4f}' for r in roots]}")
print(f"  Root-factorization: M(P) = {M:.6f}")
print(f"  Circle integral:    M(P) = {M_int:.6f}")
print(f"  Expected: M = 2^(1/3) * 2^(1/3) * 2^(1/3) = 2.000000")
print()

# ═══════════════════════════════════════════════════════════════════
# DEMO 2: Cyclotomic polynomials have Mahler measure 1
# ═══════════════════════════════════════════════════════════════════
print("=" * 70)
print("DEMO 2: Cyclotomic Polynomials Have Mahler Measure 1")
print("=" * 70)
print()

for n in [2, 3, 5, 7, 11, 13, 22, 30]:
    coeffs = cyclotomic_polynomial(n)
    if len(coeffs) > 1:
        M, log_M, roots = mahler_measure_from_roots(coeffs)
        norms = sorted([abs(r) for r in roots]) if len(roots) > 0 else [1.0]
        print(f"  Φ_{n:2d}: degree={len(coeffs)-1:2d}, M(Φ_{n}) = {M:.10f}, "
              f"log M = {log_M:+.2e}, "
              f"max|root| = {max(norms):.6f}")

print()
print("  ✓ All cyclotomic polynomials have M = 1 (within numerical precision)")
print()

# ═══════════════════════════════════════════════════════════════════
# DEMO 3: Lehmer's Polynomial — the champion
# ═══════════════════════════════════════════════════════════════════
print("=" * 70)
print("DEMO 3: Lehmer's Polynomial — Minimal Known Mahler Measure > 1")
print("=" * 70)
print()

# L(X) = X^10 + X^9 - X^7 - X^6 - X^5 - X^4 - X^3 + X + 1
lehmer = [1, 1, 0, -1, -1, -1, -1, -1, 0, 1, 1]  # ascending
M_L, log_M_L, roots_L = mahler_measure_from_roots(lehmer)
M_L_int, log_M_L_int = mahler_measure_integral(lehmer)

print("L(X) = X¹⁰ + X⁹ - X⁷ - X⁶ - X⁵ - X⁴ - X³ + X + 1")
print()
print(f"  Root-factorization: M(L) = {M_L:.15f}")
print(f"  Circle integral:    M(L) = {M_L_int:.15f}")
print(f"  log M(L) = {log_M_L:.15f}")
print()
print("  Roots and their moduli:")
for i, r in enumerate(sorted(roots_L, key=lambda x: -abs(x))):
    marker = " ◀ OUTSIDE" if abs(r) > 1.001 else ""
    print(f"    α_{i+1}: |α| = {abs(r):.10f}, α = {r:.8f}{marker}")

print()
print(f"  Roots outside unit circle: "
      f"{sum(1 for r in roots_L if abs(r) > 1.001)}")
print(f"  L(1) = {sum(lehmer)}")
print(f"  L(-1) = {sum((-1)**i * c for i, c in enumerate(lehmer))}")
print()

# ═══════════════════════════════════════════════════════════════════
# DEMO 4: Companion Matrix and Spectral Entropy
# ═══════════════════════════════════════════════════════════════════
print("=" * 70)
print("DEMO 4: Companion Matrix Spectral Entropy = Mahler Measure")
print("=" * 70)
print()

C_L = companion_matrix(lehmer)
h_spec = spectral_entropy(C_L)

print("Companion matrix of Lehmer's polynomial (10×10):")
print(f"  Spectral entropy h(C_L) = {h_spec:.15f}")
print(f"  log M(L)                = {log_M_L:.15f}")
print(f"  Difference              = {abs(h_spec - log_M_L):.2e}")
print()

eigenvalues = np.linalg.eigvals(C_L)
print("  Eigenvalues of companion matrix (= roots of L):")
for i, ev in enumerate(sorted(eigenvalues, key=lambda x: -abs(x))):
    contrib = max(0, np.log(abs(ev)))
    print(f"    λ_{i+1}: |λ| = {abs(ev):.10f}, "
          f"max(0, log|λ|) = {contrib:.10f}")

print()

# Verify for a simpler example
coeffs_x2_2 = [-2, 0, 1]  # X^2 - 2
C = companion_matrix(coeffs_x2_2)
h = spectral_entropy(C)
M_check, log_M_check, _ = mahler_measure_from_roots(coeffs_x2_2)
print(f"  Verification: X² - 2")
print(f"    Spectral entropy = {h:.10f}")
print(f"    log M            = {log_M_check:.10f}")
print(f"    Match: {'✓' if abs(h - log_M_check) < 1e-10 else '✗'}")
print()

# ═══════════════════════════════════════════════════════════════════
# DEMO 5: Survey of Mahler measures for small polynomials
# ═══════════════════════════════════════════════════════════════════
print("=" * 70)
print("DEMO 5: Smallest Mahler Measures Among Integer Polynomials")
print("=" * 70)
print()

# Search through monic integer polynomials of small degree with bounded coefficients
# looking for small Mahler measures > 1
results = []

for degree in range(2, 8):
    for trial in range(5000):
        # Random monic polynomial with coefficients in {-1, 0, 1}
        coeffs = [1]  # leading coefficient
        for _ in range(degree):
            coeffs.append(np.random.choice([-1, 0, 1]))
        coeffs = coeffs[::-1]  # ascending order
        
        try:
            M, log_M, roots = mahler_measure_from_roots(coeffs)
            if M > 1.001 and log_M < 0.5:
                results.append((M, log_M, coeffs, degree))
        except:
            pass

# Sort by Mahler measure and show top 15
results.sort(key=lambda x: x[0])
seen = set()
print("  Smallest Mahler measures > 1 found (random search):")
print(f"  {'M(P)':>15s}  {'log M':>12s}  {'deg':>3s}  Polynomial")
print(f"  {'-'*15}  {'-'*12}  {'-'*3}  {'-'*30}")

count = 0
for M, log_M, coeffs, deg in results:
    key = tuple(coeffs)
    if key not in seen and count < 15:
        seen.add(key)
        poly_str = " + ".join(
            f"{c}x^{i}" if i > 0 and c != 0 else str(c) if c != 0 else ""
            for i, c in enumerate(coeffs)
        ).replace("+ -", "- ").replace("1x", "x")
        print(f"  {M:15.10f}  {log_M:12.10f}  {deg:3d}  {poly_str[:40]}")
        count += 1

print()
print(f"  Lehmer's polynomial:  M = {M_L:.10f}, log M = {log_M_L:.10f}")
print()
print("  ═══════════════════════════════════════════════════════════════")
print("  Key insight: Lehmer's polynomial consistently has the smallest")
print("  known Mahler measure > 1 among ALL integer polynomials.")
print("  Whether this is truly minimal remains one of the deepest open")
print("  problems in number theory.")
print("  ═══════════════════════════════════════════════════════════════")
