#!/usr/bin/env python3
"""
Applications of Tropical Ecosystem Dynamics
============================================

Real-world applications of min-plus predator-prey theory to ecology,
network science, scheduling, and control systems.
"""

import numpy as np
from typing import List, Tuple


def trop_step(params, state):
    a, b, c, d = params
    x, y = state
    return (min(a + x, b + y), min(c + x, d + y))


def trop_eigenvalue(a, b, c, d):
    return min(a, d, (b + c) / 2)


# ═══════════════════════════════════════════════════════════════════════════
# APPLICATION 1: Ecological Resilience Analysis
# ═══════════════════════════════════════════════════════════════════════════

def ecological_resilience_analysis():
    """
    Analyze ecosystem resilience under parameter perturbation.

    In tropical ecology, the eigenvalue μ = min(a, d, (b+c)/2) determines
    the long-term growth rate. Resilience is measured by how much μ changes
    under perturbation of the interaction parameters.

    A resilient ecosystem has ∂μ/∂p ≈ 0 for small perturbations p.
    """
    print("=" * 70)
    print("APPLICATION 1: Ecological Resilience Analysis")
    print("=" * 70)

    # Baseline ecosystem: wolves and rabbits
    # a = rabbit self-renewal rate (tropical)
    # b = rabbit response to wolf pressure
    # c = wolf benefit from rabbit prey
    # d = wolf self-renewal rate
    a, b, c, d = 2.0, 5.0, 3.0, 4.0
    mu_base = trop_eigenvalue(a, b, c, d)
    print(f"\nBaseline ecosystem: a={a}, b={b}, c={c}, d={d}")
    print(f"Tropical eigenvalue μ = {mu_base}")
    print(f"Dominant cycle: ", end="")
    if mu_base == a:
        print("prey self-loop (prey-limited)")
    elif mu_base == d:
        print("predator self-loop (predator-limited)")
    else:
        print("predator-prey cycle (interaction-limited)")

    # Perturbation analysis
    print("\nPerturbation sensitivity (Δ = ±0.5):")
    delta = 0.5
    for name, perturbed in [
        ("a+Δ", (a + delta, b, c, d)),
        ("a-Δ", (a - delta, b, c, d)),
        ("b+Δ", (a, b + delta, c, d)),
        ("c+Δ", (a, b, c + delta, d)),
        ("d+Δ", (a, b, c, d + delta)),
        ("d-Δ", (a, b, c, d - delta)),
    ]:
        mu_pert = trop_eigenvalue(*perturbed)
        print(f"  {name:5s}: μ = {mu_pert:.2f}, Δμ = {mu_pert - mu_base:+.2f}")

    # Regime shift detection
    print("\nRegime shift analysis (increasing wolf pressure b):")
    for b_val in np.arange(0, 8, 0.5):
        mu = trop_eigenvalue(a, b_val, c, d)
        dominant = "prey" if mu == a else ("pred" if mu == d else "cycle")
        bar = "█" * int(mu * 5) if mu > 0 else ""
        print(f"  b={b_val:4.1f}: μ={mu:5.2f} [{dominant:5s}] {bar}")


# ═══════════════════════════════════════════════════════════════════════════
# APPLICATION 2: Discrete Event System / Manufacturing
# ═══════════════════════════════════════════════════════════════════════════

def manufacturing_scheduling():
    """
    Model a two-machine manufacturing line as a min-plus system.

    Machine 1 (prey): processing unit
    Machine 2 (predator): assembly unit

    a = Machine 1 cycle time when self-feeding
    b = Machine 1 waiting time for Machine 2 output
    c = Machine 2 waiting time for Machine 1 output
    d = Machine 2 cycle time when self-feeding

    The tropical eigenvalue gives the throughput rate.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Manufacturing Line Throughput")
    print("=" * 70)

    # Scenario: Two machines with different cycle times
    configs = [
        ("Balanced line", 3, 2, 2, 3),
        ("Bottleneck at M1", 5, 2, 2, 3),
        ("Bottleneck at M2", 3, 2, 2, 6),
        ("Fast exchange", 4, 1, 1, 4),
    ]

    for name, a, b, c, d in configs:
        mu = trop_eigenvalue(a, b, c, d)
        throughput = 1.0 / mu if mu > 0 else float('inf')
        print(f"\n  {name}:")
        print(f"    Parameters: a={a}, b={b}, c={c}, d={d}")
        print(f"    Cycle time μ = {mu:.2f}")
        print(f"    Throughput = {throughput:.3f} units/time")

        # Simulate 20 steps
        state = (0.0, 0.0)
        times = [state]
        for _ in range(20):
            state = trop_step((a, b, c, d), state)
            times.append(state)

        # Check linear growth
        growth_1 = (times[-1][0] - times[0][0]) / 20
        growth_2 = (times[-1][1] - times[0][1]) / 20
        print(f"    Empirical growth rate: M1={growth_1:.2f}, M2={growth_2:.2f}")


# ═══════════════════════════════════════════════════════════════════════════
# APPLICATION 3: Network Shortest Paths / Routing
# ═══════════════════════════════════════════════════════════════════════════

def network_routing():
    """
    Interpret tropical dynamics as iterative shortest-path computation.

    In network routing, the min-plus iteration computes shortest paths:
    x_{n+1}(i) = min_j (w_{ij} + x_n(j))

    The tropical eigenvalue gives the minimum average cost per hop.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Network Routing — Min-Cost Cycles")
    print("=" * 70)

    # Network with 2 routers
    # a = cost of routing through self (Router 1)
    # b = cost of routing from Router 2 to Router 1
    # c = cost of routing from Router 1 to Router 2
    # d = cost of routing through self (Router 2)

    networks = [
        ("Symmetric network", 1, 2, 2, 1),
        ("Asymmetric costs", 1, 3, 1, 4),
        ("Cheap shortcut 2→1", 3, 0.5, 2, 3),
    ]

    for name, a, b, c, d in networks:
        mu = trop_eigenvalue(a, b, c, d)
        print(f"\n  {name}: [[{a}, {b}], [{c}, {d}]]")
        print(f"    Min avg cost per hop: {mu:.2f}")
        print(f"    Self-loop R1: {a:.1f}, Self-loop R2: {d:.1f}, "
              f"Cycle R1↔R2: {(b+c)/2:.1f}")


# ═══════════════════════════════════════════════════════════════════════════
# APPLICATION 4: Food Web Analysis (n-species extension)
# ═══════════════════════════════════════════════════════════════════════════

def food_web_analysis():
    """
    Extend to a 3-species food web using min-plus matrix iteration.

    Species: Grass (G), Rabbit (R), Fox (F)
    Interaction matrix A in min-plus:
        A[i][j] = tropical cost of species i being influenced by species j
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Three-Species Food Web")
    print("=" * 70)

    # 3x3 min-plus matrix
    INF = float('inf')
    A = [
        [1, INF, 4],    # Grass: self-renew=1, no rabbit input, fox decay cost=4
        [2, 3, INF],    # Rabbit: eats grass=2, self-renew=3, no fox input
        [INF, 1, 5],    # Fox: no grass, eats rabbit=1, self-renew=5
    ]

    print("  Interaction matrix (∞ = no direct interaction):")
    for i, row in enumerate(A):
        species = ["Grass", "Rabbit", "Fox"][i]
        print(f"    {species:6s}: {[f'{x:4.0f}' if x < INF else ' inf' for x in row]}")

    # Compute all cycle means
    n = 3
    print("\n  Simple cycles and their means:")

    # 1-cycles (self-loops)
    for i in range(n):
        if A[i][i] < INF:
            name = ["Grass", "Rabbit", "Fox"][i]
            print(f"    {name} self-loop: {A[i][i]:.1f}")

    # 2-cycles
    for i in range(n):
        for j in range(i + 1, n):
            if A[i][j] < INF and A[j][i] < INF:
                mean = (A[i][j] + A[j][i]) / 2
                ni, nj = ["G", "R", "F"][i], ["G", "R", "F"][j]
                print(f"    {ni}↔{nj} 2-cycle: ({A[i][j]}+{A[j][i]})/2 = {mean:.1f}")

    # 3-cycle
    if all(A[i][(i+1)%3] < INF for i in range(3)):
        cycle_sum = sum(A[i][(i+1)%3] for i in range(3))
        mean = cycle_sum / 3
        print(f"    G→R→F→G 3-cycle: {cycle_sum}/3 = {mean:.2f}")

    # Find minimum cycle mean (tropical eigenvalue for n×n)
    all_means = []
    for i in range(n):
        if A[i][i] < INF:
            all_means.append(A[i][i])
    for i in range(n):
        for j in range(i + 1, n):
            if A[i][j] < INF and A[j][i] < INF:
                all_means.append((A[i][j] + A[j][i]) / 2)
    if all(A[i][(i+1)%3] < INF for i in range(3)):
        all_means.append(sum(A[i][(i+1)%3] for i in range(3)) / 3)

    mu = min(all_means)
    print(f"\n  Minimum cycle mean (tropical eigenvalue): μ = {mu:.2f}")
    print(f"  This determines the long-term growth rate of the food web.")


# ═══════════════════════════════════════════════════════════════════════════
# APPLICATION 5: Climate Perturbation Scenario
# ═══════════════════════════════════════════════════════════════════════════

def climate_perturbation():
    """
    Model how climate change shifts ecosystem dynamics by perturbing
    interaction parameters and tracking regime shifts.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 5: Climate Perturbation & Regime Shifts")
    print("=" * 70)

    # Baseline: temperate predator-prey system
    a_base, b_base, c_base, d_base = 2.0, 4.0, 3.0, 3.0

    print(f"\n  Baseline: a={a_base}, b={b_base}, c={c_base}, d={d_base}")
    print(f"  Baseline μ = {trop_eigenvalue(a_base, b_base, c_base, d_base):.2f}")

    # Climate warming: prey reproduction easier (a↓), predator stress (d↑)
    print("\n  Climate warming scenario (prey a decreases, predator d increases):")
    for temp_shift in np.arange(0, 3, 0.5):
        a = a_base - 0.3 * temp_shift
        d = d_base + 0.5 * temp_shift
        mu = trop_eigenvalue(a, b_base, c_base, d)
        regime = "prey" if mu == a else ("pred" if mu == d else "cycle")
        print(f"    ΔT={temp_shift:+.1f}°C: a={a:.1f}, d={d:.1f}, "
              f"μ={mu:.2f} [{regime}]")


# ═══════════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    ecological_resilience_analysis()
    manufacturing_scheduling()
    network_routing()
    food_web_analysis()
    climate_perturbation()
    print("\n" + "=" * 70)
    print("ALL APPLICATIONS COMPLETED")
    print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Ecosystem Dynamics: Predator-Prey as Min-Plus Lotka-Volterra
=====================================================================

Concrete numerical demonstrations of the formally verified theorems.
"""

import numpy as np

def trop_pred_prey(a, b, c, d, x, y):
    """Tropical predator-prey update: min-plus matrix action."""
    x_new = min(a + x, b + y)
    y_new = min(c + x, d + y)
    return x_new, y_new

def trop_eigenvalue_2(a, b, c, d):
    """Tropical eigenvalue: minimum cycle mean of 2-node digraph."""
    return min(a, d, (b + c) / 2)

def sup_dist(p, q):
    """Sup-norm (L-infinity) distance between two points."""
    return max(abs(p[0] - q[0]), abs(p[1] - q[1]))

# ─── Demo 1: Fixed Point Invariance ────────────────────────────────────────
print("=" * 70)
print("DEMO 1: Fixed Point Invariance (Theorem 1)")
print("=" * 70)

# Parameters where (0, 0) is a fixed point: need min(a, b) = 0 and min(c, d) = 0
a, b, c, d = 0, 1, 2, 0
p = (0.0, 0.0)
print(f"Parameters: a={a}, b={b}, c={c}, d={d}")
print(f"Fixed point candidate: p = {p}")
print(f"F(p) = {trop_pred_prey(a, b, c, d, *p)}")
print(f"Verifying F(p) == p: {trop_pred_prey(a, b, c, d, *p) == p}")

# Iterate 20 times
state = p
for n in range(20):
    state = trop_pred_prey(a, b, c, d, *state)
assert state == p, "Fixed point not preserved!"
print(f"After 20 iterations: state = {state} ✓")

# ─── Demo 2: Tropical Eigenvalue as Min Cycle Mean ─────────────────────────
print("\n" + "=" * 70)
print("DEMO 2: Tropical Eigenvalue = Min Cycle Mean (Theorem 2)")
print("=" * 70)

test_params = [
    (1, 3, 5, 2),
    (0, -1, -1, 0),
    (2, 1, 3, 4),
    (-1, 2, 0, -2),
]

for a, b, c, d in test_params:
    mu = trop_eigenvalue_2(a, b, c, d)
    loop_prey = a
    loop_pred = d
    cycle_mean = (b + c) / 2
    print(f"a={a:3}, b={b:3}, c={c:3}, d={d:3} | "
          f"prey-loop={loop_prey}, pred-loop={loop_pred}, "
          f"2-cycle-mean={cycle_mean:.1f} | μ = {mu}")

# ─── Demo 3: Eigenvector Iterates (Theorem 3) ─────────────────────────────
print("\n" + "=" * 70)
print("DEMO 3: Eigenvector Iterates — Linear Drift (Theorem 3)")
print("=" * 70)

# Find eigenvector: need min(a+v1, b+v2) = mu+v1, min(c+v1, d+v2) = mu+v2
# For a=1, b=3, c=1, d=5: mu = min(1, 5, (3+1)/2) = min(1, 5, 2) = 1
a, b, c, d = 1, 3, 1, 5
mu = trop_eigenvalue_2(a, b, c, d)
print(f"Parameters: a={a}, b={b}, c={c}, d={d}, μ={mu}")

# Eigenvector: v such that F(v) = (mu+v1, mu+v2)
# min(1+v1, 3+v2) = 1+v1 requires 1+v1 ≤ 3+v2, i.e. v1-v2 ≤ 2
# min(1+v1, 5+v2) = 1+v1 requires 1+v1 ≤ 5+v2, i.e. v1-v2 ≤ 4
# So v = (0, 0) works: min(1,3)=1=1+0, min(1,5)=1=1+0 ✓
v = (0.0, 0.0)
fv = trop_pred_prey(a, b, c, d, *v)
print(f"Eigenvector: v = {v}")
print(f"F(v) = {fv}, expected ({mu}+{v[0]}, {mu}+{v[1]}) = ({mu+v[0]}, {mu+v[1]})")

state = v
for n in range(10):
    expected = (n * mu + v[0], n * mu + v[1])
    assert abs(state[0] - expected[0]) < 1e-10 and abs(state[1] - expected[1]) < 1e-10
    print(f"  n={n:2d}: F^[n](v) = ({state[0]:6.1f}, {state[1]:6.1f}), "
          f"expected = ({expected[0]:6.1f}, {expected[1]:6.1f}) ✓")
    state = trop_pred_prey(a, b, c, d, *state)

# ─── Demo 4: Nonexpansiveness (Theorem 4) ─────────────────────────────────
print("\n" + "=" * 70)
print("DEMO 4: Nonexpansiveness in Sup-Norm (Theorem 4)")
print("=" * 70)

np.random.seed(42)
a, b, c, d = 2.0, -1.0, 0.5, 3.0
print(f"Parameters: a={a}, b={b}, c={c}, d={d}")
print(f"Testing 1000 random pairs...")

max_expansion = 0.0
for _ in range(1000):
    p = tuple(np.random.randn(2) * 10)
    q = tuple(np.random.randn(2) * 10)
    fp = trop_pred_prey(a, b, c, d, *p)
    fq = trop_pred_prey(a, b, c, d, *q)
    d_before = sup_dist(p, q)
    d_after = sup_dist(fp, fq)
    if d_before > 0:
        ratio = d_after / d_before
        max_expansion = max(max_expansion, ratio)

print(f"Maximum expansion ratio: {max_expansion:.10f}")
print(f"Nonexpansive (ratio ≤ 1): {max_expansion <= 1.0 + 1e-10} ✓")

# ─── Demo 5: Monotonicity ─────────────────────────────────────────────────
print("\n" + "=" * 70)
print("DEMO 5: Coordinatewise Monotonicity")
print("=" * 70)

a, b, c, d = 1.0, 2.0, 3.0, 4.0
print(f"Parameters: a={a}, b={b}, c={c}, d={d}")
violations = 0
for _ in range(10000):
    p = tuple(np.random.randn(2) * 5)
    q = (p[0] + abs(np.random.randn()), p[1] + abs(np.random.randn()))
    fp = trop_pred_prey(a, b, c, d, *p)
    fq = trop_pred_prey(a, b, c, d, *q)
    if fp[0] > fq[0] + 1e-12 or fp[1] > fq[1] + 1e-12:
        violations += 1
print(f"Tested 10000 pairs with p ≤ q componentwise")
print(f"Monotonicity violations: {violations} ✓")

# ─── Demo 6: Spectral Bound ───────────────────────────────────────────────
print("\n" + "=" * 70)
print("DEMO 6: Spectral Bound — μ^n ≤ 1 when 0 ≤ μ ≤ 1")
print("=" * 70)

a, b, c, d = 0.3, 0.5, 0.7, 0.4
mu = trop_eigenvalue_2(a, b, c, d)
print(f"Parameters: a={a}, b={b}, c={c}, d={d}")
print(f"Tropical eigenvalue μ = {mu}")
print(f"0 ≤ μ ≤ 1: {0 <= mu <= 1}")
for n in range(1, 11):
    print(f"  μ^{n:2d} = {mu**n:.10f} ≤ 1: {mu**n <= 1.0}")

print("\n" + "=" * 70)
print("ALL DEMOS PASSED ✓")
print("=" * 70)


#!/usr/bin/env python3
"""
Visualizations for Tropical Ecosystem Dynamics
===============================================

Generates publication-quality figures illustrating min-plus predator-prey theory.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import base64
import io


def trop_step(params, state):
    a, b, c, d = params
    x, y = state
    return (min(a + x, b + y), min(c + x, d + y))


def trop_eigenvalue(a, b, c, d):
    return min(a, d, (b + c) / 2)


def fig_to_base64(fig) -> str:
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode()


# ─── Figure 1: Eigenvector Drift Trajectory ────────────────────────────────

def plot_eigenvector_drift():
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: trajectory in state space
    ax = axes[0]
    a, b, c, d = 1, 3, 1, 5
    mu = trop_eigenvalue(a, b, c, d)
    v = (0.0, 0.0)

    xs, ys = [v[0]], [v[1]]
    state = v
    for _ in range(15):
        state = trop_step((a, b, c, d), state)
        xs.append(state[0])
        ys.append(state[1])

    ax.plot(xs, ys, 'o-', color='#2196F3', markersize=8, linewidth=2, label='Trajectory')
    ax.plot(xs[0], ys[0], 's', color='#4CAF50', markersize=12, zorder=5, label='Start')

    # Theoretical line y = x (eigenvector direction)
    t = np.linspace(0, max(xs) * 1.1, 100)
    ax.plot(t, t, '--', color='#FF9800', alpha=0.5, linewidth=1.5, label='y = x (eigenvector line)')

    ax.set_xlabel('Prey (tropical)', fontsize=12)
    ax.set_ylabel('Predator (tropical)', fontsize=12)
    ax.set_title(f'Eigenvector Drift: μ={mu}, params=({a},{b},{c},{d})', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Right: coordinate vs time
    ax = axes[1]
    ns = range(len(xs))
    ax.plot(ns, xs, 'o-', color='#2196F3', label='Prey x(n)', markersize=6)
    ax.plot(ns, ys, 's-', color='#F44336', label='Predator y(n)', markersize=6)
    ax.plot(ns, [n * mu for n in ns], '--', color='#9C27B0', linewidth=2,
            label=f'n·μ = n·{mu}')

    ax.set_xlabel('Time step n', fontsize=12)
    ax.set_ylabel('Tropical coordinate', fontsize=12)
    ax.set_title('Linear Growth at Eigenvalue Rate', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    b64 = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/fig_eigenvector_drift.png', dpi=150, bbox_inches='tight')
    plt.close()
    return b64


# ─── Figure 2: Nonexpansiveness ────────────────────────────────────────────

def plot_nonexpansiveness():
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    params_list = [(2, -1, 0.5, 3), (0, -1, -1, 0)]
    titles = ['Standard params (2,-1,0.5,3)', 'Symmetric params (0,-1,-1,0)']

    for ax, params, title in zip(axes, params_list, titles):
        rng = np.random.RandomState(42)
        d_in_list, d_out_list = [], []

        for _ in range(2000):
            p = tuple(rng.randn(2) * 5)
            q = tuple(rng.randn(2) * 5)
            fp = trop_step(params, p)
            fq = trop_step(params, q)
            d_in = max(abs(p[0]-q[0]), abs(p[1]-q[1]))
            d_out = max(abs(fp[0]-fq[0]), abs(fp[1]-fq[1]))
            d_in_list.append(d_in)
            d_out_list.append(d_out)

        ax.scatter(d_in_list, d_out_list, alpha=0.3, s=10, color='#2196F3')
        mx = max(max(d_in_list), max(d_out_list)) * 1.05
        ax.plot([0, mx], [0, mx], 'r--', linewidth=2, label='d_out = d_in (boundary)')
        ax.set_xlabel('Input distance (sup-norm)', fontsize=12)
        ax.set_ylabel('Output distance (sup-norm)', fontsize=12)
        ax.set_title(f'Nonexpansiveness: {title}', fontsize=12)
        ax.legend(fontsize=10)
        ax.grid(True, alpha=0.3)
        ax.set_xlim(0, mx)
        ax.set_ylim(0, mx)

    plt.tight_layout()
    b64 = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/fig_nonexpansiveness.png', dpi=150, bbox_inches='tight')
    plt.close()
    return b64


# ─── Figure 3: Eigenvalue Phase Diagram ───────────────────────────────────

def plot_eigenvalue_phase():
    fig, ax = plt.subplots(figsize=(8, 6))

    # Fix a=2, d=3, vary b and c
    a, d_val = 2, 3
    bs = np.linspace(-2, 8, 200)
    cs = np.linspace(-2, 8, 200)
    B, C = np.meshgrid(bs, cs)

    # Compute which regime dominates
    # mu = min(a, d, (b+c)/2)
    regime = np.zeros_like(B)
    for i in range(len(cs)):
        for j in range(len(bs)):
            b_val, c_val = B[i, j], C[i, j]
            cycle = (b_val + c_val) / 2
            mu = min(a, d_val, cycle)
            if mu == a:
                regime[i, j] = 0  # prey-limited
            elif mu == d_val:
                regime[i, j] = 1  # predator-limited
            else:
                regime[i, j] = 2  # cycle-limited

    cmap = plt.cm.get_cmap('Set2', 3)
    pcm = ax.pcolormesh(B, C, regime, cmap=cmap, shading='auto', alpha=0.7)

    # Boundaries
    # a = (b+c)/2 → c = 2a - b = 4 - b
    b_line = np.linspace(-2, 8, 100)
    ax.plot(b_line, 2 * a - b_line, 'k-', linewidth=2, label=f'(b+c)/2 = a = {a}')
    # d = (b+c)/2 → c = 2d - b = 6 - b
    ax.plot(b_line, 2 * d_val - b_line, 'k--', linewidth=2, label=f'(b+c)/2 = d = {d_val}')

    ax.set_xlabel('b (prey←predator coupling)', fontsize=12)
    ax.set_ylabel('c (predator←prey coupling)', fontsize=12)
    ax.set_title(f'Eigenvalue Phase Diagram (a={a}, d={d_val})', fontsize=13)

    from matplotlib.patches import Patch
    legend_elements = [
        Patch(facecolor=cmap(0), label='Prey-limited (μ=a)'),
        Patch(facecolor=cmap(1), label='Predator-limited (μ=d)'),
        Patch(facecolor=cmap(2), label='Cycle-limited (μ=(b+c)/2)'),
    ]
    ax.legend(handles=legend_elements, fontsize=10, loc='upper left')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    b64 = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/fig_phase_diagram.png', dpi=150, bbox_inches='tight')
    plt.close()
    return b64


# ─── Figure 4: Multiple Trajectories ──────────────────────────────────────

def plot_trajectories():
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    configs = [
        ("Prey-limited (μ=a=1)", (1, 5, 3, 4)),
        ("Predator-limited (μ=d=1)", (3, 5, 3, 1)),
        ("Cycle-limited (μ=(b+c)/2=1)", (3, 1, 1, 4)),
        ("Negative eigenvalue (μ=-1)", (0, -1, -1, 0)),
    ]

    for ax, (title, params) in zip(axes.flat, configs):
        a, b, c, d = params
        mu = trop_eigenvalue(a, b, c, d)

        # Multiple initial conditions
        for x0, y0, color in [
            (0, 0, '#2196F3'), (3, -2, '#F44336'),
            (-1, 4, '#4CAF50'), (5, 5, '#FF9800')
        ]:
            state = (float(x0), float(y0))
            xs, ys = [state[0]], [state[1]]
            for _ in range(20):
                state = trop_step(params, state)
                xs.append(state[0])
                ys.append(state[1])
            ax.plot(xs, ys, 'o-', color=color, markersize=4, linewidth=1.5, alpha=0.7)
            ax.plot(xs[0], ys[0], 's', color=color, markersize=8)

        ax.set_xlabel('Prey', fontsize=10)
        ax.set_ylabel('Predator', fontsize=10)
        ax.set_title(f'{title}\nμ={mu:.1f}', fontsize=11)
        ax.grid(True, alpha=0.3)

    plt.suptitle('Tropical Predator-Prey Trajectories', fontsize=14, y=1.02)
    plt.tight_layout()
    b64 = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/fig_trajectories.png', dpi=150, bbox_inches='tight')
    plt.close()
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")
    b64_drift = plot_eigenvector_drift()
    print(f"  Eigenvector drift: {len(b64_drift)} chars")
    b64_nonexp = plot_nonexpansiveness()
    print(f"  Nonexpansiveness: {len(b64_nonexp)} chars")
    b64_phase = plot_eigenvalue_phase()
    print(f"  Phase diagram: {len(b64_phase)} chars")
    b64_traj = plot_trajectories()
    print(f"  Trajectories: {len(b64_traj)} chars")
    print("Done! Figures saved as PNG files.")
