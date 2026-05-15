#!/usr/bin/env python3
"""
Tropical Black Hole Entropy — Applications

Real-world applications of the tropical thermodynamic framework:
1. Shortest-path routing (tropical channel = Bellman equation)
2. Portfolio optimization (extremal risk minimization)
3. Network reliability (tropical channel composition)
4. Black hole area law simulation
"""

import numpy as np


def shortest_path_tropical(source_costs, edge_costs):
    """
    Solve shortest-path problem using tropical channel computation.

    The tropical channel Ch(b) = min_a [E(a) + K(a,b)] is exactly the
    Bellman equation for shortest paths.

    Parameters
    ----------
    source_costs : np.ndarray, shape (n_sources,)
        Cost of starting at each source node.
    edge_costs : np.ndarray, shape (n_sources, n_destinations)
        Cost of traversing from source i to destination j.

    Returns
    -------
    dict with 'destination_costs', 'optimal_sources', 'total_min_cost'
    """
    n_src, n_dst = edge_costs.shape
    total_costs = source_costs[:, None] + edge_costs
    best_sources = np.argmin(total_costs, axis=0)
    dest_costs = np.min(total_costs, axis=0)

    return {
        'destination_costs': dest_costs,
        'optimal_sources': best_sources,
        'total_min_cost': float(np.min(dest_costs)),
        'z_trop_input': float(np.min(source_costs)),
        'k_min': float(np.min(edge_costs)),
        'lower_bound': float(np.min(source_costs) + np.min(edge_costs)),
        'gap': float(np.min(dest_costs) - np.min(source_costs) - np.min(edge_costs))
    }


def portfolio_extremal_risk(asset_risks, correlation_costs):
    """
    Tropical portfolio optimization: minimize worst-case portfolio cost.

    Models portfolio construction as a tropical channel where:
    - Input states = individual assets with base risk
    - Channel kernel = correlation/combination costs
    - Output = portfolio configurations

    Parameters
    ----------
    asset_risks : np.ndarray, shape (n_assets,)
    correlation_costs : np.ndarray, shape (n_assets, n_portfolios)

    Returns
    -------
    dict with optimal portfolio info
    """
    total = asset_risks[:, None] + correlation_costs
    portfolio_costs = np.min(total, axis=0)
    optimal_portfolio = int(np.argmin(portfolio_costs))
    optimal_asset = int(np.argmin(total[:, optimal_portfolio]))

    return {
        'optimal_portfolio': optimal_portfolio,
        'optimal_base_asset': optimal_asset,
        'portfolio_cost': float(portfolio_costs[optimal_portfolio]),
        'all_portfolio_costs': portfolio_costs,
        'min_asset_risk': float(np.min(asset_risks)),
        'min_correlation_cost': float(np.min(correlation_costs)),
        'data_processing_gap': float(
            portfolio_costs[optimal_portfolio]
            - np.min(asset_risks)
            - np.min(correlation_costs)
        )
    }


def iterated_radiation_simulation(E_init, K, n_steps):
    """
    Simulate iterated Hawking radiation using tropical channel composition.

    At each step, the output energy landscape of one round becomes the
    input for the next: E_{t+1}(b) = min_a [E_t(a) + K(a,b)].

    Parameters
    ----------
    E_init : np.ndarray, shape (n,)
        Initial microstate energies.
    K : np.ndarray, shape (n, n)
        Radiation channel kernel (square, same in/out states).
    n_steps : int
        Number of radiation rounds.

    Returns
    -------
    dict with energy histories and tropical entropy trajectory
    """
    n = len(E_init)
    entropies = [float(np.min(E_init))]
    energies = [E_init.copy()]
    E_current = E_init.copy()

    for t in range(n_steps):
        E_next = np.min(E_current[:, None] + K, axis=0)
        E_current = E_next
        energies.append(E_current.copy())
        entropies.append(float(np.min(E_current)))

    return {
        'entropies': np.array(entropies),
        'final_energies': E_current,
        'n_steps': n_steps,
        'entropy_growth_rate': (entropies[-1] - entropies[0]) / n_steps if n_steps > 0 else 0,
        'energy_history': energies
    }


def area_law_verification(base_costs, k_over_4, areas):
    """
    Verify the tropical Bekenstein-Hawking area law.

    For E_A(i) = base(i) + (k/4)*A, verify that
    Z_trop(E_A) = Z_trop(base) + (k/4)*A.

    Parameters
    ----------
    base_costs : np.ndarray, shape (n,)
    k_over_4 : float
        The coefficient k/4.
    areas : np.ndarray
        Array of area values to test.

    Returns
    -------
    dict with verification results
    """
    Z_base = float(np.min(base_costs))
    results = []

    for A in areas:
        E_A = base_costs + k_over_4 * A
        Z_A = float(np.min(E_A))
        expected = Z_base + k_over_4 * A
        results.append({
            'area': float(A),
            'Z_trop': Z_A,
            'expected': expected,
            'error': abs(Z_A - expected),
            'matches': np.isclose(Z_A, expected)
        })

    return {
        'Z_base': Z_base,
        'k_over_4': k_over_4,
        'results': results,
        'all_match': all(r['matches'] for r in results)
    }


def demo_all_applications():
    """Run all application demonstrations."""

    print("╔══════════════════════════════════════════════════════════╗")
    print("║  TROPICAL THERMODYNAMICS — APPLICATIONS                 ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    # Application 1: Shortest Path
    print("=" * 60)
    print("APPLICATION 1: Shortest-Path Routing")
    print("=" * 60)
    print()
    print("Network: 4 servers → 3 data centers")
    source = np.array([10.0, 5.0, 8.0, 15.0])
    edges = np.array([
        [3.0, 7.0, 2.0],
        [6.0, 1.0, 8.0],
        [4.0, 3.0, 5.0],
        [2.0, 9.0, 1.0]
    ])
    result = shortest_path_tropical(source, edges)
    print(f"  Source costs: {source}")
    print(f"  Edge costs:\n{edges}")
    print(f"  Destination costs: {result['destination_costs']}")
    print(f"  Best source for each dest: {result['optimal_sources']}")
    print(f"  Optimal total cost: {result['total_min_cost']}")
    print(f"  Data-processing lower bound: {result['lower_bound']}")
    print(f"  Gap: {result['gap']}")
    print()

    # Application 2: Portfolio Optimization
    print("=" * 60)
    print("APPLICATION 2: Extremal Portfolio Risk")
    print("=" * 60)
    print()
    assets = np.array([0.05, 0.12, 0.03, 0.08, 0.15])
    correlations = np.array([
        [0.01, 0.04, 0.02],
        [0.03, 0.01, 0.05],
        [0.02, 0.03, 0.01],
        [0.04, 0.02, 0.03],
        [0.01, 0.05, 0.04]
    ])
    pf = portfolio_extremal_risk(assets, correlations)
    print(f"  Asset base risks: {assets}")
    print(f"  Optimal portfolio: #{pf['optimal_portfolio']}")
    print(f"  Optimal base asset: #{pf['optimal_base_asset']}")
    print(f"  Tropical portfolio cost: {pf['portfolio_cost']:.4f}")
    print(f"  All portfolio costs: {pf['all_portfolio_costs']}")
    print(f"  Data-processing gap: {pf['data_processing_gap']:.4f}")
    print()

    # Application 3: Iterated Radiation
    print("=" * 60)
    print("APPLICATION 3: Iterated Hawking Radiation")
    print("=" * 60)
    print()
    E0 = np.array([1.0, 3.0, 2.0])
    K_rad = np.array([
        [0.5, 1.2, 0.8],
        [1.0, 0.3, 1.5],
        [0.7, 0.9, 0.4]
    ])
    sim = iterated_radiation_simulation(E0, K_rad, 10)
    print(f"  Initial energies: {E0}")
    print(f"  Radiation kernel K:\n{K_rad}")
    print(f"  Tropical entropy over time:")
    for t, s in enumerate(sim['entropies']):
        print(f"    t={t:2d}: H_trop = {s:.4f}")
    print(f"  Entropy growth rate: {sim['entropy_growth_rate']:.4f} per step")
    print()

    # Application 4: Area Law
    print("=" * 60)
    print("APPLICATION 4: Bekenstein-Hawking Area Law")
    print("=" * 60)
    print()
    base = np.array([2.0, 0.5, 1.3, 3.1, 0.8])
    k4 = 0.25
    areas = np.array([0, 10, 50, 100, 500, 1000])
    al = area_law_verification(base, k4, areas)
    print(f"  Base costs: {base}")
    print(f"  Z_trop(base) = {al['Z_base']}")
    print(f"  k/4 = {k4}")
    print(f"  {'Area':>6s}  {'Z_trop':>10s}  {'Expected':>10s}  {'Match':>6s}")
    print(f"  {'-'*6}  {'-'*10}  {'-'*10}  {'-'*6}")
    for r in al['results']:
        print(f"  {r['area']:6.0f}  {r['Z_trop']:10.4f}  {r['expected']:10.4f}  "
              f"{'✓' if r['matches'] else '✗':>6s}")
    print(f"  All match: {al['all_match']} ✓")
    print()


if __name__ == "__main__":
    demo_all_applications()


#!/usr/bin/env python3
"""
Tropical Black Hole Entropy — Demonstration of Core Theorems

Concrete numerical examples verifying:
1. Tropical partition function = minimum energy
2. Translation invariance (area law)
3. Idempotent conservation (duplication invariance)
4. Tropical data-processing inequality
5. Equality with joint minimizers
"""

import numpy as np

def tropical_partition(E):
    """Tropical partition function: min over all microstate energies."""
    return np.min(E)

def tropical_channel(E, K):
    """Tropical channel output: for each output b, min_a (E[a] + K[a,b])."""
    return np.min(E[:, None] + K, axis=0)

def tropical_output_entropy(E, K):
    """Tropical output entropy: min_b min_a (E[a] + K[a,b])."""
    return np.min(tropical_channel(E, K))

def kernel_min(K):
    """Minimum channel cost over all input-output pairs."""
    return np.min(K)


def demo_extremal_characterization():
    """Theorem 2.1-2.3: Extremal characterization."""
    print("=" * 60)
    print("THEOREM 2.1-2.3: Extremal Characterization")
    print("=" * 60)

    E = np.array([3.0, 1.5, 2.7, 4.2, 1.5])
    Z = tropical_partition(E)
    minimizer = np.argmin(E)

    print(f"  Energies: {E}")
    print(f"  Z_trop = min(E) = {Z}")
    print(f"  Minimizer index: {minimizer}, E[{minimizer}] = {E[minimizer]}")
    print(f"  Z_trop == E[minimizer]: {Z == E[minimizer]}")

    # Verify lower bound for all states
    for i, e in enumerate(E):
        assert Z <= e, f"Lower bound violated at i={i}"
    print(f"  Z_trop ≤ E[i] for all i: ✓")
    print()


def demo_translation_invariance():
    """Theorem 3.1: Translation invariance (area law)."""
    print("=" * 60)
    print("THEOREM 3.1: Translation Invariance (Area Law)")
    print("=" * 60)

    E = np.array([3.0, 1.5, 2.7])
    c = 2.0
    E_shifted = E + c

    Z_orig = tropical_partition(E)
    Z_shifted = tropical_partition(E_shifted)

    print(f"  E = {E}")
    print(f"  c = {c}")
    print(f"  E + c = {E_shifted}")
    print(f"  Z_trop(E) = {Z_orig}")
    print(f"  Z_trop(E + c) = {Z_shifted}")
    print(f"  Z_trop(E) + c = {Z_orig + c}")
    print(f"  Equal: {np.isclose(Z_shifted, Z_orig + c)} ✓")
    print()

    # Area law: E_A(i) = base(i) + λ*A
    base = np.array([2.0, 0.5, 1.3, 3.1])
    lam = 0.25  # k/4 in Bekenstein-Hawking
    areas = [0, 10, 50, 100, 1000]

    print("  Area Law: Z_trop(base + λ*A) = Z_trop(base) + λ*A")
    print(f"  base = {base}, λ = {lam}")
    print(f"  Z_trop(base) = {tropical_partition(base)}")
    for A in areas:
        E_A = base + lam * A
        Z_A = tropical_partition(E_A)
        expected = tropical_partition(base) + lam * A
        print(f"    A = {A:4d}: Z_trop = {Z_A:8.2f}, "
              f"expected = {expected:8.2f}, match = {np.isclose(Z_A, expected)}")
    print()


def demo_idempotent_conservation():
    """Theorem 4.1-4.2: Idempotent conservation."""
    print("=" * 60)
    print("THEOREM 4.1: Idempotent Conservation")
    print("=" * 60)

    E = np.array([3.0, 1.5, 2.7])
    E_doubled = np.concatenate([E, E])  # sumEnergy E E

    Z_orig = tropical_partition(E)
    Z_doubled = tropical_partition(E_doubled)

    print(f"  E = {E}")
    print(f"  E ⊕ E = {E_doubled}")
    print(f"  Z_trop(E) = {Z_orig}")
    print(f"  Z_trop(E ⊕ E) = {Z_doubled}")
    print(f"  Equal: {Z_orig == Z_doubled} ✓ (idempotent!)")
    print()

    # Spectrum equivalence
    E1 = np.array([3.0, 1.5, 2.7])
    E2 = np.array([2.7, 3.0, 1.5, 2.7, 1.5])  # Same spectrum, different multiplicities

    print("  THEOREM 4.2: Spectrum Equivalence")
    print(f"  E1 = {E1} (spectrum: {set(E1)})")
    print(f"  E2 = {E2} (spectrum: {set(E2)})")
    print(f"  Z_trop(E1) = {tropical_partition(E1)}")
    print(f"  Z_trop(E2) = {tropical_partition(E2)}")
    print(f"  Equal: {tropical_partition(E1) == tropical_partition(E2)} ✓")
    print()


def demo_data_processing_inequality():
    """Theorem 5.1-5.2: Tropical data-processing inequality."""
    print("=" * 60)
    print("THEOREM 5.1: Tropical Data-Processing Inequality")
    print("=" * 60)

    # Example without joint minimizer (strict inequality)
    E = np.array([1.0, 3.0])
    K = np.array([[2.0, 5.0],
                   [1.0, 4.0]])

    H_out = tropical_output_entropy(E, K)
    Z_in = tropical_partition(E)
    K_min = kernel_min(K)
    lower_bound = Z_in + K_min

    ch = tropical_channel(E, K)
    print(f"  E = {E}")
    print(f"  K = {K}")
    print(f"  Channel outputs: {ch}")
    print(f"  H_out = min_b Ch(b) = {H_out}")
    print(f"  Z_trop(E) = {Z_in}")
    print(f"  K_min = {K_min}")
    print(f"  Lower bound = Z_trop(E) + K_min = {lower_bound}")
    print(f"  H_out ≥ lower bound: {H_out >= lower_bound - 1e-10} ✓")
    print(f"  Gap = {H_out - lower_bound}")
    print()

    # Example with joint minimizer (equality)
    print("  THEOREM 5.2: Equality with Joint Minimizer")
    E2 = np.array([1.0, 3.0])
    K2 = np.array([[2.0, 5.0],
                    [4.0, 7.0]])

    H_out2 = tropical_output_entropy(E2, K2)
    Z_in2 = tropical_partition(E2)
    K_min2 = kernel_min(K2)
    lower2 = Z_in2 + K_min2

    print(f"  E = {E2}")
    print(f"  K = {K2}")
    print(f"  a₀=0 minimizes E (E[0]={E2[0]} ≤ E[1]={E2[1]})")
    print(f"  (a₀,b₀)=(0,0) minimizes K (K[0,0]={K2[0,0]})")
    print(f"  H_out = {H_out2}")
    print(f"  Z_trop(E) + K_min = {lower2}")
    print(f"  Equality: {np.isclose(H_out2, lower2)} ✓")
    print()


def demo_monotonicity():
    """Theorem 6.1: Monotonicity."""
    print("=" * 60)
    print("THEOREM 6.1: Monotonicity")
    print("=" * 60)

    E1 = np.array([1.0, 2.0, 3.0])
    E2 = np.array([1.5, 2.5, 3.5])

    Z1 = tropical_partition(E1)
    Z2 = tropical_partition(E2)

    print(f"  E1 = {E1}")
    print(f"  E2 = {E2}")
    print(f"  E1[i] ≤ E2[i] for all i: {all(E1 <= E2)}")
    print(f"  Z_trop(E1) = {Z1}")
    print(f"  Z_trop(E2) = {Z2}")
    print(f"  Z_trop(E1) ≤ Z_trop(E2): {Z1 <= Z2} ✓")
    print()


def demo_classical_to_tropical_convergence():
    """Classical free energy converges to tropical partition function."""
    print("=" * 60)
    print("CONVERGENCE: Classical → Tropical (β → ∞)")
    print("=" * 60)

    E = np.array([3.0, 1.5, 2.7, 4.2])
    Z_trop = tropical_partition(E)

    betas = [0.1, 0.5, 1.0, 2.0, 5.0, 10.0, 20.0, 50.0, 100.0]
    n = len(E)

    print(f"  E = {E}")
    print(f"  Z_trop = min(E) = {Z_trop}")
    print(f"  n = {n}, log(n)/β bound applies")
    print()
    print(f"  {'β':>6s}  {'F(β)':>10s}  {'|F-Z_trop|':>12s}  {'log(n)/β':>10s}  {'Bound?':>8s}")
    print(f"  {'-'*6}  {'-'*10}  {'-'*12}  {'-'*10}  {'-'*8}")

    for beta in betas:
        log_Z = np.log(np.sum(np.exp(-beta * E)))
        F_beta = -log_Z / beta
        error = abs(F_beta - Z_trop)
        bound = np.log(n) / beta
        print(f"  {beta:6.1f}  {F_beta:10.6f}  {error:12.2e}  {bound:10.6f}  "
              f"{'✓' if error <= bound + 1e-10 else '✗':>8s}")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  TROPICAL BLACK HOLE ENTROPY — THEOREM DEMONSTRATIONS   ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_extremal_characterization()
    demo_translation_invariance()
    demo_idempotent_conservation()
    demo_data_processing_inequality()
    demo_monotonicity()
    demo_classical_to_tropical_convergence()

    print("All demonstrations completed successfully! ✓")


#!/usr/bin/env python3
"""Generate PACKAGE.json with all artifacts."""

import json
import sys
sys.path.insert(0, '/workspace/request-project')
from visualizations import generate_all_visualizations

# Read all text files
def read_file(path):
    with open(path, 'r') as f:
        return f.read()

article = read_file('/workspace/request-project/ARTICLE.md')
research_paper = read_file('/workspace/request-project/RESEARCH_PAPER.md')
future_directions = read_file('/workspace/request-project/FUTURE_DIRECTIONS.md')
lean_proofs = read_file('/workspace/request-project/Physics/TropicalGravity/TropicalBlackHoleEntropy.lean')
demo_code = read_file('/workspace/request-project/demo.py')
algorithms_code = read_file('/workspace/request-project/algorithms.py')
applications_code = read_file('/workspace/request-project/applications.py')

# Generate visualizations
figs = generate_all_visualizations()

package = {
    "title": "Tropical Gravitational Information Theory: Min-Plus Black Hole Thermodynamics",
    "domain": "Mathematical Physics / Tropical Algebra / Information Theory",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Black Hole Entropy Demonstrations",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Tropical Partition Function",
            "pseudocode": "INPUT: Energy array E[1..n]\nOUTPUT: Z_trop = min(E)\n\n1. z ← E[1]\n2. FOR i = 2 TO n:\n3.   z ← min(z, E[i])\n4. RETURN z\n\nTime: O(n), Space: O(1)",
            "code": "def tropical_partition(E):\n    \"\"\"Tropical partition function: Z_trop = min_i E(i).\"\"\"\n    import numpy as np\n    return float(np.min(E))"
        },
        {
            "name": "Tropical Channel Propagation",
            "pseudocode": "INPUT: Energy array E[1..n], Kernel K[1..n, 1..m]\nOUTPUT: Channel output Ch[1..m]\n\n1. FOR b = 1 TO m:\n2.   Ch[b] ← E[1] + K[1,b]\n3.   FOR a = 2 TO n:\n4.     Ch[b] ← min(Ch[b], E[a] + K[a,b])\n5. RETURN Ch\n\nTime: O(n*m), Space: O(m)",
            "code": "def tropical_channel_output(E, K):\n    \"\"\"Tropical channel: Ch(b) = min_a [E(a) + K(a,b)].\"\"\"\n    import numpy as np\n    return np.min(E[:, None] + K, axis=0)"
        },
        {
            "name": "Tropical Matrix Power (Iterated Radiation)",
            "pseudocode": "INPUT: Square kernel K[1..n, 1..n], power p\nOUTPUT: K^p[1..n, 1..n]\n\n1. R ← K\n2. FOR step = 2 TO p:\n3.   R_new ← matrix of +∞\n4.   FOR i = 1 TO n:\n5.     FOR j = 1 TO n:\n6.       FOR k = 1 TO n:\n7.         R_new[i,j] ← min(R_new[i,j], R[i,k] + K[k,j])\n8.   R ← R_new\n9. RETURN R\n\nTime: O(n^3 * p), Space: O(n^2)",
            "code": "def tropical_matrix_power(K, p):\n    \"\"\"Compute K^p in the tropical (min-plus) semiring.\"\"\"\n    import numpy as np\n    n = K.shape[0]\n    R = K.copy()\n    for _ in range(p - 1):\n        R_new = np.full((n, n), np.inf)\n        for k in range(n):\n            R_new = np.minimum(R_new, R[:, k:k+1] + K[k:k+1, :])\n        R = R_new\n    return R"
        },
        {
            "name": "Classical-to-Tropical Convergence (Maslov Dequantization)",
            "pseudocode": "INPUT: Energy array E[1..n], inverse temperature β\nOUTPUT: Classical free energy F(β)\n\n1. max_val ← max(-β*E[i] for i=1..n)   // for numerical stability\n2. log_Z ← max_val + log(Σ exp(-β*E[i] - max_val))\n3. F ← -log_Z / β\n4. RETURN F\n\nAs β → ∞: F(β) → min(E) = Z_trop\nError bound: |F(β) - Z_trop| ≤ log(n)/β",
            "code": "def classical_free_energy(E, beta):\n    \"\"\"F(beta) = -(1/beta) * log sum exp(-beta*E_i).\"\"\"\n    import numpy as np\n    shifted = -beta * E\n    max_val = np.max(shifted)\n    log_Z = max_val + np.log(np.sum(np.exp(shifted - max_val)))\n    return -log_Z / beta"
        }
    ],
    "visualizations": [
        {
            "name": "Classical to Tropical Convergence (Maslov Dequantization)",
            "data": figs['convergence']
        },
        {
            "name": "Tropical Data-Processing Inequality",
            "data": figs['data_processing']
        },
        {
            "name": "Bekenstein-Hawking Tropical Area Law",
            "data": figs['area_law']
        },
        {
            "name": "Iterated Hawking Radiation Dynamics",
            "data": figs['radiation']
        }
    ],
    "lean_proofs": lean_proofs
}

with open('/workspace/request-project/PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated: {len(json.dumps(package))} chars")
print("Done!")


#!/usr/bin/env python3
"""
Tropical Black Hole Entropy — Visualizations

Generates publication-quality figures:
1. Classical-to-tropical convergence (Maslov dequantization)
2. Data-processing inequality gap landscape
3. Area law linearity
4. Iterated radiation entropy trajectory
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
from io import BytesIO


def fig_to_base64(fig):
    """Convert a matplotlib figure to base64 PNG data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def plot_convergence():
    """Plot classical free energy converging to tropical partition function."""
    E = np.array([3.0, 1.5, 2.7, 4.2])
    Z_trop = np.min(E)

    betas = np.logspace(-1, 2, 200)
    F_values = []
    for beta in betas:
        shifted = -beta * E
        max_val = np.max(shifted)
        log_Z = max_val + np.log(np.sum(np.exp(shifted - max_val)))
        F_values.append(-log_Z / beta)
    F_values = np.array(F_values)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: convergence
    ax1.semilogx(betas, F_values, 'b-', linewidth=2, label=r'$F(\beta)$')
    ax1.axhline(y=Z_trop, color='r', linestyle='--', linewidth=2,
                label=r'$Z_{\mathrm{trop}} = \min_i E_i$')
    ax1.fill_between(betas, Z_trop, F_values, alpha=0.15, color='blue')
    ax1.set_xlabel(r'Inverse temperature $\beta$', fontsize=13)
    ax1.set_ylabel('Free energy', fontsize=13)
    ax1.set_title('Maslov Dequantization:\nClassical → Tropical', fontsize=14)
    ax1.legend(fontsize=12)
    ax1.grid(True, alpha=0.3)

    # Right: error decay
    errors = np.abs(F_values - Z_trop)
    n = len(E)
    bound = np.log(n) / betas

    ax2.loglog(betas, errors, 'b-', linewidth=2, label=r'$|F(\beta) - Z_{\mathrm{trop}}|$')
    ax2.loglog(betas, bound, 'r--', linewidth=2, label=r'$\log(n)/\beta$ bound')
    ax2.set_xlabel(r'Inverse temperature $\beta$', fontsize=13)
    ax2.set_ylabel('Approximation error', fontsize=13)
    ax2.set_title('Convergence Rate', fontsize=14)
    ax2.legend(fontsize=12)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Classical to Tropical Convergence', fontsize=16, y=1.02)
    fig.tight_layout()
    return fig


def plot_data_processing():
    """Plot the data-processing inequality gap for random channels."""
    np.random.seed(42)
    sizes = [3, 5, 10, 20, 50]
    n_trials = 500

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    all_gaps = {}
    for n in sizes:
        gaps = []
        for _ in range(n_trials):
            E = np.random.exponential(2.0, size=n)
            K = np.random.exponential(1.0, size=(n, n))
            ch = np.min(E[:, None] + K, axis=0)
            H_out = np.min(ch)
            lower = np.min(E) + np.min(K)
            gaps.append(H_out - lower)
        all_gaps[n] = np.array(gaps)

    # Left: histogram of gaps
    for n in sizes:
        ax1.hist(all_gaps[n], bins=30, alpha=0.5, label=f'n={n}', density=True)
    ax1.axvline(x=0, color='red', linestyle='--', linewidth=2, label='Bound (gap=0)')
    ax1.set_xlabel('Data-processing gap Δ', fontsize=13)
    ax1.set_ylabel('Density', fontsize=13)
    ax1.set_title('Distribution of DPI Gap\n(always ≥ 0, Theorem 5.1)', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Right: box plot
    data = [all_gaps[n] for n in sizes]
    bp = ax2.boxplot(data, labels=[str(n) for n in sizes], patch_artist=True)
    colors = plt.cm.viridis(np.linspace(0.2, 0.8, len(sizes)))
    for patch, color in zip(bp['boxes'], colors):
        patch.set_facecolor(color)
        patch.set_alpha(0.7)
    ax2.set_xlabel('Channel size n', fontsize=13)
    ax2.set_ylabel('Data-processing gap Δ', fontsize=13)
    ax2.set_title('Gap vs Channel Size\n(median gap increases with n)', fontsize=14)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Tropical Data-Processing Inequality', fontsize=16, y=1.02)
    fig.tight_layout()
    return fig


def plot_area_law():
    """Plot the tropical area law: Z_trop linear in area."""
    base = np.array([2.0, 0.5, 1.3, 3.1, 0.8])
    Z_base = np.min(base)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: different k/4 values
    k_values = [0.1, 0.25, 0.5, 1.0]
    areas = np.linspace(0, 100, 200)

    for k4 in k_values:
        Z_values = [np.min(base + k4 * A) for A in areas]
        ax1.plot(areas, Z_values, linewidth=2, label=f'k/4 = {k4}')
        # Expected line
        expected = Z_base + k4 * areas
        ax1.plot(areas, expected, '--', linewidth=1, alpha=0.5)

    ax1.set_xlabel('Horizon area A', fontsize=13)
    ax1.set_ylabel(r'$Z_{\mathrm{trop}}(E_A)$', fontsize=13)
    ax1.set_title('Tropical Area Law\n(solid = computed, dashed = predicted)', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    # Right: error (should be exactly 0)
    k4 = 0.25
    areas_test = np.linspace(0, 1000, 500)
    errors = []
    for A in areas_test:
        Z = np.min(base + k4 * A)
        expected = Z_base + k4 * A
        errors.append(abs(Z - expected))

    ax2.plot(areas_test, errors, 'r-', linewidth=2)
    ax2.set_xlabel('Horizon area A', fontsize=13)
    ax2.set_ylabel('|Z_trop - predicted|', fontsize=13)
    ax2.set_title(f'Area Law Error (k/4 = {k4})\n(machine precision: identity is exact)', fontsize=14)
    ax2.set_ylim(-1e-16, max(errors) * 1.5 + 1e-16)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Bekenstein-Hawking Tropical Area Law', fontsize=16, y=1.02)
    fig.tight_layout()
    return fig


def plot_iterated_radiation():
    """Plot entropy trajectory under iterated tropical radiation."""
    np.random.seed(123)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    n_steps = 20

    # Left: different initial conditions, same kernel
    K = np.array([
        [0.5, 1.2, 0.8],
        [1.0, 0.3, 1.5],
        [0.7, 0.9, 0.4]
    ])

    initials = [
        np.array([1.0, 3.0, 2.0]),
        np.array([5.0, 5.0, 5.0]),
        np.array([0.1, 10.0, 5.0]),
    ]
    labels = ['Varied', 'Uniform', 'Extreme']

    for E0, label in zip(initials, labels):
        entropies = [np.min(E0)]
        E = E0.copy()
        for _ in range(n_steps):
            E = np.min(E[:, None] + K, axis=0)
            entropies.append(np.min(E))
        ax1.plot(range(n_steps + 1), entropies, 'o-', linewidth=2,
                 markersize=4, label=f'{label}: E₀={E0}')

    ax1.set_xlabel('Radiation step t', fontsize=13)
    ax1.set_ylabel(r'$H_{\mathrm{trop}}(t)$', fontsize=13)
    ax1.set_title('Tropical Entropy Under\nIterated Radiation', fontsize=14)
    ax1.legend(fontsize=9)
    ax1.grid(True, alpha=0.3)

    # Right: growth rate converges to tropical eigenvalue
    sizes = [3, 5, 8]
    for n in sizes:
        K_rand = np.random.exponential(1.0, size=(n, n))
        E0 = np.random.exponential(2.0, size=n)
        n_long = 50

        entropies = [np.min(E0)]
        E = E0.copy()
        for _ in range(n_long):
            E = np.min(E[:, None] + K_rand, axis=0)
            entropies.append(np.min(E))

        entropies = np.array(entropies)
        rates = np.diff(entropies)

        ax2.plot(range(1, n_long + 1), rates, '-', linewidth=2,
                 alpha=0.8, label=f'n={n}')

    ax2.set_xlabel('Radiation step t', fontsize=13)
    ax2.set_ylabel(r'$\Delta H_{\mathrm{trop}}$ per step', fontsize=13)
    ax2.set_title('Entropy Growth Rate\n(converges to tropical eigenvalue)', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Iterated Hawking Radiation Dynamics', fontsize=16, y=1.02)
    fig.tight_layout()
    return fig


def generate_all_visualizations():
    """Generate all figures and return as base64 data URIs."""
    figs = {}

    print("Generating convergence plot...")
    fig = plot_convergence()
    figs['convergence'] = fig_to_base64(fig)

    print("Generating data-processing plot...")
    fig = plot_data_processing()
    figs['data_processing'] = fig_to_base64(fig)

    print("Generating area law plot...")
    fig = plot_area_law()
    figs['area_law'] = fig_to_base64(fig)

    print("Generating radiation plot...")
    fig = plot_iterated_radiation()
    figs['radiation'] = fig_to_base64(fig)

    print(f"Generated {len(figs)} visualizations.")
    return figs


if __name__ == "__main__":
    figs = generate_all_visualizations()
    for name, data_uri in figs.items():
        print(f"  {name}: {len(data_uri)} chars")
    print("All visualizations generated successfully! ✓")
