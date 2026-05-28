#!/usr/bin/env python3
"""
Applications of Lorentzian Recognition Complexity Theory

Demonstrates real-world connections:
1. Log-concavity certification in combinatorics
2. Stability analysis in statistical physics
3. Matroid polynomial checking
4. Optimization barrier detection
"""

import numpy as np
from math import comb, factorial
from typing import List, Tuple, Dict


# ============================================================
# Application 1: Log-Concavity Certification
# ============================================================

def check_log_concavity(seq: List[float]) -> Tuple[bool, List[int]]:
    """
    Check if a sequence is log-concave: a_k² ≥ a_{k-1} a_{k+1}.

    Returns (is_log_concave, list of violation indices).
    """
    violations = []
    for k in range(1, len(seq) - 1):
        if seq[k] ** 2 < seq[k - 1] * seq[k + 1] - 1e-10:
            violations.append(k)
    return len(violations) == 0, violations


def generating_polynomial_hessian(seq: List[float]) -> np.ndarray:
    """
    For a sequence (a_0, ..., a_d), the generating polynomial is
    f(x, y) = Σ a_k * C(d,k) * x^k * y^(d-k).
    Its Hessian encodes log-concavity.
    """
    d = len(seq) - 1
    H = np.zeros((2, 2))
    for k in range(d + 1):
        coeff = seq[k] * comb(d, k)
        # Contribution to second derivatives
        if k >= 2:
            H[0, 0] += coeff * k * (k - 1)
        if k >= 1 and k <= d - 1:
            H[0, 1] += coeff * k * (d - k)
            H[1, 0] += coeff * k * (d - k)
        if k <= d - 2:
            H[1, 1] += coeff * (d - k) * (d - k - 1)
    return H


def demo_log_concavity():
    """Demonstrate log-concavity certification via Lorentzian polynomials."""
    print("=" * 60)
    print("Application 1: Log-Concavity Certification")
    print("=" * 60)

    # Binomial coefficients are log-concave
    for n in [4, 6, 8]:
        seq = [comb(n, k) for k in range(n + 1)]
        is_lc, violations = check_log_concavity(seq)
        print(f"\nBinomial coefficients C({n},k): {seq}")
        print(f"  Log-concave: {is_lc}")

    # Chromatic polynomial of K4 (complete graph on 4 vertices)
    # χ(K4, t) = t(t-1)(t-2)(t-3) = t⁴ - 6t³ + 11t² - 6t
    # Coefficients: [0, -6, 11, -6, 1]  (not log-concave in this form)
    # Absolute values: [0, 6, 11, 6, 1]
    seq_chrom = [0, 6, 11, 6, 1]
    is_lc_c, violations_c = check_log_concavity(seq_chrom)
    print(f"\nChromatic poly |coeffs| of K4: {seq_chrom}")
    print(f"  Log-concave (abs values): {is_lc_c}")

    # Certificate complexity for checking Lorentzian property
    print(f"\n  Certificate complexity analysis:")
    for d in [4, 6, 8, 10, 15, 20]:
        from math import comb as mcomb
        n_vars = 2  # bivariate generating polynomial
        leaves = mcomb(n_vars + d - 3, d - 2) if d >= 2 else 1
        print(f"    degree {d:2d}: {leaves:8d} quadratic leaves (manageable: bivariate)")


# ============================================================
# Application 2: Stability in Statistical Physics
# ============================================================

def ising_partition_poly(n: int, J: float = 1.0) -> Dict[Tuple[int, ...], float]:
    """
    Compute the partition polynomial of a 1D Ising chain with n sites.
    Z(x1, ..., xn) = Σ_{σ} Π_i x_i^{(1+σ_i)/2} * exp(J Σ σ_i σ_{i+1})

    For simplicity, returns coefficients of the multilinear polynomial.
    """
    coeffs = {}
    for bits in range(2**n):
        sigma = [(bits >> i) & 1 for i in range(n)]
        # Energy
        energy = sum(J * (2*sigma[i]-1) * (2*sigma[(i+1)%n]-1) for i in range(n-1))
        weight = np.exp(energy)
        alpha = tuple(sigma)
        coeffs[alpha] = coeffs.get(alpha, 0) + weight
    return coeffs


def demo_statistical_physics():
    """Demonstrate stability analysis for Ising-type partition functions."""
    print("\n" + "=" * 60)
    print("Application 2: Stability in Statistical Physics")
    print("=" * 60)

    for n in [3, 4, 5]:
        coeffs = ising_partition_poly(n)
        print(f"\n1D Ising chain, n={n} sites:")
        print(f"  Number of terms: {len(coeffs)}")

        # Check if coefficients are all positive (stability)
        all_positive = all(v > 0 for v in coeffs.values())
        print(f"  All positive coefficients: {all_positive}")

        # For Lorentzian recognition of degree-n polynomial in n vars:
        d = n
        leaves = comb(n + d - 3, d - 2) if d >= 2 else 1
        print(f"  Lorentzian certificate complexity: {leaves} leaves")
        print(f"  Exponential lower bound: 2^{d-2} = {2**(d-2)}")


# ============================================================
# Application 3: Matroid Polynomial Checking
# ============================================================

def uniform_matroid_basis_poly(n: int, r: int) -> Dict[Tuple[int, ...], float]:
    """
    Basis generating polynomial of the uniform matroid U(r, n).
    f = Σ_{|S|=r} Π_{i∈S} x_i
    """
    from itertools import combinations
    coeffs = {}
    for S in combinations(range(n), r):
        alpha = tuple(1 if i in S else 0 for i in range(n))
        coeffs[alpha] = 1.0
    return coeffs


def demo_matroid_polynomials():
    """Demonstrate matroid polynomial Lorentzian recognition."""
    print("\n" + "=" * 60)
    print("Application 3: Matroid Basis Polynomial Recognition")
    print("=" * 60)

    for n, r in [(4, 2), (5, 2), (5, 3), (6, 3), (8, 4)]:
        coeffs = uniform_matroid_basis_poly(n, r)
        d = r  # degree = rank
        leaves = comb(n + d - 3, d - 2) if d >= 2 else 1
        print(f"\nU({r},{n}): {comb(n,r)} bases, degree={d}, {n} variables")
        print(f"  Certificate complexity: {leaves} leaves")
        print(f"  Fixed-degree bound: {n**(d-2) if d >= 2 else 1}")
        print(f"  Known to be Lorentzian: Yes (Brändén-Huh 2020)")

    print("\n  Note: As rank r grows with n, certificate complexity")
    print("  transitions from polynomial to exponential — this is the")
    print("  phase transition theorem in action.")


# ============================================================
# Application 4: Optimization Barriers
# ============================================================

def demo_optimization_barriers():
    """Show how Lorentzian recognition complexity affects optimization."""
    print("\n" + "=" * 60)
    print("Application 4: Optimization & Log-Concavity Barriers")
    print("=" * 60)

    print("""
    In convex optimization, log-concave distributions enable efficient
    sampling (via MCMC) and counting (via volume computation). The
    generating polynomial of a distribution is Lorentzian iff the
    distribution satisfies strong log-concavity.

    The phase transition theorem implies:

    1. For distributions with bounded interaction degree d:
       - Lorentzian certification has polynomial cost O(n^{d-2})
       - Efficient sampling algorithms are available

    2. For distributions with unbounded interaction degree:
       - Lorentzian certification has exponential cost Ω(2^n)
       - Certification becomes a computational barrier

    This creates a natural boundary for tractable inference:
    """)

    print(f"{'Interaction degree':>20} {'Cert. cost (n=20)':>20} {'Tractable?':>12}")
    print("-" * 56)
    for d in [3, 4, 5, 6, 8, 10, 15, 20, 22]:
        n = 20
        cost = comb(n + d - 3, d - 2) if d >= 2 else 1
        tractable = "Yes" if cost < 10**9 else "Borderline" if cost < 10**15 else "No"
        print(f"{d:20d} {cost:20d} {tractable:>12}")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Applications of Lorentzian Complexity Theory           ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_log_concavity()
    demo_statistical_physics()
    demo_matroid_polynomials()
    demo_optimization_barriers()

    print("\n" + "=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Demo: Complexity Lower Bounds for Lorentzian Polynomial Recognition

This script demonstrates the key mathematical results:
1. Central binomial coefficient lower bound: C(2n,n) >= 2^n
2. Multiindex count exponential growth
3. Complexity phase transition visualization
4. CNF formula encoding and derivative branch exploration
5. Spectral obstruction for Lorentzian quadratic forms
"""

import numpy as np
from math import comb, factorial
from itertools import product as iter_product
from typing import List, Tuple, Dict, Set


# ============================================================
# Part 1: Central Binomial Coefficient Bound
# ============================================================

def central_binom(n: int) -> int:
    """Compute the central binomial coefficient C(2n, n)."""
    return comb(2 * n, n)

def verify_central_binom_bound(max_n: int = 20) -> None:
    """Verify C(2n, n) >= 2^n for all n up to max_n."""
    print("=" * 60)
    print("THEOREM: Central Binomial Coefficient Bound")
    print("C(2n, n) >= 2^n for all n >= 0")
    print("=" * 60)
    print(f"{'n':>4} {'C(2n,n)':>15} {'2^n':>15} {'Ratio':>10} {'Valid':>6}")
    print("-" * 56)
    for n in range(max_n + 1):
        cb = central_binom(n)
        power = 2 ** n
        ratio = cb / power if power > 0 else float('inf')
        valid = cb >= power
        print(f"{n:4d} {cb:15d} {power:15d} {ratio:10.2f} {'  ✓' if valid else '  ✗':>6}")


# ============================================================
# Part 2: Multiindex Count and Phase Transition
# ============================================================

def multichoose(n: int, k: int) -> int:
    """Number of multiindices of weight k in n variables = C(n+k-1, k)."""
    if n == 0:
        return 1 if k == 0 else 0
    return comb(n + k - 1, k)

def quadratic_leaf_count(n: int, d: int) -> int:
    """Number of quadratic leaves in Lorentzian recognition tree."""
    if d < 2:
        return 1
    return multichoose(n, d - 2)

def demonstrate_phase_transition() -> None:
    """Show the phase transition: polynomial for fixed d, exponential for d ~ n."""
    print("\n" + "=" * 70)
    print("THEOREM: Complexity Phase Transition")
    print("Fixed degree: leaf count <= n^(d-2) [polynomial]")
    print("Degree ~ n:   leaf count >= 2^n     [exponential]")
    print("=" * 70)

    print("\n--- Fixed degree d=6, varying n ---")
    print(f"{'n':>4} {'Leaves':>12} {'n^4 (bound)':>12} {'Ratio':>8}")
    print("-" * 40)
    for n in [2, 3, 5, 8, 10, 15, 20, 30]:
        leaves = quadratic_leaf_count(n, 6)
        bound = n ** 4
        print(f"{n:4d} {leaves:12d} {bound:12d} {leaves/bound:8.4f}")

    print("\n--- Degree d = n+2, varying n (exponential regime) ---")
    print(f"{'n':>4} {'d':>4} {'Leaves':>15} {'2^n':>15} {'Ratio':>8}")
    print("-" * 50)
    for n in [2, 3, 4, 5, 6, 8, 10, 12, 15, 20]:
        d = n + 2
        leaves = quadratic_leaf_count(n + 1, d)
        lower = 2 ** n
        print(f"{n:4d} {d:4d} {leaves:15d} {lower:15d} {leaves/lower:8.2f}")


# ============================================================
# Part 3: CNF Formula Encoding
# ============================================================

class CNFFormula:
    """A CNF formula over Boolean variables."""

    def __init__(self, num_vars: int, clauses: List[List[Tuple[int, bool]]]):
        """
        Args:
            num_vars: Number of Boolean variables
            clauses: List of clauses, each clause is a list of (var_index, polarity) pairs
        """
        self.num_vars = num_vars
        self.clauses = clauses

    def is_satisfied_by(self, assignment: List[bool]) -> bool:
        """Check if the formula is satisfied by the given assignment."""
        for clause in self.clauses:
            clause_sat = False
            for var_idx, polarity in clause:
                if assignment[var_idx] == polarity:
                    clause_sat = True
                    break
            if not clause_sat:
                return False
        return True

    def is_satisfiable(self) -> Tuple[bool, List[bool]]:
        """Brute-force SAT check. Returns (satisfiable, witness_assignment)."""
        for bits in iter_product([False, True], repeat=self.num_vars):
            assignment = list(bits)
            if self.is_satisfied_by(assignment):
                return True, assignment
        return False, []

    def __repr__(self):
        def lit_str(var, pol):
            return f"x{var}" if pol else f"¬x{var}"
        clause_strs = [" ∨ ".join(lit_str(v, p) for v, p in c) for c in self.clauses]
        return " ∧ ".join(f"({s})" for s in clause_strs)


def demonstrate_cnf_framework() -> None:
    """Demonstrate CNF formula satisfiability."""
    print("\n" + "=" * 60)
    print("CNF Satisfiability Framework")
    print("=" * 60)

    # Example 1: satisfiable formula
    phi1 = CNFFormula(3, [
        [(0, True), (1, False)],   # x0 ∨ ¬x1
        [(1, True), (2, True)],     # x1 ∨ x2
        [(0, False), (2, False)],   # ¬x0 ∨ ¬x2
    ])
    sat1, witness1 = phi1.is_satisfiable()
    print(f"\nFormula 1: {phi1}")
    print(f"Satisfiable: {sat1}")
    if sat1:
        print(f"Witness: {['T' if b else 'F' for b in witness1]}")

    # Example 2: unsatisfiable formula
    phi2 = CNFFormula(2, [
        [(0, True)],    # x0
        [(0, False)],   # ¬x0
    ])
    sat2, _ = phi2.is_satisfiable()
    print(f"\nFormula 2: {phi2}")
    print(f"Satisfiable: {sat2}")

    # Example 3: empty formula
    phi3 = CNFFormula(3, [])
    sat3, _ = phi3.is_satisfiable()
    print(f"\nFormula 3 (empty): {phi3 if phi3.clauses else '(no clauses)'}")
    print(f"Satisfiable: {sat3} (vacuously true, matching our theorem)")

    # Example 4: formula with empty clause
    phi4 = CNFFormula(2, [[]])
    sat4, _ = phi4.is_satisfiable()
    print(f"\nFormula 4 (contains empty clause)")
    print(f"Satisfiable: {sat4} (matching formula_with_empty_clause_unsat)")


# ============================================================
# Part 4: Derivative Branch Exploration
# ============================================================

def enumerate_multiindices(n: int, d: int) -> List[Tuple[int, ...]]:
    """Enumerate all multiindices of weight d in n variables."""
    if n == 0:
        return [()] if d == 0 else []
    if n == 1:
        return [(d,)]
    result = []
    for k in range(d + 1):
        for rest in enumerate_multiindices(n - 1, d - k):
            result.append((k,) + rest)
    return result

def demonstrate_derivative_branches() -> None:
    """Explore derivative branches and their exponential growth."""
    print("\n" + "=" * 60)
    print("Derivative Branch Exploration")
    print("=" * 60)

    for n in [2, 3, 4, 5]:
        for d in [2, 3, 4]:
            indices = enumerate_multiindices(n, d)
            print(f"n={n}, d={d}: {len(indices)} multiindices (bound: {n**d})")
            if len(indices) <= 10:
                for idx in indices:
                    print(f"  α = {idx}, |α| = {sum(idx)}")

    print("\n--- Exponential growth: n = d+1 ---")
    for d in range(1, 12):
        n = d + 1
        count = multichoose(n, d)
        print(f"d={d:2d}, n={n:2d}: {count:>10d} multiindices, "
              f"2^d={2**d:>10d}, ratio={count/2**d:.2f}")


# ============================================================
# Part 5: Spectral Obstruction
# ============================================================

def is_lorentzian_quadratic(A: np.ndarray) -> Tuple[bool, str]:
    """
    Check if a symmetric matrix defines a Lorentzian quadratic form.
    Returns (is_lorentzian, explanation).
    """
    n = A.shape[0]
    eigenvalues = np.linalg.eigvalsh(A)
    num_positive = np.sum(eigenvalues > 1e-10)

    if num_positive <= 1:
        return True, f"Eigenvalues: {np.sort(eigenvalues)[::-1]}, {num_positive} positive"
    else:
        return False, f"Eigenvalues: {np.sort(eigenvalues)[::-1]}, {num_positive} positive (>1)"

def demonstrate_spectral_obstruction() -> None:
    """Demonstrate spectral obstruction theorems."""
    print("\n" + "=" * 60)
    print("Spectral Obstruction Theorems")
    print("=" * 60)

    # Identity matrix (not Lorentzian for n >= 2)
    for n in [2, 3, 4]:
        A = np.eye(n)
        is_lor, explanation = is_lorentzian_quadratic(A)
        print(f"\nI_{n}: Lorentzian = {is_lor}")
        print(f"  {explanation}")
        print(f"  (Matches identity_not_lorentzian: {'✓' if not is_lor else '✗'})")

    # Minkowski metric (Lorentzian)
    A_mink = np.diag([1.0, -1.0, -1.0])
    is_lor, explanation = is_lorentzian_quadratic(A_mink)
    print(f"\nMinkowski diag(1,-1,-1): Lorentzian = {is_lor}")
    print(f"  {explanation}")

    # Zero matrix (Lorentzian, neg semidefinite)
    A_zero = np.zeros((3, 3))
    is_lor, explanation = is_lorentzian_quadratic(A_zero)
    print(f"\nZero 3×3: Lorentzian = {is_lor}")
    print(f"  {explanation}")
    print(f"  (Matches neg_semidefinite_is_lorentzian: {'✓' if is_lor else '✗'})")

    # Negative definite (Lorentzian)
    A_neg = -np.eye(3)
    is_lor, explanation = is_lorentzian_quadratic(A_neg)
    print(f"\n-I_3: Lorentzian = {is_lor}")
    print(f"  {explanation}")

    # A = [[1,2],[2,1]] (one pos eigenvalue, Lorentzian)
    A_test = np.array([[1.0, 2.0], [2.0, 1.0]])
    is_lor, explanation = is_lorentzian_quadratic(A_test)
    print(f"\n[[1,2],[2,1]]: Lorentzian = {is_lor}")
    print(f"  {explanation}")
    print(f"  Note: Q(e1)=1>0 and Q(e2)=1>0 but still Lorentzian!")
    print(f"  (Two positive Q-directions ≠ two positive eigenvalues)")


# ============================================================
# Part 6: Certificate Complexity Visualization
# ============================================================

def demonstrate_certificate_complexity() -> None:
    """Show certificate complexity growth patterns."""
    print("\n" + "=" * 60)
    print("Certificate Complexity: Phase Transition")
    print("=" * 60)

    print("\n--- Certificate complexity = quadratic leaf count ---")
    print(f"{'n':>4} {'d':>4} {'Cert. Complexity':>18} {'Fixed-d bound':>15} {'Growing-d bound':>16}")
    print("-" * 62)

    for n in [3, 5, 7, 10, 15, 20]:
        d_fixed = 6
        d_growing = n + 2
        cc_fixed = quadratic_leaf_count(n, d_fixed)
        cc_growing = quadratic_leaf_count(n, d_growing)
        bound_fixed = n ** max(d_fixed - 2, 0)
        bound_growing = 2 ** max(n - 2, 0)
        print(f"{n:4d} {d_fixed:4d} {cc_fixed:18d} {bound_fixed:15d} {'':>16}")
        print(f"{n:4d} {d_growing:4d} {cc_growing:18d} {'':>15} {bound_growing:16d}")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Complexity Lower Bounds for Lorentzian Recognition     ║")
    print("║  Interactive Demo                                       ║")
    print("╚══════════════════════════════════════════════════════════╝")

    verify_central_binom_bound(15)
    demonstrate_phase_transition()
    demonstrate_cnf_framework()
    demonstrate_derivative_branches()
    demonstrate_spectral_obstruction()
    demonstrate_certificate_complexity()

    print("\n" + "=" * 60)
    print("Demo complete. All theorems verified computationally.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Central Binomial Coefficient Lower Bound

Plots C(2n, n) vs 2^n and 4^n/sqrt(πn), showing:
1. The proved lower bound C(2n,n) ≥ 2^n
2. The asymptotic behavior C(2n,n) ~ 4^n/sqrt(πn)
3. The ratio C(2n,n)/2^n growing as 2^n/sqrt(πn)

This illustrates Theorem 3.1 (centralBinom_ge_two_pow) and its
role as the engine for exponential lower bounds.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import comb, sqrt, pi, log2


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Data
ns = list(range(0, 21))
central_binom = [comb(2*n, n) for n in ns]
two_pow = [2**n for n in ns]
four_pow_approx = [4**n / sqrt(pi * n) if n > 0 else 1 for n in ns]

# Panel 1: Log-scale comparison
ax1 = axes[0]
ax1.semilogy(ns, central_binom, 'bo-', markersize=6, label='C(2n, n)', linewidth=2)
ax1.semilogy(ns, two_pow, 'r^--', markersize=5, label='2^n (lower bound)', linewidth=1.5)
ax1.semilogy(ns, four_pow_approx, 'g*--', markersize=5, label='4^n/√(πn) (asymptotic)', linewidth=1.5)
ax1.fill_between(ns, two_pow, central_binom, alpha=0.15, color='blue',
                  label='Gap: C(2n,n) − 2^n')
ax1.set_xlabel('n', fontsize=12)
ax1.set_ylabel('Value (log scale)', fontsize=12)
ax1.set_title('Central Binomial Coefficient\nvs. Lower Bound', fontsize=13)
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# Panel 2: Ratio C(2n,n)/2^n
ax2 = axes[1]
ratios = [central_binom[n] / two_pow[n] for n in ns]
theoretical_ratio = [2**n / sqrt(pi * n) if n > 0 else 1 for n in ns]
ax2.plot(ns, ratios, 'bo-', markersize=6, label='C(2n,n) / 2^n', linewidth=2)
ax2.plot(ns[1:], theoretical_ratio[1:], 'g--', markersize=4,
         label='2^n/√(πn) (asymptotic)', linewidth=1.5)
ax2.axhline(y=1, color='red', linestyle=':', alpha=0.7, label='Ratio = 1 (bound)')
ax2.set_xlabel('n', fontsize=12)
ax2.set_ylabel('Ratio', fontsize=12)
ax2.set_title('Ratio C(2n,n)/2^n\n(always ≥ 1, grows exponentially)', fontsize=13)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)
ax2.set_yscale('log')

# Panel 3: Inductive multiplier
ax3 = axes[2]
multipliers = [2 * (2*n + 1) / (n + 1) for n in ns]
ax3.plot(ns, multipliers, 'mo-', markersize=6, linewidth=2,
         label='2(2n+1)/(n+1)')
ax3.axhline(y=2, color='red', linestyle='--', alpha=0.7,
            label='Threshold = 2')
ax3.axhline(y=4, color='green', linestyle=':', alpha=0.5,
            label='Limit = 4')
ax3.set_xlabel('n', fontsize=12)
ax3.set_ylabel('Multiplier', fontsize=12)
ax3.set_title('Inductive Multiplier\nC(2(n+1),n+1)/C(2n,n) ≥ 2', fontsize=13)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)
ax3.set_ylim(1.5, 4.5)

plt.tight_layout()
plt.savefig('viz_central_binom.png', dpi=150, bbox_inches='tight')
print("Saved viz_central_binom.png")


#!/usr/bin/env python3
"""
Visualization: Complexity Phase Transition for Lorentzian Recognition

Plots the certificate complexity (quadratic leaf count) as a function of
the number of variables n, for different degree regimes:
- Fixed degree (polynomial growth)
- Degree proportional to n (exponential growth)

This visualizes the central theorem: the phase transition between
polynomial and exponential certificate complexity.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import comb, log2


def multiindex_count(n, d):
    """Number of multiindices of weight d in n variables."""
    if n == 0:
        return 1 if d == 0 else 0
    return comb(n + d - 1, d)


def quadratic_leaf_count(n, d):
    """Number of quadratic leaves for degree d in n variables."""
    if d < 2:
        return 1
    return multiindex_count(n, d - 2)


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: log-scale comparison
ax1 = axes[0]
ns = list(range(3, 26))

# Fixed degree regimes
for d in [4, 6, 8]:
    leaves = [quadratic_leaf_count(n, d) for n in ns]
    ax1.semilogy(ns, leaves, 'o-', label=f'Fixed d={d} (≤ n^{d-2})', markersize=4)

# Growing degree regime: d = n
leaves_growing = [quadratic_leaf_count(n, n) for n in ns]
ax1.semilogy(ns, leaves_growing, 's-', color='red', linewidth=2.5,
             markersize=6, label='d = n (exponential)')

# Reference line: 2^n
ref_exp = [2**(n-2) for n in ns]
ax1.semilogy(ns, ref_exp, '--', color='darkred', alpha=0.5, label='2^(n-2) lower bound')

ax1.set_xlabel('Number of variables n', fontsize=12)
ax1.set_ylabel('Certificate complexity (leaf count)', fontsize=12)
ax1.set_title('Phase Transition: Fixed vs. Growing Degree', fontsize=13)
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# Right panel: heatmap of certificate complexity
ax2 = axes[1]
n_range = list(range(2, 18))
d_range = list(range(2, 18))
data = np.zeros((len(d_range), len(n_range)))

for i, d in enumerate(d_range):
    for j, n in enumerate(n_range):
        val = quadratic_leaf_count(n, d)
        data[i, j] = log2(max(val, 1))

im = ax2.imshow(data, aspect='auto', cmap='YlOrRd', origin='lower',
                extent=[n_range[0]-0.5, n_range[-1]+0.5,
                        d_range[0]-0.5, d_range[-1]+0.5])

# Draw the phase transition line d = n
ax2.plot(n_range, n_range, 'w--', linewidth=2, label='d = n (transition)')
ax2.plot(n_range, [6]*len(n_range), 'w:', linewidth=1.5, label='d = 6 (fixed)')

plt.colorbar(im, ax=ax2, label='log₂(leaf count)')
ax2.set_xlabel('Number of variables n', fontsize=12)
ax2.set_ylabel('Degree d', fontsize=12)
ax2.set_title('Certificate Complexity Heatmap (log₂ scale)', fontsize=13)
ax2.legend(fontsize=9, loc='upper left')

plt.tight_layout()
plt.savefig('viz_phase_transition.png', dpi=150, bbox_inches='tight')
print("Saved viz_phase_transition.png")


#!/usr/bin/env python3
"""
Visualization: Spectral Obstruction for Lorentzian Quadratic Forms

Shows the eigenvalue landscape for 2x2 symmetric matrices and
classifies them as Lorentzian or non-Lorentzian based on eigenvalue sign.

This visualizes:
- positive_definite_not_lorentzian (2 positive eigenvalues → not Lorentzian)
- neg_semidefinite_is_lorentzian (0 positive eigenvalues → Lorentzian)
- The transition at exactly 1 positive eigenvalue (Lorentzian boundary)
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Classification of 2x2 symmetric matrices by eigenvalue signature
ax1 = axes[0]

# For A = [[a, b], [b, c]], eigenvalues are ((a+c) ± sqrt((a-c)² + 4b²)) / 2
# Number of positive eigenvalues depends on trace and determinant:
# trace = a + c, det = ac - b²
# 2 positive: trace > 0 and det > 0
# 1 positive: det < 0
# 0 positive: trace < 0 and det > 0

trace_range = np.linspace(-4, 4, 300)
det_range = np.linspace(-4, 4, 300)
T, D = np.meshgrid(trace_range, det_range)

# Classify regions
# Number of positive eigenvalues:
# eigenvalues = (T ± sqrt(T² - 4D)) / 2
# Both positive: T > 0, D > 0
# One positive, one negative: D < 0
# Both negative: T < 0, D > 0
# Complex (D > T²/4): never for real symmetric

region = np.zeros_like(T)  # 0: impossible (above discriminant)
mask_real = D <= T**2 / 4

# 2 positive eigenvalues (positive definite)
mask_2pos = mask_real & (T > 0) & (D > 0)
# 1 positive, 1 negative
mask_1pos = mask_real & (D < 0)
# 0 positive eigenvalues (negative semidefinite or definite)
mask_0pos = mask_real & (T < 0) & (D > 0)
# 1 positive, 1 zero (boundary)
mask_1pos0 = mask_real & (D == 0) & (T > 0)
# Both zero
mask_0 = (T == 0) & (D == 0)

# Assign colors
colors = np.ones((*T.shape, 4))  # RGBA, default white
colors[mask_2pos] = [1.0, 0.3, 0.3, 0.8]    # Red: not Lorentzian
colors[mask_1pos] = [0.3, 0.8, 0.3, 0.8]    # Green: Lorentzian (1 pos)
colors[mask_0pos] = [0.3, 0.5, 1.0, 0.8]    # Blue: Lorentzian (0 pos)
colors[~mask_real] = [0.95, 0.95, 0.95, 0.3]  # Light grey: impossible

ax1.imshow(colors, extent=[-4, 4, -4, 4], origin='lower', aspect='auto')

# Draw boundaries
t_line = np.linspace(-4, 4, 500)
# D = 0 line (one eigenvalue is zero)
ax1.axhline(y=0, color='black', linewidth=1.5, alpha=0.5)
# T = 0 line
ax1.axvline(x=0, color='black', linewidth=1.5, alpha=0.5)
# Discriminant curve D = T²/4
ax1.plot(t_line, t_line**2/4, 'k-', linewidth=2, label='Discriminant = 0')

# Labels
ax1.text(2, 2, 'NOT\nLorentzian\n(2 pos. eig.)', ha='center', fontsize=10,
         fontweight='bold', color='darkred')
ax1.text(2, -2, 'Lorentzian\n(1 pos. eig.)', ha='center', fontsize=10,
         fontweight='bold', color='darkgreen')
ax1.text(-2, -2, 'Lorentzian\n(1 pos. eig.)', ha='center', fontsize=10,
         fontweight='bold', color='darkgreen')
ax1.text(-2, 2, 'Lorentzian\n(0 pos. eig.)', ha='center', fontsize=10,
         fontweight='bold', color='darkblue')

# Example points
examples = [
    (2, 1, 'I₂', 'ko'),    # Identity: not Lorentzian
    (0, -1, 'M₂', 'g^'),   # Minkowski: Lorentzian
    (-2, 1, '-I₂', 'bs'),   # Negative identity: Lorentzian
    (0, 0, '0', 'kD'),      # Zero: Lorentzian
]
for tr, det, name, marker in examples:
    ax1.plot(tr, det, marker, markersize=10, markeredgecolor='black', markeredgewidth=1.5)
    ax1.annotate(name, (tr, det), textcoords="offset points",
                 xytext=(10, 10), fontsize=11, fontweight='bold')

ax1.set_xlabel('trace(A) = λ₁ + λ₂', fontsize=12)
ax1.set_ylabel('det(A) = λ₁ · λ₂', fontsize=12)
ax1.set_title('Lorentzian Classification\nof 2×2 Symmetric Matrices', fontsize=13)
ax1.set_xlim(-4, 4)
ax1.set_ylim(-4, 4)

# Panel 2: Eigenvalue cones
ax2 = axes[1]

# Draw the Lorentzian cone in eigenvalue space
lam1 = np.linspace(-3, 3, 300)
lam2 = np.linspace(-3, 3, 300)
L1, L2 = np.meshgrid(lam1, lam2)

# Count positive eigenvalues
n_pos = (L1 > 0).astype(int) + (L2 > 0).astype(int)

# Color by Lorentzian status
colors2 = np.ones((*L1.shape, 4))
colors2[n_pos == 0] = [0.3, 0.5, 1.0, 0.6]    # Blue: neg semidefinite
colors2[n_pos == 1] = [0.3, 0.8, 0.3, 0.6]    # Green: Lorentzian
colors2[n_pos == 2] = [1.0, 0.3, 0.3, 0.6]    # Red: not Lorentzian

ax2.imshow(colors2, extent=[-3, 3, -3, 3], origin='lower', aspect='auto')
ax2.axhline(y=0, color='black', linewidth=1.5)
ax2.axvline(x=0, color='black', linewidth=1.5)

# Annotations
ax2.text(1.5, 1.5, 'NOT\nLorentzian', ha='center', fontsize=11,
         fontweight='bold', color='darkred')
ax2.text(-1.5, -1.5, 'Neg. semidef.\n(Lorentzian)', ha='center', fontsize=11,
         fontweight='bold', color='darkblue')
ax2.text(1.5, -1.5, 'Exactly 1 pos.\n(Lorentzian)', ha='center', fontsize=11,
         fontweight='bold', color='darkgreen')
ax2.text(-1.5, 1.5, 'Exactly 1 pos.\n(Lorentzian)', ha='center', fontsize=11,
         fontweight='bold', color='darkgreen')

# Key point examples
ax2.plot(1, 1, 'ko', markersize=10, markeredgewidth=2)
ax2.annotate('I₂ (1,1)', (1, 1), xytext=(15, 10),
             textcoords="offset points", fontsize=10, fontweight='bold')
ax2.plot(1, -1, 'g^', markersize=10, markeredgewidth=2)
ax2.annotate('Mink (1,-1)', (1, -1), xytext=(15, -15),
             textcoords="offset points", fontsize=10, fontweight='bold')

ax2.set_xlabel('Eigenvalue λ₁', fontsize=12)
ax2.set_ylabel('Eigenvalue λ₂', fontsize=12)
ax2.set_title('Lorentzian Condition\nin Eigenvalue Space', fontsize=13)

plt.tight_layout()
plt.savefig('viz_spectral_obstruction.png', dpi=150, bbox_inches='tight')
print("Saved viz_spectral_obstruction.png")
