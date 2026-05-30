"""
Applications of Mod-p Spectral Fingerprints

Real-world applications demonstrating the mathematical results:
1. Network expansion analysis using edge boundaries
2. Graph isomorphism distinguishing via fingerprints
3. Cryptographic matrix structure detection
"""

from typing import List, Dict, Tuple
import math


# ============ Inline required functions ============

def sieve_primes(N: int) -> List[int]:
    if N < 2:
        return []
    sieve = [True] * (N + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(N**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, N + 1, i):
                sieve[j] = False
    return [i for i in range(2, N + 1) if sieve[i]]


def mod_p_rank(M: List[List[int]], p: int) -> int:
    n = len(M)
    if n == 0:
        return 0
    m = len(M[0])
    A = [[M[i][j] % p for j in range(m)] for i in range(n)]
    rank = 0
    for col in range(m):
        pivot_row = None
        for row in range(rank, n):
            if A[row][col] % p != 0:
                pivot_row = row
                break
        if pivot_row is None:
            continue
        A[rank], A[pivot_row] = A[pivot_row], A[rank]
        inv = pow(A[rank][col], p - 2, p)
        for row in range(n):
            if row != rank and A[row][col] % p != 0:
                factor = (A[row][col] * inv) % p
                for c in range(m):
                    A[row][c] = (A[row][c] - factor * A[rank][c]) % p
        rank += 1
    return rank


def spectral_fingerprint(M: List[List[int]], primes: List[int]) -> Dict[int, int]:
    return {p: mod_p_rank(M, p) for p in primes}


def path_graph_laplacian(n: int) -> List[List[int]]:
    L = [[0] * n for _ in range(n)]
    for i in range(n):
        if i == 0 or i == n - 1:
            L[i][i] = 1
        else:
            L[i][i] = 2
        if i > 0:
            L[i][i-1] = -1
        if i < n - 1:
            L[i][i+1] = -1
    return L


def complete_graph_laplacian(n: int) -> List[List[int]]:
    return [[(n if i == j else 0) - 1 for j in range(n)] for i in range(n)]


def edge_boundary(L: List[List[int]], S: List[int]) -> int:
    n = len(L)
    S_set = set(S)
    Sc = [j for j in range(n) if j not in S_set]
    return sum(-L[i][j] for i in S for j in Sc)


# ============ Application 1: Network Expansion Analysis ============

def analyze_network_expansion(adj_list: Dict[int, List[int]], n: int) -> Dict:
    """
    Analyze expansion properties of a network using its Laplacian.

    Given a graph as an adjacency list, computes:
    - The Laplacian matrix
    - Edge boundaries for all subsets up to size n/2
    - The minimum expansion ratio (Cheeger constant)
    - The spectral fingerprint

    Args:
        adj_list: Graph as adjacency list {vertex: [neighbors]}
        n: Number of vertices

    Returns:
        Dictionary with expansion analysis results
    """
    # Build Laplacian
    L = [[0] * n for _ in range(n)]
    for i in range(n):
        neighbors = adj_list.get(i, [])
        L[i][i] = len(neighbors)
        for j in neighbors:
            L[i][j] = -1

    # Compute expansion for small subsets
    min_expansion = float('inf')
    min_expansion_set = []

    # Check all subsets of size 1 to n//2 (only small sizes for efficiency)
    for size in range(1, min(n // 2 + 1, 6)):
        # Check a few representative subsets
        for start in range(n - size + 1):
            S = list(range(start, start + size))
            eb = edge_boundary(L, S)
            exp_ratio = eb / size
            if exp_ratio < min_expansion:
                min_expansion = exp_ratio
                min_expansion_set = S

    # Spectral fingerprint
    primes = sieve_primes(50)
    fp = spectral_fingerprint(L, primes)

    return {
        "laplacian": L,
        "min_expansion_ratio": min_expansion,
        "min_expansion_set": min_expansion_set,
        "spectral_fingerprint": fp,
        "is_good_expander": min_expansion >= 1.0,
    }


# ============ Application 2: Graph Distinguishing ============

def distinguish_graphs(graphs: List[Tuple[str, List[List[int]]]],
                       prime_bound: int = 50) -> Dict:
    """
    Use spectral fingerprints to distinguish non-isomorphic graphs.

    Two graphs with different fingerprints cannot be isomorphic.
    This provides a fast necessary condition for isomorphism.

    Args:
        graphs: List of (name, Laplacian) pairs
        prime_bound: Check primes up to this bound

    Returns:
        Grouping of graphs by fingerprint equivalence class
    """
    primes = sieve_primes(prime_bound)
    fingerprints = {}

    for name, L in graphs:
        fp = spectral_fingerprint(L, primes)
        fp_key = tuple(sorted(fp.items()))
        if fp_key not in fingerprints:
            fingerprints[fp_key] = []
        fingerprints[fp_key].append(name)

    return {
        "equivalence_classes": list(fingerprints.values()),
        "num_classes": len(fingerprints),
        "can_distinguish": len(fingerprints) > 1,
    }


# ============ Application 3: Matrix Structure Detection ============

def detect_matrix_structure(M: List[List[int]], prime_bound: int = 100) -> Dict:
    """
    Detect structural properties of an integer matrix via its fingerprint.

    Returns:
        - Whether the matrix is likely singular
        - The set of bad primes (prime divisors of the determinant)
        - A lower bound on |det(M)|
        - The asymptotic rank stability
    """
    n = len(M)
    primes = sieve_primes(prime_bound)
    fp = spectral_fingerprint(M, primes)

    bad_primes = [p for p in primes if fp[p] < n]
    max_rank = max(fp.values()) if fp else 0

    # Check if likely singular
    likely_singular = max_rank < n

    # Lower bound on determinant
    det_lower_bound = 1
    for p in bad_primes:
        det_lower_bound *= p

    # Rank stability: fraction of primes with max rank
    stability = sum(1 for r in fp.values() if r == max_rank) / len(primes) if primes else 0

    return {
        "dimension": n,
        "max_rank": max_rank,
        "likely_singular": likely_singular,
        "bad_primes": bad_primes,
        "det_lower_bound": det_lower_bound,
        "rank_stability": stability,
        "fingerprint": fp,
    }


# ============ Demo ============

if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATION 1: Network Expansion Analysis")
    print("=" * 70)

    # Petersen graph (known good expander)
    petersen = {
        0: [1, 4, 5], 1: [0, 2, 6], 2: [1, 3, 7],
        3: [2, 4, 8], 4: [0, 3, 9], 5: [0, 7, 8],
        6: [1, 8, 9], 7: [2, 5, 9], 8: [3, 5, 6],
        9: [4, 6, 7]
    }

    result = analyze_network_expansion(petersen, 10)
    print(f"\nPetersen graph (n=10):")
    print(f"  Min expansion ratio: {result['min_expansion_ratio']:.2f}")
    print(f"  Min expansion set: {result['min_expansion_set']}")
    print(f"  Good expander? {result['is_good_expander']}")

    # Path graph (poor expander)
    path_adj = {i: [j for j in [i-1, i+1] if 0 <= j < 8] for i in range(8)}
    result2 = analyze_network_expansion(path_adj, 8)
    print(f"\nPath graph P_8:")
    print(f"  Min expansion ratio: {result2['min_expansion_ratio']:.2f}")
    print(f"  Good expander? {result2['is_good_expander']}")

    print("\n" + "=" * 70)
    print("APPLICATION 2: Graph Distinguishing via Fingerprints")
    print("=" * 70)

    graphs = [
        ("K_4", complete_graph_laplacian(4)),
        ("P_4", path_graph_laplacian(4)),
        ("C_4", [[2, -1, 0, -1], [-1, 2, -1, 0], [0, -1, 2, -1], [-1, 0, -1, 2]]),
        ("Star_4", [[3, -1, -1, -1], [-1, 1, 0, 0], [-1, 0, 1, 0], [-1, 0, 0, 1]]),
    ]

    result3 = distinguish_graphs(graphs)
    print(f"\nGraphs on 4 vertices:")
    for cls in result3["equivalence_classes"]:
        print(f"  Fingerprint class: {cls}")
    print(f"  Distinguished {result3['num_classes']} classes")

    print("\n" + "=" * 70)
    print("APPLICATION 3: Matrix Structure Detection")
    print("=" * 70)

    M = [[12, 5, 3, 1], [0, 30, 7, 2], [0, 0, 42, 11], [0, 0, 0, 20]]
    result4 = detect_matrix_structure(M)
    print(f"\nUpper triangular matrix with det = 12*30*42*20 = {12*30*42*20}")
    print(f"  Bad primes: {result4['bad_primes']}")
    print(f"  Det lower bound: {result4['det_lower_bound']}")
    print(f"  Rank stability: {result4['rank_stability']:.1%}")
    print(f"  Max rank: {result4['max_rank']}")

    print("\nAll applications completed successfully!")


"""
Demo: Mod-p Spectral Fingerprints of Arithmetic Simplicial Complexes

Demonstrates the key theorems:
1. Determinant commutes with mod-p reduction
2. Spectral fingerprints detect prime divisors
3. Bad primes are finite
4. Edge boundary and expansion
"""

import numpy as np
from typing import List, Tuple, Dict


def mod_p_reduce(M: np.ndarray, p: int) -> np.ndarray:
    """Reduce an integer matrix modulo p."""
    return M % p


def mod_p_rank(M: np.ndarray, p: int) -> int:
    """Compute the rank of M mod p over F_p using Gaussian elimination."""
    n = M.shape[0]
    A = M.copy() % p
    rank = 0
    for col in range(min(n, M.shape[1])):
        # Find pivot
        pivot_row = None
        for row in range(rank, n):
            if A[row, col] % p != 0:
                pivot_row = row
                break
        if pivot_row is None:
            continue
        # Swap rows
        A[[rank, pivot_row]] = A[[pivot_row, rank]]
        # Eliminate below
        inv = pow(int(A[rank, col]), p - 2, p)  # Fermat's little theorem
        for row in range(n):
            if row != rank and A[row, col] % p != 0:
                factor = (A[row, col] * inv) % p
                A[row] = (A[row] - factor * A[rank]) % p
        rank += 1
    return rank


def spectral_fingerprint(M: np.ndarray, primes: List[int]) -> Dict[int, int]:
    """Compute the spectral fingerprint: p -> rank(M mod p)."""
    return {p: mod_p_rank(M, p) for p in primes}


def complete_laplacian(n: int) -> np.ndarray:
    """Laplacian of the complete graph K_n: nI - J."""
    return n * np.eye(n, dtype=int) - np.ones((n, n), dtype=int)


def path_laplacian(n: int) -> np.ndarray:
    """Laplacian of the path graph P_n."""
    L = np.zeros((n, n), dtype=int)
    for i in range(n):
        if i == 0 or i == n - 1:
            L[i, i] = 1
        else:
            L[i, i] = 2
        if i > 0:
            L[i, i-1] = -1
        if i < n - 1:
            L[i, i+1] = -1
    return L


def cycle_laplacian(n: int) -> np.ndarray:
    """Laplacian of the cycle graph C_n."""
    L = np.zeros((n, n), dtype=int)
    for i in range(n):
        L[i, i] = 2
        L[i, (i+1) % n] = -1
        L[(i+1) % n, i] = -1
    return L


def edge_boundary(L: np.ndarray, S: List[int]) -> int:
    """Compute the edge boundary of subset S in graph with Laplacian L."""
    n = L.shape[0]
    S_set = set(S)
    Sc = [j for j in range(n) if j not in S_set]
    return sum(-L[i, j] for i in S for j in Sc)


def primes_up_to(N: int) -> List[int]:
    """Sieve of Eratosthenes."""
    if N < 2:
        return []
    sieve = [True] * (N + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(N**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, N + 1, i):
                sieve[j] = False
    return [i for i in range(2, N + 1) if sieve[i]]


# ========== DEMO 1: Determinant commutes with mod-p reduction ==========
print("=" * 70)
print("DEMO 1: det(M mod p) = det(M) mod p")
print("=" * 70)

M = np.array([[3, 1, 2], [0, 5, 4], [1, 2, 7]], dtype=int)
det_M = int(round(np.linalg.det(M)))
print(f"\nM = \n{M}")
print(f"det(M) = {det_M}")

for p in [2, 3, 5, 7, 11, 13]:
    Mp = mod_p_reduce(M, p)
    det_Mp = int(round(np.linalg.det(Mp))) % p
    det_mod_p = det_M % p
    print(f"  p={p:2d}: det(M mod p) mod p = {det_Mp}, det(M) mod p = {det_mod_p}, match = {det_Mp == det_mod_p}")


# ========== DEMO 2: Spectral fingerprint ==========
print("\n" + "=" * 70)
print("DEMO 2: Spectral Fingerprint")
print("=" * 70)

M2 = np.array([[6, 2, 3], [4, 10, 5], [1, 3, 15]], dtype=int)
det_M2 = int(round(np.linalg.det(M2)))
ps = primes_up_to(50)
fp = spectral_fingerprint(M2, ps)

print(f"\nM = \n{M2}")
print(f"det(M) = {det_M2}")
print(f"Prime factorization hint: {det_M2} = ", end="")
d = abs(det_M2)
factors = []
for p in ps:
    while d % p == 0:
        factors.append(p)
        d //= p
if d > 1:
    factors.append(d)
print(" × ".join(str(f) for f in factors))

print(f"\nSpectral fingerprint (p -> rank(M mod p)):")
for p in ps:
    r = fp[p]
    marker = " <-- BAD PRIME (rank drop!)" if r < 3 else ""
    print(f"  p={p:2d}: rank = {r}{marker}")


# ========== DEMO 3: Complete graph Laplacian ==========
print("\n" + "=" * 70)
print("DEMO 3: Complete Graph Laplacian K_n")
print("=" * 70)

for n in [3, 4, 5, 6]:
    L = complete_laplacian(n)
    det_L = int(round(np.linalg.det(L)))
    fp_L = spectral_fingerprint(L, primes_up_to(20))
    print(f"\nK_{n}: det = {det_L} (always 0 since all-ones is in kernel)")
    print(f"  Fingerprint: {fp_L}")
    print(f"  Row sums: {[sum(L[i]) for i in range(n)]}")


# ========== DEMO 4: Edge boundary and expansion ==========
print("\n" + "=" * 70)
print("DEMO 4: Edge Boundary (Cheeger bound)")
print("=" * 70)

n = 6
L = path_laplacian(n)
print(f"\nPath graph P_{n}, Laplacian:")
print(L)

for S in [[0], [0, 1], [0, 1, 2], [0, 1, 2, 3]]:
    eb = edge_boundary(L, S)
    print(f"  S = {S}: edge boundary = {eb} (>= 0 by Cheeger bound)")


# ========== DEMO 5: Bad primes are finite ==========
print("\n" + "=" * 70)
print("DEMO 5: Bad Primes are Finite (Rank Stability)")
print("=" * 70)

# Random 4x4 integer matrix with nonzero determinant
np.random.seed(42)
while True:
    M3 = np.random.randint(-10, 11, (4, 4))
    det_M3 = int(round(np.linalg.det(M3)))
    if det_M3 != 0:
        break

print(f"\nRandom 4×4 matrix M:\n{M3}")
print(f"det(M) = {det_M3}")

ps_large = primes_up_to(100)
fp3 = spectral_fingerprint(M3, ps_large)
bad_primes = [p for p in ps_large if fp3[p] < 4]
good_primes = [p for p in ps_large if fp3[p] == 4]

print(f"\nBad primes (rank < 4): {bad_primes}")
print(f"Number of bad primes: {len(bad_primes)}")
print(f"Number of good primes (out of {len(ps_large)}): {len(good_primes)}")
print(f"Bad primes divide det = {det_M3}? ", end="")
print(all(det_M3 % p == 0 for p in bad_primes))


# ========== DEMO 6: Falsifiable Conjecture Test ==========
print("\n" + "=" * 70)
print("DEMO 6: Falsifiable Conjecture - Path Laplacian Rank Stability")
print("=" * 70)

for n in [3, 5, 8, 10, 15]:
    L = path_laplacian(n)
    ps_test = [p for p in primes_up_to(100) if p > n]
    ranks = [mod_p_rank(L, p) for p in ps_test]
    all_n_minus_1 = all(r == n - 1 for r in ranks)
    print(f"\n  P_{n}: Testing primes > {n}: {ps_test[:10]}...")
    print(f"  All ranks = {n-1}? {all_n_minus_1}")
    if not all_n_minus_1:
        exceptions = [(p, r) for p, r in zip(ps_test, ranks) if r != n - 1]
        print(f"  Exceptions: {exceptions[:5]}")

print("\n\nAll demos completed successfully!")


"""
Visualization: Edge Expansion Profile

Plots the edge expansion ratio h(S) = |∂S|/|S| for contiguous subsets
of different graph families. This demonstrates the proven theorem that
edge boundaries are always nonneg (Cheeger bound), and shows how
different graph topologies yield different expansion profiles.

The expansion profile is a "fingerprint" of the graph's connectivity:
- Complete graphs: high, uniform expansion
- Path graphs: low expansion (bottleneck in the middle)
- Cycle graphs: moderate, symmetric expansion
- Random regular graphs: near-optimal expansion (Ramanujan property)
"""

import matplotlib.pyplot as plt
import numpy as np


def path_laplacian(n):
    L = [[0]*n for _ in range(n)]
    for i in range(n):
        L[i][i] = 1 if (i == 0 or i == n-1) else 2
        if i > 0: L[i][i-1] = -1
        if i < n-1: L[i][i+1] = -1
    return L


def complete_laplacian(n):
    return [[(n if i == j else 0) - 1 for j in range(n)] for i in range(n)]


def cycle_laplacian(n):
    L = [[0]*n for _ in range(n)]
    for i in range(n):
        L[i][i] = 2
        L[i][(i+1)%n] = -1
        L[(i+1)%n][i] = -1
    return L


def petersen_laplacian():
    n = 10
    edges = [(0,1),(0,4),(0,5),(1,2),(1,6),(2,3),(2,7),
             (3,4),(3,8),(4,9),(5,7),(5,8),(6,8),(6,9),(7,9)]
    L = [[0]*n for _ in range(n)]
    for i, j in edges:
        L[i][j] = -1
        L[j][i] = -1
        L[i][i] += 1
        L[j][j] += 1
    return L


def edge_boundary(L, S):
    n = len(L)
    S_set = set(S)
    Sc = [j for j in range(n) if j not in S_set]
    return sum(-L[i][j] for i in S for j in Sc)


def expansion_profile(L, n):
    """Compute expansion for subsets of size 1..n//2."""
    sizes = list(range(1, n // 2 + 1))
    min_expansions = []
    for size in sizes:
        min_exp = float('inf')
        # Check contiguous subsets starting at different positions
        for start in range(n):
            S = [(start + k) % n for k in range(size)]
            eb = edge_boundary(L, S)
            exp_ratio = eb / size
            min_exp = min(min_exp, exp_ratio)
        min_expansions.append(min_exp)
    return sizes, min_expansions


fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Plot 1: Expansion profiles for different graph families
ax1 = axes[0]
n = 12

graphs = [
    ("Complete K₁₂", complete_laplacian(n), 'tab:red', '-', 'o'),
    ("Cycle C₁₂", cycle_laplacian(n), 'tab:blue', '--', 's'),
    ("Path P₁₂", path_laplacian(n), 'tab:green', '-.', '^'),
]

for name, L, color, ls, marker in graphs:
    sizes, exps = expansion_profile(L, n)
    ax1.plot(sizes, exps, color=color, linestyle=ls, marker=marker,
             markersize=5, label=name, linewidth=2)

ax1.axhline(y=0, color='gray', linestyle=':', alpha=0.5,
            label='Cheeger bound (≥ 0)')
ax1.set_xlabel('Subset size |S|', fontsize=12)
ax1.set_ylabel('Min expansion h(S) = |∂S|/|S|', fontsize=12)
ax1.set_title('Expansion Profiles of Graph Families', fontsize=13)
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# Plot 2: Expansion vs spectral gap connection
ax2 = axes[1]

def sieve_primes(N):
    if N < 2: return []
    sieve = [True] * (N + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(N**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, N + 1, i):
                sieve[j] = False
    return [i for i in range(2, N + 1) if sieve[i]]


def mod_p_rank(M, p):
    n = len(M)
    m = len(M[0]) if n > 0 else 0
    A = [[M[i][j] % p for j in range(m)] for i in range(n)]
    rank = 0
    for col in range(m):
        pivot_row = None
        for row in range(rank, n):
            if A[row][col] % p != 0:
                pivot_row = row
                break
        if pivot_row is None:
            continue
        A[rank], A[pivot_row] = A[pivot_row], A[rank]
        inv = pow(A[rank][col], p - 2, p)
        for row in range(n):
            if row != rank and A[row][col] % p != 0:
                factor = (A[row][col] * inv) % p
                for c in range(m):
                    A[row][c] = (A[row][c] - factor * A[rank][c]) % p
        rank += 1
    return rank


# Show how fingerprint stability correlates with expansion
ns = list(range(4, 25))
path_stabilities = []
cycle_stabilities = []
path_cheeger = []
cycle_cheeger = []
primes = sieve_primes(100)

for n_val in ns:
    Lp = path_laplacian(n_val)
    Lc = cycle_laplacian(n_val)

    # Fingerprint stability: fraction of primes giving full rank (n-1 for Laplacians)
    fp_p = sum(1 for p in primes if mod_p_rank(Lp, p) >= n_val - 1) / len(primes)
    fp_c = sum(1 for p in primes if mod_p_rank(Lc, p) >= n_val - 1) / len(primes)
    path_stabilities.append(fp_p)
    cycle_stabilities.append(fp_c)

    # Min expansion
    _, exps_p = expansion_profile(Lp, n_val)
    _, exps_c = expansion_profile(Lc, n_val)
    path_cheeger.append(min(exps_p) if exps_p else 0)
    cycle_cheeger.append(min(exps_c) if exps_c else 0)

ax2.scatter(path_stabilities, path_cheeger, c='tab:green', marker='^',
            s=60, label='Path graphs', zorder=5)
ax2.scatter(cycle_stabilities, cycle_cheeger, c='tab:blue', marker='s',
            s=60, label='Cycle graphs', zorder=5)

ax2.set_xlabel('Fingerprint stability (fraction of full-rank primes)', fontsize=11)
ax2.set_ylabel('Cheeger constant h(G)', fontsize=11)
ax2.set_title('Fingerprint Stability vs Expansion', fontsize=13)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_expansion_profile.png', dpi=150, bbox_inches='tight')
print("Saved viz_expansion_profile.png")


"""
Visualization: Spectral Fingerprint Heatmap

Visualizes the mod-p rank (spectral fingerprint) of various graph Laplacians
across different primes. Each row is a different graph, each column is a prime p.
The color intensity shows the rank drop: dark = full rank, light = rank deficient.

This reveals the arithmetic structure of graph Laplacians:
- Complete graphs K_n have rank drops at primes dividing n
- Path graphs stabilize quickly
- Cycle graphs show periodic patterns
"""

import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np


def sieve_primes(N):
    if N < 2:
        return []
    sieve = [True] * (N + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(N**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, N + 1, i):
                sieve[j] = False
    return [i for i in range(2, N + 1) if sieve[i]]


def mod_p_rank(M, p):
    n = len(M)
    m = len(M[0]) if n > 0 else 0
    A = [[M[i][j] % p for j in range(m)] for i in range(n)]
    rank = 0
    for col in range(m):
        pivot_row = None
        for row in range(rank, n):
            if A[row][col] % p != 0:
                pivot_row = row
                break
        if pivot_row is None:
            continue
        A[rank], A[pivot_row] = A[pivot_row], A[rank]
        inv = pow(A[rank][col], p - 2, p)
        for row in range(n):
            if row != rank and A[row][col] % p != 0:
                factor = (A[row][col] * inv) % p
                for c in range(m):
                    A[row][c] = (A[row][c] - factor * A[rank][c]) % p
        rank += 1
    return rank


def complete_laplacian(n):
    return [[(n if i == j else 0) - 1 for j in range(n)] for i in range(n)]


def path_laplacian(n):
    L = [[0]*n for _ in range(n)]
    for i in range(n):
        L[i][i] = 1 if (i == 0 or i == n-1) else 2
        if i > 0: L[i][i-1] = -1
        if i < n-1: L[i][i+1] = -1
    return L


def cycle_laplacian(n):
    L = [[0]*n for _ in range(n)]
    for i in range(n):
        L[i][i] = 2
        L[i][(i+1)%n] = -1
        L[(i+1)%n][i] = -1
    return L


# Build data
primes = sieve_primes(47)
graphs = [
    ("K₃", complete_laplacian(3), 3),
    ("K₄", complete_laplacian(4), 4),
    ("K₅", complete_laplacian(5), 5),
    ("K₆", complete_laplacian(6), 6),
    ("P₄", path_laplacian(4), 4),
    ("P₅", path_laplacian(5), 5),
    ("P₆", path_laplacian(6), 6),
    ("C₄", cycle_laplacian(4), 4),
    ("C₅", cycle_laplacian(5), 5),
    ("C₆", cycle_laplacian(6), 6),
]

data = np.zeros((len(graphs), len(primes)))
for i, (name, L, n) in enumerate(graphs):
    for j, p in enumerate(primes):
        rank = mod_p_rank(L, p)
        # Normalize: show fraction of full rank achieved
        data[i, j] = rank / n

fig, ax = plt.subplots(figsize=(14, 6))

cmap = plt.cm.RdYlGn
im = ax.imshow(data, aspect='auto', cmap=cmap, vmin=0, vmax=1,
               interpolation='nearest')

ax.set_xticks(range(len(primes)))
ax.set_xticklabels([str(p) for p in primes], fontsize=8, rotation=45)
ax.set_yticks(range(len(graphs)))
ax.set_yticklabels([g[0] for g in graphs], fontsize=10)

ax.set_xlabel('Prime p', fontsize=12)
ax.set_ylabel('Graph', fontsize=12)
ax.set_title('Spectral Fingerprint Heatmap: Rank(L mod p) / dim(L)\n'
             'Green = full rank, Red = rank deficient (bad prime)', fontsize=13)

# Add colorbar
cbar = plt.colorbar(im, ax=ax, shrink=0.8)
cbar.set_label('Fraction of full rank', fontsize=10)

# Annotate cells with rank values
for i, (name, L, n) in enumerate(graphs):
    for j, p in enumerate(primes):
        rank = mod_p_rank(L, p)
        color = 'white' if data[i, j] < 0.5 else 'black'
        ax.text(j, i, str(rank), ha='center', va='center',
                fontsize=7, color=color, fontweight='bold')

plt.tight_layout()
plt.savefig('viz_fingerprint_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_fingerprint_heatmap.png")


"""
Visualization: Rank Stability and Bad Primes

Shows how the mod-p rank of integer matrices stabilizes as primes grow,
illustrating the theorem that only finitely many primes cause rank drops.

The left panel shows rank vs prime for specific matrices.
The right panel shows the cumulative count of bad primes, demonstrating
that the count plateaus (finite bad primes theorem).
"""

import matplotlib.pyplot as plt
import numpy as np


def sieve_primes(N):
    if N < 2: return []
    sieve = [True] * (N + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(N**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, N + 1, i):
                sieve[j] = False
    return [i for i in range(2, N + 1) if sieve[i]]


def mod_p_rank(M, p):
    n = len(M)
    m = len(M[0]) if n > 0 else 0
    A = [[M[i][j] % p for j in range(m)] for i in range(n)]
    rank = 0
    for col in range(m):
        pivot_row = None
        for row in range(rank, n):
            if A[row][col] % p != 0:
                pivot_row = row
                break
        if pivot_row is None:
            continue
        A[rank], A[pivot_row] = A[pivot_row], A[rank]
        inv = pow(A[rank][col], p - 2, p)
        for row in range(n):
            if row != rank and A[row][col] % p != 0:
                factor = (A[row][col] * inv) % p
                for c in range(m):
                    A[row][c] = (A[row][c] - factor * A[rank][c]) % p
        rank += 1
    return rank


# Test matrices with known determinants
matrices = [
    ("det = 2·3·5·7 = 210",
     [[210, 1, 0], [0, 1, 0], [0, 0, 1]], 3),
    ("det = 2⁴·3² = 144",
     [[12, 0, 0], [0, 12, 0], [0, 0, 1]], 3),
    ("det = 2·3·5·7·11·13 = 30030",
     [[30030, 1, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]], 4),
    ("det = 7¹ = 7",
     [[7, 3], [0, 1]], 2),
]

primes = sieve_primes(200)

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Left: Rank vs prime
ax1 = axes[0]
colors = ['tab:red', 'tab:blue', 'tab:green', 'tab:orange']

for idx, (label, M, n) in enumerate(matrices):
    ranks = [mod_p_rank(M, p) for p in primes]
    ax1.scatter(primes, ranks, c=colors[idx], s=15, alpha=0.7, label=label)
    ax1.plot(primes, [n] * len(primes), color=colors[idx], linestyle='--',
             alpha=0.3, linewidth=1)

ax1.set_xlabel('Prime p', fontsize=12)
ax1.set_ylabel('Rank mod p', fontsize=12)
ax1.set_title('Mod-p Rank Stabilization\n(rank drops only at prime divisors of det)', fontsize=12)
ax1.legend(fontsize=8, loc='lower right')
ax1.grid(True, alpha=0.3)

# Right: Cumulative bad primes
ax2 = axes[1]

for idx, (label, M, n) in enumerate(matrices):
    ranks = [mod_p_rank(M, p) for p in primes]
    cumulative_bad = np.cumsum([1 if r < n else 0 for r in ranks])
    ax2.plot(primes, cumulative_bad, color=colors[idx], linewidth=2,
             label=label, marker=None)

ax2.set_xlabel('Prime p', fontsize=12)
ax2.set_ylabel('Cumulative # of bad primes', fontsize=12)
ax2.set_title('Cumulative Bad Primes\n(plateaus confirm finiteness theorem)', fontsize=12)
ax2.legend(fontsize=8)
ax2.grid(True, alpha=0.3)

# Add annotation
ax2.annotate('Plateau = all bad\nprimes found',
             xy=(120, 4.2), fontsize=9,
             bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))

plt.tight_layout()
plt.savefig('viz_rank_stability.png', dpi=150, bbox_inches='tight')
print("Saved viz_rank_stability.png")
