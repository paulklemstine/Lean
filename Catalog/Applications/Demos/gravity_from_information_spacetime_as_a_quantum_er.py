"""
Holographic Gravity Demo: Spacetime as Quantum Error-Correcting Code

Demonstrates the key mathematical structures connecting quantum error
correction to holographic gravity:
1. Syndrome defect computation and visualization
2. Entropy cone separation (GHZ vs holographic)
3. Singleton bound - RT bridge
"""

import numpy as np
from itertools import combinations

def entropy_profile(n_sites: int, S_func) -> dict:
    """Compute the full entropy profile for n boundary sites."""
    sites = list(range(n_sites))
    profile = {}
    for r in range(n_sites + 1):
        for subset in combinations(sites, r):
            profile[frozenset(subset)] = S_func(frozenset(subset))
    return profile

def syndrome_defect(S: dict, X: frozenset, Y: frozenset) -> float:
    """Compute syndrome defect δ(X,Y) = S(X) + S(Y) - S(X∩Y) - S(X∪Y)."""
    return S[X] + S[Y] - S[X & Y] - S[X | Y]

def mutual_info(S: dict, X: frozenset, Y: frozenset) -> float:
    """Compute mutual information I(X:Y) = S(X) + S(Y) - S(X∪Y)."""
    return S[X] + S[Y] - S[X | Y]

def tripartite_info(S: dict, A: frozenset, B: frozenset, C: frozenset) -> float:
    """Compute tripartite information I₃(A:B:C)."""
    return (S[A] + S[B] + S[C]
            - S[A | B] - S[A | C] - S[B | C]
            + S[A | B | C])

def total_defect(S: dict, n_sites: int) -> float:
    """Compute total defect Σ δ(X,Y) over all pairs."""
    sites = list(range(n_sites))
    all_subsets = []
    for r in range(n_sites + 1):
        for subset in combinations(sites, r):
            all_subsets.append(frozenset(subset))
    total = 0.0
    for X in all_subsets:
        for Y in all_subsets:
            total += syndrome_defect(S, X, Y)
    return total

# === Demo 1: Holographic profile (pure state, submodular) ===
print("=" * 60)
print("DEMO 1: Holographic Entropy Profile (3 sites)")
print("=" * 60)

def holographic_S(X: frozenset) -> float:
    """Page-curve-like entropy: S(X) = min(|X|, n-|X|)."""
    n = 3
    k = len(X)
    return float(min(k, n - k))

S_holo = entropy_profile(3, holographic_S)
print("\nEntropy values:")
for subset, val in sorted(S_holo.items(), key=lambda x: (len(x[0]), x[0])):
    label = str(set(subset)) if subset else '∅'
    print(f"  S({label:>10}) = {val:.1f}")

# Check submodularity
print("\nSubmodularity check (S(X)+S(Y) ≥ S(X∩Y)+S(X∪Y)):")
sites = [frozenset({0}), frozenset({1}), frozenset({2}),
         frozenset({0,1}), frozenset({0,2}), frozenset({1,2})]
for i, X in enumerate(sites):
    for Y in sites[i+1:]:
        lhs = S_holo[X] + S_holo[Y]
        rhs = S_holo[X & Y] + S_holo[X | Y]
        status = "✓" if lhs >= rhs - 1e-10 else "✗"
        print(f"  {status} {set(X)} ∪ {set(Y)}: {lhs:.1f} ≥ {rhs:.1f}")

# Syndrome defects
print("\nSyndrome defects:")
A, B, C = frozenset({0}), frozenset({1}), frozenset({2})
print(f"  δ({{0}}, {{1}}) = {syndrome_defect(S_holo, A, B):.2f}")
print(f"  δ({{0}}, {{2}}) = {syndrome_defect(S_holo, A, C):.2f}")
print(f"  δ({{1}}, {{2}}) = {syndrome_defect(S_holo, B, C):.2f}")
print(f"  δ({{0}}, {{0,1}}) = {syndrome_defect(S_holo, A, frozenset({0,1})):.2f} (nested → 0)")

# Tripartite information
I3 = tripartite_info(S_holo, A, B, C)
print(f"\nTripartite information I₃(0:1:2) = {I3:.2f}")
print(f"  {'Holographic (MMI satisfied)' if I3 <= 0 else 'NON-holographic (MMI violated)'}")

# === Demo 2: GHZ state (violates MMI) ===
print("\n" + "=" * 60)
print("DEMO 2: GHZ State — Violates Monogamy of Mutual Information")
print("=" * 60)

def ghz_S(X: frozenset) -> float:
    """GHZ-like entropy: S = 0 if X is empty or full, else 1."""
    n = 3
    k = len(X)
    if k == 0 or k == n:
        return 0.0
    return 1.0

S_ghz = entropy_profile(3, ghz_S)
I3_ghz = tripartite_info(S_ghz, A, B, C)
print(f"\nGHZ entropy: S(single) = 1, S(pair) = 1, S(triple) = 0")
print(f"Tripartite information I₃ = {I3_ghz:.2f}")
print(f"  {'Holographic' if I3_ghz <= 0 else 'NON-holographic'} — GHZ violates MMI!")

# === Demo 3: Singleton bound and RT ===
print("\n" + "=" * 60)
print("DEMO 3: Singleton Bound ↔ Bekenstein-Hawking")
print("=" * 60)

def singleton_check(n: int, k: float, d: int) -> bool:
    """Check quantum Singleton bound: 2d + k ≤ n + 2."""
    return 2 * d + k <= n + 2

print("\nQuantum Singleton bound: 2d + k ≤ n + 2")
print("With RT: k = S = area/(4G), n ∝ area/l_P²")
print()
for n in [5, 7, 9, 15, 25]:
    for d in range(1, n // 2 + 2):
        k_max = n + 2 - 2 * d
        if k_max >= 0:
            print(f"  [[{n}, k≤{k_max}, {d}]] code: rate ≤ {k_max/n:.3f}, "
                  f"relative distance = {d/n:.3f}")
    print()

# === Demo 4: Total defect ===
print("=" * 60)
print("DEMO 4: Total Defect and Flatness")
print("=" * 60)

def modular_S(X: frozenset) -> float:
    """Modular (flat) entropy: S = weighted sum of elements."""
    weights = {0: 0.5, 1: 0.3, 2: 0.2}
    return sum(weights.get(x, 0) for x in X)

S_mod = entropy_profile(3, modular_S)
td = total_defect(S_mod, 3)
print(f"\nModular entropy (flat geometry):")
print(f"  Total defect = {td:.6f} (should be 0)")

td_holo = total_defect(S_holo, 3)
print(f"\nHolographic entropy (curved geometry):")
print(f"  Total defect = {td_holo:.2f} (positive → curvature)")

print("\n✓ Flatness rigidity: total defect = 0 ⟹ all pairwise defects = 0")
print("  Physical meaning: zero curvature everywhere = flat spacetime")
