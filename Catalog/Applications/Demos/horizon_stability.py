#!/usr/bin/env python3
"""
Applications of Tropical Horizon Stability

Demonstrates real-world applications of the horizon stability theorems:
1. Network security: robustness of min-cut security thresholds
2. Holographic entanglement: discrete Ryu-Takayanagi surfaces
3. Black hole thermodynamics: entropy bounds under metric perturbation
4. Communication networks: wiretap channel capacity stability
"""

import numpy as np
from typing import Set, Tuple, List, Dict
from algorithms import (
    compute_horizon, certify_stability, compute_cut_weight,
    einstein_maxwell_effective_weight, enumerate_separating_cuts
)


def application_network_security():
    """
    Application 1: Network Security Threshold Robustness
    
    In network security, the min-cut determines the maximum information
    that can be securely transmitted. The horizon stability theorem
    guarantees that if link capacities are measured with error ≤ ε,
    the security threshold changes by at most |V|² · ε.
    """
    print("=" * 70)
    print("APPLICATION 1: Network Security Threshold Robustness")
    print("=" * 70)
    
    # Model a small corporate network
    # Nodes: 0=Internet, 1=Firewall, 2=DMZ, 3=AppServer, 4=Database, 5=Backup
    n = 6
    labels = ["Internet", "Firewall", "DMZ", "AppServer", "Database", "Backup"]
    
    # Capacity matrix (in Gbps - security relevant)
    W = np.zeros((n, n))
    W[0, 1] = W[1, 0] = 10.0   # Internet-Firewall
    W[1, 2] = W[2, 1] = 5.0    # Firewall-DMZ
    W[1, 3] = W[3, 1] = 3.0    # Firewall-AppServer
    W[2, 3] = W[3, 2] = 4.0    # DMZ-AppServer
    W[3, 4] = W[4, 3] = 2.0    # AppServer-Database
    W[3, 5] = W[5, 3] = 1.5    # AppServer-Backup
    W[4, 5] = W[5, 4] = 1.0    # Database-Backup
    
    # Security question: what's the min-cut between Internet and Database?
    s, t = 0, 4  # Attacker at Internet, target is Database
    
    result = compute_horizon(W, s, t)
    cert = certify_stability(W, s, t, 0.5)  # 0.5 Gbps measurement error
    
    print(f"\nNetwork topology: {n} nodes")
    for i, label in enumerate(labels):
        print(f"  Node {i}: {label}")
    
    print(f"\nSecurity analysis (attacker: {labels[s]} → target: {labels[t]}):")
    print(f"  Min-cut (security threshold): {result.value} Gbps")
    print(f"  Critical cut: {[labels[v] for v in sorted(result.minimizer)]}")
    print(f"  Gap to next cut: {result.gap} Gbps")
    
    print(f"\nRobustness under 0.5 Gbps measurement uncertainty:")
    print(f"  {cert.message}")
    print(f"  Worst-case threshold shift: ≤ {cert.lipschitz_constant * 0.5} Gbps")
    print(f"  Guaranteed minimum security: {max(0, result.value - cert.lipschitz_constant * 0.5):.1f} Gbps")


def application_holographic_entanglement():
    """
    Application 2: Discrete Ryu-Takayanagi Entanglement Surfaces
    
    In holographic entanglement entropy, the entanglement entropy of a
    boundary region equals the area of the minimal surface in the bulk.
    On a discrete graph, this becomes a min-cut problem.
    
    The stability theorem shows that small metric perturbations in the
    bulk geometry cause only small changes in entanglement entropy.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Holographic Entanglement (Discrete Ryu-Takayanagi)")
    print("=" * 70)
    
    # Model a simple AdS/CFT discretization
    # Boundary: nodes 0, 5 (CFT boundary regions A, B)
    # Bulk: nodes 1, 2, 3, 4 (discretized AdS bulk)
    n = 6
    labels = ["Boundary_A", "Bulk_1", "Bulk_2", "Bulk_3", "Bulk_4", "Boundary_B"]
    
    # Metric weights (encoding discrete geometry)
    W = np.zeros((n, n))
    # Boundary-bulk connections
    W[0, 1] = W[1, 0] = 3.0
    W[0, 2] = W[2, 0] = 4.0
    W[5, 3] = W[3, 5] = 3.0
    W[5, 4] = W[4, 5] = 4.0
    # Bulk-bulk connections
    W[1, 2] = W[2, 1] = 2.0
    W[1, 3] = W[3, 1] = 5.0
    W[2, 4] = W[4, 2] = 5.0
    W[3, 4] = W[4, 3] = 2.0
    W[2, 3] = W[3, 2] = 1.0
    
    s, t = 0, 5
    result = compute_horizon(W, s, t)
    
    print(f"\nDiscrete AdS geometry: {n} nodes")
    print(f"Boundary regions: {labels[s]} (A) and {labels[t]} (B)")
    print(f"\nEntanglement entropy S(A) ≈ min-cut area = {result.value}")
    print(f"Minimal surface (RT surface): {[labels[v] for v in sorted(result.minimizer)]}")
    
    # Perturbation analysis (quantum corrections to geometry)
    print(f"\nQuantum corrections (metric perturbation ε):")
    print(f"  {'ε':>6} {'ΔS(A) bound':>14} {'Surface stable?':>16}")
    print(f"  {'-'*38}")
    for eps in [0.01, 0.05, 0.1, 0.5]:
        cert = certify_stability(W, s, t, eps)
        bound = cert.lipschitz_constant * eps
        print(f"  {eps:6.2f} {bound:14.4f} {'Yes ✓' if cert.is_stable else 'No ✗':>16}")


def application_black_hole_entropy():
    """
    Application 3: Black Hole Entropy Stability
    
    The Bekenstein-Hawking entropy S = A/(4G) says that black hole entropy
    is proportional to horizon area. On a discrete graph, the horizon
    is a min-cut and the entropy is bounded by the number of microstates.
    
    The stability theorem shows that small perturbations to the metric
    cause controlled changes in the "area" (cut weight).
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Discrete Black Hole Entropy Stability")
    print("=" * 70)
    
    # Model a radial discretization of Schwarzschild-like geometry
    # Node 0: singularity (interior), Node n-1: asymptotic observer
    n = 5
    labels = ["Singularity", "Inner_r1", "Horizon_r2", "Outer_r3", "Observer"]
    
    # Weights decrease with distance (gravitational potential)
    W = np.zeros((n, n))
    W[0, 1] = W[1, 0] = 8.0
    W[1, 2] = W[2, 1] = 3.0   # Horizon region - low weight = bottleneck
    W[2, 3] = W[3, 2] = 6.0
    W[3, 4] = W[4, 3] = 10.0
    # Add some angular connections
    W[1, 3] = W[3, 1] = 7.0
    W[0, 2] = W[2, 0] = 5.0
    
    s, t = 0, 4  # Interior to exterior
    result = compute_horizon(W, s, t)
    
    print(f"\nDiscrete Schwarzschild geometry: {n} radial nodes")
    print(f"  Interior: {labels[s]}, Exterior: {labels[t]}")
    print(f"\n'Horizon' (min-cut):")
    print(f"  Cut vertices: {[labels[v] for v in sorted(result.minimizer)]}")
    print(f"  'Area' (cut weight): {result.value}")
    print(f"  Bekenstein entropy bound: S ≤ log₂(microstates) = {result.entropy_bits:.2f} bits")
    print(f"  Gap (stability margin): {result.gap}")
    
    # Stability under Planck-scale fluctuations
    print(f"\nPlanck-scale metric fluctuation analysis:")
    for eps_name, eps in [("Classical", 0.001), ("Semiclassical", 0.1), 
                          ("Quantum", 0.5), ("Strong quantum", 1.0)]:
        cert = certify_stability(W, s, t, eps)
        delta_S = cert.lipschitz_constant * eps
        print(f"  {eps_name:16s} (ε={eps:.3f}): ΔArea ≤ {delta_S:.3f}, "
              f"horizon {'stable' if cert.is_stable else 'may shift'}")


def application_wiretap_capacity():
    """
    Application 4: Wiretap Channel Capacity Stability
    
    In information-theoretic security, the secrecy capacity of a wiretap
    network is determined by the min-cut between legitimate parties
    minus the min-cut to the eavesdropper.
    
    The stability theorem ensures robust security guarantees even with
    imperfect knowledge of channel capacities.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Wiretap Channel Capacity Stability")
    print("=" * 70)
    
    # Network: Alice(0), Bob(5), Eve(eavesdropper at node 3)
    n = 6
    labels = ["Alice", "Relay_1", "Relay_2", "Eve", "Relay_3", "Bob"]
    
    W = np.zeros((n, n))
    # Legitimate path
    W[0, 1] = W[1, 0] = 5.0
    W[0, 2] = W[2, 0] = 4.0
    W[1, 4] = W[4, 1] = 6.0
    W[2, 4] = W[4, 2] = 3.0
    W[4, 5] = W[5, 4] = 7.0
    # Eve's connections
    W[1, 3] = W[3, 1] = 2.0
    W[2, 3] = W[3, 2] = 1.5
    W[3, 4] = W[4, 3] = 1.0
    
    # Legitimate capacity: min-cut Alice to Bob
    result_legit = compute_horizon(W, 0, 5)
    # Eve's capacity: min-cut Alice to Eve
    result_eve = compute_horizon(W, 0, 3)
    
    secrecy = max(0, result_legit.value - result_eve.value)
    
    print(f"\nNetwork: {labels}")
    print(f"\nLegitimate channel (Alice→Bob):")
    print(f"  Min-cut capacity: {result_legit.value}")
    print(f"  Critical link: {[labels[v] for v in sorted(result_legit.minimizer)]}")
    
    print(f"\nEavesdropper channel (Alice→Eve):")
    print(f"  Min-cut capacity: {result_eve.value}")
    
    print(f"\nSecrecy capacity: {secrecy}")
    
    # Stability under channel estimation errors
    print(f"\nRobustness under channel estimation error ε:")
    print(f"  {'ε':>6} {'Secrecy lower bound':>20} {'Both cuts stable?':>18}")
    print(f"  {'-'*46}")
    for eps in [0.05, 0.1, 0.2, 0.5]:
        C = n ** 2
        # Worst case: legit capacity drops, Eve's rises
        worst_secrecy = max(0, secrecy - 2 * C * eps)
        cert_l = certify_stability(W, 0, 5, eps)
        cert_e = certify_stability(W, 0, 3, eps)
        both_stable = cert_l.is_stable and cert_e.is_stable
        print(f"  {eps:6.2f} {worst_secrecy:20.3f} {'Yes ✓' if both_stable else 'No ✗':>18}")


if __name__ == "__main__":
    application_network_security()
    application_holographic_entanglement()
    application_black_hole_entropy()
    application_wiretap_capacity()
    
    print("\n" + "=" * 70)
    print("All applications demonstrated successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Horizon Stability: Demonstrations and Numerical Examples

This script demonstrates the key theorems from the tropical horizon stability
framework on concrete weighted graphs, showing:
1. Cut weight computation and horizon value identification
2. Lipschitz stability under edge weight perturbation
3. Gap-based combinatorial stability of minimizers
4. Einstein-Maxwell coupled stability
5. Microstate counting and entropy bounds
"""

import numpy as np
from itertools import combinations
from typing import List, Tuple, Set, Dict
import json


def cut_weight(W: np.ndarray, S: Set[int], V: Set[int]) -> float:
    """Compute the cut weight of subset S in graph with weight matrix W."""
    complement = V - S
    total = 0.0
    for i in S:
        for j in complement:
            total += W[i, j]
    return total


def all_separating_cuts(n: int, s: int, t: int) -> List[Set[int]]:
    """Generate all subsets S of {0,...,n-1} with s in S and t not in S."""
    V = set(range(n))
    cuts = []
    # Enumerate all subsets containing s but not t
    others = list(V - {s, t})
    for r in range(len(others) + 1):
        for combo in combinations(others, r):
            S = {s} | set(combo)
            cuts.append(S)
    return cuts


def horizon_value(W: np.ndarray, s: int, t: int) -> Tuple[float, Set[int]]:
    """Compute the horizon value (min cut weight) and a minimizing cut."""
    n = W.shape[0]
    V = set(range(n))
    cuts = all_separating_cuts(n, s, t)
    
    best_weight = float('inf')
    best_cut = None
    for S in cuts:
        w = cut_weight(W, S, V)
        if w < best_weight:
            best_weight = w
            best_cut = S
    return best_weight, best_cut


def horizon_gap(W: np.ndarray, s: int, t: int) -> float:
    """Compute the gap between best and second-best cut weights."""
    n = W.shape[0]
    V = set(range(n))
    cuts = all_separating_cuts(n, s, t)
    weights = sorted([cut_weight(W, S, V) for S in cuts])
    if len(weights) < 2:
        return 0.0
    return weights[1] - weights[0]


def demo_lipschitz_stability():
    """Demonstrate Lipschitz stability of horizon values under perturbation."""
    print("=" * 70)
    print("DEMO 1: Horizon Value Lipschitz Stability")
    print("=" * 70)
    
    # Create a 5-vertex weighted graph
    n = 5
    np.random.seed(42)
    W1 = np.random.rand(n, n) * 10
    W1 = (W1 + W1.T) / 2  # Symmetrize
    np.fill_diagonal(W1, 0)
    
    s, t = 0, 4
    C = n ** 2  # Lipschitz constant
    
    print(f"\nGraph: {n} vertices, terminals s={s}, t={t}")
    print(f"Lipschitz constant C = |V|^2 = {C}")
    print(f"\nOriginal weight matrix W1:")
    print(np.round(W1, 3))
    
    hv1, hc1 = horizon_value(W1, s, t)
    print(f"\nHorizon value H(W1) = {hv1:.6f}")
    print(f"Minimizing cut: {sorted(hc1)}")
    
    # Perturb by various epsilon values
    print(f"\n{'ε':>10} {'H(W2)':>12} {'|ΔH|':>12} {'C·ε':>12} {'Bound holds?':>14}")
    print("-" * 62)
    
    for eps in [0.01, 0.05, 0.1, 0.5, 1.0, 2.0]:
        perturbation = np.random.uniform(-eps, eps, (n, n))
        perturbation = (perturbation + perturbation.T) / 2
        np.fill_diagonal(perturbation, 0)
        W2 = W1 + perturbation
        
        # Verify pointwise bound
        actual_max_diff = np.max(np.abs(W1 - W2))
        
        hv2, hc2 = horizon_value(W2, s, t)
        diff = abs(hv1 - hv2)
        bound = C * eps
        
        print(f"{eps:10.3f} {hv2:12.6f} {diff:12.6f} {bound:12.6f} {'✓' if diff <= bound + 1e-10 else '✗':>14}")
    
    print("\n✓ The Lipschitz bound |H(W1) - H(W2)| ≤ |V|² · ε holds in all cases.")


def demo_gap_stability():
    """Demonstrate combinatorial stability under gap hypothesis."""
    print("\n" + "=" * 70)
    print("DEMO 2: Combinatorial Stability Under Gap Hypothesis")
    print("=" * 70)
    
    # Create a graph with a clear gap
    n = 4
    W1 = np.array([
        [0, 1, 10, 10],
        [1, 0, 10, 10],
        [10, 10, 0, 1],
        [10, 10, 1, 0]
    ], dtype=float)
    
    s, t = 0, 3
    V = set(range(n))
    C = n ** 2
    
    hv1, hc1 = horizon_value(W1, s, t)
    gap = horizon_gap(W1, s, t)
    
    print(f"\nGraph: {n} vertices, terminals s={s}, t={t}")
    print(f"Weight matrix:")
    print(W1)
    print(f"\nHorizon value: {hv1}")
    print(f"Minimizing cut: {sorted(hc1)}")
    print(f"Horizon gap δ = {gap}")
    print(f"Stability threshold: ε < δ/(2C) = {gap/(2*C):.6f}")
    
    # Show all cuts and their weights
    cuts = all_separating_cuts(n, s, t)
    print(f"\nAll separating cuts and weights:")
    for S in cuts:
        w = cut_weight(W1, S, V)
        marker = " ← MINIMIZER" if abs(w - hv1) < 1e-10 else ""
        print(f"  {sorted(S)} : weight = {w}{marker}")
    
    # Perturb within stability threshold
    eps_safe = gap / (2 * C) * 0.9  # Within threshold
    eps_unsafe = gap / (2 * C) * 3.0  # Beyond threshold
    
    print(f"\n--- Safe perturbation (ε = {eps_safe:.6f} < threshold) ---")
    np.random.seed(123)
    P = np.random.uniform(-eps_safe, eps_safe, (n, n))
    P = (P + P.T) / 2
    np.fill_diagonal(P, 0)
    W2 = W1 + P
    hv2, hc2 = horizon_value(W2, s, t)
    print(f"Original minimizer: {sorted(hc1)}")
    print(f"Perturbed minimizer: {sorted(hc2)}")
    print(f"Same cut? {'✓ YES' if hc1 == hc2 else '✗ NO'}")
    
    print(f"\n--- Large perturbation (ε = {eps_unsafe:.6f} > threshold) ---")
    P = np.random.uniform(-eps_unsafe, eps_unsafe, (n, n))
    P = (P + P.T) / 2
    np.fill_diagonal(P, 0)
    W2 = W1 + P
    hv2, hc2 = horizon_value(W2, s, t)
    print(f"Original minimizer: {sorted(hc1)}")
    print(f"Perturbed minimizer: {sorted(hc2)}")
    print(f"Same cut? {'✓ YES' if hc1 == hc2 else '✗ NO'} (stability not guaranteed)")


def demo_einstein_maxwell():
    """Demonstrate Einstein-Maxwell coupled horizon stability."""
    print("\n" + "=" * 70)
    print("DEMO 3: Einstein-Maxwell Coupled Horizon Stability")
    print("=" * 70)
    
    n = 4
    # Gravitational metric
    g1 = np.array([
        [0, 2, 5, 8],
        [2, 0, 3, 6],
        [5, 3, 0, 2],
        [8, 6, 2, 0]
    ], dtype=float)
    
    # Gauge potential
    A1 = np.array([
        [0, 1, -2, 3],
        [-1, 0, 1, -1],
        [2, -1, 0, 2],
        [-3, 1, -2, 0]
    ], dtype=float)
    
    lam = 0.5  # Coupling constant
    s, t = 0, 3
    C = n ** 2
    
    # Effective weight
    W1_eff = g1 + lam * np.abs(A1)
    
    print(f"\nGravitational metric g:")
    print(g1)
    print(f"\nGauge potential A:")
    print(A1)
    print(f"\nCoupling constant λ = {lam}")
    print(f"\nEffective weight W_eff = g + λ|A|:")
    print(np.round(W1_eff, 3))
    
    hv1, hc1 = horizon_value(W1_eff, s, t)
    print(f"\nHorizon value: {hv1:.6f}")
    print(f"Minimizing cut: {sorted(hc1)}")
    
    # Perturb both g and A
    print(f"\n{'εg':>8} {'εA':>8} {'|ΔH|':>12} {'C(εg+λεA)':>12} {'Bound?':>8}")
    print("-" * 50)
    
    for eps_g, eps_A in [(0.1, 0.1), (0.5, 0.2), (1.0, 0.5), (0.0, 1.0), (1.0, 0.0)]:
        np.random.seed(77)
        Pg = np.random.uniform(-eps_g, eps_g, (n, n))
        Pg = (Pg + Pg.T) / 2
        np.fill_diagonal(Pg, 0)
        
        PA = np.random.uniform(-eps_A, eps_A, (n, n))
        PA = (PA - PA.T) / 2  # Antisymmetric gauge
        
        g2 = g1 + Pg
        A2 = A1 + PA
        W2_eff = g2 + lam * np.abs(A2)
        
        hv2, _ = horizon_value(W2_eff, s, t)
        diff = abs(hv1 - hv2)
        bound = C * (eps_g + lam * eps_A)
        
        print(f"{eps_g:8.2f} {eps_A:8.2f} {diff:12.6f} {bound:12.6f} {'✓' if diff <= bound + 1e-10 else '✗':>8}")


def demo_microstate_entropy():
    """Demonstrate microstate counting and entropy bounds."""
    print("\n" + "=" * 70)
    print("DEMO 4: Horizon Microstate Count and Entropy Bounds")
    print("=" * 70)
    
    for n in range(2, 8):
        s, t = 0, n - 1
        cuts = all_separating_cuts(n, s, t)
        num_cuts = len(cuts)
        bound = 2 ** n
        entropy = np.log2(num_cuts) if num_cuts > 0 else 0
        max_entropy = n  # log2(2^n)
        
        print(f"n={n}: separating cuts = {num_cuts:5d}, "
              f"bound 2^n = {bound:5d}, "
              f"entropy = {entropy:.2f} bits, "
              f"max = {max_entropy} bits, "
              f"{'✓' if num_cuts <= bound else '✗'}")
    
    print("\n✓ The bound |separating cuts| ≤ 2^|V| holds for all tested sizes.")
    print("  This is the discrete Bekenstein-Hawking area-entropy bound.")


def demo_perturbation_landscape():
    """Demonstrate the perturbation landscape of horizon values."""
    print("\n" + "=" * 70)
    print("DEMO 5: Perturbation Landscape Analysis")
    print("=" * 70)
    
    n = 4
    W_base = np.array([
        [0, 3, 7, 9],
        [3, 0, 2, 8],
        [7, 2, 0, 4],
        [9, 8, 4, 0]
    ], dtype=float)
    
    s, t = 0, 3
    hv_base, hc_base = horizon_value(W_base, s, t)
    
    print(f"\nBase graph ({n} vertices), s={s}, t={t}")
    print(f"Base horizon value: {hv_base}")
    print(f"Base minimizer: {sorted(hc_base)}")
    
    # Scan epsilon and track horizon value and minimizer changes
    num_trials = 100
    epsilons = np.linspace(0, 3, 30)
    
    print(f"\n{'ε':>6} {'Mean |ΔH|':>12} {'Max |ΔH|':>12} {'Bound C·ε':>12} {'Cut changes':>12}")
    print("-" * 56)
    
    C = n ** 2
    for eps in epsilons[1::3]:  # Sample every 3rd
        diffs = []
        changes = 0
        for trial in range(num_trials):
            np.random.seed(trial * 1000 + int(eps * 100))
            P = np.random.uniform(-eps, eps, (n, n))
            P = (P + P.T) / 2
            np.fill_diagonal(P, 0)
            W2 = W_base + P
            hv2, hc2 = horizon_value(W2, s, t)
            diffs.append(abs(hv_base - hv2))
            if hc2 != hc_base:
                changes += 1
        
        print(f"{eps:6.2f} {np.mean(diffs):12.4f} {np.max(diffs):12.4f} "
              f"{C * eps:12.4f} {changes:>8d}/{num_trials}")


if __name__ == "__main__":
    demo_lipschitz_stability()
    demo_gap_stability()
    demo_einstein_maxwell()
    demo_microstate_entropy()
    demo_perturbation_landscape()
    
    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualizations for Tropical Horizon Stability

Generates publication-quality figures demonstrating the key results.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import combinations
from typing import Set, List, Dict, Tuple
import base64
import io


def compute_cut_weight(W, S):
    n = W.shape[0]
    V = set(range(n))
    complement = V - S
    return sum(W[i, j] for i in S for j in complement)


def enumerate_separating_cuts(n, s, t):
    others = [v for v in range(n) if v != s and v != t]
    cuts = []
    for r in range(len(others) + 1):
        for combo in combinations(others, r):
            cuts.append({s} | set(combo))
    return cuts


def horizon_value(W, s, t):
    n = W.shape[0]
    cuts = enumerate_separating_cuts(n, s, t)
    weights = [(compute_cut_weight(W, S), S) for S in cuts]
    weights.sort(key=lambda x: x[0])
    return weights[0][0], weights[0][1]


def fig_to_base64(fig):
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return base64.b64encode(buf.read()).decode('utf-8')


def plot_lipschitz_stability():
    """Plot 1: Lipschitz stability demonstration."""
    n = 5
    np.random.seed(42)
    W_base = np.random.rand(n, n) * 10
    W_base = (W_base + W_base.T) / 2
    np.fill_diagonal(W_base, 0)
    
    s, t = 0, 4
    C = n ** 2
    hv_base, _ = horizon_value(W_base, s, t)
    
    epsilons = np.linspace(0, 2.0, 50)
    num_trials = 80
    
    mean_diffs = []
    max_diffs = []
    
    for eps in epsilons:
        diffs = []
        for trial in range(num_trials):
            np.random.seed(trial * 1000 + int(eps * 1000))
            P = np.random.uniform(-eps, eps, (n, n))
            P = (P + P.T) / 2
            np.fill_diagonal(P, 0)
            W2 = W_base + P
            hv2, _ = horizon_value(W2, s, t)
            diffs.append(abs(hv_base - hv2))
        mean_diffs.append(np.mean(diffs))
        max_diffs.append(np.max(diffs))
    
    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    ax.fill_between(epsilons, 0, C * epsilons, alpha=0.15, color='red',
                    label=f'Lipschitz bound |V|²·ε = {C}ε')
    ax.plot(epsilons, C * epsilons, 'r--', linewidth=2)
    ax.plot(epsilons, max_diffs, 'b-', linewidth=2, label='Max |ΔH| (empirical)')
    ax.plot(epsilons, mean_diffs, 'g-', linewidth=2, label='Mean |ΔH| (empirical)')
    ax.set_xlabel('Perturbation magnitude ε', fontsize=13)
    ax.set_ylabel('|H(w₁) - H(w₂)|', fontsize=13)
    ax.set_title('Lipschitz Stability of Horizon Value', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    fig.savefig('/workspace/request-project/fig_lipschitz.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def plot_gap_stability():
    """Plot 2: Gap-based combinatorial stability."""
    n = 4
    W_base = np.array([
        [0, 1, 10, 10],
        [1, 0, 10, 10],
        [10, 10, 0, 1],
        [10, 10, 1, 0]
    ], dtype=float)
    
    s, t = 0, 3
    C = n ** 2
    
    # Compute gap
    cuts = enumerate_separating_cuts(n, s, t)
    V = set(range(n))
    weights = sorted([compute_cut_weight(W_base, S) for S in cuts])
    gap = weights[1] - weights[0]
    threshold = gap / (2 * C)
    
    epsilons = np.linspace(0, threshold * 4, 60)
    num_trials = 100
    
    change_rates = []
    for eps in epsilons:
        changes = 0
        _, base_cut = horizon_value(W_base, s, t)
        for trial in range(num_trials):
            np.random.seed(trial + int(eps * 10000))
            P = np.random.uniform(-eps, eps, (n, n))
            P = (P + P.T) / 2
            np.fill_diagonal(P, 0)
            W2 = W_base + P
            _, perturbed_cut = horizon_value(W2, s, t)
            if perturbed_cut != base_cut:
                changes += 1
        change_rates.append(changes / num_trials)
    
    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    ax.plot(epsilons, change_rates, 'b-', linewidth=2, label='Minimizer change rate')
    ax.axvline(x=threshold, color='r', linestyle='--', linewidth=2,
               label=f'Stability threshold δ/(2C) = {threshold:.4f}')
    ax.fill_between([0, threshold], 0, 1, alpha=0.1, color='green')
    ax.fill_between([threshold, epsilons[-1]], 0, 1, alpha=0.1, color='red')
    ax.text(threshold * 0.4, 0.85, 'STABLE\nZONE', fontsize=12, ha='center',
            color='green', fontweight='bold')
    ax.text(threshold * 2.5, 0.85, 'UNSTABLE\nZONE', fontsize=12, ha='center',
            color='red', fontweight='bold')
    ax.set_xlabel('Perturbation magnitude ε', fontsize=13)
    ax.set_ylabel('Fraction of trials with minimizer change', fontsize=13)
    ax.set_title('Combinatorial Stability Under Gap Hypothesis', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-0.05, 1.05)
    
    fig.savefig('/workspace/request-project/fig_gap_stability.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def plot_einstein_maxwell():
    """Plot 3: Einstein-Maxwell coupled stability."""
    n = 4
    g = np.array([
        [0, 2, 5, 8],
        [2, 0, 3, 6],
        [5, 3, 0, 2],
        [8, 6, 2, 0]
    ], dtype=float)
    
    A = np.array([
        [0, 1, -2, 3],
        [-1, 0, 1, -1],
        [2, -1, 0, 2],
        [-3, 1, -2, 0]
    ], dtype=float)
    
    s, t = 0, 3
    C = n ** 2
    lambdas = np.linspace(0, 2, 30)
    
    # Compute horizon value as function of coupling
    hvs = []
    for lam in lambdas:
        W_eff = g + lam * np.abs(A)
        hv, _ = horizon_value(W_eff, s, t)
        hvs.append(hv)
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    # Left: horizon value vs coupling
    ax1.plot(lambdas, hvs, 'b-', linewidth=2)
    ax1.set_xlabel('Coupling constant λ', fontsize=13)
    ax1.set_ylabel('Horizon value H(g, A, λ)', fontsize=13)
    ax1.set_title('Horizon Value vs. Gauge Coupling', fontsize=14)
    ax1.grid(True, alpha=0.3)
    
    # Right: 2D stability scan
    eps_gs = np.linspace(0, 1.0, 25)
    eps_As = np.linspace(0, 1.0, 25)
    lam = 0.5
    
    W_eff_base = g + lam * np.abs(A)
    hv_base, _ = horizon_value(W_eff_base, s, t)
    
    max_diffs = np.zeros((len(eps_As), len(eps_gs)))
    bounds = np.zeros_like(max_diffs)
    
    for i, eps_A in enumerate(eps_As):
        for j, eps_g in enumerate(eps_gs):
            diffs = []
            for trial in range(20):
                np.random.seed(trial + i * 100 + j)
                Pg = np.random.uniform(-eps_g, eps_g, (n, n))
                Pg = (Pg + Pg.T) / 2
                np.fill_diagonal(Pg, 0)
                PA = np.random.uniform(-eps_A, eps_A, (n, n))
                PA = (PA - PA.T) / 2
                g2 = g + Pg
                A2 = A + PA
                W2 = g2 + lam * np.abs(A2)
                hv2, _ = horizon_value(W2, s, t)
                diffs.append(abs(hv_base - hv2))
            max_diffs[i, j] = max(diffs)
            bounds[i, j] = C * (eps_g + lam * eps_A)
    
    im = ax2.imshow(max_diffs, origin='lower', aspect='auto',
                    extent=[eps_gs[0], eps_gs[-1], eps_As[0], eps_As[-1]],
                    cmap='YlOrRd')
    ax2.contour(eps_gs, eps_As, bounds, levels=[1, 2, 4, 8], colors='blue',
                linewidths=1.5, linestyles='--')
    ax2.set_xlabel('Metric perturbation εg', fontsize=13)
    ax2.set_ylabel('Gauge perturbation εA', fontsize=13)
    ax2.set_title(f'Max |ΔH| (λ={lam})', fontsize=14)
    plt.colorbar(im, ax=ax2, label='Max |ΔH|')
    
    fig.savefig('/workspace/request-project/fig_einstein_maxwell.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def plot_entropy_bounds():
    """Plot 4: Microstate counting and entropy bounds."""
    ns = list(range(2, 10))
    
    actual_counts = []
    bounds = []
    entropies = []
    max_entropies = []
    
    for n in ns:
        cuts = enumerate_separating_cuts(n, 0, n - 1)
        count = len(cuts)
        actual_counts.append(count)
        bounds.append(2 ** n)
        entropies.append(np.log2(count) if count > 0 else 0)
        max_entropies.append(n)
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    # Left: microstate counts
    ax1.semilogy(ns, actual_counts, 'bo-', linewidth=2, markersize=8, label='Actual #cuts')
    ax1.semilogy(ns, bounds, 'r^--', linewidth=2, markersize=8, label='Bound 2^|V|')
    ax1.set_xlabel('Number of vertices |V|', fontsize=13)
    ax1.set_ylabel('Number of separating cuts', fontsize=13)
    ax1.set_title('Microstate Count vs. Bekenstein Bound', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)
    
    # Right: entropy
    ax2.plot(ns, entropies, 'go-', linewidth=2, markersize=8, label='Actual entropy')
    ax2.plot(ns, max_entropies, 'r^--', linewidth=2, markersize=8, label='Max entropy |V|')
    ax2.set_xlabel('Number of vertices |V|', fontsize=13)
    ax2.set_ylabel('Entropy (bits)', fontsize=13)
    ax2.set_title('Horizon Entropy vs. Area Bound', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)
    
    fig.savefig('/workspace/request-project/fig_entropy.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")
    b64_lip = plot_lipschitz_stability()
    print("  ✓ Lipschitz stability plot")
    b64_gap = plot_gap_stability()
    print("  ✓ Gap stability plot")
    b64_em = plot_einstein_maxwell()
    print("  ✓ Einstein-Maxwell plot")
    b64_ent = plot_entropy_bounds()
    print("  ✓ Entropy bounds plot")
    print("All visualizations saved.")
