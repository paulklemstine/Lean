"""
algorithms.py — Implementations of Information-Efficient Algorithms

This module implements the three canonical algorithms formalized in Lean 4:
binary search, Dijkstra's shortest paths, and NTT/FFT, along with their
information-theoretic and algebraic interpretations.
"""

import math
from typing import Callable, List, Tuple, Optional, Dict
import heapq


# ============================================================================
# Binary Search
# ============================================================================

def binary_search(
    predicate: Callable[[int], bool],
    n: int,
    trace: bool = False
) -> Tuple[int, int, List[Tuple[int, int, int]]]:
    """
    Find the least index i in [0, n) satisfying predicate(i),
    assuming predicate is monotone (once true, stays true).

    Returns:
        (result_index, num_comparisons, trace_log)
        result_index is n if no index satisfies the predicate.

    >>> binary_search(lambda x: x >= 5, 10)
    (5, 4, ...)
    """
    lo, hi = 0, n
    comparisons = 0
    trace_log: List[Tuple[int, int, int]] = []

    while lo < hi:
        mid = (lo + hi) // 2
        comparisons += 1
        if trace:
            trace_log.append((lo, hi, mid))
        if predicate(mid):
            hi = mid
        else:
            lo = mid + 1

    return lo, comparisons, trace_log


def binary_search_full_trace(n: int, target: int) -> dict:
    """
    Run binary search for a target in [0, n) and return full trace info.
    """
    result, comps, trace = binary_search(lambda x: x >= target, n, trace=True)
    return {
        "target": target,
        "result": result,
        "comparisons": comps,
        "theoretical_max": math.ceil(math.log2(n)) if n > 0 else 0,
        "trace": trace,
        "entropy_bits": math.log2(n) if n > 0 else 0,
    }


def full_linear_search(predicate: Callable[[int], bool], n: int) -> Tuple[int, int]:
    """Full linear search for comparison with binary search."""
    for i in range(n):
        if predicate(i):
            return i, i + 1
    return n, n


# ============================================================================
# Dijkstra's Algorithm
# ============================================================================

def dijkstra(
    graph: Dict[int, List[Tuple[int, int]]],
    source: int,
    trace: bool = False
) -> Tuple[Dict[int, int], Dict[int, Optional[int]], List[dict]]:
    """
    Dijkstra's shortest path algorithm.

    Args:
        graph: adjacency list {vertex: [(neighbor, weight), ...]}
        source: source vertex
        trace: whether to record frontier evolution

    Returns:
        (distances, predecessors, trace_log)

    >>> g = {0: [(1, 4), (2, 1)], 1: [(3, 1)], 2: [(1, 2), (3, 5)], 3: []}
    >>> dist, pred, _ = dijkstra(g, 0)
    >>> dist[3]
    4
    """
    dist: Dict[int, int] = {source: 0}
    pred: Dict[int, Optional[int]] = {source: None}
    settled: set = set()
    frontier: List[Tuple[int, int]] = [(0, source)]
    trace_log: List[dict] = []

    while frontier:
        d, u = heapq.heappop(frontier)
        if u in settled:
            continue

        settled.add(u)

        if trace:
            trace_log.append({
                "settled_vertex": u,
                "distance": d,
                "settled_count": len(settled),
                "frontier_size": len(frontier),
            })

        for v, w in graph.get(u, []):
            new_dist = d + w
            if v not in dist or new_dist < dist[v]:
                dist[v] = new_dist
                pred[v] = u
                heapq.heappush(frontier, (new_dist, v))

    return dist, pred, trace_log


def reconstruct_path(pred: Dict[int, Optional[int]], target: int) -> List[int]:
    """Reconstruct shortest path from predecessor map."""
    path = []
    current: Optional[int] = target
    while current is not None:
        path.append(current)
        current = pred.get(current)
    return list(reversed(path))


# ============================================================================
# NTT / FFT
# ============================================================================

def ntt(a: List[int], omega: int, mod: int) -> List[int]:
    """
    Number Theoretic Transform of sequence a.

    Args:
        a: input sequence of length n
        omega: primitive n-th root of unity mod p
        mod: prime modulus

    Returns:
        NTT of a
    """
    n = len(a)
    result = []
    for j in range(n):
        val = 0
        for i in range(n):
            val = (val + a[i] * pow(omega, i * j, mod)) % mod
        result.append(val)
    return result


def intt(a: List[int], omega: int, mod: int) -> List[int]:
    """Inverse NTT."""
    n = len(a)
    omega_inv = pow(omega, mod - 2, mod)
    n_inv = pow(n, mod - 2, mod)
    transformed = ntt(a, omega_inv, mod)
    return [(x * n_inv) % mod for x in transformed]


def cyclic_convolution(a: List[int], b: List[int], mod: int) -> List[int]:
    """Naive cyclic convolution mod p."""
    n = len(a)
    result = [0] * n
    for k in range(n):
        for i in range(n):
            j = (k - i) % n
            result[k] = (result[k] + a[i] * b[j]) % mod
    return result


def ntt_convolution(a: List[int], b: List[int], omega: int, mod: int) -> List[int]:
    """Fast convolution via NTT."""
    fa = ntt(a, omega, mod)
    fb = ntt(b, omega, mod)
    fc = [(x * y) % mod for x, y in zip(fa, fb)]
    return intt(fc, omega, mod)


def find_primitive_root(p: int, n: int) -> Optional[int]:
    """
    Find a primitive n-th root of unity mod p.
    Requires n | (p-1).
    """
    if (p - 1) % n != 0:
        return None

    # Find a generator of the multiplicative group
    def factorize(m: int) -> List[int]:
        factors = []
        d = 2
        while d * d <= m:
            while m % d == 0:
                factors.append(d)
                m //= d
            d += 1
        if m > 1:
            factors.append(m)
        return factors

    factors = list(set(factorize(p - 1)))

    for g in range(2, p):
        if all(pow(g, (p - 1) // f, p) != 1 for f in factors):
            # g is a generator; omega = g^((p-1)/n)
            omega = pow(g, (p - 1) // n, p)
            return omega

    return None


def fft_cost(m: int) -> int:
    """FFT cost for input size 2^m: m * 2^m operations."""
    return m * (2 ** m)


# ============================================================================
# Tropical / Min-Plus Operations
# ============================================================================

INF = float('inf')


def tropical_mul(a: float, b: float) -> float:
    """Tropical multiplication = ordinary addition."""
    if a == INF or b == INF:
        return INF
    return a + b


def tropical_add(a: float, b: float) -> float:
    """Tropical addition = min."""
    return min(a, b)


def tropical_matrix_mul(
    A: List[List[float]], B: List[List[float]]
) -> List[List[float]]:
    """Tropical matrix multiplication (min-plus)."""
    n = len(A)
    C = [[INF] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i][j] = tropical_add(C[i][j], tropical_mul(A[i][k], B[k][j]))
    return C


def tropical_closure(W: List[List[float]]) -> List[List[float]]:
    """
    Compute the tropical closure (all-pairs shortest paths)
    via repeated tropical matrix squaring.
    """
    n = len(W)
    # Initialize with identity (0 on diagonal, inf elsewhere) + W
    D = [[INF] * n for _ in range(n)]
    for i in range(n):
        D[i][i] = 0
    for i in range(n):
        for j in range(n):
            D[i][j] = tropical_add(D[i][j], W[i][j])

    # Repeated squaring
    steps = int(math.ceil(math.log2(n))) + 1 if n > 1 else 1
    for _ in range(steps):
        D = tropical_matrix_mul(D, D)

    return D


if __name__ == "__main__":
    # Quick test
    print("Binary search for 7 in [0, 16):")
    result = binary_search_full_trace(16, 7)
    print(f"  Result: {result['result']}, Comparisons: {result['comparisons']}")
    print(f"  Theoretical max: {result['theoretical_max']}, Entropy: {result['entropy_bits']:.2f} bits")

    print("\nDijkstra on small graph:")
    g = {0: [(1, 4), (2, 1)], 1: [(3, 1)], 2: [(1, 2), (3, 5)], 3: []}
    dist, pred, _ = dijkstra(g, 0)
    print(f"  Distances: {dist}")
    print(f"  Path to 3: {reconstruct_path(pred, 3)}")

    print("\nNTT convolution (mod 17, n=4):")
    omega = find_primitive_root(17, 4)
    print(f"  Primitive 4th root of unity mod 17: {omega}")
    a, b = [1, 2, 3, 4], [4, 3, 2, 1]
    naive = cyclic_convolution(a, b, 17)
    fast = ntt_convolution(a, b, omega, 17)
    print(f"  Naive convolution: {naive}")
    print(f"  NTT convolution:   {fast}")
    print(f"  Match: {naive == fast}")
