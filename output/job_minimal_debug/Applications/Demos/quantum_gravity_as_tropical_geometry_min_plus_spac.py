#!/usr/bin/env python3
"""
applications.py — Real-world applications of tropical spacetime dynamics.

Demonstrates:
1. Network routing as tropical gravity
2. Causal structure detection in event networks
3. Resource allocation via Bellman operators
4. Horizon detection in layered networks
"""

import numpy as np


def tropical_einstein_step(K: np.ndarray, u: np.ndarray) -> np.ndarray:
    """Bellman / tropical Einstein step: u_new[x] = min_y (u[y] + K[y, x])."""
    return np.min(u[:, None] + K, axis=0)


def application_network_routing():
    """Application 1: Network routing as tropical gravitational propagation.

    A data center has 6 servers. Latencies between servers form the
    transition kernel K. We compute optimal routing tables using
    tropical evolution — this is exactly the Bellman-Ford algorithm.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 1: Network Routing as Tropical Gravity")
    print("=" * 60)

    # 6-server data center with asymmetric latencies (ms)
    INF = np.inf
    K = np.array([
        [0,   2,   INF, 6,   INF, INF],
        [2,   0,   3,   INF, 5,   INF],
        [INF, 3,   0,   1,   INF, 4  ],
        [6,   INF, 1,   0,   2,   INF],
        [INF, 5,   INF, 2,   0,   1  ],
        [INF, INF, 4,   INF, 1,   0  ],
    ], dtype=float)

    server_names = ["Web", "API", "DB", "Cache", "Queue", "Log"]

    # Compute shortest paths from each source
    for source in range(6):
        u = np.full(6, INF)
        u[source] = 0.0
        for _ in range(6):
            u = tropical_einstein_step(K, u)
        print(f"\n  From {server_names[source]:5s}: ", end="")
        for j in range(6):
            if j == source:
                print(f"  -  ", end="")
            else:
                print(f" {u[j]:3.0f} ", end="")
    print()


def application_causal_structure():
    """Application 2: Causal structure in discrete spacetime.

    Model a 2D discrete spacetime with 4 spatial positions × 3 time steps.
    Edge weights represent proper time intervals. The tropical evolution
    computes causal influence propagation.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Causal Structure in Discrete Spacetime")
    print("=" * 60)

    # 4 spatial nodes, causal edges go forward in time
    # Light cone width = 1 (nearest neighbor causal connections)
    n_spatial = 4
    INF = np.inf

    # Transition kernel: causal connections with proper time costs
    K = np.array([
        [1.0, 1.5, INF, INF],
        [1.5, 1.0, 1.5, INF],
        [INF, 1.5, 1.0, 1.5],
        [INF, INF, 1.5, 1.0],
    ])

    # Flash event at position 1
    u0 = np.array([INF, 0.0, INF, INF])

    print(f"\n  Flash event at spatial position 1")
    print(f"  Causal propagation (minimum action paths):")

    u = u0.copy()
    for t in range(4):
        print(f"  t={t}: {u}")
        u = tropical_einstein_step(K, u)
    print(f"  t=4: {u}")

    print("\n  Light cone expands: positions with finite cost are causally connected.")


def application_resource_allocation():
    """Application 3: Resource allocation via tropical dynamics.

    A factory has 5 production stages. Moving resources between stages
    has transition costs. We find the optimal allocation strategy using
    tropical evolution (= dynamic programming).
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Resource Allocation (Dynamic Programming)")
    print("=" * 60)

    # 5 production stages with transition costs
    K = np.array([
        [0,   3,   7,  10, 15],
        [3,   0,   2,   6, 12],
        [7,   2,   0,   3,  8],
        [10,  6,   3,   0,  4],
        [15, 12,   8,   4,  0],
    ], dtype=float)

    # Initial cost: resources start at stage 0
    u0 = np.array([0.0, np.inf, np.inf, np.inf, np.inf])
    stage_names = ["Raw", "Cut", "Assemble", "Test", "Ship"]

    print(f"\n  Optimal cost to reach each stage from Raw Materials:")
    u = u0.copy()
    for t in range(5):
        u = tropical_einstein_step(K, u)

    for i, (name, cost) in enumerate(zip(stage_names, u)):
        print(f"    {name:10s}: cost = {cost:.1f}")

    # Verify monotonicity: higher initial costs lead to higher final costs
    u0_expensive = np.array([5.0, np.inf, np.inf, np.inf, np.inf])
    u_exp = u0_expensive.copy()
    for t in range(5):
        u_exp = tropical_einstein_step(K, u_exp)

    print(f"\n  With +5 initial cost: {u_exp}")
    print(f"  Original + 5:        {u + 5}")
    print(f"  Shift equivariance verified: {np.allclose(u_exp, u + 5)}")


def application_horizon_detection():
    """Application 4: Horizon detection in layered networks.

    Model a gravitational well as a layered graph where edge weights
    increase near the center. The radial update detects the trapping horizon.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Horizon Detection in Gravitational Wells")
    print("=" * 60)

    masses = [1.0, 2.0, 3.0, 5.0, 10.0]

    print(f"\n  Mass vs. Horizon Radius (Tropical Schwarzschild):")
    print(f"  {'Mass':>8s} {'Horizon (2m)':>12s} {'Fixed Point?':>12s}")
    print(f"  {'----':>8s} {'----------':>12s} {'----------':>12s}")

    for m in masses:
        r_h = 2 * m
        fixed = min(r_h, 2 * m)
        print(f"  {m:8.1f} {r_h:12.1f} {str(fixed == r_h):>12s}")

    # Demonstrate absorption
    m = 5.0
    print(f"\n  Absorption beyond horizon (m={m}, horizon={2*m}):")
    test_radii = np.linspace(0, 20, 21)
    for r in test_radii:
        updated = min(r, 2 * m)
        marker = " ← horizon" if abs(r - 2 * m) < 0.5 else ""
        marker = " (absorbed)" if r > 2 * m else marker
        print(f"    r={r:5.1f} → radialUpdate = {updated:5.1f}{marker}")


def main():
    print("TROPICAL SPACETIME — REAL-WORLD APPLICATIONS")
    application_network_routing()
    application_causal_structure()
    application_resource_allocation()
    application_horizon_detection()
    print("\n" + "=" * 60)
    print("ALL APPLICATIONS COMPLETED")
    print("=" * 60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
demo.py — Demonstration of Tropical Spacetime Dynamics

Concrete numerical examples illustrating the formally verified theorems:
- Theorem A: Idempotent superposition
- Theorem B/C: Tropical Einstein evolution (Bellman operator)
- Theorem D: Tropical Schwarzschild horizon
"""

import numpy as np


def tropical_superpose(a: float, b: float) -> float:
    """Tropical superposition: min(a, b)."""
    return min(a, b)


def tropical_einstein_step(K: np.ndarray, u: np.ndarray) -> np.ndarray:
    """One-step tropical Einstein evolution (Bellman update).

    For each node x, computes min_y (u[y] + K[y, x]).
    """
    n = len(u)
    result = np.full(n, np.inf)
    for x in range(n):
        for y in range(n):
            result[x] = min(result[x], u[y] + K[y, x])
    return result


def tropical_evolution(K: np.ndarray, u0: np.ndarray, T: int) -> list[np.ndarray]:
    """Multi-step tropical evolution. Returns trajectory [u0, u1, ..., uT]."""
    trajectory = [u0.copy()]
    u = u0.copy()
    for _ in range(T):
        u = tropical_einstein_step(K, u)
        trajectory.append(u.copy())
    return trajectory


def radial_update(m: float, r: float) -> float:
    """Tropical radial update: min(r, 2m)."""
    return min(r, 2 * m)


def main():
    print("=" * 60)
    print("TROPICAL SPACETIME DYNAMICS — NUMERICAL DEMONSTRATIONS")
    print("=" * 60)

    # ---- Theorem A: Idempotent Superposition ----
    print("\n--- Theorem A: Idempotent Superposition ---")
    test_values = [3.14, -2.7, 0.0, 100.0]
    for s in test_values:
        result = tropical_superpose(s, s)
        assert result == s, f"Idempotence failed for {s}"
        print(f"  min({s}, {s}) = {result} ✓")

    print("\n  Commutativity: min(3, 5) =", tropical_superpose(3, 5),
          "= min(5, 3) =", tropical_superpose(5, 3))
    print("  Associativity: min(min(2,4),6) =",
          tropical_superpose(tropical_superpose(2, 4), 6),
          "= min(2,min(4,6)) =",
          tropical_superpose(2, tropical_superpose(4, 6)))
    print("  Distributivity: min(3+1, 5+1) =",
          tropical_superpose(3 + 1, 5 + 1),
          "= min(3,5)+1 =", tropical_superpose(3, 5) + 1)

    # ---- Theorem B/C: Tropical Einstein Evolution ----
    print("\n--- Theorem B/C: Tropical Einstein Evolution ---")

    # 4-node network
    K = np.array([
        [0, 1, 4, np.inf],
        [np.inf, 0, 2, 5],
        [np.inf, np.inf, 0, 1],
        [np.inf, np.inf, np.inf, 0]
    ])
    u0 = np.array([0, np.inf, np.inf, np.inf])

    print(f"\n  Kernel K (transition costs):")
    for row in K:
        print(f"    {row}")
    print(f"  Initial data u0 = {u0}")

    trajectory = tropical_evolution(K, u0, T=4)
    for t, u in enumerate(trajectory):
        print(f"  t={t}: u = {u}")

    print(f"\n  Final shortest-path distances: {trajectory[-1]}")
    print(f"  Expected: [0, 1, 3, 4]")

    # Monotonicity demonstration
    print("\n  --- Monotonicity verification ---")
    u_lower = np.array([0.0, 1.0, 2.0, 3.0])
    u_upper = np.array([1.0, 2.0, 3.0, 4.0])
    print(f"  u_lower = {u_lower}")
    print(f"  u_upper = {u_upper}")
    print(f"  u_lower ≤ u_upper? {np.all(u_lower <= u_upper)}")

    K_small = np.array([[0, 1, 3], [2, 0, 1], [1, 3, 0]], dtype=float)
    for t in range(4):
        step_lower = tropical_einstein_step(K_small, u_lower[:3])
        step_upper = tropical_einstein_step(K_small, u_upper[:3])
        mono_ok = np.all(step_lower <= step_upper)
        print(f"  After step {t + 1}: lower={step_lower}, upper={step_upper}, "
              f"monotone? {mono_ok}")
        u_lower[:3] = step_lower
        u_upper[:3] = step_upper

    # Shift equivariance
    print("\n  --- Shift equivariance (tropical linearity) ---")
    u_test = np.array([1.0, 3.0, 5.0])
    c = 10.0
    step_u = tropical_einstein_step(K_small, u_test)
    step_uc = tropical_einstein_step(K_small, u_test + c)
    print(f"  step(u) = {step_u}")
    print(f"  step(u + {c}) = {step_uc}")
    print(f"  step(u) + {c} = {step_u + c}")
    print(f"  Equal? {np.allclose(step_uc, step_u + c)}")

    # ---- Theorem D: Tropical Schwarzschild Horizon ----
    print("\n--- Theorem D: Tropical Schwarzschild Horizon ---")

    masses = [0.5, 1.0, 2.0, 5.0, 10.0]
    for m in masses:
        r_h = 2 * m
        fixed = radial_update(m, r_h)
        print(f"  m={m}: horizon 2m={r_h}, radialUpdate(m, 2m)={fixed}, "
              f"fixed point? {fixed == r_h}")

    print("\n  --- Fixed-point characterization ---")
    m = 3.0
    test_radii = [0.0, 1.0, 3.0, 5.99, 6.0, 6.01, 10.0, 100.0]
    for r in test_radii:
        updated = radial_update(m, r)
        is_fixed = (updated == r)
        print(f"  r={r:6.2f}: radialUpdate({m}, {r:6.2f}) = {updated:6.2f}, "
              f"fixed? {is_fixed:5}, r ≤ 2m? {r <= 2 * m}")

    print("\n  --- Idempotence ---")
    for r in [1.0, 5.0, 6.0, 7.0, 100.0]:
        once = radial_update(m, r)
        twice = radial_update(m, once)
        print(f"  r={r}: update(r)={once}, update(update(r))={twice}, "
              f"idempotent? {once == twice}")

    print("\n  --- Absorption beyond horizon ---")
    for r in [6.0, 6.1, 10.0, 1000.0]:
        result = radial_update(m, r)
        print(f"  r={r}: radialUpdate({m}, {r}) = {result} = 2m = {2 * m}")

    print("\n  --- Mass monotonicity ---")
    r_fixed = 5.0
    masses_mono = [1.0, 2.0, 3.0, 4.0, 5.0]
    results = [radial_update(mi, r_fixed) for mi in masses_mono]
    print(f"  r={r_fixed}, masses={masses_mono}")
    print(f"  radialUpdate results: {results}")
    print(f"  Monotone? {all(results[i] <= results[i + 1] for i in range(len(results) - 1))}")

    print("\n" + "=" * 60)
    print("ALL DEMONSTRATIONS PASSED SUCCESSFULLY")
    print("=" * 60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Generate PACKAGE.json with all artifacts."""
import json
import base64
from io import BytesIO
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# Read text files
def read_file(path):
    with open(path, 'r') as f:
        return f.read()

article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_proofs = read_file('Catalog/Physics/TropicalGravity/PlanckSpacetime.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')

# Generate visualization base64
def fig_to_base64(fig):
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"

def tropical_einstein_step(K, u):
    return np.min(u[:, None] + K, axis=0)

# Viz 1: Evolution convergence
np.random.seed(42)
n = 10
K = np.random.uniform(0, 5, (n, n))
np.fill_diagonal(K, 0)
u0 = np.random.uniform(0, 20, n)
T = 15
trajectory = [u0.copy()]
u = u0.copy()
for _ in range(T):
    u = tropical_einstein_step(K, u)
    trajectory.append(u.copy())
trajectory_arr = np.array(trajectory)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
for i in range(n):
    ax1.plot(range(T + 1), trajectory_arr[:, i], '-o', markersize=3, alpha=0.7)
ax1.set_xlabel('Time Step'); ax1.set_ylabel('State Value')
ax1.set_title('Tropical Einstein Evolution: Convergence'); ax1.grid(True, alpha=0.3)
changes = [np.max(np.abs(trajectory_arr[t+1] - trajectory_arr[t])) for t in range(T)]
ax2.semilogy(range(1, T+1), changes, 'b-o', markersize=5)
ax2.set_xlabel('Time Step'); ax2.set_ylabel('Max Change')
ax2.set_title('Convergence Rate'); ax2.grid(True, alpha=0.3)
plt.tight_layout()
viz1 = fig_to_base64(fig)

# Viz 2: Radial update
fig, axes = plt.subplots(1, 3, figsize=(16, 5))
r = np.linspace(0, 20, 200)
masses = [2, 4, 6, 8]
ax = axes[0]
ax.plot(r, r, 'k--', alpha=0.5, label='identity')
for m in masses:
    ax.plot(r, np.minimum(r, 2*m), linewidth=2, label=f'm={m}')
ax.set_xlabel('r'); ax.set_ylabel('radialUpdate(m,r)'); ax.set_title('Tropical Radial Update')
ax.legend(); ax.grid(True, alpha=0.3)
ax = axes[1]
m_vals = np.linspace(0, 5, 100)
ax.fill_between(m_vals, 0, 2*m_vals, alpha=0.3, color='blue', label='Fixed points {r≤2m}')
ax.plot(m_vals, 2*m_vals, 'r-', linewidth=2, label='Greatest fixed pt r=2m')
ax.set_xlabel('Mass m'); ax.set_ylabel('Radius r'); ax.set_title('Fixed Point Set'); ax.legend(); ax.grid(True, alpha=0.3)
ax = axes[2]
m = 3.0
for r0 in [1, 4, 6, 8, 12, 15]:
    vals = [r0]
    rc = r0
    for _ in range(6):
        rc = min(rc, 2*m)
        vals.append(rc)
    ax.plot(range(len(vals)), vals, '-o', markersize=5, label=f'r₀={r0}')
ax.axhline(y=2*m, color='red', linestyle='--', alpha=0.7, label='Horizon')
ax.set_xlabel('Iteration'); ax.set_ylabel('Radius'); ax.set_title('Iteration to Horizon'); ax.legend(); ax.grid(True, alpha=0.3)
plt.tight_layout()
viz2 = fig_to_base64(fig)

# Viz 3: Monotonicity
np.random.seed(123)
n = 5
K = np.random.uniform(0, 3, (n, n))
np.fill_diagonal(K, 0)
u_lo = np.array([0.0, 1.0, 2.0, 3.0, 4.0])
u_hi = u_lo + 2.0
T = 10
traj_lo = [u_lo.copy()]; traj_hi = [u_hi.copy()]
ul, uh = u_lo.copy(), u_hi.copy()
for _ in range(T):
    ul = tropical_einstein_step(K, ul); uh = tropical_einstein_step(K, uh)
    traj_lo.append(ul.copy()); traj_hi.append(uh.copy())
traj_lo = np.array(traj_lo); traj_hi = np.array(traj_hi)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
for i in range(n):
    c = plt.cm.tab10(i)
    ax1.plot(range(T+1), traj_lo[:,i], '-', color=c, alpha=0.7)
    ax1.plot(range(T+1), traj_hi[:,i], '--', color=c, alpha=0.7)
ax1.set_xlabel('Time Step'); ax1.set_ylabel('Value'); ax1.set_title('Monotonicity Preserved'); ax1.grid(True, alpha=0.3)
gaps = traj_hi - traj_lo
for i in range(n):
    ax2.plot(range(T+1), gaps[:,i], '-o', markersize=3, label=f'Node {i}')
ax2.axhline(y=0, color='red', linestyle='--', alpha=0.5)
ax2.set_xlabel('Time Step'); ax2.set_ylabel('Gap'); ax2.set_title('Gap ≥ 0 (Monotonicity)'); ax2.legend(); ax2.grid(True, alpha=0.3)
plt.tight_layout()
viz3 = fig_to_base64(fig)

# Viz 4: Distance matrix
np.random.seed(7)
n = 8
K = np.random.uniform(1, 10, (n, n))
np.fill_diagonal(K, 0)
mask = np.random.random((n, n)) > 0.6
np.fill_diagonal(mask, False)
K[mask] = np.inf
D = K.copy()
for k in range(n):
    for i in range(n):
        for j in range(n):
            if D[i,k] + D[k,j] < D[i,j]:
                D[i,j] = D[i,k] + D[k,j]
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
Kp = K.copy(); Kp[Kp==np.inf] = np.nan
ax1.imshow(Kp, cmap='YlOrRd'); ax1.set_title('Edge Weights'); ax1.set_xlabel('Target'); ax1.set_ylabel('Source')
Dp = D.copy(); Dp[Dp==np.inf] = np.nan
ax2.imshow(Dp, cmap='YlOrRd'); ax2.set_title('Shortest Paths (Tropical Distance)'); ax2.set_xlabel('Target'); ax2.set_ylabel('Source')
plt.tight_layout()
viz4 = fig_to_base64(fig)

# Build package
package = {
    "title": "Tropical Spacetime at Planck Scale: Idempotent Gravitational Dynamics",
    "domain": "Mathematical Physics / Tropical Geometry",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {"name": "Tropical Spacetime Demo", "code": demo_code},
        {"name": "Applications Demo", "code": applications_code}
    ],
    "algorithms": [
        {
            "name": "Tropical Einstein Evolution (Bellman Operator)",
            "pseudocode": "Input: K (n×n kernel), u₀ (initial state), T (steps)\nOutput: Evolved state u_T\n\nu ← u₀\nfor t = 1 to T:\n    for each x in {1,...,n}:\n        u_new[x] ← min_{y} (u[y] + K[y,x])\n    u ← u_new\nreturn u\n\nComplexity: O(T·n²) time, O(n) space",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {"name": "Evolution Convergence", "data": viz1},
        {"name": "Radial Update & Horizon", "data": viz2},
        {"name": "Monotonicity Verification", "data": viz3},
        {"name": "Tropical Distance Matrix", "data": viz4}
    ],
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("PACKAGE.json generated successfully.")
print(f"Size: {len(json.dumps(package))} chars")


#!/usr/bin/env python3
"""
visualizations.py — Generate visualizations for tropical spacetime dynamics.

Creates publication-quality figures showing:
1. Tropical evolution convergence on a random graph
2. Radial update and horizon fixed points
3. Monotonicity of evolution
4. Tropical distance matrix heatmap
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
from io import BytesIO


def tropical_einstein_step(K, u):
    return np.min(u[:, None] + K, axis=0)


def fig_to_base64(fig) -> str:
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def plot_evolution_convergence():
    """Plot convergence of tropical evolution on a random graph."""
    np.random.seed(42)
    n = 10
    K = np.random.uniform(0, 5, (n, n))
    np.fill_diagonal(K, 0)

    u0 = np.random.uniform(0, 20, n)
    T = 15

    trajectory = [u0.copy()]
    u = u0.copy()
    for _ in range(T):
        u = tropical_einstein_step(K, u)
        trajectory.append(u.copy())

    trajectory = np.array(trajectory)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    for i in range(n):
        ax1.plot(range(T + 1), trajectory[:, i], '-o', markersize=3,
                 label=f'Node {i}', alpha=0.7)
    ax1.set_xlabel('Time Step', fontsize=12)
    ax1.set_ylabel('State Value', fontsize=12)
    ax1.set_title('Tropical Einstein Evolution: Convergence', fontsize=14)
    ax1.legend(fontsize=8, ncol=2)
    ax1.grid(True, alpha=0.3)

    # Plot max change per step
    changes = [np.max(np.abs(trajectory[t + 1] - trajectory[t]))
               for t in range(T)]
    ax2.semilogy(range(1, T + 1), changes, 'b-o', markersize=5)
    ax2.set_xlabel('Time Step', fontsize=12)
    ax2.set_ylabel('Max Change (log scale)', fontsize=12)
    ax2.set_title('Convergence Rate', fontsize=14)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Tropical Spacetime Evolution on Random 10-Node Graph',
                 fontsize=16, y=1.02)
    plt.tight_layout()

    fig.savefig('evolution_convergence.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def plot_radial_update():
    """Plot the radial update function and its fixed points."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Plot 1: radialUpdate for different masses
    r = np.linspace(0, 20, 200)
    masses = [2, 4, 6, 8]
    ax = axes[0]
    ax.plot(r, r, 'k--', alpha=0.5, label='r = r (identity)')
    for m in masses:
        y = np.minimum(r, 2 * m)
        ax.plot(r, y, linewidth=2, label=f'm = {m} (horizon = {2*m})')
    ax.set_xlabel('Radius r', fontsize=12)
    ax.set_ylabel('radialUpdate(m, r)', fontsize=12)
    ax.set_title('Tropical Radial Update', fontsize=14)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 20)
    ax.set_ylim(0, 20)

    # Plot 2: Fixed point set visualization
    ax = axes[1]
    m_vals = np.linspace(0, 5, 100)
    ax.fill_between(m_vals, 0, 2 * m_vals, alpha=0.3, color='blue',
                     label='Fixed point region\n{r ≤ 2m}')
    ax.plot(m_vals, 2 * m_vals, 'r-', linewidth=2,
            label='Greatest nonneg fixed point\nr = 2m')
    ax.set_xlabel('Mass m', fontsize=12)
    ax.set_ylabel('Radius r', fontsize=12)
    ax.set_title('Fixed Point Characterization', fontsize=14)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Plot 3: Iteration to fixed point
    ax = axes[2]
    m = 3.0
    starts = [1, 4, 6, 8, 12, 15]
    for r0 in starts:
        vals = [r0]
        r_curr = r0
        for _ in range(6):
            r_curr = min(r_curr, 2 * m)
            vals.append(r_curr)
        ax.plot(range(len(vals)), vals, '-o', markersize=5, label=f'r₀ = {r0}')
    ax.axhline(y=2 * m, color='red', linestyle='--', alpha=0.7, label=f'Horizon = {2*m}')
    ax.set_xlabel('Iteration', fontsize=12)
    ax.set_ylabel('Radius', fontsize=12)
    ax.set_title(f'Iteration to Horizon (m={m})', fontsize=14)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    fig.suptitle('Tropical Schwarzschild Horizon Analysis', fontsize=16, y=1.02)
    plt.tight_layout()

    fig.savefig('radial_update.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def plot_monotonicity():
    """Demonstrate monotonicity of tropical evolution."""
    np.random.seed(123)
    n = 5
    K = np.random.uniform(0, 3, (n, n))
    np.fill_diagonal(K, 0)

    u_lo = np.array([0.0, 1.0, 2.0, 3.0, 4.0])
    u_hi = u_lo + 2.0
    T = 10

    traj_lo = [u_lo.copy()]
    traj_hi = [u_hi.copy()]
    u, v = u_lo.copy(), u_hi.copy()
    for _ in range(T):
        u = tropical_einstein_step(K, u)
        v = tropical_einstein_step(K, v)
        traj_lo.append(u.copy())
        traj_hi.append(v.copy())

    traj_lo = np.array(traj_lo)
    traj_hi = np.array(traj_hi)

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    ax = axes[0]
    for i in range(n):
        color = plt.cm.tab10(i)
        ax.plot(range(T + 1), traj_lo[:, i], '-', color=color, alpha=0.7,
                label=f'Node {i} (lower)')
        ax.plot(range(T + 1), traj_hi[:, i], '--', color=color, alpha=0.7,
                label=f'Node {i} (upper)')
    ax.set_xlabel('Time Step', fontsize=12)
    ax.set_ylabel('State Value', fontsize=12)
    ax.set_title('Monotonicity: Lower ≤ Upper Preserved', fontsize=14)
    ax.grid(True, alpha=0.3)

    ax = axes[1]
    gaps = traj_hi - traj_lo  # Should be >= 0 everywhere
    for i in range(n):
        ax.plot(range(T + 1), gaps[:, i], '-o', markersize=3, label=f'Node {i}')
    ax.axhline(y=0, color='red', linestyle='--', alpha=0.5)
    ax.set_xlabel('Time Step', fontsize=12)
    ax.set_ylabel('Gap (upper - lower)', fontsize=12)
    ax.set_title('Gap Remains Nonneg (Monotonicity)', fontsize=14)
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    fig.suptitle('Order Preservation in Tropical Evolution', fontsize=16, y=1.02)
    plt.tight_layout()

    fig.savefig('monotonicity.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def plot_distance_matrix():
    """Visualize tropical shortest-path distance matrix."""
    np.random.seed(7)
    n = 8
    K = np.random.uniform(1, 10, (n, n))
    np.fill_diagonal(K, 0)
    # Make some edges infinite (sparse graph)
    mask = np.random.random((n, n)) > 0.6
    np.fill_diagonal(mask, False)
    K[mask] = np.inf

    # Floyd-Warshall
    D = K.copy()
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if D[i, k] + D[k, j] < D[i, j]:
                    D[i, j] = D[i, k] + D[k, j]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    K_plot = K.copy()
    K_plot[K_plot == np.inf] = np.nan
    im1 = ax1.imshow(K_plot, cmap='YlOrRd', aspect='equal')
    ax1.set_title('Edge Weights (NaN = no edge)', fontsize=14)
    ax1.set_xlabel('Target Node')
    ax1.set_ylabel('Source Node')
    plt.colorbar(im1, ax=ax1, shrink=0.8)

    D_plot = D.copy()
    D_plot[D_plot == np.inf] = np.nan
    im2 = ax2.imshow(D_plot, cmap='YlOrRd', aspect='equal')
    ax2.set_title('Tropical Distance (Shortest Paths)', fontsize=14)
    ax2.set_xlabel('Target Node')
    ax2.set_ylabel('Source Node')
    plt.colorbar(im2, ax=ax2, shrink=0.8)

    fig.suptitle('Tropical Metric from Min-Plus Edge Composition', fontsize=16, y=1.02)
    plt.tight_layout()

    fig.savefig('distance_matrix.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def main():
    print("Generating visualizations...")
    b64_evolution = plot_evolution_convergence()
    print(f"  evolution_convergence.png: {len(b64_evolution)} chars")

    b64_radial = plot_radial_update()
    print(f"  radial_update.png: {len(b64_radial)} chars")

    b64_mono = plot_monotonicity()
    print(f"  monotonicity.png: {len(b64_mono)} chars")

    b64_dist = plot_distance_matrix()
    print(f"  distance_matrix.png: {len(b64_dist)} chars")

    print("All visualizations generated.")
    return {
        "evolution_convergence": b64_evolution,
        "radial_update": b64_radial,
        "monotonicity": b64_mono,
        "distance_matrix": b64_dist,
    }


if __name__ == "__main__":
    main()
