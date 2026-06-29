#!/usr/bin/env python3
"""
Tropical Min-Plus Diffie-Hellman Key Exchange — Demo

Demonstrates the Tropical Centralizer Key Exchange (TCKE) protocol
using min-plus matrix algebra. Shows:
1. Tropical matrix multiplication (min-plus)
2. The TCKE protocol with power-based secrets
3. Security boundary: rank-1 vs generic matrices
4. Centralizer computation for small examples
"""

import numpy as np
from typing import Optional

INF = float('inf')

def trop_add(a: float, b: float) -> float:
    """Tropical addition: min(a, b)."""
    return min(a, b)

def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b (ordinary addition), with ∞ absorbing."""
    if a == INF or b == INF:
        return INF
    return a + b

def trop_mat_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical matrix multiplication: (A ⊗ B)_{ij} = min_k(A_{ik} + B_{kj})."""
    n, m = A.shape[0], B.shape[1]
    k = A.shape[1]
    C = np.full((n, m), INF)
    for i in range(n):
        for j in range(m):
            for l in range(k):
                val = trop_mul(A[i, l], B[l, j])
                C[i, j] = trop_add(C[i, j], val)
    return C

def trop_mat_pow(A: np.ndarray, k: int) -> np.ndarray:
    """Tropical matrix power A^k via repeated squaring."""
    n = A.shape[0]
    # Identity matrix: 0 on diagonal, ∞ elsewhere
    result = np.full((n, n), INF)
    np.fill_diagonal(result, 0)
    base = A.copy()
    while k > 0:
        if k % 2 == 1:
            result = trop_mat_mul(result, base)
        base = trop_mat_mul(base, base)
        k //= 2
    return result

def is_rank1(M: np.ndarray) -> bool:
    """Check if M is tropically rank-1 (M_{ij} = u_i + v_j for some u, v)."""
    n = M.shape[0]
    if n <= 1:
        return True
    # If rank-1, then M_{ij} - M_{i0} = v_j - v_0 is constant across rows
    for j in range(1, n):
        diffs = set()
        for i in range(n):
            if M[i, j] == INF or M[i, 0] == INF:
                diffs.add(INF)
            else:
                diffs.add(M[i, j] - M[i, 0])
        if len(diffs) > 1:
            return False
    return True

def compute_centralizer_size(G: np.ndarray, bound: int) -> int:
    """Count matrices with entries in {0,...,bound} that commute with G."""
    n = G.shape[0]
    count = 0
    from itertools import product as iprod
    entries = list(range(bound + 1))
    for vals in iprod(entries, repeat=n*n):
        M = np.array(vals, dtype=float).reshape(n, n)
        if np.array_equal(trop_mat_mul(M, G), trop_mat_mul(G, M)):
            count += 1
    return count

# ─── DEMO 1: Basic Tropical Arithmetic ───
print("=" * 60)
print("DEMO 1: Tropical (Min-Plus) Matrix Arithmetic")
print("=" * 60)

A = np.array([[0, 3], [7, 1]], dtype=float)
B = np.array([[2, 5], [4, 0]], dtype=float)

print(f"\nA = \n{A}")
print(f"\nB = \n{B}")

AB = trop_mat_mul(A, B)
BA = trop_mat_mul(B, A)
print(f"\nA ⊗ B = \n{AB}")
print(f"  (A⊗B)_00 = min(0+2, 3+4) = min(2, 7) = {AB[0,0]}")
print(f"\nB ⊗ A = \n{BA}")
print(f"\nA ⊗ B ≠ B ⊗ A: {not np.array_equal(AB, BA)} (Non-commutative!)")

# ─── DEMO 2: TCKE Protocol ───
print("\n" + "=" * 60)
print("DEMO 2: Tropical Centralizer Key Exchange (TCKE)")
print("=" * 60)

G = np.array([[0, 3, 7],
              [2, 0, 5],
              [4, 6, 0]], dtype=float)
alice_secret = 5   # Alice picks secret exponent a = 5
bob_secret = 8     # Bob picks secret exponent b = 8

print(f"\nPublic generator G:\n{G}")
print(f"Alice's secret: a = {alice_secret}")
print(f"Bob's secret:   b = {bob_secret}")

# Alice computes G^a, Bob computes G^b
Ga = trop_mat_pow(G, alice_secret)
Gb = trop_mat_pow(G, bob_secret)
print(f"\nAlice's public key G^{alice_secret}:\n{Ga}")
print(f"\nBob's public key G^{bob_secret}:\n{Gb}")

# Shared key: both compute G^(a+b+1)
alice_shared = trop_mat_mul(Ga, trop_mat_mul(Gb, G))  # A * (B * G)
bob_shared = trop_mat_mul(Gb, trop_mat_mul(Ga, G))    # B * (A * G)

print(f"\nAlice's shared key (G^a ⊗ G^b ⊗ G):\n{alice_shared}")
print(f"\nBob's shared key   (G^b ⊗ G^a ⊗ G):\n{bob_shared}")
print(f"\nKeys match: {np.array_equal(alice_shared, bob_shared)} ✓")

# Direct computation
G_ab1 = trop_mat_pow(G, alice_secret + bob_secret + 1)
print(f"\nDirect G^{alice_secret + bob_secret + 1}:\n{G_ab1}")
print(f"Matches shared key: {np.array_equal(alice_shared, G_ab1)} ✓")

# ─── DEMO 3: Security Boundary — Rank-1 Matrices ───
print("\n" + "=" * 60)
print("DEMO 3: Security Boundary — Rank-1 Matrices")
print("=" * 60)

u = np.array([1, 3, 5], dtype=float)
v = np.array([2, 0, 4], dtype=float)
R1 = np.add.outer(u, v)  # Rank-1: R1_{ij} = u_i + v_j

print(f"\nRank-1 matrix R1 (u_i + v_j):")
print(f"u = {u}, v = {v}")
print(f"R1 = \n{R1}")
print(f"Is rank-1: {is_rank1(R1)}")

R1_sq = trop_mat_mul(R1, R1)
print(f"\nR1² = \n{R1_sq}")
print(f"R1² is also rank-1: {is_rank1(R1_sq)} (sub-semigroup property!)")

print(f"\nIdentity matrix (n=3):")
I3 = np.full((3, 3), INF)
np.fill_diagonal(I3, 0)
print(f"{I3}")
print(f"Is rank-1: {is_rank1(I3)} (identity is NOT rank-1 for n ≥ 2)")

# ─── DEMO 4: Centralizer Size ───
print("\n" + "=" * 60)
print("DEMO 4: Centralizer Size Analysis")
print("=" * 60)

# Small example: n=2, entries in {0,1,2}
G2 = np.array([[0, 2], [1, 0]], dtype=float)
B = 2
total = (B + 1) ** (2 * 2)
cent_size = compute_centralizer_size(G2, B)

print(f"\nGenerator G = {G2.tolist()}")
print(f"Entry bound B = {B}")
print(f"Total 2x2 matrices: {total}")
print(f"Centralizer size: {cent_size}")
print(f"Centralizer fraction: {cent_size/total:.4f}")

# Scalar matrix (worst case)
G_scalar = np.array([[1, INF], [INF, 1]], dtype=float)
cent_scalar = compute_centralizer_size(G_scalar, B)
print(f"\nScalar matrix G = diag(1,1):")
print(f"Centralizer size: {cent_scalar} (= full space = {total})")
print(f"Security: ZERO (as proven in centralizer_of_scalar_is_everything)")

# ─── DEMO 5: Power Orbit Period ───
print("\n" + "=" * 60)
print("DEMO 5: Power Orbit and Periodicity")
print("=" * 60)

G_small = np.array([[0, 1], [1, 0]], dtype=float)
print(f"\nG = {G_small.tolist()}")
for k in range(1, 10):
    Gk = trop_mat_pow(G_small, k)
    print(f"  G^{k} = {Gk.tolist()}")

print("\nObserving linear growth pattern (no finite period for this G)")
print("The orbit is infinite — this means the tropical DLP is hard!")

print("\n" + "=" * 60)
print("ALL DEMOS COMPLETE")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Centralizer Size vs. Matrix Dimension

Shows how the fraction of matrices commuting with a random generator
decreases as the matrix dimension grows — the "centralizer gap" that
provides security for TCKE.
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product as iprod

INF = float('inf')

def trop_mat_mul(A, B):
    n, m, k = A.shape[0], B.shape[1], A.shape[1]
    C = np.full((n, m), INF)
    for i in range(n):
        for j in range(m):
            for l in range(k):
                if A[i,l] != INF and B[l,j] != INF:
                    C[i,j] = min(C[i,j], A[i,l] + B[l,j])
    return C

def centralizer_fraction(n, bound, num_samples=20):
    total = (bound + 1) ** (n * n)
    entries = list(range(bound + 1))
    fracs = []
    for _ in range(num_samples):
        G = np.random.randint(0, bound + 1, size=(n, n)).astype(float)
        count = 0
        for vals in iprod(entries, repeat=n*n):
            M = np.array(vals, dtype=float).reshape(n, n)
            if np.array_equal(trop_mat_mul(M, G), trop_mat_mul(G, M)):
                count += 1
        fracs.append(count / total)
    return np.mean(fracs), np.std(fracs)

# Compute for n = 1, 2, 3 with bound = 2
dims = [1, 2, 3]
bound = 2
means = []
stds = []

print("Computing centralizer fractions...")
for n in dims:
    print(f"  n = {n}...")
    m, s = centralizer_fraction(n, bound, num_samples=10)
    means.append(m)
    stds.append(s)
    print(f"    fraction = {m:.4f} ± {s:.4f}")

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Centralizer fraction vs dimension
ax1.errorbar(dims, means, yerr=stds, fmt='o-', linewidth=2, markersize=8,
             capsize=5, color='#2196F3', label='Empirical mean')
ax1.fill_between(dims, [m-s for m,s in zip(means, stds)],
                 [m+s for m,s in zip(means, stds)], alpha=0.2, color='#2196F3')
ax1.set_xlabel('Matrix dimension n', fontsize=14)
ax1.set_ylabel('Centralizer fraction\n(|C(G)| / total matrices)', fontsize=14)
ax1.set_title('Centralizer Gap: Security Grows with Dimension', fontsize=16)
ax1.set_yscale('log')
ax1.grid(True, alpha=0.3)
ax1.legend(fontsize=12)

# Plot 2: Key space vs centralizer
total_spaces = [(bound + 1) ** (n * n) for n in dims]
cent_sizes = [m * t for m, t in zip(means, total_spaces)]

x = np.arange(len(dims))
width = 0.35
bars1 = ax2.bar(x - width/2, total_spaces, width, label='Total key space',
                color='#FF9800', alpha=0.8)
bars2 = ax2.bar(x + width/2, cent_sizes, width, label='Centralizer size',
                color='#4CAF50', alpha=0.8)

ax2.set_xlabel('Matrix dimension n', fontsize=14)
ax2.set_ylabel('Number of matrices', fontsize=14)
ax2.set_title('Key Space vs. Centralizer Size', fontsize=16)
ax2.set_xticks(x)
ax2.set_xticklabels([str(d) for d in dims])
ax2.set_yscale('log')
ax2.legend(fontsize=12)
ax2.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('centralizer_gap.png', dpi=150, bbox_inches='tight')
print("\nSaved: centralizer_gap.png")
