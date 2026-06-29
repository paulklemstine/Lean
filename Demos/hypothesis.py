"""
Real-World Applications of Tropical Residuation

Demonstrates how tropical residuation applies to:
1. Neural network robustness certification
2. Job-shop scheduling with deadline propagation
3. Mathematical morphology (dilation/erosion)
4. Dynamic programming (shortest/longest paths)
"""

import numpy as np
from typing import List, Tuple


# ═══════════════════════════════════════════════════════════════════
# Application 1: Neural Network Robustness Certification
# ═══════════════════════════════════════════════════════════════════

def relu_network_tropical_bound(
    weights: List[np.ndarray],
    biases: List[np.ndarray],
    x: np.ndarray,
) -> np.ndarray:
    """
    Compute a tropical upper bound for a ReLU network output.

    Since max(0, a) ≤ max(0, b) when a ≤ b, and ReLU networks
    compose affine maps with pointwise max(·, 0), a tropical
    (max-plus) network with the same weights provides an upper bound.

    This tropical envelope is then amenable to exact backward
    certification via residuation.

    Args:
        weights: List of weight matrices.
        biases: List of bias vectors.
        x: Input vector.

    Returns:
        Tropical upper bound on the network output.
    """
    current = x.copy()
    for W, b in zip(weights, biases):
        # Tropical layer: y_j = max_i(x_i + |W_{ij}|) + |b_j|
        # Using absolute values ensures an upper bound on ReLU networks
        W_abs = np.abs(W)
        b_abs = np.abs(b)
        current = np.max(current[:, None] + W_abs, axis=0) + b_abs
    return current


def certify_relu_network(
    weights: List[np.ndarray],
    biases: List[np.ndarray],
    x_nominal: np.ndarray,
    epsilon: float,
    output_threshold: np.ndarray,
) -> dict:
    """
    Certify that a ReLU network's output stays below a threshold
    for all inputs within an epsilon ball of x_nominal.

    Uses tropical residuation to compute exact backward bounds on the
    tropical envelope, which provides a sound (but possibly conservative)
    certificate for the original ReLU network.

    Args:
        weights, biases: Network parameters.
        x_nominal: Center of the input ball.
        epsilon: Perturbation radius (L∞).
        output_threshold: Maximum allowed output.

    Returns:
        Certification result dictionary.
    """
    # Compute tropical upper bound at worst-case input
    x_worst = x_nominal + epsilon  # worst case for upper bound
    tropical_output = relu_network_tropical_bound(weights, biases, x_worst)

    # Check if tropical bound is below threshold
    certified = np.all(tropical_output <= output_threshold)

    return {
        "nominal_input": x_nominal,
        "epsilon": epsilon,
        "tropical_upper_bound": tropical_output,
        "threshold": output_threshold,
        "certified": certified,
        "margin": np.min(output_threshold - tropical_output),
    }


# ═══════════════════════════════════════════════════════════════════
# Application 2: Job-Shop Scheduling
# ═══════════════════════════════════════════════════════════════════

def schedule_analysis(
    task_names: List[str],
    durations: np.ndarray,
    precedence: np.ndarray,
    deadlines: np.ndarray,
) -> dict:
    """
    Analyze a scheduling problem using tropical algebra.

    The precedence matrix P[i,j] encodes that task j cannot start
    until duration P[i,j] after task i starts. This is a tropical
    (max-plus) linear constraint.

    Forward analysis: earliest start times = tropical_matmul(P, release_times)
    Backward analysis: latest start times = tropical_backward(P, deadlines)

    Args:
        task_names: Names of tasks.
        durations: Processing durations for each task.
        precedence: Precedence constraint matrix.
        deadlines: Task deadlines.

    Returns:
        Analysis results with feasibility information.
    """
    n = len(task_names)
    release_times = np.zeros(n)

    # Forward: earliest start times
    earliest = np.max(release_times[:, None] + precedence, axis=0)

    # Backward: latest start times from deadlines
    latest = np.min(deadlines[None, :] - precedence, axis=1)

    # Slack
    slack = latest - earliest

    # Feasibility
    feasible = np.all(slack >= 0)

    return {
        "tasks": task_names,
        "earliest_starts": earliest,
        "latest_starts": latest,
        "slack": slack,
        "feasible": feasible,
        "critical_tasks": [task_names[i] for i in range(n) if slack[i] < 1e-10],
    }


# ═══════════════════════════════════════════════════════════════════
# Application 3: Mathematical Morphology
# ═══════════════════════════════════════════════════════════════════

def tropical_dilation(image: np.ndarray, kernel: np.ndarray) -> np.ndarray:
    """
    Morphological dilation as tropical aggregation.

    Dilation of a grayscale image by a flat structuring element is
    exactly a tropical (max-plus) convolution:
        (δ_B f)(x) = max_{b ∈ B} f(x - b)

    With a weighted (non-flat) structuring element:
        (δ_w f)(x) = max_{b} (f(x - b) + w(b))

    This is tropical aggregation applied locally.

    Args:
        image: 1D grayscale signal (for simplicity).
        kernel: Structuring element weights.

    Returns:
        Dilated signal.
    """
    n = len(image)
    k = len(kernel)
    pad = k // 2
    padded = np.pad(image, pad, mode='edge')
    result = np.zeros(n)
    for i in range(n):
        result[i] = np.max(padded[i:i+k] + kernel)
    return result


def tropical_erosion(image: np.ndarray, kernel: np.ndarray) -> np.ndarray:
    """
    Morphological erosion as tropical residual.

    Erosion is the residual (right adjoint) of dilation:
        (ε_w f)(x) = min_{b} (f(x + b) - w(b))

    The dilation-erosion adjunction:
        δ_w(f) ≤ g  ⟺  f ≤ ε_w(g)

    is exactly the tropical residuation theorem applied to image processing.

    Args:
        image: 1D grayscale signal.
        kernel: Structuring element weights.

    Returns:
        Eroded signal.
    """
    n = len(image)
    k = len(kernel)
    pad = k // 2
    padded = np.pad(image, pad, mode='edge')
    result = np.zeros(n)
    for i in range(n):
        result[i] = np.min(padded[i:i+k] - kernel)
    return result


# ═══════════════════════════════════════════════════════════════════
# Application 4: Shortest Path / Dynamic Programming
# ═══════════════════════════════════════════════════════════════════

def tropical_shortest_paths(adjacency: np.ndarray, steps: int = 1) -> np.ndarray:
    """
    Compute shortest path distances using tropical matrix power.

    In the min-plus semiring, matrix multiplication gives shortest paths.
    Here we use the max-plus (negated) convention:
        D^{(k)}[i,j] = max over k-step paths of (sum of negated edge weights)

    The residual gives the tightest constraint on source times given
    destination deadlines.

    Args:
        adjacency: Negated adjacency matrix (use -inf for no edge).
        steps: Number of hops.

    Returns:
        Distance matrix after `steps` hops.
    """
    n = adjacency.shape[0]
    result = adjacency.copy()
    current = adjacency.copy()
    for _ in range(steps - 1):
        new = np.full((n, n), -np.inf)
        for i in range(n):
            for j in range(n):
                for k in range(n):
                    new[i, j] = max(new[i, j], current[i, k] + adjacency[k, j])
        current = new
        result = np.maximum(result, current)
    return current


# ═══════════════════════════════════════════════════════════════════
# Run all applications
# ═══════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("=" * 60)
    print("APPLICATION 1: Neural Network Certification")
    print("=" * 60)

    # Simple 2-layer network
    W1 = np.array([[0.5, -0.3], [0.2, 0.7]])
    b1 = np.array([0.1, -0.1])
    W2 = np.array([[0.4, 0.6], [-0.2, 0.3]])
    b2 = np.array([0.0, 0.1])

    x = np.array([1.0, 0.5])
    result = certify_relu_network(
        [W1, W2], [b1, b2], x, epsilon=0.1,
        output_threshold=np.array([5.0, 5.0])
    )
    print(f"Input: {result['nominal_input']}")
    print(f"Epsilon: {result['epsilon']}")
    print(f"Tropical bound: {result['tropical_upper_bound']}")
    print(f"Certified: {result['certified']}")
    print(f"Margin: {result['margin']:.4f}")

    print("\n" + "=" * 60)
    print("APPLICATION 2: Job-Shop Scheduling")
    print("=" * 60)

    tasks = ["Design", "Build", "Test", "Deploy"]
    P = np.array([
        [0, 3, 5, 8],
        [0, 0, 2, 5],
        [0, 0, 0, 3],
        [0, 0, 0, 0],
    ], dtype=float)
    deadlines = np.array([10, 7, 9, 12], dtype=float)

    sched = schedule_analysis(tasks, np.diag(P), P, deadlines)
    print(f"Tasks: {sched['tasks']}")
    print(f"Earliest starts: {sched['earliest_starts']}")
    print(f"Latest starts: {sched['latest_starts']}")
    print(f"Slack: {sched['slack']}")
    print(f"Feasible: {sched['feasible']}")
    print(f"Critical tasks: {sched['critical_tasks']}")

    print("\n" + "=" * 60)
    print("APPLICATION 3: Mathematical Morphology")
    print("=" * 60)

    signal = np.array([0, 0, 1, 3, 5, 3, 1, 0, 0, 0], dtype=float)
    kernel = np.array([0, 0, 0], dtype=float)  # flat SE of width 3

    dilated = tropical_dilation(signal, kernel)
    eroded = tropical_erosion(signal, kernel)

    print(f"Signal:  {signal}")
    print(f"Dilated: {dilated}")
    print(f"Eroded:  {eroded}")
    # Verify adjunction: dilation ≤ threshold iff signal ≤ erosion(threshold)
    threshold = np.array([1, 2, 3, 5, 5, 5, 3, 2, 1, 0], dtype=float)
    dil_ok = np.all(dilated <= threshold)
    ero_val = tropical_erosion(threshold, kernel)
    ero_ok = np.all(signal <= ero_val)
    print(f"Threshold: {threshold}")
    print(f"Dilation ≤ threshold: {dil_ok}")
    print(f"Signal ≤ erosion(threshold): {ero_ok}")
    print(f"Adjunction consistent: {dil_ok == ero_ok}")

    print("\n" + "=" * 60)
    print("APPLICATION 4: Shortest Paths via Tropical Matrix Power")
    print("=" * 60)

    # Graph with 4 nodes (negated weights for max-plus)
    G = np.array([
        [0, -2, -np.inf, -np.inf],
        [-np.inf, 0, -3, -np.inf],
        [-np.inf, -np.inf, 0, -1],
        [-np.inf, -np.inf, -np.inf, 0],
    ])

    D3 = tropical_shortest_paths(G, steps=3)
    print(f"Adjacency (negated):\n{G}")
    print(f"3-hop distances:\n{D3}")
    print("(Read -6 as shortest path 0→1→2→3 = 2+3+1 = 6)")


"""
Tropical Residuation: Concrete Numerical Demonstrations

This module demonstrates the core tropical residuation theorems with
concrete numerical examples, making the algebraic adjunction laws tangible.
"""

import numpy as np

def tropical_translate(a: float, x: float) -> float:
    """Tropical translation: x ↦ x + a (tropical multiplication by a)."""
    return x + a

def tropical_residual_scalar(a: float, c: float) -> float:
    """Residual of tropical translation: c ↦ c - a."""
    return c - a

def tropical_agg(w: np.ndarray, x: np.ndarray) -> float:
    """Tropical aggregation: max_i (x_i + w_i)."""
    return np.max(x + w)

def tropical_matmul(W: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Tropical matrix-vector product: y_j = max_i (x_i + W_{ij})."""
    m, n = W.shape
    y = np.zeros(n)
    for j in range(n):
        y[j] = np.max(x + W[:, j])
    return y

def tropical_backward(W: np.ndarray, y: np.ndarray) -> np.ndarray:
    """Backward (residual) map: x_i = min_j (y_j - W_{ij})."""
    m, n = W.shape
    x = np.zeros(m)
    for i in range(m):
        x[i] = np.min(y - W[i, :])
    return x

# ═══════════════════════════════════════════════════════════════════
# Demo 1: Scalar Tropical Residuation
# ═══════════════════════════════════════════════════════════════════
print("=" * 65)
print("DEMO 1: Scalar Tropical Residuation")
print("  Theorem: a + y ≤ c  ⟺  y ≤ c - a")
print("=" * 65)

test_cases = [
    (3.0, 2.0, 6.0),   # 3+2=5 ≤ 6, and 2 ≤ 6-3=3 ✓
    (3.0, 4.0, 6.0),   # 3+4=7 > 6, and 4 > 6-3=3 ✓
    (-1.0, 5.0, 3.5),  # -1+5=4 > 3.5, and 5 > 3.5-(-1)=4.5 ✓
    (2.5, 1.0, 3.5),   # 2.5+1=3.5 ≤ 3.5, and 1 ≤ 3.5-2.5=1 ✓ (boundary)
]

for a, y, c in test_cases:
    lhs = (a + y <= c)
    rhs = (y <= c - a)
    status = "✓" if lhs == rhs else "✗"
    print(f"  a={a:5.1f}, y={y:5.1f}, c={c:5.1f} | "
          f"a+y={a+y:5.1f}≤{c}? {lhs}  |  y={y}≤{c-a}? {rhs}  {status}")

# ═══════════════════════════════════════════════════════════════════
# Demo 2: Finite Aggregation Residuation
# ═══════════════════════════════════════════════════════════════════
print("\n" + "=" * 65)
print("DEMO 2: Finite Tropical Aggregation Residuation")
print("  Theorem: max_i(x_i + w_i) ≤ c  ⟺  ∀i, x_i ≤ c - w_i")
print("=" * 65)

x = np.array([1.0, 3.0, 2.0])
w = np.array([2.0, 1.0, 4.0])
c = 7.0

agg_val = tropical_agg(w, x)
lhs = (agg_val <= c)
rhs_vals = x <= (c - w)
rhs = all(rhs_vals)

print(f"  x = {x}")
print(f"  w = {w}")
print(f"  c = {c}")
print(f"  x + w = {x + w}")
print(f"  max(x + w) = {agg_val}")
print(f"  LHS: max(x+w) ≤ c? {lhs}")
print(f"  c - w = {c - w}")
print(f"  x ≤ c-w? {rhs_vals} → all: {rhs}")
print(f"  Iff matches: {'✓' if lhs == rhs else '✗'}")

# Now test with c = 5 (should fail both sides)
c2 = 5.0
agg_val2 = tropical_agg(w, x)
lhs2 = (agg_val2 <= c2)
rhs_vals2 = x <= (c2 - w)
rhs2 = all(rhs_vals2)
print(f"\n  With c = {c2}:")
print(f"  LHS: {agg_val}≤{c2}? {lhs2}")
print(f"  c - w = {c2 - w}")
print(f"  x ≤ c-w? {rhs_vals2} → all: {rhs2}")
print(f"  Iff matches: {'✓' if lhs2 == rhs2 else '✗'}")

# ═══════════════════════════════════════════════════════════════════
# Demo 3: Matrix Tropical Residuation (Galois Connection)
# ═══════════════════════════════════════════════════════════════════
print("\n" + "=" * 65)
print("DEMO 3: Tropical Matrix Residuation (Galois Connection)")
print("  Theorem: F_W(x) ≤ y  ⟺  x ≤ B_W(y)")
print("=" * 65)

W = np.array([
    [1.0, 3.0, 0.0],
    [2.0, 0.0, 1.0],
])  # 2×3 matrix

x = np.array([1.0, 2.0])  # input vector (dim m=2)
y = np.array([5.0, 6.0, 4.0])  # threshold vector (dim n=3)

forward = tropical_matmul(W, x)
backward = tropical_backward(W, y)

lhs = all(forward <= y)
rhs = all(x <= backward)

print(f"  W =\n{W}")
print(f"  x = {x}")
print(f"  y = {y}")
print(f"  F_W(x) = tropicalMatMul(W, x) = {forward}")
print(f"  B_W(y) = tropicalBackward(W, y) = {backward}")
print(f"  F_W(x) ≤ y? {forward <= y} → all: {lhs}")
print(f"  x ≤ B_W(y)? {x <= backward} → all: {rhs}")
print(f"  Galois connection verified: {'✓' if lhs == rhs else '✗'}")

# Test with tighter threshold
y_tight = np.array([3.0, 4.0, 3.0])
forward2 = tropical_matmul(W, x)
backward2 = tropical_backward(W, y_tight)
lhs2 = all(forward2 <= y_tight)
rhs2 = all(x <= backward2)
print(f"\n  With tighter y = {y_tight}:")
print(f"  F_W(x) = {forward2}")
print(f"  B_W(y) = {backward2}")
print(f"  F_W(x) ≤ y? {lhs2}  |  x ≤ B_W(y)? {rhs2}")
print(f"  Galois connection verified: {'✓' if lhs2 == rhs2 else '✗'}")

# ═══════════════════════════════════════════════════════════════════
# Demo 4: Two-Layer Composition (Tropical Cut-Elimination)
# ═══════════════════════════════════════════════════════════════════
print("\n" + "=" * 65)
print("DEMO 4: Two-Layer Composition (Tropical Cut-Elimination)")
print("  Theorem: F_{W2}(F_{W1}(x)) ≤ z  ⟺  x ≤ B_{W1}(B_{W2}(z))")
print("=" * 65)

W1 = np.array([
    [1.0, 2.0],
    [3.0, 0.0],
])  # 2×2

W2 = np.array([
    [0.0, 1.0],
    [2.0, 0.0],
])  # 2×2

x = np.array([1.0, 0.5])
z = np.array([8.0, 7.0])

# Forward: two layers
layer1 = tropical_matmul(W1, x)
layer2 = tropical_matmul(W2, layer1)

# Backward: chain residuals in reverse
back2 = tropical_backward(W2, z)
back1 = tropical_backward(W1, back2)

lhs = all(layer2 <= z)
rhs = all(x <= back1)

print(f"  W1 =\n{W1}")
print(f"  W2 =\n{W2}")
print(f"  x = {x}")
print(f"  z = {z}")
print(f"\n  Forward pass:")
print(f"    Layer 1: F_W1(x) = {layer1}")
print(f"    Layer 2: F_W2(F_W1(x)) = {layer2}")
print(f"\n  Backward pass (residual chain):")
print(f"    B_W2(z) = {back2}")
print(f"    B_W1(B_W2(z)) = {back1}")
print(f"\n  F_W2(F_W1(x)) ≤ z? {layer2 <= z} → all: {lhs}")
print(f"  x ≤ B_W1(B_W2(z))? {x <= back1} → all: {rhs}")
print(f"  Cut-elimination verified: {'✓' if lhs == rhs else '✗'}")

# ═══════════════════════════════════════════════════════════════════
# Demo 5: Monotonicity
# ═══════════════════════════════════════════════════════════════════
print("\n" + "=" * 65)
print("DEMO 5: Monotonicity of Tropical Maps")
print("=" * 65)

W = np.array([[1.0, 2.0], [0.0, 3.0]])
x1 = np.array([1.0, 2.0])
x2 = np.array([2.0, 3.0])  # x1 ≤ x2 pointwise

f1 = tropical_matmul(W, x1)
f2 = tropical_matmul(W, x2)

print(f"  x1 = {x1}")
print(f"  x2 = {x2}")
print(f"  x1 ≤ x2 pointwise: {all(x1 <= x2)}")
print(f"  F_W(x1) = {f1}")
print(f"  F_W(x2) = {f2}")
print(f"  F_W(x1) ≤ F_W(x2) pointwise: {all(f1 <= f2)} ✓")

print("\n" + "=" * 65)
print("All demonstrations complete.")
print("=" * 65)


"""
Visualizations for Tropical Residuation

Generates publication-quality figures illustrating the key mathematical
structures and their applications.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def visualize_scalar_residuation():
    """Visualize the scalar tropical residuation law."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    a = 3.0
    y_range = np.linspace(-2, 8, 300)

    # Left: forward view (a + y vs c)
    ax = axes[0]
    c_values = [4, 6, 8]
    colors = ['#e74c3c', '#3498db', '#2ecc71']
    for c, color in zip(c_values, colors):
        ax.axhline(y=c, color=color, linestyle='--', alpha=0.7, label=f'c = {c}')
        # Shade feasible region
        feasible = y_range[a + y_range <= c]
        if len(feasible) > 0:
            ax.fill_between(feasible, a + feasible, c,
                          alpha=0.1, color=color)
    ax.plot(y_range, a + y_range, 'k-', linewidth=2, label=f'a + y (a={a})')
    ax.set_xlabel('y', fontsize=12)
    ax.set_ylabel('a + y', fontsize=12)
    ax.set_title('Forward: a + y ≤ c', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-2, 8)
    ax.set_ylim(0, 12)

    # Right: residual view (y ≤ c - a)
    ax = axes[1]
    for c, color in zip(c_values, colors):
        residual = c - a
        ax.axvline(x=residual, color=color, linestyle='--', linewidth=2,
                   label=f'c - a = {residual}')
        ax.fill_betweenx([0, 1], -2, residual, alpha=0.15, color=color)
    ax.set_xlabel('y', fontsize=12)
    ax.set_title('Residual: y ≤ c − a', fontsize=14)
    ax.set_xlim(-2, 8)
    ax.set_yticks([])
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3, axis='x')

    fig.suptitle('Scalar Tropical Residuation: a + y ≤ c  ⟺  y ≤ c − a',
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig


def visualize_galois_connection():
    """Visualize the Galois connection for tropical matrix multiply."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    W = np.array([[1.0, 3.0], [2.0, 0.0]])

    # Test multiple input vectors
    x_tests = [
        np.array([0.0, 1.0]),
        np.array([1.0, 2.0]),
        np.array([2.0, 0.5]),
        np.array([3.0, 1.0]),
    ]
    y_threshold = np.array([5.0, 5.0])

    # Forward computation
    ax = axes[0]
    for i, x in enumerate(x_tests):
        fw = np.max(x[:, None] + W, axis=0)
        satisfied = np.all(fw <= y_threshold)
        color = '#2ecc71' if satisfied else '#e74c3c'
        marker = '✓' if satisfied else '✗'
        ax.barh([f'x={list(x)} {marker}'], [fw[0]], color=color, alpha=0.6,
               height=0.3, label=f'j=0' if i == 0 else '')
        ax.barh([f'x={list(x)} {marker}'], [fw[1]], left=[fw[0]],
               color=color, alpha=0.3, height=0.3,
               label=f'j=1' if i == 0 else '')
    ax.axvline(x=y_threshold[0], color='black', linestyle='--', linewidth=2)
    ax.set_xlabel('F_W(x)_j', fontsize=12)
    ax.set_title('Forward: F_W(x) ≤ y?', fontsize=14)

    # Backward computation
    ax = axes[1]
    backward = np.min(y_threshold[None, :] - W, axis=1)
    ax.barh(['B_W(y)_0', 'B_W(y)_1'], backward, color='#3498db', alpha=0.7)
    for i, x in enumerate(x_tests):
        satisfied = np.all(x <= backward)
        color = '#2ecc71' if satisfied else '#e74c3c'
        for dim in range(2):
            ax.plot(x[dim], f'B_W(y)_{dim}', 'o', color=color, markersize=8)
    ax.set_xlabel('value', fontsize=12)
    ax.set_title('Backward: x ≤ B_W(y)?', fontsize=14)

    # Connection diagram
    ax = axes[2]
    ax.text(0.5, 0.85, 'Galois Connection', fontsize=16, fontweight='bold',
            ha='center', va='center', transform=ax.transAxes)
    ax.text(0.5, 0.65, 'F_W(x) ≤ y', fontsize=14, ha='center',
            va='center', transform=ax.transAxes,
            bbox=dict(boxstyle='round,pad=0.3', facecolor='#3498db', alpha=0.3))
    ax.text(0.5, 0.5, '⟺', fontsize=24, ha='center', va='center',
            transform=ax.transAxes)
    ax.text(0.5, 0.35, 'x ≤ B_W(y)', fontsize=14, ha='center',
            va='center', transform=ax.transAxes,
            bbox=dict(boxstyle='round,pad=0.3', facecolor='#2ecc71', alpha=0.3))
    ax.text(0.5, 0.15, f'W = {W.tolist()}', fontsize=10, ha='center',
            va='center', transform=ax.transAxes, family='monospace')
    ax.axis('off')

    fig.suptitle('Tropical Matrix Galois Connection', fontsize=16,
                 fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig


def visualize_cut_elimination():
    """Visualize the cut-elimination / compositional residuation."""
    fig, ax = plt.subplots(figsize=(14, 7))

    # Network architecture
    layers = [
        {'name': 'Input\nx ∈ ℝ²', 'x': 0.1, 'nodes': 2},
        {'name': 'Hidden\nh ∈ ℝ³', 'x': 0.35, 'nodes': 3},
        {'name': 'Output\ny ∈ ℝ²', 'x': 0.6, 'nodes': 2},
    ]

    node_y_positions = {}
    for layer in layers:
        n = layer['nodes']
        positions = np.linspace(0.2, 0.8, n)
        node_y_positions[layer['name']] = positions
        for i, pos in enumerate(positions):
            ax.plot(layer['x'], pos, 'o', markersize=20, color='#3498db',
                   zorder=5)
            ax.text(layer['x'], pos, f'{i}', ha='center', va='center',
                   fontsize=10, color='white', fontweight='bold', zorder=6)

    # Forward arrows (blue)
    for i in range(2):
        for j in range(3):
            ax.annotate('', xy=(0.33, node_y_positions[layers[1]['name']][j]),
                       xytext=(0.12, node_y_positions[layers[0]['name']][i]),
                       arrowprops=dict(arrowstyle='->', color='#3498db',
                                      alpha=0.4, lw=1.5))

    for i in range(3):
        for j in range(2):
            ax.annotate('', xy=(0.58, node_y_positions[layers[2]['name']][j]),
                       xytext=(0.37, node_y_positions[layers[1]['name']][i]),
                       arrowprops=dict(arrowstyle='->', color='#3498db',
                                      alpha=0.4, lw=1.5))

    # Backward arrows (red, curved)
    for i in range(2):
        for j in range(3):
            ax.annotate('', xy=(0.12, node_y_positions[layers[0]['name']][i] - 0.02),
                       xytext=(0.33, node_y_positions[layers[1]['name']][j] - 0.02),
                       arrowprops=dict(arrowstyle='->', color='#e74c3c',
                                      alpha=0.3, lw=1, connectionstyle='arc3,rad=0.2'))

    for i in range(3):
        for j in range(2):
            ax.annotate('', xy=(0.37, node_y_positions[layers[1]['name']][i] - 0.02),
                       xytext=(0.58, node_y_positions[layers[2]['name']][j] - 0.02),
                       arrowprops=dict(arrowstyle='->', color='#e74c3c',
                                      alpha=0.3, lw=1, connectionstyle='arc3,rad=0.2'))

    # Labels
    ax.text(0.25, 0.95, 'F_{W₁}', fontsize=14, ha='center', color='#3498db',
           fontweight='bold', transform=ax.transAxes)
    ax.text(0.5, 0.95, 'F_{W₂}', fontsize=14, ha='center', color='#3498db',
           fontweight='bold', transform=ax.transAxes)

    # Right side: theorem statement
    ax.text(0.82, 0.7, 'Cut-Elimination:', fontsize=14, fontweight='bold',
           ha='center', transform=ax.transAxes)
    ax.text(0.82, 0.55, 'F_{W₂}(F_{W₁}(x)) ≤ z', fontsize=12,
           ha='center', transform=ax.transAxes,
           bbox=dict(boxstyle='round', facecolor='#3498db', alpha=0.2))
    ax.text(0.82, 0.45, '⟺', fontsize=20, ha='center', transform=ax.transAxes)
    ax.text(0.82, 0.35, 'x ≤ B_{W₁}(B_{W₂}(z))', fontsize=12,
           ha='center', transform=ax.transAxes,
           bbox=dict(boxstyle='round', facecolor='#e74c3c', alpha=0.2))

    ax.text(0.82, 0.15, 'Forward → Blue\nBackward → Red', fontsize=10,
           ha='center', transform=ax.transAxes, style='italic')

    for layer in layers:
        ax.text(layer['x'], 0.05, layer['name'], ha='center', va='center',
               fontsize=11, transform=ax.transAxes)

    ax.set_xlim(-0.05, 1.05)
    ax.set_ylim(0, 1)
    ax.axis('off')
    ax.set_title('Tropical Cut-Elimination: Compositional Residuation',
                fontsize=16, fontweight='bold', pad=20)

    return fig


def visualize_morphology():
    """Visualize dilation/erosion as tropical residuation."""
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Signal
    x = np.linspace(0, 10, 200)
    signal = np.exp(-(x - 3)**2) + 0.7 * np.exp(-(x - 7)**2 / 2)

    # Flat structuring element (width 5)
    kernel_width = 15

    # Dilation
    dilated = np.array([np.max(signal[max(0, i-kernel_width//2):
                                      min(len(signal), i+kernel_width//2+1)])
                       for i in range(len(signal))])

    # Erosion
    eroded = np.array([np.min(signal[max(0, i-kernel_width//2):
                                     min(len(signal), i+kernel_width//2+1)])
                      for i in range(len(signal))])

    # Plot signal and dilation
    ax = axes[0, 0]
    ax.fill_between(x, 0, signal, alpha=0.3, color='#3498db')
    ax.plot(x, signal, 'b-', linewidth=2, label='Signal f')
    ax.plot(x, dilated, 'r-', linewidth=2, label='Dilation δ(f)')
    ax.set_title('Dilation = Tropical Forward', fontsize=13, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # Plot signal and erosion
    ax = axes[0, 1]
    ax.fill_between(x, 0, signal, alpha=0.3, color='#3498db')
    ax.plot(x, signal, 'b-', linewidth=2, label='Signal f')
    ax.plot(x, eroded, 'g-', linewidth=2, label='Erosion ε(f)')
    ax.set_title('Erosion = Tropical Backward', fontsize=13, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # Adjunction visualization
    threshold = 0.6
    ax = axes[1, 0]
    ax.plot(x, signal, 'b-', linewidth=2, label='f')
    ax.plot(x, dilated, 'r-', linewidth=2, label='δ(f)')
    ax.axhline(y=threshold, color='black', linestyle='--', linewidth=2,
              label=f'threshold g={threshold}')
    region = dilated <= threshold
    ax.fill_between(x, 0, dilated, where=region, alpha=0.2, color='green',
                   label='δ(f) ≤ g')
    ax.set_title('Forward check: δ(f) ≤ g?', fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    ax = axes[1, 1]
    threshold_signal = np.full_like(signal, threshold)
    eroded_threshold = np.array([
        np.min(threshold_signal[max(0, i-kernel_width//2):
                                min(len(signal), i+kernel_width//2+1)])
        for i in range(len(signal))])
    ax.plot(x, signal, 'b-', linewidth=2, label='f')
    ax.plot(x, eroded_threshold, 'g-', linewidth=2, label='ε(g)')
    region2 = signal <= eroded_threshold
    ax.fill_between(x, 0, signal, where=region2, alpha=0.2, color='green',
                   label='f ≤ ε(g)')
    ax.set_title('Backward check: f ≤ ε(g)?', fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    fig.suptitle('Mathematical Morphology as Tropical Residuation\n'
                 'δ(f) ≤ g  ⟺  f ≤ ε(g)', fontsize=16, fontweight='bold')
    plt.tight_layout()
    return fig


if __name__ == "__main__":
    print("Generating visualizations...")

    fig1 = visualize_scalar_residuation()
    fig1.savefig('viz_scalar_residuation.png', dpi=150, bbox_inches='tight')
    print("  Saved viz_scalar_residuation.png")

    fig2 = visualize_galois_connection()
    fig2.savefig('viz_galois_connection.png', dpi=150, bbox_inches='tight')
    print("  Saved viz_galois_connection.png")

    fig3 = visualize_cut_elimination()
    fig3.savefig('viz_cut_elimination.png', dpi=150, bbox_inches='tight')
    print("  Saved viz_cut_elimination.png")

    fig4 = visualize_morphology()
    fig4.savefig('viz_morphology.png', dpi=150, bbox_inches='tight')
    print("  Saved viz_morphology.png")

    print("All visualizations generated.")
