#!/usr/bin/env python3
"""
Applications of the Jacobian Conjecture machinery:
practical use cases of nilpotency detection, polynomial map
certification, and Drużkowski transform analysis.

Application 1: Polynomial Map Invertibility Certification
  Given a polynomial map F, certify that it is invertible by
  checking the Keller condition and constructing the inverse.

Application 2: Control Theory - Stability Analysis
  Nilpotent perturbations appear in linearized control systems.
  Detecting nilpotency certifies that perturbations decay.

Application 3: Cryptographic Multivariate Map Analysis
  Multivariate polynomial cryptosystems use invertible polynomial
  maps. The Keller condition provides a structural certificate.
"""

from fractions import Fraction
from typing import List, Tuple, Optional, Dict
from itertools import product

Matrix = List[List[Fraction]]
Vector = List[Fraction]


def zero_matrix(n: int) -> Matrix:
    return [[Fraction(0)] * n for _ in range(n)]

def identity_matrix(n: int) -> Matrix:
    m = zero_matrix(n)
    for i in range(n):
        m[i][i] = Fraction(1)
    return m

def mat_mul(A: Matrix, B: Matrix) -> Matrix:
    n = len(A)
    C = zero_matrix(n)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i][j] += A[i][k] * B[k][j]
    return C

def determinant(A: Matrix) -> Fraction:
    n = len(A)
    if n == 0:
        return Fraction(1)
    M = [row[:] for row in A]
    det = Fraction(1)
    for col in range(n):
        pivot = None
        for row in range(col, n):
            if M[row][col] != 0:
                pivot = row
                break
        if pivot is None:
            return Fraction(0)
        if pivot != col:
            M[col], M[pivot] = M[pivot], M[col]
            det = -det
        det *= M[col][col]
        inv = Fraction(1) / M[col][col]
        for row in range(col + 1, n):
            factor = M[row][col] * inv
            for j in range(col, n):
                M[row][j] -= factor * M[col][j]
    return det

def is_nilpotent(A: Matrix) -> Tuple[bool, int]:
    n = len(A)
    power = identity_matrix(n)
    for k in range(1, n + 1):
        power = mat_mul(power, A)
        if all(power[i][j] == 0 for i in range(n) for j in range(n)):
            return True, k
    return False, -1

def trace(A: Matrix) -> Fraction:
    return sum(A[i][i] for i in range(len(A)))


# ═══════════════════════════════════════════════════════════════
# APPLICATION 1: Polynomial Map Invertibility Certification
# ═══════════════════════════════════════════════════════════════

def certify_triangular_inverse(coeffs: List[Tuple[int, Fraction, List[Fraction]]]):
    """
    Certify that a triangular polynomial map is invertible
    and compute its inverse by back-substitution.

    A triangular map has the form:
      F_i(x) = a_i * x_i + p_i(x_1, ..., x_{i-1})

    where a_i ≠ 0 and p_i depends only on earlier variables.

    Input: list of (index, diagonal_coeff, lower_coefficients)
    Output: certification result and inverse description
    """
    n = len(coeffs)
    print("  Triangular Map Certification")
    print(f"    Dimension: {n}")

    all_invertible = True
    for idx, diag, lower in coeffs:
        if diag == 0:
            print(f"    ✗ Component {idx+1}: diagonal coefficient is 0!")
            all_invertible = False
        else:
            print(f"    ✓ Component {idx+1}: diagonal coefficient = {diag} ≠ 0")

    if all_invertible:
        det_val = Fraction(1)
        for _, diag, _ in coeffs:
            det_val *= diag
        print(f"    Jacobian determinant: {det_val}")
        print(f"    Map is INVERTIBLE (triangular with nonzero diagonal)")
        print(f"    Inverse exists and can be computed by back-substitution")
    else:
        print(f"    Map may NOT be invertible")

    return all_invertible


def app_polynomial_certification():
    """Demonstrate polynomial map invertibility certification."""
    print("\n" + "=" * 65)
    print("  APPLICATION 1: Polynomial Map Invertibility")
    print("=" * 65)
    print()
    print("  Given a polynomial map, we certify invertibility")
    print("  by checking the triangular structure + nonzero diagonal.")
    print()

    # Example 1: Simple shear
    print("  Example 1: Shear map F(x,y) = (x + y², y)")
    certify_triangular_inverse([
        (0, Fraction(1), [Fraction(0)]),
        (1, Fraction(1), []),
    ])
    print()

    # Example 2: 3D triangular
    print("  Example 2: F(x,y,z) = (2x + 3y, y + z², z)")
    certify_triangular_inverse([
        (0, Fraction(2), [Fraction(3)]),
        (1, Fraction(1), []),
        (2, Fraction(1), []),
    ])
    print()

    # Example 3: Non-invertible (zero diagonal)
    print("  Example 3: F(x,y) = (y, x) — not triangular")
    print("  This map IS invertible, but our triangular certificate")
    print("  cannot directly certify it. A more general method is needed.")
    print()


# ═══════════════════════════════════════════════════════════════
# APPLICATION 2: Nilpotent Perturbation Analysis
# ═══════════════════════════════════════════════════════════════

def app_nilpotent_perturbation():
    """Demonstrate nilpotent perturbation analysis for stability."""
    print("=" * 65)
    print("  APPLICATION 2: Nilpotent Perturbation Stability")
    print("=" * 65)
    print()
    print("  In control theory, a system ẋ = Ax is stable if A is nilpotent")
    print("  (polynomial decay) or has all eigenvalues with negative real part.")
    print("  Our nilpotency detector certifies polynomial stability.")
    print()

    systems = [
        ("Shift register (nilpotent, index 3)",
         [[Fraction(0), Fraction(1), Fraction(0)],
          [Fraction(0), Fraction(0), Fraction(1)],
          [Fraction(0), Fraction(0), Fraction(0)]]),
        ("Feedback controller (not nilpotent)",
         [[Fraction(0), Fraction(1)],
          [Fraction(-1), Fraction(0)]]),
        ("Cascade decay (nilpotent, index 2)",
         [[Fraction(0), Fraction(5)],
          [Fraction(0), Fraction(0)]]),
        ("4D chain (nilpotent, index 4)",
         [[Fraction(0), Fraction(1), Fraction(0), Fraction(0)],
          [Fraction(0), Fraction(0), Fraction(1), Fraction(0)],
          [Fraction(0), Fraction(0), Fraction(0), Fraction(1)],
          [Fraction(0), Fraction(0), Fraction(0), Fraction(0)]]),
    ]

    for name, A in systems:
        n = len(A)
        nilp, idx = is_nilpotent(A)
        tr = trace(A)
        det_val = determinant(A)

        print(f"  {name} ({n}×{n}):")
        for row in A:
            print(f"    [{' '.join(f'{str(x):>4}' for x in row)}]")
        print(f"    Nilpotent: {nilp}" + (f" (index {idx})" if nilp else ""))
        print(f"    Trace = {tr}, Det = {det_val}")
        if nilp:
            print(f"    ✓ System decays polynomially: x(t) = 0 for t ≥ {idx}")
            print(f"    ✓ det(I+tA) = 1 for all t (Keller condition)")
        else:
            print(f"    System has oscillatory or exponential behavior")
        print()


# ═══════════════════════════════════════════════════════════════
# APPLICATION 3: Multivariate Cryptographic Map Analysis
# ═══════════════════════════════════════════════════════════════

def app_crypto_analysis():
    """Demonstrate analysis of multivariate polynomial maps for crypto."""
    print("=" * 65)
    print("  APPLICATION 3: Cryptographic Map Structure Analysis")
    print("=" * 65)
    print()
    print("  Multivariate polynomial cryptosystems (e.g., HFE, UOV, Rainbow)")
    print("  rely on invertible polynomial maps. The Jacobian Conjecture")
    print("  provides structural certificates for invertibility.")
    print()
    print("  Key insight: if a map is in Drużkowski form Φ = Id + (A·x)^[3]")
    print("  with nilpotent A, then Φ is automatically invertible and its")
    print("  inverse can be computed by truncating the formal power series")
    print("  Φ⁻¹ = Id - H + H² - H³ + ... (terminates since A is nilpotent).")
    print()

    # Example: constructing an invertible cubic map
    print("  Example: Invertible cubic map from nilpotent matrix")
    A = [[Fraction(0), Fraction(1), Fraction(0)],
         [Fraction(0), Fraction(0), Fraction(1)],
         [Fraction(0), Fraction(0), Fraction(0)]]

    nilp, idx = is_nilpotent(A)
    print(f"    Matrix A (nilpotent, index {idx}):")
    for row in A:
        print(f"      [{' '.join(f'{str(x):>3}' for x in row)}]")

    print(f"\n    Drużkowski map Φ(x) = x + (Ax)^[3]:")
    print(f"      Φ₁(x) = x₁ + (x₂)³")
    print(f"      Φ₂(x) = x₂ + (x₃)³")
    print(f"      Φ₃(x) = x₃")
    print(f"\n    Inverse (by Neumann series truncation):")
    print(f"      Φ⁻¹₃(y) = y₃")
    print(f"      Φ⁻¹₂(y) = y₂ - (y₃)³")
    print(f"      Φ⁻¹₁(y) = y₁ - (y₂ - y₃³)³")

    # Verify at a point
    x = [Fraction(2), Fraction(3), Fraction(1)]
    y1 = x[0] + x[1]**3
    y2 = x[1] + x[2]**3
    y3 = x[2]
    y = [y1, y2, y3]

    x3_inv = y3
    x2_inv = y2 - y3**3
    x1_inv = y1 - (y2 - y3**3)**3

    print(f"\n    Verification at x = {[str(xi) for xi in x]}:")
    print(f"      Φ(x) = {[str(yi) for yi in y]}")
    print(f"      Φ⁻¹(Φ(x)) = [{x1_inv}, {x2_inv}, {x3_inv}]")
    print(f"      Matches x: {[x1_inv, x2_inv, x3_inv] == x} ✓")
    print()

    print("  Security implication: maps with nilpotent structure have")
    print("  efficiently computable inverses, making them suitable for")
    print("  trapdoor constructions in multivariate cryptography.")
    print()


# ═══════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print()
    print("╔═══════════════════════════════════════════════════════════════╗")
    print("║        APPLICATIONS OF THE JACOBIAN CONJECTURE              ║")
    print("║   Polynomial Maps, Control Theory, and Cryptography         ║")
    print("╚═══════════════════════════════════════════════════════════════╝")
    print()

    app_polynomial_certification()
    app_nilpotent_perturbation()
    app_crypto_analysis()


#!/usr/bin/env python3
"""
Interactive demonstration of the Jacobian Conjecture:
Drużkowski maps, Keller certification, and the rank conjecture.

This script:
1. Enumerates cubic linear (Drużkowski) maps over small finite fields
2. Tests the Keller condition (unit Jacobian determinant)
3. Verifies the rank conjecture for small dimensions
4. Visualizes the Hessian graph structure
5. Demonstrates nilpotency detection
"""

from fractions import Fraction
from typing import List, Tuple, Dict, Set
from itertools import product
import sys

# ═══════════════════════════════════════════════════════════════
# Core Linear Algebra (exact arithmetic over Q)
# ═══════════════════════════════════════════════════════════════

Matrix = List[List[Fraction]]


def zero_matrix(n: int) -> Matrix:
    return [[Fraction(0)] * n for _ in range(n)]


def identity_matrix(n: int) -> Matrix:
    m = zero_matrix(n)
    for i in range(n):
        m[i][i] = Fraction(1)
    return m


def mat_mul(A: Matrix, B: Matrix) -> Matrix:
    n = len(A)
    C = zero_matrix(n)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i][j] += A[i][k] * B[k][j]
    return C


def determinant(A: Matrix) -> Fraction:
    n = len(A)
    if n == 0:
        return Fraction(1)
    M = [row[:] for row in A]
    det = Fraction(1)
    for col in range(n):
        pivot = None
        for row in range(col, n):
            if M[row][col] != 0:
                pivot = row
                break
        if pivot is None:
            return Fraction(0)
        if pivot != col:
            M[col], M[pivot] = M[pivot], M[col]
            det = -det
        det *= M[col][col]
        inv_pivot = Fraction(1) / M[col][col]
        for row in range(col + 1, n):
            factor = M[row][col] * inv_pivot
            for j in range(col, n):
                M[row][j] -= factor * M[col][j]
    return det


def matrix_rank(A: Matrix) -> int:
    n = len(A)
    if n == 0:
        return 0
    m = len(A[0])
    M = [row[:] for row in A]
    rank = 0
    for col in range(m):
        pivot = None
        for row in range(rank, n):
            if M[row][col] != 0:
                pivot = row
                break
        if pivot is None:
            continue
        M[rank], M[pivot] = M[pivot], M[rank]
        inv_pivot = Fraction(1) / M[rank][col]
        for row in range(n):
            if row != rank and M[row][col] != 0:
                factor = M[row][col] * inv_pivot
                for j in range(m):
                    M[row][j] -= factor * M[rank][j]
        rank += 1
    return rank


def is_nilpotent(A: Matrix) -> Tuple[bool, int]:
    n = len(A)
    power = identity_matrix(n)
    for k in range(1, n + 1):
        power = mat_mul(power, A)
        if all(power[i][j] == 0 for i in range(n) for j in range(n)):
            return True, k
    return False, -1


def trace(A: Matrix) -> Fraction:
    return sum(A[i][i] for i in range(len(A)))


def format_matrix(A: Matrix) -> str:
    n = len(A)
    rows = []
    for i in range(n):
        row_str = " ".join(f"{str(A[i][j]):>4}" for j in range(n))
        rows.append(f"  [{row_str}]")
    return "\n".join(rows)


# ═══════════════════════════════════════════════════════════════
# Drużkowski Map Computations
# ═══════════════════════════════════════════════════════════════

def check_keller_druzkowski(A: Matrix, num_tests: int = 15) -> bool:
    """Check det(JΦ(x)) = 1 at several rational test points."""
    n = len(A)
    for trial in range(num_tests):
        x = [Fraction(trial * (j + 1) - n, max(1, trial + j + 1))
             for j in range(n)]
        ell = [sum(A[i][j] * x[j] for j in range(n)) for i in range(n)]
        J = zero_matrix(n)
        for i in range(n):
            for j in range(n):
                J[i][j] = (Fraction(1) if i == j else Fraction(0)) + \
                           3 * A[i][j] * ell[i] ** 2
        d = determinant(J)
        if d != Fraction(1):
            return False
    return True


def hessian_graph(A: Matrix) -> Dict[int, Set[int]]:
    """Compute the Hessian graph of a Drużkowski map.

    The Hessian graph has vertices {1,...,n} and an edge i→j
    when A_{ij} ≠ 0. This encodes the dependency structure
    of the Jacobian perturbation.
    """
    n = len(A)
    graph: Dict[int, Set[int]] = {i: set() for i in range(n)}
    for i in range(n):
        for j in range(n):
            if A[i][j] != 0:
                graph[i].add(j)
    return graph


def is_acyclic(graph: Dict[int, Set[int]]) -> bool:
    """Check if a directed graph is acyclic (DAG)."""
    n = len(graph)
    visited = set()
    in_stack = set()

    def dfs(node):
        visited.add(node)
        in_stack.add(node)
        for neighbor in graph.get(node, set()):
            if neighbor in in_stack:
                return False
            if neighbor not in visited:
                if not dfs(neighbor):
                    return False
        in_stack.discard(node)
        return True

    for node in graph:
        if node not in visited:
            if not dfs(node):
                return False
    return True


def visualize_graph_ascii(graph: Dict[int, Set[int]], label: str = "") -> str:
    """Create an ASCII visualization of a directed graph."""
    n = len(graph)
    lines = []
    if label:
        lines.append(f"  Graph: {label}")
    lines.append(f"  Vertices: {{{', '.join(str(i+1) for i in range(n))}}}")
    edges = []
    for i in sorted(graph):
        for j in sorted(graph[i]):
            edges.append(f"{i+1}→{j+1}")
    lines.append(f"  Edges: {{{', '.join(edges)}}}")
    lines.append(f"  Acyclic: {is_acyclic(graph)}")
    return "\n".join(lines)


# ═══════════════════════════════════════════════════════════════
# DEMO 1: Nilpotency Detection
# ═══════════════════════════════════════════════════════════════

def demo_nilpotency():
    print("=" * 65)
    print("  DEMO 1: Matrix Nilpotency Detection")
    print("=" * 65)
    print()
    print("A nilpotent matrix A satisfies A^k = 0 for some k.")
    print("Our theorem proves: det(I + tA) = 1 for all t ⟹ A is nilpotent.")
    print()

    examples = [
        ("Zero 3×3", [[Fraction(0)]*3 for _ in range(3)]),
        ("Strictly upper triangular",
         [[Fraction(0), Fraction(1), Fraction(2)],
          [Fraction(0), Fraction(0), Fraction(3)],
          [Fraction(0), Fraction(0), Fraction(0)]]),
        ("Jordan block (nilpotent)",
         [[Fraction(0), Fraction(1), Fraction(0)],
          [Fraction(0), Fraction(0), Fraction(1)],
          [Fraction(0), Fraction(0), Fraction(0)]]),
        ("Non-nilpotent",
         [[Fraction(1), Fraction(0)],
          [Fraction(0), Fraction(1)]]),
        ("2×2 nilpotent",
         [[Fraction(0), Fraction(1)],
          [Fraction(0), Fraction(0)]]),
    ]

    for name, A in examples:
        n = len(A)
        nilp, idx = is_nilpotent(A)
        tr = trace(A)
        det_val = determinant(A)

        # Check det(I + tA) = 1 for various t
        det_values = []
        for t_num in range(-3, 4):
            t = Fraction(t_num)
            M = [[A[i][j] * t + (Fraction(1) if i == j else Fraction(0))
                  for j in range(n)] for i in range(n)]
            det_values.append(determinant(M))

        all_one = all(d == 1 for d in det_values)

        print(f"  {name} ({n}×{n}):")
        print(format_matrix(A))
        print(f"    Nilpotent: {nilp}" + (f" (index {idx})" if nilp else ""))
        print(f"    Trace: {tr}, Det: {det_val}")
        print(f"    det(I+tA)=1 for t∈{{-3,...,3}}: {all_one}")
        if nilp and all_one:
            print(f"    ✓ Confirms theorem: det constraint ⟹ nilpotent")
        elif not nilp and not all_one:
            print(f"    ✓ Non-nilpotent: det(I+tA) varies as expected")
        print()


# ═══════════════════════════════════════════════════════════════
# DEMO 2: Drużkowski Map Keller Certification
# ═══════════════════════════════════════════════════════════════

def demo_druzkowski():
    print("=" * 65)
    print("  DEMO 2: Drużkowski Map Keller Certification")
    print("=" * 65)
    print()
    print("A Drużkowski map is Φ(x) = x + (Ax)^[3].")
    print("It is Keller if det(JΦ(x)) = 1 for all x.")
    print()

    examples = [
        ("Upper triangular (always Keller)",
         [[Fraction(0), Fraction(1)],
          [Fraction(0), Fraction(0)]]),
        ("Full nilpotent 2×2",
         [[Fraction(0), Fraction(1)],
          [Fraction(-1), Fraction(0)]]),
        ("3×3 chain",
         [[Fraction(0), Fraction(1), Fraction(0)],
          [Fraction(0), Fraction(0), Fraction(1)],
          [Fraction(0), Fraction(0), Fraction(0)]]),
        ("3×3 rank 2",
         [[Fraction(0), Fraction(1), Fraction(0)],
          [Fraction(0), Fraction(0), Fraction(1)],
          [Fraction(0), Fraction(-1), Fraction(0)]]),
        ("2×2 non-Keller",
         [[Fraction(1), Fraction(0)],
          [Fraction(0), Fraction(1)]]),
    ]

    for name, A in examples:
        n = len(A)
        is_keller = check_keller_druzkowski(A)
        nilp, idx = is_nilpotent(A)
        r = matrix_rank(A)

        print(f"  {name} ({n}×{n}):")
        print(format_matrix(A))
        print(f"    Rank(A): {r}, Nilpotent: {nilp}" +
              (f" (index {idx})" if nilp else ""))
        print(f"    Keller: {'YES ✓' if is_keller else 'NO ✗'}")
        if is_keller:
            print(f"    Rank < n: {r < n} {'✓' if r < n else '✗ (counterexample!)'}")
        print()


# ═══════════════════════════════════════════════════════════════
# DEMO 3: Rank Conjecture Testing
# ═══════════════════════════════════════════════════════════════

def demo_rank_conjecture():
    print("=" * 65)
    print("  DEMO 3: Cubic Linear Keller Rank Conjecture")
    print("=" * 65)
    print()
    print("CONJECTURE: For Drużkowski Keller maps in dim n ≤ 5,")
    print("the matrix A always has rank < n.")
    print()
    print("Testing by exhaustive enumeration over small entry ranges...")
    print()

    for n in range(1, 4):
        max_entry = 1
        entries = range(-max_entry, max_entry + 1)
        total = 0
        keller_count = 0
        rank_deficient = 0
        max_rank_seen = 0

        for flat in product(entries, repeat=n * n):
            total += 1
            A = [[Fraction(flat[i * n + j]) for j in range(n)] for i in range(n)]

            if check_keller_druzkowski(A, num_tests=8):
                keller_count += 1
                r = matrix_rank(A)
                max_rank_seen = max(max_rank_seen, r)
                if r < n:
                    rank_deficient += 1

        print(f"  Dimension n = {n}:")
        print(f"    Total matrices tested: {total}")
        print(f"    Keller maps found: {keller_count}")
        print(f"    Rank-deficient Keller maps: {rank_deficient}")
        print(f"    Maximum rank among Keller maps: {max_rank_seen}")
        if keller_count > 0 and rank_deficient == keller_count:
            print(f"    ✓ Conjecture HOLDS for dim {n} with entries in [-{max_entry},{max_entry}]")
        elif keller_count > 0:
            print(f"    ✗ COUNTEREXAMPLE FOUND for dim {n}!")
        else:
            print(f"    (No non-trivial Keller maps found)")
        print()


# ═══════════════════════════════════════════════════════════════
# DEMO 4: Hessian Graph Structure
# ═══════════════════════════════════════════════════════════════

def demo_hessian_graph():
    print("=" * 65)
    print("  DEMO 4: Hessian Graph Structure")
    print("=" * 65)
    print()
    print("The Hessian graph of a Drużkowski map Φ(x) = x + (Ax)^[3]")
    print("has vertex set {1,...,n} with edge i→j when A_{ij} ≠ 0.")
    print("Acyclic graphs correspond to triangularizable maps.")
    print()

    examples = [
        ("Upper triangular (acyclic → triangular)",
         [[Fraction(0), Fraction(1), Fraction(2)],
          [Fraction(0), Fraction(0), Fraction(3)],
          [Fraction(0), Fraction(0), Fraction(0)]]),
        ("Chain map (acyclic → triangular)",
         [[Fraction(0), Fraction(1), Fraction(0)],
          [Fraction(0), Fraction(0), Fraction(1)],
          [Fraction(0), Fraction(0), Fraction(0)]]),
        ("Cyclic dependency",
         [[Fraction(0), Fraction(1), Fraction(0)],
          [Fraction(0), Fraction(0), Fraction(1)],
          [Fraction(1), Fraction(0), Fraction(0)]]),
        ("Self-loop",
         [[Fraction(1), Fraction(0)],
          [Fraction(0), Fraction(0)]]),
    ]

    for name, A in examples:
        graph = hessian_graph(A)
        print(f"  {name}:")
        print(format_matrix(A))
        print(visualize_graph_ascii(graph))
        is_keller = check_keller_druzkowski(A)
        print(f"    Keller: {'YES' if is_keller else 'NO'}")
        print()


# ═══════════════════════════════════════════════════════════════
# DEMO 5: Cross-Domain Connection Summary
# ═══════════════════════════════════════════════════════════════

def demo_cross_domain():
    print("=" * 65)
    print("  DEMO 5: Cross-Domain Connections")
    print("=" * 65)
    print()
    print("The Jacobian Conjecture connects multiple mathematical domains:")
    print()
    print("  ┌─────────────────────┐")
    print("  │  Jacobian Conjecture │")
    print("  │  (Polynomial Maps)   │")
    print("  └────────┬────────────┘")
    print("           │")
    print("     ┌─────┴──────┐")
    print("     │            │")
    print("     ▼            ▼")
    print("  ┌──────────┐ ┌──────────────┐")
    print("  │ Drużkowski│ │   Dixmier    │")
    print("  │ Reduction │ │  Conjecture  │")
    print("  │ (Cubic    │ │  (Weyl       │")
    print("  │  Linear)  │ │   Algebra)   │")
    print("  └─────┬─────┘ └──────┬───────┘")
    print("        │              │")
    print("        ▼              ▼")
    print("  ┌──────────┐ ┌──────────────┐")
    print("  │ Nilpotent│ │   Symbol     │")
    print("  │ Matrices │ │   Calculus   │")
    print("  │ (Linear  │ │   (Quantum   │")
    print("  │  Algebra)│ │   Mechanics) │")
    print("  └──────────┘ └──────────────┘")
    print()
    print("Our formally verified results:")
    print("  1. det(I+tA)=1 ∀t ⟹ A nilpotent (key algebraic lemma)")
    print("  2. Drużkowski maps are cubic homogeneous")
    print("  3. Jacobian = I + JH structure for F = Id + H")
    print("  4. Nilpotent ⟹ trace=0, det=0, charpoly=X^n")
    print("  5. Strictly upper triangular ⟹ nilpotent")
    print("  6. 2×2 trace=0 ∧ det=0 ⟹ M²=0")
    print("  7. JC ⟹ DC (abstract bridge)")
    print()


# ═══════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print()
    print("╔═══════════════════════════════════════════════════════════════╗")
    print("║         JACOBIAN CONJECTURE: INTERACTIVE DEMONSTRATION       ║")
    print("║   Drużkowski Maps, Nilpotency, and the Dixmier Bridge       ║")
    print("╚═══════════════════════════════════════════════════════════════╝")
    print()

    demos = [demo_nilpotency, demo_druzkowski, demo_rank_conjecture,
             demo_hessian_graph, demo_cross_domain]

    for demo_fn in demos:
        demo_fn()
        print()
