#!/usr/bin/env python3
"""
Applications of the Threshold Phase Transition Theorem

Demonstrates real-world applications in:
1. Logistics: Green shipping incentive threshold
2. Machine Learning: Reward shaping for fairness constraints  
3. Economics: Subsidy threshold for renewable energy adoption
4. Network Design: Reliability bonus threshold
"""

import numpy as np
from algorithms import (
    compute_exact_threshold,
    binary_search_threshold,
    classify_phase,
    bonus_objective,
    find_all_minimizers,
)


def app_green_shipping():
    """
    Application 1: Green Shipping Incentives
    
    A logistics company has multiple shipping routes. Some are "green"
    (lower emissions). What carbon credit bonus makes green routes optimal?
    """
    print("=" * 60)
    print("APPLICATION 1: Green Shipping Incentives")
    print("=" * 60)
    
    routes = ["Truck (highway)", "Truck (scenic)", "Rail", "Ship", "Air"]
    cost = np.array([45.0, 52.0, 38.0, 35.0, 80.0])  # dollars per unit
    green = [False, False, True, True, False]  # rail and ship are green
    
    print("\nRoutes:")
    for i, route in enumerate(routes):
        tag = " 🌿" if green[i] else ""
        print(f"  {route}: ${cost[i]:.0f}/unit{tag}")
    
    delta, g_idx, m_idx = compute_exact_threshold(cost, green)
    print(f"\nCheapest overall: {routes[g_idx]} (${cost[g_idx]:.0f})")
    print(f"Cheapest green:   {routes[m_idx]} (${cost[m_idx]:.0f})")
    print(f"\n→ Carbon credit threshold: ${delta:.2f}/unit")
    print(f"  Below ${delta:.2f}: cheapest route wins (may not be green)")
    print(f"  Above ${delta:.2f}: green route always wins")
    print(f"  At exactly ${delta:.2f}: both are equally optimal")
    
    print("\nPolicy analysis:")
    for credit in [0, 1, 2, 3, 4, 5]:
        mins = find_all_minimizers(cost, green, credit)
        chosen = [routes[i] for i in mins]
        phase = classify_phase(cost, green, credit)
        print(f"  Credit ${credit}: optimal = {chosen} ({phase})")


def app_fair_ml():
    """
    Application 2: Fairness-Constrained Model Selection
    
    Select a ML model from a pool. Some models satisfy a fairness criterion.
    What reward bonus makes fair models preferred?
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Fair Model Selection in ML")
    print("=" * 60)
    
    models = [
        "Logistic Regression",
        "Random Forest",
        "Neural Net (small)",
        "Neural Net (large)",
        "Fair Logistic Reg.",
        "Fair Neural Net",
    ]
    # Error rates (lower is better)
    error = np.array([0.15, 0.08, 0.06, 0.04, 0.18, 0.09])
    fair = [False, False, False, False, True, True]
    
    print("\nModels (error rate):")
    for i, model in enumerate(models):
        tag = " ✓fair" if fair[i] else ""
        print(f"  {model}: {error[i]:.2f}{tag}")
    
    delta, g_idx, m_idx = compute_exact_threshold(error, fair)
    print(f"\nBest overall:  {models[g_idx]} (error = {error[g_idx]:.2f})")
    print(f"Best fair:     {models[m_idx]} (error = {error[m_idx]:.2f})")
    print(f"\n→ Fairness bonus threshold: {delta:.4f}")
    print(f"  This is the minimum reward needed to make fair models preferred.")
    
    print("\nReward sensitivity:")
    for bonus in np.arange(0, 0.12, 0.01):
        phase = classify_phase(error, fair, bonus)
        mins = find_all_minimizers(error, fair, bonus)
        chosen = [models[i] for i in mins]
        print(f"  bonus = {bonus:.2f}: {phase:10s} → {chosen}")


def app_renewable_energy():
    """
    Application 3: Renewable Energy Subsidy Threshold
    
    An energy planner chooses power sources. Some are renewable.
    What subsidy per MWh makes renewables the cheapest option?
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Renewable Energy Subsidy Threshold")
    print("=" * 60)
    
    sources = ["Coal", "Natural Gas", "Nuclear", "Solar", "Wind", "Hydro"]
    cost_per_mwh = np.array([65.0, 50.0, 75.0, 55.0, 48.0, 40.0])
    renewable = [False, False, False, True, True, True]
    
    print("\nPower sources ($/MWh):")
    for i, src in enumerate(sources):
        tag = " ☀️" if renewable[i] else " ⚡"
        print(f"  {src}: ${cost_per_mwh[i]:.0f}/MWh{tag}")
    
    delta, g_idx, m_idx = compute_exact_threshold(cost_per_mwh, renewable)
    print(f"\nCheapest overall:   {sources[g_idx]} (${cost_per_mwh[g_idx]:.0f}/MWh)")
    print(f"Cheapest renewable: {sources[m_idx]} (${cost_per_mwh[m_idx]:.0f}/MWh)")
    print(f"\n→ Subsidy threshold: ${delta:.2f}/MWh")
    
    # Binary search demonstration
    delta_search, history = binary_search_threshold(
        cost_per_mwh, renewable, lo=0, hi=50, tolerance=0.001
    )
    print(f"\nBinary search found threshold in {len(history)} steps")
    print(f"  Exact:  ${delta:.4f}/MWh")
    print(f"  Search: ${delta_search:.4f}/MWh")


def app_network_reliability():
    """
    Application 4: Reliability Bonus in Network Design
    
    Choose network paths. Some paths are redundant (reliable).
    What reliability bonus makes redundant paths preferred?
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Network Reliability Bonus")
    print("=" * 60)
    
    paths = [
        "Direct (single fiber)",
        "Direct (dual fiber)",
        "Via Hub A",
        "Via Hub A + B (redundant)",
        "Satellite",
        "Satellite + fiber backup",
    ]
    latency = np.array([5.0, 7.0, 12.0, 15.0, 200.0, 180.0])  # ms
    reliable = [False, True, False, True, False, True]
    
    print("\nNetwork paths (latency in ms):")
    for i, path in enumerate(paths):
        tag = " [redundant]" if reliable[i] else ""
        print(f"  {path}: {latency[i]:.0f}ms{tag}")
    
    delta, g_idx, m_idx = compute_exact_threshold(latency, reliable)
    print(f"\nFastest overall:   {paths[g_idx]} ({latency[g_idx]:.0f}ms)")
    print(f"Fastest reliable:  {paths[m_idx]} ({latency[m_idx]:.0f}ms)")
    print(f"\n→ Reliability bonus threshold: {delta:.1f}ms")
    print(f"  Interpretation: If reliability saves >{delta:.1f}ms of expected")
    print(f"  downtime, redundant paths become optimal.")


if __name__ == "__main__":
    app_green_shipping()
    app_fair_ml()
    app_renewable_energy()
    app_network_reliability()
    print("\n" + "=" * 60)
    print("All applications demonstrated successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Demo: Binary Search Threshold for Global Minimizers

Demonstrates the phase transition theorem with concrete numerical examples.
Shows how a marking bonus β creates a sharp threshold that separates
unmarked-optimal from marked-optimal regimes.
"""

import numpy as np

def bonus_obj(cost, marked, beta, x):
    """Compute F_β(x) = cost(x) - β · 𝟙_{marked(x)}"""
    return cost[x] - (beta if marked[x] else 0.0)

def find_minimizers(cost, marked, beta):
    """Find all global minimizers of F_β."""
    n = len(cost)
    values = [bonus_obj(cost, marked, beta, x) for x in range(n)]
    min_val = min(values)
    return [x for x in range(n) if abs(values[x] - min_val) < 1e-12]

def demo_basic_threshold():
    """Basic example: 5 cities with costs and a 'green' marking."""
    print("=" * 60)
    print("DEMO 1: Basic Threshold Phenomenon")
    print("=" * 60)
    
    # 5 options with costs
    cost = np.array([1.0, 3.0, 2.0, 5.0, 4.0])
    marked = [False, True, False, True, True]  # "green" options
    labels = ["A", "B", "C", "D", "E"]
    
    print("\nSetup:")
    for i in range(len(cost)):
        tag = " [MARKED]" if marked[i] else ""
        print(f"  Option {labels[i]}: cost = {cost[i]}{tag}")
    
    # Global minimum
    global_min_idx = np.argmin(cost)
    # Marked minimum
    marked_costs = [(cost[i], i) for i in range(len(cost)) if marked[i]]
    marked_min_cost, marked_min_idx = min(marked_costs)
    
    delta = marked_min_cost - cost[global_min_idx]
    print(f"\nGlobal minimum: {labels[global_min_idx]} (cost = {cost[global_min_idx]})")
    print(f"Best marked:    {labels[marked_min_idx]} (cost = {marked_min_cost})")
    print(f"Threshold Δ = {delta}")
    
    print("\nPhase transition:")
    betas = [0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0]
    for beta in betas:
        mins = find_minimizers(cost, marked, beta)
        min_labels = [labels[i] for i in mins]
        min_types = ["M" if marked[i] else "U" for i in mins]
        marker = ""
        if abs(beta - delta) < 1e-10:
            marker = " ← THRESHOLD (tie!)"
        elif beta < delta:
            marker = " (unmarked regime)"
        else:
            marker = " (marked regime)"
        print(f"  β = {beta:4.1f}: minimizers = {min_labels} ({min_types}){marker}")

def demo_binary_search():
    """Demonstrate binary search recovering the threshold."""
    print("\n" + "=" * 60)
    print("DEMO 2: Binary Search Recovers Threshold")
    print("=" * 60)
    
    # Random problem
    np.random.seed(42)
    n = 20
    cost = np.random.uniform(0, 10, n)
    marked = [np.random.random() < 0.3 for _ in range(n)]
    
    # Ensure at least one marked and one unmarked
    marked[0] = False
    marked[1] = True
    
    global_min = min(cost)
    marked_min = min(cost[i] for i in range(n) if marked[i])
    true_delta = marked_min - global_min
    
    print(f"\nProblem: {n} options, {sum(marked)} marked")
    print(f"True threshold Δ = {true_delta:.6f}")
    
    # Binary search
    lo, hi = 0.0, max(cost) - min(cost) + 1
    print(f"\nBinary search (initial bracket: [{lo:.4f}, {hi:.4f}]):")
    
    for step in range(20):
        mid = (lo + hi) / 2
        mins = find_minimizers(cost, marked, mid)
        any_marked = any(marked[i] for i in mins)
        all_marked = all(marked[i] for i in mins)
        
        if all_marked:
            hi = mid  # threshold is below
        elif not any_marked:
            lo = mid  # threshold is above
        else:
            # Tie - we found it
            lo = hi = mid
            break
        
        if step < 5 or step >= 17:
            print(f"  Step {step+1:2d}: mid = {mid:.6f}, "
                  f"bracket = [{lo:.6f}, {hi:.6f}], "
                  f"width = {hi-lo:.8f}")
        elif step == 5:
            print(f"  ... (skipping steps 6-18) ...")
    
    print(f"\nRecovered Δ ≈ {(lo+hi)/2:.10f}")
    print(f"True      Δ = {true_delta:.10f}")
    print(f"Error       = {abs((lo+hi)/2 - true_delta):.2e}")

def demo_tropical_decomposition():
    """Show the tropical decomposition: V(β) = min(globalMin, markedMin - β)."""
    print("\n" + "=" * 60)
    print("DEMO 3: Tropical Decomposition (Value Function)")
    print("=" * 60)
    
    cost = np.array([1.0, 3.0, 2.0, 5.0, 4.0])
    marked = [False, True, False, True, True]
    
    global_min = min(cost)
    marked_min = min(cost[i] for i in range(len(cost)) if marked[i])
    delta = marked_min - global_min
    
    print(f"\nV(β) = min(globalMin, markedMin - β)")
    print(f"     = min({global_min}, {marked_min} - β)")
    print(f"Breakpoint (tropical root) at β = Δ = {delta}")
    
    print("\nβ     | V(β)  | Branch")
    print("-" * 35)
    for beta in np.arange(0, 5.1, 0.5):
        v = min(global_min, marked_min - beta)
        branch = "unmarked" if global_min <= marked_min - beta else "marked"
        tie = " ← TIE" if abs(global_min - (marked_min - beta)) < 1e-10 else ""
        print(f"{beta:4.1f}  | {v:5.1f}  | {branch}{tie}")

def demo_monotonicity():
    """Show monotonicity of the 'all minimizers marked' predicate."""
    print("\n" + "=" * 60)
    print("DEMO 4: Monotonicity of Phase Predicate")
    print("=" * 60)
    
    cost = np.array([1.0, 3.0, 2.0, 5.0, 4.0])
    marked = [False, True, False, True, True]
    
    print("\nP(β) = 'every minimizer of F_β is marked'")
    print("Q(β) = 'every minimizer of F_β is unmarked'\n")
    
    print("β     | P(β)  | Q(β)  | Minimizer types")
    print("-" * 50)
    for beta in np.arange(-1, 6.1, 0.5):
        mins = find_minimizers(cost, marked, beta)
        types = ["M" if marked[i] else "U" for i in mins]
        all_marked_flag = all(marked[i] for i in mins)
        all_unmarked_flag = all(not marked[i] for i in mins)
        print(f"{beta:5.1f} | {str(all_marked_flag):5s} | {str(all_unmarked_flag):5s} | {types}")

if __name__ == "__main__":
    demo_basic_threshold()
    demo_binary_search()
    demo_tropical_decomposition()
    demo_monotonicity()
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for the Threshold Phase Transition Theorem.

Generates publication-quality figures showing:
1. Phase transition diagram
2. Tropical value function decomposition
3. Binary search convergence
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def plot_phase_transition():
    """Plot the phase transition diagram showing minimizer types vs β."""
    cost = np.array([1.0, 3.0, 2.0, 5.0, 4.0])
    marked = [False, True, False, True, True]
    labels = ["A(U)", "B(M)", "C(U)", "D(M)", "E(M)"]
    colors = ['#2196F3', '#E91E63', '#2196F3', '#E91E63', '#E91E63']
    
    delta = 2.0  # marked min (3.0) - global min (1.0)
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    # Left: F_β(x) for each option as function of β
    betas = np.linspace(-0.5, 5, 200)
    for i in range(len(cost)):
        if marked[i]:
            vals = cost[i] - betas
            ax1.plot(betas, vals, color=colors[i], linewidth=2, 
                    label=labels[i], linestyle='--')
        else:
            vals = np.full_like(betas, cost[i])
            ax1.plot(betas, vals, color=colors[i], linewidth=2, 
                    label=labels[i])
    
    ax1.axvline(x=delta, color='black', linestyle=':', linewidth=1.5, alpha=0.7)
    ax1.annotate('Δ = 2.0', xy=(delta, 0.5), fontsize=12, ha='left',
                fontweight='bold')
    
    # Shade regions
    ax1.axvspan(-0.5, delta, alpha=0.08, color='blue', label='Unmarked optimal')
    ax1.axvspan(delta, 5, alpha=0.08, color='red', label='Marked optimal')
    
    ax1.set_xlabel('Bonus parameter β', fontsize=13)
    ax1.set_ylabel('F_β(x) = cost(x) - β·𝟙(x)', fontsize=13)
    ax1.set_title('Perturbed Objective by Option', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=9, loc='upper right')
    ax1.set_ylim(-3, 6)
    ax1.grid(True, alpha=0.3)
    
    # Right: Phase diagram
    betas_fine = np.linspace(-0.5, 4.5, 500)
    phase_colors = []
    for b in betas_fine:
        vals = [cost[i] - (b if marked[i] else 0) for i in range(len(cost))]
        min_val = min(vals)
        mins = [i for i in range(len(cost)) if abs(vals[i] - min_val) < 1e-10]
        has_m = any(marked[i] for i in mins)
        has_u = any(not marked[i] for i in mins)
        if has_m and has_u:
            phase_colors.append('gold')
        elif has_m:
            phase_colors.append('#E91E63')
        else:
            phase_colors.append('#2196F3')
    
    for i in range(len(betas_fine)):
        ax2.axvspan(betas_fine[i] - 0.005, betas_fine[i] + 0.005, 
                    color=phase_colors[i], alpha=0.8)
    
    ax2.axvline(x=delta, color='black', linewidth=2)
    ax2.text(delta/2, 0.5, 'UNMARKED\nOPTIMAL', transform=ax2.get_xaxis_transform(),
            ha='center', va='center', fontsize=14, fontweight='bold', color='#1565C0')
    ax2.text(delta + (4.5-delta)/2, 0.5, 'MARKED\nOPTIMAL', 
            transform=ax2.get_xaxis_transform(),
            ha='center', va='center', fontsize=14, fontweight='bold', color='#AD1457')
    ax2.text(delta, 0.85, '← Δ = 2.0 →\n(coexistence)', 
            transform=ax2.get_xaxis_transform(),
            ha='center', fontsize=11, fontweight='bold')
    
    ax2.set_xlabel('Bonus parameter β', fontsize=13)
    ax2.set_title('Phase Diagram', fontsize=14, fontweight='bold')
    ax2.set_yticks([])
    ax2.set_xlim(-0.5, 4.5)
    
    fig.suptitle('Threshold Phase Transition in Finite Optimization', 
                fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()
    
    fig.savefig('/workspace/request-project/phase_transition.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_tropical_value():
    """Plot the tropical value function decomposition."""
    global_min = 1.0
    marked_min = 3.0
    delta = marked_min - global_min
    
    fig, ax = plt.subplots(figsize=(8, 5))
    
    betas = np.linspace(-1, 5, 300)
    
    # Unmarked branch (constant)
    ax.plot(betas, np.full_like(betas, global_min), 
           color='#2196F3', linewidth=2, linestyle='--', label='Unmarked branch: cost(x₀)')
    
    # Marked branch (linear)
    ax.plot(betas, marked_min - betas, 
           color='#E91E63', linewidth=2, linestyle='--', label='Marked branch: cost(xₘ) - β')
    
    # Value function (tropical min)
    values = np.minimum(global_min, marked_min - betas)
    ax.plot(betas, values, color='black', linewidth=3, label='V(β) = min(branches)')
    
    # Breakpoint
    ax.plot(delta, global_min, 'ko', markersize=10, zorder=5)
    ax.annotate(f'Tropical root\nΔ = {delta:.1f}', 
               xy=(delta, global_min), xytext=(delta+0.5, global_min+1.2),
               fontsize=12, fontweight='bold',
               arrowprops=dict(arrowstyle='->', color='black', lw=1.5))
    
    ax.axvline(x=delta, color='gray', linestyle=':', alpha=0.5)
    ax.set_xlabel('Bonus parameter β', fontsize=13)
    ax.set_ylabel('Value V(β)', fontsize=13)
    ax.set_title('Tropical Decomposition of Value Function', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-3, 5)
    
    fig.tight_layout()
    fig.savefig('/workspace/request-project/tropical_value.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_binary_search():
    """Plot binary search convergence."""
    np.random.seed(42)
    n = 50
    cost = np.random.uniform(0, 10, n)
    marked = [np.random.random() < 0.3 for _ in range(n)]
    marked[0] = False
    marked[1] = True
    
    global_min = min(cost)
    marked_min = min(cost[i] for i in range(n) if marked[i])
    true_delta = marked_min - global_min
    
    # Run binary search tracking brackets
    lo, hi = 0.0, max(cost) - min(cost) + 1
    los, his = [lo], [hi]
    
    for _ in range(50):
        if hi - lo < 1e-14:
            break
        mid = (lo + hi) / 2
        vals = [cost[i] - (mid if marked[i] else 0) for i in range(n)]
        min_val = min(vals)
        mins = [i for i in range(n) if abs(vals[i] - min_val) < 1e-12]
        
        if all(marked[i] for i in mins):
            hi = mid
        elif not any(marked[i] for i in mins):
            lo = mid
        else:
            lo = hi = mid
        los.append(lo)
        his.append(hi)
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))
    
    steps = range(len(los))
    ax1.fill_between(steps, los, his, alpha=0.3, color='#4CAF50')
    ax1.plot(steps, los, 'b-', linewidth=1.5, label='Lower bound')
    ax1.plot(steps, his, 'r-', linewidth=1.5, label='Upper bound')
    ax1.axhline(y=true_delta, color='black', linestyle=':', linewidth=1.5, label=f'True Δ = {true_delta:.4f}')
    ax1.set_xlabel('Binary search step', fontsize=13)
    ax1.set_ylabel('Bracket bounds', fontsize=13)
    ax1.set_title('Binary Search Convergence', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    
    # Error plot (log scale)
    errors = [max(abs(los[i] - true_delta), abs(his[i] - true_delta)) for i in range(len(los))]
    errors = [max(e, 1e-16) for e in errors]  # clamp for log
    ax2.semilogy(steps, errors, 'g-o', markersize=3, linewidth=1.5)
    ax2.set_xlabel('Binary search step', fontsize=13)
    ax2.set_ylabel('Maximum error', fontsize=13)
    ax2.set_title('Exponential Convergence', fontsize=14, fontweight='bold')
    ax2.grid(True, alpha=0.3)
    
    fig.suptitle('Binary Search Recovers Threshold', fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()
    
    fig.savefig('/workspace/request-project/binary_search.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


if __name__ == "__main__":
    b64_phase = plot_phase_transition()
    b64_tropical = plot_tropical_value()
    b64_search = plot_binary_search()
    
    print("Generated visualizations:")
    print(f"  phase_transition.png ({len(b64_phase)} chars base64)")
    print(f"  tropical_value.png ({len(b64_tropical)} chars base64)")
    print(f"  binary_search.png ({len(b64_search)} chars base64)")
    
    # Save base64 strings for JSON package
    with open('/workspace/request-project/viz_data.py', 'w') as f:
        f.write("# Auto-generated visualization data\n")
        f.write(f"phase_transition_b64 = \"{b64_phase}\"\n")
        f.write(f"tropical_value_b64 = \"{b64_tropical}\"\n")
        f.write(f"binary_search_b64 = \"{b64_search}\"\n")
