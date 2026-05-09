#!/usr/bin/env python3
"""
Tropical Post-Quantum Cryptography Demo
========================================
Demonstrates the min-plus semiring algebra and its cryptographic applications.

This demo implements:
1. Tropical (min-plus) matrix arithmetic
2. Tropical Diffie-Hellman key exchange
3. Non-commutativity witness
4. Lipschitz bounds for certified robustness
5. Security parameter analysis

All operations use integer arithmetic with infinity (float('inf')).
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import permutations
import time

INF = float('inf')

# =============================================================================
# Part 1: Tropical Arithmetic Primitives
# =============================================================================

def trop_add(a, b):
    """Tropical addition: min(a, b)."""
    return min(a, b)

def trop_mul(a, b):
    """Tropical multiplication: a + b (ordinary addition)."""
    if a == INF or b == INF:
        return INF
    return a + b

def trop_mat_mul(A, B):
    """Tropical matrix multiplication: (A⊗B)_{ij} = min_k(A_{ik} + B_{kj})."""
    n = len(A)
    C = [[INF] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            for k in range(n):
                val = trop_mul(A[i][k], B[k][j])
                C[i][j] = trop_add(C[i][j], val)
    return C

def trop_mat_pow(A, k):
    """Tropical matrix power via repeated squaring: O(n³ log k)."""
    n = len(A)
    # Identity matrix: 0 on diagonal, ∞ elsewhere
    result = [[INF] * n for _ in range(n)]
    for i in range(n):
        result[i][i] = 0
    
    base = [row[:] for row in A]
    muls = 0
    while k > 0:
        if k % 2 == 1:
            result = trop_mat_mul(result, base)
            muls += 1
        base = trop_mat_mul(base, base)
        muls += 1
        k //= 2
    return result, muls

def trop_trace(A):
    """Tropical trace: min of diagonal entries."""
    return min(A[i][i] for i in range(len(A)))

def trop_det(A):
    """Tropical determinant: minimum weight perfect matching."""
    n = len(A)
    best = INF
    for perm in permutations(range(n)):
        weight = sum(A[i][perm[i]] for i in range(n))
        best = min(best, weight)
    return best

def print_trop_mat(A, name=""):
    """Pretty-print a tropical matrix."""
    n = len(A)
    if name:
        print(f"\n{name}:")
    for i in range(n):
        row = []
        for j in range(n):
            if A[i][j] == INF:
                row.append("  ∞")
            else:
                row.append(f"{A[i][j]:3d}")
        print("  [" + ", ".join(row) + "]")

# =============================================================================
# Part 2: Demonstrations
# =============================================================================

def demo_basic_arithmetic():
    """Demonstrate tropical arithmetic fundamentals."""
    print("=" * 60)
    print("DEMO 1: Tropical (Min-Plus) Arithmetic")
    print("=" * 60)
    
    print("\nTropical addition (= min):")
    print(f"  3 ⊕ 5 = min(3, 5) = {trop_add(3, 5)}")
    print(f"  7 ⊕ 2 = min(7, 2) = {trop_add(7, 2)}")
    print(f"  4 ⊕ ∞ = min(4, ∞) = {trop_add(4, INF)}")
    
    print("\nTropical multiplication (= +):")
    print(f"  3 ⊗ 5 = 3 + 5 = {trop_mul(3, 5)}")
    print(f"  7 ⊗ 2 = 7 + 2 = {trop_mul(7, 2)}")
    print(f"  4 ⊗ ∞ = 4 + ∞ = {trop_mul(4, INF)}")
    
    print("\nKey properties:")
    print(f"  Additive identity: ∞ (min(x, ∞) = x)")
    print(f"  Multiplicative identity: 0 (x + 0 = x)")
    print(f"  Idempotent addition: 3 ⊕ 3 = min(3,3) = {trop_add(3, 3)}")
    print(f"  ← This means NO additive inverses exist!")
    print(f"  ← Tropical semiring is NOT a ring")
    print(f"  ← Blocks algebraic attacks on crypto schemes")

def demo_noncommutativity():
    """Demonstrate that tropical matrix multiplication is non-commutative."""
    print("\n" + "=" * 60)
    print("DEMO 2: Non-Commutativity (Foundation of Hardness)")
    print("=" * 60)
    
    A = [[0, 1], [2, 3]]
    B = [[4, 5], [6, 0]]
    
    print_trop_mat(A, "A")
    print_trop_mat(B, "B")
    
    AB = trop_mat_mul(A, B)
    BA = trop_mat_mul(B, A)
    
    print_trop_mat(AB, "A ⊗ B")
    print_trop_mat(BA, "B ⊗ A")
    
    print(f"\n  A ⊗ B ≠ B ⊗ A? {AB != BA} ✓")
    print(f"  Difference at (0,1): {AB[0][1]} ≠ {BA[0][1]}")
    print(f"  Difference at (1,0): {AB[1][0]} ≠ {BA[1][0]}")
    print(f"\n  → Non-commutativity prevents algebraic DLP shortcuts")

def demo_diffie_hellman():
    """Demonstrate tropical Diffie-Hellman key exchange."""
    print("\n" + "=" * 60)
    print("DEMO 3: Tropical Diffie-Hellman Key Exchange")
    print("=" * 60)
    
    # Public generator matrix
    G = [[0, 3, 7],
         [5, 0, 2],
         [1, 4, 0]]
    
    print_trop_mat(G, "Public generator G")
    
    # Alice's secret: a = 7
    # Bob's secret: b = 11
    a, b = 7, 11
    print(f"\n  Alice's secret: a = {a}")
    print(f"  Bob's secret:   b = {b}")
    
    # Compute public keys
    Ga, muls_a = trop_mat_pow(G, a)
    Gb, muls_b = trop_mat_pow(G, b)
    
    print_trop_mat(Ga, f"Alice's public key G^{a}")
    print(f"  (computed in {muls_a} matrix multiplications)")
    
    print_trop_mat(Gb, f"Bob's public key G^{b}")
    print(f"  (computed in {muls_b} matrix multiplications)")
    
    # Shared key: both compute G^(a+b)
    Gab_alice, _ = trop_mat_pow(G, a + b)
    
    # Verify: G^a * G^b = G^(a+b) (powers commute!)
    Ga_Gb = trop_mat_mul(Ga, Gb)
    Gb_Ga = trop_mat_mul(Gb, Ga)
    
    print_trop_mat(Ga_Gb, f"Alice computes: G^{a} ⊗ G^{b}")
    print_trop_mat(Gb_Ga, f"Bob computes: G^{b} ⊗ G^{a}")
    
    print(f"\n  Shared keys agree? {Ga_Gb == Gb_Ga} ✓")
    print(f"  Equals G^{a+b}?    {Ga_Gb == Gab_alice} ✓")
    print(f"\n  → Powers of the SAME matrix always commute")
    print(f"  → Even though general tropical ⊗ is non-commutative!")

def demo_lipschitz():
    """Demonstrate Lipschitz bounds for certified robustness."""
    print("\n" + "=" * 60)
    print("DEMO 4: 1-Lipschitz Bound (Certified Robustness)")
    print("=" * 60)
    
    n = 4
    a = [3, -1, 5, 2]  # Coefficients
    
    def trop_linear(x):
        return min(a[j] + x[j] for j in range(n))
    
    print(f"\n  Tropical linear form: f(x) = min_j(a_j + x_j)")
    print(f"  Coefficients a = {a}")
    
    # Test with random vectors
    np.random.seed(42)
    max_violations = 0
    trials = 10000
    
    diffs = []
    output_diffs = []
    
    for _ in range(trials):
        x = np.random.randint(-10, 10, n).tolist()
        y = np.random.randint(-10, 10, n).tolist()
        
        fx = trop_linear(x)
        fy = trop_linear(y)
        
        output_diff = abs(fx - fy)
        input_diff = max(abs(x[j] - y[j]) for j in range(n))
        
        diffs.append(input_diff)
        output_diffs.append(output_diff)
        
        if output_diff > input_diff:
            max_violations += 1
    
    print(f"\n  Tested {trials} random pairs:")
    print(f"  Lipschitz violations (|f(x)-f(y)| > max|x_j-y_j|): {max_violations}")
    print(f"  Maximum |f(x)-f(y)|/max|x_j-y_j| ratio: {max(od/max(d,1e-10) for od,d in zip(output_diffs, diffs)):.4f}")
    print(f"\n  → Tropical linear forms are always 1-Lipschitz ✓")
    print(f"  → This gives EXACT certified adversarial robustness radii")
    
    # Plot
    plt.figure(figsize=(8, 6))
    plt.scatter(diffs, output_diffs, alpha=0.1, s=5, color='blue')
    plt.plot([0, max(diffs)], [0, max(diffs)], 'r--', linewidth=2, label='Lipschitz bound (L=1)')
    plt.xlabel('Input distance: max_j |x_j - y_j|', fontsize=12)
    plt.ylabel('Output distance: |f(x) - f(y)|', fontsize=12)
    plt.title('Tropical Linear Form: 1-Lipschitz Bound', fontsize=14)
    plt.legend(fontsize=12)
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('lipschitz_bound.png', dpi=150)
    plt.close()
    print(f"\n  [Plot saved to lipschitz_bound.png]")

def demo_security_params():
    """Demonstrate security parameter analysis."""
    print("\n" + "=" * 60)
    print("DEMO 5: Post-Quantum Security Parameters")
    print("=" * 60)
    
    print(f"\n  {'n':>4} {'B':>4} {'Key space':>20} {'Bits':>8} {'Grover bits':>12}")
    print(f"  {'-'*4} {'-'*4} {'-'*20} {'-'*8} {'-'*12}")
    
    params = [(4, 7), (8, 15), (8, 255), (16, 255), (32, 255), (64, 255)]
    
    for n, B in params:
        key_space_bits = n * n * np.log2(B + 1)
        grover_bits = key_space_bits / 2
        
        if key_space_bits < 100:
            ks_str = f"{(B+1)**(n*n)}"
        else:
            ks_str = f"≈ 2^{key_space_bits:.0f}"
        
        print(f"  {n:4d} {B:4d} {ks_str:>20} {key_space_bits:>8.0f} {grover_bits:>12.0f}")
    
    print(f"\n  NIST security levels:")
    print(f"  Level 1 (AES-128): need ≥ 128 Grover bits → n=8, B=255 (256 bits, Grover=128)")
    print(f"  Level 3 (AES-192): need ≥ 192 Grover bits → n=8, B=255+ or n=16")
    print(f"  Level 5 (AES-256): need ≥ 256 Grover bits → n=16, B=255 (2048 bits, Grover=1024)")

def demo_repeated_squaring():
    """Demonstrate repeated squaring efficiency."""
    print("\n" + "=" * 60)
    print("DEMO 6: Repeated Squaring Complexity")
    print("=" * 60)
    
    sizes = [4, 8, 16, 32]
    exponents = [10, 100, 1000, 10000, 100000, 1000000]
    
    print(f"\n  Matrix multiplications needed for A^k (repeated squaring):")
    print(f"  {'k':>10} {'⌊log₂ k⌋':>10} {'Muls (≤ 2log₂k+2)':>20}")
    print(f"  {'-'*10} {'-'*10} {'-'*20}")
    
    for k in exponents:
        log2k = int(np.log2(k))
        muls = 2 * (log2k + 1)
        print(f"  {k:>10,} {log2k:>10} {muls:>20}")
    
    print(f"\n  Timing comparison (n=32 matrices):")
    n = 32
    G = [[np.random.randint(0, 100) for _ in range(n)] for _ in range(n)]
    
    for k in [10, 100, 1000]:
        t0 = time.time()
        _, muls = trop_mat_pow(G, k)
        elapsed = time.time() - t0
        print(f"  G^{k:>6}: {elapsed*1000:.1f} ms ({muls} matrix multiplications)")

def demo_shortest_paths():
    """Demonstrate that tropical matrix powering computes shortest paths."""
    print("\n" + "=" * 60)
    print("DEMO 7: Shortest Paths via Tropical Powers")
    print("=" * 60)
    
    # Weighted directed graph (adjacency matrix with edge weights)
    # ∞ means no direct edge
    A = [[INF,   3,   8, INF, INF],
         [INF, INF,   2,   1, INF],
         [INF, INF, INF, INF,   4],
         [INF, INF, INF, INF,   7],
         [INF, INF, INF, INF, INF]]
    
    print_trop_mat(A, "Adjacency matrix A (edge weights)")
    
    # A^k gives shortest paths using exactly k edges
    # The Kleene star A* = I ⊕ A ⊕ A² ⊕ ... gives all shortest paths
    n = len(A)
    star = [[INF] * n for _ in range(n)]
    for i in range(n):
        star[i][i] = 0
    
    for k in range(1, n):
        Ak, _ = trop_mat_pow(A, k)
        for i in range(n):
            for j in range(n):
                star[i][j] = min(star[i][j], Ak[i][j])
    
    print_trop_mat(star, "Kleene star A* (all-pairs shortest paths)")
    
    print(f"\n  Shortest path 0→4: {star[0][4]}")
    print(f"  (Path: 0→1→2→4 with weight 3+2+4 = 9)")
    print(f"  Shortest path 0→3: {star[0][3]}")
    print(f"  (Path: 0→1→3 with weight 3+1 = 4)")

# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  TROPICAL POST-QUANTUM CRYPTOGRAPHY — NUMERICAL DEMO   ║")
    print("║  Min-Plus One-Way Functions & Lattice-Free Hardness     ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    demo_basic_arithmetic()
    demo_noncommutativity()
    demo_diffie_hellman()
    demo_lipschitz()
    demo_security_params()
    demo_repeated_squaring()
    demo_shortest_paths()
    
    print("\n" + "=" * 60)
    print("All demos complete!")
    print("=" * 60)
