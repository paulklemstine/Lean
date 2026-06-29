#!/usr/bin/env python3
"""
Applications of Tropical Barrier Theory

Demonstrates real-world applications of the tropical diffusion barrier
framework to:
1. Network flow stability analysis
2. Consensus dynamics on graphs
3. Discrete vorticity control for fluid simulation
4. Neural network activation bounding
"""

import numpy as np
from typing import Tuple


def tropical_diffusion(K: np.ndarray, u: np.ndarray) -> np.ndarray:
    """Min-plus tropical diffusion: T_K(u)(i) = min_j (u[j] + K[i,j])."""
    return np.min(K + u[np.newaxis, :], axis=1)


# ─────────────────────────────────────────────────────────────────────
# Application 1: Network Flow Stability
# ─────────────────────────────────────────────────────────────────────

def network_stability_analysis(
    adjacency: np.ndarray,
    initial_load: np.ndarray,
    dissipation: float = -0.1,
    n_steps: int = 50,
) -> Tuple[np.ndarray, np.ndarray]:
    """
    Analyze stability of load distribution on a network.

    Models a network where each node has a load value, and load
    redistributes via tropical diffusion (shortest-path routing).
    The barrier theorem guarantees peak load never increases.

    Args:
        adjacency: (n, n) adjacency matrix (0/1 or weighted)
        initial_load: (n,) initial load at each node
        dissipation: per-step dissipation (< 0 for energy loss)
        n_steps: simulation steps

    Returns:
        trajectory: (n_steps+1, n) load trajectory
        peak_loads: (n_steps+1,) peak load at each step
    """
    n = len(initial_load)
    # Convert adjacency to tropical viscosity kernel
    K = np.where(adjacency > 0, adjacency, np.inf)
    np.fill_diagonal(K, 0)
    # Use graph shortest paths as kernel
    # Floyd-Warshall for all-pairs shortest paths
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if K[i, k] + K[k, j] < K[i, j]:
                    K[i, j] = K[i, k] + K[k, j]

    trajectory = np.zeros((n_steps + 1, n))
    peak_loads = np.zeros(n_steps + 1)
    trajectory[0] = initial_load.copy()
    peak_loads[0] = initial_load.max()

    for step in range(n_steps):
        omega = trajectory[step]
        T_omega = tropical_diffusion(K, omega)
        trajectory[step + 1] = np.minimum(omega, T_omega + dissipation)
        peak_loads[step + 1] = trajectory[step + 1].max()

    return trajectory, peak_loads


# ─────────────────────────────────────────────────────────────────────
# Application 2: Consensus Dynamics
# ─────────────────────────────────────────────────────────────────────

def tropical_consensus(
    K: np.ndarray,
    opinions: np.ndarray,
    n_steps: int = 100,
) -> Tuple[np.ndarray, np.ndarray]:
    """
    Tropical consensus protocol on a weighted graph.

    Each agent updates their opinion to the minimum of neighboring
    opinions plus communication cost. The oscillation contraction
    theorem guarantees convergence to consensus.

    Args:
        K: (n, n) communication cost kernel
        opinions: (n,) initial opinions
        n_steps: number of rounds

    Returns:
        trajectory: (n_steps+1, n) opinion trajectory
        oscillations: (n_steps+1,) oscillation at each step
    """
    n = len(opinions)
    trajectory = np.zeros((n_steps + 1, n))
    oscillations = np.zeros(n_steps + 1)

    trajectory[0] = opinions.copy()
    oscillations[0] = opinions.max() - opinions.min()

    for step in range(n_steps):
        trajectory[step + 1] = tropical_diffusion(K, trajectory[step])
        oscillations[step + 1] = (trajectory[step + 1].max() -
                                   trajectory[step + 1].min())

    return trajectory, oscillations


# ─────────────────────────────────────────────────────────────────────
# Application 3: Discrete Vorticity Control
# ─────────────────────────────────────────────────────────────────────

def vorticity_simulation(
    grid_size: int = 8,
    viscosity: float = 0.5,
    dissipation: float = -0.05,
    n_steps: int = 100,
) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """
    Simulate discrete vorticity evolution with tropical viscosity barrier.

    Models a 2D grid where vorticity evolves under tropical diffusion
    with a distance-based kernel. The barrier theorem certifies that
    the maximum vorticity is nonincreasing.

    Args:
        grid_size: size of the grid (grid_size x grid_size)
        viscosity: scale factor for the distance kernel
        dissipation: per-step dissipation
        n_steps: simulation steps

    Returns:
        trajectory: (n_steps+1, grid_size^2) vorticity trajectory
        max_vorticity: (n_steps+1,) maximum vorticity
        theoretical_bound: (n_steps+1,) theoretical barrier bound
    """
    n = grid_size * grid_size

    # Build distance kernel on 2D grid
    coords = np.array([(i, j) for i in range(grid_size)
                       for j in range(grid_size)])
    K = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            dist = abs(coords[i][0] - coords[j][0]) + abs(coords[i][1] - coords[j][1])
            K[i, j] = viscosity * dist

    # Initial vorticity: localized vortex
    omega_0 = np.zeros(n)
    center = grid_size // 2
    for i in range(n):
        r = abs(coords[i][0] - center) + abs(coords[i][1] - center)
        omega_0[i] = max(0, 10.0 - 2.0 * r)

    trajectory = np.zeros((n_steps + 1, n))
    max_vorticity = np.zeros(n_steps + 1)
    M0 = omega_0.max()

    trajectory[0] = omega_0.copy()
    max_vorticity[0] = M0

    for step in range(n_steps):
        omega = trajectory[step]
        T_omega = tropical_diffusion(K, omega)
        trajectory[step + 1] = np.minimum(omega, T_omega + dissipation)
        max_vorticity[step + 1] = trajectory[step + 1].max()

    theoretical_bound = np.full(n_steps + 1, M0)  # constant barrier

    return trajectory, max_vorticity, theoretical_bound


# ─────────────────────────────────────────────────────────────────────
# Application 4: Neural Network Activation Bounding
# ─────────────────────────────────────────────────────────────────────

def tropical_neural_bound(
    weight_matrices: list,
    input_bound: float,
) -> float:
    """
    Compute certified activation bound for a tropical neural network.

    A tropical (min-plus) neural network layer computes
    h_{l+1}(i) = min_j (W_l(i,j) + h_l(j))

    If all weight matrices have nonneg entries and zero diagonal,
    the barrier theorem guarantees max(h_l) <= max(h_0) for all layers.

    Args:
        weight_matrices: list of (n, n) weight matrices
        input_bound: maximum absolute value of input activations

    Returns:
        certified upper bound on activations at any layer
    """
    bound = input_bound
    for W in weight_matrices:
        # Verify tropical viscosity kernel property
        assert np.all(W >= 0), "Weight matrix must be nonnegative"
        assert np.allclose(np.diag(W), 0), "Weight matrix must have zero diagonal"
        # By the barrier theorem, max does not increase
        # bound remains unchanged

    return bound


def demo_network_stability():
    """Demonstrate network flow stability analysis."""
    print("=" * 60)
    print("APPLICATION 1: Network Flow Stability")
    print("=" * 60)

    # Small network: ring with shortcuts
    n = 6
    adj = np.zeros((n, n))
    for i in range(n):
        adj[i, (i + 1) % n] = 1
        adj[(i + 1) % n, i] = 1
    adj[0, 3] = 1  # shortcut
    adj[3, 0] = 1

    load = np.array([10.0, 2.0, 5.0, 15.0, 3.0, 8.0])
    print(f"\nInitial load: {load}")
    print(f"Peak load: {load.max()}")

    traj, peaks = network_stability_analysis(adj, load, dissipation=-0.2, n_steps=30)
    print(f"\nAfter 30 steps:")
    print(f"  Final load: {np.round(traj[-1], 2)}")
    print(f"  Peak load: {peaks[-1]:.4f}")
    print(f"  Peak nonincreasing: {all(peaks[i+1] <= peaks[i] + 1e-10 for i in range(len(peaks)-1))}")


def demo_consensus():
    """Demonstrate tropical consensus dynamics."""
    print("\n" + "=" * 60)
    print("APPLICATION 2: Tropical Consensus")
    print("=" * 60)

    n = 5
    K = np.array([
        [0, 0.5, 1, 1.5, 2],
        [0.5, 0, 0.5, 1, 1.5],
        [1, 0.5, 0, 0.5, 1],
        [1.5, 1, 0.5, 0, 0.5],
        [2, 1.5, 1, 0.5, 0],
    ])

    opinions = np.array([10.0, 2.0, 7.0, 15.0, 4.0])
    print(f"\nInitial opinions: {opinions}")
    print(f"Initial oscillation: {opinions.max() - opinions.min():.2f}")

    traj, oscs = tropical_consensus(K, opinions, n_steps=20)
    print(f"\nAfter 20 rounds:")
    print(f"  Final opinions: {np.round(traj[-1], 4)}")
    print(f"  Final oscillation: {oscs[-1]:.6f}")
    print(f"  Oscillation nonincreasing: "
          f"{all(oscs[i+1] <= oscs[i] + 1e-10 for i in range(len(oscs)-1))}")


def demo_vorticity():
    """Demonstrate discrete vorticity control."""
    print("\n" + "=" * 60)
    print("APPLICATION 3: Discrete Vorticity Control")
    print("=" * 60)

    traj, maxv, bound = vorticity_simulation(
        grid_size=6, viscosity=0.3, dissipation=-0.1, n_steps=50
    )

    print(f"\n6x6 grid, viscosity=0.3, dissipation=-0.1")
    print(f"Initial max vorticity: {maxv[0]:.4f}")
    print(f"Final max vorticity:   {maxv[-1]:.4f}")
    print(f"Barrier bound:         {bound[-1]:.4f}")
    print(f"Bound holds at all steps: "
          f"{all(maxv[i] <= bound[i] + 1e-10 for i in range(len(maxv)))}")
    print(f"Max nonincreasing: "
          f"{all(maxv[i+1] <= maxv[i] + 1e-10 for i in range(len(maxv)-1))}")


def demo_neural():
    """Demonstrate neural network activation bounding."""
    print("\n" + "=" * 60)
    print("APPLICATION 4: Neural Network Activation Bounding")
    print("=" * 60)

    n = 4
    layers = 5
    weights = []
    for _ in range(layers):
        W = np.random.rand(n, n) * 2
        np.fill_diagonal(W, 0)
        weights.append(W)

    input_bound = 10.0
    cert_bound = tropical_neural_bound(weights, input_bound)
    print(f"\n{layers}-layer tropical network, {n} neurons per layer")
    print(f"Input bound: {input_bound}")
    print(f"Certified activation bound: {cert_bound}")

    # Verify empirically
    np.random.seed(0)
    max_activation = 0
    for trial in range(1000):
        h = np.random.uniform(0, input_bound, n)
        for W in weights:
            h = tropical_diffusion(W, h)
        max_activation = max(max_activation, h.max())

    print(f"Empirical max activation (1000 trials): {max_activation:.4f}")
    print(f"Bound holds: {max_activation <= cert_bound + 1e-10}")


if __name__ == "__main__":
    demo_network_stability()
    demo_consensus()
    demo_vorticity()
    demo_neural()
    print("\n" + "=" * 60)
    print("All application demos completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Diffusion and Barrier Theorem Demonstrations

Concrete numerical examples demonstrating:
1. Tropical (min-plus) diffusion on finite state spaces
2. The tropical maximum principle
3. Dissipative barrier evolution (Theorem B)
4. Exponential decay under linear damping (Theorem C)
5. Oscillation contraction
"""

import numpy as np


def tropical_diffusion(K: np.ndarray, u: np.ndarray) -> np.ndarray:
    """
    Min-plus tropical diffusion operator.
    T_K(u)(i) = min_j (u[j] + K[i,j])

    Args:
        K: (n, n) nonnegative kernel matrix
        u: (n,) state vector

    Returns:
        (n,) diffused state
    """
    n = len(u)
    result = np.zeros(n)
    for i in range(n):
        result[i] = min(u[j] + K[i, j] for j in range(n))
    return result


def dissipative_update(K: np.ndarray, c: float, u: np.ndarray) -> np.ndarray:
    """
    Dissipative barrier update.
    Phi(u)(i) = min(u[i], T_K(u)(i) + c)

    Args:
        K: (n, n) nonnegative kernel matrix
        c: dissipation constant (should be <= 0)
        u: (n,) state vector

    Returns:
        (n,) updated state
    """
    Tu = tropical_diffusion(K, u)
    return np.minimum(u, Tu + c)


def damped_update(K: np.ndarray, c: float, lam: float, u: np.ndarray) -> np.ndarray:
    """
    Damped barrier update with linear contraction.
    Phi(u)(i) = min(lam * u[i], T_K(u)(i) + c)

    Args:
        K: (n, n) nonnegative kernel matrix
        c: dissipation constant (should be <= 0)
        lam: damping factor (0 <= lam <= 1)
        u: (n,) state vector

    Returns:
        (n,) updated state
    """
    Tu = tropical_diffusion(K, u)
    return np.minimum(lam * u, Tu + c)


def demo_maximum_principle():
    """Demonstrate the tropical maximum principle (Theorem A)."""
    print("=" * 60)
    print("DEMO 1: Tropical Maximum Principle")
    print("=" * 60)

    # Define a 4-site system with a tropical viscosity kernel
    K = np.array([
        [0.0, 1.0, 2.0, 3.0],
        [1.0, 0.0, 1.0, 2.0],
        [2.0, 1.0, 0.0, 1.0],
        [3.0, 2.0, 1.0, 0.0],
    ])
    print(f"\nKernel K (graph distance matrix):\n{K}")
    assert np.all(K >= 0), "K must be nonneg"
    assert np.all(np.diag(K) == 0), "K must have zero diagonal"

    u = np.array([5.0, 2.0, 8.0, 3.0])
    print(f"\nInitial state u = {u}")
    print(f"  min(u) = {u.min():.2f}")
    print(f"  max(u) = {u.max():.2f}")

    Tu = tropical_diffusion(K, u)
    print(f"\nDiffused state T_K(u) = {Tu}")
    print(f"  min(T_K(u)) = {Tu.min():.2f}")
    print(f"  max(T_K(u)) = {Tu.max():.2f}")

    print(f"\n  min(u) <= min(T_K(u))? {u.min() <= Tu.min() + 1e-10}  "
          f"({u.min():.2f} <= {Tu.min():.2f})")
    print(f"  min(T_K(u)) = min(u)?  {abs(Tu.min() - u.min()) < 1e-10}  "
          f"(preserved exactly)")
    print(f"  max(T_K(u)) <= max(u)? {Tu.max() <= u.max() + 1e-10}  "
          f"({Tu.max():.2f} <= {u.max():.2f})")
    print(f"  Oscillation: {u.max() - u.min():.2f} -> {Tu.max() - Tu.min():.2f}")


def demo_barrier_nonincreasing():
    """Demonstrate the dissipative barrier theorem (Theorem B)."""
    print("\n" + "=" * 60)
    print("DEMO 2: Dissipative Barrier (Theorem B)")
    print("=" * 60)

    n_sites = 5
    # Random tropical viscosity kernel
    np.random.seed(42)
    K = np.random.rand(n_sites, n_sites) * 3
    K = (K + K.T) / 2  # symmetrize
    np.fill_diagonal(K, 0)  # zero diagonal

    omega = np.array([10.0, 7.0, 15.0, 3.0, 12.0])
    c = -0.5  # dissipation constant

    print(f"\nInitial vorticity: {omega}")
    print(f"Dissipation constant c = {c}")
    print(f"\n{'Step':>4}  {'max(ω)':>8}  {'min(ω)':>8}  {'osc(ω)':>8}")
    print(f"{'─' * 4}  {'─' * 8}  {'─' * 8}  {'─' * 8}")

    maxes = [omega.max()]
    for step in range(20):
        osc = omega.max() - omega.min()
        print(f"{step:4d}  {omega.max():8.4f}  {omega.min():8.4f}  {osc:8.4f}")
        omega = dissipative_update(K, c, omega)
        maxes.append(omega.max())

    print(f"\nmax(ω) nonincreasing? {all(maxes[i+1] <= maxes[i] + 1e-10 for i in range(len(maxes)-1))}")


def demo_exponential_decay():
    """Demonstrate exponential decay (Theorem C)."""
    print("\n" + "=" * 60)
    print("DEMO 3: Exponential Decay (Theorem C)")
    print("=" * 60)

    n_sites = 4
    K = np.array([
        [0, 1, 2, 3],
        [1, 0, 1, 2],
        [2, 1, 0, 1],
        [3, 2, 1, 0],
    ], dtype=float)

    lam = 0.9
    c = -0.1
    omega = np.array([10.0, 8.0, 12.0, 6.0])
    M0 = omega.max()

    print(f"\nDamping factor λ = {lam}")
    print(f"Dissipation c = {c}")
    print(f"Initial max M_0 = {M0}")
    print(f"\n{'Step':>4}  {'max(ω)':>10}  {'λ^n·M_0':>10}  {'Bound holds':>12}")
    print(f"{'─' * 4}  {'─' * 10}  {'─' * 10}  {'─' * 12}")

    for n in range(25):
        bound = lam ** n * M0
        actual = omega.max()
        holds = actual <= bound + 1e-10
        print(f"{n:4d}  {actual:10.6f}  {bound:10.6f}  {'✓' if holds else '✗':>12}")
        omega = damped_update(K, c, lam, omega)

    print(f"\nAfter 24 steps: max(ω) = {omega.max():.6f}")
    print(f"Theoretical bound λ^24·M_0 = {lam**24 * M0:.6f}")


def demo_oscillation_contraction():
    """Demonstrate oscillation (energy) contraction."""
    print("\n" + "=" * 60)
    print("DEMO 4: Oscillation Contraction")
    print("=" * 60)

    n_sites = 6
    K = np.zeros((n_sites, n_sites))
    for i in range(n_sites):
        for j in range(n_sites):
            K[i, j] = abs(i - j) * 0.5  # linear distance kernel
    np.fill_diagonal(K, 0)

    omega = np.array([20.0, 2.0, 15.0, 1.0, 18.0, 5.0])
    c = -0.3

    print(f"\nInitial state: {omega}")
    print(f"Initial oscillation: {omega.max() - omega.min():.4f}")
    print(f"\n{'Step':>4}  {'osc(ω)':>10}  {'max(ω)':>10}  {'min(ω)':>10}")
    print(f"{'─' * 4}  {'─' * 10}  {'─' * 10}  {'─' * 10}")

    for step in range(30):
        osc = omega.max() - omega.min()
        print(f"{step:4d}  {osc:10.4f}  {omega.max():10.4f}  {omega.min():10.4f}")
        omega = dissipative_update(K, c, omega)

    print(f"\nFinal state: {np.round(omega, 4)}")
    print(f"Final oscillation: {omega.max() - omega.min():.6f}")


def demo_monotonicity():
    """Demonstrate monotonicity of tropical diffusion."""
    print("\n" + "=" * 60)
    print("DEMO 5: Monotonicity of Tropical Diffusion")
    print("=" * 60)

    K = np.array([
        [0, 1, 2],
        [1, 0, 1],
        [2, 1, 0],
    ], dtype=float)

    u = np.array([3.0, 1.0, 5.0])
    v = np.array([4.0, 2.0, 6.0])

    print(f"\nu = {u}")
    print(f"v = {v}")
    print(f"u <= v pointwise? {np.all(u <= v)}")

    Tu = tropical_diffusion(K, u)
    Tv = tropical_diffusion(K, v)
    print(f"\nT_K(u) = {Tu}")
    print(f"T_K(v) = {Tv}")
    print(f"T_K(u) <= T_K(v) pointwise? {np.all(Tu <= Tv + 1e-10)}")


if __name__ == "__main__":
    demo_maximum_principle()
    demo_barrier_nonincreasing()
    demo_exponential_decay()
    demo_oscillation_contraction()
    demo_monotonicity()
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for Tropical Barrier Theory

Generates publication-quality figures demonstrating:
1. Barrier nonincreasing (Theorem B)
2. Exponential decay (Theorem C)
3. Oscillation contraction
4. Vorticity field evolution
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
import base64
from io import BytesIO


def tropical_diffusion(K, u):
    return np.min(K + u[np.newaxis, :], axis=1)


def save_fig_base64(fig) -> str:
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode()


def plot_barrier_theorem():
    """Plot Theorem B: fmax nonincreasing under barrier evolution."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    n_sites = 6
    K = np.zeros((n_sites, n_sites))
    for i in range(n_sites):
        for j in range(n_sites):
            K[i, j] = abs(i - j) * 0.8
    np.fill_diagonal(K, 0)

    # Multiple initial conditions
    np.random.seed(42)
    colors = ['#2196F3', '#FF5722', '#4CAF50', '#9C27B0']
    n_steps = 40

    for idx, scale in enumerate([1.0, 1.5, 0.7, 2.0]):
        omega = np.random.rand(n_sites) * 10 * scale + 2
        maxes = [omega.max()]
        mins = [omega.min()]
        for step in range(n_steps):
            T = tropical_diffusion(K, omega)
            omega = np.minimum(omega, T - 0.3)
            maxes.append(omega.max())
            mins.append(omega.min())

        axes[0].plot(maxes, color=colors[idx], linewidth=2,
                     label=f'Trial {idx+1}', alpha=0.8)

    axes[0].set_xlabel('Time Step', fontsize=12)
    axes[0].set_ylabel('Global Maximum', fontsize=12)
    axes[0].set_title('Theorem B: Max Nonincreasing Under Barrier Evolution',
                      fontsize=13, fontweight='bold')
    axes[0].legend(fontsize=10)
    axes[0].grid(True, alpha=0.3)

    # Single trajectory with min and max
    omega = np.array([15.0, 3.0, 10.0, 7.0, 12.0, 5.0])
    maxes, mins, oscs = [omega.max()], [omega.min()], [omega.max() - omega.min()]
    for step in range(n_steps):
        T = tropical_diffusion(K, omega)
        omega = np.minimum(omega, T - 0.2)
        maxes.append(omega.max())
        mins.append(omega.min())
        oscs.append(omega.max() - omega.min())

    steps = range(len(maxes))
    axes[1].fill_between(steps, mins, maxes, alpha=0.3, color='#2196F3')
    axes[1].plot(maxes, 'b-', linewidth=2, label='max(ω)')
    axes[1].plot(mins, 'r-', linewidth=2, label='min(ω)')
    axes[1].plot(oscs, 'g--', linewidth=2, label='oscillation')
    axes[1].set_xlabel('Time Step', fontsize=12)
    axes[1].set_ylabel('Value', fontsize=12)
    axes[1].set_title('Range Contraction Under Dissipative Update', fontsize=13,
                      fontweight='bold')
    axes[1].legend(fontsize=10)
    axes[1].grid(True, alpha=0.3)

    plt.tight_layout()
    fig.savefig('fig_barrier_theorem.png', dpi=150, bbox_inches='tight')
    b64 = save_fig_base64(fig)
    plt.close()
    return b64


def plot_exponential_decay():
    """Plot Theorem C: exponential decay with damping."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    K = np.array([
        [0, 1, 2, 3],
        [1, 0, 1, 2],
        [2, 1, 0, 1],
        [3, 2, 1, 0],
    ], dtype=float)

    n_steps = 50
    lambdas = [0.99, 0.95, 0.9, 0.8, 0.7]
    colors = ['#F44336', '#FF9800', '#FFC107', '#4CAF50', '#2196F3']

    for lam, color in zip(lambdas, colors):
        omega = np.array([12.0, 8.0, 15.0, 6.0])
        M0 = omega.max()
        maxes = [M0]
        bounds = [M0]

        for step in range(n_steps):
            T = tropical_diffusion(K, omega)
            omega = np.minimum(lam * omega, T)
            maxes.append(omega.max())
            bounds.append(lam ** (step + 1) * M0)

        axes[0].semilogy(maxes, color=color, linewidth=2, label=f'λ={lam}')
        axes[0].semilogy(bounds, '--', color=color, linewidth=1, alpha=0.5)

    axes[0].set_xlabel('Time Step', fontsize=12)
    axes[0].set_ylabel('max(ω) [log scale]', fontsize=12)
    axes[0].set_title('Theorem C: Exponential Decay for Various λ',
                      fontsize=13, fontweight='bold')
    axes[0].legend(fontsize=10)
    axes[0].grid(True, alpha=0.3, which='both')

    # Convergence rate comparison
    lam = 0.9
    omega = np.array([12.0, 8.0, 15.0, 6.0])
    M0 = omega.max()
    maxes = [M0]
    bounds = [M0]

    for step in range(n_steps):
        T = tropical_diffusion(K, omega)
        omega = np.minimum(lam * omega, T)
        maxes.append(omega.max())
        bounds.append(lam ** (step + 1) * M0)

    ratios = np.array(maxes[1:]) / np.array(maxes[:-1])
    ratios = np.where(np.array(maxes[:-1]) > 1e-15, ratios, lam)

    axes[1].plot(ratios, 'b-', linewidth=2, label='Actual ratio M_{n+1}/M_n')
    axes[1].axhline(y=lam, color='r', linestyle='--', linewidth=2,
                    label=f'λ = {lam}')
    axes[1].set_xlabel('Time Step', fontsize=12)
    axes[1].set_ylabel('Ratio', fontsize=12)
    axes[1].set_title('Step-by-Step Contraction Ratio (λ=0.9)',
                      fontsize=13, fontweight='bold')
    axes[1].legend(fontsize=10)
    axes[1].grid(True, alpha=0.3)
    axes[1].set_ylim(0, 1.1)

    plt.tight_layout()
    fig.savefig('fig_exponential_decay.png', dpi=150, bbox_inches='tight')
    b64 = save_fig_base64(fig)
    plt.close()
    return b64


def plot_vorticity_evolution():
    """Plot vorticity field evolution on a 2D grid."""
    grid_size = 10
    n = grid_size * grid_size

    coords = np.array([(i, j) for i in range(grid_size) for j in range(grid_size)])
    K = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            K[i, j] = 0.5 * (abs(coords[i][0] - coords[j][0]) +
                              abs(coords[i][1] - coords[j][1]))
    np.fill_diagonal(K, 0)

    # Initial vortex
    center = grid_size // 2
    omega = np.zeros(n)
    for i in range(n):
        r = np.sqrt((coords[i][0] - center)**2 + (coords[i][1] - center)**2)
        omega[i] = max(0, 10.0 * np.exp(-r))

    fig, axes = plt.subplots(2, 4, figsize=(16, 8))
    steps_to_show = [0, 5, 15, 40]

    current = omega.copy()
    step = 0
    for idx, target_step in enumerate(steps_to_show):
        while step < target_step:
            T = tropical_diffusion(K, current)
            current = np.minimum(current, T - 0.1)
            current = np.maximum(current, 0)
            step += 1

        field = current.reshape(grid_size, grid_size)
        im = axes[0, idx].imshow(field, cmap='hot', vmin=0, vmax=10,
                                  interpolation='bilinear')
        axes[0, idx].set_title(f'Step {target_step}', fontsize=12, fontweight='bold')
        axes[0, idx].axis('off')

        axes[1, idx].bar(range(n), current, color='steelblue', alpha=0.7, width=1.0)
        axes[1, idx].set_ylim(0, 12)
        axes[1, idx].set_xlabel('Site', fontsize=10)
        axes[1, idx].set_ylabel('ω', fontsize=10)
        axes[1, idx].set_title(f'max={current.max():.2f}', fontsize=10)

    fig.suptitle('Vorticity Evolution Under Tropical Diffusion Barrier',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    fig.savefig('fig_vorticity_evolution.png', dpi=150, bbox_inches='tight')
    b64 = save_fig_base64(fig)
    plt.close()
    return b64


def plot_comparison_principle():
    """Plot the tropical maximum principle."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    n = 8
    K = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            K[i, j] = abs(i - j) * 0.5
    np.fill_diagonal(K, 0)

    u = np.array([8, 3, 10, 2, 7, 5, 9, 4], dtype=float)
    Tu = tropical_diffusion(K, u)

    x = np.arange(n)
    width = 0.35

    axes[0].bar(x - width/2, u, width, label='u', color='#2196F3', alpha=0.8)
    axes[0].bar(x + width/2, Tu, width, label='T_K(u)', color='#FF5722', alpha=0.8)
    axes[0].axhline(y=u.min(), color='blue', linestyle='--', alpha=0.5,
                    label=f'min(u) = {u.min():.0f}')
    axes[0].axhline(y=u.max(), color='red', linestyle='--', alpha=0.5,
                    label=f'max(u) = {u.max():.0f}')
    axes[0].set_xlabel('Site i', fontsize=12)
    axes[0].set_ylabel('Value', fontsize=12)
    axes[0].set_title('Maximum Principle: T_K preserves range',
                      fontsize=13, fontweight='bold')
    axes[0].legend(fontsize=9)
    axes[0].grid(True, alpha=0.3)

    # Multiple iterations
    n_iter = 15
    maxes = [u.max()]
    mins = [u.min()]
    oscs = [u.max() - u.min()]
    current = u.copy()
    for _ in range(n_iter):
        current = tropical_diffusion(K, current)
        maxes.append(current.max())
        mins.append(current.min())
        oscs.append(current.max() - current.min())

    axes[1].plot(maxes, 'r-o', markersize=4, linewidth=2, label='max')
    axes[1].plot(mins, 'b-o', markersize=4, linewidth=2, label='min')
    axes[1].fill_between(range(len(maxes)), mins, maxes, alpha=0.15, color='purple')
    axes[1].set_xlabel('Iteration', fontsize=12)
    axes[1].set_ylabel('Value', fontsize=12)
    axes[1].set_title('Iterated Diffusion: Range Contracts',
                      fontsize=13, fontweight='bold')
    axes[1].legend(fontsize=10)
    axes[1].grid(True, alpha=0.3)

    plt.tight_layout()
    fig.savefig('fig_comparison_principle.png', dpi=150, bbox_inches='tight')
    b64 = save_fig_base64(fig)
    plt.close()
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")

    b64_barrier = plot_barrier_theorem()
    print(f"  fig_barrier_theorem.png generated ({len(b64_barrier)} chars)")

    b64_decay = plot_exponential_decay()
    print(f"  fig_exponential_decay.png generated ({len(b64_decay)} chars)")

    b64_vorticity = plot_vorticity_evolution()
    print(f"  fig_vorticity_evolution.png generated ({len(b64_vorticity)} chars)")

    b64_comparison = plot_comparison_principle()
    print(f"  fig_comparison_principle.png generated ({len(b64_comparison)} chars)")

    print("\nAll visualizations generated successfully.")
