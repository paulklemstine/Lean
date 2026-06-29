#!/usr/bin/env python3
"""
Applications of the Cap Set Polynomial Method

Demonstrates real-world and cross-domain applications:
1. Coding theory: bounds on codes avoiding arithmetic progressions
2. Communication complexity: multiparty NOF lower bounds
3. Matrix multiplication: connections to tensor rank
4. Finite geometry: counting structures in affine/projective spaces
"""

import numpy as np
from itertools import product
from typing import List, Tuple, Dict
from algorithms import (
    count_monomials_by_degree,
    eg_bound,
    verify_cap_set,
    greedy_cap_set,
    cumulative_monomial_count
)


# ============================================================
# Application 1: Coding Theory
# ============================================================

def progression_free_code_bound(n: int, q: int = 3) -> Dict:
    """
    Bound on codes in F_q^n avoiding arithmetic progressions.

    A cap set is exactly a code in F_3^n with no three-term AP.
    The EG bound gives the maximum code size.

    In coding theory, this constrains:
    - Error-correcting codes with specific distance properties
    - Locally decodable codes
    - Codes with forbidden additive patterns
    """
    bound = eg_bound(n, q)
    total = q ** n
    rate = np.log2(bound) / n if bound > 0 else 0
    trivial_rate = np.log2(total) / n

    return {
        'n': n,
        'q': q,
        'max_codewords': bound,
        'alphabet_size': total,
        'rate_bits_per_symbol': rate,
        'trivial_rate': trivial_rate,
        'density': bound / total
    }


def code_rate_table(max_n: int = 15, q: int = 3):
    """Print a table of progression-free code rates."""
    print("Progression-Free Code Rate Bounds")
    print("=" * 60)
    print(f"{'n':>4} | {'Max words':>10} | {'Rate (bits/sym)':>15} | "
          f"{'Density':>10}")
    print("-" * 55)

    for n in range(1, max_n + 1):
        info = progression_free_code_bound(n, q)
        print(f"{info['n']:>4} | {info['max_codewords']:>10} | "
              f"{info['rate_bits_per_symbol']:>15.4f} | "
              f"{info['density']:>10.6f}")


# ============================================================
# Application 2: Sunflower-Free Sets
# ============================================================

def sunflower_free_bound(n: int, k: int = 3) -> int:
    """
    The cap set bound has implications for sunflower-free families.

    A k-sunflower is a collection of k sets whose pairwise intersections
    are all equal. The Erdős-Ko-Rado sunflower conjecture was resolved
    using polynomial method techniques related to cap sets.

    For k=3 (3-sunflower-free families in 2^[n]):
    The bound relates to cap sets via the "slice rank" method.

    Returns: upper bound on size of 3-sunflower-free family.
    """
    # The connection: a 3-sunflower-free family of subsets of [n]
    # can be encoded as a cap-like set in F_3^n.
    # The bound is essentially the same as the EG cap set bound.
    return eg_bound(n, 3)


# ============================================================
# Application 3: Matrix Multiplication Barriers
# ============================================================

def matrix_mult_barrier(n: int) -> Dict:
    """
    Connection to matrix multiplication complexity.

    The cap set bound implies barriers for certain approaches to
    fast matrix multiplication. Specifically:

    If the "simultaneous triple product property" (STPP) holds for
    a subset S of an abelian group G, then the support of S^3
    on the diagonal is bounded by the slice rank of a related tensor.

    The cap set bound shows that "large" STPP subsets cannot exist
    in F_3^n, limiting one approach to proving omega(matrix mult) = 2.

    The "cap set conjecture" (now theorem) implies:
    - The Coppersmith-Winograd approach cannot achieve omega = 2
      using the specific group structure of F_3^n.
    """
    bound = eg_bound(n, 3)
    total = 3 ** n

    # The STPP capacity is related to bound^3 / total
    stpp_capacity = (bound / total) ** 3

    return {
        'n': n,
        'cap_set_bound': bound,
        'universe_size': total,
        'density_bound': bound / total,
        'stpp_barrier': stpp_capacity,
        'omega_implication': 'CW approach limited' if n >= 6 else 'n too small'
    }


# ============================================================
# Application 4: Finite Geometry
# ============================================================

def affine_cap_analysis(n: int) -> Dict:
    """
    Analysis of caps in the affine geometry AG(n, 3).

    A cap in AG(n, 3) = F_3^n is a set of points no three of which
    are collinear. In F_3, collinearity of {a, b, c} means
    a + b + c = 0 (mod 3), so caps = cap sets.

    Key geometric invariants:
    - Cap number: maximum cap size
    - Cap density: cap number / |AG(n,3)|
    - Blocking number: minimum set meeting all lines
    """
    total = 3 ** n
    bound = eg_bound(n, 3)

    # Number of lines through a point in AG(n, 3)
    # Each line has 3 points. Lines through origin: (3^n - 1) / 2
    num_lines_per_point = (total - 1) // 2

    # Total number of lines in AG(n, 3)
    total_lines = total * num_lines_per_point // 3

    # Greedy lower bound
    if n <= 6:
        greedy = greedy_cap_set(n)
        lower = len(greedy)
    else:
        lower = None

    return {
        'n': n,
        'total_points': total,
        'total_lines': total_lines,
        'lines_per_point': num_lines_per_point,
        'upper_bound_EG': bound,
        'greedy_lower_bound': lower,
        'density_upper_bound': bound / total
    }


# ============================================================
# Application 5: Communication Complexity
# ============================================================

def nof_communication_bound(n: int) -> Dict:
    """
    Number-on-the-forehead (NOF) communication complexity bounds.

    In the NOF model with 3 players:
    - Player i sees all inputs EXCEPT player i's input
    - The cap set bound constrains the communication needed for
      certain "pattern-matching" functions

    Specifically, the function f(x,y,z) = [x+y+z = 0 in F_3^n]
    has NOF communication complexity related to cap set density.

    If players can solve f with c bits of communication,
    then the "monochromatic rectangle" partition has ≤ 2^c parts,
    and the size of the largest "1-rectangle" intersecting the
    diagonal is bounded by the cap set bound.
    """
    total = 3 ** n
    bound = eg_bound(n, 3)

    # Lower bound on communication
    comm_lower = max(1, int(np.ceil(np.log2(total / bound)))) if bound > 0 else n

    return {
        'n': n,
        'input_size': n * int(np.ceil(np.log2(3))),  # bits
        'cap_set_bound': bound,
        'comm_lower_bound_bits': comm_lower,
        'trivial_comm_upper': n * 2,  # trivially n * log(3) bits
    }


# ============================================================
# Main: Run all applications
# ============================================================

if __name__ == "__main__":
    print("Cap Set Polynomial Method - Applications")
    print("=" * 60)
    print()

    # Application 1: Coding theory
    print("APPLICATION 1: Progression-Free Codes")
    print("-" * 40)
    code_rate_table(12)
    print()

    # Application 2: Sunflower bounds
    print("APPLICATION 2: Sunflower-Free Set Bounds")
    print("-" * 40)
    for n in range(1, 10):
        b = sunflower_free_bound(n)
        print(f"  n={n}: 3-sunflower-free bound = {b} "
              f"(vs 2^{n} = {2**n} total subsets)")
    print()

    # Application 3: Matrix multiplication
    print("APPLICATION 3: Matrix Multiplication Barriers")
    print("-" * 40)
    for n in range(3, 10):
        info = matrix_mult_barrier(n)
        print(f"  n={n}: density = {info['density_bound']:.4f}, "
              f"STPP barrier = {info['stpp_barrier']:.6f}")
    print()

    # Application 4: Finite geometry
    print("APPLICATION 4: Caps in Affine Geometry AG(n,3)")
    print("-" * 40)
    print(f"  {'n':>3} | {'Points':>8} | {'Lines':>10} | "
          f"{'EG upper':>10} | {'Greedy':>8} | {'Density':>8}")
    print("  " + "-" * 58)
    for n in range(1, 7):
        info = affine_cap_analysis(n)
        lb = info['greedy_lower_bound'] if info['greedy_lower_bound'] else "?"
        print(f"  {n:>3} | {info['total_points']:>8} | "
              f"{info['total_lines']:>10} | "
              f"{info['upper_bound_EG']:>10} | {str(lb):>8} | "
              f"{info['density_upper_bound']:>8.4f}")
    print()

    # Application 5: Communication complexity
    print("APPLICATION 5: NOF Communication Complexity")
    print("-" * 40)
    for n in range(1, 10):
        info = nof_communication_bound(n)
        print(f"  n={n}: comm lower bound = {info['comm_lower_bound_bits']} bits "
              f"(vs trivial upper = {info['trivial_comm_upper']} bits)")


#!/usr/bin/env python3
"""Build the PACKAGE.json file with all deliverables."""

import json
import os


def read_file(path):
    with open(path, 'r') as f:
        return f.read()


def main():
    # Read all content
    article = read_file('ARTICLE.md')
    research_paper = read_file('RESEARCH_PAPER.md')
    future_directions = read_file('FUTURE_DIRECTIONS.md')
    demo_code = read_file('demo.py')
    algorithms_code = read_file('algorithms.py')
    applications_code = read_file('applications.py')
    lean_code = read_file('Catalog/Algebra/AdditiveCombinatorics/CapSet.lean')

    # Read visualization data
    with open('viz_data.json', 'r') as f:
        viz_data = json.load(f)

    package = {
        "title": "Cap Set Polynomial Method: Dimension-Theoretic Foundations",
        "domain": "Additive Combinatorics / Polynomial Method",
        "article": article,
        "research_paper": research_paper,
        "future_directions": future_directions,
        "demos": [
            {
                "name": "Cap Set Polynomial Method Demo",
                "code": demo_code
            },
            {
                "name": "Applications of Cap Set Bounds",
                "code": applications_code
            }
        ],
        "algorithms": [
            {
                "name": "Cap Set Verification",
                "pseudocode": """
Algorithm: VerifyCapSet(A, n)
Input: Set A ⊆ F_3^n, dimension n
Output: True if A is a cap set, False otherwise

1. Build hash set S from A
2. For each x in A:
3.   For each y in A:
4.     Compute z = -(x+y) mod 3
5.     If z in S and not (x = y = z):
6.       Return False
7. Return True

Time: O(|A|^2 · n)
Space: O(|A|)
""",
                "code": algorithms_code
            },
            {
                "name": "Monomial Counting via Dynamic Programming",
                "pseudocode": """
Algorithm: CountMonomials(n, q)
Input: Number of variables n, field size q
Output: Array c where c[k] = #{m in {0,...,q-1}^n : sum(m) = k}

1. Initialize dp[0] = 1, dp[k] = 0 for k > 0
2. For i = 1 to n:
3.   For k = max_degree down to 0:
4.     new_dp[k] = sum(dp[k-j] for j in {0,...,q-1})
5.   dp = new_dp
6. Return dp

Time: O(n · q · n)
Space: O(q · n)
""",
                "code": algorithms_code
            },
            {
                "name": "EG Bound Computation",
                "pseudocode": """
Algorithm: EGBound(n, q=3)
Input: Dimension n, field size q
Output: Upper bound on cap set size

1. d = floor((q-1)*n / q)
2. Compute D(d) = sum of CountMonomials(n,q)[0..d]
3. Return q * D(d)

Time: O(n^2 · q)
Space: O(n · q)
""",
                "code": algorithms_code
            }
        ],
        "visualizations": [
            {
                "name": "Cap Set Density Decay with Dimension",
                "data": viz_data['density_decay']
            },
            {
                "name": "Trinomial Coefficient Distribution",
                "data": viz_data['trinomial']
            },
            {
                "name": "Kernel Matrix Identity on Cap Sets",
                "data": viz_data['kernel_matrix']
            },
            {
                "name": "Exponential Base Convergence",
                "data": viz_data['base_convergence']
            },
            {
                "name": "Cap Sets in F_3^2",
                "data": viz_data['cap_set_f3_2']
            }
        ],
        "lean_proofs": lean_code
    }

    with open('PACKAGE.json', 'w') as f:
        json.dump(package, f, ensure_ascii=False)

    print(f"PACKAGE.json created ({os.path.getsize('PACKAGE.json')} bytes)")


if __name__ == '__main__':
    main()


#!/usr/bin/env python3
"""
Cap Set Polynomial Method: Interactive Demonstrations

Demonstrates the key mathematical ideas behind the Ellenberg-Gijswijt cap set bound:
1. The Kronecker delta polynomial over F_3^n
2. Cap set detection and enumeration
3. The kernel matrix M(a,b) = sum_c Delta(a+b+c)
4. Monomial counting and the EG bound
5. Comparison of bounds across dimensions
"""

import numpy as np
from itertools import product
from typing import List, Tuple, Set
import sys


def F3(x: int) -> int:
    """Reduce to F_3 = {0, 1, 2}."""
    return x % 3


def F3_vec(v: np.ndarray) -> np.ndarray:
    """Reduce a vector modulo 3."""
    return v % 3


def delta_indicator(v: np.ndarray) -> int:
    """
    Kronecker delta polynomial: Delta(v) = prod_i (1 - v_i^2) over F_3.
    Returns 1 if v = 0 (mod 3), 0 otherwise.

    This is the fundamental building block of the polynomial method.
    """
    result = 1
    for vi in v:
        result = F3(result * F3(1 - F3(vi * vi)))
    return result


def is_cap_set(A: List[Tuple[int, ...]], n: int) -> bool:
    """
    Check if A is a cap set in F_3^n.
    A is a cap set iff for all x, y, z in A with x+y+z = 0 (mod 3),
    we have x = y = z.
    """
    A_set = set(A)
    for x in A:
        for y in A:
            # z must be -(x+y) mod 3
            z = tuple((3 - x[i] - y[i]) % 3 for i in range(n))
            if z in A_set:
                if not (x == y == z):
                    return False
    return True


def enumerate_F3n(n: int) -> List[Tuple[int, ...]]:
    """Enumerate all elements of F_3^n."""
    return list(product(range(3), repeat=n))


def find_max_cap_set(n: int) -> List[Tuple[int, ...]]:
    """
    Find a maximum cap set in F_3^n by brute force.
    Only feasible for small n (n <= 4).
    """
    all_points = enumerate_F3n(n)
    best = []

    def backtrack(idx: int, current: List[Tuple[int, ...]]):
        nonlocal best
        if len(current) > len(best):
            best = current[:]
        for i in range(idx, len(all_points)):
            candidate = current + [all_points[i]]
            if is_cap_set(candidate, n):
                backtrack(i + 1, candidate)

    backtrack(0, [])
    return best


def kernel_matrix(A: List[Tuple[int, ...]], n: int) -> np.ndarray:
    """
    Compute the kernel matrix M(a,b) = sum_{c in A} Delta(a + b + c)
    for a, b in A. On a cap set, this should be the identity matrix.
    """
    m = len(A)
    M = np.zeros((m, m), dtype=int)
    for i, a in enumerate(A):
        for j, b in enumerate(A):
            total = 0
            for c in A:
                v = np.array([(a[k] + b[k] + c[k]) % 3 for k in range(n)])
                total = F3(total + delta_indicator(v))
            M[i, j] = total
    return M


def count_low_deg_monomials(n: int, d: int) -> int:
    """
    Count the number of reduced monomials in n variables with
    each exponent in {0, 1, 2} and total degree <= d.

    This is D(d) = |{m in {0,1,2}^n : sum(m) <= d}|.
    """
    count = 0
    for m in product(range(3), repeat=n):
        if sum(m) <= d:
            count += 1
    return count


def eg_bound(n: int) -> int:
    """
    Compute the Ellenberg-Gijswijt bound: 3 * D(floor(2n/3)).
    """
    d = (2 * n) // 3
    return 3 * count_low_deg_monomials(n, d)


def trinomial_coefficients(n: int) -> List[int]:
    """
    Compute coefficients of (1 + x + x^2)^n.
    The k-th coefficient counts the number of n-tuples in {0,1,2}^n
    with sum exactly k.
    """
    # Dynamic programming
    coeffs = [0] * (2 * n + 1)
    coeffs[0] = 1

    for _ in range(n):
        new_coeffs = [0] * (2 * n + 1)
        for k in range(2 * n + 1):
            for j in range(3):
                if k - j >= 0:
                    new_coeffs[k] += coeffs[k - j]
        coeffs = new_coeffs

    return coeffs


# ============================================================
# DEMONSTRATIONS
# ============================================================

def demo_delta_indicator():
    """Demonstrate the Kronecker delta polynomial."""
    print("=" * 60)
    print("DEMO 1: Kronecker Delta Polynomial over F_3^n")
    print("=" * 60)
    print()
    print("Delta(v) = prod_i (1 - v_i^2) over F_3")
    print("This equals 1 at v=0 and 0 everywhere else.")
    print()

    for n in range(1, 4):
        print(f"--- F_3^{n} ---")
        for v in enumerate_F3n(n):
            val = delta_indicator(np.array(v))
            if val == 1:
                print(f"  Delta{v} = {val}  <-- zero vector detected!")
            else:
                # Only print a few non-zero examples
                if sum(v) <= 1:
                    print(f"  Delta{v} = {val}")
        print()


def demo_cap_sets():
    """Demonstrate cap set detection and enumeration."""
    print("=" * 60)
    print("DEMO 2: Cap Sets in F_3^n")
    print("=" * 60)
    print()
    print("A cap set has no three elements summing to zero (mod 3)")
    print("unless all three are equal.")
    print()

    for n in range(1, 5):
        total = 3 ** n
        print(f"--- F_3^{n} (total: {total} points) ---")

        if n <= 3:
            cap = find_max_cap_set(n)
            print(f"  Maximum cap set size: {len(cap)}")
            if n <= 2:
                print(f"  Example: {cap}")
            print(f"  Is valid cap set: {is_cap_set(cap, n)}")
        else:
            print(f"  (Brute force too slow for n={n})")

        # EG bound
        d = (2 * n) // 3
        D = count_low_deg_monomials(n, d)
        bound = 3 * D
        print(f"  EG bound: |A| <= 3 * D({d}) = 3 * {D} = {bound}")
        print(f"  Trivial bound: |A| <= 3^{n} = {total}")
        if bound < total:
            print(f"  ** EG improves trivial by factor {total/bound:.2f} **")
        print()


def demo_kernel_matrix():
    """Demonstrate the kernel matrix identity on cap sets."""
    print("=" * 60)
    print("DEMO 3: Kernel Matrix M(a,b) = sum_c Delta(a+b+c)")
    print("=" * 60)
    print()
    print("On a cap set A, M should be the identity matrix.")
    print("This is the STRUCTURAL HEART of the EG argument.")
    print()

    for n in range(1, 4):
        print(f"--- F_3^{n} ---")
        # Use a known cap set
        all_pts = enumerate_F3n(n)

        # Find a reasonably large cap set
        if n == 1:
            A = [(0,), (1,)]
        elif n == 2:
            A = [(0, 0), (0, 1), (1, 0), (1, 1)]
        elif n == 3:
            # Find a cap set in F_3^3 by greedy construction
            from algorithms import greedy_cap_set as _gcs
            A = _gcs(3)

        valid = is_cap_set(A, n)
        print(f"  Cap set A has {len(A)} elements (valid: {valid})")

        if valid:
            M = kernel_matrix(A, n)
            is_identity = np.array_equal(M, np.eye(len(A), dtype=int))
            print(f"  Kernel matrix M = Identity? {is_identity}")
            if len(A) <= 6:
                print(f"  M =")
                for row in M:
                    print(f"    {list(row)}")
        print()


def demo_monomial_counting():
    """Demonstrate monomial counting and the generating function."""
    print("=" * 60)
    print("DEMO 4: Monomial Counting and Trinomial Coefficients")
    print("=" * 60)
    print()
    print("D(d) = |{m in {0,1,2}^n : sum(m) <= d}|")
    print("These are coefficients of (1+x+x^2)^n")
    print()

    for n in range(1, 9):
        coeffs = trinomial_coefficients(n)
        total = sum(coeffs)
        d = (2 * n) // 3

        D_d = sum(coeffs[:d + 1])
        bound = 3 * D_d
        trivial = 3 ** n
        ratio = bound / trivial if trivial > 0 else float('inf')

        print(f"n={n}: D({d}) = {D_d}, "
              f"3*D = {bound}, "
              f"3^n = {trivial}, "
              f"ratio = {ratio:.4f}")

    print()
    print("As n grows, the ratio 3*D(2n/3) / 3^n -> 0 exponentially!")
    print("This proves cap sets have exponentially small density.")


def demo_degree_splitting():
    """Demonstrate the degree splitting lemma."""
    print()
    print("=" * 60)
    print("DEMO 5: Degree Splitting Lemma")
    print("=" * 60)
    print()
    print("If a + b + c <= 2n, then min(a, b, c) <= floor(2n/3).")
    print("This is the combinatorial engine of the EG bound.")
    print()

    for n in range(1, 6):
        threshold = (2 * n) // 3
        print(f"n={n}: threshold = floor(2*{n}/3) = {threshold}")

        # Check all triples
        violations = 0
        total = 0
        for a in range(2 * n + 1):
            for b in range(2 * n + 1 - a):
                for c in range(2 * n + 1 - a - b):
                    total += 1
                    if min(a, b, c) > threshold:
                        violations += 1

        print(f"  Checked {total} triples with a+b+c <= {2*n}: "
              f"{violations} violations (should be 0)")


def demo_bound_comparison():
    """Compare bounds across dimensions."""
    print()
    print("=" * 60)
    print("DEMO 6: Bound Comparison Table")
    print("=" * 60)
    print()
    print(f"{'n':>3} | {'3^n':>10} | {'EG bound':>10} | {'Ratio':>8} | {'Known max':>10}")
    print("-" * 55)

    known_max = {1: 2, 2: 4, 3: 9, 4: 20, 5: 45, 6: 112}

    for n in range(1, 13):
        trivial = 3 ** n
        bound = eg_bound(n)
        ratio = bound / trivial
        km = known_max.get(n, "?")
        print(f"{n:>3} | {trivial:>10} | {bound:>10} | {ratio:>8.4f} | {str(km):>10}")


if __name__ == "__main__":
    demo_delta_indicator()
    demo_cap_sets()
    demo_kernel_matrix()
    demo_monomial_counting()
    demo_degree_splitting()
    demo_bound_comparison()


#!/usr/bin/env python3
"""
Visualizations for the Cap Set Polynomial Method

Generates charts showing:
1. Cap set density decay with dimension
2. Monomial distribution (trinomial coefficients)
3. Kernel matrix structure
4. EG bound vs trivial bound comparison
5. Effective exponential base convergence
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product
import base64
import io
from algorithms import (
    count_monomials_by_degree,
    eg_bound,
    greedy_cap_set,
    verify_cap_set,
    cumulative_monomial_count,
    build_kernel_matrix,
    exponential_base
)


def save_fig_base64(fig) -> str:
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def plot_density_decay(max_n: int = 20) -> str:
    """Plot how cap set density decays with dimension."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    ns = list(range(1, max_n + 1))
    bounds = [eg_bound(n) for n in ns]
    trivials = [3 ** n for n in ns]
    densities = [b / t for b, t in zip(bounds, trivials)]

    # Left: absolute bounds on log scale
    ax1.semilogy(ns, trivials, 'b-o', label='Trivial bound (3ⁿ)', markersize=4)
    ax1.semilogy(ns, bounds, 'r-s', label='EG bound (3·D₀)', markersize=4)
    ax1.set_xlabel('Dimension n', fontsize=12)
    ax1.set_ylabel('Maximum cap set size', fontsize=12)
    ax1.set_title('Cap Set Bounds: Trivial vs. Ellenberg–Gijswijt', fontsize=13)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    # Right: density ratio
    ax2.semilogy(ns, densities, 'g-^', markersize=5, color='#2ca02c')
    ax2.axhline(y=1, color='gray', linestyle='--', alpha=0.5)
    ax2.set_xlabel('Dimension n', fontsize=12)
    ax2.set_ylabel('EG bound / 3ⁿ', fontsize=12)
    ax2.set_title('Cap Set Density Decay', fontsize=13)
    ax2.grid(True, alpha=0.3)

    # Add annotation
    ax2.annotate('Exponential decay →\nCap sets are sparse!',
                 xy=(max_n * 0.6, densities[int(max_n * 0.6)]),
                 fontsize=10, color='#2ca02c',
                 arrowprops=dict(arrowstyle='->', color='#2ca02c'),
                 xytext=(max_n * 0.3, densities[2]))

    fig.tight_layout()
    return save_fig_base64(fig)


def plot_trinomial_distribution(ns: list = [3, 6, 9, 12]) -> str:
    """Plot trinomial coefficient distributions for various n."""
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728']

    for idx, n in enumerate(ns):
        ax = axes[idx // 2, idx % 2]
        coeffs = count_monomials_by_degree(n)
        degrees = list(range(len(coeffs)))
        d_threshold = (2 * n) // 3

        # Split into low-degree (blue) and high-degree (gray)
        low_deg = [c if k <= d_threshold else 0 for k, c in enumerate(coeffs)]
        high_deg = [c if k > d_threshold else 0 for k, c in enumerate(coeffs)]

        ax.bar(degrees, low_deg, color=colors[idx], alpha=0.8,
               label=f'Degree ≤ {d_threshold} (counted)')
        ax.bar(degrees, high_deg, color='lightgray', alpha=0.6,
               label=f'Degree > {d_threshold}')

        ax.axvline(x=d_threshold + 0.5, color='red', linestyle='--',
                   linewidth=1.5, label=f'Threshold ⌊2n/3⌋ = {d_threshold}')
        ax.axvline(x=n, color='black', linestyle=':', alpha=0.5,
                   label=f'Mean = {n}')

        D_d = sum(coeffs[:d_threshold + 1])
        total = sum(coeffs)
        ax.set_title(f'n = {n}: D({d_threshold}) = {D_d} / {total} '
                     f'({100*D_d/total:.1f}%)', fontsize=11)
        ax.set_xlabel('Total degree')
        ax.set_ylabel('Count')
        ax.legend(fontsize=8)

    fig.suptitle('Trinomial Coefficients: (1 + x + x²)ⁿ', fontsize=14, y=1.02)
    fig.tight_layout()
    return save_fig_base64(fig)


def plot_kernel_matrix() -> str:
    """Plot kernel matrices for small cap sets."""
    fig, axes = plt.subplots(1, 3, figsize=(14, 4))

    cap_sets = {
        1: [(0,), (1,)],
        2: [(0, 0), (0, 1), (1, 0), (1, 1)],
        3: greedy_cap_set(3)
    }

    for idx, (n, A) in enumerate(cap_sets.items()):
        ax = axes[idx]
        M = build_kernel_matrix(A, n)

        im = ax.imshow(M, cmap='Blues', vmin=0, vmax=2, aspect='equal')
        ax.set_title(f'F₃^{n}: |A| = {len(A)}', fontsize=12)
        ax.set_xlabel('Column index (b)')
        ax.set_ylabel('Row index (a)')

        # Add text annotations
        for i in range(len(A)):
            for j in range(len(A)):
                color = 'white' if M[i, j] > 0.5 else 'black'
                ax.text(j, i, str(M[i, j]), ha='center', va='center',
                        fontsize=8, color=color)

    fig.suptitle('Kernel Matrix M(a,b) = Σ_c Δ(a+b+c) on Cap Sets',
                 fontsize=13)
    fig.colorbar(im, ax=axes, shrink=0.8, label='Value (mod 3)')
    fig.tight_layout()
    return save_fig_base64(fig)


def plot_base_convergence(max_n: int = 30) -> str:
    """Plot convergence of the effective exponential base."""
    fig, ax = plt.subplots(figsize=(10, 6))

    ns = list(range(2, max_n + 1))
    bases = [exponential_base(n) for n in ns]

    ax.plot(ns, bases, 'b-o', markersize=3, label='Effective base c_n')

    # Theoretical limit
    c_theory = 3 * 2 ** (2 / 3) / 3 ** (1 / 3)
    ax.axhline(y=c_theory, color='red', linestyle='--',
               label=f'Theoretical limit ≈ {c_theory:.4f}')
    ax.axhline(y=3, color='gray', linestyle=':', alpha=0.5,
               label='Trivial base = 3')

    ax.set_xlabel('Dimension n', fontsize=12)
    ax.set_ylabel('Effective exponential base', fontsize=12)
    ax.set_title('Convergence of EG Bound Base: 3·D(2n/3)^{1/n}', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_ylim([2.5, 3.5])

    # Annotation
    ax.annotate(f'Cap sets grow as O({c_theory:.3f}ⁿ)\n'
                f'Much slower than 3ⁿ!',
                xy=(max_n * 0.7, c_theory + 0.05),
                fontsize=10, color='red')

    fig.tight_layout()
    return save_fig_base64(fig)


def plot_cap_set_f3_squared() -> str:
    """Visualize cap sets in F_3^2."""
    fig, axes = plt.subplots(1, 3, figsize=(14, 4.5))

    # All 9 points of F_3^2
    all_points = [(x, y) for x in range(3) for y in range(3)]

    # Three example cap sets
    examples = [
        ("Maximum cap (size 4)", [(0, 0), (0, 1), (1, 0), (1, 1)]),
        ("Another cap (size 4)", [(0, 0), (0, 2), (2, 0), (2, 2)]),
        ("NOT a cap (size 5)", [(0, 0), (0, 1), (0, 2), (1, 0), (2, 0)])
    ]

    for idx, (title, cap) in enumerate(examples):
        ax = axes[idx]
        cap_set = set(cap)
        is_valid = verify_cap_set(cap, 2)[0]

        # Draw grid
        for x in range(3):
            for y in range(3):
                if (x, y) in cap_set:
                    ax.plot(x, y, 'o', markersize=20,
                            color='#2ca02c' if is_valid else '#d62728',
                            zorder=5)
                else:
                    ax.plot(x, y, 'o', markersize=8, color='lightgray',
                            zorder=3)

        # Draw lines (triples summing to 0)
        for a in all_points:
            for b in all_points:
                c = ((3 - a[0] - b[0]) % 3, (3 - a[1] - b[1]) % 3)
                if a <= b <= c:
                    if not (a == b == c):
                        # Check if all three in cap
                        if {a, b, c}.issubset(cap_set):
                            ax.plot([a[0], b[0], c[0], a[0]],
                                    [a[1], b[1], c[1], a[1]],
                                    'r-', linewidth=2, alpha=0.5)

        ax.set_xlim(-0.5, 2.5)
        ax.set_ylim(-0.5, 2.5)
        ax.set_xticks(range(3))
        ax.set_yticks(range(3))
        ax.set_aspect('equal')
        status = "✓ Valid" if is_valid else "✗ Invalid"
        ax.set_title(f'{title}\n{status}', fontsize=11)
        ax.grid(True, alpha=0.2)

    fig.suptitle('Cap Sets in F₃²: Points No Three Collinear', fontsize=14)
    fig.tight_layout()
    return save_fig_base64(fig)


def generate_all_visualizations() -> dict:
    """Generate all visualizations and return as dict."""
    print("Generating visualizations...")

    viz = {}
    print("  1. Density decay plot...")
    viz['density_decay'] = plot_density_decay()

    print("  2. Trinomial distribution...")
    viz['trinomial'] = plot_trinomial_distribution()

    print("  3. Kernel matrices...")
    viz['kernel_matrix'] = plot_kernel_matrix()

    print("  4. Base convergence...")
    viz['base_convergence'] = plot_base_convergence()

    print("  5. F_3^2 cap sets...")
    viz['cap_set_f3_2'] = plot_cap_set_f3_squared()

    print("Done!")
    return viz


if __name__ == "__main__":
    viz = generate_all_visualizations()
    # Save as PNG files
    for name, data_uri in viz.items():
        # Extract base64 data
        b64_data = data_uri.split(',')[1]
        img_data = base64.b64decode(b64_data)
        filename = f"{name}.png"
        with open(filename, 'wb') as f:
            f.write(img_data)
        print(f"Saved {filename}")
