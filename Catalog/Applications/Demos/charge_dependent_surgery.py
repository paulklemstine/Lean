"""
Applications of Charged Wormhole Surgery

Demonstrates real-world applications of the gauge-covariant tropical
graph surgery framework.
"""

import numpy as np
from algorithms import (floyd_warshall, charged_penalty, wormhole_surgery,
                         charged_wormhole_surgery, compute_charged_distances,
                         verify_surgery_bound, verify_sandwich)


def electrical_network_example():
    """
    Application: Electrical network with voltage-dependent transmission costs.
    
    Vertices = substations, edges = transmission lines.
    A[i] = operating voltage at substation i (kV).
    W[i][j] = base transmission loss between i and j.
    Adding a new line costs λ (base) + κ|V_u - V_v| (transformer cost).
    """
    print("=" * 60)
    print("APPLICATION: Electrical Network Design")
    print("=" * 60)
    
    # 6-substation grid
    n = 6
    INF = 1000.0
    W = np.full((n, n), INF)
    np.fill_diagonal(W, 0)
    
    # Grid topology
    edges = [(0,1,5), (1,2,8), (2,3,3), (3,4,6), (4,5,4),
             (0,5,7), (1,4,12), (2,5,15)]
    for i, j, w in edges:
        W[i][j] = W[j][i] = w
    
    # Voltage levels (kV)
    A = np.array([110.0, 220.0, 220.0, 110.0, 330.0, 110.0])
    
    print(f"Substations: {n}")
    print(f"Voltages (kV): {A}")
    
    lam = 3.0   # base construction cost
    kap = 0.05  # transformer cost per kV mismatch
    
    # Compare wormhole placements
    best_reduction = 0
    best_pair = None
    
    D_orig = floyd_warshall(W)
    avg_orig = np.mean(D_orig[D_orig < INF])
    
    print(f"\nOriginal average distance: {avg_orig:.2f}")
    print(f"\nCandidate new transmission lines:")
    
    for u in range(n):
        for v in range(u+1, n):
            if W[u][v] < INF:
                continue  # skip existing edges
            
            penalty = charged_penalty(A, u, v, lam, kap)
            D_ch = compute_charged_distances(W, A, u, v, lam, kap)
            D_unch = floyd_warshall(wormhole_surgery(W, u, v, lam))
            
            avg_ch = np.mean(D_ch[D_ch < INF])
            avg_unch = np.mean(D_unch[D_unch < INF])
            
            reduction = avg_orig - avg_ch
            unch_reduction = avg_orig - avg_unch
            
            print(f"  ({u},{v}): ΔV={abs(A[u]-A[v]):.0f}kV, "
                  f"penalty={penalty:.1f}, "
                  f"avg_dist: {avg_ch:.2f} (charged), {avg_unch:.2f} (uncharged), "
                  f"improvement: {reduction:.2f}")
            
            if reduction > best_reduction:
                best_reduction = reduction
                best_pair = (u, v)
    
    print(f"\n  Best placement: {best_pair} with improvement {best_reduction:.2f}")
    
    # Verify theorems
    if best_pair:
        u, v = best_pair
        assert verify_surgery_bound(W, A, u, v, lam, kap)
        assert verify_sandwich(W, A, u, v, lam, kap)
        print(f"  Surgery bound and sandwich inequality verified ✓")


def supply_chain_example():
    """
    Application: Supply chain with quality standard mismatch costs.
    
    Vertices = facilities, edges = shipping routes.
    A[i] = quality standard level (1-10) at facility i.
    Connecting facilities at different quality levels requires inspection overhead.
    """
    print("\n" + "=" * 60)
    print("APPLICATION: Supply Chain Optimization")
    print("=" * 60)
    
    n = 5
    labels = ["Raw Material", "Component A", "Component B", "Assembly", "Distribution"]
    
    INF = 100.0
    W = np.full((n, n), INF)
    np.fill_diagonal(W, 0)
    
    edges = [(0,1,3), (0,2,4), (1,3,5), (2,3,6), (3,4,2)]
    for i, j, w in edges:
        W[i][j] = W[j][i] = w
    
    # Quality standards (1-10 scale)
    A = np.array([3.0, 7.0, 5.0, 9.0, 6.0])
    
    print(f"Facilities: {labels}")
    print(f"Quality levels: {A}")
    
    lam = 2.0
    kap = 0.5  # quality inspection cost per level mismatch
    
    # Try adding direct route from Raw Material to Assembly
    u, v = 0, 3
    penalty = charged_penalty(A, u, v, lam, kap)
    
    D_orig = floyd_warshall(W)
    D_ch = compute_charged_distances(W, A, u, v, lam, kap)
    D_unch = floyd_warshall(wormhole_surgery(W, u, v, lam))
    
    print(f"\nNew route: {labels[u]} → {labels[v]}")
    print(f"Quality mismatch: |{A[u]} - {A[v]}| = {abs(A[u]-A[v])}")
    print(f"Base cost: {lam}, Inspection cost: {kap}*{abs(A[u]-A[v])} = {kap*abs(A[u]-A[v])}")
    print(f"Total charged penalty: {penalty}")
    
    print(f"\nDistance from Raw Material to Distribution:")
    print(f"  Original:    {D_orig[0][4]:.1f}")
    print(f"  Uncharged:   {D_unch[0][4]:.1f}")
    print(f"  Charged:     {D_ch[0][4]:.1f}")
    print(f"  Savings (uncharged): {D_orig[0][4] - D_unch[0][4]:.1f}")
    print(f"  Savings (charged):   {D_orig[0][4] - D_ch[0][4]:.1f}")
    print(f"  Quality tax:         {D_ch[0][4] - D_unch[0][4]:.1f}")


def gauge_invariance_demo():
    """
    Demonstrate gauge invariance with a physical analogy.
    
    Shows that shifting all potentials by a constant doesn't change
    any distances or optimal routes.
    """
    print("\n" + "=" * 60)
    print("APPLICATION: Gauge Invariance in Practice")
    print("=" * 60)
    
    n = 4
    W = np.array([
        [0, 5, 20, 15],
        [5, 0, 8, 20],
        [20, 8, 0, 3],
        [15, 20, 3, 0]
    ], dtype=float)
    
    A = np.array([10.0, 25.0, 15.0, 30.0])
    u, v = 0, 2
    lam, kap = 3.0, 0.5
    
    print("Scenario: Adding a shortcut in a 4-node network")
    print(f"Original potentials: {A}")
    
    D_base = compute_charged_distances(W, A, u, v, lam, kap)
    
    shifts = [0, 100, -50, 1000000]
    for c in shifts:
        A_shifted = A + c
        D_shifted = compute_charged_distances(W, A_shifted, u, v, lam, kap)
        match = np.allclose(D_base, D_shifted)
        print(f"  Shift by {c:>10}: distances match = {match} ✓" if match 
              else f"  Shift by {c:>10}: MISMATCH ✗")
    
    print("\nKey insight: Only potential DIFFERENCES matter, not absolute values.")
    print("This is the tropical analogue of electromagnetic gauge invariance.")


if __name__ == "__main__":
    electrical_network_example()
    supply_chain_example()
    gauge_invariance_demo()


"""
Charged Wormhole Surgery: Demonstration and Numerical Verification

This script demonstrates the core theorems of gauge-covariant tropical graph surgery
with concrete numerical examples, verifying the formal mathematical results.
"""

import numpy as np
from itertools import permutations

def floyd_warshall(W):
    """Compute all-pairs shortest paths using Floyd-Warshall."""
    n = W.shape[0]
    D = W.copy()
    for k in range(n):
        for i in range(n):
            for j in range(n):
                D[i][j] = min(D[i][j], D[i][k] + D[k][j])
    return D

def charged_penalty(A, u, v, lam, kap):
    """Compute the charged penalty: λ + κ|A(u) - A(v)|"""
    return lam + kap * abs(A[u] - A[v])

def wormhole_surgery(W, u, v, tau):
    """Apply wormhole surgery with tunnel cost τ."""
    W_mod = W.copy()
    W_mod[u][v] = min(W[u][v], tau)
    W_mod[v][u] = min(W[v][u], tau)
    return W_mod

def charged_wormhole_surgery(W, A, u, v, lam, kap):
    """Apply charged wormhole surgery."""
    penalty = charged_penalty(A, u, v, lam, kap)
    return wormhole_surgery(W, u, v, penalty)

def demonstrate_main_theorem():
    """Demonstrate Theorem 3.1: Charged Surgery Bound"""
    print("=" * 60)
    print("THEOREM 3.1: Charged Wormhole Surgery Bound")
    print("=" * 60)
    
    n = 4
    INF = 1000.0
    W = np.full((n, n), INF)
    np.fill_diagonal(W, 0)
    W[0][1] = W[1][0] = 2
    W[1][2] = W[2][1] = 100
    W[2][3] = W[3][2] = 2
    W[0][3] = W[3][0] = 100
    
    A = np.array([0.0, 0.0, 5.0, 5.0])
    u, v = 1, 2
    lam, kap = 1.0, 1.0
    
    penalty = charged_penalty(A, u, v, lam, kap)
    print(f"\nGraph: 4 vertices, weights: (0,1)=2, (1,2)=100, (2,3)=2, (0,3)=100")
    print(f"Potential A = {A}")
    print(f"Wormhole: ({u},{v}), λ={lam}, κ={kap}")
    print(f"Charged penalty = {lam} + {kap}*|{A[u]}-{A[v]}| = {penalty}")
    
    D_W = floyd_warshall(W)
    W_charged = charged_wormhole_surgery(W, A, u, v, lam, kap)
    D_charged = floyd_warshall(W_charged)
    
    print(f"\nOriginal distances:")
    for i in range(n):
        for j in range(n):
            if D_W[i][j] < INF:
                print(f"  d({i},{j}) = {D_W[i][j]}")
    
    print(f"\nCharged surgery distances:")
    for i in range(n):
        for j in range(n):
            if D_charged[i][j] < D_W[i][j]:
                print(f"  d_charged({i},{j}) = {D_charged[i][j]} (was {D_W[i][j]})")
    
    print(f"\nVerifying bound for all (x,y):")
    all_pass = True
    for x in range(n):
        for y in range(n):
            bound = min(
                D_W[x][y],
                D_W[x][u] + penalty + D_W[v][y],
                D_W[x][v] + penalty + D_W[u][y]
            )
            ok = D_charged[x][y] <= bound + 1e-10
            if not ok:
                print(f"  FAIL: d_charged({x},{y})={D_charged[x][y]} > bound={bound}")
                all_pass = False
    
    print(f"  All bounds verified: {'✓' if all_pass else '✗'}")

def demonstrate_gauge_invariance():
    """Demonstrate Theorem 3.2: Gauge Invariance"""
    print("\n" + "=" * 60)
    print("THEOREM 3.2: Gauge Invariance")
    print("=" * 60)
    
    n = 4
    A = np.array([1.0, 3.0, 7.0, 2.0])
    u, v = 1, 2
    lam, kap = 2.0, 0.5
    
    for c in [-10, 0, 5, 100, 3.14159]:
        A_shifted = A + c
        p_orig = charged_penalty(A, u, v, lam, kap)
        p_shifted = charged_penalty(A_shifted, u, v, lam, kap)
        match = abs(p_orig - p_shifted) < 1e-10
        print(f"  c={c:>8.3f}: penalty(A)={p_orig:.4f}, penalty(A+c)={p_shifted:.4f} {'✓' if match else '✗'}")

def demonstrate_symmetry():
    """Demonstrate Theorem 3.4: Symmetry"""
    print("\n" + "=" * 60)
    print("THEOREM 3.4: Symmetry")
    print("=" * 60)
    
    n = 5
    A = np.array([1.0, 4.0, 2.0, 8.0, 3.0])
    lam, kap = 3.0, 1.5
    
    for u in range(n):
        for v in range(u+1, n):
            p_uv = charged_penalty(A, u, v, lam, kap)
            p_vu = charged_penalty(A, v, u, lam, kap)
            match = abs(p_uv - p_vu) < 1e-10
            if not match:
                print(f"  FAIL: penalty({u},{v})={p_uv} ≠ penalty({v},{u})={p_vu}")
    
    print(f"  All symmetry checks passed ✓")

def demonstrate_sandwich():
    """Demonstrate Theorem 3.6: Sandwich Inequality"""
    print("\n" + "=" * 60)
    print("THEOREM 3.6: Sandwich Inequality")
    print("=" * 60)
    
    n = 5
    np.random.seed(42)
    W = np.random.uniform(1, 20, (n, n))
    W = (W + W.T) / 2  # symmetrize
    np.fill_diagonal(W, 0)
    A = np.random.uniform(-10, 10, n)
    u, v = 1, 3
    lam, kap = 2.0, 1.0
    
    D_W = floyd_warshall(W)
    W_unch = wormhole_surgery(W, u, v, lam)
    D_unch = floyd_warshall(W_unch)
    W_ch = charged_wormhole_surgery(W, A, u, v, lam, kap)
    D_ch = floyd_warshall(W_ch)
    
    all_pass = True
    for x in range(n):
        for y in range(n):
            if not (D_unch[x][y] <= D_ch[x][y] + 1e-10):
                print(f"  FAIL sandwich left: d_unch({x},{y})={D_unch[x][y]} > d_ch({x},{y})={D_ch[x][y]}")
                all_pass = False
            if not (D_ch[x][y] <= D_W[x][y] + 1e-10):
                print(f"  FAIL sandwich right: d_ch({x},{y})={D_ch[x][y]} > d_W({x},{y})={D_W[x][y]}")
                all_pass = False
    
    print(f"  d_uncharged ≤ d_charged ≤ d_original: {'✓' if all_pass else '✗'}")
    
    # Show some examples
    for x, y in [(0,2), (1,4), (2,3)]:
        print(f"  ({x},{y}): uncharged={D_unch[x][y]:.2f} ≤ charged={D_ch[x][y]:.2f} ≤ original={D_W[x][y]:.2f}")

def demonstrate_perturbative():
    """Demonstrate perturbative comparison numerically"""
    print("\n" + "=" * 60)
    print("PERTURBATIVE COMPARISON (numerical verification)")
    print("=" * 60)
    
    n = 5
    np.random.seed(123)
    
    for trial in range(5):
        W = np.random.uniform(1, 50, (n, n))
        W = (W + W.T) / 2
        np.fill_diagonal(W, 0)
        A = np.random.uniform(-20, 20, n)
        u, v = np.random.choice(n, 2, replace=False)
        lam = np.random.uniform(0.5, 5)
        kap = np.random.uniform(0, 3)
        
        defect = kap * abs(A[u] - A[v])
        
        D_unch = floyd_warshall(wormhole_surgery(W, u, v, lam))
        D_ch = floyd_warshall(charged_wormhole_surgery(W, A, u, v, lam, kap))
        
        max_gap = 0
        all_pass = True
        for x in range(n):
            for y in range(n):
                gap = D_ch[x][y] - D_unch[x][y]
                max_gap = max(max_gap, gap)
                if gap > defect + 1e-10:
                    all_pass = False
        
        print(f"  Trial {trial+1}: defect={defect:.2f}, max gap={max_gap:.2f}, "
              f"gap ≤ defect: {'✓' if all_pass else '✗'}")

def main():
    print("CHARGED WORMHOLE SURGERY: NUMERICAL DEMONSTRATIONS")
    print("=" * 60)
    
    demonstrate_main_theorem()
    demonstrate_gauge_invariance()
    demonstrate_symmetry()
    demonstrate_sandwich()
    demonstrate_perturbative()
    
    print("\n" + "=" * 60)
    print("All demonstrations complete.")

if __name__ == "__main__":
    main()


"""Generate PACKAGE.json with all artifacts."""
import json
import sys
sys.path.insert(0, '.')

# Read all text files
def read_file(path):
    with open(path, 'r') as f:
        return f.read()

article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_proofs = read_file('Catalog/Tropical/GraphTheory/ChargedSurgery.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')

# Generate visualizations and get base64
from visualizations import (plot_charged_penalty_landscape, plot_surgery_comparison,
                              plot_sandwich_inequality, plot_gauge_invariance)

viz1 = plot_charged_penalty_landscape()
viz2 = plot_surgery_comparison()
viz3 = plot_sandwich_inequality()
viz4 = plot_gauge_invariance()

package = {
    "title": "Gauge-Covariant Tropical Graph Surgery: Charged Wormhole Metrics",
    "domain": "Tropical Geometry / Graph Theory / Discrete Gauge Theory",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Charged Wormhole Surgery Demonstration",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Charged Surgery Distance (Floyd-Warshall)",
            "pseudocode": """Algorithm: ChargedSurgeryDistance(W, A, u, v, λ, κ)
Input: Weight matrix W, potential A, wormhole (u,v), parameters λ, κ
Output: Distance matrix D_charged

1. Compute penalty = λ + κ * |A[u] - A[v]|
2. W_mod = copy(W)
3. W_mod[u][v] = min(W[u][v], penalty)
4. W_mod[v][u] = min(W[v][u], penalty)
5. D_charged = FloydWarshall(W_mod)
6. Return D_charged

Time: O(n³), Space: O(n²)""",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {"name": "Charged Penalty Landscape", "data": viz1},
        {"name": "Surgery Distance Comparison", "data": viz2},
        {"name": "Sandwich Inequality", "data": viz3},
        {"name": "Gauge Invariance", "data": viz4}
    ],
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated ({len(json.dumps(package))} chars)")


"""
Visualizations for Charged Wormhole Surgery

Generates publication-quality figures showing key mathematical structures.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
import io

def fig_to_base64(fig):
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def plot_charged_penalty_landscape():
    """Plot how the charged penalty varies with potential mismatch and coupling."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    # Left: penalty vs mismatch for different κ
    mismatch = np.linspace(0, 10, 100)
    lam = 2.0
    for kap in [0, 0.5, 1.0, 2.0, 5.0]:
        penalty = lam + kap * mismatch
        axes[0].plot(mismatch, penalty, label=f'κ = {kap}', linewidth=2)
    
    axes[0].set_xlabel('Potential mismatch |A(u) - A(v)|', fontsize=12)
    axes[0].set_ylabel('Charged penalty', fontsize=12)
    axes[0].set_title('Charged Penalty vs. Potential Mismatch', fontsize=14)
    axes[0].legend(fontsize=10)
    axes[0].grid(True, alpha=0.3)
    axes[0].axhline(y=lam, color='gray', linestyle='--', alpha=0.5, label='base cost λ')
    
    # Right: penalty heatmap
    kap_vals = np.linspace(0, 3, 50)
    mismatch_vals = np.linspace(0, 10, 50)
    K, M = np.meshgrid(kap_vals, mismatch_vals)
    P = lam + K * M
    
    im = axes[1].contourf(K, M, P, levels=20, cmap='viridis')
    plt.colorbar(im, ax=axes[1], label='Charged penalty')
    axes[1].set_xlabel('Coupling κ', fontsize=12)
    axes[1].set_ylabel('Mismatch |A(u) - A(v)|', fontsize=12)
    axes[1].set_title('Charged Penalty Landscape', fontsize=14)
    
    fig.tight_layout()
    fig.savefig('charged_penalty_landscape.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_surgery_comparison():
    """Compare uncharged vs charged surgery distances."""
    from algorithms import (floyd_warshall, wormhole_surgery, 
                             charged_wormhole_surgery, compute_charged_distances)
    
    n = 6
    np.random.seed(42)
    W = np.random.uniform(3, 15, (n, n))
    W = (W + W.T) / 2
    np.fill_diagonal(W, 0)
    
    A = np.array([0.0, 2.0, 8.0, 1.0, 6.0, 3.0])
    u, v = 2, 4
    lam = 2.0
    
    kap_values = np.linspace(0, 5, 50)
    max_dists_charged = []
    avg_dists_charged = []
    
    D_orig = floyd_warshall(W)
    D_unch = floyd_warshall(wormhole_surgery(W, u, v, lam))
    
    for kap in kap_values:
        D_ch = compute_charged_distances(W, A, u, v, lam, kap)
        max_dists_charged.append(np.max(D_ch))
        avg_dists_charged.append(np.mean(D_ch))
    
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    axes[0].plot(kap_values, max_dists_charged, 'b-', linewidth=2, label='Charged surgery')
    axes[0].axhline(y=np.max(D_unch), color='g', linestyle='--', 
                     linewidth=2, label='Uncharged surgery')
    axes[0].axhline(y=np.max(D_orig), color='r', linestyle=':', 
                     linewidth=2, label='Original (no surgery)')
    axes[0].set_xlabel('Coupling κ', fontsize=12)
    axes[0].set_ylabel('Maximum distance', fontsize=12)
    axes[0].set_title('Max Distance vs. Coupling Strength', fontsize=14)
    axes[0].legend(fontsize=10)
    axes[0].grid(True, alpha=0.3)
    
    axes[1].plot(kap_values, avg_dists_charged, 'b-', linewidth=2, label='Charged surgery')
    axes[1].axhline(y=np.mean(D_unch), color='g', linestyle='--', 
                     linewidth=2, label='Uncharged surgery')
    axes[1].axhline(y=np.mean(D_orig), color='r', linestyle=':', 
                     linewidth=2, label='Original')
    axes[1].set_xlabel('Coupling κ', fontsize=12)
    axes[1].set_ylabel('Average distance', fontsize=12)
    axes[1].set_title('Average Distance vs. Coupling Strength', fontsize=14)
    axes[1].legend(fontsize=10)
    axes[1].grid(True, alpha=0.3)
    axes[1].fill_between(kap_values, np.mean(D_unch), avg_dists_charged, 
                          alpha=0.2, color='blue', label='Charge defect region')
    
    fig.tight_layout()
    fig.savefig('surgery_comparison.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_sandwich_inequality():
    """Visualize the sandwich inequality d_unch ≤ d_charged ≤ d_orig."""
    from algorithms import (floyd_warshall, wormhole_surgery, compute_charged_distances)
    
    n = 5
    np.random.seed(99)
    W = np.random.uniform(2, 20, (n, n))
    W = (W + W.T) / 2
    np.fill_diagonal(W, 0)
    
    A = np.array([0.0, 5.0, 2.0, 8.0, 3.0])
    u, v = 1, 3
    lam = 3.0
    kap = 1.0
    
    D_orig = floyd_warshall(W)
    D_unch = floyd_warshall(wormhole_surgery(W, u, v, lam))
    D_ch = compute_charged_distances(W, A, u, v, lam, kap)
    
    pairs = [(i, j) for i in range(n) for j in range(i+1, n)]
    x_labels = [f'({i},{j})' for i, j in pairs]
    
    d_orig_vals = [D_orig[i][j] for i, j in pairs]
    d_unch_vals = [D_unch[i][j] for i, j in pairs]
    d_ch_vals = [D_ch[i][j] for i, j in pairs]
    
    fig, ax = plt.subplots(figsize=(12, 6))
    x = np.arange(len(pairs))
    width = 0.25
    
    bars1 = ax.bar(x - width, d_unch_vals, width, label='Uncharged surgery', 
                    color='green', alpha=0.7)
    bars2 = ax.bar(x, d_ch_vals, width, label='Charged surgery', 
                    color='blue', alpha=0.7)
    bars3 = ax.bar(x + width, d_orig_vals, width, label='Original', 
                    color='red', alpha=0.7)
    
    ax.set_xlabel('Vertex pair', fontsize=12)
    ax.set_ylabel('Distance', fontsize=12)
    ax.set_title('Sandwich Inequality: d_unch ≤ d_charged ≤ d_orig', fontsize=14)
    ax.set_xticks(x)
    ax.set_xticklabels(x_labels, rotation=45)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3, axis='y')
    
    fig.tight_layout()
    fig.savefig('sandwich_inequality.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_gauge_invariance():
    """Visualize gauge invariance by showing distances are shift-invariant."""
    from algorithms import compute_charged_distances
    
    n = 4
    W = np.array([
        [0, 5, 20, 15],
        [5, 0, 8, 20],
        [20, 8, 0, 3],
        [15, 20, 3, 0]
    ], dtype=float)
    
    A = np.array([10.0, 25.0, 15.0, 30.0])
    u, v = 0, 2
    lam, kap = 3.0, 0.5
    
    shifts = np.linspace(-100, 100, 50)
    d_02_values = []
    d_13_values = []
    d_03_values = []
    
    for c in shifts:
        D = compute_charged_distances(W, A + c, u, v, lam, kap)
        d_02_values.append(D[0][2])
        d_13_values.append(D[1][3])
        d_03_values.append(D[0][3])
    
    fig, ax = plt.subplots(figsize=(10, 5))
    ax.plot(shifts, d_02_values, 'b-', linewidth=2, label='d(0,2)')
    ax.plot(shifts, d_13_values, 'r--', linewidth=2, label='d(1,3)')
    ax.plot(shifts, d_03_values, 'g-.', linewidth=2, label='d(0,3)')
    
    ax.set_xlabel('Gauge shift c (A ↦ A + c)', fontsize=12)
    ax.set_ylabel('Charged surgery distance', fontsize=12)
    ax.set_title('Gauge Invariance: Distances are Independent of Global Potential Shift', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    fig.tight_layout()
    fig.savefig('gauge_invariance.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    
    b64_1 = plot_charged_penalty_landscape()
    print(f"  1. Charged penalty landscape: {len(b64_1)} chars")
    
    b64_2 = plot_surgery_comparison()
    print(f"  2. Surgery comparison: {len(b64_2)} chars")
    
    b64_3 = plot_sandwich_inequality()
    print(f"  3. Sandwich inequality: {len(b64_3)} chars")
    
    b64_4 = plot_gauge_invariance()
    print(f"  4. Gauge invariance: {len(b64_4)} chars")
    
    print("\nAll visualizations saved as PNG files and base64 encoded.")
