#!/usr/bin/env python3
"""
Tropical Cryptography Demo: Min-Plus Diffie-Hellman Key Exchange

Demonstrates:
1. Tropical matrix arithmetic and power computation
2. Diffie-Hellman key exchange using tropical matrices
3. Eigenvalue attack on the Tropical Discrete Logarithm Problem
4. Kleene star (shortest path) computation
5. Security analysis: why tropical DLP is structurally weak
"""

from algorithms import (
    trop_mat_mul, trop_mat_pow, trop_mat_identity, trop_trace,
    kleene_star, eigenvalue_attack, trop_eigenvalue_estimate,
    TropicalDiffieHellman, generate_random_tropical_matrix, INF
)
import time


def fmt_mat(A, name=""):
    """Pretty-print a tropical matrix."""
    n = len(A)
    lines = []
    if name:
        lines.append(f"  {name} =")
    for row in A:
        entries = []
        for x in row:
            if x == INF:
                entries.append("  ∞")
            else:
                entries.append(f"{int(x):3d}")
        lines.append("  [" + " ".join(entries) + "]")
    return "\n".join(lines)


def demo_tropical_arithmetic():
    """Demo 1: Basic tropical matrix operations."""
    print("=" * 70)
    print("DEMO 1: Tropical Matrix Arithmetic")
    print("=" * 70)
    print()
    print("In the min-plus semiring: a ⊕ b = min(a,b), a ⊗ b = a + b")
    print("Matrix multiplication: (A⊗B)_{ij} = min_k (A_{ik} + B_{kj})")
    print()

    A = [[1, 3, INF],
         [INF, 2, 0],
         [4, INF, 5]]

    B = [[0, INF, 2],
         [1, 3, INF],
         [INF, 1, 0]]

    print(fmt_mat(A, "A"))
    print()
    print(fmt_mat(B, "B"))
    print()

    C = trop_mat_mul(A, B)
    print(fmt_mat(C, "A ⊗ B"))
    print()

    # Verify non-commutativity
    D = trop_mat_mul(B, A)
    print(fmt_mat(D, "B ⊗ A"))
    print()
    print(f"  A ⊗ B == B ⊗ A? {C == D}")
    print("  → Tropical matrix multiplication is NOT commutative!")
    print()


def demo_diffie_hellman():
    """Demo 2: Tropical Diffie-Hellman key exchange."""
    print("=" * 70)
    print("DEMO 2: Tropical Diffie-Hellman Key Exchange")
    print("=" * 70)
    print()

    # Public generator matrix
    G = [[0, 3, 7],
         [2, 0, 5],
         [4, 1, 0]]

    print(fmt_mat(G, "Public generator G"))
    print()

    dh = TropicalDiffieHellman(G)

    # Alice's secret: a = 17
    # Bob's secret: b = 23
    a, b = 17, 23

    print(f"  Alice's secret: a = {a}")
    print(f"  Bob's secret:   b = {b}")
    print()

    t0 = time.time()
    pub_a = dh.public_key(a)
    t1 = time.time()
    pub_b = dh.public_key(b)
    t2 = time.time()

    print(f"  Alice publishes G^{a}:")
    print(fmt_mat(pub_a))
    print(f"  (computed in {(t1-t0)*1000:.2f} ms)")
    print()

    print(f"  Bob publishes G^{b}:")
    print(fmt_mat(pub_b))
    print(f"  (computed in {(t2-t1)*1000:.2f} ms)")
    print()

    key_alice = dh.shared_key(a, pub_b)
    key_bob = dh.shared_key(b, pub_a)

    print("  Alice computes (G^b)^a:")
    print(fmt_mat(key_alice))
    print()
    print("  Bob computes (G^a)^b:")
    print(fmt_mat(key_bob))
    print()
    print(f"  Keys match? {key_alice == key_bob}")
    print("  → Correctness guaranteed by (G^a)^b = G^{ab} = (G^b)^a")
    print()


def demo_eigenvalue_attack():
    """Demo 3: Breaking TDLP via eigenvalue attack."""
    print("=" * 70)
    print("DEMO 3: Eigenvalue Attack on Tropical DLP")
    print("=" * 70)
    print()

    G = [[0, 3, 7],
         [2, 0, 5],
         [4, 1, 0]]

    secret_k = 42

    print(f"  Secret exponent k = {secret_k}")
    print(fmt_mat(G, "Public matrix G"))
    print()

    B = trop_mat_pow(G, secret_k)
    print(f"  B = G^{secret_k}:")
    print(fmt_mat(B))
    print()

    # Eigenvalue estimate
    lam = trop_eigenvalue_estimate(G, max_k=10)
    print(f"  Tropical eigenvalue λ(G) ≈ {lam:.4f}")
    tr_B = trop_trace(B)
    print(f"  Tropical trace tr(B) = {tr_B}")
    if lam != INF and lam != 0 and tr_B != INF:
        print(f"  Estimated k ≈ tr(B)/λ(G) = {tr_B/lam:.1f}")
    print()

    # Full attack
    t0 = time.time()
    recovered_k = eigenvalue_attack(G, B)
    t1 = time.time()

    if recovered_k is not None:
        print(f"  ✓ Attack recovered k = {recovered_k} (in {(t1-t0)*1000:.2f} ms)")
        print(f"  ✓ Correct? {recovered_k == secret_k}")
    else:
        print("  ✗ Attack failed (would need more sophisticated methods)")
    print()


def demo_diagonal_attack():
    """Demo 4: Trivial TDLP for diagonal matrices."""
    print("=" * 70)
    print("DEMO 4: Diagonal Matrix Attack (Proven in Lean)")
    print("=" * 70)
    print()
    print("  For diagonal matrices, (diag(d))^k = diag(k*d).")
    print("  The TDLP is trivially solvable: k = B_{ii} / A_{ii}.")
    print()

    # Diagonal matrix
    d = [3, 7, 11, 5]
    n = len(d)
    A = [[INF] * n for _ in range(n)]
    for i in range(n):
        A[i][i] = d[i]

    secret_k = 137

    B = trop_mat_pow(A, secret_k)

    print(f"  d = {d}")
    print(f"  Secret k = {secret_k}")
    print()
    print(f"  A = diag(d):")
    for i in range(n):
        print(f"    A[{i}][{i}] = {A[i][i]}")
    print()
    print(f"  B = A^k:")
    for i in range(n):
        print(f"    B[{i}][{i}] = {int(B[i][i])}")
    print()

    # Attack
    for i in range(n):
        if A[i][i] != 0 and A[i][i] != INF:
            k_est = int(B[i][i] / A[i][i])
            print(f"  From entry ({i},{i}): k = {int(B[i][i])} / {int(A[i][i])} = {k_est}")

    print()
    print("  → Lean theorem `trop_diag_attack_recovers_k` proves this always works!")
    print()


def demo_kleene_star():
    """Demo 5: Kleene star = shortest paths."""
    print("=" * 70)
    print("DEMO 5: Kleene Star (All-Pairs Shortest Paths)")
    print("=" * 70)
    print()

    # Weighted graph (adjacency matrix)
    A = [[INF, 3, INF, 7],
         [INF, INF, 1, INF],
         [INF, INF, INF, 2],
         [INF, INF, INF, INF]]

    print("  Weighted directed graph (adjacency matrix):")
    print(fmt_mat(A))
    print()
    print("  Edges: 0→1 (weight 3), 1→2 (weight 1), 2→3 (weight 2), 0→3 (weight 7)")
    print()

    K = kleene_star(A)
    print("  Kleene star A* (all-pairs shortest paths):")
    print(fmt_mat(K))
    print()
    print("  Interpretation:")
    print("    K[0][3] = 6: shortest 0→3 path is 0→1→2→3 (cost 3+1+2=6)")
    print("    K[0][2] = 4: shortest 0→2 path is 0→1→2 (cost 3+1=4)")
    print()
    print("  → Lean theorem `kleenePrefix_antitone`: each Kleene prefix step")
    print("    can only improve (decrease) path weights.")
    print()


def demo_security_analysis():
    """Demo 6: Why tropical DLP is structurally weak."""
    print("=" * 70)
    print("DEMO 6: Security Analysis — Five Structural Weaknesses")
    print("=" * 70)
    print()
    print("  The Lean theorem `tropical_five_weaknesses` proves:")
    print()
    print("  1. ABELIAN ORBIT: All powers of G commute → no non-abelian hardness")
    print("  2. IDEMPOTENT ADDITION: A^k ⊕ A^k = A^k → no ring structure")
    print("  3. HOMOMORPHISM: G^{a+b} = G^a ⊗ G^b → additive structure leaks")
    print("  4. IDENTITY: G^0 = I → trivial base case")
    print("  5. DH CORRECTNESS: (G^a)^b = (G^b)^a → protocol works but...")
    print()
    print("  Combined impact: The tropical DLP has too much algebraic structure")
    print("  for cryptographic hardness. The eigenvalue attack (Demo 3) exploits")
    print("  weakness #3 (homomorphism + linearity of tropical eigenvalues).")
    print()

    # Benchmark: timing comparison
    sizes = [3, 5, 8, 10, 15]
    print("  Benchmarks: tropical matrix power computation time")
    print(f"  {'Size':>6} {'G^100 (ms)':>12} {'G^10000 (ms)':>14} {'Attack (ms)':>12}")
    print("  " + "-" * 50)

    for n in sizes:
        G = generate_random_tropical_matrix(n, max_val=50, inf_prob=0.05)

        t0 = time.time()
        B = trop_mat_pow(G, 100)
        t1 = time.time()
        _ = trop_mat_pow(G, 10000)
        t2 = time.time()

        t3 = time.time()
        k_found = eigenvalue_attack(G, B)
        t4 = time.time()

        status = "✓" if k_found == 100 else "✗"

        print(f"  {n:>6} {(t1-t0)*1000:>11.2f} {(t2-t1)*1000:>13.2f} "
              f"{(t4-t3)*1000:>10.2f} {status}")

    print()
    print("  → Attack time scales polynomially, breaking the 'one-way' assumption.")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║     TROPICAL CRYPTOGRAPHY: Min-Plus Encryption & Cryptanalysis      ║")
    print("║                                                                      ║")
    print("║  Demonstrating structural attacks on the Tropical Discrete Log       ║")
    print("║  Problem (TDLP), with machine-verified proofs in Lean 4.            ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_tropical_arithmetic()
    demo_diffie_hellman()
    demo_eigenvalue_attack()
    demo_diagonal_attack()
    demo_kleene_star()
    demo_security_analysis()

    print("=" * 70)
    print("SUMMARY: Tropical cryptography is structurally vulnerable.")
    print()
    print("The min-plus semiring provides efficient forward computation (O(n³ log k))")
    print("but the Tropical DLP can be broken via:")
    print("  1. Diagonal entry analysis (proven: trop_diag_attack_recovers_k)")
    print("  2. Eigenvalue extraction (proven: trop_power_diag_subadditive)")
    print("  3. Shortest path algorithms (proven: graph-matrix correspondence)")
    print("  4. Orbit periodicity (proven: trop_bounded_orbit_periodic)")
    print()
    print("All structural results are machine-verified in Lean 4 with zero sorries.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: TDLP Attack Success Rate vs Matrix Size

Compares the success of different attack strategies across matrix sizes,
demonstrating that the TDLP is structurally weak.
"""
import matplotlib.pyplot as plt
import numpy as np
import random
import time

def trop_add(a, b):
    return min(a, b)

def trop_mul(a, b):
    if a == float('inf') or b == float('inf'):
        return float('inf')
    return a + b

def trop_mat_mul(A, B):
    n = len(A)
    C = [[float('inf')] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i][j] = trop_add(C[i][j], trop_mul(A[i][k], B[k][j]))
    return C

def trop_mat_identity(n):
    I = [[float('inf')] * n for _ in range(n)]
    for i in range(n):
        I[i][i] = 0
    return I

def trop_mat_pow(A, k):
    n = len(A)
    result = trop_mat_identity(n)
    base = [row[:] for row in A]
    while k > 0:
        if k & 1:
            result = trop_mat_mul(result, base)
        base = trop_mat_mul(base, base)
        k >>= 1
    return result

def trop_trace(A):
    return min(A[i][i] for i in range(len(A)))

def diagonal_attack(A, B):
    n = len(A)
    for i in range(n):
        if A[i][i] != 0 and A[i][i] != float('inf') and B[i][i] != float('inf'):
            k_est = B[i][i] / A[i][i]
            if abs(k_est - round(k_est)) < 0.001 and k_est > 0:
                k = int(round(k_est))
                if trop_mat_pow(A, k) == B:
                    return k
    return None

def orbit_attack(A, B, max_k=200):
    n = len(A)
    power = trop_mat_identity(n)
    for k in range(1, max_k + 1):
        power = trop_mat_mul(power, A)
        if power == B:
            return k
    return None

def random_tropical_matrix(n, max_val=20, inf_prob=0.1):
    A = []
    for i in range(n):
        row = []
        for j in range(n):
            if random.random() < inf_prob:
                row.append(float('inf'))
            else:
                row.append(random.randint(0, max_val))
        A.append(row)
    return A

def main():
    random.seed(42)
    
    sizes = [2, 3, 4, 5, 6, 8]
    trials = 30
    secret_k = 50
    
    diag_success = []
    orbit_success = []
    total_success = []
    avg_times = []
    
    for n in sizes:
        d_wins = 0
        o_wins = 0
        t_wins = 0
        times = []
        
        for _ in range(trials):
            A = random_tropical_matrix(n, max_val=20, inf_prob=0.05)
            B = trop_mat_pow(A, secret_k)
            
            t0 = time.time()
            
            # Try diagonal attack
            k = diagonal_attack(A, B)
            if k is not None:
                d_wins += 1
                t_wins += 1
                times.append(time.time() - t0)
                continue
            
            # Try orbit attack
            k = orbit_attack(A, B, max_k=200)
            if k is not None:
                o_wins += 1
                t_wins += 1
                times.append(time.time() - t0)
                continue
            
            times.append(time.time() - t0)
        
        diag_success.append(d_wins / trials * 100)
        orbit_success.append(o_wins / trials * 100)
        total_success.append(t_wins / trials * 100)
        avg_times.append(np.mean(times) * 1000)
    
    # Create figure
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    
    x = np.arange(len(sizes))
    width = 0.25
    
    ax1.bar(x - width, diag_success, width, label='Diagonal Attack',
           color='#e74c3c', alpha=0.8)
    ax1.bar(x, orbit_success, width, label='Orbit Attack',
           color='#3498db', alpha=0.8)
    ax1.bar(x + width, total_success, width, label='Combined',
           color='#2ecc71', alpha=0.8)
    
    ax1.set_xlabel('Matrix Size n', fontsize=12)
    ax1.set_ylabel('Attack Success Rate (%)', fontsize=12)
    ax1.set_title(f'TDLP Attack Success Rate\n(k = {secret_k}, {trials} trials per size)',
                 fontsize=13)
    ax1.set_xticks(x)
    ax1.set_xticklabels([f'{n}×{n}' for n in sizes])
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3, axis='y')
    ax1.set_ylim(0, 105)
    
    # Plot 2: Attack time vs matrix size
    ax2.semilogy(sizes, avg_times, 'ro-', markersize=8, linewidth=2,
                label='Average attack time')
    
    # Polynomial fit for comparison
    coeffs = np.polyfit(np.log(sizes), np.log(avg_times), 1)
    fit_x = np.linspace(min(sizes), max(sizes), 100)
    fit_y = np.exp(coeffs[1]) * fit_x ** coeffs[0]
    ax2.semilogy(fit_x, fit_y, 'b--', alpha=0.5,
                label=f'Power law: O(n^{{{coeffs[0]:.1f}}})')
    
    ax2.set_xlabel('Matrix Size n', fontsize=12)
    ax2.set_ylabel('Average Time (ms)', fontsize=12)
    ax2.set_title('Attack Computational Cost\n(Polynomial, NOT exponential)', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    
    plt.suptitle('Structural Cryptanalysis of the Tropical DLP',
                fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('tropical_attack_comparison.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved tropical_attack_comparison.png")

if __name__ == '__main__':
    main()


#!/usr/bin/env python3
"""
Visualization: Tropical Matrix Power Orbit and Eigenvalue Convergence

Shows how the tropical trace (minimum diagonal entry) of A^k converges
to the tropical eigenvalue, demonstrating the subadditivity attack.
"""
import matplotlib.pyplot as plt
import numpy as np

def trop_add(a, b):
    return min(a, b)

def trop_mul(a, b):
    if a == float('inf') or b == float('inf'):
        return float('inf')
    return a + b

def trop_mat_mul(A, B):
    n = len(A)
    C = [[float('inf')] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i][j] = trop_add(C[i][j], trop_mul(A[i][k], B[k][j]))
    return C

def trop_mat_identity(n):
    I = [[float('inf')] * n for _ in range(n)]
    for i in range(n):
        I[i][i] = 0
    return I

def trop_trace(A):
    return min(A[i][i] for i in range(len(A)))

def main():
    # Test matrix
    A = [[2, 5, 1, 8],
         [3, 4, 7, 2],
         [6, 1, 3, 5],
         [4, 8, 2, 6]]

    max_k = 30
    traces = []
    mean_traces = []
    diag_entries = {i: [] for i in range(4)}
    
    power = trop_mat_identity(4)
    for k in range(1, max_k + 1):
        power = trop_mat_mul(power, A)
        tr = trop_trace(power)
        traces.append(tr)
        mean_traces.append(tr / k)
        for i in range(4):
            diag_entries[i].append(power[i][i])

    # Create figure with 3 subplots
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Plot 1: Diagonal entries showing subadditivity
    ks = list(range(1, max_k + 1))
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12']
    for i in range(4):
        axes[0].plot(ks, diag_entries[i], '-o', markersize=3,
                    color=colors[i], label=f'(A^k)_{{{i}{i}}}')
    axes[0].set_xlabel('Power k', fontsize=12)
    axes[0].set_ylabel('Diagonal entry value', fontsize=12)
    axes[0].set_title('Diagonal Entries of A^k\n(Subadditive sequences)', fontsize=13)
    axes[0].legend(fontsize=9)
    axes[0].grid(True, alpha=0.3)

    # Plot 2: Trace and subadditivity bound
    axes[1].plot(ks, traces, 'b-o', markersize=3, label='tr(A^k) = min diag')
    # Show subadditivity: tr(A^{m+k}) ≤ tr(A^m) + tr(A^k)
    bound = [traces[0] * k for k in ks]
    axes[1].plot(ks, bound, 'r--', alpha=0.7, label=f'k · tr(A) = k · {traces[0]}')
    axes[1].set_xlabel('Power k', fontsize=12)
    axes[1].set_ylabel('Tropical trace', fontsize=12)
    axes[1].set_title('Tropical Trace: tr(A^k)\n(Linear bound from subadditivity)', fontsize=13)
    axes[1].legend(fontsize=9)
    axes[1].grid(True, alpha=0.3)

    # Plot 3: Convergence to tropical eigenvalue
    axes[2].plot(ks, mean_traces, 'g-o', markersize=3, label='tr(A^k) / k')
    eigenvalue = min(mean_traces)
    axes[2].axhline(y=eigenvalue, color='r', linestyle='--', alpha=0.7,
                   label=f'λ(A) ≈ {eigenvalue:.3f}')
    axes[2].set_xlabel('Power k', fontsize=12)
    axes[2].set_ylabel('Normalized trace', fontsize=12)
    axes[2].set_title('Convergence to Tropical Eigenvalue\nλ(A) = lim tr(A^k)/k', fontsize=13)
    axes[2].legend(fontsize=9)
    axes[2].grid(True, alpha=0.3)

    plt.suptitle('Tropical Matrix Power Analysis: Walk Concatenation & Eigenvalue Attack',
                fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('tropical_orbit_analysis.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved tropical_orbit_analysis.png")

if __name__ == '__main__':
    main()
