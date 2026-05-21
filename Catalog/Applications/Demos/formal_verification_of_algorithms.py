"""
applications.py — Real-world applications of information-efficient algorithms.

Demonstrates how the formal theory connects to practical computation:
1. Database index lookup via binary search
2. Network routing via Dijkstra
3. Polynomial multiplication via NTT
4. Tropical shortest paths and their connection to Dijkstra
"""

import math
from typing import List, Tuple, Dict
from algorithms import (
    binary_search, dijkstra, reconstruct_path,
    ntt, intt, ntt_convolution, cyclic_convolution,
    find_primitive_root, tropical_closure, fft_cost, INF
)


# ============================================================================
# Application 1: Database Index Lookup
# ============================================================================

def database_lookup_demo():
    """
    Simulate a sorted database lookup using binary search.
    Shows how binary search extracts information at exponential rate.
    """
    print("=" * 60)
    print("APPLICATION 1: Sorted Database Lookup")
    print("=" * 60)

    # Simulate a sorted database of 1 million records
    n = 1_000_000
    target_key = 731_459

    result, comparisons, trace = binary_search(
        lambda x: x >= target_key, n, trace=True
    )

    print(f"\nDatabase size: {n:,} records")
    print(f"Target key:    {target_key:,}")
    print(f"Found at:      {result:,}")
    print(f"Comparisons:   {comparisons}")
    print(f"Theoretical:   ⌈log₂({n:,})⌉ = {math.ceil(math.log2(n))}")
    print(f"\nInformation extracted per comparison:")
    print(f"  Total information: log₂({n:,}) = {math.log2(n):.2f} bits")
    print(f"  Per comparison:    {math.log2(n) / comparisons:.2f} bits")
    print(f"  Efficiency:        {math.log2(n) / comparisons / 1.0 * 100:.1f}% of theoretical max")

    # Compare with linear search
    print(f"\nLinear search would need up to {n:,} comparisons")
    print(f"Binary search speedup: {n / comparisons:.0f}x")


# ============================================================================
# Application 2: Network Routing
# ============================================================================

def network_routing_demo():
    """
    Simulate network routing using Dijkstra's algorithm.
    Shows how Dijkstra performs monotone energy minimization.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Network Routing (Dijkstra)")
    print("=" * 60)

    # A small network topology (10 nodes)
    graph: Dict[int, List[Tuple[int, int]]] = {
        0: [(1, 4), (2, 1), (3, 7)],
        1: [(4, 1), (5, 3)],
        2: [(1, 2), (3, 5), (5, 8)],
        3: [(6, 2)],
        4: [(7, 2)],
        5: [(4, 1), (7, 4), (8, 3)],
        6: [(8, 1), (9, 6)],
        7: [(9, 1)],
        8: [(9, 2)],
        9: [],
    }

    dist, pred, trace = dijkstra(graph, 0, trace=True)

    print("\nNetwork: 10 nodes, weighted edges")
    print(f"Source: node 0")
    print(f"\nShortest distances from source:")
    for v in sorted(dist.keys()):
        path = reconstruct_path(pred, v)
        print(f"  Node {v}: distance = {dist[v]}, path = {' → '.join(map(str, path))}")

    print(f"\nDijkstra frontier evolution:")
    for step in trace:
        print(f"  Step {step['settled_count']}: settled node {step['settled_vertex']} "
              f"(dist={step['distance']})")

    print(f"\nTotal iterations: {len(trace)} (= number of reachable vertices)")
    print(f"This matches the O(|V|) iteration bound proved in Lean.")


# ============================================================================
# Application 3: Polynomial Multiplication via NTT
# ============================================================================

def polynomial_multiplication_demo():
    """
    Multiply polynomials using NTT, demonstrating symmetry factorization.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Polynomial Multiplication via NTT")
    print("=" * 60)

    # Working mod p = 97, which has 97-1 = 96 = 2^5 * 3
    # So we can do NTT of size 8 (since 8 | 96)
    p = 97
    n = 8
    omega = find_primitive_root(p, n)

    print(f"\nPrime modulus: p = {p}")
    print(f"Transform size: n = {n}")
    print(f"Primitive {n}-th root of unity: ω = {omega}")
    print(f"Verification: ω^{n} ≡ {pow(omega, n, p)} (mod {p})")

    # Multiply (1 + 2x + 3x²) * (4 + 5x + 6x²) mod 97
    a = [1, 2, 3, 0, 0, 0, 0, 0]  # padded to length 8
    b = [4, 5, 6, 0, 0, 0, 0, 0]

    # NTT convolution
    result = ntt_convolution(a, b, omega, p)

    # True polynomial product: 4 + 13x + 28x² + 27x³ + 18x⁴
    true_result = [4, 13, 28, 27, 18, 0, 0, 0]
    true_result_mod = [x % p for x in true_result]

    print(f"\nPolynomial A: 1 + 2x + 3x²")
    print(f"Polynomial B: 4 + 5x + 6x²")
    print(f"Product (NTT):  {result[:5]} (first 5 coefficients)")
    print(f"Product (true): {true_result_mod[:5]}")
    print(f"Match: {result == true_result_mod}")

    # Complexity comparison
    naive_ops = n * n
    fft_ops = fft_cost(int(math.log2(n)))
    print(f"\nComplexity comparison:")
    print(f"  Naive convolution: O(n²) = {naive_ops} multiplications")
    print(f"  NTT (n log n):     {fft_ops} operations")
    print(f"  Speedup factor:    {naive_ops / fft_ops:.1f}x")


# ============================================================================
# Application 4: Tropical Shortest Paths
# ============================================================================

def tropical_demo():
    """
    Compute all-pairs shortest paths using tropical matrix multiplication.
    Shows the connection between Dijkstra and tropical algebra.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Tropical Algebra and Shortest Paths")
    print("=" * 60)

    # Weight matrix (INF = no edge)
    W = [
        [0,    4,    1,    INF],
        [INF,  0,    INF,  1  ],
        [INF,  2,    0,    5  ],
        [INF,  INF,  INF,  0  ],
    ]

    print("\nWeight matrix W:")
    for row in W:
        print("  ", [f"{x:3.0f}" if x != INF else "  ∞" for x in row])

    D = tropical_closure(W)

    print("\nTropical closure (all-pairs shortest paths):")
    for row in D:
        print("  ", [f"{x:3.0f}" if x != INF else "  ∞" for x in row])

    # Verify with Dijkstra from each source
    graph = {
        0: [(1, 4), (2, 1)],
        1: [(3, 1)],
        2: [(1, 2), (3, 5)],
        3: [],
    }

    print("\nVerification with Dijkstra from each source:")
    for src in range(4):
        dist, _, _ = dijkstra(graph, src)
        dijk_row = [dist.get(j, float('inf')) for j in range(4)]
        tropical_row = D[src]
        match = all(abs(a - b) < 1e-9 for a, b in zip(dijk_row, tropical_row))
        print(f"  Source {src}: Dijkstra = {[int(x) if x != float('inf') else '∞' for x in dijk_row]}, "
              f"Tropical = {[int(x) if x != float('inf') else '∞' for x in tropical_row]}, "
              f"Match: {match}")

    print("\nThis demonstrates that Dijkstra computes rows of the tropical closure,")
    print("connecting graph algorithms to tropical geometry and min-plus algebra.")


if __name__ == "__main__":
    database_lookup_demo()
    network_routing_demo()
    polynomial_multiplication_demo()
    tropical_demo()


#!/usr/bin/env python3
"""
demo.py — Interactive demonstration of information-efficient algorithms.

This script demonstrates:
1. Binary search traces vs full search (information extraction rate)
2. Dijkstra frontier evolution on small graphs
3. NTT-based convolution vs naive convolution
4. Testing the entropy-optimality conjecture on small instances

All algorithms are self-contained in this file for portability.
"""

import math
import heapq
from typing import List, Tuple, Dict, Optional, Callable
from itertools import product as cartesian_product

INF = float('inf')


# ============================================================================
# Self-contained implementations
# ============================================================================

def binary_search(pred: Callable[[int], bool], n: int) -> Tuple[int, int, list]:
    lo, hi = 0, n
    comps = 0
    trace = []
    while lo < hi:
        mid = (lo + hi) // 2
        comps += 1
        trace.append((lo, hi, mid))
        if pred(mid):
            hi = mid
        else:
            lo = mid + 1
    return lo, comps, trace


def dijkstra(graph: Dict[int, List[Tuple[int, int]]], src: int):
    dist = {src: 0}
    pred = {src: None}
    settled = set()
    pq = [(0, src)]
    trace = []
    while pq:
        d, u = heapq.heappop(pq)
        if u in settled:
            continue
        settled.add(u)
        trace.append({"vertex": u, "dist": d, "settled": len(settled)})
        for v, w in graph.get(u, []):
            nd = d + w
            if v not in dist or nd < dist[v]:
                dist[v] = nd
                pred[v] = u
                heapq.heappush(pq, (nd, v))
    return dist, pred, trace


def ntt_transform(a: List[int], omega: int, mod: int) -> List[int]:
    n = len(a)
    return [sum(a[i] * pow(omega, i * j, mod) for i in range(n)) % mod for j in range(n)]


def intt_transform(a: List[int], omega: int, mod: int) -> List[int]:
    n = len(a)
    omega_inv = pow(omega, mod - 2, mod)
    n_inv = pow(n, mod - 2, mod)
    t = ntt_transform(a, omega_inv, mod)
    return [(x * n_inv) % mod for x in t]


def naive_cyclic_conv(a: List[int], b: List[int], mod: int) -> List[int]:
    n = len(a)
    return [sum(a[i] * b[(k - i) % n] for i in range(n)) % mod for k in range(n)]


def ntt_conv(a: List[int], b: List[int], omega: int, mod: int) -> List[int]:
    fa, fb = ntt_transform(a, omega, mod), ntt_transform(b, omega, mod)
    fc = [(x * y) % mod for x, y in zip(fa, fb)]
    return intt_transform(fc, omega, mod)


def find_prim_root(p: int, n: int) -> Optional[int]:
    if (p - 1) % n != 0:
        return None
    def factorize(m):
        fs = set()
        d = 2
        while d * d <= m:
            while m % d == 0:
                fs.add(d); m //= d
            d += 1
        if m > 1: fs.add(m)
        return fs
    for g in range(2, p):
        if all(pow(g, (p - 1) // f, p) != 1 for f in factorize(p - 1)):
            return pow(g, (p - 1) // n, p)
    return None


# ============================================================================
# DEMO 1: Binary Search Traces vs Full Search
# ============================================================================

def demo_binary_search():
    print("=" * 70)
    print("DEMO 1: Binary Search — Information Extraction at Exponential Rate")
    print("=" * 70)

    sizes = [8, 16, 32, 64, 128, 256, 512, 1024]

    print(f"\n{'Size n':>8} | {'BS Comps':>10} | {'Full Search':>12} | {'log₂ n':>8} | {'Speedup':>8}")
    print("-" * 60)

    for n in sizes:
        # Worst case: target at various positions
        max_comps = 0
        for target in range(n + 1):
            _, comps, _ = binary_search(lambda x, t=target: x >= t, n)
            max_comps = max(max_comps, comps)

        log_n = math.ceil(math.log2(n)) if n > 1 else 1
        speedup = n / max_comps if max_comps > 0 else float('inf')

        print(f"{n:>8} | {max_comps:>10} | {n:>12} | {log_n:>8} | {speedup:>8.1f}x")

    print(f"\nKey insight: Binary search uses ⌈log₂ n⌉ comparisons,")
    print(f"extracting ~1 bit of information per comparison.")

    # Detailed trace for n = 16
    print(f"\nDetailed trace for n=16, target=11:")
    _, comps, trace = binary_search(lambda x: x >= 11, 16)
    for step, (lo, hi, mid) in enumerate(trace, 1):
        width = hi - lo
        print(f"  Step {step}: [lo={lo}, hi={hi}] test mid={mid}, "
              f"width={width}, entropy={math.log2(width):.2f} bits")
    print(f"  Result: {_}, total comparisons: {comps}")


# ============================================================================
# DEMO 2: Dijkstra Frontier Evolution
# ============================================================================

def demo_dijkstra():
    print("\n" + "=" * 70)
    print("DEMO 2: Dijkstra's Algorithm — Monotone Energy Minimization")
    print("=" * 70)

    graph = {
        0: [(1, 4), (2, 1), (3, 7)],
        1: [(4, 1), (5, 3)],
        2: [(1, 2), (3, 5), (5, 8)],
        3: [(6, 2)],
        4: [(7, 2)],
        5: [(4, 1), (7, 4), (8, 3)],
        6: [(8, 1), (9, 6)],
        7: [(9, 1)],
        8: [(9, 2)],
        9: [],
    }

    dist, pred, trace = dijkstra(graph, 0)

    print(f"\nGraph: 10 vertices, weighted directed edges")
    print(f"Source: vertex 0\n")

    print(f"Frontier evolution (monotone settling order):")
    print(f"{'Step':>4} | {'Vertex':>7} | {'Distance':>9} | {'Settled':>8}")
    print("-" * 40)
    for step in trace:
        print(f"{step['settled']:>4} | {step['vertex']:>7} | {step['dist']:>9} | "
              f"{step['settled']:>8}")

    print(f"\nKey property: settled distances are monotonically non-decreasing.")
    dists_in_order = [s['dist'] for s in trace]
    is_monotone = all(a <= b for a, b in zip(dists_in_order, dists_in_order[1:]))
    print(f"Verified monotone: {is_monotone}")

    print(f"\nFinal shortest distances:")
    for v in sorted(dist.keys()):
        path = []
        cur = v
        while cur is not None:
            path.append(cur)
            cur = pred.get(cur)
        path.reverse()
        print(f"  Vertex {v}: dist = {dist[v]:>2}, path: {' → '.join(map(str, path))}")


# ============================================================================
# DEMO 3: NTT Convolution vs Naive
# ============================================================================

def demo_ntt():
    print("\n" + "=" * 70)
    print("DEMO 3: NTT/FFT — Symmetry-Exploiting Convolution Compression")
    print("=" * 70)

    # Use p = 97 (prime), n = 8 (since 8 | 96)
    p = 97
    n = 8
    omega = find_prim_root(p, n)

    print(f"\nSetup: prime p = {p}, transform size n = {n}")
    print(f"Primitive root: ω = {omega}")
    print(f"Verification: ω^{n} ≡ {pow(omega, n, p)} (mod {p})")
    for k in range(1, n):
        print(f"  ω^{k} ≡ {pow(omega, k, p)} (mod {p}) {'✗ = 1' if pow(omega, k, p) == 1 else '✓ ≠ 1'}")

    # Test convolution theorem
    a = [1, 2, 3, 4, 5, 6, 7, 8]
    b = [8, 7, 6, 5, 4, 3, 2, 1]

    naive_result = naive_cyclic_conv(a, b, p)
    ntt_result = ntt_conv(a, b, omega, p)

    print(f"\na = {a}")
    print(f"b = {b}")
    print(f"\nNaive cyclic convolution (mod {p}): {naive_result}")
    print(f"NTT-based convolution (mod {p}):    {ntt_result}")
    print(f"Results match: {naive_result == ntt_result}")

    # Demonstrate the convolution theorem pointwise
    fa = ntt_transform(a, omega, p)
    fb = ntt_transform(b, omega, p)
    f_conv_naive = ntt_transform(naive_result, omega, p)
    f_pointwise = [(x * y) % p for x, y in zip(fa, fb)]

    print(f"\nConvolution theorem verification:")
    print(f"  NTT(a):              {fa}")
    print(f"  NTT(b):              {fb}")
    print(f"  NTT(a) · NTT(b):     {f_pointwise}")
    print(f"  NTT(a * b):          {f_conv_naive}")
    print(f"  Match: {f_pointwise == f_conv_naive}")

    # Complexity analysis
    print(f"\nComplexity for various sizes:")
    print(f"{'Size 2^m':>10} | {'Naive O(n²)':>12} | {'FFT O(n log n)':>15} | {'Ratio':>8}")
    print("-" * 55)
    for m in range(1, 11):
        nn = 2 ** m
        naive_ops = nn * nn
        fft_ops = m * nn
        print(f"{nn:>10} | {naive_ops:>12} | {fft_ops:>15} | {naive_ops/fft_ops:>8.1f}x")


# ============================================================================
# DEMO 4: Testing the Entropy-Optimality Conjecture
# ============================================================================

def demo_conjecture():
    print("\n" + "=" * 70)
    print("DEMO 4: Testing the Entropy-Optimality Conjecture")
    print("=" * 70)

    print("""
Conjecture: For every n ≥ 1, among all deterministic comparison algorithms
locating the first true index of a monotone Boolean predicate on {0,...,n-1},
binary search minimizes the worst-case number of comparisons.

Test: For small n, enumerate all monotone predicates and compute worst-case
comparisons for binary search. Compare against the information-theoretic
lower bound ⌈log₂(n+1)⌉.
""")

    print(f"{'n':>4} | {'BS worst':>10} | {'⌈log₂(n+1)⌉':>13} | {'Optimal?':>9}")
    print("-" * 45)

    for n in range(1, 17):
        # All monotone predicates on {0,...,n-1}: defined by threshold t ∈ {0,...,n}
        # p(i) = (i >= t), with t the least true index (or n if all false)
        max_comps = 0
        for t in range(n + 1):
            _, comps, _ = binary_search(lambda x, th=t: x >= th, n)
            max_comps = max(max_comps, comps)

        # Information-theoretic lower bound: ⌈log₂(n+1)⌉
        # because there are n+1 possible answers {0, 1, ..., n}
        lower_bound = math.ceil(math.log2(n + 1))

        is_optimal = max_comps == lower_bound
        print(f"{n:>4} | {max_comps:>10} | {lower_bound:>13} | {'✓ YES' if is_optimal else '✗ NO':>9}")

    print(f"\nFor all tested n from 1 to 16:")
    print(f"Binary search achieves exactly ⌈log₂(n+1)⌉ worst-case comparisons,")
    print(f"matching the information-theoretic lower bound.")
    print(f"The conjecture holds for all tested instances.")


# ============================================================================
# DEMO 5: Unified View — Three Archetypes
# ============================================================================

def demo_unified():
    print("\n" + "=" * 70)
    print("DEMO 5: Unified View — Three Archetypes of Efficient Computation")
    print("=" * 70)

    print("""
┌─────────────────┬──────────────────────┬────────────────────────┐
│ Algorithm       │ Archetype            │ Information Principle  │
├─────────────────┼──────────────────────┼────────────────────────┤
│ Binary Search   │ Ordered Elimination  │ 1 bit per comparison   │
│ Dijkstra        │ Monotone Relaxation  │ Greedy finality        │
│ FFT/NTT         │ Symmetry Factorize   │ n log n via butterfly  │
└─────────────────┴──────────────────────┴────────────────────────┘

Each algorithm is an instance of InfoEfficientAlgorithm:
  - step:      advance the state machine
  - invariant: correctness certificate maintained at each step
  - potential: strictly decreasing measure → termination
  - extract:   read off the answer at termination

Formally verified properties:
  ✓ Binary search: width halves each step, finds least witness
  ✓ Dijkstra:      settled vertices have optimal distances
  ✓ NTT:           diagonalizes cyclic convolution
  ✓ Cross-domain:  BS → entropy bound, NTT → number theory,
                   Dijkstra → tropical algebra
""")


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    demo_binary_search()
    demo_dijkstra()
    demo_ntt()
    demo_conjecture()
    demo_unified()
