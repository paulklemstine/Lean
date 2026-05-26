"""
Applications of Lorentzian Recognition Complexity Theory

Demonstrates practical applications of the theoretical results:
1. Estimating recognition difficulty for given polynomial parameters
2. SAT-to-branch-obstruction pipeline
3. Hessian signature analysis for optimization
4. Certificate size prediction for polynomial families
"""

import numpy as np
from math import comb, log2, factorial
from itertools import product
from typing import List, Tuple, Dict, Optional


def multiindex_count(n: int, d: int) -> int:
    """C(n+d-1, d) = number of multiindices of weight d in n variables."""
    if n == 0:
        return 1 if d == 0 else 0
    return comb(n + d - 1, d)


def quadratic_leaf_count(n: int, d: int) -> int:
    """Number of quadratic leaves in Lorentzian recognition tree."""
    if d < 2:
        return 1
    return multiindex_count(n, d - 2)


# ============================================================
# Application 1: Recognition Difficulty Estimator
# ============================================================
def recognition_difficulty(n: int, d: int) -> Dict:
    """
    Estimate the computational difficulty of Lorentzian recognition
    for a polynomial with given parameters.

    Args:
        n: Number of variables
        d: Degree of the polynomial

    Returns:
        Dict with difficulty metrics

    Example:
        >>> recognition_difficulty(10, 5)
        {'n': 10, 'd': 5, 'leaf_count': 220, ...}
    """
    leaves = quadratic_leaf_count(n, d)
    lower = 2 ** (d - 2) if n > d - 2 and d >= 2 else 1
    upper = n ** (d - 2) if d >= 2 else 1

    # Each leaf requires O(n^3) eigenvalue computation
    total_ops_estimate = leaves * n ** 3

    # Classify difficulty
    if d < 2:
        regime = "trivial"
    elif d <= 5:
        regime = "polynomial (fixed degree)"
    elif leaves < 10 ** 6:
        regime = "feasible"
    elif leaves < 10 ** 12:
        regime = "challenging"
    else:
        regime = "intractable"

    return {
        'n': n,
        'd': d,
        'leaf_count': leaves,
        'lower_bound': lower,
        'upper_bound': upper,
        'ops_estimate': total_ops_estimate,
        'log2_leaves': log2(leaves) if leaves > 0 else 0,
        'regime': regime,
    }


# ============================================================
# Application 2: SAT-to-Branch Pipeline
# ============================================================
def sat_to_branch_analysis(n_vars: int, clauses: List[List[Tuple[int, bool]]]) -> Dict:
    """
    Analyze a CNF formula through the lens of branch obstruction.

    For each assignment, finds conflicted clauses and reports statistics
    relevant to the SAT-Lorentzian correspondence.

    Args:
        n_vars: Number of variables
        clauses: CNF clauses

    Returns:
        Dict with branch analysis results
    """
    total_assignments = 2 ** n_vars
    n_obstructed = 0  # assignments with ≥1 conflicted clause
    conflict_histogram = {}  # number of conflicts → count

    for assignment in product([False, True], repeat=n_vars):
        n_conflicts = 0
        for clause in clauses:
            if all(assignment[v] != p for v, p in clause):
                n_conflicts += 1
        if n_conflicts > 0:
            n_obstructed += 1
        conflict_histogram[n_conflicts] = conflict_histogram.get(n_conflicts, 0) + 1

    is_unsat = (n_obstructed == total_assignments)

    return {
        'n_vars': n_vars,
        'n_clauses': len(clauses),
        'total_assignments': total_assignments,
        'obstructed_assignments': n_obstructed,
        'is_unsatisfiable': is_unsat,
        'obstruction_fraction': n_obstructed / total_assignments,
        'conflict_histogram': dict(sorted(conflict_histogram.items())),
    }


# ============================================================
# Application 3: Spectral Obstruction Detector
# ============================================================
def detect_spectral_obstruction(matrix: np.ndarray) -> Dict:
    """
    Analyze a symmetric matrix for Lorentzian signature properties.

    Reports eigenvalue structure, Lorentzian status, and if not Lorentzian,
    provides witness vectors forming a positive-definite subspace.

    Args:
        matrix: Symmetric matrix

    Returns:
        Dict with spectral analysis
    """
    n = matrix.shape[0]
    H = (matrix + matrix.T) / 2  # symmetrize
    eigenvalues, eigenvectors = np.linalg.eigh(H)

    pos_indices = np.where(eigenvalues > 1e-10)[0]
    n_positive = len(pos_indices)
    is_lorentzian = n_positive <= 1

    result = {
        'dimension': n,
        'eigenvalues': eigenvalues.tolist(),
        'n_positive': n_positive,
        'n_negative': int(np.sum(eigenvalues < -1e-10)),
        'n_zero': n - n_positive - int(np.sum(eigenvalues < -1e-10)),
        'is_lorentzian': is_lorentzian,
    }

    if not is_lorentzian and n_positive >= 2:
        # Provide two positive directions as obstruction witness
        v1 = eigenvectors[:, pos_indices[0]]
        v2 = eigenvectors[:, pos_indices[1]]
        result['obstruction_vectors'] = (v1.tolist(), v2.tolist())
        result['quadform_v1'] = float(v1 @ H @ v1)
        result['quadform_v2'] = float(v2 @ H @ v2)

    return result


# ============================================================
# Application 4: Certificate Size Prediction
# ============================================================
def certificate_size_analysis(n_range: range, d_modes: List[str]) -> List[Dict]:
    """
    Predict certificate sizes for different polynomial families.

    Modes:
    - "fixed_3": degree 3 (linear growth)
    - "fixed_5": degree 5 (polynomial growth)
    - "linear": degree = n (exponential growth)
    - "quadratic": degree = n^2 (super-exponential)

    Args:
        n_range: Range of variable counts
        d_modes: List of degree growth modes

    Returns:
        List of prediction records
    """
    results = []
    for n in n_range:
        for mode in d_modes:
            if mode == "fixed_3":
                d = 3
            elif mode == "fixed_5":
                d = 5
            elif mode == "linear":
                d = n
            elif mode == "quadratic":
                d = min(n * n, 30)  # cap for computation
            else:
                continue

            leaves = quadratic_leaf_count(n, d)
            results.append({
                'n': n,
                'd': d,
                'mode': mode,
                'leaves': leaves,
                'log2_leaves': log2(leaves) if leaves > 0 else 0,
            })
    return results


# ============================================================
# Main: Run all applications
# ============================================================
if __name__ == "__main__":
    print("=" * 60)
    print("Applications of Lorentzian Recognition Complexity")
    print("=" * 60)

    # App 1: Difficulty estimation
    print("\n--- Recognition Difficulty Estimator ---")
    test_cases = [(5, 3), (10, 5), (20, 10), (50, 50), (100, 4)]
    for n, d in test_cases:
        r = recognition_difficulty(n, d)
        print(f"  n={r['n']:3d}, d={r['d']:3d}: "
              f"leaves={r['leaf_count']:>12}, "
              f"log₂={r['log2_leaves']:6.1f}, "
              f"regime='{r['regime']}'")

    # App 2: SAT analysis
    print("\n--- SAT-to-Branch Pipeline ---")
    formulas = [
        ("x∧¬x", 1, [[(0, True)], [(0, False)]]),
        ("(x₀∨x₁)∧(¬x₀∨x₁)∧(x₀∨¬x₁)∧(¬x₀∨¬x₁)", 2, [
            [(0, True), (1, True)], [(0, False), (1, True)],
            [(0, True), (1, False)], [(0, False), (1, False)],
        ]),
        ("(x₀∨x₁)∧(¬x₀∨x₂)", 3, [
            [(0, True), (1, True)], [(0, False), (2, True)],
        ]),
    ]
    for name, nv, cl in formulas:
        r = sat_to_branch_analysis(nv, cl)
        print(f"  {name}: UNSAT={r['is_unsatisfiable']}, "
              f"obstruction={r['obstruction_fraction']:.1%}, "
              f"conflicts={r['conflict_histogram']}")

    # App 3: Spectral analysis
    print("\n--- Spectral Obstruction Detection ---")
    matrices = [
        ("Lorentzian", np.diag([1., -1., -1.])),
        ("Pos. definite", np.eye(3)),
        ("2 positive", np.diag([2., 1., -3.])),
    ]
    for name, A in matrices:
        r = detect_spectral_obstruction(A)
        print(f"  {name}: Lor={r['is_lorentzian']}, "
              f"eigs={[f'{e:.1f}' for e in r['eigenvalues']]}, "
              f"pos={r['n_positive']}")

    # App 4: Certificate predictions
    print("\n--- Certificate Size Predictions ---")
    results = certificate_size_analysis(range(3, 11), ["fixed_3", "linear"])
    for r in results:
        print(f"  n={r['n']:2d}, mode={r['mode']:>8s}, d={r['d']:3d}: "
              f"leaves={r['leaves']:>10}, log₂={r['log2_leaves']:6.1f}")


"""
Interactive Demo: Lorentzian Recognition Complexity

Demonstrates the key mathematical results:
1. Exponential growth of derivative tree leaves
2. Phase transition between fixed and unbounded degree
3. SAT-branch duality for CNF formulas
4. Spectral obstruction for Lorentzian signature
5. Certificate complexity bounds
"""

import numpy as np
from itertools import product
from math import comb, log2


def multiindex_count(n: int, d: int) -> int:
    """C(n+d-1, d) = number of multiindices of weight d in n variables."""
    if n == 0:
        return 1 if d == 0 else 0
    return comb(n + d - 1, d)


def quadratic_leaf_count(n: int, d: int) -> int:
    """Number of quadratic leaves in Lorentzian recognition tree."""
    if d < 2:
        return 1
    return multiindex_count(n, d - 2)


def binary_to_multiindex(b, n):
    """Encode binary string as multiindex (lower bound construction)."""
    k = len(b)
    alpha = [0] * n
    s = 0
    for i in range(k):
        alpha[i] = 1 if b[i] else 0
        s += alpha[i]
    alpha[k] = k - s
    return tuple(alpha)


def has_lorentzian_signature(matrix):
    """Check if symmetric matrix has at most one positive eigenvalue."""
    eigenvalues = np.linalg.eigvalsh(matrix)
    return int(np.sum(eigenvalues > 1e-10)) <= 1


def cnf_is_satisfiable(n_vars, clauses):
    """Brute-force SAT check. Returns (is_sat, witness_or_None)."""
    for assignment in product([False, True], repeat=n_vars):
        if all(
            any(assignment[v] == p for v, p in clause)
            for clause in clauses
        ):
            return True, assignment
    return False, None


def find_conflicted_clauses(assignment, clauses):
    """Find clauses where all literals are falsified."""
    return [
        i for i, clause in enumerate(clauses)
        if all(assignment[v] != p for v, p in clause)
    ]


# ============================================================
# DEMO 1: Exponential Lower Bound
# ============================================================
def demo_exponential_lower_bound():
    print("=" * 60)
    print("DEMO 1: Exponential Lower Bound on Leaf Count")
    print("=" * 60)
    print()
    print("The binary-to-multiindex injection proves:")
    print("  |M(n, k)| ≥ 2^k  when n > k")
    print()

    print(f"{'k':>3} {'n':>3} {'|M(n,k)|':>10} {'2^k':>10} {'n^k':>10} {'Ratio':>8}")
    print("-" * 50)
    for k in range(9):
        n = k + 1
        actual = multiindex_count(n, k)
        lb = 2 ** k
        ub = n ** k if k > 0 else 1
        ratio = actual / lb if lb > 0 else float('inf')
        print(f"{k:3d} {n:3d} {actual:10d} {lb:10d} {ub:10d} {ratio:8.2f}")

    print()
    print("Injection example (k=3, n=5):")
    print("  Binary strings → Multiindices of weight 3:")
    for bits in product([False, True], repeat=3):
        alpha = binary_to_multiindex(bits, 5)
        print(f"  {tuple(int(b) for b in bits)} → {alpha}  (sum={sum(alpha)})")


# ============================================================
# DEMO 2: Phase Transition
# ============================================================
def demo_phase_transition():
    print()
    print("=" * 60)
    print("DEMO 2: Phase Transition — Fixed vs. Growing Degree")
    print("=" * 60)
    print()
    print("Fixed degree d=3: L(n, 3) = n (linear growth)")
    print("Growing degree d=n: L(n+1, n) ≥ 2^(n-2) (exponential growth)")
    print()

    print(f"{'n':>3} {'L(n,3)':>8} {'L(n+1,n)':>12} {'2^(n-2)':>10} {'log₂(L)':>8}")
    print("-" * 45)
    for n in range(3, 14):
        fixed = quadratic_leaf_count(n, 3)
        growing = quadratic_leaf_count(n + 1, n)
        lb = 2 ** (n - 2)
        log_g = log2(growing) if growing > 0 else 0
        print(f"{n:3d} {fixed:8d} {growing:12d} {lb:10d} {log_g:8.1f}")

    print()
    print("The gap between L(n+1,n) and 2^(n-2) grows rapidly,")
    print("confirming the exponential lower bound is not tight —")
    print("actual growth is Θ(4^n / √n) by Stirling's formula.")


# ============================================================
# DEMO 3: SAT-Branch Duality
# ============================================================
def demo_sat_branch_duality():
    print()
    print("=" * 60)
    print("DEMO 3: Branch-SAT Duality")
    print("=" * 60)
    print()
    print("Theorem: φ is UNSAT ⟺ every assignment has a conflicted clause")
    print()

    examples = [
        ("Satisfiable: (x₀∨x₁) ∧ (¬x₀∨x₁)", 2, [
            [(0, True), (1, True)],
            [(0, False), (1, True)],
        ]),
        ("Unsatisfiable: (x₀) ∧ (¬x₀)", 1, [
            [(0, True)],
            [(0, False)],
        ]),
        ("Unsatisfiable: (x₀∨x₁) ∧ (¬x₀) ∧ (¬x₁)", 2, [
            [(0, True), (1, True)],
            [(0, False)],
            [(1, False)],
        ]),
        ("Satisfiable: (x₀∨¬x₁) ∧ (x₁∨¬x₂) ∧ (x₂∨¬x₀)", 3, [
            [(0, True), (1, False)],
            [(1, True), (2, False)],
            [(2, True), (0, False)],
        ]),
    ]

    for name, n_vars, clauses in examples:
        is_sat, witness = cnf_is_satisfiable(n_vars, clauses)

        all_have_conflict = True
        for assignment in product([False, True], repeat=n_vars):
            conflicts = find_conflicted_clauses(assignment, clauses)
            if len(conflicts) == 0:
                all_have_conflict = False
                break

        duality_ok = is_sat != all_have_conflict
        print(f"  {name}")
        print(f"    SAT={is_sat}, AllConflict={all_have_conflict}, "
              f"Duality={'✓' if duality_ok else '✗'}")
        if is_sat and witness:
            print(f"    Witness: {witness}")
        print()


# ============================================================
# DEMO 4: Spectral Obstruction
# ============================================================
def demo_spectral_obstruction():
    print()
    print("=" * 60)
    print("DEMO 4: Spectral Obstruction Theorem")
    print("=" * 60)
    print()
    print("Theorem: Positive-definite matrices (dim ≥ 2) are NOT Lorentzian")
    print("Theorem: 2 positive directions ⟹ not Lorentzian")
    print()

    matrices = [
        ("diag(1, -1, -1) [Lorentzian]", np.diag([1., -1., -1.])),
        ("diag(1, -1, -1, -1) [Lorentzian]", np.diag([1., -1., -1., -1.])),
        ("Identity 3×3 [Pos. def. → NOT Lor.]", np.eye(3)),
        ("diag(1, 1, -1) [2 pos → NOT Lor.]", np.diag([1., 1., -1.])),
        ("diag(0, 0, 0) [Zero → Lor. trivially]", np.zeros((3, 3))),
        ("diag(-1, -1, -1) [Neg. def. → Lor.]", np.diag([-1., -1., -1.])),
        ("diag(2, -3, -5) [Lorentzian]", np.diag([2., -3., -5.])),
    ]

    for name, A in matrices:
        eigs = np.linalg.eigvalsh(A)
        is_lor = has_lorentzian_signature(A)
        n_pos = int(np.sum(eigs > 1e-10))
        print(f"  {name}")
        print(f"    Eigenvalues: {eigs}")
        print(f"    Positive eigenvalues: {n_pos}")
        print(f"    Lorentzian signature: {is_lor}")
        print()


# ============================================================
# DEMO 5: Certificate Complexity
# ============================================================
def demo_certificate_complexity():
    print()
    print("=" * 60)
    print("DEMO 5: Certificate Complexity Bounds")
    print("=" * 60)
    print()
    print("For a degree-d polynomial in n variables:")
    print("  Lower bound: 2^(d-2)  (when n > d-2)")
    print("  Upper bound: n^(d-2)")
    print("  Exact count: C(n+d-3, d-2)")
    print()

    print(f"{'n':>3} {'d':>3} {'Exact':>10} {'Lower':>10} {'Upper':>10} {'Tight?':>8}")
    print("-" * 50)
    for n, d in [(4, 3), (5, 4), (6, 5), (10, 5), (5, 10), (8, 8), (10, 10)]:
        if d < 2:
            continue
        exact = quadratic_leaf_count(n, d)
        lower = 2 ** (d - 2) if n > d - 2 else 0
        upper = n ** (d - 2)
        tight = "Yes" if exact >= lower else "No"
        print(f"{n:3d} {d:3d} {exact:10d} {lower:10d} {upper:10d} {tight:>8}")

    print()
    print("The lower bound 2^(d-2) is always satisfied when n > d-2.")
    print("The gap between exact and upper bound shows room for improvement.")


# ============================================================
# DEMO 6: Two-Variable Exact Count
# ============================================================
def demo_two_variable_exact():
    print()
    print("=" * 60)
    print("DEMO 6: Exact Multiindex Count in 2 Variables")
    print("=" * 60)
    print()
    print("Theorem: |M(2, k)| = k + 1  for all k")
    print()

    print(f"{'k':>3} {'|M(2,k)|':>10} {'k+1':>5} {'Match':>7}")
    print("-" * 30)
    for k in range(13):
        actual = multiindex_count(2, k)
        expected = k + 1
        match = "✓" if actual == expected else "✗"
        print(f"{k:3d} {actual:10d} {expected:5d} {match:>7}")


# ============================================================
# Run all demos
# ============================================================
if __name__ == "__main__":
    demo_exponential_lower_bound()
    demo_phase_transition()
    demo_sat_branch_duality()
    demo_spectral_obstruction()
    demo_certificate_complexity()
    demo_two_variable_exact()

    print()
    print("=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


"""
Visualization: Branch-SAT Duality

Shows the correspondence between Boolean assignments and branch obstructions.
For a small CNF formula, visualizes which assignments conflict which clauses,
illustrating the Branch-SAT Duality Theorem.

Self-contained — does not import any local modules.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product

def find_conflicts(n_vars, clauses):
    """For each assignment, find conflicted clause indices."""
    assignments = list(product([False, True], repeat=n_vars))
    conflict_matrix = np.zeros((len(assignments), len(clauses)), dtype=int)

    for i, assignment in enumerate(assignments):
        for j, clause in enumerate(clauses):
            if all(assignment[v] != p for v, p in clause):
                conflict_matrix[i, j] = 1

    return assignments, conflict_matrix

# Example 1: Unsatisfiable formula
# (x₀∨x₁) ∧ (¬x₀) ∧ (¬x₁)
clauses_unsat = [
    [(0, True), (1, True)],   # x₀ ∨ x₁
    [(0, False)],              # ¬x₀
    [(1, False)],              # ¬x₁
]
clause_labels_unsat = ['x₀∨x₁', '¬x₀', '¬x₁']
assignments_u, conflicts_u = find_conflicts(2, clauses_unsat)
assign_labels_u = [f"({int(a[0])},{int(a[1])})" for a in assignments_u]

# Example 2: Satisfiable formula
# (x₀∨x₁) ∧ (¬x₀∨x₁)
clauses_sat = [
    [(0, True), (1, True)],    # x₀ ∨ x₁
    [(0, False), (1, True)],   # ¬x₀ ∨ x₁
]
clause_labels_sat = ['x₀∨x₁', '¬x₀∨x₁']
assignments_s, conflicts_s = find_conflicts(2, clauses_sat)
assign_labels_s = [f"({int(a[0])},{int(a[1])})" for a in assignments_s]

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Left: Unsatisfiable
ax = axes[0]
im = ax.imshow(conflicts_u, cmap='RdYlGn_r', aspect='auto', vmin=0, vmax=1)
ax.set_xticks(range(len(clause_labels_unsat)))
ax.set_xticklabels(clause_labels_unsat, fontsize=11)
ax.set_yticks(range(len(assign_labels_u)))
ax.set_yticklabels(assign_labels_u, fontsize=11)
ax.set_xlabel('Clauses', fontsize=12)
ax.set_ylabel('Assignment (x₀, x₁)', fontsize=12)
ax.set_title('UNSATISFIABLE\nEvery row has ≥1 conflict (red)', fontsize=12, color='red')

for i in range(conflicts_u.shape[0]):
    for j in range(conflicts_u.shape[1]):
        color = 'white' if conflicts_u[i, j] else 'black'
        text = '✗' if conflicts_u[i, j] else '✓'
        ax.text(j, i, text, ha='center', va='center', fontsize=14, color=color)

# Right: Satisfiable
ax = axes[1]
im = ax.imshow(conflicts_s, cmap='RdYlGn_r', aspect='auto', vmin=0, vmax=1)
ax.set_xticks(range(len(clause_labels_sat)))
ax.set_xticklabels(clause_labels_sat, fontsize=11)
ax.set_yticks(range(len(assign_labels_s)))
ax.set_yticklabels(assign_labels_s, fontsize=11)
ax.set_xlabel('Clauses', fontsize=12)
ax.set_ylabel('Assignment (x₀, x₁)', fontsize=12)
ax.set_title('SATISFIABLE\nSome rows have no conflict', fontsize=12, color='green')

for i in range(conflicts_s.shape[0]):
    for j in range(conflicts_s.shape[1]):
        color = 'white' if conflicts_s[i, j] else 'black'
        text = '✗' if conflicts_s[i, j] else '✓'
        ax.text(j, i, text, ha='center', va='center', fontsize=14, color=color)

    # Highlight conflict-free rows
    if np.sum(conflicts_s[i]) == 0:
        ax.add_patch(plt.Rectangle((-0.5, i - 0.5), len(clause_labels_sat), 1,
                                    fill=False, edgecolor='green', linewidth=3))

plt.suptitle('Branch-SAT Duality: Assignment-Clause Conflict Maps',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_branch_duality.png', dpi=150, bbox_inches='tight')
print("Saved viz_branch_duality.png")


"""
Visualization: Phase Transition in Lorentzian Recognition Complexity

Shows how certificate complexity transitions from polynomial (fixed degree)
to exponential (degree growing with variables). This is the central visual
of the hardness result.

Self-contained — does not import any local modules.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb, log2

def quadratic_leaf_count(n, d):
    if d < 2:
        return 1
    return comb(n + d - 3, d - 2)

# Compute data
ns = list(range(3, 16))

fixed_3 = [quadratic_leaf_count(n, 3) for n in ns]
fixed_5 = [quadratic_leaf_count(n, 5) for n in ns]
growing = [quadratic_leaf_count(n + 1, n) for n in ns]
lower_bound = [2 ** (n - 2) for n in ns]

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: Linear scale
ax = axes[0]
ax.plot(ns, fixed_3, 'b-o', label='Fixed degree d=3', markersize=5)
ax.plot(ns, fixed_5, 'g-s', label='Fixed degree d=5', markersize=5)
ax.plot(ns, growing, 'r-^', label='Growing degree d=n', markersize=5)
ax.plot(ns, lower_bound, 'k--', label='Lower bound 2^(n-2)', linewidth=1.5)
ax.set_xlabel('Number of variables n', fontsize=12)
ax.set_ylabel('Certificate size (leaf count)', fontsize=12)
ax.set_title('Certificate Complexity: Linear Scale', fontsize=13)
ax.legend(fontsize=10)
ax.set_yscale('log')
ax.grid(True, alpha=0.3)

# Right panel: Log scale showing phase transition
ax = axes[1]
log_fixed_3 = [log2(x) if x > 0 else 0 for x in fixed_3]
log_fixed_5 = [log2(x) if x > 0 else 0 for x in fixed_5]
log_growing = [log2(x) if x > 0 else 0 for x in growing]
log_lower = [n - 2 for n in ns]

ax.plot(ns, log_fixed_3, 'b-o', label='Fixed d=3: O(log n)', markersize=5)
ax.plot(ns, log_fixed_5, 'g-s', label='Fixed d=5: O(log n)', markersize=5)
ax.plot(ns, log_growing, 'r-^', label='d=n: Θ(n)', markersize=5)
ax.plot(ns, log_lower, 'k--', label='Lower bound: n-2', linewidth=1.5)

# Shade the two regimes
ax.axvspan(2.5, 15.5, alpha=0.05, color='red')
ax.text(9, max(log_growing) * 0.85, 'EXPONENTIAL\n(d grows with n)',
        ha='center', fontsize=11, color='red', fontweight='bold')
ax.text(5, max(log_fixed_5) + 1, 'POLYNOMIAL\n(d fixed)',
        ha='center', fontsize=10, color='blue')

ax.set_xlabel('Number of variables n', fontsize=12)
ax.set_ylabel('log₂(Certificate size)', fontsize=12)
ax.set_title('Phase Transition: log₂ Scale', fontsize=13)
ax.legend(fontsize=10, loc='upper left')
ax.grid(True, alpha=0.3)

plt.suptitle('Complexity Phase Transition in Lorentzian Recognition',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_phase_transition.png', dpi=150, bbox_inches='tight')
print("Saved viz_phase_transition.png")


"""
Visualization: Spectral Obstruction for Lorentzian Signature

Shows level curves of quadratic forms Q(x) = x^T A x for matrices with
different eigenvalue signatures, illustrating when Lorentzian signature
holds versus when it fails (two positive directions defeat it).

Self-contained — does not import any local modules.
"""

import numpy as np
import matplotlib.pyplot as plt

def quadratic_form(A, x, y):
    """Compute Q_A([x, y]) = x^T A [x,y] for 2D vectors."""
    return A[0, 0] * x**2 + (A[0, 1] + A[1, 0]) * x * y + A[1, 1] * y**2

fig, axes = plt.subplots(2, 2, figsize=(12, 11))

x = np.linspace(-2, 2, 300)
y = np.linspace(-2, 2, 300)
X, Y = np.meshgrid(x, y)

# Matrix configurations
configs = [
    {
        'title': 'Lorentzian Signature\ndiag(1, -1)',
        'A': np.array([[1., 0.], [0., -1.]]),
        'description': '1 positive eigenvalue ✓',
        'color': 'green',
    },
    {
        'title': 'Positive Definite (NOT Lorentzian)\ndiag(1, 1)',
        'A': np.array([[1., 0.], [0., 1.]]),
        'description': '2 positive eigenvalues ✗',
        'color': 'red',
    },
    {
        'title': 'Negative Semidefinite (Lorentzian)\ndiag(-1, -2)',
        'A': np.array([[-1., 0.], [0., -2.]]),
        'description': '0 positive eigenvalues ✓',
        'color': 'green',
    },
    {
        'title': 'Mixed Non-Lorentzian\n[[2, 1], [1, 2]]',
        'A': np.array([[2., 1.], [1., 2.]]),
        'description': '2 positive eigenvalues ✗',
        'color': 'red',
    },
]

for idx, config in enumerate(configs):
    ax = axes[idx // 2][idx % 2]
    A = config['A']

    Z = quadratic_form(A, X, Y)

    # Level curves
    levels = np.linspace(-4, 4, 17)
    cs = ax.contour(X, Y, Z, levels=levels, cmap='RdBu_r', linewidths=0.8)
    ax.contourf(X, Y, Z, levels=levels, cmap='RdBu_r', alpha=0.3)
    ax.contour(X, Y, Z, levels=[0], colors='black', linewidths=2)

    # Mark positive region
    ax.contourf(X, Y, Z, levels=[0, 100], colors=['none'], hatches=['/'],
                alpha=0)

    # Eigenvalue info
    eigs = np.linalg.eigvalsh(A)
    eigvecs = np.linalg.eigh(A)[1]

    # Draw eigenvectors
    for i in range(2):
        ev = eigvecs[:, i]
        color_arrow = 'green' if eigs[i] > 0.01 else ('red' if eigs[i] < -0.01 else 'gray')
        ax.annotate('', xy=(ev[0] * 1.5, ev[1] * 1.5),
                    xytext=(0, 0),
                    arrowprops=dict(arrowstyle='->', color=color_arrow,
                                    lw=2.5))

    ax.set_xlim(-2, 2)
    ax.set_ylim(-2, 2)
    ax.set_aspect('equal')
    ax.set_xlabel('x₁', fontsize=11)
    ax.set_ylabel('x₂', fontsize=11)
    ax.set_title(config['title'], fontsize=11, color=config['color'],
                 fontweight='bold')
    ax.text(0.02, 0.98, config['description'],
            transform=ax.transAxes, fontsize=9,
            verticalalignment='top',
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

    ax.axhline(y=0, color='gray', linewidth=0.5)
    ax.axvline(x=0, color='gray', linewidth=0.5)
    ax.grid(True, alpha=0.2)

plt.suptitle('Spectral Obstruction: Quadratic Form Level Curves\n'
             'Green arrows = positive eigendirections, '
             'Red arrows = negative eigendirections',
             fontsize=13, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_spectral_obstruction.png', dpi=150, bbox_inches='tight')
print("Saved viz_spectral_obstruction.png")
