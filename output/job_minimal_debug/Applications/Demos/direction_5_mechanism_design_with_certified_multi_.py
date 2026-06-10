#!/usr/bin/env python3
"""
Applications of Multi-Criteria Truthful Mechanisms.

Demonstrates real-world applications of the certified multi-criteria
truthful approximation framework:

1. Healthcare resource allocation under multiple fairness criteria
2. Public infrastructure procurement with cost/coverage tradeoffs
3. Network sensor placement with reliability + cost objectives
"""

import random
import math
from typing import List, Tuple, Set, Dict


# ──────────────────────────────────────────────────────────────
# Core mechanism (self-contained)
# ──────────────────────────────────────────────────────────────

def solve_fractional(n, edges, costs):
    x = [0.0] * n
    for _ in range(50):
        for edge in edges:
            cov = sum(x[v] for v in edge)
            if cov >= 1.0 - 1e-10:
                continue
            deficit = 1.0 - cov
            ic = [1.0 / max(costs[v], 1e-10) for v in edge]
            t = sum(ic)
            for j, v in enumerate(edge):
                x[v] = min(1.0, x[v] + deficit * ic[j] / t)
    return x


def threshold_round(x, tau):
    return {v for v in range(len(x)) if x[v] >= tau}


def is_transversal(edges, selected):
    return all(any(v in selected for v in e) for e in edges)


def critical_payment(n, edges, bids, tau, v):
    lo, hi = bids[v], max(bids) * 10 + 20.0
    for _ in range(25):
        mid = (lo + hi) / 2
        mb = bids[:]
        mb[v] = mid
        x = solve_fractional(n, edges, mb)
        if x[v] >= tau:
            lo = mid
        else:
            hi = mid
    return lo


# ──────────────────────────────────────────────────────────────
# Application 1: Healthcare Resource Allocation
# ──────────────────────────────────────────────────────────────

def healthcare_demo():
    """
    Scenario: A health authority must select hospitals to provide
    emergency coverage for geographic regions. Each hospital has
    a private operating cost. The authority cares about:
    - Total cost minimization
    - Population-weighted coverage (larger regions weighted more)
    - Rural equity (rural hospitals weighted more)
    - Pandemic readiness (hospitals with ICU capacity weighted more)
    """
    print("=" * 60)
    print("  APPLICATION 1: Healthcare Resource Allocation")
    print("=" * 60)
    print()

    hospitals = ["City General", "Suburban Med", "Rural Clinic",
                 "University Hosp", "Community Care", "Regional Center"]
    n = len(hospitals)

    # Regions each hospital can serve (hyperedges)
    regions = {
        "Downtown": [0, 1, 3],
        "Suburbs": [1, 4, 5],
        "Rural North": [2, 5],
        "University Dist": [0, 3],
        "Industrial": [1, 4],
    }
    edges = list(regions.values())
    rank = max(len(e) for e in edges)
    tau = 1.0 / rank

    # Private costs (millions)
    true_costs = [8.0, 5.0, 3.0, 12.0, 4.0, 6.0]

    # Objectives
    uniform = [1.0] * n  # Total cost
    population = [3.0, 2.0, 0.5, 2.5, 1.5, 1.0]  # Pop-weighted
    rural_equity = [0.5, 1.0, 3.0, 0.5, 1.0, 2.0]  # Rural bias
    pandemic = [2.0, 1.0, 0.5, 3.0, 0.5, 1.5]  # ICU capacity

    objectives = [uniform, population, rural_equity, pandemic]
    obj_names = ["Total Cost", "Population Coverage", "Rural Equity", "Pandemic Readiness"]

    # Run mechanism
    x = solve_fractional(n, edges, true_costs)
    selected = threshold_round(x, tau)

    payments = [0.0] * n
    for v in selected:
        payments[v] = critical_payment(n, edges, true_costs, tau, v)

    print(f"  Hospitals: {', '.join(hospitals)}")
    print(f"  Regions: {list(regions.keys())}")
    print(f"  Rank: {rank}, Threshold: {tau:.3f}")
    print()
    print(f"  Selected hospitals: {[hospitals[v] for v in sorted(selected)]}")
    print(f"  Coverage: {'ALL regions covered' if is_transversal(edges, selected) else 'INCOMPLETE'}")
    print()
    print(f"  Hospital | True Cost | Payment | Profit")
    print(f"  {'-'*50}")
    for v in range(n):
        if v in selected:
            profit = payments[v] - true_costs[v]
            print(f"  {hospitals[v]:18s} | ${true_costs[v]:6.1f}M  | ${payments[v]:6.1f}M | ${profit:+.1f}M")

    print()
    print(f"  Multi-criteria approximation ratios:")
    for name, w in zip(obj_names, objectives):
        ic = sum(w[v] for v in selected)
        fc = sum(w[v] * x[v] for v in range(n))
        ratio = ic / max(fc, 1e-10)
        print(f"    {name:25s}: {ratio:.3f} (guaranteed ≤ {rank})")
    print()


# ──────────────────────────────────────────────────────────────
# Application 2: Public Infrastructure Procurement
# ──────────────────────────────────────────────────────────────

def procurement_demo():
    """
    Scenario: A city procures contractors to cover infrastructure
    maintenance zones. Each contractor has private costs and serves
    a subset of zones. The city simultaneously cares about:
    - Total expenditure
    - Service quality (heavier weight on experienced contractors)
    - Environmental impact (green contractors weighted less)
    - Speed of deployment
    """
    print("=" * 60)
    print("  APPLICATION 2: Public Infrastructure Procurement")
    print("=" * 60)
    print()

    contractors = ["AlphaBuild", "BetaServ", "GammaCorp",
                   "DeltaEnv", "EpsilonFast"]
    n = len(contractors)

    zones = {
        "Zone A (roads)": [0, 1, 3],
        "Zone B (bridges)": [0, 2, 4],
        "Zone C (utilities)": [1, 3],
        "Zone D (parks)": [2, 3, 4],
    }
    edges = list(zones.values())
    rank = max(len(e) for e in edges)
    tau = 1.0 / rank

    costs = [10.0, 6.0, 8.0, 7.0, 5.0]

    objectives = [
        [1.0, 1.0, 1.0, 1.0, 1.0],         # expenditure
        [3.0, 1.0, 2.0, 1.5, 0.5],         # quality
        [2.0, 1.5, 1.0, 0.3, 1.0],         # env impact
        [1.0, 0.5, 0.8, 0.6, 3.0],         # speed
    ]
    obj_names = ["Expenditure", "Quality", "Env. Impact", "Speed"]

    x = solve_fractional(n, edges, costs)
    selected = threshold_round(x, tau)
    payments = [0.0] * n
    for v in selected:
        payments[v] = critical_payment(n, edges, costs, tau, v)

    print(f"  Contractors: {', '.join(contractors)}")
    print(f"  Selected: {[contractors[v] for v in sorted(selected)]}")
    print(f"  All zones covered: {is_transversal(edges, selected)}")
    print()
    for v in sorted(selected):
        print(f"  {contractors[v]:15s}: cost ${costs[v]:.0f}M, payment ${payments[v]:.1f}M")
    print()
    print(f"  Simultaneous approximation:")
    for name, w in zip(obj_names, objectives):
        ic = sum(w[v] for v in selected)
        fc = sum(w[v] * x[v] for v in range(n))
        ratio = ic / max(fc, 1e-10)
        print(f"    {name:15s}: {ratio:.3f} (≤ {rank})")
    print()


# ──────────────────────────────────────────────────────────────
# Application 3: Network Sensor Placement
# ──────────────────────────────────────────────────────────────

def sensor_demo():
    """
    Scenario: Deploy sensors to monitor network segments.
    Each sensor location has a deployment cost and covers certain
    network segments. Multiple objectives:
    - Deployment cost
    - Redundancy (overlap with other sensors)
    - Maintenance accessibility
    """
    print("=" * 60)
    print("  APPLICATION 3: Network Sensor Placement")
    print("=" * 60)
    print()

    locations = [f"Site {i}" for i in range(7)]
    n = len(locations)

    segments = [
        [0, 1, 2], [1, 3, 4], [2, 4, 5],
        [3, 5, 6], [0, 4, 6], [1, 5],
    ]
    rank = max(len(e) for e in segments)
    tau = 1.0 / rank

    costs = [3.0, 2.0, 4.0, 5.0, 1.5, 3.5, 2.5]

    rng = random.Random(99)
    objectives = [[rng.uniform(0.5, 3.0) for _ in range(n)] for _ in range(3)]
    obj_names = ["Deploy Cost", "Redundancy", "Accessibility"]

    x = solve_fractional(n, segments, costs)
    selected = threshold_round(x, tau)
    payments = [0.0] * n
    for v in selected:
        payments[v] = critical_payment(n, segments, costs, tau, v)

    print(f"  Locations: {n}, Segments: {len(segments)}, Rank: {rank}")
    print(f"  Selected: {sorted(selected)}")
    print(f"  Full coverage: {is_transversal(segments, selected)}")
    print()
    for name, w in zip(obj_names, objectives):
        ic = sum(w[v] for v in selected)
        fc = sum(w[v] * x[v] for v in range(n))
        ratio = ic / max(fc, 1e-10)
        print(f"    {name:15s}: ratio {ratio:.3f} (≤ {rank})")
    print()


if __name__ == "__main__":
    healthcare_demo()
    procurement_demo()
    sensor_demo()


#!/usr/bin/env python3
"""
Demo: Multi-Criteria Truthful Approximation Mechanisms for Hypergraph Covering.

This script:
1. Generates random hypergraph covering instances
2. Runs the threshold-rounded mechanism with critical payments
3. Tests 1000 random strategic deviations
4. Reports whether any profitable deviation was found
5. Displays approximation ratios for multiple scalarizations
"""

import random
import math
from typing import List, Tuple, Set, Dict


def generate_random_hypergraph(n_vertices: int, n_edges: int, max_rank: int,
                                seed: int = 42) -> Tuple[int, List[List[int]], int]:
    """Generate a random hypergraph."""
    rng = random.Random(seed)
    edges = []
    for _ in range(n_edges):
        size = rng.randint(2, max_rank)
        edge = sorted(rng.sample(range(n_vertices), min(size, n_vertices)))
        edges.append(edge)
    rank = max(len(e) for e in edges) if edges else 1
    return n_vertices, edges, rank


def solve_fractional_covering_simple(n: int, edges: List[List[int]],
                                      costs: List[float]) -> List[float]:
    """Simple iterative fractional covering solver.

    Each vertex gets value inversely proportional to its cost,
    scaled to cover every edge.
    """
    x = [0.0] * n
    for _ in range(50):
        for edge in edges:
            coverage = sum(x[v] for v in edge)
            if coverage >= 1.0 - 1e-10:
                continue
            deficit = 1.0 - coverage
            inv_costs = [1.0 / max(costs[v], 1e-10) for v in edge]
            total = sum(inv_costs)
            for j, v in enumerate(edge):
                x[v] = min(1.0, x[v] + deficit * inv_costs[j] / total)
    return x


def threshold_round(x: List[float], tau: float) -> Set[int]:
    """Threshold rounding: select v if x[v] >= tau."""
    return {v for v in range(len(x)) if x[v] >= tau}


def is_transversal(edges: List[List[int]], selected: Set[int]) -> bool:
    """Check if selected covers every edge."""
    return all(any(v in selected for v in edge) for edge in edges)


def compute_critical_payment(n: int, edges: List[List[int]], bids: List[float],
                              tau: float, v: int) -> float:
    """Compute critical payment for agent v via binary search.

    Find the highest bid at which v is still selected.
    """
    lo, hi = bids[v], max(bids) * 10 + 20.0
    for _ in range(25):
        mid = (lo + hi) / 2
        mod_bids = bids[:]
        mod_bids[v] = mid
        x = solve_fractional_covering_simple(n, edges, mod_bids)
        if x[v] >= tau:
            lo = mid
        else:
            hi = mid
    return lo


def run_demo():
    print("=" * 70)
    print("  MULTI-CRITERIA TRUTHFUL APPROXIMATION MECHANISM — DEMO")
    print("=" * 70)
    print()

    total_deviations = 0
    total_violations = 0
    all_ratios = []

    n_instances = 5
    obj_names = ["fairness", "efficiency", "equity", "welfare"]

    for inst_idx in range(n_instances):
        seed = 100 + inst_idx
        rng = random.Random(seed)

        n = rng.randint(5, 8)
        n_e = rng.randint(3, 6)
        max_r = min(rng.randint(2, 3), n)

        n, edges, rank = generate_random_hypergraph(n, n_e, max_r, seed=seed)
        tau = 1.0 / max(rank, 1)

        true_costs = [rng.uniform(0.5, 5.0) for _ in range(n)]
        objectives = [[rng.uniform(0, 1) for _ in range(n)] for _ in range(4)]

        print(f"--- Instance {inst_idx + 1} ---")
        print(f"  Vertices: {n}, Edges: {len(edges)}, Rank: {rank}, τ: {tau:.3f}")

        # Run mechanism
        x = solve_fractional_covering_simple(n, edges, true_costs)
        selected = threshold_round(x, tau)
        feasible = is_transversal(edges, selected)

        # Payments
        payments = [0.0] * n
        for v in selected:
            payments[v] = compute_critical_payment(n, edges, true_costs, tau, v)

        sel_list = sorted(selected)
        print(f"  Selected: {sel_list}")
        print(f"  Feasible: {feasible}")
        print(f"  Payments: {[round(p, 3) for p in payments]}")

        # Approximation ratios
        print(f"  Approximation ratios:")
        for name, w in zip(obj_names, objectives):
            int_cost = sum(w[v] for v in selected) if selected else 0
            frac_cost = sum(w[v] * x[v] for v in range(n))
            ratio = int_cost / max(frac_cost, 1e-10)
            all_ratios.append(ratio)
            status = f"≤ {rank}" if ratio <= rank + 0.01 else "*** EXCEEDS ***"
            print(f"    {name}: {ratio:.4f} ({status})")

        # Test truthfulness: ~200 deviations per instance
        instance_violations = 0
        n_tests = min(200, n * 40)
        for _ in range(n_tests):
            total_deviations += 1
            v = rng.randint(0, n - 1)

            # Truthful utility
            if v in selected:
                truth_util = payments[v] - true_costs[v]
            else:
                truth_util = 0.0

            # Deviated bid
            alt_bid = rng.uniform(0, true_costs[v] * 3 + 1.0)
            mod_bids = true_costs[:]
            mod_bids[v] = alt_bid

            x_dev = solve_fractional_covering_simple(n, edges, mod_bids)
            sel_dev = threshold_round(x_dev, tau)

            if v in sel_dev:
                pay_dev = compute_critical_payment(n, edges, mod_bids, tau, v)
                dev_util = pay_dev - true_costs[v]
            else:
                dev_util = 0.0

            if dev_util > truth_util + 1e-3:
                instance_violations += 1
                total_violations += 1

        print(f"  Truthfulness: {n_tests} deviations, {instance_violations} violations")
        print()

    # Summary
    print("=" * 70)
    print("  SUMMARY")
    print("=" * 70)
    print(f"  Total instances: {n_instances}")
    print(f"  Total deviations tested: {total_deviations}")
    print(f"  Total violations found: {total_violations}")
    status = "CONFIRMED (no violations)" if total_violations == 0 else f"VIOLATED ({total_violations})"
    print(f"  Truthfulness: {status}")
    print()
    if all_ratios:
        print(f"  Approximation ratios across all instances/objectives:")
        print(f"    Min:    {min(all_ratios):.4f}")
        print(f"    Max:    {max(all_ratios):.4f}")
        print(f"    Mean:   {sum(all_ratios)/len(all_ratios):.4f}")
        sorted_r = sorted(all_ratios)
        print(f"    Median: {sorted_r[len(sorted_r)//2]:.4f}")
    print()
    print("  CONJECTURE: Universal truthful simultaneous approximation")
    print(f"  for bounded-rank hypergraphs: {'SUPPORTED' if total_violations == 0 else 'REFUTED'}")
    print("=" * 70)


if __name__ == "__main__":
    run_demo()


#!/usr/bin/env python3
"""
Visualization: Multi-Criteria Truthful Mechanism Performance.

Produces three plots:
1. Approximation ratios across objectives and instances
2. Payment vs. true cost scatter (showing truthfulness margin)
3. Pareto frontier visualization for bi-objective case
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import random
import math


def solve_fractional(n, edges, costs):
    x = [0.0] * n
    for _ in range(50):
        for edge in edges:
            cov = sum(x[v] for v in edge)
            if cov >= 1.0 - 1e-10:
                continue
            deficit = 1.0 - cov
            ic = [1.0 / max(costs[v], 1e-10) for v in edge]
            t = sum(ic)
            for j, v in enumerate(edge):
                x[v] = min(1.0, x[v] + deficit * ic[j] / t)
    return x


def threshold_round(x, tau):
    return {v for v in range(len(x)) if x[v] >= tau}


def critical_payment(n, edges, bids, tau, v):
    lo, hi = bids[v], max(bids) * 10 + 20.0
    for _ in range(25):
        mid = (lo + hi) / 2
        mb = bids[:]
        mb[v] = mid
        x = solve_fractional(n, edges, mb)
        if x[v] >= tau:
            lo = mid
        else:
            hi = mid
    return lo


fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# ── Plot 1: Approximation ratios heatmap ──
rng = random.Random(42)
n_instances = 8
obj_names = ["Cost", "Fairness", "Equity", "Welfare"]
ratio_matrix = []

for i in range(n_instances):
    n = rng.randint(5, 8)
    n_e = rng.randint(3, 6)
    max_r = min(rng.randint(2, 3), n)
    edges = []
    for _ in range(n_e):
        sz = rng.randint(2, max_r)
        edges.append(sorted(rng.sample(range(n), min(sz, n))))
    rank = max(len(e) for e in edges)
    tau = 1.0 / rank
    costs = [rng.uniform(0.5, 5) for _ in range(n)]
    objs = [[rng.uniform(0, 1) for _ in range(n)] for _ in range(4)]

    x = solve_fractional(n, edges, costs)
    selected = threshold_round(x, tau)

    row = []
    for w in objs:
        ic = sum(w[v] for v in selected) if selected else 0
        fc = sum(w[v] * x[v] for v in range(n))
        row.append(ic / max(fc, 1e-10))
    ratio_matrix.append(row)

im = axes[0].imshow(ratio_matrix, aspect='auto', cmap='YlOrRd', vmin=0.5, vmax=3.0)
axes[0].set_xticks(range(4))
axes[0].set_xticklabels(obj_names, fontsize=9)
axes[0].set_ylabel("Instance", fontsize=11)
axes[0].set_title("Approximation Ratios\n(all ≤ rank bound)", fontsize=12, fontweight='bold')
plt.colorbar(im, ax=axes[0], label="Ratio")

# ── Plot 2: Payment vs true cost ──
all_costs = []
all_payments = []
n = 6
edges = [[0,1,2], [1,3,4], [2,4,5], [0,3,5]]
rank = 3
tau = 1.0 / rank

for trial in range(15):
    rng2 = random.Random(200 + trial)
    costs = [rng2.uniform(1, 8) for _ in range(n)]
    x = solve_fractional(n, edges, costs)
    selected = threshold_round(x, tau)
    for v in selected:
        p = critical_payment(n, edges, costs, tau, v)
        all_costs.append(costs[v])
        all_payments.append(p)

max_val = max(max(all_costs), max(all_payments)) * 1.1
axes[1].scatter(all_costs, all_payments, c='steelblue', alpha=0.7, s=50, edgecolors='navy')
axes[1].plot([0, max_val], [0, max_val], 'r--', alpha=0.5, label='Payment = Cost')
axes[1].set_xlabel("True Cost", fontsize=11)
axes[1].set_ylabel("Critical Payment", fontsize=11)
axes[1].set_title("Payment ≥ Cost\n(truthfulness margin)", fontsize=12, fontweight='bold')
axes[1].legend(fontsize=9)
axes[1].set_xlim(0, max_val)
axes[1].set_ylim(0, max_val)

# ── Plot 3: Bi-objective Pareto frontier ──
n = 5
edges = [[0,1], [1,2,3], [2,4], [0,3,4]]
rank = 3
tau = 1.0 / rank
w1 = [1.0, 0.5, 2.0, 1.5, 0.8]
w2 = [0.5, 2.0, 0.8, 1.0, 1.5]

# Generate many feasible solutions by varying costs
pareto_x = []
pareto_y = []
mech_x = []
mech_y = []

for trial in range(40):
    rng3 = random.Random(300 + trial)
    costs = [rng3.uniform(0.5, 5) for _ in range(n)]
    x = solve_fractional(n, edges, costs)
    sel = threshold_round(x, tau)
    c1 = sum(w1[v] for v in sel)
    c2 = sum(w2[v] for v in sel)
    pareto_x.append(c1)
    pareto_y.append(c2)

# Mechanism output (single canonical)
costs = [2.0, 1.5, 3.0, 2.5, 1.0]
x = solve_fractional(n, edges, costs)
sel = threshold_round(x, tau)
mc1 = sum(w1[v] for v in sel)
mc2 = sum(w2[v] for v in sel)

# Fractional optimum
fc1 = sum(w1[v] * x[v] for v in range(n))
fc2 = sum(w2[v] * x[v] for v in range(n))

axes[2].scatter(pareto_x, pareto_y, c='lightgray', alpha=0.6, s=30, label='Feasible solutions')
axes[2].scatter([mc1], [mc2], c='red', s=150, zorder=5, marker='*', label='Mechanism output')
axes[2].scatter([fc1], [fc2], c='green', s=100, zorder=5, marker='D', label='LP relaxation')

# Draw approximation region
axes[2].axhline(y=mc2 / rank, color='orange', linestyle=':', alpha=0.5)
axes[2].axvline(x=mc1 / rank, color='orange', linestyle=':', alpha=0.5, label=f'1/{rank} · mechanism cost')

axes[2].set_xlabel("Objective 1 (cost)", fontsize=11)
axes[2].set_ylabel("Objective 2 (cost)", fontsize=11)
axes[2].set_title("Bi-Objective Space\n(Pareto certification)", fontsize=12, fontweight='bold')
axes[2].legend(fontsize=8, loc='upper right')

plt.tight_layout()
plt.savefig('/workspace/request-project/mechanism_visualization.png', dpi=150, bbox_inches='tight')
print("Saved: mechanism_visualization.png")
