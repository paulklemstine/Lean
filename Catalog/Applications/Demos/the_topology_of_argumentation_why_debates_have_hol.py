#!/usr/bin/env python3
"""
Argumentation Topology Demo
============================

Demonstrates the key results from the formalization:
1. Conflict-free sets form a simplicial complex
2. Admissible sets do NOT form a simplicial complex
3. The Euler characteristic conjecture is FALSE
4. Defense depth stratification
5. Extension nerve contractibility
"""

from algorithms import ArgFramework
from typing import FrozenSet


def demo_simplicial_complex():
    """Demonstrate that conflict-free sets are downward-closed."""
    print("=" * 60)
    print("DEMO 1: Conflict-Free Sets Form a Simplicial Complex")
    print("=" * 60)

    # Framework: a→b, c→b (two arguments attacking b)
    af = ArgFramework(
        args={'a', 'b', 'c'},
        attacks={('a', 'b'), ('c', 'b')}
    )

    cf_sets = af.all_conflict_free_sets()
    print(f"\nArguments: {{a, b, c}}")
    print(f"Attacks: a→b, c→b")
    print(f"\nConflict-free sets ({len(cf_sets)}):")
    for s in sorted(cf_sets, key=lambda x: (len(x), str(x))):
        print(f"  {set(s) if s else '{}'}")

    # Verify simplicial property
    simplicial = True
    for s in cf_sets:
        for elem in s:
            subset = s - {elem}
            if subset not in cf_sets:
                simplicial = False
                break
    print(f"\nSimplicial (downward-closed): {simplicial}")
    print(f"Euler characteristic: χ = {af.euler_characteristic()}")


def demo_admissibility_not_simplicial():
    """Demonstrate the counterexample: admissible ≠ simplicial."""
    print("\n" + "=" * 60)
    print("DEMO 2: Admissible Sets Are NOT a Simplicial Complex")
    print("=" * 60)

    # Framework: 1→0, 2→1  (the Lean counterexample)
    af = ArgFramework(
        args={'0', '1', '2'},
        attacks={('1', '0'), ('2', '1')}
    )

    print(f"\nArguments: {{0, 1, 2}}")
    print(f"Attacks: 1→0, 2→1")

    s_full = frozenset({'0', '2'})
    s_sub = frozenset({'0'})

    print(f"\n{{0, 2}} is admissible: {af.is_admissible(s_full)}")
    print(f"  - Conflict-free: {af.is_conflict_free(s_full)}")
    print(f"  - 0 defended: {af.defends(s_full, '0')} (2 attacks 1, who attacks 0)")
    print(f"  - 2 defended: {af.defends(s_full, '2')} (nobody attacks 2)")

    print(f"\n{{0}} is admissible: {af.is_admissible(s_sub)}")
    print(f"  - Conflict-free: {af.is_conflict_free(s_sub)}")
    print(f"  - 0 defended: {af.defends(s_sub, '0')} (nobody in {{0}} attacks 1)")

    print(f"\n→ {{0, 2}} ⊇ {{0}}, admissible superset, non-admissible subset!")
    print(f"→ Admissibility is NOT downward-closed. ✓")


def demo_euler_counterexample():
    """Demonstrate that the Euler characteristic conjecture is false."""
    print("\n" + "=" * 60)
    print("DEMO 3: Euler Characteristic Conjecture is FALSE")
    print("=" * 60)

    # Trivial framework: one argument, no attacks
    af_trivial = ArgFramework(args={'a'}, attacks=set())
    match, info = af_trivial.verify_euler_conjecture()
    print(f"\nFramework 1: A = {{a}}, R = ∅")
    print(f"  Euler characteristic χ = {info['euler_char']}")
    print(f"  # preferred extensions = {info['n_preferred']}")
    print(f"  |grounded extension| = {info['grounded_size']}")
    print(f"  Conjectured χ = {info['n_preferred']} - {info['grounded_size']} = {info['conjectured']}")
    print(f"  Match: {match} {'✓' if match else '✗ COUNTEREXAMPLE!'}")

    # Two mutual attackers
    af_mutual = ArgFramework(args={'a', 'b'}, attacks={('a', 'b'), ('b', 'a')})
    match2, info2 = af_mutual.verify_euler_conjecture()
    print(f"\nFramework 2: A = {{a, b}}, R = {{a→b, b→a}}")
    print(f"  Euler characteristic χ = {info2['euler_char']}")
    print(f"  # preferred extensions = {info2['n_preferred']}")
    print(f"  |grounded extension| = {info2['grounded_size']}")
    print(f"  Conjectured χ = {info2['n_preferred']} - {info2['grounded_size']} = {info2['conjectured']}")
    print(f"  Match: {match2} {'✓' if match2 else '✗ COUNTEREXAMPLE!'}")

    # Test many random frameworks
    print(f"\nSystematic test on random frameworks:")
    from algorithms import generate_random_af
    matches = 0
    total = 50
    for seed in range(total):
        af_rand = generate_random_af(4, 0.3, seed=seed)
        m, _ = af_rand.verify_euler_conjecture()
        if m:
            matches += 1
    print(f"  {matches}/{total} random 4-argument frameworks satisfy the conjecture")
    print(f"  {total - matches}/{total} are counterexamples")


def demo_defense_depth():
    """Demonstrate the defense depth stratification."""
    print("\n" + "=" * 60)
    print("DEMO 4: Defense Depth Stratification")
    print("=" * 60)

    # Chain: d→c→b→a (d attacks c, c attacks b, b attacks a)
    af = ArgFramework(
        args={'a', 'b', 'c', 'd'},
        attacks={('b', 'a'), ('c', 'b'), ('d', 'c')}
    )

    print(f"\nArguments: {{a, b, c, d}}")
    print(f"Attacks: b→a, c→b, d→c (linear chain)")

    chain = af.defense_chain()
    print(f"\nDefense chain:")
    for i, layer in enumerate(chain):
        print(f"  F^{i+1}(∅) = {set(layer) if layer else '{}'}")
        if i > 0 and chain[i] == chain[i-1]:
            print(f"  → Stabilized at step {i+1}")
            break

    print(f"\nDefense depths:")
    for arg in sorted(af.args):
        depth = af.defense_depth(arg)
        label = "unattacked" if depth == 0 else f"depth {depth}" if depth >= 0 else "not grounded"
        print(f"  {arg}: {label}")

    print(f"\nGrounded extension: {set(af.grounded_extension())}")


def demo_nerve_contractibility():
    """Demonstrate extension nerve contractibility."""
    print("\n" + "=" * 60)
    print("DEMO 5: Extension Nerve Contractibility")
    print("=" * 60)

    # Framework with non-empty grounded extension
    af1 = ArgFramework(
        args={'a', 'b', 'c'},
        attacks={('b', 'c'), ('c', 'b')}
    )
    g1 = af1.grounded_extension()
    prefs1 = af1.preferred_extensions()

    print(f"\nFramework 1: A = {{a, b, c}}, R = {{b→c, c→b}}")
    print(f"  Grounded extension: {set(g1)}")
    print(f"  Preferred extensions: {[set(p) for p in prefs1]}")

    if g1:
        common = set.intersection(*[set(p) for p in prefs1]) if prefs1 else set()
        print(f"  Common intersection of all preferred: {common}")
        print(f"  Grounded ⊆ intersection: {set(g1) <= common}")
        print(f"  → Non-empty grounded ⟹ nerve is contractible (a cone)")

    # Framework with empty grounded extension
    af2 = ArgFramework(
        args={'a', 'b', 'c'},
        attacks={('a', 'b'), ('b', 'c'), ('c', 'a')}
    )
    g2 = af2.grounded_extension()
    prefs2 = af2.preferred_extensions()

    print(f"\nFramework 2: A = {{a, b, c}}, R = {{a→b, b→c, c→a}} (3-cycle)")
    print(f"  Grounded extension: {set(g2) if g2 else '{}'}")
    print(f"  Preferred extensions: {[set(p) for p in prefs2]}")
    if not g2:
        print(f"  → Empty grounded ⟹ nerve may have non-trivial topology!")
        if prefs2:
            common = set.intersection(*[set(p) for p in prefs2])
            print(f"  Intersection of preferred: {common if common else '{}'}")


if __name__ == '__main__':
    demo_simplicial_complex()
    demo_admissibility_not_simplicial()
    demo_euler_counterexample()
    demo_defense_depth()
    demo_nerve_contractibility()


#!/usr/bin/env python3
"""
Visualization: Defense Depth Stratification
Shows how arguments are layered by their defense depth.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from algorithms import ArgFramework


def visualize_defense_depth():
    """Visualize defense depth stratification for a chain framework."""
    # 6-argument chain: each attacks the next
    af = ArgFramework(
        args={'a0', 'a1', 'a2', 'a3', 'a4', 'a5'},
        attacks={('a1', 'a0'), ('a2', 'a1'), ('a3', 'a2'),
                 ('a4', 'a3'), ('a5', 'a4')}
    )

    chain = af.defense_chain()
    grounded = af.grounded_extension()

    # Compute depths
    depths = {}
    for arg in sorted(af.args):
        d = af.defense_depth(arg)
        depths[arg] = d

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: defense chain evolution
    ax1 = axes[0]
    args_sorted = sorted(af.args)
    n_args = len(args_sorted)
    arg_to_idx = {a: i for i, a in enumerate(args_sorted)}

    # Create matrix: step x argument
    max_steps = len(chain)
    matrix = np.zeros((max_steps, n_args))
    for step, layer in enumerate(chain):
        for a in layer:
            matrix[step, arg_to_idx[a]] = 1

    im = ax1.imshow(matrix, aspect='auto', cmap='YlOrRd',
                    interpolation='nearest')
    ax1.set_xticks(range(n_args))
    ax1.set_xticklabels(args_sorted, fontsize=10)
    ax1.set_yticks(range(max_steps))
    ax1.set_yticklabels([f'F^{i+1}(∅)' for i in range(max_steps)], fontsize=10)
    ax1.set_xlabel('Arguments', fontsize=12)
    ax1.set_ylabel('Defense Chain Iteration', fontsize=12)
    ax1.set_title('Defense Chain Evolution', fontsize=14, fontweight='bold')

    # Right: graph with depth coloring
    ax2 = axes[1]
    colors = {0: '#2ecc71', 1: '#3498db', 2: '#9b59b6', -1: '#e74c3c'}
    color_labels = {0: 'Depth 0 (unattacked)',
                    1: 'Depth 1 (defended by layer 0)',
                    2: 'Depth 2 (defended by layer 1)',
                    -1: 'Not grounded'}

    positions = {
        'a0': (0, 0), 'a1': (1, 1), 'a2': (2, 0),
        'a3': (3, 1), 'a4': (4, 0), 'a5': (5, 1)
    }

    # Draw attacks
    for (a, b) in af.attacks:
        x1, y1 = positions[a]
        x2, y2 = positions[b]
        ax2.annotate('', xy=(x2, y2), xytext=(x1, y1),
                     arrowprops=dict(arrowstyle='->', color='gray',
                                     lw=1.5, connectionstyle='arc3,rad=0.1'))

    # Draw nodes
    for arg in args_sorted:
        x, y = positions[arg]
        d = depths[arg]
        c = colors.get(d, '#95a5a6')
        circle = plt.Circle((x, y), 0.25, color=c, ec='black', lw=2, zorder=5)
        ax2.add_patch(circle)
        ax2.text(x, y, arg, ha='center', va='center', fontsize=9,
                 fontweight='bold', zorder=6)

    # Legend
    legend_patches = [mpatches.Patch(color=colors[k], label=color_labels[k])
                      for k in sorted(colors.keys())]
    ax2.legend(handles=legend_patches, loc='upper left', fontsize=9)

    ax2.set_xlim(-0.8, 5.8)
    ax2.set_ylim(-0.8, 1.8)
    ax2.set_aspect('equal')
    ax2.axis('off')
    ax2.set_title('Attack Graph with Defense Depth', fontsize=14, fontweight='bold')

    plt.tight_layout()
    plt.savefig('defense_depth.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved defense_depth.png")


def visualize_euler_test():
    """Visualize the Euler conjecture test across many frameworks."""
    from algorithms import generate_random_af

    results = []
    for n in [3, 4, 5, 6]:
        for seed in range(30):
            for p in [0.2, 0.3, 0.5]:
                af = generate_random_af(n, p, seed=seed * 100 + int(p * 100))
                match, info = af.verify_euler_conjecture()
                results.append({
                    'n': n, 'p': p, 'seed': seed,
                    'euler_char': info['euler_char'],
                    'conjectured': info['conjectured'],
                    'match': match,
                    'diff': info['euler_char'] - info['conjectured']
                })

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: scatter of actual vs conjectured
    ax1 = axes[0]
    actual = [r['euler_char'] for r in results]
    conj = [r['conjectured'] for r in results]
    matches = [r['match'] for r in results]

    ax1.scatter([c for c, m in zip(conj, matches) if m],
                [a for a, m in zip(actual, matches) if m],
                c='green', alpha=0.5, label='Match', s=30)
    ax1.scatter([c for c, m in zip(conj, matches) if not m],
                [a for a, m in zip(actual, matches) if not m],
                c='red', alpha=0.5, label='Mismatch', s=30)

    mn = min(min(actual), min(conj)) - 1
    mx = max(max(actual), max(conj)) + 1
    ax1.plot([mn, mx], [mn, mx], 'k--', alpha=0.3, label='y = x')
    ax1.set_xlabel('Conjectured: |pref| - |grounded|', fontsize=12)
    ax1.set_ylabel('Actual Euler characteristic', fontsize=12)
    ax1.set_title('Euler Conjecture Test', fontsize=14, fontweight='bold')
    ax1.legend()

    # Right: match rate by framework size
    ax2 = axes[1]
    sizes = sorted(set(r['n'] for r in results))
    match_rates = []
    for n in sizes:
        subset = [r for r in results if r['n'] == n]
        rate = sum(1 for r in subset if r['match']) / len(subset)
        match_rates.append(rate)

    ax2.bar(sizes, match_rates, color=['#2ecc71' if r > 0.5 else '#e74c3c'
                                        for r in match_rates])
    ax2.set_xlabel('Number of Arguments', fontsize=12)
    ax2.set_ylabel('Conjecture Match Rate', fontsize=12)
    ax2.set_title('Conjecture Failure Rate by Size', fontsize=14, fontweight='bold')
    ax2.set_ylim(0, 1)
    ax2.axhline(y=0.5, color='gray', linestyle='--', alpha=0.5)

    plt.tight_layout()
    plt.savefig('euler_test.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved euler_test.png")


if __name__ == '__main__':
    visualize_defense_depth()
    visualize_euler_test()
