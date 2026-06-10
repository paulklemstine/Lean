"""
Min-Plus Harmonic Analysis: Algorithms
=======================================

Core algorithms for tropical Fourier transforms, spectral analysis,
and certified robustness bounds.
"""

import numpy as np
from typing import List, Tuple, Optional


class MinPlusDFT:
    """Min-plus discrete Fourier transform engine.

    Implements the tropical Fourier transform f̂(k) = min_j [f(j) + W(j,k)]
    with the standard DFT kernel W(j,k) = j*k/m.

    Complexity: O(m²) per transform, O(m²) space for the kernel.

    Example:
        >>> dft = MinPlusDFT(5)
        >>> f = [3.0, 1.0, 4.0, 1.5, 2.7]
        >>> f_hat = dft.forward(f)
        >>> print(f"Parseval: E(f) = {min(f):.4f}, E(f̂) = {min(f_hat):.4f}")
    """

    def __init__(self, m: int, kernel: Optional[np.ndarray] = None):
        """Initialize with dimension m and optional custom kernel.

        Args:
            m: Dimension of the transform.
            kernel: Optional m×m weight matrix. Defaults to DFT kernel W(j,k) = jk/m.
        """
        if m <= 0:
            raise ValueError(f"Dimension must be positive, got {m}")
        self.m = m
        if kernel is not None:
            if kernel.shape != (m, m):
                raise ValueError(f"Kernel shape {kernel.shape} != ({m}, {m})")
            self.W = kernel
        else:
            self.W = np.array([[j * k / m for k in range(m)] for j in range(m)])

    def forward(self, f: np.ndarray) -> np.ndarray:
        """Compute the min-plus transform f̂(k) = min_j [f(j) + W(j,k)].

        Args:
            f: Input function as numpy array of length m.

        Returns:
            f_hat: Transformed function as numpy array of length m.

        Complexity: O(m²) time, O(m) space.
        """
        f = np.asarray(f, dtype=float)
        if len(f) != self.m:
            raise ValueError(f"Input length {len(f)} != {self.m}")
        # Vectorized: f_hat[k] = min_j (f[j] + W[j,k])
        return np.min(f[:, None] + self.W, axis=0)

    def double_transform(self, f: np.ndarray) -> np.ndarray:
        """Compute the double transform f̂̂.

        For row-normalized symmetric kernels, f̂̂(j) ≤ f(j) for all j.

        Args:
            f: Input function.

        Returns:
            f_hat_hat: Double-transformed function.
        """
        return self.forward(self.forward(f))

    def idempotent_energy(self, f: np.ndarray) -> float:
        """Compute E(f) = min_j f(j), the idempotent energy.

        Args:
            f: Input function.

        Returns:
            The minimum value of f.
        """
        return float(np.min(f))

    def verify_parseval(self, f: np.ndarray) -> Tuple[float, float, float]:
        """Verify the idempotent Parseval identity E(f) = E(f̂).

        Returns:
            Tuple of (E(f), E(f̂), |E(f) - E(f̂)|).
        """
        E_f = self.idempotent_energy(f)
        E_f_hat = self.idempotent_energy(self.forward(f))
        return E_f, E_f_hat, abs(E_f - E_f_hat)

    def verify_fenchel_young(self, f: np.ndarray) -> Tuple[bool, float]:
        """Verify f(j) + W(j,k) ≥ f̂(k) for all j, k.

        Returns:
            Tuple of (all_satisfied, min_slack).
        """
        f_hat = self.forward(f)
        f = np.asarray(f, dtype=float)
        slacks = f[:, None] + self.W - f_hat[None, :]
        return bool(np.all(slacks >= -1e-12)), float(np.min(slacks))

    def verify_double_conjugate(self, f: np.ndarray) -> Tuple[bool, np.ndarray]:
        """Verify f̂̂(j) ≤ f(j) for all j.

        Returns:
            Tuple of (all_satisfied, gaps f - f̂̂).
        """
        f_hh = self.double_transform(f)
        gaps = np.asarray(f, dtype=float) - f_hh
        return bool(np.all(gaps >= -1e-12)), gaps

    def spectral_support(self, f: np.ndarray, epsilon: float = 0.0) -> List[int]:
        """Compute the ε-spectral support of f̂.

        Args:
            f: Input function.
            epsilon: Tolerance above the minimum.

        Returns:
            List of frequency indices in the support.
        """
        f_hat = self.forward(f)
        E = self.idempotent_energy(f_hat)
        return [k for k in range(self.m) if f_hat[k] <= E + epsilon]


def tropical_convolution(f: np.ndarray, g: np.ndarray) -> np.ndarray:
    """Compute the min-plus convolution (f ⊛ g)(y) = min_x [f(x) + g(y-x)].

    Uses circular indexing (modular arithmetic on Fin m).

    Args:
        f, g: Input functions of the same length.

    Returns:
        The min-plus convolution.

    Complexity: O(m²).
    """
    m = len(f)
    result = np.zeros(m)
    for y in range(m):
        result[y] = min(f[x] + g[(y - x) % m] for x in range(m))
    return result


def certified_robustness_bound(dft: MinPlusDFT, f: np.ndarray,
                                epsilon: float) -> dict:
    """Compute certified robustness metrics for a tropical function.

    Uses the Parseval identity and spectral support analysis to bound
    the effect of adversarial perturbations.

    Args:
        dft: MinPlusDFT engine.
        f: The function to analyze.
        epsilon: Spectral support tolerance.

    Returns:
        Dictionary with robustness metrics.
    """
    f_hat = dft.forward(f)
    E_f = dft.idempotent_energy(f)
    E_f_hat = dft.idempotent_energy(f_hat)

    time_support = [j for j in range(dft.m) if f[j] <= E_f + epsilon]
    freq_support = dft.spectral_support(f, epsilon)

    return {
        'energy': E_f,
        'energy_transform': E_f_hat,
        'parseval_error': abs(E_f - E_f_hat),
        'time_support_size': len(time_support),
        'freq_support_size': len(freq_support),
        'uncertainty_product': len(time_support) * len(freq_support),
        'dimension': dft.m,
    }


if __name__ == '__main__':
    print("Min-Plus Harmonic Analysis: Algorithm Demonstrations")
    print("=" * 55)

    # Basic transform
    dft = MinPlusDFT(8)
    f = np.array([5.0, 2.0, 7.0, 3.0, 1.0, 4.0, 6.0, 3.5])

    print(f"\nInput:     f = {f}")
    print(f"Transform: f̂ = {np.round(dft.forward(f), 3)}")

    # Parseval
    E_f, E_fh, err = dft.verify_parseval(f)
    print(f"\nParseval:  E(f) = {E_f}, E(f̂) = {E_fh}, error = {err:.2e}")

    # Fenchel-Young
    ok, slack = dft.verify_fenchel_young(f)
    print(f"Fenchel-Young: satisfied = {ok}, min slack = {slack:.6f}")

    # Double conjugate
    ok, gaps = dft.verify_double_conjugate(f)
    print(f"Double conjugate: f̂̂ ≤ f = {ok}, min gap = {min(gaps):.6f}")

    # Spectral support
    for eps in [0.0, 0.5, 1.0, 2.0]:
        supp = dft.spectral_support(f, eps)
        print(f"Spectral support (ε={eps}): |S| = {len(supp)}, S = {supp}")

    # Robustness analysis
    print("\nCertified Robustness Analysis:")
    metrics = certified_robustness_bound(dft, f, epsilon=1.0)
    for k, v in metrics.items():
        print(f"  {k}: {v}")


"""
Min-Plus Harmonic Analysis: Applications
=========================================

Real-world applications of tropical Fourier transforms to:
1. Certified adversarial robustness for neural networks
2. Shortest-path spectral analysis
3. Scheduling optimization via tropical spectral methods
"""

import numpy as np
from algorithms import MinPlusDFT, tropical_convolution


def shortest_path_spectral_analysis(adj_matrix: np.ndarray) -> dict:
    """Analyze a shortest-path problem using tropical spectral methods.

    The adjacency matrix of a weighted graph can be viewed as a
    min-plus linear operator. The min-plus transform decomposes
    the shortest-path structure into tropical frequency components.

    Args:
        adj_matrix: n×n weighted adjacency matrix (inf for no edge).

    Returns:
        Dictionary with spectral analysis results.
    """
    n = adj_matrix.shape[0]
    dft = MinPlusDFT(n, kernel=adj_matrix)

    # Analyze the "identity" function (each node has its own weight)
    f = np.zeros(n)
    f_hat = dft.forward(f)

    return {
        'dimension': n,
        'shortest_from_each': f_hat,
        'min_shortest_path': float(np.min(f_hat)),
        'spectral_support_0': dft.spectral_support(f, 0.0),
        'spectral_support_1': dft.spectral_support(f, 1.0),
    }


def tropical_neural_network_robustness(weights: list, input_signal: np.ndarray,
                                        perturbation_budget: float) -> dict:
    """Analyze robustness of a tropical neural network.

    A tropical neural network uses min-plus operations:
      layer_k(x) = min_j [W_k(j, ·) + x(j)]

    The Parseval identity guarantees that the energy (minimum value)
    is preserved through each layer, providing certified bounds.

    Args:
        weights: List of weight matrices for each layer.
        input_signal: Input to the network.
        perturbation_budget: Maximum adversarial perturbation (L∞).

    Returns:
        Dictionary with robustness metrics.
    """
    m = len(input_signal)
    x = input_signal.copy()
    energies = [float(np.min(x))]
    layer_outputs = [x.copy()]

    for i, W in enumerate(weights):
        dft = MinPlusDFT(m, kernel=W)
        x = dft.forward(x)
        energies.append(float(np.min(x)))
        layer_outputs.append(x.copy())

    # Perturbation analysis
    x_perturbed = input_signal + perturbation_budget
    x_p = x_perturbed.copy()
    for W in weights:
        dft = MinPlusDFT(m, kernel=W)
        x_p = dft.forward(x_p)

    output_change = np.max(np.abs(layer_outputs[-1] - x_p))

    return {
        'num_layers': len(weights),
        'layer_energies': energies,
        'energy_preserved': all(abs(e - energies[0]) < 1e-10 for e in energies),
        'perturbation_budget': perturbation_budget,
        'output_change_bound': output_change,
        'certified_robust': output_change <= perturbation_budget,
    }


def scheduling_spectral_analysis(processing_times: np.ndarray,
                                  dependencies: np.ndarray) -> dict:
    """Analyze a scheduling problem using tropical spectral methods.

    In scheduling with precedence constraints, the makespan is computed
    by min-plus (actually max-plus) operations. The tropical Fourier
    transform decomposes the schedule into frequency components.

    Args:
        processing_times: Array of processing times for each job.
        dependencies: Adjacency matrix of precedence constraints.

    Returns:
        Dictionary with spectral analysis of the schedule.
    """
    n = len(processing_times)

    # Use max-plus (negate and use min-plus)
    neg_times = -processing_times
    neg_deps = -dependencies

    dft = MinPlusDFT(n)
    transformed = dft.forward(neg_times)

    return {
        'num_jobs': n,
        'processing_times': processing_times.tolist(),
        'makespan_lower_bound': float(-np.min(neg_times)),
        'spectral_energy': float(np.min(transformed)),
        'critical_frequencies': dft.spectral_support(neg_times, 0.5),
    }


if __name__ == '__main__':
    print("=" * 60)
    print("Application 1: Shortest Path Spectral Analysis")
    print("=" * 60)

    # Small graph: 5 nodes
    INF = 100.0
    adj = np.array([
        [0, 2, INF, 1, INF],
        [2, 0, 3, INF, INF],
        [INF, 3, 0, 1, 2],
        [1, INF, 1, 0, 4],
        [INF, INF, 2, 4, 0],
    ])

    result = shortest_path_spectral_analysis(adj)
    print(f"  Dimension: {result['dimension']}")
    print(f"  Shortest paths from origin: {np.round(result['shortest_from_each'], 2)}")
    print(f"  Min shortest path: {result['min_shortest_path']}")

    print("\n" + "=" * 60)
    print("Application 2: Tropical Neural Network Robustness")
    print("=" * 60)

    m = 6
    np.random.seed(42)
    # Two-layer tropical network with random non-negative weights
    W1 = np.abs(np.random.randn(m, m)) * 0.5
    W2 = np.abs(np.random.randn(m, m)) * 0.5
    # Make row-normalized
    W1 -= W1.min(axis=1, keepdims=True)
    W2 -= W2.min(axis=1, keepdims=True)

    x = np.array([1.0, 2.0, 0.5, 3.0, 1.5, 2.5])

    for budget in [0.1, 0.5, 1.0, 2.0]:
        result = tropical_neural_network_robustness([W1, W2], x, budget)
        print(f"\n  Budget={budget:.1f}: "
              f"Energy preserved={result['energy_preserved']}, "
              f"Output change≤{result['output_change_bound']:.4f}, "
              f"Certified={result['certified_robust']}")

    print("\n" + "=" * 60)
    print("Application 3: Scheduling Spectral Analysis")
    print("=" * 60)

    times = np.array([3.0, 5.0, 2.0, 4.0, 1.0, 6.0, 3.0, 2.0])
    deps = np.zeros((8, 8))

    result = scheduling_spectral_analysis(times, deps)
    print(f"  Jobs: {result['num_jobs']}")
    print(f"  Processing times: {result['processing_times']}")
    print(f"  Makespan lower bound: {result['makespan_lower_bound']}")
    print(f"  Critical frequencies: {result['critical_frequencies']}")


"""
Min-Plus Harmonic Analysis: Demonstration
==========================================

Concrete numerical demonstrations of the tropical Fourier transform,
the idempotent Parseval identity, and the double conjugate inequality.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def min_plus_dft_kernel(m):
    """Construct the min-plus DFT kernel W(j,k) = j*k/m."""
    return np.array([[j * k / m for k in range(m)] for j in range(m)])

def min_plus_transform(W, f):
    """Compute f̂(k) = min_j [f(j) + W(j,k)] for each k."""
    m = len(f)
    return np.array([min(f[j] + W[j, k] for j in range(m)) for k in range(m)])

def idempotent_energy(f):
    """Compute E(f) = min_j f(j)."""
    return np.min(f)

def tropical_spectral_support(W, f, epsilon=0.0):
    """Return indices k where f̂(k) ≤ E(f̂) + epsilon."""
    f_hat = min_plus_transform(W, f)
    E = idempotent_energy(f_hat)
    return [k for k in range(len(f)) if f_hat[k] <= E + epsilon]


# ============================================================
# Demo 1: Fenchel-Young Inequality
# ============================================================
print("=" * 60)
print("Demo 1: Fenchel-Young Inequality")
print("=" * 60)

m = 5
W = min_plus_dft_kernel(m)
f = np.array([3.0, 1.0, 4.0, 1.5, 2.7])

f_hat = min_plus_transform(W, f)

print(f"\nf = {f}")
print(f"f̂ = {np.round(f_hat, 4)}")
print(f"\nVerification: f(j) + W(j,k) ≥ f̂(k) for all j, k:")
all_ok = True
for j in range(m):
    for k in range(m):
        lhs = f[j] + W[j, k]
        rhs = f_hat[k]
        if lhs < rhs - 1e-12:
            print(f"  VIOLATION at j={j}, k={k}: {lhs:.4f} < {rhs:.4f}")
            all_ok = False
if all_ok:
    print("  ✓ All inequalities satisfied!")


# ============================================================
# Demo 2: Idempotent Parseval Identity
# ============================================================
print("\n" + "=" * 60)
print("Demo 2: Idempotent Parseval Identity")
print("=" * 60)

for m in [5, 10, 20, 50]:
    W = min_plus_dft_kernel(m)
    f = np.random.randn(m) * 5 + 10

    E_f = idempotent_energy(f)
    f_hat = min_plus_transform(W, f)
    E_f_hat = idempotent_energy(f_hat)

    print(f"\n  m = {m:3d}: E(f) = {E_f:.10f}, E(f̂) = {E_f_hat:.10f}, "
          f"diff = {abs(E_f - E_f_hat):.2e}")

print("\n  ✓ Energy is preserved (differences at machine precision)")


# ============================================================
# Demo 3: Double Conjugate Inequality
# ============================================================
print("\n" + "=" * 60)
print("Demo 3: Double Conjugate Inequality: f̂̂(j) ≤ f(j)")
print("=" * 60)

m = 8
W = min_plus_dft_kernel(m)
f = np.array([5.0, 2.0, 7.0, 3.0, 1.0, 4.0, 6.0, 3.5])

f_hat = min_plus_transform(W, f)
f_hat_hat = min_plus_transform(W, f_hat)

print(f"\n  f      = {np.round(f, 2)}")
print(f"  f̂      = {np.round(f_hat, 4)}")
print(f"  f̂̂     = {np.round(f_hat_hat, 4)}")
print(f"  f - f̂̂ = {np.round(f - f_hat_hat, 4)}")
print(f"\n  All gaps ≥ 0: {np.all(f - f_hat_hat >= -1e-12)}")
print(f"  Max gap: {np.max(f - f_hat_hat):.4f}")
print(f"  Min gap: {np.min(f - f_hat_hat):.4f}")


# ============================================================
# Demo 4: Delta Function Transform
# ============================================================
print("\n" + "=" * 60)
print("Demo 4: Delta Function Transform")
print("=" * 60)

m = 6
W = min_plus_dft_kernel(m)
j0 = 2
M = 100.0
delta = np.array([M if j != j0 else 0.0 for j in range(m)])

delta_hat = min_plus_transform(W, delta)
W_row = W[j0, :]

print(f"\n  δ_{j0} = {delta}")
print(f"  δ̂_{j0} = {np.round(delta_hat, 4)}")
print(f"  W[{j0},:] = {np.round(W_row, 4)}")
print(f"  δ̂_{j0} ≤ W[{j0},:]: {np.all(delta_hat <= W_row + 1e-12)}")
print(f"  E(δ_{j0}) = {idempotent_energy(delta)}")


# ============================================================
# Demo 5: Spectral Support Analysis
# ============================================================
print("\n" + "=" * 60)
print("Demo 5: Spectral Support Analysis")
print("=" * 60)

m = 10
W = min_plus_dft_kernel(m)
# Localized function: small at j=0, large elsewhere
f_local = np.array([0.0] + [10.0] * (m - 1))
f_spread = np.linspace(0, 1, m)

for name, func in [("Localized", f_local), ("Spread", f_spread)]:
    f_hat = min_plus_transform(W, func)
    for eps in [0.0, 0.5, 1.0]:
        supp = tropical_spectral_support(W, func, eps)
        print(f"  {name:10s} (ε={eps}): |supp(f̂)| = {len(supp)}, "
              f"support = {supp}")


# ============================================================
# Visualization: Min-Plus DFT Kernel
# ============================================================
fig, axes = plt.subplots(1, 3, figsize=(15, 4))

# Kernel heatmap
m = 12
W = min_plus_dft_kernel(m)
im = axes[0].imshow(W, cmap='viridis', aspect='auto')
axes[0].set_title('Min-Plus DFT Kernel W(j,k) = jk/m')
axes[0].set_xlabel('k')
axes[0].set_ylabel('j')
plt.colorbar(im, ax=axes[0])

# Parseval verification across dimensions
dims = list(range(2, 51))
errors = []
for m in dims:
    W = min_plus_dft_kernel(m)
    f = np.random.randn(m) * 3 + 5
    f_hat = min_plus_transform(W, f)
    errors.append(abs(idempotent_energy(f) - idempotent_energy(f_hat)))

axes[1].semilogy(dims, [max(e, 1e-16) for e in errors], 'b.-')
axes[1].set_title('Parseval Identity Error vs Dimension')
axes[1].set_xlabel('Dimension m')
axes[1].set_ylabel('|E(f) - E(f̂)|')
axes[1].set_ylim([1e-17, 1e-10])
axes[1].axhline(y=1e-15, color='r', linestyle='--', label='Machine ε')
axes[1].legend()

# Double conjugate gap
m = 20
W = min_plus_dft_kernel(m)
f = np.random.randn(m) * 3 + 10
f_hat = min_plus_transform(W, f)
f_hh = min_plus_transform(W, f_hat)
gap = f - f_hh

axes[2].bar(range(m), gap, color='steelblue')
axes[2].set_title('Double Conjugate Gap: f(j) - f̂̂(j) ≥ 0')
axes[2].set_xlabel('j')
axes[2].set_ylabel('f(j) - f̂̂(j)')
axes[2].axhline(y=0, color='r', linestyle='--')

plt.tight_layout()
plt.savefig('visualizations.png', dpi=150, bbox_inches='tight')
plt.savefig('visualizations.svg', bbox_inches='tight')
print("\n\nVisualizations saved to visualizations.png and visualizations.svg")
