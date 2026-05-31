#!/usr/bin/env python3
"""
Tropical Cryptography Demo: Min-Plus Encryption with Tropical Matrices

Demonstrates:
1. Tropical matrix arithmetic
2. Tropical Diffie-Hellman key exchange
3. TDLP attack analysis (eigenvalue method vs brute force)
4. Security scaling with matrix dimension
"""

import time
import random
from algorithms import (
    TropicalDiffieHellman, trop_mat_pow, trop_identity,
    trop_mat_mul, trop_eigenvalue_estimate, attempt_tdlp_eigenvalue,
    attempt_tdlp_brute_force, generate_random_tropical_matrix,
    print_tropical_matrix, INF
)


def demo_tropical_arithmetic():
    """Demonstrate basic tropical matrix operations."""
    print("=" * 60)
    print("DEMO 1: Tropical Matrix Arithmetic")
    print("=" * 60)
    print()
    print("In tropical (min-plus) algebra:")
    print("  a ⊕ b = min(a, b)    (tropical addition)")
    print("  a ⊗ b = a + b        (tropical multiplication)")
    print("  0_trop = ∞            (additive identity)")
    print("  1_trop = 0            (multiplicative identity)")
    print()

    A = [[1, 3], [2, 0]]
    B = [[0, 2], [1, 4]]

    print_tropical_matrix(A, "A")
    print()
    print_tropical_matrix(B, "B")
    print()

    C = trop_mat_mul(A, B)
    print("A ⊗ B (tropical product):")
    print_tropical_matrix(C, "A⊗B")
    print()
    print("Verification: (A⊗B)_00 = min(1+0, 3+1) = min(1,4) = 1 ✓")
    print("              (A⊗B)_01 = min(1+2, 3+4) = min(3,7) = 3 ✓")
    print()

    I = trop_identity(2)
    print_tropical_matrix(I, "I (tropical identity)")
    print()
    AI = trop_mat_mul(A, I)
    print(f"A ⊗ I = A? {AI == A} ✓")
    print()


def demo_diffie_hellman():
    """Demonstrate the Tropical Diffie-Hellman key exchange."""
    print("=" * 60)
    print("DEMO 2: Tropical Diffie-Hellman Key Exchange")
    print("=" * 60)
    print()

    # Generator matrix
    G = [[1, 3, 7],
         [2, 0, 5],
         [4, 6, 1]]

    print("Public generator matrix:")
    print_tropical_matrix(G, "G")
    print()

    alice_secret = 17
    bob_secret = 23

    dh = TropicalDiffieHellman(G)

    # Key generation
    pub_a = dh.public_key(alice_secret)
    pub_b = dh.public_key(bob_secret)

    print(f"Alice's secret: a = {alice_secret}")
    print(f"Bob's secret:   b = {bob_secret}")
    print()

    print("Alice's public key G^{⊗a}:")
    print_tropical_matrix(pub_a, "pub_A")
    print()

    print("Bob's public key G^{⊗b}:")
    print_tropical_matrix(pub_b, "pub_B")
    print()

    # Shared key computation
    key_alice = dh.shared_key(pub_b, alice_secret)
    key_bob = dh.shared_key(pub_a, bob_secret)

    print("Alice computes: (pub_B)^{⊗a}")
    print_tropical_matrix(key_alice, "key_A")
    print()

    print("Bob computes: (pub_A)^{⊗b}")
    print_tropical_matrix(key_bob, "key_B")
    print()

    agreed = key_alice == key_bob
    print(f"Keys match: {agreed} {'✓' if agreed else '✗'}")
    print()

    # Verify against direct computation
    direct = trop_mat_pow(G, alice_secret * bob_secret)
    print(f"Direct G^{{⊗(a·b)}} = G^{{⊗{alice_secret * bob_secret}}} matches: {direct == key_alice} ✓")
    print()


def demo_tdlp_attacks():
    """Demonstrate attacks on the Tropical Discrete Logarithm Problem."""
    print("=" * 60)
    print("DEMO 3: TDLP Attack Analysis")
    print("=" * 60)
    print()

    random.seed(42)

    for n in [3, 5, 8]:
        print(f"--- Matrix dimension n = {n} ---")
        A = generate_random_tropical_matrix(n, max_val=50, seed=42 + n)
        k_true = random.randint(2, 50)
        B = trop_mat_pow(A, k_true)

        print(f"True exponent k = {k_true}")

        # Eigenvalue attack
        t0 = time.time()
        k_eigen = attempt_tdlp_eigenvalue(A, B)
        t_eigen = time.time() - t0

        if k_eigen is not None:
            print(f"  Eigenvalue attack: k = {k_eigen} "
                  f"({'correct' if k_eigen == k_true else 'WRONG'}) "
                  f"[{t_eigen*1000:.1f} ms]")
        else:
            print(f"  Eigenvalue attack: FAILED [{t_eigen*1000:.1f} ms]")

        # Brute force
        t0 = time.time()
        k_brute = attempt_tdlp_brute_force(A, B, max_k=200)
        t_brute = time.time() - t0

        if k_brute is not None:
            print(f"  Brute force:       k = {k_brute} "
                  f"({'correct' if k_brute == k_true else 'WRONG'}) "
                  f"[{t_brute*1000:.1f} ms]")
        else:
            print(f"  Brute force:       FAILED [{t_brute*1000:.1f} ms]")

        # Tropical eigenvalue
        lam = trop_eigenvalue_estimate(A)
        print(f"  Tropical eigenvalue λ(A) = {lam}")
        print()


def demo_security_scaling():
    """Measure key generation time vs matrix dimension."""
    print("=" * 60)
    print("DEMO 4: Security Scaling Analysis")
    print("=" * 60)
    print()

    print(f"{'n':>4} {'k':>6} {'KeyGen (ms)':>12} {'Eigenval':>10} {'EigenAtk':>10}")
    print("-" * 50)

    random.seed(123)

    for n in [3, 5, 8, 10, 15, 20, 30]:
        A = generate_random_tropical_matrix(n, max_val=100, seed=123 + n)
        k = random.randint(10, 100)

        # Key generation timing
        t0 = time.time()
        B = trop_mat_pow(A, k)
        t_keygen = (time.time() - t0) * 1000

        # Eigenvalue computation
        lam = trop_eigenvalue_estimate(A)
        lam_str = f"{lam:.2f}" if lam is not None else "None"

        # Eigenvalue attack
        k_attack = attempt_tdlp_eigenvalue(A, B)
        attack_str = str(k_attack) if k_attack is not None else "FAIL"

        print(f"{n:>4} {k:>6} {t_keygen:>12.2f} {lam_str:>10} {attack_str:>10}")

    print()
    print("Key insight: Key generation scales as O(n³ log k),")
    print("but the eigenvalue attack may succeed or fail depending")
    print("on the matrix structure. For 'generic' matrices, the")
    print("eigenvalue method often works, suggesting additional")
    print("hardness assumptions are needed for security.")


def demo_eigenvalue_vulnerability():
    """Show the eigenvalue-based vulnerability in tropical crypto."""
    print()
    print("=" * 60)
    print("DEMO 5: Eigenvalue Vulnerability Analysis")
    print("=" * 60)
    print()

    random.seed(999)
    n_trials = 100
    results = {True: 0, False: 0}

    for trial in range(n_trials):
        n = 5
        A = generate_random_tropical_matrix(n, max_val=20, seed=trial)
        k = random.randint(2, 50)
        B = trop_mat_pow(A, k)
        k_recovered = attempt_tdlp_eigenvalue(A, B)
        results[k_recovered == k] += True

    success_rate = results[True] / n_trials * 100
    print(f"Eigenvalue attack on 5×5 matrices (100 trials):")
    print(f"  Success rate: {success_rate:.0f}%")
    print(f"  Successes: {results[True]}, Failures: {results[False]}")
    print()

    if success_rate > 50:
        print("⚠ The eigenvalue attack succeeds often!")
        print("  This confirms that tropical eigenvalue computation")
        print("  is a viable attack, and security requires choosing")
        print("  matrices where this attack fails (e.g., matrices")
        print("  with multiple critical cycles or eigenvalue 0).")
    else:
        print("✓ The eigenvalue attack has limited success,")
        print("  supporting the TDLP hardness conjecture.")


if __name__ == "__main__":
    demo_tropical_arithmetic()
    print()
    demo_diffie_hellman()
    print()
    demo_tdlp_attacks()
    print()
    demo_security_scaling()
    demo_eigenvalue_vulnerability()
    print()
    print("=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Tropical Cryptography Security Landscape

Three panels:
1. Key generation time vs matrix dimension (log scale)
2. Eigenvalue attack success rate vs matrix dimension
3. Tropical matrix power entry evolution (heatmap)
"""

import random
import time
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np


# ---- Inlined tropical arithmetic functions ----

INF = float('inf')

def trop_add(a, b):
    return min(a, b)

def trop_mul(a, b):
    if a == INF or b == INF:
        return INF
    return a + b

def trop_identity(n):
    return [[0 if i == j else INF for j in range(n)] for i in range(n)]

def trop_mat_mul(A, B):
    n = len(A)
    C = [[INF] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i][j] = trop_add(C[i][j], trop_mul(A[i][k], B[k][j]))
    return C

def trop_mat_pow(A, k):
    n = len(A)
    if k == 0:
        return trop_identity(n)
    result = trop_identity(n)
    base = [row[:] for row in A]
    while k > 0:
        if k % 2 == 1:
            result = trop_mat_mul(result, base)
        base = trop_mat_mul(base, base)
        k //= 2
    return result

def trop_eigenvalue_estimate(A):
    n = len(A)
    powers = [trop_identity(n)]
    for k in range(1, n + 1):
        powers.append(trop_mat_mul(powers[-1], A))
    min_avg = INF
    for i in range(n):
        if powers[n][i][i] == INF:
            continue
        max_val = -INF
        for k in range(n):
            if powers[k][i][i] == INF:
                continue
            avg = (powers[n][i][i] - powers[k][i][i]) / (n - k)
            max_val = max(max_val, avg)
        if max_val < min_avg:
            min_avg = max_val
    return min_avg if min_avg != INF else None

def attempt_tdlp_eigenvalue(A, B):
    lambda_a = trop_eigenvalue_estimate(A)
    lambda_b = trop_eigenvalue_estimate(B)
    if lambda_a is None or lambda_b is None or lambda_a == 0:
        return None
    k_est = lambda_b / lambda_a
    k = round(k_est)
    if k >= 0 and trop_mat_pow(A, k) == B:
        return k
    return None

def generate_random_tropical_matrix(n, max_val=100, seed=None):
    rng = random.Random(seed)
    return [[rng.randint(0, max_val) for _ in range(n)] for _ in range(n)]

# ---- Visualization ----

def main():
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    fig.suptitle('Tropical Cryptography: Security Analysis', fontsize=14, fontweight='bold')

    # Panel 1: Key generation time vs dimension
    ax1 = axes[0]
    dimensions = [3, 5, 8, 10, 15, 20, 25, 30]
    keygen_times = []
    for n in dimensions:
        A = generate_random_tropical_matrix(n, max_val=50, seed=42 + n)
        t0 = time.time()
        for _ in range(5):
            trop_mat_pow(A, 100)
        t = (time.time() - t0) / 5 * 1000
        keygen_times.append(t)

    ax1.semilogy(dimensions, keygen_times, 'bo-', linewidth=2, markersize=8)
    # Fit n^3 curve
    n_fit = np.array(dimensions, dtype=float)
    scale = keygen_times[3] / (dimensions[3] ** 3)
    ax1.semilogy(n_fit, scale * n_fit**3, 'r--', alpha=0.6, label='O(n³) fit')
    ax1.set_xlabel('Matrix dimension n', fontsize=12)
    ax1.set_ylabel('Key generation time (ms)', fontsize=12)
    ax1.set_title('Key Generation Scaling', fontsize=12)
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Panel 2: Eigenvalue attack success rate
    ax2 = axes[1]
    dims_attack = [3, 4, 5, 6, 7, 8, 10, 12]
    success_rates = []
    n_trials = 50
    for n in dims_attack:
        successes = 0
        for trial in range(n_trials):
            A = generate_random_tropical_matrix(n, max_val=30, seed=trial * 100 + n)
            k = random.Random(trial + n).randint(2, 40)
            B = trop_mat_pow(A, k)
            k_rec = attempt_tdlp_eigenvalue(A, B)
            if k_rec == k:
                successes += 1
        success_rates.append(successes / n_trials * 100)

    ax2.bar(range(len(dims_attack)), success_rates, color='coral', edgecolor='darkred', alpha=0.8)
    ax2.set_xticks(range(len(dims_attack)))
    ax2.set_xticklabels([str(d) for d in dims_attack])
    ax2.set_xlabel('Matrix dimension n', fontsize=12)
    ax2.set_ylabel('Attack success rate (%)', fontsize=12)
    ax2.set_title('Eigenvalue Attack Success', fontsize=12)
    ax2.axhline(y=50, color='gray', linestyle='--', alpha=0.5, label='50% threshold')
    ax2.set_ylim(0, 100)
    ax2.legend()
    ax2.grid(True, alpha=0.3, axis='y')

    # Panel 3: Entry evolution heatmap
    ax3 = axes[2]
    n = 6
    A = generate_random_tropical_matrix(n, max_val=10, seed=77)
    max_pow = 15
    # Track entry (0,0) through (n-1, n-1) across powers
    entry_grid = np.zeros((n, max_pow))
    for p in range(1, max_pow + 1):
        Ap = trop_mat_pow(A, p)
        for i in range(n):
            entry_grid[i, p-1] = Ap[i][i] if Ap[i][i] != INF else np.nan

    im = ax3.imshow(entry_grid, aspect='auto', cmap='viridis',
                     interpolation='nearest')
    ax3.set_xlabel('Power k', fontsize=12)
    ax3.set_ylabel('Diagonal index i', fontsize=12)
    ax3.set_title('Diagonal entries of A^{⊗k}', fontsize=12)
    ax3.set_xticks(range(0, max_pow, 2))
    ax3.set_xticklabels([str(k+1) for k in range(0, max_pow, 2)])
    plt.colorbar(im, ax=ax3, label='Entry value')

    plt.tight_layout()
    plt.savefig('tropical_crypto_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved: tropical_crypto_analysis.png")


if __name__ == "__main__":
    main()
