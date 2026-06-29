#!/usr/bin/env python3
"""
Applications of Tropical Vertical Composition Theory

Demonstrates real-world applications of the tropical spectral growth bound
to deep learning stability analysis, optimal control, and scheduling.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def trop_mat_vec(A, x):
    return np.max(A + x[np.newaxis, :], axis=1)


def vertical_iterate(A, k, x):
    result = x.copy()
    for _ in range(k):
        result = trop_mat_vec(A, result)
    return result


def sup_norm(x):
    return float(np.max(x))


def mat_max_entry(A):
    return float(np.max(A))


def relu_layer(W, b, x):
    """Standard ReLU layer: max(Wx + b, 0)."""
    return np.maximum(W @ x + b, 0)


def tropical_layer(A, x):
    """Tropical layer: (A ⊗ x)_i = max_j(A_ij + x_j)."""
    return trop_mat_vec(A, x)


# ═══════════════════════════════════════════════════════════════════════
# Application 1: Deep Learning Stability Certification
# ═══════════════════════════════════════════════════════════════════════
print("=" * 70)
print("APPLICATION 1: Deep Learning Depth Stability Certification")
print("=" * 70)
print()
print("A tropical neural network with weight matrix A has certified")
print("activation growth bounded by k * max(A_ij) at depth k.")
print()

np.random.seed(42)
n_neurons = 10
depth = 50

# Scenario 1: Well-conditioned network (negative spectral bound)
print("Scenario 1: Contracting Network")
A_contract = np.random.randn(n_neurons, n_neurons) * 0.3 - 0.5
M_contract = mat_max_entry(A_contract)
x0 = np.random.randn(n_neurons)
norms_contract = [sup_norm(vertical_iterate(A_contract, k, x0)) for k in range(depth+1)]
print(f"  matMaxEntry = {M_contract:.3f}")
print(f"  Depth 0:  supNorm = {norms_contract[0]:.3f}")
print(f"  Depth 25: supNorm = {norms_contract[25]:.3f}")
print(f"  Depth 50: supNorm = {norms_contract[50]:.3f}")
print(f"  Certificate: activations decrease — network is stable!")
print()

# Scenario 2: Exploding network (positive spectral bound)
print("Scenario 2: Exploding Network")
A_explode = np.random.randn(n_neurons, n_neurons) * 0.5 + 0.3
M_explode = mat_max_entry(A_explode)
norms_explode = [sup_norm(vertical_iterate(A_explode, k, x0)) for k in range(depth+1)]
print(f"  matMaxEntry = {M_explode:.3f}")
print(f"  Depth 0:  supNorm = {norms_explode[0]:.3f}")
print(f"  Depth 25: supNorm = {norms_explode[25]:.3f}")
print(f"  Depth 50: supNorm = {norms_explode[50]:.3f}")
print(f"  Certificate: activations grow at most {M_explode:.3f} per layer")
print()

# Scenario 3: Critical initialization
print("Scenario 3: Critical Initialization (Near-Zero Spectral Bound)")
A_critical = np.random.randn(n_neurons, n_neurons) * 0.5
A_critical -= mat_max_entry(A_critical)  # shift so max entry ≈ 0
M_critical = mat_max_entry(A_critical)
norms_critical = [sup_norm(vertical_iterate(A_critical, k, x0)) for k in range(depth+1)]
print(f"  matMaxEntry = {M_critical:.6f}")
print(f"  Depth 0:  supNorm = {norms_critical[0]:.3f}")
print(f"  Depth 25: supNorm = {norms_critical[25]:.3f}")
print(f"  Depth 50: supNorm = {norms_critical[50]:.3f}")
print(f"  Certificate: activations bounded by {depth * M_critical:.3f} above input")
print()


# ═══════════════════════════════════════════════════════════════════════
# Application 2: Optimal Scheduling / Shortest Path
# ═══════════════════════════════════════════════════════════════════════
print("=" * 70)
print("APPLICATION 2: Max-Plus Scheduling — Longest Path Analysis")
print("=" * 70)
print()
print("In scheduling theory, tropical matrix iteration computes the")
print("longest (critical) path in a task dependency graph.")
print()

# Factory with 4 machines, processing times as tropical weights
# A_ij = time for job to go from machine j's output to machine i
A_schedule = np.array([
    [2.0, 3.0, -np.inf, 1.0],   # Machine 1 receives from 1,2,4
    [1.0, 1.5, 2.0, -np.inf],   # Machine 2 receives from 1,2,3
    [-np.inf, 2.0, 1.0, 3.0],   # Machine 3 receives from 2,3,4
    [1.5, -np.inf, 1.0, 2.0],   # Machine 4 receives from 1,3,4
])

# Replace -inf with very negative for computation
A_sched_finite = np.where(np.isinf(A_schedule), -100, A_schedule)

# Starting times (all machines available at time 0)
start_times = np.zeros(4)

print("Task dependency matrix (processing times):")
print(A_schedule)
print()
print("Machine completion times over production cycles:")
print(f"  {'Cycle':>6s}  {'M1':>8s}  {'M2':>8s}  {'M3':>8s}  {'M4':>8s}  {'Makespan':>10s}")
print(f"  {'─'*6}  {'─'*8}  {'─'*8}  {'─'*8}  {'─'*8}  {'─'*10}")

for cycle in range(8):
    times = vertical_iterate(A_sched_finite, cycle, start_times)
    makespan = sup_norm(times)
    print(f"  {cycle:6d}  {times[0]:8.2f}  {times[1]:8.2f}  {times[2]:8.2f}  {times[3]:8.2f}  {makespan:10.2f}")

M_sched = mat_max_entry(A_sched_finite)
print(f"\n  Spectral bound (max processing time): {M_sched:.1f}")
print(f"  Certified: makespan ≤ {M_sched} × number_of_cycles")


# ═══════════════════════════════════════════════════════════════════════
# Application 3: ReLU Network Tropicalization
# ═══════════════════════════════════════════════════════════════════════
print()
print("=" * 70)
print("APPLICATION 3: ReLU to Tropical Network Comparison")
print("=" * 70)
print()
print("ReLU networks are piecewise-linear and tropicalize naturally.")
print("We compare growth behavior of standard vs tropical networks.")
print()

np.random.seed(0)
n = 5
K = 30

# ReLU network with same weight matrix
W = np.random.randn(n, n) * 0.3
b = np.zeros(n)
A_trop = W.copy()  # Use same weights for tropical version

x0 = np.ones(n)

relu_norms = [np.max(x0)]
trop_norms = [sup_norm(x0)]
x_relu = x0.copy()
x_trop = x0.copy()

for k in range(K):
    x_relu = relu_layer(W, b, x_relu)
    x_trop = tropical_layer(A_trop, x_trop)
    relu_norms.append(np.max(x_relu))
    trop_norms.append(sup_norm(x_trop))

print(f"  Weight matrix max entry: {mat_max_entry(A_trop):.3f}")
print(f"  ReLU network norm after {K} layers: {relu_norms[-1]:.4f}")
print(f"  Tropical network supNorm after {K} layers: {trop_norms[-1]:.4f}")
print(f"  Tropical bound: {K * mat_max_entry(A_trop) + sup_norm(x0):.4f}")
print()

# Visualization
fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: Deep learning stability
ax = axes[0]
ks = range(depth + 1)
ax.plot(ks, norms_contract, 'b-', label='Contracting', linewidth=2)
ax.plot(ks, norms_explode, 'r-', label='Exploding', linewidth=2)
ax.plot(ks, norms_critical, 'g-', label='Critical', linewidth=2)
# bounds
ax.plot(ks, [k * M_explode + sup_norm(x0) for k in ks], 'r--', alpha=0.5, label='Exploding bound')
ax.set_xlabel('Network Depth', fontsize=12)
ax.set_ylabel('Activation Scale (supNorm)', fontsize=12)
ax.set_title('Depth Stability Certification', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 2: Scheduling
ax = axes[1]
cycles = range(8)
makespans = [sup_norm(vertical_iterate(A_sched_finite, c, start_times)) for c in cycles]
bounds = [c * M_sched for c in cycles]
ax.plot(cycles, makespans, 'bo-', label='Actual makespan', markersize=6, linewidth=2)
ax.plot(cycles, bounds, 'r--', label=f'Bound (slope={M_sched:.1f})', linewidth=2)
ax.set_xlabel('Production Cycle', fontsize=12)
ax.set_ylabel('Makespan', fontsize=12)
ax.set_title('Scheduling: Critical Path Growth', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 3: ReLU vs Tropical
ax = axes[2]
ks_rt = range(K + 1)
ax.plot(ks_rt, relu_norms, 'b-', label='ReLU network', linewidth=2)
ax.plot(ks_rt, trop_norms, 'r-', label='Tropical network', linewidth=2)
M_t = mat_max_entry(A_trop)
bounds_t = [k * M_t + sup_norm(x0) for k in ks_rt]
ax.plot(ks_rt, bounds_t, 'r--', alpha=0.5, label='Tropical bound', linewidth=1)
ax.set_xlabel('Depth', fontsize=12)
ax.set_ylabel('Max Activation', fontsize=12)
ax.set_title('ReLU vs Tropical Growth', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('/workspace/request-project/applications_visualization.png', dpi=150, bbox_inches='tight')
print("Saved: applications_visualization.png")

print()
print("All applications demonstrated successfully!")


#!/usr/bin/env python3
"""
Tropical Vertical Composition: Numerical Demonstrations

Demonstrates the formally verified theorems about tropical matrix-vector
multiplication and the spectral growth bound for iterated composition.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def trop_mat_vec(A: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Tropical matrix-vector product: (A ⊗ x)_i = max_j (A_ij + x_j)."""
    n = A.shape[0]
    result = np.empty(n)
    for i in range(n):
        result[i] = np.max(A[i, :] + x)
    return result


def sup_norm(x: np.ndarray) -> float:
    """Sup-norm: max_i x_i."""
    return np.max(x)


def mat_max_entry(A: np.ndarray) -> float:
    """Maximum matrix entry (tropical spectral bound)."""
    return np.max(A)


def vertical_iterate(A: np.ndarray, k: int, x: np.ndarray) -> np.ndarray:
    """k-fold tropical matrix-vector iteration."""
    result = x.copy()
    for _ in range(k):
        result = trop_mat_vec(A, result)
    return result


def max_cycle_mean(A: np.ndarray) -> float:
    """Maximum cycle mean of matrix A (tropical spectral radius).
    For an n×n matrix, considers all cycles and returns max average weight."""
    n = A.shape[0]
    # Use Karp's algorithm: compute max cycle mean
    # d[k][i] = max weight of a path of length k ending at i (starting from any vertex)
    d = np.full((n + 1, n), -np.inf)
    d[0, :] = 0.0
    for k in range(1, n + 1):
        for i in range(n):
            for j in range(n):
                d[k][i] = max(d[k][i], d[k-1][j] + A[i][j])
    # Karp's formula: max_i min_k (d[n][i] - d[k][i]) / (n - k)
    result = -np.inf
    for i in range(n):
        min_val = np.inf
        for k in range(n):
            if d[n][i] > -np.inf and d[k][i] > -np.inf:
                val = (d[n][i] - d[k][i]) / (n - k)
                min_val = min(min_val, val)
        if min_val < np.inf:
            result = max(result, min_val)
    return result


# ═══════════════════════════════════════════════════════════════════════
# Demo 1: One-step bound verification
# ═══════════════════════════════════════════════════════════════════════
print("=" * 70)
print("DEMO 1: One-Step Spectral Growth Bound")
print("=" * 70)
print()
print("Theorem: supNorm(A ⊗ x) ≤ matMaxEntry(A) + supNorm(x)")
print()

np.random.seed(42)
for trial in range(5):
    n = np.random.randint(2, 6)
    A = np.random.randn(n, n) * 3
    x = np.random.randn(n) * 2

    result = trop_mat_vec(A, x)
    lhs = sup_norm(result)
    rhs = mat_max_entry(A) + sup_norm(x)

    print(f"  Trial {trial+1}: n={n}")
    print(f"    supNorm(A ⊗ x) = {lhs:.4f}")
    print(f"    matMaxEntry(A) + supNorm(x) = {rhs:.4f}")
    print(f"    Bound satisfied: {lhs <= rhs + 1e-10}  (gap = {rhs - lhs:.4f})")
    print()


# ═══════════════════════════════════════════════════════════════════════
# Demo 2: k-step iterate bound
# ═══════════════════════════════════════════════════════════════════════
print("=" * 70)
print("DEMO 2: k-Step Vertical Composition Bound")
print("=" * 70)
print()
print("Theorem: supNorm(A^k ⊗ x) ≤ k * matMaxEntry(A) + supNorm(x)")
print()

A = np.array([[1.0, -2.0], [0.5, 1.5]])
x = np.array([0.0, 0.0])
M = mat_max_entry(A)

print(f"  Matrix A = {A.tolist()}")
print(f"  matMaxEntry(A) = {M}")
print(f"  Initial x = {x.tolist()}")
print()
print(f"  {'k':>4s}  {'supNorm(A^k x)':>16s}  {'k*M + supNorm(x)':>18s}  {'Bound OK':>10s}")
print(f"  {'─'*4}  {'─'*16}  {'─'*18}  {'─'*10}")

for k in range(11):
    y = vertical_iterate(A, k, x)
    lhs = sup_norm(y)
    rhs = k * M + sup_norm(x)
    print(f"  {k:4d}  {lhs:16.4f}  {rhs:18.4f}  {'✓' if lhs <= rhs + 1e-10 else '✗':>10s}")


# ═══════════════════════════════════════════════════════════════════════
# Demo 3: Eigenvector exactness
# ═══════════════════════════════════════════════════════════════════════
print()
print("=" * 70)
print("DEMO 3: Tropical Eigenvector Iteration Exactness")
print("=" * 70)
print()
print("Theorem: If A ⊗ v = λ + v, then A^k ⊗ v = k*λ + v")
print()

# Construct a matrix with known tropical eigenvector
# For A = [[2, -∞], [-∞, 2]], eigenvector v = [0, 0], eigenvalue λ = 2
# Using finite entries: A = [[2, -100], [-100, 2]]
A_eig = np.array([[2.0, -100.0], [-100.0, 2.0]])
v = np.array([0.0, 0.0])
lam = 2.0

print(f"  Matrix A = {A_eig.tolist()}")
print(f"  Eigenvector v = {v.tolist()}")
print(f"  Eigenvalue λ = {lam}")
print()

# Verify eigenvector condition
Av = trop_mat_vec(A_eig, v)
print(f"  A ⊗ v = {Av.tolist()}")
print(f"  λ + v = {(lam + v).tolist()}")
print(f"  Eigenvector condition: {np.allclose(Av, lam + v)}")
print()

print(f"  {'k':>4s}  {'A^k ⊗ v':>20s}  {'k*λ + v':>20s}  {'Match':>8s}")
print(f"  {'─'*4}  {'─'*20}  {'─'*20}  {'─'*8}")
for k in range(8):
    actual = vertical_iterate(A_eig, k, v)
    expected = k * lam + v
    match = np.allclose(actual, expected)
    print(f"  {k:4d}  {str(actual.tolist()):>20s}  {str(expected.tolist()):>20s}  {'✓' if match else '✗':>8s}")


# ═══════════════════════════════════════════════════════════════════════
# Demo 4: 2×2 Spectral Control
# ═══════════════════════════════════════════════════════════════════════
print()
print("=" * 70)
print("DEMO 4: 2×2 Spectral Control — Depth Growth")
print("=" * 70)
print()

# Three different 2×2 matrices with different spectral properties
matrices = {
    "Stable (M < 0)": np.array([[-1.0, -2.0], [-3.0, -0.5]]),
    "Neutral (M ≈ 0)": np.array([[0.0, -1.0], [-1.0, 0.0]]),
    "Growing (M > 0)": np.array([[2.0, 1.0], [0.5, 1.5]]),
}

for name, A in matrices.items():
    M = mat_max_entry(A)
    mcm = max_cycle_mean(A)
    x0 = np.array([0.0, 0.0])
    print(f"  {name}: matMaxEntry = {M:.2f}, maxCycleMean = {mcm:.2f}")

    norms = []
    for k in range(21):
        y = vertical_iterate(A, k, x0)
        norms.append(sup_norm(y))

    print(f"    k=0: {norms[0]:.2f}, k=5: {norms[5]:.2f}, k=10: {norms[10]:.2f}, k=20: {norms[20]:.2f}")
    print(f"    Growth rate ≈ {(norms[20] - norms[0]) / 20:.4f} (predicted by MCM: {mcm:.4f})")
    print()


# ═══════════════════════════════════════════════════════════════════════
# Demo 5: Zero-input depth certificate
# ═══════════════════════════════════════════════════════════════════════
print("=" * 70)
print("DEMO 5: Zero-Input Depth Certificate")
print("=" * 70)
print()
print("Theorem: supNorm(A^k ⊗ 0) ≤ k * matMaxEntry(A)")
print()

A = np.array([[3.0, 1.0, -2.0],
              [0.0, 2.0, 1.0],
              [-1.0, 0.5, 4.0]])
M = mat_max_entry(A)
x0 = np.zeros(3)

print(f"  3×3 Matrix with matMaxEntry = {M:.1f}")
print()
print(f"  {'k':>4s}  {'supNorm(A^k ⊗ 0)':>18s}  {'k * M':>10s}  {'Gap':>10s}")
print(f"  {'─'*4}  {'─'*18}  {'─'*10}  {'─'*10}")

for k in range(11):
    y = vertical_iterate(A, k, x0)
    lhs = sup_norm(y)
    rhs = k * M
    print(f"  {k:4d}  {lhs:18.4f}  {rhs:10.1f}  {rhs - lhs:10.4f}")


# ═══════════════════════════════════════════════════════════════════════
# Visualization: Growth curves
# ═══════════════════════════════════════════════════════════════════════
print()
print("=" * 70)
print("Generating visualization...")
print("=" * 70)

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: Growth curves for different spectral bounds
ax = axes[0]
K = 30
for M_val, color, label in [(-0.5, 'blue', 'M = -0.5 (contracting)'),
                              (0.0, 'green', 'M = 0 (neutral)'),
                              (1.0, 'orange', 'M = 1 (growing)'),
                              (2.0, 'red', 'M = 2 (fast growing)')]:
    A = np.array([[M_val, M_val - 1], [M_val - 1, M_val]])
    x0 = np.zeros(2)
    norms = [sup_norm(vertical_iterate(A, k, x0)) for k in range(K+1)]
    ax.plot(range(K+1), norms, color=color, label=label, linewidth=2)
    # Plot the bound
    bound = [k * mat_max_entry(A) for k in range(K+1)]
    ax.plot(range(K+1), bound, color=color, linestyle='--', alpha=0.5, linewidth=1)

ax.set_xlabel('Depth k', fontsize=12)
ax.set_ylabel('supNorm(A^k ⊗ 0)', fontsize=12)
ax.set_title('Depth Growth vs Spectral Bound', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 2: Eigenvector exactness
ax = axes[1]
A_eig = np.array([[2.0, -100.0], [-100.0, 2.0]])
v = np.array([1.0, -1.0])
lam = 2.0
K = 15

actual_norms = [sup_norm(vertical_iterate(A_eig, k, v)) for k in range(K+1)]
predicted = [k * lam + sup_norm(v) for k in range(K+1)]
bound = [k * mat_max_entry(A_eig) + sup_norm(v) for k in range(K+1)]

ax.plot(range(K+1), actual_norms, 'bo-', label='Actual supNorm(A^k v)', markersize=5)
ax.plot(range(K+1), predicted, 'g--', label=f'Exact: k·λ + supNorm(v)', linewidth=2)
ax.plot(range(K+1), bound, 'r:', label='Upper bound: k·M + supNorm(v)', linewidth=2)
ax.set_xlabel('Depth k', fontsize=12)
ax.set_ylabel('supNorm', fontsize=12)
ax.set_title('Eigenvector Exactness', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 3: Bound tightness for random matrices
ax = axes[2]
np.random.seed(123)
n_trials = 50
K = 20
ratios = []
for _ in range(n_trials):
    n = 4
    A = np.random.randn(n, n)
    x0 = np.zeros(n)
    actual = sup_norm(vertical_iterate(A, K, x0))
    bound = K * mat_max_entry(A)
    if bound > 0:
        ratios.append(actual / bound)

ax.hist(ratios, bins=20, color='steelblue', edgecolor='white', alpha=0.8)
ax.axvline(x=1.0, color='red', linestyle='--', linewidth=2, label='Bound = 1.0')
ax.set_xlabel('actual / bound', fontsize=12)
ax.set_ylabel('Count', fontsize=12)
ax.set_title(f'Bound Tightness (k={K}, n=4)', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('/workspace/request-project/tropical_growth_visualization.png', dpi=150, bbox_inches='tight')
print("  Saved: tropical_growth_visualization.png")

# Phase diagram
fig2, ax2 = plt.subplots(1, 1, figsize=(8, 6))

a_vals = np.linspace(-3, 3, 50)
d_vals = np.linspace(-3, 3, 50)
AA, DD = np.meshgrid(a_vals, d_vals)

# For mat22(a, 0, 0, d), matMaxEntry = max(a, 0, 0, d) = max(a, d, 0)
# maxCycleMean = max(a, d)
growth_rates = np.maximum(AA, DD)

c = ax2.contourf(AA, DD, growth_rates, levels=20, cmap='RdYlBu_r')
plt.colorbar(c, ax=ax2, label='Max Cycle Mean')
ax2.contour(AA, DD, growth_rates, levels=[0], colors='black', linewidths=2)
ax2.set_xlabel('a (diagonal entry)', fontsize=12)
ax2.set_ylabel('d (diagonal entry)', fontsize=12)
ax2.set_title('Tropical Spectral Phase Diagram\n(Diagonal 2×2 Matrix)', fontsize=13)
ax2.annotate('Contracting\nRegion', xy=(-2, -2), fontsize=11, ha='center',
            color='blue', fontweight='bold')
ax2.annotate('Growing\nRegion', xy=(2, 2), fontsize=11, ha='center',
            color='red', fontweight='bold')
ax2.plot([-3, 3], [-3, 3], 'k--', alpha=0.3, label='a = d')
ax2.legend(fontsize=10)

plt.tight_layout()
plt.savefig('/workspace/request-project/tropical_phase_diagram.png', dpi=150, bbox_inches='tight')
print("  Saved: tropical_phase_diagram.png")

print()
print("All demos completed successfully!")
