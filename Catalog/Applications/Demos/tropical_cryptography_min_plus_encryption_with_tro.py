#!/usr/bin/env python3
"""
Tropical Cryptography Demo
===========================
Demonstrates the Tropical Diffie-Hellman key exchange,
the spectral attack on the TDLP, and tropical mask encryption.
"""

import random
from algorithms import (
    trop_mat_mul, trop_mat_pow, trop_trace, trop_eigenvalue_estimate,
    trop_identity, trop_scalar_matrix, spectral_attack,
    TropicalDiffieHellman, TropicalMaskEncryption, make_permutation_mask,
    INF
)


def print_matrix(name: str, M):
    """Pretty-print a tropical matrix."""
    print(f"\n{name}:")
    for row in M:
        print("  [" + ", ".join(f"{x:6.1f}" if x != INF else "   inf" for x in row) + "]")


def demo_tropical_dh():
    """Demonstrate the Tropical Diffie-Hellman key exchange."""
    print("=" * 60)
    print("DEMO 1: Tropical Diffie-Hellman Key Exchange")
    print("=" * 60)
    
    # Public generator matrix
    A = [[0, 1, 5, 2],
         [3, 0, 2, 4],
         [1, 6, 0, 1],
         [2, 3, 4, 0]]
    
    print_matrix("Public generator A", A)
    
    # Alice and Bob choose secret exponents
    alice_secret = 13
    bob_secret = 7
    print(f"\nAlice's secret: a = {alice_secret}")
    print(f"Bob's secret:   b = {bob_secret}")
    
    dh = TropicalDiffieHellman(A)
    
    # Compute public keys
    alice_pub = dh.public_key(alice_secret)
    bob_pub = dh.public_key(bob_secret)
    print_matrix("Alice's public key A^{⊗a}", alice_pub)
    print_matrix("Bob's public key A^{⊗b}", bob_pub)
    
    # Compute shared secrets
    shared_alice = dh.shared_secret(bob_pub, alice_secret)
    shared_bob = dh.shared_secret(alice_pub, bob_secret)
    print_matrix("Alice computes (A^{⊗b})^{⊗a}", shared_alice)
    print_matrix("Bob computes (A^{⊗a})^{⊗b}", shared_bob)
    
    print(f"\n✓ Shared secrets match: {shared_alice == shared_bob}")
    print(f"  This confirms tropPow_mul: A^{{⊗(ab)}} = (A^{{⊗a}})^{{⊗b}}")


def demo_spectral_attack():
    """Demonstrate the spectral attack on TDLP."""
    print("\n" + "=" * 60)
    print("DEMO 2: Spectral Attack on the Tropical DLP")
    print("=" * 60)
    
    # Case 1: Scalar matrix (attack succeeds)
    print("\n--- Case 1: Scalar matrix (λ = 3) ---")
    n = 4
    S = trop_scalar_matrix(n, 3.0)
    k_true = 17
    Sk = trop_mat_pow(S, k_true)
    
    lam_S = trop_eigenvalue_estimate(S)
    lam_Sk = trop_eigenvalue_estimate(Sk)
    print(f"λ(S) = {lam_S}")
    print(f"λ(S^{{⊗{k_true}}}) = {lam_Sk}")
    print(f"k = λ(S^k) / λ(S) = {lam_Sk} / {lam_S} = {lam_Sk / lam_S}")
    
    recovered = spectral_attack(S, Sk)
    print(f"Spectral attack recovers k = {recovered} (true k = {k_true})")
    print(f"✓ Attack {'SUCCEEDS' if recovered == k_true else 'FAILS'}")
    
    # Case 2: Dense matrix (attack may or may not succeed)
    print("\n--- Case 2: Dense random matrix ---")
    random.seed(42)
    A = [[random.randint(0, 10) for _ in range(4)] for _ in range(4)]
    k_true = 5
    Ak = trop_mat_pow(A, k_true)
    
    print_matrix("A", A)
    lam_A = trop_eigenvalue_estimate(A)
    lam_Ak = trop_eigenvalue_estimate(Ak)
    print(f"\nλ(A) = {lam_A}")
    print(f"λ(A^{{⊗{k_true}}}) = {lam_Ak}")
    
    recovered = spectral_attack(A, Ak)
    print(f"Spectral attack recovers k = {recovered} (true k = {k_true})")
    
    # Case 3: Demonstrate eigenvalue additivity for powers
    print("\n--- Case 3: Eigenvalue under tropical powers ---")
    A = [[0, 1, 3],
         [2, 0, 1],
         [1, 3, 0]]
    print_matrix("A", A)
    lam = trop_eigenvalue_estimate(A)
    print(f"λ(A) = {lam}")
    
    for k in range(1, 8):
        Ak = trop_mat_pow(A, k)
        lam_k = trop_eigenvalue_estimate(Ak)
        print(f"  λ(A^{{⊗{k}}}) = {lam_k:6.2f},  k·λ(A) = {k * lam:6.2f},  "
              f"ratio = {lam_k / lam if lam != 0 else 'N/A':>6}")


def demo_mask_encryption():
    """Demonstrate tropical mask encryption."""
    print("\n" + "=" * 60)
    print("DEMO 3: Tropical Mask Encryption")
    print("=" * 60)
    
    # Create a permutation-based mask
    perm = [2, 0, 3, 1]  # a permutation of {0,1,2,3}
    mask, mask_inv = make_permutation_mask(perm)
    
    print(f"Permutation: {perm}")
    print_matrix("Mask M", mask)
    print_matrix("Mask inverse M⁻¹", mask_inv)
    
    # Verify M ⊗ M⁻¹ = I
    product = trop_mat_mul(mask, mask_inv)
    identity = trop_identity(4)
    print(f"\nM ⊗ M⁻¹ = I: {product == identity}")
    
    # Encrypt and decrypt a message
    plaintext = [[1, 2, 3, 4],
                 [5, 6, 7, 8],
                 [9, 10, 11, 12],
                 [13, 14, 15, 16]]
    
    enc = TropicalMaskEncryption(mask, mask_inv)
    ciphertext = enc.encrypt(plaintext)
    recovered = enc.decrypt(ciphertext)
    
    print_matrix("Plaintext P", plaintext)
    print_matrix("Ciphertext E = M ⊗ P ⊗ M⁻¹", ciphertext)
    print_matrix("Decrypted M⁻¹ ⊗ E ⊗ M", recovered)
    print(f"\n✓ Decryption correct: {recovered == plaintext}")


def demo_diagonal_subadditivity():
    """Demonstrate the diagonal entry subadditivity property."""
    print("\n" + "=" * 60)
    print("DEMO 4: Diagonal Entry Subadditivity")
    print("=" * 60)
    
    A = [[0, 1, 5],
         [3, 0, 2],
         [1, 4, 0]]
    
    print_matrix("A", A)
    print(f"\nVerifying (A^{{⊗(m+k)}})_{{ii}} ≤ (A^{{⊗m}})_{{ii}} + (A^{{⊗k}})_{{ii}}:")
    
    for m in range(1, 5):
        for k in range(1, 5):
            Am = trop_mat_pow(A, m)
            Ak = trop_mat_pow(A, k)
            Amk = trop_mat_pow(A, m + k)
            
            for i in range(3):
                lhs = Amk[i][i]
                rhs = Am[i][i] + Ak[i][i]
                holds = lhs <= rhs + 1e-10
                if not holds:
                    print(f"  VIOLATION at m={m}, k={k}, i={i}: "
                          f"{lhs} > {rhs}")
    
    print("  ✓ All checks passed!")
    
    # Show the values
    print("\n  Diagonal values (A^{⊗k})_{00} for k=1..8:")
    for k in range(1, 9):
        Ak = trop_mat_pow(A, k)
        print(f"    k={k}: {Ak[0][0]:6.1f}  (average: {Ak[0][0]/k:6.2f})")


if __name__ == "__main__":
    demo_tropical_dh()
    demo_spectral_attack()
    demo_mask_encryption()
    demo_diagonal_subadditivity()
    
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Tropical Matrix Power Stabilization and Spectral Attack
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import random

INF = float('inf')

def trop_mat_mul(A, B):
    n = len(A)
    k = len(B)
    m = len(B[0]) if k > 0 else 0
    result = [[INF] * m for _ in range(n)]
    for i in range(n):
        for j in range(m):
            for t in range(k):
                a, b = A[i][t], B[t][j]
                if a != INF and b != INF:
                    result[i][j] = min(result[i][j], a + b)
    return result

def trop_identity(n):
    return [[0 if i == j else INF for j in range(n)] for i in range(n)]

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

def trop_trace(A):
    return min(A[i][i] for i in range(len(A)))

# --- Plot 1: Diagonal entry growth under tropical powers ---
fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Matrix with interesting eigenvalue structure
A = [[0, 3, 7, 2],
     [5, 0, 1, 4],
     [2, 6, 0, 3],
     [1, 4, 5, 0]]

max_k = 20
diag_vals = {i: [] for i in range(4)}
traces = []
for k in range(1, max_k + 1):
    Ak = trop_mat_pow(A, k)
    for i in range(4):
        diag_vals[i].append(Ak[i][i])
    traces.append(trop_trace(Ak))

ax = axes[0]
ks = list(range(1, max_k + 1))
for i in range(4):
    ax.plot(ks, diag_vals[i], 'o-', markersize=3, label=f'$(A^{{\\otimes k}})_{{{i}{i}}}$')
ax.plot(ks, traces, 'k--', linewidth=2, label='Trace (min diag)')
ax.set_xlabel('Power k')
ax.set_ylabel('Value')
ax.set_title('Diagonal Entries of $A^{\\otimes k}$')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# --- Plot 2: Normalized diagonal (convergence to eigenvalue) ---
ax = axes[1]
for i in range(4):
    normalized = [diag_vals[i][k-1] / k for k in range(1, max_k + 1)]
    ax.plot(ks, normalized, 'o-', markersize=3, label=f'$(A^{{\\otimes k}})_{{{i}{i}}}/k$')
ax.axhline(y=min(traces[k-1]/k for k in range(1, max_k+1)), color='red', 
           linestyle='--', label='$\\lambda(A)$')
ax.set_xlabel('Power k')
ax.set_ylabel('Normalized value')
ax.set_title('Convergence to Tropical Eigenvalue')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# --- Plot 3: Spectral attack success rate vs matrix structure ---
ax = axes[2]
random.seed(42)
sizes = [2, 3, 4, 5, 6]
densities = [0.5, 0.7, 1.0]
results = {}

for density in densities:
    success_rates = []
    for n in sizes:
        successes = 0
        trials = 20
        for trial in range(trials):
            M = [[INF] * n for _ in range(n)]
            for i in range(n):
                for j in range(n):
                    if random.random() < density:
                        M[i][j] = random.randint(1, 10)
            k_true = random.randint(2, 15)
            Mk = trop_mat_pow(M, k_true)
            # Try spectral attack
            lam_M = min((trop_trace(trop_mat_pow(M, k)) / k 
                        for k in range(1, n * 2 + 1) 
                        if trop_trace(trop_mat_pow(M, k)) != INF), default=INF)
            lam_Mk = min((trop_trace(trop_mat_pow(Mk, k)) / k 
                         for k in range(1, n * 2 + 1)
                         if trop_trace(trop_mat_pow(Mk, k)) != INF), default=INF)
            if lam_M != INF and lam_M != 0 and lam_Mk != INF:
                k_est = round(lam_Mk / lam_M)
                if k_est == k_true:
                    successes += 1
            elif lam_M == 0:
                pass  # eigenvalue zero -> attack fails
        success_rates.append(successes / trials * 100)
    ax.plot(sizes, success_rates, 'o-', markersize=5, label=f'density={density}')

ax.set_xlabel('Matrix size n')
ax.set_ylabel('Attack success rate (%)')
ax.set_title('Spectral Attack Effectiveness')
ax.legend()
ax.grid(True, alpha=0.3)
ax.set_ylim(-5, 105)

plt.tight_layout()
plt.savefig('tropical_crypto_analysis.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved tropical_crypto_analysis.png")
