#!/usr/bin/env python3
"""
Real-world applications of the Algorithmic Certificate framework.

Demonstrates how the unified state-machine proof paradigm applies to:
1. Polynomial multiplication via NTT (cryptography)
2. Network routing via Dijkstra (telecommunications)
3. Database index lookup via binary search (systems)
4. Potential-based amortized analysis (algorithm design)
"""

from typing import List, Tuple, Dict
import math


# ============================================================
# Application 1: Polynomial Multiplication via NTT
# ============================================================

def polynomial_multiply_ntt(
    poly_a: List[int],
    poly_b: List[int],
    mod: int = 998244353  # Common NTT-friendly prime
) -> List[int]:
    """
    Multiply two polynomials using NTT in O(n log n).

    This is the core operation in:
    - Post-quantum lattice cryptography (CRYSTALS-Kyber, Dilithium)
    - Zero-knowledge proof systems (SNARKs, STARKs)
    - Homomorphic encryption (BGV, BFV)

    The correctness of this multiplication relies on the formally
    verified NTT convolution theorem.

    Args:
        poly_a: Coefficients of polynomial a (a[i] = coefficient of x^i)
        poly_b: Coefficients of polynomial b
        mod: NTT-friendly prime (must be of form k*2^m + 1)

    Returns:
        Coefficients of a * b reduced mod p
    """
    n = 1
    target_len = len(poly_a) + len(poly_b) - 1
    while n < target_len:
        n <<= 1

    # Pad to power of 2
    a = poly_a + [0] * (n - len(poly_a))
    b = poly_b + [0] * (n - len(poly_b))

    # Find primitive n-th root of unity
    # For mod = 998244353 = 119 * 2^23 + 1, generator is 3
    g = 3
    omega = pow(g, (mod - 1) // n, mod)

    # NTT-based multiplication
    def ntt_recursive(seq, w, p):
        if len(seq) == 1:
            return [seq[0] % p]
        half = len(seq) // 2
        w2 = w * w % p
        even = ntt_recursive(seq[0::2], w2, p)
        odd = ntt_recursive(seq[1::2], w2, p)
        result = [0] * len(seq)
        wk = 1
        for k in range(half):
            result[k] = (even[k] + wk * odd[k]) % p
            result[k + half] = (even[k] - wk * odd[k]) % p
            wk = wk * w % p
        return result

    fa = ntt_recursive(a, omega, mod)
    fb = ntt_recursive(b, omega, mod)
    fc = [(x * y) % mod for x, y in zip(fa, fb)]

    omega_inv = pow(omega, -1, mod)
    result = ntt_recursive(fc, omega_inv, mod)
    n_inv = pow(n, -1, mod)
    result = [(x * n_inv) % mod for x in result]

    return result[:target_len]


# ============================================================
# Application 2: Network Routing via Dijkstra
# ============================================================

def network_routing(
    nodes: List[str],
    links: List[Tuple[str, str, int]],  # (src, dst, latency_ms)
    source: str,
    destination: str
) -> Tuple[int, List[str]]:
    """
    Find optimal route in a network using Dijkstra's algorithm.

    Applications:
    - Internet routing (OSPF protocol)
    - GPS navigation
    - Telecommunications network planning

    The correctness guarantee comes from the formally verified
    settled-optimality invariant.

    Args:
        nodes: Network node identifiers
        links: Directed links with latencies
        source: Starting node
        destination: Target node

    Returns:
        (total_latency, path) shortest path and its cost
    """
    INF = float('inf')
    adj: Dict[str, List[Tuple[str, int]]] = {n: [] for n in nodes}
    for u, v, w in links:
        adj[u].append((v, w))

    dist = {n: INF for n in nodes}
    prev = {n: None for n in nodes}
    dist[source] = 0
    settled = set()

    while len(settled) < len(nodes):
        # Extract minimum
        u = min((n for n in nodes if n not in settled), key=lambda n: dist[n])
        if dist[u] == INF:
            break
        settled.add(u)

        # Relax
        for v, w in adj[u]:
            if dist[u] + w < dist[v]:
                dist[v] = dist[u] + w
                prev[v] = u

    # Reconstruct path
    path = []
    current = destination
    while current is not None:
        path.append(current)
        current = prev[current]
    path.reverse()

    return dist[destination], path


# ============================================================
# Application 3: Database Index Lookup via Binary Search
# ============================================================

def database_index_lookup(
    sorted_keys: List[int],
    target: int
) -> Tuple[int, int, List[Tuple[int, int]]]:
    """
    Binary search in a sorted database index.

    Applications:
    - B-tree index lookups in databases
    - Binary search in sorted arrays (std::lower_bound)
    - Interpolation search for uniformly distributed keys

    The formally verified property guarantees:
    - Exact result: returns the insertion point (lower bound)
    - Logarithmic steps: at most ceil(log2(n+1)) comparisons
    - Information optimality: each comparison halves the search space

    Args:
        sorted_keys: Sorted array of keys
        target: Key to search for

    Returns:
        (index, steps, trace) where index is the insertion point,
        steps is the number of comparisons, and trace is the
        sequence of (lo, hi) intervals
    """
    n = len(sorted_keys)
    lo, hi = 0, n
    steps = 0
    trace = [(lo, hi)]

    while lo < hi:
        mid = (lo + hi) // 2
        steps += 1
        if sorted_keys[mid] < target:
            lo = mid + 1
        else:
            hi = mid
        trace.append((lo, hi))

    return lo, steps, trace


# ============================================================
# Application 4: Amortized Analysis via Potential Functions
# ============================================================

class DynamicArray:
    """
    Dynamic array with amortized O(1) append.

    The potential function phi(s) = 2*size - capacity certifies
    that the amortized cost of each append is O(1), even though
    individual appends may cost O(n) when the array doubles.

    This is an instance of the Algorithmic Certificate framework
    where the potential bounds the amortized cost.
    """

    def __init__(self):
        self.data = [None] * 1
        self.size = 0
        self.capacity = 1
        self.total_cost = 0
        self.operations = 0

    def potential(self) -> int:
        """Potential function: 2*size - capacity."""
        return 2 * self.size - self.capacity

    def append(self, value) -> int:
        """
        Append value. Returns the actual cost (number of element copies).
        """
        cost = 1  # Writing the new element
        if self.size == self.capacity:
            # Double the array
            new_cap = self.capacity * 2
            cost += self.size  # Copy all existing elements
            new_data = [None] * new_cap
            for i in range(self.size):
                new_data[i] = self.data[i]
            self.data = new_data
            self.capacity = new_cap

        self.data[self.size] = value
        self.size += 1
        self.total_cost += cost
        self.operations += 1
        return cost

    @property
    def amortized_cost(self) -> float:
        """Average cost per operation so far."""
        if self.operations == 0:
            return 0
        return self.total_cost / self.operations


# ============================================================
# Demonstrations
# ============================================================

def demo_crypto():
    """Polynomial multiplication for lattice cryptography."""
    print("=" * 60)
    print("APPLICATION: NTT for Lattice Cryptography")
    print("=" * 60)

    # Simulate CRYSTALS-Kyber style polynomial multiplication
    # (simplified: real Kyber uses n=256, q=3329)
    a = [1, 2, 3, 4, 5, 6, 7, 8]
    b = [8, 7, 6, 5, 4, 3, 2, 1]

    result = polynomial_multiply_ntt(a, b)
    print(f"\nPolynomial a = {a}")
    print(f"Polynomial b = {b}")
    print(f"a * b = {result}")

    # Verify against naive multiplication
    naive = [0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        for j, bj in enumerate(b):
            naive[i + j] += ai * bj
    # Reduce mod p
    p = 998244353
    naive_mod = [x % p for x in naive]
    print(f"Naive verification: {naive_mod}")
    print(f"Match: {result == naive_mod}")


def demo_routing():
    """Network routing with Dijkstra."""
    print("\n" + "=" * 60)
    print("APPLICATION: Network Routing (OSPF-style)")
    print("=" * 60)

    nodes = ["NYC", "CHI", "DEN", "LAX", "HOU", "ATL", "MIA"]
    links = [
        ("NYC", "CHI", 12), ("NYC", "ATL", 14), ("NYC", "MIA", 22),
        ("CHI", "DEN", 16), ("CHI", "HOU", 15),
        ("DEN", "LAX", 13), ("DEN", "HOU", 10),
        ("ATL", "HOU", 11), ("ATL", "MIA", 9),
        ("HOU", "LAX", 18),
        ("MIA", "HOU", 16),
    ]

    source, dest = "NYC", "LAX"
    latency, path = network_routing(nodes, links, source, dest)
    print(f"\nRoute {source} → {dest}:")
    print(f"  Path: {' → '.join(path)}")
    print(f"  Total latency: {latency} ms")
    print(f"  Hops: {len(path) - 1}")


def demo_database():
    """Database index lookup with binary search."""
    print("\n" + "=" * 60)
    print("APPLICATION: Database Index Lookup")
    print("=" * 60)

    # Simulate a sorted database index with 1M entries
    n = 1_000_000
    keys = list(range(0, n * 10, 10))  # Keys: 0, 10, 20, ..., 9999990
    target = 4567890

    idx, steps, trace = database_index_lookup(keys, target)
    print(f"\nDatabase with {n:,} entries")
    print(f"Searching for key {target:,}")
    print(f"Found at index: {idx:,}")
    print(f"Comparisons: {steps}")
    print(f"Theoretical bound: ceil(log2({n}+1)) = {math.ceil(math.log2(n+1))}")
    print(f"Efficiency: {steps / math.ceil(math.log2(n+1)) * 100:.1f}% of bound")

    # Show trace for small example
    small_keys = [2, 5, 8, 12, 16, 23, 38, 56, 72, 91]
    idx, steps, trace = database_index_lookup(small_keys, 23)
    print(f"\nSmall example: keys = {small_keys}, target = 23")
    print(f"Trace:")
    for i, (lo, hi) in enumerate(trace):
        print(f"  Step {i}: [{lo}, {hi})  width={hi-lo}")
    print(f"Found at index {idx}: keys[{idx}] = {small_keys[idx]}")


def demo_amortized():
    """Dynamic array amortized analysis."""
    print("\n" + "=" * 60)
    print("APPLICATION: Amortized Analysis via Potential")
    print("=" * 60)

    arr = DynamicArray()
    costs = []
    potentials = []
    amortized = []

    for i in range(64):
        cost = arr.append(i)
        costs.append(cost)
        potentials.append(arr.potential())
        amortized.append(arr.amortized_cost)

    print(f"\nDynamic array: 64 appends")
    print(f"Total actual cost: {arr.total_cost}")
    print(f"Average cost per append: {arr.amortized_cost:.2f}")
    print(f"Amortized bound (O(1)): 3")

    print(f"\nStep  ActualCost  Potential  AmortizedAvg")
    for i in [0, 1, 2, 3, 4, 7, 8, 15, 16, 31, 32, 63]:
        print(f"  {i:3d}  {costs[i]:10d}  {potentials[i]:9d}  {amortized[i]:12.2f}")


if __name__ == "__main__":
    demo_crypto()
    demo_routing()
    demo_database()
    demo_amortized()
    print("\n✓ All application demos completed successfully.")


#!/usr/bin/env python3
"""
Demonstration of the Algorithmic Certificate framework:
Binary Search, Dijkstra, and NTT as instances of decreasing-potential state machines.
"""

import math
from typing import Callable, Optional, List, Tuple

# ============================================================
# 1. Abstract Algorithmic Certificate Framework
# ============================================================

class AlgorithmicCertificate:
    """
    A state machine with:
    - step: State -> State
    - invariant: State -> bool
    - potential: State -> int (non-negative, strictly decreasing)
    - terminal: State -> bool
    - extract: State -> Spec
    """
    def __init__(self, step, invariant, potential, terminal, extract):
        self.step = step
        self.invariant = invariant
        self.potential = potential
        self.terminal = terminal
        self.extract = extract

    def run(self, init):
        """Run until terminal, tracking states and potentials."""
        states = [init]
        potentials = [self.potential(init)]
        s = init
        steps = 0
        while not self.terminal(s):
            s = self.step(s)
            states.append(s)
            potentials.append(self.potential(s))
            steps += 1
            if steps > potentials[0] + 1:
                raise RuntimeError("Exceeded potential bound!")
        return self.extract(s), states, potentials


# ============================================================
# 2. Binary Search as Algorithmic Certificate
# ============================================================

def binary_search_certificate(n: int, predicate: Callable[[int], bool]):
    """Binary search as a decreasing-potential state machine."""

    def step(state):
        lo, hi = state
        if lo >= hi:
            return state
        mid = (lo + hi) // 2
        if predicate(mid):
            return (lo, mid)
        else:
            return (mid + 1, hi)

    def invariant(state):
        lo, hi = state
        return 0 <= lo <= hi <= n

    def potential(state):
        lo, hi = state
        return hi - lo

    def terminal(state):
        lo, hi = state
        return lo >= hi

    def extract(state):
        return state[0]

    return AlgorithmicCertificate(step, invariant, potential, terminal, extract)


def demo_binary_search():
    """Demonstrate binary search finding the least witness."""
    print("=" * 60)
    print("BINARY SEARCH: Information Halving Protocol")
    print("=" * 60)

    # Find least x in [0, 16) where x >= 11
    n = 16
    target = 11
    pred = lambda x: x >= target

    cert = binary_search_certificate(n, pred)
    result, states, potentials = cert.run((0, n))

    print(f"\nSearching for least x in [0, {n}) where x >= {target}")
    print(f"\nStep-by-step trace:")
    for i, (s, p) in enumerate(zip(states, potentials)):
        lo, hi = s
        status = "DONE" if lo >= hi else f"test mid={((lo+hi)//2)}"
        print(f"  Step {i}: [{lo}, {hi})  width={p}  {status}")

    print(f"\nResult: {result}")
    print(f"Steps: {len(states) - 1}")
    print(f"log2({n}) = {math.log2(n):.1f}")
    print(f"Potential bound: {potentials[0]}")

    # Verify width halving
    print(f"\nWidth sequence: {potentials}")
    for i in range(1, len(potentials)):
        if potentials[i-1] > 0:
            ratio = potentials[i] / potentials[i-1]
            print(f"  Width ratio step {i}: {ratio:.3f} (≤ 0.5: {ratio <= 0.5})")

    # Power-of-two exact bound
    print(f"\nPower-of-two verification:")
    for k in range(1, 6):
        n_pow = 2**k
        # Worst case: all true
        cert_pow = binary_search_certificate(n_pow, lambda x: True)
        _, _, pots = cert_pow.run((0, n_pow))
        steps = len(pots) - 1
        print(f"  n=2^{k}={n_pow}: {steps} steps (bound: k+1={k+1})")


# ============================================================
# 3. Dijkstra as Algorithmic Certificate
# ============================================================

def dijkstra_certificate(vertices, weight_fn, src):
    """Dijkstra's algorithm as a decreasing-potential state machine."""
    INF = float('inf')

    def step(state):
        settled, dist = state
        # Find unsettled vertex with minimum distance
        min_d = INF
        min_v = None
        for v in vertices:
            if v not in settled and dist[v] < min_d:
                min_d = dist[v]
                min_v = v
        if min_v is None:
            return state
        # Settle min_v and relax neighbors
        new_settled = settled | {min_v}
        new_dist = dict(dist)
        for v in vertices:
            w = weight_fn(min_v, v)
            if w is not None and dist[min_v] + w < new_dist[v]:
                new_dist[v] = dist[min_v] + w
        return (new_settled, new_dist)

    def invariant(state):
        return True  # simplified

    def potential(state):
        settled, _ = state
        return len(vertices) - len(settled)

    def terminal(state):
        settled, _ = state
        return len(settled) == len(vertices)

    def extract(state):
        return state[1]  # distance map

    init_dist = {v: (0 if v == src else INF) for v in vertices}
    init = (set(), init_dist)

    return AlgorithmicCertificate(step, invariant, potential, terminal, extract), init


def demo_dijkstra():
    """Demonstrate Dijkstra with frontier invariant tracking."""
    print("\n" + "=" * 60)
    print("DIJKSTRA: Greedy Frontier Separation")
    print("=" * 60)

    vertices = ['A', 'B', 'C', 'D', 'E']
    edges = {
        ('A', 'B'): 4, ('A', 'C'): 2,
        ('B', 'D'): 3, ('B', 'C'): 1,
        ('C', 'B'): 1, ('C', 'D'): 5, ('C', 'E'): 7,
        ('D', 'E'): 1,
        ('E', 'D'): 1,
    }

    def weight_fn(u, v):
        return edges.get((u, v))

    cert, init = dijkstra_certificate(vertices, weight_fn, 'A')
    result, states, potentials = cert.run(init)

    print(f"\nGraph: {len(vertices)} vertices, {len(edges)} edges")
    print(f"Source: A")
    print(f"\nStep-by-step trace:")
    for i, (s, p) in enumerate(zip(states, potentials)):
        settled, dist = s
        settled_str = '{' + ', '.join(sorted(settled)) + '}' if settled else '{}'
        dist_str = ', '.join(f"{v}:{dist[v]}" for v in vertices)
        print(f"  Step {i}: settled={settled_str}  dist=[{dist_str}]  unsettled={p}")

    print(f"\nFinal distances: {result}")
    print(f"Steps (= |V|): {len(states) - 1}")
    print(f"Potential decreased: {potentials[0]} -> {potentials[-1]}")


# ============================================================
# 4. NTT as Algorithmic Certificate
# ============================================================

def ntt(a, omega, mod):
    """Number Theoretic Transform."""
    n = len(a)
    return [sum(a[i] * pow(omega, i * j, mod) for i in range(n)) % mod for j in range(n)]


def inv_ntt(a, omega, mod):
    """Inverse NTT using omega^(-1)."""
    n = len(a)
    omega_inv = pow(omega, -1, mod)
    n_inv = pow(n, -1, mod)
    result = ntt(a, omega_inv, mod)
    return [(x * n_inv) % mod for x in result]


def cyclic_conv(a, b, mod):
    """Cyclic convolution of two sequences mod p."""
    n = len(a)
    result = [0] * n
    for i in range(n):
        for j in range(n):
            result[(i + j) % n] = (result[(i + j) % n] + a[i] * b[j]) % mod
    return result


def demo_ntt():
    """Demonstrate NTT convolution theorem."""
    print("\n" + "=" * 60)
    print("NTT: Spectral Diagonalization of Cyclic Convolution")
    print("=" * 60)

    # Use p = 17, n = 4, omega = 2 (primitive 4th root: 2^4 = 16 ≡ -1 mod 17,
    # so 2^8 = 1 mod 17; need 4th root: 2^2 = 4, 4^4 = 256 = 15*17+1 = 1 mod 17)
    p = 17
    n = 4
    omega = 4  # 4 is a primitive 4th root of unity mod 17

    # Verify primitivity
    print(f"\nRing: Z/{p}Z, n={n}, ω={omega}")
    print(f"ω^1={pow(omega,1,p)}, ω^2={pow(omega,2,p)}, ω^3={pow(omega,3,p)}, ω^4={pow(omega,4,p)}")
    assert pow(omega, n, p) == 1
    assert all(pow(omega, m, p) != 1 for m in range(1, n))

    a = [1, 2, 3, 4]
    b = [5, 6, 7, 8]

    # Direct cyclic convolution
    conv_direct = cyclic_conv(a, b, p)

    # NTT-based convolution
    ntt_a = ntt(a, omega, p)
    ntt_b = ntt(b, omega, p)
    pointwise = [(x * y) % p for x, y in zip(ntt_a, ntt_b)]
    conv_ntt = inv_ntt(pointwise, omega, p)

    print(f"\na = {a}")
    print(f"b = {b}")
    print(f"NTT(a) = {ntt_a}")
    print(f"NTT(b) = {ntt_b}")
    print(f"NTT(a) ⊙ NTT(b) = {pointwise}")
    print(f"\nDirect convolution:  {conv_direct}")
    print(f"NTT convolution:     {conv_ntt}")
    print(f"Match: {conv_direct == conv_ntt}")

    # Verify the convolution theorem: NTT(a*b) = NTT(a) ⊙ NTT(b)
    ntt_conv = ntt(conv_direct, omega, p)
    print(f"\nNTT(a*b) = {ntt_conv}")
    print(f"NTT(a)⊙NTT(b) = {pointwise}")
    print(f"NTT(a*b) = NTT(a)⊙NTT(b): {ntt_conv == pointwise}")

    # Cooley-Tukey decomposition demo
    print(f"\nCooley-Tukey decomposition (n=4 → 2×n=2):")
    a8 = [1, 2, 3, 4, 5, 6, 7, 8]
    even = a8[0::2]  # [1, 3, 5, 7]
    odd = a8[1::2]   # [2, 4, 6, 8]
    print(f"  a = {a8}")
    print(f"  even(a) = {even}")
    print(f"  odd(a) = {odd}")

    # NTT cost: k * 2^k
    print(f"\nNTT cost model (k * 2^k ring operations):")
    for k in range(1, 8):
        cost = k * (2**k)
        print(f"  k={k}, n=2^k={2**k}: cost={cost}, ratio={cost/(2**k):.1f}=k")


# ============================================================
# 5. Unified Framework Demo
# ============================================================

def demo_unified():
    """Show all three algorithms as instances of the same framework."""
    print("\n" + "=" * 60)
    print("UNIFIED FRAMEWORK: Algorithms as Dynamical Systems")
    print("=" * 60)

    print("""
The Algorithmic Certificate Meta-Theorem:

  Given:
    - State machine (step, invariant, potential, terminal, extract)
    - Invariant preserved by non-terminal steps
    - Potential strictly decreases on non-terminal steps
    - Extraction yields correct answer at terminal states

  Then:
    ∃ t ≤ potential(init), terminal(step^t(init)) ∧ correct(extract(step^t(init)))

Instances:
  ┌───────────────┬──────────────┬───────────────┬──────────────┐
  │ Algorithm     │ State        │ Potential     │ Complexity   │
  ├───────────────┼──────────────┼───────────────┼──────────────┤
  │ Binary Search │ [lo, hi)     │ hi - lo       │ O(log n)     │
  │ Dijkstra      │ (settled, d) │ |V|-|settled| │ O(|V|²)      │
  │ NTT (recur.)  │ subproblems  │ recursion dep │ O(n log n)   │
  └───────────────┴──────────────┴───────────────┴──────────────┘
""")

    # Run all three and compare potential decay
    print("Potential decay comparison:")
    print("-" * 40)

    # Binary search n=32
    cert_bs = binary_search_certificate(32, lambda x: x >= 20)
    _, _, pots_bs = cert_bs.run((0, 32))
    print(f"Binary Search (n=32):  {pots_bs}")

    # Dijkstra
    verts = list(range(5))
    edges_d = {(0,1):2, (0,2):4, (1,2):1, (1,3):7, (2,3):3, (2,4):5, (3,4):1}
    def wt(u,v): return edges_d.get((u,v))
    cert_dj, init_dj = dijkstra_certificate(verts, wt, 0)
    _, _, pots_dj = cert_dj.run(init_dj)
    print(f"Dijkstra (|V|=5):      {pots_dj}")

    # NTT recursion depth
    pots_ntt = [k for k in range(5, -1, -1)]
    print(f"NTT (n=2^5, depth):    {pots_ntt}")


if __name__ == "__main__":
    demo_binary_search()
    demo_dijkstra()
    demo_ntt()
    demo_unified()
    print("\n✓ All demonstrations completed successfully.")


#!/usr/bin/env python3
"""Generate PACKAGE.json with all artifacts."""

import json
import base64

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def read_b64(path):
    with open(path, 'r') as f:
        return f.read()

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')

# Read Lean proofs
lean_files = [
    'Computation/AlgorithmicCertificate.lean',
    'Computation/BinarySearch.lean',
    'Computation/Dijkstra.lean',
    'Computation/NTT.lean',
]
lean_proofs = '\n\n-- ' + '='*60 + '\n\n'.join(
    f'-- FILE: {f}\n' + '='*60 + '\n\n' + read_file(f) for f in lean_files
)

# Read Python code
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')

# Read visualization data
viz_data = {}
for name in ['viz_binary_search', 'viz_dijkstra', 'viz_ntt', 'viz_unified']:
    viz_data[name] = read_b64(f'{name}.b64')

package = {
    "title": "Algorithmic Certificates: A Unified Framework for Verified Algorithms",
    "domain": "Computation / Formal Verification / Algorithm Design",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Binary Search, Dijkstra, and NTT Demonstrations",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Binary Search (Certified Information Halving)",
            "pseudocode": """BINARY-SEARCH(predicate p, size n):
  lo ← 0, hi ← n
  while lo < hi:
    mid ← (lo + hi) / 2
    if p(mid): hi ← mid
    else: lo ← mid + 1
  return lo

INVARIANT: ∀ i < lo, ¬p(i) ∧ ∀ i ≥ hi, p(i)
POTENTIAL: hi - lo (strictly decreasing)
COMPLEXITY: O(log n) steps""",
            "code": algorithms_code
        },
        {
            "name": "Dijkstra's Algorithm (Greedy Frontier Separation)",
            "pseudocode": """DIJKSTRA(graph G, source s):
  dist[s] ← 0, dist[v] ← ∞ for all v ≠ s
  settled ← ∅
  while settled ≠ V:
    u ← argmin_{v ∉ settled} dist[v]
    settled ← settled ∪ {u}
    for each neighbor v of u:
      dist[v] ← min(dist[v], dist[u] + w(u,v))
  return dist

INVARIANT: ∀ v ∈ settled, dist[v] = shortestDist(v)
POTENTIAL: |V| - |settled| (decreases by 1 per step)
COMPLEXITY: O(|V|²) dense, O((|V|+|E|) log |V|) with heap""",
            "code": algorithms_code
        },
        {
            "name": "Number Theoretic Transform (Spectral Convolution)",
            "pseudocode": """NTT(sequence a, root ω, size n):
  if n = 1: return a
  even ← NTT(a[0::2], ω², n/2)
  odd  ← NTT(a[1::2], ω², n/2)
  for j = 0 to n/2 - 1:
    result[j]     ← even[j] + ω^j · odd[j]
    result[j+n/2] ← even[j] - ω^j · odd[j]
  return result

CONVOLUTION THEOREM: NTT(a ∗ b) = NTT(a) ⊙ NTT(b)
COST: T(k) = k · 2^k ring operations for n = 2^k""",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Binary Search: Information Halving",
            "data": viz_data['viz_binary_search']
        },
        {
            "name": "Dijkstra: Frontier Separation",
            "data": viz_data['viz_dijkstra']
        },
        {
            "name": "NTT: Butterfly Structure and Cost",
            "data": viz_data['viz_ntt']
        },
        {
            "name": "Unified Framework: Three Algorithms, One Theorem",
            "data": viz_data['viz_unified']
        }
    ],
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated: {len(json.dumps(package))} chars")


#!/usr/bin/env python3
"""
Visualizations for the Algorithmic Certificate framework.
Generates PNG figures for the article and research paper.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import math
import base64
from io import BytesIO


def fig_to_base64(fig):
    """Convert a matplotlib figure to a base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def viz_binary_search_potential():
    """Visualize binary search potential decay (information halving)."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: potential decay for different n
    for k in range(2, 7):
        n = 2**k
        # Simulate worst-case width sequence
        widths = [n]
        w = n
        while w > 0:
            w = w // 2
            widths.append(w)
        ax1.plot(range(len(widths)), widths, 'o-', label=f'n=2^{k}={n}', markersize=4)

    ax1.set_xlabel('Step', fontsize=12)
    ax1.set_ylabel('Interval Width (Potential)', fontsize=12)
    ax1.set_title('Binary Search: Exponential Potential Decay', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.set_yscale('log', base=2)
    ax1.grid(True, alpha=0.3)

    # Right: steps vs n showing logarithmic growth
    ns = list(range(1, 129))
    steps_bound = [math.ceil(math.log2(n + 1)) if n > 0 else 0 for n in ns]
    ax2.plot(ns, steps_bound, 'b-', linewidth=2, label='ceil(log₂(n+1))')
    ax2.fill_between(ns, 0, steps_bound, alpha=0.1, color='blue')
    ax2.set_xlabel('Search Space Size n', fontsize=12)
    ax2.set_ylabel('Maximum Steps', fontsize=12)
    ax2.set_title('Binary Search Complexity: O(log n)', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Binary Search as Certified Information Halving', fontsize=14, fontweight='bold')
    plt.tight_layout()
    fig.savefig('viz_binary_search.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def viz_dijkstra_frontier():
    """Visualize Dijkstra's frontier invariant."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: potential (unsettled count) decay
    steps = [0, 1, 2, 3, 4, 5]
    unsettled = [5, 4, 3, 2, 1, 0]
    dists = {
        'A': [0, 0, 0, 0, 0, 0],
        'B': [float('inf'), 4, 3, 3, 3, 3],
        'C': [float('inf'), 2, 2, 2, 2, 2],
        'D': [float('inf'), float('inf'), 7, 6, 6, 6],
        'E': [float('inf'), float('inf'), 9, 9, 7, 7],
    }

    ax1.bar(steps, unsettled, color='steelblue', alpha=0.7)
    ax1.set_xlabel('Iteration', fontsize=12)
    ax1.set_ylabel('Unsettled Vertices', fontsize=12)
    ax1.set_title('Dijkstra: Potential Decreases Monotonically', fontsize=13)
    ax1.set_xticks(steps)
    ax1.grid(True, alpha=0.3, axis='y')

    # Right: distance evolution
    for name, ds in dists.items():
        ds_plot = [min(d, 15) for d in ds]  # Cap infinity for display
        style = '-' if ds[0] == 0 else '--'
        ax2.plot(steps, ds_plot, 'o-', label=name, markersize=6)

    ax2.set_xlabel('Iteration', fontsize=12)
    ax2.set_ylabel('Tentative Distance', fontsize=12)
    ax2.set_title('Dijkstra: Distance Convergence', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.set_ylim(-0.5, 12)
    ax2.grid(True, alpha=0.3)

    fig.suptitle("Dijkstra's Algorithm: Greedy Frontier Separation", fontsize=14, fontweight='bold')
    plt.tight_layout()
    fig.savefig('viz_dijkstra.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def viz_ntt_butterfly():
    """Visualize NTT butterfly structure and cost."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: Cost model T(n) = n log n
    ks = list(range(1, 16))
    ns = [2**k for k in ks]
    costs = [k * 2**k for k in ks]
    naive = [n**2 for n in ns]

    ax1.plot(ks, costs, 'bo-', label='NTT: k·2^k', markersize=5, linewidth=2)
    ax1.plot(ks, naive, 'r^--', label='Naive: (2^k)²', markersize=5, linewidth=1)
    ax1.set_xlabel('k (n = 2^k)', fontsize=12)
    ax1.set_ylabel('Ring Operations', fontsize=12)
    ax1.set_title('NTT vs Naive Cost', fontsize=13)
    ax1.set_yscale('log')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Right: Butterfly diagram for n=8
    n = 8
    k = 3  # log2(8)
    ax2.set_xlim(-0.5, k + 0.5)
    ax2.set_ylim(-0.5, n - 0.5)

    # Draw nodes
    for stage in range(k + 1):
        for i in range(n):
            color = 'steelblue' if stage == 0 else ('orange' if stage == k else 'gray')
            ax2.plot(stage, i, 'o', color=color, markersize=10, zorder=5)

    # Draw butterfly connections
    for stage in range(k):
        half = 2**(k - stage - 1)
        group_size = 2**(stage + 1)
        for group_start in range(0, n, group_size):
            for j in range(group_size // 2):
                top = group_start + j
                bot = top + half
                ax2.plot([stage, stage + 1], [top, top], 'k-', linewidth=0.8)
                ax2.plot([stage, stage + 1], [bot, bot], 'k-', linewidth=0.8)
                ax2.plot([stage, stage + 1], [top, bot], 'b--', linewidth=0.5, alpha=0.5)
                ax2.plot([stage, stage + 1], [bot, top], 'r--', linewidth=0.5, alpha=0.5)

    ax2.set_xlabel('Stage', fontsize=12)
    ax2.set_ylabel('Index', fontsize=12)
    ax2.set_title(f'NTT Butterfly (n={n}, depth={k})', fontsize=13)
    ax2.set_xticks(range(k + 1))
    ax2.set_xticklabels([f'Stage {i}' for i in range(k + 1)])
    ax2.invert_yaxis()
    ax2.grid(True, alpha=0.2)

    fig.suptitle('Number Theoretic Transform: Divide-and-Conquer Structure', fontsize=14, fontweight='bold')
    plt.tight_layout()
    fig.savefig('viz_ntt.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def viz_unified_framework():
    """Visualize the unified framework: three algorithms, one structure."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Binary Search potential
    ax = axes[0]
    widths = [32, 16, 8, 4, 2, 1, 0]
    ax.fill_between(range(len(widths)), widths, alpha=0.3, color='blue')
    ax.plot(range(len(widths)), widths, 'bo-', markersize=8, linewidth=2)
    ax.set_title('Binary Search\nPotential = Interval Width', fontsize=12, fontweight='bold')
    ax.set_xlabel('Step')
    ax.set_ylabel('Potential')
    ax.grid(True, alpha=0.3)

    # Dijkstra potential
    ax = axes[1]
    unsettled = [10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
    ax.fill_between(range(len(unsettled)), unsettled, alpha=0.3, color='green')
    ax.plot(range(len(unsettled)), unsettled, 'go-', markersize=8, linewidth=2)
    ax.set_title("Dijkstra\nPotential = Unsettled Count", fontsize=12, fontweight='bold')
    ax.set_xlabel('Step')
    ax.grid(True, alpha=0.3)

    # NTT recursion potential
    ax = axes[2]
    ntt_pot = [5, 4, 3, 2, 1, 0]
    ax.fill_between(range(len(ntt_pot)), ntt_pot, alpha=0.3, color='red')
    ax.plot(range(len(ntt_pot)), ntt_pot, 'ro-', markersize=8, linewidth=2)
    ax.set_title('NTT Recursion\nPotential = Recursion Depth', fontsize=12, fontweight='bold')
    ax.set_xlabel('Step')
    ax.grid(True, alpha=0.3)

    fig.suptitle('Three Algorithms, One Theorem: Decreasing Potential → Correctness',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    fig.savefig('viz_unified.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    b64_bs = viz_binary_search_potential()
    print(f"  Binary Search: {len(b64_bs)} chars")
    b64_dj = viz_dijkstra_frontier()
    print(f"  Dijkstra: {len(b64_dj)} chars")
    b64_ntt = viz_ntt_butterfly()
    print(f"  NTT: {len(b64_ntt)} chars")
    b64_uni = viz_unified_framework()
    print(f"  Unified: {len(b64_uni)} chars")
    print("✓ All visualizations saved as PNG files.")
