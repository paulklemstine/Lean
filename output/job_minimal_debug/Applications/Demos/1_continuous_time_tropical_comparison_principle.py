#!/usr/bin/env python3
"""
Applications of the Continuous-Time Tropical Comparison Principle.

Demonstrates real-world applications:
1. Neural network robustness certification for ReLU networks.
2. Network routing with guaranteed convergence.
3. Tropical Lyapunov stability for switched systems.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


# ─── Application 1: Neural Network Robustness ──────────────────────────────

def neural_robustness_certificate():
    """
    Certify robustness of a ReLU neural ODE against input perturbations.
    
    System: dx/dt = max(Wx + b, 0) - x  (tropical neural flow)
    
    If ||W||_∞ ≤ 1 and K_i ≥ max(W_i · K + b_i, 0), then
    max_i(x_i(t) - K_i) ≤ exp(-t) · max_i(x_i(0) - K_i).
    
    This gives certified perturbation bounds: if two inputs differ by δ,
    the outputs converge exponentially.
    """
    print("=" * 60)
    print("Application 1: Neural Network Robustness Certificate")
    print("=" * 60)
    
    np.random.seed(42)
    n = 4
    
    # Weight matrix with ||W||_∞ ≤ 1
    W = np.array([
        [0.3, -0.2, 0.1, 0.0],
        [0.0, 0.4, -0.1, 0.2],
        [-0.1, 0.0, 0.3, 0.1],
        [0.1, -0.1, 0.0, 0.5],
    ])
    b = np.array([0.1, -0.1, 0.2, 0.0])
    
    # Barrier: K chosen so T(x)_i = max(Wx+b, 0)_i ≤ K_i
    # Since ReLU output is non-negative and bounded by ||W||_∞ * ||x||_∞ + |b|,
    # choose K large enough
    K = np.array([2.0, 2.0, 2.0, 2.0])
    
    def T(x):
        return np.maximum(W @ x + b, 0)
    
    dt = 0.001
    t_final = 8.0
    t = np.arange(0, t_final, dt)
    
    # Two nearby initial conditions (adversarial perturbation)
    x0 = np.array([3.0, 2.5, 4.0, 1.5])
    delta = 0.5
    x0_perturbed = x0 + delta * np.array([1, -1, 0.5, -0.5]) / np.sqrt(1.5)
    
    def simulate(x_init):
        traj = np.zeros((len(t), n))
        traj[0] = x_init
        for k in range(len(t) - 1):
            Tx = T(traj[k])
            traj[k+1] = traj[k] + dt * (Tx - traj[k])
        return traj
    
    traj1 = simulate(x0)
    traj2 = simulate(x0_perturbed)
    
    # Compute barrier functional for the difference
    diff = traj1 - traj2
    max_diff = np.max(np.abs(diff), axis=1)
    
    # Theoretical bound
    bound = max_diff[0] * np.exp(-t)
    
    print(f"  Dimension: {n}")
    print(f"  Initial perturbation: ||δx(0)||_∞ = {max_diff[0]:.4f}")
    print(f"  At t=2: ||δx(2)||_∞ = {max_diff[int(2/dt)]:.6f}, bound = {bound[int(2/dt)]:.6f}")
    print(f"  At t=5: ||δx(5)||_∞ = {max_diff[int(5/dt)]:.8f}, bound = {bound[int(5/dt)]:.8f}")
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    ax = axes[0]
    for i in range(n):
        ax.plot(t, traj1[:, i], '-', linewidth=1.5, label=f'$x_{i+1}$ (original)')
        ax.plot(t, traj2[:, i], '--', linewidth=1.5, label=f'$x_{i+1}$ (perturbed)')
    ax.set_xlabel("Time $t$", fontsize=13)
    ax.set_ylabel("State", fontsize=13)
    ax.set_title("Neural ODE Trajectories", fontsize=14)
    ax.legend(fontsize=8, ncol=2)
    ax.grid(True, alpha=0.3)
    
    ax = axes[1]
    ax.semilogy(t, max_diff, 'b-', linewidth=2, label=r'$\|x(t)-x^\prime(t)\|_\infty$')
    ax.semilogy(t, bound, 'r--', linewidth=2, label=r'$e^{-t}\|\delta x(0)\|_\infty$')
    ax.set_xlabel("Time $t$", fontsize=13)
    ax.set_ylabel("Perturbation (log)", fontsize=13)
    ax.set_title("Certified Robustness: Exponential Convergence", fontsize=14)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    
    fig.suptitle("Application: Tropical Neural Network Robustness", fontsize=16, y=1.02)
    fig.tight_layout()
    fig.savefig("neural_robustness.png", dpi=150, bbox_inches='tight')
    plt.close(fig)
    print("  → Saved neural_robustness.png\n")


# ─── Application 2: Network Routing ────────────────────────────────────────

def network_routing_convergence():
    """
    Tropical comparison for distributed routing convergence.
    
    In a network with n nodes, each node maintains a distance estimate d_i
    to a destination. The Bellman update is:
        d_i' = min_{j neighbors} (w_{ij} + d_j) - d_i
    
    In max-plus (tropical) formulation with negated distances:
        x_i' = max_{j} (-w_{ij} + x_j) - x_i = T(x)_i - x_i
    
    The barrier K_i = 0 (optimal distances) gives exponential convergence.
    """
    print("=" * 60)
    print("Application 2: Network Routing Convergence")
    print("=" * 60)
    
    # Simple 5-node network
    n = 5
    # Adjacency with weights (0 = no edge)
    W = np.array([
        [0, 1, 0, 3, 0],
        [1, 0, 2, 0, 0],
        [0, 2, 0, 1, 4],
        [3, 0, 1, 0, 2],
        [0, 0, 4, 2, 0],
    ], dtype=float)
    
    # Tropical operator: T(x)_i = max_{j: w_ij > 0} (x_j - w_ij)
    # Barrier: K = optimal shortest-path distances (negated)
    K = np.array([0, -1, -3, -2, -4], dtype=float)  # True shortest paths from node 0
    
    def T(x):
        result = np.full(n, -np.inf)
        for i in range(n):
            for j in range(n):
                if W[i, j] > 0:
                    result[i] = max(result[i], x[j] - W[i, j])
        return result
    
    dt = 0.005
    t_final = 10.0
    t_arr = np.arange(0, t_final, dt)
    
    # Start with bad initial estimates
    x0 = np.array([0, 5, 10, 8, 15], dtype=float)
    
    traj = np.zeros((len(t_arr), n))
    traj[0] = x0
    
    for k in range(len(t_arr) - 1):
        Tx = T(traj[k])
        traj[k+1] = traj[k] + dt * (Tx - traj[k])
    
    excess = traj - K[np.newaxis, :]
    fmax_vals = np.max(excess, axis=1)
    bound = fmax_vals[0] * np.exp(-t_arr)
    
    print(f"  Optimal distances (negated): K = {K}")
    print(f"  Initial estimates: x(0) = {x0}")
    print(f"  Initial barrier: {fmax_vals[0]:.2f}")
    print(f"  Final barrier: {fmax_vals[-1]:.6f}")
    print(f"  Convergence to optimal: {np.allclose(traj[-1], K, atol=0.1)}")
    
    fig, ax = plt.subplots(figsize=(10, 6))
    for i in range(n):
        ax.plot(t_arr, traj[:, i], linewidth=2, label=f'Node {i+1}')
        ax.axhline(y=K[i], linestyle=':', alpha=0.3)
    ax.set_xlabel("Time $t$", fontsize=13)
    ax.set_ylabel("Distance estimate", fontsize=13)
    ax.set_title("Network Routing: Convergence to Optimal Distances", fontsize=15)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig("routing_convergence.png", dpi=150)
    plt.close(fig)
    print("  → Saved routing_convergence.png\n")


# ─── Application 3: Switched System Stability ──────────────────────────────

def switched_system_stability():
    """
    Tropical Lyapunov function for a switched linear system.
    
    Consider a system that switches between modes:
        Mode 1: x' = A1·x
        Mode 2: x' = A2·x
    
    Neither mode is individually stable, but the tropical barrier
    V(x) = max_i(x_i - K_i) certifies stability under constrained switching.
    """
    print("=" * 60)
    print("Application 3: Switched System Stability (Tropical Lyapunov)")
    print("=" * 60)
    
    n = 2
    K = np.array([0.0, 0.0])
    
    # Two modes: individually may grow, but tropically stable
    def T1(x):
        return np.array([0.3 * x[0] + 0.1 * x[1], 0.2 * x[0] + 0.2 * x[1]])
    
    def T2(x):
        return np.array([0.1 * x[0] + 0.3 * x[1], 0.1 * x[0] + 0.4 * x[1]])
    
    dt = 0.002
    t_final = 10.0
    t_arr = np.arange(0, t_final, dt)
    
    x0 = np.array([3.0, 2.0])
    
    traj = np.zeros((len(t_arr), n))
    traj[0] = x0
    modes = np.zeros(len(t_arr), dtype=int)
    
    for k in range(len(t_arr) - 1):
        # Switch every 0.5 time units
        mode = int(t_arr[k] / 0.5) % 2
        modes[k] = mode
        T = T1 if mode == 0 else T2
        traj[k+1] = traj[k] + dt * (T(traj[k]) - traj[k])
    
    excess = traj - K[np.newaxis, :]
    fmax_vals = np.max(excess, axis=1)
    bound = fmax_vals[0] * np.exp(-t_arr)
    
    print(f"  Initial state: {x0}")
    print(f"  Initial barrier: {fmax_vals[0]:.4f}")
    print(f"  Final barrier: {fmax_vals[-1]:.8f}")
    
    fig, axes = plt.subplots(2, 1, figsize=(12, 8))
    
    ax = axes[0]
    ax.plot(t_arr, traj[:, 0], 'b-', linewidth=2, label='$x_1(t)$')
    ax.plot(t_arr, traj[:, 1], 'r-', linewidth=2, label='$x_2(t)$')
    ax.set_ylabel("State", fontsize=13)
    ax.set_title("Switched System Trajectory", fontsize=14)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    
    ax = axes[1]
    ax.semilogy(t_arr, np.maximum(fmax_vals, 1e-15), 'b-', linewidth=2, 
                label=r'$\max_i(x_i - K_i)$')
    ax.semilogy(t_arr, bound, 'r--', linewidth=2, label=r'$e^{-t}$ bound')
    ax.set_xlabel("Time $t$", fontsize=13)
    ax.set_ylabel("Barrier (log)", fontsize=13)
    ax.set_title("Tropical Lyapunov Decay Under Switching", fontsize=14)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    
    fig.suptitle("Switched System Stability via Tropical Barriers", fontsize=16, y=1.02)
    fig.tight_layout()
    fig.savefig("switched_stability.png", dpi=150, bbox_inches='tight')
    plt.close(fig)
    print("  → Saved switched_stability.png\n")


if __name__ == "__main__":
    print("\n🌴 Tropical Comparison Principle — Applications\n")
    neural_robustness_certificate()
    network_routing_convergence()
    switched_system_stability()
    print("✅ All applications completed!")


#!/usr/bin/env python3
"""
Demonstration of the Continuous-Time Tropical Comparison Principle.

This script provides concrete numerical examples showing that trajectories
governed by tropical differential inequalities exhibit exponential decay
of the barrier functional max_i(ω(t)(i) - K(i)).
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import Callable

# ─── Example 1: Scalar Grönwall Decay ───────────────────────────────────────

def demo_scalar_decay():
    """
    Demonstrate scalar_exp_decay: if φ'(t) ≤ -φ(t), then φ(t) ≤ exp(-t)·φ(0).
    
    We simulate φ'(t) = -φ(t) + noise where noise ≤ 0,
    and verify the bound φ(t) ≤ exp(-t)·φ(0) holds.
    """
    print("=" * 60)
    print("Example 1: Scalar Exponential Decay (Grönwall)")
    print("=" * 60)
    
    dt = 0.001
    T_final = 5.0
    t = np.arange(0, T_final, dt)
    
    # Case 1: exact equality φ' = -φ
    phi0 = 3.0
    phi_exact = phi0 * np.exp(-t)
    
    # Case 2: φ' = -φ + c(t) where c(t) = -0.5*sin²(t) ≤ 0
    phi_perturbed = np.zeros_like(t)
    phi_perturbed[0] = phi0
    for k in range(len(t) - 1):
        c_t = -0.5 * np.sin(t[k])**2  # ≤ 0
        phi_perturbed[k+1] = phi_perturbed[k] + dt * (-phi_perturbed[k] + c_t)
    
    bound = phi0 * np.exp(-t)
    
    print(f"  φ(0) = {phi0}")
    print(f"  At t=1: φ_exact = {phi0*np.exp(-1):.4f}, bound = {bound[int(1/dt)]:.4f}")
    print(f"  At t=3: φ_exact = {phi0*np.exp(-3):.4f}, bound = {bound[int(3/dt)]:.4f}")
    print(f"  At t=5: φ_perturbed = {phi_perturbed[-1]:.6f}, bound = {bound[-1]:.6f}")
    print(f"  Bound holds everywhere: {np.all(phi_perturbed <= bound + 1e-10)}")
    
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.plot(t, phi_exact, 'b-', linewidth=2, label=r"$\varphi'=-\varphi$ (exact)")
    ax.plot(t, phi_perturbed, 'g-', linewidth=2, label=r"$\varphi'=-\varphi + c(t)$, $c\leq 0$")
    ax.plot(t, bound, 'r--', linewidth=2, label=r"Bound: $e^{-t}\cdot\varphi(0)$")
    ax.set_xlabel("Time $t$", fontsize=14)
    ax.set_ylabel(r"$\varphi(t)$", fontsize=14)
    ax.set_title("Scalar Exponential Decay: Grönwall Comparison", fontsize=16)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-0.2, 3.5)
    fig.tight_layout()
    fig.savefig("scalar_decay.png", dpi=150)
    plt.close(fig)
    print("  → Saved scalar_decay.png\n")


# ─── Example 2: Tropical Barrier Decay (3D system) ─────────────────────────

def demo_tropical_barrier():
    """
    Demonstrate tropical_fmax_exponential_decay for a 3-component system.
    
    System: ω'_i(t) = T(ω(t))_i - ω_i(t) + c(t)
    where T(x)_i = min(K_i, some_function(x)) ≤ K_i
    and c(t) ≤ 0.
    """
    print("=" * 60)
    print("Example 2: Tropical Barrier Decay (3-component system)")
    print("=" * 60)
    
    n = 3
    K = np.array([2.0, 1.0, 3.0])  # barrier levels
    
    # T(x)_i = K_i - 0.1 (constant, always ≤ K_i)
    def T(x):
        return K - 0.1
    
    dt = 0.001
    T_final = 5.0
    t = np.arange(0, T_final, dt)
    
    # Initial condition: above the barrier
    omega0 = np.array([5.0, 4.0, 6.0])
    
    omega = np.zeros((len(t), n))
    omega[0] = omega0
    
    for k in range(len(t) - 1):
        c_t = -0.1 * np.exp(-t[k])  # c(t) ≤ 0
        for i in range(n):
            omega[k+1, i] = omega[k, i] + dt * (T(omega[k])[i] - omega[k, i] + c_t)
    
    # Compute barrier functional: max_i (ω(t)(i) - K(i))
    excess = omega - K[np.newaxis, :]
    fmax = np.max(excess, axis=1)
    
    # Theoretical bound: exp(-t) * fmax(0)
    fmax0 = np.max(omega0 - K)
    bound = np.exp(-t) * fmax0
    
    print(f"  K = {K}")
    print(f"  ω(0) = {omega0}")
    print(f"  fmax(0) = max_i(ω(0)(i) - K(i)) = {fmax0}")
    print(f"  At t=1: fmax = {fmax[int(1/dt)]:.4f}, bound = {bound[int(1/dt)]:.4f}")
    print(f"  At t=3: fmax = {fmax[int(3/dt)]:.6f}, bound = {bound[int(3/dt)]:.6f}")
    print(f"  Bound holds everywhere: {np.all(fmax <= bound + 1e-8)}")
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left: individual excess coordinates
    ax = axes[0]
    colors = ['#e74c3c', '#3498db', '#2ecc71']
    for i in range(n):
        ax.plot(t, excess[:, i], color=colors[i], linewidth=2, 
                label=f"$\\omega_{i+1}(t) - K_{i+1}$")
        ax.plot(t, (omega0[i] - K[i]) * np.exp(-t), '--', color=colors[i], 
                alpha=0.5, label=f"$e^{{-t}}(\\omega_{i+1}(0)-K_{i+1})$")
    ax.set_xlabel("Time $t$", fontsize=13)
    ax.set_ylabel("Excess coordinate", fontsize=13)
    ax.set_title("Coordinatewise Decay", fontsize=14)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    
    # Right: barrier functional
    ax = axes[1]
    ax.plot(t, fmax, 'b-', linewidth=2.5, label=r"$\max_i(\omega_i(t) - K_i)$")
    ax.plot(t, bound, 'r--', linewidth=2.5, label=r"$e^{-t} \cdot f_{\max}(0)$")
    ax.fill_between(t, fmax, bound, alpha=0.15, color='green', label="Safety margin")
    ax.set_xlabel("Time $t$", fontsize=13)
    ax.set_ylabel("Barrier functional", fontsize=13)
    ax.set_title("Tropical Barrier Exponential Decay", fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    fig.suptitle("Continuous-Time Tropical Comparison Principle", fontsize=16, y=1.02)
    fig.tight_layout()
    fig.savefig("tropical_barrier_decay.png", dpi=150, bbox_inches='tight')
    plt.close(fig)
    print("  → Saved tropical_barrier_decay.png\n")


# ─── Example 3: Phase Portrait of Tropical Flow ────────────────────────────

def demo_phase_portrait():
    """
    2D phase portrait showing trajectories converging to the barrier set.
    """
    print("=" * 60)
    print("Example 3: Phase Portrait of 2D Tropical Flow")
    print("=" * 60)
    
    K = np.array([1.0, 1.0])
    
    def T(x):
        return np.minimum(x, K)  # T(x)_i = min(x_i, K_i) ≤ K_i
    
    dt = 0.005
    T_final = 4.0
    t = np.arange(0, T_final, dt)
    
    fig, ax = plt.subplots(figsize=(8, 8))
    
    # Multiple initial conditions
    np.random.seed(42)
    starts = [(3, 4), (4, 2), (0, 5), (5, 5), (2, 0.5), (4, 4), (-1, 3), (3, -0.5)]
    
    for omega0 in starts:
        omega = np.zeros((len(t), 2))
        omega[0] = np.array(omega0)
        
        for k in range(len(t) - 1):
            omega[k+1] = omega[k] + dt * (T(omega[k]) - omega[k])
        
        ax.plot(omega[:, 0], omega[:, 1], 'b-', alpha=0.6, linewidth=1.5)
        ax.plot(omega[0, 0], omega[0, 1], 'ro', markersize=8)
        ax.plot(omega[-1, 0], omega[-1, 1], 'g^', markersize=8)
    
    # Draw barrier set {x : max(x_i - K_i) = 0}
    ax.axhline(y=K[1], color='red', linestyle='--', alpha=0.5, label=f'$x_2 = K_2 = {K[1]}$')
    ax.axvline(x=K[0], color='red', linestyle='--', alpha=0.5, label=f'$x_1 = K_1 = {K[0]}$')
    
    ax.set_xlabel("$\\omega_1$", fontsize=14)
    ax.set_ylabel("$\\omega_2$", fontsize=14)
    ax.set_title("Phase Portrait: Tropical Flow Toward Barrier", fontsize=15)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-2, 6)
    ax.set_ylim(-1, 6)
    ax.set_aspect('equal')
    fig.tight_layout()
    fig.savefig("phase_portrait.png", dpi=150)
    plt.close(fig)
    print("  → Saved phase_portrait.png\n")


# ─── Example 4: Convergence Rate Comparison ────────────────────────────────

def demo_convergence_rates():
    """
    Compare the decay rate for different dimensions and operators.
    """
    print("=" * 60)
    print("Example 4: Decay Rate vs Dimension")
    print("=" * 60)
    
    dt = 0.001
    T_final = 5.0
    t = np.arange(0, T_final, dt)
    
    fig, ax = plt.subplots(figsize=(10, 6))
    
    for n in [2, 5, 10, 50]:
        K = np.ones(n)
        omega0 = np.ones(n) * 3.0  # All start at 3
        omega0[0] = 5.0  # One coordinate is higher
        
        def T(x, K=K):
            return np.minimum(x, K)
        
        omega = np.zeros((len(t), n))
        omega[0] = omega0
        
        for k in range(len(t) - 1):
            omega[k+1] = omega[k] + dt * (T(omega[k]) - omega[k])
        
        excess = omega - K[np.newaxis, :]
        fmax_vals = np.max(excess, axis=1)
        
        ax.semilogy(t, np.maximum(fmax_vals, 1e-15), linewidth=2, label=f"dim = {n}")
    
    ax.semilogy(t, (5.0 - 1.0) * np.exp(-t), 'k--', linewidth=2, 
                label=r"Bound: $4 e^{-t}$")
    
    ax.set_xlabel("Time $t$", fontsize=14)
    ax.set_ylabel(r"$f_{\max}(\omega(t))$  (log scale)", fontsize=14)
    ax.set_title("Barrier Decay is Dimension-Independent", fontsize=16)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig("convergence_rates.png", dpi=150)
    plt.close(fig)
    
    print("  Key insight: decay rate exp(-t) is independent of dimension!")
    print("  → Saved convergence_rates.png\n")


if __name__ == "__main__":
    print("\n🌴 Continuous-Time Tropical Comparison Principle — Demos\n")
    demo_scalar_decay()
    demo_tropical_barrier()
    demo_phase_portrait()
    demo_convergence_rates()
    print("✅ All demos completed successfully!")
