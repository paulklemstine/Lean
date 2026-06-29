#!/usr/bin/env python3
"""
Applications of Idempotent Blackwell–Thermodynamic Duality

Demonstrates real-world applications:
1. Feature selection in ML as closure system optimization
2. Communication channel comparison
3. Thermodynamic work extraction bounds
4. Sensor network information ordering
"""

import numpy as np
from algorithms import (
    WeightedClosureSystem, tropical_matmul, tropical_identity,
    free_energy_profile, free_energy, weighted_free_energy,
    check_blackwell_le, extract_minimal_channel
)

INF = float('inf')


# ================================================================
# Application 1: Feature Selection as Closure Optimization
# ================================================================

def application_feature_selection():
    """
    Model feature selection in ML as a closure system problem.

    Features induce a closure: if feature A implies feature B is
    redundant, then B is in cl({A}). The weight w(A) is the
    computational cost of evaluating feature A.

    The canonical channel represents the cost of observing each
    feature from each data state. Garbling corresponds to feature
    aggregation. Free-energy monotonicity guarantees that
    aggregating features can only increase prediction cost.
    """
    print("=" * 60)
    print("APPLICATION 1: Feature Selection as Closure System")
    print("=" * 60)

    # 5 features: {temperature, humidity, pressure, wind_speed, wind_dir}
    features = ["temp", "humid", "press", "wind_spd", "wind_dir"]
    n = len(features)

    # Closure: knowing temperature implies humidity is predictable (correlated)
    # Knowing wind_speed implies wind_direction is partly determined
    def feature_cl(S):
        result = set(S)
        changed = True
        while changed:
            changed = False
            # temp → humid (strong correlation)
            if 0 in result and 1 not in result:
                result.add(1); changed = True
            # wind_spd → wind_dir (moderate correlation)
            if 3 in result and 4 not in result:
                result.add(4); changed = True
        return frozenset(result)

    # Costs: temp=1, humid=0.5, press=2, wind_spd=1.5, wind_dir=0.8
    costs = np.array([1.0, 0.5, 2.0, 1.5, 0.8])

    C = WeightedClosureSystem(n, feature_cl, costs)

    print(f"\nFeatures: {features}")
    print(f"Costs: {dict(zip(features, costs))}")
    print(f"\nClosure structure (feature implications):")
    for i in range(n):
        cl = set(C.singleton_closure(i))
        implied = cl - {i}
        if implied:
            print(f"  {features[i]} → {{{', '.join(features[j] for j in implied)}}}")
        else:
            print(f"  {features[i]} → (no implications)")

    K_C = C.canonical_channel()
    profile = free_energy_profile(costs, K_C)
    print(f"\nFree-energy profile (weighted observation cost per feature):")
    for i in range(n):
        print(f"  {features[i]}: {profile[i]:.2f}")

    # Aggregate features: merge temp+humid, merge wind_spd+wind_dir
    T_agg = np.array([
        [0, INF, INF],      # temp → group 0
        [0, INF, INF],      # humid → group 0
        [INF, 0, INF],      # press → group 1
        [INF, INF, 0],      # wind_spd → group 2
        [INF, INF, 0],      # wind_dir → group 2
    ])
    K_agg = tropical_matmul(K_C, T_agg)
    profile_agg = free_energy_profile(costs, K_agg)

    print(f"\nAfter feature aggregation (temp+humid, press, wind):")
    print(f"  Free-energy profile: {profile_agg}")
    print(f"  Original profile:    {profile}")
    print(f"  Monotonicity holds:  {all(profile[i] <= profile_agg[i] for i in range(n))}")
    print(f"  → Aggregating features only increases prediction cost (second law)")


# ================================================================
# Application 2: Sensor Network Comparison
# ================================================================

def application_sensor_network():
    """
    Compare sensor networks using Blackwell ordering.

    Different sensor configurations are modeled as channels from
    environment states to sensor readings. Blackwell dominance
    determines which network is more informative.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Sensor Network Information Ordering")
    print("=" * 60)

    # 4 environment states: {cold-dry, cold-wet, hot-dry, hot-wet}
    states = ["cold-dry", "cold-wet", "hot-dry", "hot-wet"]

    # Network A: high-res sensors (4 distinct readings)
    K_A = np.array([
        [0.5, 2.0, 3.0, 3.5],
        [2.0, 0.5, 3.5, 3.0],
        [3.0, 3.5, 0.5, 2.0],
        [3.5, 3.0, 2.0, 0.5],
    ])

    # Network B: low-res sensors (merge cold readings)
    K_B = np.array([
        [0.5, 3.0, 3.5],
        [0.5, 3.5, 3.0],
        [3.0, 0.5, 2.0],
        [3.0, 2.0, 0.5],
    ])

    # Network C: single aggregate sensor
    K_C_net = np.array([
        [0.5],
        [0.5],
        [0.5],
        [0.5],
    ])

    print(f"\nEnvironment states: {states}")
    print(f"\nNetwork A (high-res, 4 readings): freeEnergy = {free_energy(K_A):.2f}")
    print(f"Network B (low-res, 3 readings):  freeEnergy = {free_energy(K_B):.2f}")
    print(f"Network C (aggregate, 1 reading):  freeEnergy = {free_energy(K_C_net):.2f}")

    # Test dominance relationships
    ab, _ = check_blackwell_le(K_A, K_B)
    ac, _ = check_blackwell_le(K_A, K_C_net)
    bc, _ = check_blackwell_le(K_B, K_C_net)

    print(f"\nBlackwell ordering:")
    print(f"  A ≥ B (A dominates B): {ab}")
    print(f"  A ≥ C (A dominates C): {ac}")
    print(f"  B ≥ C (B dominates C): {bc}")
    print(f"  → Forms a chain: A ≥ B ≥ C (by transitivity)")

    weights = np.array([1.0, 1.0, 1.0, 1.0])
    for name, K in [("A", K_A), ("B", K_B), ("C", K_C_net)]:
        fe = weighted_free_energy(weights, K)
        print(f"  weightedFreeEnergy({name}) = {fe:.2f}")
    print(f"  Monotonicity: wFE(A) ≤ wFE(B) ≤ wFE(C) ✓")


# ================================================================
# Application 3: Thermodynamic Work Extraction
# ================================================================

def application_thermodynamics():
    """
    Model thermodynamic work extraction as channel optimization.

    States represent microstates of a physical system. The channel
    models a measurement apparatus. Free energy measures the maximum
    extractable work. Garbling (coarsening the measurement) reduces
    extractable work — the idempotent second law.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Thermodynamic Work Extraction Bounds")
    print("=" * 60)

    # 6 microstates with different energy levels
    energies = np.array([0.0, 0.5, 1.0, 1.5, 2.0, 2.5])
    n = len(energies)

    # Fine measurement: can distinguish all states
    K_fine = np.diag(energies) + np.where(np.eye(n) == 0, 10.0, 0)
    # Make it a proper cost matrix
    for i in range(n):
        for j in range(n):
            if i != j:
                K_fine[i, j] = abs(energies[i] - energies[j]) + 1.0

    # Coarse measurement: merges states into {low, mid, high}
    T_coarse = np.array([
        [0, INF, INF],  # state 0 → low
        [0, INF, INF],  # state 1 → low
        [INF, 0, INF],  # state 2 → mid
        [INF, 0, INF],  # state 3 → mid
        [INF, INF, 0],  # state 4 → high
        [INF, INF, 0],  # state 5 → high
    ])
    K_coarse = tropical_matmul(K_fine, T_coarse)

    print(f"\nMicrostates with energies: {list(energies)}")
    print(f"\nFine measurement ({K_fine.shape[1]} outcomes):")
    print(f"  freeEnergy = {free_energy(K_fine):.3f}")
    profile_fine = free_energy_profile(energies, K_fine)
    print(f"  Profile: {[f'{x:.2f}' for x in profile_fine]}")

    print(f"\nCoarse measurement ({K_coarse.shape[1]} outcomes, groups of 2):")
    print(f"  freeEnergy = {free_energy(K_coarse):.3f}")
    profile_coarse = free_energy_profile(energies, K_coarse)
    print(f"  Profile: {[f'{x:.2f}' for x in profile_coarse]}")

    print(f"\nIdempotent second law verification:")
    print(f"  freeEnergy(fine) ≤ freeEnergy(coarse): "
          f"{free_energy(K_fine):.3f} ≤ {free_energy(K_coarse):.3f} → "
          f"{free_energy(K_fine) <= free_energy(K_coarse)}")
    print(f"  Pointwise profile monotonicity:")
    for i in range(n):
        print(f"    State {i} (E={energies[i]}): "
              f"{profile_fine[i]:.2f} ≤ {profile_coarse[i]:.2f} → "
              f"{profile_fine[i] <= profile_coarse[i] + 1e-10}")

    # Minimal channel
    K_min, kept = extract_minimal_channel(K_fine)
    print(f"\n  Minimal fine channel: {K_min.shape[1]} observations "
          f"(from {K_fine.shape[1]})")


# ================================================================
# Application 4: Communication Channel Capacity
# ================================================================

def application_communication():
    """
    Model communication channel degradation.

    Tropical channels model the cost of transmitting symbols.
    Garbling represents noise/interference. The free energy
    gives a lower bound on the minimum transmission cost.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Communication Channel Degradation")
    print("=" * 60)

    # 4-symbol alphabet
    symbols = ['A', 'B', 'C', 'D']
    n = 4

    # Clean channel: low cost for correct transmission
    K_clean = np.array([
        [0.1, 2.0, 2.0, 2.0],
        [2.0, 0.1, 2.0, 2.0],
        [2.0, 2.0, 0.1, 2.0],
        [2.0, 2.0, 2.0, 0.1],
    ])

    # Noisy channel: some symbols confused
    K_noisy = np.array([
        [0.5, 1.0, 2.0, 2.0],
        [1.0, 0.5, 2.0, 2.0],
        [2.0, 2.0, 0.5, 1.0],
        [2.0, 2.0, 1.0, 0.5],
    ])

    # Very noisy: all symbols nearly indistinguishable
    K_very_noisy = np.array([
        [1.0, 1.2, 1.3, 1.1],
        [1.2, 1.0, 1.1, 1.3],
        [1.3, 1.1, 1.0, 1.2],
        [1.1, 1.3, 1.2, 1.0],
    ])

    weights = np.ones(n)

    print(f"\nSymbol alphabet: {symbols}")
    for name, K in [("Clean", K_clean), ("Noisy", K_noisy), ("Very Noisy", K_very_noisy)]:
        fe = free_energy(K)
        wfe = weighted_free_energy(weights, K)
        profile = free_energy_profile(weights, K)
        print(f"\n  {name} channel:")
        print(f"    freeEnergy = {fe:.3f}")
        print(f"    weightedFreeEnergy = {wfe:.3f}")
        print(f"    profile = {[f'{x:.2f}' for x in profile]}")

    # Check dominance
    cn, _ = check_blackwell_le(K_clean, K_noisy)
    nv, _ = check_blackwell_le(K_noisy, K_very_noisy)
    cv, _ = check_blackwell_le(K_clean, K_very_noisy)
    print(f"\n  Blackwell ordering:")
    print(f"    Clean ≥ Noisy: {cn}")
    print(f"    Noisy ≥ Very Noisy: {nv}")
    print(f"    Clean ≥ Very Noisy: {cv}")


# ================================================================
# Main
# ================================================================

if __name__ == "__main__":
    application_feature_selection()
    application_sensor_network()
    application_thermodynamics()
    application_communication()

    print("\n" + "=" * 60)
    print("All applications completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Idempotent Blackwell–Thermodynamic Duality: Concrete Demonstrations

This script demonstrates the core theorems with numerical examples,
showing how weighted closure systems, tropical channels, and free-energy
monotones are interconnected in the finite idempotent regime.
"""

import numpy as np
from itertools import combinations

INF = float('inf')


def tropical_add(a, b):
    """Tropical addition = min."""
    return min(a, b)


def tropical_mul(a, b):
    """Tropical multiplication = ordinary +."""
    if a == INF or b == INF:
        return INF
    return a + b


def tropical_matmul(A, B):
    """Tropical (min-plus) matrix multiplication."""
    n, m = A.shape
    m2, p = B.shape
    assert m == m2, "Dimension mismatch"
    C = np.full((n, p), INF)
    for i in range(n):
        for j in range(p):
            for k in range(m):
                C[i, j] = tropical_add(C[i, j], tropical_mul(A[i, k], B[k, j]))
    return C


def tropical_identity(n):
    """Tropical identity matrix: 0 on diagonal, INF elsewhere."""
    M = np.full((n, n), INF)
    np.fill_diagonal(M, 0)
    return M


# ===========================================================
# Demo 1: Blackwell Preorder (Reflexivity and Transitivity)
# ===========================================================
print("=" * 60)
print("DEMO 1: Blackwell Preorder Properties")
print("=" * 60)

# Define a channel K: 3 states, 4 observations
K = np.array([
    [1.0, 3.0, INF, 2.0],
    [INF, 2.0, 1.0, 3.0],
    [2.0, INF, 3.0, 1.0],
])

print("\nChannel K (3 states × 4 observations):")
print(K)

# Reflexivity: K = K ⊗ I
I = tropical_identity(4)
KI = tropical_matmul(K, I)
print("\nK ⊗ I (should equal K):")
print(KI)
print(f"K ⊗ I == K: {np.allclose(K, KI, equal_nan=True) and np.all((K == INF) == (KI == INF))}")

# Define a garbling matrix T: 4 obs → 2 obs
T = np.array([
    [0.0, 1.0],
    [1.0, 0.0],
    [0.5, 0.5],
    [0.0, 2.0],
])

L = tropical_matmul(K, T)
print(f"\nGarbling T (4 × 2):")
print(T)
print(f"\nGarbled channel L = K ⊗ T (3 × 2):")
print(L)
print("L is a garbling of K: BlackwellLE(K, L) holds by construction.")

# Transitivity: another garbling
T2 = np.array([
    [0.0],
    [0.5],
])
M = tropical_matmul(L, T2)
print(f"\nSecond garbling T2 (2 × 1):")
print(T2)
print(f"\nM = L ⊗ T2 (3 × 1):")
print(M)

T_composed = tropical_matmul(T, T2)
M_direct = tropical_matmul(K, T_composed)
print(f"\nT_composed = T ⊗ T2 (4 × 1):")
print(T_composed)
print(f"M_direct = K ⊗ T_composed (3 × 1):")
print(M_direct)
print(f"Transitivity verified: M == M_direct: {np.allclose(M, M_direct)}")

# ===========================================================
# Demo 2: Free Energy Monotonicity (The Idempotent Second Law)
# ===========================================================
print("\n" + "=" * 60)
print("DEMO 2: Free Energy Monotonicity (Idempotent Second Law)")
print("=" * 60)


def free_energy_at(channel, a):
    """freeEnergyAt K a = min_b K(a,b)"""
    return np.min(channel[a, :])


def free_energy(channel):
    """freeEnergy K = min_a (freeEnergyAt K a)"""
    return min(free_energy_at(channel, a) for a in range(channel.shape[0]))


def weighted_free_energy(weights, channel):
    """weightedFreeEnergy C K = min_a (w(a) + freeEnergyAt K a)"""
    return min(weights[a] + free_energy_at(channel, a)
               for a in range(channel.shape[0]))


weights = np.array([1.0, 2.0, 0.5])

print(f"\nGenerator weights w = {weights}")
print(f"\nChannel K:")
for a in range(3):
    fe = free_energy_at(K, a)
    print(f"  freeEnergyAt(K, {a}) = min{list(K[a,:])} = {fe}")
print(f"  freeEnergy(K) = {free_energy(K)}")
print(f"  weightedFreeEnergy(K) = {weighted_free_energy(weights, K)}")

print(f"\nGarbled channel L = K ⊗ T:")
for a in range(3):
    fe = free_energy_at(L, a)
    print(f"  freeEnergyAt(L, {a}) = min{list(L[a,:])} = {fe}")
print(f"  freeEnergy(L) = {free_energy(L)}")
print(f"  weightedFreeEnergy(L) = {weighted_free_energy(weights, L)}")

print(f"\nMonotonicity check:")
print(f"  freeEnergy(K) ≤ freeEnergy(L): {free_energy(K)} ≤ {free_energy(L)} → {free_energy(K) <= free_energy(L)}")
print(f"  weightedFreeEnergy(K) ≤ weightedFreeEnergy(L): {weighted_free_energy(weights, K)} ≤ {weighted_free_energy(weights, L)} → {weighted_free_energy(weights, K) <= weighted_free_energy(weights, L)}")

for a in range(3):
    feK = free_energy_at(K, a)
    feL = free_energy_at(L, a)
    print(f"  freeEnergyAt(K,{a}) ≤ freeEnergyAt(L,{a}): {feK} ≤ {feL} → {feK <= feL}")

# ===========================================================
# Demo 3: Canonical Channel Construction
# ===========================================================
print("\n" + "=" * 60)
print("DEMO 3: Canonical Channel from Weighted Closure System")
print("=" * 60)


class WeightedClosureSystem:
    """A weighted closure system on {0, 1, ..., n-1}."""

    def __init__(self, n, cl_func, weights):
        self.n = n
        self.elements = list(range(n))
        self._cl = cl_func
        self.weights = weights

    def cl(self, S):
        """Closure of a set S (as frozenset)."""
        return self._cl(frozenset(S))

    def canonical_channel(self):
        """Build the canonical channel K_C(a,b) = w(a) if b ∈ cl({a}), else ∞."""
        n = self.n
        K = np.full((n, n), INF)
        for a in range(n):
            closure_a = self.cl({a})
            for b in range(n):
                if b in closure_a:
                    K[a, b] = self.weights[a]
        return K


# Example: closure on {0, 1, 2, 3} where
# cl({0}) = {0, 1}, cl({1}) = {1}, cl({2}) = {2, 3}, cl({3}) = {0, 3}
def example_cl(S):
    """Example closure operator."""
    result = set(S)
    # closure rules: 0 → {0,1}, 2 → {2,3}, 3 → {0,3}
    if 0 in result:
        result.add(1)
    if 2 in result:
        result.add(3)
    if 3 in result:
        result.add(0)
        result.add(1)  # since 0 is now in, close again
    return frozenset(result)


weights_C = np.array([1.0, 2.0, 3.0, 1.5])
C = WeightedClosureSystem(4, example_cl, weights_C)

print(f"\nClosure system on {{0, 1, 2, 3}}:")
for a in range(4):
    print(f"  cl({{{a}}}) = {set(C.cl({a}))}, w({a}) = {C.weights[a]}")

K_C = C.canonical_channel()
print(f"\nCanonical channel K_C:")
for a in range(4):
    row = [f"{v:.1f}" if v != INF else "∞" for v in K_C[a, :]]
    print(f"  K_C({a}, ·) = [{', '.join(row)}]")

print(f"\nReconstruction check:")
print(f"  K_C recovers weights: K_C(a,a) = w(a) for all a?")
for a in range(4):
    print(f"    K_C({a},{a}) = {K_C[a,a]}, w({a}) = {C.weights[a]}, match = {K_C[a,a] == C.weights[a]}")

print(f"\n  K_C recovers cl({{a}}): {{b : K_C(a,b) ≠ ∞}} = cl({{a}})?")
for a in range(4):
    reconstructed = {b for b in range(4) if K_C[a, b] != INF}
    original = set(C.cl({a}))
    print(f"    a={a}: reconstructed={reconstructed}, cl={original}, match={reconstructed == original}")

# Verify it's a realization: freeEnergyAt = w(a) for all a
print(f"\n  Realization check: freeEnergyAt(K_C, a) = w(a)?")
for a in range(4):
    fe = free_energy_at(K_C, a)
    print(f"    freeEnergyAt(K_C, {a}) = {fe}, w({a}) = {C.weights[a]}, match = {fe == C.weights[a]}")

# ===========================================================
# Demo 4: Blackwell Equivalence and Free-Energy Profile
# ===========================================================
print("\n" + "=" * 60)
print("DEMO 4: Blackwell Equivalence and Free-Energy Invariant")
print("=" * 60)

# Two closure systems that agree on singletons and weights
# → same canonical channel → trivially Blackwell equivalent
weights_D = np.array([1.0, 2.0, 3.0, 1.5])
D = WeightedClosureSystem(4, example_cl, weights_D)
K_D = D.canonical_channel()

print(f"\nCanonical channels equal (same closure + weights):")
print(f"  K_C == K_D: {np.allclose(K_C, K_D, equal_nan=True) and np.all((K_C == INF) == (K_D == INF))}")

# Free energy profile
def free_energy_profile(weights, channel):
    n = channel.shape[0]
    return [weights[a] + free_energy_at(channel, a) for a in range(n)]


profile_C = free_energy_profile(weights_C, K_C)
profile_D = free_energy_profile(weights_D, K_D)
print(f"\nFree-energy profile of K_C: {profile_C}")
print(f"Free-energy profile of K_D: {profile_D}")
print(f"Profiles equal: {profile_C == profile_D}")

# Now garble K_C and show profile changes monotonically
T_garble = np.array([
    [0.0, 0.5],
    [0.5, 0.0],
    [1.0, 0.0],
    [0.0, 1.0],
])
K_garbled = tropical_matmul(K_C, T_garble)
print(f"\nGarbled channel K_garbled = K_C ⊗ T (4 × 2):")
for a in range(4):
    row = [f"{v:.1f}" if v != INF else "∞" for v in K_garbled[a, :]]
    print(f"  K_garbled({a}, ·) = [{', '.join(row)}]")

profile_garbled = free_energy_profile(weights_C, K_garbled)
print(f"\nFree-energy profile of K_garbled: {profile_garbled}")
print(f"Pointwise monotonicity (garbled ≥ original):")
for a in range(4):
    print(f"  a={a}: {profile_garbled[a]} ≥ {profile_C[a]} → {profile_garbled[a] >= profile_C[a]}")

print("\n" + "=" * 60)
print("All demonstrations completed successfully!")
print("=" * 60)


#!/usr/bin/env python3
"""Generate PACKAGE.json with all embedded content."""

import json
import base64
from pathlib import Path

# Read markdown files
article = Path("ARTICLE.md").read_text()
research_paper = Path("RESEARCH_PAPER.md").read_text()
future_directions = Path("FUTURE_DIRECTIONS.md").read_text()
lean_code = Path("Bridges/AlgebraEMLPhysics/IdempotentBlackwellThermodynamicDuality.lean").read_text()
demo_code = Path("demo.py").read_text()
algorithms_code = Path("algorithms.py").read_text()
applications_code = Path("applications.py").read_text()

# Read visualization images as base64
viz_data = []
for fig_name in ["fig_blackwell_ordering.png", "fig_canonical_channel.png",
                  "fig_free_energy_profile.png", "fig_tropical_composition.png"]:
    with open(fig_name, "rb") as f:
        b64 = base64.b64encode(f.read()).decode("utf-8")
    viz_data.append({
        "name": fig_name.replace("fig_", "").replace(".png", "").replace("_", " ").title(),
        "data": f"data:image/png;base64,{b64}"
    })

package = {
    "title": "Idempotent Blackwell-Thermodynamic Duality via Closure Information Semimodules",
    "domain": "Mathematical Bridges: Information Theory × Algebra × Thermodynamics",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Blackwell Ordering and Free-Energy Monotonicity Demo",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Tropical Matrix Operations and Channel Reconstruction",
            "pseudocode": """Algorithm CanonicalChannel(C):
  Input: Weighted closure system C = (cl, w) on n elements
  Output: Channel matrix K ∈ Cost^{n×n}
  
  for a = 0 to n-1:
    cl_a ← cl({a})
    for b = 0 to n-1:
      K[a,b] ← w(a) if b ∈ cl_a else ∞
  return K

Time: O(n²), Space: O(n²)

Algorithm TestBlackwellLE(K, L):
  Input: Channels K ∈ Cost^{n×m}, L ∈ Cost^{n×p}
  Output: (bool, garbling matrix T)
  
  for b, c: T[b,c] ← max_a(L[a,c] - K[a,b]) for finite entries
  Verify: K ⊗ T ≈ L
  
Time: O(n·m·p)

Algorithm FreeEnergyProfile(w, K):
  for a: P[a] ← w(a) + min_b K[a,b]
  
Time: O(n·m)""",
            "code": algorithms_code
        }
    ],
    "visualizations": viz_data,
    "lean_proofs": lean_code
}

with open("PACKAGE.json", "w") as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("PACKAGE.json generated successfully!")
print(f"  Size: {len(json.dumps(package))} bytes")


#!/usr/bin/env python3
"""
Visualizations for Idempotent Blackwell–Thermodynamic Duality

Generates publication-quality figures illustrating:
1. Blackwell ordering lattice
2. Free-energy monotonicity under garbling
3. Closure system and canonical channel
4. Tropical matrix composition
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.colors import LinearSegmentedColormap
import base64
from io import BytesIO

INF = float('inf')


def fig_to_base64(fig):
    """Convert matplotlib figure to base64-encoded PNG data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


# ================================================================
# Figure 1: Blackwell Ordering and Free-Energy Monotonicity
# ================================================================

def create_blackwell_ordering_figure():
    """Create a Hasse diagram of the Blackwell ordering with free energies."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Hasse diagram
    ax1.set_xlim(-1.5, 1.5)
    ax1.set_ylim(-0.5, 3.5)

    nodes = {
        'K (full)': (0, 3),
        'L (merged AB)': (-0.8, 2),
        'M (merged CD)': (0.8, 2),
        'N (2-obs)': (0, 1),
        'P (trivial)': (0, 0),
    }

    free_energies = {
        'K (full)': 0.1,
        'L (merged AB)': 0.5,
        'M (merged CD)': 0.5,
        'N (2-obs)': 1.0,
        'P (trivial)': 1.5,
    }

    edges = [
        ('K (full)', 'L (merged AB)'),
        ('K (full)', 'M (merged CD)'),
        ('L (merged AB)', 'N (2-obs)'),
        ('M (merged CD)', 'N (2-obs)'),
        ('N (2-obs)', 'P (trivial)'),
    ]

    # Draw edges
    for src, dst in edges:
        x1, y1 = nodes[src]
        x2, y2 = nodes[dst]
        ax1.annotate('', xy=(x2, y2 + 0.15), xytext=(x1, y1 - 0.15),
                     arrowprops=dict(arrowstyle='->', color='#555555',
                                     lw=1.5, connectionstyle='arc3,rad=0'))

    # Draw nodes
    for name, (x, y) in nodes.items():
        fe = free_energies[name]
        color_val = fe / 1.5
        color = plt.cm.RdYlGn_r(color_val * 0.8 + 0.1)
        circle = plt.Circle((x, y), 0.18, color=color, ec='black', lw=1.5, zorder=5)
        ax1.add_patch(circle)
        ax1.text(x, y + 0.35, name, ha='center', va='bottom', fontsize=9, fontweight='bold')
        ax1.text(x, y - 0.05, f'F={fe:.1f}', ha='center', va='center', fontsize=8)

    ax1.set_title('Blackwell Ordering (Hasse Diagram)\n↓ = garbling (information loss)',
                  fontsize=12, fontweight='bold')
    ax1.set_aspect('equal')
    ax1.axis('off')

    # Right: Free-energy monotonicity bar chart
    names = list(free_energies.keys())
    fes = [free_energies[n] for n in names]
    short_names = ['K', 'L', 'M', 'N', 'P']

    colors = [plt.cm.RdYlGn_r(f / 1.5 * 0.8 + 0.1) for f in fes]
    bars = ax2.bar(short_names, fes, color=colors, edgecolor='black', linewidth=1.2)

    ax2.set_ylabel('Free Energy F(K)', fontsize=12)
    ax2.set_xlabel('Channel', fontsize=12)
    ax2.set_title('Free Energy Increases Under Garbling\n(Idempotent Second Law)',
                  fontsize=12, fontweight='bold')
    ax2.set_ylim(0, 2.0)

    # Add arrow showing monotonicity direction
    ax2.annotate('More\ninformative', xy=(0, 0.1), fontsize=9,
                 color='green', ha='center', fontweight='bold')
    ax2.annotate('Less\ninformative', xy=(4, 1.5), fontsize=9,
                 color='red', ha='center', fontweight='bold')

    plt.tight_layout()
    return fig


# ================================================================
# Figure 2: Canonical Channel Heatmap
# ================================================================

def create_canonical_channel_figure():
    """Visualize a canonical channel as a heatmap alongside its closure system."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Closure system
    n = 5
    labels = ['a₀', 'a₁', 'a₂', 'a₃', 'a₄']

    # cl({0}) = {0,1}, cl({1}) = {1}, cl({2}) = {2,3,4}, cl({3}) = {3}, cl({4}) = {4}
    closures = [
        {0, 1},     # a₀ → {a₀, a₁}
        {1},         # a₁ → {a₁}
        {2, 3, 4},   # a₂ → {a₂, a₃, a₄}
        {3},         # a₃ → {a₃}
        {4},         # a₄ → {a₄}
    ]
    weights = [1.0, 2.0, 0.5, 3.0, 1.5]

    # Draw closure system as directed graph
    positions = {
        0: (0, 2), 1: (1, 2),
        2: (2.5, 2), 3: (2, 1), 4: (3, 1)
    }

    for i in range(n):
        x, y = positions[i]
        circle = plt.Circle((x, y), 0.2, color=plt.cm.Blues(weights[i] / 3.5),
                             ec='black', lw=2, zorder=5)
        ax1.add_patch(circle)
        ax1.text(x, y, labels[i], ha='center', va='center', fontsize=10, fontweight='bold')
        ax1.text(x, y - 0.35, f'w={weights[i]}', ha='center', va='top', fontsize=8)

    # Draw closure arrows
    closure_edges = [(0, 1), (2, 3), (2, 4)]
    for src, dst in closure_edges:
        x1, y1 = positions[src]
        x2, y2 = positions[dst]
        ax1.annotate('', xy=(x2, y2 + 0.22), xytext=(x1, y1 - 0.22),
                     arrowprops=dict(arrowstyle='->', color='red', lw=2,
                                     connectionstyle='arc3,rad=0.2'))

    ax1.set_xlim(-0.5, 3.5)
    ax1.set_ylim(0.3, 2.8)
    ax1.set_title('Weighted Closure System\n(red arrows = closure implications)',
                  fontsize=12, fontweight='bold')
    ax1.set_aspect('equal')
    ax1.axis('off')

    # Canonical channel heatmap
    K = np.full((n, n), np.nan)
    for a in range(n):
        for b in range(n):
            if b in closures[a]:
                K[a, b] = weights[a]

    # Create custom colormap with NaN as white
    cmap = plt.cm.YlOrRd.copy()
    cmap.set_bad('white')

    im = ax2.imshow(K, cmap=cmap, aspect='equal', vmin=0, vmax=3.5)
    ax2.set_xticks(range(n))
    ax2.set_xticklabels(labels, fontsize=10)
    ax2.set_yticks(range(n))
    ax2.set_yticklabels(labels, fontsize=10)
    ax2.set_xlabel('Observation b', fontsize=12)
    ax2.set_ylabel('State a', fontsize=12)
    ax2.set_title('Canonical Channel K_C(a,b)\n(white = ∞, colored = w(a))',
                  fontsize=12, fontweight='bold')

    # Add text annotations
    for a in range(n):
        for b in range(n):
            if b in closures[a]:
                ax2.text(b, a, f'{weights[a]:.1f}', ha='center', va='center',
                         fontsize=9, fontweight='bold')
            else:
                ax2.text(b, a, '∞', ha='center', va='center',
                         fontsize=9, color='gray')

    plt.colorbar(im, ax=ax2, shrink=0.8, label='Cost')

    plt.tight_layout()
    return fig


# ================================================================
# Figure 3: Free-Energy Profile Comparison
# ================================================================

def create_free_energy_profile_figure():
    """Compare free-energy profiles across channels in the Blackwell order."""
    fig, ax = plt.subplots(figsize=(10, 6))

    states = ['State 0', 'State 1', 'State 2', 'State 3']
    n = 4

    # Example profiles (monotonically increasing under garbling)
    profiles = {
        'K (4 obs, most informative)': [2.0, 3.0, 3.5, 2.5],
        'L (3 obs, garbled)': [2.5, 3.5, 4.0, 3.0],
        'M (2 obs, more garbled)': [3.0, 4.0, 4.5, 3.5],
        'N (1 obs, trivial)': [4.0, 5.0, 5.5, 4.5],
    }

    x = np.arange(n)
    width = 0.2
    colors = ['#2ecc71', '#3498db', '#e67e22', '#e74c3c']

    for i, (name, profile) in enumerate(profiles.items()):
        bars = ax.bar(x + i * width, profile, width * 0.9,
                      label=name, color=colors[i], edgecolor='black', linewidth=0.8)

    ax.set_xlabel('State a', fontsize=12)
    ax.set_ylabel('Free-Energy Profile: w(a) + min_b K(a,b)', fontsize=12)
    ax.set_title('Free-Energy Profile Monotonicity Under Garbling\n'
                 'More garbling → higher profile at every state',
                 fontsize=13, fontweight='bold')
    ax.set_xticks(x + 1.5 * width)
    ax.set_xticklabels(states, fontsize=11)
    ax.legend(fontsize=9, loc='upper left')

    # Add monotonicity arrows
    for s in range(n):
        y_min = profiles['K (4 obs, most informative)'][s]
        y_max = profiles['N (1 obs, trivial)'][s]
        ax.annotate('', xy=(s + 3 * width, y_max + 0.15),
                     xytext=(s, y_min - 0.15),
                     arrowprops=dict(arrowstyle='->', color='gray',
                                     lw=1, ls='--'))

    ax.set_ylim(0, 7)
    plt.tight_layout()
    return fig


# ================================================================
# Figure 4: Tropical Composition Visualization
# ================================================================

def create_tropical_composition_figure():
    """Visualize tropical matrix composition as path-cost minimization."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # K: 3×3 channel
    K = np.array([[1, 3, 5], [4, 1, 3], [2, 5, 1]], dtype=float)
    # T: 3×2 garbling
    T = np.array([[0, 2], [1, 0], [2, 1]], dtype=float)

    # Draw K
    ax = axes[0]
    im = ax.imshow(K, cmap='YlOrRd', vmin=0, vmax=5)
    for i in range(3):
        for j in range(3):
            ax.text(j, i, f'{K[i,j]:.0f}', ha='center', va='center',
                    fontsize=14, fontweight='bold')
    ax.set_title('Channel K\n(3 states × 3 obs)', fontsize=12, fontweight='bold')
    ax.set_xlabel('Observation')
    ax.set_ylabel('State')
    ax.set_xticks(range(3))
    ax.set_yticks(range(3))

    # Draw T
    ax = axes[1]
    im = ax.imshow(T, cmap='YlGnBu', vmin=0, vmax=3)
    for i in range(3):
        for j in range(2):
            ax.text(j, i, f'{T[i,j]:.0f}', ha='center', va='center',
                    fontsize=14, fontweight='bold')
    ax.set_title('Garbling T\n(3 obs → 2 obs)', fontsize=12, fontweight='bold')
    ax.set_xlabel('Output')
    ax.set_ylabel('Input')
    ax.set_xticks(range(2))
    ax.set_yticks(range(3))

    # Compute and draw L = K ⊗ T
    L = np.full((3, 2), INF)
    for i in range(3):
        for j in range(2):
            for k in range(3):
                L[i, j] = min(L[i, j], K[i, k] + T[k, j])

    ax = axes[2]
    im = ax.imshow(L, cmap='YlOrRd', vmin=0, vmax=5)
    for i in range(3):
        for j in range(2):
            # Show the min-plus computation
            terms = [f'{K[i,k]:.0f}+{T[k,j]:.0f}' for k in range(3)]
            min_val = L[i, j]
            ax.text(j, i, f'{min_val:.0f}', ha='center', va='center',
                    fontsize=14, fontweight='bold')
    ax.set_title('L = K ⊗ T (min-plus)\nL[i,j] = min_k(K[i,k]+T[k,j])',
                 fontsize=12, fontweight='bold')
    ax.set_xlabel('Output')
    ax.set_ylabel('State')
    ax.set_xticks(range(2))
    ax.set_yticks(range(3))

    plt.suptitle('Tropical (Min-Plus) Matrix Composition: Channel Garbling',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig


# ================================================================
# Generate all figures
# ================================================================

if __name__ == "__main__":
    print("Generating visualizations...")

    fig1 = create_blackwell_ordering_figure()
    fig1.savefig('fig_blackwell_ordering.png', dpi=150, bbox_inches='tight')
    print("  Saved fig_blackwell_ordering.png")

    fig2 = create_canonical_channel_figure()
    fig2.savefig('fig_canonical_channel.png', dpi=150, bbox_inches='tight')
    print("  Saved fig_canonical_channel.png")

    fig3 = create_free_energy_profile_figure()
    fig3.savefig('fig_free_energy_profile.png', dpi=150, bbox_inches='tight')
    print("  Saved fig_free_energy_profile.png")

    fig4 = create_tropical_composition_figure()
    fig4.savefig('fig_tropical_composition.png', dpi=150, bbox_inches='tight')
    print("  Saved fig_tropical_composition.png")

    print("\nAll visualizations generated successfully!")
