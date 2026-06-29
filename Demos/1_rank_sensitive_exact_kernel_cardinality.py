#!/usr/bin/env python3
"""
Real-world applications of the Rank-Sensitive Kernel Cardinality Theorem.

Demonstrates applications in:
1. Cryptographic zero-knowledge proofs (linear constraint systems)
2. Error-correcting codes (nullspace code dimension)
3. Randomized algorithm analysis (Freivalds with rank awareness)
4. Privacy analysis (information leakage through linear queries)
"""

import numpy as np
from algorithms import GaloisField, gaussian_elimination, kernel_basis, affine_solution_count


# ─── Application 1: Linear Code Parameters ───────────────────────────────

def linear_code_analysis():
    """Analyze a linear error-correcting code defined by a parity-check matrix.

    A linear [n, k, d] code over GF(q) with parity-check matrix H has:
    - Block length n (number of columns of H)
    - Dimension k = n - rank(H) (by our theorem: |C| = q^k)
    - Minimum distance d (minimum Hamming weight of nonzero codewords)

    Our theorem gives the exact codeword count: |C| = q^(n - rank(H)).
    """
    print("=" * 70)
    print("APPLICATION 1: Linear Error-Correcting Code Analysis")
    print("=" * 70)
    print()

    # Hamming [7,4,3] code over GF(2)
    # Parity-check matrix
    H = np.array([
        [1, 0, 1, 0, 1, 0, 1],
        [0, 1, 1, 0, 0, 1, 1],
        [0, 0, 0, 1, 1, 1, 1],
    ])
    q = 2
    n = H.shape[1]
    _, rank_H, _ = gaussian_elimination(H, q)
    k = n - rank_H

    print(f"  Hamming [7,4,3] code over GF({q})")
    print(f"  Parity-check matrix H ({H.shape[0]}×{H.shape[1]}):")
    for row in H:
        print(f"    {row.tolist()}")
    print()
    print(f"  Block length n = {n}")
    print(f"  rank(H) = {rank_H}")
    print(f"  Code dimension k = n - rank(H) = {k}")
    print(f"  Number of codewords |C| = {q}^{k} = {q**k}")
    print(f"  Code rate R = k/n = {k}/{n} = {k/n:.4f}")
    print()

    # Verify by enumeration
    codewords = kernel_basis(H, q)
    print(f"  Kernel basis ({len(codewords)} vectors):")
    for v in codewords:
        print(f"    {v.tolist()}")
    print()

    # Count minimum weight
    from itertools import product as iproduct
    min_weight = n + 1
    total_codewords = 0
    for coeffs in iproduct(range(q), repeat=len(codewords)):
        cw = np.zeros(n, dtype=int)
        for c, bv in zip(coeffs, codewords):
            cw = (cw + c * bv) % q
        total_codewords += 1
        w = np.count_nonzero(cw)
        if w > 0:
            min_weight = min(min_weight, w)

    print(f"  Total codewords (enumerated): {total_codewords}")
    print(f"  Minimum distance d = {min_weight}")
    print(f"  Error correction capability: t = ⌊(d-1)/2⌋ = {(min_weight-1)//2}")
    print()


# ─── Application 2: Syndrome Decoding ────────────────────────────────────

def syndrome_decoding_demo():
    """Demonstrate syndrome decoding using affine solution counting.

    When a codeword c is sent and received as y = c + e (error),
    the syndrome s = H·y = H·e tells us about the error pattern.
    The number of error patterns consistent with syndrome s is |{e : H·e = s}|.
    By our theorem, this is q^(n - rank(H)) = |C| for any nonzero syndrome.
    """
    print("=" * 70)
    print("APPLICATION 2: Syndrome Decoding and Coset Structure")
    print("=" * 70)
    print()

    H = np.array([
        [1, 0, 1, 0, 1, 0, 1],
        [0, 1, 1, 0, 0, 1, 1],
        [0, 0, 0, 1, 1, 1, 1],
    ])
    q = 2
    n = H.shape[1]
    _, rank_H, _ = gaussian_elimination(H, q)

    print(f"  Hamming [7,4,3] code, H is {H.shape[0]}×{H.shape[1]} over GF({q})")
    print(f"  rank(H) = {rank_H}")
    print()
    print(f"  Number of distinct syndromes: {q}^{rank_H} = {q**rank_H}")
    print(f"  Vectors per coset: {q}^({n}-{rank_H}) = {q**(n-rank_H)}")
    print(f"  Total: {q**rank_H} × {q**(n-rank_H)} = {q**n} = {q}^{n} ✓")
    print()

    # Show coset sizes for each syndrome
    print("  Syndrome → Coset size (should all be equal):")
    from itertools import product as iproduct
    for s in iproduct(range(q), repeat=H.shape[0]):
        s_arr = np.array(s, dtype=int)
        count = affine_solution_count(H, s_arr, q)
        print(f"    s = {list(s)}: |coset| = {count}")
    print()


# ─── Application 3: Privacy / Information Leakage ────────────────────────

def privacy_analysis():
    """Analyze information leakage through linear queries over finite fields.

    If a database holds a secret vector x ∈ GF(q)^p, and an analyst
    submits linear queries (rows of a matrix M), the analyst learns M·x.
    The remaining uncertainty about x is exactly |ker(M)| = q^(p - rank(M)).

    Information leaked = rank(M) · log₂(q) bits.
    """
    print("=" * 70)
    print("APPLICATION 3: Privacy Analysis — Linear Query Information Leakage")
    print("=" * 70)
    print()

    q = 7
    p = 5
    total_entropy = p * np.log2(q)

    print(f"  Secret vector x ∈ GF({q})^{p}")
    print(f"  Total entropy: {p} × log₂({q}) = {total_entropy:.2f} bits")
    print()

    # Progressive queries
    queries = [
        np.array([[1, 0, 0, 0, 0]]),
        np.array([[1, 0, 0, 0, 0], [0, 1, 0, 0, 0]]),
        np.array([[1, 0, 0, 0, 0], [0, 1, 0, 0, 0], [0, 0, 1, 0, 0]]),
        np.array([[1, 0, 0, 0, 0], [0, 1, 0, 0, 0], [0, 0, 1, 0, 0],
                  [0, 0, 0, 1, 0], [0, 0, 0, 0, 1]]),
    ]

    print(f"  {'Queries':>8}  {'Rank':>5}  {'|ker|':>10}  {'Leaked (bits)':>14}  {'Remaining':>10}")
    print(f"  {'─'*8}  {'─'*5}  {'─'*10}  {'─'*14}  {'─'*10}")

    for M in queries:
        _, r, _ = gaussian_elimination(M, q)
        ker_size = q ** (p - r)
        leaked = r * np.log2(q)
        remaining = (p - r) * np.log2(q)
        print(f"  {M.shape[0]:>8}  {r:>5}  {ker_size:>10}  {leaked:>14.2f}  {remaining:>10.2f}")

    print()
    print("  Key insight: Each independent linear query leaks exactly log₂(q) bits.")
    print("  Redundant queries (rank-deficient) leak nothing additional.")
    print()


# ─── Application 4: Randomized Matrix Verification ───────────────────────

def verification_confidence():
    """Show how rank-awareness improves verification confidence bounds.

    Standard Freivalds: after k trials, Pr[false accept] ≤ (1/q)^k.
    Rank-aware: Pr[false accept] = (1/q)^{k·rank(E)}.

    For high-rank errors, far fewer trials are needed.
    """
    print("=" * 70)
    print("APPLICATION 4: Verification Confidence — Rank-Aware Bounds")
    print("=" * 70)
    print()

    q = 2
    import math

    print(f"  Field: GF({q})")
    print(f"  Target: Pr[false accept] < 2^(-128) (cryptographic security)")
    print()

    target_bits = 128

    print(f"  {'rank(E)':>8}  {'Trials (standard)':>18}  {'Trials (rank-aware)':>20}  {'Speedup':>8}")
    print(f"  {'─'*8}  {'─'*18}  {'─'*20}  {'─'*8}")

    for rank_E in [1, 2, 4, 8, 16, 32, 64]:
        standard_trials = target_bits  # Each trial gives 1 bit
        rank_aware_trials = math.ceil(target_bits / rank_E)
        speedup = standard_trials / rank_aware_trials
        print(f"  {rank_E:>8}  {standard_trials:>18}  {rank_aware_trials:>20}  {speedup:>8.1f}×")

    print()
    print("  Conclusion: A rank-64 error matrix needs only 2 trials for 128-bit security!")
    print("  Standard analysis would require 128 trials regardless of rank.")
    print()


if __name__ == "__main__":
    linear_code_analysis()
    syndrome_decoding_demo()
    privacy_analysis()
    verification_confidence()


#!/usr/bin/env python3
"""
Demonstration of the Rank-Sensitive Exact Kernel Cardinality Theorem.

For a matrix M over GF(q) (the finite field with q elements, q prime),
the number of vectors r satisfying M·r = 0 is exactly q^(p - rank(M)),
where p is the number of columns.

This script verifies the theorem computationally with concrete examples.
"""

import numpy as np
from itertools import product


def gf_add(a, b, q):
    """Addition in GF(q)."""
    return (a + b) % q


def gf_mul(a, b, q):
    """Multiplication in GF(q)."""
    return (a * b) % q


def matrix_mul_vec(M, v, q):
    """Compute M·v over GF(q)."""
    m, p = M.shape
    result = np.zeros(m, dtype=int)
    for i in range(m):
        s = 0
        for j in range(p):
            s = gf_add(s, gf_mul(M[i, j], v[j], q), q)
        result[i] = s
    return result


def gf_rank(M, q):
    """Compute the rank of M over GF(q) via Gaussian elimination."""
    M = M.copy() % q
    m, n = M.shape
    rank = 0
    for col in range(n):
        # Find pivot
        pivot = None
        for row in range(rank, m):
            if M[row, col] % q != 0:
                pivot = row
                break
        if pivot is None:
            continue
        # Swap rows
        M[[rank, pivot]] = M[[pivot, rank]]
        # Find inverse of pivot element
        pivot_val = M[rank, col] % q
        pivot_inv = pow(int(pivot_val), q - 2, q)  # Fermat's little theorem
        # Scale pivot row
        M[rank] = (M[rank] * pivot_inv) % q
        # Eliminate column
        for row in range(m):
            if row != rank and M[row, col] % q != 0:
                factor = M[row, col] % q
                M[row] = (M[row] - factor * M[rank]) % q
        rank += 1
    return rank


def count_kernel(M, q):
    """Count vectors in ker(M) by brute force enumeration."""
    m, p = M.shape
    count = 0
    for v in product(range(q), repeat=p):
        v_arr = np.array(v, dtype=int)
        if np.all(matrix_mul_vec(M, v_arr, q) == 0):
            count += 1
    return count


def count_affine_solutions(M, b, q):
    """Count vectors r with M·r = b by brute force."""
    m, p = M.shape
    count = 0
    for v in product(range(q), repeat=p):
        v_arr = np.array(v, dtype=int)
        if np.all(matrix_mul_vec(M, v_arr, q) == b):
            count += 1
    return count


def demo_basic():
    """Demonstrate the basic kernel cardinality theorem."""
    print("=" * 70)
    print("DEMO 1: Basic Kernel Cardinality Theorem")
    print("=" * 70)
    print()
    print("Theorem: |ker(M)| = q^(p - rank(M))  for M over GF(q)")
    print()

    examples = [
        # (q, M description, M matrix)
        (2, "Zero 2×3 matrix", np.array([[0, 0, 0], [0, 0, 0]])),
        (2, "Identity 2×2 matrix", np.array([[1, 0], [0, 1]])),
        (2, "Rank-1 matrix [[1,1],[1,1]]", np.array([[1, 1], [1, 1]])),
        (3, "Rank-2 matrix over GF(3)", np.array([[1, 0, 1], [0, 1, 2]])),
        (5, "Rank-1 matrix over GF(5)", np.array([[1, 2], [2, 4]])),
        (2, "3×4 rank-2 matrix over GF(2)",
         np.array([[1, 0, 1, 0], [0, 1, 0, 1], [1, 1, 1, 1]])),
    ]

    all_pass = True
    for q, desc, M in examples:
        m, p = M.shape
        r = gf_rank(M, q)
        predicted = q ** (p - r)
        actual = count_kernel(M, q)

        status = "✓" if predicted == actual else "✗"
        if predicted != actual:
            all_pass = False

        print(f"  {status} {desc}")
        print(f"    q={q}, size={m}×{p}, rank={r}")
        print(f"    Predicted |ker| = {q}^({p}-{r}) = {predicted}")
        print(f"    Actual |ker|    = {actual}")
        print()

    print(f"All tests passed: {all_pass}")
    print()


def demo_affine():
    """Demonstrate the affine solution counting theorem."""
    print("=" * 70)
    print("DEMO 2: Affine Solution Counting  |{r : M·r = b}|")
    print("=" * 70)
    print()
    print("Theorem: |{r : M·r = b}| = q^(p-rank(M)) if b ∈ Im(M), else 0")
    print()

    q = 3
    M = np.array([[1, 0, 1], [0, 1, 2]])
    m, p = M.shape
    r = gf_rank(M, q)
    print(f"  M = {M.tolist()} over GF({q})")
    print(f"  rank(M) = {r}, p = {p}")
    print(f"  Expected solutions when b ∈ Im(M): {q}^({p}-{r}) = {q**(p-r)}")
    print()

    for b in product(range(q), repeat=m):
        b_arr = np.array(b, dtype=int)
        actual = count_affine_solutions(M, b_arr, q)
        in_range = actual > 0
        expected = q ** (p - r) if in_range else 0
        status = "✓" if expected == actual else "✗"
        label = "in Im(M)" if in_range else "NOT in Im(M)"
        print(f"    {status} b={list(b)}: |solutions| = {actual}  ({label})")

    print()


def demo_freivalds():
    """Demonstrate rank-sensitive Freivalds verification."""
    print("=" * 70)
    print("DEMO 3: Rank-Sensitive Freivalds Verification")
    print("=" * 70)
    print()
    print("For AB ≠ C, Pr[ABr = Cr] = q^(-rank(AB-C))")
    print()

    q = 5
    # Create A, B, C where AB ≠ C
    A = np.array([[1, 2], [3, 4]])
    B = np.array([[1, 0, 1], [0, 1, 1]])
    # AB over GF(5)
    AB = np.zeros((2, 3), dtype=int)
    for i in range(2):
        for j in range(3):
            s = 0
            for k in range(2):
                s = gf_add(s, gf_mul(A[i, k], B[k, j], q), q)
            AB[i, j] = s

    print(f"  A = {A.tolist()}")
    print(f"  B = {B.tolist()}")
    print(f"  AB = {AB.tolist()} (over GF({q}))")
    print()

    # Test with different error matrices of varying rank
    errors = [
        ("Rank-1 error", np.array([[1, 0, 0], [0, 0, 0]])),
        ("Rank-2 error", np.array([[1, 0, 0], [0, 1, 0]])),
        ("Zero error (AB=C)", np.array([[0, 0, 0], [0, 0, 0]])),
    ]

    p = 3
    total_vectors = q ** p

    for desc, E in errors:
        C = (AB - E) % q
        r_E = gf_rank(E, q)
        kernel_size = count_kernel(E, q)
        prob = kernel_size / total_vectors

        print(f"  {desc}:")
        print(f"    E = {E.tolist()}, rank(E) = {r_E}")
        print(f"    |ker(E)| = {kernel_size}")
        print(f"    Pr[Er=0] = {kernel_size}/{total_vectors} = {prob:.6f}")
        print(f"    q^(-rank(E)) = {q}^(-{r_E}) = {q**(-r_E):.6f}")
        print(f"    Match: {abs(prob - q**(-r_E)) < 1e-10}")
        print()


def demo_rank_spectrum():
    """Show how kernel size varies with rank."""
    print("=" * 70)
    print("DEMO 4: Rank Spectrum — Kernel Size vs Matrix Rank")
    print("=" * 70)
    print()

    q = 3
    p = 4
    print(f"  Field: GF({q}), Columns: p = {p}")
    print(f"  Ambient space size: {q}^{p} = {q**p}")
    print()
    print(f"  {'Rank':>6}  {'|ker|':>8}  {'q^(p-rank)':>10}  {'Pr[Mr=0]':>12}")
    print(f"  {'─'*6}  {'─'*8}  {'─'*10}  {'─'*12}")

    for rank in range(p + 1):
        ker_size = q ** (p - rank)
        prob = ker_size / q**p
        print(f"  {rank:>6}  {ker_size:>8}  {q}^{p-rank} = {ker_size:>4}  {prob:>12.6f}")

    print()
    print("  Key insight: each unit increase in rank divides the kernel by q.")
    print(f"  Full rank ({p}): unique solution (|ker| = 1)")
    print(f"  Rank 0: all {q**p} vectors are solutions")
    print()


if __name__ == "__main__":
    demo_basic()
    demo_affine()
    demo_freivalds()
    demo_rank_spectrum()


#!/usr/bin/env python3
"""
Generate visualizations for the Rank-Sensitive Kernel Cardinality Theorem.
Saves figures as PNG files and prints base64 data URIs for embedding.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
import io
import json


def fig_to_base64(fig) -> str:
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def viz_kernel_size_vs_rank():
    """Kernel size as a function of rank for different field sizes."""
    fig, ax = plt.subplots(figsize=(8, 5))

    p = 8  # number of columns
    for q in [2, 3, 5, 7]:
        ranks = list(range(p + 1))
        ker_sizes = [q ** (p - r) for r in ranks]
        ax.semilogy(ranks, ker_sizes, 'o-', label=f'q = {q}', markersize=6)

    ax.set_xlabel('Rank of M', fontsize=13)
    ax.set_ylabel('|ker(M)|  (log scale)', fontsize=13)
    ax.set_title(f'Kernel Size vs. Rank  (p = {p} columns)', fontsize=14)
    ax.legend(title='Field size', fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_xticks(range(p + 1))
    fig.tight_layout()
    fig.savefig('/workspace/request-project/viz_kernel_vs_rank.png', dpi=150)
    return fig_to_base64(fig)


def viz_acceptance_probability():
    """False acceptance probability for Freivalds verification."""
    fig, ax = plt.subplots(figsize=(8, 5))

    ranks = np.arange(1, 17)
    for q in [2, 3, 5, 7]:
        probs = [float(q) ** (-r) for r in ranks]
        ax.semilogy(ranks, probs, 's-', label=f'q = {q}', markersize=5)

    ax.set_xlabel('Rank of error matrix E = AB − C', fontsize=13)
    ax.set_ylabel('Pr[false accept]  (log scale)', fontsize=13)
    ax.set_title('Rank-Sensitive Freivalds: False Acceptance Probability', fontsize=14)
    ax.legend(title='Field size', fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.axhline(y=2**-40, color='red', linestyle='--', alpha=0.5, label='2⁻⁴⁰ security')
    ax.text(14, 2**-38, '2⁻⁴⁰ security threshold', fontsize=9, color='red', alpha=0.7)
    fig.tight_layout()
    fig.savefig('/workspace/request-project/viz_acceptance_prob.png', dpi=150)
    return fig_to_base64(fig)


def viz_information_leakage():
    """Information leakage through linear queries."""
    fig, ax = plt.subplots(figsize=(8, 5))

    p = 10
    for q in [2, 3, 5]:
        num_queries = list(range(p + 1))
        # Assume independent queries, so rank = min(queries, p)
        leaked = [min(k, p) * np.log2(q) for k in num_queries]
        remaining = [p * np.log2(q) - l for l in leaked]
        ax.plot(num_queries, leaked, 'o-', label=f'Leaked (q={q})', markersize=5)
        ax.plot(num_queries, remaining, 's--', label=f'Remaining (q={q})',
                markersize=4, alpha=0.6)

    ax.set_xlabel('Number of independent linear queries', fontsize=13)
    ax.set_ylabel('Information (bits)', fontsize=13)
    ax.set_title(f'Privacy: Information Leakage vs. Queries  (p = {p})', fontsize=14)
    ax.legend(fontsize=9, ncol=2)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('/workspace/request-project/viz_info_leakage.png', dpi=150)
    return fig_to_base64(fig)


def viz_coset_structure():
    """Visualize the coset structure of GF(2)^4 under a rank-2 map."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    q = 2
    p = 4
    # A rank-2 matrix over GF(2)
    M = np.array([[1, 0, 1, 0], [0, 1, 0, 1]])

    from itertools import product as iproduct

    # Partition all vectors by their image
    cosets = {}
    for v in iproduct(range(q), repeat=p):
        v_arr = np.array(v, dtype=int)
        img = tuple((M @ v_arr) % q)
        cosets.setdefault(img, []).append(v)

    # Left panel: coset sizes
    ax = axes[0]
    labels = [str(list(k)) for k in sorted(cosets.keys())]
    sizes = [len(cosets[k]) for k in sorted(cosets.keys())]
    colors = plt.cm.Set2(np.linspace(0, 1, len(labels)))
    ax.bar(labels, sizes, color=colors, edgecolor='black', linewidth=0.5)
    ax.set_xlabel('Image M·r', fontsize=12)
    ax.set_ylabel('Coset size', fontsize=12)
    ax.set_title('Coset Sizes (all equal by theorem)', fontsize=13)
    for i, s in enumerate(sizes):
        ax.text(i, s + 0.1, str(s), ha='center', fontsize=11, fontweight='bold')
    ax.set_ylim(0, max(sizes) + 1)

    # Right panel: partition diagram
    ax = axes[1]
    ax.set_xlim(-0.5, 3.5)
    ax.set_ylim(-0.5, 4.5)
    ax.set_aspect('equal')
    ax.set_title(f'GF(2)⁴ partitioned into cosets', fontsize=13)
    ax.axis('off')

    y_offset = 0
    for idx, (img, vecs) in enumerate(sorted(cosets.items())):
        color = colors[idx]
        for j, v in enumerate(vecs):
            x = j
            y = idx
            ax.add_patch(plt.Rectangle((x - 0.4, y - 0.3), 0.8, 0.6,
                                       facecolor=color, edgecolor='black', linewidth=0.5))
            ax.text(x, y, str(list(v)), ha='center', va='center', fontsize=6)
        ax.text(-0.5, idx, f'M·r={list(img)}', ha='right', va='center', fontsize=8)

    fig.tight_layout()
    fig.savefig('/workspace/request-project/viz_coset_structure.png', dpi=150)
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    data = {}
    data['kernel_vs_rank'] = viz_kernel_size_vs_rank()
    data['acceptance_prob'] = viz_acceptance_probability()
    data['info_leakage'] = viz_information_leakage()
    data['coset_structure'] = viz_coset_structure()

    # Save base64 data for JSON package
    with open('/workspace/request-project/viz_data.json', 'w') as f:
        json.dump(data, f)

    print("Saved PNG files and base64 data.")
    print("Files: viz_kernel_vs_rank.png, viz_acceptance_prob.png,")
    print("       viz_info_leakage.png, viz_coset_structure.png")
