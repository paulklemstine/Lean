#!/usr/bin/env python3
"""
Tropical Causal Ordering — Applications
=========================================
Real-world applications of tropical causal theory.
"""

import numpy as np
from typing import List, Tuple


# ──────────────────────────────────────────────────────────────────────────────
# Application 1: Neural Network Robustness Certification
# ──────────────────────────────────────────────────────────────────────────────

class TropicalReLULayer:
    """A ReLU layer viewed as a tropical (max-plus) linear map."""

    def __init__(self, W: np.ndarray, b: np.ndarray):
        self.W = W
        self.b = b

    def forward(self, x: np.ndarray) -> np.ndarray:
        return np.maximum(self.W @ x + self.b, 0)

    def lipschitz_constant(self) -> float:
        """Upper bound on the operator norm (sup-norm Lipschitz constant)."""
        return float(np.max(np.sum(np.abs(self.W), axis=1)))


class TropicalNetwork:
    """A feedforward ReLU network with tropical causal analysis."""

    def __init__(self, layers: List[TropicalReLULayer]):
        self.layers = layers

    def forward(self, x: np.ndarray) -> np.ndarray:
        for layer in self.layers:
            x = layer.forward(x)
        return x

    def causal_budget(self, input_perturbation: float) -> float:
        """
        Compute the causal budget at the output given an input perturbation.
        Uses the budgeted transitivity theorem: budgets compose multiplicatively
        through Lipschitz layers.
        """
        budget = input_perturbation
        for layer in self.layers:
            budget *= layer.lipschitz_constant()
        return budget

    def certified_radius(self, x: np.ndarray, true_class: int) -> float:
        """
        Compute the certified adversarial robustness radius.
        Returns the maximum ε such that no perturbation of L∞ norm ≤ ε
        can change the classification.
        """
        output = self.forward(x)
        margin = output[true_class] - np.max(
            [output[j] for j in range(len(output)) if j != true_class]
        )
        if margin <= 0:
            return 0.0
        total_lip = 1.0
        for layer in self.layers:
            total_lip *= layer.lipschitz_constant()
        if total_lip <= 0:
            return float('inf')
        return margin / (2 * total_lip)


def demo_neural_robustness():
    """Demonstrate certified robustness via tropical causality."""
    print("=" * 60)
    print("APPLICATION 1: Neural Network Robustness Certification")
    print("=" * 60)

    np.random.seed(42)

    # Simple 2-layer network
    W1 = np.array([[0.5, -0.3], [0.2, 0.8], [-0.1, 0.4]])
    b1 = np.array([0.1, -0.2, 0.3])
    W2 = np.array([[0.6, -0.4, 0.2], [-0.3, 0.7, 0.1]])
    b2 = np.array([0.0, 0.0])

    net = TropicalNetwork([
        TropicalReLULayer(W1, b1),
        TropicalReLULayer(W2, b2),
    ])

    x = np.array([1.0, 2.0])
    output = net.forward(x)
    true_class = int(np.argmax(output))

    print(f"Input: {x}")
    print(f"Output: {output.round(4)}")
    print(f"Predicted class: {true_class}")
    print(f"Layer 1 Lipschitz: {net.layers[0].lipschitz_constant():.4f}")
    print(f"Layer 2 Lipschitz: {net.layers[1].lipschitz_constant():.4f}")

    radius = net.certified_radius(x, true_class)
    print(f"Certified robustness radius: {radius:.4f}")
    print(f"  → No adversarial perturbation of L∞ norm ≤ {radius:.4f}")
    print(f"    can change the classification.")

    # Verify by sampling perturbations
    n_tests = 1000
    changes = 0
    for _ in range(n_tests):
        delta = np.random.uniform(-radius, radius, size=x.shape)
        perturbed_output = net.forward(x + delta)
        if np.argmax(perturbed_output) != true_class:
            changes += 1
    print(f"\nVerification: {n_tests} random perturbations within radius,")
    print(f"  {changes} classification changes (should be 0)")
    print()


# ──────────────────────────────────────────────────────────────────────────────
# Application 2: Factory Scheduling (Min-Plus Systems)
# ──────────────────────────────────────────────────────────────────────────────

def demo_factory_scheduling():
    """Demonstrate min-plus scheduling with causal constraints."""
    print("=" * 60)
    print("APPLICATION 2: Factory Scheduling via Min-Plus Causality")
    print("=" * 60)

    # 4 machines, processing times between consecutive machines
    # A[i][j] = minimum time to move a job from machine i to machine j
    A = np.array([
        [0,   3,   7,  np.inf],
        [np.inf, 0, 2,   5],
        [np.inf, np.inf, 0, 4],
        [np.inf, np.inf, np.inf, 0]
    ])

    print("Processing pipeline (4 machines):")
    print("Machine adjacency matrix (time costs):")
    print(A)

    # Compute causal closure (all-pairs minimum times)
    n = A.shape[0]
    D = A.copy()
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if D[i][k] + D[k][j] < D[i][j]:
                    D[i][j] = D[i][k] + D[k][j]

    print("\nCausal closure (minimum production times):")
    print(D)

    # Deadline analysis
    deadline = 10.0
    print(f"\nDeadline: {deadline} time units")
    for i in range(n):
        for j in range(i+1, n):
            feasible = D[i][j] <= deadline
            print(f"  Machine {i} → Machine {j}: "
                  f"min time = {D[i][j]:.1f}, "
                  f"{'FEASIBLE' if feasible else 'INFEASIBLE'}")

    # Throughput: cycle time = max diagonal of A* (tropical eigenvalue)
    print(f"\nEnd-to-end minimum time (Machine 0 → Machine {n-1}): {D[0][n-1]:.1f}")
    print()


# ──────────────────────────────────────────────────────────────────────────────
# Application 3: Network Routing with Budget Constraints
# ──────────────────────────────────────────────────────────────────────────────

def demo_network_routing():
    """Demonstrate causal reachability in network routing."""
    print("=" * 60)
    print("APPLICATION 3: Network Routing with Causal Budgets")
    print("=" * 60)

    # 6-node network with latencies
    n = 6
    INF = np.inf
    latency = np.array([
        [0,   2,   5, INF, INF, INF],
        [2,   0,   1,   3, INF, INF],
        [5,   1,   0, INF,   4, INF],
        [INF, 3, INF,   0,   1,   6],
        [INF, INF, 4,   1,   0,   2],
        [INF, INF, INF, 6,   2,   0]
    ])

    node_names = ['A', 'B', 'C', 'D', 'E', 'F']

    print("Network topology (latencies in ms):")
    for i in range(n):
        for j in range(n):
            if latency[i][j] < INF and i != j:
                print(f"  {node_names[i]} → {node_names[j]}: {latency[i][j]:.0f}ms")

    # Causal closure
    D = latency.copy()
    pred = np.full((n, n), -1, dtype=int)
    for i in range(n):
        for j in range(n):
            if i != j and latency[i][j] < INF:
                pred[i][j] = i
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if D[i][k] + D[k][j] < D[i][j]:
                    D[i][j] = D[i][k] + D[k][j]
                    pred[i][j] = pred[k][j]

    # QoS budget analysis
    qos_budget = 8.0
    print(f"\nQoS latency budget: {qos_budget}ms")
    print(f"Reachable pairs within budget:")
    for i in range(n):
        for j in range(n):
            if i != j and D[i][j] <= qos_budget:
                # Reconstruct path
                path = [j]
                while path[-1] != i:
                    p = pred[i][path[-1]]
                    if p == -1:
                        break
                    path.append(p)
                path.reverse()
                path_str = " → ".join(node_names[p] for p in path)
                print(f"  {node_names[i]} → {node_names[j]}: "
                      f"{D[i][j]:.0f}ms via {path_str}")
    print()


# ──────────────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo_neural_robustness()
    demo_factory_scheduling()
    demo_network_routing()
    print("All applications completed successfully.")


#!/usr/bin/env python3
"""
Tropical Causal Ordering — Demonstration
=========================================
Concrete numerical examples illustrating the theorems from the formal development.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import List, Tuple, Optional

# ──────────────────────────────────────────────────────────────────────────────
# §1  Core Definitions
# ──────────────────────────────────────────────────────────────────────────────

def sup_norm_displacement(x: np.ndarray, y: np.ndarray) -> float:
    """τ(x, y) = max_i |x_i - y_i|  (sup-norm displacement)."""
    return float(np.max(np.abs(x - y)))

def one_sided_displacement(x: np.ndarray, y: np.ndarray) -> float:
    """τ(x, y) = max_i (y_i - x_i)  (one-sided displacement)."""
    return float(np.max(y - x))

def tropical_causal(tau, T: float, x, y) -> bool:
    """TropicalCausal τ T x y  :⟺  τ(x, y) ≤ T."""
    return tau(x, y) <= T + 1e-12

def tropical_future(tau, x, y) -> bool:
    """TropicalFuture τ x y  :⟺  τ(x, y) ≤ 0."""
    return tau(x, y) <= 1e-12


# ──────────────────────────────────────────────────────────────────────────────
# §2  Budgeted Transitivity Demo
# ──────────────────────────────────────────────────────────────────────────────

def demo_budgeted_transitivity():
    """Demonstrate Theorem 3.1: budgets compose under the triangle inequality."""
    print("=" * 60)
    print("DEMO 1: Budgeted Causal Transitivity")
    print("=" * 60)

    np.random.seed(42)
    n = 5  # dimension
    x = np.random.randn(n)
    y = np.random.randn(n)
    z = np.random.randn(n)

    tau = sup_norm_displacement
    d_xy = tau(x, y)
    d_yz = tau(y, z)
    d_xz = tau(x, z)

    print(f"x = {x.round(3)}")
    print(f"y = {y.round(3)}")
    print(f"z = {z.round(3)}")
    print(f"\nτ(x, y) = {d_xy:.4f}")
    print(f"τ(y, z) = {d_yz:.4f}")
    print(f"τ(x, z) = {d_xz:.4f}")
    print(f"τ(x,y) + τ(y,z) = {d_xy + d_yz:.4f}")
    print(f"\nTriangle inequality holds: τ(x,z) ≤ τ(x,y) + τ(y,z)?  "
          f"{d_xz <= d_xy + d_yz + 1e-12}")

    T1 = d_xy + 0.1
    T2 = d_yz + 0.1
    print(f"\nBudget T₁ = {T1:.4f}, T₂ = {T2:.4f}")
    print(f"Causal(T₁, x, y)? {tropical_causal(tau, T1, x, y)}")
    print(f"Causal(T₂, y, z)? {tropical_causal(tau, T2, y, z)}")
    print(f"Causal(T₁+T₂, x, z)? {tropical_causal(tau, T1+T2, x, z)}")
    print(f"  (Budget composition verified ✓)")
    print()


# ──────────────────────────────────────────────────────────────────────────────
# §3  One-Sided Future Preorder Demo
# ──────────────────────────────────────────────────────────────────────────────

def demo_one_sided_preorder():
    """Demonstrate the coordinatewise partial order from one-sided displacement."""
    print("=" * 60)
    print("DEMO 2: One-Sided Displacement Preorder")
    print("=" * 60)

    x = np.array([5.0, 3.0, 7.0])
    y = np.array([4.0, 2.0, 6.0])  # y ≤ x coordinatewise
    z = np.array([3.0, 1.0, 5.0])  # z ≤ y coordinatewise
    w = np.array([4.0, 4.0, 6.0])  # w NOT ≤ x (w[1] > x[1]... wait, x[1]=3, w[1]=4)

    tau = one_sided_displacement
    print(f"x = {x},  y = {y},  z = {z},  w = {w}")
    print(f"\nτ_onesided(x, y) = max_i(y_i - x_i) = {tau(x, y):.1f}")
    print(f"τ_onesided(y, z) = max_i(z_i - y_i) = {tau(y, z):.1f}")
    print(f"τ_onesided(x, z) = max_i(z_i - x_i) = {tau(x, z):.1f}")
    print(f"τ_onesided(x, w) = max_i(w_i - x_i) = {tau(x, w):.1f}")
    print(f"\ny in Future(x)? {tropical_future(tau, x, y)} (y ≤ x coordinatewise)")
    print(f"z in Future(y)? {tropical_future(tau, y, z)} (z ≤ y coordinatewise)")
    print(f"z in Future(x)? {tropical_future(tau, x, z)} (transitivity ✓)")
    print(f"w in Future(x)? {tropical_future(tau, x, w)} (w[1]=4 > x[1]=3, so NO)")
    print()


# ──────────────────────────────────────────────────────────────────────────────
# §4  Nonexpansive Map Demo
# ──────────────────────────────────────────────────────────────────────────────

def demo_nonexpansive():
    """Demonstrate that nonexpansive maps preserve causal order."""
    print("=" * 60)
    print("DEMO 3: Nonexpansive Maps Preserve Causality")
    print("=" * 60)

    # A tropical-style map: coordinatewise min with a threshold
    def f(v, threshold=2.0):
        return np.minimum(v, threshold)

    tau = sup_norm_displacement
    x = np.array([1.0, 3.0, 0.5])
    y = np.array([1.5, 2.5, 1.0])

    print(f"f(v) = min(v, 2.0) coordinatewise")
    print(f"x = {x},  y = {y}")
    print(f"f(x) = {f(x)},  f(y) = {f(y)}")
    print(f"\nτ(x, y) = {tau(x, y):.4f}")
    print(f"τ(f(x), f(y)) = {tau(f(x), f(y)):.4f}")
    print(f"Nonexpansive? τ(f(x),f(y)) ≤ τ(x,y)?  {tau(f(x), f(y)) <= tau(x, y) + 1e-12}")

    # Check causal preservation
    T = tau(x, y) + 0.1
    print(f"\nBudget T = {T:.4f}")
    print(f"Causal(T, x, y)? {tropical_causal(tau, T, x, y)}")
    print(f"Causal(T, f(x), f(y))? {tropical_causal(tau, T, f(x), f(y))} (preserved ✓)")

    # Statistical test: random vectors
    np.random.seed(123)
    violations = 0
    for _ in range(10000):
        a = np.random.randn(5)
        b = np.random.randn(5)
        if tau(f(a), f(b)) > tau(a, b) + 1e-10:
            violations += 1
    print(f"\nStatistical test (10000 random pairs): {violations} violations (expected: 0)")
    print()


# ──────────────────────────────────────────────────────────────────────────────
# §5  Matrix / Path Causality Demo
# ──────────────────────────────────────────────────────────────────────────────

def path_cost(A: np.ndarray, path: List[int]) -> float:
    """Compute the cost of a path in a weighted directed graph."""
    if len(path) <= 1:
        return 0.0
    cost = 0.0
    for i in range(len(path) - 1):
        cost += A[path[i], path[i+1]]
    return cost

def floyd_warshall(A: np.ndarray) -> np.ndarray:
    """Compute all-pairs shortest paths (causal closure)."""
    n = A.shape[0]
    D = A.copy()
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if D[i][k] + D[k][j] < D[i][j]:
                    D[i][j] = D[i][k] + D[k][j]
    return D

def demo_matrix_causality():
    """Demonstrate matrix causal transitivity via path concatenation."""
    print("=" * 60)
    print("DEMO 4: Matrix / Path Causality")
    print("=" * 60)

    n = 5
    np.random.seed(7)
    # Random weighted directed graph
    A = np.random.rand(n, n) * 10
    np.fill_diagonal(A, 0)  # zero self-loops

    print("Weight matrix A (5×5):")
    print(np.round(A, 2))

    # Find paths
    path_ij = [0, 2, 3]   # path from 0 to 3 via 2
    path_jk = [3, 1, 4]   # path from 3 to 4 via 1

    c_ij = path_cost(A, path_ij)
    c_jk = path_cost(A, path_jk)

    # Concatenated path
    path_ik = path_ij + path_jk[1:]  # drop duplicate junction vertex
    c_ik = path_cost(A, path_ik)

    print(f"\nPath i→j: {path_ij}, cost = {c_ij:.4f}")
    print(f"Path j→k: {path_jk}, cost = {c_jk:.4f}")
    print(f"Concatenated i→k: {path_ik}, cost = {c_ik:.4f}")
    print(f"Sum of budgets: {c_ij + c_jk:.4f}")
    print(f"Transitivity: cost(i→k) ≤ cost(i→j) + cost(j→k)?  "
          f"{c_ik <= c_ij + c_jk + 1e-10} ✓")

    # Floyd-Warshall: causal closure
    D = floyd_warshall(A)
    print(f"\nFloyd-Warshall shortest path matrix (causal closure):")
    print(np.round(D, 2))

    # Verify transitivity for all triples
    violations = 0
    for i in range(n):
        for j in range(n):
            for k in range(n):
                if D[i][k] > D[i][j] + D[j][k] + 1e-10:
                    violations += 1
    print(f"\nTriangle inequality violations in closure: {violations} (expected: 0)")
    print()


# ──────────────────────────────────────────────────────────────────────────────
# §6  Security Propagation Demo
# ──────────────────────────────────────────────────────────────────────────────

def demo_security_propagation():
    """Demonstrate security degradation along causal chains."""
    print("=" * 60)
    print("DEMO 5: Security Propagation Along Causal Chains")
    print("=" * 60)

    np.random.seed(99)
    chain_length = 10
    budgets = np.random.uniform(0, 0.5, chain_length)

    # Lipschitz security function
    def security(v):
        return 10.0 - np.max(np.abs(v))

    # Generate chain: each step adds a bounded perturbation
    points = [np.zeros(3)]
    for T in budgets:
        delta = np.random.randn(3)
        delta = delta / max(np.max(np.abs(delta)), 1e-10) * T  # ensure ||delta||_inf ≤ T
        points.append(points[-1] + delta)

    print(f"Chain of {chain_length} steps with budgets:")
    print(f"  {budgets.round(4)}")
    print(f"  Total budget: {budgets.sum():.4f}")

    sec_start = security(points[0])
    sec_end = security(points[-1])
    guaranteed = sec_start - budgets.sum()

    print(f"\nSecurity at start:  {sec_start:.4f}")
    print(f"Security at end:    {sec_end:.4f}")
    print(f"Guaranteed minimum: {guaranteed:.4f}")
    print(f"Actual ≥ guaranteed? {sec_end >= guaranteed - 1e-10} ✓")

    # Track security along chain
    print(f"\nStep-by-step security degradation:")
    cumulative = 0.0
    for i in range(chain_length + 1):
        s = security(points[i])
        g = sec_start - cumulative
        print(f"  Step {i:2d}: security = {s:.4f}, guaranteed ≥ {g:.4f}, ok = {s >= g - 1e-10}")
        if i < chain_length:
            cumulative += budgets[i]
    print()


# ──────────────────────────────────────────────────────────────────────────────
# §7  Visualizations
# ──────────────────────────────────────────────────────────────────────────────

def create_visualizations():
    """Generate visualization plots."""

    # --- Plot 1: Causal cones in 2D ---
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    # Sup-norm cones
    ax = axes[0]
    x0 = np.array([0.0, 0.0])
    for T, color, alpha in [(0.5, 'blue', 0.3), (1.0, 'green', 0.2), (2.0, 'red', 0.1)]:
        rect = plt.Rectangle((-T, -T), 2*T, 2*T, fill=True, color=color,
                              alpha=alpha, label=f'T = {T}')
        ax.add_patch(rect)
    ax.set_xlim(-3, 3)
    ax.set_ylim(-3, 3)
    ax.set_aspect('equal')
    ax.set_title('Sup-Norm Causal Cones (2D)')
    ax.set_xlabel('$y_1 - x_1$')
    ax.set_ylabel('$y_2 - x_2$')
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.plot(0, 0, 'ko', markersize=8, label='x')

    # One-sided cones
    ax = axes[1]
    for T, color, alpha in [(0.5, 'blue', 0.3), (1.0, 'green', 0.2), (2.0, 'red', 0.1)]:
        # One-sided: y_i - x_i ≤ T for all i, so y_i ≤ x_i + T
        # In displacement coordinates d_i = y_i - x_i: d_i ≤ T
        rect = plt.Rectangle((-3, -3), 3+T, 3+T, fill=True, color=color,
                              alpha=alpha, label=f'T = {T}')
        ax.add_patch(rect)
    ax.set_xlim(-3, 3)
    ax.set_ylim(-3, 3)
    ax.set_aspect('equal')
    ax.set_title('One-Sided Causal Cones (2D)')
    ax.set_xlabel('$y_1 - x_1$')
    ax.set_ylabel('$y_2 - x_2$')
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.plot(0, 0, 'ko', markersize=8)

    plt.tight_layout()
    plt.savefig('causal_cones.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: causal_cones.png")

    # --- Plot 2: Security degradation ---
    fig, ax = plt.subplots(figsize=(10, 5))

    np.random.seed(99)
    chain_length = 20
    budgets = np.random.uniform(0, 0.3, chain_length)

    sec_values = [10.0]
    guaranteed = [10.0]
    cumulative = 0.0
    for i in range(chain_length):
        # Simulate actual security (random walk with bounded steps)
        sec_values.append(sec_values[-1] - np.random.uniform(0, budgets[i]))
        cumulative += budgets[i]
        guaranteed.append(10.0 - cumulative)

    steps = list(range(chain_length + 1))
    ax.plot(steps, sec_values, 'b-o', markersize=4, label='Actual security', linewidth=2)
    ax.plot(steps, guaranteed, 'r--s', markersize=4, label='Guaranteed lower bound', linewidth=2)
    ax.fill_between(steps, guaranteed, [min(guaranteed)-0.5]*len(steps),
                     alpha=0.1, color='red')
    ax.set_xlabel('Chain step')
    ax.set_ylabel('Security level')
    ax.set_title('Security Propagation Along a Causal Chain')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('security_propagation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: security_propagation.png")

    # --- Plot 3: Graph causality ---
    fig, ax = plt.subplots(figsize=(8, 6))

    n = 6
    np.random.seed(42)
    A = np.random.rand(n, n) * 5 + 0.5
    np.fill_diagonal(A, 0)
    D = floyd_warshall(A)

    im = ax.imshow(D, cmap='YlOrRd', aspect='equal')
    ax.set_title('All-Pairs Shortest Paths (Causal Closure)')
    ax.set_xlabel('Target vertex')
    ax.set_ylabel('Source vertex')
    for i in range(n):
        for j in range(n):
            ax.text(j, i, f'{D[i,j]:.1f}', ha='center', va='center', fontsize=9)
    plt.colorbar(im, ax=ax, label='Causal budget (shortest path cost)')
    plt.tight_layout()
    plt.savefig('causal_closure.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: causal_closure.png")


# ──────────────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo_budgeted_transitivity()
    demo_one_sided_preorder()
    demo_nonexpansive()
    demo_matrix_causality()
    demo_security_propagation()
    print("\n" + "=" * 60)
    print("Generating visualizations...")
    print("=" * 60)
    create_visualizations()
    print("\nAll demos completed successfully.")
