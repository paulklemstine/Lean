#!/usr/bin/env python3
"""
Applications of Tropical Perturbation Amplification.

Demonstrates real-world applications of the tensorization principle:
1. Channel capacity estimation (information theory)
2. Automata state space growth (formal languages)
3. Robustness certification (optimization)
"""

import math
import itertools
from typing import List, Dict, Tuple

# ============================================================
# Application 1: Channel Capacity via Tropical Tensorization
# ============================================================

def channel_capacity_tropical(alphabet_size: int, n_uses: int) -> float:
    """Estimate channel capacity using tropical tensorization.

    The tropical perturbation bound log(|S|) serves as a capacity-like
    measure. For n independent uses of a channel with alphabet S,
    the total capacity is n · log(|S|) by the amplification theorem.

    This models the fundamental theorem: capacity grows linearly
    in the number of independent channel uses.

    Args:
        alphabet_size: Size of the channel alphabet.
        n_uses: Number of independent channel uses.

    Returns:
        Total capacity in nats.
    """
    return n_uses * math.log(alphabet_size)


def demo_channel_capacity():
    """Demonstrate channel capacity scaling."""
    print("=" * 60)
    print("APPLICATION 1: Channel Capacity via Tropical Tensorization")
    print("=" * 60)
    print()

    alphabets = [2, 4, 8, 16, 256]
    max_n = 10

    for q in alphabets:
        capacities = [channel_capacity_tropical(q, n) for n in range(1, max_n + 1)]
        bits = [c / math.log(2) for c in capacities]
        print(f"Alphabet size q={q:3d}:")
        print(f"  Capacity (bits) for n=1..{max_n}: "
              + ", ".join(f"{b:.1f}" for b in bits))
        print(f"  Rate per use: {math.log(q)/math.log(2):.2f} bits/use")
    print()


# ============================================================
# Application 2: Automata State Space Growth
# ============================================================

def automata_state_growth(base_states: int, composition_depth: int) -> Dict[str, float]:
    """Analyze state space growth under automaton composition.

    The exponential multiplicativity theorem says:
    exp(bound(S^n)) = exp(bound(S))^n = |S|^n

    For automata, this means the number of distinguishable states
    in a product automaton grows exponentially with composition depth.

    Args:
        base_states: Number of states in the base automaton.
        composition_depth: Number of composed copies.

    Returns:
        Dictionary with tropical bound, state count, and growth rate.
    """
    bound = composition_depth * math.log(base_states)
    state_count = base_states ** composition_depth
    growth_rate = math.log(base_states)  # per composition step

    return {
        'tropical_bound': bound,
        'state_count': state_count,
        'growth_rate': growth_rate,
        'growth_rate_bits': growth_rate / math.log(2),
    }


def demo_automata_growth():
    """Demonstrate automata state space growth."""
    print("=" * 60)
    print("APPLICATION 2: Automata State Space Growth")
    print("=" * 60)
    print()

    base_states = 5
    print(f"Base automaton: {base_states} states")
    print(f"Growth rate: log({base_states}) = {math.log(base_states):.4f} nats/step "
          f"= {math.log(base_states)/math.log(2):.4f} bits/step")
    print()

    print(f"{'Depth':>6s} {'Bound':>10s} {'States':>12s} {'States(exp)':>14s}")
    print("-" * 44)
    for d in range(1, 9):
        result = automata_state_growth(base_states, d)
        print(f"{d:6d} {result['tropical_bound']:10.4f} {result['state_count']:12d} "
              f"{math.exp(result['tropical_bound']):14.1f}")
    print()


# ============================================================
# Application 3: Robustness Certification
# ============================================================

def certify_robustness(
    factor_perturbations: List[float],
    support_sizes: List[int]
) -> Dict[str, float]:
    """Certify robustness of a product system.

    Using the separable perturbation theorem:
    - Each factor has perturbation bound ε_i
    - The product perturbation is bounded by Σ ε_i
    - The complexity of the product support is Σ log(|S_i|)

    This gives a certified robustness guarantee for the composed system.

    Args:
        factor_perturbations: List of per-factor perturbation bounds.
        support_sizes: List of per-factor support sizes.

    Returns:
        Dictionary with total perturbation bound, complexity, and efficiency.
    """
    total_perturbation = sum(factor_perturbations)
    total_complexity = sum(math.log(s) for s in support_sizes)
    product_support_size = 1
    for s in support_sizes:
        product_support_size *= s

    # Efficiency: perturbation per unit complexity
    efficiency = total_perturbation / total_complexity if total_complexity > 0 else float('inf')

    return {
        'total_perturbation_bound': total_perturbation,
        'total_complexity': total_complexity,
        'product_support_size': product_support_size,
        'n_factors': len(factor_perturbations),
        'perturbation_per_complexity': efficiency,
    }


def demo_robustness():
    """Demonstrate robustness certification."""
    print("=" * 60)
    print("APPLICATION 3: Robustness Certification for Composed Systems")
    print("=" * 60)
    print()

    # Scenario: composing multiple independent subsystems
    scenarios = [
        ("Small system (3 factors)", [0.01, 0.02, 0.015], [10, 20, 15]),
        ("Medium system (5 factors)", [0.01]*5, [100]*5),
        ("Heterogeneous (4 factors)", [0.1, 0.001, 0.05, 0.02], [5, 1000, 50, 200]),
        ("Large scale (8 factors)", [0.005]*8, [50]*8),
    ]

    for name, perturbs, sizes in scenarios:
        result = certify_robustness(perturbs, sizes)
        print(f"{name}:")
        print(f"  Factors: {result['n_factors']}")
        print(f"  Per-factor ε: {perturbs}")
        print(f"  Per-factor |S|: {sizes}")
        print(f"  Total perturbation bound: {result['total_perturbation_bound']:.6f}")
        print(f"  Total complexity (Σ log|Si|): {result['total_complexity']:.4f}")
        print(f"  Product support size: {result['product_support_size']:.2e}")
        print(f"  Perturbation/complexity ratio: {result['perturbation_per_complexity']:.6f}")
        print()


# ============================================================
# Application 4: Tropical Free Energy Computation
# ============================================================

def tropical_free_energy(
    energies: Dict, temperature: float = 1.0
) -> float:
    """Compute tropical free energy (zero-temperature limit).

    In statistical mechanics, F = -T log Z where Z = Σ exp(-E_i/T).
    In the tropical (T → 0) limit, F → min(E_i).

    The tropical perturbation bound measures the "entropy" contribution:
    log(|S|) counts the number of accessible microstates.

    Args:
        energies: Dictionary mapping states to energies.
        temperature: Temperature parameter.

    Returns:
        Free energy estimate.
    """
    if temperature > 0:
        Z = sum(math.exp(-E / temperature) for E in energies.values())
        return -temperature * math.log(Z)
    else:
        return min(energies.values())


def demo_free_energy():
    """Demonstrate tropical free energy for product systems."""
    print("=" * 60)
    print("APPLICATION 4: Tropical Free Energy Extensivity")
    print("=" * 60)
    print()

    # Two independent subsystems
    E1 = {0: 1.0, 1: 2.0, 2: 0.5}
    E2 = {0: 0.3, 1: 1.5}

    # Product energies
    E_prod = {(s, t): E1[s] + E2[t] for s in E1 for t in E2}

    print("Subsystem 1 energies:", E1)
    print("Subsystem 2 energies:", E2)
    print()

    temps = [10.0, 1.0, 0.1, 0.01]
    print(f"{'T':>8s} {'F1':>10s} {'F2':>10s} {'F1+F2':>10s} {'F(prod)':>10s} {'diff':>10s}")
    print("-" * 60)

    for T in temps:
        F1 = tropical_free_energy(E1, T)
        F2 = tropical_free_energy(E2, T)
        F_prod = tropical_free_energy(E_prod, T)
        diff = abs(F_prod - (F1 + F2))
        print(f"{T:8.3f} {F1:10.6f} {F2:10.6f} {F1+F2:10.6f} {F_prod:10.6f} {diff:10.2e}")

    # Zero temperature (tropical limit)
    F1_trop = min(E1.values())
    F2_trop = min(E2.values())
    F_prod_trop = min(E_prod.values())
    print(f"{'0 (trop)':>8s} {F1_trop:10.6f} {F2_trop:10.6f} "
          f"{F1_trop+F2_trop:10.6f} {F_prod_trop:10.6f} "
          f"{abs(F_prod_trop - (F1_trop + F2_trop)):10.2e}")

    print(f"\nTropical entropy (log |S|):")
    print(f"  System 1: log({len(E1)}) = {math.log(len(E1)):.4f}")
    print(f"  System 2: log({len(E2)}) = {math.log(len(E2)):.4f}")
    print(f"  Product:  log({len(E_prod)}) = {math.log(len(E_prod)):.4f}")
    print(f"  Sum:      {math.log(len(E1)) + math.log(len(E2)):.4f}")
    print()


if __name__ == "__main__":
    demo_channel_capacity()
    demo_automata_growth()
    demo_robustness()
    demo_free_energy()

    print("=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Perturbation Amplification: Numerical Demonstrations

Demonstrates the key theorems from the formal development:
1. Tropical max functional separability on products
2. Log-cardinality additivity under Cartesian products
3. N-fold amplification (scaling law)
4. Separable perturbation stability
"""

import numpy as np
import itertools
from typing import List, Tuple, Callable

# ============================================================
# 1. Tropical Max Functional
# ============================================================

def trop_max(support: List, weights: dict, f: Callable) -> float:
    """Compute the tropical max functional: max_{s in S} (f(s) + w(s))"""
    return max(f(s) + weights[s] for s in support)


def demo_tropical_max():
    """Demonstrate the tropical max functional on simple examples."""
    print("=" * 60)
    print("DEMO 1: Tropical Max Functional")
    print("=" * 60)

    S = [1, 2, 3]
    w = {1: 0.5, 2: 1.0, 3: -0.5}

    f1 = lambda x: x ** 2
    f2 = lambda x: -x

    val1 = trop_max(S, w, f1)
    val2 = trop_max(S, w, f2)

    print(f"Support S = {S}")
    print(f"Weights w = {w}")
    print(f"f1(x) = x^2:  tropMax(S, w, f1) = {val1}")
    print(f"f2(x) = -x:   tropMax(S, w, f2) = {val2}")
    print(f"max(f1, f2):   tropMax(S, w, max(f1,f2)) = "
          f"{trop_max(S, w, lambda x: max(f1(x), f2(x)))}")
    print(f"max(val1, val2) = {max(val1, val2)}")
    print(f"Sup-preservation verified: {abs(trop_max(S, w, lambda x: max(f1(x), f2(x))) - max(val1, val2)) < 1e-10}")
    print()


# ============================================================
# 2. Product Separability
# ============================================================

def demo_product_separability():
    """Demonstrate that tropMax on products with separable weights/functions decomposes."""
    print("=" * 60)
    print("DEMO 2: Product Separability (tropMax_product_separable)")
    print("=" * 60)

    S = [1, 2, 3]
    T = ['a', 'b']

    w1 = {1: 0.5, 2: 1.0, 3: -0.5}
    w2 = {'a': 0.3, 'b': -0.2}

    f1_func = lambda s: s * 0.7
    f2_func = lambda t: 1.0 if t == 'a' else 2.0

    # Product support
    ST = list(itertools.product(S, T))
    w_prod = {(s, t): w1[s] + w2[t] for s in S for t in T}
    f_prod = lambda p: f1_func(p[0]) + f2_func(p[1])

    # Compute on product
    val_product = trop_max(ST, w_prod, f_prod)

    # Compute on factors
    val_S = trop_max(S, w1, f1_func)
    val_T = trop_max(T, w2, f2_func)

    print(f"S = {S}, T = {T}")
    print(f"w1 = {w1}, w2 = {w2}")
    print(f"tropMax(S×T, w1⊕w2, f1⊕f2) = {val_product:.6f}")
    print(f"tropMax(S, w1, f1) + tropMax(T, w2, f2) = {val_S:.6f} + {val_T:.6f} = {val_S + val_T:.6f}")
    print(f"Separability verified: {abs(val_product - (val_S + val_T)) < 1e-10}")
    print()


# ============================================================
# 3. Log-Cardinality Additivity
# ============================================================

def tropical_perturbation_bound(support_size: int) -> float:
    """The tropical perturbation bound: log(|S|)"""
    return np.log(support_size)


def demo_log_additivity():
    """Demonstrate log(|S × T|) = log(|S|) + log(|T|)."""
    print("=" * 60)
    print("DEMO 3: Log-Cardinality Additivity (Main Tensorization Law)")
    print("=" * 60)

    test_cases = [
        (3, 4),
        (5, 7),
        (10, 10),
        (2, 100),
        (1, 50),
    ]

    for card_s, card_t in test_cases:
        bound_product = tropical_perturbation_bound(card_s * card_t)
        bound_s = tropical_perturbation_bound(card_s)
        bound_t = tropical_perturbation_bound(card_t)
        diff = abs(bound_product - (bound_s + bound_t))
        print(f"|S|={card_s:3d}, |T|={card_t:3d}: "
              f"log({card_s*card_t:5d}) = {bound_product:.6f}, "
              f"log({card_s}) + log({card_t}) = {bound_s + bound_t:.6f}, "
              f"diff = {diff:.2e}")

    print()


# ============================================================
# 4. N-fold Amplification
# ============================================================

def demo_n_fold_amplification():
    """Demonstrate log(|S^n|) = n · log(|S|)."""
    print("=" * 60)
    print("DEMO 4: N-fold Amplification Law")
    print("=" * 60)

    card_s = 5
    base_bound = tropical_perturbation_bound(card_s)

    print(f"Base support size |S| = {card_s}, base bound = log({card_s}) = {base_bound:.6f}")
    print(f"{'n':>3s} {'|S^n|':>12s} {'log(|S^n|)':>12s} {'n·log(|S|)':>12s} {'diff':>10s}")
    print("-" * 55)

    for n in range(1, 9):
        card_sn = card_s ** n
        bound_sn = tropical_perturbation_bound(card_sn)
        n_times_bound = n * base_bound
        diff = abs(bound_sn - n_times_bound)
        print(f"{n:3d} {card_sn:12d} {bound_sn:12.6f} {n_times_bound:12.6f} {diff:10.2e}")

    print()


# ============================================================
# 5. Perturbation Stability
# ============================================================

def demo_perturbation_stability():
    """Demonstrate separable perturbation stability on products."""
    print("=" * 60)
    print("DEMO 5: Separable Perturbation Stability")
    print("=" * 60)

    S = list(range(1, 6))
    T = list(range(1, 4))

    np.random.seed(42)
    w1 = {s: np.random.randn() for s in S}
    w2 = {t: np.random.randn() for t in T}

    eps1, eps2 = 0.1, 0.05

    # Perturbed weights
    w1p = {s: w1[s] + np.random.uniform(-eps1, eps1) for s in S}
    w2p = {t: w2[t] + np.random.uniform(-eps2, eps2) for t in T}

    # Check factor bounds
    max_diff1 = max(abs(w1[s] - w1p[s]) for s in S)
    max_diff2 = max(abs(w2[t] - w2p[t]) for t in T)

    # Product weights
    ST = list(itertools.product(S, T))
    w_prod = {(s, t): w1[s] + w2[t] for s in S for t in T}
    w_prod_p = {(s, t): w1p[s] + w2p[t] for s in S for t in T}

    # Test functional differences on random inputs
    max_func_diff = 0.0
    for _ in range(1000):
        f_vals = {p: np.random.randn() for p in ST}
        f_func = lambda p, fv=f_vals: fv[p]
        val1 = trop_max(ST, w_prod, f_func)
        val2 = trop_max(ST, w_prod_p, f_func)
        max_func_diff = max(max_func_diff, abs(val1 - val2))

    print(f"|S| = {len(S)}, |T| = {len(T)}")
    print(f"Max |w1 - w1'| = {max_diff1:.6f} ≤ ε₁ = {eps1}")
    print(f"Max |w2 - w2'| = {max_diff2:.6f} ≤ ε₂ = {eps2}")
    print(f"Max |F - F'| over 1000 random inputs = {max_func_diff:.6f}")
    print(f"Theoretical bound ε₁ + ε₂ = {eps1 + eps2:.6f}")
    print(f"Stability verified: {max_func_diff <= eps1 + eps2 + 1e-10}")
    print()


# ============================================================
# 6. Exponential Multiplicativity
# ============================================================

def demo_exponential():
    """Demonstrate exp(bound(S×T)) = exp(bound(S)) · exp(bound(T))."""
    print("=" * 60)
    print("DEMO 6: Exponential Multiplicativity")
    print("=" * 60)

    test_cases = [(3, 5), (7, 11), (2, 8), (4, 4)]

    for cs, ct in test_cases:
        bound_s = tropical_perturbation_bound(cs)
        bound_t = tropical_perturbation_bound(ct)
        bound_st = tropical_perturbation_bound(cs * ct)

        exp_product = np.exp(bound_st)
        exp_s_times_exp_t = np.exp(bound_s) * np.exp(bound_t)

        print(f"|S|={cs}, |T|={ct}: exp(bound(S×T)) = {exp_product:.4f}, "
              f"exp(bound(S))·exp(bound(T)) = {exp_s_times_exp_t:.4f}, "
              f"(= |S|·|T| = {cs*ct})")

    print()


if __name__ == "__main__":
    demo_tropical_max()
    demo_product_separability()
    demo_log_additivity()
    demo_n_fold_amplification()
    demo_perturbation_stability()
    demo_exponential()

    print("=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for Tropical Perturbation Amplification.
Generates PNG figures for the research paper and article.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')


def fig1_tensorization_law():
    """Visualize log(|S×T|) = log(|S|) + log(|T|) across support sizes."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: 3D surface showing additivity
    card_s = np.arange(1, 21)
    card_t = np.arange(1, 21)
    CS, CT = np.meshgrid(card_s, card_t)

    bound_product = np.log(CS * CT)
    bound_sum = np.log(CS) + np.log(CT)

    ax = axes[0]
    c = ax.pcolormesh(CS, CT, bound_product, shading='auto', cmap='viridis')
    ax.set_xlabel('|S|', fontsize=12)
    ax.set_ylabel('|T|', fontsize=12)
    ax.set_title('Tropical Perturbation Bound\nlog(|S × T|)', fontsize=13)
    fig.colorbar(c, ax=ax, label='log(|S × T|)')

    # Right: residual (should be zero)
    ax = axes[1]
    residual = bound_product - bound_sum
    c = ax.pcolormesh(CS, CT, np.abs(residual), shading='auto', cmap='Reds')
    ax.set_xlabel('|S|', fontsize=12)
    ax.set_ylabel('|T|', fontsize=12)
    ax.set_title('Tensorization Residual\n|log(|S×T|) - log(|S|) - log(|T|)|', fontsize=13)
    fig.colorbar(c, ax=ax, label='Residual (≈ 0)')

    plt.tight_layout()
    plt.savefig('fig1_tensorization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fig1_tensorization.png")


def fig2_n_fold_amplification():
    """Visualize the n-fold amplification law."""
    fig, ax = plt.subplots(figsize=(10, 6))

    for card_s in [2, 3, 5, 7, 10]:
        ns = np.arange(1, 11)
        bounds = ns * np.log(card_s)
        ax.plot(ns, bounds, 'o-', label=f'|S| = {card_s}', markersize=6, linewidth=2)

    ax.set_xlabel('n (number of copies)', fontsize=13)
    ax.set_ylabel('Tropical Perturbation Bound log(|S|ⁿ)', fontsize=13)
    ax.set_title('N-fold Amplification: log(|S|ⁿ) = n · log(|S|)', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_xticks(range(1, 11))

    plt.tight_layout()
    plt.savefig('fig2_amplification.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fig2_amplification.png")


def fig3_perturbation_stability():
    """Visualize perturbation stability: errors add under composition."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    np.random.seed(42)

    # Left: empirical functional error vs theoretical bound
    ax = axes[0]
    eps_vals = np.linspace(0.01, 1.0, 30)
    card_s, card_t = 5, 4

    empirical_maxes = []
    for eps in eps_vals:
        max_diff = 0
        S = list(range(card_s))
        T = list(range(card_t))
        w1 = {s: np.random.randn() for s in S}
        w2 = {t: np.random.randn() for t in T}
        w1p = {s: w1[s] + np.random.uniform(-eps, eps) for s in S}
        w2p = {t: w2[t] + np.random.uniform(-eps, eps) for t in T}

        for _ in range(500):
            f_vals = {(s, t): np.random.randn() for s in S for t in T}
            val1 = max(f_vals[(s, t)] + w1[s] + w2[t] for s in S for t in T)
            val2 = max(f_vals[(s, t)] + w1p[s] + w2p[t] for s in S for t in T)
            max_diff = max(max_diff, abs(val1 - val2))
        empirical_maxes.append(max_diff)

    ax.plot(eps_vals, 2 * eps_vals, 'r--', linewidth=2, label='Theoretical: ε₁ + ε₂ = 2ε')
    ax.plot(eps_vals, empirical_maxes, 'b.', markersize=8, label='Empirical max |F - F\'|')
    ax.set_xlabel('ε (per-factor perturbation)', fontsize=12)
    ax.set_ylabel('Functional difference', fontsize=12)
    ax.set_title('Perturbation Stability:\nErrors Add Under Composition', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # Right: stability constant = 1 (non-amplification)
    ax = axes[1]
    support_sizes = range(2, 51)
    stability_constants = [1.0] * len(list(support_sizes))

    ax.bar(list(support_sizes), stability_constants, color='steelblue', alpha=0.7)
    ax.axhline(y=1.0, color='red', linestyle='--', linewidth=2, label='Stability constant = 1')
    ax.set_xlabel('Support size |S|', fontsize=12)
    ax.set_ylabel('Stability constant', fontsize=12)
    ax.set_title('Stability Constant Is Exactly 1\n(No Amplification of Noise)', fontsize=13)
    ax.set_ylim(0, 2)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('fig3_stability.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fig3_stability.png")


def fig4_exponential_multiplicativity():
    """Visualize exp(bound(S×T)) = exp(bound(S)) · exp(bound(T)) = |S|·|T|."""
    fig, ax = plt.subplots(figsize=(10, 6))

    card_s_vals = range(1, 11)
    card_t = 5

    exp_bounds = [np.exp(np.log(cs * card_t)) for cs in card_s_vals]
    products = [cs * card_t for cs in card_s_vals]

    ax.bar(list(card_s_vals), exp_bounds, color='coral', alpha=0.7, label='exp(bound(S×T))')
    ax.plot(list(card_s_vals), products, 'ko-', markersize=8, linewidth=2, label='|S| · |T|')
    ax.set_xlabel('|S|', fontsize=13)
    ax.set_ylabel('exp(tropical perturbation bound)', fontsize=13)
    ax.set_title(f'Exponential Multiplicativity (|T| = {card_t})\n'
                 f'exp(log(|S×T|)) = |S| · |T|', fontsize=14)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('fig4_exponential.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fig4_exponential.png")


if __name__ == "__main__":
    fig1_tensorization_law()
    fig2_n_fold_amplification()
    fig3_perturbation_stability()
    fig4_exponential_multiplicativity()
    print("\nAll visualizations generated.")
