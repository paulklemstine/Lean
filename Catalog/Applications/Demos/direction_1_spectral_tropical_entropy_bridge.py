#!/usr/bin/env python3
"""
applications.py — Real-World Applications of the Spectral-Tropical Entropy Bridge

Demonstrates practical applications of the spectral-entropy theorems:
1. Network anomaly detection using entropy bounds
2. Graph classification via regularity deficit
3. Network robustness estimation from spectral certificates
"""

import math
import random
import numpy as np
from typing import List, Dict, Tuple


# ─── Core Functions (self-contained) ─────────────────────────────────────────

def degree_entropy(degrees: List[int]) -> float:
    vol = sum(degrees)
    if vol == 0:
        return 0.0
    H = 0.0
    for d in degrees:
        if d > 0:
            p = d / vol
            H -= p * math.log(p)
    return H


def regularity_deficit(degrees: List[int]) -> float:
    n = len(degrees)
    if n == 0:
        return 0.0
    return math.log(n) - degree_entropy(degrees)


def entropy_lower_bound(degrees: List[int]) -> float:
    n = len(degrees)
    vol = sum(degrees)
    delta = max(degrees) if degrees else 0
    if n == 0 or vol == 0 or delta == 0:
        return float('-inf')
    d_bar = vol / n
    return math.log(n * d_bar / delta)


def spectral_radius(adj: np.ndarray) -> float:
    return float(np.max(np.linalg.eigvalsh(adj)))


def generate_erdos_renyi(n: int, p: float) -> np.ndarray:
    adj = np.zeros((n, n))
    for i in range(n):
        for j in range(i + 1, n):
            if random.random() < p:
                adj[i][j] = adj[j][i] = 1
    return adj


# ─── Application 1: Network Anomaly Detection ───────────────────────────────

def app_anomaly_detection():
    """
    Detect structural anomalies in networks by comparing entropy to bounds.

    Idea: A network whose entropy is close to its lower bound has a severe
    degree bottleneck — a hub-and-spoke structure that concentrates
    connectivity. This is often a sign of attack, failure, or design flaw.
    """
    print("=" * 70)
    print("APPLICATION 1: NETWORK ANOMALY DETECTION")
    print("=" * 70)
    print()
    print("Scenario: Monitor a network over time. When the entropy margin")
    print("(H - bound) drops below a threshold, flag it as anomalous.")
    print()

    random.seed(42)
    np.random.seed(42)

    n = 30

    # Generate a "healthy" network (moderately connected)
    healthy = generate_erdos_renyi(n, 0.3)
    degrees_h = [int(np.sum(healthy[i])) for i in range(n)]
    H_h = degree_entropy(degrees_h)
    bound_h = entropy_lower_bound(degrees_h)
    margin_h = H_h - bound_h

    # Generate an "attacked" network: add a super-hub
    attacked = healthy.copy()
    hub = 0
    for i in range(1, n):
        attacked[hub][i] = attacked[i][hub] = 1
    degrees_a = [int(np.sum(attacked[i])) for i in range(n)]
    H_a = degree_entropy(degrees_a)
    bound_a = entropy_lower_bound(degrees_a)
    margin_a = H_a - bound_a

    # Generate a "degraded" network: remove many edges from some nodes
    degraded = healthy.copy()
    for v in range(n // 3):
        for j in range(n):
            if random.random() < 0.7:
                degraded[v][j] = degraded[j][v] = 0
    degrees_d = [int(np.sum(degraded[i])) for i in range(n)]
    H_d = degree_entropy(degrees_d)
    bound_d = entropy_lower_bound(degrees_d)
    margin_d = H_d - bound_d

    print(f"  {'Network':<20} {'Entropy':<10} {'Bound':<10} {'Margin':<10} {'Status':<15}")
    print("  " + "-" * 65)
    threshold = 0.3
    for name, H, bound, margin in [
        ("Healthy", H_h, bound_h, margin_h),
        ("Hub-attacked", H_a, bound_a, margin_a),
        ("Degraded", H_d, bound_d, margin_d)
    ]:
        status = "NORMAL" if margin > threshold else "⚠ ANOMALOUS"
        print(f"  {name:<20} {H:<10.4f} {bound:<10.4f} {margin:<10.4f} {status:<15}")

    print()
    print(f"  Threshold: margin < {threshold} → flag as anomalous")
    print("  Key insight: The entropy bound provides a principled baseline.")


# ─── Application 2: Graph Classification ────────────────────────────────────

def app_graph_classification():
    """
    Classify graphs by regularity deficit into categories:
    - Regular (deficit ≈ 0)
    - Near-regular (small deficit)
    - Moderately irregular
    - Highly irregular (large deficit)
    """
    print()
    print("=" * 70)
    print("APPLICATION 2: GRAPH CLASSIFICATION BY REGULARITY DEFICIT")
    print("=" * 70)
    print()

    random.seed(123)
    np.random.seed(123)

    n = 15
    graphs = []

    # Complete (regular)
    K = np.ones((n, n)) - np.eye(n)
    graphs.append(("Complete K15", K))

    # Cycle (regular)
    C = np.zeros((n, n))
    for i in range(n):
        C[i][(i + 1) % n] = C[(i + 1) % n][i] = 1
    graphs.append(("Cycle C15", C))

    # Random dense (near-regular)
    G1 = generate_erdos_renyi(n, 0.7)
    graphs.append(("G(15,0.7)", G1))

    # Random medium
    G2 = generate_erdos_renyi(n, 0.3)
    graphs.append(("G(15,0.3)", G2))

    # Random sparse
    G3 = generate_erdos_renyi(n, 0.1)
    graphs.append(("G(15,0.1)", G3))

    # Star (highly irregular)
    S = np.zeros((n, n))
    for i in range(1, n):
        S[0][i] = S[i][0] = 1
    graphs.append(("Star S15", S))

    # Path
    P = np.zeros((n, n))
    for i in range(n - 1):
        P[i][i + 1] = P[i + 1][i] = 1
    graphs.append(("Path P15", P))

    print(f"  {'Graph':<20} {'Deficit':<10} {'Category':<25} {'Delta/dbar':<10}")
    print("  " + "-" * 65)

    for name, adj in graphs:
        degrees = [int(np.sum(adj[i])) for i in range(n)]
        if sum(degrees) == 0:
            continue
        deficit = regularity_deficit(degrees)
        delta = max(degrees)
        d_bar = sum(degrees) / n
        ratio = delta / d_bar if d_bar > 0 else float('inf')

        if deficit < 1e-10:
            cat = "Regular"
        elif deficit < 0.05:
            cat = "Near-regular"
        elif deficit < 0.3:
            cat = "Moderately irregular"
        else:
            cat = "Highly irregular"

        print(f"  {name:<20} {deficit:<10.6f} {cat:<25} {ratio:<10.2f}")


# ─── Application 3: Network Robustness ──────────────────────────────────────

def app_robustness_estimation():
    """
    Estimate network robustness using spectral-entropy certificates.

    Principle: Networks with high entropy (close to log|V|) distribute
    connectivity evenly and are more robust to random vertex/edge removal.
    The spectral bound provides a certificate of minimum entropy without
    computing the full degree distribution.
    """
    print()
    print("=" * 70)
    print("APPLICATION 3: ROBUSTNESS ESTIMATION VIA SPECTRAL CERTIFICATES")
    print("=" * 70)
    print()

    random.seed(42)
    np.random.seed(42)

    n = 25

    print("Comparing robustness of different network topologies:")
    print(f"  Remove 20% of edges randomly, measure connectivity drop.")
    print()

    topologies = []

    # Complete
    K = np.ones((n, n)) - np.eye(n)
    topologies.append(("Complete", K))

    # Cycle
    C = np.zeros((n, n))
    for i in range(n):
        C[i][(i + 1) % n] = C[(i + 1) % n][i] = 1
    topologies.append(("Cycle", C))

    # Dense random
    G1 = generate_erdos_renyi(n, 0.5)
    topologies.append(("G(n,0.5)", G1))

    # Sparse random
    G2 = generate_erdos_renyi(n, 0.15)
    topologies.append(("G(n,0.15)", G2))

    # Star
    S = np.zeros((n, n))
    for i in range(1, n):
        S[0][i] = S[i][0] = 1
    topologies.append(("Star", S))

    print(f"  {'Topology':<15} {'H(G)':<8} {'Deficit':<10} {'lambda1':<10} "
          f"{'Post-removal H':<16} {'Robustness':<12}")
    print("  " + "-" * 70)

    for name, adj in topologies:
        degrees = [int(np.sum(adj[i])) for i in range(n)]
        if sum(degrees) == 0:
            continue
        H = degree_entropy(degrees)
        deficit = regularity_deficit(degrees)
        lam1 = spectral_radius(adj)

        # Simulate edge removal
        degraded = adj.copy()
        edges = [(i, j) for i in range(n) for j in range(i + 1, n) if adj[i][j] == 1]
        num_remove = max(1, len(edges) // 5)
        removed = random.sample(edges, min(num_remove, len(edges)))
        for i, j in removed:
            degraded[i][j] = degraded[j][i] = 0
        degrees_d = [int(np.sum(degraded[i])) for i in range(n)]
        H_d = degree_entropy(degrees_d) if sum(degrees_d) > 0 else 0

        robustness = H_d / H if H > 0 else 0

        print(f"  {name:<15} {H:<8.4f} {deficit:<10.4f} {lam1:<10.4f} "
              f"{H_d:<16.4f} {robustness:<12.4f}")

    print()
    print("  Key insight: High-entropy (low-deficit) graphs maintain their")
    print("  information structure better under random damage.")


# ─── Main ────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  SPECTRAL-TROPICAL ENTROPY BRIDGE — REAL-WORLD APPLICATIONS        ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    app_anomaly_detection()
    app_graph_classification()
    app_robustness_estimation()

    print()
    print("=" * 70)
    print("ALL APPLICATIONS COMPLETE")
    print("=" * 70)


#!/usr/bin/env python3
"""
demo.py — Spectral-Tropical Entropy Bridge: Demonstration & Conjecture Testing

Generates random graphs, computes entropy and spectral bounds, tests the
strong conjecture H(G) >= log(|V| * lambda_1 / Delta), and displays results
for regular, near-regular, and highly irregular graphs.

Usage:
    python demo.py
"""

import math
import random
import numpy as np
from typing import List, Tuple, Dict


# ─── Core Functions (self-contained) ─────────────────────────────────────────

def degree_entropy(degrees: List[int]) -> float:
    """Shannon entropy of the degree distribution."""
    vol = sum(degrees)
    if vol == 0:
        return 0.0
    H = 0.0
    for d in degrees:
        if d > 0:
            p = d / vol
            H -= p * math.log(p)
    return H


def regularity_deficit(degrees: List[int]) -> float:
    """D(G) = log|V| - H(G)."""
    n = len(degrees)
    if n == 0:
        return 0.0
    return math.log(n) - degree_entropy(degrees)


def kl_to_uniform(degrees: List[int]) -> float:
    """KL divergence from uniform."""
    n = len(degrees)
    vol = sum(degrees)
    if n == 0 or vol == 0:
        return 0.0
    u = 1.0 / n
    kl = 0.0
    for d in degrees:
        if d > 0:
            p = d / vol
            kl += p * math.log(p / u)
    return kl


def spectral_radius(adj: np.ndarray) -> float:
    """Largest eigenvalue of adjacency matrix."""
    eigs = np.linalg.eigvalsh(adj)
    return float(np.max(eigs))


def generate_erdos_renyi(n: int, p: float) -> np.ndarray:
    """Generate Erdos-Renyi G(n,p) adjacency matrix."""
    adj = np.zeros((n, n))
    for i in range(n):
        for j in range(i + 1, n):
            if random.random() < p:
                adj[i][j] = 1
                adj[j][i] = 1
    return adj


def analyze_graph(adj: np.ndarray) -> Dict[str, float]:
    """Full analysis of a graph."""
    n = adj.shape[0]
    degrees = [int(np.sum(adj[i])) for i in range(n)]
    vol = sum(degrees)
    delta = max(degrees) if degrees else 0
    d_bar = vol / n if n > 0 else 0
    H = degree_entropy(degrees)
    log_n = math.log(n) if n > 0 else 0
    deficit = log_n - H
    lam1 = spectral_radius(adj)

    # Bounds
    if delta > 0 and d_bar > 0:
        bound_avg = math.log(n * d_bar / delta)
        bound_spec = math.log(n * lam1 / delta) if lam1 > 0 else float('-inf')
    else:
        bound_avg = float('-inf')
        bound_spec = float('-inf')

    return {
        'n': n,
        'vol': vol,
        'delta': delta,
        'd_bar': d_bar,
        'H': H,
        'log_n': log_n,
        'deficit': deficit,
        'kl': kl_to_uniform(degrees),
        'lambda1': lam1,
        'bound_avg': bound_avg,
        'bound_spec': bound_spec,
        'margin_avg': H - bound_avg if bound_avg > float('-inf') else float('inf'),
        'margin_spec': H - bound_spec if bound_spec > float('-inf') else float('inf'),
        'is_regular': len(set(degrees)) <= 1,
    }


# ─── Demo Functions ──────────────────────────────────────────────────────────

def demo_specific_graphs():
    """Demonstrate with specific graph families."""
    print("=" * 70)
    print("PART 1: SPECIFIC GRAPH FAMILIES")
    print("=" * 70)

    n = 10

    # Complete graph K_n
    Kn = np.ones((n, n)) - np.eye(n)
    r = analyze_graph(Kn)
    print(f"\n--- Complete Graph K{n} (regular, d={n-1}) ---")
    print(f"  H(G) = {r['H']:.6f},  log|V| = {r['log_n']:.6f}")
    print(f"  Deficit D(G) = {r['deficit']:.6f}  (should be 0)")
    print(f"  KL(p||u) = {r['kl']:.6f}  (should equal deficit)")
    print(f"  lambda_1 = {r['lambda1']:.4f},  Delta = {r['delta']},  d_bar = {r['d_bar']:.2f}")
    print(f"  Bound (avg/max): {r['bound_avg']:.6f},  margin: {r['margin_avg']:.6f}")
    print(f"  Bound (spectral): {r['bound_spec']:.6f},  margin: {r['margin_spec']:.6f}")
    print(f"  Regular: {r['is_regular']}")

    # Cycle C_n
    Cn = np.zeros((n, n))
    for i in range(n):
        Cn[i][(i + 1) % n] = 1
        Cn[(i + 1) % n][i] = 1
    r = analyze_graph(Cn)
    print(f"\n--- Cycle C{n} (regular, d=2) ---")
    print(f"  H(G) = {r['H']:.6f},  log|V| = {r['log_n']:.6f}")
    print(f"  Deficit = {r['deficit']:.6f},  KL = {r['kl']:.6f}")
    print(f"  lambda_1 = {r['lambda1']:.4f},  Delta = {r['delta']},  d_bar = {r['d_bar']:.2f}")
    print(f"  Bound (avg/max): {r['bound_avg']:.6f},  margin: {r['margin_avg']:.6f}")
    print(f"  Regular: {r['is_regular']}")

    # Star graph S_n
    Sn = np.zeros((n, n))
    for i in range(1, n):
        Sn[0][i] = 1
        Sn[i][0] = 1
    r = analyze_graph(Sn)
    print(f"\n--- Star S{n} (highly irregular) ---")
    print(f"  H(G) = {r['H']:.6f},  log|V| = {r['log_n']:.6f}")
    print(f"  Deficit = {r['deficit']:.6f},  KL = {r['kl']:.6f}")
    print(f"  lambda_1 = {r['lambda1']:.4f},  Delta = {r['delta']},  d_bar = {r['d_bar']:.2f}")
    print(f"  Bound (avg/max): {r['bound_avg']:.6f},  margin: {r['margin_avg']:.6f}")
    print(f"  Bound (spectral): {r['bound_spec']:.6f},  margin: {r['margin_spec']:.6f}")
    print(f"  Regular: {r['is_regular']}")

    # Path graph P_n
    Pn = np.zeros((n, n))
    for i in range(n - 1):
        Pn[i][i + 1] = 1
        Pn[i + 1][i] = 1
    r = analyze_graph(Pn)
    print(f"\n--- Path P{n} (slightly irregular) ---")
    print(f"  H(G) = {r['H']:.6f},  log|V| = {r['log_n']:.6f}")
    print(f"  Deficit = {r['deficit']:.6f},  KL = {r['kl']:.6f}")
    print(f"  lambda_1 = {r['lambda1']:.4f},  Delta = {r['delta']},  d_bar = {r['d_bar']:.2f}")
    print(f"  Bound (avg/max): {r['bound_avg']:.6f},  margin: {r['margin_avg']:.6f}")
    print(f"  Regular: {r['is_regular']}")


def demo_conjecture_testing():
    """Test the strong conjecture on random graphs."""
    print("\n" + "=" * 70)
    print("PART 2: STRONG CONJECTURE TESTING")
    print("H(G) >= log(|V| * lambda_1 / Delta)")
    print("=" * 70)

    random.seed(42)
    np.random.seed(42)

    n = 50
    num_trials = 200
    probabilities = [0.1, 0.3, 0.5]

    for p in probabilities:
        margins_avg = []
        margins_spec = []
        violations = 0

        for _ in range(num_trials):
            adj = generate_erdos_renyi(n, p)
            # Ensure connected (skip isolated vertices for this test)
            degrees = [int(np.sum(adj[i])) for i in range(n)]
            if max(degrees) == 0:
                continue
            r = analyze_graph(adj)
            margins_avg.append(r['margin_avg'])
            margins_spec.append(r['margin_spec'])
            if r['margin_spec'] < -1e-10:
                violations += 1

        if margins_avg:
            print(f"\n--- G({n}, {p}): {len(margins_avg)} graphs tested ---")
            print(f"  Average margin (avg/max bound):  mean={np.mean(margins_avg):.6f}, "
                  f"min={np.min(margins_avg):.6f}, max={np.max(margins_avg):.6f}")
            print(f"  Average margin (spectral bound): mean={np.mean(margins_spec):.6f}, "
                  f"min={np.min(margins_spec):.6f}, max={np.max(margins_spec):.6f}")
            print(f"  Strong conjecture violations: {violations}/{len(margins_spec)}")
            if violations == 0:
                print(f"  ✓ Strong conjecture HOLDS for all tested graphs")
            else:
                print(f"  ✗ Strong conjecture VIOLATED in {violations} cases")


def demo_deficit_kl_equality():
    """Verify that regularity deficit equals KL divergence."""
    print("\n" + "=" * 70)
    print("PART 3: VERIFIED THEOREM — D(G) = D_KL(p || u)")
    print("=" * 70)

    random.seed(123)
    np.random.seed(123)

    print("\nChecking deficit = KL divergence for 100 random graphs:")
    max_error = 0.0
    for _ in range(100):
        n = random.randint(5, 30)
        p = random.uniform(0.1, 0.9)
        adj = generate_erdos_renyi(n, p)
        degrees = [int(np.sum(adj[i])) for i in range(n)]
        if sum(degrees) == 0:
            continue
        deficit = regularity_deficit(degrees)
        kl = kl_to_uniform(degrees)
        error = abs(deficit - kl)
        max_error = max(max_error, error)

    print(f"  Max |D(G) - KL(p||u)|: {max_error:.2e}")
    print(f"  ✓ Equality verified to machine precision" if max_error < 1e-12
          else f"  ✗ Discrepancy detected")


def demo_regularity_rigidity():
    """Demonstrate entropy rigidity: H = log|V| iff regular."""
    print("\n" + "=" * 70)
    print("PART 4: ENTROPY RIGIDITY")
    print("H(G) = log|V| iff G is regular")
    print("=" * 70)

    # Regular graphs
    print("\nRegular graphs (should have deficit = 0):")
    for name, n, d in [("K5", 5, 4), ("C8", 8, 2), ("Petersen", 10, 3)]:
        if name == "K5":
            adj = np.ones((n, n)) - np.eye(n)
        elif name == "C8":
            adj = np.zeros((n, n))
            for i in range(n):
                adj[i][(i + 1) % n] = 1
                adj[(i + 1) % n][i] = 1
        else:  # Petersen graph
            adj = np.zeros((10, 10))
            # Outer cycle
            for i in range(5):
                adj[i][(i + 1) % 5] = adj[(i + 1) % 5][i] = 1
            # Inner pentagram
            for i in range(5):
                adj[5 + i][5 + (i + 2) % 5] = adj[5 + (i + 2) % 5][5 + i] = 1
            # Spokes
            for i in range(5):
                adj[i][5 + i] = adj[5 + i][i] = 1
        degrees = [int(np.sum(adj[i])) for i in range(adj.shape[0])]
        H = degree_entropy(degrees)
        log_n = math.log(adj.shape[0])
        print(f"  {name}: H={H:.6f}, log|V|={log_n:.6f}, diff={abs(H-log_n):.2e}, "
              f"regular={len(set(degrees))<=1}")

    # Irregular graphs
    print("\nIrregular graphs (should have deficit > 0):")
    for name in ["Star S8", "Path P8", "Random G(8,0.5)"]:
        n = 8
        if "Star" in name:
            adj = np.zeros((n, n))
            for i in range(1, n):
                adj[0][i] = adj[i][0] = 1
        elif "Path" in name:
            adj = np.zeros((n, n))
            for i in range(n - 1):
                adj[i][i + 1] = adj[i + 1][i] = 1
        else:
            random.seed(999)
            adj = generate_erdos_renyi(n, 0.5)
        degrees = [int(np.sum(adj[i])) for i in range(n)]
        H = degree_entropy(degrees)
        log_n = math.log(n)
        deficit = log_n - H
        print(f"  {name}: H={H:.6f}, log|V|={log_n:.6f}, deficit={deficit:.6f}, "
              f"regular={len(set(degrees))<=1}")


def demo_bound_comparison():
    """Compare the avg/max bound with the spectral bound."""
    print("\n" + "=" * 70)
    print("PART 5: BOUND COMPARISON — avg/max vs spectral")
    print("=" * 70)

    random.seed(777)
    np.random.seed(777)

    n = 20
    print(f"\nGraphs on {n} vertices:")
    print(f"  {'Type':<20} {'H(G)':<10} {'Bound(a/m)':<12} {'Bound(spec)':<12} "
          f"{'Margin(a/m)':<12} {'Margin(sp)':<12}")
    print("  " + "-" * 78)

    graphs = []

    # Complete
    K = np.ones((n, n)) - np.eye(n)
    graphs.append(("Complete", K))

    # Cycle
    C = np.zeros((n, n))
    for i in range(n):
        C[i][(i + 1) % n] = C[(i + 1) % n][i] = 1
    graphs.append(("Cycle", C))

    # Star
    S = np.zeros((n, n))
    for i in range(1, n):
        S[0][i] = S[i][0] = 1
    graphs.append(("Star", S))

    # Path
    P = np.zeros((n, n))
    for i in range(n - 1):
        P[i][i + 1] = P[i + 1][i] = 1
    graphs.append(("Path", P))

    # Random graphs
    for p_val in [0.1, 0.3, 0.5, 0.7]:
        G = generate_erdos_renyi(n, p_val)
        graphs.append((f"G(n,{p_val})", G))

    for name, adj in graphs:
        r = analyze_graph(adj)
        if r['delta'] > 0:
            print(f"  {name:<20} {r['H']:<10.4f} {r['bound_avg']:<12.4f} "
                  f"{r['bound_spec']:<12.4f} {r['margin_avg']:<12.4f} "
                  f"{r['margin_spec']:<12.4f}")


# ─── Main ────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║     SPECTRAL-TROPICAL ENTROPY BRIDGE — DEMONSTRATION SUITE         ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    demo_specific_graphs()
    demo_conjecture_testing()
    demo_deficit_kl_equality()
    demo_regularity_rigidity()
    demo_bound_comparison()

    print("\n" + "=" * 70)
    print("DEMO COMPLETE")
    print("=" * 70)


"""
Visualization 1: Entropy Landscape — Degree Entropy vs. Regularity Deficit

Visualizes how different graph families occupy the entropy-deficit space.
Regular graphs sit at deficit=0 (maximum entropy), while irregular graphs
have positive deficit. The certified upper bound log(Delta/d_bar) is shown
as a boundary line.
"""

import math
import random
import numpy as np
import matplotlib.pyplot as plt


def degree_entropy(degrees):
    vol = sum(degrees)
    if vol == 0:
        return 0.0
    H = 0.0
    for d in degrees:
        if d > 0:
            p = d / vol
            H -= p * math.log(p)
    return H


def regularity_deficit(degrees):
    n = len(degrees)
    if n == 0:
        return 0.0
    return math.log(n) - degree_entropy(degrees)


def deficit_upper_bound(degrees):
    delta = max(degrees) if degrees else 0
    d_bar = sum(degrees) / len(degrees) if degrees else 0
    if d_bar <= 0 or delta == 0:
        return float('inf')
    return math.log(delta / d_bar)


def generate_erdos_renyi(n, p):
    adj = np.zeros((n, n))
    for i in range(n):
        for j in range(i + 1, n):
            if random.random() < p:
                adj[i][j] = adj[j][i] = 1
    return adj


random.seed(42)
np.random.seed(42)
n = 20

# Collect data points
categories = {
    'Regular': {'H': [], 'D': [], 'color': '#2196F3', 'marker': 's'},
    'Near-regular': {'H': [], 'D': [], 'color': '#4CAF50', 'marker': 'o'},
    'Irregular': {'H': [], 'D': [], 'color': '#FF9800', 'marker': '^'},
    'Highly irregular': {'H': [], 'D': [], 'color': '#F44336', 'marker': 'D'},
}

# Complete graph (regular)
K = np.ones((n, n)) - np.eye(n)
degrees = [int(np.sum(K[i])) for i in range(n)]
categories['Regular']['H'].append(degree_entropy(degrees))
categories['Regular']['D'].append(regularity_deficit(degrees))

# Cycle (regular)
C_adj = np.zeros((n, n))
for i in range(n):
    C_adj[i][(i + 1) % n] = C_adj[(i + 1) % n][i] = 1
degrees = [int(np.sum(C_adj[i])) for i in range(n)]
categories['Regular']['H'].append(degree_entropy(degrees))
categories['Regular']['D'].append(regularity_deficit(degrees))

# Random graphs at various densities
for p in [0.6, 0.7, 0.8]:
    for _ in range(15):
        adj = generate_erdos_renyi(n, p)
        degrees = [int(np.sum(adj[i])) for i in range(n)]
        if sum(degrees) == 0:
            continue
        categories['Near-regular']['H'].append(degree_entropy(degrees))
        categories['Near-regular']['D'].append(regularity_deficit(degrees))

for p in [0.2, 0.3, 0.4]:
    for _ in range(15):
        adj = generate_erdos_renyi(n, p)
        degrees = [int(np.sum(adj[i])) for i in range(n)]
        if sum(degrees) == 0:
            continue
        categories['Irregular']['H'].append(degree_entropy(degrees))
        categories['Irregular']['D'].append(regularity_deficit(degrees))

# Star (highly irregular)
S = np.zeros((n, n))
for i in range(1, n):
    S[0][i] = S[i][0] = 1
degrees = [int(np.sum(S[i])) for i in range(n)]
categories['Highly irregular']['H'].append(degree_entropy(degrees))
categories['Highly irregular']['D'].append(regularity_deficit(degrees))

# Path
P_adj = np.zeros((n, n))
for i in range(n - 1):
    P_adj[i][i + 1] = P_adj[i + 1][i] = 1
degrees = [int(np.sum(P_adj[i])) for i in range(n)]
categories['Highly irregular']['H'].append(degree_entropy(degrees))
categories['Highly irregular']['D'].append(regularity_deficit(degrees))

# Very sparse random
for p in [0.05, 0.1]:
    for _ in range(10):
        adj = generate_erdos_renyi(n, p)
        degrees = [int(np.sum(adj[i])) for i in range(n)]
        if sum(degrees) == 0:
            continue
        categories['Highly irregular']['H'].append(degree_entropy(degrees))
        categories['Highly irregular']['D'].append(regularity_deficit(degrees))

# Plot
fig, ax = plt.subplots(1, 1, figsize=(10, 7))

for cat, data in categories.items():
    if data['H']:
        ax.scatter(data['D'], data['H'], c=data['color'], marker=data['marker'],
                   s=80, label=cat, alpha=0.8, edgecolors='white', linewidth=0.5)

# Add log|V| line
log_n = math.log(n)
ax.axhline(y=log_n, color='gray', linestyle='--', alpha=0.5, label=f'H = log|V| = {log_n:.2f}')

# Add the bound region
D_vals = np.linspace(0, 2.5, 100)
H_bound = [log_n - D for D in D_vals]
ax.plot(D_vals, H_bound, 'k-', alpha=0.3, linewidth=2, label='H = log|V| - D(G)')

ax.set_xlabel('Regularity Deficit D(G) = log|V| - H(G)', fontsize=13)
ax.set_ylabel('Degree Entropy H(G)', fontsize=13)
ax.set_title('Entropy Landscape: Graph Families in the (Deficit, Entropy) Plane\n'
             f'n = {n} vertices', fontsize=14)
ax.legend(loc='upper right', fontsize=10)
ax.set_xlim(-0.05, 2.0)
ax.set_ylim(0, log_n + 0.3)
ax.grid(True, alpha=0.3)

# Annotate special graphs
ax.annotate('Complete K₂₀', xy=(0, log_n), fontsize=9,
            xytext=(0.3, log_n + 0.15), arrowprops=dict(arrowstyle='->', color='gray'))
ax.annotate('Star S₂₀', xy=(categories['Highly irregular']['D'][0],
            categories['Highly irregular']['H'][0]), fontsize=9,
            xytext=(1.2, 1.0), arrowprops=dict(arrowstyle='->', color='gray'))

plt.tight_layout()
plt.savefig('viz_entropy_landscape.png', dpi=150, bbox_inches='tight')
print("Saved: viz_entropy_landscape.png")


"""
Visualization 3: Entropy Rigidity — Regular Graphs as Entropy Maximizers

Demonstrates the rigidity theorem: H(G) = log|V| if and only if G is regular.
Shows how perturbing a regular graph away from regularity always decreases entropy,
and how the deficit correlates with the degree variance.
"""

import math
import random
import numpy as np
import matplotlib.pyplot as plt


def degree_entropy(degrees):
    vol = sum(degrees)
    if vol == 0:
        return 0.0
    H = 0.0
    for d in degrees:
        if d > 0:
            p = d / vol
            H -= p * math.log(p)
    return H


def regularity_deficit(degrees):
    n = len(degrees)
    if n == 0:
        return 0.0
    return math.log(n) - degree_entropy(degrees)


random.seed(42)
np.random.seed(42)

n = 20

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# --- Panel 1: Perturbation from regularity ---
ax1 = axes[0]

# Start from a regular graph (complete graph)
K = np.ones((n, n)) - np.eye(n)
perturbation_levels = range(0, n * (n - 1) // 4, 2)
deficits = []
variances = []

for num_removals in perturbation_levels:
    adj = K.copy()
    edges = [(i, j) for i in range(n) for j in range(i + 1, n) if adj[i][j] == 1]
    random.shuffle(edges)
    for k in range(min(num_removals, len(edges))):
        i, j = edges[k]
        adj[i][j] = adj[j][i] = 0
    degrees = [int(np.sum(adj[i])) for i in range(n)]
    if sum(degrees) == 0:
        break
    deficit = regularity_deficit(degrees)
    var = np.var(degrees)
    deficits.append(deficit)
    variances.append(var)

ax1.plot(list(perturbation_levels)[:len(deficits)], deficits, 'b-o',
         markersize=4, label='Deficit D(G)')
ax1.set_xlabel('Edges removed from K₂₀', fontsize=11)
ax1.set_ylabel('Regularity deficit D(G)', fontsize=11)
ax1.set_title('Perturbation from Regularity', fontsize=12)
ax1.axhline(y=0, color='green', linestyle='--', alpha=0.5, label='D=0 (regular)')
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# --- Panel 2: Deficit vs Degree Variance ---
ax2 = axes[1]

all_deficits = []
all_variances = []
all_types = []

# Generate various graphs
for _ in range(200):
    p = random.uniform(0.05, 0.95)
    adj = np.zeros((n, n))
    for i in range(n):
        for j in range(i + 1, n):
            if random.random() < p:
                adj[i][j] = adj[j][i] = 1
    degrees = [int(np.sum(adj[i])) for i in range(n)]
    if sum(degrees) == 0:
        continue
    d = regularity_deficit(degrees)
    v = np.var(degrees)
    all_deficits.append(d)
    all_variances.append(v)

ax2.scatter(all_variances, all_deficits, c='steelblue', s=20, alpha=0.5)
ax2.set_xlabel('Degree Variance σ²', fontsize=11)
ax2.set_ylabel('Regularity Deficit D(G)', fontsize=11)
ax2.set_title('Deficit ↔ Degree Variance', fontsize=12)
ax2.grid(True, alpha=0.3)

# Add trendline
if all_variances:
    z = np.polyfit(all_variances, all_deficits, 2)
    x_fit = np.linspace(0, max(all_variances), 100)
    y_fit = np.polyval(z, x_fit)
    ax2.plot(x_fit, y_fit, 'r-', alpha=0.7, linewidth=2, label='Quadratic fit')
    ax2.legend(fontsize=9)

# --- Panel 3: Entropy bar chart for graph families ---
ax3 = axes[2]

families = []

# Complete
degrees = [n - 1] * n
families.append(('Complete\nK₂₀', degree_entropy(degrees), True))

# Cycle
degrees = [2] * n
families.append(('Cycle\nC₂₀', degree_entropy(degrees), True))

# Petersen-like (3-regular)
degrees = [3] * n
families.append(('3-Regular', degree_entropy(degrees), True))

# Dense random
adj = np.zeros((n, n))
random.seed(100)
for i in range(n):
    for j in range(i + 1, n):
        if random.random() < 0.6:
            adj[i][j] = adj[j][i] = 1
degrees = [int(np.sum(adj[i])) for i in range(n)]
families.append(('G(n,0.6)', degree_entropy(degrees), False))

# Sparse random
adj = np.zeros((n, n))
random.seed(200)
for i in range(n):
    for j in range(i + 1, n):
        if random.random() < 0.2:
            adj[i][j] = adj[j][i] = 1
degrees = [int(np.sum(adj[i])) for i in range(n)]
families.append(('G(n,0.2)', degree_entropy(degrees), False))

# Path
degrees = [1] + [2] * (n - 2) + [1]
families.append(('Path\nP₂₀', degree_entropy(degrees), False))

# Star
degrees = [n - 1] + [1] * (n - 1)
families.append(('Star\nS₂₀', degree_entropy(degrees), False))

names = [f[0] for f in families]
entropies = [f[1] for f in families]
is_reg = [f[2] for f in families]
colors = ['#2196F3' if r else '#FF9800' for r in is_reg]

bars = ax3.bar(names, entropies, color=colors, edgecolor='white', linewidth=0.5)
ax3.axhline(y=math.log(n), color='red', linestyle='--', alpha=0.7,
            label=f'log|V| = {math.log(n):.2f}')
ax3.set_ylabel('Degree Entropy H(G)', fontsize=11)
ax3.set_title('Entropy Rigidity:\nH = log|V| ⟺ Regular', fontsize=12)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3, axis='y')

# Custom legend
from matplotlib.patches import Patch
legend_elements = [Patch(facecolor='#2196F3', label='Regular'),
                   Patch(facecolor='#FF9800', label='Irregular')]
ax3.legend(handles=legend_elements + [plt.Line2D([0], [0], color='red',
           linestyle='--', label=f'log|V| = {math.log(n):.2f}')],
           fontsize=9, loc='lower left')

plt.suptitle('Entropy Rigidity: Regular Graphs as Information-Theoretic Extrema',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_rigidity.png', dpi=150, bbox_inches='tight')
print("Saved: viz_rigidity.png")


"""
Visualization 2: Spectral Bound Verification

Shows the relationship between spectral radius lambda_1, average degree,
and the entropy lower bound for random graphs. Verifies that the bound
H(G) >= log(|V| * d_bar / Delta) holds universally, and tests the stronger
spectral conjecture H(G) >= log(|V| * lambda_1 / Delta).
"""

import math
import random
import numpy as np
import matplotlib.pyplot as plt


def degree_entropy(degrees):
    vol = sum(degrees)
    if vol == 0:
        return 0.0
    H = 0.0
    for d in degrees:
        if d > 0:
            p = d / vol
            H -= p * math.log(p)
    return H


def generate_erdos_renyi(n, p):
    adj = np.zeros((n, n))
    for i in range(n):
        for j in range(i + 1, n):
            if random.random() < p:
                adj[i][j] = adj[j][i] = 1
    return adj


random.seed(42)
np.random.seed(42)

n = 30
num_per_p = 80
p_values = np.linspace(0.05, 0.95, 19)

data = {pv: {'H': [], 'bound_avg': [], 'bound_spec': [], 'lambda1': [], 'd_bar': []}
        for pv in p_values}

for pv in p_values:
    for _ in range(num_per_p):
        adj = generate_erdos_renyi(n, pv)
        degrees = [int(np.sum(adj[i])) for i in range(n)]
        vol = sum(degrees)
        if vol == 0:
            continue
        delta = max(degrees)
        d_bar = vol / n
        H = degree_entropy(degrees)
        lam1 = float(np.max(np.linalg.eigvalsh(adj)))

        if delta > 0 and d_bar > 0:
            bound_avg = math.log(n * d_bar / delta)
            bound_spec = math.log(n * lam1 / delta) if lam1 > 0 else float('-inf')
        else:
            continue

        data[pv]['H'].append(H)
        data[pv]['bound_avg'].append(bound_avg)
        data[pv]['bound_spec'].append(bound_spec)
        data[pv]['lambda1'].append(lam1)
        data[pv]['d_bar'].append(d_bar)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Entropy vs avg/max bound
ax1 = axes[0, 0]
all_H = []
all_bound_avg = []
colors_p = []
for pv in p_values:
    for H, ba in zip(data[pv]['H'], data[pv]['bound_avg']):
        all_H.append(H)
        all_bound_avg.append(ba)
        colors_p.append(pv)

sc1 = ax1.scatter(all_bound_avg, all_H, c=colors_p, cmap='viridis', s=15, alpha=0.6)
lo, hi = min(all_bound_avg + all_H), max(all_bound_avg + all_H)
ax1.plot([lo, hi], [lo, hi], 'r--', alpha=0.5, label='y = x (tight)')
ax1.set_xlabel('Lower bound: log(|V|·d̄/Δ)')
ax1.set_ylabel('Actual entropy H(G)')
ax1.set_title('Theorem A: H(G) ≥ log(|V|·d̄/Δ)')
ax1.legend()
ax1.grid(True, alpha=0.3)
plt.colorbar(sc1, ax=ax1, label='Edge probability p')

# Plot 2: Entropy margin distribution
ax2 = axes[0, 1]
margins_by_p = {}
for pv in p_values:
    margins = [H - ba for H, ba in zip(data[pv]['H'], data[pv]['bound_avg'])]
    if margins:
        margins_by_p[pv] = margins

selected_p = [0.1, 0.3, 0.5, 0.7, 0.9]
colors = ['#F44336', '#FF9800', '#4CAF50', '#2196F3', '#9C27B0']
for i, sp in enumerate(selected_p):
    closest_p = min(p_values, key=lambda x: abs(x - sp))
    if closest_p in margins_by_p:
        ax2.hist(margins_by_p[closest_p], bins=15, alpha=0.5,
                 label=f'p={sp:.1f}', color=colors[i])
ax2.axvline(x=0, color='red', linestyle='--', alpha=0.5, label='Bound = H')
ax2.set_xlabel('Margin: H(G) - bound')
ax2.set_ylabel('Count')
ax2.set_title('Distribution of Entropy Margins')
ax2.legend(fontsize=8)
ax2.grid(True, alpha=0.3)

# Plot 3: Spectral radius vs average degree
ax3 = axes[1, 0]
all_lam = []
all_dbar = []
all_colors = []
for pv in p_values:
    for l, d in zip(data[pv]['lambda1'], data[pv]['d_bar']):
        all_lam.append(l)
        all_dbar.append(d)
        all_colors.append(pv)
sc3 = ax3.scatter(all_dbar, all_lam, c=all_colors, cmap='viridis', s=15, alpha=0.6)
lo, hi = 0, max(max(all_lam), max(all_dbar))
ax3.plot([0, hi], [0, hi], 'r--', alpha=0.5, label='λ₁ = d̄')
ax3.set_xlabel('Average degree d̄')
ax3.set_ylabel('Spectral radius λ₁')
ax3.set_title('λ₁ ≥ d̄ (Collatz–Sinogowitz)')
ax3.legend()
ax3.grid(True, alpha=0.3)
plt.colorbar(sc3, ax=ax3, label='Edge probability p')

# Plot 4: Strong conjecture margin
ax4 = axes[1, 1]
all_spec_margins = []
all_colors_spec = []
for pv in p_values:
    for H, bs in zip(data[pv]['H'], data[pv]['bound_spec']):
        if bs > float('-inf'):
            all_spec_margins.append(H - bs)
            all_colors_spec.append(pv)
sc4 = ax4.scatter(all_colors_spec, all_spec_margins, c=all_colors_spec,
                  cmap='viridis', s=15, alpha=0.6)
ax4.axhline(y=0, color='red', linestyle='--', alpha=0.5)
ax4.set_xlabel('Edge probability p')
ax4.set_ylabel('H(G) - log(|V|·λ₁/Δ)')
ax4.set_title('Strong Conjecture: H(G) ≥ log(|V|·λ₁/Δ)')
ax4.grid(True, alpha=0.3)
violations = sum(1 for m in all_spec_margins if m < -1e-10)
ax4.text(0.5, 0.95, f'Violations: {violations}/{len(all_spec_margins)}',
         transform=ax4.transAxes, ha='center', va='top',
         fontsize=11, color='green' if violations == 0 else 'red',
         bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

plt.suptitle(f'Spectral-Tropical Entropy Bounds — G(n={n}, p) Random Graphs',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_spectral_bound.png', dpi=150, bbox_inches='tight')
print("Saved: viz_spectral_bound.png")
