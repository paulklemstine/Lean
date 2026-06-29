#!/usr/bin/env python3
"""
McEliece Cryptosystem Demo

Demonstrates key generation, encryption, and decryption using a toy-sized
binary Goppa code. Also computes ISD work factors for NIST parameters.
"""

import random
from math import comb, log2, sqrt

# ============================================================
# Part 1: Toy McEliece over a small linear code
# ============================================================

def random_binary_vector(n, weight=None):
    """Generate a random binary vector of length n with optional fixed weight."""
    if weight is not None:
        v = [0] * n
        positions = random.sample(range(n), weight)
        for p in positions:
            v[p] = 1
        return v
    return [random.randint(0, 1) for _ in range(n)]

def gf2_dot(a, b):
    """Dot product over GF(2)."""
    return sum(x * y for x, y in zip(a, b)) % 2

def gf2_mat_vec(mat, vec):
    """Matrix-vector product over GF(2)."""
    return [gf2_dot(row, vec) for row in mat]

def gf2_vec_add(a, b):
    """Vector addition over GF(2)."""
    return [(x + y) % 2 for x, y in zip(a, b)]

def hamming_weight(v):
    """Hamming weight of a binary vector."""
    return sum(v)

def transpose(mat):
    """Transpose a matrix."""
    return [list(row) for row in zip(*mat)]

# A simple [7, 4, 3] Hamming code (can correct 1 error)
# Generator matrix (systematic form)
G_hamming = [
    [1, 0, 0, 0, 1, 1, 0],
    [0, 1, 0, 0, 1, 0, 1],
    [0, 0, 1, 0, 0, 1, 1],
    [0, 0, 0, 1, 1, 1, 1],
]

# Parity check matrix
H_hamming = [
    [1, 1, 0, 1, 1, 0, 0],
    [1, 0, 1, 1, 0, 1, 0],
    [0, 1, 1, 1, 0, 0, 1],
]

def hamming_decode(received):
    """Decode a [7,4,3] Hamming code (correct up to 1 error)."""
    syndrome = gf2_mat_vec(H_hamming, received)
    if syndrome == [0, 0, 0]:
        return received[:4]  # No error
    # Find which column of H matches the syndrome
    corrected = received[:]
    for j in range(7):
        col = [H_hamming[r][j] for r in range(3)]
        if col == syndrome:
            corrected[j] = 1 - corrected[j]
            break
    return corrected[:4]

def toy_mceliece_keygen():
    """Generate a toy McEliece key pair using [7,4,3] Hamming code.
    For this demo, we use identity scrambling to clearly show the
    encode → add error → decode pipeline."""
    return {
        'public_key': G_hamming,  # In real McEliece, this would be S*G*P
        'secret_key': {
            'G': G_hamming,
        }
    }

def toy_mceliece_encrypt(pub_key, message, error_weight=1):
    """Encrypt a 4-bit message. Codeword = sum of message[i] * pub_key[i]."""
    n = len(pub_key[0])
    codeword = [0] * n
    for i, bit in enumerate(message):
        if bit:
            codeword = gf2_vec_add(codeword, pub_key[i])
    error = random_binary_vector(n, weight=error_weight)
    ciphertext = gf2_vec_add(codeword, error)
    return ciphertext, error

def toy_mceliece_decrypt(secret_key, ciphertext):
    """Decrypt using the secret key (identity scrambling in this demo)."""
    # In real McEliece: apply P^{-1}, then decode, then apply S^{-1}
    # Here with identity scrambling, just decode directly
    decoded = hamming_decode(ciphertext)
    return decoded

# Demo
print("=" * 60)
print("McEliece Cryptosystem Demo (Toy [7,4,3] Hamming Code)")
print("=" * 60)

keys = toy_mceliece_keygen()
message = [1, 0, 1, 1]
print(f"\nOriginal message:  {message}")

ciphertext, error = toy_mceliece_encrypt(keys['public_key'], message, error_weight=1)
print(f"Error vector:      {error} (weight {hamming_weight(error)})")
print(f"Ciphertext:        {ciphertext}")

recovered = toy_mceliece_decrypt(keys['secret_key'], ciphertext)
print(f"Recovered message: {recovered}")
print(f"Correct: {recovered == message}")

# ============================================================
# Part 2: ISD Work Factor Analysis for NIST Parameters
# ============================================================

print("\n" + "=" * 60)
print("Information Set Decoding Work Factors")
print("=" * 60)

nist_params = [
    ("McEliece-348864", 3488, 2720, 64),
    ("McEliece-460896", 4608, 3360, 96),
    ("McEliece-6688128", 6688, 5024, 128),
    ("McEliece-6960119", 6960, 5413, 119),
    ("McEliece-8192128", 8192, 6528, 128),
]

print(f"\n{'Name':<22} {'n':>6} {'k':>6} {'t':>4} {'C(n,t) bits':>12} {'Quantum bits':>13}")
print("-" * 70)

for name, n, k, t in nist_params:
    # C(n,t) ≈ 2^(log2(C(n,t)))
    log_comb = sum(log2(n - i) - log2(i + 1) for i in range(t))
    quantum_bits = log_comb / 2
    print(f"{name:<22} {n:>6} {k:>6} {t:>4} {log_comb:>12.1f} {quantum_bits:>13.1f}")

# ============================================================
# Part 3: Grover's Bound Demonstration
# ============================================================

print("\n" + "=" * 60)
print("Grover's Quantum Search Lower Bound")
print("=" * 60)

for bits in [64, 128, 192, 256]:
    classical = 2 ** bits
    quantum_queries = int(sqrt(classical))
    print(f"  Classical: 2^{bits} → Quantum: 2^{bits//2} ({bits//2}-bit quantum security)")

# ============================================================
# Part 4: Pascal's Identity and Binomial Growth
# ============================================================

print("\n" + "=" * 60)
print("Pascal's Identity: C(n,t) = C(n-1,t-1) + C(n-1,t)")
print("=" * 60)

for n in [10, 20, 50, 100]:
    for t in [2, 5]:
        if t <= n // 2:
            c_nt = comb(n, t)
            c_left = comb(n-1, t-1)
            c_right = comb(n-1, t)
            print(f"  C({n},{t}) = {c_nt} = {c_left} + {c_right} "
                  f"(≈ 2^{log2(c_nt):.1f} bits)")

# ============================================================
# Part 5: GCD Experiment (Empirical)
# ============================================================

print("\n" + "=" * 60)
print("Goppa Code Distinguishing: Empirical Test")
print("=" * 60)

def random_matrix_gf2(rows, cols):
    """Generate a random binary matrix."""
    return [[random.randint(0, 1) for _ in range(cols)] for _ in range(rows)]

def matrix_rank_gf2(mat):
    """Compute rank of a binary matrix via Gaussian elimination."""
    mat = [row[:] for row in mat]
    m, n = len(mat), len(mat[0])
    rank = 0
    for col in range(n):
        pivot = None
        for row in range(rank, m):
            if mat[row][col] == 1:
                pivot = row
                break
        if pivot is None:
            continue
        mat[rank], mat[pivot] = mat[pivot], mat[rank]
        for row in range(m):
            if row != rank and mat[row][col] == 1:
                mat[row] = [(mat[row][j] + mat[rank][j]) % 2 for j in range(n)]
        rank += 1
    return rank

# Generate random matrices and check rank distribution
print("\nRank distribution of random 8x12 binary matrices:")
rank_counts = {}
for _ in range(1000):
    M = random_matrix_gf2(8, 12)
    r = matrix_rank_gf2(M)
    rank_counts[r] = rank_counts.get(r, 0) + 1

for r in sorted(rank_counts):
    print(f"  Rank {r}: {rank_counts[r]/10:.1f}%")

print("\nA Goppa code's generator matrix always has full rank (= k).")
print("This is a necessary but not sufficient distinguishing criterion.")
print("The GCD assumption states that no efficient algorithm can do better.")


#!/usr/bin/env python3
"""
Visualization: ISD Complexity Growth

Plots how the Information Set Decoding work factor grows with code parameters,
demonstrating the exponential hardness that underpins McEliece security.
"""

import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')
from math import log2, comb

# Plot 1: C(n,t) growth for fixed t/n ratio
fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Panel 1: C(n, t) for varying n, fixed t
ax = axes[0]
ts = [8, 16, 32, 64]
for t in ts:
    ns = list(range(2*t, min(500, 10*t), max(1, t//4)))
    bits = [sum(log2(n - i) - log2(i + 1) for i in range(t)) for n in ns]
    ax.plot(ns, bits, linewidth=2, label=f't = {t}')

ax.set_xlabel('Code length n', fontsize=12)
ax.set_ylabel('log₂ C(n,t)', fontsize=12)
ax.set_title('Binomial Growth: C(n,t)', fontsize=14)
ax.legend(fontsize=10)
ax.grid(alpha=0.3)

# Panel 2: Pascal's identity illustration
ax = axes[1]
n_vals = list(range(2, 30))
for t in [1, 2, 3, 5]:
    c_vals = [comb(n, t) for n in n_vals if t <= n]
    valid_n = [n for n in n_vals if t <= n]
    ax.semilogy(valid_n, c_vals, 'o-', linewidth=2, markersize=4, label=f'C(n, {t})')

ax.set_xlabel('n', fontsize=12)
ax.set_ylabel('C(n, t) [log scale]', fontsize=12)
ax.set_title("Pascal's Growth: C(n,t) ≥ 2 for 1≤t≤n/2", fontsize=14)
ax.legend(fontsize=10)
ax.grid(alpha=0.3)

# Panel 3: Grover speedup visualization
ax = axes[2]
classical = list(range(64, 513, 16))
quantum = [c / 2 for c in classical]
ax.fill_between(classical, quantum, classical, alpha=0.2, color='red', label='Quantum advantage region')
ax.plot(classical, classical, 'b-', linewidth=2, label='Classical security')
ax.plot(classical, quantum, 'r--', linewidth=2, label='Quantum security (Grover)')
ax.axhline(y=128, color='green', linestyle=':', alpha=0.7, label='128-bit threshold')

ax.set_xlabel('Classical Security (bits)', fontsize=12)
ax.set_ylabel('Effective Security (bits)', fontsize=12)
ax.set_title("Grover's Halving: λ_q = λ_c / 2", fontsize=14)
ax.legend(fontsize=10)
ax.grid(alpha=0.3)

plt.tight_layout()
plt.savefig('isd_complexity.png', dpi=150, bbox_inches='tight')
print("Saved: isd_complexity.png")


#!/usr/bin/env python3
"""
Visualization: McEliece Security Landscape

Plots classical vs quantum security levels for various McEliece parameter sets,
showing the Grover halving effect.
"""

import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')
from math import log2

def isd_work_factor(n, k, t):
    """Compute ISD work factor in bits."""
    log_num = sum(log2(n - i) - log2(i + 1) for i in range(t))
    log_den = sum(log2(n - k - i) - log2(i + 1) for i in range(min(t, n - k)))
    return log_num - log_den

# NIST parameter sets
params = [
    ("348864", 3488, 2720, 64),
    ("460896", 4608, 3360, 96),
    ("6688128", 6688, 5024, 128),
    ("6960119", 6960, 5413, 119),
    ("8192128", 8192, 6528, 128),
]

names = []
classical_bits = []
quantum_bits = []
key_sizes_kb = []

for name, n, k, t in params:
    wf = isd_work_factor(n, k, t)
    names.append(name)
    classical_bits.append(wf)
    quantum_bits.append(wf / 2)
    key_sizes_kb.append(k * (n - k) / 8 / 1024)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Classical vs Quantum Security
x = range(len(names))
width = 0.35
bars1 = ax1.bar([i - width/2 for i in x], classical_bits, width, label='Classical Security', color='#2196F3', alpha=0.8)
bars2 = ax1.bar([i + width/2 for i in x], quantum_bits, width, label='Quantum Security (Grover)', color='#FF5722', alpha=0.8)

# Reference lines
ax1.axhline(y=128, color='green', linestyle='--', alpha=0.7, label='128-bit target')
ax1.axhline(y=256, color='orange', linestyle='--', alpha=0.7, label='256-bit target')

ax1.set_xlabel('Parameter Set', fontsize=12)
ax1.set_ylabel('Security Level (bits)', fontsize=12)
ax1.set_title('McEliece Security: Classical vs Quantum', fontsize=14)
ax1.set_xticks(x)
ax1.set_xticklabels(names, rotation=30, ha='right')
ax1.legend(fontsize=10)
ax1.grid(axis='y', alpha=0.3)

# Plot 2: Key Size vs Security Tradeoff
ax2.scatter(key_sizes_kb, quantum_bits, s=150, c='#FF5722', zorder=5, label='Quantum Security')
ax2.scatter(key_sizes_kb, classical_bits, s=150, c='#2196F3', zorder=5, label='Classical Security')

for i, name in enumerate(names):
    ax2.annotate(name, (key_sizes_kb[i], quantum_bits[i]),
                textcoords="offset points", xytext=(10, -10), fontsize=9)

ax2.axhline(y=128, color='green', linestyle='--', alpha=0.7, label='128-bit target')
ax2.set_xlabel('Public Key Size (KB)', fontsize=12)
ax2.set_ylabel('Security Level (bits)', fontsize=12)
ax2.set_title('Security vs Key Size Tradeoff', fontsize=14)
ax2.legend(fontsize=10)
ax2.grid(alpha=0.3)

plt.tight_layout()
plt.savefig('security_landscape.png', dpi=150, bbox_inches='tight')
print("Saved: security_landscape.png")
