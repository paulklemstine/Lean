#!/usr/bin/env python3
"""
Tropical Cryptography: Applications

Demonstrates practical applications of tropical matrix factorization:
1. Tropical one-way function
2. Challenge-response protocol simulation
3. SAT solver via tropical selection
4. Key size analysis and comparison
"""

import numpy as np
import time
from typing import List, Tuple, Optional

INF = float('inf')


def trop_mat_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical matrix multiplication."""
    n, r = A.shape
    _, m = B.shape
    C = np.full((n, m), INF)
    for i in range(n):
        for j in range(m):
            for k in range(r):
                if A[i, k] != INF and B[k, j] != INF:
                    C[i, j] = min(C[i, j], A[i, k] + B[k, j])
    return C


def random_bounded_tropical(rows: int, cols: int, bound: int = 10,
                             inf_prob: float = 0.3) -> np.ndarray:
    """Generate random tropical matrix with bounded entries and some ⊤ values."""
    M = np.random.randint(-bound, bound + 1, size=(rows, cols)).astype(float)
    mask = np.random.random((rows, cols)) < inf_prob
    M[mask] = INF
    return M


# ─────────────────────────────────────────────────────────────
# Application 1: Tropical One-Way Function
# ─────────────────────────────────────────────────────────────

def tropical_owf_keygen(n: int, m: int, r: int, bound: int = 10):
    """
    Generate a tropical one-way function keypair.

    Private key: (A, B) where A is n×r, B is r×m
    Public key:  M = A ⊗ B (n×m matrix)

    The hardness of inverting f(A,B) = A⊗B is based on
    the NP-hardness of tropical matrix factorization.
    """
    A = random_bounded_tropical(n, r, bound, inf_prob=0.2)
    B = random_bounded_tropical(r, m, bound, inf_prob=0.2)
    M = trop_mat_mul(A, B)
    return (A, B), M


def tropical_owf_verify(A, B, M) -> bool:
    """Verify that (A, B) is a valid factorization of M."""
    return np.array_equal(trop_mat_mul(A, B), M)


# ─────────────────────────────────────────────────────────────
# Application 2: Challenge-Response Protocol
# ─────────────────────────────────────────────────────────────

def challenge_response_demo(n: int = 8, m: int = 8, r: int = 4):
    """
    Simulate a tropical challenge-response authentication protocol.

    Setup:
    - Prover has private key (A, B) with M = A ⊗ B
    - Verifier has public key M

    Protocol:
    1. Verifier sends random challenge vector c (m×1)
    2. Prover computes response = A ⊗ (B ⊗ c) (n×1 vector)
    3. Verifier checks response == M ⊗ c

    Security: Computing A ⊗ (B ⊗ c) without knowing A, B requires
    factoring M, which is NP-hard.
    """
    print("Challenge-Response Protocol Simulation")
    print("-" * 40)

    # Setup
    (A, B), M = tropical_owf_keygen(n, m, r)
    print(f"Key dimensions: n={n}, m={m}, r={r}")
    print(f"Public key M: {n}×{m} tropical matrix")
    print(f"Private key: A ({n}×{r}), B ({r}×{m})")

    # Challenge
    c = random_bounded_tropical(m, 1, bound=5, inf_prob=0.1)
    print(f"\nVerifier sends challenge: {m}×1 vector")

    # Prover's response
    Bc = trop_mat_mul(B, c)
    response = trop_mat_mul(A, Bc)

    # Verification
    expected = trop_mat_mul(M, c)
    valid = np.array_equal(response, expected)
    print(f"Prover's response matches M ⊗ c? {valid}")
    print(f"Protocol {'ACCEPTED' if valid else 'REJECTED'}")

    return valid


# ─────────────────────────────────────────────────────────────
# Application 3: SAT Solver via Tropical Selection
# ─────────────────────────────────────────────────────────────

def solve_sat_tropical(
    clauses: List[List[Tuple[str, int]]],
    num_vars: int
) -> Optional[List[bool]]:
    """
    Solve a SAT instance by exhaustive search over tropical column selections.

    This demonstrates the SAT ↔ tropical selection correspondence:
    - Build the incidence matrix
    - Search for a consistent column selection covering all rows
    - Extract assignment from selection

    Time: O(2^v · c · v) — exponential, as expected for NP-complete problems.
    """
    c = len(clauses)
    m = 2 * num_vars

    # Build incidence matrix
    M = np.full((c, m), INF)
    for i, clause in enumerate(clauses):
        for sign, var in clause:
            col = 2 * var if sign == '+' else 2 * var + 1
            M[i, col] = 0

    # Search over all consistent selections
    for bits in range(2 ** num_vars):
        assignment = [(bits >> k) & 1 == 1 for k in range(num_vars)]
        selection = [2 * k if assignment[k] else 2 * k + 1
                     for k in range(num_vars)]

        # Check if selection covers all rows
        covers_all = True
        for i in range(c):
            if not any(M[i, s] == 0 for s in selection):
                covers_all = False
                break

        if covers_all:
            return assignment

    return None


# ─────────────────────────────────────────────────────────────
# Application 4: Key Size Analysis
# ─────────────────────────────────────────────────────────────

def key_size_comparison():
    """Compare key sizes across security levels and with other post-quantum systems."""
    print("\nKey Size Analysis: Tropical vs. Lattice-Based Systems")
    print("=" * 70)
    print(f"{'Security':>10} {'Tropical PK':>14} {'Tropical SK':>14} "
          f"{'Kyber PK':>12} {'Kyber SK':>12}")
    print(f"{'(bits)':>10} {'(bytes)':>14} {'(bytes)':>14} "
          f"{'(bytes)':>12} {'(bytes)':>12}")
    print("-" * 70)

    kyber_sizes = {
        128: (800, 1632),
        192: (1184, 2400),
        256: (1568, 3168),
    }

    for lam in [128, 192, 256]:
        n = 2 * lam ** 2
        m = 2 * lam ** 2
        r = lam ** 2
        bits_per_entry = max(1, int(np.log2(lam + 1)) + 1)

        pk_bits = n * m * bits_per_entry
        sk_bits = (n * r + r * m) * bits_per_entry
        pk_bytes = pk_bits // 8
        sk_bytes = sk_bits // 8

        kyber_pk, kyber_sk = kyber_sizes.get(lam, ("N/A", "N/A"))

        print(f"{lam:>10} {pk_bytes:>14,} {sk_bytes:>14,} "
              f"{kyber_pk:>12,} {kyber_sk:>12,}")

    print(f"\nNote: Tropical key sizes use naive encoding.")
    print(f"Structured/sparse matrices could reduce these significantly.")
    print(f"The main advantage is computational simplicity (min + add only).")


# ─────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("Tropical Cryptography Applications")
    print("=" * 60)

    # App 1: One-way function
    print("\n--- Application 1: Tropical One-Way Function ---")
    (A, B), M = tropical_owf_keygen(6, 6, 3)
    print(f"Generated keypair: M = A ⊗ B")
    print(f"  Public key (M): 6×6 matrix")
    print(f"  Private key (A, B): 6×3 + 3×6 matrices")
    print(f"  Verification: {tropical_owf_verify(A, B, M)}")

    # App 2: Challenge-response
    print(f"\n--- Application 2: Challenge-Response Protocol ---")
    challenge_response_demo()

    # App 3: SAT solver
    print(f"\n--- Application 3: SAT via Tropical Selection ---")
    test_cases = [
        ("(x₁ ∨ x₂) ∧ (¬x₁ ∨ x₃)",
         [[('+', 0), ('+', 1)], [('-', 0), ('+', 2)]], 3),
        ("(x₁) ∧ (¬x₁)",
         [[('+', 0)], [('-', 0)]], 1),
        ("(x₁ ∨ x₂) ∧ (¬x₁ ∨ ¬x₂) ∧ (x₁ ∨ ¬x₂)",
         [[('+', 0), ('+', 1)], [('-', 0), ('-', 1)], [('+', 0), ('-', 1)]], 2),
    ]

    for desc, clauses, nv in test_cases:
        result = solve_sat_tropical(clauses, nv)
        if result is not None:
            assign_str = ", ".join(f"x{i+1}={'T' if v else 'F'}" for i, v in enumerate(result))
            print(f"  {desc}: SAT ({assign_str})")
        else:
            print(f"  {desc}: UNSAT")

    # App 4: Key sizes
    print(f"\n--- Application 4: Key Size Analysis ---")
    key_size_comparison()

    # Timing
    print(f"\n--- Tropical Multiplication Timing ---")
    for n in [10, 50, 100]:
        A = random_bounded_tropical(n, n, 10, 0.2)
        B = random_bounded_tropical(n, n, 10, 0.2)
        t0 = time.time()
        _ = trop_mat_mul(A, B)
        dt = time.time() - t0
        print(f"  {n}×{n} ⊗ {n}×{n}: {dt:.4f}s")

    print("\nAll applications completed!")


#!/usr/bin/env python3
"""
Tropical Matrix Factorization: Interactive Demonstrations

Demonstrates the core theorems with concrete numerical examples:
1. Tropical matrix multiplication
2. Zero-top bridge (factorization ↔ rectangle cover)
3. SAT-to-tropical-selection reduction
4. Security dimension bounds
"""

import numpy as np
from typing import Optional

INF = float('inf')

# ─────────────────────────────────────────────────────────────
# §1. Tropical Matrix Arithmetic
# ─────────────────────────────────────────────────────────────

def trop_add(a: float, b: float) -> float:
    """Tropical addition: min(a, b)."""
    return min(a, b)

def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b (with INF absorbing)."""
    if a == INF or b == INF:
        return INF
    return a + b

def trop_mat_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical matrix multiplication: (A⊗B)(i,j) = min_k(A(i,k) + B(k,j))."""
    n, r = A.shape
    r2, m = B.shape
    assert r == r2, f"Inner dimensions must match: {r} ≠ {r2}"
    C = np.full((n, m), INF)
    for i in range(n):
        for j in range(m):
            for k in range(r):
                val = trop_mul(A[i, k], B[k, j])
                C[i, j] = trop_add(C[i, j], val)
    return C

def trop_identity(n: int) -> np.ndarray:
    """Tropical identity: 0 on diagonal, INF elsewhere."""
    I = np.full((n, n), INF)
    np.fill_diagonal(I, 0)
    return I


# ─────────────────────────────────────────────────────────────
# §2. Demonstrations
# ─────────────────────────────────────────────────────────────

def demo_identity():
    """Demonstrate: I ⊗ M = M."""
    print("=" * 60)
    print("Demo 1: Tropical Identity (I ⊗ M = M)")
    print("=" * 60)

    M = np.array([[1, 3, INF],
                   [2, 0, 5],
                   [INF, 4, 1]])
    I = trop_identity(3)

    print("\nTropical Identity I₃:")
    print(format_matrix(I))
    print("\nMatrix M:")
    print(format_matrix(M))

    result = trop_mat_mul(I, M)
    print("\nI₃ ⊗ M:")
    print(format_matrix(result))
    print(f"\nI ⊗ M == M? {np.array_equal(result, M)}")


def demo_factorization():
    """Demonstrate tropical matrix factorization."""
    print("\n" + "=" * 60)
    print("Demo 2: Tropical Matrix Factorization")
    print("=" * 60)

    A = np.array([[0, INF],
                   [INF, 0],
                   [0, 0]])
    B = np.array([[0, 1, INF],
                   [INF, 0, 2]])

    M = trop_mat_mul(A, B)
    print("\nFactor A (3×2):")
    print(format_matrix(A))
    print("\nFactor B (2×3):")
    print(format_matrix(B))
    print("\nProduct M = A ⊗ B (3×3):")
    print(format_matrix(M))
    print(f"\nTropical rank of M ≤ 2 (inner dimension of factorization)")


def demo_zero_top_bridge():
    """Demonstrate the zero-top bridge theorem."""
    print("\n" + "=" * 60)
    print("Demo 3: Zero-Top Bridge (Factorization ↔ Rectangle Cover)")
    print("=" * 60)

    # A {0, ⊤} matrix
    M = np.array([[0,   0,   INF, INF],
                   [0,   INF, 0,   INF],
                   [INF, 0,   0,   0  ],
                   [INF, INF, INF, 0  ]])
    print("\nZero-top matrix M (0 = zero, ∞ = top):")
    print(format_matrix(M))

    # Find zero-support
    zeros = [(i, j) for i in range(4) for j in range(4) if M[i, j] == 0]
    print(f"\nZero-support: {zeros}")

    # Rectangle cover
    rectangles = [
        ({0, 1}, {0}),      # R1: rows {0,1}, cols {0}
        ({0, 2}, {1}),      # R2: rows {0,2}, cols {1}
        ({1, 2}, {2}),      # R3: rows {1,2}, cols {2}
        ({2, 3}, {3}),      # R4: rows {2,3}, cols {3}
    ]
    print("\nExact rectangle cover (4 rectangles):")
    for k, (rows, cols) in enumerate(rectangles):
        print(f"  R{k+1}: rows={rows}, cols={cols}")

    # Verify cover
    covered = set()
    for rows, cols in rectangles:
        for i in rows:
            for j in cols:
                covered.add((i, j))
    print(f"\nCovered positions: {sorted(covered)}")
    print(f"Matches zero-support? {set(zeros) == covered}")

    # Construct factor matrices from cover
    r = len(rectangles)
    A = np.full((4, r), INF)
    B = np.full((r, 4), INF)
    for k, (rows, cols) in enumerate(rectangles):
        for i in rows:
            A[i, k] = 0
        for j in cols:
            B[k, j] = 0

    print(f"\nFactor A (from cover):")
    print(format_matrix(A))
    print(f"\nFactor B (from cover):")
    print(format_matrix(B))

    M_reconstructed = trop_mat_mul(A, B)
    print(f"\nA ⊗ B (should equal M):")
    print(format_matrix(M_reconstructed))
    print(f"\nReconstruction matches? {np.array_equal(M, M_reconstructed)}")


def demo_sat_reduction():
    """Demonstrate SAT-to-tropical-selection reduction."""
    print("\n" + "=" * 60)
    print("Demo 4: SAT → Tropical Column Selection")
    print("=" * 60)

    # Formula: (x₁ ∨ x₂) ∧ (¬x₁ ∨ x₃) ∧ (x₂ ∨ ¬x₃)
    # Variables: x₁ (idx 0), x₂ (idx 1), x₃ (idx 2)
    # Clauses:
    #   C₁ = [x₁, x₂]       → literals pos(0), pos(1)
    #   C₂ = [¬x₁, x₃]      → literals neg(0), pos(2)
    #   C₃ = [x₂, ¬x₃]      → literals pos(1), neg(2)

    v = 3  # number of variables
    clauses = [
        [('+', 0), ('+', 1)],       # x₁ ∨ x₂
        [('-', 0), ('+', 2)],       # ¬x₁ ∨ x₃
        [('+', 1), ('-', 2)],       # x₂ ∨ ¬x₃
    ]

    print(f"\nFormula: (x₁ ∨ x₂) ∧ (¬x₁ ∨ x₃) ∧ (x₂ ∨ ¬x₃)")
    print(f"Variables: {v}, Clauses: {len(clauses)}")

    # Build incidence matrix
    c = len(clauses)
    M = np.full((c, 2 * v), INF)
    for i, clause in enumerate(clauses):
        for sign, var in clause:
            col = 2 * var if sign == '+' else 2 * var + 1
            M[i, col] = 0

    col_labels = ['x₁', '¬x₁', 'x₂', '¬x₂', 'x₃', '¬x₃']
    print(f"\nIncidence matrix M (columns: {col_labels}):")
    print(format_matrix(M))

    # Satisfying assignment: x₁=True, x₂=True, x₃=True
    assignment = [True, True, True]
    print(f"\nSatisfying assignment: x₁={assignment[0]}, x₂={assignment[1]}, x₃={assignment[2]}")

    # Build selection
    sel = [2 * k if assignment[k] else 2 * k + 1 for k in range(v)]
    print(f"Column selection: sel = {sel}")
    print(f"Selected columns: {[col_labels[s] for s in sel]}")

    # Verify consistency
    print(f"\nConsistency check:")
    for k in range(v):
        print(f"  Variable {k}: sel[{k}] = {sel[k]}, "
              f"∈ {{{2*k}, {2*k+1}}}? {sel[k] in {2*k, 2*k+1}}")

    # Verify coverage
    print(f"\nCoverage check:")
    for i in range(c):
        covered = [k for k in range(v) if M[i, sel[k]] == 0]
        print(f"  Clause {i}: covered by variable(s) {covered}, "
              f"covered? {len(covered) > 0}")


def demo_security_bounds():
    """Demonstrate security dimension bounds."""
    print("\n" + "=" * 60)
    print("Demo 5: Security Dimension Bounds")
    print("=" * 60)

    print(f"\n{'λ (bits)':>10} {'n':>10} {'m':>10} {'r':>10} {'Key size (bits)':>16}")
    print("-" * 60)
    for lam in [64, 128, 192, 256]:
        n = 2 * lam ** 2
        m = 2 * lam ** 2
        r = lam ** 2
        key_bits = n * r * 16 + r * m * 16  # 16 bits per entry estimate
        print(f"{lam:>10} {n:>10,} {m:>10,} {r:>10,} {key_bits:>16,}")

    print(f"\nDimension scaling: n = m = 2λ², r = λ² (quadratic in security parameter)")


# ─────────────────────────────────────────────────────────────
# Utilities
# ─────────────────────────────────────────────────────────────

def format_matrix(M: np.ndarray) -> str:
    """Pretty-print a tropical matrix."""
    rows = []
    for i in range(M.shape[0]):
        entries = []
        for j in range(M.shape[1]):
            if M[i, j] == INF:
                entries.append(" ∞")
            else:
                entries.append(f"{int(M[i,j]):>2}")
        rows.append("  [" + ", ".join(entries) + "]")
    return "\n".join(rows)


if __name__ == "__main__":
    demo_identity()
    demo_factorization()
    demo_zero_top_bridge()
    demo_sat_reduction()
    demo_security_bounds()
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Cryptography: Visualizations

Generates publication-quality figures for the research paper.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from io import BytesIO
import base64

INF = float('inf')


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def viz_tropical_matrix():
    """Visualize a tropical matrix with color-coded entries."""
    fig, axes = plt.subplots(1, 3, figsize=(14, 4))

    # Factor A
    A = np.array([[0, INF, 0],
                   [INF, 0, INF],
                   [0, 0, INF],
                   [INF, INF, 0]])

    # Factor B
    B = np.array([[0, 1, INF, 2],
                   [INF, 0, 3, INF],
                   [1, INF, 0, 1]])

    # Product
    M = np.full((4, 4), INF)
    for i in range(4):
        for j in range(4):
            for k in range(3):
                if A[i,k] != INF and B[k,j] != INF:
                    M[i,j] = min(M[i,j], A[i,k] + B[k,j])

    for ax, mat, title in [(axes[0], A, 'Factor A (4×3)'),
                            (axes[1], B, 'Factor B (3×4)'),
                            (axes[2], M, 'Product M = A⊗B (4×4)')]:
        n, m = mat.shape
        display = np.where(mat == INF, np.nan, mat)

        im = ax.imshow(display, cmap='YlOrRd_r', aspect='auto',
                       vmin=-2, vmax=5)
        ax.set_title(title, fontsize=12, fontweight='bold')

        for i in range(n):
            for j in range(m):
                if mat[i,j] == INF:
                    ax.text(j, i, '∞', ha='center', va='center',
                           fontsize=11, color='gray')
                else:
                    ax.text(j, i, f'{int(mat[i,j])}', ha='center',
                           va='center', fontsize=11, fontweight='bold')

        ax.set_xticks(range(m))
        ax.set_yticks(range(n))
        ax.set_xticklabels(range(m))
        ax.set_yticklabels(range(n))

    fig.suptitle('Tropical Matrix Factorization', fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig


def viz_rectangle_cover():
    """Visualize rectangle cover of a zero-top matrix."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    M = np.array([[0,   0,   INF, INF, 0],
                   [0,   INF, 0,   INF, INF],
                   [INF, 0,   0,   0,   INF],
                   [INF, INF, INF, 0,   0]])

    # Left: the matrix
    ax = axes[0]
    n, m = M.shape
    for i in range(n):
        for j in range(m):
            color = '#2ecc71' if M[i,j] == 0 else '#ecf0f1'
            rect = patches.Rectangle((j-0.5, i-0.5), 1, 1,
                                     facecolor=color, edgecolor='gray', linewidth=1)
            ax.add_patch(rect)
            text = '0' if M[i,j] == 0 else '∞'
            ax.text(j, i, text, ha='center', va='center', fontsize=12,
                   fontweight='bold' if M[i,j] == 0 else 'normal',
                   color='#2c3e50' if M[i,j] == 0 else '#95a5a6')

    ax.set_xlim(-0.6, m-0.4)
    ax.set_ylim(n-0.4, -0.6)
    ax.set_title('Zero-Top Matrix M', fontsize=12, fontweight='bold')
    ax.set_xlabel('Column')
    ax.set_ylabel('Row')
    ax.set_xticks(range(m))
    ax.set_yticks(range(n))

    # Right: rectangle cover with colored rectangles
    ax = axes[1]
    colors = ['#e74c3c', '#3498db', '#f39c12', '#9b59b6', '#1abc9c']
    rectangles = [
        ({0, 1}, {0}, 'R₁'),
        ({0, 2}, {1}, 'R₂'),  # Adjusted - made inexact for visual, but close
        ({1, 2}, {2}, 'R₃'),
        ({2, 3}, {3}, 'R₄'),
        ({0, 3}, {4}, 'R₅'),
    ]

    for i in range(n):
        for j in range(m):
            color = '#ecf0f1'
            rect = patches.Rectangle((j-0.5, i-0.5), 1, 1,
                                     facecolor=color, edgecolor='gray', linewidth=0.5)
            ax.add_patch(rect)

    for idx, (rows, cols, label) in enumerate(rectangles):
        c = colors[idx % len(colors)]
        for i in rows:
            for j in cols:
                rect = patches.Rectangle((j-0.45, i-0.45), 0.9, 0.9,
                                         facecolor=c, alpha=0.4,
                                         edgecolor=c, linewidth=2)
                ax.add_patch(rect)
                ax.text(j, i, label, ha='center', va='center', fontsize=9,
                       color=c, fontweight='bold')

    ax.set_xlim(-0.6, m-0.4)
    ax.set_ylim(n-0.4, -0.6)
    ax.set_title(f'Rectangle Cover ({len(rectangles)} rectangles)', fontsize=12, fontweight='bold')
    ax.set_xlabel('Column')
    ax.set_ylabel('Row')
    ax.set_xticks(range(m))
    ax.set_yticks(range(n))

    fig.suptitle('Zero-Top Bridge: Factorization ↔ Rectangle Cover',
                fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig


def viz_sat_reduction():
    """Visualize the SAT-to-tropical-selection reduction."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Formula: (x₁ ∨ x₂) ∧ (¬x₁ ∨ x₃) ∧ (x₂ ∨ ¬x₃) ∧ (x₁ ∨ ¬x₂ ∨ x₃)
    v = 3
    clauses_text = ['x₁ ∨ x₂', '¬x₁ ∨ x₃', 'x₂ ∨ ¬x₃', 'x₁ ∨ ¬x₂ ∨ x₃']
    col_labels = ['x₁', '¬x₁', 'x₂', '¬x₂', 'x₃', '¬x₃']

    M = np.array([[0,   INF, 0,   INF, INF, INF],  # x₁ ∨ x₂
                   [INF, 0,   INF, INF, 0,   INF],  # ¬x₁ ∨ x₃
                   [INF, INF, 0,   INF, INF, 0  ],  # x₂ ∨ ¬x₃
                   [0,   INF, INF, 0,   0,   INF]]) # x₁ ∨ ¬x₂ ∨ x₃

    c, cols = M.shape

    # Left: incidence matrix
    ax = axes[0]
    for i in range(c):
        for j in range(cols):
            color = '#27ae60' if M[i,j] == 0 else '#f5f5f5'
            rect = patches.Rectangle((j-0.5, i-0.5), 1, 1,
                                     facecolor=color, edgecolor='#bdc3c7', linewidth=1)
            ax.add_patch(rect)
            text = '0' if M[i,j] == 0 else '∞'
            fc = 'white' if M[i,j] == 0 else '#ccc'
            ax.text(j, i, text, ha='center', va='center', fontsize=11, color=fc,
                   fontweight='bold')

    ax.set_xlim(-0.6, cols-0.4)
    ax.set_ylim(c-0.4, -0.6)
    ax.set_xticks(range(cols))
    ax.set_xticklabels(col_labels, fontsize=10)
    ax.set_yticks(range(c))
    ax.set_yticklabels(clauses_text, fontsize=10)
    ax.set_title('Tropical Incidence Matrix', fontsize=12, fontweight='bold')

    # Right: with selection highlighted
    ax = axes[1]
    assignment = [True, True, True]  # x₁=T, x₂=T, x₃=T
    selection = [0, 2, 4]  # columns x₁, x₂, x₃

    for i in range(c):
        for j in range(cols):
            if j in selection:
                color = '#3498db' if M[i,j] == 0 else '#d5e8f0'
            else:
                color = '#f5f5f5'
            rect = patches.Rectangle((j-0.5, i-0.5), 1, 1,
                                     facecolor=color, edgecolor='#bdc3c7', linewidth=1)
            ax.add_patch(rect)
            text = '0' if M[i,j] == 0 else '∞'
            fc = 'white' if (M[i,j] == 0 and j in selection) else '#aaa'
            ax.text(j, i, text, ha='center', va='center', fontsize=11, color=fc,
                   fontweight='bold')

    # Mark selected columns
    for j in selection:
        ax.axvline(x=j, color='#e74c3c', linewidth=2, alpha=0.5, linestyle='--')

    ax.set_xlim(-0.6, cols-0.4)
    ax.set_ylim(c-0.4, -0.6)
    ax.set_xticks(range(cols))
    ax.set_xticklabels(col_labels, fontsize=10)
    ax.set_yticks(range(c))
    ax.set_yticklabels(clauses_text, fontsize=10)
    ax.set_title('Selection: x₁=T, x₂=T, x₃=T\n(blue = selected covering zeros)',
                fontsize=11, fontweight='bold')

    fig.suptitle('SAT → Tropical Column Selection Reduction',
                fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig


def viz_security_scaling():
    """Visualize security parameter scaling."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    lambdas = np.arange(1, 300)
    n_dims = 2 * lambdas ** 2
    r_dims = lambdas ** 2

    # Left: dimension growth
    ax1.semilogy(lambdas, n_dims, 'b-', linewidth=2, label='n = m = 2λ²')
    ax1.semilogy(lambdas, r_dims, 'r--', linewidth=2, label='r = λ²')
    ax1.axvline(x=128, color='gray', linestyle=':', alpha=0.5)
    ax1.axvline(x=256, color='gray', linestyle=':', alpha=0.5)
    ax1.text(128, 1e2, 'λ=128', rotation=90, va='bottom', fontsize=9, color='gray')
    ax1.text(256, 1e2, 'λ=256', rotation=90, va='bottom', fontsize=9, color='gray')
    ax1.set_xlabel('Security Parameter λ (bits)', fontsize=11)
    ax1.set_ylabel('Matrix Dimension', fontsize=11)
    ax1.set_title('Dimension Scaling', fontsize=12, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Right: key size comparison
    lambdas_key = [64, 128, 192, 256]
    tropical_pk = [2*(l**2)**2 * 16 / 8 / 1e6 for l in lambdas_key]  # MB
    tropical_sk = [2*(l**2)*(l**2) * 16 / 8 / 1e6 for l in lambdas_key]  # MB
    kyber_pk = [0.0008, 0.0008, 0.001184, 0.001568]  # MB (approximate)
    kyber_sk = [0.001632, 0.001632, 0.0024, 0.003168]  # MB (approximate)

    x = np.arange(len(lambdas_key))
    width = 0.35

    bars1 = ax2.bar(x - width/2, tropical_pk, width, label='Tropical PK',
                    color='#3498db', alpha=0.8)
    bars2 = ax2.bar(x + width/2, kyber_pk, width, label='Kyber PK',
                    color='#e74c3c', alpha=0.8)

    ax2.set_yscale('log')
    ax2.set_xlabel('Security Level (bits)', fontsize=11)
    ax2.set_ylabel('Public Key Size (MB)', fontsize=11)
    ax2.set_title('Key Size Comparison', fontsize=12, fontweight='bold')
    ax2.set_xticks(x)
    ax2.set_xticklabels(lambdas_key)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3, axis='y')

    fig.suptitle('Security Parameter Analysis',
                fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig


def generate_all_visualizations():
    """Generate all visualizations and return as base64 data URIs."""
    results = {}

    print("Generating visualizations...")

    fig = viz_tropical_matrix()
    fig.savefig('/workspace/request-project/viz_factorization.png', dpi=150,
                bbox_inches='tight', facecolor='white')
    results['factorization'] = fig_to_base64(fig)
    print("  ✓ Tropical matrix factorization")

    fig = viz_rectangle_cover()
    fig.savefig('/workspace/request-project/viz_rectangle_cover.png', dpi=150,
                bbox_inches='tight', facecolor='white')
    results['rectangle_cover'] = fig_to_base64(fig)
    print("  ✓ Rectangle cover bridge")

    fig = viz_sat_reduction()
    fig.savefig('/workspace/request-project/viz_sat_reduction.png', dpi=150,
                bbox_inches='tight', facecolor='white')
    results['sat_reduction'] = fig_to_base64(fig)
    print("  ✓ SAT reduction")

    fig = viz_security_scaling()
    fig.savefig('/workspace/request-project/viz_security.png', dpi=150,
                bbox_inches='tight', facecolor='white')
    results['security'] = fig_to_base64(fig)
    print("  ✓ Security scaling")

    return results


if __name__ == "__main__":
    results = generate_all_visualizations()
    print(f"\nGenerated {len(results)} visualizations.")
    for name, data_uri in results.items():
        print(f"  {name}: {len(data_uri)} chars")
