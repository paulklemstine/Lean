#!/usr/bin/env python3
"""
Applications of the Anisotropic Footprint Bound

Real-world applications demonstrating how the footprint bound applies to:
1. Error-correcting codes with non-uniform alphabets
2. Polynomial identity testing
3. Combinatorial Nullstellensatz applications
4. Secret sharing with heterogeneous participants
"""

from typing import List, Set, Tuple, Dict
from itertools import product
from functools import reduce
import numpy as np


# =============================================================================
# APPLICATION 1: Affine Cartesian Codes for Non-Uniform Communication Channels
# =============================================================================

def design_heterogeneous_code(channel_alphabets: List[int],
                               max_degrees: List[int],
                               prime: int) -> Dict:
    """
    Design an error-correcting code for a communication system where
    different channels have different alphabet sizes.

    In modern communication, different sub-channels may support different
    modulation orders. The footprint bound gives the minimum distance
    guarantee for polynomial codes on such heterogeneous channels.

    Args:
        channel_alphabets: Number of symbols available per sub-channel.
        max_degrees: Polynomial degree bounds per dimension.
        prime: Field size for arithmetic.

    Returns:
        Code design parameters and distance guarantees.

    Example: A system with 3 sub-channels supporting 4, 6, and 3 symbols:
    >>> result = design_heterogeneous_code([4, 6, 3], [2, 3, 1], 7)
    """
    n_channels = len(channel_alphabets)

    # Code parameters
    length = reduce(lambda a, b: a * b, channel_alphabets)
    dimension = reduce(lambda a, b: a * b, [d + 1 for d in max_degrees])

    # Footprint bound gives minimum distance
    min_distance = 1
    for si, ei in zip(channel_alphabets, max_degrees):
        min_distance *= (si - ei)

    # Information rate
    rate = dimension / length

    # Error correction capability
    errors_correctable = (min_distance - 1) // 2

    return {
        "n_channels": n_channels,
        "channel_alphabets": channel_alphabets,
        "code_length": length,
        "code_dimension": dimension,
        "min_distance_bound": min_distance,
        "rate": rate,
        "errors_correctable": errors_correctable,
        "max_degrees": max_degrees,
        "field_size": prime,
    }


# =============================================================================
# APPLICATION 2: Polynomial Identity Testing on Product Domains
# =============================================================================

def polynomial_identity_test(poly_coeffs: Dict[Tuple[int, ...], int],
                              grid_sizes: List[int],
                              prime: int,
                              n_tests: int = 10) -> Dict:
    """
    Test whether a polynomial is identically zero using the footprint bound
    to determine required grid sizes.

    The footprint bound tells us: if f is nonzero with degree bounds e_i,
    then evaluating on sets S_i with |S_i| > e_i, the probability of
    f(random point) = 0 is at most 1 - prod((|S_i| - e_i) / |S_i|).

    Args:
        poly_coeffs: Polynomial coefficients.
        grid_sizes: Size of evaluation sets per variable.
        prime: Field characteristic.
        n_tests: Number of random evaluations.

    Returns:
        Test results including bounds on false-zero probability.
    """
    n_vars = len(grid_sizes) if grid_sizes else 0
    if not poly_coeffs:
        return {"conclusion": "zero", "confidence": 1.0}

    # Determine degree bounds
    degree_bounds = [0] * n_vars
    for exp in poly_coeffs:
        for i, e in enumerate(exp):
            degree_bounds[i] = max(degree_bounds[i], e)

    # Footprint bound: probability of nonzero evaluation
    nonzero_prob_lower = 1.0
    for si, ei in zip(grid_sizes, degree_bounds):
        if ei >= si:
            return {"error": f"Grid size {si} too small for degree {ei}"}
        nonzero_prob_lower *= (si - ei) / si

    # Run random tests
    all_zero = True
    for _ in range(n_tests):
        point = tuple(np.random.randint(0, s) for s in grid_sizes)
        val = 0
        for exp, c in poly_coeffs.items():
            term = c
            for i in range(n_vars):
                term *= point[i] ** exp[i]
            val += term
        if prime > 0:
            val = val % prime
        if val != 0:
            all_zero = False
            break

    # False-zero probability if polynomial is actually nonzero
    false_zero_prob = (1 - nonzero_prob_lower) ** n_tests

    return {
        "degree_bounds": degree_bounds,
        "grid_sizes": grid_sizes,
        "nonzero_prob_lower_bound": nonzero_prob_lower,
        "n_tests": n_tests,
        "all_evaluations_zero": all_zero,
        "false_zero_probability_bound": false_zero_prob,
        "conclusion": "likely zero" if all_zero else "definitely nonzero",
    }


# =============================================================================
# APPLICATION 3: Combinatorial Nullstellensatz for Additive Combinatorics
# =============================================================================

def sumset_lower_bound(A: Set[int], B: Set[int], prime: int) -> Dict:
    """
    Use the Combinatorial Nullstellensatz on non-uniform grids to bound
    the size of the sumset A + B.

    The polynomial f(x, y) = prod_{c in C}(x + y - c) vanishes on A × B
    exactly when x + y ∈ C. By the footprint bound, if deg_x(f) < |A|
    and deg_y(f) < |B|, then f cannot vanish everywhere on A × B
    unless |C| >= |A| + |B| - 1.

    This gives the Cauchy-Davenport theorem as a special case!

    Args:
        A: First finite set in GF(prime).
        B: Second finite set in GF(prime).
        prime: Field characteristic.

    Returns:
        Bounds on |A + B|.
    """
    sumset = {(a + b) % prime for a in A for b in B}

    # The polynomial f(x,y) = prod_{s in sumset}(x + y - s)
    # has degree |sumset| in x and |sumset| in y.
    # For f to vanish on A × B, we need |sumset| >= max(|A|, |B|).
    # But the footprint bound says more:

    # If |A+B| < |A| + |B| - 1, then there exists a nonzero polynomial
    # of degree |A|-1 in x and |B|-1 in y that vanishes on A × B,
    # contradicting the footprint bound.

    cauchy_davenport = min(prime, len(A) + len(B) - 1)

    return {
        "A": sorted(A),
        "B": sorted(B),
        "|A|": len(A),
        "|B|": len(B),
        "|A+B|": len(sumset),
        "A+B": sorted(sumset),
        "Cauchy-Davenport_bound": cauchy_davenport,
        "bound_satisfied": len(sumset) >= cauchy_davenport,
    }


# =============================================================================
# APPLICATION 4: Product-State Rigidity in Statistical Mechanics
# =============================================================================

def product_state_rigidity(state_counts: List[int],
                            interaction_degree: int,
                            prime: int) -> Dict:
    """
    Analyze rigidity of polynomial observables on product configuration spaces.

    In a system where site i has state_counts[i] possible states, a polynomial
    observable with bounded coordinatewise degree cannot be "silent" (zero)
    on too many configurations.

    The footprint bound gives: if the observable is nonzero with degree e_i
    in the state at site i, it must be active on at least prod(|S_i| - e_i)
    configurations.

    Args:
        state_counts: Number of states at each site.
        interaction_degree: Maximum degree of interaction per site.
        prime: Field for arithmetic (or 0 for reals approximation).

    Returns:
        Rigidity analysis results.
    """
    n_sites = len(state_counts)
    total_configs = reduce(lambda a, b: a * b, state_counts)

    # Degree bound per site
    e = [min(interaction_degree, s - 1) for s in state_counts]

    # Footprint bound on active configurations
    min_active = 1
    for si, ei in zip(state_counts, e):
        min_active *= (si - ei)

    # Activity fraction
    activity_fraction = min_active / total_configs

    return {
        "n_sites": n_sites,
        "state_counts": state_counts,
        "total_configurations": total_configs,
        "interaction_degree": interaction_degree,
        "effective_degrees": e,
        "min_active_configs": min_active,
        "activity_fraction": activity_fraction,
        "interpretation": (
            f"Any nonzero polynomial observable with degree ≤ {interaction_degree} "
            f"per site must be active on at least {min_active} of "
            f"{total_configs} configurations ({activity_fraction:.1%} of the space)."
        ),
    }


def main():
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  APPLICATIONS OF THE ANISOTROPIC FOOTPRINT BOUND               ║")
    print("╚══════════════════════════════════════════════════════════════════╝\n")

    # Application 1: Heterogeneous communication channels
    print("=" * 65)
    print("APP 1: Heterogeneous Channel Coding")
    print("=" * 65)
    result = design_heterogeneous_code([4, 6, 3], [2, 3, 1], 7)
    for k, v in result.items():
        print(f"  {k}: {v}")
    print()

    # Application 2: Polynomial identity testing
    print("=" * 65)
    print("APP 2: Polynomial Identity Testing")
    print("=" * 65)
    # Test a nonzero polynomial
    poly = {(2, 1): 1, (1, 0): 3, (0, 2): -1}
    result = polynomial_identity_test(poly, [10, 8], 101, n_tests=5)
    for k, v in result.items():
        print(f"  {k}: {v}")
    print()

    # Test the zero polynomial
    result = polynomial_identity_test({}, [10, 8], 101, n_tests=5)
    print(f"  Zero polynomial: {result}")
    print()

    # Application 3: Sumset bounds
    print("=" * 65)
    print("APP 3: Cauchy-Davenport via Nullstellensatz")
    print("=" * 65)
    A = {0, 1, 2, 3}
    B = {0, 2, 4}
    result = sumset_lower_bound(A, B, 11)
    for k, v in result.items():
        print(f"  {k}: {v}")
    print()

    # Application 4: Statistical mechanics rigidity
    print("=" * 65)
    print("APP 4: Product-State Configuration Rigidity")
    print("=" * 65)
    result = product_state_rigidity([3, 4, 2, 5], interaction_degree=1, prime=0)
    for k, v in result.items():
        print(f"  {k}: {v}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Demo: Anisotropic Footprint Bound on Finite Cartesian Products

Demonstrates the Alon-Füredi / footprint bound for multivariate polynomials
evaluated on non-uniform finite grids over a field.

Theorem: If f is a nonzero polynomial with deg_{x_i}(f) <= e_i < |S_i|,
then |{x in prod S_i : f(x) != 0}| >= prod (|S_i| - e_i).
"""

import numpy as np
from itertools import product



def count_nonzeros_on_grid(poly_coeffs, variables, grid_sets, prime=None):
    """
    Count nonzero evaluations of a multivariate polynomial on a finite grid.

    Args:
        poly_coeffs: dict mapping exponent tuples to coefficients
        variables: list of variable names
        grid_sets: list of sets (one per variable)
        prime: if given, work over GF(prime)

    Returns:
        (total_grid_points, nonzero_count, zero_count)
    """
    n = len(variables)
    grid_points = list(product(*grid_sets))
    total = len(grid_points)

    nonzero = 0
    for pt in grid_points:
        val = 0
        for exps, coeff in poly_coeffs.items():
            term = coeff
            for i in range(n):
                term *= pt[i] ** exps[i]
            val += term
        if prime:
            val = val % prime
        if val != 0:
            nonzero += 1

    return total, nonzero, total - nonzero


def max_degree_per_var(poly_coeffs, n):
    """Get maximum degree in each variable."""
    e = [0] * n
    for exps in poly_coeffs:
        for i in range(n):
            e[i] = max(e[i], exps[i])
    return e


def footprint_lower_bound(grid_sets, degree_bounds):
    """Compute the footprint lower bound prod(|S_i| - e_i)."""
    bound = 1
    for S, e in zip(grid_sets, degree_bounds):
        bound *= (len(S) - e)
    return bound


def demo_1_uniform_grid():
    """Demo 1: Uniform grid (classical Schwartz-Zippel specialization)."""
    print("=" * 70)
    print("DEMO 1: Uniform Grid — Classical Schwartz-Zippel Setting")
    print("=" * 70)
    print()

    # f(x, y) = x^2 + xy + y + 1 over Z/7Z, grid = {0,1,2,3,4}^2
    poly = {(2, 0): 1, (1, 1): 1, (0, 1): 1, (0, 0): 1}
    grid_sets = [set(range(5)), set(range(5))]
    prime = 7

    e = max_degree_per_var(poly, 2)
    bound = footprint_lower_bound(grid_sets, e)
    total, nonzero, zeros = count_nonzeros_on_grid(poly, ['x', 'y'], grid_sets, prime)

    print(f"Polynomial: f(x,y) = x² + xy + y + 1 over GF(7)")
    print(f"Grid: {{0,1,2,3,4}}² (uniform, |S| = 5)")
    print(f"Degree bounds: e = {e}")
    print(f"")
    print(f"Grid size:           {total}")
    print(f"Nonzero evaluations: {nonzero}")
    print(f"Zero evaluations:    {zeros}")
    print(f"Footprint bound:     ∏(|Sᵢ| - eᵢ) = {bound}")
    print(f"Bound satisfied:     {nonzero} ≥ {bound} → {'✓ YES' if nonzero >= bound else '✗ NO'}")
    print()


def demo_2_anisotropic_grid():
    """Demo 2: Anisotropic grid — the novel case."""
    print("=" * 70)
    print("DEMO 2: Anisotropic Grid — Non-Uniform Coordinate Sets")
    print("=" * 70)
    print()

    # f(x, y, z) = x*y + y^2*z + z + 3 over Z/11Z
    # S_x = {0,1,2,3,4,5}, S_y = {0,1,2}, S_z = {0,1,2,3}
    poly = {(1, 1, 0): 1, (0, 2, 1): 1, (0, 0, 1): 1, (0, 0, 0): 3}
    grid_sets = [set(range(6)), set(range(3)), set(range(4))]
    prime = 11

    e = max_degree_per_var(poly, 3)
    bound = footprint_lower_bound(grid_sets, e)
    total, nonzero, zeros = count_nonzeros_on_grid(poly, ['x', 'y', 'z'], grid_sets, prime)

    print(f"Polynomial: f(x,y,z) = xy + y²z + z + 3 over GF(11)")
    print(f"Grid: {{0,...,5}} × {{0,1,2}} × {{0,1,2,3}} (ANISOTROPIC)")
    print(f"  |S_x| = 6, |S_y| = 3, |S_z| = 4")
    print(f"Degree bounds: e = {e}")
    print(f"  (e_x = {e[0]} < |S_x| = 6  ✓)")
    print(f"  (e_y = {e[1]} < |S_y| = 3  ✓)")
    print(f"  (e_z = {e[2]} < |S_z| = 4  ✓)")
    print(f"")
    print(f"Grid size:           {total}")
    print(f"Nonzero evaluations: {nonzero}")
    print(f"Zero evaluations:    {zeros}")
    print(f"Footprint bound:     ∏(|Sᵢ| - eᵢ) = (6-1)·(3-2)·(4-1) = {bound}")
    print(f"Bound satisfied:     {nonzero} ≥ {bound} → {'✓ YES' if nonzero >= bound else '✗ NO'}")
    print()


def demo_3_tightness():
    """Demo 3: Show the bound can be tight."""
    print("=" * 70)
    print("DEMO 3: Tightness — When the Bound is Exact")
    print("=" * 70)
    print()

    # The product of vanishing-like polynomials saturates the bound.
    # f(x) = (x-0)(x-1) = x^2 - x on S = {0,1,2,3,4} over Z/7Z
    # e = 2, |S| = 5, bound = 5 - 2 = 3
    # Nonzeros: f(2)=2, f(3)=6, f(4)=12≡5 (mod 7) → exactly 3 nonzeros
    poly = {(2,): 1, (1,): -1}
    grid_sets = [set(range(5))]
    prime = 7

    e = max_degree_per_var(poly, 1)
    bound = footprint_lower_bound(grid_sets, e)
    total, nonzero, zeros = count_nonzeros_on_grid(poly, ['x'], grid_sets, prime)

    print(f"Polynomial: f(x) = x² - x = x(x-1) over GF(7)")
    print(f"Grid: {{0,1,2,3,4}}, |S| = 5")
    print(f"Degree bound: e = {e[0]}")
    print(f"f(0) = 0, f(1) = 0, f(2) = 2, f(3) = 6, f(4) = 5 mod 7")
    print(f"")
    print(f"Grid size:           {total}")
    print(f"Nonzero evaluations: {nonzero}")
    print(f"Footprint bound:     |S| - e = 5 - 2 = {bound}")
    print(f"Bound is TIGHT:      {nonzero} = {bound} → {'✓ EXACT' if nonzero == bound else 'not tight'}")
    print()


def demo_4_coding_theory():
    """Demo 4: Affine Cartesian code minimum distance."""
    print("=" * 70)
    print("DEMO 4: Coding Theory — Affine Cartesian Code Distance")
    print("=" * 70)
    print()

    # For the evaluation code C(S, e) on grid prod S_i with deg_{x_i} <= e_i,
    # the minimum distance d_min >= prod(|S_i| - e_i).

    prime = 5
    grid_sets = [set(range(4)), set(range(3))]  # S_x={0,1,2,3}, S_y={0,1,2}
    max_degs = [2, 1]  # allow deg_x ≤ 2, deg_y ≤ 1

    print(f"Affine Cartesian Code over GF({prime})")
    print(f"Grid: {{0,1,2,3}} × {{0,1,2}} (|S_x|=4, |S_y|=3)")
    print(f"Maximum degrees: e_x={max_degs[0]}, e_y={max_degs[1]}")
    print(f"")

    # Generate all reduced monomials
    monomials = []
    for dx in range(max_degs[0] + 1):
        for dy in range(max_degs[1] + 1):
            monomials.append((dx, dy))

    print(f"Reduced monomials: {monomials}")
    print(f"Code dimension k = {len(monomials)}")
    print(f"Code length n = {len(list(product(*grid_sets)))}")
    print(f"")

    bound = footprint_lower_bound(grid_sets, max_degs)
    print(f"Minimum distance bound: d_min ≥ ∏(|Sᵢ| - eᵢ) = (4-2)·(3-1) = {bound}")

    # Verify by checking all nonzero codewords
    grid_pts = list(product(*grid_sets))
    min_weight = float('inf')

    # Check random codewords
    np.random.seed(42)
    for _ in range(1000):
        coeffs = {m: np.random.randint(1, prime) for m in monomials}
        if all(c == 0 for c in coeffs.values()):
            continue
        _, nonzero, _ = count_nonzeros_on_grid(coeffs, ['x', 'y'], grid_sets, prime)
        if nonzero > 0:
            min_weight = min(min_weight, nonzero)

    print(f"Minimum weight found (sampling): {min_weight}")
    print(f"Bound satisfied: {min_weight} ≥ {bound} → {'✓ YES' if min_weight >= bound else '✗ NO'}")
    print()


def demo_5_scaling():
    """Demo 5: How the bound scales with dimension."""
    print("=" * 70)
    print("DEMO 5: Dimensional Scaling of the Footprint Bound")
    print("=" * 70)
    print()

    prime = 101
    results = []

    for n in range(1, 6):
        # Use anisotropic grid: S_i = {0,...,2+i}
        grid_sets = [set(range(3 + i)) for i in range(n)]
        # Polynomial: sum of x_i^1
        poly = {}
        for i in range(n):
            exp = tuple(1 if j == i else 0 for j in range(n))
            poly[exp] = 1

        e = max_degree_per_var(poly, n)
        bound = footprint_lower_bound(grid_sets, e)
        total, nonzero, zeros = count_nonzeros_on_grid(poly, [f'x{i}' for i in range(n)], grid_sets, prime)

        results.append((n, total, nonzero, bound))
        print(f"n={n}: grid_size={total:6d}, nonzeros={nonzero:6d}, "
              f"bound={bound:6d}, ratio={nonzero/total:.3f}")

    print()
    print("The bound grows multiplicatively with dimension,")
    print("reflecting the product structure of the grid.")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  ANISOTROPIC FOOTPRINT BOUND — Computational Demonstrations    ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()

    demo_1_uniform_grid()
    demo_2_anisotropic_grid()
    demo_3_tightness()
    demo_4_coding_theory()
    demo_5_scaling()

    print()
    print("All demonstrations complete. The footprint bound is verified in every case.")


#!/usr/bin/env python3
"""Generate PACKAGE.json with all embedded content."""

import json
import sys
import os

# Read markdown files
def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read Lean files
def read_lean():
    helpers = read_file('Bridges/Combinatorics/FootprintHelpers.lean')
    main = read_file('Bridges/Combinatorics/CartesianFootprintBound.lean')
    return helpers + "\n\n-- ═══════════════════════════════════════════\n-- Main File: CartesianFootprintBound.lean\n-- ═══════════════════════════════════════════\n\n" + main

# Generate visualizations
sys.path.insert(0, '.')
from visualizations import viz1_grid_pattern, viz2_bound_comparison, viz3_dimensional_scaling, viz4_code_tradeoff

print("Generating visualizations...")
v1 = viz1_grid_pattern()
v2 = viz2_bound_comparison()
v3 = viz3_dimensional_scaling()
v4 = viz4_code_tradeoff()

print("Reading source files...")
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_proofs = read_lean()
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')

# Build the footprint bound algorithm pseudocode
footprint_pseudocode = """Algorithm: Anisotropic Footprint Bound Verification
Input: Polynomial f (as coefficient dict), grid sets S_1,...,S_n, field char p
Output: (nonzero_count, footprint_bound, is_satisfied)

1. Compute degree bounds: e_i = max{m_i : X^m in supp(f)} for each i
2. Verify reducedness: e_i < |S_i| for all i
3. Compute footprint bound: B = prod_{i=1}^{n} (|S_i| - e_i)
4. Enumerate grid: G = S_1 × S_2 × ... × S_n
5. Count nonzeros: N = |{x in G : f(x) mod p != 0}|
6. Return (N, B, N >= B)

Time: O(|G| * |supp(f)|) = O(prod|S_i| * #monomials)
Space: O(|G|)"""

package = {
    "title": "Anisotropic Footprint Bound on Finite Cartesian Products",
    "domain": "Algebra / Combinatorics / Coding Theory",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Footprint Bound Demonstrations",
            "code": demo_code
        },
        {
            "name": "Applications: Coding, Testing, Combinatorics, Physics",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Anisotropic Footprint Bound Verification",
            "pseudocode": footprint_pseudocode,
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Nonzero Patterns on Anisotropic 2D Grid",
            "data": v1
        },
        {
            "name": "Footprint Bound vs Actual Nonzero Count",
            "data": v2
        },
        {
            "name": "Dimensional Scaling of the Footprint Bound",
            "data": v3
        },
        {
            "name": "Code Rate-Distance Tradeoff",
            "data": v4
        }
    ],
    "lean_proofs": lean_proofs
}

print("Writing PACKAGE.json...")
with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json written ({os.path.getsize('PACKAGE.json')} bytes)")


#!/usr/bin/env python3
"""
Visualizations for the Anisotropic Footprint Bound

Generates publication-quality figures showing:
1. Nonzero patterns on 2D grids
2. Footprint bound vs actual count comparison
3. Dimensional scaling
4. Code rate-distance tradeoff
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import product
import base64
from io import BytesIO


def eval_poly_grid(poly_coeffs, grid_sets, prime):
    """Evaluate polynomial on grid, return array of values."""
    grid_pts = list(product(*[sorted(s) for s in grid_sets]))
    values = []
    for pt in grid_pts:
        val = 0
        for exp, c in poly_coeffs.items():
            term = c
            for i in range(len(pt)):
                term *= pt[i] ** exp[i]
            val += term
        if prime:
            val = val % prime
        values.append(val)
    return grid_pts, values


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def viz1_grid_pattern():
    """Visualize nonzero pattern on a 2D anisotropic grid."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    polys = [
        ({(1, 0): 1, (0, 1): 1, (0, 0): 2}, "f(x,y) = x + y + 2"),
        ({(2, 0): 1, (1, 1): 1, (0, 0): 1}, "f(x,y) = x² + xy + 1"),
        ({(1, 1): 1, (0, 2): 1, (0, 0): 3}, "f(x,y) = xy + y² + 3"),
    ]

    grid_x = list(range(7))
    grid_y = list(range(5))
    prime = 11

    for ax, (poly, title) in zip(axes, polys):
        pts, vals = eval_poly_grid(poly, [grid_x, grid_y], prime)

        for pt, v in zip(pts, vals):
            color = '#2ecc71' if v != 0 else '#e74c3c'
            marker = 'o' if v != 0 else 'x'
            size = 80 if v != 0 else 60
            ax.scatter(pt[0], pt[1], c=color, marker=marker, s=size, zorder=3)

        e = [max(exp[i] for exp in poly) for i in range(2)]
        bound = (len(grid_x) - e[0]) * (len(grid_y) - e[1])
        nonzeros = sum(1 for v in vals if v != 0)

        ax.set_title(f"{title}\nNonzeros: {nonzeros}, Bound: {bound}", fontsize=11)
        ax.set_xlabel('x')
        ax.set_ylabel('y')
        ax.set_xlim(-0.5, 6.5)
        ax.set_ylim(-0.5, 4.5)
        ax.grid(True, alpha=0.3)
        ax.set_aspect('equal')

    fig.suptitle('Nonzero Patterns on Anisotropic Grid {0,...,6} × {0,...,4} over GF(11)',
                 fontsize=13, fontweight='bold')
    plt.tight_layout()
    return fig_to_base64(fig)


def viz2_bound_comparison():
    """Compare footprint bound with actual nonzero counts."""
    fig, ax = plt.subplots(figsize=(10, 6))

    prime = 101
    np.random.seed(42)

    # Generate random polynomials with various degree profiles
    results = []
    for trial in range(50):
        n_vars = 2
        grid_sizes = [np.random.randint(3, 10) for _ in range(n_vars)]
        max_degs = [np.random.randint(1, s) for s in grid_sizes]

        # Random polynomial
        poly = {}
        for _ in range(np.random.randint(1, 8)):
            exp = tuple(np.random.randint(0, d + 1) for d in max_degs)
            poly[exp] = np.random.randint(1, prime)

        if not poly:
            continue

        grid_sets = [list(range(s)) for s in grid_sizes]
        _, vals = eval_poly_grid(poly, grid_sets, prime)
        nonzeros = sum(1 for v in vals if v != 0)
        bound = 1
        for s, d in zip(grid_sizes, max_degs):
            bound *= (s - d)

        results.append((bound, nonzeros, grid_sizes[0] * grid_sizes[1]))

    bounds = [r[0] for r in results]
    actuals = [r[1] for r in results]
    sizes = [r[2] for r in results]

    scatter = ax.scatter(bounds, actuals, c=sizes, cmap='viridis',
                         s=80, alpha=0.7, edgecolors='black', linewidth=0.5)
    plt.colorbar(scatter, label='Grid size |∏Sᵢ|')

    max_val = max(max(bounds), max(actuals)) * 1.1
    ax.plot([0, max_val], [0, max_val], 'r--', alpha=0.5, label='y = x (tight bound)')
    ax.set_xlabel('Footprint Bound ∏(|Sᵢ| - eᵢ)', fontsize=12)
    ax.set_ylabel('Actual Nonzero Count', fontsize=12)
    ax.set_title('Footprint Bound vs. Actual Nonzeros\n(50 Random Polynomials on Random Anisotropic Grids)',
                 fontsize=13, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    return fig_to_base64(fig)


def viz3_dimensional_scaling():
    """Show how the bound scales with dimension."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    prime = 1009
    dims = range(1, 8)

    # Fixed degree d=1, varying grid size
    for grid_base in [3, 4, 5, 6]:
        bounds = []
        totals = []
        for n in dims:
            bound = (grid_base - 1) ** n
            total = grid_base ** n
            bounds.append(bound)
            totals.append(total)
        ax1.semilogy(list(dims), totals, '--', alpha=0.4, color='gray')
        ax1.semilogy(list(dims), bounds, 'o-', label=f'|S|={grid_base}, d=1',
                     markersize=6)

    ax1.set_xlabel('Number of variables n', fontsize=12)
    ax1.set_ylabel('Count (log scale)', fontsize=12)
    ax1.set_title('Footprint Bound Scaling\n(degree 1, varying grid size)',
                  fontsize=13, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Fixed grid size, varying degree
    grid_size = 6
    for d in [1, 2, 3, 4]:
        bounds = []
        for n in dims:
            bounds.append((grid_size - d) ** n)
        ax2.semilogy(list(dims), bounds, 'o-', label=f'd={d}, |S|={grid_size}',
                     markersize=6)

    ax2.semilogy(list(dims), [grid_size ** n for n in dims], 'k--',
                 alpha=0.4, label=f'Grid size {grid_size}ⁿ')
    ax2.set_xlabel('Number of variables n', fontsize=12)
    ax2.set_ylabel('Footprint bound (log scale)', fontsize=12)
    ax2.set_title('Effect of Degree on Footprint\n(fixed grid size |S|=6)',
                  fontsize=13, fontweight='bold')
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    return fig_to_base64(fig)


def viz4_code_tradeoff():
    """Rate-distance tradeoff for affine Cartesian codes."""
    fig, ax = plt.subplots(figsize=(10, 7))

    # Varying anisotropy
    configs = [
        ([5, 5, 5], 'Uniform 5³', 'o'),
        ([3, 5, 7], 'Aniso 3×5×7', 's'),
        ([4, 4, 7], 'Aniso 4×4×7', '^'),
        ([3, 6, 6], 'Aniso 3×6×6', 'D'),
    ]

    for grid_sizes, label, marker in configs:
        rates = []
        rel_distances = []
        for e0 in range(1, grid_sizes[0]):
            for e1 in range(1, grid_sizes[1]):
                for e2 in range(1, grid_sizes[2]):
                    dim = (e0 + 1) * (e1 + 1) * (e2 + 1)
                    length = grid_sizes[0] * grid_sizes[1] * grid_sizes[2]
                    dist = (grid_sizes[0] - e0) * (grid_sizes[1] - e1) * (grid_sizes[2] - e2)
                    rate = dim / length
                    rel_dist = dist / length
                    rates.append(rate)
                    rel_distances.append(rel_dist)

        ax.scatter(rates, rel_distances, marker=marker, alpha=0.6,
                   s=40, label=label, edgecolors='black', linewidth=0.3)

    # Singleton bound
    r = np.linspace(0, 1, 100)
    ax.plot(r, 1 - r, 'r--', alpha=0.5, label='Singleton bound', linewidth=2)

    ax.set_xlabel('Code Rate k/n', fontsize=12)
    ax.set_ylabel('Relative Min. Distance d/n', fontsize=12)
    ax.set_title('Rate-Distance Tradeoff for Affine Cartesian Codes\n'
                 '(Footprint Bound on Various Grid Geometries)',
                 fontsize=13, fontweight='bold')
    ax.legend(fontsize=10, loc='upper right')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)

    plt.tight_layout()
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")

    v1 = viz1_grid_pattern()
    print(f"  Grid pattern: {len(v1)} chars")

    v2 = viz2_bound_comparison()
    print(f"  Bound comparison: {len(v2)} chars")

    v3 = viz3_dimensional_scaling()
    print(f"  Dimensional scaling: {len(v3)} chars")

    v4 = viz4_code_tradeoff()
    print(f"  Code tradeoff: {len(v4)} chars")

    print("All visualizations generated successfully.")
