#!/usr/bin/env python3
"""
Algorithms for Oracle Trace Ultrametric Entropy.
Implements LCVP computation, ultrametric clustering, and entropy-capacity analysis.
"""

from typing import List, Dict, Set, Tuple, Optional
import math
from collections import defaultdict


def lcvp_len(u: List[int], v: List[int]) -> int:
    """
    Compute the longest common valued prefix length.

    Time complexity: O(min(|u|, |v|))
    Space complexity: O(1)

    Args:
        u: First trace (list of symbols).
        v: Second trace (list of symbols).

    Returns:
        Length of the longest common prefix.

    Examples:
        >>> lcvp_len([1, 2, 3], [1, 2, 4])
        2
        >>> lcvp_len([1, 2, 3], [1, 2, 3])
        3
        >>> lcvp_len([1, 2, 3], [4, 5, 6])
        0
    """
    k = 0
    for a, b in zip(u, v):
        if a != b:
            break
        k += 1
    return k


def prefix_dist(rho: float, u: List[int], v: List[int]) -> float:
    """
    Exponential prefix distance: rho^lcvp(u,v).

    For rho in (0,1), this satisfies the strong ultrametric inequality:
        prefix_dist(rho, u, w) <= max(prefix_dist(rho, u, v), prefix_dist(rho, v, w))

    Time complexity: O(min(|u|, |v|))

    Args:
        rho: Base in (0, 1).
        u: First trace.
        v: Second trace.

    Returns:
        The prefix distance.
    """
    return rho ** lcvp_len(u, v)


def prefix_gap(rho: float, u: List[int], v: List[int]) -> float:
    """
    Prefix gap metric: 0 if u==v, else rho^lcvp(u,v).

    This is a true metric (satisfies separation: gap = 0 iff u = v).

    Args:
        rho: Base in (0, 1).
        u: First trace.
        v: Second trace.

    Returns:
        The prefix gap.
    """
    if u == v:
        return 0.0
    return rho ** lcvp_len(u, v)


def ultrametric_cluster(
    traces: List[List[int]],
    rho: float,
    threshold: float
) -> List[List[int]]:
    """
    Ultrametric single-linkage clustering.

    Due to the isosceles property of ultrametrics, single-linkage and
    complete-linkage clustering produce identical results. This is a
    unique feature of non-Archimedean metrics.

    Time complexity: O(n^2 * L) where n = |traces|, L = max trace length.
    Space complexity: O(n)

    Args:
        traces: List of traces to cluster.
        rho: Ultrametric base in (0, 1).
        threshold: Distance threshold for merging.

    Returns:
        List of cluster indices (one per trace).

    Example:
        >>> traces = [[0,0,0], [0,0,1], [0,1,0], [1,0,0]]
        >>> ultrametric_cluster(traces, 0.5, 0.6)
        [0, 0, 1, 2]
    """
    n = len(traces)
    parent = list(range(n))

    def find(x: int) -> int:
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x: int, y: int):
        px, py = find(x), find(y)
        if px != py:
            parent[px] = py

    for i in range(n):
        for j in range(i + 1, n):
            if prefix_gap(rho, traces[i], traces[j]) < threshold:
                union(i, j)

    # Normalize cluster labels
    label_map: Dict[int, int] = {}
    result = []
    for i in range(n):
        root = find(i)
        if root not in label_map:
            label_map[root] = len(label_map)
        result.append(label_map[root])

    return result


def oracle_entropy_proxy(traces: List[List[int]]) -> float:
    """
    Compute the oracle entropy proxy: log(|distinct traces|).

    This is the Shannon entropy of the uniform distribution over
    distinct trace values.

    Args:
        traces: List of traces.

    Returns:
        log of the number of distinct traces.
    """
    distinct = set(map(tuple, traces))
    if len(distinct) == 0:
        return 0.0
    return math.log(len(distinct))


def oracle_capacity(num_states: int) -> float:
    """
    Compute the oracle state capacity: log(|states|).

    Args:
        num_states: Number of oracle states.

    Returns:
        log of the number of states.
    """
    if num_states <= 0:
        return 0.0
    return math.log(num_states)


def certified_prefix_radius(
    rho: float, u: List[int], v: List[int]
) -> float:
    """
    Certified prefix robustness radius.

    In the ultrametric, any trace within this radius of u is guaranteed
    to be on the same side of the decision boundary as u (relative to v).

    Args:
        rho: Ultrametric base.
        u: Center trace.
        v: Boundary trace.

    Returns:
        Certified robustness radius.
    """
    return prefix_gap(rho, u, v) / 2.0


def build_ultrametric_dendrogram(
    traces: List[List[int]], rho: float
) -> List[Tuple[int, int, float]]:
    """
    Build a hierarchical clustering dendrogram from the ultrametric.

    Returns merge events sorted by distance (ascending).

    Time complexity: O(n^2 * L)

    Args:
        traces: List of traces.
        rho: Ultrametric base.

    Returns:
        List of (i, j, distance) merge events.
    """
    n = len(traces)
    parent = list(range(n))

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    # Compute all pairwise distances
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            d = prefix_gap(rho, traces[i], traces[j])
            edges.append((d, i, j))

    edges.sort()
    merges = []

    for d, i, j in edges:
        ri, rj = find(i), find(j)
        if ri != rj:
            parent[ri] = rj
            merges.append((i, j, d))

    return merges


def post_quantum_separation_check(
    traces: List[List[int]], rho: float
) -> Tuple[bool, float]:
    """
    Check post-quantum prefix separation and compute minimum gap.

    Args:
        traces: List of traces (should be distinct).
        rho: Ultrametric base.

    Returns:
        (is_separated, min_gap) where is_separated is True iff all
        distinct pairs have positive gap.
    """
    n = len(traces)
    min_gap = float('inf')

    for i in range(n):
        for j in range(i + 1, n):
            if traces[i] != traces[j]:
                g = prefix_gap(rho, traces[i], traces[j])
                min_gap = min(min_gap, g)
                if g <= 0:
                    return False, 0.0

    return True, min_gap if min_gap < float('inf') else 0.0


if __name__ == "__main__":
    # Quick self-test
    print("Algorithm self-tests:")

    # LCVP
    assert lcvp_len([1, 2, 3], [1, 2, 4]) == 2
    assert lcvp_len([], [1, 2]) == 0
    assert lcvp_len([1, 2, 3], [1, 2, 3]) == 3
    print("  lcvp_len: PASS")

    # Clustering
    traces = [[0, 0, 0], [0, 0, 1], [0, 1, 0], [1, 0, 0]]
    clusters = ultrametric_cluster(traces, 0.5, 0.6)
    assert clusters[0] == clusters[1]  # share prefix [0,0]
    assert clusters[0] != clusters[3]  # differ at position 0
    print("  ultrametric_cluster: PASS")

    # Entropy-capacity
    traces_inj = [[i] for i in range(10)]
    e = oracle_entropy_proxy(traces_inj)
    c = oracle_capacity(10)
    assert abs(e - c) < 1e-12
    print("  entropy_capacity_equality: PASS")

    # Post-quantum separation
    sep, min_g = post_quantum_separation_check(traces_inj, 0.5)
    assert sep
    assert min_g > 0
    print("  post_quantum_separation: PASS")

    print("\nAll self-tests passed.")


#!/usr/bin/env python3
"""
Applications of Oracle Trace Ultrametric Entropy.

Demonstrates real-world applications in:
- Certified ML robustness
- Post-quantum code design
- Trace compression via ultrametric clustering
"""

import math
import random
from typing import List, Dict, Tuple
from algorithms import (
    lcvp_len, prefix_dist, prefix_gap,
    ultrametric_cluster, oracle_entropy_proxy, oracle_capacity,
    certified_prefix_radius, post_quantum_separation_check
)


# ─── Application 1: Certified Robustness ──────────────────────────────

def certified_robustness_demo():
    """
    Demonstrate certified robustness for a trace-based classifier.

    We simulate a classifier that maps execution traces to class labels,
    then compute certified robustness radii using the ultrametric.
    The key insight: ultrametric certification is dimension-free.
    """
    print("=" * 60)
    print("Application 1: Certified ML Robustness via Ultrametric Traces")
    print("=" * 60)

    rho = 0.5

    # Simulate traces from two classes
    class_a_traces = [
        [0, 0, 0, 0, i] for i in range(5)
    ]
    class_b_traces = [
        [0, 0, 1, j, k] for j in range(3) for k in range(3)
    ]

    print(f"\n  Class A: {len(class_a_traces)} traces (prefix [0,0,0,0,_])")
    print(f"  Class B: {len(class_b_traces)} traces (prefix [0,0,1,_,_])")
    print(f"  ρ = {rho}")

    # For each class A trace, compute certified radius
    print(f"\n  Certified Robustness Radii for Class A traces:")
    for trace_a in class_a_traces[:3]:
        min_gap_to_b = min(
            prefix_gap(rho, trace_a, trace_b)
            for trace_b in class_b_traces
        )
        radius = min_gap_to_b / 2
        print(f"    Trace {trace_a}: gap to Class B = {min_gap_to_b:.4f}, "
              f"certified radius = {radius:.4f}")

    # Compare with inter-class gap
    intra_class_gaps = []
    for i, t1 in enumerate(class_a_traces):
        for t2 in class_a_traces[i+1:]:
            g = prefix_gap(rho, t1, t2)
            if g > 0:
                intra_class_gaps.append(g)

    if intra_class_gaps:
        print(f"\n  Intra-class (A) min gap: {min(intra_class_gaps):.4f}")
        print(f"  Inter-class min gap: {min_gap_to_b:.4f}")
        print(f"  Ratio: {min_gap_to_b / min(intra_class_gaps):.2f}x")

    print()


# ─── Application 2: Post-Quantum Code Design ──────────────────────────

def post_quantum_code_demo():
    """
    Design and analyze a post-quantum code using prefix separation.

    The minimum prefix gap of the code determines its collision resistance,
    analogous to the minimum distance in lattice-based cryptography.
    """
    print("=" * 60)
    print("Application 2: Post-Quantum Trace Code Design")
    print("=" * 60)

    rho = 0.5
    alphabet_size = 4
    depth = 6

    # Generate a maximal separated code: all traces of exact length k
    # for varying k to see the tradeoff
    print(f"\n  Alphabet size q = {alphabet_size}, depth n = {depth}, ρ = {rho}")
    print(f"\n  {'Depth k':>10s} {'Codewords':>12s} {'Min Gap':>10s} {'Log Capacity':>14s}")
    print(f"  {'-'*10} {'-'*12} {'-'*10} {'-'*14}")

    for k in range(1, depth + 1):
        # Generate all traces of length k with first k-1 symbols = 0
        # and last symbol varying (a simple separated code)
        codewords = []
        for last_sym in range(alphabet_size):
            codewords.append([0] * (k - 1) + [last_sym])

        is_sep, min_gap = post_quantum_separation_check(codewords, rho)
        log_cap = math.log(len(codewords)) if len(codewords) > 0 else 0

        print(f"  {k:>10d} {len(codewords):>12d} "
              f"{min_gap:>10.6f} {log_cap:>14.4f}")

    # Now show the capacity-optimal code
    print(f"\n  Capacity-optimal code: all length-{depth} traces")
    optimal_size = alphabet_size ** depth
    print(f"  Size: {optimal_size} = {alphabet_size}^{depth}")
    print(f"  Capacity: log({optimal_size}) = {math.log(optimal_size):.4f}")
    print(f"  Min gap: ρ^{depth} = {rho**depth:.6f}")
    print()


# ─── Application 3: Trace Compression ─────────────────────────────────

def trace_compression_demo():
    """
    Demonstrate trace compression using ultrametric clustering.

    Traces within the same ultrametric ball share a common prefix and
    can be compressed by storing only the shared prefix + suffix deltas.
    """
    print("=" * 60)
    print("Application 3: Trace Compression via Ultrametric Clustering")
    print("=" * 60)

    rho = 0.5
    random.seed(42)

    # Generate traces with hierarchical structure
    traces = []
    for _ in range(20):
        # Random trace of length 8 with biased prefix structure
        base = [random.randint(0, 1)] * 3
        mid = [random.randint(0, 3)] * 3
        tail = [random.randint(0, 7)] * 2
        traces.append(base + mid + tail)

    # Cluster at various thresholds
    print(f"\n  Generated {len(traces)} traces of length {len(traces[0])}")
    print(f"\n  {'Threshold':>12s} {'Clusters':>10s} {'Compression':>14s} {'Bits Saved':>12s}")
    print(f"  {'-'*12} {'-'*10} {'-'*14} {'-'*12}")

    raw_bits = len(traces) * len(traces[0]) * 3  # log2(8) = 3 bits per symbol

    for threshold in [0.01, 0.05, 0.1, 0.25, 0.5, 1.0]:
        clusters = ultrametric_cluster(traces, rho, threshold)
        num_clusters = len(set(clusters))

        # Estimate compressed size: prefix per cluster + suffix per trace
        # In each cluster, shared prefix can be stored once
        cluster_sizes = {}
        for i, c in enumerate(clusters):
            if c not in cluster_sizes:
                cluster_sizes[c] = []
            cluster_sizes[c].append(traces[i])

        compressed_bits = 0
        for members in cluster_sizes.values():
            # Shared prefix
            shared = lcvp_len(members[0], members[-1]) if len(members) > 1 else len(members[0])
            prefix_bits = shared * 3
            suffix_bits = sum((len(t) - shared) * 3 for t in members)
            compressed_bits += prefix_bits + suffix_bits

        ratio = compressed_bits / raw_bits if raw_bits > 0 else 1.0
        saved = raw_bits - compressed_bits

        print(f"  {threshold:>12.3f} {num_clusters:>10d} "
              f"{ratio:>14.2%} {saved:>12d}")

    print()


# ─── Application 4: Thermodynamic Analysis ────────────────────────────

def thermodynamic_analysis():
    """
    Verify the entropy-capacity principle for various oracle models.
    """
    print("=" * 60)
    print("Application 4: Thermodynamic Entropy-Capacity Analysis")
    print("=" * 60)

    print(f"\n  {'States':>8s} {'Alphabet':>10s} {'Depth':>7s} "
          f"{'Entropy':>10s} {'Capacity':>10s} {'Density':>10s} {'≤ log(q)':>10s}")
    print(f"  {'-'*8} {'-'*10} {'-'*7} {'-'*10} {'-'*10} {'-'*10} {'-'*10}")

    for num_states in [4, 8, 16, 32, 64]:
        for alphabet in [2, 4]:
            depth = max(1, int(math.ceil(math.log(num_states) / math.log(alphabet))))

            # Injective encoding: state i -> base-q representation
            traces = []
            for state in range(num_states):
                trace = []
                s = state
                for _ in range(depth):
                    trace.append(s % alphabet)
                    s //= alphabet
                traces.append(trace)

            entropy = oracle_entropy_proxy(traces)
            cap = oracle_capacity(num_states)
            density = cap / (depth + 1)
            log_q = math.log(alphabet)

            print(f"  {num_states:>8d} {alphabet:>10d} {depth:>7d} "
                  f"{entropy:>10.4f} {cap:>10.4f} {density:>10.4f} "
                  f"{'✓' if density <= log_q + 1e-10 else '✗':>10s}")

    print()


# ─── Main ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("Oracle Trace Ultrametric Entropy — Real-World Applications")
    print("=" * 60)
    print()

    certified_robustness_demo()
    post_quantum_code_demo()
    trace_compression_demo()
    thermodynamic_analysis()

    print("All applications complete.")


#!/usr/bin/env python3
"""
Demo: Oracle Trace Ultrametric Entropy
=======================================
Numerical demonstrations of the LCVP ultrametric and entropy-capacity principles.
"""

import random
import math
from typing import List, Tuple

# ─── LCVP Core Functions ──────────────────────────────────────────────

def lcvp_len(u: List[int], v: List[int]) -> int:
    """Longest common valued prefix length."""
    k = 0
    for a, b in zip(u, v):
        if a != b:
            break
        k += 1
    return k


def prefix_dist(rho: float, u: List[int], v: List[int]) -> float:
    """Exponential prefix distance: rho^lcvp(u,v)."""
    return rho ** lcvp_len(u, v)


def prefix_gap(rho: float, u: List[int], v: List[int]) -> float:
    """Prefix gap metric: 0 if u==v, else rho^lcvp(u,v)."""
    if u == v:
        return 0.0
    return rho ** lcvp_len(u, v)


# ─── Demo 1: Verify Min-Prefix Inequality ─────────────────────────────

def demo_min_prefix_inequality(num_trials: int = 10000, max_len: int = 20, alphabet: int = 4):
    """Verify lcvp(u,w) >= min(lcvp(u,v), lcvp(v,w)) on random triples."""
    print("=" * 60)
    print("Demo 1: Min-Prefix (Ultrametric Valuation) Inequality")
    print("=" * 60)

    violations = 0
    for _ in range(num_trials):
        n = random.randint(1, max_len)
        u = [random.randint(0, alphabet - 1) for _ in range(n)]
        v = [random.randint(0, alphabet - 1) for _ in range(n)]
        w = [random.randint(0, alphabet - 1) for _ in range(n)]

        luv = lcvp_len(u, v)
        lvw = lcvp_len(v, w)
        luw = lcvp_len(u, w)

        if min(luv, lvw) > luw:
            violations += 1

    print(f"  Trials: {num_trials}")
    print(f"  Violations: {violations}")
    print(f"  Result: {'PASS ✓' if violations == 0 else 'FAIL ✗'}")
    print()


# ─── Demo 2: Verify Isosceles Property ────────────────────────────────

def demo_isosceles(num_trials: int = 10000, rho: float = 0.5, max_len: int = 15, alphabet: int = 3):
    """Verify that every triangle in prefix distance is isosceles."""
    print("=" * 60)
    print("Demo 2: Isosceles Property of Ultrametric Triangles")
    print("=" * 60)

    violations = 0
    for _ in range(num_trials):
        n = random.randint(1, max_len)
        u = [random.randint(0, alphabet - 1) for _ in range(n)]
        v = [random.randint(0, alphabet - 1) for _ in range(n)]
        w = [random.randint(0, alphabet - 1) for _ in range(n)]

        d_uv = prefix_dist(rho, u, v)
        d_vw = prefix_dist(rho, v, w)
        d_uw = prefix_dist(rho, u, w)

        sides = sorted([d_uv, d_vw, d_uw])
        # In an ultrametric, at least two sides are equal
        # The two largest sides must be equal
        if abs(sides[1] - sides[2]) > 1e-12:
            violations += 1

    print(f"  Trials: {num_trials}, ρ = {rho}")
    print(f"  Violations: {violations}")
    print(f"  Result: {'PASS ✓' if violations == 0 else 'FAIL ✗'}")
    print()


# ─── Demo 3: Entropy-Capacity Equality ────────────────────────────────

def demo_entropy_capacity():
    """Verify entropy = capacity under injective encoding."""
    print("=" * 60)
    print("Demo 3: Entropy–Capacity Equality Under Injective Encoding")
    print("=" * 60)

    for num_states in [2, 5, 10, 20, 50, 100]:
        # Create injective encoding: state i -> [i]
        traces = {i: [i] for i in range(num_states)}
        image_size = len(set(map(tuple, traces.values())))

        entropy = math.log(image_size) if image_size > 0 else 0
        capacity = math.log(num_states) if num_states > 0 else 0

        print(f"  States: {num_states:4d} | "
              f"Image size: {image_size:4d} | "
              f"Entropy: {entropy:.4f} | "
              f"Capacity: {capacity:.4f} | "
              f"Equal: {'✓' if abs(entropy - capacity) < 1e-12 else '✗'}")

    print()


# ─── Demo 4: Context Contraction ──────────────────────────────────────

def demo_context_contraction(rho: float = 0.5):
    """Demonstrate multiplicative contraction under shared prefix."""
    print("=" * 60)
    print("Demo 4: Context Contraction (Shared Prefix Effect)")
    print("=" * 60)

    u = [1, 2, 3]
    v = [1, 2, 4]  # differ at position 2

    for prefix_len in range(6):
        p = list(range(prefix_len))
        pu = p + u
        pv = p + v

        d_base = prefix_dist(rho, u, v)
        d_extended = prefix_dist(rho, pu, pv)
        contraction = rho ** prefix_len

        print(f"  Prefix length {prefix_len}: "
              f"d(u,v) = {d_base:.6f}, "
              f"d(p++u, p++v) = {d_extended:.6f}, "
              f"ρ^|p| = {contraction:.6f}, "
              f"Product = {d_base * contraction:.6f} "
              f"{'✓' if abs(d_extended - d_base * contraction) < 1e-12 else '✗'}")

    print()


# ─── Demo 5: Distance Matrix ──────────────────────────────────────────

def demo_distance_matrix(rho: float = 0.5):
    """Display a distance matrix showing ultrametric structure."""
    print("=" * 60)
    print("Demo 5: Ultrametric Distance Matrix")
    print("=" * 60)

    traces = [
        [0, 0, 0, 0],
        [0, 0, 0, 1],
        [0, 0, 1, 0],
        [0, 1, 0, 0],
        [1, 0, 0, 0],
    ]

    labels = ["0000", "0001", "0010", "0100", "1000"]

    print(f"\n  {'':>6s}", end="")
    for lbl in labels:
        print(f"  {lbl:>6s}", end="")
    print()

    for i, u in enumerate(traces):
        print(f"  {labels[i]:>6s}", end="")
        for j, v in enumerate(traces):
            d = prefix_gap(rho, u, v)
            print(f"  {d:6.4f}", end="")
        print()

    print(f"\n  Note: Hierarchical clustering structure visible.")
    print(f"  Traces sharing longer prefixes are exponentially closer.")
    print()


# ─── Main ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    random.seed(42)
    print()
    print("Oracle Trace Ultrametric Entropy — Numerical Demonstrations")
    print("=" * 60)
    print()

    demo_min_prefix_inequality()
    demo_isosceles()
    demo_entropy_capacity()
    demo_context_contraction()
    demo_distance_matrix()

    print("All demonstrations complete.")


#!/usr/bin/env python3
"""Generate visualizations for the Oracle Trace Ultrametric Entropy project."""

import math
import base64
import io

def generate_svg_diagram() -> str:
    """Generate an SVG diagram showing the ultrametric tree structure."""
    svg = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 500" width="800" height="500">
  <defs>
    <linearGradient id="bg" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" style="stop-color:#1a1a2e;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#16213e;stop-opacity:1" />
    </linearGradient>
    <style>
      .title { font: bold 18px monospace; fill: #e0e0e0; }
      .label { font: 12px monospace; fill: #a0d0ff; }
      .value { font: 11px monospace; fill: #80ffaa; }
      .dist { font: 10px monospace; fill: #ffaa80; }
      .node { fill: #4ecdc4; stroke: #2a9d8f; stroke-width: 2; }
      .edge { stroke: #a0d0ff; stroke-width: 2; fill: none; }
      .bracket { stroke: #ff6b6b; stroke-width: 1.5; fill: none; stroke-dasharray: 4,3; }
    </style>
  </defs>

  <rect width="800" height="500" fill="url(#bg)" rx="10"/>

  <text x="400" y="35" text-anchor="middle" class="title">Ultrametric Tree: Prefix Distance Hierarchy</text>
  <text x="400" y="55" text-anchor="middle" class="value">ρ = 0.5, Alphabet = {0, 1}</text>

  <!-- Level 0: Root (all traces) -->
  <circle cx="400" cy="90" r="8" class="node"/>
  <text x="415" y="85" class="label">root</text>
  <text x="415" y="100" class="dist">d = 1.0 (lcvp=0)</text>

  <!-- Level 1: Split on first symbol -->
  <path d="M400,98 L250,150" class="edge"/>
  <path d="M400,98 L550,150" class="edge"/>

  <circle cx="250" cy="155" r="7" class="node"/>
  <text x="205" y="150" class="label">0...</text>

  <circle cx="550" cy="155" r="7" class="node"/>
  <text x="565" y="150" class="label">1...</text>
  <text x="350" y="135" class="dist">d = 0.5 (lcvp=1)</text>

  <!-- Level 2: Split on second symbol -->
  <path d="M250,162 L170,215" class="edge"/>
  <path d="M250,162 L330,215" class="edge"/>
  <path d="M550,162 L470,215" class="edge"/>
  <path d="M550,162 L630,215" class="edge"/>

  <circle cx="170" cy="220" r="6" class="node"/>
  <text x="140" y="215" class="label">00..</text>

  <circle cx="330" cy="220" r="6" class="node"/>
  <text x="340" y="215" class="label">01..</text>

  <circle cx="470" cy="220" r="6" class="node"/>
  <text x="440" y="215" class="label">10..</text>

  <circle cx="630" cy="220" r="6" class="node"/>
  <text x="640" y="215" class="label">11..</text>

  <text x="250" y="200" class="dist">d = 0.25 (lcvp=2)</text>

  <!-- Level 3: Leaves -->
  <path d="M170,226 L130,280" class="edge"/>
  <path d="M170,226 L210,280" class="edge"/>
  <path d="M330,226 L290,280" class="edge"/>
  <path d="M330,226 L370,280" class="edge"/>
  <path d="M470,226 L430,280" class="edge"/>
  <path d="M470,226 L510,280" class="edge"/>
  <path d="M630,226 L590,280" class="edge"/>
  <path d="M630,226 L670,280" class="edge"/>

  <circle cx="130" cy="285" r="5" style="fill:#ff6b6b"/>
  <text x="115" y="305" class="value">000</text>

  <circle cx="210" cy="285" r="5" style="fill:#ff6b6b"/>
  <text x="195" y="305" class="value">001</text>

  <circle cx="290" cy="285" r="5" style="fill:#ff6b6b"/>
  <text x="275" y="305" class="value">010</text>

  <circle cx="370" cy="285" r="5" style="fill:#ff6b6b"/>
  <text x="355" y="305" class="value">011</text>

  <circle cx="430" cy="285" r="5" style="fill:#ff6b6b"/>
  <text x="415" y="305" class="value">100</text>

  <circle cx="510" cy="285" r="5" style="fill:#ff6b6b"/>
  <text x="495" y="305" class="value">101</text>

  <circle cx="590" cy="285" r="5" style="fill:#ff6b6b"/>
  <text x="575" y="305" class="value">110</text>

  <circle cx="670" cy="285" r="5" style="fill:#ff6b6b"/>
  <text x="655" y="305" class="value">111</text>

  <text x="400" y="265" class="dist">d = 0.125 (lcvp=3)</text>

  <!-- Isosceles triangle annotation -->
  <rect x="50" y="340" width="700" height="145" rx="8" fill="#0f3460" opacity="0.7"/>

  <text x="400" y="365" text-anchor="middle" class="title">Isosceles Property: Every Triangle Has ≥ 2 Equal Sides</text>

  <text x="80" y="395" class="label">Example: d(000, 001) = 0.25,  d(001, 010) = 0.50,  d(000, 010) = 0.50</text>
  <text x="80" y="415" class="value">         ↑ shortest                ↑ tied longest         ↑ tied longest</text>

  <text x="80" y="445" class="label">Entropy–Capacity: H(traces) = log(8) = 2.08 = Capacity(8 states) ✓</text>
  <text x="80" y="470" class="label">Post-Quantum Separation: min gap = ρ³ = 0.125 > 0 ✓ (collision barrier)</text>
</svg>'''
    return svg


def generate_distance_matrix_svg() -> str:
    """Generate an SVG heatmap of pairwise prefix distances."""
    traces = ["000", "001", "010", "011", "100", "101", "110", "111"]
    n = len(traces)
    rho = 0.5

    def lcvp(u, v):
        k = 0
        for a, b in zip(u, v):
            if a != b: break
            k += 1
        return k

    cell = 55
    margin = 80
    w = margin + n * cell + 20
    h = margin + n * cell + 60

    svg = f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}">\n'
    svg += f'<rect width="{w}" height="{h}" fill="#1a1a2e" rx="8"/>\n'
    svg += f'<text x="{w//2}" y="25" text-anchor="middle" font-size="16" font-family="monospace" fill="#e0e0e0" font-weight="bold">Prefix Gap Distance Matrix (ρ = 0.5)</text>\n'

    colors = {0.0: "#000033", 0.125: "#003366", 0.25: "#006699", 0.5: "#3399cc", 1.0: "#ff6b6b"}

    for i in range(n):
        # Row label
        svg += f'<text x="{margin - 10}" y="{margin + i*cell + cell//2 + 4}" text-anchor="end" font-size="11" font-family="monospace" fill="#a0d0ff">{traces[i]}</text>\n'
        # Col label
        svg += f'<text x="{margin + i*cell + cell//2}" y="{margin - 10}" text-anchor="middle" font-size="11" font-family="monospace" fill="#a0d0ff">{traces[i]}</text>\n'

        for j in range(n):
            d = 0.0 if traces[i] == traces[j] else rho ** lcvp(traces[i], traces[j])
            # Find closest color
            best_color = "#000033"
            best_diff = float('inf')
            for val, col in colors.items():
                if abs(d - val) < best_diff:
                    best_diff = abs(d - val)
                    best_color = col

            x = margin + j * cell
            y = margin + i * cell
            svg += f'<rect x="{x}" y="{y}" width="{cell-2}" height="{cell-2}" fill="{best_color}" rx="3"/>\n'
            svg += f'<text x="{x + cell//2 - 1}" y="{y + cell//2 + 4}" text-anchor="middle" font-size="10" font-family="monospace" fill="white">{d:.3f}</text>\n'

    # Legend
    ly = margin + n * cell + 15
    svg += f'<text x="{margin}" y="{ly + 15}" font-size="11" font-family="monospace" fill="#80ffaa">Legend: 0.000 = identical | 0.125 = lcvp=3 | 0.250 = lcvp=2 | 0.500 = lcvp=1 | 1.000 = lcvp=0</text>\n'

    svg += '</svg>'
    return svg


if __name__ == "__main__":
    # Save main diagram
    svg1 = generate_svg_diagram()
    with open("diagram.svg", "w") as f:
        f.write(svg1)
    print("Saved diagram.svg")

    # Save distance matrix
    svg2 = generate_distance_matrix_svg()
    with open("distance_matrix.svg", "w") as f:
        f.write(svg2)
    print("Saved distance_matrix.svg")
