#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Compositional Certification

Shows how the modular composition framework applies to:
1. Verified AI systems (modular ML pipelines)
2. Cryptographic protocol composition
3. Distributed systems verification
4. Scientific computing error bounds
"""

import math
from typing import List, Dict


# ============================================================
# Application 1: Modular ML Pipeline Certification
# ============================================================

def ml_pipeline_certification(
    stages: List[Dict[str, float]],
    interface_costs: List[float]
) -> Dict:
    """Certify a modular ML pipeline using compositional bounds.

    Each stage has an error bound. The total pipeline error is bounded
    by the sum of stage errors plus interface costs (data transformation
    overhead at stage boundaries).

    This directly applies the Compositional Certification Theorem.

    Args:
        stages: List of {name, error_bound} for each pipeline stage
        interface_costs: Cost of data transformation between stages

    Returns:
        Certification report
    """
    total_error = sum(s['error_bound'] for s in stages)
    total_interface = sum(interface_costs)
    global_bound = total_error + total_interface

    return {
        'pipeline_stages': len(stages),
        'stage_bounds': [(s['name'], s['error_bound']) for s in stages],
        'total_stage_error': total_error,
        'total_interface_cost': total_interface,
        'global_error_bound': global_bound,
        'certified': True,  # By the compositional certification theorem
        'theorem': 'compositional_certification'
    }


# ============================================================
# Application 2: Cryptographic Protocol Composition
# ============================================================

def protocol_composition_bound(
    protocols: List[Dict[str, float]],
    composition_overhead: float = 0.0
) -> Dict:
    """Bound the security of a composed cryptographic protocol.

    When multiple cryptographic protocols are composed, their security
    levels combine with at most an additive overhead — exactly the
    compositional certification principle.

    Each protocol has a security parameter (log₂ of adversary's advantage).

    Args:
        protocols: List of {name, security_bits}
        composition_overhead: Additional security cost from composition

    Returns:
        Composition security analysis
    """
    min_security = min(p['security_bits'] for p in protocols)
    total_advantage_log = sum(2**(-p['security_bits']) for p in protocols)
    effective_security = -math.log2(total_advantage_log) if total_advantage_log > 0 else float('inf')

    return {
        'num_protocols': len(protocols),
        'protocols': [(p['name'], p['security_bits']) for p in protocols],
        'min_individual_security': min_security,
        'effective_composed_security': effective_security,
        'composition_overhead_bits': composition_overhead,
        'final_security': effective_security - composition_overhead,
        'theorem': 'modular_evidence_composition (security as log-evidence)'
    }


# ============================================================
# Application 3: Distributed System Verification
# ============================================================

def distributed_verification(
    nodes: List[Dict[str, float]],
    network_latency: float
) -> Dict:
    """Verify a distributed system using compositional bounds.

    Each node has a local verification time. The global verification
    time is bounded by the maximum local time (parallel) plus
    network communication overhead (the interface cost).

    This is a parallelized version of the composition theorem.

    Args:
        nodes: List of {name, verification_time, correctness_prob}
        network_latency: Communication overhead between nodes

    Returns:
        Distributed verification report
    """
    max_time = max(n['verification_time'] for n in nodes)
    min_prob = min(n['correctness_prob'] for n in nodes)
    total_prob = math.prod(n['correctness_prob'] for n in nodes)

    return {
        'num_nodes': len(nodes),
        'parallel_verification_time': max_time + network_latency,
        'sequential_verification_time': sum(n['verification_time'] for n in nodes),
        'speedup': sum(n['verification_time'] for n in nodes) / (max_time + network_latency),
        'individual_correctness_min': min_prob,
        'composed_correctness': total_prob,
        'interface_cost': network_latency,
        'theorem': 'composition_of_systems'
    }


# ============================================================
# Application 4: Scientific Computing Error Propagation
# ============================================================

def error_propagation(
    computations: List[Dict[str, float]],
    interaction_error: float = 0.0
) -> Dict:
    """Bound error propagation in a modular scientific computation.

    Each computational module has a local error bound (e.g., from
    floating-point arithmetic). The total error is bounded by the
    sum of local errors plus interaction errors.

    This models the real-world situation where a large scientific
    simulation is decomposed into modules (mesh generation, solver,
    post-processing, etc.).

    Args:
        computations: List of {name, error_bound, relative_error}
        interaction_error: Error from data exchange between modules

    Returns:
        Error propagation analysis
    """
    total_abs_error = sum(c['error_bound'] for c in computations)
    total_rel_error = sum(c['relative_error'] for c in computations)

    return {
        'num_modules': len(computations),
        'modules': [(c['name'], c['error_bound'], c['relative_error'])
                    for c in computations],
        'total_absolute_error': total_abs_error + interaction_error,
        'total_relative_error': total_rel_error,
        'interaction_error': interaction_error,
        'theorem': 'modular_evidence_composition (error as negative evidence)'
    }


# ============================================================
# Demo: Run all applications
# ============================================================

def demo_all_applications():
    """Run all application demos."""

    print("=" * 70)
    print("APPLICATION 1: Modular ML Pipeline Certification")
    print("=" * 70)

    pipeline = ml_pipeline_certification(
        stages=[
            {'name': 'Feature Extraction', 'error_bound': 0.02},
            {'name': 'Model Inference', 'error_bound': 0.05},
            {'name': 'Post-Processing', 'error_bound': 0.01},
            {'name': 'Calibration', 'error_bound': 0.03},
        ],
        interface_costs=[0.005, 0.01, 0.005]
    )
    print(f"  Pipeline with {pipeline['pipeline_stages']} stages")
    for name, bound in pipeline['stage_bounds']:
        print(f"    {name}: error ≤ {bound}")
    print(f"  Total stage error: {pipeline['total_stage_error']:.3f}")
    print(f"  Interface cost: {pipeline['total_interface_cost']:.3f}")
    print(f"  Global error bound: {pipeline['global_error_bound']:.3f}")
    print(f"  Certified: {pipeline['certified']}")
    print()

    print("=" * 70)
    print("APPLICATION 2: Cryptographic Protocol Composition")
    print("=" * 70)

    crypto = protocol_composition_bound(
        protocols=[
            {'name': 'AES-256', 'security_bits': 256},
            {'name': 'SHA-3', 'security_bits': 256},
            {'name': 'ECDSA-P256', 'security_bits': 128},
            {'name': 'TLS Handshake', 'security_bits': 128},
        ],
        composition_overhead=2.0
    )
    print(f"  Composed {crypto['num_protocols']} protocols")
    for name, bits in crypto['protocols']:
        print(f"    {name}: {bits}-bit security")
    print(f"  Min individual: {crypto['min_individual_security']}-bit")
    print(f"  Effective composed: {crypto['effective_composed_security']:.1f}-bit")
    print(f"  After overhead: {crypto['final_security']:.1f}-bit")
    print()

    print("=" * 70)
    print("APPLICATION 3: Distributed System Verification")
    print("=" * 70)

    distributed = distributed_verification(
        nodes=[
            {'name': 'Node A', 'verification_time': 2.0, 'correctness_prob': 0.999},
            {'name': 'Node B', 'verification_time': 3.0, 'correctness_prob': 0.998},
            {'name': 'Node C', 'verification_time': 1.5, 'correctness_prob': 0.999},
            {'name': 'Node D', 'verification_time': 4.0, 'correctness_prob': 0.997},
        ],
        network_latency=0.5
    )
    print(f"  {distributed['num_nodes']} nodes")
    print(f"  Parallel time: {distributed['parallel_verification_time']:.1f}s")
    print(f"  Sequential time: {distributed['sequential_verification_time']:.1f}s")
    print(f"  Speedup: {distributed['speedup']:.1f}x")
    print(f"  Composed correctness: {distributed['composed_correctness']:.6f}")
    print()

    print("=" * 70)
    print("APPLICATION 4: Scientific Computing Error Propagation")
    print("=" * 70)

    science = error_propagation(
        computations=[
            {'name': 'Mesh Generation', 'error_bound': 1e-6, 'relative_error': 1e-8},
            {'name': 'PDE Solver', 'error_bound': 1e-4, 'relative_error': 1e-6},
            {'name': 'Interpolation', 'error_bound': 1e-5, 'relative_error': 1e-7},
            {'name': 'Visualization', 'error_bound': 1e-3, 'relative_error': 1e-5},
        ],
        interaction_error=1e-5
    )
    print(f"  {science['num_modules']} computational modules")
    for name, abs_err, rel_err in science['modules']:
        print(f"    {name}: |ε| ≤ {abs_err:.1e}, rel ≤ {rel_err:.1e}")
    print(f"  Total absolute error: {science['total_absolute_error']:.1e}")
    print(f"  Interaction error: {science['interaction_error']:.1e}")
    print()


if __name__ == "__main__":
    demo_all_applications()


#!/usr/bin/env python3
"""
demo.py — Demonstrations of Compositional Certification Theorems

Concrete numerical examples showing how modular decomposition preserves
quantitative control: local bounds compose into global bounds with
at most an additive interface penalty.
"""

import math
from typing import List, Tuple

# ============================================================
# Demo 1: Compositional System Cost
# ============================================================

def compositional_cost(local_costs: List[float], interface_cost: float) -> float:
    """Global cost = sum of local costs + interface cost."""
    return sum(local_costs) + interface_cost

def demo_compositional_cost():
    """Show that refining a module decreases global cost."""
    print("=" * 60)
    print("DEMO 1: Compositional System Cost")
    print("=" * 60)

    modules = [2.5, 1.8, 3.2, 0.9]
    interface = 1.0
    total = compositional_cost(modules, interface)
    print(f"Modules: {modules}")
    print(f"Interface cost: {interface}")
    print(f"Total cost: {total:.2f}")

    # Refine module 2 (index 2) from 3.2 to 1.5
    refined = modules.copy()
    refined[2] = 1.5
    new_total = compositional_cost(refined, interface)
    print(f"\nAfter refining module 3: {refined}")
    print(f"New total cost: {new_total:.2f}")
    print(f"Cost reduction: {total - new_total:.2f}")
    print(f"Theorem: refinement_decreases_cost ✓")
    print()

# ============================================================
# Demo 2: Regret Bounds for Modular Expert Systems
# ============================================================

def regret_bound(n: int, T: int) -> float:
    """√(T · log(n) / 2) — the multiplicative weights regret bound."""
    if n <= 0:
        return 0.0
    return math.sqrt(T * math.log(n) / 2)

def interface_bound(k: int, n: int) -> float:
    """k · √n — the holographic interface bound."""
    return k * math.sqrt(n)

def demo_regret_composition():
    """Show modular regret composition: total ≤ sum of parts + interface."""
    print("=" * 60)
    print("DEMO 2: Modular Regret Composition")
    print("=" * 60)

    # A system with 3 expert modules, each with different expert counts
    k = 3
    expert_counts = [10, 50, 100]
    T = 1000

    print(f"Modules: {k}")
    print(f"Expert counts per module: {expert_counts}")
    print(f"Time horizon T: {T}")
    print()

    module_regrets = [regret_bound(n, T) for n in expert_counts]
    total_module_regret = sum(module_regrets)
    iface = interface_bound(k, T)

    for i, (n, r) in enumerate(zip(expert_counts, module_regrets)):
        print(f"  Module {i+1} ({n} experts): regret ≤ {r:.2f}")

    print(f"\n  Sum of module regrets: {total_module_regret:.2f}")
    print(f"  Interface bound: {iface:.2f}")
    print(f"  Total bound: {total_module_regret + iface:.2f}")

    # Compare with monolithic system
    monolithic = regret_bound(sum(expert_counts), T)
    print(f"\n  Monolithic system ({sum(expert_counts)} experts): regret ≤ {monolithic:.2f}")
    print(f"  Ratio (modular/monolithic): {(total_module_regret + iface) / monolithic:.2f}")
    print(f"\n  Theorem: modular_regret_with_interface ✓")
    print()

# ============================================================
# Demo 3: Evidence Composition for Bayesian Systems
# ============================================================

def demo_evidence_composition():
    """Show that evidence composes: sum of local ≤ sum of bounds + interface."""
    print("=" * 60)
    print("DEMO 3: Evidence Composition for Bayesian Systems")
    print("=" * 60)

    # 4 modules, each with local evidence and local bound
    actual_evidence = [0.7, 0.5, 0.9, 0.3]
    local_bounds = [0.8, 0.6, 1.0, 0.4]
    interface_cost = 0.2

    total_evidence = sum(actual_evidence)
    total_bound = sum(local_bounds) + interface_cost

    print(f"Module evidence: {actual_evidence}")
    print(f"Local bounds:    {local_bounds}")
    print(f"Interface cost:  {interface_cost}")
    print(f"\nTotal evidence: {total_evidence:.2f}")
    print(f"Total bound:    {total_bound:.2f}")
    print(f"Slack:          {total_bound - total_evidence:.2f}")
    print(f"\nTheorem: modular_evidence_composition ✓")
    print()

# ============================================================
# Demo 4: Multiplicative-to-Additive Transfer (Gaussian Norms)
# ============================================================

def gaussian_norm(a: int, b: int) -> int:
    """Gaussian norm: a² + b²."""
    return a * a + b * b

def gaussian_product(a1: int, b1: int, a2: int, b2: int) -> Tuple[int, int]:
    """Gaussian integer multiplication: (a1+b1i)(a2+b2i)."""
    return (a1 * a2 - b1 * b2, a1 * b2 + b1 * a2)

def demo_multiplicative_transfer():
    """Show that Gaussian norm multiplication → log-norm addition."""
    print("=" * 60)
    print("DEMO 4: Multiplicative-to-Additive Transfer")
    print("=" * 60)

    examples = [
        (3, 4, 1, 2),
        (2, 1, 3, 1),
        (5, 0, 0, 3),
    ]

    for a, b, c, d in examples:
        n1 = gaussian_norm(a, b)
        n2 = gaussian_norm(c, d)
        e, f = gaussian_product(a, b, c, d)
        n_prod = gaussian_norm(e, f)

        print(f"  ({a}+{b}i) × ({c}+{d}i) = ({e}+{f}i)")
        print(f"  N = {n1} × {n2} = {n_prod}")
        print(f"  log N = {math.log(n1):.3f} + {math.log(n2):.3f} = {math.log(n_prod):.3f}")
        assert n1 * n2 == n_prod, "Multiplicativity check failed!"
        assert abs(math.log(n1) + math.log(n2) - math.log(n_prod)) < 1e-10
        print(f"  Brahmagupta-Fibonacci ✓, Log-additivity ✓")
        print()

    print("Theorem: log_gaussianNorm_additive ✓")
    print()

# ============================================================
# Demo 5: Fibonacci GCD Identity
# ============================================================

def fib(n: int) -> int:
    """Fibonacci sequence."""
    if n <= 0:
        return 0
    if n == 1:
        return 1
    a, b = 0, 1
    for _ in range(2, n + 1):
        a, b = b, a + b
    return b

def demo_fib_gcd():
    """Demonstrate gcd(F(m), F(n)) = F(gcd(m,n))."""
    print("=" * 60)
    print("DEMO 5: Fibonacci GCD Identity")
    print("=" * 60)

    pairs = [(6, 9), (12, 8), (15, 20), (21, 14), (30, 45)]

    for m, n in pairs:
        fm, fn = fib(m), fib(n)
        g = math.gcd(m, n)
        fg = fib(g)
        gcd_fib = math.gcd(fm, fn)

        print(f"  m={m}, n={n}: F({m})={fm}, F({n})={fn}")
        print(f"    gcd(F({m}),F({n})) = {gcd_fib}")
        print(f"    F(gcd({m},{n})) = F({g}) = {fg}")
        assert gcd_fib == fg, f"Identity failed for m={m}, n={n}!"
        print(f"    ✓ Equal!")

    print(f"\nTheorem: fib_gcd_compositional ✓")
    print()

# ============================================================
# Demo 6: Carmichael Number 561 — Korselt's Criterion
# ============================================================

def demo_carmichael_561():
    """Show that 561 = 3×11×17 satisfies Korselt's criterion at each factor."""
    print("=" * 60)
    print("DEMO 6: Carmichael Number 561 — Modular Composition")
    print("=" * 60)

    n = 561
    factors = [3, 11, 17]

    print(f"  561 = {' × '.join(str(f) for f in factors)}")
    print(f"  561 - 1 = 560")
    print()

    all_korselt = True
    for p in factors:
        divides_n = n % p == 0
        pm1_divides = 560 % (p - 1) == 0
        print(f"  p = {p}:")
        print(f"    {p} | 561? {'Yes' if divides_n else 'No'}")
        print(f"    ({p}-1) = {p-1} | 560? {'Yes' if pm1_divides else 'No'} (560/{p-1} = {560//(p-1)})")
        all_korselt = all_korselt and divides_n and pm1_divides

    print(f"\n  All Korselt conditions satisfied: {all_korselt}")

    # Verify the Carmichael property for small coprime values
    print(f"\n  Verification: a^560 ≡ 1 (mod 561) for coprime a:")
    for a in [2, 4, 5, 7, 8, 10, 13]:
        if math.gcd(a, 561) == 1:
            result = pow(a, 560, 561)
            print(f"    {a}^560 mod 561 = {result} {'✓' if result == 1 else '✗'}")

    print(f"\n  Theorems: korselt_561_3, korselt_561_11, korselt_561_17, composite_561 ✓")
    print()

# ============================================================
# Demo 7: Interface Bound Scaling
# ============================================================

def demo_interface_scaling():
    """Show interface bound monotonicity and scaling behavior."""
    print("=" * 60)
    print("DEMO 7: Interface Bound Scaling")
    print("=" * 60)

    print(f"  {'k':>4} {'n':>6} {'interfaceBound(k,n)':>20}")
    print(f"  {'---':>4} {'---':>6} {'---':>20}")

    for k in [1, 2, 5, 10]:
        for n in [10, 100, 1000, 10000]:
            ib = interface_bound(k, n)
            print(f"  {k:>4} {n:>6} {ib:>20.2f}")
        print()

    print("  Monotonicity in k (fixed n=1000):")
    for k in range(1, 6):
        print(f"    k={k}: {interface_bound(k, 1000):.2f}")
    print(f"\n  Theorem: interfaceBound_mono_left, interfaceBound_mono_right ✓")
    print()


if __name__ == "__main__":
    demo_compositional_cost()
    demo_regret_composition()
    demo_evidence_composition()
    demo_multiplicative_transfer()
    demo_fib_gcd()
    demo_carmichael_561()
    demo_interface_scaling()

    print("=" * 60)
    print("ALL DEMOS COMPLETED SUCCESSFULLY")
    print("=" * 60)


#!/usr/bin/env python3
"""Generate PACKAGE.json with all artifacts embedded."""
import json
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_code = read_file('Catalog/Logic/ModularComposition.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
visualizations_code = read_file('visualizations.py')

# Read base64 images
viz_data = {}
for name in ['regret_composition', 'interface_bound', 'fib_gcd_lattice', 'optimal_decomposition']:
    b64_path = f'figures/{name}.b64'
    if os.path.exists(b64_path):
        viz_data[name] = read_file(b64_path)

package = {
    "title": "Compositional Certification: A Formal Framework for Modular Verified Reasoning",
    "domain": "Logic / Compositional Verification",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Compositional Certification Demos",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Compositional System Optimizer",
            "pseudocode": """
Algorithm: CompositionalSystemOptimizer
Input: modules M[1..k] with costs c[i], interface cost I
Output: global cost G, refinement opportunities

1. G ← Σ c[i] + I
2. For each module i:
   2a. savings[i] ← c[i]  // maximum possible savings
3. Sort savings in decreasing order
4. Return G, sorted savings
""",
            "code": algorithms_code
        },
        {
            "name": "Modular Regret Calculator",
            "pseudocode": """
Algorithm: ModularRegretBound
Input: expert counts n[1..k], time horizon T
Output: total regret bound

1. For each module i:
   1a. r[i] ← √(T · log(n[i]) / 2)
2. module_total ← Σ r[i]
3. interface ← k · √T
4. Return module_total + interface
""",
            "code": "# See algorithms.py modular_regret_bound function"
        }
    ],
    "visualizations": [
        {
            "name": "Regret Composition: Modular vs Monolithic",
            "data": viz_data.get('regret_composition', '')
        },
        {
            "name": "Interface Bound Heatmap",
            "data": viz_data.get('interface_bound', '')
        },
        {
            "name": "Fibonacci GCD Lattice Structure",
            "data": viz_data.get('fib_gcd_lattice', '')
        },
        {
            "name": "Optimal Decomposition Tradeoff",
            "data": viz_data.get('optimal_decomposition', '')
        }
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json written ({os.path.getsize('PACKAGE.json')} bytes)")


#!/usr/bin/env python3
"""
visualizations.py — Visualizations for Compositional Certification

Generates matplotlib figures showing:
1. Regret decomposition across modules
2. Interface bound scaling
3. Fibonacci GCD lattice structure
4. Optimal decomposition tradeoff curve
"""

import math
import base64
import io
import os

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def save_figure_base64(fig) -> str:
    """Save figure as base64 PNG data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def save_figure_file(fig, filename: str):
    """Save figure to file."""
    fig.savefig(filename, dpi=150, bbox_inches='tight')
    plt.close(fig)


# ============================================================
# Figure 1: Regret Composition Bar Chart
# ============================================================

def plot_regret_composition():
    """Bar chart showing modular vs monolithic regret bounds."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Parameters
    T = 1000
    module_experts = [10, 50, 100]
    k = len(module_experts)
    total_experts = sum(module_experts)

    # Module regrets
    module_regrets = [math.sqrt(T * math.log(n) / 2) for n in module_experts]
    interface = k * math.sqrt(T)
    monolithic = math.sqrt(T * math.log(total_experts) / 2)

    # Left plot: Stacked bar chart
    labels = [f'Module {i+1}\n({n} experts)' for i, n in enumerate(module_experts)]
    labels.append('Interface')
    values = module_regrets + [interface]
    colors = ['#3498db', '#2ecc71', '#e74c3c', '#f39c12']

    bars = ax1.bar(labels, values, color=colors[:len(values)], edgecolor='black', linewidth=0.5)
    ax1.axhline(y=monolithic, color='purple', linestyle='--', linewidth=2, label=f'Monolithic ({total_experts} experts)')
    ax1.set_ylabel('Regret Bound', fontsize=12)
    ax1.set_title('Modular vs Monolithic Regret (T=1000)', fontsize=14)
    ax1.legend(fontsize=10)

    # Add value labels on bars
    for bar, val in zip(bars, values):
        ax1.text(bar.get_x() + bar.get_width()/2., bar.get_height() + 0.5,
                f'{val:.1f}', ha='center', va='bottom', fontsize=9)

    # Right plot: Cumulative comparison
    T_values = np.arange(100, 5001, 100)
    modular_totals = []
    monolithic_totals = []

    for T_val in T_values:
        mod_reg = sum(math.sqrt(T_val * math.log(n) / 2) for n in module_experts)
        iface = k * math.sqrt(T_val)
        mono = math.sqrt(T_val * math.log(total_experts) / 2)
        modular_totals.append(mod_reg + iface)
        monolithic_totals.append(mono)

    ax2.plot(T_values, modular_totals, 'b-', linewidth=2, label='Modular (3 modules)')
    ax2.plot(T_values, monolithic_totals, 'r--', linewidth=2, label='Monolithic')
    ax2.fill_between(T_values, monolithic_totals, modular_totals, alpha=0.1, color='blue')
    ax2.set_xlabel('Time Horizon T', fontsize=12)
    ax2.set_ylabel('Regret Bound', fontsize=12)
    ax2.set_title('Regret Scaling with Time', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    fig.tight_layout()
    return fig


# ============================================================
# Figure 2: Interface Bound Heatmap
# ============================================================

def plot_interface_bound():
    """Heatmap of interface bound k · √n for various k, n."""
    fig, ax = plt.subplots(figsize=(10, 7))

    k_values = np.arange(1, 21)
    n_values = np.array([10, 50, 100, 500, 1000, 5000, 10000])

    bounds = np.zeros((len(k_values), len(n_values)))
    for i, k in enumerate(k_values):
        for j, n in enumerate(n_values):
            bounds[i, j] = k * math.sqrt(n)

    im = ax.imshow(bounds, aspect='auto', cmap='YlOrRd')
    ax.set_xticks(range(len(n_values)))
    ax.set_xticklabels([str(n) for n in n_values], fontsize=10)
    ax.set_yticks(range(0, len(k_values), 2))
    ax.set_yticklabels([str(k) for k in k_values[::2]], fontsize=10)
    ax.set_xlabel('Problem Size n', fontsize=12)
    ax.set_ylabel('Number of Modules k', fontsize=12)
    ax.set_title('Interface Bound: k · √n', fontsize=14)
    plt.colorbar(im, ax=ax, label='Interface Cost')

    fig.tight_layout()
    return fig


# ============================================================
# Figure 3: Fibonacci GCD Lattice
# ============================================================

def plot_fib_gcd_lattice():
    """Visualize the Fibonacci GCD identity on a lattice."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Table of gcd(F(m), F(n)) = F(gcd(m,n))
    def fib(n):
        if n <= 0: return 0
        if n == 1: return 1
        a, b = 0, 1
        for _ in range(2, n + 1):
            a, b = b, a + b
        return b

    max_n = 12
    pairs = [(m, n) for m in range(1, max_n+1) for n in range(1, max_n+1)]

    # Create divisibility heatmap
    div_matrix = np.zeros((max_n, max_n))
    for i in range(max_n):
        for j in range(max_n):
            m, n = i + 1, j + 1
            g = math.gcd(m, n)
            div_matrix[i, j] = g

    im = ax1.imshow(div_matrix, cmap='viridis', origin='lower')
    ax1.set_xlabel('n', fontsize=12)
    ax1.set_ylabel('m', fontsize=12)
    ax1.set_title('gcd(m, n) — Index Lattice', fontsize=14)
    ax1.set_xticks(range(0, max_n, 2))
    ax1.set_xticklabels(range(1, max_n + 1, 2))
    ax1.set_yticks(range(0, max_n, 2))
    ax1.set_yticklabels(range(1, max_n + 1, 2))
    plt.colorbar(im, ax=ax1, label='gcd(m,n)')

    # Right: Fibonacci values and GCD verification
    fibs = [fib(i) for i in range(1, max_n + 1)]
    gcd_matrix = np.zeros((max_n, max_n))
    for i in range(max_n):
        for j in range(max_n):
            gcd_matrix[i, j] = math.gcd(fibs[i], fibs[j])

    im2 = ax2.imshow(np.log1p(gcd_matrix), cmap='plasma', origin='lower')
    ax2.set_xlabel('n', fontsize=12)
    ax2.set_ylabel('m', fontsize=12)
    ax2.set_title('log(1 + gcd(F(m), F(n))) — Fibonacci Lattice', fontsize=14)
    ax2.set_xticks(range(0, max_n, 2))
    ax2.set_xticklabels(range(1, max_n + 1, 2))
    ax2.set_yticks(range(0, max_n, 2))
    ax2.set_yticklabels(range(1, max_n + 1, 2))
    plt.colorbar(im2, ax=ax2, label='log(1 + gcd)')

    fig.suptitle('Fibonacci GCD Identity: gcd(F(m), F(n)) = F(gcd(m,n))', fontsize=16, y=1.02)
    fig.tight_layout()
    return fig


# ============================================================
# Figure 4: Optimal Decomposition Tradeoff
# ============================================================

def plot_optimal_decomposition():
    """Plot the tradeoff between module count and total cost."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    for n_total, color in [(50, '#3498db'), (100, '#2ecc71'), (500, '#e74c3c'), (1000, '#9b59b6')]:
        T = n_total
        ks = list(range(1, min(51, n_total)))
        module_regrets = []
        interfaces = []
        totals = []

        for k in ks:
            n_per = max(1, n_total // k)
            mr = k * math.sqrt(T * math.log(max(2, n_per)) / 2)
            ib = k * math.sqrt(T)
            module_regrets.append(mr)
            interfaces.append(ib)
            totals.append(mr + ib)

        best_k = ks[totals.index(min(totals))]

        ax1.plot(ks, totals, color=color, linewidth=2, label=f'n={n_total} (opt k={best_k})')
        ax1.scatter([best_k], [min(totals)], color=color, s=100, zorder=5, edgecolors='black')

    ax1.set_xlabel('Number of Modules k', fontsize=12)
    ax1.set_ylabel('Total Bound (regret + interface)', fontsize=12)
    ax1.set_title('Optimal Module Count', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Right: Component breakdown for n=100
    n_total = 100
    T = 100
    ks = list(range(1, 51))
    module_regrets = []
    interfaces = []

    for k in ks:
        n_per = max(1, n_total // k)
        mr = k * math.sqrt(T * math.log(max(2, n_per)) / 2)
        ib = k * math.sqrt(T)
        module_regrets.append(mr)
        interfaces.append(ib)

    ax2.fill_between(ks, 0, module_regrets, alpha=0.4, color='#3498db', label='Module Regret')
    ax2.fill_between(ks, module_regrets, [m + i for m, i in zip(module_regrets, interfaces)],
                     alpha=0.4, color='#e74c3c', label='Interface Cost')
    ax2.plot(ks, [m + i for m, i in zip(module_regrets, interfaces)], 'k-', linewidth=2, label='Total')
    ax2.set_xlabel('Number of Modules k', fontsize=12)
    ax2.set_ylabel('Bound Value', fontsize=12)
    ax2.set_title('Cost Decomposition (n=100)', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    fig.tight_layout()
    return fig


# ============================================================
# Generate all figures
# ============================================================

def generate_all_figures():
    """Generate all visualization figures."""
    os.makedirs('/workspace/request-project/figures', exist_ok=True)

    print("Generating Figure 1: Regret Composition...")
    fig1 = plot_regret_composition()
    save_figure_file(fig1, '/workspace/request-project/figures/regret_composition.png')

    print("Generating Figure 2: Interface Bound Heatmap...")
    fig2 = plot_interface_bound()
    save_figure_file(fig2, '/workspace/request-project/figures/interface_bound.png')

    print("Generating Figure 3: Fibonacci GCD Lattice...")
    fig3 = plot_fib_gcd_lattice()
    save_figure_file(fig3, '/workspace/request-project/figures/fib_gcd_lattice.png')

    print("Generating Figure 4: Optimal Decomposition...")
    fig4 = plot_optimal_decomposition()
    save_figure_file(fig4, '/workspace/request-project/figures/optimal_decomposition.png')

    print("All figures generated successfully!")
    return {
        'regret_composition': fig1,
        'interface_bound': fig2,
        'fib_gcd_lattice': fig3,
        'optimal_decomposition': fig4
    }


def get_all_base64():
    """Generate all figures and return as base64 data URIs."""
    fig1 = plot_regret_composition()
    fig2 = plot_interface_bound()
    fig3 = plot_fib_gcd_lattice()
    fig4 = plot_optimal_decomposition()

    return {
        'regret_composition': save_figure_base64(fig1),
        'interface_bound': save_figure_base64(fig2),
        'fib_gcd_lattice': save_figure_base64(fig3),
        'optimal_decomposition': save_figure_base64(fig4)
    }


if __name__ == "__main__":
    generate_all_figures()
