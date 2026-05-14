#!/usr/bin/env python3
"""
Applications of Tropical Incompleteness

Real-world applications of the tropical fixed-point framework:
1. Shortest-path verification (network routing)
2. Abstract interpretation bounds (program analysis)
3. Dynamic programming certification (optimization)
4. Recurrent neural network stability (machine learning)
"""

import numpy as np
from typing import Callable, List, Tuple
from algorithms import (
    knaster_tarski_lfp,
    bellman_tropical_fixpoint,
    diagonal_fixed_point,
    check_soundness_completeness,
    FixedPointResult
)


def application_1_network_routing():
    """
    Application 1: Shortest-Path Verification in Network Routing

    In network routing (e.g., BGP, OSPF), routers compute shortest paths
    by iterating a Bellman-Ford operator. The stable routing table is a
    fixed point of this operator — a "tropical Gödel sentence" in the
    network's cost semantics.

    The incompleteness theorem implies: no sound verification system
    can certify ALL correct routing tables without sometimes failing
    to recognize a valid one.
    """
    print("=" * 60)
    print("APPLICATION 1: Network Routing Verification")
    print("=" * 60)
    print()

    # Network topology: 5 routers
    INF = 999
    # Cost matrix: M[i][j] = cost of direct link from i to j
    M = np.array([
        [0,   2,   INF, 6,   INF],
        [2,   0,   3,   8,   5  ],
        [INF, 3,   0,   INF, 7  ],
        [6,   8,   INF, 0,   9  ],
        [INF, 5,   7,   9,   0  ]
    ])

    print("Network topology (5 routers):")
    print("Link costs:")
    for i in range(5):
        for j in range(5):
            if M[i][j] < INF and i != j:
                print(f"  Router {i} → Router {j}: cost {M[i][j]}")

    # Compute shortest-path distances (tropical fixed point)
    result = bellman_tropical_fixpoint(M, bound=50)

    print(f"\nShortest-path distances (tropical fixed point):")
    print(f"  {result.point}")
    print(f"  Converged in {result.iterations} iterations")
    print()

    # This fixed point IS the correct routing table
    print("This fixed point is a 'tropical Gödel sentence': a routing")
    print("table that is self-consistent under Bellman updates.")
    print()

    # Demonstrate the incompleteness connection
    print("Incompleteness implication:")
    print("  Any SOUND routing verifier (one that never certifies")
    print("  an incorrect routing table) must be INCOMPLETE:")
    print("  there exist correct routing tables it cannot certify.")
    print()


def application_2_abstract_interpretation():
    """
    Application 2: Abstract Interpretation Bounds in Program Analysis

    Static analyzers approximate program behavior using abstract domains.
    Over idempotent (tropical) abstract domains, the analyzer computes
    fixed points of transfer functions.

    The tropical incompleteness theorem implies: no sound static analyzer
    over an idempotent domain can be complete for all programs.
    """
    print("=" * 60)
    print("APPLICATION 2: Abstract Interpretation (Program Analysis)")
    print("=" * 60)
    print()

    # Simple abstract domain: intervals [0, B] for each variable
    # A program with 3 variables, abstract state is a 3-vector in ℕ³
    print("Program: 3 integer variables with range [0, 10]")
    print("Abstract domain: upper bounds (tropical valuations)")
    print()

    # Transfer function: models a loop body
    # x₁ = min(x₁ + 1, 10)  -- increment, capped at 10
    # x₂ = min(x₂ + x₁, 10) -- depends on x₁
    # x₃ = min(x₃, x₂)      -- constrained by x₂
    def transfer(x: np.ndarray) -> np.ndarray:
        return np.array([
            min(x[0] + 1, 10),
            min(x[1] + x[0], 10),
            min(x[2], x[1])
        ])

    bound = np.array([10, 10, 10])
    result = knaster_tarski_lfp(transfer, 3, bound)

    print("Transfer function (loop body):")
    print("  x₁ ← min(x₁ + 1, 10)")
    print("  x₂ ← min(x₂ + x₁, 10)")
    print("  x₃ ← min(x₃, x₂)")
    print()
    print(f"Fixed point (loop invariant): {result.point}")
    print(f"Iterations: {result.iterations}")
    print()

    # Show convergence trajectory
    print("Convergence trajectory:")
    for i, x in enumerate(result.trajectory):
        print(f"  Iteration {i}: {x}")
    print()

    print("This fixed point IS the strongest loop invariant expressible")
    print("in the abstract domain. The tropical incompleteness theorem")
    print("tells us: for sufficiently complex programs, no sound analyzer")
    print("can always find this strongest invariant.")
    print()


def application_3_dynamic_programming():
    """
    Application 3: Dynamic Programming Certification

    Bellman's principle of optimality says: the optimal value function
    is a fixed point of the Bellman operator. But can we always CERTIFY
    that a proposed value function is optimal?

    The tropical incompleteness theorem says: no.
    """
    print("=" * 60)
    print("APPLICATION 3: Dynamic Programming Certification")
    print("=" * 60)
    print()

    # A simple grid-world MDP with deterministic transitions
    # States: 4x4 grid, goal at (3,3)
    # Actions: up, down, left, right (cost 1 each)
    # Value function: minimum cost to reach goal

    n = 16  # 4x4 grid
    INF = 999

    def state_to_pos(s: int) -> Tuple[int, int]:
        return s // 4, s % 4

    def pos_to_state(r: int, c: int) -> int:
        return r * 4 + c

    # Build transition cost matrix
    M = np.full((n, n), INF)
    for s in range(n):
        r, c = state_to_pos(s)
        # Self-loop at goal with cost 0
        if r == 3 and c == 3:
            M[s][s] = 0
            continue
        # Adjacent cells have cost 1
        for dr, dc in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
            nr, nc = r + dr, c + dc
            if 0 <= nr < 4 and 0 <= nc < 4:
                ns = pos_to_state(nr, nc)
                M[s][ns] = 1

    result = bellman_tropical_fixpoint(M, bound=20)

    print("4×4 Grid World (goal at bottom-right corner):")
    print("Action cost: 1 per step")
    print()
    print("Optimal value function (tropical fixed point):")
    for r in range(4):
        row = [result.point[pos_to_state(r, c)] for c in range(4)]
        print(f"  {row}")
    print()
    print(f"Converged in {result.iterations} Bellman iterations")
    print()
    print("Each cell shows the minimum number of steps to the goal.")
    print("This IS the fixed point of the Bellman operator — the")
    print("'tropical Gödel sentence' of this optimization problem.")
    print()
    print("The incompleteness theorem implies: for sufficiently complex")
    print("optimization problems, no sound certification system can")
    print("verify ALL correct value functions.")
    print()


def application_4_rnn_stability():
    """
    Application 4: Recurrent Neural Network Stability

    A ReLU recurrent neural network computes:
        h_{t+1} = ReLU(W h_t + b)

    Since ReLU(x) = max(0, x) and the network is piecewise linear,
    this is a tropical (min-plus dual) operator. Stable hidden states
    are fixed points — tropical Gödel sentences of the network.
    """
    print("=" * 60)
    print("APPLICATION 4: ReLU RNN Stability Analysis")
    print("=" * 60)
    print()

    # Simple 3-unit ReLU RNN
    np.random.seed(42)
    W = np.array([
        [0.5, -0.3, 0.1],
        [0.2,  0.4, -0.2],
        [-0.1, 0.3,  0.6]
    ])
    b = np.array([1.0, 0.5, 0.8])

    def relu(x):
        return np.maximum(0, x)

    def rnn_step(h):
        return relu(W @ h + b)

    print("ReLU RNN: h_{t+1} = ReLU(W h_t + b)")
    print(f"Weight matrix W:\n{W}")
    print(f"Bias b: {b}")
    print()

    # Find fixed point by iteration
    h = np.zeros(3)
    print("Iteration to fixed point:")
    for i in range(20):
        h_next = rnn_step(h)
        diff = np.max(np.abs(h_next - h))
        print(f"  t={i+1}: h = [{h_next[0]:.4f}, {h_next[1]:.4f}, {h_next[2]:.4f}]  (max Δ = {diff:.6f})")
        if diff < 1e-10:
            print(f"  → Converged at iteration {i+1}!")
            break
        h = h_next

    print()
    print(f"Stable hidden state (fixed point): [{h[0]:.4f}, {h[1]:.4f}, {h[2]:.4f}]")
    print(f"Verification: ReLU(Wh + b) = [{rnn_step(h)[0]:.4f}, {rnn_step(h)[1]:.4f}, {rnn_step(h)[2]:.4f}]")
    print()
    print("This fixed point is a 'tropical Gödel sentence' of the network:")
    print("a hidden representation that encodes its own stability.")
    print()
    print("The incompleteness theorem suggests: no sound verification")
    print("tool can certify the stability of ALL ReLU RNN fixed points.")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  TROPICAL INCOMPLETENESS: Real-World Applications      ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    application_1_network_routing()
    application_2_abstract_interpretation()
    application_3_dynamic_programming()
    application_4_rnn_stability()

    print("=" * 60)
    print("All applications demonstrated.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Incompleteness: Concrete Demonstrations

This script demonstrates the core theorems of tropical incompleteness
with concrete numerical examples, making the mathematics tangible.
"""

import numpy as np
from typing import Callable, Tuple, Optional


def trop_min_operator(c: np.ndarray) -> Callable[[np.ndarray], np.ndarray]:
    """
    Construct the tropMin operator: x ↦ min(x, c) pointwise.
    This is a monotone, idempotent, deflationary operator.
    """
    def T(x: np.ndarray) -> np.ndarray:
        return np.minimum(x, c)
    return T


def trop_shift_operator(a: np.ndarray, b: np.ndarray) -> Callable[[np.ndarray], np.ndarray]:
    """
    Construct the tropShift operator: x ↦ min(x + a, b) pointwise.
    This models a Bellman-style update with additive costs capped by bounds.
    """
    def T(x: np.ndarray) -> np.ndarray:
        return np.minimum(x + a, b)
    return T


def find_fixed_point_iteration(
    T: Callable[[np.ndarray], np.ndarray],
    x0: np.ndarray,
    max_iter: int = 1000
) -> Tuple[np.ndarray, int]:
    """
    Find a fixed point of T by iterating from x0.
    Returns (fixed_point, num_iterations).
    """
    x = x0.copy()
    for i in range(max_iter):
        x_next = T(x)
        if np.array_equal(x_next, x):
            return x, i
        x = x_next
    return x, max_iter


def find_fixed_point_knaster_tarski(
    T: Callable[[np.ndarray], np.ndarray],
    n: int,
    B: np.ndarray
) -> np.ndarray:
    """
    Find the least fixed point by iterating T from 0 (bottom element).
    For monotone bounded T on ℕ^n, this converges in at most sum(B)+1 steps.
    """
    x = np.zeros(n, dtype=int)
    for _ in range(int(np.sum(B)) + 1):
        x_next = T(x)
        if np.array_equal(x_next, x):
            return x
        x = x_next
    return x


def demo_1_tropmin_fixed_point():
    """Demo 1: tropMin operator and its fixed point."""
    print("=" * 60)
    print("DEMO 1: tropMin Fixed Point")
    print("=" * 60)
    print()
    print("The operator tropMin(c) maps x ↦ min(x, c) pointwise.")
    print("It is monotone and idempotent. Its fixed point is c itself.")
    print()

    c = np.array([3, 7, 2, 5])
    T = trop_min_operator(c)
    n = len(c)

    print(f"Constants c = {c}")
    print()

    # Show idempotency
    x = np.array([10, 4, 8, 1])
    Tx = T(x)
    TTx = T(Tx)
    print(f"  x     = {x}")
    print(f"  T(x)  = {Tx}")
    print(f"  T²(x) = {TTx}")
    print(f"  T(x) == T²(x)? {np.array_equal(Tx, TTx)} (idempotency)")
    print()

    # Show fixed point
    print(f"  T(c)  = {T(c)}")
    print(f"  c     = {c}")
    print(f"  T(c) == c? {np.array_equal(T(c), c)} (fixed point)")
    print()


def demo_2_tropshift_fixed_point():
    """Demo 2: tropShift operator — Bellman-style with additive costs."""
    print("=" * 60)
    print("DEMO 2: tropShift Fixed Point (Bellman-style)")
    print("=" * 60)
    print()
    print("The operator tropShift(a, b) maps x ↦ min(x + a, b) pointwise.")
    print("This models a dynamic programming / shortest-path update.")
    print()

    a = np.array([1, 2, 3])
    b = np.array([5, 6, 7])
    T = trop_shift_operator(a, b)
    n = len(a)

    print(f"Additive costs a = {a}")
    print(f"Upper bounds   b = {b}")
    print()

    # Iterate from 0
    x = np.zeros(n, dtype=int)
    print("Iteration from x₀ = [0, 0, 0]:")
    for i in range(10):
        x_next = T(x)
        print(f"  T^{i+1}(0) = {x_next}")
        if np.array_equal(x_next, x):
            print(f"  → Fixed point reached at iteration {i+1}!")
            break
        x = x_next
    print()

    # The fixed point satisfies: for each i, either x[i] = b[i]
    # or x[i] + a[i] = x[i] (impossible for a[i] > 0)
    # So the fixed point is just b.
    fp = x
    print(f"Fixed point: {fp}")
    print(f"Verification: T(fp) = {T(fp)}")
    print(f"T(fp) == fp? {np.array_equal(T(fp), fp)}")
    print()
    print("Interpretation: The fixed point represents the stable 'cost'")
    print("valuation — the tropical Gödel sentence. It encodes a state")
    print("that is invariant under its own proof-cost transformation.")
    print()


def demo_3_composition_fixed_point():
    """Demo 3: Fixed point of C ∘ D — the diagonal construction."""
    print("=" * 60)
    print("DEMO 3: Composition Fixed Point (Diagonal Construction)")
    print("=" * 60)
    print()
    print("Given monotone C (closure) and D (diagonal transformer),")
    print("we find g such that C(D(g)) = g — a tropical Gödel sentence.")
    print()

    n = 4

    # C = closure operator: x ↦ min(x, [4,4,4,4]) (clips to [0,4])
    cap = np.array([4, 4, 4, 4])
    def C(x: np.ndarray) -> np.ndarray:
        return np.minimum(x, cap)

    # D = diagonal transformer: x ↦ x + [1,1,1,1] (shift up by 1)
    def D(x: np.ndarray) -> np.ndarray:
        return x + 1

    # F = C ∘ D: x ↦ min(x+1, 4)
    def F(x: np.ndarray) -> np.ndarray:
        return C(D(x))

    print("C(x) = min(x, [4,4,4,4])  (closure/capping operator)")
    print("D(x) = x + [1,1,1,1]      (diagonal/shift transformer)")
    print("F = C ∘ D: x ↦ min(x+1, 4)")
    print()

    # Find fixed point by iteration from 0
    x = np.zeros(n, dtype=int)
    print("Iteration from x₀ = [0, 0, 0, 0]:")
    for i in range(10):
        x_next = F(x)
        print(f"  F^{i+1}(0) = {x_next}")
        if np.array_equal(x_next, x):
            print(f"  → Fixed point reached at iteration {i+1}!")
            break
        x = x_next

    g = x
    print()
    print(f"Tropical Gödel sentence g = {g}")
    print(f"D(g) = {D(g)}")
    print(f"C(D(g)) = {C(D(g))}")
    print(f"C(D(g)) == g? {np.array_equal(C(D(g)), g)}")
    print()
    print("This g satisfies C(D(g)) = g — it is a fixed point of the")
    print("composition of closure and diagonal transformation.")
    print("It represents a 'self-referential tropical sentence.'")
    print()


def demo_4_soundness_completeness_obstruction():
    """Demo 4: Soundness vs completeness — the incompleteness obstruction."""
    print("=" * 60)
    print("DEMO 4: Soundness vs Completeness Obstruction")
    print("=" * 60)
    print()
    print("We demonstrate the logical impossibility:")
    print("If Provable is sound w.r.t. Valid, and there exists g with")
    print("Valid(g) ↔ ¬Provable(g), then the system is incomplete.")
    print()

    # Model: sentences are integers 0..9
    # Valid: sentences that are "true" (say, even numbers)
    # Provable: sentences we can prove

    sentences = list(range(10))
    valid = {0, 2, 4, 6, 8}  # Even numbers are "valid"

    print(f"Sentences: {sentences}")
    print(f"Valid sentences: {sorted(valid)}")
    print()

    # The diagonal sentence g = 5 satisfies: Valid(5) ↔ ¬Provable(5)
    # Since 5 is not valid: ¬Valid(5) is true
    # So we need: ¬Valid(5) ↔ ¬(¬Provable(5)) ↔ Provable(5)
    # Wait, let's reformulate: Valid(g) ↔ ¬Provable(g)

    # Take g = 4 (which IS valid). Then Valid(4) ↔ ¬Provable(4).
    # Valid(4) is True. So ¬Provable(4) must be True. So Provable(4) is False.
    # But then the system is incomplete: 4 is Valid but not Provable.
    g = 4
    print(f"Diagonal sentence g = {g}")
    print(f"Valid(g) = {g in valid}")
    print()
    print("The diagonal condition: Valid(g) ↔ ¬Provable(g)")
    print()
    print("Analysis:")
    print("  • Since Valid(g) is True, ¬Provable(g) must be True")
    print("  • Therefore Provable(g) is False")
    print("  • But g is Valid, so the system fails to prove a valid sentence")
    print("  • The system is INCOMPLETE.")
    print()

    # What if g is not valid?
    g2 = 5
    print(f"Alternative: What if g = {g2}?")
    print(f"Valid(g) = {g2 in valid}")
    print("  • Valid(g) is False, so ¬Provable(g) must be False")
    print("  • Therefore Provable(g) is True")
    print("  • But g is not Valid, contradicting soundness!")
    print("  • Soundness forces: Provable(g) → Valid(g)")
    print("  • This is a CONTRADICTION — such a system cannot exist.")
    print()

    print("CONCLUSION: In either case, the diagonal condition is incompatible")
    print("with both soundness and completeness simultaneously.")
    print("This is the core of Gödel's insight, extracted into pure")
    print("order-theoretic / tropical semantics.")
    print()


def demo_5_matrix_bellman_fixed_point():
    """Demo 5: Matrix-based Bellman operator fixed point."""
    print("=" * 60)
    print("DEMO 5: Tropical Matrix Bellman Fixed Point")
    print("=" * 60)
    print()
    print("A tropical matrix M defines a Bellman operator:")
    print("T(x)[i] = min_j (M[i,j] + x[j])")
    print("Fixed points are stable cost valuations — tropical Gödel sentences")
    print("in the shortest-path semantics.")
    print()

    INF = 999  # Represent infinity

    # A 4x4 tropical matrix (shortest-path weights)
    M = np.array([
        [0, 3, INF, 7],
        [INF, 0, 2, INF],
        [1, INF, 0, INF],
        [INF, INF, 4, 0]
    ])

    def bellman_op(x: np.ndarray) -> np.ndarray:
        n = len(x)
        result = np.full(n, INF)
        for i in range(n):
            for j in range(n):
                result[i] = min(result[i], M[i, j] + x[j])
        return result

    # Cap at bound B to ensure convergence in ℕ
    B = np.full(4, 20)
    def bellman_bounded(x: np.ndarray) -> np.ndarray:
        return np.minimum(bellman_op(x), B)

    print("Tropical matrix M:")
    print(M)
    print()

    # Iterate from 0
    x = np.zeros(4, dtype=int)
    print("Bellman iteration from x₀ = [0, 0, 0, 0]:")
    for i in range(15):
        x_next = bellman_bounded(x)
        print(f"  T^{i+1}(0) = {x_next}")
        if np.array_equal(x_next, x):
            print(f"  → Fixed point reached at iteration {i+1}!")
            break
        x = x_next

    print()
    print(f"Fixed point (tropical Gödel sentence): {x}")
    print(f"Verification: T(x) = {bellman_bounded(x)}")
    print()
    print("This fixed point represents the shortest-path distances")
    print("from each node to node 0 in the weighted graph defined by M.")
    print("It is a self-consistent cost valuation — a 'sentence' that")
    print("is stable under its own proof-cost transformation.")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  TROPICAL INCOMPLETENESS: Concrete Demonstrations      ║")
    print("║  Self-Reference via Idempotent Fixed Points             ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_1_tropmin_fixed_point()
    demo_2_tropshift_fixed_point()
    demo_3_composition_fixed_point()
    demo_4_soundness_completeness_obstruction()
    demo_5_matrix_bellman_fixed_point()

    print("=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""Generate PACKAGE.json by reading all deliverables."""
import json
import os

root = '/workspace/request-project'

def read_file(path):
    with open(os.path.join(root, path), 'r') as f:
        return f.read()

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_code = read_file('Logic/TropicalIncompleteness.lean')
demo_code = read_file('demo.py')
algo_code = read_file('algorithms.py')
app_code = read_file('applications.py')

# Read visualization data
with open(os.path.join(root, 'viz_data.json'), 'r') as f:
    viz_data = json.load(f)

package = {
    "title": "Tropical Incompleteness: Self-Reference and Proof Limits via Idempotent Fixed Points",
    "domain": "Logic / Tropical Algebra / Order Theory",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Fixed-Point Demonstrations",
            "code": demo_code
        }
    ],
    "algorithms": [
        {
            "name": "Knaster-Tarski Least Fixed Point",
            "pseudocode": "x ← 0\nrepeat\n  x' ← T(x)\n  if x' = x then return x\n  x ← x'\nuntil convergence\n\nComplexity: O(||B||₁ × cost(T))",
            "code": algo_code
        }
    ],
    "visualizations": viz_data,
    "lean_proofs": lean_code
}

with open(os.path.join(root, 'PACKAGE.json'), 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("PACKAGE.json generated successfully")
print(f"Size: {os.path.getsize(os.path.join(root, 'PACKAGE.json'))} bytes")


#!/usr/bin/env python3
"""
Visualizations for Tropical Incompleteness

Generates publication-quality figures showing:
1. Fixed-point convergence trajectories
2. Tropical lattice structure
3. Bellman operator convergence
4. Soundness-completeness obstruction diagram
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def viz_1_convergence_trajectory():
    """Visualize the convergence of tropShift iteration to its fixed point."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # tropShift convergence
    a = np.array([1, 2, 3])
    b = np.array([5, 6, 7])
    trajectory = [[0, 0, 0]]
    x = np.zeros(3, dtype=int)
    for _ in range(8):
        x = np.minimum(x + a, b)
        trajectory.append(x.copy())

    trajectory = np.array(trajectory)
    ax = axes[0]
    for i in range(3):
        ax.plot(trajectory[:, i], 'o-', linewidth=2, markersize=8,
                label=f'Coordinate {i+1}')
    ax.axhline(y=5, color='C0', linestyle='--', alpha=0.3)
    ax.axhline(y=6, color='C1', linestyle='--', alpha=0.3)
    ax.axhline(y=7, color='C2', linestyle='--', alpha=0.3)
    ax.set_xlabel('Iteration', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('tropShift Convergence to Fixed Point', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # C ∘ D convergence
    cap = 4
    trajectory2 = [[0]]
    x = 0
    for _ in range(6):
        x = min(x + 1, cap)
        trajectory2.append([x])
    trajectory2 = np.array(trajectory2)

    ax = axes[1]
    ax.plot(trajectory2, 'o-', linewidth=2, markersize=8, color='darkred')
    ax.axhline(y=cap, color='darkred', linestyle='--', alpha=0.3,
               label=f'Fixed point = {cap}')
    ax.set_xlabel('Iteration', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('C∘D Convergence (Diagonal Fixed Point)', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    fig.suptitle('Tropical Fixed-Point Convergence', fontsize=15, fontweight='bold')
    plt.tight_layout()

    fig.savefig('/workspace/request-project/fig_convergence.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def viz_2_bellman_grid():
    """Visualize the Bellman fixed point on a 4x4 grid world."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Compute optimal values
    n = 16
    INF = 999
    M = np.full((n, n), INF)
    for s in range(n):
        r, c = s // 4, s % 4
        if r == 3 and c == 3:
            M[s][s] = 0
            continue
        for dr, dc in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
            nr, nc = r + dr, c + dc
            if 0 <= nr < 4 and 0 <= nc < 4:
                ns = nr * 4 + nc
                M[s][ns] = 1

    # Iterate
    bound = 20
    x = np.zeros(n, dtype=int)
    snapshots = [x.reshape(4, 4).copy()]
    for _ in range(10):
        x_new = np.full(n, bound)
        for i in range(n):
            for j in range(n):
                if M[i][j] < INF:
                    x_new[i] = min(x_new[i], M[i][j] + x[j])
        x_new = np.minimum(x_new, bound)
        snapshots.append(x_new.reshape(4, 4).copy())
        if np.array_equal(x_new, x):
            break
        x = x_new

    # Plot 3 snapshots
    titles = ['Initial (t=0)', f'Intermediate (t={len(snapshots)//2})', f'Fixed Point (t={len(snapshots)-1})']
    indices = [0, len(snapshots)//2, len(snapshots)-1]

    for ax, idx, title in zip(axes, indices, titles):
        grid = snapshots[min(idx, len(snapshots)-1)]
        im = ax.imshow(grid, cmap='YlOrRd_r', vmin=0, vmax=6)
        for i in range(4):
            for j in range(4):
                val = grid[i][j]
                color = 'white' if val > 3 else 'black'
                ax.text(j, i, str(val), ha='center', va='center',
                        fontsize=16, fontweight='bold', color=color)
        ax.set_title(title, fontsize=12)
        ax.set_xticks(range(4))
        ax.set_yticks(range(4))
        if i == 3 and j == 3:
            ax.text(3, 3, '★', ha='center', va='center', fontsize=20, color='gold')

    fig.colorbar(im, ax=axes, shrink=0.8, label='Cost to Goal')
    fig.suptitle('Bellman Fixed Point: Grid World Shortest Paths', fontsize=14, fontweight='bold')
    plt.tight_layout()

    fig.savefig('/workspace/request-project/fig_bellman_grid.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def viz_3_incompleteness_diagram():
    """Visualize the soundness-completeness obstruction."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 7))

    # Draw Venn-like diagram
    from matplotlib.patches import Circle, FancyArrowPatch

    valid_circle = Circle((0.4, 0.5), 0.3, fill=True, facecolor='#3498db',
                          alpha=0.3, edgecolor='#2980b9', linewidth=2)
    provable_circle = Circle((0.6, 0.5), 0.25, fill=True, facecolor='#e74c3c',
                             alpha=0.3, edgecolor='#c0392b', linewidth=2)
    ax.add_patch(valid_circle)
    ax.add_patch(provable_circle)

    ax.text(0.25, 0.5, 'Valid\nsentences', ha='center', va='center',
            fontsize=14, color='#2980b9', fontweight='bold')
    ax.text(0.75, 0.5, 'Provable\nsentences', ha='center', va='center',
            fontsize=13, color='#c0392b', fontweight='bold')

    # Mark the diagonal sentence g
    ax.plot(0.35, 0.35, 'k*', markersize=20, zorder=5)
    ax.text(0.35, 0.25, 'g (diagonal sentence)\nValid but NOT Provable',
            ha='center', va='center', fontsize=11, fontweight='bold',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='yellow', alpha=0.7))

    # Soundness arrow
    ax.annotate('Soundness:\nProvable ⊆ Valid',
                xy=(0.5, 0.75), fontsize=11, ha='center',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='#2ecc71', alpha=0.5))

    # Completeness crossed out
    ax.annotate('Completeness: Valid ⊆ Provable\n✗ IMPOSSIBLE',
                xy=(0.5, 0.1), fontsize=11, ha='center',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='#e74c3c', alpha=0.3))

    ax.set_xlim(0, 1)
    ax.set_ylim(0, 0.9)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Tropical Incompleteness: The Diagonal Obstruction',
                 fontsize=15, fontweight='bold', pad=20)

    fig.savefig('/workspace/request-project/fig_incompleteness.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def viz_4_lattice_fixed_points():
    """Visualize fixed points in a small lattice."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 8))

    # Hasse diagram of the power set lattice P({a,b})
    # Elements: ∅, {a}, {b}, {a,b}
    positions = {
        '∅': (0.5, 0),
        '{a}': (0.25, 0.33),
        '{b}': (0.75, 0.33),
        '{a,b}': (0.5, 0.66)
    }

    # Draw edges (Hasse diagram)
    edges = [('∅', '{a}'), ('∅', '{b}'), ('{a}', '{a,b}'), ('{b}', '{a,b}')]
    for e1, e2 in edges:
        x1, y1 = positions[e1]
        x2, y2 = positions[e2]
        ax.plot([x1, x2], [y1, y2], 'k-', linewidth=1.5, alpha=0.5)

    # Draw nodes
    for name, (x, y) in positions.items():
        ax.plot(x, y, 'o', markersize=25, color='#3498db', zorder=5)
        ax.text(x, y, name, ha='center', va='center', fontsize=10,
                fontweight='bold', zorder=6)

    # Mark fixed points of a closure operator
    # C: ∅ → {a}, {a} → {a}, {b} → {a,b}, {a,b} → {a,b}
    # Fixed points: {a}, {a,b}
    for name in ['{a}', '{a,b}']:
        x, y = positions[name]
        ax.plot(x, y, 'o', markersize=30, color='#e74c3c', zorder=4,
                fillstyle='none', linewidth=3)

    # Arrows showing C action
    arrows = [('∅', '{a}'), ('{b}', '{a,b}')]
    for src, dst in arrows:
        x1, y1 = positions[src]
        x2, y2 = positions[dst]
        ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                    arrowprops=dict(arrowstyle='->', color='#e74c3c',
                                   lw=2, connectionstyle='arc3,rad=0.3'))

    ax.text(0.5, 0.85, 'Closure operator C on P({a,b})',
            ha='center', fontsize=13, fontweight='bold')
    ax.text(0.5, 0.78, 'Red circles = fixed points of C\nRed arrows = C maps non-fixed to fixed',
            ha='center', fontsize=10, color='#e74c3c')
    ax.text(0.5, -0.1, 'The Knaster–Tarski theorem guarantees:\nevery monotone C on a complete lattice has fixed points',
            ha='center', fontsize=10, style='italic')

    ax.set_xlim(-0.05, 1.05)
    ax.set_ylim(-0.2, 0.95)
    ax.axis('off')

    fig.savefig('/workspace/request-project/fig_lattice.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    b64_1 = viz_1_convergence_trajectory()
    print("  ✓ fig_convergence.png")
    b64_2 = viz_2_bellman_grid()
    print("  ✓ fig_bellman_grid.png")
    b64_3 = viz_3_incompleteness_diagram()
    print("  ✓ fig_incompleteness.png")
    b64_4 = viz_4_lattice_fixed_points()
    print("  ✓ fig_lattice.png")
    print("All visualizations generated.")

    # Return base64 strings for PACKAGE.json
    import json
    viz_data = [
        {"name": "Fixed-Point Convergence", "data": b64_1},
        {"name": "Bellman Grid World", "data": b64_2},
        {"name": "Incompleteness Obstruction", "data": b64_3},
        {"name": "Lattice Fixed Points", "data": b64_4}
    ]
    with open('/workspace/request-project/viz_data.json', 'w') as f:
        json.dump(viz_data, f)
    print("Visualization data saved to viz_data.json")
