#!/usr/bin/env python3
"""
Applications of Certified Intervention Sequencing

Real-world scenarios demonstrating the multi-objective bottleneck framework:
1. Infrastructure network upgrade planning
2. Cloud computing resource optimization
3. Supply chain resilience analysis
4. Hospital capacity planning
"""

from algorithms import BottleneckSystem, WeightedBottleneckSystem


def infrastructure_planning():
    """
    Municipal infrastructure upgrade planning.

    A city has aging infrastructure across water, power, and transport.
    Three objectives: public safety, service reliability, environmental impact.
    """
    print("=" * 70)
    print("APPLICATION 1: Municipal Infrastructure Upgrade Planning")
    print("=" * 70)

    system = WeightedBottleneckSystem(
        bottlenecks={
            'Safety': {
                'water_main_5th_st', 'bridge_hwy101',
                'gas_line_downtown', 'fire_station_eq'
            },
            'Reliability': {
                'power_substation_N', 'water_main_5th_st',
                'telecom_tower_3', 'backup_generator_city_hall'
            },
            'Environment': {
                'wastewater_plant', 'water_main_5th_st',
                'stormwater_basin_E', 'solar_array_south'
            },
        },
        weights={
            'water_main_5th_st': 2.5,      # $2.5M
            'bridge_hwy101': 15.0,          # $15M
            'gas_line_downtown': 4.0,       # $4M
            'fire_station_eq': 1.2,         # $1.2M
            'power_substation_N': 8.0,      # $8M
            'telecom_tower_3': 3.0,         # $3M
            'backup_generator_city_hall': 0.5,  # $0.5M
            'wastewater_plant': 12.0,       # $12M
            'stormwater_basin_E': 6.0,      # $6M
            'solar_array_south': 4.5,       # $4.5M
        }
    )

    print("\nObjective bottleneck components:")
    for obj in system.objectives:
        print(f"  {obj}: {sorted(system.bottlenecks[obj])}")

    keystones = system.find_keystones()
    print(f"\nKeystone components: {sorted(keystones)}")
    if keystones:
        k = next(iter(keystones))
        print(f"  → Upgrading '{k}' alone improves ALL three objectives!")
        print(f"  → Cost: ${system.weights[k]}M")

    print("\nAll Pareto-optimal upgrade plans (by cost):")
    for plan, cost in system.min_cost_pareto_plans():
        print(f"  {sorted(plan)}: ${cost}M")

    print(f"\n  RECOMMENDATION: The keystone upgrade '{next(iter(keystones))}' at "
          f"${system.weights[next(iter(keystones))]}M is the most cost-effective\n"
          f"  single intervention, certified to improve safety, reliability, AND\n"
          f"  environmental impact simultaneously.")


def cloud_optimization():
    """
    Cloud computing resource optimization.

    A SaaS company must improve three metrics: API latency,
    data throughput, and system uptime. Each has bottleneck components.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Cloud Computing Resource Optimization")
    print("=" * 70)

    system = BottleneckSystem({
        'API_Latency': {
            'load_balancer', 'cache_layer', 'db_read_replica',
            'cdn_edge_node'
        },
        'Data_Throughput': {
            'db_write_primary', 'message_queue', 'storage_tier',
            'network_backbone'
        },
        'System_Uptime': {
            'health_checker', 'auto_scaler', 'failover_dns',
            'db_read_replica'
        },
    })

    print(f"\nSystem has {len(system.components)} components across "
          f"{len(system.objectives)} objectives")

    analysis = system.analyze()
    print(f"Keystones: {sorted(analysis['keystones']) or 'None'}")

    is_disj, overlaps = system.check_pairwise_disjoint()
    if overlaps:
        print(f"Shared bottlenecks:")
        for a, b, shared in overlaps:
            print(f"  {a} ∩ {b}: {sorted(shared)}")

    print(f"\nPareto-optimal upgrade plans ({analysis['num_pareto_plans']} options):")
    for plan in sorted(analysis['pareto_frontier'],
                       key=lambda x: (len(x), sorted(x))):
        print(f"  {sorted(plan)} (size {len(plan)})")

    print(f"\n  INSIGHT: The shared component 'db_read_replica' affects both\n"
          f"  latency and uptime, but no single component affects all three.\n"
          f"  Minimum upgrade package requires {analysis['min_plan_size']} components.")


def supply_chain():
    """
    Supply chain resilience analysis.

    A manufacturer has three supply chain objectives with completely
    separate bottlenecks — demonstrating the impossibility certificate.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Supply Chain Resilience — Impossibility Certificate")
    print("=" * 70)

    system = BottleneckSystem({
        'Production_Speed': {
            'supplier_chips_A', 'supplier_chips_B'
        },
        'Quality_Control': {
            'test_equipment_X', 'inspection_lab_Y'
        },
        'Logistics_Cost': {
            'shipping_route_1', 'warehouse_expansion'
        },
    })

    analysis = system.analyze()

    print(f"\nBottleneck sets:")
    for obj in system.objectives:
        print(f"  {obj}: {sorted(system.bottlenecks[obj])}")

    print(f"\nPairwise disjoint: {analysis['is_disjoint']}")
    print(f"Number of objectives: {len(system.objectives)}")
    print(f"\n  CERTIFIED IMPOSSIBILITY: No single supplier change, equipment\n"
          f"  upgrade, or logistics adjustment can improve ALL three metrics.\n"
          f"  Any feasible improvement plan requires at least "
          f"{analysis['lower_bound']} separate actions.")

    print(f"\nMinimal improvement plans ({analysis['num_pareto_plans']} options):")
    for plan in sorted(analysis['pareto_frontier'],
                       key=lambda x: (len(x), sorted(x))):
        print(f"  {sorted(plan)}")


def hospital_planning():
    """
    Hospital capacity planning.

    A hospital must improve ER wait times, surgical throughput,
    and patient satisfaction. Some bottlenecks overlap.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Hospital Capacity Planning")
    print("=" * 70)

    system = WeightedBottleneckSystem(
        bottlenecks={
            'ER_Wait_Time': {
                'triage_nurses', 'er_beds', 'lab_turnaround', 'admit_process'
            },
            'Surgical_Throughput': {
                'or_scheduling', 'anesthesia_staff', 'sterilization',
                'lab_turnaround'
            },
            'Patient_Satisfaction': {
                'nurse_ratio', 'discharge_process', 'lab_turnaround',
                'food_service'
            },
        },
        weights={
            'triage_nurses': 200,       # $200K/year
            'er_beds': 500,             # $500K capital
            'lab_turnaround': 150,      # $150K for new equipment
            'admit_process': 50,        # $50K process redesign
            'or_scheduling': 80,        # $80K software
            'anesthesia_staff': 300,    # $300K/year
            'sterilization': 120,       # $120K equipment
            'nurse_ratio': 400,         # $400K/year
            'discharge_process': 30,    # $30K process redesign
            'food_service': 100,        # $100K contract
        }
    )

    analysis = system.analyze()

    print(f"\nKeystone bottleneck: {sorted(analysis['keystones'])}")
    if analysis['keystones']:
        k = next(iter(analysis['keystones']))
        print(f"  → Upgrading '{k}' improves ER wait, surgery, AND satisfaction!")
        print(f"  → Cost: ${system.weights[k]}K")

    print(f"\nAll Pareto-optimal plans by cost:")
    for plan, cost in system.min_cost_pareto_plans()[:5]:
        print(f"  {sorted(plan)}: ${cost}K")

    print(f"\n  RECOMMENDATION: Investing ${system.weights[next(iter(analysis['keystones']))]}K\n"
          f"  in '{next(iter(analysis['keystones']))}' is the single most impactful\n"
          f"  upgrade, certified to improve all three patient care metrics.")


if __name__ == "__main__":
    infrastructure_planning()
    cloud_optimization()
    supply_chain()
    hospital_planning()

    print("\n" + "=" * 70)
    print("ALL APPLICATIONS COMPLETE")
    print("=" * 70)


#!/usr/bin/env python3
"""
Demo: Certified Intervention Sequencing for Multi-Objective Systems

Concrete numerical examples demonstrating the main theorems:
1. Keystone detection (common intersection)
2. Hitting set enumeration (Pareto-optimal plans)
3. Disjointness lower bound (impossibility certificate)
4. Weighted/monotone capacity extension
"""

from itertools import combinations


def gain(B: dict, i, S: set) -> int:
    """Binary gain: objective i improves iff S intersects B[i]."""
    return 1 if S & B[i] else 0


def improves_all(B: dict, S: set) -> bool:
    """Check if plan S improves all objectives."""
    return all(gain(B, i, S) == 1 for i in B)


def is_hitting_set(B: dict, S: set) -> bool:
    """Check if S is a hitting set (intersects every B[i])."""
    return all(S & B[i] for i in B)


def find_keystone(B: dict) -> set:
    """Find keystone elements: common intersection of all bottleneck sets."""
    if not B:
        return set()
    common = set.intersection(*B.values())
    return common


def minimal_hitting_sets(B: dict, universe: set) -> list:
    """Enumerate all minimal hitting sets by brute force."""
    results = []
    for size in range(1, len(universe) + 1):
        for S in combinations(universe, size):
            S_set = set(S)
            if is_hitting_set(B, S_set):
                # Check minimality: no proper subset is a hitting set
                is_minimal = True
                for elem in S:
                    if is_hitting_set(B, S_set - {elem}):
                        is_minimal = False
                        break
                if is_minimal:
                    results.append(S_set)
    return results


def are_pairwise_disjoint(B: dict) -> bool:
    """Check if bottleneck sets are pairwise disjoint."""
    keys = list(B.keys())
    for i in range(len(keys)):
        for j in range(i + 1, len(keys)):
            if B[keys[i]] & B[keys[j]]:
                return False
    return True


# =============================================================================
# EXAMPLE 1: Water Network with Keystone Component
# =============================================================================
print("=" * 70)
print("EXAMPLE 1: Water Network — Keystone Component")
print("=" * 70)

components = {'J3', 'P1', 'M7', 'T2', 'F4', 'R1', 'W2'}
B_water = {
    'Pressure':      {'J3', 'P1', 'M7'},
    'Contamination': {'T2', 'J3', 'F4'},
    'Drought':       {'R1', 'J3', 'W2'},
}

print(f"\nComponents: {sorted(components)}")
for obj, bset in B_water.items():
    print(f"  Bottleneck({obj}): {sorted(bset)}")

keystones = find_keystone(B_water)
print(f"\nKeystone elements (common intersection): {sorted(keystones)}")

# Verify Theorem 1: singleton keystone improves all
for k in keystones:
    gains = {obj: gain(B_water, obj, {k}) for obj in B_water}
    print(f"  Singleton {{{k}}}: gains = {gains}")
    assert all(g == 1 for g in gains.values()), "Theorem 1 violated!"

print("\n✓ Theorem verified: keystone singleton improves ALL objectives")

# Enumerate all Pareto-optimal plans (= minimal hitting sets)
mhs = minimal_hitting_sets(B_water, components)
print(f"\nAll Pareto-optimal plans ({len(mhs)} total):")
for s in sorted(mhs, key=lambda x: (len(x), sorted(x))):
    print(f"  {sorted(s)} (size {len(s)})")

# =============================================================================
# EXAMPLE 2: Disjoint Bottlenecks — Impossibility Certificate
# =============================================================================
print("\n" + "=" * 70)
print("EXAMPLE 2: Disjoint Bottlenecks — Impossibility Certificate")
print("=" * 70)

B_disjoint = {
    'Throughput':  {'server_A', 'server_B'},
    'Latency':     {'cache_X', 'cache_Y'},
    'Reliability': {'backup_P', 'backup_Q'},
}

print(f"\nBottleneck sets:")
for obj, bset in B_disjoint.items():
    print(f"  Bottleneck({obj}): {sorted(bset)}")

disjoint = are_pairwise_disjoint(B_disjoint)
print(f"\nPairwise disjoint: {disjoint}")
print(f"Number of objectives: {len(B_disjoint)}")
print(f"Lower bound on plan size (Theorem 4): {len(B_disjoint)}")

# Verify: no singleton improves all
universe_disj = set().union(*B_disjoint.values())
for a in sorted(universe_disj):
    if improves_all(B_disjoint, {a}):
        print(f"  VIOLATION: singleton {{{a}}} improves all!")
        break
else:
    print("\n✓ Theorem verified: NO singleton improves all objectives")

# Verify all hitting sets have size >= k
mhs_disj = minimal_hitting_sets(B_disjoint, universe_disj)
print(f"\nMinimal hitting sets ({len(mhs_disj)} total):")
for s in sorted(mhs_disj, key=lambda x: (len(x), sorted(x))):
    print(f"  {sorted(s)} (size {len(s)})")
    assert len(s) >= len(B_disjoint), "Lower bound violated!"
print(f"\n✓ Theorem verified: all hitting sets have size ≥ {len(B_disjoint)}")

# =============================================================================
# EXAMPLE 3: Weighted/Monotone Capacity Model
# =============================================================================
print("\n" + "=" * 70)
print("EXAMPLE 3: Weighted Capacity Model — Critical Elements")
print("=" * 70)

# Capacity functions: c_i(S) = weighted count of relevant components
def capacity_throughput(S):
    return 10 * len(S & {'gpu_1', 'gpu_2', 'cpu_1'}) + 2 * len(S & {'mem_1'})

def capacity_latency(S):
    return 5 * len(S & {'cache_1', 'gpu_1'}) + 3 * len(S & {'net_1'})

def capacity_reliability(S):
    return 8 * len(S & {'backup_1', 'gpu_1'}) + 4 * len(S & {'ups_1'})

capacities = {
    'Throughput':  capacity_throughput,
    'Latency':     capacity_latency,
    'Reliability': capacity_reliability,
}

S0 = {'cpu_1', 'mem_1'}  # Baseline plan
print(f"\nBaseline plan S₀ = {sorted(S0)}")
print(f"Baseline capacities:")
for obj, cfn in capacities.items():
    print(f"  {obj}: {cfn(S0)}")

# Find critical elements at baseline S0
all_components = {'gpu_1', 'gpu_2', 'cpu_1', 'mem_1', 'cache_1', 'net_1', 'backup_1', 'ups_1'}
critical_sets = {}
for obj, cfn in capacities.items():
    crit = set()
    for a in all_components - S0:
        if cfn(S0 | {a}) > cfn(S0):
            crit.add(a)
    critical_sets[obj] = crit

print(f"\nCritical sets at baseline S₀:")
for obj, crit in critical_sets.items():
    print(f"  Critical({obj}): {sorted(crit)}")

common_critical = find_keystone(critical_sets)
print(f"\nCommon critical elements: {sorted(common_critical)}")

if common_critical:
    a = next(iter(common_critical))
    print(f"\nUpgrading common critical element '{a}':")
    for obj, cfn in capacities.items():
        before = cfn(S0)
        after = cfn(S0 | {a})
        print(f"  {obj}: {before} → {after} (Δ = +{after - before})")
        assert after > before, "Theorem 6 violated!"
    print(f"\n✓ Theorem verified: common critical element gives strict Pareto improvement")

# =============================================================================
# EXAMPLE 4: Pareto–Transversal Equivalence Verification
# =============================================================================
print("\n" + "=" * 70)
print("EXAMPLE 4: Pareto–Transversal Equivalence (Theorem 3)")
print("=" * 70)

B_mixed = {
    'Speed':    {'a', 'b', 'c'},
    'Quality':  {'b', 'd', 'e'},
    'Cost':     {'c', 'e', 'f'},
}
universe_mixed = {'a', 'b', 'c', 'd', 'e', 'f'}

print(f"\nBottleneck sets:")
for obj, bset in B_mixed.items():
    print(f"  Bottleneck({obj}): {sorted(bset)}")

mhs_mixed = minimal_hitting_sets(B_mixed, universe_mixed)
print(f"\nMinimal hitting sets = Pareto-optimal plans ({len(mhs_mixed)} total):")
for s in sorted(mhs_mixed, key=lambda x: (len(x), sorted(x))):
    # Verify: each element is essential
    essential = []
    for elem in s:
        if not is_hitting_set(B_mixed, s - {elem}):
            essential.append(elem)
    print(f"  {sorted(s)} — essential elements: {sorted(essential)}")
    assert len(essential) == len(s), "Non-minimal set found!"

print(f"\n✓ Verified: every element in every Pareto-optimal plan is essential")
print(f"  (removing any component would fail at least one objective)")

print("\n" + "=" * 70)
print("ALL DEMONSTRATIONS COMPLETE — ALL THEOREMS VERIFIED")
print("=" * 70)


#!/usr/bin/env python3
"""
Visualizations for Certified Intervention Sequencing

Generates publication-quality figures illustrating the main theorems.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch
import numpy as np
from itertools import combinations
import base64
import io
import json


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def plot_venn_bottlenecks():
    """
    Figure 1: Bottleneck sets as a Venn diagram showing keystone element.
    """
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Overlapping (keystone exists)
    colors = ['#FF6B6B', '#4ECDC4', '#45B7D1']
    labels = ['Pressure', 'Contamination', 'Drought']

    circle1 = plt.Circle((-0.3, 0.3), 1.0, alpha=0.25, color=colors[0])
    circle2 = plt.Circle((0.3, 0.3), 1.0, alpha=0.25, color=colors[1])
    circle3 = plt.Circle((0.0, -0.3), 1.0, alpha=0.25, color=colors[2])

    for c in [circle1, circle2, circle3]:
        ax1.add_patch(c)

    ax1.plot(0.0, 0.1, 'k*', markersize=20, zorder=5)
    ax1.annotate('Keystone\n(J3)', (0.0, 0.1), (0.6, -0.8),
                fontsize=11, fontweight='bold', ha='center',
                arrowprops=dict(arrowstyle='->', color='black', lw=1.5))

    ax1.text(-0.9, 0.9, 'P1, M7', fontsize=9, ha='center', color=colors[0])
    ax1.text(0.9, 0.9, 'T2, F4', fontsize=9, ha='center', color=colors[1])
    ax1.text(0.0, -1.0, 'R1, W2', fontsize=9, ha='center', color=colors[2])

    patches = [mpatches.Patch(color=c, alpha=0.4, label=l)
               for c, l in zip(colors, labels)]
    ax1.legend(handles=patches, loc='upper left', fontsize=9)
    ax1.set_xlim(-2, 2)
    ax1.set_ylim(-2, 2)
    ax1.set_aspect('equal')
    ax1.set_title('Common Intersection → Keystone\n(Theorem 2: Universal Singleton)',
                  fontsize=12, fontweight='bold')
    ax1.axis('off')

    # Right: Disjoint (no keystone)
    circle4 = plt.Circle((-1.2, 0), 0.7, alpha=0.3, color=colors[0])
    circle5 = plt.Circle((0.0, 0), 0.7, alpha=0.3, color=colors[1])
    circle6 = plt.Circle((1.2, 0), 0.7, alpha=0.3, color=colors[2])

    for c in [circle4, circle5, circle6]:
        ax2.add_patch(c)

    ax2.text(-1.2, 0, 'A1, A2', fontsize=9, ha='center')
    ax2.text(0.0, 0, 'B1, B2', fontsize=9, ha='center')
    ax2.text(1.2, 0, 'C1, C2', fontsize=9, ha='center')

    labels2 = ['Throughput', 'Latency', 'Reliability']
    patches2 = [mpatches.Patch(color=c, alpha=0.4, label=l)
                for c, l in zip(colors, labels2)]
    ax2.legend(handles=patches2, loc='upper left', fontsize=9)
    ax2.set_xlim(-2.5, 2.5)
    ax2.set_ylim(-1.5, 1.5)
    ax2.set_aspect('equal')
    ax2.set_title('Pairwise Disjoint → No Universal Singleton\n(Theorem 5: Impossibility)',
                  fontsize=12, fontweight='bold')
    ax2.axis('off')

    fig.suptitle('Bottleneck Set Geometry: Keystone vs. Disjointness',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig


def plot_pareto_frontier():
    """
    Figure 2: Pareto frontier visualization for 2-objective system.
    """
    fig, ax = plt.subplots(figsize=(8, 6))

    # Generate all subsets of {a,b,c,d,e} and compute scores
    B = {0: {'a', 'b', 'c'}, 1: {'c', 'd', 'e'}}
    components = ['a', 'b', 'c', 'd', 'e']

    plans = []
    for size in range(1, len(components) + 1):
        for combo in combinations(components, size):
            S = set(combo)
            g0 = 1 if S & B[0] else 0
            g1 = 1 if S & B[1] else 0
            plans.append((S, g0, g1, len(S)))

    # Categorize
    infeasible = [(s, g0, g1, sz) for s, g0, g1, sz in plans if g0 + g1 < 2]
    feasible = [(s, g0, g1, sz) for s, g0, g1, sz in plans if g0 + g1 == 2]

    # Find minimal hitting sets
    def is_minimal(S):
        for elem in S:
            sub = S - {elem}
            if (sub & B[0]) and (sub & B[1]):
                return False
        return True

    minimal = [(s, g0, g1, sz) for s, g0, g1, sz in feasible if is_minimal(s)]
    non_minimal = [(s, g0, g1, sz) for s, g0, g1, sz in feasible if not is_minimal(s)]

    # Plot with jitter for visibility
    np.random.seed(42)

    for i, (s, g0, g1, sz) in enumerate(infeasible):
        jx = np.random.uniform(-0.15, 0.15)
        jy = np.random.uniform(-0.15, 0.15)
        ax.scatter(g0 + jx, g1 + jy, c='lightgray', s=40, alpha=0.5, zorder=2)

    for i, (s, g0, g1, sz) in enumerate(non_minimal):
        jx = np.random.uniform(-0.08, 0.08)
        jy = np.random.uniform(-0.08, 0.08)
        ax.scatter(g0 + jx, g1 + jy, c='steelblue', s=80, alpha=0.6,
                  edgecolors='navy', zorder=3)

    for i, (s, g0, g1, sz) in enumerate(minimal):
        jx = np.random.uniform(-0.05, 0.05)
        jy = np.random.uniform(-0.05, 0.05)
        ax.scatter(g0 + jx, g1 + jy, c='gold', s=150, marker='*',
                  edgecolors='darkorange', linewidth=1, zorder=4)
        ax.annotate(f'{sorted(s)}', (g0 + jx, g1 + jy + 0.08),
                   fontsize=7, ha='center', rotation=15)

    ax.scatter([], [], c='lightgray', s=40, label='Infeasible (misses ≥1 objective)')
    ax.scatter([], [], c='steelblue', s=80, edgecolors='navy',
              label='Feasible but non-minimal')
    ax.scatter([], [], c='gold', s=150, marker='*', edgecolors='darkorange',
              label='Pareto-optimal (minimal hitting set)')

    ax.set_xlabel('Gain for Objective 1', fontsize=12)
    ax.set_ylabel('Gain for Objective 2', fontsize=12)
    ax.set_title('Pareto Frontier = Minimal Transversals\n'
                 'B₁ = {a,b,c}, B₂ = {c,d,e}',
                 fontsize=13, fontweight='bold')
    ax.legend(loc='upper left', fontsize=9)
    ax.set_xlim(-0.3, 1.5)
    ax.set_ylim(-0.3, 1.5)
    ax.axhline(y=0.5, color='gray', linestyle=':', alpha=0.3)
    ax.axvline(x=0.5, color='gray', linestyle=':', alpha=0.3)
    plt.tight_layout()
    return fig


def plot_plan_size_distribution():
    """
    Figure 3: How plan size lower bound varies with disjointness.
    """
    fig, ax = plt.subplots(figsize=(8, 5))

    np.random.seed(123)
    n_components = 20
    n_objectives_range = range(2, 9)
    bottleneck_sizes = [3, 5, 8]

    for bsize in bottleneck_sizes:
        avg_min_sizes = []
        for k in n_objectives_range:
            min_sizes = []
            for trial in range(200):
                # Random bottleneck sets
                B = {}
                for i in range(k):
                    B[i] = set(np.random.choice(n_components, bsize, replace=False))

                # Find a hitting set greedily
                covered = set()
                plan = set()
                remaining = list(range(k))
                while remaining:
                    # Pick element covering most uncovered objectives
                    best_elem = None
                    best_count = 0
                    for e in range(n_components):
                        count = sum(1 for i in remaining if e in B[i])
                        if count > best_count:
                            best_count = count
                            best_elem = e
                    if best_elem is not None:
                        plan.add(best_elem)
                        remaining = [i for i in remaining if best_elem not in B[i]]
                min_sizes.append(len(plan))
            avg_min_sizes.append(np.mean(min_sizes))

        ax.plot(list(n_objectives_range), avg_min_sizes,
                'o-', linewidth=2, markersize=6,
                label=f'|B(i)| = {bsize}')

    # Theoretical lower bound for disjoint case
    ax.plot(list(n_objectives_range), list(n_objectives_range),
            'k--', linewidth=2, alpha=0.5, label='Lower bound (disjoint)')

    ax.set_xlabel('Number of Objectives (k)', fontsize=12)
    ax.set_ylabel('Average Minimum Plan Size', fontsize=12)
    ax.set_title('Plan Size vs. Number of Objectives\n'
                 f'(n = {n_components} components, random bottleneck sets)',
                 fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    return fig


def plot_keystone_probability():
    """
    Figure 4: Probability of keystone existence vs. bottleneck size.
    """
    fig, ax = plt.subplots(figsize=(8, 5))

    np.random.seed(456)
    n_components = 30
    n_trials = 2000
    k_values = [2, 3, 5, 8]
    bsize_range = range(1, 16)

    for k in k_values:
        probs = []
        for bsize in bsize_range:
            count = 0
            for _ in range(n_trials):
                sets = [set(np.random.choice(n_components, min(bsize, n_components),
                           replace=False)) for _ in range(k)]
                common = sets[0]
                for s in sets[1:]:
                    common = common & s
                if common:
                    count += 1
            probs.append(count / n_trials)
        ax.plot(list(bsize_range), probs, 'o-', linewidth=2,
                markersize=5, label=f'k = {k} objectives')

    ax.set_xlabel('Bottleneck Set Size |B(i)|', fontsize=12)
    ax.set_ylabel('Probability of Keystone Existence', fontsize=12)
    ax.set_title(f'Keystone Probability vs. Bottleneck Coverage\n'
                 f'(n = {n_components} components)',
                 fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-0.05, 1.05)
    plt.tight_layout()
    return fig


if __name__ == "__main__":
    print("Generating visualizations...")

    fig1 = plot_venn_bottlenecks()
    fig1.savefig('fig_venn_bottlenecks.png', dpi=150, bbox_inches='tight')
    print("  Saved fig_venn_bottlenecks.png")

    fig2 = plot_pareto_frontier()
    fig2.savefig('fig_pareto_frontier.png', dpi=150, bbox_inches='tight')
    print("  Saved fig_pareto_frontier.png")

    fig3 = plot_plan_size_distribution()
    fig3.savefig('fig_plan_size.png', dpi=150, bbox_inches='tight')
    print("  Saved fig_plan_size.png")

    fig4 = plot_keystone_probability()
    fig4.savefig('fig_keystone_prob.png', dpi=150, bbox_inches='tight')
    print("  Saved fig_keystone_prob.png")

    print("All visualizations generated.")
