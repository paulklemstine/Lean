"""
Retrocausal Proof Theory: Interactive Demo

Demonstrates the key concepts of retrocausal proof theory with
concrete examples and numerical experiments.
"""

from algorithms import (
    ConsequenceSystem,
    retrocausal_search,
    generate_random_system,
    find_discrimination_chain,
    measure_compression_statistics,
)
import random


def demo_example_system():
    """Demo 1: The canonical 3-element consequence system."""
    print("=" * 60)
    print("DEMO 1: Canonical 3-Element Consequence System")
    print("=" * 60)

    system = ConsequenceSystem(
        propositions=frozenset({0, 1, 2}),
        provable=frozenset({0, 1}),
        consequences={
            0: frozenset({0, 1}),
            1: frozenset({1}),
            2: frozenset(),
        },
        complexity={0: 1, 1: 1, 2: 1},
    )

    print("\nUniverse: {0, 1, 2}")
    print("Provable: {0, 1}")
    print()

    for p in [0, 1, 2]:
        cons = sorted(system.consequences[p])
        stable = system.is_stable(p)
        sep = system.is_separated(p)
        maximal = system.is_consequence_maximal(p)
        print(f"  Prop {p}: consequences={cons}, stable={stable}, "
              f"separated={sep}, maximal={maximal}")

    print("\n--- Retrocausal Search for Proposition 0 ---")
    candidates, verifs, history = retrocausal_search(system, 0)
    for i, (v, c) in enumerate(zip(verifs, history[1:])):
        prev = history[i]
        print(f"  Step {i+1}: Verify consequence {v}")
        print(f"    Compression: {prev:.3f} → {c:.3f}")

    print(f"  Final candidates: {sorted(candidates)}")
    print(f"  Result: {'UNIQUE' if len(candidates) == 1 else 'AMBIGUOUS'}")


def demo_larger_system():
    """Demo 2: A larger system showing exponential compression."""
    print("\n" + "=" * 60)
    print("DEMO 2: 10-Element System with Exponential Compression")
    print("=" * 60)

    # Create a system where each prop has a unique binary signature
    n = 10
    propositions = frozenset(range(n))

    # Each proposition p has consequences = {q : bit q of p is 1}
    # This gives injective consequences (each prop has unique set)
    consequences = {}
    for p in range(n):
        cons = frozenset(q for q in range(4) if (p >> q) & 1)
        consequences[p] = cons

    provable = frozenset(range(4))  # All "bit" propositions are provable

    system = ConsequenceSystem(
        propositions=propositions,
        provable=provable,
        consequences=consequences,
        complexity={p: 1 for p in range(n)},
    )

    print(f"\nUniverse size: {n}")
    print(f"Consequence 'bits': {sorted(provable)}")
    print()

    for p in range(n):
        cons = sorted(system.consequences[p])
        print(f"  Prop {p}: consequences={cons} (binary={p:04b})")

    # Search for proposition 7 (binary 0111, consequences = {0, 1, 2})
    target = 7
    print(f"\n--- Retrocausal Search for Proposition {target} ---")
    candidates, verifs, history = retrocausal_search(system, target)
    for i, (v, c) in enumerate(zip(verifs, history[1:])):
        prev = history[i]
        cand = system.candidates_for(frozenset(verifs[:i+1]))
        print(f"  Step {i+1}: Verify consequence {v}")
        print(f"    Candidates: {len(cand)}/{n} "
              f"(compression: {prev:.2f} → {c:.2f})")

    print(f"  Final candidates: {sorted(candidates)}")


def demo_compression_statistics():
    """Demo 3: Statistical analysis of compression across random systems."""
    print("\n" + "=" * 60)
    print("DEMO 3: Compression Statistics (100 random systems)")
    print("=" * 60)

    for density in [0.1, 0.3, 0.5]:
        stats = measure_compression_statistics(
            n_trials=100,
            system_size=30,
            consequence_density=density,
        )
        print(f"\n  Consequence density = {density}")
        print(f"    Avg final compression ratio: {stats['avg_final_compression']:.4f}")
        print(f"    Avg discrimination chain length: {stats['avg_chain_length']:.1f}")
        print(f"    Separation rate: {stats['separation_rate']:.4f}")
        print(f"    Stability rate: {stats['stability_rate']:.4f}")


def demo_discrimination_chain():
    """Demo 4: Finding and analyzing discrimination chains."""
    print("\n" + "=" * 60)
    print("DEMO 4: Discrimination Chain Analysis")
    print("=" * 60)

    system = generate_random_system(20, consequence_density=0.25, seed=42)

    print(f"\nSystem: {len(system.propositions)} propositions")
    print(f"Provable: {len(system.provable)}")

    chain = find_discrimination_chain(
        system, frozenset(), list(system.propositions)
    )
    print(f"Maximal discrimination chain length: {len(chain)}")

    # Show compression at each step
    observed = set()
    for i, q in enumerate(chain[:10]):  # Show first 10 steps
        observed.add(q)
        cands = system.candidates_for(frozenset(observed))
        ratio = len(cands) / len(system.propositions)
        print(f"  Step {i+1}: Add consequence {q}, "
              f"candidates={len(cands)}, ratio={ratio:.3f}")


def demo_separation_vs_stability():
    """Demo 5: Exploring the gap between stability and provability."""
    print("\n" + "=" * 60)
    print("DEMO 5: Stability vs. Provability Gap")
    print("=" * 60)

    # System where all propositions are stable but some are unprovable
    system = ConsequenceSystem(
        propositions=frozenset(range(5)),
        provable=frozenset({0, 1}),
        consequences={
            0: frozenset({0}),
            1: frozenset({1}),
            2: frozenset(),  # Empty consequences → vacuously stable
            3: frozenset(),
            4: frozenset({0, 1}),  # Consequences are provable
        },
        complexity={p: p + 1 for p in range(5)},
    )

    print("\n  Prop | Provable | Stable | Status")
    print("  " + "-" * 40)
    for p in range(5):
        prov = p in system.provable
        stable = system.is_stable(p)
        if prov and stable:
            status = "Provable & Stable ✓"
        elif stable and not prov:
            status = "Stable but UNPROVABLE ⚠"
        elif prov and not stable:
            status = "Provable but UNSTABLE ✗"
        else:
            status = "Neither"
        print(f"    {p}  |  {str(prov):5s}   | {str(stable):5s}  | {status}")

    stable_count = sum(1 for p in range(5) if system.is_stable(p))
    provable_count = len(system.provable)
    print(f"\n  Stable: {stable_count}/5, Provable: {provable_count}/5")
    print("  Gap demonstrates Theorem 3.2: stability ⇏ provability")


if __name__ == "__main__":
    demo_example_system()
    demo_larger_system()
    demo_compression_statistics()
    demo_discrimination_chain()
    demo_separation_vs_stability()
    print("\n" + "=" * 60)
    print("All demos complete.")


"""
Visualization: Retrocausal Compression Ratio

Plots the compression ratio as a function of the number of
verified consequences, demonstrating exponential narrowing
of the search space.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import random


def generate_random_system(n, consequence_density=0.3, provable_fraction=0.5, seed=None):
    if seed is not None:
        random.seed(seed)
    propositions = list(range(n))
    provable = set(random.sample(propositions, int(n * provable_fraction)))
    consequences = {}
    for p in propositions:
        consequences[p] = frozenset(
            q for q in propositions if random.random() < consequence_density
        )
    return propositions, provable, consequences


def candidates_for(propositions, consequences, observed):
    observed_set = frozenset(observed)
    return [p for p in propositions if observed_set.issubset(consequences.get(p, frozenset()))]


def discrimination_power(propositions, consequences, candidates, q):
    return sum(1 for p in candidates if q not in consequences.get(p, frozenset()))


def retrocausal_search(propositions, consequences, target, n):
    target_cons = list(consequences.get(target, frozenset()))
    observed = set()
    candidates = list(propositions)
    history = [len(candidates) / n]

    for _ in range(len(target_cons)):
        remaining = [q for q in target_cons if q not in observed]
        if not remaining:
            break
        best_q = max(remaining,
                     key=lambda q: discrimination_power(propositions, consequences, candidates, q))
        observed.add(best_q)
        candidates = candidates_for(propositions, consequences, observed)
        history.append(len(candidates) / n)
        if len(candidates) <= 1:
            break

    return history


def plot_compression_curves():
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Panel 1: Single system compression curve
    ax = axes[0]
    n = 50
    props, prov, cons = generate_random_system(n, 0.3, 0.5, seed=42)
    target = random.Random(42).choice(props)
    history = retrocausal_search(props, cons, target, n)

    ax.plot(range(len(history)), history, 'b-o', markersize=4, linewidth=2)
    ax.axhline(y=1/n, color='r', linestyle='--', alpha=0.5, label='Optimal (1/N)')
    ax.set_xlabel('Number of Verified Consequences', fontsize=12)
    ax.set_ylabel('Compression Ratio', fontsize=12)
    ax.set_title('Retrocausal Compression\n(Single System, N=50)', fontsize=13)
    ax.legend(fontsize=10)
    ax.set_ylim(-0.05, 1.05)
    ax.grid(True, alpha=0.3)

    # Panel 2: Average compression across densities
    ax = axes[1]
    densities = [0.1, 0.2, 0.3, 0.4, 0.5]
    colors = plt.cm.viridis(np.linspace(0.2, 0.8, len(densities)))

    for density, color in zip(densities, colors):
        avg_histories = []
        max_len = 0
        for trial in range(20):
            props, prov, cons = generate_random_system(30, density, 0.5, seed=trial*100)
            target = random.Random(trial).choice(props)
            h = retrocausal_search(props, cons, target, 30)
            avg_histories.append(h)
            max_len = max(max_len, len(h))

        # Pad and average
        padded = []
        for h in avg_histories:
            padded.append(h + [h[-1]] * (max_len - len(h)))
        avg = np.mean(padded, axis=0)
        ax.plot(range(len(avg)), avg, '-o', color=color, markersize=3,
                linewidth=1.5, label=f'density={density}')

    ax.set_xlabel('Verification Steps', fontsize=12)
    ax.set_ylabel('Avg Compression Ratio', fontsize=12)
    ax.set_title('Compression vs Consequence Density\n(Averaged over 20 trials)', fontsize=13)
    ax.legend(fontsize=9)
    ax.set_ylim(-0.05, 1.05)
    ax.grid(True, alpha=0.3)

    # Panel 3: Separation rate vs density
    ax = axes[2]
    sep_rates = []
    stab_rates = []
    test_densities = np.linspace(0.05, 0.7, 15)

    for d in test_densities:
        sep = 0
        stab = 0
        total = 0
        for trial in range(30):
            props, prov, cons = generate_random_system(20, d, 0.5, seed=trial*200)
            for p in props:
                total += 1
                p_cons = cons.get(p, frozenset())
                if all(cons.get(q, frozenset()) != p_cons for q in props if q != p):
                    sep += 1
                if all(q in prov for q in p_cons):
                    stab += 1
        sep_rates.append(sep / total)
        stab_rates.append(stab / total)

    ax.plot(test_densities, sep_rates, 'b-s', markersize=4, linewidth=2, label='Separation rate')
    ax.plot(test_densities, stab_rates, 'r-^', markersize=4, linewidth=2, label='Stability rate')
    ax.set_xlabel('Consequence Density', fontsize=12)
    ax.set_ylabel('Rate', fontsize=12)
    ax.set_title('Separation & Stability\nvs Consequence Density', fontsize=13)
    ax.legend(fontsize=10)
    ax.set_ylim(-0.05, 1.05)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('retrocausal_compression.png', dpi=150, bbox_inches='tight')
    print("Saved: retrocausal_compression.png")


if __name__ == "__main__":
    plot_compression_curves()
