#!/usr/bin/env python3
"""
Memory Algebra Demo: Numerical examples of lossy memory compression.

Demonstrates the key theorems:
1. Memory Compression: finite memory over ≥2 symbols must be lossy
2. Oblivion Kernel: ghost experiences that leave no trace
3. Forgetting Lattice: comparing memory systems by what they forget
"""

from itertools import product
from collections import defaultdict
from typing import Callable, Dict, List, Set, Tuple


def free_monoid_streams(alphabet: List[int], max_length: int) -> List[Tuple[int, ...]]:
    """Generate all streams over alphabet up to max_length."""
    streams = [()]  # empty stream = identity
    for length in range(1, max_length + 1):
        streams.extend(product(alphabet, repeat=length))
    return streams


def apply_memory_hom(stream: Tuple[int, ...], gen_images: Dict[int, int],
                     group_op: Callable, identity: int) -> int:
    """Apply monoid homomorphism defined by generator images."""
    result = identity
    for symbol in stream:
        result = group_op(result, gen_images[symbol])
    return result


def demo_compression_theorem():
    """Demonstrate the Memory Compression Theorem."""
    print("=" * 60)
    print("DEMO 1: Memory Compression Theorem")
    print("=" * 60)
    print()
    print("Alphabet: {0, 1} (2 symbols)")
    print("State space: Z/4 = {0, 1, 2, 3} (addition mod 4)")
    print("Homomorphism: 0 -> 1, 1 -> 3")
    print()

    alphabet = [0, 1]
    gen_images = {0: 1, 1: 3}
    mod = 4
    group_op = lambda a, b: (a + b) % mod

    streams = free_monoid_streams(alphabet, max_length=4)

    # Group streams by their memory state
    classes: Dict[int, List] = defaultdict(list)
    for s in streams:
        state = apply_memory_hom(s, gen_images, group_op, 0)
        classes[state].append(s)

    print(f"Total streams of length ≤ 4: {len(streams)}")
    print(f"Distinct memory states reached: {len(classes)}")
    print()

    for state, members in sorted(classes.items()):
        print(f"  State {state}: {len(members)} streams")
        if len(members) <= 5:
            for m in members:
                print(f"    {'ε' if len(m) == 0 else ''.join(map(str, m))}")
        else:
            for m in members[:3]:
                print(f"    {'ε' if len(m) == 0 else ''.join(map(str, m))}")
            print(f"    ... and {len(members) - 3} more")
    print()

    # Find collisions (proof of lossiness)
    collision_found = False
    for state, members in classes.items():
        if len(members) > 1:
            x, y = members[0], members[1]
            if x != y:
                print(f"COLLISION FOUND: streams '{x}' and '{y}' both map to state {state}")
                collision_found = True
                break

    if collision_found:
        print("→ The memory system IS lossy, as the theorem guarantees.")
    print()


def demo_oblivion_kernel():
    """Demonstrate the Oblivion Kernel Theorem for groups."""
    print("=" * 60)
    print("DEMO 2: Oblivion Kernel (Ghost Experiences)")
    print("=" * 60)
    print()
    print("State space: Z/6 (group under addition mod 6)")
    print("Homomorphism: 0 -> 2, 1 -> 3")
    print()

    alphabet = [0, 1]
    gen_images = {0: 2, 1: 3}
    mod = 6
    group_op = lambda a, b: (a + b) % mod

    # Compute order of each generator's image
    for sym, img in gen_images.items():
        order = 1
        current = img
        while current != 0:
            current = (current + img) % mod
            order += 1
        print(f"  Generator {sym} -> {img}, order = {order}")
        print(f"  Ghost experience: '{sym}' repeated {order} times = {''.join([str(sym)] * order)}")
        # Verify
        stream = tuple([sym] * order)
        result = apply_memory_hom(stream, gen_images, group_op, 0)
        print(f"  Verification: φ({''.join(map(str, stream))}) = {result} (identity)")
    print()

    # Find ALL oblivion kernel elements up to length 6
    streams = free_monoid_streams(alphabet, max_length=6)
    kernel = []
    for s in streams:
        if len(s) > 0 and apply_memory_hom(s, gen_images, group_op, 0) == 0:
            kernel.append(s)

    print(f"Oblivion kernel elements (length 1-6): {len(kernel)}")
    for s in kernel[:10]:
        print(f"  {''.join(map(str, s))} (length {len(s)})")
    if len(kernel) > 10:
        print(f"  ... and {len(kernel) - 10} more")
    print()

    # Verify it's a submonoid (closed under concatenation)
    kernel_set = set(kernel)
    violations = 0
    for i, a in enumerate(kernel[:20]):
        for b in kernel[:20]:
            ab = a + b
            if len(ab) <= 6:
                result = apply_memory_hom(ab, gen_images, group_op, 0)
                if result != 0:
                    violations += 1
    print(f"Submonoid check (concatenation of kernel elements): {violations} violations out of tested pairs")
    if violations == 0:
        print("→ Confirmed: oblivion kernel is closed under concatenation (submonoid).")
    print()


def demo_forgetting_lattice():
    """Demonstrate the forgetting lattice and monotonicity."""
    print("=" * 60)
    print("DEMO 3: Forgetting Lattice & Monotonicity")
    print("=" * 60)
    print()

    alphabet = [0, 1]

    # Memory system 1: φ₁ encodes to Z/4
    gen1 = {0: 1, 1: 3}
    mod1 = 4
    op1 = lambda a, b: (a + b) % mod1

    # Memory system 2: φ₂ encodes to Z/2 (φ₂ = projection of φ₁ mod 2)
    gen2 = {0: 1, 1: 1}
    mod2 = 2
    op2 = lambda a, b: (a + b) % mod2

    streams = free_monoid_streams(alphabet, max_length=5)

    print("Memory System φ₁: FreeMonoid({0,1}) → Z/4, generators: 0→1, 1→3")
    print("Memory System φ₂: FreeMonoid({0,1}) → Z/2, generators: 0→1, 1→1")
    print()

    # Check if φ₁ ≤ φ₂ (φ₁ forgets less than φ₂)
    phi1_leq_phi2 = True
    phi2_leq_phi1 = True

    classes1 = defaultdict(list)
    classes2 = defaultdict(list)

    for s in streams:
        s1 = apply_memory_hom(s, gen1, op1, 0)
        s2 = apply_memory_hom(s, gen2, op2, 0)
        classes1[s1].append(s)
        classes2[s2].append(s)

    # Check φ₁ ≤ φ₂: if φ₁(x) = φ₁(y) then φ₂(x) = φ₂(y)?
    for state, members in classes1.items():
        images2 = set()
        for m in members:
            images2.add(apply_memory_hom(m, gen2, op2, 0))
        if len(images2) > 1:
            phi1_leq_phi2 = False
            break

    # Check φ₂ ≤ φ₁: if φ₂(x) = φ₂(y) then φ₁(x) = φ₁(y)?
    for state, members in classes2.items():
        images1 = set()
        for m in members:
            images1.add(apply_memory_hom(m, gen1, op1, 0))
        if len(images1) > 1:
            phi2_leq_phi1 = False
            break

    print(f"φ₁ classes (length ≤ 5): {len(classes1)} distinct states")
    print(f"φ₂ classes (length ≤ 5): {len(classes2)} distinct states")
    print()
    print(f"φ₁ forgets ≤ φ₂ (Con.ker φ₁ ≤ Con.ker φ₂): {phi1_leq_phi2}")
    print(f"φ₂ forgets ≤ φ₁ (Con.ker φ₂ ≤ Con.ker φ₁): {phi2_leq_phi1}")
    print()

    if phi1_leq_phi2 and not phi2_leq_phi1:
        print("→ φ₂ strictly forgets more than φ₁.")
        print("  This means φ₂ factors through the quotient by Con.ker φ₁.")
        print("  The 'forgetting map' is the projection Z/4 → Z/2 (mod 2).")
    print()

    # Demonstrate monotonicity: composing φ₁ with projection increases loss
    print("Monotonicity: composing φ₁ with projection π: Z/4 → Z/2")
    print("  π ∘ φ₁ = φ₂ (by construction)")
    print("  Con.ker φ₁ ≤ Con.ker(π ∘ φ₁) = Con.ker φ₂ ✓")
    print()


def demo_capacity_bound():
    """Demonstrate the memory capacity bound."""
    print("=" * 60)
    print("DEMO 4: Memory Capacity Bound")
    print("=" * 60)
    print()

    alphabet = [0, 1]
    gen_images = {0: 1, 1: 2}
    mod = 5
    group_op = lambda a, b: (a + b) % mod

    print(f"Alphabet size k = {len(alphabet)}")
    print(f"State space size m = {mod}")
    print()

    for n in range(1, 8):
        streams_n = list(product(alphabet, repeat=n))
        distinct = set()
        for s in streams_n:
            state = apply_memory_hom(s, gen_images, group_op, 0)
            distinct.add(state)

        print(f"  Length {n}: {len(streams_n)} streams, "
              f"{len(distinct)} distinct states "
              f"(bound: {mod}), "
              f"compression ratio: {len(streams_n)/len(distinct):.1f}x")

    print()
    print(f"→ Distinct states never exceed {mod} (= |state space|), as guaranteed.")
    print(f"→ Compression ratio grows exponentially with stream length.")
    print()


if __name__ == "__main__":
    demo_compression_theorem()
    demo_oblivion_kernel()
    demo_forgetting_lattice()
    demo_capacity_bound()


#!/usr/bin/env python3
"""
Visualization: Information Loss Congruence Classes

Shows how experience streams are grouped into equivalence classes
by a memory system, illustrating the compression and information loss.
"""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import product
from collections import defaultdict
from typing import Dict, List, Tuple


def encode_stream(stream: Tuple[int, ...], gen_images: Dict[int, int],
                  mod: int) -> int:
    result = 0
    for s in stream:
        result = (result + gen_images[s]) % mod
    return result


def generate_streams(alphabet: List[int], length: int) -> List[Tuple[int, ...]]:
    return list(product(alphabet, repeat=length))


def main():
    alphabet = [0, 1]
    gen_images = {0: 1, 1: 3}
    mod = 4
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12']

    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    fig.suptitle('Information Loss Congruence Classes\n'
                 'Memory System: FreeMonoid({0,1}) → Z/4, generators 0→1, 1→3',
                 fontsize=14, fontweight='bold')

    for idx, n in enumerate(range(1, 7)):
        ax = axes[idx // 3][idx % 3]
        streams = generate_streams(alphabet, n)

        classes: Dict[int, List[str]] = defaultdict(list)
        for s in streams:
            state = encode_stream(s, gen_images, mod)
            label = ''.join(map(str, s))
            classes[state].append(label)

        # Bar chart of class sizes
        states = sorted(classes.keys())
        sizes = [len(classes[s]) for s in states]
        bars = ax.bar(states, sizes, color=[colors[s] for s in states],
                      edgecolor='black', linewidth=0.5)

        ax.set_title(f'Length {n}: {len(streams)} streams → {len(classes)} classes',
                     fontsize=10)
        ax.set_xlabel('Memory State')
        ax.set_ylabel('Class Size')
        ax.set_xticks(states)

        # Annotate with example streams
        for i, s in enumerate(states):
            members = classes[s]
            if len(members) <= 3:
                text = '\n'.join(members)
            else:
                text = '\n'.join(members[:2]) + f'\n+{len(members)-2} more'
            ax.annotate(text, xy=(s, sizes[i]), xytext=(0, 5),
                        textcoords='offset points', ha='center', va='bottom',
                        fontsize=6, fontfamily='monospace')

    plt.tight_layout()
    plt.savefig('viz_congruence_classes.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_congruence_classes.png")


if __name__ == '__main__':
    main()


#!/usr/bin/env python3
"""
Visualization: The Lattice of Forgetting Strategies

Shows the partial order on memory systems by forgetting,
from perfect memory (bottom) to total amnesia (top).
"""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import product
from collections import defaultdict
from typing import Dict, List, Tuple


def encode(stream: Tuple[int, ...], gen_images: Dict[int, int], mod: int) -> int:
    result = 0
    for s in stream:
        result = (result + gen_images[s]) % mod
    return result


def count_classes(gen_images: Dict[int, int], mod: int, max_len: int) -> int:
    seen = set()
    streams = [()]
    for length in range(1, max_len + 1):
        streams.extend(product([0, 1], repeat=length))
    for s in streams:
        seen.add(encode(s, gen_images, mod))
    return len(seen)


def check_leq(gen1: Dict[int, int], mod1: int,
              gen2: Dict[int, int], mod2: int, max_len: int) -> bool:
    """Check if system 1's congruence ≤ system 2's congruence."""
    streams = [()]
    for length in range(1, max_len + 1):
        streams.extend(product([0, 1], repeat=length))

    classes1 = defaultdict(list)
    for s in streams:
        classes1[encode(s, gen1, mod1)].append(s)

    for members in classes1.values():
        images2 = {encode(m, gen2, mod2) for m in members}
        if len(images2) > 1:
            return False
    return True


def main():
    # Define several memory systems over {0, 1}
    systems = [
        ("Z/1 (amnesia)", {0: 0, 1: 0}, 1),
        ("Z/2 (parity)", {0: 1, 1: 1}, 2),
        ("Z/2 (diff)", {0: 1, 1: 0}, 2),
        ("Z/3 (mod 3)", {0: 1, 1: 2}, 3),
        ("Z/4 (rich)", {0: 1, 1: 3}, 4),
        ("Z/6 (fine)", {0: 2, 1: 3}, 6),
    ]

    max_len = 4
    n = len(systems)

    # Compute the partial order
    leq = np.zeros((n, n), dtype=bool)
    for i in range(n):
        for j in range(n):
            leq[i][j] = check_leq(systems[i][1], systems[i][2],
                                   systems[j][1], systems[j][2], max_len)

    # Compute classes count
    class_counts = []
    for name, gen, mod in systems:
        cc = count_classes(gen, mod, max_len)
        class_counts.append(cc)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 7))
    fig.suptitle('The Lattice of Forgetting Strategies', fontsize=14, fontweight='bold')

    # Left: Hasse diagram (partial order)
    ax1.set_title('Forgetting Order (Hasse-like Diagram)')

    # Position nodes by class count (y) and spread (x)
    y_positions = {}
    for i, cc in enumerate(class_counts):
        if cc not in y_positions:
            y_positions[cc] = []
        y_positions[cc].append(i)

    positions = {}
    for cc, indices in y_positions.items():
        spread = np.linspace(-len(indices)/2, len(indices)/2, len(indices))
        for k, idx in enumerate(indices):
            positions[idx] = (spread[k], cc)

    # Draw edges (only Hasse: remove transitive edges)
    for i in range(n):
        for j in range(n):
            if i != j and leq[i][j]:
                # Check if this is a direct edge (no intermediate)
                is_direct = True
                for k in range(n):
                    if k != i and k != j and leq[i][k] and leq[k][j]:
                        is_direct = False
                        break
                if is_direct:
                    xi, yi = positions[i]
                    xj, yj = positions[j]
                    ax1.annotate('', xy=(xj, yj - 0.15), xytext=(xi, yi + 0.15),
                                arrowprops=dict(arrowstyle='->', color='#555',
                                                lw=1.5, connectionstyle='arc3,rad=0.1'))

    # Draw nodes
    node_colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6', '#1abc9c']
    for i, (name, gen, mod) in enumerate(systems):
        x, y = positions[i]
        circle = plt.Circle((x, y), 0.3, color=node_colors[i % len(node_colors)],
                            ec='black', lw=1.5, zorder=5)
        ax1.add_patch(circle)
        ax1.text(x, y, str(class_counts[i]), ha='center', va='center',
                fontsize=10, fontweight='bold', color='white', zorder=6)
        ax1.text(x + 0.4, y, name, ha='left', va='center', fontsize=8)

    ax1.set_xlim(-3, 4)
    ax1.set_ylim(0, max(class_counts) + 1)
    ax1.set_ylabel('Number of Distinct Memory Classes')
    ax1.set_xlabel('(nodes show class count; arrows show forgetting order)')
    ax1.grid(True, alpha=0.3)

    # Right: Compression ratios
    ax2.set_title('Compression Ratio by Stream Length')

    for i, (name, gen, mod) in enumerate(systems):
        lengths = range(1, 7)
        ratios = []
        for L in lengths:
            total = 2 ** L
            streams = list(product([0, 1], repeat=L))
            distinct = len({encode(s, gen, mod) for s in streams})
            ratios.append(total / max(distinct, 1))

        ax2.plot(list(lengths), ratios, 'o-', color=node_colors[i % len(node_colors)],
                label=name, linewidth=2, markersize=6)

    ax2.set_xlabel('Stream Length')
    ax2.set_ylabel('Compression Ratio (streams / distinct states)')
    ax2.legend(fontsize=8)
    ax2.set_yscale('log')
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_forgetting_lattice.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_forgetting_lattice.png")


if __name__ == '__main__':
    main()


#!/usr/bin/env python3
"""
Visualization: Oblivion Kernel Growth

Shows how the oblivion kernel (ghost experiences) grows exponentially
compared to the fixed number of distinguishable classes.
"""
import matplotlib.pyplot as plt
import numpy as np
from itertools import product
from collections import defaultdict


def encode(stream, gen_images, mod):
    result = 0
    for s in stream:
        result = (result + gen_images[s]) % mod
    return result


def main():
    alphabet = [0, 1]
    gen_images = {0: 2, 1: 3}
    mod = 6

    lengths = range(1, 10)
    total_streams = []
    kernel_sizes = []
    distinct_states = []

    for L in lengths:
        streams = list(product(alphabet, repeat=L))
        total = len(streams)
        total_streams.append(total)

        kernel_count = sum(1 for s in streams if encode(s, gen_images, mod) == 0)
        kernel_sizes.append(kernel_count)

        distinct = len({encode(s, gen_images, mod) for s in streams})
        distinct_states.append(distinct)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle('Oblivion Kernel Growth\n'
                 'Memory System: FreeMonoid({0,1}) → Z/6, generators 0→2, 1→3',
                 fontsize=13, fontweight='bold')

    # Left: Absolute counts
    ax1.set_title('Stream Counts by Length')
    ax1.semilogy(list(lengths), total_streams, 'ko-', label='Total streams (2ⁿ)',
                linewidth=2, markersize=6)
    ax1.semilogy(list(lengths), kernel_sizes, 'rs-', label='Oblivion kernel',
                linewidth=2, markersize=6)
    ax1.semilogy(list(lengths), distinct_states, 'b^-', label='Distinct states',
                linewidth=2, markersize=6)

    # Theoretical bound
    theoretical = [max(1, (2**L - mod) // mod) for L in lengths]
    ax1.semilogy(list(lengths), theoretical, 'r--', alpha=0.5,
                label='Lower bound ⌊(2ⁿ-6)/6⌋', linewidth=1)

    ax1.set_xlabel('Stream Length n')
    ax1.set_ylabel('Count (log scale)')
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Right: Proportions
    ax2.set_title('Fraction of Streams in Oblivion Kernel')
    fractions = [k/t for k, t in zip(kernel_sizes, total_streams)]
    expected = [1/mod] * len(lengths)

    ax2.plot(list(lengths), fractions, 'rs-', label='Actual kernel fraction',
            linewidth=2, markersize=8)
    ax2.axhline(y=1/mod, color='gray', linestyle='--', alpha=0.7,
               label=f'Expected (1/{mod} = {1/mod:.4f})')

    ax2.set_xlabel('Stream Length n')
    ax2.set_ylabel('Fraction')
    ax2.legend()
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(0, max(fractions) * 1.3)

    plt.tight_layout()
    plt.savefig('viz_oblivion_kernel.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_oblivion_kernel.png")


if __name__ == '__main__':
    main()
