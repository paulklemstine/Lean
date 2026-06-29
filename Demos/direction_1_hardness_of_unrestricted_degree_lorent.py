#!/usr/bin/env python3
"""
Applications of Lorentzian Recognition Complexity Theory

Demonstrates practical applications of the formal results:
1. Optimization barrier detection via spectral tests
2. Log-concavity certification for combinatorial sequences
3. Matroid theory connections
4. Complexity classification of polynomial families

Run: python3 applications.py
"""

import math
import itertools
from typing import List, Tuple


# ═══════════════════════════════════════════════════════════════════
# Application 1: Optimization Barrier Detection
# ═══════════════════════════════════════════════════════════════════

def detect_optimization_barrier(hessian: List[List[float]]) -> dict:
    """
    Detect whether a quadratic objective has an optimization barrier
    via Lorentzian signature analysis.

    If the Hessian has Lorentzian signature (at most one positive eigenvalue),
    the objective is concave on tangent hyperplanes — a strong structural
    constraint that enables efficient optimization.

    If the Hessian is positive definite (our pos_def_not_lorentzian theorem),
    no such Lorentzian structure exists, and the optimization landscape
    may be more complex.

    Returns diagnostic information about the barrier.
    """
    n = len(hessian)
    if n != 2:
        return {'supported': False, 'reason': '2D only in this demo'}

    a, b = hessian[0][0], hessian[0][1]
    c = hessian[1][1]
    det = a * c - b * b
    trace = a + c
    disc = max(0, trace**2 - 4 * det)
    sqrt_disc = math.sqrt(disc)
    e1 = (trace + sqrt_disc) / 2
    e2 = (trace - sqrt_disc) / 2

    is_pos_def = a > 0 and c > 0 and det > 0
    is_lorentzian = not (e1 > 1e-12 and e2 > 1e-12)

    return {
        'eigenvalues': (e1, e2),
        'determinant': det,
        'is_positive_definite': is_pos_def,
        'has_lorentzian_signature': is_lorentzian,
        'optimization_implication': (
            "Lorentzian: tangent-space concavity available"
            if is_lorentzian else
            "Non-Lorentzian: no tangent-space concavity guarantee"
        )
    }


# ═══════════════════════════════════════════════════════════════════
# Application 2: Log-Concavity Certification
# ═══════════════════════════════════════════════════════════════════

def check_log_concavity_sequence(seq: List[float]) -> dict:
    """
    Check if a nonneg sequence is log-concave: a_k² ≥ a_{k-1} · a_{k+1}.

    Log-concavity is a key consequence of Lorentzianity for univariate
    specializations. If a homogeneous polynomial is Lorentzian, its
    coefficient sequence under any positive direction is log-concave.

    The certificate size for verifying Lorentzianity grows with degree,
    but log-concavity can be checked directly in O(n) time.
    """
    if any(x < 0 for x in seq):
        return {'is_log_concave': False, 'reason': 'negative entries'}

    violations = []
    for k in range(1, len(seq) - 1):
        if seq[k] * seq[k] < seq[k-1] * seq[k+1] - 1e-12:
            violations.append(k)

    return {
        'is_log_concave': len(violations) == 0,
        'violations': violations,
        'sequence_length': len(seq),
        'certificate_size': len(seq) - 2  # number of inequalities to check
    }


def binomial_coefficients(n: int) -> List[int]:
    """Return the sequence (C(n,0), C(n,1), ..., C(n,n))."""
    return [math.comb(n, k) for k in range(n + 1)]


# ═══════════════════════════════════════════════════════════════════
# Application 3: Complexity Classification
# ═══════════════════════════════════════════════════════════════════

def classify_recognition_complexity(n: int, d: int) -> dict:
    """
    Classify the complexity of Lorentzian recognition for given n, d.

    Using the formal results:
    - certificate_size_exponential_lower: lower bound 2^(d-2) when n > d-2
    - quadratic_leaf_count_le: upper bound n^(d-2)

    The phase transition occurs when d grows with n.
    """
    if d < 2:
        cert_size = 1
    else:
        cert_size = math.comb(d - 2 + n - 1, n - 1)

    if d < 2:
        regime = "trivial"
    elif d <= math.log2(n + 1) + 2:
        regime = "polynomial"
    elif d <= n:
        regime = "intermediate"
    else:
        regime = "exponential"

    return {
        'n_variables': n,
        'degree': d,
        'exact_leaf_count': cert_size,
        'upper_bound': n ** max(0, d - 2),
        'lower_bound': 2 ** max(0, d - 2) if n > d - 2 else max(1, d - 1),
        'complexity_regime': regime,
        'is_fpt': d <= 20,  # fixed-parameter tractable for bounded d
        'log_cert_size': math.log2(max(1, cert_size))
    }


# ═══════════════════════════════════════════════════════════════════
# Application 4: Matroid Independence Polynomial Analysis
# ═══════════════════════════════════════════════════════════════════

def uniform_matroid_polynomial(n: int, r: int) -> List[int]:
    """
    Compute coefficients of the independence polynomial of U_{r,n}.

    The independence polynomial of the uniform matroid U_{r,n} is
    Σ_{k=0}^{r} C(n,k) · x^k.

    By the Brändén-Huh theorem, this polynomial (homogenized) is Lorentzian.
    The log-concavity of its coefficients is a classical result (Newton's
    inequality for binomial coefficients).
    """
    return [math.comb(n, k) for k in range(r + 1)]


# ═══════════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATIONS OF LORENTZIAN RECOGNITION COMPLEXITY THEORY")
    print("=" * 70)

    # Application 1
    print("\n" + "─" * 70)
    print("APPLICATION 1: Optimization Barrier Detection")
    print("─" * 70)

    matrices = [
        ([[1, 0], [0, -1]], "Minkowski metric"),
        ([[2, 1], [1, 2]], "Positive definite"),
        ([[3, 2], [2, 1]], "Indefinite (det < 0)"),
        ([[0, 1], [1, 0]], "Hyperbolic"),
    ]

    for A, name in matrices:
        result = detect_optimization_barrier(A)
        print(f"\n  {name}: {A}")
        print(f"    Eigenvalues: {result['eigenvalues']}")
        print(f"    Lorentzian: {result['has_lorentzian_signature']}")
        print(f"    → {result['optimization_implication']}")

    # Application 2
    print("\n" + "─" * 70)
    print("APPLICATION 2: Log-Concavity Certification")
    print("─" * 70)

    for n in [5, 8, 12]:
        coeffs = binomial_coefficients(n)
        result = check_log_concavity_sequence(coeffs)
        print(f"\n  Binomial coefficients C({n}, k):")
        print(f"    Sequence: {coeffs}")
        print(f"    Log-concave: {result['is_log_concave']}")

    # Non-log-concave example
    seq = [1, 2, 1, 3, 1]
    result = check_log_concavity_sequence(seq)
    print(f"\n  Custom sequence: {seq}")
    print(f"    Log-concave: {result['is_log_concave']}")
    if result['violations']:
        print(f"    Violations at positions: {result['violations']}")

    # Application 3
    print("\n" + "─" * 70)
    print("APPLICATION 3: Complexity Classification")
    print("─" * 70)

    print("\n  Phase transition landscape:")
    print(f"  {'n':>4} {'d':>4} {'leaves':>12} {'regime':>15} {'log₂(size)':>12}")
    print("  " + "-" * 50)
    for n, d in [(10, 3), (10, 5), (10, 10), (20, 5), (20, 10), (20, 20),
                 (50, 5), (50, 10), (50, 50)]:
        result = classify_recognition_complexity(n, d)
        log_size = result['log_cert_size']
        print(f"  {n:4d} {d:4d} {result['exact_leaf_count']:12d} "
              f"{result['complexity_regime']:>15} {log_size:12.1f}")

    # Application 4
    print("\n" + "─" * 70)
    print("APPLICATION 4: Matroid Independence Polynomials")
    print("─" * 70)

    for n, r in [(6, 3), (8, 4), (10, 5)]:
        coeffs = uniform_matroid_polynomial(n, r)
        lc = check_log_concavity_sequence(coeffs)
        print(f"\n  U_{{{r},{n}}} independence polynomial:")
        print(f"    Coefficients: {coeffs}")
        print(f"    Log-concave: {lc['is_log_concave']} (guaranteed by Lorentzianity)")

    print("\n" + "=" * 70)
    print("All applications demonstrated successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Demo: Complexity Barriers for Lorentzian Polynomial Recognition

This script demonstrates the key mathematical constructions from
the formal development, including:
1. CNF formula encoding and satisfiability checking
2. Derivative tree branch counting and exponential growth
3. Spectral obstruction detection for non-Lorentzian matrices
4. Certificate complexity visualization

Run: python3 demo.py
"""

import itertools
import math
from typing import List, Tuple, Dict, Set, Optional


# ═══════════════════════════════════════════════════════════════════
# Part 1: CNF Formulas and Satisfiability
# ═══════════════════════════════════════════════════════════════════

class CNFFormula:
    """A CNF formula over n Boolean variables."""
    def __init__(self, n_vars: int, clauses: List[List[Tuple[int, bool]]]):
        self.n_vars = n_vars
        self.clauses = clauses

    def is_satisfied_by(self, assignment: Dict[int, bool]) -> bool:
        """Check if the formula is satisfied by the given assignment."""
        for clause in self.clauses:
            clause_sat = False
            for var, polarity in clause:
                if assignment.get(var, False) == polarity:
                    clause_sat = True
                    break
            if not clause_sat:
                return False
        return True

    def is_satisfiable(self) -> Tuple[bool, Optional[Dict[int, bool]]]:
        """Brute-force SAT check. Returns (is_sat, witness_or_None)."""
        for bits in itertools.product([False, True], repeat=self.n_vars):
            assignment = {i: bits[i] for i in range(self.n_vars)}
            if self.is_satisfied_by(assignment):
                return True, assignment
        return False, None

    def __repr__(self):
        def lit_str(var, pol):
            return f"x{var}" if pol else f"¬x{var}"
        clauses_str = " ∧ ".join(
            "(" + " ∨ ".join(lit_str(v, p) for v, p in c) + ")"
            for c in self.clauses
        )
        return f"CNF({self.n_vars} vars): {clauses_str}"


# ═══════════════════════════════════════════════════════════════════
# Part 2: Multiindex Counting
# ═══════════════════════════════════════════════════════════════════

def multiindex_count(n: int, d: int) -> int:
    """Count multiindices α : {0,...,n-1} → ℕ with Σα = d.
    This equals C(d+n-1, n-1) = (d+n-1)! / (d! (n-1)!)."""
    if n == 0:
        return 1 if d == 0 else 0
    return math.comb(d + n - 1, n - 1)


def quadratic_leaf_count(n: int, d: int) -> int:
    """Number of quadratic leaves in the recursive Lorentzian
    recognition tree for degree d in n variables."""
    if d < 2:
        return 1
    return multiindex_count(n, d - 2)


# ═══════════════════════════════════════════════════════════════════
# Part 3: Derivative Branch Correspondence
# ═══════════════════════════════════════════════════════════════════

def assignment_to_multiindex(assignment: Dict[int, bool], n: int) -> Tuple[int, ...]:
    """Convert a Boolean assignment to a {0,1}-valued multiindex."""
    return tuple(1 if assignment.get(i, False) else 0 for i in range(n))


def binary_branch_count(n: int) -> int:
    """Number of binary derivative branches = 2^n."""
    return 2 ** n


# ═══════════════════════════════════════════════════════════════════
# Part 4: Spectral Obstruction Detection
# ═══════════════════════════════════════════════════════════════════

def quadratic_form(A, x):
    """Compute Q_A(x) = Σ_ij A_ij x_i x_j."""
    n = len(x)
    return sum(A[i][j] * x[i] * x[j] for i in range(n) for j in range(n))


def bilinear_form(A, x, y):
    """Compute B_A(x,y) = Σ_ij A_ij x_i y_j."""
    n = len(x)
    return sum(A[i][j] * x[i] * y[j] for i in range(n) for j in range(n))


def is_lorentzian_2x2(a: float, b: float, c: float) -> bool:
    """Check if the 2×2 symmetric matrix [[a,b],[b,c]] has Lorentzian signature.
    Lorentzian = at most one positive eigenvalue.
    For 2×2: eigenvalues are ((a+c) ± √((a-c)²+4b²))/2.
    At most one positive iff det ≤ 0 or trace ≤ 0 with special cases."""
    det = a * c - b * b
    trace = a + c
    disc = (a - c) ** 2 + 4 * b * b
    sqrt_disc = math.sqrt(max(0, disc))
    e1 = (trace + sqrt_disc) / 2
    e2 = (trace - sqrt_disc) / 2
    n_positive = (1 if e1 > 1e-12 else 0) + (1 if e2 > 1e-12 else 0)
    return n_positive <= 1


def check_reversed_cauchy_schwarz(A, x, y):
    """Check B(x,y)² ≥ Q(x)·Q(y) for Lorentzian forms."""
    qx = quadratic_form(A, x)
    qy = quadratic_form(A, y)
    bxy = bilinear_form(A, x, y)
    return bxy ** 2, qx * qy, bxy ** 2 >= qx * qy - 1e-10


# ═══════════════════════════════════════════════════════════════════
# Main Demo
# ═══════════════════════════════════════════════════════════════════

def main():
    print("=" * 70)
    print("COMPLEXITY BARRIERS FOR LORENTZIAN POLYNOMIAL RECOGNITION")
    print("=" * 70)

    # Demo 1: CNF Formula Satisfiability
    print("\n" + "─" * 70)
    print("DEMO 1: CNF Formula Satisfiability")
    print("─" * 70)

    # A satisfiable formula: (x0 ∨ x1) ∧ (¬x0 ∨ x1)
    phi_sat = CNFFormula(2, [
        [(0, True), (1, True)],
        [(0, False), (1, True)]
    ])
    print(f"\nFormula: {phi_sat}")
    sat, witness = phi_sat.is_satisfiable()
    print(f"Satisfiable: {sat}")
    if witness:
        print(f"Witness: {witness}")

    # An unsatisfiable formula: (x0) ∧ (¬x0)
    phi_unsat = CNFFormula(1, [
        [(0, True)],
        [(0, False)]
    ])
    print(f"\nFormula: {phi_unsat}")
    sat, witness = phi_unsat.is_satisfiable()
    print(f"Satisfiable: {sat}")

    # Demo 2: Derivative Tree Growth
    print("\n" + "─" * 70)
    print("DEMO 2: Derivative Tree Growth — The Complexity Phase Transition")
    print("─" * 70)
    print("\n  n vars | degree d | leaves n^(d-2) | 2^(d-2)  | ratio")
    print("  " + "-" * 60)

    for d in range(2, 12):
        n = d + 1  # n grows with d
        leaves = quadratic_leaf_count(n, d)
        upper = n ** (d - 2) if d >= 2 else 1
        lower = 2 ** (d - 2) if d >= 2 else 1
        ratio = leaves / lower if lower > 0 else float('inf')
        print(f"  {n:6d} | {d:8d} | {leaves:14d} | {lower:8d} | {ratio:.2f}")

    # Demo 3: Exponential Lower Bound
    print("\n" + "─" * 70)
    print("DEMO 3: Certificate Size Exponential Lower Bound")
    print("─" * 70)
    print("\nTheorem: 2^n ≤ multiIndexCount(n+1, n)")
    print("(Binary branches inject into multiindices)")
    print("\n  n  | 2^n        | multiIndexCount(n+1, n)")
    print("  " + "-" * 45)
    for n in range(1, 16):
        mic = multiindex_count(n + 1, n)
        two_n = 2 ** n
        ok = "✓" if mic >= two_n else "✗"
        print(f"  {n:2d} | {two_n:10d} | {mic:10d}  {ok}")

    # Demo 4: Spectral Obstruction
    print("\n" + "─" * 70)
    print("DEMO 4: Spectral Obstruction Detection")
    print("─" * 70)

    # Positive definite → NOT Lorentzian
    print("\n4a. Positive definite matrix → NOT Lorentzian:")
    A_pd = [[2, 1], [1, 2]]
    lor = is_lorentzian_2x2(2, 1, 2)
    det = 2 * 2 - 1 * 1
    print(f"  A = {A_pd}, det = {det} > 0")
    print(f"  Has Lorentzian signature: {lor}")
    print(f"  (Theorem pos_def_not_lorentzian confirms: ¬Lorentzian)")

    # Lorentzian signature → reversed Cauchy-Schwarz
    print("\n4b. Lorentzian matrix — Reversed Cauchy-Schwarz:")
    A_lor = [[1, 0], [0, -1]]  # Minkowski metric
    lor = is_lorentzian_2x2(1, 0, -1)
    print(f"  A = {A_lor}")
    print(f"  Has Lorentzian signature: {lor}")

    x = [2, 1]  # Q(x) = 4 - 1 = 3 > 0
    y = [3, 1]  # Q(y) = 9 - 1 = 8 > 0
    bsq, qxqy, holds = check_reversed_cauchy_schwarz(A_lor, x, y)
    print(f"  x = {x}, y = {y}")
    print(f"  Q(x) = {quadratic_form(A_lor, x)}, Q(y) = {quadratic_form(A_lor, y)}")
    print(f"  B(x,y)² = {bsq:.1f} ≥ Q(x)·Q(y) = {qxqy:.1f}: {holds}")

    # Demo 5: Branch-Assignment Correspondence
    print("\n" + "─" * 70)
    print("DEMO 5: Branch-Assignment Correspondence")
    print("─" * 70)
    n = 4
    print(f"\n  Boolean assignments on {n} variables → {0,1}-multiindices:")
    for bits in itertools.product([False, True], repeat=n):
        assignment = {i: bits[i] for i in range(n)}
        mi = assignment_to_multiindex(assignment, n)
        weight = sum(mi)
        print(f"  τ = {bits} → α = {mi}, weight = {weight}")
    print(f"\n  Total: {2**n} assignments = 2^{n} branches")
    print(f"  All inject into multiIndexSet({n+1}, {n})")
    print(f"  |multiIndexSet({n+1}, {n})| = {multiindex_count(n+1, n)}")

    # Demo 6: Complexity Phase Transition Summary
    print("\n" + "─" * 70)
    print("DEMO 6: The Complexity Phase Transition")
    print("─" * 70)
    print("""
    Fixed degree d:
      Certificate size = O(n^(d-2))  — POLYNOMIAL in n
      → Fixed-parameter TRACTABLE

    Unbounded degree (d grows with n):
      Certificate size ≥ 2^(n-2)     — EXPONENTIAL
      → Intrinsic complexity BARRIER

    This is the central result: Lorentzian recognition has a phase transition
    from polynomial (fixed degree) to exponential (unbounded degree).
    """)

    print("=" * 70)
    print("All demos completed successfully.")
    print("=" * 70)


if __name__ == "__main__":
    main()


"""
Visualization: Derivative Tree Explosion

Shows how the derivative tree for Lorentzian recognition grows:
- For fixed degree, the tree has polynomially many leaves
- For unbounded degree, the tree explodes exponentially
- Binary branches (Boolean assignments) embed into the tree

Produces a bar chart comparing certificate sizes across regimes.
"""
import math
import matplotlib.pyplot as plt
import numpy as np


def multiindex_count(n: int, d: int) -> int:
    """C(d+n-1, n-1)"""
    if n <= 0:
        return 1 if d == 0 else 0
    return math.comb(d + n - 1, n - 1)


fig, axes = plt.subplots(2, 2, figsize=(14, 11))

# ── Panel 1: Upper vs lower bounds ──
ax = axes[0, 0]
degrees = list(range(3, 18))
n_fixed = 5

exact = [multiindex_count(n_fixed, d - 2) for d in degrees]
upper = [n_fixed ** (d - 2) for d in degrees]
lower = [d - 1 for d in degrees]

ax.semilogy(degrees, exact, 'bo-', markersize=5, label=f'Exact (n={n_fixed})')
ax.semilogy(degrees, upper, 'r^--', markersize=4, alpha=0.7, label=f'Upper: n^(d-2)={n_fixed}^(d-2)')
ax.semilogy(degrees, lower, 'gs--', markersize=4, alpha=0.7, label='Lower: d-1')
ax.set_xlabel('Degree (d)', fontsize=12)
ax.set_ylabel('Certificate size (log scale)', fontsize=12)
ax.set_title('Fixed n=5: Polynomial Growth', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# ── Panel 2: Exponential regime (d = n) ──
ax = axes[0, 1]
n_vals = list(range(3, 20))

exact_dn = [multiindex_count(n, n - 2) for n in n_vals]
exp_lower = [2 ** (n - 2) for n in n_vals]
poly_upper = [n ** (n - 2) for n in n_vals]

ax.semilogy(n_vals, exact_dn, 'bo-', markersize=5, label='Exact (d=n)')
ax.semilogy(n_vals, exp_lower, 'r^--', markersize=4, alpha=0.7, label='Lower: 2^(n-2)')
ax.semilogy(n_vals, poly_upper, 'gs--', markersize=4, alpha=0.7, label='Upper: n^(n-2)')
ax.set_xlabel('n = d (variables = degree)', fontsize=12)
ax.set_ylabel('Certificate size (log scale)', fontsize=12)
ax.set_title('Unbounded Degree: Exponential Growth', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# ── Panel 3: Binary branch embedding ──
ax = axes[1, 0]
n_vals2 = list(range(1, 16))
binary = [2 ** n for n in n_vals2]
multi = [multiindex_count(n + 1, n) for n in n_vals2]

x_pos = np.arange(len(n_vals2))
width = 0.35
bars1 = ax.bar(x_pos - width/2, binary, width, label='2^n (binary branches)',
               color='steelblue', alpha=0.8)
bars2 = ax.bar(x_pos + width/2, multi, width, label='|multiIndexSet(n+1, n)|',
               color='coral', alpha=0.8)

ax.set_yscale('log')
ax.set_xlabel('n', fontsize=12)
ax.set_ylabel('Count (log scale)', fontsize=12)
ax.set_title('Branch Embedding: 2^n ≤ multiIndexCount(n+1, n)',
             fontsize=12, fontweight='bold')
ax.set_xticks(x_pos)
ax.set_xticklabels(n_vals2)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3, axis='y')

# ── Panel 4: Ratio analysis ──
ax = axes[1, 1]
ratios_dn = []
d_for_ratio = list(range(4, 22))
for d in d_for_ratio:
    n = d + 1
    exact_val = multiindex_count(n, d - 2)
    lower_val = 2 ** (d - 2)
    if lower_val > 0:
        ratios_dn.append(exact_val / lower_val)
    else:
        ratios_dn.append(1)

ax.plot(d_for_ratio, ratios_dn, 'mo-', markersize=5)
ax.axhline(y=1, color='red', linewidth=1, linestyle='--', alpha=0.5, label='ratio = 1')
ax.set_xlabel('Degree d (with n = d+1)', fontsize=12)
ax.set_ylabel('Exact / Lower bound ratio', fontsize=12)
ax.set_title('How Tight is the Exponential Lower Bound?',
             fontsize=13, fontweight='bold')
ax.set_yscale('log')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.suptitle('Derivative Tree Explosion in Lorentzian Recognition',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('derivative_tree.png', dpi=150, bbox_inches='tight')
print("Saved: derivative_tree.png")


"""
Visualization: Complexity Phase Transition in Lorentzian Recognition

Shows how certificate size transitions from polynomial (fixed degree)
to exponential (unbounded degree) as degree grows with the number
of variables. This is the central discovery of the formal development.

Produces a heatmap of log₂(certificate size) over (n, d) space,
with the polynomial/exponential boundary clearly visible.
"""
import math
import matplotlib.pyplot as plt
import numpy as np


def multiindex_count(n: int, d: int) -> int:
    """Number of multiindices of weight d in n variables = C(d+n-1, n-1)."""
    if n <= 0:
        return 1 if d == 0 else 0
    return math.comb(d + n - 1, n - 1)


def log2_cert_size(n: int, d: int) -> float:
    """Log₂ of the quadratic leaf count = multiindex_count(n, d-2)."""
    if d < 2:
        return 0
    count = multiindex_count(n, d - 2)
    return math.log2(max(1, count))


# Create the heatmap data
n_max = 30
d_max = 30
n_vals = list(range(2, n_max + 1))
d_vals = list(range(2, d_max + 1))

data = np.zeros((len(d_vals), len(n_vals)))
for i, d in enumerate(d_vals):
    for j, n in enumerate(n_vals):
        data[i, j] = log2_cert_size(n, d)

fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Left: Heatmap
ax1 = axes[0]
im = ax1.imshow(data, aspect='auto', origin='lower',
                extent=[n_vals[0], n_vals[-1], d_vals[0], d_vals[-1]],
                cmap='inferno')
ax1.set_xlabel('Number of variables (n)', fontsize=13)
ax1.set_ylabel('Degree (d)', fontsize=13)
ax1.set_title('log₂(Certificate Size) for\nLorentzian Recognition', fontsize=14)

# Draw the d = n line (phase transition boundary)
ax1.plot([2, min(n_max, d_max)], [2, min(n_max, d_max)],
         'w--', linewidth=2, alpha=0.8, label='d = n (phase transition)')
ax1.legend(loc='upper left', fontsize=11, facecolor='black', edgecolor='white',
           labelcolor='white')

cbar = plt.colorbar(im, ax=ax1)
cbar.set_label('log₂(certificate size)', fontsize=12)

# Right: Growth curves for fixed n and growing d
ax2 = axes[1]
d_range = list(range(2, 25))

for n in [3, 5, 8, 12, 20]:
    sizes = [log2_cert_size(n, d) for d in d_range]
    ax2.plot(d_range, sizes, 'o-', markersize=3, label=f'n = {n}')

# Also plot 2^(d-2) reference line
ref = [d - 2 for d in d_range]
ax2.plot(d_range, ref, 'k--', linewidth=2, alpha=0.5, label='2^(d-2) lower bound')

ax2.set_xlabel('Degree (d)', fontsize=13)
ax2.set_ylabel('log₂(certificate size)', fontsize=13)
ax2.set_title('Certificate Size Growth\n(Fixed n, Growing d)', fontsize=14)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('phase_transition.png', dpi=150, bbox_inches='tight')
print("Saved: phase_transition.png")


"""
Visualization: Spectral Obstruction and Lorentzian Signature

Shows the geometric meaning of Lorentzian signature for 2×2 matrices:
- The quadratic form Q(v) = a*v₁² + 2b*v₁*v₂ + c*v₂² defines a conic
- Lorentzian signature ≡ at most one positive eigenvalue ≡ the conic
  has a hyperbolic or degenerate shape
- Positive definite ≡ two positive eigenvalues ≡ the conic is elliptic
  → NOT Lorentzian (pos_def_not_lorentzian theorem)

Also illustrates the reversed Cauchy-Schwarz inequality for Lorentzian forms.
"""
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch


def quadratic_form_2d(a, b, c, v1, v2):
    """Q(v) = a*v1^2 + 2*b*v1*v2 + c*v2^2."""
    return a * v1**2 + 2 * b * v1 * v2 + c * v2**2


fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# ── Panel 1: Positive definite (NOT Lorentzian) ──
ax = axes[0]
v = np.linspace(-2, 2, 400)
V1, V2 = np.meshgrid(v, v)
a, b, c = 2.0, 0.5, 2.0  # det = 4 - 0.25 = 3.75 > 0
Q = quadratic_form_2d(a, b, c, V1, V2)

contour = ax.contourf(V1, V2, Q, levels=20, cmap='RdYlBu_r', alpha=0.8)
ax.contour(V1, V2, Q, levels=[0], colors='black', linewidths=2)
ax.set_title('Positive Definite\n(NOT Lorentzian)', fontsize=13, fontweight='bold')
ax.set_xlabel('v₁')
ax.set_ylabel('v₂')
ax.set_aspect('equal')
ax.text(0.05, 0.95, f'a={a}, b={b}, c={c}\ndet={a*c-b**2:.2f} > 0\nQ > 0 everywhere',
        transform=ax.transAxes, fontsize=9, verticalalignment='top',
        bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))
plt.colorbar(contour, ax=ax, shrink=0.8, label='Q(v)')

# ── Panel 2: Lorentzian signature (Minkowski) ──
ax = axes[1]
a, b, c = 1.0, 0.0, -1.0  # det = -1 < 0, eigenvalues 1, -1
Q = quadratic_form_2d(a, b, c, V1, V2)

contour = ax.contourf(V1, V2, Q, levels=np.linspace(-3, 3, 25),
                      cmap='RdYlBu_r', alpha=0.8)
ax.contour(V1, V2, Q, levels=[0], colors='black', linewidths=2)

# Show vectors in the positive cone
x = np.array([1.5, 0.5])  # Q(x) = 1.5² - 0.5² = 2 > 0
y = np.array([1.8, 0.3])  # Q(y) = 1.8² - 0.3² > 0
ax.annotate('', xy=x, xytext=[0, 0],
            arrowprops=dict(arrowstyle='->', color='blue', lw=2))
ax.annotate('', xy=y, xytext=[0, 0],
            arrowprops=dict(arrowstyle='->', color='green', lw=2))
ax.text(x[0]+0.1, x[1]+0.1, 'x', color='blue', fontsize=12, fontweight='bold')
ax.text(y[0]+0.1, y[1]+0.1, 'y', color='green', fontsize=12, fontweight='bold')

ax.set_title('Lorentzian Signature\n(Minkowski metric)', fontsize=13, fontweight='bold')
ax.set_xlabel('v₁')
ax.set_ylabel('v₂')
ax.set_aspect('equal')
ax.text(0.05, 0.95, f'a={a}, b={b}, c={c}\ndet={a*c-b**2:.0f} < 0\nQ > 0 in light cone',
        transform=ax.transAxes, fontsize=9, verticalalignment='top',
        bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))
plt.colorbar(contour, ax=ax, shrink=0.8, label='Q(v)')

# ── Panel 3: Phase diagram of signature types ──
ax = axes[2]
a_vals = np.linspace(-2, 3, 200)
c_vals = np.linspace(-2, 3, 200)
A_grid, C_grid = np.meshgrid(a_vals, c_vals)

# For b = 0: det = a*c, eigenvalues = a, c
# Lorentzian iff at most one positive eigenvalue
n_positive = (A_grid > 0).astype(int) + (C_grid > 0).astype(int)

colors = np.zeros((*A_grid.shape, 3))
# Both negative (0 positive): blue
colors[n_positive == 0] = [0.2, 0.4, 0.8]
# Exactly one positive (Lorentzian): green
colors[n_positive == 1] = [0.2, 0.7, 0.3]
# Both positive (NOT Lorentzian): red
colors[n_positive == 2] = [0.8, 0.2, 0.2]

ax.imshow(colors, extent=[a_vals[0], a_vals[-1], c_vals[0], c_vals[-1]],
          origin='lower', aspect='auto')

ax.axhline(y=0, color='black', linewidth=0.5, alpha=0.5)
ax.axvline(x=0, color='black', linewidth=0.5, alpha=0.5)

# Labels
ax.text(1.5, 1.5, 'NOT\nLorentzian\n(pos. def.)',
        fontsize=10, ha='center', color='white', fontweight='bold')
ax.text(-1, 1.5, 'Lorentzian\n(1 pos. eig.)',
        fontsize=10, ha='center', color='white', fontweight='bold')
ax.text(1.5, -1, 'Lorentzian\n(1 pos. eig.)',
        fontsize=10, ha='center', color='white', fontweight='bold')
ax.text(-1, -1, 'Neg. semi-def.\n(0 pos. eig.)',
        fontsize=9, ha='center', color='white', fontweight='bold')

ax.set_xlabel('Eigenvalue λ₁ (= a for diagonal)', fontsize=11)
ax.set_ylabel('Eigenvalue λ₂ (= c for diagonal)', fontsize=11)
ax.set_title('Signature Phase Diagram\n(diagonal matrices, b=0)', fontsize=13, fontweight='bold')

plt.tight_layout()
plt.savefig('spectral_obstruction.png', dpi=150, bbox_inches='tight')
print("Saved: spectral_obstruction.png")
