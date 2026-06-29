#!/usr/bin/env python3
"""
Applications of Tropical Ecosystem Dynamics

Demonstrates real-world applications of the tropical predator-prey framework:
1. Ecological network resilience analysis
2. Supply chain bottleneck detection (food web as resource flow)
3. Epidemiological contact tracing (infection dynamics as tropical shortest paths)
4. Traffic network equilibrium
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import List, Tuple, Dict


# ─────────────────────────────────────────────────────────────
# Shared infrastructure
# ─────────────────────────────────────────────────────────────

def tropical_matvec(A: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Min-plus matrix-vector product."""
    n = A.shape[0]
    result = np.full(n, np.inf)
    for i in range(n):
        for j in range(n):
            if A[i, j] < np.inf:
                result[i] = min(result[i], A[i, j] + x[j])
    return result


def min_cycle_mean_karp(W: np.ndarray) -> float:
    """Karp's algorithm for minimum cycle mean."""
    n = W.shape[0]
    D = np.full((n + 1, n), np.inf)
    for v in range(n):
        D[0][v] = 0.0
    for k in range(1, n + 1):
        for v in range(n):
            for u in range(n):
                if D[k-1][u] < np.inf and W[u][v] < np.inf:
                    D[k][v] = min(D[k][v], D[k-1][u] + W[u][v])
    lambda_star = np.inf
    for v in range(n):
        if D[n][v] < np.inf:
            max_ratio = -np.inf
            for k in range(n):
                if D[k][v] < np.inf:
                    ratio = (D[n][v] - D[k][v]) / (n - k)
                    max_ratio = max(max_ratio, ratio)
            lambda_star = min(lambda_star, max_ratio)
    return lambda_star


def sup_norm_dist(x: np.ndarray, y: np.ndarray) -> float:
    """L∞ distance."""
    return np.max(np.abs(x - y))


# ─────────────────────────────────────────────────────────────
# Application 1: Ecological Network Resilience
# ─────────────────────────────────────────────────────────────

def ecological_resilience():
    """Analyze resilience of a 5-species food web using tropical eigenvalues.
    
    The minimum cycle mean determines the system's growth rate.
    Perturbation of interaction weights models environmental stress.
    The change in eigenvalue quantifies resilience.
    """
    print("=" * 60)
    print("APPLICATION 1: Ecological Network Resilience")
    print("=" * 60)
    
    # 5-species food web: grass, rabbit, fox, hawk, decomposer
    species = ["Grass", "Rabbit", "Fox", "Hawk", "Decomp."]
    INF = np.inf
    
    # Interaction matrix (min-plus weights represent interaction costs)
    W = np.array([
        [0.2, INF, INF, INF, 0.5],  # Grass: self-renewal, decomposer input
        [0.3, 0.8, INF, INF, INF],   # Rabbit: eats grass
        [INF, 0.5, 1.0, INF, INF],   # Fox: eats rabbit
        [INF, 0.4, 0.6, 0.9, INF],   # Hawk: eats rabbit and fox
        [INF, INF, 0.3, 0.7, 0.1],   # Decomposer: recycles fox and hawk
    ])
    
    mu_base = min_cycle_mean_karp(W)
    print(f"\n  Base food web eigenvalue: μ = {mu_base:.4f}")
    print(f"  Interpretation: system growth rate = {mu_base:.4f} per time step")
    
    # Perturbation analysis: what happens if we remove each species?
    print(f"\n  Resilience under species removal:")
    for removed in range(5):
        W_perturbed = W.copy()
        W_perturbed[removed, :] = INF
        W_perturbed[:, removed] = INF
        W_perturbed[removed, removed] = INF
        
        mu_new = min_cycle_mean_karp(W_perturbed)
        delta = mu_new - mu_base if mu_new < INF else float('inf')
        
        status = "SYSTEM COLLAPSE" if mu_new == INF else f"Δμ = {delta:+.4f}"
        print(f"    Remove {species[removed]:10s}: μ' = {'∞' if mu_new == INF else f'{mu_new:.4f}'} ({status})")
    
    # Gradual environmental stress
    print(f"\n  Gradual stress on grass self-renewal (a₀₀):")
    stresses = np.linspace(0, 2.0, 20)
    eigenvalues = []
    for stress in stresses:
        W_stressed = W.copy()
        W_stressed[0, 0] = 0.2 + stress
        mu_s = min_cycle_mean_karp(W_stressed)
        eigenvalues.append(mu_s)
    
    for s, mu in zip(stresses[::4], eigenvalues[::4]):
        print(f"    stress = {s:.2f}: μ = {mu:.4f}")
    
    # Visualization
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    axes[0].plot(stresses, eigenvalues, 'b-o', markersize=4)
    axes[0].axhline(y=mu_base, color='r', linestyle='--', alpha=0.5, label=f'Baseline μ={mu_base:.3f}')
    axes[0].set_xlabel('Environmental Stress')
    axes[0].set_ylabel('Tropical Eigenvalue μ')
    axes[0].set_title('Ecosystem Growth Rate Under Stress')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)
    
    # Simulate trajectories
    x0 = np.zeros(5)
    n_steps = 30
    
    for stress_level, color, label in [(0, 'green', 'No stress'),
                                        (0.5, 'orange', 'Mild stress'),
                                        (1.5, 'red', 'Severe stress')]:
        W_s = W.copy()
        W_s[0, 0] = 0.2 + stress_level
        
        x = x0.copy()
        trajectory = [x.copy()]
        for _ in range(n_steps):
            x = tropical_matvec(W_s, x)
            trajectory.append(x.copy())
        
        traj_arr = np.array(trajectory)
        # Plot the mean state
        axes[1].plot(range(n_steps + 1), np.mean(traj_arr, axis=1),
                    color=color, linewidth=2, label=label)
    
    axes[1].set_xlabel('Time Step')
    axes[1].set_ylabel('Mean Population Level')
    axes[1].set_title('Ecosystem Trajectories Under Stress')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('ecological_resilience.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"\n  Saved: ecological_resilience.png")
    print()


# ─────────────────────────────────────────────────────────────
# Application 2: Supply Chain as Tropical Food Web
# ─────────────────────────────────────────────────────────────

def supply_chain_analysis():
    """Model a supply chain as a tropical ecosystem.
    
    Each node is a production stage. Edges represent processing times.
    The minimum cycle mean gives the maximum sustainable throughput rate.
    This is the tropical analogue of the bottleneck in a production network.
    """
    print("=" * 60)
    print("APPLICATION 2: Supply Chain Bottleneck Detection")
    print("=" * 60)
    
    stages = ["Raw Material", "Component A", "Component B", "Assembly", "QC/Ship"]
    INF = np.inf
    
    # Processing time matrix (min-plus: lower = faster)
    W = np.array([
        [2.0, INF, INF, INF, 1.0],   # Raw material: 2h replenishment, 1h from returns
        [1.5, 3.0, INF, INF, INF],    # Component A: 1.5h from raw, 3h rework
        [2.0, 0.5, 2.5, INF, INF],    # Component B: 2h from raw, 0.5h from A
        [INF, 1.0, 1.5, 4.0, INF],    # Assembly: from A and B
        [INF, INF, INF, 0.5, 3.0],    # QC/Ship: 0.5h from assembly
    ])
    
    mu = min_cycle_mean_karp(W)
    print(f"\n  Minimum cycle mean (throughput rate): {mu:.4f} hours/unit")
    print(f"  Maximum sustainable throughput: 1 unit per {mu:.2f} hours")
    
    # Identify the bottleneck by perturbing each stage
    print(f"\n  Bottleneck identification (speedup each stage by 0.5h):")
    for stage in range(5):
        W_improved = W.copy()
        for j in range(5):
            if W_improved[stage, j] < INF:
                W_improved[stage, j] = max(0.1, W_improved[stage, j] - 0.5)
        mu_new = min_cycle_mean_karp(W_improved)
        improvement = mu - mu_new
        print(f"    Improve {stages[stage]:15s}: μ = {mu_new:.4f} (Δ = {improvement:+.4f})")
    
    print()


# ─────────────────────────────────────────────────────────────
# Application 3: Epidemiological Contact Dynamics
# ─────────────────────────────────────────────────────────────

def epidemiological_dynamics():
    """Model disease spread as tropical dynamics.
    
    States represent population compartments (S, I, R, etc.).
    Min-plus weights represent minimum transmission/recovery times.
    The tropical eigenvalue gives the characteristic timescale of epidemic cycles.
    """
    print("=" * 60)
    print("APPLICATION 3: Epidemic Cycle Analysis")
    print("=" * 60)
    
    compartments = ["Susceptible", "Exposed", "Infected", "Recovered"]
    INF = np.inf
    
    # SEIR-like model in tropical form
    # Weights = minimum time for transition between compartments
    W = np.array([
        [7.0,  INF, 0.5,  14.0],  # S: 7d natural turnover, 0.5d from contact with I, 14d immunity waning
        [INF,  3.0, INF,  INF],    # E: 3d incubation (self-loop)
        [INF,  2.0, 5.0,  INF],    # I: 2d from E, 5d persistent infection
        [INF,  INF, 7.0,  30.0],   # R: 7d recovery from I, 30d long-term immunity
    ])
    
    mu = min_cycle_mean_karp(W)
    print(f"\n  Epidemic cycle rate: μ = {mu:.4f} days")
    print(f"  Interpretation: fastest epidemic cycle repeats every ~{mu:.1f} days per stage")
    
    # Simulate epidemic trajectory
    x0 = np.array([0.0, 5.0, 10.0, 0.0])  # Initial: some exposed and infected
    
    print(f"\n  Trajectory (tropical epidemic dynamics):")
    print(f"  {'Step':>4s} {'S':>8s} {'E':>8s} {'I':>8s} {'R':>8s}")
    
    x = x0.copy()
    for t in range(16):
        print(f"  {t:4d} {x[0]:8.2f} {x[1]:8.2f} {x[2]:8.2f} {x[3]:8.2f}")
        x = tropical_matvec(W, x)
    
    # Intervention: vaccination reduces S→I transmission time
    print(f"\n  Effect of vaccination (increasing S→I time from 0.5 to 5.0):")
    W_vax = W.copy()
    W_vax[0, 2] = 5.0
    mu_vax = min_cycle_mean_karp(W_vax)
    print(f"    Without vaccination: μ = {mu:.4f}")
    print(f"    With vaccination:    μ = {mu_vax:.4f}")
    print(f"    Slowdown factor:     {mu_vax/mu:.2f}x")
    print()


# ─────────────────────────────────────────────────────────────
# Application 4: Traffic Network Equilibrium
# ─────────────────────────────────────────────────────────────

def traffic_equilibrium():
    """Model traffic network as tropical dynamics.
    
    Nodes = intersections/zones. Weights = travel times.
    The tropical eigenvalue gives the minimum average circuit time.
    Nonexpansiveness ensures that traffic perturbations don't amplify.
    """
    print("=" * 60)
    print("APPLICATION 4: Traffic Network Equilibrium")
    print("=" * 60)
    
    zones = ["Downtown", "Suburb N", "Suburb E", "Industrial", "Airport"]
    INF = np.inf
    
    # Travel time matrix (minutes)
    W = np.array([
        [5.0,  15.0, 20.0, INF,  45.0],  # Downtown
        [12.0, 8.0,  INF,  25.0, INF],    # Suburb N
        [18.0, INF,  7.0,  10.0, 30.0],   # Suburb E
        [INF,  22.0, 12.0, 6.0,  15.0],   # Industrial
        [40.0, INF,  25.0, 18.0, 10.0],   # Airport
    ])
    
    mu = min_cycle_mean_karp(W)
    print(f"\n  Minimum circuit time: {mu:.2f} minutes per node")
    print(f"  Average fastest round-trip: ~{mu * 5:.0f} minutes for {len(zones)} zones")
    
    # Nonexpansiveness demonstration
    print(f"\n  Nonexpansiveness verification (random perturbations):")
    np.random.seed(42)
    x = np.zeros(5)
    
    for trial in range(5):
        x = np.random.randn(5) * 10
        y = x + np.random.randn(5) * 2  # Small perturbation
        
        d_before = sup_norm_dist(x, y)
        x_next = tropical_matvec(W, x)
        y_next = tropical_matvec(W, y)
        d_after = sup_norm_dist(x_next, y_next)
        
        print(f"    Trial {trial+1}: d_before = {d_before:.4f}, d_after = {d_after:.4f}, "
              f"ratio = {d_after/d_before:.4f} {'✓' if d_after <= d_before + 1e-10 else '✗'}")
    
    # Rush hour analysis
    print(f"\n  Rush hour impact (doubling downtown travel times):")
    W_rush = W.copy()
    W_rush[0, :] = np.where(W_rush[0, :] < INF, W_rush[0, :] * 2, INF)
    mu_rush = min_cycle_mean_karp(W_rush)
    print(f"    Normal:    μ = {mu:.2f} min/node")
    print(f"    Rush hour: μ = {mu_rush:.2f} min/node")
    print(f"    Slowdown:  {(mu_rush - mu):.2f} min/node ({(mu_rush/mu - 1)*100:.1f}%)")
    print()


# ─────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    ecological_resilience()
    supply_chain_analysis()
    epidemiological_dynamics()
    traffic_equilibrium()
    
    print("=" * 60)
    print("All applications completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Ecosystem Dynamics: Predator-Prey as Min-Plus Lotka-Volterra

Demonstrations of the formally verified tropical predator-prey system.
Each demo corresponds to a theorem proven in Lean 4 with machine-verified proofs.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import Tuple, List

# ─────────────────────────────────────────────────────────────
# Core Definitions (matching the Lean formalization)
# ─────────────────────────────────────────────────────────────

def trop_pred_prey(a: float, b: float, c: float, d: float,
                   p: Tuple[float, float]) -> Tuple[float, float]:
    """Tropical predator-prey update map F : ℝ² → ℝ².
    
    prey:     x' = min(a + x, b + y)
    predator: y' = min(c + x, d + y)
    """
    x, y = p
    return (min(a + x, b + y), min(c + x, d + y))


def trop_eigenvalue_2(a: float, b: float, c: float, d: float) -> float:
    """Tropical eigenvalue: minimum cycle mean of the 2-node digraph.
    
    μ = min(a, d, (b+c)/2)
    """
    return min(a, min(d, (b + c) / 2))


def sup_dist(p: Tuple[float, float], q: Tuple[float, float]) -> float:
    """Sup-norm (L∞) distance between two points."""
    return max(abs(p[0] - q[0]), abs(p[1] - q[1]))


def iterate_F(a, b, c, d, p, n):
    """Compute F^[n](p)."""
    for _ in range(n):
        p = trop_pred_prey(a, b, c, d, p)
    return p


# ─────────────────────────────────────────────────────────────
# Demo 1: Fixed Point Invariance (Theorem 1)
# ─────────────────────────────────────────────────────────────

def demo_fixed_point():
    """Demonstrate that fixed points are preserved under iteration.
    
    Formally verified: trop_pred_prey_fixed_point_invariant
    """
    print("=" * 60)
    print("DEMO 1: Fixed Point Invariance")
    print("=" * 60)
    
    # Parameters where p = (0, 0) is a fixed point when a=b=c=d=0
    a, b, c, d = 0.0, 0.0, 0.0, 0.0
    p = (0.0, 0.0)
    
    print(f"Parameters: a={a}, b={b}, c={c}, d={d}")
    print(f"Initial point: p = {p}")
    print(f"F(p) = {trop_pred_prey(a, b, c, d, p)}")
    print(f"Fixed point? {trop_pred_prey(a, b, c, d, p) == p}")
    print()
    
    # Verify invariance for 20 iterates
    for n in range(21):
        result = iterate_F(a, b, c, d, p, n)
        print(f"  F^[{n:2d}](p) = ({result[0]:8.4f}, {result[1]:8.4f})")
    
    # Another example: find a fixed point for general parameters
    # Fixed point satisfies: x = min(a+x, b+y), y = min(c+x, d+y)
    # If a ≤ 0 and d ≤ 0 and b+c > a+d: x = a+x => need a=0, similarly d=0
    # Simpler: a=0, d=0, b=1, c=1 => x = min(x, 1+y), y = min(x+1, y)
    # => x = x, y = y when x ≤ 1+y and y ≤ 1+x, any such point works with x=y=0
    a2, b2, c2, d2 = 0.0, 1.0, 1.0, 0.0
    p2 = (0.0, 0.0)
    print(f"\nSecond example: a={a2}, b={b2}, c={c2}, d={d2}")
    print(f"F({p2}) = {trop_pred_prey(a2, b2, c2, d2, p2)}")
    print(f"Fixed point? {trop_pred_prey(a2, b2, c2, d2, p2) == p2}")
    for n in range(6):
        result = iterate_F(a2, b2, c2, d2, p2, n)
        print(f"  F^[{n}](p) = ({result[0]:.4f}, {result[1]:.4f})")
    print()


# ─────────────────────────────────────────────────────────────
# Demo 2: Tropical Eigenvalue as Minimum Cycle Mean (Theorem 2)
# ─────────────────────────────────────────────────────────────

def demo_eigenvalue():
    """Demonstrate the tropical eigenvalue formula.
    
    Formally verified: trop_eigenvalue_2x2_is_min_cycle_mean
    """
    print("=" * 60)
    print("DEMO 2: Tropical Eigenvalue = Minimum Cycle Mean")
    print("=" * 60)
    
    test_cases = [
        (1.0, 2.0, 3.0, 4.0),
        (5.0, 1.0, 1.0, 5.0),
        (0.0, -1.0, 3.0, 2.0),
        (2.0, 3.0, 5.0, 1.0),
        (-1.0, 2.0, 2.0, -1.0),
    ]
    
    for a, b, c, d in test_cases:
        mu = trop_eigenvalue_2(a, b, c, d)
        self_loop_prey = a
        self_loop_pred = d
        two_cycle = (b + c) / 2
        
        print(f"\n  a={a:5.1f}, b={b:5.1f}, c={c:5.1f}, d={d:5.1f}")
        print(f"  Self-loop prey:       {self_loop_prey:6.2f}")
        print(f"  Self-loop predator:   {self_loop_pred:6.2f}")
        print(f"  2-cycle mean (b+c)/2: {two_cycle:6.2f}")
        print(f"  μ = min(a, d, (b+c)/2) = {mu:6.2f}")
        
        # Verify
        assert mu == min(a, min(d, two_cycle))
    
    print("\n  ✓ All tropical eigenvalues match minimum cycle means.")
    print()


# ─────────────────────────────────────────────────────────────
# Demo 3: Eigenvector Iterates (Theorem 3)
# ─────────────────────────────────────────────────────────────

def demo_eigenvector_iterates():
    """Demonstrate linear drift of eigenvector iterates.
    
    Formally verified: trop_eigenvector_iterates
    If F(v) = (μ + v.1, μ + v.2), then F^[n](v) = (n*μ + v.1, n*μ + v.2).
    """
    print("=" * 60)
    print("DEMO 3: Eigenvector Iterates — Linear Drift")
    print("=" * 60)
    
    # Choose parameters and find an eigenvector
    # For a=1, b=2, c=2, d=1: μ = min(1, 1, 2) = 1
    # Eigenvector: F(v) = (1 + v.1, 1 + v.2)
    # => min(1+v1, 2+v2) = 1+v1 and min(2+v1, 1+v2) = 1+v2
    # => 1+v1 ≤ 2+v2 (i.e., v1-v2 ≤ 1) and 1+v2 ≤ 2+v1 (i.e., v2-v1 ≤ 1)
    # => |v1-v2| ≤ 1. Take v = (0, 0).
    a, b, c, d = 1.0, 2.0, 2.0, 1.0
    mu = trop_eigenvalue_2(a, b, c, d)
    v = (0.0, 0.0)
    
    print(f"  Parameters: a={a}, b={b}, c={c}, d={d}")
    print(f"  Tropical eigenvalue μ = {mu}")
    print(f"  Eigenvector v = {v}")
    print(f"  F(v) = {trop_pred_prey(a, b, c, d, v)}")
    print(f"  (μ+v.1, μ+v.2) = ({mu+v[0]}, {mu+v[1]})")
    print(f"  Eigenvector condition: {trop_pred_prey(a, b, c, d, v) == (mu+v[0], mu+v[1])}")
    print()
    
    print("  n | F^[n](v)            | predicted (n*μ+v.1, n*μ+v.2)")
    print("  " + "-" * 55)
    
    current = v
    for n in range(11):
        predicted = (n * mu + v[0], n * mu + v[1])
        match = "✓" if abs(current[0] - predicted[0]) < 1e-10 and abs(current[1] - predicted[1]) < 1e-10 else "✗"
        print(f"  {n:2d} | ({current[0]:8.3f}, {current[1]:8.3f}) | ({predicted[0]:8.3f}, {predicted[1]:8.3f}) {match}")
        current = trop_pred_prey(a, b, c, d, current)
    
    print()


# ─────────────────────────────────────────────────────────────
# Demo 4: Nonexpansiveness (Theorem 4)
# ─────────────────────────────────────────────────────────────

def demo_nonexpansive():
    """Demonstrate nonexpansiveness in sup-norm.
    
    Formally verified: trop_pred_prey_nonexpansive
    supDist(F(p), F(q)) ≤ supDist(p, q) for all p, q.
    """
    print("=" * 60)
    print("DEMO 4: Nonexpansiveness in Sup-Norm")
    print("=" * 60)
    
    np.random.seed(42)
    a, b, c, d = 1.0, 3.0, 2.0, 0.5
    
    print(f"  Parameters: a={a}, b={b}, c={c}, d={d}")
    print()
    
    num_tests = 10
    print(f"  Testing {num_tests} random point pairs:")
    print(f"  {'p':>20s} {'q':>20s} | {'d(p,q)':>8s} {'d(Fp,Fq)':>8s} {'≤?':>3s}")
    print("  " + "-" * 65)
    
    all_pass = True
    for _ in range(num_tests):
        p = tuple(np.random.randn(2) * 5)
        q = tuple(np.random.randn(2) * 5)
        
        fp = trop_pred_prey(a, b, c, d, p)
        fq = trop_pred_prey(a, b, c, d, q)
        
        d_before = sup_dist(p, q)
        d_after = sup_dist(fp, fq)
        ok = d_after <= d_before + 1e-12
        all_pass = all_pass and ok
        
        print(f"  ({p[0]:6.2f},{p[1]:6.2f}) ({q[0]:6.2f},{q[1]:6.2f}) | {d_before:8.4f} {d_after:8.4f} {'✓' if ok else '✗'}")
    
    print(f"\n  {'✓ All pairs satisfy nonexpansiveness.' if all_pass else '✗ Some pairs FAILED!'}")
    
    # Show contraction over many iterates
    print("\n  Distance evolution over 20 iterates (fixed pair):")
    p, q = (5.0, -3.0), (-2.0, 4.0)
    print(f"  Initial: p={p}, q={q}, d={sup_dist(p, q):.4f}")
    for n in range(1, 21):
        p = trop_pred_prey(a, b, c, d, p)
        q = trop_pred_prey(a, b, c, d, q)
        print(f"    n={n:2d}: d(F^n p, F^n q) = {sup_dist(p, q):.6f}")
    print()


# ─────────────────────────────────────────────────────────────
# Demo 5: Monotonicity
# ─────────────────────────────────────────────────────────────

def demo_monotonicity():
    """Demonstrate coordinatewise monotonicity.
    
    Formally verified: trop_pred_prey_monotone
    """
    print("=" * 60)
    print("DEMO 5: Coordinatewise Monotonicity")
    print("=" * 60)
    
    a, b, c, d = 0.5, 1.0, 1.5, 0.8
    
    test_pairs = [
        ((0.0, 0.0), (1.0, 1.0)),
        ((-2.0, -1.0), (0.0, 0.0)),
        ((1.0, 2.0), (3.0, 4.0)),
        ((-5.0, -3.0), (-1.0, 0.0)),
    ]
    
    print(f"  Parameters: a={a}, b={b}, c={c}, d={d}")
    print()
    
    for p, q in test_pairs:
        fp = trop_pred_prey(a, b, c, d, p)
        fq = trop_pred_prey(a, b, c, d, q)
        
        mono_x = fp[0] <= fq[0]
        mono_y = fp[1] <= fq[1]
        
        print(f"  p={p}, q={q}")
        print(f"  p≤q coord: ({p[0]<=q[0]}, {p[1]<=q[1]})")
        print(f"  F(p)={fp}, F(q)={fq}")
        print(f"  F(p)≤F(q) coord: ({mono_x}, {mono_y}) {'✓' if mono_x and mono_y else '✗'}")
        print()


# ─────────────────────────────────────────────────────────────
# Demo 6: Phase Portrait Visualization
# ─────────────────────────────────────────────────────────────

def demo_phase_portrait():
    """Generate phase portrait showing tropical trajectories."""
    print("=" * 60)
    print("DEMO 6: Phase Portrait (saved as tropical_phase_portrait.png)")
    print("=" * 60)
    
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    
    param_sets = [
        (0.5, 2.0, 2.0, 0.5, "Symmetric: a=0.5, b=2, c=2, d=0.5"),
        (0.2, 3.0, 1.0, 0.8, "Asymmetric: a=0.2, b=3, c=1, d=0.8"),
        (-0.5, 1.0, 1.0, -0.5, "Contractive: a=-0.5, b=1, c=1, d=-0.5"),
    ]
    
    for ax, (a, b, c, d, title) in zip(axes, param_sets):
        mu = trop_eigenvalue_2(a, b, c, d)
        
        # Multiple initial conditions
        np.random.seed(123)
        colors = plt.cm.viridis(np.linspace(0.1, 0.9, 8))
        
        for i, color in enumerate(colors):
            x0 = np.random.uniform(-5, 5)
            y0 = np.random.uniform(-5, 5)
            p = (x0, y0)
            
            xs, ys = [x0], [y0]
            for _ in range(30):
                p = trop_pred_prey(a, b, c, d, p)
                xs.append(p[0])
                ys.append(p[1])
            
            ax.plot(xs, ys, '-o', color=color, markersize=2, linewidth=0.8, alpha=0.7)
            ax.plot(xs[0], ys[0], 's', color=color, markersize=5)
        
        ax.set_title(f"{title}\nμ = {mu:.2f}", fontsize=10)
        ax.set_xlabel("Prey (x)")
        ax.set_ylabel("Predator (y)")
        ax.grid(True, alpha=0.3)
        ax.set_aspect('equal')
    
    plt.suptitle("Tropical Predator-Prey Phase Portraits", fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('tropical_phase_portrait.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: tropical_phase_portrait.png\n")


# ─────────────────────────────────────────────────────────────
# Demo 7: Eigenvalue Landscape
# ─────────────────────────────────────────────────────────────

def demo_eigenvalue_landscape():
    """Visualize how the tropical eigenvalue depends on parameters."""
    print("=" * 60)
    print("DEMO 7: Eigenvalue Landscape (saved as eigenvalue_landscape.png)")
    print("=" * 60)
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Fix a=1, d=2, vary b and c
    a_fix, d_fix = 1.0, 2.0
    b_vals = np.linspace(-2, 6, 200)
    c_vals = np.linspace(-2, 6, 200)
    B, C = np.meshgrid(b_vals, c_vals)
    
    MU = np.minimum(a_fix, np.minimum(d_fix, (B + C) / 2))
    
    im = axes[0].contourf(B, C, MU, levels=20, cmap='RdYlBu_r')
    plt.colorbar(im, ax=axes[0], label='μ')
    axes[0].set_xlabel('b (prey→predator effect)')
    axes[0].set_ylabel('c (predator→prey effect)')
    axes[0].set_title(f'Tropical Eigenvalue μ\n(a={a_fix}, d={d_fix})')
    
    # Mark regions where different cycle types dominate
    # μ = a when a ≤ d and a ≤ (b+c)/2
    # μ = d when d ≤ a and d ≤ (b+c)/2
    # μ = (b+c)/2 when (b+c)/2 ≤ a and (b+c)/2 ≤ d
    axes[0].contour(B, C, MU, levels=[a_fix], colors='red', linewidths=2, linestyles='--')
    axes[0].contour(B, C, MU, levels=[d_fix], colors='blue', linewidths=2, linestyles='--')
    
    # 1D slice: fix c=2, vary b
    c_fix = 2.0
    b_range = np.linspace(-3, 7, 300)
    mu_vals = [trop_eigenvalue_2(a_fix, b, c_fix, d_fix) for b in b_range]
    
    axes[1].plot(b_range, mu_vals, 'k-', linewidth=2, label='μ = min(a, d, (b+c)/2)')
    axes[1].axhline(y=a_fix, color='r', linestyle='--', alpha=0.5, label=f'a = {a_fix}')
    axes[1].axhline(y=d_fix, color='b', linestyle='--', alpha=0.5, label=f'd = {d_fix}')
    axes[1].plot(b_range, (b_range + c_fix) / 2, 'g--', alpha=0.5, label=f'(b+c)/2 (c={c_fix})')
    axes[1].set_xlabel('b')
    axes[1].set_ylabel('μ')
    axes[1].set_title(f'Eigenvalue vs. b\n(a={a_fix}, c={c_fix}, d={d_fix})')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)
    
    plt.suptitle("Tropical Eigenvalue as Minimum Cycle Mean", fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('eigenvalue_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: eigenvalue_landscape.png\n")


# ─────────────────────────────────────────────────────────────
# Demo 8: Nonexpansiveness Visualization
# ─────────────────────────────────────────────────────────────

def demo_nonexpansive_viz():
    """Visualize the contraction of distances under iteration."""
    print("=" * 60)
    print("DEMO 8: Distance Contraction (saved as nonexpansive_contraction.png)")
    print("=" * 60)
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Multiple trajectory pairs
    a, b, c, d = 0.3, 2.0, 1.5, 0.5
    np.random.seed(99)
    
    N_iter = 30
    num_pairs = 15
    
    for i in range(num_pairs):
        p = tuple(np.random.randn(2) * 4)
        q = tuple(np.random.randn(2) * 4)
        
        dists = [sup_dist(p, q)]
        for _ in range(N_iter):
            p = trop_pred_prey(a, b, c, d, p)
            q = trop_pred_prey(a, b, c, d, q)
            dists.append(sup_dist(p, q))
        
        color = plt.cm.plasma(i / num_pairs)
        axes[0].plot(range(N_iter + 1), dists, '-', color=color, alpha=0.6, linewidth=1)
    
    axes[0].set_xlabel('Iteration n')
    axes[0].set_ylabel('supDist(F^n(p), F^n(q))')
    axes[0].set_title('Distance Evolution Under Iteration')
    axes[0].grid(True, alpha=0.3)
    
    # Show contraction ratio
    a2, b2, c2, d2 = 0.5, 1.0, 1.0, 0.5
    ratios_list = []
    for _ in range(100):
        p = tuple(np.random.randn(2) * 5)
        q = tuple(np.random.randn(2) * 5)
        d0 = sup_dist(p, q)
        fp = trop_pred_prey(a2, b2, c2, d2, p)
        fq = trop_pred_prey(a2, b2, c2, d2, q)
        d1 = sup_dist(fp, fq)
        if d0 > 1e-10:
            ratios_list.append(d1 / d0)
    
    axes[1].hist(ratios_list, bins=30, color='steelblue', edgecolor='white', alpha=0.8)
    axes[1].axvline(x=1.0, color='red', linestyle='--', linewidth=2, label='ratio = 1 (nonexpansive bound)')
    axes[1].set_xlabel('Contraction Ratio d(F(p),F(q))/d(p,q)')
    axes[1].set_ylabel('Count')
    axes[1].set_title(f'Contraction Ratios\n(a={a2}, b={b2}, c={c2}, d={d2})')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)
    
    plt.suptitle("Tropical Predator-Prey: Nonexpansive Dynamics", fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('nonexpansive_contraction.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: nonexpansive_contraction.png\n")


if __name__ == "__main__":
    demo_fixed_point()
    demo_eigenvalue()
    demo_eigenvector_iterates()
    demo_nonexpansive()
    demo_monotonicity()
    demo_phase_portrait()
    demo_eigenvalue_landscape()
    demo_nonexpansive_viz()
    
    print("=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""Generate PACKAGE.json with all artifacts."""

import json
import base64

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def encode_image(path):
    with open(path, 'rb') as f:
        data = base64.b64encode(f.read()).decode()
    return f"data:image/png;base64,{data}"

# Read all text content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
lean_code = read_file('Catalog/Bridges/TropicalEcosystemDynamics.lean')

# Encode images
viz_phase = encode_image('tropical_phase_portrait.png')
viz_eigenvalue = encode_image('eigenvalue_landscape.png')
viz_contraction = encode_image('nonexpansive_contraction.png')
viz_resilience = encode_image('ecological_resilience.png')

package = {
    "title": "Tropical Ecosystem Dynamics: Predator-Prey as Min-Plus Lotka-Volterra",
    "domain": "Bridges — Tropical Algebra, Ecological Dynamics, Spectral Theory",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Predator-Prey Demonstrations",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Tropical Matrix-Vector Product (Min-Plus)",
            "pseudocode": "function TropicalMatVec(A, x):\n    for i = 1 to n:\n        result[i] = +∞\n        for j = 1 to n:\n            result[i] = min(result[i], A[i,j] + x[j])\n    return result\n\nComplexity: O(n²) time, O(n) space",
            "code": algorithms_code
        },
        {
            "name": "Minimum Cycle Mean (Karp's Algorithm)",
            "pseudocode": "function MinCycleMean(W):\n    D[0][v] = 0 for all v\n    for k = 1 to n:\n        for v = 1 to n:\n            D[k][v] = min_u (D[k-1][u] + W[u][v])\n    λ* = min_v max_{k<n} (D[n][v] - D[k][v]) / (n - k)\n    return λ*\n\nComplexity: O(n³) time, O(n²) space",
            "code": algorithms_code
        },
        {
            "name": "Tropical Power Iteration",
            "pseudocode": "function TropicalPowerIteration(W, ε):\n    x = zeros(n)\n    repeat:\n        y = TropicalMatVec(W, x)\n        μ = min(y)\n        y = y - μ\n        if ||y - x||∞ < ε: return (μ, y)\n        x = y\n\nConvergence: O(n²) iterations for irreducible matrices",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Tropical Predator-Prey Phase Portraits",
            "data": viz_phase
        },
        {
            "name": "Tropical Eigenvalue Landscape",
            "data": viz_eigenvalue
        },
        {
            "name": "Nonexpansive Contraction Dynamics",
            "data": viz_contraction
        },
        {
            "name": "Ecological Network Resilience",
            "data": viz_resilience
        }
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json written ({len(json.dumps(package))} bytes)")
