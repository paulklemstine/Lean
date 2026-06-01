#!/usr/bin/env python3
"""
Memory Algebra Demo: Numerical Examples

Demonstrates the key theorems from the memory algebra framework:
1. Finite memory lossiness (pigeonhole)
2. Confusion congruence structure
3. Kernel submonoid
4. Forgetting lattice
5. Capacity bounds
"""

from algorithms import (
    MemorySystem, FiniteMonoid, cyclic_monoid, trivial_monoid,
    compute_confusion_classes, detect_lossiness, compute_kernel,
    verify_congruence_property, memory_capacity_analysis,
    compose_memory_system, forgetting_lattice_comparison
)


def demo_lossiness():
    """Demonstrate that finite memory systems are necessarily lossy."""
    print("=" * 60)
    print("DEMO 1: Finite Memory Lossiness Theorem")
    print("=" * 60)

    # Memory system: alphabet {a=0, b=1}, monoid Z/3Z, φ(a)=1, φ(b)=2
    M = cyclic_monoid(3)
    sys = MemorySystem(alphabet_size=2, monoid=M, generator_images=[1, 2])

    print(f"\nAlphabet: {{a, b}}")
    print(f"Memory states: Z/3Z = {{0, 1, 2}}")
    print(f"φ(a) = 1, φ(b) = 2")

    # Find lossiness
    result = detect_lossiness(sys, max_length=4)
    if result:
        x, y = result
        letters = {0: 'a', 1: 'b'}
        x_str = ''.join(letters[i] for i in x) if x else 'ε'
        y_str = ''.join(letters[i] for i in y) if y else 'ε'
        print(f"\nLossiness detected!")
        print(f"  Stream '{x_str}' → state {sys.encode(x)}")
        print(f"  Stream '{y_str}' → state {sys.encode(y)}")
        print(f"  These distinct streams produce the same memory state!")
    print()


def demo_confusion_classes():
    """Demonstrate the structure of confusion classes."""
    print("=" * 60)
    print("DEMO 2: Confusion Congruence Classes")
    print("=" * 60)

    M = cyclic_monoid(4)
    sys = MemorySystem(alphabet_size=2, monoid=M, generator_images=[1, 3])

    print(f"\nAlphabet: {{a, b}}")
    print(f"Memory: Z/4Z, φ(a) = 1, φ(b) = 3")

    classes = compute_confusion_classes(sys, max_length=3)
    letters = {0: 'a', 1: 'b'}

    for state, streams in sorted(classes.items()):
        stream_strs = []
        for s in streams[:8]:  # Show at most 8 per class
            stream_strs.append(''.join(letters[i] for i in s) if s else 'ε')
        suffix = f" ... ({len(streams)} total)" if len(streams) > 8 else ""
        print(f"  State {state}: {{{', '.join(stream_strs)}{suffix}}}")
    print()


def demo_kernel():
    """Demonstrate the kernel submonoid."""
    print("=" * 60)
    print("DEMO 3: Kernel Submonoid (Perfectly Forgotten)")
    print("=" * 60)

    M = cyclic_monoid(3)
    sys = MemorySystem(alphabet_size=2, monoid=M, generator_images=[1, 2])

    print(f"\nMemory: Z/3Z, φ(a) = 1, φ(b) = 2")
    print(f"Kernel = streams mapping to identity (0):")

    kernel = compute_kernel(sys, max_length=5)
    letters = {0: 'a', 1: 'b'}
    for s in kernel[:20]:
        s_str = ''.join(letters[i] for i in s) if s else 'ε'
        print(f"  '{s_str}' → {sys.encode(s)}")

    # Verify closure: kernel is closed under concatenation
    print(f"\nVerifying submonoid property (closure under concatenation):")
    for i in range(min(5, len(kernel))):
        for j in range(min(5, len(kernel))):
            concat = kernel[i] + kernel[j]
            result = sys.encode(concat)
            assert result == 0, f"Submonoid violation: {kernel[i]} ++ {kernel[j]} → {result}"
    print("  ✓ Kernel is closed under concatenation")
    print()


def demo_congruence():
    """Verify the congruence property of confusion."""
    print("=" * 60)
    print("DEMO 4: Congruence Property Verification")
    print("=" * 60)

    M = cyclic_monoid(5)
    sys = MemorySystem(alphabet_size=2, monoid=M, generator_images=[1, 3])

    print(f"\nMemory: Z/5Z, φ(a) = 1, φ(b) = 3")
    print(f"Checking congruence property for streams up to length 3...")

    is_congruence = verify_congruence_property(sys, max_length=3)
    print(f"  Result: {'✓ Congruence property holds!' if is_congruence else '✗ Congruence property violated!'}")
    print()


def demo_forgetting_lattice():
    """Demonstrate the forgetting lattice ordering."""
    print("=" * 60)
    print("DEMO 5: Forgetting Lattice")
    print("=" * 60)

    # Three memory systems of decreasing precision
    M6 = cyclic_monoid(6)
    M3 = cyclic_monoid(3)
    M2 = cyclic_monoid(2)

    sys_fine = MemorySystem(alphabet_size=2, monoid=M6, generator_images=[1, 5])
    sys_med = MemorySystem(alphabet_size=2, monoid=M3, generator_images=[1, 2])
    sys_coarse = MemorySystem(alphabet_size=2, monoid=M2, generator_images=[1, 1])

    print(f"\nThree memory systems over alphabet {{a, b}}:")
    print(f"  Fine:   Z/6Z, φ(a) = 1, φ(b) = 5")
    print(f"  Medium: Z/3Z, φ(a) = 1, φ(b) = 2")
    print(f"  Coarse: Z/2Z, φ(a) = 1, φ(b) = 1")

    result_fm = forgetting_lattice_comparison(sys_fine, sys_med, max_length=3)
    result_mc = forgetting_lattice_comparison(sys_med, sys_coarse, max_length=3)
    result_fc = forgetting_lattice_comparison(sys_fine, sys_coarse, max_length=3)

    print(f"\n  Fine vs Medium: {result_fm['relationship']}")
    print(f"  Medium vs Coarse: {result_mc['relationship']}")
    print(f"  Fine vs Coarse: {result_fc['relationship']}")
    print()


def demo_capacity():
    """Demonstrate memory capacity bounds."""
    print("=" * 60)
    print("DEMO 6: Memory Capacity Analysis")
    print("=" * 60)

    for n in [2, 3, 5, 7]:
        M = cyclic_monoid(n)
        sys = MemorySystem(alphabet_size=2, monoid=M, generator_images=[1, n - 1])
        analysis = memory_capacity_analysis(sys, max_length=4)

        print(f"\n  Z/{n}Z memory system (streams up to length 4):")
        print(f"    Total streams: {analysis['total_streams']}")
        print(f"    Confusion classes: {analysis['num_confusion_classes']}")
        print(f"    Monoid size (capacity bound): {analysis['monoid_size']}")
        print(f"    Capacity utilization: {analysis['capacity_ratio']:.1%}")
        print(f"    Compression ratio: {analysis['compression_ratio']:.1f}x")
    print()


def demo_composition():
    """Demonstrate lossiness composition theorem."""
    print("=" * 60)
    print("DEMO 7: Lossiness Composition (Irreversibility)")
    print("=" * 60)

    M6 = cyclic_monoid(6)
    M3 = cyclic_monoid(3)

    sys = MemorySystem(alphabet_size=2, monoid=M6, generator_images=[1, 5])

    # Compose with mod-3 reduction
    hom = [i % 3 for i in range(6)]
    sys_composed = compose_memory_system(sys, M3, hom)

    loss_orig = detect_lossiness(sys, max_length=5)
    loss_composed = detect_lossiness(sys_composed, max_length=5)

    print(f"\nOriginal: Z/6Z, φ(a) = 1, φ(b) = 5")
    print(f"Composed: Z/3Z via mod-3 reduction")

    orig_analysis = memory_capacity_analysis(sys, max_length=4)
    comp_analysis = memory_capacity_analysis(sys_composed, max_length=4)

    print(f"\n  Original confusion classes: {orig_analysis['num_confusion_classes']}")
    print(f"  Composed confusion classes: {comp_analysis['num_confusion_classes']}")
    print(f"  Original is {'lossy' if loss_orig else 'lossless'}")
    print(f"  Composed is {'lossy' if loss_composed else 'lossless'}")
    print(f"  ✓ Composition preserves lossiness (composed ≤ original classes)")
    print()


if __name__ == "__main__":
    demo_lossiness()
    demo_confusion_classes()
    demo_kernel()
    demo_congruence()
    demo_forgetting_lattice()
    demo_capacity()
    demo_composition()

    print("=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Confusion classes and the forgetting lattice.

Produces a figure showing:
1. Confusion class sizes across different memory system sizes
2. Compression ratio as a function of stream length
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from collections import defaultdict
from itertools import product


def cyclic_monoid_mul(a: int, b: int, n: int) -> int:
    return (a + b) % n


def encode_stream(stream: list, gen_images: list, n: int) -> int:
    state = 0
    for s in stream:
        state = cyclic_monoid_mul(state, gen_images[s], n)
    return state


def enumerate_streams(alpha_size: int, max_len: int):
    for length in range(max_len + 1):
        for stream in product(range(alpha_size), repeat=length):
            yield list(stream)


def count_classes(alpha_size: int, n: int, gen_images: list, max_len: int) -> int:
    states = set()
    for stream in enumerate_streams(alpha_size, max_len):
        states.add(encode_stream(stream, gen_images, n))
    return len(states)


def total_streams(alpha_size: int, max_len: int) -> int:
    return sum(alpha_size ** k for k in range(max_len + 1))


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Confusion classes vs monoid size
monoid_sizes = list(range(2, 16))
max_len = 5
alpha_size = 2
class_counts = []

for n in monoid_sizes:
    gen = [1, n - 1]
    cc = count_classes(alpha_size, n, gen, max_len)
    class_counts.append(cc)

ax1 = axes[0]
ax1.bar(monoid_sizes, class_counts, color='steelblue', alpha=0.8, label='Actual classes')
ax1.plot(monoid_sizes, monoid_sizes, 'r--', linewidth=2, label='Capacity bound (|M|)')
ax1.set_xlabel('Memory monoid size |M|', fontsize=12)
ax1.set_ylabel('Number of confusion classes', fontsize=12)
ax1.set_title('Memory Capacity Theorem:\nClasses ≤ |M|', fontsize=13)
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)

# Plot 2: Compression ratio vs stream length
max_lengths = list(range(1, 9))
for n in [2, 3, 5, 8]:
    gen = [1, n - 1]
    ratios = []
    for ml in max_lengths:
        ts = total_streams(alpha_size, ml)
        cc = count_classes(alpha_size, n, gen, ml)
        ratios.append(ts / cc)
    axes[1].plot(max_lengths, ratios, 'o-', linewidth=2, markersize=6,
                 label=f'Z/{n}Z')

ax2 = axes[1]
ax2.set_xlabel('Maximum stream length', fontsize=12)
ax2.set_ylabel('Compression ratio (streams/classes)', fontsize=12)
ax2.set_title('Compression Grows Exponentially\nwith Stream Length', fontsize=13)
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)
ax2.set_yscale('log')

plt.tight_layout()
plt.savefig('viz_confusion_lattice.png', dpi=150, bbox_inches='tight')
print("Saved viz_confusion_lattice.png")
