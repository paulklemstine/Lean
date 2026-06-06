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
