#!/usr/bin/env python3
"""
Applications of bounded-degree polynomial dimension formulas.

Demonstrates connections to machine learning (polynomial kernels),
coding theory (Reed-Muller codes), statistical mechanics (partition functions),
and numerical analysis (interpolation).
"""

import numpy as np
from math import comb, factorial
from algorithms import (
    bounded_degree_dimension,
    homogeneous_dimension,
    enumerate_exponent_vectors,
    construct_vandermonde,
    monomial_to_string,
)


# ============================================================================
# APPLICATION 1: Polynomial Kernel Methods (Machine Learning)
# ============================================================================

def polynomial_kernel_analysis(n_features: int, max_degree: int):
    """Analyze polynomial kernel feature expansion.
    
    In kernel methods, a polynomial kernel of degree d maps data from R^n
    to a feature space of dimension C(d+n, n) (for degree ≤ d).
    
    This function analyzes the dimensionality explosion.
    """
    print("=" * 60)
    print(f"POLYNOMIAL KERNEL ANALYSIS: {n_features} features")
    print("=" * 60)
    
    for d in range(1, max_degree + 1):
        dim = bounded_degree_dimension(n_features, d + 1)  # degree ≤ d = degree < d+1
        print(f"  Degree ≤ {d}: {dim:>10,} feature dimensions")
    
    # Growth analysis
    print(f"\n  Growth is O(n^d/d!) ≈ n^d/{factorial(max_degree)}")
    print(f"  For n={n_features}, d={max_degree}: exact = {bounded_degree_dimension(n_features, max_degree+1):,}")
    print(f"  Approximate: {n_features**max_degree // factorial(max_degree):,}")
    print()


def polynomial_regression_demo():
    """Demonstrate polynomial regression using the dimension formula."""
    print("=" * 60)
    print("POLYNOMIAL REGRESSION: Minimum Data Requirements")
    print("=" * 60)
    
    print("\nTo fit a polynomial of degree < d in n variables, you need")
    print("at least C(d+n-1, n) data points.\n")
    
    scenarios = [
        ("Simple parabola", 1, 3),
        ("Quadratic surface", 2, 3),
        ("Cubic surface", 2, 4),
        ("ML: quadratic model, 10 features", 10, 3),
        ("ML: quadratic model, 100 features", 100, 3),
        ("ML: cubic model, 10 features", 10, 4),
        ("ML: quartic model, 5 features", 5, 5),
    ]
    
    for desc, n, d in scenarios:
        dim = bounded_degree_dimension(n, d)
        print(f"  {desc}:")
        print(f"    n={n}, d={d} → {dim:>10,} coefficients needed")
    print()


# ============================================================================
# APPLICATION 2: Reed-Muller Codes (Coding Theory)
# ============================================================================

def reed_muller_analysis():
    """Analyze Reed-Muller error-correcting codes.
    
    RM(r, m) is the code of polynomials of degree ≤ r in m variables over F_2.
    - Block length: 2^m
    - Dimension: ∑_{i=0}^{r} C(m, i) = C(m+r, m) for RM over F_2
    - Minimum distance: 2^{m-r}
    
    Note: Over F_2, since x² = x, the dimension is different from
    the general formula. Here we show the general polynomial space
    dimension for comparison.
    """
    print("=" * 60)
    print("REED-MULLER CODE ANALYSIS")
    print("=" * 60)
    
    print("\nGeneral polynomial space dimension C(d+n-1, n):")
    print(f"{'(r,m)':>8} {'block_len':>10} {'poly_dim':>10} {'rate':>8}")
    print("-" * 40)
    
    for m in range(2, 7):
        for r in range(1, m):
            block_len = 2**m
            poly_dim = bounded_degree_dimension(m, r + 1)
            rate = poly_dim / block_len
            print(f"({r},{m})    {block_len:>10} {poly_dim:>10} {rate:>8.4f}")
    print()


# ============================================================================
# APPLICATION 3: Statistical Mechanics (Partition Functions)
# ============================================================================

def bosonic_occupancy_demo():
    """Demonstrate the connection to bosonic occupancy states.
    
    In quantum mechanics, C(m+n-1, n-1) counts the number of ways
    to distribute m identical bosons across n energy levels.
    This is exactly the dimension of the homogeneous component.
    """
    print("=" * 60)
    print("BOSONIC OCCUPANCY STATES")
    print("=" * 60)
    
    print("\nNumber of ways to distribute m bosons into n energy levels")
    print("= Number of monomials of degree m in n variables")
    print("= C(m+n-1, n-1)\n")
    
    for n in [2, 3, 4, 5]:
        print(f"  n={n} levels:")
        total = 0
        for m in range(8):
            states = homogeneous_dimension(n, m)
            total += states
            print(f"    m={m} bosons: {states:>6} states (cumulative: {total})")
        print()


def partition_function_demo():
    """Compute partition functions using the dimension formula.
    
    The partition function Z = ∑_m g(m) exp(-βm) where g(m) is the
    degeneracy (number of states at energy m).
    
    For n energy levels: g(m) = C(m+n-1, n-1).
    """
    print("=" * 60)
    print("PARTITION FUNCTION COMPUTATION")
    print("=" * 60)
    
    n_levels = 3
    max_energy = 20
    temperatures = [0.5, 1.0, 2.0, 5.0, 10.0]
    
    print(f"\n{n_levels} energy levels, E_max = {max_energy}")
    print(f"{'kT':>6}", end="")
    print(f"{'Z':>12}", end="")
    print(f"{'<E>':>12}", end="")
    print(f"{'<E²>':>12}")
    print("-" * 44)
    
    for kT in temperatures:
        beta = 1.0 / kT
        Z = 0.0
        E_avg = 0.0
        E2_avg = 0.0
        
        for m in range(max_energy + 1):
            g = homogeneous_dimension(n_levels, m)
            boltzmann = np.exp(-beta * m)
            Z += g * boltzmann
            E_avg += m * g * boltzmann
            E2_avg += m**2 * g * boltzmann
        
        E_avg /= Z
        E2_avg /= Z
        
        print(f"{kT:>6.1f} {Z:>12.2f} {E_avg:>12.4f} {E2_avg:>12.4f}")
    
    print(f"\nExact: Z = 1/(1 - e^{{-β}})^{n_levels}")
    print()


# ============================================================================
# APPLICATION 4: Numerical Interpolation
# ============================================================================

def interpolation_demo():
    """Demonstrate multivariate polynomial interpolation."""
    print("=" * 60)
    print("MULTIVARIATE POLYNOMIAL INTERPOLATION")
    print("=" * 60)
    
    n, d = 2, 4  # 2 variables, degree < 4
    dim = bounded_degree_dimension(n, d)
    
    print(f"\nInterpolating degree < {d} polynomials in {n} variables")
    print(f"Dimension: {dim} (need at least {dim} points)")
    
    # Generate random interpolation points
    np.random.seed(42)
    N = dim  # Minimal interpolation
    points = np.random.randn(N, n)
    
    # Target function: a known polynomial
    def target(x, y):
        return 1 + 2*x + 3*y + x**2 - x*y + 0.5*y**2 + x**3
    
    values = np.array([target(p[0], p[1]) for p in points])
    
    # Build Vandermonde and solve
    V = construct_vandermonde(points, d)
    
    # Solve least squares
    coeffs, residuals, rank, sv = np.linalg.lstsq(V, values, rcond=None)
    
    print(f"  Vandermonde matrix shape: {V.shape}")
    print(f"  Matrix rank: {rank}")
    print(f"  Condition number: {sv[0]/sv[-1]:.2e}")
    
    # Show recovered coefficients
    exponents = list(enumerate_exponent_vectors(n, d))
    print(f"\n  Recovered coefficients:")
    for exp, c in zip(exponents, coeffs):
        if abs(c) > 1e-10:
            monomial = monomial_to_string(exp)
            print(f"    {monomial:>10}: {c:>10.4f}")
    
    # Verify on test points
    test_points = np.random.randn(100, n)
    test_values = np.array([target(p[0], p[1]) for p in test_points])
    V_test = construct_vandermonde(test_points, d)
    predictions = V_test @ coeffs
    max_error = np.max(np.abs(predictions - test_values))
    print(f"\n  Max interpolation error on 100 test points: {max_error:.2e}")
    print()


# ============================================================================
# APPLICATION 5: Feature Dimension Explosion Visualization Data
# ============================================================================

def feature_explosion_data():
    """Generate data for visualizing feature dimension explosion."""
    print("=" * 60)
    print("FEATURE DIMENSION EXPLOSION")
    print("=" * 60)
    
    print("\nDimension C(d+n-1, n) grows polynomially in d for fixed n:")
    for n in [2, 5, 10, 20, 50]:
        dims = [bounded_degree_dimension(n, d) for d in range(1, 11)]
        print(f"  n={n:>3}: {dims}")
    
    print("\n...and exponentially in n for fixed d:")
    for d in [2, 3, 4, 5]:
        dims = [bounded_degree_dimension(n, d) for n in [2, 5, 10, 20, 50, 100]]
        print(f"  d={d}: {dims}")
    print()


if __name__ == "__main__":
    polynomial_kernel_analysis(10, 5)
    polynomial_regression_demo()
    reed_muller_analysis()
    bosonic_occupancy_demo()
    partition_function_demo()
    interpolation_demo()
    feature_explosion_data()


#!/usr/bin/env python3
"""
Demonstrations of the bounded-degree polynomial dimension formula.

This script illustrates the stars-and-bars theorem and its algebraic
interpretation: the dimension of the space of multivariate polynomials
of bounded total degree.
"""

from math import comb, factorial
from itertools import product as cartesian_product


def multichoose(n: int, k: int) -> int:
    """Number of multisets of size k from n elements = C(n+k-1, k)."""
    if n == 0 and k == 0:
        return 1
    if n == 0:
        return 0
    return comb(n + k - 1, k)


def count_monomials_exact(n: int, m: int) -> int:
    """Count monomials in n variables with total degree exactly m.
    
    This equals the number of weak compositions of m into n parts,
    which is multichoose(n, m) = C(m+n-1, n-1) for n >= 1.
    """
    return multichoose(n, m)


def count_monomials_bounded(n: int, d: int) -> int:
    """Count monomials in n variables with total degree < d.
    
    This equals C(d+n-1, n) for d+n > 0.
    """
    if d == 0:
        return 0
    return sum(count_monomials_exact(n, m) for m in range(d))


def enumerate_monomials(n: int, d: int) -> list:
    """Enumerate all monomials in n variables with total degree < d.
    
    Returns list of exponent tuples.
    """
    if d == 0:
        return []
    result = []
    # Generate all tuples (e_1, ..., e_n) with sum < d
    def generate(remaining_vars, remaining_degree, current):
        if remaining_vars == 0:
            result.append(tuple(current))
            return
        for e in range(remaining_degree + 1):
            current.append(e)
            generate(remaining_vars - 1, remaining_degree - e, current)
            current.pop()
    
    for total in range(d):
        generate(n, total, [])
    return result


def verify_formula(max_n: int = 6, max_d: int = 8):
    """Verify the dimension formula by enumeration for small cases."""
    print("=" * 70)
    print("VERIFICATION: Counting monomials vs formula")
    print("=" * 70)
    print(f"{'n':>3} {'d':>3} {'enumerated':>12} {'formula':>12} {'match':>6}")
    print("-" * 40)
    
    for n in range(1, max_n + 1):
        for d in range(max_d + 1):
            # Enumerate directly
            monomials = enumerate_monomials(n, d)
            count_enum = len(monomials)
            # Formula
            count_formula = comb(d + n - 1, n)
            
            match = "✓" if count_enum == count_formula else "✗"
            if n <= 3 or d <= 3:  # Don't print everything
                print(f"{n:>3} {d:>3} {count_enum:>12} {count_formula:>12} {match:>6}")
    print()


def print_monomial_table():
    """Print a nice table of monomial counts."""
    print("=" * 70)
    print("TABLE: Number of monomials of degree < d in n variables")
    print("       C(d + n - 1, n)")
    print("=" * 70)
    
    max_n = 8
    max_d = 10
    
    # Header
    print(f"{'d\\n':>6}", end="")
    for n in range(1, max_n + 1):
        print(f"{n:>8}", end="")
    print()
    print("-" * (6 + 8 * max_n))
    
    for d in range(max_d + 1):
        print(f"{d:>6}", end="")
        for n in range(1, max_n + 1):
            val = comb(d + n - 1, n)
            print(f"{val:>8}", end="")
        print()
    print()


def print_homogeneous_table():
    """Print dimensions of homogeneous components."""
    print("=" * 70)
    print("TABLE: Dimension of degree-m homogeneous component in n variables")
    print("       C(m + n - 1, n - 1)")
    print("=" * 70)
    
    max_n = 8
    max_m = 10
    
    print(f"{'m\\n':>6}", end="")
    for n in range(1, max_n + 1):
        print(f"{n:>8}", end="")
    print()
    print("-" * (6 + 8 * max_n))
    
    for m in range(max_m + 1):
        print(f"{m:>6}", end="")
        for n in range(1, max_n + 1):
            val = comb(m + n - 1, n - 1)
            print(f"{val:>8}", end="")
        print()
    print()


def hockey_stick_demo():
    """Demonstrate the hockey-stick identity linking homogeneous and bounded."""
    print("=" * 70)
    print("HOCKEY-STICK IDENTITY")
    print("∑_{m=0}^{d-1} C(m+n-1, n-1) = C(d+n-1, n)")
    print("=" * 70)
    
    for n in [2, 3, 4]:
        for d in [1, 3, 5]:
            lhs = sum(comb(m + n - 1, n - 1) for m in range(d))
            rhs = comb(d + n - 1, n)
            print(f"  n={n}, d={d}: ∑ = {lhs}, C({d+n-1},{n}) = {rhs}  {'✓' if lhs == rhs else '✗'}")
    print()


def polynomial_feature_map_demo():
    """Demonstrate polynomial feature maps for machine learning."""
    print("=" * 70)
    print("APPLICATION: Polynomial Feature Maps")
    print("=" * 70)
    
    print("\nFor a polynomial kernel of degree < d on n-dimensional inputs:")
    print("The feature dimension equals C(d+n-1, n).\n")
    
    examples = [
        (2, 3, "quadratic features on 2D data"),
        (10, 3, "quadratic features on 10D data"),
        (100, 3, "quadratic features on 100D data"),
        (2, 6, "degree-5 features on 2D data"),
        (3, 6, "degree-5 features on 3D data"),
        (10, 4, "cubic features on 10D data"),
    ]
    
    for n, d, desc in examples:
        dim = comb(d + n - 1, n)
        print(f"  {desc}: {dim:,} features")
    print()


def reed_muller_demo():
    """Demonstrate Reed-Muller code dimensions."""
    print("=" * 70)
    print("APPLICATION: Reed-Muller Code Dimensions")
    print("=" * 70)
    
    print("\nReed-Muller code RM(r, m) has message dimension = C(m+r, m).")
    print("(Polynomials of degree ≤ r in m variables over F_2.)\n")
    
    for m in range(1, 7):
        for r in range(m + 1):
            dim = comb(m + r, m)  # degree ≤ r = degree < r+1
            block_len = 2**m
            print(f"  RM({r},{m}): [{block_len}, {dim}] code", end="")
            if r == 0:
                print(" (repetition code)")
            elif r == m:
                print(" (universe code)")
            elif r == 1:
                print(" (first-order RM)")
            else:
                print()
    print()


def stars_and_bars_visual():
    """Visual demonstration of stars-and-bars bijection."""
    print("=" * 70)
    print("STARS-AND-BARS VISUALIZATION")
    print("Distributing 3 identical balls into 3 boxes")
    print("= Monomials of degree 3 in 3 variables")
    print(f"= C(3+3-1, 3-1) = C(5,2) = {comb(5,2)} ways")
    print("=" * 70)
    
    n, m = 3, 3
    count = 0
    for a in range(m + 1):
        for b in range(m - a + 1):
            c = m - a - b
            stars = "★" * a + "│" + "★" * b + "│" + "★" * c
            monomial = ""
            parts = []
            if a > 0: parts.append(f"x^{a}" if a > 1 else "x")
            if b > 0: parts.append(f"y^{b}" if b > 1 else "y")
            if c > 0: parts.append(f"z^{c}" if c > 1 else "z")
            monomial = " · ".join(parts) if parts else "1"
            
            print(f"  ({a},{b},{c})  {stars:<12}  →  {monomial}")
            count += 1
    print(f"\nTotal: {count} monomials\n")


if __name__ == "__main__":
    print("\n" + "=" * 70)
    print("BOUNDED-DEGREE POLYNOMIAL DIMENSION FORMULA")
    print("Stars-and-Bars meets Multivariate Algebra")
    print("=" * 70 + "\n")
    
    verify_formula(max_n=4, max_d=6)
    print_monomial_table()
    print_homogeneous_table()
    hockey_stick_demo()
    stars_and_bars_visual()
    polynomial_feature_map_demo()
    reed_muller_demo()


#!/usr/bin/env python3
"""Generate visualizations for the bounded-degree polynomial dimension formula."""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import comb
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert a matplotlib figure to a base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def bounded_degree_dimension(n, d):
    if d == 0:
        return 0
    if n == 0:
        return 1
    return comb(d + n - 1, n)


def homogeneous_dimension(n, m):
    if n == 0:
        return 1 if m == 0 else 0
    return comb(m + n - 1, n - 1)


def plot_dimension_heatmap():
    """Create a heatmap of dimension C(d+n-1, n) as function of n and d."""
    fig, ax = plt.subplots(figsize=(10, 7))
    
    max_n, max_d = 12, 15
    data = np.zeros((max_n, max_d))
    for n in range(1, max_n + 1):
        for d in range(1, max_d + 1):
            data[n-1, d-1] = bounded_degree_dimension(n, d)
    
    # Use log scale for better visualization
    log_data = np.log10(data + 1)
    
    im = ax.imshow(log_data, cmap='YlOrRd', aspect='auto', origin='lower')
    
    # Add text annotations
    for i in range(max_n):
        for j in range(max_d):
            val = int(data[i, j])
            if val < 10000:
                text = str(val)
            else:
                text = f"{val:.0e}"
            fontsize = 7 if len(text) <= 4 else 5
            ax.text(j, i, text, ha='center', va='center', fontsize=fontsize)
    
    ax.set_xticks(range(max_d))
    ax.set_xticklabels(range(1, max_d + 1))
    ax.set_yticks(range(max_n))
    ax.set_yticklabels(range(1, max_n + 1))
    ax.set_xlabel('Degree bound d', fontsize=12)
    ax.set_ylabel('Number of variables n', fontsize=12)
    ax.set_title('Dimension of Bounded-Degree Polynomial Space\nC(d + n - 1, n)', fontsize=14)
    
    cbar = plt.colorbar(im, ax=ax, label='log₁₀(dimension)')
    
    return fig


def plot_growth_curves():
    """Plot dimension growth as a function of degree for various n."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left: linear scale
    max_d = 20
    for n in [1, 2, 3, 4, 5, 8, 10]:
        dims = [bounded_degree_dimension(n, d) for d in range(max_d + 1)]
        ax1.plot(range(max_d + 1), dims, 'o-', markersize=3, label=f'n={n}')
    
    ax1.set_xlabel('Degree bound d', fontsize=12)
    ax1.set_ylabel('Dimension', fontsize=12)
    ax1.set_title('Dimension Growth (Linear Scale)', fontsize=13)
    ax1.legend()
    ax1.grid(True, alpha=0.3)
    
    # Right: log scale
    max_d = 30
    for n in [1, 2, 3, 5, 10, 20]:
        dims = [bounded_degree_dimension(n, d) for d in range(1, max_d + 1)]
        ax2.semilogy(range(1, max_d + 1), dims, 'o-', markersize=3, label=f'n={n}')
    
    ax2.set_xlabel('Degree bound d', fontsize=12)
    ax2.set_ylabel('Dimension (log scale)', fontsize=12)
    ax2.set_title('Dimension Growth (Log Scale)', fontsize=13)
    ax2.legend()
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    return fig


def plot_homogeneous_components():
    """Visualize the decomposition into homogeneous components."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    n = 4  # 4 variables
    max_d = 12
    
    colors = plt.cm.viridis(np.linspace(0.1, 0.9, max_d))
    
    bottom = np.zeros(max_d)
    for m in range(max_d):
        heights = [homogeneous_dimension(n, m)] * max_d
        # Only show bar up to the right position
        actual_heights = [homogeneous_dimension(n, m) if d > m else 0 for d in range(max_d)]
        ax.bar(range(max_d), actual_heights, bottom=bottom, 
               color=colors[m], label=f'deg {m}', alpha=0.8, edgecolor='white', linewidth=0.5)
        bottom += actual_heights
    
    # Overlay the total dimension
    totals = [bounded_degree_dimension(n, d) for d in range(max_d)]
    ax.plot(range(max_d), totals, 'ko-', markersize=6, linewidth=2, label='Total dim')
    
    ax.set_xlabel('Degree bound d', fontsize=12)
    ax.set_ylabel('Dimension', fontsize=12)
    ax.set_title(f'Bounded-Degree Space Decomposition (n={n} variables)\n'
                 f'Stacked homogeneous components: C(d+{n}-1, {n})', fontsize=13)
    ax.legend(loc='upper left', ncol=2)
    ax.grid(True, alpha=0.3, axis='y')
    
    return fig


def plot_stars_and_bars():
    """Visualize the stars-and-bars bijection."""
    fig, axes = plt.subplots(2, 3, figsize=(15, 9))
    
    for idx, (n, m) in enumerate([(2, 3), (3, 2), (2, 4), (3, 3), (4, 2), (2, 5)]):
        ax = axes[idx // 3][idx % 3]
        
        # Generate all compositions
        compositions = []
        def gen(remaining_vars, remaining_sum, current):
            if remaining_vars == 0:
                compositions.append(tuple(current))
                return
            for e in range(remaining_sum + 1):
                current.append(e)
                gen(remaining_vars - 1, remaining_sum - e, current)
                current.pop()
        gen(n, m, [])
        
        # Plot as a grid
        count = len(compositions)
        expected = comb(m + n - 1, n - 1)
        
        cols = min(count, 8)
        rows = (count + cols - 1) // cols
        
        for i, comp in enumerate(compositions):
            row, col = i // cols, i % cols
            # Draw stars and bars
            x_pos = col * (m + n + 1)
            y_pos = (rows - 1 - row) * 2
            
            pos = 0
            for j, val in enumerate(comp):
                for _ in range(val):
                    ax.plot(x_pos + pos, y_pos, 'r*', markersize=10)
                    pos += 1
                if j < n - 1:
                    ax.plot([x_pos + pos - 0.5, x_pos + pos - 0.5], 
                            [y_pos - 0.5, y_pos + 0.5], 'b-', linewidth=2)
        
        ax.set_xlim(-1, cols * (m + n + 1))
        ax.set_ylim(-1, rows * 2)
        ax.set_aspect('equal')
        ax.set_title(f'n={n}, m={m}: {count} compositions\n'
                     f'= C({m+n-1}, {n-1}) = {expected}', fontsize=10)
        ax.axis('off')
    
    fig.suptitle('Stars-and-Bars: Weak Compositions\n'
                 '★ = units, | = dividers', fontsize=14, y=1.02)
    plt.tight_layout()
    return fig


def plot_hilbert_series():
    """Plot Hilbert function and cumulative dimension."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    
    max_m = 15
    
    for n in [1, 2, 3, 4, 5]:
        hf = [homogeneous_dimension(n, m) for m in range(max_m + 1)]
        ax1.plot(range(max_m + 1), hf, 'o-', markersize=4, label=f'n={n}')
    
    ax1.set_xlabel('Degree m', fontsize=12)
    ax1.set_ylabel('H(m) = dim of degree-m component', fontsize=12)
    ax1.set_title('Hilbert Function H(m) = C(m+n-1, n-1)', fontsize=13)
    ax1.legend()
    ax1.grid(True, alpha=0.3)
    
    # Cumulative = bounded degree dimension
    for n in [1, 2, 3, 4, 5]:
        cumul = [bounded_degree_dimension(n, d) for d in range(max_m + 2)]
        ax2.plot(range(max_m + 2), cumul, 'o-', markersize=4, label=f'n={n}')
    
    ax2.set_xlabel('Degree bound d', fontsize=12)
    ax2.set_ylabel('Cumulative dimension', fontsize=12)
    ax2.set_title('Cumulative: dim(deg < d) = C(d+n-1, n)', fontsize=13)
    ax2.legend()
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    return fig


def generate_all_visualizations():
    """Generate all visualizations and return as base64 data URIs."""
    results = {}
    
    print("Generating heatmap...")
    fig = plot_dimension_heatmap()
    results["dimension_heatmap"] = fig_to_base64(fig)
    fig.savefig("/workspace/request-project/dimension_heatmap.png", dpi=150, bbox_inches='tight')
    plt.close(fig)
    
    print("Generating growth curves...")
    fig = plot_growth_curves()
    results["growth_curves"] = fig_to_base64(fig)
    fig.savefig("/workspace/request-project/growth_curves.png", dpi=150, bbox_inches='tight')
    plt.close(fig)
    
    print("Generating homogeneous decomposition...")
    fig = plot_homogeneous_components()
    results["homogeneous_decomposition"] = fig_to_base64(fig)
    fig.savefig("/workspace/request-project/homogeneous_decomposition.png", dpi=150, bbox_inches='tight')
    plt.close(fig)
    
    print("Generating Hilbert series...")
    fig = plot_hilbert_series()
    results["hilbert_series"] = fig_to_base64(fig)
    fig.savefig("/workspace/request-project/hilbert_series.png", dpi=150, bbox_inches='tight')
    plt.close(fig)
    
    print("All visualizations generated.")
    return results


if __name__ == "__main__":
    results = generate_all_visualizations()
    for name, data in results.items():
        print(f"  {name}: {len(data)} chars")
