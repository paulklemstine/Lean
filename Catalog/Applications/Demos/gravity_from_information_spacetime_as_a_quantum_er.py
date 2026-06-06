#!/usr/bin/env python3
"""
demo.py — Gravity from Information: Spacetime as a Quantum Error-Correcting Code

Demonstrates the key theorems about quantum error-correcting codes and their
holographic interpretation.
"""

import math

def singleton_bound(n: int, k: int, d: int) -> bool:
    """Check if [[n, k, d]] satisfies the quantum Singleton bound."""
    return 2 * d + k <= n + 2

def singleton_deficit(n: int, k: int, d: int) -> int:
    """Compute the Singleton deficit."""
    return max(0, (n + 2) - (2 * d + k))

def is_mds(n: int, k: int, d: int) -> bool:
    """Check if a code is MDS (Maximum Distance Separable)."""
    return 2 * d + k == n + 2

def entropy(n: int, k: int) -> int:
    """Entanglement entropy S = n - k."""
    return n - k

def can_reconstruct(n: int, d: int, s: int) -> bool:
    """Can a region of size s reconstruct the bulk?"""
    return s + d > n

def bpt_bound(n: int, k: int, d: int) -> bool:
    """Check the BPT bound kd² ≤ n."""
    return k * d ** 2 <= n

def concat_params(n1, k1, d1, n2, k2, d2):
    """Concatenate two codes."""
    return n1 * n2, k1 * k2, d1 * d2


print("=" * 70)
print("GRAVITY FROM INFORMATION: KEY DEMONSTRATIONS")
print("=" * 70)

# --- Demo 1: The [[5,1,3]] code ---
print("\n--- Demo 1: The [[5,1,3]] Perfect Code ---")
n, k, d = 5, 1, 3
print(f"Code: [[{n}, {k}, {d}]]")
print(f"Singleton bound: 2d + k = {2*d+k} ≤ n + 2 = {n+2}: {singleton_bound(n,k,d)}")
print(f"MDS: {is_mds(n,k,d)}")
print(f"Entropy: S = {entropy(n,k)}")
print(f"Deficit: Δ = {singleton_deficit(n,k,d)}")
print(f"Erasure capacity: {d-1} qubits")

# --- Demo 2: Erasure phase transition ---
print("\n--- Demo 2: Erasure Phase Transition for [[5,1,3]] ---")
for s in range(n + 1):
    rec = can_reconstruct(n, d, s)
    comp_rec = can_reconstruct(n, d, n - s)
    print(f"  Region size {s}: reconstruct={rec}, complement reconstruct={comp_rec}", end="")
    if rec and not comp_rec:
        print(" ← No-cloning satisfied!")
    elif not rec and comp_rec:
        print(" ← Complement reconstructs")
    elif not rec and not comp_rec:
        print(" ← Neither reconstructs")
    else:
        print(" ← ERROR: both reconstruct (impossible for k≥1)")

# --- Demo 3: Toric code family ---
print("\n--- Demo 3: Toric Code Family [[2L², 2, L]] ---")
print(f"{'L':>3} {'n':>6} {'k':>3} {'d':>4} {'S':>6} {'Δ':>6} {'kd²':>6} {'BPT':>5} {'MDS':>5}")
print("-" * 55)
for L in range(1, 8):
    n = 2 * L ** 2
    k, d = 2, L
    S = entropy(n, k)
    delta = singleton_deficit(n, k, d)
    kd2 = k * d ** 2
    bpt = "✓" if kd2 == n else "✗"
    mds = "✓" if is_mds(n, k, d) else "✗"
    print(f"{L:3d} {n:6d} {k:3d} {d:4d} {S:6d} {delta:6d} {kd2:6d} {bpt:>5} {mds:>5}")
print(f"\nNote: kd² = n for all L (BPT saturation)")
print(f"Note: Deficit grows quadratically: Δ(L) = 2L(L-1)")

# --- Demo 4: Concatenation ---
print("\n--- Demo 4: Concatenation ---")
codes = [
    ("[[5,1,3]]", 5, 1, 3),
    ("[[7,1,3]]", 7, 1, 3),
    ("[[5,1,3]]⊗[[5,1,3]]", *concat_params(5,1,3,5,1,3)),
    ("[[5,1,3]]⊗[[7,1,3]]", *concat_params(5,1,3,7,1,3)),
]
for name, n, k, d in codes:
    valid = singleton_bound(n, k, d)
    delta = singleton_deficit(n, k, d)
    print(f"  {name:25s}: [[{n},{k},{d}]], valid={valid}, Δ={delta}")

# Counterexample
print("\n  Counterexample (k=0):")
n, k, d = concat_params(2, 0, 2, 2, 0, 2)
print(f"  [[2,0,2]]⊗[[2,0,2]] = [[{n},{k},{d}]]")
print(f"  2d + k = {2*d+k}, n + 2 = {n+2}: valid = {singleton_bound(n,k,d)}")
print(f"  ⟹ Concatenation FAILS Singleton when k=0!")

# --- Demo 5: BPT implies Singleton ---
print("\n--- Demo 5: BPT implies Singleton ---")
print("Testing: if kd² ≤ n, k ≥ 1, d ≥ 1 → 2d + k ≤ n + 2")
test_cases = [(10, 2, 3), (20, 2, 3), (50, 5, 3), (100, 4, 5), (8, 2, 2)]
for n, k, d in test_cases:
    bpt_ok = bpt_bound(n, k, d)
    sing_ok = singleton_bound(n, k, d)
    print(f"  [[{n},{k},{d}]]: BPT={bpt_ok}, Singleton={sing_ok}", end="")
    if bpt_ok and not sing_ok:
        print(" ← BPT but not Singleton! (impossible by theorem)")
    elif bpt_ok:
        print(" ← BPT ⟹ Singleton ✓")
    else:
        print()

# --- Demo 6: Bekenstein-Hawking as Singleton ---
print("\n--- Demo 6: Bekenstein-Hawking as Singleton Maximum ---")
print("For MDS codes: S = n - 2d + 2 = A/ℓ_P² - L/ℓ_P + 2")
lP = 1.0  # Planck length in natural units
G = lP ** 2 / 4  # 4G = ℓ_P²
for L_geod in [2.0, 4.0, 6.0, 10.0]:
    for A in [10.0, 50.0, 100.0]:
        n_planck = A / lP ** 2
        d_code = L_geod / (2 * lP)
        S_BH = A / (4 * G)
        S_singleton = n_planck - 2 * d_code + 2
        if S_singleton >= 0 and abs(S_BH - S_singleton) < 1e-10:
            print(f"  A={A:5.0f}, L={L_geod:4.1f}: S_BH={S_BH:8.1f}, S_Singleton={S_singleton:8.1f} ← MATCH (MDS)")

# --- Demo 7: Syndrome defect ---
print("\n--- Demo 7: Syndrome Defect as Curvature ---")
print("For submodular entropy S, defect(X,Y) = S(X) + S(Y) - S(X∩Y) - S(X∪Y)")
print("Zero defect = flat geometry, positive defect = curvature")
print()
print("Example: 4-qubit system with S({i}) = 1, S({i,j}) = 1.5, S({i,j,k}) = 1.8")
S = {
    frozenset(): 0,
    frozenset({1}): 1, frozenset({2}): 1, frozenset({3}): 1, frozenset({4}): 1,
    frozenset({1,2}): 1.5, frozenset({1,3}): 1.5, frozenset({1,4}): 1.5,
    frozenset({2,3}): 1.5, frozenset({2,4}): 1.5, frozenset({3,4}): 1.5,
    frozenset({1,2,3}): 1.8, frozenset({1,2,4}): 1.8,
    frozenset({1,3,4}): 1.8, frozenset({2,3,4}): 1.8,
    frozenset({1,2,3,4}): 2.0
}
for X_set, Y_set in [({1,2}, {2,3}), ({1}, {2}), ({1,2}, {3,4}), ({1,2,3}, {2,3,4})]:
    X, Y = frozenset(X_set), frozenset(Y_set)
    inter = X & Y
    union = X | Y
    defect = S[X] + S[Y] - S[inter] - S[union]
    print(f"  defect({set(X)}, {set(Y)}) = {S[X]:.1f} + {S[Y]:.1f} - {S[inter]:.1f} - {S[union]:.1f} = {defect:.2f}",
          "← flat" if abs(defect) < 1e-10 else "← curved")

print("\n" + "=" * 70)
print("All demonstrations complete.")


#!/usr/bin/env python3
"""
Visualization: Singleton Deficit as Curvature

Shows how the deficit (= curvature) grows for the toric code family and
compares with the MDS (flat) HaPPY codes.
"""

import matplotlib.pyplot as plt
import numpy as np


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Deficit growth
ax = axes[0]
Ls = np.arange(1, 15)
toric_deficits = [max(0, 2 * L ** 2 - 2 * L) for L in Ls]
happy_deficits = [0 for L in Ls]  # HaPPY L=0 is MDS, others have deficit

# HaPPY deficit for L > 0: n=5(L+1), k=L+1, d=3
# 2*3 + (L+1) = 7+L, n+2 = 5L+7, deficit = 5L+7 - 7 - L = 4L
happy_deficits_actual = [4 * L for L in Ls]

ax.plot(Ls, toric_deficits, 'o-', color='#E91E63', linewidth=2, markersize=6,
        label='Toric [[2L²,2,L]]: Δ=2L(L-1)')
ax.plot(Ls, happy_deficits_actual, 's-', color='#4CAF50', linewidth=2, markersize=6,
        label='HaPPY [[5(L+1),L+1,3]]: Δ=4L')
ax.axhline(y=0, color='gray', linestyle=':', alpha=0.5)
ax.set_xlabel('Scale parameter L', fontsize=12)
ax.set_ylabel('Singleton Deficit Δ (= Curvature)', fontsize=12)
ax.set_title('Deficit Growth: Quadratic vs Linear', fontsize=14)
ax.legend(fontsize=10)

# Right: BPT bound visualization
ax = axes[1]
ns = np.arange(1, 100)
for k in [1, 2, 4]:
    max_d = np.sqrt(ns / k)
    ax.plot(ns, max_d, '-', linewidth=2, label=f'k={k}: d ≤ √(n/{k})')

# Mark specific codes
codes = {
    '[[5,1,3]]': (5, 3),
    '[[8,2,2]]': (8, 2),
    '[[18,2,3]]': (18, 3),
    '[[32,2,4]]': (32, 4),
    '[[50,2,5]]': (50, 5),
}
for name, (n, d) in codes.items():
    ax.plot(n, d, 'ko', markersize=8)
    ax.annotate(name, (n, d), textcoords="offset points", xytext=(5, 5), fontsize=8)

ax.set_xlabel('n (physical qubits)', fontsize=12)
ax.set_ylabel('d (code distance)', fontsize=12)
ax.set_title('BPT Bound: d ≤ √(n/k)', fontsize=14)
ax.legend(fontsize=10)
ax.set_xlim(0, 100)
ax.set_ylim(0, 12)

plt.tight_layout()
plt.savefig('deficit_curvature.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: deficit_curvature.png")


#!/usr/bin/env python3
"""
Visualization: Erasure Phase Transition in Holographic Codes

Shows the sharp reconstruction threshold for the [[5,1,3]] and toric code families.
"""

import matplotlib.pyplot as plt
import numpy as np


def can_reconstruct(n, d, s):
    return s + d > n


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: [[5,1,3]] code
ax = axes[0]
n, k, d = 5, 1, 3
sizes = np.arange(0, n + 1)
rec = [1 if can_reconstruct(n, d, s) else 0 for s in sizes]
comp_rec = [1 if can_reconstruct(n, d, n - s) else 0 for s in sizes]

ax.bar(sizes - 0.15, rec, 0.3, label='Region reconstructs', color='#2196F3', alpha=0.8)
ax.bar(sizes + 0.15, comp_rec, 0.3, label='Complement reconstructs', color='#FF5722', alpha=0.8)
ax.axvline(x=n - d + 0.5, color='green', linestyle='--', linewidth=2, label=f'Threshold (s={n-d+1})')
ax.set_xlabel('Region size s', fontsize=12)
ax.set_ylabel('Can reconstruct?', fontsize=12)
ax.set_title('[[5,1,3]] Erasure Phase Transition', fontsize=14)
ax.set_xticks(sizes)
ax.set_yticks([0, 1])
ax.set_yticklabels(['No', 'Yes'])
ax.legend(fontsize=10)
ax.set_xlim(-0.5, n + 0.5)

# Right: Toric code threshold fraction
ax = axes[1]
Ls = np.arange(1, 20)
threshold_fracs = [(2 * L ** 2 - L + 1) / (2 * L ** 2) for L in Ls]

ax.plot(Ls, threshold_fracs, 'o-', color='#9C27B0', linewidth=2, markersize=6)
ax.axhline(y=1.0, color='gray', linestyle=':', alpha=0.5)
ax.axhline(y=0.5, color='gray', linestyle=':', alpha=0.5, label='50% threshold')
ax.set_xlabel('Grid size L', fontsize=12)
ax.set_ylabel('Threshold fraction (s₀/n)', fontsize=12)
ax.set_title('Toric Code: Threshold Fraction → 1', fontsize=14)
ax.legend(fontsize=10)
ax.set_ylim(0.4, 1.05)

plt.tight_layout()
plt.savefig('phase_transition.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: phase_transition.png")
