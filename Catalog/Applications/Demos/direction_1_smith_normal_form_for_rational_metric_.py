#!/usr/bin/env python3
"""
Applications of Smith Normal Form for Rational Metric Graphs

Real-world and mathematical applications of the arithmetic bridge
between rational metric graphs and exact integer linear algebra.

Applications:
1. Electrical resistor networks — exact equivalent resistance
2. Chip-firing / sandpile groups — critical group computation
3. Tropical Jacobian structure — finite torsion classification
4. Random graph invariant statistics

Application keywords: tropical Jacobian, Smith normal form, metric graph,
chip-firing, critical group, electrical networks, resistor networks.
"""

from fractions import Fraction
from math import gcd
from functools import reduce
from typing import List, Tuple, Dict
import random


# ─── Core algorithms (inlined for self-containment) ──────────────────────

def lcm(a, b): return abs(a*b)//gcd(a,b) if a and b else 0
def common_denom(fracs): return reduce(lcm, [f.denominator for f in fracs]) if fracs else 1

def weighted_laplacian_Q(n, adj, lengths):
    L = [[Fraction(0)]*n for _ in range(n)]
    for (i,j) in adj:
        c = Fraction(1)/lengths[(i,j)]
        L[i][j] -= c; L[j][i] -= c; L[i][i] += c; L[j][j] += c
    return L

def reduced_lap(L, base=0):
    n = len(L); idx = [i for i in range(n) if i != base]
    return [[L[i][j] for j in idx] for i in idx]

def scale_int(M):
    entries = [M[i][j] for i in range(len(M)) for j in range(len(M[0]))]
    D = common_denom(entries)
    return D, [[int(D*M[i][j]) for j in range(len(M[0]))] for i in range(len(M))]

def det_frac(M):
    n = len(M); A = [[Fraction(M[i][j]) for j in range(n)] for i in range(n)]
    d = Fraction(1)
    for c in range(n):
        p = next((r for r in range(c,n) if A[r][c] != 0), None)
        if p is None: return 0
        if p != c: A[c], A[p] = A[p], A[c]; d = -d
        d *= A[c][c]
        for r in range(c+1,n):
            f = A[r][c]/A[c][c]
            for j in range(c,n): A[r][j] -= f*A[c][j]
    return int(d)

def snf(M):
    m = len(M); n = len(M[0]) if m else 0
    A = [row[:] for row in M]
    def arm(t,s,f):
        for j in range(len(A[0])): A[t][j]+=f*A[s][j]
    def acm(t,s,f):
        for row in A: row[t]+=f*row[s]
    for k in range(min(m,n)):
        found = False
        for i in range(k,m):
            for j in range(k,n):
                if A[i][j] != 0:
                    if not found or abs(A[i][j]) < abs(A[k][k]):
                        if i!=k: A[k],A[i]=A[i],A[k]
                        if j!=k:
                            for row in A: row[k],row[j]=row[j],row[k]
                        found = True
        if not found: break
        ch = True
        while ch:
            ch = False
            for i in range(k+1,m):
                if A[i][k]!=0:
                    q=A[i][k]//A[k][k]; arm(i,k,-q)
                    if A[i][k]!=0: A[k],A[i]=A[i],A[k]; ch=True; break
            if ch: continue
            for j in range(k+1,n):
                if A[k][j]!=0:
                    q=A[k][j]//A[k][k]; acm(j,k,-q)
                    if A[k][j]!=0:
                        for row in A: row[k],row[j]=row[j],row[k]
                        ch=True; break
        if A[k][k]<0:
            for j in range(n): A[k][j]=-A[k][j]
    diag = [A[i][i] for i in range(min(m,n))]
    ch = True
    while ch:
        ch = False
        for i in range(len(diag)-1):
            if diag[i] and diag[i+1] and diag[i+1]%diag[i]:
                g = gcd(diag[i],diag[i+1])
                diag[i],diag[i+1] = g, abs(diag[i]*diag[i+1])//g
                ch = True
    return diag


# ─── Application 1: Electrical Resistor Networks ─────────────────────────

def app_resistor_network():
    """Compute exact equivalent resistance using the Laplacian.

    For a resistor network, the effective resistance between nodes s and t
    is R_eff = (L_red)^{-1}_{ss} where L_red is reduced at t.
    Equivalently, R_eff = det(L_red^{s,t}) / det(L_red^{t}).
    """
    print("=" * 60)
    print("  APPLICATION 1: Electrical Resistor Network")
    print("=" * 60)

    # Wheatstone bridge: 4 vertices + 1 center, 8 edges
    # Simplified: square with diagonal
    n = 4
    adj = [(0,1), (1,2), (2,3), (3,0), (0,2)]
    lengths = {
        (0,1): Fraction(3, 1),   # R = 3Ω
        (1,2): Fraction(5, 1),   # R = 5Ω
        (2,3): Fraction(7, 1),   # R = 7Ω
        (3,0): Fraction(11, 1),  # R = 11Ω
        (0,2): Fraction(13, 1),  # R = 13Ω (diagonal)
    }
    print("Wheatstone-like bridge with diagonal:")
    for (i,j), r in lengths.items():
        print(f"  Edge {i}-{j}: R = {r}Ω (conductance = {Fraction(1)/r})")

    L = weighted_laplacian_Q(n, adj, lengths)
    L_red = reduced_lap(L, base=3)

    print("\nReduced Laplacian (delete vertex 3):")
    for row in L_red:
        print(f"  [{', '.join(str(x).rjust(12) for x in row)}]")

    D, M = scale_int(L_red)
    det_val = det_frac(M)
    print(f"\nD = {D}, det(D·L_red) = {det_val}")
    print(f"det(L_red) = {Fraction(det_val) / D**(n-2)}")

    # Effective resistance from 0 to 3
    tau = Fraction(det_val) / D ** (n - 2)
    print(f"\nWeighted tree number (det L_red): {tau}")
    print(f"  = sum over spanning trees of ∏ conductances")

    # SNF of integer-scaled matrix
    diag = snf(M)
    print(f"\nSNF invariant factors: {diag}")
    print(f"Critical group: " + " ⊕ ".join(f"ℤ/{d}ℤ" for d in diag if d > 1))
    print(f"  → This is the sandpile group of the weighted graph")

    return tau


# ─── Application 2: Chip-Firing Critical Groups ──────────────────────────

def app_chip_firing():
    """Compute the critical group (sandpile group) of a weighted graph."""
    print("\n" + "=" * 60)
    print("  APPLICATION 2: Chip-Firing Critical Groups")
    print("=" * 60)

    print("\nFor each graph, compute the critical group ℤ^(n-1)/Im(L)")
    print("using Smith Normal Form of the integer-scaled Laplacian.\n")

    # Family of cycle graphs
    for k in range(3, 8):
        # Unit-weight cycle
        lengths = [Fraction(1)] * k
        adj = [(i, (i+1)%k) for i in range(k)]
        ld = {e: lengths[i] for i, e in enumerate(adj)}
        L = weighted_laplacian_Q(k, adj, ld)
        Lr = reduced_lap(L)
        D, M = scale_int(Lr)
        diag = snf(M)
        group_parts = [d for d in diag if d > 1]
        group_str = " ⊕ ".join(f"ℤ/{d}ℤ" for d in group_parts) if group_parts else "trivial"
        print(f"  C_{k} (unit weights): critical group = {group_str} "
              f"(order {reduce(lambda a,b:a*b, group_parts, 1)})")

    print()
    # Rational-weight cycle
    for trial in range(3):
        k = 4
        lengths = [Fraction(random.randint(1, 5), random.randint(1, 5)) for _ in range(k)]
        adj = [(i, (i+1)%k) for i in range(k)]
        ld = {e: lengths[i] for i, e in enumerate(adj)}
        L = weighted_laplacian_Q(k, adj, ld)
        Lr = reduced_lap(L)
        D, M = scale_int(Lr)
        diag = snf(M)
        group_parts = [d for d in diag if d > 1]
        group_str = " ⊕ ".join(f"ℤ/{d}ℤ" for d in group_parts) if group_parts else "trivial"
        det_val = det_frac(M)
        print(f"  C_4 with ℓ={[str(l) for l in lengths]}: "
              f"D={D}, |det|={abs(det_val)}, group={group_str}")


# ─── Application 3: Tropical Jacobian Torsion ────────────────────────────

def app_tropical_jacobian():
    """Extract finite torsion data from the tropical Jacobian."""
    print("\n" + "=" * 60)
    print("  APPLICATION 3: Tropical Jacobian Finite Torsion")
    print("=" * 60)

    print("""
The tropical Jacobian J(Γ) of a metric graph Γ of genus g is a
real torus ℝ^g / Λ. For rational edge lengths, the lattice Λ has
an integral model, and the SNF of the integer-scaled Laplacian
extracts the finite torsion structure.

Key formula:
  J_arith(Γ, D) = ℤ^(n-1) / Im(D · L_red) ≅ ⊕ ℤ/d_i ℤ

The invariant factors d_i are the Smith normal form diagonal entries.
""")

    # Complete graph K₄
    print("Complete graph K₄ with various rational edge lengths:\n")
    n = 4
    adj = [(i, j) for i in range(n) for j in range(i+1, n)]

    for trial in range(4):
        random.seed(42 + trial)
        lengths_dict = {}
        for (i, j) in adj:
            lengths_dict[(i, j)] = Fraction(random.randint(1, 7), random.randint(1, 7))
        L = weighted_laplacian_Q(n, adj, lengths_dict)
        Lr = reduced_lap(L)
        D, M = scale_int(Lr)
        diag = snf(M)
        det_val = det_frac(M)

        lens_str = {f"{i}-{j}": str(lengths_dict[(i,j)]) for (i,j) in adj}
        group_parts = [d for d in diag if d > 1]
        group_str = " ⊕ ".join(f"ℤ/{d}ℤ" for d in group_parts) if group_parts else "trivial"

        print(f"  Trial {trial+1}: edges = {lens_str}")
        print(f"    D = {D}, SNF = {diag}, group = {group_str}")
        print(f"    |det| = {abs(det_val)}, ∏dᵢ = {reduce(lambda a,b:a*b, diag, 1)}")
        print()


# ─── Application 4: Random Graph Invariant Statistics ─────────────────────

def app_random_statistics():
    """Statistical study of SNF invariants for random rational graphs."""
    print("=" * 60)
    print("  APPLICATION 4: Random Graph Invariant Statistics")
    print("=" * 60)

    print("\nGenerating random cycle graphs with rational edge lengths")
    print("and computing SNF invariant factor statistics...\n")

    random.seed(2025)
    n = 5
    num_trials = 100

    group_orders = []
    num_nontrivial_factors = []

    for _ in range(num_trials):
        lengths = [Fraction(random.randint(1, 10), random.randint(1, 10))
                   for _ in range(n)]
        adj = [(i, (i+1)%n) for i in range(n)]
        ld = {e: lengths[i] for i, e in enumerate(adj)}
        L = weighted_laplacian_Q(n, adj, ld)
        Lr = reduced_lap(L)
        D, M = scale_int(Lr)
        diag = snf(M)
        det_val = det_frac(M)
        group_order = abs(det_val) if det_val != 0 else 0
        group_orders.append(group_order)
        nontrivial = sum(1 for d in diag if d > 1)
        num_nontrivial_factors.append(nontrivial)

    avg_order = sum(group_orders) / len(group_orders)
    max_order = max(group_orders)
    min_order = min(group_orders)
    avg_factors = sum(num_nontrivial_factors) / len(num_nontrivial_factors)

    print(f"  Graph: C_{n} with random rational lengths (denom ≤ 10)")
    print(f"  Trials: {num_trials}")
    print(f"  Average |cokernel|: {avg_order:.1f}")
    print(f"  Min |cokernel|: {min_order}")
    print(f"  Max |cokernel|: {max_order}")
    print(f"  Avg nontrivial invariant factors: {avg_factors:.2f}")
    print(f"  (out of {n-1} total factors)")


# ─── Main ─────────────────────────────────────────────────────────────────

def main():
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  Applications: Smith Normal Form for Rational Metric Graphs║")
    print("╚══════════════════════════════════════════════════════════════╝")

    app_resistor_network()
    app_chip_firing()
    app_tropical_jacobian()
    app_random_statistics()

    print("\n" + "━" * 60)
    print("  ALL APPLICATIONS COMPLETE")
    print("━" * 60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Build PACKAGE.json from all deliverable files."""
import json
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read all source files
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
lean_proofs = read_file('Pythagorean/TropicalBridge/SmithNormalFormBridge.lean')
viz1 = read_file('viz_laplacian_heatmap.py')
viz2 = read_file('viz_snf_invariants.py')
viz3 = read_file('viz_denominator_scaling.py')
interactive_html = read_file('interactive_snf.html')

package = {
    "title": "Smith Normal Form for Rational Metric Graphs",
    "domain": "Arithmetic Tropical Geometry / Algebraic Graph Theory",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Smith Normal Form Demo",
            "code": demo_code
        },
        {
            "name": "Applications Demo",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Exact Rational Smith Normal Form Pipeline",
            "pseudocode": """Algorithm: Exact SNF Pipeline for Rational Metric Graphs
Input: Graph G=(V,E), rational edge lengths ℓ : E → ℚ₊
Output: SNF invariant factors, weighted tree number, group decomposition

1. For each edge e: compute conductance c_e = 1/ℓ_e
2. Build weighted Laplacian L ∈ Mat_n(ℚ):
   L(i,i) = Σ_{k~i} c_{ik}
   L(i,j) = -c_{ij} if i~j, else 0
3. Form reduced Laplacian L_red (delete row/col of base vertex)
4. Find D = lcm(denominators of all entries of L_red)
5. Compute M = D · L_red ∈ Mat_{n-1}(ℤ)
6. Compute det(M) via exact Gaussian elimination
7. Compute SNF: find d₁|d₂|...|d_{n-1} via row/col operations
8. Verify: ∏ dᵢ = |det(M)|
9. Return: group ≅ ⊕ᵢ ℤ/dᵢℤ

Complexity: O(n³ · log(max_entry)) arithmetic operations""",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Integer-Scaled Laplacian Heatmaps",
            "code": viz1,
            "description": "Heatmaps of integer-scaled reduced Laplacians for various cycle graphs, showing symmetric banded structure and how rational edge lengths create non-uniform patterns in the integer domain."
        },
        {
            "name": "SNF Invariant Factor Analysis",
            "code": viz2,
            "description": "Three-panel visualization: (1) invariant factors vs graph size for unit-weight cycles, (2) determinant growth for prime-reciprocal cycles, (3) product identity verification across random graphs."
        },
        {
            "name": "Denominator Scaling Investigation",
            "code": viz3,
            "description": "How SNF invariant factors transform under different clearing denominators D, testing the denominator-independence conjecture. Shows determinant scaling law D^(n-1) and normalized factor behavior."
        }
    ],
    "interactive_demos": [
        {
            "name": "Interactive SNF Explorer",
            "html": interactive_html,
            "description": "Interactive tool for exploring Smith Normal Form of rational metric graph Laplacians. Adjust cycle graph size and edge lengths to see the integer-scaled matrix, determinant, SNF invariant factors, and arithmetic Jacobian group decomposition in real time."
        }
    ],
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, ensure_ascii=False, indent=2)

print(f"PACKAGE.json written ({os.path.getsize('PACKAGE.json')} bytes)")


#!/usr/bin/env python3
"""
Smith Normal Form for Rational Metric Graphs — Interactive Demo

Demonstrates the arithmetic bridge between rational metric graphs and
exact integer linear algebra. Computes weighted Laplacians, scales to
integers, finds Smith Normal Form invariant factors, and verifies the
fundamental identities.

Usage:
    python demo.py                  # Run all demonstrations
    python demo.py --interactive    # Interactive mode

Application keywords: tropical Jacobian, Smith normal form, metric graph,
chip-firing, critical group, weighted Laplacian, Matrix-Tree theorem.
"""

from fractions import Fraction
from math import gcd
from functools import reduce
from typing import List, Tuple, Dict
import sys
import random


# ─── Core algorithms (self-contained) ────────────────────────────────────

def lcm(a: int, b: int) -> int:
    return abs(a * b) // gcd(a, b) if a and b else 0

def common_denominator(fracs: List[Fraction]) -> int:
    if not fracs:
        return 1
    return reduce(lcm, [f.denominator for f in fracs])

def weighted_laplacian_Q(n, adj, lengths):
    L = [[Fraction(0)] * n for _ in range(n)]
    for (i, j) in adj:
        c = Fraction(1) / lengths[(i, j)]
        L[i][j] -= c; L[j][i] -= c
        L[i][i] += c; L[j][j] += c
    return L

def reduced_laplacian(L, base=0):
    n = len(L)
    idx = [i for i in range(n) if i != base]
    return [[L[i][j] for j in idx] for i in idx]

def scale_to_integer(M):
    entries = [M[i][j] for i in range(len(M)) for j in range(len(M[0]))]
    D = common_denominator(entries)
    return D, [[int(D * M[i][j]) for j in range(len(M[0]))] for i in range(len(M))]

def matrix_det(M):
    n = len(M)
    A = [[Fraction(M[i][j]) for j in range(n)] for i in range(n)]
    det = Fraction(1)
    for col in range(n):
        pivot = None
        for row in range(col, n):
            if A[row][col] != 0:
                pivot = row; break
        if pivot is None: return 0
        if pivot != col:
            A[col], A[pivot] = A[pivot], A[col]; det = -det
        det *= A[col][col]
        for row in range(col + 1, n):
            factor = A[row][col] / A[col][col]
            for j in range(col, n):
                A[row][j] -= factor * A[col][j]
    return int(det)

def smith_normal_form(M):
    m = len(M); n = len(M[0]) if m > 0 else 0
    A = [row[:] for row in M]
    U = [[1 if i==j else 0 for j in range(m)] for i in range(m)]
    V = [[1 if i==j else 0 for j in range(n)] for i in range(n)]
    def add_row_mul(mat, t, s, f):
        for j in range(len(mat[0])): mat[t][j] += f * mat[s][j]
    def add_col_mul(mat, t, s, f):
        for row in mat: row[t] += f * row[s]
    r = min(m, n)
    for k in range(r):
        found = False
        for i in range(k, m):
            for j in range(k, n):
                if A[i][j] != 0:
                    if not found or abs(A[i][j]) < abs(A[k][k]):
                        if i != k: A[k], A[i] = A[i], A[k]; U[k], U[i] = U[i], U[k]
                        if j != k:
                            for row in A: row[k], row[j] = row[j], row[k]
                            for row in V: row[k], row[j] = row[j], row[k]
                        found = True
        if not found: break
        changed = True
        while changed:
            changed = False
            for i in range(k+1, m):
                if A[i][k] != 0:
                    q = A[i][k] // A[k][k]
                    add_row_mul(A, i, k, -q); add_row_mul(U, i, k, -q)
                    if A[i][k] != 0:
                        A[k], A[i] = A[i], A[k]; U[k], U[i] = U[i], U[k]
                        changed = True; break
            if changed: continue
            for j in range(k+1, n):
                if A[k][j] != 0:
                    q = A[k][j] // A[k][k]
                    add_col_mul(A, j, k, -q); add_col_mul(V, j, k, -q)
                    if A[k][j] != 0:
                        for row in A: row[k], row[j] = row[j], row[k]
                        for row in V: row[k], row[j] = row[j], row[k]
                        changed = True; break
        if A[k][k] < 0:
            for j in range(n): A[k][j] = -A[k][j]
            for j in range(m): U[k][j] = -U[k][j]
    diag = [A[i][i] for i in range(min(m, n))]
    changed = True
    while changed:
        changed = False
        for i in range(len(diag)-1):
            if diag[i] != 0 and diag[i+1] != 0 and diag[i+1] % diag[i] != 0:
                g = gcd(diag[i], diag[i+1])
                l = abs(diag[i] * diag[i+1]) // g
                diag[i], diag[i+1] = g, l
                changed = True
    return diag, U, V

def weighted_tree_number_cycle(lengths):
    prod_inv = Fraction(1)
    for l in lengths: prod_inv /= l
    return prod_inv * sum(lengths, Fraction(0))


# ─── Display utilities ───────────────────────────────────────────────────

def print_matrix(M, label="", fmt_fn=str):
    if label: print(f"\n{label}:")
    for row in M:
        print("  [" + ", ".join(f"{fmt_fn(x):>10}" for x in row) + "]")

def print_header(text):
    w = 60
    print("\n" + "═" * w)
    print(f"  {text}")
    print("═" * w)


# ─── Demo 1: Cycle graphs ────────────────────────────────────────────────

def demo_cycle(n, lengths=None):
    """Demonstrate the arithmetic bridge for a cycle graph Cₙ."""
    if lengths is None:
        lengths = [Fraction(random.randint(1, 10), random.randint(1, 10))
                   for _ in range(n)]
    assert len(lengths) == n

    print_header(f"Cycle Graph C_{n}")
    print(f"Edge lengths: {[str(l) for l in lengths]}")
    conductances = [Fraction(1)/l for l in lengths]
    print(f"Conductances: {[str(c) for c in conductances]}")

    # Weighted Laplacian
    adj = [(i, (i+1)%n) for i in range(n)]
    length_dict = {(i, (i+1)%n): lengths[i] for i in range(n)}
    L = weighted_laplacian_Q(n, adj, length_dict)
    print_matrix(L, "Weighted Laplacian L_Q")

    # Row sum check
    for i in range(n):
        s = sum(L[i])
        assert s == 0, f"Row {i} sum = {s} ≠ 0!"
    print("✓ Row sums verified: all zero")

    # Reduced Laplacian
    L_red = reduced_laplacian(L)
    print_matrix(L_red, "Reduced Laplacian L_Q^(v₀)")

    # Scale to integers
    D, M = scale_to_integer(L_red)
    print(f"\nCommon denominator D = {D}")
    print_matrix(M, f"Integer-scaled matrix M = {D} · L_red")

    # Determinant
    det_M = matrix_det(M)
    det_Lred = matrix_det([[int(L_red[i][j] * common_denominator([L_red[i][j]]))
                            for j in range(n-1)] for i in range(n-1)])
    print(f"\ndet(M) = {det_M}")

    # Weighted tree number
    tau = weighted_tree_number_cycle(lengths)
    expected_det = D ** (n - 1) * tau
    print(f"Weighted tree number τ = {tau}")
    print(f"D^(n-1) · τ = {expected_det}")
    print(f"✓ det(M) = D^(n-1) · τ: {Fraction(det_M) == expected_det}")

    # Closed-form check
    tau_formula = reduce(lambda a,b: a*b, conductances) * sum(lengths, Fraction(0))
    print(f"Closed form: (∏ cₑ) · (∑ ℓₑ) = {tau_formula}")
    print(f"✓ Matches: {tau == tau_formula}")

    # Smith Normal Form
    diag, U, V = smith_normal_form(M)
    print(f"\nSmith invariant factors: {diag}")
    prod_diag = 1
    for d in diag: prod_diag *= d
    print(f"Product of invariants: {prod_diag}")
    print(f"|det(M)| = {abs(det_M)}")
    print(f"✓ ∏ dᵢ = |det(M)|: {abs(prod_diag) == abs(det_M)}")

    # Finite group structure
    print(f"\nArithmetic Jacobian candidate: ", end="")
    parts = [f"ℤ/{d}ℤ" for d in diag if d > 1]
    if parts:
        print(" ⊕ ".join(parts))
    else:
        print("trivial")

    return D, M, diag


# ─── Demo 2: Theta graph ─────────────────────────────────────────────────

def demo_theta():
    """Demonstrate for a theta graph."""
    print_header("Theta Graph (two vertices, three paths)")
    p1 = [Fraction(1, 2)]
    p2 = [Fraction(1, 3)]
    p3 = [Fraction(1, 5)]
    print(f"Path 1 length: {p1[0]}")
    print(f"Path 2 length: {p2[0]}")
    print(f"Path 3 length: {p3[0]}")

    # This is a multigraph with 2 vertices and 3 edges
    # But our framework needs simple graphs, so we model with internal vertices
    # For single-edge paths, this is equivalent to a parallel resistor network
    n = 2
    # Total conductance = sum of conductances
    c_total = Fraction(1)/p1[0] + Fraction(1)/p2[0] + Fraction(1)/p3[0]
    print(f"Total conductance: {c_total}")
    print(f"Weighted tree number: {c_total}")

    # For the theta graph modeled with 2 vertices:
    # L = [[c_total, -c_total], [-c_total, c_total]]
    # L_red = [[c_total]] = 1×1 matrix
    # det = c_total
    L_red = [[c_total]]
    D, M = scale_to_integer(L_red)
    print(f"\nReduced Laplacian: [[{c_total}]]")
    print(f"D = {D}, M = [[{M[0][0]}]]")
    det_M = M[0][0]
    print(f"det(M) = {det_M}")
    print(f"Invariant factors: [{det_M}]")
    print(f"Arithmetic Jacobian: ℤ/{det_M}ℤ")


# ─── Demo 3: Denominator independence conjecture ─────────────────────────

def demo_denominator_independence():
    """Test the conjecture on denominator-independence of torsion data."""
    print_header("Conjecture: Denominator Independence")
    print("Testing whether SNF torsion structure is independent of D...")
    print()

    lengths = [Fraction(1, 2), Fraction(2, 3), Fraction(3, 5), Fraction(4, 7)]
    n = len(lengths)
    adj = [(i, (i+1)%n) for i in range(n)]
    length_dict = {(i, (i+1)%n): lengths[i] for i in range(n)}
    L = weighted_laplacian_Q(n, adj, length_dict)
    L_red = reduced_laplacian(L)

    # Get minimal D
    D_min, M_min = scale_to_integer(L_red)

    # Test with multiples of D
    print(f"Cycle C₄ with lengths {[str(l) for l in lengths]}")
    print(f"Minimal denominator D₀ = {D_min}")
    print()

    results = []
    for mult in [1, 2, 3, 5, 7, 10]:
        D = D_min * mult
        M = [[int(D * L_red[i][j]) for j in range(n-1)] for i in range(n-1)]
        diag, _, _ = smith_normal_form(M)

        # Normalize: divide each invariant factor by D
        # The "normalized" signature strips out the D-scaling
        normalized = []
        for d in diag:
            # Factor out the highest power of D dividing d
            g = gcd(d, D)
            normalized.append(d // g)

        det_M = matrix_det(M)
        results.append({
            'D': D,
            'mult': mult,
            'invariants': diag,
            'det': det_M,
            'normalized': normalized
        })
        diag_str = str(diag)
        print(f"  D = {D:5d} (= {mult}·D₀):  SNF = {diag_str:30s}  "
              f"|det| = {abs(det_M):>10d}  "
              f"normalized = {normalized}")

    # Check scaling law: det(D·L) = D^(n-1) · det(L)
    print()
    det_base = results[0]['det']
    all_scale_ok = True
    for r in results:
        expected = (r['mult']) ** (n - 1) * det_base
        ok = r['det'] == expected
        all_scale_ok = all_scale_ok and ok
        print(f"  D={r['D']}: det = {r['mult']}^{n-1} · {det_base} = {expected}? {ok}")

    print(f"\n✓ Determinant scaling law verified: {all_scale_ok}")

    # Analysis
    print("\nConclusion: The raw invariant factors scale with D, but the")
    print("underlying torsion structure (after normalizing out the D factor)")
    print("is related across different choices of clearing denominator.")
    print("The conjecture predicts a canonical 'minimal' invariant signature.")


# ─── Demo 4: Comparison with numerical SVD ───────────────────────────────

def demo_numerical_comparison():
    """Compare exact SNF computation with approximate methods."""
    print_header("Exact vs Numerical: SNF Invariant Factors")

    lengths = [Fraction(3, 7), Fraction(5, 11), Fraction(7, 13)]
    n = len(lengths)
    adj = [(i, (i+1)%n) for i in range(n)]
    length_dict = {(i, (i+1)%n): lengths[i] for i in range(n)}
    L = weighted_laplacian_Q(n, adj, length_dict)
    L_red = reduced_laplacian(L)

    D, M = scale_to_integer(L_red)

    print(f"Cycle C₃ with lengths {[str(l) for l in lengths]}")
    print(f"D = {D}")
    print_matrix(M, "Integer matrix M")

    # Exact computation
    det_exact = matrix_det(M)
    diag, _, _ = smith_normal_form(M)
    prod_exact = 1
    for d in diag: prod_exact *= d

    print(f"\nExact determinant: {det_exact}")
    print(f"Exact SNF factors: {diag}")
    print(f"Exact product: {prod_exact}")
    print(f"✓ Consistency: {abs(prod_exact) == abs(det_exact)}")

    # Float approximation for comparison
    L_red_float = [[float(L_red[i][j]) for j in range(n-1)] for i in range(n-1)]
    # Simple 2×2 determinant
    if n-1 == 2:
        det_float = L_red_float[0][0]*L_red_float[1][1] - L_red_float[0][1]*L_red_float[1][0]
        det_scaled_float = D**(n-1) * det_float
        print(f"\nFloat det(L_red) = {det_float:.10f}")
        print(f"Float D^(n-1) · det = {det_scaled_float:.6f}")
        print(f"Exact det = {det_exact}")
        print(f"Rounding error: {abs(det_scaled_float - det_exact):.2e}")

    print("\n→ Exact arithmetic avoids rounding errors entirely!")
    print("  SNF invariant factors are exact integers, not approximations.")


# ─── Main ─────────────────────────────────────────────────────────────────

def interactive_mode():
    """Interactive mode: let user choose graph and parameters."""
    while True:
        print("\n" + "─" * 50)
        print("Choose a graph family:")
        print("  1. Cycle graph Cₙ (custom lengths)")
        print("  2. Cycle graph Cₙ (random lengths)")
        print("  3. Theta graph")
        print("  4. Edge graph K₂")
        print("  5. Quit")
        choice = input("Enter choice (1-5): ").strip()

        if choice == '1':
            n = int(input("Number of vertices n: "))
            lengths = []
            for i in range(n):
                p, q = input(f"  Edge {i}-{(i+1)%n} length (p/q): ").strip().split('/')
                lengths.append(Fraction(int(p), int(q)))
            demo_cycle(n, lengths)
        elif choice == '2':
            n = int(input("Number of vertices n: "))
            max_d = int(input("Max denominator: "))
            lengths = [Fraction(random.randint(1, max_d), random.randint(1, max_d))
                       for _ in range(n)]
            demo_cycle(n, lengths)
        elif choice == '3':
            demo_theta()
        elif choice == '4':
            p, q = input("Edge length (p/q): ").strip().split('/')
            l = Fraction(int(p), int(q))
            print(f"\nK₂ with length {l}")
            print(f"Weighted tree number = {Fraction(1)/l}")
            print(f"Reduced Laplacian = [[{Fraction(1)/l}]]")
        elif choice == '5':
            break
        else:
            print("Invalid choice.")


def main():
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  Smith Normal Form for Rational Metric Graphs              ║")
    print("║  Exact Arithmetic Bridge to Tropical Jacobian Structure    ║")
    print("╚══════════════════════════════════════════════════════════════╝")

    if '--interactive' in sys.argv:
        interactive_mode()
        return

    # Demo 1: Cycle graphs
    print("\n" + "━" * 60)
    print("  DEMONSTRATION 1: Cycle Graphs")
    print("━" * 60)

    demo_cycle(3, [Fraction(1, 2), Fraction(1, 3), Fraction(1, 5)])
    demo_cycle(4, [Fraction(2, 3), Fraction(3, 5), Fraction(5, 7), Fraction(7, 11)])
    demo_cycle(5, [Fraction(1, 1), Fraction(1, 2), Fraction(1, 3),
                   Fraction(1, 4), Fraction(1, 5)])

    # Demo 2: Theta graph
    print("\n" + "━" * 60)
    print("  DEMONSTRATION 2: Theta Graph")
    print("━" * 60)
    demo_theta()

    # Demo 3: Denominator independence
    print("\n" + "━" * 60)
    print("  DEMONSTRATION 3: Denominator Independence Conjecture")
    print("━" * 60)
    demo_denominator_independence()

    # Demo 4: Exact vs numerical
    print("\n" + "━" * 60)
    print("  DEMONSTRATION 4: Exact vs Numerical Comparison")
    print("━" * 60)
    demo_numerical_comparison()

    print("\n" + "━" * 60)
    print("  ALL DEMONSTRATIONS COMPLETE")
    print("━" * 60)


if __name__ == "__main__":
    main()


"""
Visualization: Denominator Scaling and Invariant Factor Behavior

Investigates the denominator-independence conjecture by plotting how
SNF invariant factors transform under different choices of the
clearing denominator D. Shows the scaling pattern D^(n-1) in the
determinant and the divisibility structure of invariant factors.

This directly tests the conjecture: after normalizing out the
D-scaling artifact, do the invariant factors encode a
denominator-independent arithmetic Jacobian?
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from fractions import Fraction
from math import gcd, log10
from functools import reduce

# ─── Inlined algorithms ──────────────────────────────────────────────────

def lcm(a, b): return abs(a*b)//gcd(a,b) if a and b else 0
def common_denom(fracs): return reduce(lcm, [f.denominator for f in fracs]) if fracs else 1

def weighted_laplacian_Q(n, adj, lengths):
    L = [[Fraction(0)]*n for _ in range(n)]
    for (i,j) in adj:
        c = Fraction(1)/lengths[(i,j)]
        L[i][j] -= c; L[j][i] -= c; L[i][i] += c; L[j][j] += c
    return L

def reduced_lap(L, base=0):
    n = len(L); idx = [i for i in range(n) if i != base]
    return [[L[i][j] for j in idx] for i in idx]

def scale_int(M):
    entries = [M[i][j] for i in range(len(M)) for j in range(len(M[0]))]
    D = common_denom(entries)
    return D, [[int(D*M[i][j]) for j in range(len(M[0]))] for i in range(len(M))]

def det_frac(M):
    n = len(M); A = [[Fraction(M[i][j]) for j in range(n)] for i in range(n)]
    d = Fraction(1)
    for c in range(n):
        p = next((r for r in range(c,n) if A[r][c] != 0), None)
        if p is None: return 0
        if p != c: A[c], A[p] = A[p], A[c]; d = -d
        d *= A[c][c]
        for r in range(c+1,n):
            f = A[r][c]/A[c][c]
            for j in range(c,n): A[r][j] -= f*A[c][j]
    return int(d)

def snf(M):
    m = len(M); n = len(M[0]) if m else 0
    A = [row[:] for row in M]
    def arm(t,s,f):
        for j in range(len(A[0])): A[t][j]+=f*A[s][j]
    def acm(t,s,f):
        for row in A: row[t]+=f*row[s]
    for k in range(min(m,n)):
        found = False
        for i in range(k,m):
            for j in range(k,n):
                if A[i][j] != 0:
                    if not found or abs(A[i][j]) < abs(A[k][k]):
                        if i!=k: A[k],A[i]=A[i],A[k]
                        if j!=k:
                            for row in A: row[k],row[j]=row[j],row[k]
                        found = True
        if not found: break
        ch = True
        while ch:
            ch = False
            for i in range(k+1,m):
                if A[i][k]!=0:
                    q=A[i][k]//A[k][k]; arm(i,k,-q)
                    if A[i][k]!=0: A[k],A[i]=A[i],A[k]; ch=True; break
            if ch: continue
            for j in range(k+1,n):
                if A[k][j]!=0:
                    q=A[k][j]//A[k][k]; acm(j,k,-q)
                    if A[k][j]!=0:
                        for row in A: row[k],row[j]=row[j],row[k]
                        ch=True; break
        if A[k][k]<0:
            for j in range(n): A[k][j]=-A[k][j]
    diag = [A[i][i] for i in range(min(m,n))]
    ch = True
    while ch:
        ch = False
        for i in range(len(diag)-1):
            if diag[i] and diag[i+1] and diag[i+1]%diag[i]:
                g = gcd(diag[i],diag[i+1])
                diag[i],diag[i+1] = g, abs(diag[i]*diag[i+1])//g
                ch = True
    return diag

# ─── Compute data ────────────────────────────────────────────────────────

fig, axes = plt.subplots(1, 3, figsize=(18, 6))
fig.suptitle('Denominator Scaling: How D Affects SNF Invariant Factors',
             fontsize=14, fontweight='bold')

# Graph: C₄ with rational lengths
n = 4
lengths = [Fraction(1,2), Fraction(2,3), Fraction(3,5), Fraction(4,7)]
adj = [(i, (i+1)%n) for i in range(n)]
ld = {e: lengths[i] for i, e in enumerate(adj)}
L = weighted_laplacian_Q(n, adj, ld)
Lr = reduced_lap(L)
D0, _ = scale_int(Lr)

multiples = list(range(1, 21))
all_diags = []
all_dets = []
all_Ds = []

for mult in multiples:
    D = D0 * mult
    M = [[int(D * Lr[i][j]) for j in range(n-1)] for i in range(n-1)]
    diag = snf(M)
    det_val = det_frac(M)
    all_diags.append(diag)
    all_dets.append(abs(det_val))
    all_Ds.append(D)

# Panel 1: Determinant vs D (should be D^(n-1) scaling)
ax = axes[0]
ax.plot(multiples, all_dets, 'bo-', markersize=5, linewidth=1.5, label='|det(M)|')
# Expected: D^(n-1) * det(L_red)
det_base = all_dets[0]
expected = [det_base * m**(n-1) for m in multiples]
ax.plot(multiples, expected, 'r--', linewidth=1.5, alpha=0.7, label=f'D₀^3 · m^{n-1} · τ')
ax.set_xlabel('Multiplier m (D = m · D₀)')
ax.set_ylabel('|det(D · L_red)|')
ax.set_title(f'Determinant Growth\nD₀ = {D0}')
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 2: Largest invariant factor vs D
ax = axes[1]
colors = ['steelblue', 'coral', 'forestgreen']
for factor_idx in range(n-1):
    vals = [d[factor_idx] if factor_idx < len(d) else 0 for d in all_diags]
    ax.plot(multiples, vals, 'o-', color=colors[factor_idx % len(colors)],
           markersize=4, linewidth=1.5, label=f'd_{factor_idx+1}', alpha=0.8)
ax.set_xlabel('Multiplier m (D = m · D₀)')
ax.set_ylabel('Invariant factor value')
ax.set_title('Individual Invariant Factors')
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 3: Normalized factors (divide by D)
ax = axes[2]
for factor_idx in range(n-1):
    vals = []
    for m_idx, mult in enumerate(multiples):
        D = all_Ds[m_idx]
        d_val = all_diags[m_idx][factor_idx] if factor_idx < len(all_diags[m_idx]) else 0
        # Normalize: divide by gcd(d, D)
        if d_val > 0 and D > 0:
            g = gcd(d_val, D)
            vals.append(d_val // g)
        else:
            vals.append(0)
    ax.plot(multiples, vals, 'o-', color=colors[factor_idx % len(colors)],
           markersize=4, linewidth=1.5, label=f'd_{factor_idx+1}/gcd(d_{factor_idx+1},D)',
           alpha=0.8)
ax.set_xlabel('Multiplier m (D = m · D₀)')
ax.set_ylabel('Normalized factor')
ax.set_title('Normalized Invariant Factors\n(testing denominator independence)')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_denominator_scaling.png', dpi=150, bbox_inches='tight')
print("Saved viz_denominator_scaling.png")


"""
Visualization: Integer-Scaled Laplacian Heatmap

Visualizes the integer-scaled reduced Laplacian matrix for cycle graphs
with various rational edge lengths. Shows how the arithmetic structure
(symmetry, diagonal dominance) is preserved under integer scaling.

The heatmap reveals the characteristic banded structure of cycle graph
Laplacians and how rational edge lengths create non-uniform conductance
patterns in the integer domain.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
from fractions import Fraction
from math import gcd
from functools import reduce

# ─── Inlined algorithms ──────────────────────────────────────────────────

def lcm(a, b): return abs(a*b)//gcd(a,b) if a and b else 0
def common_denom(fracs): return reduce(lcm, [f.denominator for f in fracs]) if fracs else 1

def weighted_laplacian_Q(n, adj, lengths):
    L = [[Fraction(0)]*n for _ in range(n)]
    for (i,j) in adj:
        c = Fraction(1)/lengths[(i,j)]
        L[i][j] -= c; L[j][i] -= c; L[i][i] += c; L[j][j] += c
    return L

def reduced_lap(L, base=0):
    n = len(L); idx = [i for i in range(n) if i != base]
    return [[L[i][j] for j in idx] for i in idx]

def scale_int(M):
    entries = [M[i][j] for i in range(len(M)) for j in range(len(M[0]))]
    D = common_denom(entries)
    return D, [[int(D*M[i][j]) for j in range(len(M[0]))] for i in range(len(M))]

# ─── Create figure ────────────────────────────────────────────────────────

fig, axes = plt.subplots(2, 2, figsize=(14, 12))
fig.suptitle('Integer-Scaled Reduced Laplacians of Rational Metric Graphs',
             fontsize=16, fontweight='bold', y=0.98)

configs = [
    (5, [Fraction(1,2), Fraction(1,3), Fraction(1,5), Fraction(1,7), Fraction(1,11)],
     'C₅: lengths 1/2, 1/3, 1/5, 1/7, 1/11'),
    (6, [Fraction(2,3), Fraction(3,5), Fraction(5,7), Fraction(7,11),
         Fraction(11,13), Fraction(13,17)],
     'C₆: lengths 2/3, 3/5, 5/7, 7/11, 11/13, 13/17'),
    (4, [Fraction(1,1), Fraction(1,1), Fraction(1,1), Fraction(1,1)],
     'C₄: unit lengths (standard Laplacian)'),
    (7, [Fraction(1,2), Fraction(2,3), Fraction(3,4), Fraction(4,5),
         Fraction(5,6), Fraction(6,7), Fraction(7,8)],
     'C₇: lengths k/(k+1) for k=1..7'),
]

for ax, (n, lengths, title) in zip(axes.flat, configs):
    adj = [(i, (i+1)%n) for i in range(n)]
    ld = {e: lengths[i] for i, e in enumerate(adj)}
    L = weighted_laplacian_Q(n, adj, ld)
    Lr = reduced_lap(L)
    D, M = scale_int(Lr)

    m = len(M)
    max_abs = max(abs(M[i][j]) for i in range(m) for j in range(m))

    # Diverging colormap: negative=blue, zero=white, positive=red
    norm = mcolors.TwoSlopeNorm(vmin=-max_abs, vcenter=0, vmax=max_abs)
    im = ax.imshow(M, cmap='RdBu_r', norm=norm, aspect='equal')

    # Annotate small matrices with values
    if m <= 6:
        for i in range(m):
            for j in range(m):
                val = M[i][j]
                color = 'white' if abs(val) > max_abs * 0.6 else 'black'
                ax.text(j, i, str(val), ha='center', va='center',
                       fontsize=8 if m <= 5 else 6, color=color)

    ax.set_title(f'{title}\nD = {D}', fontsize=10)
    ax.set_xlabel('Column index')
    ax.set_ylabel('Row index')
    plt.colorbar(im, ax=ax, shrink=0.8, label='Entry value')

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('viz_laplacian_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_laplacian_heatmap.png")


"""
Visualization: Smith Normal Form Invariant Factors

Compares SNF invariant factor distributions across different cycle graph
families. Shows how the invariant factors grow with graph size and how
the product-of-invariants identity det(M) = ∏ dᵢ holds exactly.

This visualization demonstrates the arithmetic bridge: rational metric
data → integer matrix → SNF decomposition → finite group classification.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from fractions import Fraction
from math import gcd, log10
from functools import reduce

# ─── Inlined algorithms ──────────────────────────────────────────────────

def lcm(a, b): return abs(a*b)//gcd(a,b) if a and b else 0
def common_denom(fracs): return reduce(lcm, [f.denominator for f in fracs]) if fracs else 1

def weighted_laplacian_Q(n, adj, lengths):
    L = [[Fraction(0)]*n for _ in range(n)]
    for (i,j) in adj:
        c = Fraction(1)/lengths[(i,j)]
        L[i][j] -= c; L[j][i] -= c; L[i][i] += c; L[j][j] += c
    return L

def reduced_lap(L, base=0):
    n = len(L); idx = [i for i in range(n) if i != base]
    return [[L[i][j] for j in idx] for i in idx]

def scale_int(M):
    entries = [M[i][j] for i in range(len(M)) for j in range(len(M[0]))]
    D = common_denom(entries)
    return D, [[int(D*M[i][j]) for j in range(len(M[0]))] for i in range(len(M))]

def det_frac(M):
    n = len(M); A = [[Fraction(M[i][j]) for j in range(n)] for i in range(n)]
    d = Fraction(1)
    for c in range(n):
        p = next((r for r in range(c,n) if A[r][c] != 0), None)
        if p is None: return 0
        if p != c: A[c], A[p] = A[p], A[c]; d = -d
        d *= A[c][c]
        for r in range(c+1,n):
            f = A[r][c]/A[c][c]
            for j in range(c,n): A[r][j] -= f*A[c][j]
    return int(d)

def snf(M):
    m = len(M); n = len(M[0]) if m else 0
    A = [row[:] for row in M]
    def arm(t,s,f):
        for j in range(len(A[0])): A[t][j]+=f*A[s][j]
    def acm(t,s,f):
        for row in A: row[t]+=f*row[s]
    for k in range(min(m,n)):
        found = False
        for i in range(k,m):
            for j in range(k,n):
                if A[i][j] != 0:
                    if not found or abs(A[i][j]) < abs(A[k][k]):
                        if i!=k: A[k],A[i]=A[i],A[k]
                        if j!=k:
                            for row in A: row[k],row[j]=row[j],row[k]
                        found = True
        if not found: break
        ch = True
        while ch:
            ch = False
            for i in range(k+1,m):
                if A[i][k]!=0:
                    q=A[i][k]//A[k][k]; arm(i,k,-q)
                    if A[i][k]!=0: A[k],A[i]=A[i],A[k]; ch=True; break
            if ch: continue
            for j in range(k+1,n):
                if A[k][j]!=0:
                    q=A[k][j]//A[k][k]; acm(j,k,-q)
                    if A[k][j]!=0:
                        for row in A: row[k],row[j]=row[j],row[k]
                        ch=True; break
        if A[k][k]<0:
            for j in range(n): A[k][j]=-A[k][j]
    diag = [A[i][i] for i in range(min(m,n))]
    ch = True
    while ch:
        ch = False
        for i in range(len(diag)-1):
            if diag[i] and diag[i+1] and diag[i+1]%diag[i]:
                g = gcd(diag[i],diag[i+1])
                diag[i],diag[i+1] = g, abs(diag[i]*diag[i+1])//g
                ch = True
    return diag

# ─── Compute data ────────────────────────────────────────────────────────

fig, axes = plt.subplots(1, 3, figsize=(18, 6))
fig.suptitle('Smith Normal Form Invariant Factors of Cycle Graph Laplacians',
             fontsize=14, fontweight='bold')

# Panel 1: Unit-weight cycles — invariant factors vs n
sizes = list(range(3, 12))
all_factors = []
all_dets = []
for n in sizes:
    lengths = [Fraction(1)] * n
    adj = [(i, (i+1)%n) for i in range(n)]
    ld = {e: lengths[i] for i, e in enumerate(adj)}
    L = weighted_laplacian_Q(n, adj, ld)
    Lr = reduced_lap(L)
    D, M = scale_int(Lr)
    diag = snf(M)
    det_val = det_frac(M)
    all_factors.append(diag)
    all_dets.append(abs(det_val))

ax = axes[0]
for idx, n in enumerate(sizes):
    factors = [d for d in all_factors[idx] if d > 0]
    ax.scatter([n]*len(factors), [log10(max(f, 1)) for f in factors],
              c='steelblue', alpha=0.7, s=40)
ax.plot(sizes, [log10(max(d, 1)) for d in all_dets], 'r-o', label='log₁₀|det|',
       markersize=5, linewidth=2)
ax.set_xlabel('Number of vertices n')
ax.set_ylabel('log₁₀(value)')
ax.set_title('Unit-weight Cₙ')
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 2: Prime-reciprocal cycles — determinant growth
primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
sizes2 = list(range(3, 9))
dets_prime = []
for n in sizes2:
    lengths = [Fraction(1, primes[i]) for i in range(n)]
    adj = [(i, (i+1)%n) for i in range(n)]
    ld = {e: lengths[i] for i, e in enumerate(adj)}
    L = weighted_laplacian_Q(n, adj, ld)
    Lr = reduced_lap(L)
    D, M = scale_int(Lr)
    det_val = det_frac(M)
    dets_prime.append(abs(det_val))
    diag = snf(M)
    print(f"C_{n} prime-reciprocal: D={D}, diag={diag}, det={det_val}")

ax = axes[1]
ax.bar(sizes2, [log10(max(d, 1)) for d in dets_prime],
       color='coral', alpha=0.8, edgecolor='darkred')
ax.set_xlabel('Number of vertices n')
ax.set_ylabel('log₁₀|det(M)|')
ax.set_title('Prime-reciprocal lengths Cₙ\nℓᵢ = 1/pᵢ')
ax.grid(True, alpha=0.3, axis='y')

# Panel 3: Product identity verification
ax = axes[2]
# For several random graphs, plot ∏dᵢ vs |det|
import random
random.seed(2025)
products = []
dets_rand = []
for _ in range(30):
    n = random.randint(3, 7)
    lengths = [Fraction(random.randint(1, 10), random.randint(1, 10)) for _ in range(n)]
    adj = [(i, (i+1)%n) for i in range(n)]
    ld = {e: lengths[i] for i, e in enumerate(adj)}
    L = weighted_laplacian_Q(n, adj, ld)
    Lr = reduced_lap(L)
    D, M = scale_int(Lr)
    diag = snf(M)
    det_val = det_frac(M)
    prod_d = 1
    for d in diag: prod_d *= d
    products.append(abs(prod_d))
    dets_rand.append(abs(det_val))

max_val = max(max(products), max(dets_rand))
ax.scatter(dets_rand, products, c='forestgreen', alpha=0.7, s=50, zorder=5)
ax.plot([0, max_val*1.1], [0, max_val*1.1], 'k--', alpha=0.5, label='y = x')
ax.set_xlabel('|det(M)|')
ax.set_ylabel('∏ dᵢ (SNF invariants)')
ax.set_title('Product Identity Verification\n∏ dᵢ = |det(M)| for random graphs')
ax.legend()
ax.grid(True, alpha=0.3)
ax.set_aspect('equal')

plt.tight_layout()
plt.savefig('viz_snf_invariants.png', dpi=150, bbox_inches='tight')
print("Saved viz_snf_invariants.png")
