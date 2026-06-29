#!/usr/bin/env python3
"""
Applications of the Coefficient Extraction Theorem

Demonstrates practical applications of the line restriction / homogeneous
component identity in:
1. Finite-field polynomial testing (Schwartz-Zippel style)
2. Reed-Muller code analysis
3. Kakeya set size estimation
4. Incidence geometry energy bounds
"""

from collections import defaultdict
from itertools import product
from math import comb, factorial
from typing import Dict, List, Set, Tuple


# ═══════════════════════════════════════════════════════════════════════════
# Application 1: Polynomial Identity Testing via Line Restrictions
# ═══════════════════════════════════════════════════════════════════════════

def polynomial_identity_test_via_lines(
    poly_coeffs: Dict[Tuple[int, ...], int],
    n_vars: int,
    q: int,
    num_lines: int = 10
) -> bool:
    """Test whether a polynomial is identically zero over F_q using line restrictions.

    The coefficient extraction theorem tells us that if P is nonzero of degree d,
    then there exists a direction v such that eval(HC_d(P), v) ≠ 0.
    This means the restriction to ANY line with that direction has nonzero t^d coeff,
    hence is a nonzero univariate polynomial.

    A nonzero univariate polynomial of degree ≤ d over F_q has at most d roots,
    so it's nonzero at a random point with probability ≥ 1 - d/q.

    Args:
        poly_coeffs: polynomial as monomial -> coefficient mapping
        n_vars: number of variables
        q: field size (prime)
        num_lines: number of random lines to test

    Returns:
        True if the polynomial appears to be zero (all tests pass),
        False if definitely nonzero (some evaluation was nonzero).
    """
    import random

    for _ in range(num_lines):
        # Pick a random line
        x = [random.randint(0, q - 1) for _ in range(n_vars)]
        v = [random.randint(0, q - 1) for _ in range(n_vars)]

        # Evaluate at a random point on the line
        t = random.randint(0, q - 1)
        point = [(x[i] + t * v[i]) % q for i in range(n_vars)]

        # Evaluate polynomial
        val = 0
        for exp, coeff in poly_coeffs.items():
            term = coeff
            for i in range(n_vars):
                term = (term * pow(point[i], exp[i], q)) % q
            val = (val + term) % q

        if val != 0:
            return False  # Definitely nonzero

    return True  # Probably zero


# ═══════════════════════════════════════════════════════════════════════════
# Application 2: Reed-Muller Code Word Detection
# ═══════════════════════════════════════════════════════════════════════════

def reed_muller_codeword_check(
    evaluation_table: Dict[Tuple[int, ...], int],
    degree: int,
    q: int,
    n_vars: int,
    num_tests: int = 20
) -> float:
    """Check if an evaluation table is close to a Reed-Muller codeword.

    A degree-d Reed-Muller codeword over F_q^n is the evaluation table
    of a polynomial of total degree ≤ d. By our coefficient theorem,
    restricting to any line gives a univariate polynomial of degree ≤ d.

    We test this property on random lines and return the fraction that pass.

    Args:
        evaluation_table: point -> value mapping
        degree: maximum degree
        q: field size
        n_vars: number of variables
        num_tests: number of random lines to test

    Returns:
        Fraction of lines where the restriction has degree ≤ d.
    """
    import random
    passes = 0

    for _ in range(num_tests):
        x = [random.randint(0, q - 1) for _ in range(n_vars)]
        v = [random.randint(0, q - 1) for _ in range(n_vars)]

        # Evaluate on q points of the line
        values = []
        for t in range(q):
            point = tuple((x[i] + t * v[i]) % q for i in range(n_vars))
            values.append(evaluation_table.get(point, 0))

        # Check if the interpolating polynomial has degree ≤ d
        # Using finite differences: the (d+1)-th finite difference should be 0
        diffs = list(values)
        is_low_degree = True
        for order in range(degree + 1):
            diffs = [(diffs[i + 1] - diffs[i]) % q for i in range(len(diffs) - 1)]
        if any(d != 0 for d in diffs):
            is_low_degree = False

        if is_low_degree:
            passes += 1

    return passes / num_tests


# ═══════════════════════════════════════════════════════════════════════════
# Application 3: Kakeya Set Size Analysis
# ═══════════════════════════════════════════════════════════════════════════

def analyze_kakeya_sets(q: int, n: int) -> Dict:
    """Analyze Kakeya sets in F_q^n.

    For small field sizes, enumerate various Kakeya set constructions
    and compare with Dvir's lower bound.

    Args:
        q: field size (prime, should be small ≤ 7)
        n: dimension (should be small ≤ 3)

    Returns:
        Dictionary with analysis results.
    """
    results = {}
    results['field_size'] = q
    results['dimension'] = n
    results['dvir_bound'] = q ** n / factorial(n)
    results['total_points'] = q ** n

    # All nonzero directions
    all_dirs = [d for d in product(range(q), repeat=n)
                if any(x != 0 for x in d)]
    results['num_directions'] = len(all_dirs)

    # Projective directions (up to scalar multiple)
    proj_dirs = set()
    for v in all_dirs:
        # Normalize: find first nonzero coordinate, make it 1
        normalized = list(v)
        for i in range(n):
            if normalized[i] != 0:
                inv = pow(normalized[i], q - 2, q)  # Modular inverse
                normalized = tuple((c * inv) % q for c in normalized)
                break
        proj_dirs.add(normalized)
    results['num_projective_directions'] = len(proj_dirs)

    # Construct minimal Kakeya set greedily
    kakeya = set()
    for v in proj_dirs:
        best_x = None
        best_new = -1

        # Find the line that adds fewest new points
        for x in product(range(q), repeat=n):
            line_pts = set()
            for t in range(q):
                pt = tuple((x[i] + t * v[i]) % q for i in range(n))
                line_pts.add(pt)
            new_pts = len(line_pts - kakeya)
            if best_x is None or new_pts < best_new:
                best_x = x
                best_new = new_pts

        # Add this line
        for t in range(q):
            pt = tuple((best_x[i] + t * v[i]) % q for i in range(n))
            kakeya.add(pt)

    results['greedy_kakeya_size'] = len(kakeya)

    return results


# ═══════════════════════════════════════════════════════════════════════════
# Application 4: Incidence Energy Computation
# ═══════════════════════════════════════════════════════════════════════════

def compute_incidence_energy(q: int, n: int) -> Dict:
    """Compute incidence energy for line families over F_q^n.

    For a family of one line per projective direction, compute:
    - The union size |P|
    - The multiplicity function m(x)
    - The energy E = sum m(x)^2
    - The Cauchy-Schwarz lower bound E ≥ (Nq)^2/|P|

    Args:
        q: field size
        n: dimension

    Returns:
        Dictionary with energy analysis.
    """
    # Projective directions
    all_dirs = [d for d in product(range(q), repeat=n) if any(x != 0 for x in d)]
    proj_dirs = set()
    for v in all_dirs:
        normalized = list(v)
        for i in range(n):
            if normalized[i] != 0:
                inv = pow(normalized[i], q - 2, q)
                normalized = tuple((c * inv) % q for c in normalized)
                break
        proj_dirs.add(normalized)

    N = len(proj_dirs)

    # Assign lines: for direction v, use line through origin
    multiplicity = defaultdict(int)
    for v in proj_dirs:
        for t in range(q):
            pt = tuple((t * v[i]) % q for i in range(n))
            multiplicity[pt] += 1

    union_size = len(multiplicity)
    total_incidences = sum(multiplicity.values())
    energy = sum(m ** 2 for m in multiplicity.values())
    cauchy_schwarz_bound = total_incidences ** 2 / union_size

    return {
        'num_projective_directions': N,
        'union_size': union_size,
        'total_incidences': total_incidences,
        'energy': energy,
        'cauchy_schwarz_bound': cauchy_schwarz_bound,
        'energy_ratio': energy / cauchy_schwarz_bound if cauchy_schwarz_bound > 0 else float('inf'),
        'max_multiplicity': max(multiplicity.values()),
        'multiplicity_distribution': dict(
            sorted(defaultdict(int, {m: sum(1 for v in multiplicity.values() if v == m)
                                     for m in set(multiplicity.values())}).items())
        )
    }


# ═══════════════════════════════════════════════════════════════════════════
# Main: Run all applications
# ═══════════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("═" * 70)
    print("APPLICATION 1: Polynomial Identity Testing")
    print("═" * 70)

    q = 11
    # Test with the zero polynomial
    zero_poly = {}
    result = polynomial_identity_test_via_lines(zero_poly, 3, q)
    print(f"  Zero polynomial test (q={q}): {'ZERO' if result else 'NONZERO'}")

    # Test with a nonzero polynomial
    nonzero = {(2, 0, 0): 1, (0, 1, 1): 3, (0, 0, 0): 1}
    result = polynomial_identity_test_via_lines(nonzero, 3, q)
    print(f"  Nonzero polynomial test: {'ZERO' if result else 'NONZERO'}")
    print()

    print("═" * 70)
    print("APPLICATION 2: Reed-Muller Codeword Detection")
    print("═" * 70)

    q = 5
    n = 2
    degree = 2

    # Create a genuine RM codeword: evaluation of X² + Y
    codeword = {}
    for pt in product(range(q), repeat=n):
        codeword[pt] = (pt[0] ** 2 + pt[1]) % q

    score = reed_muller_codeword_check(codeword, degree, q, n, num_tests=50)
    print(f"  Genuine RM codeword (deg ≤ {degree}): pass rate = {score:.0%}")

    # Create a corrupted codeword
    corrupted = dict(codeword)
    corrupted[(0, 0)] = (corrupted[(0, 0)] + 1) % q
    corrupted[(1, 1)] = (corrupted[(1, 1)] + 2) % q

    score = reed_muller_codeword_check(corrupted, degree, q, n, num_tests=50)
    print(f"  Corrupted codeword: pass rate = {score:.0%}")
    print()

    print("═" * 70)
    print("APPLICATION 3: Kakeya Set Analysis")
    print("═" * 70)

    for q in [3, 5, 7]:
        for n_dim in [2, 3]:
            if q ** n_dim > 1000:
                continue
            results = analyze_kakeya_sets(q, n_dim)
            print(f"  F_{q}^{n_dim}: |K_greedy| = {results['greedy_kakeya_size']}, "
                  f"Dvir bound = {results['dvir_bound']:.1f}, "
                  f"|F_q^n| = {results['total_points']}")
    print()

    print("═" * 70)
    print("APPLICATION 4: Incidence Energy Analysis")
    print("═" * 70)

    for q in [3, 5, 7]:
        n_dim = 2
        energy_data = compute_incidence_energy(q, n_dim)
        print(f"  F_{q}^{n_dim}: E = {energy_data['energy']}, "
              f"CS bound = {energy_data['cauchy_schwarz_bound']:.1f}, "
              f"ratio = {energy_data['energy_ratio']:.3f}, "
              f"max mult = {energy_data['max_multiplicity']}")
        print(f"    Multiplicity distribution: {energy_data['multiplicity_distribution']}")


#!/usr/bin/env python3
"""
Demo: Coefficient Extraction for Line Restrictions of Multivariate Polynomials

Demonstrates the main theorem: the d-th coefficient of a multivariate polynomial
restricted to an affine line x + t*v equals the evaluation of the degree-d
homogeneous component at the direction vector v.

This is the algebraic engine behind Dvir's finite-field Kakeya lower bound.
"""

from itertools import product
from collections import defaultdict


def multivariate_eval(coeffs, point, variables):
    """Evaluate a multivariate polynomial at a point.

    Args:
        coeffs: dict mapping exponent tuples to coefficients
        point: tuple/list of values for each variable
        variables: number of variables

    Returns:
        The evaluated value
    """
    result = 0
    for exponent, coeff in coeffs.items():
        term = coeff
        for i in range(variables):
            term *= point[i] ** exponent[i]
        result += term
    return result


def restrict_to_line(coeffs, x, v, variables):
    """Restrict a multivariate polynomial to the line x + t*v.

    Returns coefficients of the univariate polynomial in t.
    """
    # Find maximum possible degree
    max_deg = max(sum(exp) for exp in coeffs.keys()) if coeffs else 0

    # For each monomial a * X^m, the restriction is a * prod_i (x_i + t*v_i)^{m_i}
    # We compute coefficients of this univariate polynomial by convolution
    result = defaultdict(lambda: 0)

    for exponent, coeff in coeffs.items():
        # Compute product of (x_i + t * v_i)^{m_i} for each variable
        poly = [1.0]  # Start with constant 1
        for i in range(variables):
            # (x_i + t * v_i)^{m_i} via binomial theorem
            factor = []
            xi, vi, mi = x[i], v[i], exponent[i]
            for k in range(mi + 1):
                from math import comb
                binom = comb(mi, k)
                factor.append(binom * (xi ** (mi - k)) * (vi ** k))
            # Multiply poly by factor (polynomial multiplication)
            new_poly = [0.0] * (len(poly) + len(factor) - 1)
            for j1, c1 in enumerate(poly):
                for j2, c2 in enumerate(factor):
                    new_poly[j1 + j2] += c1 * c2
            poly = new_poly

        for deg, c in enumerate(poly):
            result[deg] += coeff * c

    return dict(result)


def homogeneous_component(coeffs, d):
    """Extract the degree-d homogeneous component."""
    return {exp: c for exp, c in coeffs.items() if sum(exp) == d}


def eval_homogeneous_at(coeffs, d, v, variables):
    """Evaluate the degree-d homogeneous component at v."""
    hc = homogeneous_component(coeffs, d)
    return multivariate_eval(hc, v, variables)


def demo_main_theorem():
    """Demonstrate the main coefficient extraction theorem."""
    print("=" * 70)
    print("DEMO: Coefficient Extraction for Line Restrictions")
    print("=" * 70)
    print()

    # Example 1: A polynomial in 2 variables with total degree 3
    print("Example 1: P(X,Y) = 2X³ + 3X²Y + XY + 5Y² + X + 7")
    print("-" * 50)
    n_vars = 2
    coeffs = {
        (3, 0): 2,   # 2X³
        (2, 1): 3,   # 3X²Y
        (1, 1): 1,   # XY
        (0, 2): 5,   # 5Y²
        (1, 0): 1,   # X
        (0, 0): 7,   # 7
    }
    total_degree = 3

    x = [1.0, 2.0]
    v = [3.0, -1.0]
    print(f"  Base point x = {x}")
    print(f"  Direction  v = {v}")
    print()

    restricted = restrict_to_line(coeffs, x, v, n_vars)
    print(f"  Restriction P(x + tv) as polynomial in t:")
    for deg in sorted(restricted.keys()):
        if abs(restricted[deg]) > 1e-10:
            print(f"    coefficient of t^{deg}: {restricted[deg]:.4f}")
    print()

    d = total_degree
    coeff_d = restricted.get(d, 0)
    eval_hc = eval_homogeneous_at(coeffs, d, v, n_vars)

    print(f"  Main theorem verification (d = {d} = totalDegree):")
    print(f"    coeff(P(x+tv), t^{d}) = {coeff_d:.4f}")
    print(f"    eval(homogeneousComponent({d}, P), v) = {eval_hc:.4f}")
    print(f"    ✓ Equal: {abs(coeff_d - eval_hc) < 1e-10}")
    print()

    # Also check for d = 2 (below total degree — theorem also holds)
    for d_check in range(total_degree + 1):
        coeff_d = restricted.get(d_check, 0)
        eval_hc = eval_homogeneous_at(coeffs, d_check, v, n_vars)
        status = "✓" if abs(coeff_d - eval_hc) < 1e-10 else "✗"
        print(f"    d={d_check}: coeff={coeff_d:.4f}, eval(HC_{d_check},v)={eval_hc:.4f} {status}")

    print()
    print("  Note: The identity holds when totalDegree(P) ≤ d.")
    print("  When d < totalDegree, cross-terms from higher-degree monomials contribute.")
    print("  For d > totalDegree, both sides are trivially 0.")
    print()

    # Example 2: Demonstration over a finite field (Z/5Z)
    print("Example 2: Over F_5 (the finite field with 5 elements)")
    print("-" * 50)
    q = 5
    n_vars = 2

    # P(X,Y) = X² + 2XY + 3Y² (degree 2 polynomial)
    coeffs = {
        (2, 0): 1,
        (1, 1): 2,
        (0, 2): 3,
    }
    total_degree = 2

    print(f"  P(X,Y) = X² + 2XY + 3Y²  over F_{q}")
    print()

    # Pick a direction and show vanishing corollary
    v = [1, 2]
    print(f"  Direction v = {v}")

    # For each base point x, restrict and evaluate
    print(f"  Testing Dvir corollary: if P vanishes on the full line,")
    print(f"  then eval(HC_d, v) = 0.")
    print()

    for x in product(range(q), repeat=n_vars):
        x = list(x)
        # Check if P vanishes on the entire line x + tv
        all_zero = True
        for t in range(q):
            point = [(x[i] + t * v[i]) % q for i in range(n_vars)]
            val = multivariate_eval(coeffs, point, n_vars) % q
            if val != 0:
                all_zero = False
                break

        if all_zero:
            eval_hc = eval_homogeneous_at(coeffs, total_degree, v, n_vars) % q
            print(f"  x={x}: P vanishes on full line → eval(HC_{total_degree}, v) = {eval_hc} (mod {q})")

    print()

    # Example 3: The Kakeya connection
    print("Example 3: Kakeya Set Demo over F_7")
    print("-" * 50)
    q = 7
    n_vars = 2

    print(f"  A Kakeya set in F_{q}^{n_vars} contains a line in every direction.")
    from math import factorial
    print(f"  Dvir's bound: |K| ≥ q^n / n! = {q**n_vars} / {factorial(n_vars)} = {q**n_vars / factorial(n_vars):.1f}")
    print()

    # Construct a Kakeya set: for each nonzero direction, pick a line
    kakeya_set = set()
    directions = [(a, b) for a in range(q) for b in range(q) if (a, b) != (0, 0)]

    # Use a simple construction: for direction v, use base point 0
    for v in directions:
        for t in range(q):
            point = tuple((t * v[i]) % q for i in range(n_vars))
            kakeya_set.add(point)

    print(f"  Simple Kakeya set (lines through origin): |K| = {len(kakeya_set)}")
    print(f"  This equals q² - 1 + 1 = {q**2} (all points since lines through 0 cover F_q^2)")
    print()

    # A more efficient Kakeya set
    kakeya_set2 = set()
    for v_idx, v in enumerate(directions):
        # Choose different base points for different directions
        x = ((v_idx * 3) % q, (v_idx * 2 + 1) % q)
        for t in range(q):
            point = tuple((x[i] + t * v[i]) % q for i in range(n_vars))
            kakeya_set2.add(point)

    print(f"  Randomized Kakeya set: |K| = {len(kakeya_set2)}")
    print(f"  Dvir lower bound:       |K| ≥ {q**n_vars / factorial(n_vars):.1f}")
    print()


def demo_counterexample_without_degree_bound():
    """Show the theorem fails without the degree bound."""
    print("=" * 70)
    print("DEMO: Why the Degree Bound is Necessary")
    print("=" * 70)
    print()

    # P(X) = X², a single-variable polynomial of degree 2
    # Restrict to line x=1, v=1: P(1+t) = 1 + 2t + t²
    # coeff(P(1+t), t^1) = 2
    # homogeneousComponent(1, X²) = 0 (no degree-1 part)
    # eval(0, v) = 0 ≠ 2

    n_vars = 1
    coeffs = {(2,): 1}  # P(X) = X²
    x = [1.0]
    v = [1.0]

    restricted = restrict_to_line(coeffs, x, v, n_vars)
    print("  P(X) = X²,  x = [1],  v = [1]")
    print(f"  P(1+t) = {restricted.get(0,0):.0f} + {restricted.get(1,0):.0f}t + {restricted.get(2,0):.0f}t²")
    print()

    for d in range(3):
        coeff_d = restricted.get(d, 0)
        eval_hc = eval_homogeneous_at(coeffs, d, v, n_vars)
        match = abs(coeff_d - eval_hc) < 1e-10
        bound_holds = d >= 2  # totalDegree = 2
        print(f"  d={d}: coeff={coeff_d:.0f}, eval(HC_{d},v)={eval_hc:.0f}, "
              f"equal={match}, totalDeg≤d={bound_holds}")

    print()
    print("  → The identity fails for d=1 < totalDegree=2!")
    print("  → The degree bound totalDegree ≤ d is essential.")
    print()


if __name__ == "__main__":
    demo_main_theorem()
    demo_counterexample_without_degree_bound()
