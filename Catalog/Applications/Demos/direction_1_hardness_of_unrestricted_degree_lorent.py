#!/usr/bin/env python3
"""
applications.py — Applications of Lorentzian recognition complexity results.

Demonstrates real-world connections:
1. Log-concavity verification for combinatorial sequences
2. Certificate complexity for optimization barriers
3. SAT instance analysis through multiindex lens
"""

from math import comb, factorial, log2
from itertools import product as iterproduct
from typing import List, Tuple, Dict
import numpy as np


def multiindex_count(n: int, d: int) -> int:
    """Stars-and-bars count."""
    if n == 0:
        return 1 if d == 0 else 0
    return comb(n + d - 1, d)


def number_of_quadratic_leaves(n: int, d: int) -> int:
    """Number of leaves in Lorentzian recognition tree."""
    return 1 if d < 2 else multiindex_count(n, d - 2)


# ============================================================
# Application 1: Log-Concavity Verification Complexity
# ============================================================

def log_concavity_certificate_analysis():
    """Analyze the complexity of verifying log-concavity via Lorentzian certificates.
    
    Many important combinatorial sequences (chromatic polynomials, matching
    polynomials, characteristic polynomials of matroids) are conjectured or
    proved to be log-concave. Lorentzian polynomials provide certificates
    for log-concavity. This function analyzes how the certificate size
    grows for typical combinatorial applications.
    """
    print("="*60)
    print("APPLICATION 1: Log-Concavity Certificate Complexity")
    print("="*60)
    
    # Complete graph chromatic polynomial: degree n-1, n variables
    print("\nChromatic polynomial of K_n (complete graph on n vertices):")
    print(f"  Degree = n-1, Variables = n")
    print(f"  {'n':>4} | {'degree':>6} | {'leaves':>12} | {'log2(leaves)':>12}")
    print(f"  {'-'*4}-+-{'-'*6}-+-{'-'*12}-+-{'-'*12}")
    for n in range(3, 16):
        d = n - 1
        leaves = number_of_quadratic_leaves(n, d)
        log_leaves = log2(leaves) if leaves > 0 else 0
        print(f"  {n:>4} | {d:>6} | {leaves:>12,} | {log_leaves:>12.1f}")
    
    # Matroid characteristic polynomial
    print("\nMatroid rank r with n elements (degree = r, vars = n):")
    print(f"  {'n':>4} | {'r':>4} | {'leaves':>12} | {'tractable?':>10}")
    print(f"  {'-'*4}-+-{'-'*4}-+-{'-'*12}-+-{'-'*10}")
    for n in [5, 10, 20, 50, 100]:
        for r in [3, 5, n//2]:
            if r < 2:
                continue
            leaves = number_of_quadratic_leaves(n, r)
            tractable = "Yes" if leaves < 10**6 else "Marginal" if leaves < 10**9 else "No"
            print(f"  {n:>4} | {r:>4} | {leaves:>12,} | {tractable:>10}")


# ============================================================
# Application 2: Optimization Barrier Analysis  
# ============================================================

def optimization_barrier_analysis():
    """Analyze how Lorentzian certificate complexity creates barriers
    for convexity certification in optimization.
    
    The tangent-space negativity theorem (from the catalog) connects
    Lorentzian signature to convexity. This means certifying convexity
    via the Lorentzian route has complexity governed by our lower bounds.
    """
    print("\n" + "="*60)
    print("APPLICATION 2: Optimization Convexity Barriers")
    print("="*60)
    
    print("\nScenario: Certifying convexity of degree-d barriers in n dimensions")
    print("The Lorentzian route requires checking all quadratic leaves.")
    print()
    
    scenarios = [
        ("Portfolio optimization (10 assets, cubic)", 10, 3),
        ("Sensor network (20 nodes, quartic)", 20, 4),
        ("Neural network (50 params, degree 6)", 50, 6),
        ("Quantum state (100 qubits, degree 8)", 100, 8),
        ("Climate model (200 vars, degree 10)", 200, 10),
        ("Protein folding (500 residues, degree 12)", 500, 12),
    ]
    
    print(f"  {'Scenario':<45} | {'Leaves':>12} | {'Feasible?':>10}")
    print(f"  {'-'*45}-+-{'-'*12}-+-{'-'*10}")
    for desc, n, d in scenarios:
        leaves = number_of_quadratic_leaves(n, d)
        if leaves < 10**6:
            feasible = "Easy"
        elif leaves < 10**9:
            feasible = "Hard"
        elif leaves < 10**15:
            feasible = "Very hard"
        else:
            feasible = "Infeasible"
        leaves_str = f"{leaves:,}" if leaves < 10**15 else f"{leaves:.2e}"
        print(f"  {desc:<45} | {leaves_str:>12} | {feasible:>10}")


# ============================================================
# Application 3: SAT Complexity Through Multiindex Lens
# ============================================================

def sat_multiindex_analysis():
    """Analyze SAT instance structure through the multiindex encoding.
    
    Each Boolean assignment to n variables becomes a multiindex in 2n variables.
    The distribution of satisfying vs unsatisfying assignments in multiindex
    space reveals structure about the SAT instance.
    """
    print("\n" + "="*60)
    print("APPLICATION 3: SAT Analysis via Multiindex Encoding")
    print("="*60)
    
    def assignment_to_multiindex(tau):
        result = []
        for b in tau:
            result.extend([1, 0] if b else [0, 1])
        return tuple(result)
    
    # Example: Random 3-SAT instances
    import random
    random.seed(42)
    
    for n in [4, 5, 6]:
        m = int(4.26 * n)  # Near the SAT threshold
        
        # Generate random 3-SAT
        clauses = []
        for _ in range(m):
            vars_chosen = random.sample(range(n), 3)
            clause = [(v, random.choice([True, False])) for v in vars_chosen]
            clauses.append(clause)
        
        # Count satisfying assignments
        sat_count = 0
        sat_multiindices = []
        unsat_multiindices = []
        
        for tau in iterproduct([False, True], repeat=n):
            satisfied = True
            for clause in clauses:
                if not any(tau[v] == p for v, p in clause):
                    satisfied = False
                    break
            
            mi = assignment_to_multiindex(tau)
            if satisfied:
                sat_count += 1
                sat_multiindices.append(mi)
            else:
                unsat_multiindices.append(mi)
        
        total = 2**n
        frac = sat_count / total
        
        print(f"\nRandom 3-SAT: n={n}, m={m}, ratio={m/n:.2f}")
        print(f"  Total assignments: {total}")
        print(f"  Satisfying: {sat_count} ({frac:.1%})")
        print(f"  Multiindex space: {2*n} dimensions, weight {n}")
        print(f"  Total multiindices of weight {n}: {multiindex_count(2*n, n)}")
        print(f"  Encoded SAT assignments: {sat_count}/{multiindex_count(2*n, n)} "
              f"({sat_count/multiindex_count(2*n, n):.1%} of space)")


# ============================================================
# Application 4: Complexity Phase Transition Map
# ============================================================

def phase_transition_map():
    """Map the complexity phase transition in the (n, d) plane.
    
    Shows where recognition transitions from tractable to hard.
    """
    print("\n" + "="*60)
    print("APPLICATION 4: Complexity Phase Transition")
    print("="*60)
    
    print("\nLeaf count classification in the (n, d) plane:")
    print("  T = Trivial (<100), M = Moderate (<10^6), H = Hard (<10^12), X = Extreme")
    print()
    
    hdr = 'n\\d'
    print(f"  {hdr:>4}", end="")
    for d in range(2, 21):
        print(f" {d:>3}", end="")
    print()
    print("  " + "-" * 62)
    
    for n in range(2, 16):
        print(f"  {n:>4}", end="")
        for d in range(2, 21):
            leaves = number_of_quadratic_leaves(n, d)
            if leaves < 100:
                c = "  T"
            elif leaves < 10**6:
                c = "  M"
            elif leaves < 10**12:
                c = "  H"
            else:
                c = "  X"
            print(c, end="")
        print()
    
    print("\n  The phase transition boundary runs diagonally:")
    print("  tractability requires d = O(log n / log log n)")


if __name__ == "__main__":
    log_concavity_certificate_analysis()
    optimization_barrier_analysis()
    sat_multiindex_analysis()
    phase_transition_map()


#!/usr/bin/env python3
"""
demo.py — Interactive demonstration of Lorentzian recognition complexity barriers.

Demonstrates the key theorems:
1. Multiindex counting and leaf growth
2. Boolean assignment → multiindex encoding
3. CNF formula encoding and branch exploration
4. Certificate size computation and exponential barrier
"""

from math import comb, factorial
from itertools import product as iterproduct
from typing import List, Tuple, Dict, Optional
import numpy as np


def multiindex_count(n: int, d: int) -> int:
    """Exact count of multiindices of weight d in n variables.
    Uses stars-and-bars: C(n + d - 1, d)."""
    if n == 0:
        return 1 if d == 0 else 0
    return comb(n + d - 1, d)


def number_of_quadratic_leaves(n: int, d: int) -> int:
    """Number of quadratic leaves in recursive Lorentzian recognition."""
    if d < 2:
        return 1
    return multiindex_count(n, d - 2)


def enumerate_multiindices(n: int, d: int) -> List[Tuple[int, ...]]:
    """Enumerate all multiindices alpha : {0,...,n-1} -> N with sum = d."""
    if n == 0:
        return [()] if d == 0 else []
    if n == 1:
        return [(d,)]
    result = []
    for k in range(d + 1):
        for rest in enumerate_multiindices(n - 1, d - k):
            result.append((k,) + rest)
    return result


def assignment_to_multiindex(tau: Tuple[bool, ...]) -> Tuple[int, ...]:
    """Encode a Boolean assignment as a multiindex in 2n variables.
    
    Maps tau : {0,...,n-1} -> Bool to alpha : {0,...,2n-1} -> N where:
    - alpha(2i) = 1 if tau(i) = True, else 0
    - alpha(2i+1) = 0 if tau(i) = True, else 1
    Total weight = n.
    """
    result = []
    for b in tau:
        result.append(1 if b else 0)
        result.append(0 if b else 1)
    return tuple(result)


def binary_to_multiindex(f: Tuple[bool, ...], n: int, d: int) -> Tuple[int, ...]:
    """Injection from binary strings to multiindices.
    
    f : Fin m -> Bool maps to alpha : Fin n -> N with sum = d.
    First m coordinates are 0/1 from f, coordinate m gets the slack,
    remaining coordinates are 0.
    """
    m = len(f)
    assert m < n and m <= d
    bits = [1 if b else 0 for b in f]
    slack = d - sum(bits)
    return tuple(bits + [slack] + [0] * (n - m - 1))


class CNFFormula:
    """A CNF formula with n variables and m clauses."""
    
    def __init__(self, n: int, clauses: List[List[Tuple[int, bool]]]):
        self.n = n
        self.clauses = clauses
        self.m = len(clauses)
    
    def is_satisfied_by(self, tau: Tuple[bool, ...]) -> bool:
        """Check if assignment tau satisfies this formula."""
        for clause in self.clauses:
            if not any(tau[var] == pol for var, pol in clause):
                return False
        return True
    
    def all_satisfying(self) -> List[Tuple[bool, ...]]:
        """Find all satisfying assignments."""
        result = []
        for tau in iterproduct([False, True], repeat=self.n):
            if self.is_satisfied_by(tau):
                result.append(tau)
        return result
    
    def is_satisfiable(self) -> bool:
        return len(self.all_satisfying()) > 0
    
    def sat_count(self) -> int:
        return len(self.all_satisfying())


def compute_hessian(coefficients: Dict[Tuple[int, ...], float], n: int) -> np.ndarray:
    """Compute the Hessian matrix of a polynomial given as coefficient dict.
    H[i][j] = coefficient of x_i * x_j after taking d²/dx_i dx_j.
    For a homogeneous degree-2 polynomial, this captures all information.
    """
    H = np.zeros((n, n))
    for mono, coeff in coefficients.items():
        if sum(mono) != 2:
            continue
        for i in range(n):
            for j in range(n):
                alpha = list(mono)
                if alpha[i] > 0:
                    factor_i = alpha[i]
                    alpha[i] -= 1
                    if alpha[j] > 0:
                        factor_j = alpha[j]
                        H[i][j] += coeff * factor_i * factor_j
                    alpha[i] += 1
    return H


def has_lorentzian_signature(H: np.ndarray) -> bool:
    """Check if a symmetric matrix has at most one positive eigenvalue."""
    eigenvalues = np.linalg.eigvalsh(H)
    return sum(1 for ev in eigenvalues if ev > 1e-10) <= 1


def explore_derivative_tree(n: int, d: int, max_display: int = 20):
    """Explore and display the derivative tree structure."""
    leaves = enumerate_multiindices(n, d - 2) if d >= 2 else [()]
    print(f"\n{'='*60}")
    print(f"Derivative Tree: n={n} variables, degree d={d}")
    print(f"{'='*60}")
    print(f"Number of quadratic leaves: {len(leaves)}")
    print(f"Upper bound n^(d-2): {n**(d-2) if d >= 2 else 1}")
    print(f"Lower bound 2^((d-2)/2): {2**((d-2)//2) if d >= 4 else 'N/A'}")
    print(f"\nFirst {min(max_display, len(leaves))} leaves:")
    for i, leaf in enumerate(leaves[:max_display]):
        print(f"  α_{i} = {leaf}, weight = {sum(leaf)}")
    if len(leaves) > max_display:
        print(f"  ... ({len(leaves) - max_display} more)")


def demo_theorem_a():
    """Demonstrate Theorem A: linear lower bound."""
    print("\n" + "="*60)
    print("THEOREM A: Linear Lower Bound")
    print("numberOfQuadraticLeaves(n, d) >= d - 1 for n >= 2, d >= 2")
    print("="*60)
    
    for n in [2, 3, 5, 10]:
        print(f"\nn = {n}:")
        print(f"  {'d':>4} | {'leaves':>10} | {'d-1':>6} | {'n^(d-2)':>10} | satisfies?")
        print(f"  {'-'*4}-+-{'-'*10}-+-{'-'*6}-+-{'-'*10}-+-{'-'*10}")
        for d in range(2, 12):
            leaves = number_of_quadratic_leaves(n, d)
            lower = d - 1
            upper = n ** (d - 2) if d >= 2 else 1
            ok = "✓" if leaves >= lower else "✗"
            print(f"  {d:>4} | {leaves:>10} | {lower:>6} | {upper:>10} | {ok}")


def demo_theorem_b():
    """Demonstrate Theorem B: exponential lower bound."""
    print("\n" + "="*60)
    print("THEOREM B: Exponential Lower Bound")
    print("multiIndexCount(n, d) >= 2^(d/2) for n > d/2")
    print("="*60)
    
    print(f"\n{'d':>4} | {'n=d':>4} | {'count':>10} | {'2^(d/2)':>10} | {'ratio':>8}")
    print(f"{'-'*4}-+-{'-'*4}-+-{'-'*10}-+-{'-'*10}-+-{'-'*8}")
    for d in range(2, 16):
        n = d
        count = multiindex_count(n, d)
        lower = 2 ** (d // 2)
        ratio = count / lower if lower > 0 else float('inf')
        print(f"{d:>4} | {n:>4} | {count:>10} | {lower:>10} | {ratio:>8.1f}")


def demo_theorem_c():
    """Demonstrate Theorem C: Boolean encoding bridge."""
    print("\n" + "="*60)
    print("THEOREM C: Boolean Assignment → Multiindex Encoding")
    print("multiIndexCount(2n, n) >= 2^n")
    print("="*60)
    
    for n in range(1, 6):
        assignments = list(iterproduct([False, True], repeat=n))
        multiindices = [assignment_to_multiindex(tau) for tau in assignments]
        
        # Verify injectivity
        unique = len(set(multiindices))
        all_weight_n = all(sum(mi) == n for mi in multiindices)
        
        print(f"\nn = {n}: {len(assignments)} assignments → {unique} distinct multiindices")
        print(f"  All weight {n}? {all_weight_n}")
        print(f"  multiIndexCount(2n={2*n}, n={n}) = {multiindex_count(2*n, n)}")
        print(f"  2^n = {2**n}")
        
        if n <= 3:
            for tau, mi in zip(assignments, multiindices):
                tau_str = ''.join('T' if b else 'F' for b in tau)
                print(f"    τ=({tau_str}) → α={mi}")


def demo_cnf_encoding():
    """Demonstrate CNF formula encoding and branch structure."""
    print("\n" + "="*60)
    print("CNF FORMULA ENCODING")
    print("="*60)
    
    # Example: (x0 ∨ x1) ∧ (¬x0 ∨ x2) ∧ (¬x1 ∨ ¬x2)
    phi = CNFFormula(3, [
        [(0, True), (1, True)],
        [(0, False), (2, True)],
        [(1, False), (2, False)]
    ])
    
    print(f"\nFormula: (x₀ ∨ x₁) ∧ (¬x₀ ∨ x₂) ∧ (¬x₁ ∨ ¬x₂)")
    print(f"Variables: {phi.n}, Clauses: {phi.m}")
    print(f"Satisfiable: {phi.is_satisfiable()}")
    print(f"Number of satisfying assignments: {phi.sat_count()}")
    
    print(f"\nAll assignments and their multiindex encodings:")
    for tau in iterproduct([False, True], repeat=phi.n):
        mi = assignment_to_multiindex(tau)
        sat = phi.is_satisfied_by(tau)
        tau_str = ''.join('T' if b else 'F' for b in tau)
        print(f"  τ=({tau_str}) → α={mi}, weight={sum(mi)}, satisfies={sat}")
    
    # Unsatisfiable example
    print(f"\nUnsatisfiable formula: (x₀) ∧ (¬x₀)")
    phi2 = CNFFormula(1, [
        [(0, True)],
        [(0, False)]
    ])
    print(f"Satisfiable: {phi2.is_satisfiable()}")
    print(f"SAT count: {phi2.sat_count()}")


def demo_certificate_complexity():
    """Demonstrate certificate complexity and the superpolynomial barrier."""
    print("\n" + "="*60)
    print("CERTIFICATE COMPLEXITY BARRIER")
    print("For any polynomial bound n^c, there exist n, d with")
    print("numberOfQuadraticLeaves(n, d) > n^c")
    print("="*60)
    
    for c in [2, 3, 5, 10]:
        print(f"\nc = {c}: looking for n, d with leaves > n^{c}")
        found = False
        for n in range(2, 50):
            d = 2 * n
            leaves = number_of_quadratic_leaves(n, d)
            bound = n ** c
            if leaves > bound:
                print(f"  Found: n={n}, d={d}, leaves={leaves:,} > n^{c}={bound:,}")
                found = True
                break
        if not found:
            print(f"  (not found in range, but guaranteed by theorem)")


def demo_visualization_data():
    """Generate data for the branch growth visualization."""
    print("\n" + "="*60)
    print("BRANCH GROWTH DATA")
    print("="*60)
    
    header = 'n\\d'
    print(f"\n{header:>4}", end="")
    for d in range(2, 13):
        print(f" | {d:>8}", end="")
    print()
    print("-" * 120)
    
    for n in range(2, 11):
        print(f"{n:>4}", end="")
        for d in range(2, 13):
            leaves = number_of_quadratic_leaves(n, d)
            if leaves < 10**7:
                print(f" | {leaves:>8}", end="")
            else:
                print(f" | {leaves:>8.2e}", end="")
        print()


if __name__ == "__main__":
    print("="*60)
    print("LORENTZIAN RECOGNITION COMPLEXITY BARRIERS")
    print("Interactive Demonstration")
    print("="*60)
    
    demo_theorem_a()
    demo_theorem_b()
    demo_theorem_c()
    demo_cnf_encoding()
    demo_certificate_complexity()
    demo_visualization_data()
    
    print("\n" + "="*60)
    print("SUMMARY")
    print("="*60)
    print("""
Key findings demonstrated:
1. Leaf count grows at least linearly in d (Theorem A)
2. Leaf count grows exponentially when n ~ d (Theorem B)  
3. Boolean assignments inject into multiindices (Theorem C)
4. No polynomial bound suffices for unbounded degree (Theorem D)
5. CNF formulas can be encoded into the branch structure

These results establish that Lorentzian polynomial recognition
exhibits a complexity phase transition: tractable for fixed degree,
exponentially hard for unbounded degree.
""")


#!/usr/bin/env python3
"""
Visualization: Boolean Assignment to Multiindex Encoding

Visualizes the injection from Boolean assignments on n variables to
multiindices in 2n variables. Shows how the encoding maps satisfying
and unsatisfying assignments of a CNF formula to distinct points in
multiindex space.

This illustrates Theorem C: the cross-domain bridge between
satisfiability and derivative-tree structure.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product as iterproduct
from math import comb


def assignment_to_multiindex(tau):
    """Encode Boolean assignment as multiindex in 2n variables."""
    result = []
    for b in tau:
        result.extend([1, 0] if b else [0, 1])
    return tuple(result)


def multiindex_count(n, d):
    if n == 0:
        return 1 if d == 0 else 0
    return comb(n + d - 1, d)


fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: Encoding visualization for n=3
ax1 = axes[0]
n = 3
assignments = list(iterproduct([False, True], repeat=n))
multiindices = [assignment_to_multiindex(tau) for tau in assignments]

# Use first two principal components for visualization
mi_array = np.array(multiindices, dtype=float)
# Simple 2D projection: sum of even indices vs sum of odd indices
x_proj = mi_array[:, 0::2].sum(axis=1)  # "true" dimensions
y_proj = mi_array[:, 1::2].sum(axis=1)  # "false" dimensions

# CNF formula: (x0 ∨ x1) ∧ (¬x0 ∨ x2) ∧ (¬x1 ∨ ¬x2)
def check_sat(tau):
    clauses = [
        [(0, True), (1, True)],
        [(0, False), (2, True)],
        [(1, False), (2, False)]
    ]
    for clause in clauses:
        if not any(tau[v] == p for v, p in clause):
            return False
    return True

colors = ['green' if check_sat(tau) else 'red' for tau in assignments]
markers = ['o' if check_sat(tau) else 'x' for tau in assignments]

for i, (x, y, c, tau) in enumerate(zip(x_proj, y_proj, colors, assignments)):
    label_str = ''.join('1' if b else '0' for b in tau)
    marker = 'o' if check_sat(tau) else 'X'
    ax1.scatter(x, y, c=c, s=150, marker=marker, edgecolors='black', linewidths=1, zorder=5)
    ax1.annotate(label_str, (x, y), textcoords="offset points",
                xytext=(8, 8), fontsize=8, fontweight='bold')

ax1.set_xlabel('# True assignments (Σ α_{2i})', fontsize=11)
ax1.set_ylabel('# False assignments (Σ α_{2i+1})', fontsize=11)
ax1.set_title('Boolean → Multiindex Encoding\n(n=3, green=SAT, red=UNSAT)', fontsize=12)
ax1.grid(True, alpha=0.3)

# Add line x + y = n
xx = np.linspace(-0.5, n + 0.5, 100)
ax1.plot(xx, n - xx, 'b--', alpha=0.3, label=f'x + y = {n}')
ax1.legend(fontsize=9)

# Panel 2: Encoding density — how many multiindices are "used"
ax2 = axes[1]
ns = list(range(1, 13))
used = [2**nn for nn in ns]
total = [multiindex_count(2*nn, nn) for nn in ns]
density = [u/t for u, t in zip(used, total)]

ax2.semilogy(ns, total, 'b^-', label='Total multiindices C(2n, n)', markersize=6)
ax2.semilogy(ns, used, 'ro-', label='Boolean assignments 2^n', markersize=6)

ax2.set_xlabel('Number of Boolean variables n', fontsize=11)
ax2.set_ylabel('Count (log scale)', fontsize=11)
ax2.set_title('Encoding Density:\nAssignments vs Total Multiindices', fontsize=12)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# Panel 3: Density ratio
ax3 = axes[2]
ax3.plot(ns, [d * 100 for d in density], 'ko-', markersize=6, linewidth=2)
ax3.axhline(y=100, color='gray', linestyle='--', alpha=0.5, label='100% density')

ax3.set_xlabel('Number of Boolean variables n', fontsize=11)
ax3.set_ylabel('Encoding density (%)', fontsize=11)
ax3.set_title('Fraction of Multiindex Space\nUsed by Boolean Encoding', fontsize=12)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)
ax3.set_ylim(0, 110)

plt.suptitle('Cross-Domain Bridge: Boolean Satisfiability ↔ Derivative Trees',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_boolean_encoding.png', dpi=150, bbox_inches='tight')
print("Saved viz_boolean_encoding.png")


#!/usr/bin/env python3
"""
Visualization: Certificate Complexity Barrier

Visualizes the superpolynomial barrier theorem: for any polynomial bound n^c,
there exist parameters where the Lorentzian certificate complexity exceeds it.
Shows the "impossible region" where polynomial-time recognition fails.

This illustrates Theorem D: unbounded degree forces superpolynomial complexity.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb, log2, log10


def multiindex_count(n, d):
    if n == 0:
        return 1 if d == 0 else 0
    return comb(n + d - 1, d)


def number_of_quadratic_leaves(n, d):
    return 1 if d < 2 else multiindex_count(n, d - 2)


fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: Leaf count vs polynomial bounds
ax1 = axes[0]
ns = list(range(2, 25))

# Balanced regime: d = 2n
leaves_balanced = [number_of_quadratic_leaves(n, 2*n) for n in ns]
ax1.semilogy(ns, leaves_balanced, 'ko-', label='Leaves (d=2n)', markersize=5, linewidth=2)

# Polynomial bounds
for c, color in [(2, 'blue'), (3, 'green'), (5, 'orange'), (10, 'red')]:
    bounds = [n**c for n in ns]
    ax1.semilogy(ns, bounds, f'{color[0]}--', label=f'n^{c}', linewidth=1.5, alpha=0.7)

ax1.set_xlabel('Number of variables n', fontsize=12)
ax1.set_ylabel('Count (log scale)', fontsize=12)
ax1.set_title('Certificate Size vs Polynomial Bounds\n(d = 2n regime)', fontsize=13)
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# Panel 2: The crossing points — when exponential overtakes polynomial
ax2 = axes[1]

crossing_data = []
for c in range(1, 16):
    for n in range(2, 100):
        leaves = number_of_quadratic_leaves(n, 2*n)
        if leaves > n**c:
            crossing_data.append((c, n))
            break

cs, crossing_ns = zip(*crossing_data) if crossing_data else ([], [])
ax2.bar(cs, crossing_ns, color='steelblue', alpha=0.8)
ax2.set_xlabel('Polynomial exponent c', fontsize=12)
ax2.set_ylabel('Smallest n where leaves > n^c', fontsize=12)
ax2.set_title('Superpolynomial Witnesses\n(Theorem D)', fontsize=13)
ax2.grid(True, alpha=0.3, axis='y')

# Panel 3: Growth rate comparison
ax3 = axes[2]

ds = list(range(4, 30))
# Exact growth for n = d
exact_growth = []
lower_bound_growth = []
for d in ds:
    exact = number_of_quadratic_leaves(d, d)
    lower = 2**((d-2)//2)
    exact_growth.append(log2(exact) if exact > 0 else 0)
    lower_bound_growth.append((d-2)//2)

ax3.plot(ds, exact_growth, 'bo-', label='log₂(exact)', markersize=4, linewidth=2)
ax3.plot(ds, lower_bound_growth, 'r^--', label='(d-2)/2 (our bound)', markersize=4)
ax3.plot(ds, [d-2 for d in ds], 'g--', label='d-2 (linear ref)', alpha=0.5)

# Theoretical asymptotic: log2(C(2d-3, d-2)) ≈ 2d·log2(2) - 0.5·log2(d)
asymptotic = [2*(d-2)*1 - 0.5*log2(max(1,d)) for d in ds]
ax3.plot(ds, asymptotic, 'k:', label='~2(d-2) (Stirling)', alpha=0.5)

ax3.set_xlabel('Degree d (with n = d)', fontsize=12)
ax3.set_ylabel('log₂(leaf count)', fontsize=12)
ax3.set_title('Growth Rate of Certificate Complexity\n(Balanced Regime)', fontsize=13)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

plt.suptitle('Lorentzian Recognition: The Superpolynomial Barrier',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_certificate_barrier.png', dpi=150, bbox_inches='tight')
print("Saved viz_certificate_barrier.png")


#!/usr/bin/env python3
"""
Visualization: Leaf Count Growth and Complexity Barrier

Visualizes the exponential growth of quadratic leaf counts in the
Lorentzian recognition tree, comparing exact counts with our proved
lower bounds and the catalog's upper bounds.

This illustrates the core complexity phase transition: fixed degree
gives polynomial growth (bottom curves), while balanced parameters
give exponential growth (top curves).
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb, log2


def multiindex_count(n, d):
    if n == 0:
        return 1 if d == 0 else 0
    return comb(n + d - 1, d)


def number_of_quadratic_leaves(n, d):
    return 1 if d < 2 else multiindex_count(n, d - 2)


fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: Leaf count vs degree for fixed n
ax1 = axes[0]
for n in [2, 3, 5, 8, 12]:
    ds = list(range(2, 20))
    leaves = [number_of_quadratic_leaves(n, d) for d in ds]
    ax1.semilogy(ds, leaves, 'o-', label=f'n={n}', markersize=4)

# Lower bound: d - 1
ds_lb = list(range(2, 20))
lower = [max(1, d - 1) for d in ds_lb]
ax1.semilogy(ds_lb, lower, 'k--', label='Lower: d-1', linewidth=2)

ax1.set_xlabel('Degree d', fontsize=12)
ax1.set_ylabel('Number of Quadratic Leaves', fontsize=12)
ax1.set_title('Leaf Count vs Degree\n(Fixed Variables)', fontsize=13)
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# Panel 2: Balanced regime (n = d) — exponential growth
ax2 = axes[1]
ds = list(range(2, 22))
exact = [number_of_quadratic_leaves(d, d) for d in ds]
lower_exp = [2**((d-2)//2) for d in ds]
upper = [d**(d-2) if d >= 2 else 1 for d in ds]

ax2.semilogy(ds, exact, 'bo-', label='Exact count', markersize=5, linewidth=2)
ax2.semilogy(ds, lower_exp, 'r^--', label='Lower: 2^((d-2)/2)', markersize=5)
ax2.semilogy(ds, upper, 'gs--', label='Upper: d^(d-2)', markersize=4, alpha=0.6)

ax2.set_xlabel('Degree d = n', fontsize=12)
ax2.set_ylabel('Number of Quadratic Leaves', fontsize=12)
ax2.set_title('Balanced Regime (n = d)\nExponential Growth', fontsize=13)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# Panel 3: Phase transition heatmap
ax3 = axes[2]
ns = list(range(2, 21))
ds = list(range(2, 21))
data = np.zeros((len(ns), len(ds)))

for i, n in enumerate(ns):
    for j, d in enumerate(ds):
        leaves = number_of_quadratic_leaves(n, d)
        data[i, j] = log2(max(1, leaves))

im = ax3.imshow(data, aspect='auto', origin='lower',
                extent=[ds[0]-0.5, ds[-1]+0.5, ns[0]-0.5, ns[-1]+0.5],
                cmap='YlOrRd')
cbar = plt.colorbar(im, ax=ax3, label='log₂(leaf count)')

# Draw the "phase boundary" where leaves ≈ 10^6
boundary_n = []
boundary_d = []
for d in ds:
    for n in ns:
        if number_of_quadratic_leaves(n, d) >= 10**6:
            boundary_n.append(n)
            boundary_d.append(d)
            break

if boundary_d and boundary_n:
    ax3.plot(boundary_d, boundary_n, 'w-', linewidth=2, label='10⁶ boundary')
    ax3.legend(fontsize=9)

ax3.set_xlabel('Degree d', fontsize=12)
ax3.set_ylabel('Variables n', fontsize=12)
ax3.set_title('Complexity Phase Transition\nlog₂(leaf count)', fontsize=13)

plt.suptitle('Lorentzian Recognition: Certificate Complexity Barriers',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_leaf_growth.png', dpi=150, bbox_inches='tight')
print("Saved viz_leaf_growth.png")
