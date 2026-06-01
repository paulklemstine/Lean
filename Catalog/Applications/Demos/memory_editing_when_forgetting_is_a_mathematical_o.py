"""
Memory Algebra: Demonstrations

Numerical examples illustrating the main theorems:
1. Pigeonhole lossiness for a small modular memory
2. Confusion set structure and submonoid closure
3. Selective forgetting and monotonicity
4. Capacity bound verification
5. Matrix (non-commutative) memory systems
"""

from algorithms import (
    MemorySystem, modular_memory, matrix_memory,
    detect_confusion, compute_confusion_set, selective_forget,
    verify_submonoid_closure, capacity_bound, confusion_class_sizes
)
from collections import defaultdict
from itertools import product


def demo_pigeonhole_lossiness():
    """Demonstrate that finite memory must be lossy."""
    print("=" * 60)
    print("DEMO 1: Pigeonhole Lossiness Theorem")
    print("=" * 60)

    # Binary alphabet, memory = Z/4Z
    ms = modular_memory(['0', '1'], modulus=4, generator_values={'0': 1, '1': 3})
    print(f"Alphabet: {{0, 1}}, Memory: Z/4Z (4 states)")
    print(f"Generator map: 0 → 1, 1 → 3")

    # Find confused pair
    result = detect_confusion(ms, max_length=3)
    if result:
        s, t = result
        print(f"\nConfused pair found:")
        print(f"  Stream 1: {s} → encode = {ms.encode(s)}")
        print(f"  Stream 2: {t} → encode = {ms.encode(t)}")
        print(f"  Both map to the same memory state!")

    # Show all encodings for length 1, 2, 3
    for k in [1, 2, 3]:
        n_streams = 2 ** k
        classes = confusion_class_sizes(ms, k)
        print(f"\nLength {k}: {n_streams} streams → {len(classes)} distinct memory states")
        if n_streams > len(classes):
            print(f"  → LOSSY: {n_streams - len(classes)} streams share states with others")
    print()


def demo_confusion_set_structure():
    """Demonstrate that the confusion set is a submonoid."""
    print("=" * 60)
    print("DEMO 2: Confusion Set Submonoid Structure")
    print("=" * 60)

    ms = modular_memory(['a', 'b'], modulus=3, generator_values={'a': 1, 'b': 2})
    print(f"Alphabet: {{a, b}}, Memory: Z/3Z")
    print(f"Generator map: a → 1, b → 2")

    # Compute confusion set for short streams
    confusion = compute_confusion_set(ms, max_length=3)
    print(f"\nConfusion set (streams up to length 3): {len(confusion)} pairs")

    # Show some confused pairs
    confused_list = sorted(confusion, key=lambda p: (len(p[0]), p[0]))[:10]
    print("\nSample confused pairs:")
    for s, t in confused_list:
        print(f"  {list(s)} ≡ {list(t)}  (both encode to {ms.encode(list(s))})")

    # Verify submonoid closure
    # Convert to list format for verification
    pairs_as_lists = [(list(s), list(t)) for s, t in confused_list[:5]]
    is_closed = verify_submonoid_closure(ms, pairs_as_lists)
    print(f"\nSubmonoid closure verified: {is_closed}")

    # Demonstrate closure: if (s1,t1) confused and (s2,t2) confused,
    # then (s1++s2, t1++t2) confused
    if len(confused_list) >= 2:
        s1, t1 = list(confused_list[0][0]), list(confused_list[0][1])
        s2, t2 = list(confused_list[1][0]), list(confused_list[1][1])
        combined_s = s1 + s2
        combined_t = t1 + t2
        print(f"\nClosure example:")
        print(f"  {s1} ≡ {t1} (encode: {ms.encode(s1)})")
        print(f"  {s2} ≡ {t2} (encode: {ms.encode(s2)})")
        print(f"  {combined_s} ≡ {combined_t} (encode: {ms.encode(combined_s)}, {ms.encode(combined_t)})")
        print(f"  Closure holds: {ms.is_confused(combined_s, combined_t)}")
    print()


def demo_selective_forgetting():
    """Demonstrate selective forgetting and monotonicity."""
    print("=" * 60)
    print("DEMO 3: Selective Forgetting")
    print("=" * 60)

    stream = ['see', 'hear', 'see', 'touch', 'hear', 'see']
    print(f"Experience stream: {stream}")

    # Forget visual experiences
    S = {'see'}
    forgotten_S = selective_forget(stream, S)
    print(f"\nForget S = {{see}}: {forgotten_S}")

    # Forget visual and tactile
    T = {'see', 'touch'}
    forgotten_T = selective_forget(stream, T)
    print(f"Forget T = {{see, touch}}: {forgotten_T}")

    # Monotonicity: S ⊆ T means T-forgetting is coarser
    print(f"\nS ⊆ T: {S.issubset(T)}")
    print(f"|forgotten_S| = {len(forgotten_S)} ≥ |forgotten_T| = {len(forgotten_T)}")

    # Show that S-equivalent streams are also T-equivalent
    stream2 = ['hear', 'hear', 'touch', 'hear']
    print(f"\nStream 2: {stream2}")
    print(f"  S-forget: {selective_forget(stream2, S)}")
    print(f"  T-forget: {selective_forget(stream2, T)}")

    s1_S = selective_forget(stream, S)
    s2_S = selective_forget(stream2, S)
    s1_T = selective_forget(stream, T)
    s2_T = selective_forget(stream2, T)
    print(f"\n  S-equivalent: {s1_S == s2_S}")
    print(f"  T-equivalent: {s1_T == s2_T}")
    if s1_S == s2_S:
        print(f"  → Monotonicity: S-equivalent implies T-equivalent: {s1_T == s2_T}")
    print()


def demo_capacity_bound():
    """Demonstrate the memory capacity bound."""
    print("=" * 60)
    print("DEMO 4: Memory Capacity Bound")
    print("=" * 60)

    configs = [
        (2, 4, "binary alphabet, 4 states"),
        (2, 16, "binary alphabet, 16 states"),
        (3, 27, "ternary alphabet, 27 states"),
        (26, 1000000, "English letters, 1M states"),
    ]

    for n, m, desc in configs:
        k = capacity_bound(n, m)
        print(f"\n{desc}:")
        print(f"  |Σ| = {n}, |M| = {m}")
        print(f"  Max distinguishing length: k = {k}")
        print(f"  Verification: {n}^{k} = {n**k} ≤ {m} = |M|: {n**k <= m}")
        if n**(k+1) <= m:
            print(f"  But {n}^{k+1} = {n**(k+1)} ≤ {m} too (bound not tight here)")
        else:
            print(f"  And {n}^{k+1} = {n**(k+1)} > {m} (bound is tight!)")

    # Detailed verification for a concrete system
    print(f"\n\nDetailed check: Z/8Z with binary alphabet")
    ms = modular_memory(['0', '1'], modulus=8, generator_values={'0': 1, '1': 5})
    for k in range(1, 6):
        classes = confusion_class_sizes(ms, k)
        n_streams = 2 ** k
        n_classes = len(classes)
        injective = (n_streams == n_classes)
        print(f"  k={k}: {n_streams} streams → {n_classes} classes, injective: {injective}")
    print()


def demo_matrix_memory():
    """Demonstrate non-commutative memory via matrix multiplication."""
    print("=" * 60)
    print("DEMO 5: Non-Commutative Matrix Memory")
    print("=" * 60)

    # 2x2 matrices over Z/5Z
    ms = matrix_memory(
        alphabet=['L', 'R'],
        size=2,
        generator_matrices={
            'L': [[1, 1], [0, 1]],  # upper triangular
            'R': [[1, 0], [1, 1]],  # lower triangular
        },
        modulus=5
    )

    print("Memory: 2×2 matrices over Z/5Z")
    print("L → [[1,1],[0,1]], R → [[1,0],[1,1]]")

    # Show non-commutativity
    lr = ms.encode(['L', 'R'])
    rl = ms.encode(['R', 'L'])
    print(f"\nencode(LR) = {lr}")
    print(f"encode(RL) = {rl}")
    print(f"Non-commutative: {lr != rl}")

    # Find confusion
    result = detect_confusion(ms, max_length=4)
    if result:
        s, t = result
        print(f"\nConfused pair: {s} ≡ {t}")
        print(f"  encode({s}) = {ms.encode(s)}")
        print(f"  encode({t}) = {ms.encode(t)}")
    else:
        print("\nNo confusion found up to length 4")

    # Count distinct states by length
    for k in range(1, 5):
        classes = confusion_class_sizes(ms, k)
        print(f"  Length {k}: {2**k} streams → {len(classes)} distinct states")
    print()


def demo_forgetting_lattice():
    """Demonstrate the lattice structure of forgetting congruences."""
    print("=" * 60)
    print("DEMO 6: Forgetting Lattice")
    print("=" * 60)

    alphabet = ['a', 'b', 'c']
    ms = modular_memory(alphabet, modulus=6,
                        generator_values={'a': 1, 'b': 2, 'c': 3})

    # Different forgetting sets
    forget_sets = [
        set(),           # forget nothing
        {'a'},           # forget a
        {'b'},           # forget b
        {'a', 'b'},      # forget a and b
        {'a', 'b', 'c'}, # forget everything
    ]

    stream = ['a', 'b', 'c', 'a', 'b']
    print(f"Stream: {stream}")
    print(f"Full encoding: {ms.encode(stream)}")

    print("\nForgetting hierarchy:")
    for S in forget_sets:
        result = selective_forget(stream, S)
        label = str(S) if S else '∅'
        print(f"  Forget {label:20s} → retained: {str(result):30s} (length {len(result)})")

    # Verify lattice properties
    print("\nLattice property: S ⊆ T ⟹ T-forget is coarser")
    for i, S in enumerate(forget_sets):
        for j, T in enumerate(forget_sets):
            if S.issubset(T) and S != T:
                # Check: everything S-equivalent is T-equivalent
                # on a sample of streams
                violations = 0
                for seq in product(alphabet, repeat=3):
                    s_forg = selective_forget(list(seq), S)
                    t_forg = selective_forget(list(seq), T)
                    s_forg_stream = selective_forget(stream, S)
                    t_forg_stream = selective_forget(stream, T)
                    if s_forg == s_forg_stream and t_forg != t_forg_stream:
                        violations += 1
                status = "✓" if violations == 0 else f"✗ ({violations} violations)"
                print(f"  {S or '∅'} ⊆ {T}: {status}")
    print()


if __name__ == '__main__':
    demo_pigeonhole_lossiness()
    demo_confusion_set_structure()
    demo_selective_forgetting()
    demo_capacity_bound()
    demo_matrix_memory()
    demo_forgetting_lattice()


"""Visualization: Memory capacity bound.

Plots the relationship between memory size, alphabet size, and maximum
distinguishing length, illustrating the capacity bound theorem.
"""
import matplotlib.pyplot as plt
import numpy as np
import math


def main():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle('Memory Capacity Bounds: n^k ≤ |M|',
                 fontsize=14, fontweight='bold')

    # Plot 1: Max distinguishing length vs memory size for different alphabets
    memory_sizes = np.arange(1, 1001)
    for n in [2, 3, 5, 10, 26]:
        max_k = [math.floor(math.log(m) / math.log(n)) if m > 0 else 0
                 for m in memory_sizes]
        ax1.plot(memory_sizes, max_k, label=f'|Σ| = {n}', linewidth=2)

    ax1.set_xlabel('Memory size |M|', fontsize=12)
    ax1.set_ylabel('Max distinguishing length k', fontsize=12)
    ax1.set_title('How Much Can You Remember?')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Plot 2: Confusion growth — fraction of streams that are confused
    alphabet_size = 2
    memory_sizes_2 = [4, 8, 16, 32, 64]
    colors = plt.cm.viridis(np.linspace(0.2, 0.8, len(memory_sizes_2)))

    for m, color in zip(memory_sizes_2, colors):
        k_values = range(1, 12)
        confusion_fracs = []
        for k in k_values:
            n_streams = alphabet_size ** k
            # At most m distinct encodings, so at least max(0, n-m)/n streams share
            n_classes = min(n_streams, m)
            # Fraction that must share (lower bound)
            confused_frac = max(0, n_streams - n_classes) / n_streams
            confusion_fracs.append(confused_frac)
        ax2.plot(list(k_values), confusion_fracs,
                 label=f'|M| = {m}', linewidth=2, color=color, marker='o', markersize=4)

    ax2.set_xlabel('Stream length k', fontsize=12)
    ax2.set_ylabel('Minimum confusion fraction', fontsize=12)
    ax2.set_title('Confusion Grows with Stream Length (binary alphabet)')
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(-0.05, 1.05)

    plt.tight_layout()
    plt.savefig('viz_capacity_bound.png', dpi=150)
    plt.close()
    print("Saved viz_capacity_bound.png")


if __name__ == '__main__':
    main()


"""Visualization: Confusion heatmap for a memory system.

Shows which length-k streams get mapped to the same memory state,
visualized as a heatmap of the encoding function.
"""
import matplotlib.pyplot as plt
import numpy as np
from itertools import product


def encode_modular(stream, gen_map, modulus):
    """Encode a stream using modular arithmetic."""
    result = 0
    for s in stream:
        result = (result + gen_map[s]) % modulus
    return result


def main():
    alphabet = ['0', '1']
    modulus = 8
    gen_map = {'0': 1, '1': 3}
    max_k = 6

    fig, axes = plt.subplots(2, 3, figsize=(14, 9))
    fig.suptitle('Memory Confusion: Which Streams Share Memory States?',
                 fontsize=14, fontweight='bold')

    for idx, k in enumerate(range(1, max_k + 1)):
        ax = axes[idx // 3][idx % 3]
        streams = list(product(alphabet, repeat=k))
        encodings = [encode_modular(s, gen_map, modulus) for s in streams]

        n = len(streams)
        confusion_matrix = np.zeros((n, n))
        for i in range(n):
            for j in range(n):
                if encodings[i] == encodings[j]:
                    confusion_matrix[i][j] = 1

        ax.imshow(confusion_matrix, cmap='YlOrRd', aspect='auto')
        ax.set_title(f'Length {k} ({n} streams)', fontsize=10)
        ax.set_xlabel('Stream index')
        ax.set_ylabel('Stream index')

        # Count confusion classes
        unique_encodings = len(set(encodings))
        ax.text(0.02, 0.98, f'{unique_encodings} classes',
                transform=ax.transAxes, fontsize=8,
                verticalalignment='top',
                bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

    plt.tight_layout()
    plt.savefig('viz_confusion_heatmap.png', dpi=150)
    plt.close()
    print("Saved viz_confusion_heatmap.png")


if __name__ == '__main__':
    main()


"""Visualization: Forgetting lattice structure.

Shows the lattice of selective forgetting congruences for a 3-symbol alphabet,
illustrating how forgetting more symbols creates coarser equivalences.
"""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations


def selective_forget(stream, forgotten):
    """Remove forgotten symbols from stream."""
    return tuple(s for s in stream if s not in forgotten)


def main():
    alphabet = ['a', 'b', 'c']

    # All subsets of the alphabet (forgetting sets)
    subsets = [frozenset()]
    for r in range(1, len(alphabet) + 1):
        for combo in combinations(alphabet, r):
            subsets.append(frozenset(combo))

    # Position subsets in a lattice layout
    # Level = size of the subset
    levels = {}
    for s in subsets:
        lvl = len(s)
        if lvl not in levels:
            levels[lvl] = []
        levels[lvl].append(s)

    # Assign positions
    positions = {}
    max_level = max(levels.keys())
    for lvl, sets in levels.items():
        n = len(sets)
        for i, s in enumerate(sets):
            x = (i - (n - 1) / 2) * 2
            y = -lvl * 2
            positions[s] = (x, y)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 7))

    # Left: Lattice diagram
    ax1.set_title('Lattice of Forgetting Operations', fontsize=13, fontweight='bold')

    # Draw edges (subset relations)
    for s in subsets:
        for t in subsets:
            if s < t and len(t) == len(s) + 1:
                x1, y1 = positions[s]
                x2, y2 = positions[t]
                ax1.plot([x1, x2], [y1, y2], 'k-', linewidth=1, alpha=0.5)

    # Draw nodes
    colors = {0: '#2ecc71', 1: '#3498db', 2: '#e74c3c', 3: '#95a5a6'}
    for s in subsets:
        x, y = positions[s]
        lvl = len(s)
        label = '{' + ','.join(sorted(s)) + '}' if s else '∅'
        ax1.scatter(x, y, s=800, c=colors[lvl], zorder=5, edgecolors='black')
        ax1.annotate(label, (x, y), textcoords="offset points",
                     xytext=(0, -20), ha='center', fontsize=9, fontweight='bold')

    ax1.set_xlim(-4, 4)
    ax1.set_ylim(-8, 1)
    ax1.axis('off')

    # Add level labels
    for lvl in range(max_level + 1):
        ax1.text(-3.5, -lvl * 2, f'Forget {lvl}\nsymbols',
                 fontsize=9, ha='center', va='center',
                 bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    # Right: Equivalence class sizes
    ax2.set_title('Equivalence Classes by Forgetting Level', fontsize=13, fontweight='bold')

    # Generate all length-3 streams
    from itertools import product as iter_product
    streams = list(iter_product(alphabet, repeat=3))

    bar_data = []
    labels = []
    for s in sorted(subsets, key=lambda x: (len(x), sorted(x))):
        # Count equivalence classes
        class_map = {}
        for stream in streams:
            key = selective_forget(stream, s)
            if key not in class_map:
                class_map[key] = 0
            class_map[key] += 1

        n_classes = len(class_map)
        max_class = max(class_map.values())
        bar_data.append((n_classes, max_class))
        label = '{' + ','.join(sorted(s)) + '}' if s else '∅'
        labels.append(label)

    x = np.arange(len(labels))
    n_classes = [d[0] for d in bar_data]
    max_sizes = [d[1] for d in bar_data]

    bars1 = ax2.bar(x - 0.2, n_classes, 0.4, label='# equivalence classes',
                    color='#3498db', alpha=0.8)
    bars2 = ax2.bar(x + 0.2, max_sizes, 0.4, label='Largest class size',
                    color='#e74c3c', alpha=0.8)

    ax2.set_xlabel('Forgetting set', fontsize=11)
    ax2.set_ylabel('Count', fontsize=11)
    ax2.set_xticks(x)
    ax2.set_xticklabels(labels, rotation=45, ha='right', fontsize=8)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('viz_forgetting_lattice.png', dpi=150)
    plt.close()
    print("Saved viz_forgetting_lattice.png")


if __name__ == '__main__':
    main()
