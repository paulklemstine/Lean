#!/usr/bin/env python3
"""
Tropical Complexity Transfer — Applications

Real-world applications of the tropical transport and spectral-tropical bridge theorems:
1. Network routing cost analysis
2. Markov chain mixing certification
3. Communication protocol lower bounds
4. Distributed computing message complexity
"""

import numpy as np
from typing import List, Tuple


def log_weight_transform(P: np.ndarray) -> np.ndarray:
    """Convert probability matrix to tropical weight matrix."""
    return -np.log(np.maximum(P, 1e-300))


def triangle_cycle_gap(W: np.ndarray) -> float:
    """Minimum triangle mean over all triples."""
    n = W.shape[0]
    gap = float('inf')
    for i in range(n):
        for j in range(n):
            for k in range(n):
                mean = (W[i, j] + W[j, k] + W[k, i]) / 3.0
                gap = min(gap, mean)
    return gap


# ─────────────────────────────────────────────────────────────
# Application 1: Network Routing Cost Analysis
# ─────────────────────────────────────────────────────────────

def network_routing_analysis(
    link_probs: np.ndarray,
    node_names: List[str] = None
) -> dict:
    """
    Analyze a communication network using tropical cycle gaps.

    Given link reliability probabilities, compute the minimum "surprise cost"
    of any cyclic communication pattern. A positive cycle gap means there
    is an inherent minimum cost for any round-trip message.

    Args:
        link_probs: Matrix of link success probabilities (positive entries).
        node_names: Optional names for nodes.

    Returns:
        Dictionary with analysis results.
    """
    n = link_probs.shape[0]
    if node_names is None:
        node_names = [f"Node {i}" for i in range(n)]

    W = log_weight_transform(link_probs)
    gap = triangle_cycle_gap(W)
    max_p = float(np.max(link_probs))

    # Find the cheapest triangle
    best = (0, 0, 0, float('inf'))
    for i in range(n):
        for j in range(n):
            for k in range(n):
                mean = (W[i, j] + W[j, k] + W[k, i]) / 3.0
                if mean < best[3]:
                    best = (i, j, k, mean)

    return {
        "num_nodes": n,
        "cycle_gap": gap,
        "min_cycle_cost": gap * 3,  # Total cost of cheapest triangle
        "max_link_prob": max_p,
        "theoretical_lower_bound": -np.log(max_p),
        "cheapest_triangle": {
            "nodes": [node_names[best[0]], node_names[best[1]], node_names[best[2]]],
            "mean_cost": best[3],
            "total_cost": best[3] * 3,
        }
    }


# ─────────────────────────────────────────────────────────────
# Application 2: Markov Chain Mixing Certification
# ─────────────────────────────────────────────────────────────

def mixing_certificate(P: np.ndarray) -> dict:
    """
    Certify Markov chain mixing using tropical cycle gap.

    The spectral-tropical bridge guarantees: if P is row-stochastic,
    positive, and on ≥ 2 states, then the tropical cycle gap is positive,
    certifying mixing.

    Args:
        P: Row-stochastic positive matrix.

    Returns:
        Dictionary with mixing certificate.
    """
    n = P.shape[0]

    # Check row-stochasticity
    row_sums = P.sum(axis=1)
    is_stochastic = bool(np.allclose(row_sums, 1.0))

    # Check positivity
    is_positive = bool(np.all(P > 0))

    # Compute tropical cycle gap
    W = log_weight_transform(P)
    gap = triangle_cycle_gap(W)

    # Compute spectral gap for comparison
    eigenvalues = np.linalg.eigvals(P)
    mods = np.sort(np.abs(eigenvalues))[::-1]
    spectral_gap = float(1.0 - mods[1]) if len(mods) >= 2 else 1.0

    # Entry bound
    max_entry = float(np.max(P))
    epsilon = 1.0 - max_entry

    return {
        "num_states": n,
        "is_stochastic": is_stochastic,
        "is_positive": is_positive,
        "is_mixing_certified": gap > 0 and is_stochastic and is_positive,
        "tropical_cycle_gap": gap,
        "spectral_gap": spectral_gap,
        "max_entry": max_entry,
        "epsilon": epsilon,
        "gap_lower_bound": -np.log(max_entry) if max_entry < 1 else 0,
    }


# ─────────────────────────────────────────────────────────────
# Application 3: Communication Protocol Lower Bounds
# ─────────────────────────────────────────────────────────────

def protocol_lower_bound_analysis(
    n_bits: int,
    tropical_cost_per_bit: float = 1.0,
    simulation_overhead: float = 1.0
) -> dict:
    """
    Compute branching program lower bounds for communication functions.

    Uses the transport principle: if each of n input bits contributes
    tropical cost ≥ c, then BP depth ≥ n·c / C.

    Args:
        n_bits: Number of input bits.
        tropical_cost_per_bit: Tropical cost per input bit.
        simulation_overhead: Simulation constant C.

    Returns:
        Dictionary with lower bound analysis.
    """
    total_tropical_cost = n_bits * tropical_cost_per_bit
    bp_depth_lb = total_tropical_cost / simulation_overhead

    return {
        "n_bits": n_bits,
        "tropical_cost_per_bit": tropical_cost_per_bit,
        "total_tropical_cost": total_tropical_cost,
        "simulation_overhead": simulation_overhead,
        "bp_depth_lower_bound": bp_depth_lb,
        "bp_size_lower_bound": 2 ** bp_depth_lb,
    }


# ─────────────────────────────────────────────────────────────
# Application 4: Distributed Computing Message Complexity
# ─────────────────────────────────────────────────────────────

def distributed_message_complexity(
    network_matrix: np.ndarray,
    function_tropical_cost: float,
    simulation_overhead: float = 1.0
) -> dict:
    """
    Analyze message complexity for distributed computation on a network.

    The tropical transport theorem gives: if the function requires
    tropical cost L in any protocol, then any distributed algorithm
    on this network needs depth ≥ L/C.

    Args:
        network_matrix: Stochastic matrix of network link probabilities.
        function_tropical_cost: Tropical cost lower bound for the function.
        simulation_overhead: Protocol-to-algorithm simulation overhead.

    Returns:
        Dictionary with distributed computing analysis.
    """
    n = network_matrix.shape[0]
    W = log_weight_transform(network_matrix)
    network_gap = triangle_cycle_gap(W)

    round_lb = function_tropical_cost / simulation_overhead
    message_lb = round_lb * n  # At least n messages per round

    return {
        "num_processors": n,
        "network_cycle_gap": network_gap,
        "function_tropical_cost": function_tropical_cost,
        "round_lower_bound": round_lb,
        "message_lower_bound": message_lb,
        "network_is_mixing": network_gap > 0,
    }


def main():
    """Run all application demonstrations."""
    np.random.seed(42)

    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║      TROPICAL COMPLEXITY TRANSFER — APPLICATIONS                   ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    # App 1: Network routing
    print("=" * 70)
    print("APPLICATION 1: Network Routing Cost Analysis")
    print("=" * 70)
    print()

    # Model a 4-node network with varying link reliabilities
    link_probs = np.array([
        [0.9, 0.7, 0.3, 0.1],
        [0.6, 0.8, 0.5, 0.1],
        [0.2, 0.4, 0.7, 0.7],
        [0.1, 0.2, 0.6, 0.9],
    ])
    # Normalize to make row-stochastic
    link_probs = link_probs / link_probs.sum(axis=1, keepdims=True)

    names = ["Server A", "Server B", "Server C", "Server D"]
    result = network_routing_analysis(link_probs, names)

    print(f"  Network: {result['num_nodes']} nodes")
    print(f"  Tropical cycle gap: {result['cycle_gap']:.4f}")
    print(f"  Minimum round-trip cost: {result['min_cycle_cost']:.4f}")
    print(f"  Cheapest triangle: {' → '.join(result['cheapest_triangle']['nodes'])}")
    print(f"  Mean cost per hop: {result['cheapest_triangle']['mean_cost']:.4f}")
    print()

    # App 2: Mixing certification
    print("=" * 70)
    print("APPLICATION 2: Markov Chain Mixing Certification")
    print("=" * 70)
    print()

    # Weather model: Sunny, Cloudy, Rainy
    weather = np.array([
        [0.7, 0.2, 0.1],
        [0.3, 0.4, 0.3],
        [0.2, 0.3, 0.5],
    ])

    cert = mixing_certificate(weather)
    print(f"  Weather Markov Chain ({cert['num_states']} states)")
    print(f"  Row-stochastic: {cert['is_stochastic']}")
    print(f"  Positive: {cert['is_positive']}")
    print(f"  Mixing certified: {cert['is_mixing_certified']}")
    print(f"  Tropical cycle gap: {cert['tropical_cycle_gap']:.4f}")
    print(f"  Spectral gap: {cert['spectral_gap']:.4f}")
    print(f"  Max entry: {cert['max_entry']:.4f}")
    print(f"  ε = 1 - max: {cert['epsilon']:.4f}")
    print(f"  Gap lower bound (-log(max)): {cert['gap_lower_bound']:.4f}")
    print()

    # App 3: Communication lower bounds
    print("=" * 70)
    print("APPLICATION 3: Communication Protocol Lower Bounds")
    print("=" * 70)
    print()

    for n in [8, 16, 32, 64, 128]:
        result = protocol_lower_bound_analysis(n)
        print(f"  {n}-bit function: BP depth ≥ {result['bp_depth_lower_bound']:.0f}, "
              f"BP size ≥ 2^{result['bp_depth_lower_bound']:.0f} = {result['bp_size_lower_bound']:.0f}")
    print()

    # App 4: Distributed computing
    print("=" * 70)
    print("APPLICATION 4: Distributed Computing Message Complexity")
    print("=" * 70)
    print()

    # 5-processor ring network
    n_proc = 5
    ring = np.zeros((n_proc, n_proc))
    for i in range(n_proc):
        ring[i, i] = 0.4
        ring[i, (i + 1) % n_proc] = 0.3
        ring[i, (i - 1) % n_proc] = 0.3

    result = distributed_message_complexity(ring, function_tropical_cost=10.0)
    print(f"  Ring network: {result['num_processors']} processors")
    print(f"  Network cycle gap: {result['network_cycle_gap']:.4f}")
    print(f"  Function tropical cost: {result['function_tropical_cost']:.0f}")
    print(f"  Round lower bound: {result['round_lower_bound']:.1f}")
    print(f"  Message lower bound: {result['message_lower_bound']:.1f}")
    print(f"  Network is mixing: {result['network_is_mixing']}")
    print()

    print("=" * 70)
    print("All applications completed successfully.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Tropical Complexity Transfer — Demonstration

Concrete numerical examples illustrating the bridge theorems:
1. Transport principle: tropical cost → branching program depth
2. Spectral-tropical bridge: spectral gap → tropical cycle gap
3. Direct-sum lower bounds
"""

import numpy as np
from typing import Tuple


def log_weight_transform(P: np.ndarray) -> np.ndarray:
    """Convert stochastic matrix P to tropical weight matrix W = -log(P)."""
    return -np.log(P)


def triangle_cycle_gap(W: np.ndarray) -> float:
    """Compute the triangle cycle gap: min over all (i,j,k) of triangleMean(W,i,j,k)."""
    n = W.shape[0]
    gap = float('inf')
    for i in range(n):
        for j in range(n):
            for k in range(n):
                mean = (W[i, j] + W[j, k] + W[k, i]) / 3.0
                gap = min(gap, mean)
    return gap


def spectral_gap(P: np.ndarray) -> float:
    """Compute the spectral gap: 1 - |λ₂| where λ₂ is the second-largest eigenvalue."""
    eigenvalues = np.linalg.eigvals(P)
    mods = np.sort(np.abs(eigenvalues))[::-1]
    if len(mods) < 2:
        return 1.0
    return 1.0 - mods[1]


def max_entry(P: np.ndarray) -> float:
    """Maximum entry of the matrix."""
    return float(np.max(P))


def predicted_lower_bound(P: np.ndarray) -> float:
    """Predicted lower bound on tropical cycle gap: -log(max entry)."""
    return -np.log(max_entry(P))


def random_stochastic_matrix(n: int, alpha: float = 1.0) -> np.ndarray:
    """Generate a random row-stochastic positive matrix using Dirichlet distribution."""
    P = np.random.dirichlet(np.ones(n) * alpha, size=n)
    return P


def transport_theorem_demo():
    """Demonstrate the abstract transport principle."""
    print("=" * 70)
    print("DEMO 1: Abstract Transport Principle")
    print("=" * 70)
    print()
    print("Theorem: If every protocol has tropical cost ≥ L,")
    print("and every BP simulates to a protocol with overhead ≤ C,")
    print("then every BP has depth ≥ L/C.")
    print()

    # Example: AND function on n bits
    for n in [4, 8, 16, 32, 64]:
        L = float(n)  # Each bit contributes tropical cost 1
        C = 1.0       # Unit simulation overhead
        lower_bound = L / C
        print(f"  AND on {n:2d} bits: L = {L:.0f}, C = {C:.0f}, "
              f"BP depth ≥ {lower_bound:.0f}")

    print()

    # Example: Product function with varying overhead
    Lf, Lg = 10.0, 15.0
    print(f"  Product function: L_f = {Lf:.0f}, L_g = {Lg:.0f}")
    for C in [1.0, 2.0, 5.0]:
        lower_bound = (Lf + Lg) / C
        print(f"    C = {C:.0f}: BP depth ≥ {lower_bound:.1f}")
    print()


def spectral_tropical_bridge_demo():
    """Demonstrate the spectral-tropical bridge."""
    print("=" * 70)
    print("DEMO 2: Spectral-Tropical Bridge")
    print("=" * 70)
    print()
    print("Theorem: Positive spectral gap → Positive tropical cycle gap")
    print()

    np.random.seed(42)

    for n in [3, 5, 10]:
        print(f"  --- n = {n} ---")
        P = random_stochastic_matrix(n)
        W = log_weight_transform(P)
        gap = triangle_cycle_gap(W)
        s_gap = spectral_gap(P)
        lb = predicted_lower_bound(P)

        print(f"  Max entry:                {max_entry(P):.4f}")
        print(f"  Spectral gap (1-|λ₂|):    {s_gap:.4f}")
        print(f"  Tropical cycle gap:        {gap:.4f}")
        print(f"  Predicted lower bound:     {lb:.4f}")
        print(f"  Gap ≥ Lower bound?         {gap >= lb - 1e-10}")
        print()


def direct_sum_demo():
    """Demonstrate direct-sum lower bounds."""
    print("=" * 70)
    print("DEMO 3: Direct-Sum Lower Bounds")
    print("=" * 70)
    print()
    print("Theorem: tropical costs add under product composition,")
    print("so BP depth lower bounds add as well.")
    print()

    functions = [
        ("f₁", 5.0),
        ("f₂", 8.0),
        ("f₃", 3.0),
        ("f₄", 12.0),
    ]

    C = 2.0
    print(f"  Simulation constant C = {C:.0f}")
    print()
    print(f"  Individual lower bounds:")
    for name, L in functions:
        print(f"    {name}: tropical cost ≥ {L:.0f}, BP depth ≥ {L/C:.1f}")

    total_L = sum(L for _, L in functions)
    print()
    print(f"  Product f₁ × f₂ × f₃ × f₄:")
    print(f"    Total tropical cost ≥ {total_L:.0f}")
    print(f"    BP depth ≥ {total_L/C:.1f}")
    print()

    # Incremental composition
    print(f"  Incremental composition:")
    running_L = 0.0
    for name, L in functions:
        running_L += L
        print(f"    After adding {name}: total L = {running_L:.0f}, "
              f"BP depth ≥ {running_L/C:.1f}")
    print()


def uniform_matrix_demo():
    """Demonstrate the bridge for uniform and near-uniform matrices."""
    print("=" * 70)
    print("DEMO 4: Uniform and Near-Uniform Matrices")
    print("=" * 70)
    print()

    for n in [2, 3, 5, 10, 20]:
        # Uniform matrix: P(i,j) = 1/n
        P_uniform = np.ones((n, n)) / n
        W = log_weight_transform(P_uniform)
        gap = triangle_cycle_gap(W)
        print(f"  n = {n:2d}: Uniform P(i,j) = 1/{n}")
        print(f"         -log(1/n) = {np.log(n):.4f}")
        print(f"         Tropical cycle gap = {gap:.4f}")
        print(f"         (Equal, as expected for uniform matrix)")
        print()


def converse_direction_demo():
    """Demonstrate the converse: small tropical gap → large entries → constrained spectral gap."""
    print("=" * 70)
    print("DEMO 5: Converse Direction (2×2)")
    print("=" * 70)
    print()
    print("Theorem: If -log(P(0,0)) ≤ δ, then P(0,0) ≥ exp(-δ)")
    print()

    for delta in [0.1, 0.5, 1.0, 2.0]:
        lower_bound = np.exp(-delta)
        print(f"  δ = {delta:.1f}: P(0,0) ≥ exp(-{delta:.1f}) = {lower_bound:.4f}")
    print()


def main():
    """Run all demonstrations."""
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║          TROPICAL COMPLEXITY TRANSFER — DEMONSTRATIONS             ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    transport_theorem_demo()
    spectral_tropical_bridge_demo()
    direct_sum_demo()
    uniform_matrix_demo()
    converse_direction_demo()

    print("=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Tropical Complexity Transfer — Visualizations

Generates publication-quality figures illustrating the bridge theorems.
Saves as PNG files and returns base64 data URIs.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
import io
from typing import Tuple


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def log_weight_transform(P):
    return -np.log(P)


def triangle_cycle_gap(W):
    n = W.shape[0]
    gap = float('inf')
    for i in range(n):
        for j in range(n):
            for k in range(n):
                mean = (W[i, j] + W[j, k] + W[k, i]) / 3.0
                gap = min(gap, mean)
    return gap


def spectral_gap(P):
    eigenvalues = np.linalg.eigvals(P)
    mods = np.sort(np.abs(eigenvalues))[::-1]
    return float(1.0 - mods[1]) if len(mods) >= 2 else 1.0


def random_stochastic(n, alpha=1.0):
    return np.random.dirichlet(np.ones(n) * alpha, size=n)


# ─────────────────────────────────────────────────────────────
# Figure 1: Spectral Gap vs Tropical Cycle Gap Correlation
# ─────────────────────────────────────────────────────────────

def plot_spectral_tropical_correlation(save_path="fig_spectral_tropical.png"):
    """Scatter plot of spectral gap vs tropical cycle gap."""
    np.random.seed(42)

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    for idx, n in enumerate([3, 5, 10]):
        sg_list = []
        tg_list = []
        for _ in range(300):
            P = random_stochastic(n)
            W = log_weight_transform(P)
            sg_list.append(spectral_gap(P))
            tg_list.append(triangle_cycle_gap(W))

        ax = axes[idx]
        ax.scatter(sg_list, tg_list, alpha=0.4, s=15, c='#2196F3')
        ax.set_xlabel('Spectral Gap (1 - |λ₂|)', fontsize=12)
        ax.set_ylabel('Tropical Cycle Gap', fontsize=12)
        ax.set_title(f'n = {n}', fontsize=14)

        # Correlation
        corr = np.corrcoef(sg_list, tg_list)[0, 1]
        ax.text(0.05, 0.95, f'ρ = {corr:.3f}', transform=ax.transAxes,
                fontsize=11, verticalalignment='top',
                bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

        ax.grid(True, alpha=0.3)

    fig.suptitle('Spectral Gap vs Tropical Cycle Gap', fontsize=16, y=1.02)
    plt.tight_layout()
    fig.savefig(save_path, dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ─────────────────────────────────────────────────────────────
# Figure 2: Transport Principle — Lower Bound Scaling
# ─────────────────────────────────────────────────────────────

def plot_transport_scaling(save_path="fig_transport_scaling.png"):
    """Bar chart showing transport lower bounds for various functions."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    # Left: AND function scaling
    ns = [4, 8, 16, 32, 64, 128]
    for C in [1.0, 2.0, 4.0]:
        bounds = [n / C for n in ns]
        ax1.plot(ns, bounds, 'o-', label=f'C = {C:.0f}', linewidth=2, markersize=6)

    ax1.set_xlabel('Number of Input Bits (n)', fontsize=12)
    ax1.set_ylabel('BP Depth Lower Bound (n/C)', fontsize=12)
    ax1.set_title('AND Function: Transport Bounds', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)
    ax1.set_xscale('log', base=2)
    ax1.set_yscale('log', base=2)

    # Right: Direct sum composition
    base_costs = [3, 5, 8, 12]
    cumulative = np.cumsum(base_costs)
    C = 2.0

    colors = ['#4CAF50', '#2196F3', '#FF9800', '#F44336']
    bottom = 0
    for i, cost in enumerate(base_costs):
        ax2.bar(f'{i+1} functions', cost / C, bottom=bottom / C,
                color=colors[i], label=f'f_{i+1} (L={cost})',
                edgecolor='white', linewidth=0.5)
        bottom += cost

    ax2.set_ylabel(f'BP Depth Lower Bound (C={C:.0f})', fontsize=12)
    ax2.set_title('Direct-Sum Composition', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    fig.savefig(save_path, dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ─────────────────────────────────────────────────────────────
# Figure 3: Cycle Gap Growth with Matrix Size
# ─────────────────────────────────────────────────────────────

def plot_gap_growth(save_path="fig_gap_growth.png"):
    """Box plot of tropical cycle gap distribution by matrix size."""
    np.random.seed(42)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    sizes = [3, 5, 8, 12, 16]
    gap_data = []
    bound_data = []

    for n in sizes:
        gaps = []
        bounds = []
        for _ in range(200):
            P = random_stochastic(n)
            W = log_weight_transform(P)
            gaps.append(triangle_cycle_gap(W))
            bounds.append(-np.log(np.max(P)))
        gap_data.append(gaps)
        bound_data.append(bounds)

    # Left: Cycle gap distribution
    bp1 = ax1.boxplot(gap_data, labels=[str(n) for n in sizes],
                       patch_artist=True,
                       boxprops=dict(facecolor='#E3F2FD', edgecolor='#1565C0'),
                       medianprops=dict(color='#F44336', linewidth=2))
    ax1.set_xlabel('Matrix Size (n)', fontsize=12)
    ax1.set_ylabel('Tropical Cycle Gap', fontsize=12)
    ax1.set_title('Cycle Gap Distribution', fontsize=14)
    ax1.grid(True, alpha=0.3)

    # Right: Gap vs theoretical bound
    mean_gaps = [np.mean(g) for g in gap_data]
    mean_bounds = [np.mean(b) for b in bound_data]

    ax2.plot(sizes, mean_gaps, 'o-', color='#2196F3', linewidth=2,
             markersize=8, label='Mean Cycle Gap')
    ax2.plot(sizes, mean_bounds, 's--', color='#F44336', linewidth=2,
             markersize=8, label='Mean Lower Bound (-log max)')
    ax2.fill_between(sizes, mean_bounds, mean_gaps, alpha=0.15, color='#4CAF50')
    ax2.set_xlabel('Matrix Size (n)', fontsize=12)
    ax2.set_ylabel('Value', fontsize=12)
    ax2.set_title('Gap vs Theoretical Lower Bound', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    fig.savefig(save_path, dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ─────────────────────────────────────────────────────────────
# Figure 4: Bridge Pipeline Diagram
# ─────────────────────────────────────────────────────────────

def plot_bridge_pipeline(save_path="fig_bridge_pipeline.png"):
    """Conceptual diagram of the transport pipeline."""
    fig, ax = plt.subplots(1, 1, figsize=(14, 4))

    boxes = [
        (0.08, 'Spectral\nExpansion', '#E8F5E9', '#4CAF50'),
        (0.30, 'Tropical\nCycle Gap', '#E3F2FD', '#2196F3'),
        (0.52, 'Communication\nLower Bound', '#FFF3E0', '#FF9800'),
        (0.74, 'Branching Program\nLower Bound', '#FCE4EC', '#E91E63'),
    ]

    for x, text, fill, edge in boxes:
        rect = plt.Rectangle((x, 0.25), 0.16, 0.5, linewidth=2,
                              edgecolor=edge, facecolor=fill, zorder=2)
        ax.add_patch(rect)
        ax.text(x + 0.08, 0.5, text, ha='center', va='center',
                fontsize=12, fontweight='bold', zorder=3)

    arrows = [
        (0.24, 0.50, 'Thm 6', '#4CAF50'),
        (0.46, 0.50, 'Thm 2', '#2196F3'),
        (0.68, 0.50, 'Thm 1', '#FF9800'),
    ]

    for x, y, label, color in arrows:
        ax.annotate('', xy=(x + 0.06, y), xytext=(x, y),
                    arrowprops=dict(arrowstyle='->', color=color, lw=2.5))
        ax.text(x + 0.03, y + 0.15, label, ha='center', va='bottom',
                fontsize=10, color=color, fontweight='bold')

    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Tropical Complexity Transfer Pipeline', fontsize=16, pad=20)

    fig.savefig(save_path, dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def main():
    """Generate all visualizations."""
    print("Generating visualizations...")

    uri1 = plot_spectral_tropical_correlation()
    print(f"  fig_spectral_tropical.png — {len(uri1)} bytes")

    uri2 = plot_transport_scaling()
    print(f"  fig_transport_scaling.png — {len(uri2)} bytes")

    uri3 = plot_gap_growth()
    print(f"  fig_gap_growth.png — {len(uri3)} bytes")

    uri4 = plot_bridge_pipeline()
    print(f"  fig_bridge_pipeline.png — {len(uri4)} bytes")

    print("All visualizations generated.")
    return [uri1, uri2, uri3, uri4]


if __name__ == "__main__":
    main()
