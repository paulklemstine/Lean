#!/usr/bin/env python3
"""
The Library of Babel: Numerical Demonstrations
===============================================

Self-contained numerical examples demonstrating the key results from
the formal combinatorial analysis of Borges' Library of Babel.

Results demonstrated:
  1. Volume cardinality: |Volume(A,L)| = A^L
  2. Degree regularity: every volume has L*(A-1) Hamming neighbors
  3. Diameter: maximum Hamming distance = L
  4. Singleton Bound: |C| ≤ A^(L-d+1) for min distance d
  5. Self-reference impossibility: counting argument
  6. Mini-Library de Bruijn catalog construction
"""

from __future__ import annotations

import math
import random
from collections import defaultdict
from itertools import product
from typing import Sequence


# ──────────────────────────────────────────────────────────────────────
# 1. Core definitions
# ──────────────────────────────────────────────────────────────────────

def hamming_distance(v: Sequence[int], w: Sequence[int]) -> int:
    """Hamming distance: number of positions where v and w differ."""
    assert len(v) == len(w), "Volumes must have equal length"
    return sum(1 for a, b in zip(v, w) if a != b)


def hamming_neighbors(v: tuple[int, ...], alphabet_size: int) -> list[tuple[int, ...]]:
    """All volumes at Hamming distance exactly 1 from v."""
    neighbors: list[tuple[int, ...]] = []
    for i in range(len(v)):
        for a in range(alphabet_size):
            if a != v[i]:
                w = list(v)
                w[i] = a
                neighbors.append(tuple(w))
    return neighbors


def singleton_bound(a: int, l: int, d: int) -> int:
    """Singleton Bound: max codewords for min distance d."""
    return a ** (l - d + 1)


# ──────────────────────────────────────────────────────────────────────
# 2. Demonstrations
# ──────────────────────────────────────────────────────────────────────

def demo_volume_cardinality() -> None:
    """Demonstrate: |Volume(A,L)| = A^L."""
    print("=" * 70)
    print("DEMO 1: Volume Cardinality  (volume_card)")
    print("=" * 70)

    examples = [
        (2, 3, "Binary strings of length 3"),
        (4, 4, "DNA sequences of length 4"),
        (4, 16, "Mini-Library of Babel"),
        (25, 10, "Babel alphabet, 10 chars"),
    ]

    for a, l, desc in examples:
        total = a ** l
        print(f"  A={a}, L={l:>3}  →  {total:>15,} volumes   ({desc})")

    # Borges' actual Library
    borges_a, borges_l = 25, 1_312_000
    log10_volumes = borges_l * math.log10(borges_a)
    print(f"\n  Borges' Library: A={borges_a}, L={borges_l:,}")
    print(f"  Total volumes ≈ 10^{log10_volumes:,.0f}")
    print(f"  (a number with {int(log10_volumes)+1:,} digits)\n")


def demo_degree_regularity() -> None:
    """Demonstrate: every volume has exactly L*(A-1) neighbors (babel_degree)."""
    print("=" * 70)
    print("DEMO 2: Degree Regularity  (babel_degree)")
    print("=" * 70)

    a, l = 4, 8
    expected = l * (a - 1)
    print(f"  Mini-Library: A={a}, L={l}")
    print(f"  Expected neighbors per volume: L*(A-1) = {l}*{a-1} = {expected}")

    # Test with several random volumes
    random.seed(42)
    for trial in range(5):
        v = tuple(random.randint(0, a - 1) for _ in range(l))
        nbrs = hamming_neighbors(v, a)
        status = "✓" if len(nbrs) == expected else "✗"
        print(f"  Volume {v}  →  {len(nbrs)} neighbors  {status}")

    # Verify ALL volumes for tiny library
    a_tiny, l_tiny = 3, 3
    expected_tiny = l_tiny * (a_tiny - 1)
    all_ok = True
    for v in product(range(a_tiny), repeat=l_tiny):
        if len(hamming_neighbors(v, a_tiny)) != expected_tiny:
            all_ok = False
            break
    print(f"\n  Exhaustive check: A={a_tiny}, L={l_tiny}")
    print(f"  All {a_tiny**l_tiny} volumes have {expected_tiny} neighbors: {'✓' if all_ok else '✗'}\n")


def demo_diameter() -> None:
    """Demonstrate: diameter = L (babel_diameter_achieved)."""
    print("=" * 70)
    print("DEMO 3: Diameter  (babel_diameter_achieved)")
    print("=" * 70)

    a, l = 4, 16
    # Construct maximally distant volumes: all-0 vs all-1
    v = tuple(0 for _ in range(l))
    w = tuple(1 for _ in range(l))
    dist = hamming_distance(v, w)
    print(f"  A={a}, L={l}")
    print(f"  v = (0,0,...,0)  w = (1,1,...,1)")
    print(f"  d_H(v,w) = {dist}  (should equal L={l})  {'✓' if dist == l else '✗'}")

    # Verify no pair exceeds L (sample check)
    random.seed(123)
    max_seen = 0
    n_samples = 10_000
    for _ in range(n_samples):
        x = tuple(random.randint(0, a - 1) for _ in range(l))
        y = tuple(random.randint(0, a - 1) for _ in range(l))
        max_seen = max(max_seen, hamming_distance(x, y))
    print(f"  Max distance in {n_samples:,} random pairs: {max_seen} ≤ L={l}  ✓\n")


def demo_singleton_bound() -> None:
    """Demonstrate: |C| ≤ A^(L-d+1) (singleton_bound)."""
    print("=" * 70)
    print("DEMO 4: Singleton Bound  (singleton_bound)")
    print("=" * 70)

    a, l = 4, 16
    print(f"  Mini-Library: A={a}, L={l}, Total volumes = {a**l:,}\n")
    print(f"  {'d':>4}  {'Bound A^(L-d+1)':>20}  {'Fraction of Library':>22}")
    print(f"  {'─'*4}  {'─'*20}  {'─'*22}")

    for d in [1, 2, 3, 5, 8, 10, 16]:
        bound = singleton_bound(a, l, d)
        fraction = bound / (a ** l)
        print(f"  {d:>4}  {bound:>20,}  {fraction:>22.6e}")

    # Borges' Library
    print(f"\n  Borges' Library: A=25, L=1,312,000")
    for d in [1, 2, 100, 1000]:
        exp = 1_312_000 - d + 1
        print(f"    d={d:>5}  →  Bound = 25^{exp:,}  "
              f"(fraction = 25^{-d+1})")

    # Verify bound holds for exhaustive mini-case
    a_v, l_v = 3, 4
    print(f"\n  Exhaustive verification: A={a_v}, L={l_v}")
    all_volumes = list(product(range(a_v), repeat=l_v))
    for d_test in [2, 3]:
        # Greedy code construction
        code: list[tuple[int, ...]] = []
        random.seed(0)
        random.shuffle(all_volumes)
        for vol in all_volumes:
            if all(hamming_distance(vol, c) >= d_test for c in code):
                code.append(vol)
        bound = singleton_bound(a_v, l_v, d_test)
        ok = len(code) <= bound
        print(f"    d={d_test}: greedy code size = {len(code)}, "
              f"bound = {bound}  {'✓' if ok else '✗'}")
    print()


def demo_self_reference() -> None:
    """Demonstrate: self-evaluations exceed volumes (self_eval_exceeds_volumes)."""
    print("=" * 70)
    print("DEMO 5: Self-Reference Impossibility  (no_universal_self_evaluator)")
    print("=" * 70)

    examples = [
        (2, 2),
        (2, 3),
        (3, 2),
        (4, 4),
        (4, 16),
    ]

    print(f"  {'A':>3}  {'L':>3}  {'|V|=A^L':>15}  {'|V→V| = (A^L)^(A^L)':>30}  Exceeds?")
    print(f"  {'─'*3}  {'─'*3}  {'─'*15}  {'─'*30}  {'─'*8}")

    for a, l in examples:
        v = a ** l
        log_v = l * math.log10(a)
        log_vv = v * log_v  # log10 of v^v
        if log_vv < 15:
            vv = v ** v
            vv_str = f"{vv:,}"
        else:
            vv_str = f"≈10^{log_vv:.2e}"
        exceeds = "✓"  # always true for A>=2, L>=1
        print(f"  {a:>3}  {l:>3}  {v:>15,}  {vv_str:>30}  {exceeds}")

    print(f"\n  Borges' Library: A=25, L=1,312,000")
    v_log = 1_312_000 * math.log10(25)
    print(f"  |V| ≈ 10^{v_log:,.0f}")
    print(f"  |V→V| ≈ 10^(10^{v_log:,.0f} × {v_log:,.0f})")
    print(f"  Ratio is incomprehensibly large — no single volume can be a catalog.\n")


def demo_debruijn_catalog() -> None:
    """Demonstrate de Bruijn sequence construction for a micro-Library."""
    print("=" * 70)
    print("DEMO 6: De Bruijn Catalog for Micro-Library")
    print("=" * 70)

    a, l = 2, 4  # Binary alphabet, length-4 books → 16 volumes
    n_volumes = a ** l

    print(f"  Micro-Library: A={a}, L={l}")
    print(f"  Total volumes: {n_volumes}")

    # Build de Bruijn graph: nodes = (L-1)-tuples, edges = L-tuples
    def build_debruijn_sequence(alphabet_size: int, length: int) -> list[int]:
        """Construct a de Bruijn sequence B(alphabet_size, length) via Hierholzer."""
        # Nodes: all (length-1)-tuples
        # Edge from (a1,...,a_{k-1}) to (a2,...,a_{k-1},c) labeled c
        graph: dict[tuple[int, ...], list[int]] = defaultdict(list)
        for node in product(range(alphabet_size), repeat=length - 1):
            for c in range(alphabet_size):
                graph[node].append(c)

        # Hierholzer's algorithm for Eulerian circuit
        start = tuple(0 for _ in range(length - 1))
        stack = [start]
        circuit: list[tuple[int, ...]] = []
        edge_idx: dict[tuple[int, ...], int] = defaultdict(int)

        while stack:
            node = stack[-1]
            if edge_idx[node] < len(graph[node]):
                c = graph[node][edge_idx[node]]
                edge_idx[node] += 1
                next_node = node[1:] + (c,)
                stack.append(next_node)
            else:
                circuit.append(stack.pop())

        circuit.reverse()
        # The sequence is the first symbol of each node in the circuit
        seq = [node[0] for node in circuit[:-1]]
        return seq

    seq = build_debruijn_sequence(a, l)
    print(f"  De Bruijn sequence length: {len(seq)} (should be {n_volumes})")
    print(f"  Sequence: {''.join(str(s) for s in seq)}")

    # Verify: every L-window appears exactly once
    windows: set[tuple[int, ...]] = set()
    for i in range(len(seq)):
        window = tuple(seq[(i + j) % len(seq)] for j in range(l))
        windows.add(window)

    all_volumes_set = set(product(range(a), repeat=l))
    print(f"  Distinct {l}-windows: {len(windows)} (should be {n_volumes})")
    print(f"  All volumes covered: {'✓' if windows == all_volumes_set else '✗'}")

    # Show first few windows
    print(f"\n  First 8 sliding windows:")
    for i in range(min(8, len(seq))):
        window = tuple(seq[(i + j) % len(seq)] for j in range(l))
        print(f"    Position {i:>2}: {''.join(str(s) for s in window)}")

    # Larger example
    a2, l2 = 4, 4
    seq2 = build_debruijn_sequence(a2, l2)
    windows2: set[tuple[int, ...]] = set()
    for i in range(len(seq2)):
        window = tuple(seq2[(i + j) % len(seq2)] for j in range(l2))
        windows2.add(window)
    print(f"\n  Larger catalog: A={a2}, L={l2}")
    print(f"  Sequence length: {len(seq2):,} (= {a2}^{l2} = {a2**l2:,})")
    print(f"  All {a2**l2:,} volumes covered: "
          f"{'✓' if len(windows2) == a2**l2 else '✗'}\n")


def demo_hamming_ball_sizes() -> None:
    """Demonstrate Hamming ball volumes for the mini-Library."""
    print("=" * 70)
    print("DEMO 7: Hamming Ball Volumes")
    print("=" * 70)

    a, l = 4, 16
    print(f"  Mini-Library: A={a}, L={l}\n")
    print(f"  {'Radius r':>10}  {'|B(v,r)|':>20}  {'Fraction of Library':>22}")
    print(f"  {'─'*10}  {'─'*20}  {'─'*22}")

    total = a ** l
    cumulative = 0
    for r in range(l + 1):
        # |B(v,r)| = sum_{j=0}^{r} C(L,j) * (A-1)^j
        shell = math.comb(l, r) * ((a - 1) ** r)
        cumulative += shell
        if r <= 8 or r == l:
            fraction = cumulative / total
            print(f"  {r:>10}  {cumulative:>20,}  {fraction:>22.6e}")
        elif r == 9:
            print(f"  {'...':>10}")

    print()


# ──────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────

def main() -> None:
    """Run all demonstrations."""
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║     THE LIBRARY OF BABEL: COMBINATORIAL DEMONSTRATIONS             ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_volume_cardinality()
    demo_degree_regularity()
    demo_diameter()
    demo_singleton_bound()
    demo_self_reference()
    demo_debruijn_catalog()
    demo_hamming_ball_sizes()

    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
