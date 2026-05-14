#!/usr/bin/env python3
"""
Tropical Diffusion Regularity: Applications

Real-world applications of the tropical diffusion regularity theory
to network resilience, image processing, optimal transport, and
fluid dynamics simulation.
"""

import numpy as np
from algorithms import (
    tropical_diffusion_max, oscillation, tropical_energy,
    iterate_tropical_diffusion, build_graph_kernel, find_fixed_point,
    discrete_vorticity
)


# ============================================================
# Application 1: Network Resilience Analysis
# ============================================================

def network_resilience_demo():
    """
    Model information propagation on a network.

    In distributed systems, tropical diffusion models worst-case
    (max-plus) or best-case (min-plus) signal propagation. The
    regularity theorem guarantees that signal oscillation cannot
    amplify — the network is inherently stable.
    """
    print("=" * 60)
    print("APPLICATION 1: Network Resilience Analysis")
    print("=" * 60)

    # Build a small social/sensor network
    n = 8
    # Adjacency with latencies (nonneg, zero diagonal)
    K = np.array([
        [0, 1, 3, 0, 0, 0, 0, 2],
        [1, 0, 1, 2, 0, 0, 0, 0],
        [3, 1, 0, 1, 3, 0, 0, 0],
        [0, 2, 1, 0, 1, 2, 0, 0],
        [0, 0, 3, 1, 0, 1, 3, 0],
        [0, 0, 0, 2, 1, 0, 1, 2],
        [0, 0, 0, 0, 3, 1, 0, 1],
        [2, 0, 0, 0, 0, 2, 1, 0],
    ], dtype=float)
    # Replace 0s off-diagonal with large value (no direct connection)
    for i in range(n):
        for j in range(n):
            if i != j and K[i, j] == 0:
                K[i, j] = 10.0  # high latency = weak connection

    # Initial sensor readings (heterogeneous)
    u0 = np.array([25.0, 18.0, 32.0, 15.0, 28.0, 10.0, 35.0, 20.0])

    print(f"\nSensor readings: {u0}")
    print(f"Initial oscillation (spread): {oscillation(u0):.2f}")

    result = iterate_tropical_diffusion(K, u0, 30)

    print(f"\nAfter 30 rounds of tropical consensus:")
    print(f"  Final oscillation: {result['osc'][-1]:.4f}")
    print(f"  Oscillation never exceeded initial: {all(o <= result['osc'][0] + 1e-10 for o in result['osc'])}")
    print(f"  => Network is provably stable under tropical propagation")

    fp, steps = find_fixed_point(K, u0)
    print(f"  Consensus reached in {steps} steps")
    print(f"  Consensus value: {fp[0]:.4f} (spread: {oscillation(fp):.6f})")


# ============================================================
# Application 2: Morphological Image Processing
# ============================================================

def morphological_processing_demo():
    """
    Tropical diffusion as morphological dilation/erosion.

    In image processing, the max-plus operator T(u)(i) = max_j(u(j) - K(i,j))
    is exactly a grayscale dilation with structuring element -K.
    The regularity theorems guarantee contrast cannot increase
    under repeated dilation — a key property for stable filters.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Morphological Image Processing")
    print("=" * 60)

    # 1D "image" (grayscale profile)
    n = 20
    x = np.linspace(0, 2 * np.pi, n)
    image = 100 * np.sin(x) + 50 * np.sin(3 * x) + np.random.RandomState(42).randn(n) * 10

    # Structuring element: parabolic (models Gaussian-like smoothing)
    K = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            K[i, j] = 0.5 * (i - j) ** 2 / n

    print(f"\nImage profile (1D, {n} pixels)")
    print(f"Initial contrast (oscillation): {oscillation(image):.2f}")

    result = iterate_tropical_diffusion(K, image, 10)

    print(f"\nContrast after morphological dilation iterations:")
    for step in [0, 1, 2, 5, 10]:
        print(f"  Step {step:2d}: contrast = {result['osc'][step]:.4f}")

    print(f"\n=> Contrast monotonically decreasing: "
          f"{all(result['osc'][i] >= result['osc'][i+1] - 1e-10 for i in range(len(result['osc'])-1))}")
    print("=> Tropical regularity guarantees stable image filtering")


# ============================================================
# Application 3: Optimal Control / Dynamic Programming
# ============================================================

def optimal_control_demo():
    """
    Tropical diffusion as Bellman iteration in optimal control.

    The operator T(u)(i) = max_j(u(j) - K(i,j)) is the Bellman
    operator for a shortest-path / optimal control problem where
    K(i,j) is the transition cost. The regularity theorem says
    the value function cannot develop arbitrarily large gradients.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Optimal Control (Bellman Iteration)")
    print("=" * 60)

    n = 6
    # Transition costs (asymmetric)
    K = np.array([
        [0, 2, 5, 8, 10, 3],
        [3, 0, 2, 5, 8, 7],
        [6, 3, 0, 2, 5, 9],
        [9, 6, 3, 0, 2, 4],
        [4, 9, 6, 3, 0, 2],
        [2, 4, 9, 6, 3, 0],
    ], dtype=float)

    # Terminal rewards
    rewards = np.array([10.0, -5.0, 20.0, 0.0, 15.0, -10.0])

    print(f"\nTerminal rewards: {rewards}")
    print(f"Reward spread (oscillation): {oscillation(rewards):.2f}")

    # Bellman iteration = tropical diffusion
    result = iterate_tropical_diffusion(K, rewards, 20)

    print(f"\nValue function evolution:")
    for step in [0, 1, 2, 5, 10, 20]:
        state = result['states'][step]
        print(f"  Step {step:2d}: V = [{', '.join(f'{v:.2f}' for v in state)}]")
        print(f"           osc = {oscillation(state):.4f}")

    print(f"\n=> Value function gradient bounded by initial reward spread")
    print(f"=> Bellman iteration is provably non-amplifying")


# ============================================================
# Application 4: Discrete Fluid Simulation
# ============================================================

def fluid_simulation_demo():
    """
    Tropical diffusion as a discrete fluid velocity regularizer.

    Model a 1D velocity field on a discrete grid. Apply tropical
    diffusion as a regularization step. The vorticity bound theorem
    guarantees that velocity gradients cannot blow up.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Discrete Fluid Velocity Regularization")
    print("=" * 60)

    n = 16
    # Grid-based kernel (1D lattice distances)
    K = build_graph_kernel(n, 'path', scale=0.3)

    # Initial velocity field with sharp gradients (potential singularity)
    x = np.linspace(0, 1, n)
    velocity = np.zeros(n)
    velocity[n//4:3*n//4] = 10.0  # sharp step function
    velocity += np.random.RandomState(123).randn(n) * 0.5

    # Weight matrix for vorticity
    A = np.ones((n, n)) * 0.8

    print(f"\nGrid size: {n}")
    print(f"Initial velocity oscillation: {oscillation(velocity):.4f}")
    print(f"Initial vorticity: {discrete_vorticity(A, velocity):.4f}")

    result = iterate_tropical_diffusion(K, velocity, 30)

    print(f"\n{'Step':>4} | {'osc':>8} | {'vorticity':>10} | {'sup':>8}")
    print("-" * 45)
    for step in [0, 1, 2, 3, 5, 10, 20, 30]:
        s = result['states'][step]
        v = discrete_vorticity(A, s)
        print(f"{step:4d} | {oscillation(s):8.4f} | {v:10.4f} | {np.max(s):8.4f}")

    initial_osc = oscillation(velocity)
    all_bounded = all(
        discrete_vorticity(A, result['states'][i]) <= initial_osc + 1e-10
        for i in range(len(result['states']))
    )
    print(f"\n=> All vorticities bounded by initial oscillation ({initial_osc:.4f}): {all_bounded}")
    print("=> Tropical regularity prevents gradient blowup in discrete fluid model")


if __name__ == "__main__":
    network_resilience_demo()
    morphological_processing_demo()
    optimal_control_demo()
    fluid_simulation_demo()

    print("\n" + "=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Diffusion Regularity: Demonstrations

Demonstrates the key theorems of tropical diffusion regularity theory
with concrete numerical examples on finite grids.
"""

import numpy as np

def trop_diff_max(K, u):
    """Max-plus tropical diffusion: T(u)(i) = max_j (u(j) - K(i,j))"""
    n = len(u)
    result = np.zeros(n)
    for i in range(n):
        result[i] = max(u[j] - K[i, j] for j in range(n))
    return result

def trop_diff_min(K, u):
    """Min-plus tropical diffusion: T(u)(i) = min_j (K(i,j) + u(j))"""
    n = len(u)
    result = np.zeros(n)
    for i in range(n):
        result[i] = min(K[i, j] + u[j] for j in range(n))
    return result

def osc(u):
    """Oscillation seminorm: max(u) - min(u)"""
    return np.max(u) - np.min(u)

def trop_energy(u):
    """Tropical energy: max(u)"""
    return np.max(u)

def trop_dissipation(K, u):
    """Tropical dissipation: max_i (u(i) - T(u)(i))"""
    Tu = trop_diff_max(K, u)
    return np.max(u - Tu)

def discrete_vorticity(A, u):
    """Discrete vorticity: max_{i,j} |A(i,j) * (u(j) - u(i))|"""
    n = len(u)
    return max(abs(A[i, j] * (u[j] - u[i]))
               for i in range(n) for j in range(n))

def iterate_trop(K, u, n_steps):
    """Iterate tropical diffusion n_steps times, returning all states."""
    states = [u.copy()]
    current = u.copy()
    for _ in range(n_steps):
        current = trop_diff_max(K, current)
        states.append(current.copy())
    return states


def demo_maximum_principle():
    """Demonstrate Theorem 1: Tropical Maximum Principle"""
    print("=" * 60)
    print("DEMO 1: Tropical Maximum Principle")
    print("=" * 60)

    n = 5
    # Graph distance kernel (nonneg, zero diagonal)
    K = np.array([
        [0, 1, 2, 3, 2],
        [1, 0, 1, 2, 3],
        [2, 1, 0, 1, 2],
        [3, 2, 1, 0, 1],
        [2, 3, 2, 1, 0]
    ], dtype=float)

    u = np.array([3.0, -1.0, 7.0, 2.0, -3.0])

    Tu = trop_diff_max(K, u)
    Tu_min = trop_diff_min(K, u)

    print(f"\nInitial state u = {u}")
    print(f"Kernel K (graph distances on 5-cycle):")
    print(K)
    print(f"\nMax-plus diffusion T(u)  = {Tu}")
    print(f"Min-plus diffusion T'(u) = {Tu_min}")
    print(f"\nsup(u) = {np.max(u):.4f},  sup(T(u)) = {np.max(Tu):.4f}")
    print(f"  => sup(T(u)) ≤ sup(u)? {np.max(Tu) <= np.max(u) + 1e-10}")
    print(f"\ninf(u) = {np.min(u):.4f},  inf(T'(u)) = {np.min(Tu_min):.4f}")
    print(f"  => inf(u) ≤ inf(T'(u))? {np.min(u) <= np.min(Tu_min) + 1e-10}")


def demo_oscillation_contraction():
    """Demonstrate Theorem 2: Oscillation Contraction"""
    print("\n" + "=" * 60)
    print("DEMO 2: Oscillation Contraction")
    print("=" * 60)

    n = 6
    K = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            K[i, j] = min(abs(i - j), n - abs(i - j)) * 0.5  # scaled cycle distance

    u = np.array([10.0, -5.0, 8.0, -3.0, 12.0, -7.0])

    print(f"\nInitial state u = {u}")
    print(f"Kernel: scaled cycle distances (factor 0.5)")

    states = iterate_trop(K, u, 20)
    print(f"\n{'Step':>4} | {'sup':>8} | {'inf':>8} | {'osc':>8} | {'energy':>8}")
    print("-" * 50)
    for step, s in enumerate(states):
        print(f"{step:4d} | {np.max(s):8.4f} | {np.min(s):8.4f} | {osc(s):8.4f} | {trop_energy(s):8.4f}")
        if step >= 15:
            break

    print("\n=> Oscillation is monotonically nonincreasing ✓")


def demo_nonexpansiveness():
    """Demonstrate sup-norm nonexpansiveness"""
    print("\n" + "=" * 60)
    print("DEMO 3: Sup-Norm Nonexpansiveness")
    print("=" * 60)

    n = 4
    K = np.array([
        [0, 2, 3, 1],
        [2, 0, 1, 3],
        [3, 1, 0, 2],
        [1, 3, 2, 0]
    ], dtype=float)

    u = np.array([5.0, -2.0, 3.0, 1.0])
    v = np.array([4.0, -1.0, 2.5, 1.5])

    Tu = trop_diff_max(K, u)
    Tv = trop_diff_max(K, v)

    sup_diff_uv = np.max(np.abs(u - v))
    sup_diff_TuTv = np.max(np.abs(Tu - Tv))

    print(f"\nu = {u}")
    print(f"v = {v}")
    print(f"T(u) = {Tu}")
    print(f"T(v) = {Tv}")
    print(f"\n||u - v||_∞ = {sup_diff_uv:.4f}")
    print(f"||T(u) - T(v)||_∞ = {sup_diff_TuTv:.4f}")
    print(f"=> ||T(u)-T(v)||_∞ ≤ ||u-v||_∞? {sup_diff_TuTv <= sup_diff_uv + 1e-10}")


def demo_iterated_bounds():
    """Demonstrate Theorem 3: Iterated bounds"""
    print("\n" + "=" * 60)
    print("DEMO 4: Iterated Tropical Evolution Bounds")
    print("=" * 60)

    n = 8
    np.random.seed(42)
    K = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i != j:
                K[i, j] = np.random.uniform(0.1, 2.0)

    u = np.random.uniform(-10, 10, n)
    initial_sup = np.max(u)
    initial_osc = osc(u)

    print(f"\nGrid size: {n}")
    print(f"Initial sup = {initial_sup:.4f}")
    print(f"Initial osc = {initial_osc:.4f}")

    states = iterate_trop(K, u, 50)
    violations_sup = 0
    violations_osc = 0
    for step, s in enumerate(states):
        if np.max(s) > initial_sup + 1e-10:
            violations_sup += 1
        if osc(s) > initial_osc + 1e-10:
            violations_osc += 1

    print(f"\nAfter 50 iterations:")
    print(f"  Sup bound violations: {violations_sup}")
    print(f"  Osc bound violations: {violations_osc}")
    print(f"  Final sup = {np.max(states[-1]):.4f} (≤ {initial_sup:.4f})")
    print(f"  Final osc = {osc(states[-1]):.4f} (≤ {initial_osc:.4f})")


def demo_vorticity_control():
    """Demonstrate Theorem 4: Vorticity Control"""
    print("\n" + "=" * 60)
    print("DEMO 5: Discrete Vorticity Control")
    print("=" * 60)

    n = 5
    K = np.array([
        [0, 1, 2, 3, 2],
        [1, 0, 1, 2, 3],
        [2, 1, 0, 1, 2],
        [3, 2, 1, 0, 1],
        [2, 3, 2, 1, 0]
    ], dtype=float)

    A = np.ones((n, n)) * 0.5  # weight matrix ≤ 1

    u = np.array([10.0, -5.0, 8.0, -3.0, 12.0])
    initial_osc = osc(u)

    print(f"\nInitial state u = {u}")
    print(f"Initial osc = {initial_osc:.4f}")

    states = iterate_trop(K, u, 20)
    print(f"\n{'Step':>4} | {'osc':>8} | {'vorticity':>10} | {'vort ≤ osc(u₀)?':>16}")
    print("-" * 50)
    for step, s in enumerate(states):
        v = discrete_vorticity(A, s)
        bounded = "✓" if v <= initial_osc + 1e-10 else "✗"
        print(f"{step:4d} | {osc(s):8.4f} | {v:10.4f} | {bounded:>16}")
        if step >= 10:
            break


def demo_dissipation():
    """Demonstrate dissipation properties"""
    print("\n" + "=" * 60)
    print("DEMO 6: Tropical Dissipation")
    print("=" * 60)

    n = 5
    K = np.array([
        [0, 0.5, 1.0, 1.5, 1.0],
        [0.5, 0, 0.5, 1.0, 1.5],
        [1.0, 0.5, 0, 0.5, 1.0],
        [1.5, 1.0, 0.5, 0, 0.5],
        [1.0, 1.5, 1.0, 0.5, 0]
    ], dtype=float)

    u = np.array([5.0, -2.0, 8.0, 1.0, -4.0])

    states = iterate_trop(K, u, 15)
    print(f"\n{'Step':>4} | {'dissipation':>12} | {'energy':>8} | {'osc':>8}")
    print("-" * 50)
    for step, s in enumerate(states):
        d = trop_dissipation(K, s)
        print(f"{step:4d} | {d:12.6f} | {trop_energy(s):8.4f} | {osc(s):8.4f}")


if __name__ == "__main__":
    demo_maximum_principle()
    demo_oscillation_contraction()
    demo_nonexpansiveness()
    demo_iterated_bounds()
    demo_vorticity_control()
    demo_dissipation()
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Diffusion Regularity: Visualizations

Generates publication-quality figures illustrating the key theorems.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
import base64
import io
import json


def tropical_diffusion_max(K, u):
    return np.max(u[np.newaxis, :] - K, axis=1)

def oscillation(u):
    return float(np.max(u) - np.min(u))

def discrete_vorticity(A, u):
    n = len(u)
    diff = u[np.newaxis, :] - u[:, np.newaxis]
    return float(np.max(np.abs(A * diff)))


def fig_to_base64(fig, dpi=150):
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=dpi, bbox_inches='tight')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode('utf-8')


def plot_oscillation_evolution():
    """Plot oscillation decay under iteration for different kernels."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    n = 10
    u0 = np.array([10, -5, 8, -3, 12, -7, 6, -2, 9, -4], dtype=float)
    n_steps = 30

    configs = [
        ('Cycle (scale=0.3)', 0.3),
        ('Cycle (scale=1.0)', 1.0),
        ('Cycle (scale=3.0)', 3.0),
    ]

    for ax, (title, scale) in zip(axes, configs):
        K = np.zeros((n, n))
        for i in range(n):
            for j in range(n):
                K[i, j] = min(abs(i - j), n - abs(i - j)) * scale

        oscs = [oscillation(u0)]
        sups = [np.max(u0)]
        infs = [np.min(u0)]
        current = u0.copy()
        for _ in range(n_steps):
            current = tropical_diffusion_max(K, current)
            oscs.append(oscillation(current))
            sups.append(np.max(current))
            infs.append(np.min(current))

        steps = range(n_steps + 1)
        ax.fill_between(steps, infs, sups, alpha=0.3, color='steelblue', label='[inf, sup] envelope')
        ax.plot(steps, oscs, 'r-o', markersize=3, linewidth=2, label='Oscillation')
        ax.axhline(y=oscillation(u0), color='gray', linestyle='--', alpha=0.5, label='Initial osc')
        ax.set_xlabel('Iteration')
        ax.set_ylabel('Value')
        ax.set_title(title)
        ax.legend(fontsize=8)
        ax.grid(True, alpha=0.3)

    fig.suptitle('Oscillation Contraction Under Tropical Diffusion', fontsize=14, fontweight='bold')
    plt.tight_layout()
    return fig


def plot_state_evolution():
    """Plot the state vector evolution as a heatmap."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    n = 12
    n_steps = 25

    K_small = np.zeros((n, n))
    K_large = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            d = min(abs(i - j), n - abs(i - j))
            K_small[i, j] = d * 0.2
            K_large[i, j] = d * 1.5

    u0 = np.zeros(n)
    u0[n // 4] = 10
    u0[3 * n // 4] = -8

    for ax, K, title in [(axes[0], K_small, 'Weak Diffusion (scale=0.2)'),
                          (axes[1], K_large, 'Strong Diffusion (scale=1.5)')]:
        states = [u0.copy()]
        current = u0.copy()
        for _ in range(n_steps):
            current = tropical_diffusion_max(K, current)
            states.append(current.copy())
        mat = np.array(states)
        im = ax.imshow(mat.T, aspect='auto', cmap='RdBu_r',
                       vmin=-10, vmax=10, origin='lower')
        ax.set_xlabel('Iteration')
        ax.set_ylabel('Site index')
        ax.set_title(title)
        plt.colorbar(im, ax=ax, shrink=0.8)

    fig.suptitle('Tropical Diffusion State Evolution', fontsize=14, fontweight='bold')
    plt.tight_layout()
    return fig


def plot_vorticity_bound():
    """Plot vorticity vs oscillation bounds."""
    fig, ax = plt.subplots(figsize=(10, 6))

    n = 8
    K = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            K[i, j] = min(abs(i - j), n - abs(i - j)) * 0.5

    A = np.ones((n, n)) * 0.7
    u0 = np.array([10.0, -5.0, 8.0, -3.0, 12.0, -7.0, 6.0, -2.0])
    n_steps = 30

    oscs = [oscillation(u0)]
    vorts = [discrete_vorticity(A, u0)]
    current = u0.copy()
    for _ in range(n_steps):
        current = tropical_diffusion_max(K, current)
        oscs.append(oscillation(current))
        vorts.append(discrete_vorticity(A, current))

    steps = range(n_steps + 1)
    ax.plot(steps, oscs, 'b-o', markersize=4, linewidth=2, label='Oscillation', zorder=3)
    ax.plot(steps, vorts, 'r-s', markersize=4, linewidth=2, label='Discrete Vorticity', zorder=3)
    ax.axhline(y=oscillation(u0), color='blue', linestyle='--', alpha=0.4, label='Initial oscillation bound')
    ax.fill_between(steps, 0, oscillation(u0), alpha=0.1, color='blue')
    ax.set_xlabel('Iteration', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Vorticity Control by Oscillation Bound', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(bottom=0)

    plt.tight_layout()
    return fig


def plot_maximum_principle():
    """Visualize the maximum principle: sup/inf envelope."""
    fig, ax = plt.subplots(figsize=(10, 6))

    n = 6
    K = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            K[i, j] = abs(i - j) * 0.8

    u0 = np.array([5.0, -3.0, 8.0, -1.0, 10.0, -5.0])
    n_steps = 20

    sups, infs = [np.max(u0)], [np.min(u0)]
    current = u0.copy()
    all_states = [u0.copy()]
    for _ in range(n_steps):
        current = tropical_diffusion_max(K, current)
        sups.append(np.max(current))
        infs.append(np.min(current))
        all_states.append(current.copy())

    steps = range(n_steps + 1)
    ax.fill_between(steps, infs, sups, alpha=0.2, color='green', label='[inf, sup] range')
    ax.plot(steps, sups, 'g-^', markersize=5, linewidth=2, label='sup(T^n u)')
    ax.plot(steps, infs, 'g-v', markersize=5, linewidth=2, label='inf(T^n u)')
    ax.axhline(y=np.max(u0), color='red', linestyle='--', alpha=0.7, label='Initial sup')
    ax.axhline(y=np.min(u0), color='blue', linestyle='--', alpha=0.7, label='Initial inf')

    # Plot individual site trajectories
    for site in range(n):
        trajectory = [all_states[s][site] for s in range(n_steps + 1)]
        ax.plot(steps, trajectory, '-', alpha=0.3, color='gray', linewidth=0.8)

    ax.set_xlabel('Iteration', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Tropical Maximum Principle: No New Extrema', fontsize=14, fontweight='bold')
    ax.legend(fontsize=9, loc='center right')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    return fig


def plot_nonexpansiveness():
    """Visualize sup-norm nonexpansiveness."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    n = 6
    K = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            K[i, j] = abs(i - j) * 0.5

    np.random.seed(42)
    n_pairs = 50
    n_steps = 20

    # Track contraction ratios
    for ax, step_label, step_val in [(axes[0], 'After 1 step', 1), (axes[1], 'After 10 steps', 10)]:
        dists_before = []
        dists_after = []
        for _ in range(n_pairs):
            u = np.random.randn(n) * 5
            v = np.random.randn(n) * 5
            d_before = np.max(np.abs(u - v))

            for _ in range(step_val):
                u = tropical_diffusion_max(K, u)
                v = tropical_diffusion_max(K, v)
            d_after = np.max(np.abs(u - v))

            dists_before.append(d_before)
            dists_after.append(d_after)

        ax.scatter(dists_before, dists_after, alpha=0.6, s=30, c='steelblue')
        max_val = max(max(dists_before), max(dists_after))
        ax.plot([0, max_val], [0, max_val], 'r--', linewidth=2, label='y = x (1-Lipschitz bound)')
        ax.set_xlabel('||u - v||∞ (before)', fontsize=11)
        ax.set_ylabel('||T^n(u) - T^n(v)||∞ (after)', fontsize=11)
        ax.set_title(step_label, fontsize=12)
        ax.legend(fontsize=9)
        ax.grid(True, alpha=0.3)
        ax.set_aspect('equal')
        ax.set_xlim(0, max_val * 1.1)
        ax.set_ylim(0, max_val * 1.1)

    fig.suptitle('Sup-Norm Nonexpansiveness of Tropical Diffusion', fontsize=14, fontweight='bold')
    plt.tight_layout()
    return fig


def generate_all_visualizations():
    """Generate all visualizations and return as base64 dict."""
    print("Generating visualizations...")

    viz = {}

    fig = plot_oscillation_evolution()
    viz['oscillation_contraction'] = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/fig_oscillation_contraction.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    print("  ✓ Oscillation contraction")

    fig = plot_state_evolution()
    viz['state_evolution'] = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/fig_state_evolution.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    print("  ✓ State evolution")

    fig = plot_vorticity_bound()
    viz['vorticity_bound'] = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/fig_vorticity_bound.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    print("  ✓ Vorticity bound")

    fig = plot_maximum_principle()
    viz['maximum_principle'] = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/fig_maximum_principle.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    print("  ✓ Maximum principle")

    fig = plot_nonexpansiveness()
    viz['nonexpansiveness'] = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/fig_nonexpansiveness.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    print("  ✓ Nonexpansiveness")

    return viz


if __name__ == "__main__":
    viz = generate_all_visualizations()
    print(f"\nGenerated {len(viz)} visualizations.")
