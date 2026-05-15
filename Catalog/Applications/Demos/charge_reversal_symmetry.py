#!/usr/bin/env python3
"""
Applications of Charge-Reversal Symmetry

Demonstrates real-world applications of the charge-reversal duality:
1. Directed graph edge reversal
2. Game theory: minimax duality
3. Network flow symmetry
4. Optimization: primal-dual exchange
"""

import numpy as np

def charged_weight(W, A, q):
    return W + q * (A - A.T)

def trop_mat_dist(M, N):
    return float(np.max(np.abs(M - N)))

# ============================================================
# Application 1: Directed Graph Edge Reversal
# ============================================================

def app_directed_graph():
    """
    In a directed weighted graph, the adjacency matrix A[i,j] gives
    the weight of edge i -> j. Transposing A reverses all edges.
    
    Charge-reversal symmetry says: deforming edge weights by charge q
    and then reversing all edges is the same as deforming by charge -q.
    
    This has implications for:
    - Shortest path problems (reversed graphs have dual solutions)
    - Network flow (forward flow ~ backward flow under charge duality)
    """
    print("=" * 60)
    print("APPLICATION 1: Directed Graph Edge Reversal")
    print("=" * 60)
    
    # A small directed graph (4 nodes)
    # W = symmetric base costs, A = asymmetric perturbation
    W = np.array([
        [0, 2, 5, 1],
        [2, 0, 3, 4],
        [5, 3, 0, 2],
        [1, 4, 2, 0]
    ], dtype=float)  # symmetric base
    
    A = np.array([
        [0, 1, 0, 2],
        [3, 0, 1, 0],
        [0, 2, 0, 1],
        [1, 0, 3, 0]
    ], dtype=float)  # asymmetric perturbation
    
    q = 0.5
    
    forward = charged_weight(W, A, q)
    reversed_graph = charged_weight(W, A, -q)
    
    print(f"\nBase graph (symmetric costs):\n{W}")
    print(f"\nForward graph (q={q}):\n{forward}")
    print(f"\nReversed graph (q={-q}):\n{reversed_graph}")
    print(f"\nVerification: forward^T = reversed?")
    print(f"  max error = {np.max(np.abs(forward.T - reversed_graph)):.2e}")
    
    # The shortest path from node 0 to node 3 in the forward graph
    # corresponds to the shortest path from 3 to 0 in the reversed graph
    print(f"\nInterpretation: shortest paths in the forward graph")
    print(f"correspond to reversed shortest paths in the charge-dual graph.")
    print()

# ============================================================
# Application 2: Game Theory - Minimax Duality
# ============================================================

def app_game_theory():
    """
    In a two-player zero-sum game, the payoff matrix M[i,j] gives
    the payoff to the row player when row i and column j are chosen.
    
    Transposing the matrix swaps the roles of the two players.
    Charge-reversal symmetry provides a parameterized family of games
    where swapping players is equivalent to reversing the charge.
    """
    print("=" * 60)
    print("APPLICATION 2: Game Theory - Minimax Duality")
    print("=" * 60)
    
    # Base payoff (symmetric: fair game)
    W = np.array([
        [0, 3, 1],
        [3, 0, 2],
        [1, 2, 0]
    ], dtype=float)
    
    # Asymmetric advantage
    A = np.array([
        [0, 2, 1],
        [0, 0, 3],
        [0, 0, 0]
    ], dtype=float)
    
    print(f"\nBase payoff (symmetric):\n{W}")
    
    for q in [0.0, 0.5, 1.0, -1.0]:
        game = charged_weight(W, A, q)
        # Minimax value approximation
        row_mins = np.min(game, axis=1)
        maximin = np.max(row_mins)
        col_maxs = np.max(game, axis=0)
        minimax = np.min(col_maxs)
        
        # For the dual game (charge -q)
        dual_game = charged_weight(W, A, -q)
        dual_row_mins = np.min(dual_game, axis=1)
        dual_maximin = np.max(dual_row_mins)
        
        print(f"\n  q = {q:5.1f}: maximin = {maximin:.2f}, minimax = {minimax:.2f}")
        print(f"          dual maximin = {dual_maximin:.2f}")
        print(f"          game^T = dual? error = {np.max(np.abs(game.T - dual_game)):.2e}")
    print()

# ============================================================
# Application 3: Network Flow Symmetry
# ============================================================

def app_network_flow():
    """
    In a network flow problem, capacity[i,j] is the capacity of edge i->j.
    Charge deformation creates asymmetric capacities from symmetric base.
    
    Charge reversal swaps forward/backward capacity, corresponding to
    reversing the flow direction in the network.
    """
    print("=" * 60)
    print("APPLICATION 3: Network Flow Symmetry")
    print("=" * 60)
    
    # Base capacity (symmetric: bidirectional pipes)
    W = np.array([
        [0, 10, 0, 0],
        [10, 0, 8, 5],
        [0, 8, 0, 12],
        [0, 5, 12, 0]
    ], dtype=float)
    
    # Directional preference
    A = np.array([
        [0, 2, 0, 0],
        [0, 0, 3, 1],
        [0, 0, 0, 2],
        [0, 0, 0, 0]
    ], dtype=float)
    
    q = 1.0
    
    forward_cap = charged_weight(W, A, q)
    reverse_cap = charged_weight(W, A, -q)
    
    print(f"\nForward capacities (q={q}):")
    print(forward_cap)
    print(f"\nReverse capacities (q={-q}):")
    print(reverse_cap)
    print(f"\nForward^T = Reverse? max error = {np.max(np.abs(forward_cap.T - reverse_cap)):.2e}")
    
    # Total outgoing capacity from each node
    print(f"\nTotal outgoing capacity per node:")
    print(f"  Forward: {np.sum(forward_cap, axis=1)}")
    print(f"  Reverse: {np.sum(reverse_cap, axis=1)}")
    print(f"  (Reverse outgoing = Forward incoming, by transpose duality)")
    print()

# ============================================================
# Application 4: Optimization Primal-Dual
# ============================================================

def app_optimization():
    """
    In tropical optimization, the primal problem involves minimizing
    over rows and the dual involves minimizing over columns.
    
    Charge reversal connects primal and dual through transpose,
    providing a systematic way to convert primal solutions to dual.
    """
    print("=" * 60)
    print("APPLICATION 4: Tropical Optimization Duality")
    print("=" * 60)
    
    np.random.seed(42)
    n = 4
    W = np.random.randn(n, n)
    W = (W + W.T) / 2  # Symmetric
    A = np.random.randn(n, n)
    
    for q in [0.0, 1.0, 2.0]:
        cost = charged_weight(W, A, q)
        dual_cost = charged_weight(W, A, -q)
        
        # "Tropical assignment": max over permutations of sum of entries
        # This is simplified: just row-minimum sum as a proxy
        primal_val = np.sum(np.min(cost, axis=1))
        dual_val = np.sum(np.min(dual_cost, axis=1))
        
        # By charge-reversal: dual_cost = cost^T
        # So minimizing over rows in dual = minimizing over columns in primal
        primal_col = np.sum(np.min(cost, axis=0))
        
        print(f"  q = {q:.1f}:")
        print(f"    Primal (row-min sum)  = {primal_val:.4f}")
        print(f"    Dual   (row-min sum)  = {dual_val:.4f}")
        print(f"    Primal (col-min sum)  = {primal_col:.4f}")
        print(f"    dual row-min = primal col-min? error = {abs(dual_val - primal_col):.2e}")
    print()


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  CHARGE-REVERSAL SYMMETRY: APPLICATIONS")
    print("=" * 60 + "\n")
    
    app_directed_graph()
    app_game_theory()
    app_network_flow()
    app_optimization()
    
    print("=" * 60)
    print("  ALL APPLICATIONS COMPLETE")
    print("=" * 60)


#!/usr/bin/env python3
"""
Charge-Reversal Symmetry: Numerical Demonstrations

Demonstrates the key theorems:
1. chargedWeight(W, A, q)^T = chargedWeight(W^T, A, -q)
2. For symmetric W: chargedWeight(W, A, q)^T = chargedWeight(W, A, -q)
3. Tropical distance invariance under charge reversal
4. Spectral radius invariance under charge reversal
"""

import numpy as np

def charged_weight(W: np.ndarray, A: np.ndarray, q: float) -> np.ndarray:
    """
    Compute the charged weight matrix.
    
    chargedWeight(W, A, q)[i,j] = W[i,j] + q * (A[i,j] - A[j,i])
    
    The antisymmetrization A[i,j] - A[j,i] ensures the perturbation
    reverses sign under transpose, enabling charge-reversal symmetry.
    """
    antisymm = A - A.T
    return W + q * antisymm

def trop_mat_dist(M: np.ndarray, N: np.ndarray) -> float:
    """
    Tropical (L-infinity) matrix distance.
    
    tropMatDist(M, N) = max_{i,j} |M[i,j] - N[i,j]|
    """
    return np.max(np.abs(M - N))

def trop_spec_radius(M: np.ndarray) -> float:
    """
    Tropical spectral radius: maximum diagonal entry.
    
    tropSpecRadius(M) = max_i M[i,i]
    """
    return np.max(np.diag(M))

def demo_core_theorem():
    """Demonstrate: (chargedWeight W A q)^T = chargedWeight(W^T, A, -q)"""
    print("=" * 60)
    print("THEOREM 1: Core Charge-Reversal Identity")
    print("  (chargedWeight W A q)^T = chargedWeight(W^T, A, -q)")
    print("=" * 60)
    
    np.random.seed(42)
    n = 4
    W = np.random.randn(n, n)
    A = np.random.randn(n, n)
    
    for q in [-2.0, -0.5, 0.0, 0.5, 1.0, 3.14]:
        lhs = charged_weight(W, A, q).T
        rhs = charged_weight(W.T, A, -q)
        error = np.max(np.abs(lhs - rhs))
        print(f"  q = {q:6.2f}  |  max error = {error:.2e}  |  {'PASS' if error < 1e-14 else 'FAIL'}")
    print()

def demo_symmetric_theorem():
    """Demonstrate: For symmetric W, (chargedWeight W A q)^T = chargedWeight(W, A, -q)"""
    print("=" * 60)
    print("THEOREM 2: Symmetric Base Charge-Reversal")
    print("  W symmetric => (chargedWeight W A q)^T = chargedWeight(W, A, -q)")
    print("=" * 60)
    
    np.random.seed(123)
    n = 5
    W_raw = np.random.randn(n, n)
    W = (W_raw + W_raw.T) / 2  # Make symmetric
    A = np.random.randn(n, n)
    
    print(f"  W is symmetric: {np.allclose(W, W.T)}")
    
    for q in [-1.0, 0.0, 0.5, 2.0]:
        lhs = charged_weight(W, A, q).T
        rhs = charged_weight(W, A, -q)
        error = np.max(np.abs(lhs - rhs))
        print(f"  q = {q:6.2f}  |  max error = {error:.2e}  |  {'PASS' if error < 1e-14 else 'FAIL'}")
    print()

def demo_involutivity():
    """Demonstrate: chargedWeight(W, A, -(-q)) = chargedWeight(W, A, q)"""
    print("=" * 60)
    print("THEOREM 3: Charge Reversal is Involutive")
    print("  chargedWeight(W, A, -(-q)) = chargedWeight(W, A, q)")
    print("=" * 60)
    
    np.random.seed(7)
    n = 3
    W = np.random.randn(n, n)
    A = np.random.randn(n, n)
    
    for q in [-3.0, -1.0, 0.0, 1.0, 3.0]:
        lhs = charged_weight(W, A, -(-q))
        rhs = charged_weight(W, A, q)
        error = np.max(np.abs(lhs - rhs))
        print(f"  q = {q:6.2f}  |  max error = {error:.2e}  |  {'PASS' if error < 1e-14 else 'FAIL'}")
    print()

def demo_distance_invariance():
    """Demonstrate tropical distance invariance under charge reversal."""
    print("=" * 60)
    print("THEOREM 4: Tropical Distance Invariance")
    print("  tropDist(cW(W,A,q), cW(W,B,q)) = tropDist(cW(W,A,-q), cW(W,B,-q))")
    print("  (for symmetric W)")
    print("=" * 60)
    
    np.random.seed(99)
    n = 4
    W_raw = np.random.randn(n, n)
    W = (W_raw + W_raw.T) / 2
    A = np.random.randn(n, n)
    B = np.random.randn(n, n)
    
    for q in [-2.0, -0.5, 0.0, 1.0, 5.0]:
        d_pos = trop_mat_dist(charged_weight(W, A, q), charged_weight(W, B, q))
        d_neg = trop_mat_dist(charged_weight(W, A, -q), charged_weight(W, B, -q))
        error = abs(d_pos - d_neg)
        print(f"  q = {q:6.2f}  |  d(q) = {d_pos:.6f}  d(-q) = {d_neg:.6f}  |  diff = {error:.2e}  |  {'PASS' if error < 1e-14 else 'FAIL'}")
    print()

def demo_spectral_invariance():
    """Demonstrate tropical spectral radius invariance."""
    print("=" * 60)
    print("THEOREM 5: Spectral Radius Invariance")
    print("  tropSpecRadius(chargedWeight(W, A, q)) = tropSpecRadius(W)")
    print("  (independent of q and A!)")
    print("=" * 60)
    
    np.random.seed(55)
    n = 5
    W = np.random.randn(n, n)
    A = np.random.randn(n, n)
    base_radius = trop_spec_radius(W)
    
    print(f"  tropSpecRadius(W) = {base_radius:.6f}")
    for q in [-10.0, -1.0, 0.0, 1.0, 10.0]:
        cw = charged_weight(W, A, q)
        radius = trop_spec_radius(cw)
        error = abs(radius - base_radius)
        print(f"  q = {q:6.1f}  |  tropSpecRadius = {radius:.6f}  |  diff = {error:.2e}  |  {'PASS' if error < 1e-14 else 'FAIL'}")
    
    print(f"\n  Reason: diagonal entries satisfy chargedWeight(W,A,q)[i,i] = W[i,i]")
    print(f"  because A[i,i] - A[i,i] = 0 for all i.")
    print()

def demo_edge_reversal():
    """Demonstrate the directed graph edge reversal interpretation."""
    print("=" * 60)
    print("THEOREM 6: Edge Reversal = Charge Reversal")
    print("  chargedWeight(W, A, q)[j,i] = chargedWeight(W^T, A, -q)[i,j]")
    print("=" * 60)
    
    np.random.seed(11)
    n = 3
    W = np.random.randn(n, n)
    A = np.random.randn(n, n)
    q = 1.5
    
    cw_q = charged_weight(W, A, q)
    cw_neg = charged_weight(W.T, A, -q)
    
    print(f"  q = {q}")
    print(f"\n  chargedWeight(W, A, q):")
    print(f"  {cw_q}")
    print(f"\n  chargedWeight(W^T, A, -q):")
    print(f"  {cw_neg}")
    print(f"\n  chargedWeight(W, A, q)^T:")
    print(f"  {cw_q.T}")
    
    error = np.max(np.abs(cw_q.T - cw_neg))
    print(f"\n  max |cw(W,A,q)^T - cw(W^T,A,-q)| = {error:.2e}  |  {'PASS' if error < 1e-14 else 'FAIL'}")
    print()
    print("  Interpretation: reversing all edges in a directed weighted graph")
    print("  (transpose) is equivalent to reversing the charge parameter.")
    print()

if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  CHARGE-REVERSAL SYMMETRY: NUMERICAL VERIFICATION")
    print("=" * 60 + "\n")
    
    demo_core_theorem()
    demo_symmetric_theorem()
    demo_involutivity()
    demo_distance_invariance()
    demo_spectral_invariance()
    demo_edge_reversal()
    
    print("=" * 60)
    print("  ALL DEMONSTRATIONS COMPLETE")
    print("=" * 60)


#!/usr/bin/env python3
"""Generate PACKAGE.json with all artifacts embedded."""

import json
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read all content
article = read_file('/workspace/request-project/ARTICLE.md')
research_paper = read_file('/workspace/request-project/RESEARCH_PAPER.md')
future_directions = read_file('/workspace/request-project/FUTURE_DIRECTIONS.md')
lean_proofs = read_file('/workspace/request-project/Catalog/Tropical/ChargeReversalSymmetry.lean')
demo_code = read_file('/workspace/request-project/demo.py')
algorithms_code = read_file('/workspace/request-project/algorithms.py')
applications_code = read_file('/workspace/request-project/applications.py')

# Read visualization data
viz_data = json.loads(read_file('/workspace/request-project/viz_data.json'))

package = {
    "title": "Charge-Reversal Symmetry in Tropical Matrix Geometry",
    "domain": "Tropical Geometry / Matrix Theory",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Charge-Reversal Symmetry Verification",
            "code": demo_code
        },
        {
            "name": "Applications: Directed Graphs, Game Theory, Network Flow",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Charged Weight Matrix",
            "pseudocode": "INPUT: W (n×n base weight), A (n×n perturbation), q (charge)\n1. Compute antisymmetric part: S[i,j] = A[i,j] - A[j,i]\n2. Scale: P = q * S\n3. OUTPUT: W + P",
            "code": "import numpy as np\n\ndef charged_weight(W: np.ndarray, A: np.ndarray, q: float) -> np.ndarray:\n    \"\"\"Charged weight matrix. O(n^2) time and space.\"\"\"\n    return W + q * (A - A.T)\n\ndef charge_reverse(W, A, q):\n    \"\"\"Charge reversal: equivalent to transpose by the main theorem.\"\"\"\n    return charged_weight(W, A, -q)\n\n# Example\nW = np.array([[1, 2, 3], [4, 5, 6], [7, 8, 9]], dtype=float)\nW = (W + W.T) / 2\nA = np.array([[0, 1, -1], [2, 0, 1], [-1, 3, 0]], dtype=float)\nq = 1.5\n\ncw = charged_weight(W, A, q)\nprint('chargedWeight(W, A, q):')\nprint(cw)\nprint('\\nchargedWeight(W, A, -q):')\nprint(charge_reverse(W, A, q))\nprint('\\ncw^T:')\nprint(cw.T)\nprint('\\ncw^T == chargedWeight(W, A, -q)?', np.allclose(cw.T, charge_reverse(W, A, q)))"
        },
        {
            "name": "Tropical Matrix Distance",
            "pseudocode": "INPUT: M, N (n×n matrices)\n1. Compute D[i,j] = |M[i,j] - N[i,j]| for all i,j\n2. OUTPUT: max(D)",
            "code": "import numpy as np\n\ndef trop_mat_dist(M: np.ndarray, N: np.ndarray) -> float:\n    \"\"\"Tropical (L-infinity) matrix distance. O(n^2).\"\"\"\n    return float(np.max(np.abs(M - N)))\n\ndef trop_spec_radius(M: np.ndarray) -> float:\n    \"\"\"Tropical spectral radius. O(n).\"\"\"\n    return float(np.max(np.diag(M)))\n\n# Verify charge-reversal distance invariance\nnp.random.seed(42)\nn = 4\nW = np.random.randn(n, n)\nW = (W + W.T) / 2\nA = np.random.randn(n, n)\nB = np.random.randn(n, n)\n\ndef charged_weight(W, A, q):\n    return W + q * (A - A.T)\n\nfor q in [0.5, 1.0, 2.0, 5.0]:\n    d_pos = trop_mat_dist(charged_weight(W, A, q), charged_weight(W, B, q))\n    d_neg = trop_mat_dist(charged_weight(W, A, -q), charged_weight(W, B, -q))\n    print(f'q={q:4.1f}: d(q)={d_pos:.6f}, d(-q)={d_neg:.6f}, diff={abs(d_pos-d_neg):.2e}')"
        },
        {
            "name": "Verify All Theorems",
            "pseudocode": "INPUT: W, A, q\nFOR EACH theorem:\n  1. Compute LHS and RHS\n  2. Check |LHS - RHS| < epsilon\n  3. Report PASS/FAIL",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Charge Landscape: Entry Values vs. Charge Parameter",
            "data": viz_data["charge_landscape"]
        },
        {
            "name": "Tropical Distance Invariance Under Charge Reversal",
            "data": viz_data["distance_invariance"]
        },
        {
            "name": "Spectral Radius Independence from Charge",
            "data": viz_data["spectral_invariance"]
        },
        {
            "name": "Charged Weight Matrix Heatmaps at Different Charges",
            "data": viz_data["matrix_heatmaps"]
        }
    ],
    "lean_proofs": lean_proofs
}

with open('/workspace/request-project/PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("PACKAGE.json generated successfully.")
print(f"File size: {os.path.getsize('/workspace/request-project/PACKAGE.json') / 1024:.1f} KB")


#!/usr/bin/env python3
"""
Visualizations for Charge-Reversal Symmetry
Generates PNG figures for the research paper and article.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
import base64
import io
import json

def charged_weight(W, A, q):
    return W + q * (A - A.T)

def trop_mat_dist(M, N):
    return float(np.max(np.abs(M - N)))

def trop_spec_radius(M):
    return float(np.max(np.diag(M)))

def fig_to_base64(fig):
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode('utf-8')

def viz_charge_landscape():
    """Visualize how charged weight entries vary with charge q."""
    np.random.seed(42)
    n = 3
    W = np.array([[1, 2, 3], [4, 5, 6], [7, 8, 9]], dtype=float)
    W = (W + W.T) / 2
    A = np.array([[0, 1, -1], [2, 0, 1], [-1, 3, 0]], dtype=float)
    
    q_range = np.linspace(-3, 3, 200)
    
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    pairs = [(0, 1), (0, 2), (1, 2)]
    colors = ['#2196F3', '#F44336']
    
    for ax, (i, j) in zip(axes, pairs):
        vals_ij = [charged_weight(W, A, q)[i, j] for q in q_range]
        vals_ji = [charged_weight(W, A, q)[j, i] for q in q_range]
        
        ax.plot(q_range, vals_ij, color=colors[0], linewidth=2, label=f'entry ({i},{j})')
        ax.plot(q_range, vals_ji, color=colors[1], linewidth=2, linestyle='--', label=f'entry ({j},{i})')
        ax.axvline(x=0, color='gray', linewidth=0.5, linestyle=':')
        ax.axhline(y=W[i,j], color='green', linewidth=0.5, linestyle=':', alpha=0.7, label=f'base W[{i},{j}]')
        ax.set_xlabel('Charge q', fontsize=12)
        ax.set_ylabel('Weight value', fontsize=12)
        ax.set_title(f'Entries ({i},{j}) and ({j},{i})', fontsize=13)
        ax.legend(fontsize=10)
        ax.grid(True, alpha=0.3)
        
        # Mark the mirror symmetry
        ax.annotate('', xy=(1.5, vals_ij[150]), xytext=(-1.5, vals_ij[50]),
                    arrowprops=dict(arrowstyle='<->', color='purple', lw=1.5))
    
    fig.suptitle('Charge-Reversal Symmetry: Entries Mirror Under q ↦ -q + Transpose',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    
    fig.savefig('/workspace/request-project/viz_charge_landscape.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64

def viz_distance_invariance():
    """Visualize tropical distance invariance under charge reversal."""
    np.random.seed(99)
    n = 4
    W_raw = np.random.randn(n, n)
    W = (W_raw + W_raw.T) / 2
    A = np.random.randn(n, n)
    B = np.random.randn(n, n)
    
    q_range = np.linspace(-5, 5, 300)
    distances = [trop_mat_dist(charged_weight(W, A, q), charged_weight(W, B, q)) for q in q_range]
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    ax1.plot(q_range, distances, color='#2196F3', linewidth=2)
    ax1.set_xlabel('Charge q', fontsize=12)
    ax1.set_ylabel('Tropical Distance', fontsize=12)
    ax1.set_title('Tropical Distance vs. Charge', fontsize=13)
    ax1.grid(True, alpha=0.3)
    
    # Verify symmetry: d(q) = d(-q)
    mid = len(q_range) // 2
    left = distances[:mid]
    right = distances[mid:][::-1]
    min_len = min(len(left), len(right))
    errors = [abs(left[i] - right[i]) for i in range(min_len)]
    
    ax2.plot(q_range[:min_len], errors, color='#F44336', linewidth=2)
    ax2.set_xlabel('|q|', fontsize=12)
    ax2.set_ylabel('|d(q) - d(-q)|', fontsize=12)
    ax2.set_title('Charge-Reversal Distance Error\n(Machine Precision)', fontsize=13)
    ax2.set_yscale('log') if max(errors) > 0 else None
    ax2.grid(True, alpha=0.3)
    
    fig.suptitle('Tropical Distance is Invariant Under Charge Reversal (Symmetric W)',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    
    fig.savefig('/workspace/request-project/viz_distance_invariance.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64

def viz_spectral_invariance():
    """Visualize spectral radius invariance."""
    np.random.seed(55)
    n = 5
    W = np.random.randn(n, n)
    A = np.random.randn(n, n)
    
    q_range = np.linspace(-10, 10, 500)
    base_radius = trop_spec_radius(W)
    radii = [trop_spec_radius(charged_weight(W, A, q)) for q in q_range]
    
    fig, ax = plt.subplots(figsize=(10, 5))
    ax.plot(q_range, radii, color='#4CAF50', linewidth=2, label='tropSpecRadius(chargedWeight(W, A, q))')
    ax.axhline(y=base_radius, color='red', linewidth=1, linestyle='--', label=f'tropSpecRadius(W) = {base_radius:.4f}')
    ax.set_xlabel('Charge q', fontsize=12)
    ax.set_ylabel('Tropical Spectral Radius', fontsize=12)
    ax.set_title('Spectral Radius is Completely Charge-Independent\n(Diagonal entries are unaffected by antisymmetric perturbation)',
                 fontsize=13, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    
    fig.savefig('/workspace/request-project/viz_spectral_invariance.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64

def viz_matrix_heatmaps():
    """Visualize charged weight matrices at different charges."""
    np.random.seed(42)
    n = 5
    W = np.random.randn(n, n)
    W = (W + W.T) / 2
    A = np.random.randn(n, n)
    
    charges = [-2, -1, 0, 1, 2]
    
    fig, axes = plt.subplots(1, 5, figsize=(20, 4))
    
    vmin = min(np.min(charged_weight(W, A, q)) for q in charges)
    vmax = max(np.max(charged_weight(W, A, q)) for q in charges)
    
    for ax, q in zip(axes, charges):
        cw = charged_weight(W, A, q)
        im = ax.imshow(cw, cmap='RdBu_r', vmin=vmin, vmax=vmax, aspect='equal')
        ax.set_title(f'q = {q}', fontsize=13, fontweight='bold')
        ax.set_xticks(range(n))
        ax.set_yticks(range(n))
        for i in range(n):
            for j in range(n):
                ax.text(j, i, f'{cw[i,j]:.1f}', ha='center', va='center', fontsize=8)
    
    fig.colorbar(im, ax=axes, shrink=0.8, label='Weight Value')
    fig.suptitle('Charged Weight Matrices: q ↦ -q Mirrors via Transpose\n(Note: q=-2 is the transpose of q=2, q=-1 is the transpose of q=1)',
                 fontsize=14, fontweight='bold', y=1.08)
    plt.tight_layout()
    
    fig.savefig('/workspace/request-project/viz_matrix_heatmaps.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64

if __name__ == "__main__":
    print("Generating visualizations...")
    
    b64_landscape = viz_charge_landscape()
    print("  ✓ Charge landscape")
    
    b64_distance = viz_distance_invariance()
    print("  ✓ Distance invariance")
    
    b64_spectral = viz_spectral_invariance()
    print("  ✓ Spectral invariance")
    
    b64_heatmaps = viz_matrix_heatmaps()
    print("  ✓ Matrix heatmaps")
    
    # Save base64 data for JSON package
    viz_data = {
        "charge_landscape": b64_landscape,
        "distance_invariance": b64_distance,
        "spectral_invariance": b64_spectral,
        "matrix_heatmaps": b64_heatmaps,
    }
    
    with open('/workspace/request-project/viz_data.json', 'w') as f:
        json.dump(viz_data, f)
    
    print("\nAll visualizations saved.")
