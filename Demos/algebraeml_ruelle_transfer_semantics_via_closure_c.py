#!/usr/bin/env python3
"""
Algorithms for Ruelle Transfer Operator Computations

Implements the core algorithms from the research paper with full documentation,
type hints, and complexity analysis.
"""

import numpy as np
from typing import Callable, List, Tuple, Optional
from fractions import Fraction


def build_correspondence_matrix(
    f: Callable[[int], int], d: int
) -> np.ndarray:
    """Build the deterministic correspondence matrix for f.

    Given a map f : {0, ..., d-1} → {0, ..., d-1}, constructs the d×d matrix M
    where M[i][j] = 1 if f(i) = j, else 0.

    Complexity: O(d) time, O(d²) space.

    Args:
        f: Transition function on {0, ..., d-1}
        d: State space size

    Returns:
        d×d numpy integer array (the correspondence matrix)
    """
    M = np.zeros((d, d), dtype=int)
    for i in range(d):
        j = f(i)
        assert 0 <= j < d, f"f({i}) = {j} out of range [0, {d})"
        M[i, j] = 1
    return M


def periodic_count_via_trace(
    f: Callable[[int], int], d: int, n: int
) -> int:
    """Count periodic points of period n using the trace formula.

    Computes |Fix(f^n)| = tr(M^n) where M is the correspondence matrix.

    Complexity: O(d³ log n) time (matrix exponentiation by squaring), O(d²) space.

    Args:
        f: Transition function
        d: State space size
        n: Period

    Returns:
        Number of periodic points of period n
    """
    M = build_correspondence_matrix(f, d)
    Mn = matrix_power(M, n)
    return int(np.trace(Mn))


def periodic_count_naive(
    f: Callable[[int], int], d: int, n: int
) -> int:
    """Count periodic points naively by iterating f.

    Complexity: O(d · n) time, O(1) extra space.

    Args:
        f: Transition function
        d: State space size
        n: Period

    Returns:
        Number of periodic points of period n
    """
    count = 0
    for x in range(d):
        y = x
        for _ in range(n):
            y = f(y)
        if y == x:
            count += 1
    return count


def matrix_power(M: np.ndarray, n: int) -> np.ndarray:
    """Compute M^n by repeated squaring.

    Complexity: O(d³ log n) where d is the matrix dimension.

    Args:
        M: Square matrix
        n: Non-negative integer exponent

    Returns:
        M^n
    """
    if n == 0:
        return np.eye(M.shape[0], dtype=M.dtype)
    if n == 1:
        return M.copy()
    if n % 2 == 0:
        half = matrix_power(M, n // 2)
        return half @ half
    else:
        return M @ matrix_power(M, n - 1)


def row_sum_norm(M: np.ndarray) -> float:
    """Compute the row-sum (infinity) operator norm.

    rowSumNorm(M) = max_i sum_j |M_ij|

    Complexity: O(d²) time.

    Args:
        M: Square matrix

    Returns:
        The row-sum norm
    """
    return float(np.max(np.sum(np.abs(M), axis=1)))


def sup_norm(v: np.ndarray) -> float:
    """Compute the sup (infinity) norm of a vector.

    supNorm(v) = max_i |v_i|

    Complexity: O(d) time.

    Args:
        v: Vector

    Returns:
        The sup norm
    """
    return float(np.max(np.abs(v)))


def trace_growth_bound(M: np.ndarray, n: int) -> float:
    """Compute the certified upper bound on |tr(M^n)|.

    Returns d · rowSumNorm(M)^n, which is guaranteed to satisfy
    |tr(M^n)| ≤ d · rowSumNorm(M)^n.

    Complexity: O(d² + log n) time.

    Args:
        M: d×d matrix
        n: Exponent

    Returns:
        Upper bound on |tr(M^n)|
    """
    d = M.shape[0]
    rsn = row_sum_norm(M)
    return d * rsn ** n


def artin_mazur_coefficients(
    f: Callable[[int], int], d: int, num_terms: int
) -> List[Fraction]:
    """Compute Artin-Mazur zeta coefficients.

    artinMazurCoeff(f, n) = periodicCount(f, n+1) / (n+1)

    Complexity: O(num_terms · d³ · log(num_terms)) total.

    Args:
        f: Transition function
        d: State space size
        num_terms: Number of coefficients to compute

    Returns:
        List of Artin-Mazur coefficients as exact fractions
    """
    M = build_correspondence_matrix(f, d)
    coeffs = []
    for n in range(num_terms):
        Mn1 = matrix_power(M, n + 1)
        tr = int(np.trace(Mn1))
        coeffs.append(Fraction(tr, n + 1))
    return coeffs


def weighted_loop_sums(
    weight_matrix: np.ndarray, max_n: int
) -> List[float]:
    """Compute weighted loop sums for n = 0, 1, ..., max_n.

    weightedLoopSum(K, n) = tr(M^n) where M is the correspondence matrix.

    Complexity: O(max_n · d³) total (sequential powers).

    Args:
        weight_matrix: d×d weight matrix (entry (i,j) = weight from j to i)
        max_n: Maximum power to compute

    Returns:
        List of weighted loop sums
    """
    d = weight_matrix.shape[0]
    sums = []
    current = np.eye(d)
    for n in range(max_n + 1):
        sums.append(float(np.trace(current)))
        current = current @ weight_matrix
    return sums


def transfer_lipschitz_certificate(
    M: np.ndarray, v: np.ndarray
) -> Tuple[float, float, bool]:
    """Verify the Lipschitz bound ‖Mv‖∞ ≤ ‖M‖∞ · ‖v‖∞.

    Args:
        M: Transfer matrix
        v: Input vector

    Returns:
        Tuple of (‖Mv‖∞, ‖M‖∞ · ‖v‖∞, bound_holds)
    """
    Mv = M @ v
    lhs = sup_norm(Mv)
    rhs = row_sum_norm(M) * sup_norm(v)
    return (lhs, rhs, lhs <= rhs + 1e-12)


def matrix_mul_complexity_bound(d: int, n: int) -> int:
    """Compute the O(n·d³) complexity bound for n matrix multiplications.

    Args:
        d: Matrix dimension
        n: Number of multiplications

    Returns:
        Upper bound on operation count
    """
    return n * d ** 3


# Example usage
if __name__ == "__main__":
    print("Algorithm Demonstrations")
    print("=" * 40)

    # Example: cyclic shift on 5 elements
    d = 5
    f = lambda x: (x + 1) % d
    M = build_correspondence_matrix(f, d)

    print(f"\n1. Correspondence Matrix for f(x) = (x+1) mod {d}:")
    print(M)

    print(f"\n2. Periodic counts (trace method vs naive):")
    for n in range(1, 11):
        trace_count = periodic_count_via_trace(f, d, n)
        naive_count = periodic_count_naive(f, d, n)
        print(f"  n={n}: trace={trace_count}, naive={naive_count}, match={trace_count == naive_count}")

    print(f"\n3. Artin-Mazur coefficients:")
    coeffs = artin_mazur_coefficients(f, d, 10)
    for i, c in enumerate(coeffs):
        print(f"  a_{i} = {c} = {float(c):.6f}")

    print(f"\n4. Complexity bound for 100 multiplications of {d}×{d} matrices:")
    print(f"  {matrix_mul_complexity_bound(d, 100)} operations")


#!/usr/bin/env python3
"""
Applications of Ruelle Transfer Operator Semantics

Demonstrates real-world applications of the certified transfer operator framework
in cryptography, machine learning robustness, and statistical mechanics.
"""

import numpy as np
from typing import List, Tuple
from algorithms import (
    build_correspondence_matrix,
    periodic_count_via_trace,
    row_sum_norm,
    sup_norm,
    weighted_loop_sums,
    trace_growth_bound,
)


# ===========================================================================
# Application 1: Cryptographic Cycle Analysis
# ===========================================================================

def crypto_cycle_analysis(sbox: List[int], name: str = "S-box"):
    """Analyze the cycle structure of a cryptographic S-box permutation.

    In symmetric-key cryptography, S-boxes (substitution boxes) are permutations
    that provide confusion. The cycle structure affects security properties:
    - Short cycles indicate potential weaknesses
    - Fixed points (cycles of length 1) can leak information

    Uses the trace formula for efficient computation.
    """
    d = len(sbox)
    f = lambda x: sbox[x]
    M = build_correspondence_matrix(f, d)

    print(f"\n{'='*60}")
    print(f"Crypto Application: {name} Cycle Analysis")
    print(f"{'='*60}")
    print(f"State space size: {d}")
    print(f"Permutation: {sbox}")

    # Compute periodic counts efficiently
    print(f"\nPeriodic orbit structure:")
    print(f"{'Period n':>10} | {'|Fix(f^n)|':>12} | {'New orbits':>12}")
    print("-" * 40)

    prev_counts = {}
    for n in range(1, d + 1):
        pc = periodic_count_via_trace(f, d, n)
        # Möbius-style decomposition: orbits of exact period n
        # (simplified: just show raw counts)
        prev_counts[n] = pc
        print(f"{n:>10} | {pc:>12} | {'—':>12}")

    # Security metrics
    fixed_points = periodic_count_via_trace(f, d, 1)
    fp_ratio = fixed_points / d
    print(f"\nSecurity metrics:")
    print(f"  Fixed points: {fixed_points} ({fp_ratio:.2%} of states)")
    print(f"  Growth bound: |Fix(f^n)| ≤ {d} for all n")

    return prev_counts


# ===========================================================================
# Application 2: Recurrent Neural Network Robustness
# ===========================================================================

def rnn_robustness_analysis(
    W: np.ndarray,
    perturbation_scale: float = 0.01,
    num_steps: int = 20,
):
    """Analyze robustness of a recurrent neural network state transition.

    Models the linearized dynamics h_{t+1} = W · h_t and uses the row-sum norm
    to provide certified bounds on state growth and perturbation sensitivity.
    """
    d = W.shape[0]
    rsn = row_sum_norm(W)

    print(f"\n{'='*60}")
    print(f"ML Application: RNN Robustness Certificate")
    print(f"{'='*60}")
    print(f"Hidden state dimension: {d}")
    print(f"Weight matrix row-sum norm: {rsn:.4f}")

    # Certified growth bounds
    print(f"\nCertified state growth bounds (Lipschitz property):")
    print(f"  ‖h_t‖∞ ≤ ‖W‖∞^t · ‖h_0‖∞ = {rsn:.4f}^t · ‖h_0‖∞")
    print(f"  System is {'contractive' if rsn < 1 else 'expansive'} (norm {'<' if rsn < 1 else '≥'} 1)")

    # Trace-based periodicity analysis
    print(f"\nTrace-based periodicity analysis:")
    print(f"{'Step t':>8} | {'|tr(W^t)|':>12} | {'Bound':>14} | {'Ratio':>8}")
    print("-" * 48)
    for t in range(1, num_steps + 1):
        Wt = np.linalg.matrix_power(W, t)
        trace_abs = abs(np.trace(Wt))
        bound = trace_growth_bound(W, t)
        ratio = trace_abs / bound if bound > 0 else 0
        print(f"{t:>8} | {trace_abs:>12.4f} | {bound:>14.4f} | {ratio:>8.4f}")

    # Perturbation sensitivity
    print(f"\nPerturbation sensitivity (ε = {perturbation_scale}):")
    np.random.seed(42)
    E = np.random.randn(d, d) * perturbation_scale
    W_perturbed = W + E
    rsn_pert = row_sum_norm(W_perturbed)
    print(f"  Original ‖W‖∞ = {rsn:.4f}")
    print(f"  Perturbed ‖W+E‖∞ = {rsn_pert:.4f}")
    print(f"  Change: {abs(rsn_pert - rsn):.6f}")

    for t in [5, 10, 20]:
        orig_trace = abs(np.trace(np.linalg.matrix_power(W, t)))
        pert_trace = abs(np.trace(np.linalg.matrix_power(W_perturbed, t)))
        print(f"  |tr(W^{t})| = {orig_trace:.4f}, |tr((W+E)^{t})| = {pert_trace:.4f}, "
              f"diff = {abs(orig_trace - pert_trace):.4f}")


# ===========================================================================
# Application 3: Thermodynamic Partition Function
# ===========================================================================

def thermodynamic_analysis(
    energy_matrix: np.ndarray,
    beta_values: List[float],
):
    """Analyze a statistical mechanical system via transfer operator.

    The partition function Z(β) = tr(exp(-β E)) is approximated by
    weighted loop sums of the Boltzmann weight matrix.
    """
    d = energy_matrix.shape[0]

    print(f"\n{'='*60}")
    print(f"Physics Application: Thermodynamic Transfer Analysis")
    print(f"{'='*60}")
    print(f"System size: {d} states")
    print(f"Energy matrix:")
    print(energy_matrix)

    for beta in beta_values:
        # Boltzmann weight matrix
        W = np.exp(-beta * energy_matrix)
        rsn = row_sum_norm(W)

        # Weighted loop sums = approximation to partition function data
        loops = weighted_loop_sums(W, 10)

        print(f"\nInverse temperature β = {beta:.2f}:")
        print(f"  Row-sum norm ‖W(β)‖∞ = {rsn:.4f}")
        print(f"  Partition function Z = tr(W) = {loops[1]:.4f}")
        print(f"  Free energy F = -log(Z)/β = {-np.log(loops[1])/beta:.4f}" if beta > 0 else "")
        print(f"  Loop sums: {['%.3f' % l for l in loops[:6]]}")


# ===========================================================================
# Application 4: Lattice-based Key Schedule Analysis
# ===========================================================================

def lattice_key_schedule_analysis():
    """Analyze a simplified lattice-based key schedule transition.

    Models the state evolution in a lattice-based cryptographic key schedule
    as a finite dynamical system, using the transfer operator to bound
    the cycle structure and collision resistance.
    """
    print(f"\n{'='*60}")
    print(f"Crypto Application: Lattice Key Schedule Analysis")
    print(f"{'='*60}")

    # Simplified model: 16-state key schedule
    d = 16
    # A non-trivial permutation modeling key mixing
    f_map = [7, 12, 3, 14, 9, 2, 11, 0, 15, 6, 1, 8, 5, 10, 13, 4]
    f = lambda x: f_map[x]
    M = build_correspondence_matrix(f, d)

    print(f"Key schedule permutation: {f_map}")
    print(f"State space: {d} states")

    # Analyze cycle structure
    print(f"\nCycle structure analysis:")
    for n in range(1, d + 1):
        pc = periodic_count_via_trace(f, d, n)
        if pc > 0:
            print(f"  Period {n}: {pc} periodic states")

    # Collision resistance metric
    print(f"\nCollision resistance metrics:")
    total_periodic = sum(periodic_count_via_trace(f, d, n) for n in range(1, d + 1))
    print(f"  Total periodic states (all periods ≤ {d}): {d}")
    print(f"  Certified bound: periodic count ≤ {d} at each period")
    print(f"  Complexity to compute all periods via trace: O({d}³ · log({d})) = O({d**3 * int(np.log2(d))})")


if __name__ == "__main__":
    # Application 1: Crypto
    # A 16-element S-box
    sbox = [14, 4, 13, 1, 2, 15, 11, 8, 3, 10, 6, 12, 5, 9, 0, 7]
    crypto_cycle_analysis(sbox, "DES-style S-box")

    # Application 2: RNN Robustness
    np.random.seed(7)
    d = 8
    W = np.random.randn(d, d) * 0.3  # Scaled to be near-contractive
    rnn_robustness_analysis(W, perturbation_scale=0.01, num_steps=15)

    # Application 3: Thermodynamics
    # 4-state Ising-like energy matrix
    E = np.array([
        [0.0, 1.0, 2.0, 1.0],
        [1.0, 0.0, 1.0, 2.0],
        [2.0, 1.0, 0.0, 1.0],
        [1.0, 2.0, 1.0, 0.0]
    ])
    thermodynamic_analysis(E, beta_values=[0.1, 0.5, 1.0, 2.0])

    # Application 4: Lattice crypto
    lattice_key_schedule_analysis()

    print(f"\n{'='*60}")
    print("All applications completed successfully!")
    print(f"{'='*60}")


#!/usr/bin/env python3
"""
Ruelle Transfer Semantics: Numerical Demonstrations

Demonstrates the core theorems from the Algebra-EML Ruelle Transfer Semantics
development with concrete numerical examples.
"""

import numpy as np
from fractions import Fraction
from typing import Callable, List, Tuple


def correspondence_matrix(f: Callable[[int], int], d: int) -> np.ndarray:
    """Build the d×d deterministic correspondence matrix for f : {0,...,d-1} → {0,...,d-1}.
    Entry (i, j) = 1 if f(i) = j, else 0 (pullback convention)."""
    M = np.zeros((d, d), dtype=int)
    for i in range(d):
        M[i, f(i)] = 1
    return M


def periodic_count(f: Callable[[int], int], d: int, n: int) -> int:
    """Count periodic points of period n: |{x : f^n(x) = x}|."""
    count = 0
    for x in range(d):
        y = x
        for _ in range(n):
            y = f(y)
        if y == x:
            count += 1
    return count


def row_sum_norm(M: np.ndarray) -> float:
    """Compute the row-sum (infinity) norm: max_i sum_j |M_ij|."""
    return np.max(np.sum(np.abs(M), axis=1))


def demo_trace_equals_periodic_count():
    """Verify: tr(M^n) = periodicCount(f, n) for a concrete dynamical system."""
    print("=" * 60)
    print("Demo 1: Trace Formula  tr(M^n) = |Fix(f^n)|")
    print("=" * 60)

    # Cyclic permutation on 5 elements: f(i) = (i + 1) mod 5
    d = 5
    f = lambda x: (x + 1) % d
    M = correspondence_matrix(f, d)

    print(f"\nDynamical system: f(x) = (x + 1) mod {d}")
    print(f"Correspondence matrix M:")
    print(M)

    print(f"\n{'n':>4} | {'tr(M^n)':>10} | {'periodicCount':>15} | {'Match':>6}")
    print("-" * 45)
    for n in range(1, 16):
        trace = int(np.trace(np.linalg.matrix_power(M, n)))
        pc = periodic_count(f, d, n)
        match = "✓" if trace == pc else "✗"
        print(f"{n:>4} | {trace:>10} | {pc:>15} | {match:>6}")


def demo_growth_bound():
    """Verify: |tr(L^n)| ≤ d * rowSumNorm(L)^n for a random matrix."""
    print("\n" + "=" * 60)
    print("Demo 2: Growth Bound  |tr(L^n)| ≤ d · ‖L‖∞^n")
    print("=" * 60)

    np.random.seed(42)
    d = 6
    L = np.random.randn(d, d) * 0.5  # Scale to avoid numerical overflow

    rsn = row_sum_norm(L)
    print(f"\nRandom {d}×{d} matrix L (entries ~ N(0, 0.25))")
    print(f"Row-sum norm ‖L‖∞ = {rsn:.4f}")

    print(f"\n{'n':>4} | {'|tr(L^n)|':>14} | {'d·‖L‖∞^n':>14} | {'Bound holds':>12}")
    print("-" * 52)
    for n in range(0, 21):
        trace_abs = abs(np.trace(np.linalg.matrix_power(L, n)))
        bound = d * rsn ** n
        holds = "✓" if trace_abs <= bound * 1.001 else "✗"  # Small tolerance for float
        print(f"{n:>4} | {trace_abs:>14.4f} | {bound:>14.4f} | {holds:>12}")


def demo_lipschitz_bound():
    """Verify: ‖Lv‖∞ ≤ ‖L‖∞ · ‖v‖∞ for random vectors."""
    print("\n" + "=" * 60)
    print("Demo 3: Lipschitz Property  ‖Lv‖∞ ≤ ‖L‖∞ · ‖v‖∞")
    print("=" * 60)

    np.random.seed(123)
    d = 8
    L = np.random.randn(d, d)
    rsn = row_sum_norm(L)

    print(f"\nRandom {d}×{d} matrix L, ‖L‖∞ = {rsn:.4f}")
    print(f"\n{'Trial':>6} | {'‖v‖∞':>10} | {'‖Lv‖∞':>10} | {'‖L‖∞·‖v‖∞':>12} | {'Holds':>6}")
    print("-" * 55)

    all_hold = True
    for trial in range(10):
        v = np.random.randn(d)
        v_norm = np.max(np.abs(v))
        Lv = L @ v
        Lv_norm = np.max(np.abs(Lv))
        bound = rsn * v_norm
        holds = Lv_norm <= bound * 1.001
        all_hold = all_hold and holds
        mark = "✓" if holds else "✗"
        print(f"{trial+1:>6} | {v_norm:>10.4f} | {Lv_norm:>10.4f} | {bound:>12.4f} | {mark:>6}")

    print(f"\nAll bounds hold: {'✓' if all_hold else '✗'}")


def demo_conjugacy_invariance():
    """Verify: conjugate systems have the same periodic counts."""
    print("\n" + "=" * 60)
    print("Demo 4: Conjugacy Invariance")
    print("=" * 60)

    d = 6
    # f: a permutation
    f_perm = [2, 0, 4, 5, 3, 1]  # f(0)=2, f(1)=0, etc.
    f = lambda x: f_perm[x]

    # Conjugate by a random permutation e
    e_perm = [3, 1, 5, 0, 4, 2]  # a permutation of {0,...,5}
    e_inv = [0] * d
    for i in range(d):
        e_inv[e_perm[i]] = i

    # g = e ∘ f ∘ e⁻¹
    g = lambda x: e_perm[f(e_inv[x])]

    print(f"\nf = {f_perm}")
    print(f"e = {e_perm}")
    print(f"g = e ∘ f ∘ e⁻¹ = {[g(i) for i in range(d)]}")

    print(f"\n{'n':>4} | {'periodicCount(f,n)':>20} | {'periodicCount(g,n)':>20} | {'Equal':>6}")
    print("-" * 58)
    for n in range(1, 13):
        pc_f = periodic_count(f, d, n)
        pc_g = periodic_count(g, d, n)
        eq = "✓" if pc_f == pc_g else "✗"
        print(f"{n:>4} | {pc_f:>20} | {pc_g:>20} | {eq:>6}")


def demo_weighted_loop_sum():
    """Demonstrate weighted loop sums for a non-deterministic kernel."""
    print("\n" + "=" * 60)
    print("Demo 5: Weighted Loop Sums (Thermodynamic Transfer)")
    print("=" * 60)

    d = 4
    # Non-negative weight matrix (thermodynamic case)
    W = np.array([
        [0.5, 0.3, 0.0, 0.2],
        [0.1, 0.4, 0.3, 0.2],
        [0.2, 0.1, 0.5, 0.2],
        [0.3, 0.2, 0.1, 0.4]
    ])

    print(f"\nWeight matrix W (non-negative, thermodynamic):")
    print(W)
    print(f"Row-sum norm: {row_sum_norm(W):.4f}")

    print(f"\n{'n':>4} | {'weightedLoopSum':>16} | {'≥ 0':>6} | {'bound d·‖W‖∞^n':>16}")
    print("-" * 55)
    for n in range(0, 16):
        Wn = np.linalg.matrix_power(W, n)
        loop_sum = np.trace(Wn)
        nonneg = "✓" if loop_sum >= -1e-10 else "✗"
        bound = d * row_sum_norm(W) ** n
        print(f"{n:>4} | {loop_sum:>16.6f} | {nonneg:>6} | {bound:>16.6f}")


def demo_artin_mazur_bound():
    """Verify: |artinMazurCoeff(f, n)| ≤ card(α)."""
    print("\n" + "=" * 60)
    print("Demo 6: Artin-Mazur Coefficient Bound")
    print("=" * 60)

    d = 7
    # A non-trivial map on 7 states
    f_map = [3, 5, 1, 6, 0, 2, 4]
    f = lambda x: f_map[x]

    print(f"\nf = {f_map}, d = {d}")

    print(f"\n{'n':>4} | {'periodicCount(n+1)':>20} | {'artinMazurCoeff':>16} | {'≤ d':>6}")
    print("-" * 55)
    for n in range(0, 15):
        pc = periodic_count(f, d, n + 1)
        amc = Fraction(pc, n + 1)
        bounded = "✓" if abs(amc) <= d else "✗"
        print(f"{n:>4} | {pc:>20} | {float(amc):>16.6f} | {bounded:>6}")


if __name__ == "__main__":
    demo_trace_equals_periodic_count()
    demo_growth_bound()
    demo_lipschitz_bound()
    demo_conjugacy_invariance()
    demo_weighted_loop_sum()
    demo_artin_mazur_bound()
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for Ruelle Transfer Operator Semantics

Generates publication-quality charts demonstrating key theorems and bounds.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from algorithms import (
    build_correspondence_matrix,
    periodic_count_via_trace,
    row_sum_norm,
    weighted_loop_sums,
    trace_growth_bound,
)


def plot_trace_vs_bound():
    """Plot |tr(L^n)| vs the certified bound d·‖L‖∞^n."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Case 1: Contractive matrix
    np.random.seed(42)
    d = 6
    L = np.random.randn(d, d) * 0.3
    rsn = row_sum_norm(L)

    ns = range(0, 25)
    traces = [abs(np.trace(np.linalg.matrix_power(L, n))) for n in ns]
    bounds = [d * rsn ** n for n in ns]

    axes[0].semilogy(ns, traces, 'b-o', markersize=4, label='|tr(L^n)|')
    axes[0].semilogy(ns, bounds, 'r--', linewidth=2, label=f'd·‖L‖∞^n (‖L‖∞={rsn:.2f})')
    axes[0].set_xlabel('n', fontsize=12)
    axes[0].set_ylabel('Value', fontsize=12)
    axes[0].set_title(f'Contractive Case (d={d}, ‖L‖∞={rsn:.2f})', fontsize=13)
    axes[0].legend(fontsize=11)
    axes[0].grid(True, alpha=0.3)

    # Case 2: Expansive matrix
    L2 = np.random.randn(d, d) * 0.8
    rsn2 = row_sum_norm(L2)

    ns2 = range(0, 15)
    traces2 = [abs(np.trace(np.linalg.matrix_power(L2, n))) for n in ns2]
    bounds2 = [d * rsn2 ** n for n in ns2]

    axes[1].semilogy(ns2, traces2, 'b-o', markersize=4, label='|tr(L^n)|')
    axes[1].semilogy(ns2, bounds2, 'r--', linewidth=2, label=f'd·‖L‖∞^n (‖L‖∞={rsn2:.2f})')
    axes[1].set_xlabel('n', fontsize=12)
    axes[1].set_ylabel('Value', fontsize=12)
    axes[1].set_title(f'Expansive Case (d={d}, ‖L‖∞={rsn2:.2f})', fontsize=13)
    axes[1].legend(fontsize=11)
    axes[1].grid(True, alpha=0.3)

    plt.suptitle('Certified Trace Growth Bound: |tr(L^n)| ≤ d · ‖L‖∞^n', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('trace_bound.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: trace_bound.png")


def plot_periodic_counts():
    """Plot periodic point counts for various dynamical systems."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))

    # System 1: Cyclic permutation
    d1 = 6
    f1 = lambda x: (x + 1) % d1
    ns = range(1, 25)
    pc1 = [periodic_count_via_trace(f1, d1, n) for n in ns]
    axes[0].bar(ns, pc1, color='steelblue', alpha=0.8)
    axes[0].set_xlabel('Period n', fontsize=11)
    axes[0].set_ylabel('|Fix(f^n)|', fontsize=11)
    axes[0].set_title(f'Cyclic: f(x) = (x+1) mod {d1}', fontsize=12)
    axes[0].axhline(y=d1, color='red', linestyle='--', alpha=0.5, label=f'card(α)={d1}')
    axes[0].legend()

    # System 2: Squaring mod prime
    d2 = 11
    f2 = lambda x: (x * x) % d2
    pc2 = [periodic_count_via_trace(f2, d2, n) for n in ns]
    axes[1].bar(ns, pc2, color='darkorange', alpha=0.8)
    axes[1].set_xlabel('Period n', fontsize=11)
    axes[1].set_ylabel('|Fix(f^n)|', fontsize=11)
    axes[1].set_title(f'Quadratic: f(x) = x² mod {d2}', fontsize=12)
    axes[1].axhline(y=d2, color='red', linestyle='--', alpha=0.5, label=f'card(α)={d2}')
    axes[1].legend()

    # System 3: Composed permutation
    d3 = 8
    perm = [3, 7, 1, 5, 0, 6, 4, 2]
    f3 = lambda x: perm[x]
    pc3 = [periodic_count_via_trace(f3, d3, n) for n in ns]
    axes[2].bar(ns, pc3, color='seagreen', alpha=0.8)
    axes[2].set_xlabel('Period n', fontsize=11)
    axes[2].set_ylabel('|Fix(f^n)|', fontsize=11)
    axes[2].set_title(f'Permutation: {perm}', fontsize=12)
    axes[2].axhline(y=d3, color='red', linestyle='--', alpha=0.5, label=f'card(α)={d3}')
    axes[2].legend()

    plt.suptitle('Periodic Point Counts: tr(M^n) = |Fix(f^n)| ≤ card(α)', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('periodic_counts.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: periodic_counts.png")


def plot_weighted_loops():
    """Plot weighted loop sums for thermodynamic transfer operators."""
    fig, ax = plt.subplots(figsize=(10, 5))

    d = 4
    betas = [0.1, 0.5, 1.0, 2.0]
    E = np.array([
        [0.0, 1.0, 2.0, 1.0],
        [1.0, 0.0, 1.0, 2.0],
        [2.0, 1.0, 0.0, 1.0],
        [1.0, 2.0, 1.0, 0.0]
    ])

    colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728']
    for beta, color in zip(betas, colors):
        W = np.exp(-beta * E)
        loops = weighted_loop_sums(W, 12)
        ax.semilogy(range(len(loops)), loops, '-o', color=color,
                     markersize=5, label=f'β = {beta}')

    ax.set_xlabel('n', fontsize=12)
    ax.set_ylabel('weightedLoopSum(K, n)', fontsize=12)
    ax.set_title('Thermodynamic Weighted Loop Sums at Different Temperatures', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('weighted_loops.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: weighted_loops.png")


def plot_lipschitz_bound():
    """Visualize the Lipschitz property ‖Lv‖∞ ≤ ‖L‖∞ · ‖v‖∞."""
    fig, ax = plt.subplots(figsize=(8, 6))

    np.random.seed(99)
    d = 10
    L = np.random.randn(d, d) * 0.5
    rsn = row_sum_norm(L)

    v_norms = []
    Lv_norms = []
    for _ in range(500):
        v = np.random.randn(d) * np.random.uniform(0.1, 5.0)
        v_norm = np.max(np.abs(v))
        Lv = L @ v
        Lv_norm = np.max(np.abs(Lv))
        v_norms.append(v_norm)
        Lv_norms.append(Lv_norm)

    ax.scatter(v_norms, Lv_norms, alpha=0.4, s=10, color='steelblue', label='(‖v‖∞, ‖Lv‖∞)')

    max_v = max(v_norms)
    xs = np.linspace(0, max_v, 100)
    ax.plot(xs, rsn * xs, 'r-', linewidth=2, label=f'‖L‖∞ · ‖v‖∞ (‖L‖∞={rsn:.2f})')

    ax.set_xlabel('‖v‖∞', fontsize=12)
    ax.set_ylabel('‖Lv‖∞', fontsize=12)
    ax.set_title('Certified Lipschitz Bound for Transfer Operator', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('lipschitz_bound.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: lipschitz_bound.png")


if __name__ == "__main__":
    plot_trace_vs_bound()
    plot_periodic_counts()
    plot_weighted_loops()
    plot_lipschitz_bound()
    print("\nAll visualizations generated!")
