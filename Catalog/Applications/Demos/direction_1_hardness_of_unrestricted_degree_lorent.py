#!/usr/bin/env python3
"""
Applications of Lorentzian Recognition Complexity Theory

Demonstrates real-world applications:
1. Log-concavity testing complexity estimation
2. Matroid independence polynomial analysis
3. Optimization barrier detection via spectral obstruction
4. Parameterized complexity tradeoffs
"""

import numpy as np
from math import comb, log2, factorial
from itertools import product, combinations
from typing import List, Tuple, Dict


# =============================================================================
# Application 1: Log-Concavity Testing Complexity
# =============================================================================

def log_concavity_test_budget(n: int, d: int, time_per_check_ms: float = 1.0) -> Dict:
    """
    Estimate computational budget for testing log-concavity of a
    degree-d homogeneous polynomial in n variables via Lorentzian recognition.

    The test requires checking all C(n+d-3, d-2) quadratic leaves.
    Each check involves computing eigenvalues of an n×n matrix: O(n³).

    Args:
        n: Number of variables
        d: Degree
        time_per_check_ms: Time per spectral check in milliseconds

    Returns:
        Dictionary with complexity estimates
    """
    if d < 2:
        num_leaves = 1
    else:
        num_leaves = comb(n + d - 3, d - 2)

    spectral_cost = n ** 3  # flops per eigenvalue computation
    total_flops = num_leaves * spectral_cost
    total_time_ms = num_leaves * time_per_check_ms
    total_time_s = total_time_ms / 1000

    return {
        "variables": n,
        "degree": d,
        "num_leaves": num_leaves,
        "spectral_cost_per_leaf": spectral_cost,
        "total_flops": total_flops,
        "estimated_time_s": total_time_s,
        "feasible": total_time_s < 3600,  # under 1 hour
    }


def demo_log_concavity_complexity():
    """Show how complexity scales for log-concavity testing."""
    print("=" * 70)
    print("APPLICATION 1: Log-Concavity Testing Complexity")
    print("=" * 70)

    print("\n--- Fixed Degree (d=6): Polynomial Scaling ---")
    for n in [5, 10, 20, 50, 100, 500]:
        result = log_concavity_test_budget(n, 6)
        print(f"  n={n:>4}: {result['num_leaves']:>12} leaves, "
              f"~{result['estimated_time_s']:.2e}s")

    print("\n--- Unbounded Degree (d=n): Exponential Scaling ---")
    for n in [5, 8, 10, 12, 15, 20, 25, 30]:
        result = log_concavity_test_budget(n, n)
        feasible = "✓" if result['feasible'] else "✗"
        print(f"  n=d={n:>3}: {result['num_leaves']:>15} leaves, "
              f"~{result['estimated_time_s']:.2e}s [{feasible}]")


# =============================================================================
# Application 2: Matroid Independence Polynomial
# =============================================================================

def uniform_matroid_bases(n: int, r: int) -> List[frozenset]:
    """Return all bases of the uniform matroid U(r,n)."""
    return [frozenset(S) for S in combinations(range(n), r)]


def independence_polynomial_support(n: int, r: int) -> Dict[Tuple[int,...], int]:
    """
    Compute the support of the independence polynomial of U(r,n).

    The independence polynomial is ∑_{I independent} ∏_{i∈I} x_i.
    For U(r,n), every subset of size ≤ r is independent.

    Returns coefficients as {multiindex: coefficient}.
    """
    coeffs = {}
    for k in range(r + 1):
        for S in combinations(range(n), k):
            alpha = tuple(1 if i in S else 0 for i in range(n))
            coeffs[alpha] = coeffs.get(alpha, 0) + 1
    return coeffs


def demo_matroid_analysis():
    """Analyze Lorentzian recognition complexity for matroid polynomials."""
    print("\n" + "=" * 70)
    print("APPLICATION 2: Matroid Independence Polynomial Analysis")
    print("=" * 70)

    print("\nUniform matroid U(r, n) — independence polynomial recognition:")
    print(f"{'n':>4} {'r':>4} {'degree':>8} {'leaves':>12} {'feasible':>10}")

    for n in range(3, 12):
        for r in [2, n // 2, n - 1]:
            if r > n or r < 1:
                continue
            d = r  # degree = rank
            if d < 2:
                leaves = 1
            else:
                leaves = comb(n + d - 3, d - 2)
            feasible = "✓" if leaves < 10**9 else "✗"
            print(f"{n:>4} {r:>4} {d:>8} {leaves:>12} {feasible:>10}")

    print("\nKey insight: For rank r fixed, leaves grow polynomially in n.")
    print("For rank r ~ n, leaves grow exponentially — the phase transition!")


# =============================================================================
# Application 3: Optimization Barrier Detection
# =============================================================================

def detect_optimization_barrier(H: np.ndarray) -> Dict:
    """
    Detect optimization barriers via Lorentzian/spectral analysis.

    In optimization, a Hessian with Lorentzian signature (≤1 positive eigenvalue)
    indicates a saddle point or local maximum in most directions — useful for
    certifying that a critical point is not a local minimum.

    If the Hessian has ≥2 positive eigenvalues, the spectral obstruction
    theorem guarantees non-Lorentzian behavior, meaning the critical point
    might be a local minimum or a complex saddle.

    Returns analysis of the spectral structure.
    """
    eigenvalues = np.linalg.eigvalsh(H)
    n_pos = int(np.sum(eigenvalues > 1e-10))
    n_neg = int(np.sum(eigenvalues < -1e-10))
    n_zero = len(eigenvalues) - n_pos - n_neg

    if n_pos <= 1:
        barrier_type = "Lorentzian barrier (saddle/maximum in most directions)"
    elif n_pos == len(eigenvalues):
        barrier_type = "No barrier (positive definite — local minimum)"
    else:
        barrier_type = "Complex saddle (spectral obstruction detected)"

    return {
        "eigenvalues": eigenvalues,
        "positive_count": n_pos,
        "negative_count": n_neg,
        "zero_count": n_zero,
        "is_lorentzian": n_pos <= 1,
        "barrier_type": barrier_type,
    }


def demo_optimization_barriers():
    """Show how spectral obstruction detects optimization barriers."""
    print("\n" + "=" * 70)
    print("APPLICATION 3: Optimization Barrier Detection")
    print("=" * 70)

    # Rosenbrock-like Hessian at saddle point
    H1 = np.array([[-400, 0], [0, 200]], dtype=float)
    result1 = detect_optimization_barrier(H1)
    print(f"\nRosenbrock saddle: eigenvalues = {result1['eigenvalues']}")
    print(f"  {result1['barrier_type']}")

    # Random high-dimensional Hessian
    np.random.seed(42)
    n = 10
    M = np.random.randn(n, n)
    H2 = M @ M.T - 3 * np.eye(n)  # Shift to create mixed signature
    result2 = detect_optimization_barrier(H2)
    print(f"\nRandom {n}×{n} Hessian: {result2['positive_count']} positive, "
          f"{result2['negative_count']} negative eigenvalues")
    print(f"  {result2['barrier_type']}")

    # Clearly Lorentzian
    H3 = np.diag([5.0, -1, -1, -1, -1])
    result3 = detect_optimization_barrier(H3)
    print(f"\nLorentzian diagonal: eigenvalues = {result3['eigenvalues']}")
    print(f"  {result3['barrier_type']}")


# =============================================================================
# Application 4: Parameterized Complexity Tradeoffs
# =============================================================================

def parameterized_analysis(max_n: int = 20, max_d: int = 20) -> Dict[str, List]:
    """
    Analyze the parameterized complexity landscape.

    Identifies the boundary where recognition transitions from
    feasible (< 10^6 leaves) to infeasible (> 10^9 leaves).
    """
    feasible = []
    borderline = []
    infeasible = []

    for n in range(2, max_n + 1):
        for d in range(2, max_d + 1):
            leaves = comb(n + d - 3, d - 2)
            point = {"n": n, "d": d, "leaves": leaves}
            if leaves < 10**6:
                feasible.append(point)
            elif leaves < 10**9:
                borderline.append(point)
            else:
                infeasible.append(point)

    return {
        "feasible": feasible,
        "borderline": borderline,
        "infeasible": infeasible,
    }


def demo_parameterized():
    """Show parameterized complexity tradeoffs."""
    print("\n" + "=" * 70)
    print("APPLICATION 4: Parameterized Complexity Tradeoffs")
    print("=" * 70)

    result = parameterized_analysis(15, 15)

    print(f"\nFeasible (< 10^6 leaves): {len(result['feasible'])} configurations")
    print(f"Borderline (10^6 - 10^9): {len(result['borderline'])} configurations")
    print(f"Infeasible (> 10^9 leaves): {len(result['infeasible'])} configurations")

    print("\n--- Feasibility boundary (max d for each n) ---")
    for n in range(2, 16):
        max_feasible_d = 1
        for d in range(2, 30):
            if comb(n + d - 3, d - 2) < 10**6:
                max_feasible_d = d
            else:
                break
        print(f"  n={n:>3}: feasible up to d={max_feasible_d}")

    print("\nConclusion: For n > ~8 and d > ~8, exact Lorentzian recognition")
    print("exceeds practical limits. This is the phase transition in action.")


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Applications of Lorentzian Recognition Complexity Theory          ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    demo_log_concavity_complexity()
    demo_matroid_analysis()
    demo_optimization_barriers()
    demo_parameterized()

    print("\n" + "=" * 70)
    print("KEY TAKEAWAYS")
    print("=" * 70)
    print("""
1. Log-concavity testing via Lorentzian recognition is practical for fixed
   degree but becomes infeasible when degree grows with variable count.

2. Matroid independence polynomials exhibit the same phase transition:
   fixed rank → tractable; rank ~ n → exponential.

3. Spectral obstruction detection (Theorem 7.1) provides practical
   optimization barrier certification in polynomial time per check.

4. The feasibility boundary suggests that parameterized algorithms
   (FPT by degree or treewidth) are the right algorithmic paradigm.
""")


#!/usr/bin/env python3
"""
Demo: Lorentzian Recognition Complexity Phase Transition

Demonstrates the exponential growth of derivative tree leaves when degree
is unbounded, the Boolean-to-multiindex injection, CNF satisfiability
connections, and spectral obstruction detection.

Usage:
    python demo.py
"""

import numpy as np
from math import comb, factorial
from itertools import product
from typing import List, Tuple, Dict, Optional


# =============================================================================
# Part 1: Multiindex Counting and Phase Transition
# =============================================================================

def multiindex_count(n: int, d: int) -> int:
    """Exact count of multiindices of weight d in n variables = C(n+d-1, d)."""
    return comb(n + d - 1, d)


def number_of_quadratic_leaves(n: int, d: int) -> int:
    """Number of quadratic leaves in recursive Lorentzian recognition."""
    if d < 2:
        return 1
    return multiindex_count(n, d - 2)


def demo_phase_transition():
    """Demonstrate the complexity phase transition."""
    print("=" * 70)
    print("PHASE TRANSITION: Fixed Degree vs. Unbounded Degree")
    print("=" * 70)

    print("\n--- Fixed Degree (d=5), Varying Variables ---")
    print(f"{'n':>5} {'Leaves':>12} {'Upper bound n^3':>16}")
    for n in range(2, 16):
        leaves = number_of_quadratic_leaves(n, 5)
        upper = n ** 3
        print(f"{n:>5} {leaves:>12} {upper:>16}")

    print("\n--- Unbounded Degree (d = n+1), Exponential Growth ---")
    print(f"{'m':>5} {'n=m+1':>6} {'d=m+2':>6} {'2^m':>12} {'Leaves':>12} {'(m+1)^m':>14}")
    for m in range(1, 13):
        n = m + 1
        d = m + 2
        lower = 2 ** m
        leaves = number_of_quadratic_leaves(n, d)
        upper = (m + 1) ** m
        print(f"{m:>5} {n:>6} {d:>6} {lower:>12} {leaves:>12} {upper:>14}")


# =============================================================================
# Part 2: Boolean-to-Multiindex Injection
# =============================================================================

def count_true(b: Tuple[bool, ...]) -> int:
    """Count true entries in a Boolean tuple."""
    return sum(1 for x in b if x)


def bool_to_multiindex(m: int, b: Tuple[bool, ...]) -> Tuple[int, ...]:
    """
    Inject a Boolean assignment b ∈ {0,1}^m into a multiindex of weight m
    in (m+1) variables.

    α(0) = m - countTrue(b)
    α(i+1) = 1 if b[i] else 0
    """
    ct = count_true(b)
    alpha = [m - ct] + [int(x) for x in b]
    return tuple(alpha)


def demo_injection():
    """Demonstrate the Boolean-to-multiindex injection."""
    print("\n" + "=" * 70)
    print("BOOLEAN-TO-MULTIINDEX INJECTION")
    print("=" * 70)

    m = 4
    print(f"\nInjection for m={m}: {{0,1}}^{m} → multiindices of weight {m} in {m+1} vars")
    print(f"{'Boolean b':>20} {'Multiindex α':>25} {'Weight':>8}")

    all_bools = list(product([False, True], repeat=m))
    all_multiindices = set()
    for b in all_bools:
        alpha = bool_to_multiindex(m, b)
        weight = sum(alpha)
        all_multiindices.add(alpha)
        b_str = "".join("1" if x else "0" for x in b)
        print(f"{b_str:>20} {str(alpha):>25} {weight:>8}")

    print(f"\nTotal Boolean assignments: {len(all_bools)}")
    print(f"Distinct multiindices produced: {len(all_multiindices)}")
    print(f"Injection is {'valid' if len(all_multiindices) == len(all_bools) else 'INVALID'}!")
    print(f"Total multiindices of weight {m} in {m+1} vars: {multiindex_count(m+1, m)}")
    print(f"Lower bound 2^{m} = {2**m} ≤ {multiindex_count(m+1, m)} = C({2*m},{m}) ✓")


# =============================================================================
# Part 3: CNF Satisfiability and Obstruction
# =============================================================================

def make_cnf(num_vars: int, clauses: List[List[Tuple[int, bool]]]) -> Dict:
    """Create a CNF formula."""
    return {"num_vars": num_vars, "clauses": clauses}


def evaluate_cnf(formula: Dict, assignment: Tuple[bool, ...]) -> bool:
    """Check if an assignment satisfies a CNF formula."""
    for clause in formula["clauses"]:
        satisfied = False
        for var_idx, polarity in clause:
            if assignment[var_idx] == polarity:
                satisfied = True
                break
        if not satisfied:
            return False
    return True


def find_obstruction(formula: Dict, assignment: Tuple[bool, ...]) -> Optional[int]:
    """Find the first unsatisfied clause (obstruction), if any."""
    for idx, clause in enumerate(formula["clauses"]):
        satisfied = False
        for var_idx, polarity in clause:
            if assignment[var_idx] == polarity:
                satisfied = True
                break
        if not satisfied:
            return idx
    return None


def demo_sat_obstruction():
    """Demonstrate SAT-obstruction duality."""
    print("\n" + "=" * 70)
    print("SAT-OBSTRUCTION DUALITY")
    print("=" * 70)

    # Example 1: Satisfiable formula
    phi_sat = make_cnf(3, [
        [(0, True), (1, True)],       # x0 ∨ x1
        [(1, False), (2, True)],      # ¬x1 ∨ x2
        [(0, False), (2, False)],     # ¬x0 ∨ ¬x2
    ])

    print("\nFormula 1 (satisfiable): (x0∨x1) ∧ (¬x1∨x2) ∧ (¬x0∨¬x2)")
    all_assignments = list(product([False, True], repeat=3))
    satisfying = []
    for tau in all_assignments:
        result = evaluate_cnf(phi_sat, tau)
        obs = find_obstruction(phi_sat, tau)
        tau_str = "".join("1" if x else "0" for x in tau)
        if result:
            satisfying.append(tau)
            print(f"  τ={tau_str}: SATISFIED")
        else:
            print(f"  τ={tau_str}: OBSTRUCTED at clause {obs}")

    print(f"  → Satisfiable: {len(satisfying) > 0} ({len(satisfying)} solutions)")

    # Example 2: Unsatisfiable formula
    phi_unsat = make_cnf(2, [
        [(0, True), (1, True)],       # x0 ∨ x1
        [(0, True), (1, False)],      # x0 ∨ ¬x1
        [(0, False), (1, True)],      # ¬x0 ∨ x1
        [(0, False), (1, False)],     # ¬x0 ∨ ¬x1
    ])

    print("\nFormula 2 (unsatisfiable): (x0∨x1)∧(x0∨¬x1)∧(¬x0∨x1)∧(¬x0∨¬x1)")
    all_assignments = list(product([False, True], repeat=2))
    all_obstructed = True
    for tau in all_assignments:
        obs = find_obstruction(phi_unsat, tau)
        tau_str = "".join("1" if x else "0" for x in tau)
        if obs is not None:
            print(f"  τ={tau_str}: OBSTRUCTED at clause {obs}")
        else:
            all_obstructed = False
            print(f"  τ={tau_str}: SATISFIED")

    print(f"  → All obstructed: {all_obstructed} (duality: unsat ↔ all obstructed)")


# =============================================================================
# Part 4: Spectral Obstruction Detection
# =============================================================================

def check_lorentzian_signature(A: np.ndarray) -> Tuple[bool, np.ndarray]:
    """
    Check if a symmetric matrix has Lorentzian signature
    (at most one positive eigenvalue).
    Returns (is_lorentzian, eigenvalues).
    """
    eigenvalues = np.linalg.eigvalsh(A)
    num_positive = np.sum(eigenvalues > 1e-10)
    return num_positive <= 1, eigenvalues


def demo_spectral_obstruction():
    """Demonstrate spectral obstruction for non-Lorentzian matrices."""
    print("\n" + "=" * 70)
    print("SPECTRAL OBSTRUCTION DETECTION")
    print("=" * 70)

    # Example 1: Lorentzian matrix (1 positive eigenvalue)
    A1 = np.array([[2, 1, 0],
                    [1, -1, 0],
                    [0, 0, -3]], dtype=float)
    is_lor1, eigs1 = check_lorentzian_signature(A1)
    print(f"\nMatrix A1 eigenvalues: {np.round(eigs1, 3)}")
    print(f"  Lorentzian signature: {is_lor1}")
    print(f"  Positive eigenvalues: {np.sum(eigs1 > 1e-10)}")

    # Example 2: Non-Lorentzian matrix (2 positive eigenvalues)
    A2 = np.array([[3, 1, 0],
                    [1, 2, 0],
                    [0, 0, -1]], dtype=float)
    is_lor2, eigs2 = check_lorentzian_signature(A2)
    print(f"\nMatrix A2 eigenvalues: {np.round(eigs2, 3)}")
    print(f"  Lorentzian signature: {is_lor2}")
    print(f"  Positive eigenvalues: {np.sum(eigs2 > 1e-10)}")

    # Verify spectral obstruction theorem
    if not is_lor2:
        print("  → Spectral obstruction detected: ≥2 positive eigenvalues")
        print("    For every direction w, there exists orthogonal v with Q(v) > 0")

    # Example 3: Identity matrix (maximally non-Lorentzian)
    n = 5
    A3 = np.eye(n)
    is_lor3, eigs3 = check_lorentzian_signature(A3)
    print(f"\nIdentity {n}×{n} eigenvalues: {np.round(eigs3, 3)}")
    print(f"  Lorentzian signature: {is_lor3}")
    print(f"  All {n} eigenvalues positive → maximally non-Lorentzian")


# =============================================================================
# Part 5: Certificate Size Visualization
# =============================================================================

def demo_certificate_sizes():
    """Show certificate sizes across the phase transition."""
    print("\n" + "=" * 70)
    print("CERTIFICATE COMPLEXITY ACROSS THE PHASE TRANSITION")
    print("=" * 70)

    print("\n--- Certificate size = numberOfQuadraticLeaves(n, d) ---")
    header = 'd\\n'
    print(f"{header:>4}", end="")
    for n in range(2, 9):
        print(f"{n:>10}", end="")
    print()
    print("-" * 74)

    for d in range(2, 11):
        print(f"{d:>4}", end="")
        for n in range(2, 9):
            leaves = number_of_quadratic_leaves(n, d)
            if leaves > 999999:
                print(f"{'>' + str(leaves // 1000) + 'K':>10}", end="")
            else:
                print(f"{leaves:>10}", end="")
        print()

    print("\nDiagonal (d = n+1, the hard regime):")
    for m in range(1, 10):
        n, d = m + 1, m + 2
        leaves = number_of_quadratic_leaves(n, d)
        ratio = leaves / (2 ** m)
        print(f"  m={m}: n={n}, d={d}, leaves={leaves}, "
              f"2^m={2**m}, ratio={ratio:.2f}")


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Lorentzian Recognition Complexity: Phase Transition Demo           ║")
    print("║  Exponential Lower Bounds for Unbounded-Degree Recognition         ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    demo_phase_transition()
    demo_injection()
    demo_sat_obstruction()
    demo_spectral_obstruction()
    demo_certificate_sizes()

    print("\n" + "=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print("""
Key Results Demonstrated:
1. Phase Transition: Fixed degree → polynomial leaves; unbounded degree → exponential
2. Boolean Injection: {0,1}^m embeds into multiindices, proving 2^m lower bound
3. SAT Duality: Unsatisfiability ↔ universal obstruction (every branch blocked)
4. Spectral Obstruction: ≥2 positive eigenvalues → non-Lorentzian (contrapositive)
5. Certificate Complexity: Grows exponentially along the diagonal d ~ n
""")


#!/usr/bin/env python3
"""
Visualization: Boolean-to-Multiindex Injection

Visualizes the injection from {0,1}^m into multiindices of weight m in (m+1)
variables. Shows how Boolean assignments map to lattice points, demonstrating
the constructive proof that multiindex count ≥ 2^m.

Requires: numpy, matplotlib
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product
from math import comb


def bool_to_multiindex(m, b):
    """Inject b ∈ {0,1}^m into a multiindex α ∈ ℕ^{m+1} with |α| = m."""
    ct = sum(1 for x in b if x)
    return (m - ct,) + tuple(int(x) for x in b)


def enumerate_multiindices_3(d):
    """Enumerate multiindices of weight d in 3 variables."""
    for a in range(d + 1):
        for b in range(d - a + 1):
            yield (a, b, d - a - b)


# Create figure with 3 panels
fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: Injection for m=2 (3 variables, weight 2)
ax1 = axes[0]
m = 2
all_multiindices = list(enumerate_multiindices_3(m))

# Plot all multiindices
for alpha in all_multiindices:
    ax1.scatter(alpha[1], alpha[2], c='lightgray', s=200, zorder=1, edgecolors='gray')
    ax1.annotate(f'({alpha[0]},{alpha[1]},{alpha[2]})',
                 (alpha[1], alpha[2]), textcoords="offset points",
                 xytext=(10, 5), fontsize=8, color='gray')

# Highlight injection image
colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12']
for idx, b in enumerate(product([False, True], repeat=m)):
    alpha = bool_to_multiindex(m, b)
    b_str = "".join("1" if x else "0" for x in b)
    ax1.scatter(alpha[1], alpha[2], c=colors[idx], s=300, zorder=2,
                edgecolors='black', linewidths=2)
    ax1.annotate(f'b={b_str}', (alpha[1], alpha[2]),
                 textcoords="offset points", xytext=(-25, -20),
                 fontsize=9, fontweight='bold', color=colors[idx])

ax1.set_xlabel('α₁', fontsize=13)
ax1.set_ylabel('α₂', fontsize=13)
ax1.set_title(f'm=2: {{0,1}}² → multiindices (weight 2, 3 vars)\n'
              f'{2**m} injected / {comb(m+2, m)} total', fontsize=12)
ax1.set_xlim(-0.5, m + 0.5)
ax1.set_ylim(-0.5, m + 0.5)
ax1.grid(True, alpha=0.3)

# Panel 2: Coverage ratio as m grows
ax2 = axes[1]
ms = list(range(1, 15))
injection_sizes = [2**m for m in ms]
total_sizes = [comb(2*m, m) for m in ms]
coverage_ratios = [2**m / comb(2*m, m) for m in ms]

ax2.bar(ms, coverage_ratios, color='steelblue', alpha=0.8, edgecolor='black')
ax2.axhline(y=1.0, color='red', linestyle='--', label='Full coverage')
ax2.set_xlabel('Parameter m', fontsize=13)
ax2.set_ylabel('Coverage Ratio (2^m / C(2m,m))', fontsize=13)
ax2.set_title('Injection Coverage: Fraction of\nMultiindices Hit by Injection', fontsize=12)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3, axis='y')

# Panel 3: Injection structure visualization
ax3 = axes[2]
m = 5
bools = list(product([False, True], repeat=m))

# Create a grid showing the injection mapping
# x-axis: Boolean index (0 to 2^m-1)
# y-axis: multiindex components
data = np.zeros((m + 1, 2**m))
for j, b in enumerate(bools):
    alpha = bool_to_multiindex(m, b)
    for i in range(m + 1):
        data[i, j] = alpha[i]

im = ax3.imshow(data, aspect='auto', cmap='YlOrRd', interpolation='nearest')
ax3.set_xlabel(f'Boolean assignment index (0 to {2**m-1})', fontsize=12)
ax3.set_ylabel('Multiindex component', fontsize=13)
ax3.set_yticks(range(m + 1))
ax3.set_yticklabels([f'α₀ (slack)'] + [f'α_{i+1} = b_{i}' for i in range(m)])
ax3.set_title(f'm={m}: Injection Structure\n(color = component value)', fontsize=12)
plt.colorbar(im, ax=ax3, label='Value')

plt.tight_layout()
plt.savefig('viz_injection.png', dpi=150, bbox_inches='tight')
print("Saved viz_injection.png")


#!/usr/bin/env python3
"""
Visualization: Complexity Phase Transition for Lorentzian Recognition

Shows the phase transition from polynomial (fixed degree) to exponential
(unbounded degree) certificate complexity. Creates a heatmap of log₂(leaves)
across (n, d) parameter space, with the exponential diagonal highlighted.

Requires: numpy, matplotlib
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb, log2


def multiindex_count(n, d):
    """Number of multiindices of weight d in n variables."""
    if n <= 0 or d < 0:
        return 0
    return comb(n + d - 1, d)


def number_of_quadratic_leaves(n, d):
    """Number of quadratic leaves in Lorentzian recognition tree."""
    if d < 2:
        return 1
    return multiindex_count(n, d - 2)


# Build the data grid
max_param = 20
ns = list(range(2, max_param + 1))
ds = list(range(2, max_param + 1))

log_leaves = np.zeros((len(ds), len(ns)))
for i, d in enumerate(ds):
    for j, n in enumerate(ns):
        leaves = number_of_quadratic_leaves(n, d)
        log_leaves[i, j] = log2(max(leaves, 1))

# Create the figure
fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Left panel: Heatmap
ax1 = axes[0]
im = ax1.imshow(log_leaves, origin='lower', aspect='auto',
                cmap='inferno', interpolation='nearest',
                extent=[ns[0]-0.5, ns[-1]+0.5, ds[0]-0.5, ds[-1]+0.5])
ax1.set_xlabel('Number of Variables (n)', fontsize=13)
ax1.set_ylabel('Degree (d)', fontsize=13)
ax1.set_title('log₂(Quadratic Leaves) — Certificate Complexity', fontsize=14)
cbar = plt.colorbar(im, ax=ax1, label='log₂(number of leaves)')

# Draw the phase transition diagonal d = n+1
diag_ns = np.array(ns, dtype=float)
diag_ds = diag_ns + 1
mask = (diag_ds >= ds[0]) & (diag_ds <= ds[-1])
ax1.plot(diag_ns[mask], diag_ds[mask], 'w--', linewidth=2, label='d = n+1 (hard regime)')
ax1.legend(loc='upper left', fontsize=11, facecolor='black', labelcolor='white')

# Right panel: Growth curves
ax2 = axes[1]
ms = list(range(1, 16))
lower_bounds = [2**m for m in ms]
exact_counts = [comb(2*m, m) for m in ms]
upper_bounds = [(m+1)**m for m in ms]

ax2.semilogy(ms, lower_bounds, 'b-o', linewidth=2, markersize=6, label='Lower bound: 2^m')
ax2.semilogy(ms, exact_counts, 'r-s', linewidth=2, markersize=6, label='Exact: C(2m, m)')
ax2.semilogy(ms, upper_bounds, 'g-^', linewidth=2, markersize=6, label='Upper bound: (m+1)^m')

# Reference lines
ax2.semilogy(ms, [4**m / np.sqrt(np.pi * m) for m in ms], 'r--', alpha=0.5,
             linewidth=1, label='Asymptotic: 4^m/√(πm)')

ax2.set_xlabel('Parameter m (where n=m+1, d=m+2)', fontsize=13)
ax2.set_ylabel('Number of Quadratic Leaves', fontsize=13)
ax2.set_title('Exponential Growth Along the Phase Transition', fontsize=14)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_xlim(0.5, 15.5)

plt.tight_layout()
plt.savefig('viz_phase_transition.png', dpi=150, bbox_inches='tight')
print("Saved viz_phase_transition.png")


#!/usr/bin/env python3
"""
Visualization: Spectral Obstruction and Lorentzian Signature

Visualizes the spectral obstruction theorem: matrices with ≥2 positive
eigenvalues cannot have Lorentzian signature. Shows eigenvalue distributions
and the Lorentzian/non-Lorentzian boundary in spectral space.

Requires: numpy, matplotlib
"""

import numpy as np
import matplotlib.pyplot as plt


def generate_random_symmetric(n, seed=None):
    """Generate a random symmetric matrix."""
    rng = np.random.RandomState(seed)
    M = rng.randn(n, n)
    return (M + M.T) / 2


def classify_signature(eigenvalues, tol=1e-10):
    """Classify the Lorentzian signature of a matrix."""
    n_pos = np.sum(eigenvalues > tol)
    n_neg = np.sum(eigenvalues < -tol)
    n_zero = len(eigenvalues) - n_pos - n_neg
    is_lorentzian = n_pos <= 1
    return n_pos, n_neg, n_zero, is_lorentzian


# Create figure
fig, axes = plt.subplots(2, 2, figsize=(14, 12))

# Panel 1: Eigenvalue spectrum examples
ax1 = axes[0, 0]
examples = [
    ("Lorentzian\n(1 pos, 4 neg)", np.diag([3, -1, -2, -1, -3])),
    ("Non-Lorentzian\n(3 pos, 2 neg)", np.diag([3, 2, 1, -1, -2])),
    ("Negative definite\n(0 pos, 5 neg)", np.diag([-1, -2, -3, -4, -5])),
    ("Positive definite\n(5 pos, 0 neg)", np.diag([1, 2, 3, 4, 5])),
]

colors = ['#2ecc71', '#e74c3c', '#3498db', '#f39c12']
for idx, (label, A) in enumerate(examples):
    eigs = np.linalg.eigvalsh(A)
    y_pos = idx * 1.5
    for e in eigs:
        color = '#2ecc71' if e > 0 else '#e74c3c' if e < 0 else '#95a5a6'
        ax1.scatter(e, y_pos, c=color, s=150, zorder=2, edgecolors='black')
    ax1.text(-6.5, y_pos, label, fontsize=10, va='center')

ax1.axvline(x=0, color='gray', linestyle='--', alpha=0.5)
ax1.set_xlabel('Eigenvalue', fontsize=13)
ax1.set_title('Eigenvalue Spectra: Lorentzian vs Non-Lorentzian', fontsize=13)
ax1.set_yticks([])
ax1.set_xlim(-7, 7)
ax1.grid(True, alpha=0.3, axis='x')

# Panel 2: Random matrix signature distribution
ax2 = axes[0, 1]
n = 5
n_samples = 2000
pos_counts = []
rng = np.random.RandomState(42)

for _ in range(n_samples):
    M = rng.randn(n, n)
    A = (M + M.T) / 2
    eigs = np.linalg.eigvalsh(A)
    pos_counts.append(np.sum(eigs > 1e-10))

lor_frac = sum(1 for p in pos_counts if p <= 1) / n_samples

hist_data = ax2.hist(pos_counts, bins=np.arange(-0.5, n + 1.5, 1),
                      color='steelblue', alpha=0.8, edgecolor='black', density=True)
ax2.axvline(x=1.5, color='red', linestyle='--', linewidth=2,
            label=f'Lorentzian boundary\n(≤1 positive: {lor_frac:.1%})')
ax2.set_xlabel('Number of Positive Eigenvalues', fontsize=13)
ax2.set_ylabel('Density', fontsize=13)
ax2.set_title(f'Random {n}×{n} Symmetric Matrices\n'
              f'Signature Distribution (n={n})', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3, axis='y')

# Panel 3: Spectral obstruction visualization (2D quadratic form)
ax3 = axes[1, 0]

# Lorentzian matrix: one positive eigenvalue
theta = np.linspace(0, 2 * np.pi, 200)
# Show level curves of Q(x) = x^T A x for Lorentzian A
A_lor = np.array([[2, 0], [0, -1]])
for r in [0.5, 1.0, 1.5, 2.0]:
    x = r * np.cos(theta)
    y = r * np.sin(theta)
    Q = np.array([A_lor[0,0]*xi**2 + 2*A_lor[0,1]*xi*yi + A_lor[1,1]*yi**2
                  for xi, yi in zip(x, y)])
    c = ax3.scatter(x, y, c=Q, cmap='RdBu_r', s=3, vmin=-4, vmax=4)

ax3.set_xlabel('x₁', fontsize=13)
ax3.set_ylabel('x₂', fontsize=13)
ax3.set_title('Lorentzian Quadratic Form\nQ(x) = 2x₁² - x₂²\n(one positive direction)',
              fontsize=12)
ax3.set_aspect('equal')
ax3.grid(True, alpha=0.3)
plt.colorbar(c, ax=ax3, label='Q(x)')

# Panel 4: Non-Lorentzian matrix quadratic form
ax4 = axes[1, 1]

A_non = np.array([[2, 0], [0, 1]])
for r in [0.5, 1.0, 1.5, 2.0]:
    x = r * np.cos(theta)
    y = r * np.sin(theta)
    Q = np.array([A_non[0,0]*xi**2 + 2*A_non[0,1]*xi*yi + A_non[1,1]*yi**2
                  for xi, yi in zip(x, y)])
    c = ax4.scatter(x, y, c=Q, cmap='RdBu_r', s=3, vmin=-4, vmax=4)

ax4.set_xlabel('x₁', fontsize=13)
ax4.set_ylabel('x₂', fontsize=13)
ax4.set_title('Non-Lorentzian Quadratic Form\nQ(x) = 2x₁² + x₂²\n'
              '(two positive directions → obstruction)',
              fontsize=12)
ax4.set_aspect('equal')
ax4.grid(True, alpha=0.3)
plt.colorbar(c, ax=ax4, label='Q(x)')

plt.tight_layout()
plt.savefig('viz_spectral.png', dpi=150, bbox_inches='tight')
print("Saved viz_spectral.png")
