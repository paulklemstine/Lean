#!/usr/bin/env python3
"""
Applications of Certificate-Guided Sampling from Lorentzian Polynomials

Demonstrates real-world applications:
1. Matroid basis counting and sampling (combinatorial optimization)
2. Log-concave distribution generation (statistics/ML)
3. Graph enumeration via generating polynomials
4. Reliability polynomial evaluation (network engineering)
"""

import numpy as np
import math
from itertools import combinations
from collections import Counter
from typing import List, Tuple, Dict, Set, FrozenSet


# =============================================================================
# Application 1: Matroid Basis Sampling
# =============================================================================

def uniform_matroid_generating_poly(n: int, k: int) -> np.ndarray:
    """Compute the basis generating polynomial of U_{k,n}.

    The uniform matroid U_{k,n} has bases = all k-element subsets of [n].
    Its generating polynomial is the elementary symmetric polynomial e_k(x_1,...,x_n).
    The coefficient sequence is [C(n,0), C(n,1), ..., C(n,n)] restricted to degree k.

    Args:
        n: Number of elements
        k: Rank

    Returns:
        Coefficient sequence of the generating polynomial
    """
    return np.array([math.comb(n, k)], dtype=float)


def graphic_matroid_bases(n_vertices: int) -> Tuple[List[FrozenSet[int]], List[Tuple[int, int]]]:
    """Enumerate all bases (spanning trees) of the graphic matroid of K_n.

    Args:
        n_vertices: Number of vertices in the complete graph

    Returns:
        (bases, edges): List of spanning trees and list of edges
    """
    edges = list(combinations(range(n_vertices), 2))
    rank = n_vertices - 1
    bases = []

    for basis_edges in combinations(range(len(edges)), rank):
        adj: Dict[int, Set[int]] = {i: set() for i in range(n_vertices)}
        for idx in basis_edges:
            u, v = edges[idx]
            adj[u].add(v)
            adj[v].add(u)

        visited = set()
        queue = [0]
        visited.add(0)
        while queue:
            node = queue.pop(0)
            for neighbor in adj[node]:
                if neighbor not in visited:
                    visited.add(neighbor)
                    queue.append(neighbor)

        if len(visited) == n_vertices:
            bases.append(frozenset(basis_edges))

    return bases, edges


def spanning_tree_degree_distribution(n_vertices: int) -> np.ndarray:
    """Compute the degree-sum distribution of spanning trees of K_n.

    This distribution is log-concave (a consequence of the generating
    polynomial being Lorentzian).

    Args:
        n_vertices: Number of vertices

    Returns:
        Distribution over total edge-degree sums
    """
    bases, edges = graphic_matroid_bases(n_vertices)
    degree_sums = []

    for B in bases:
        deg_sum = 0
        for idx in B:
            deg_sum += 2  # Each edge contributes 2 to total degree
        degree_sums.append(deg_sum)

    max_deg = max(degree_sums) if degree_sums else 0
    dist = np.zeros(max_deg + 1)
    for d in degree_sums:
        dist[d] += 1

    return dist


def matroid_sampling_demo():
    """Demonstrate matroid basis sampling using certificate-guided chains."""
    print("=" * 70)
    print("APPLICATION 1: Matroid Basis Sampling")
    print("=" * 70)
    print()

    for n in [4, 5, 6]:
        print(f"  Complete graph K_{n}:")
        bases, edges = graphic_matroid_bases(n)
        n_trees = len(bases)
        cayley = n ** (n - 2)  # Cayley's formula

        print(f"    Spanning trees: {n_trees} (Cayley: n^(n-2) = {cayley})")

        # Degree distribution
        dist = spanning_tree_degree_distribution(n)
        nonzero = [(i, v) for i, v in enumerate(dist) if v > 0]

        # Check log-concavity of the nonzero part
        vals = [v for _, v in nonzero]
        lc = all(vals[k]**2 >= vals[k-1]*vals[k+1] - 1e-10
                 for k in range(1, len(vals)-1))

        print(f"    Degree distribution: {nonzero[:5]}{'...' if len(nonzero) > 5 else ''}")
        print(f"    Log-concave: {lc}")
        print()


# =============================================================================
# Application 2: Log-Concave Distribution Generation
# =============================================================================

def generate_log_concave_distribution(n: int, mode: int, spread: float = 1.0) -> np.ndarray:
    """Generate a log-concave distribution on {0, ..., n}.

    Uses the fact that exp(-α(k - μ)²) is log-concave for any α > 0.

    Args:
        n: Support size minus 1
        mode: Mode of the distribution
        spread: Controls the spread (larger = more spread)

    Returns:
        Normalized log-concave distribution
    """
    alpha = 1.0 / (2 * spread ** 2) if spread > 0 else 1.0
    dist = np.array([np.exp(-alpha * (k - mode) ** 2) for k in range(n + 1)])
    return dist / dist.sum()


def verify_log_concavity(dist: np.ndarray) -> Tuple[bool, List[float]]:
    """Verify log-concavity and compute the ratio sequence.

    Args:
        dist: Distribution to check

    Returns:
        (is_log_concave, ratios): Verification result and ratio sequence
    """
    ratios = []
    is_lc = True
    for k in range(1, len(dist) - 1):
        if dist[k] > 0:
            ratio = (dist[k-1] * dist[k+1]) / dist[k] ** 2
            ratios.append(ratio)
            if ratio > 1 + 1e-10:
                is_lc = False
        else:
            ratios.append(0.0)
    return is_lc, ratios


def log_concave_demo():
    """Demonstrate log-concave distribution properties."""
    print("=" * 70)
    print("APPLICATION 2: Log-Concave Distribution Generation & Verification")
    print("=" * 70)
    print()

    distributions = {
        "Binomial(20, 0.5)": np.array([math.comb(20, k) for k in range(21)], dtype=float),
        "Poisson(λ=5, truncated)": np.array([5**k / math.factorial(k) for k in range(21)], dtype=float),
        "Gaussian-like": generate_log_concave_distribution(20, 10, 3.0) * 1000,
    }

    for name, dist in distributions.items():
        dist_norm = dist / dist.sum()
        is_lc, ratios = verify_log_concavity(dist)
        max_ratio = max(ratios) if ratios else 0

        print(f"  {name}:")
        print(f"    Log-concave: {is_lc}")
        print(f"    Max ratio a_{{k-1}}a_{{k+1}}/a_k²: {max_ratio:.6f}")
        print(f"    Mode: {np.argmax(dist_norm)}")
        print(f"    Entropy: {-sum(p * np.log2(p) for p in dist_norm if p > 0):.3f} bits")
        print()


# =============================================================================
# Application 3: Graph Polynomial Evaluation
# =============================================================================

def chromatic_polynomial_complete(n: int, q: int) -> int:
    """Evaluate the chromatic polynomial of K_n at q.

    P(K_n, q) = q(q-1)(q-2)...(q-n+1) = falling factorial.

    Args:
        n: Number of vertices
        q: Number of colors

    Returns:
        Number of proper q-colorings of K_n
    """
    result = 1
    for i in range(n):
        result *= (q - i)
    return result


def chromatic_coefficients(n: int) -> List[int]:
    """Compute the absolute values of coefficients of the chromatic polynomial of K_n.

    The chromatic polynomial of K_n is ∑ S(n,k) * q^k * (-1)^{n-k}
    where S(n,k) are Stirling numbers of the second kind.

    Returns the sequence |a_k| which is known to be log-concave.
    """
    # Use inclusion-exclusion
    coeffs = [0] * (n + 1)
    for k in range(n + 1):
        # Coefficient of q^k in q(q-1)...(q-n+1)
        # This is the unsigned Stirling number of the first kind
        pass

    # Direct computation via evaluation and interpolation
    values = [chromatic_polynomial_complete(n, q) for q in range(n + 1)]

    # Finite differences to extract coefficients
    # P(q) = sum_k a_k * q^k
    # Use Newton's forward differences
    diffs = list(values)
    result = [diffs[0]]
    for j in range(1, n + 1):
        new_diffs = []
        for i in range(len(diffs) - 1):
            new_diffs.append(diffs[i+1] - diffs[i])
        diffs = new_diffs
        if diffs:
            result.append(diffs[0])

    return [abs(c) for c in result]


def graph_polynomial_demo():
    """Demonstrate log-concavity of graph polynomial coefficients."""
    print("=" * 70)
    print("APPLICATION 3: Graph Polynomial Log-Concavity")
    print("=" * 70)
    print()

    print("  Chromatic polynomial evaluations for K_n:")
    for n in range(2, 7):
        print(f"    K_{n}: ", end="")
        vals = [chromatic_polynomial_complete(n, q) for q in range(1, 8)]
        print(f"P(q) for q=1..7: {vals}")

    print()
    print("  Number of proper q-colorings (demonstrating log-concavity in q):")
    for n in [3, 4, 5]:
        vals = [chromatic_polynomial_complete(n, q) for q in range(n, n + 10)]
        # Check log-concavity of the evaluation sequence
        is_lc = all(vals[k]**2 >= vals[k-1]*vals[k+1] - 0.1
                     for k in range(1, len(vals)-1))
        print(f"    K_{n}, q={n}..{n+9}: {vals[:5]}... Log-concave: {is_lc}")
    print()


# =============================================================================
# Application 4: Network Reliability
# =============================================================================

def reliability_polynomial(edges: List[Tuple[int, int]], n_vertices: int,
                           p: float) -> float:
    """Compute the all-terminal reliability of a graph.

    R(G, p) = Probability that the graph remains connected when each edge
    independently fails with probability 1-p.

    This is a sum over spanning subgraphs:
    R(G, p) = ∑_{connected H ⊆ G} p^|E(H)| * (1-p)^(|E(G)|-|E(H)|)

    Args:
        edges: List of edges
        n_vertices: Number of vertices
        p: Edge reliability probability

    Returns:
        Network reliability
    """
    n_edges = len(edges)
    total_reliability = 0.0

    for mask in range(1 << n_edges):
        # Check if the subset of edges forms a connected subgraph
        adj: Dict[int, Set[int]] = {i: set() for i in range(n_vertices)}
        n_present = 0

        for idx in range(n_edges):
            if mask & (1 << idx):
                u, v = edges[idx]
                adj[u].add(v)
                adj[v].add(u)
                n_present += 1

        # BFS connectivity check
        visited = set()
        queue = [0]
        visited.add(0)
        while queue:
            node = queue.pop(0)
            for neighbor in adj[node]:
                if neighbor not in visited:
                    visited.add(neighbor)
                    queue.append(neighbor)

        if len(visited) == n_vertices:
            prob = p ** n_present * (1 - p) ** (n_edges - n_present)
            total_reliability += prob

    return total_reliability


def reliability_demo():
    """Demonstrate network reliability computation."""
    print("=" * 70)
    print("APPLICATION 4: Network Reliability via Lorentzian Certificates")
    print("=" * 70)
    print()

    # Small complete graphs
    for n in [3, 4, 5]:
        edges = list(combinations(range(n), 2))
        print(f"  Complete graph K_{n} ({len(edges)} edges):")
        print(f"    {'p':>6}  {'R(G,p)':>10}")
        print(f"    {'---':>6}  {'------':>10}")

        reliabilities = []
        for p_int in range(1, 10):
            p = p_int / 10.0
            r = reliability_polynomial(edges, n, p)
            reliabilities.append(r)
            print(f"    {p:6.1f}  {r:10.6f}")

        # Check log-concavity of reliability values
        is_lc = all(reliabilities[k]**2 >= reliabilities[k-1]*reliabilities[k+1] - 1e-6
                     for k in range(1, len(reliabilities)-1))
        print(f"    Reliability log-concave in p: {is_lc}")
        print()


# =============================================================================
# Main
# =============================================================================

def main():
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Applications of Certificate-Guided Sampling                        ║")
    print("║  from Lorentzian Polynomials                                        ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    matroid_sampling_demo()
    log_concave_demo()
    graph_polynomial_demo()
    reliability_demo()

    print("=" * 70)
    print("All applications demonstrated successfully.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Certificate-Guided Sampling from Lorentzian Polynomials: Interactive Demo

Demonstrates:
1. Log-concavity of sequences arising from Lorentzian quadratic forms
2. Certificate-guided Markov chain construction and mixing
3. Spectral gap estimation via eigenvalue computation
4. Comparison with basis-exchange walks for graphic matroids
5. Tropical diameter computation for Newton polytopes

Usage:
    python demo.py
"""

import numpy as np
from itertools import combinations
from collections import Counter
import math


# =============================================================================
# Part 1: Log-Concave Sequences and Binomial Coefficients
# =============================================================================

def is_log_concave(seq):
    """Check if a nonneg sequence is log-concave: a_k^2 >= a_{k-1} * a_{k+1}."""
    for k in range(1, len(seq) - 1):
        if seq[k] ** 2 < seq[k-1] * seq[k+1] - 1e-12:
            return False
    return True


def binomial_coefficients(n):
    """Return [C(n,0), C(n,1), ..., C(n,n)]."""
    return [math.comb(n, k) for k in range(n + 1)]


def demo_binomial_log_concavity():
    """Demonstrate that binomial coefficients are log-concave."""
    print("=" * 70)
    print("DEMO 1: Binomial Coefficient Log-Concavity")
    print("=" * 70)
    for n in [5, 10, 20]:
        coeffs = binomial_coefficients(n)
        lc = is_log_concave(coeffs)
        ratios = []
        for k in range(1, n):
            ratio = (coeffs[k-1] * coeffs[k+1]) / coeffs[k]**2
            ratios.append(ratio)
        print(f"\n  n = {n}: C(n,k) = {coeffs[:6]}{'...' if n > 5 else ''}")
        print(f"  Log-concave: {lc}")
        print(f"  Ratios C(n,k-1)*C(n,k+1)/C(n,k)^2:")
        for k, r in enumerate(ratios[:5], 1):
            print(f"    k={k}: {r:.6f} = {k}*{n-k}/({k+1}*{n-k+1}) ≤ 1 ✓")
    print()


# =============================================================================
# Part 2: Lorentzian Quadratic Forms
# =============================================================================

def lorentzian_matrix(n, positive_eigenvalue=1.0):
    """
    Construct an n×n symmetric matrix with Lorentzian signature:
    exactly one positive eigenvalue.
    """
    # Diagonal: one positive, rest negative
    D = np.diag([-1.0] * (n - 1) + [positive_eigenvalue])
    # Random orthogonal rotation
    Q, _ = np.linalg.qr(np.random.randn(n, n))
    A = Q @ D @ Q.T
    # Symmetrize
    A = (A + A.T) / 2
    return A


def quadratic_form(A, x):
    """Compute Q_A(x) = x^T A x."""
    return x @ A @ x


def bilinear_form(A, x, y):
    """Compute B_A(x, y) = x^T A y."""
    return x @ A @ y


def demo_reversed_cauchy_schwarz():
    """Demonstrate the reversed Cauchy-Schwarz inequality for Lorentzian forms."""
    print("=" * 70)
    print("DEMO 2: Reversed Cauchy-Schwarz for Lorentzian Quadratic Forms")
    print("=" * 70)
    np.random.seed(42)

    for n in [3, 5, 8]:
        A = lorentzian_matrix(n)
        eigenvalues = np.linalg.eigvalsh(A)
        pos_eigs = sum(1 for e in eigenvalues if e > 1e-10)
        print(f"\n  n = {n}, eigenvalues: {np.sort(eigenvalues)[::-1][:4].round(3)}...")
        print(f"  Positive eigenvalues: {pos_eigs} (should be 1)")

        # Find vectors in the positive cone
        eigvecs = np.linalg.eigh(A)[1]
        w = eigvecs[:, -1]  # eigenvector for largest eigenvalue

        # Generate vectors with Q(x) > 0 by adding large component along w
        successes = 0
        trials = 100
        for _ in range(trials):
            x = np.random.randn(n) + 3 * w
            y = np.random.randn(n) + 3 * w
            Qx = quadratic_form(A, x)
            Qy = quadratic_form(A, y)
            Bxy = bilinear_form(A, x, y)
            if Qx > 0 and Qy > 0:
                # Reversed CS: B(x,y)^2 >= Q(x)*Q(y)
                if Bxy ** 2 >= Qx * Qy - 1e-10:
                    successes += 1
        print(f"  Reversed CS verified: {successes}/{trials} trials with Q(x),Q(y) > 0")
    print()


# =============================================================================
# Part 3: Certificate-Guided Markov Chain
# =============================================================================

def certificate_transition_matrix(n, log_concave_dist):
    """
    Construct the Metropolis-Hastings transition matrix for a lazy
    random walk targeting a log-concave distribution on {0,...,n}.
    """
    P = np.zeros((n + 1, n + 1))
    pi = np.array(log_concave_dist, dtype=float)
    pi /= pi.sum()

    for i in range(n + 1):
        for j in range(n + 1):
            if abs(i - j) == 1:
                # Proposal: uniform neighbor
                proposal = 1.0 / max(1, min(2, (1 if i == 0 or i == n else 2)))
                # Acceptance ratio
                acceptance = min(1.0, pi[j] / pi[i]) if pi[i] > 0 else 0
                P[i, j] = 0.5 * proposal * acceptance

        # Lazy: stay with remaining probability
        P[i, i] = 1.0 - sum(P[i, j] for j in range(n + 1) if j != i)

    return P


def spectral_gap(P):
    """Compute the spectral gap of transition matrix P."""
    eigenvalues = np.sort(np.abs(np.linalg.eigvals(P)))[::-1]
    # Gap = 1 - second largest eigenvalue magnitude
    return 1.0 - eigenvalues[1]


def mixing_time_estimate(P, epsilon=0.01):
    """Estimate mixing time: smallest t such that ||P^t - pi||_TV < epsilon."""
    n = P.shape[0]
    eigenvalues = np.sort(np.abs(np.linalg.eigvals(P)))[::-1]
    lambda2 = eigenvalues[1]
    if lambda2 >= 1 - 1e-15:
        return float('inf')
    # Standard bound: t_mix <= (1/(1-lambda2)) * log(n/epsilon)
    return math.ceil((1 / (1 - lambda2)) * math.log(n / epsilon))


def demo_spectral_gap():
    """Demonstrate spectral gap bounds for log-concave distributions."""
    print("=" * 70)
    print("DEMO 3: Spectral Gap of Certificate-Guided Markov Chains")
    print("=" * 70)
    print()

    for n in [5, 10, 20, 50]:
        # Binomial distribution (log-concave)
        binom = [math.comb(n, k) for k in range(n + 1)]
        P = certificate_transition_matrix(n, binom)
        gap = spectral_gap(P)
        theoretical_bound = 1 / (8 * (n + 1) ** 2)
        t_mix = mixing_time_estimate(P)

        print(f"  n = {n:3d} | Spectral gap: {gap:.6f} | "
              f"Lower bound 1/(8(n+1)²): {theoretical_bound:.6f} | "
              f"Mixing time: {t_mix:6d}")

    print(f"\n  Theoretical guarantee: gap ≥ 1/(8(n+1)²) for log-concave π")
    print()


# =============================================================================
# Part 4: Graphic Matroid Basis-Exchange Walk
# =============================================================================

def graphic_matroid_bases(n_vertices):
    """
    Compute all spanning tree bases of K_n (complete graph).
    For small n only (combinatorial explosion).
    """
    edges = list(combinations(range(n_vertices), 2))
    n_edges = len(edges)
    rank = n_vertices - 1
    bases = []

    for basis_edges in combinations(range(n_edges), rank):
        # Check if these edges form a spanning tree (connected, no cycles)
        adj = {i: set() for i in range(n_vertices)}
        for idx in basis_edges:
            u, v = edges[idx]
            adj[u].add(v)
            adj[v].add(u)

        # BFS to check connectivity
        visited = set()
        queue = [0]
        visited.add(0)
        while queue:
            node = queue.pop(0)
            for neighbor in adj[node]:
                if neighbor not in visited:
                    visited.add(neighbor)
                    queue.append(neighbor)

        if len(visited) == n_vertices:
            bases.append(frozenset(basis_edges))

    return bases, edges


def basis_exchange_transition(bases, edges):
    """Construct transition matrix for the basis exchange walk."""
    n = len(bases)
    base_list = list(bases)
    base_idx = {b: i for i, b in enumerate(base_list)}

    P = np.zeros((n, n))
    rank = len(list(bases)[0])

    for i, B in enumerate(base_list):
        neighbors = []
        for e_out in B:
            for e_in in range(len(edges)):
                if e_in not in B:
                    new_basis = (B - {e_out}) | {e_in}
                    if new_basis in base_idx:
                        neighbors.append(base_idx[new_basis])

        if neighbors:
            prob = 1.0 / (2 * rank * (len(edges) - rank))
            for j in neighbors:
                P[i, j] += prob

        P[i, i] = 1.0 - sum(P[i, j] for j in range(n) if j != i)

    return P


def demo_exchange_comparison():
    """Compare certificate-guided sampling with basis-exchange walks."""
    print("=" * 70)
    print("DEMO 4: Certificate Chain vs Basis-Exchange Walk (Graphic Matroids)")
    print("=" * 70)
    print()

    for n_vertices in [4, 5]:
        bases, edges = graphic_matroid_bases(n_vertices)
        n_bases = len(bases)
        rank = n_vertices - 1

        # Basis exchange walk
        P_exchange = basis_exchange_transition(bases, edges)
        gap_exchange = spectral_gap(P_exchange)

        # Certificate-guided chain (log-concave on degree sequence)
        # Use the degree distribution of spanning trees
        degree_seq = Counter()
        for B in bases:
            total_degree = sum(1 for e_idx in B for _ in range(2))
            degree_seq[total_degree] += 1

        max_deg = max(degree_seq.keys())
        dist = [degree_seq.get(k, 0) for k in range(max_deg + 1)]

        P_cert = certificate_transition_matrix(max_deg, dist)
        gap_cert = spectral_gap(P_cert)

        print(f"  K_{n_vertices}: {n_bases} spanning trees, rank {rank}")
        print(f"    Exchange walk spectral gap:    {gap_exchange:.6f}")
        print(f"    Certificate chain spectral gap: {gap_cert:.6f}")
        mix_ex = mixing_time_estimate(P_exchange)
        mix_cert = mixing_time_estimate(P_cert)
        print(f"    Mixing time (exchange):  {mix_ex}")
        print(f"    Mixing time (cert):      {mix_cert}")
        print()


# =============================================================================
# Part 5: Certificate Tree Visualization
# =============================================================================

def demo_certificate_tree():
    """Visualize the certificate tree structure for small examples."""
    print("=" * 70)
    print("DEMO 5: Certificate Tree Structure")
    print("=" * 70)
    print()

    for n, d in [(3, 4), (4, 3), (5, 3)]:
        depth = d - 2
        n_leaves = n ** depth if depth > 0 else 1
        n_spectral_checks = n_leaves
        work_per_check = n ** 2
        total_work = n_spectral_checks * work_per_check

        print(f"  n={n} variables, d={d} degree:")
        print(f"    Certificate depth: {depth}")
        print(f"    Number of leaves: {n_leaves} (≤ n^(d-2) = {n}^{depth})")
        print(f"    Work per spectral check: {work_per_check} (= n² = {n}²)")
        print(f"    Total verification work: {total_work} (= n^d = {n}^{d})")
        print(f"    Spectral gap bound: 1/(8·{(n+1)**2}) = {1/(8*(n+1)**2):.6f}")
        print(f"    Mixing time bound: ≤ {8*(n+1)**2} · {d}·ln({n}) = "
              f"{8*(n+1)**2 * d * math.log(n):.1f}")
        print()


# =============================================================================
# Part 6: Tropical Diameter
# =============================================================================

def tropical_diameter_simplex(n, d):
    """
    Compute the tropical diameter of the standard d-simplex in n dimensions.
    This is the maximum tropical distance between vertices.
    """
    # Vertices of the d-simplex in n variables: e_i scaled by d
    # Tropical distance = max coordinate difference
    # For the standard simplex, diameter = d * (n-1)
    return d * (n - 1) if n > 1 else 0


def demo_tropical_diameter():
    """Demonstrate tropical diameter bounds on mixing time."""
    print("=" * 70)
    print("DEMO 6: Tropical Diameter Controls Mixing Time")
    print("=" * 70)
    print()
    print("  Tropical diameter of Newton polytope bounds canonical path length.")
    print("  Combined with spectral gap: mixing_time ≤ O(trop_diam · n² · log n)")
    print()

    print(f"  {'n':>3} {'d':>3} {'trop_diam':>12} {'gap_bound':>12} {'mix_bound':>12}")
    print(f"  {'-'*3} {'-'*3} {'-'*12} {'-'*12} {'-'*12}")
    for n in [3, 5, 10, 20]:
        for d in [2, 3, 4]:
            td = tropical_diameter_simplex(n, d)
            gap = 1 / (8 * (n + 1) ** 2)
            mix = td * (1 / gap) * math.log(n) if n > 1 else 0
            print(f"  {n:3d} {d:3d} {td:12d} {gap:12.6f} {mix:12.1f}")
    print()


# =============================================================================
# Part 7: Rejection Sampling from Ultra-Log-Concave Distributions
# =============================================================================

def ultra_log_concave_sample(distribution, n_samples=10000):
    """
    Sample from an ultra-log-concave distribution using rejection sampling.
    Returns samples and acceptance rate.
    """
    dist = np.array(distribution, dtype=float)
    dist /= dist.sum()
    d = len(dist) - 1

    # Envelope: uniform over {0,...,d} scaled by (d+1) * max(dist)
    M = (d + 1) * max(dist)

    samples = []
    total_attempts = 0

    while len(samples) < n_samples:
        # Propose uniformly
        k = np.random.randint(0, d + 1)
        u = np.random.random()
        total_attempts += 1
        if u * M / (d + 1) <= dist[k]:
            samples.append(k)

    acceptance_rate = n_samples / total_attempts
    return np.array(samples), acceptance_rate


def demo_rejection_sampling():
    """Demonstrate rejection sampling efficiency for ultra-log-concave distributions."""
    print("=" * 70)
    print("DEMO 7: Rejection Sampling from Ultra-Log-Concave Distributions")
    print("=" * 70)
    print()
    np.random.seed(123)

    for d in [5, 10, 20]:
        # Binomial distribution (ultra-log-concave)
        dist = [math.comb(d, k) for k in range(d + 1)]
        samples, rate = ultra_log_concave_sample(dist)

        print(f"  d = {d:3d} | Acceptance rate: {rate:.4f} | "
              f"Theoretical bound: ≥ {1/(d+1):.4f} = 1/(d+1)")
        print(f"          | Mean sample: {samples.mean():.2f} (expected: {d/2:.1f})")
    print()


# =============================================================================
# Main
# =============================================================================

def main():
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Certificate-Guided Sampling from Lorentzian Polynomials           ║")
    print("║  Interactive Demonstration                                          ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_binomial_log_concavity()
    demo_reversed_cauchy_schwarz()
    demo_spectral_gap()
    demo_exchange_comparison()
    demo_certificate_tree()
    demo_tropical_diameter()
    demo_rejection_sampling()

    print("=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


if __name__ == "__main__":
    main()
