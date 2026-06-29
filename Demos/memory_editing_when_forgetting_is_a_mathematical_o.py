#!/usr/bin/env python3
"""
Memory Algebra Demo: Numerical examples illustrating the theorems.

Demonstrates:
1. Lossy Memory Theorem - constructing memory systems and showing non-injectivity
2. Kernel Submonoid - computing the kernel and verifying closure
3. Forgetting as Quotient - computing congruence classes and quotient monoids
4. Fiber Partition Bound - measuring fiber sizes
"""

import itertools
from collections import Counter, defaultdict
from typing import Callable


def make_cyclic_monoid(n: int) -> list[list[int]]:
    """Create multiplication table for Z/nZ (additive, written multiplicatively)."""
    return [[(i + j) % n for j in range(n)] for i in range(n)]


def make_monoid_hom(
    src_table: list[list[int]],
    tgt_table: list[list[int]],
    mapping: list[int],
) -> bool:
    """Check if mapping is a monoid homomorphism."""
    n = len(src_table)
    for i in range(n):
        for j in range(n):
            if mapping[src_table[i][j]] != tgt_table[mapping[i]][mapping[j]]:
                return False
    # Check identity preservation (element 0 is identity)
    if mapping[0] != 0:
        return False
    return True


def compute_kernel(mapping: list[int]) -> list[int]:
    """Compute the kernel: elements mapping to identity (0)."""
    return [i for i, v in enumerate(mapping) if v == 0]


def compute_fibers(mapping: list[int], tgt_size: int) -> dict[int, list[int]]:
    """Compute fibers: for each target element, which source elements map to it."""
    fibers: dict[int, list[int]] = defaultdict(list)
    for i, v in enumerate(mapping):
        fibers[v].append(i)
    return dict(fibers)


def demo_lossy_memory():
    """Demonstrate the Lossy Memory Theorem with finite examples."""
    print("=" * 60)
    print("DEMO 1: Lossy Memory Theorem")
    print("=" * 60)
    print()

    # Map Z/6Z -> Z/3Z via mod 3
    src = make_cyclic_monoid(6)
    tgt = make_cyclic_monoid(3)
    mapping = [i % 3 for i in range(6)]

    assert make_monoid_hom(src, tgt, mapping), "Should be a valid homomorphism"

    print(f"Source monoid: Z/6Z (size {len(src)})")
    print(f"Target monoid: Z/3Z (size {len(tgt)})")
    print(f"Mapping: {mapping}")
    print()

    # Check injectivity
    is_injective = len(set(mapping)) == len(mapping)
    print(f"Is injective? {is_injective}")
    print("Theorem confirms: any hom from larger to smaller monoid is non-injective")

    # Show collisions
    fibers = compute_fibers(mapping, len(tgt))
    print(f"\nFibers (preimages):")
    for target, sources in sorted(fibers.items()):
        print(f"  {target} <- {sources}")

    print()


def demo_kernel_submonoid():
    """Demonstrate the Kernel Submonoid Theorem."""
    print("=" * 60)
    print("DEMO 2: Kernel Submonoid")
    print("=" * 60)
    print()

    # Z/6Z -> Z/3Z, kernel = {0, 3}
    src = make_cyclic_monoid(6)
    mapping = [i % 3 for i in range(6)]
    kernel = compute_kernel(mapping)

    print(f"Monoid: Z/6Z")
    print(f"Homomorphism: x -> x mod 3")
    print(f"Kernel (elements mapping to identity): {kernel}")

    # Verify submonoid properties
    print(f"\nSubmonoid verification:")
    print(f"  Identity (0) in kernel? {0 in kernel}")

    # Check closure under multiplication
    closed = True
    for a in kernel:
        for b in kernel:
            product = src[a][b]
            if product not in kernel:
                closed = False
                print(f"  FAILURE: {a} * {b} = {product} not in kernel!")
    if closed:
        print(f"  Closed under multiplication? True")
        for a in kernel:
            for b in kernel:
                product = src[a][b]
                print(f"    {a} * {b} = {product} (in kernel: {product in kernel})")

    print()


def demo_forgetting_quotient():
    """Demonstrate Forgetting as Quotient construction."""
    print("=" * 60)
    print("DEMO 3: Forgetting as Quotient")
    print("=" * 60)
    print()

    # Fine system: Z/12Z -> Z/6Z (mod 6)
    # Coarse system: Z/12Z -> Z/3Z (mod 3)
    # Bridge: Z/6Z -> Z/3Z (mod 3)

    n = 12
    src = make_cyclic_monoid(n)

    fine_map = [i % 6 for i in range(n)]
    coarse_map = [i % 3 for i in range(n)]
    bridge_map = [i % 3 for i in range(6)]

    print(f"Experience monoid: Z/{n}Z")
    print(f"Fine memory: Z/6Z (via mod 6): {fine_map}")
    print(f"Coarse memory: Z/3Z (via mod 3): {coarse_map}")
    print(f"Bridge: Z/6Z -> Z/3Z (via mod 3): {bridge_map}")

    # Verify commutation: bridge(fine(e)) = coarse(e)
    commutes = all(bridge_map[fine_map[e]] == coarse_map[e] for e in range(n))
    print(f"\nCommutation (bridge ∘ fine = coarse): {commutes}")

    # Show congruence refinement
    print(f"\nFine congruence classes:")
    fine_fibers = compute_fibers(fine_map, 6)
    for target, sources in sorted(fine_fibers.items()):
        print(f"  Class {target}: {sources}")

    print(f"\nCoarse congruence classes:")
    coarse_fibers = compute_fibers(coarse_map, 3)
    for target, sources in sorted(coarse_fibers.items()):
        print(f"  Class {target}: {sources}")

    # Verify refinement: fine classes are subsets of coarse classes
    print(f"\nRefinement check (each fine class ⊆ some coarse class):")
    for fine_target, fine_sources in sorted(fine_fibers.items()):
        coarse_target = bridge_map[fine_target]
        coarse_sources = coarse_fibers[coarse_target]
        is_subset = all(s in coarse_sources for s in fine_sources)
        print(f"  Fine class {fine_target} ⊆ Coarse class {coarse_target}: {is_subset}")

    # Kernel monotonicity
    fine_kernel = compute_kernel(fine_map)
    coarse_kernel = compute_kernel(coarse_map)
    print(f"\nFine kernel: {fine_kernel}")
    print(f"Coarse kernel: {coarse_kernel}")
    print(f"Fine kernel ⊆ Coarse kernel: {all(k in coarse_kernel for k in fine_kernel)}")

    print()


def demo_fiber_bound():
    """Demonstrate the Fiber Partition Bound / Pigeonhole Loss."""
    print("=" * 60)
    print("DEMO 4: Pigeonhole Loss Bound")
    print("=" * 60)
    print()

    for k, n_states in [(2, 3), (2, 4), (3, 4), (2, 8)]:
        n_inputs = k**n_states
        print(f"k={k} generators, n={n_states} states: {n_inputs} inputs -> {n_states} bins")

        # Best possible distribution (most uniform)
        base = n_inputs // n_states
        remainder = n_inputs % n_states
        distribution = [base + (1 if i < remainder else 0) for i in range(n_states)]
        max_fiber = max(distribution)

        print(f"  Most uniform distribution: {sorted(distribution, reverse=True)}")
        print(f"  Largest fiber: {max_fiber} (theorem guarantees ≥ {n_states})")
        print(f"  Theorem satisfied: {max_fiber >= n_states}")
        print()


def demo_information_loss_measurement():
    """Measure information loss across different memory systems."""
    print("=" * 60)
    print("DEMO 5: Information Loss Measurement")
    print("=" * 60)
    print()

    import math

    # Compare different memory sizes for Z/nZ
    source_size = 24
    print(f"Source monoid: Z/{source_size}Z\n")

    for target_size in [2, 3, 4, 6, 8, 12]:
        mapping = [i % target_size for i in range(source_size)]
        fibers = compute_fibers(mapping, target_size)
        fiber_sizes = [len(f) for f in fibers.values()]

        # Compute entropy of the fiber distribution
        total = sum(fiber_sizes)
        entropy = -sum(
            (s / total) * math.log2(s / total) for s in fiber_sizes if s > 0
        )

        # Information retained (log of number of distinguishable classes)
        info_retained = math.log2(target_size)
        info_total = math.log2(source_size)
        info_lost = info_total - info_retained

        print(f"  Memory size {target_size:2d}: "
              f"fiber sizes = {fiber_sizes}, "
              f"retained = {info_retained:.2f} bits, "
              f"lost = {info_lost:.2f} bits")

    print()


if __name__ == "__main__":
    demo_lossy_memory()
    demo_kernel_submonoid()
    demo_forgetting_quotient()
    demo_fiber_bound()
    demo_information_loss_measurement()


#!/usr/bin/env python3
"""
Visualization: Congruence lattice for memory systems on Z/12Z.
Shows the Hasse diagram of memory refinements.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import matplotlib
import numpy as np

matplotlib.use("Agg")


def divisors(n):
    return sorted([d for d in range(1, n + 1) if n % d == 0])


def main():
    n = 12
    divs = divisors(n)

    # Position divisors in a lattice layout
    # Group by "level" (number of prime factors roughly)
    levels = {}
    for d in divs:
        level = sum(1 for p in [2, 3, 5, 7, 11] for _ in range(20) if d % (p ** (_ + 1)) == 0)
        # Simpler: use log
        level = round(np.log2(d) * 2) if d > 0 else 0
        if level not in levels:
            levels[level] = []
        levels[level].append(d)

    # Manual layout for Z/12Z divisors
    positions = {
        1: (3, 0),
        2: (1, 1),
        3: (3, 1),
        4: (5, 1),
        6: (2, 2),
        12: (3, 3),
    }

    fig, ax = plt.subplots(1, 1, figsize=(10, 8))

    # Draw edges (d1 divides d2 and d2/d1 is prime)
    edges = []
    for d1 in divs:
        for d2 in divs:
            if d1 < d2 and d2 % d1 == 0:
                ratio = d2 // d1
                # Check if ratio is prime (no intermediate divisor)
                is_cover = True
                for d3 in divs:
                    if d1 < d3 < d2 and d2 % d3 == 0 and d3 % d1 == 0:
                        is_cover = False
                        break
                if is_cover:
                    edges.append((d1, d2))

    for d1, d2 in edges:
        x1, y1 = positions[d1]
        x2, y2 = positions[d2]
        ax.annotate(
            "", xy=(x2, y2 - 0.15), xytext=(x1, y1 + 0.15),
            arrowprops=dict(arrowstyle="->", color="steelblue",
                            lw=2, connectionstyle="arc3,rad=0.05"),
        )

    # Draw nodes
    for d, (x, y) in positions.items():
        kernel_size = d  # |ker| = d for Z/nZ -> Z/(n/d)Z
        memory_size = n // d
        info_loss = np.log2(n) - np.log2(memory_size) if memory_size > 0 else 0

        color = plt.cm.RdYlGn(1 - info_loss / np.log2(n))
        circle = plt.Circle((x, y), 0.3, color=color, ec="black", lw=2, zorder=3)
        ax.add_patch(circle)
        ax.text(x, y + 0.05, f"Z/{memory_size}Z", ha="center", va="center",
                fontsize=10, fontweight="bold", zorder=4)
        ax.text(x, y - 0.12, f"loss={info_loss:.1f}b", ha="center", va="center",
                fontsize=7, zorder=4, color="gray")

    ax.set_xlim(-0.5, 6.5)
    ax.set_ylim(-0.5, 3.8)
    ax.set_aspect("equal")
    ax.axis("off")
    ax.set_title(
        "Lattice of Memory Systems for Z/12Z\n"
        "(arrows = forgetting maps, color = information retention)",
        fontsize=14, fontweight="bold",
    )

    # Legend
    legend_elements = [
        mpatches.Patch(facecolor=plt.cm.RdYlGn(1.0), edgecolor="black", label="No loss"),
        mpatches.Patch(facecolor=plt.cm.RdYlGn(0.5), edgecolor="black", label="Moderate loss"),
        mpatches.Patch(facecolor=plt.cm.RdYlGn(0.0), edgecolor="black", label="Maximum loss"),
    ]
    ax.legend(handles=legend_elements, loc="lower right", fontsize=9)

    plt.tight_layout()
    plt.savefig("viz_congruence_lattice.png", dpi=150, bbox_inches="tight")
    print("Saved viz_congruence_lattice.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Memory fiber distributions for different memory sizes.
Shows how fiber sizes change as memory capacity varies.
"""

import matplotlib.pyplot as plt
import matplotlib
import numpy as np

matplotlib.use("Agg")


def make_cyclic_table(n):
    return [[(i + j) % n for j in range(n)] for i in range(n)]


def compute_fibers(mapping, target_size):
    fibers = {i: [] for i in range(target_size)}
    for i, v in enumerate(mapping):
        fibers[v].append(i)
    return fibers


def main():
    source_size = 24
    target_sizes = [2, 3, 4, 6, 8, 12, 24]

    fig, axes = plt.subplots(2, 4, figsize=(16, 8))
    axes = axes.flatten()

    for idx, target_size in enumerate(target_sizes):
        mapping = [i % target_size for i in range(source_size)]
        fibers = compute_fibers(mapping, target_size)

        ax = axes[idx]
        fiber_sizes = [len(fibers[k]) for k in sorted(fibers.keys())]
        colors = plt.cm.viridis(np.linspace(0.2, 0.8, len(fiber_sizes)))
        bars = ax.bar(range(len(fiber_sizes)), fiber_sizes, color=colors)
        ax.set_title(f"Memory size = {target_size}", fontsize=12)
        ax.set_xlabel("State")
        ax.set_ylabel("Fiber size")
        ax.set_ylim(0, source_size + 1)
        ax.axhline(y=source_size / target_size, color="red", linestyle="--",
                    alpha=0.7, label=f"avg={source_size/target_size:.0f}")
        ax.legend(fontsize=8)

    # Use last subplot for summary
    ax = axes[7]
    losses = [np.log2(source_size) - np.log2(t) for t in target_sizes]
    ax.plot(target_sizes, losses, "o-", color="crimson", linewidth=2, markersize=8)
    ax.set_xlabel("Memory size (states)")
    ax.set_ylabel("Information loss (bits)")
    ax.set_title("Loss vs. Memory Size", fontsize=12)
    ax.grid(True, alpha=0.3)

    fig.suptitle(
        f"Memory Fiber Distributions (Source: Z/{source_size}Z)",
        fontsize=14, fontweight="bold",
    )
    plt.tight_layout()
    plt.savefig("viz_memory_fibers.png", dpi=150, bbox_inches="tight")
    print("Saved viz_memory_fibers.png")


if __name__ == "__main__":
    main()
