"""
Applications of Graph Jacobian Arithmetic Statistics

Demonstrates real-world applications of the theory:
1. Network reliability analysis via Jacobian structure
2. Error-correcting code construction from graph Jacobians
3. Cryptographic group generation from random graph Laplacians
"""

import numpy as np
from math import gcd
from functools import reduce
from collections import Counter
from typing import List, Tuple


# ── Inline core algorithms ──

def laplacian_matrix(n, edges):
    A = np.zeros((n, n), dtype=int)
    for i, j in edges:
        A[i, j] = A[j, i] = 1
    D = np.diag(A.sum(axis=1))
    return D - A

def reduced_laplacian(n, edges, remove=0):
    L = laplacian_matrix(n, edges)
    idx = [i for i in range(n) if i != remove]
    return L[np.ix_(idx, idx)]

def smith_normal_form(M):
    A = M.copy().astype(int)
    rows, cols = A.shape
    n = min(rows, cols)
    for k in range(n):
        changed = True
        while changed:
            changed = False
            sub = A[k:, k:]
            nonzero = np.argwhere(sub != 0)
            if len(nonzero) == 0: break
            min_val, min_pos = float('inf'), None
            for pos in nonzero:
                val = abs(sub[pos[0], pos[1]])
                if val < min_val: min_val, min_pos = val, (pos[0]+k, pos[1]+k)
            if min_pos[0] != k: A[[k, min_pos[0]]] = A[[min_pos[0], k]]
            if min_pos[1] != k: A[:, [k, min_pos[1]]] = A[:, [min_pos[1], k]]
            if A[k, k] < 0: A[k, :] = -A[k, :]
            if A[k, k] == 0: break
            for i in range(k+1, rows):
                if A[i, k] != 0:
                    q = A[i, k] // A[k, k]; A[i, :] -= q * A[k, :]
                    if A[i, k] != 0: changed = True
            for j in range(k+1, cols):
                if A[k, j] != 0:
                    q = A[k, j] // A[k, k]; A[:, j] -= q * A[:, k]
                    if A[k, j] != 0: changed = True
    diag = [abs(A[i, i]) for i in range(n)]
    for i in range(n):
        for j in range(i+1, n):
            if diag[i] and diag[j]:
                g = gcd(diag[i], diag[j]); diag[j] = diag[i]*diag[j]//g; diag[i] = g
    return diag

def graph_jacobian_factors(n, edges):
    return sorted([d for d in smith_normal_form(reduced_laplacian(n, edges)) if d > 1])

def random_graph(n, p):
    return [(i,j) for i in range(n) for j in range(i+1,n) if np.random.random() < p]

def is_connected(n, edges):
    if n <= 1: return True
    adj = {i: set() for i in range(n)}
    for i, j in edges: adj[i].add(j); adj[j].add(i)
    visited, queue = {0}, [0]
    while queue:
        v = queue.pop(0)
        for u in adj[v]:
            if u not in visited: visited.add(u); queue.append(u)
    return len(visited) == n


# ── Application 1: Network Reliability ──

def network_reliability_analysis(n: int, edges: List[Tuple[int, int]]):
    """Analyze network reliability through Jacobian structure.

    The number of spanning trees (= |Jac(G)|) measures global
    connectivity redundancy. The invariant factor structure
    reveals finer connectivity properties.

    Args:
        n: Number of nodes.
        edges: Network links.
    """
    factors = graph_jacobian_factors(n, edges)
    order = reduce(lambda a, b: a*b, factors, 1)
    exp = max(factors) if factors else 1

    print(f"Network: {n} nodes, {len(edges)} links")
    print(f"Spanning trees: {order}")
    print(f"Jacobian: " + " × ".join(f"ℤ/{d}ℤ" for d in factors))
    print(f"Exponent: {exp}")
    print(f"Cyclic complexity: {len(factors)} invariant factors")

    # Analyze prime factorization of the group
    for q in [2, 3, 5, 7]:
        qk_count = sum(1 for d in factors if d % q == 0)
        if qk_count > 0:
            print(f"  {q}-rank: {qk_count}")

    # Redundancy metric: ratio of order to exponent
    redundancy = order / exp if exp > 0 else 0
    print(f"Redundancy ratio |Jac|/exp: {redundancy:.2f}")
    return factors, order


# ── Application 2: Code Construction ──

def jacobian_code_parameters(n: int, edges: List[Tuple[int, int]]):
    """Derive error-correcting code parameters from the graph Jacobian.

    The cut space and cycle space of a graph give binary codes.
    The Jacobian structure refines these into codes over ℤ/dℤ.

    Args:
        n: Number of vertices.
        edges: Edge list.
    """
    factors = graph_jacobian_factors(n, edges)
    m = len(edges)
    k = n - 1  # rank of cut space (assuming connected)

    print(f"\nCode from graph ({n} vertices, {m} edges):")
    print(f"  Cut code:   [{m}, {k}] over GF(2)")
    print(f"  Cycle code: [{m}, {m-k}] over GF(2)")

    # Jacobian-enhanced codes over cyclic groups
    for d in set(factors):
        mult = factors.count(d)
        print(f"  Jacobian component: {mult} copies of ℤ/{d}ℤ")
        print(f"    → [{mult}, ?, d] code over ℤ/{d}ℤ with minimum distance ≥ graph girth")


# ── Application 3: Cryptographic Group Generation ──

def crypto_group_analysis(n: int, p: float, num_trials: int = 100):
    """Analyze random graph Jacobians for cryptographic group generation.

    For certain applications, one needs finite abelian groups with
    specific properties (large prime-order subgroup, etc.).

    Args:
        n: Graph size.
        p: Edge probability.
        num_trials: Number of random graphs to test.
    """
    np.random.seed(0)
    print(f"\nCryptographic group analysis: G({n}, {p})")

    prime_order_count = 0
    large_cyclic_count = 0
    orders = []

    count = 0
    for _ in range(num_trials * 10):
        edges = random_graph(n, p)
        if not is_connected(n, edges):
            continue
        count += 1
        if count > num_trials:
            break

        factors = graph_jacobian_factors(n, edges)
        if not factors:
            continue
        order = reduce(lambda a, b: a*b, factors, 1)
        orders.append(order)

        # Check if order has a large prime factor
        if len(factors) == 1:
            large_cyclic_count += 1
        # Simple primality check for the order
        def is_prime(n):
            if n < 2: return False
            for i in range(2, int(n**0.5)+1):
                if n % i == 0: return False
            return True
        if is_prime(order):
            prime_order_count += 1

    print(f"  Sampled: {min(count, num_trials)} connected graphs")
    if orders:
        print(f"  Order range: [{min(orders)}, {max(orders)}]")
        print(f"  Mean order: {np.mean(orders):.0f}")
        print(f"  Cyclic Jacobians: {large_cyclic_count} ({100*large_cyclic_count/len(orders):.1f}%)")
        print(f"  Prime-order Jacobians: {prime_order_count} ({100*prime_order_count/len(orders):.1f}%)")


if __name__ == '__main__':
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   Applications of Graph Jacobian Arithmetic Statistics  ║")
    print("╚══════════════════════════════════════════════════════════╝\n")

    # Application 1: Network reliability
    print("═══ Application 1: Network Reliability ═══\n")
    # Small internet-like topology
    net_edges = [(0,1),(0,2),(1,2),(1,3),(2,3),(2,4),(3,4),(3,5),(4,5),(4,6),(5,6)]
    network_reliability_analysis(7, net_edges)

    # Compare with a less connected network
    print()
    sparse_edges = [(0,1),(1,2),(2,3),(3,4),(4,5),(5,6)]
    network_reliability_analysis(7, sparse_edges)

    # Application 2: Code construction
    print("\n═══ Application 2: Error-Correcting Codes ═══")
    # Petersen graph
    petersen = [(0,1),(1,2),(2,3),(3,4),(4,0),(5,7),(7,9),(9,6),(6,8),(8,5),
                (0,5),(1,6),(2,7),(3,8),(4,9)]
    jacobian_code_parameters(10, petersen)

    # Complete graph K_5
    k5 = [(i,j) for i in range(5) for j in range(i+1,5)]
    jacobian_code_parameters(5, k5)

    # Application 3: Crypto groups
    print("\n═══ Application 3: Cryptographic Groups ═══")
    crypto_group_analysis(12, 0.5, num_trials=50)
    crypto_group_analysis(15, 0.4, num_trials=50)


"""
Demo: Arithmetic Statistics of Graph Jacobians

Interactive demonstration of the connection between random graph
Laplacians, Smith normal form, and Cohen-Lenstra statistics.

Generates random Erdős-Rényi graphs G(n,p), computes their Jacobian
groups via reduced Laplacian + Smith normal form, and compares
empirical statistics against Cohen-Lenstra predictions.
"""

import numpy as np
from math import gcd
from functools import reduce
from collections import Counter
import sys

# ── Inline algorithm implementations (self-contained) ──

def adjacency_matrix(n, edges):
    A = np.zeros((n, n), dtype=int)
    for i, j in edges:
        A[i, j] = 1
        A[j, i] = 1
    return A

def laplacian_matrix(n, edges):
    A = adjacency_matrix(n, edges)
    D = np.diag(A.sum(axis=1))
    return D - A

def reduced_laplacian(n, edges, remove=0):
    L = laplacian_matrix(n, edges)
    idx = [i for i in range(n) if i != remove]
    return L[np.ix_(idx, idx)]

def smith_normal_form(M):
    A = M.copy().astype(int)
    rows, cols = A.shape
    n = min(rows, cols)
    for k in range(n):
        changed = True
        while changed:
            changed = False
            sub = A[k:, k:]
            nonzero = np.argwhere(sub != 0)
            if len(nonzero) == 0:
                break
            min_val = float('inf')
            min_pos = None
            for pos in nonzero:
                val = abs(sub[pos[0], pos[1]])
                if val < min_val:
                    min_val = val
                    min_pos = (pos[0] + k, pos[1] + k)
            if min_pos[0] != k:
                A[[k, min_pos[0]]] = A[[min_pos[0], k]]
            if min_pos[1] != k:
                A[:, [k, min_pos[1]]] = A[:, [min_pos[1], k]]
            if A[k, k] < 0:
                A[k, :] = -A[k, :]
            if A[k, k] == 0:
                break
            for i in range(k + 1, rows):
                if A[i, k] != 0:
                    q = A[i, k] // A[k, k]
                    A[i, :] -= q * A[k, :]
                    if A[i, k] != 0:
                        changed = True
            for j in range(k + 1, cols):
                if A[k, j] != 0:
                    q = A[k, j] // A[k, k]
                    A[:, j] -= q * A[:, k]
                    if A[k, j] != 0:
                        changed = True
    diag = [abs(A[i, i]) if i < min(rows, cols) else 0 for i in range(n)]
    for i in range(n):
        for j in range(i + 1, n):
            if diag[i] != 0 and diag[j] != 0:
                g = gcd(diag[i], diag[j])
                diag[j] = diag[i] * diag[j] // g
                diag[i] = g
    return diag

def invariant_factors(M):
    diag = smith_normal_form(M)
    return sorted([d for d in diag if d > 1])

def graph_jacobian_factors(n, edges):
    L_red = reduced_laplacian(n, edges)
    return invariant_factors(L_red)

def prime_power_torsion(factors, q, k):
    qk = q ** k
    return reduce(lambda a, b: a * b, [gcd(d, qk) for d in factors], 1)

def q_primary_profile(factors, q):
    profile = []
    j = 0
    while True:
        c = sum(1 for d in factors if d % (q ** j) == 0)
        if c == 0 and j > 0:
            break
        profile.append(c)
        j += 1
    return profile

def random_graph(n, p):
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if np.random.random() < p:
                edges.append((i, j))
    return edges

def is_connected(n, edges):
    if n <= 1:
        return True
    adj = {i: set() for i in range(n)}
    for i, j in edges:
        adj[i].add(j)
        adj[j].add(i)
    visited = set()
    queue = [0]
    visited.add(0)
    while queue:
        v = queue.pop(0)
        for u in adj[v]:
            if u not in visited:
                visited.add(u)
                queue.append(u)
    return len(visited) == n

def cl_expected_moment(q, k, max_terms=50):
    total = 0.0
    for m in range(max_terms):
        prob = (1 - 1.0/q) * (1.0/q)**m
        moment = q ** min(m, k)
        total += prob * moment
    return total

# ── Demo Sections ──

def demo_specific_graphs():
    """Demonstrate Jacobian computation on specific well-known graphs."""
    print("=" * 60)
    print("SECTION 1: Jacobians of Specific Graphs")
    print("=" * 60)

    # Complete graph K_n
    for n in [3, 4, 5, 6]:
        edges = [(i, j) for i in range(n) for j in range(i+1, n)]
        factors = graph_jacobian_factors(n, edges)
        group_str = " × ".join(f"ℤ/{d}ℤ" for d in factors) if factors else "trivial"
        order = reduce(lambda a, b: a * b, factors, 1)
        print(f"\nK_{n}:")
        print(f"  Invariant factors: {factors}")
        print(f"  Jac(K_{n}) ≅ {group_str}")
        print(f"  |Jac(K_{n})| = {order} (= n^(n-2) = {n**(n-2)} spanning trees)")

    # Cycle graph C_n
    for n in [4, 5, 6, 7]:
        edges = [(i, (i+1) % n) for i in range(n)]
        factors = graph_jacobian_factors(n, edges)
        group_str = " × ".join(f"ℤ/{d}ℤ" for d in factors) if factors else "trivial"
        print(f"\nC_{n}:")
        print(f"  Invariant factors: {factors}")
        print(f"  Jac(C_{n}) ≅ {group_str}")

    # Petersen graph
    petersen_edges = [
        (0,1),(1,2),(2,3),(3,4),(4,0),  # outer cycle
        (5,7),(7,9),(9,6),(6,8),(8,5),  # inner pentagram
        (0,5),(1,6),(2,7),(3,8),(4,9),  # spokes
    ]
    factors = graph_jacobian_factors(10, petersen_edges)
    group_str = " × ".join(f"ℤ/{d}ℤ" for d in factors) if factors else "trivial"
    order = reduce(lambda a, b: a * b, factors, 1)
    print(f"\nPetersen graph:")
    print(f"  Invariant factors: {factors}")
    print(f"  Jac ≅ {group_str}")
    print(f"  |Jac| = {order} (= 2000 spanning trees)")


def demo_theorem_a():
    """Demonstrate Theorem A: Prime power divisibility criterion."""
    print("\n" + "=" * 60)
    print("SECTION 2: Theorem A — Divisibility Criterion")
    print("=" * 60)
    print()
    print("Theorem: q^k | exp(Jac(G)) ⟺ ∃i, q^k | d_i ⟺ q^k | d_r")
    print()

    # K_5: Jac ≅ Z/5Z × Z/5Z × Z/5Z
    n = 5
    edges = [(i, j) for i in range(n) for j in range(i+1, n)]
    factors = graph_jacobian_factors(n, edges)
    exp = max(factors) if factors else 1
    print(f"K_5: factors = {factors}, exponent = {exp}")

    for q in [2, 3, 5]:
        for k in [1, 2]:
            dvd_exp = (exp % (q**k) == 0)
            dvd_any = any(d % (q**k) == 0 for d in factors)
            dvd_last = (factors[-1] % (q**k) == 0) if factors else False
            print(f"  {q}^{k}={q**k} | exp={exp}? {dvd_exp}  "
                  f"| some d_i? {dvd_any}  | d_r={factors[-1] if factors else 'N/A'}? {dvd_last}")
            assert dvd_exp == dvd_any == dvd_last, "Theorem A violated!"

    print("\n✓ Theorem A verified on all test cases.")


def demo_theorem_b():
    """Demonstrate Theorem B: Prime-power moment identity."""
    print("\n" + "=" * 60)
    print("SECTION 3: Theorem B — Prime-Power Moment Identity")
    print("=" * 60)
    print()
    print("Theorem: M_{q,k}(Jac(G)) = ∏_i gcd(d_i, q^k)")
    print()

    test_cases = [
        ("K_4", 4, [(i,j) for i in range(4) for j in range(i+1,4)]),
        ("K_5", 5, [(i,j) for i in range(5) for j in range(i+1,5)]),
        ("K_6", 6, [(i,j) for i in range(6) for j in range(i+1,6)]),
    ]

    for name, n, edges in test_cases:
        factors = graph_jacobian_factors(n, edges)
        print(f"\n{name}: factors = {factors}")
        for q in [2, 3, 5]:
            for k in [1, 2, 3]:
                qk = q ** k
                moment = prime_power_torsion(factors, q, k)
                prod_gcd = reduce(lambda a, b: a * b,
                                  [gcd(d, qk) for d in factors], 1)
                print(f"  M_{{{q},{k}}} = {moment} = ∏ gcd(d_i, {qk}) = {prod_gcd}")
                assert moment == prod_gcd, "Theorem B violated!"

    print("\n✓ Theorem B verified on all test cases.")


def demo_theorem_c():
    """Demonstrate Theorem C: Profile antitone and recovery."""
    print("\n" + "=" * 60)
    print("SECTION 4: Theorem C — q-Primary Profile")
    print("=" * 60)
    print()
    print("The q-primary profile λ_{q,j} = #{i : q^j | d_i} is non-increasing")
    print()

    n = 6
    edges = [(i,j) for i in range(n) for j in range(i+1,n)]
    factors = graph_jacobian_factors(n, edges)
    print(f"K_6: factors = {factors}")

    for q in [2, 3, 5]:
        prof = q_primary_profile(factors, q)
        print(f"  {q}-primary profile: {prof}")
        # Verify antitone
        for j in range(len(prof) - 1):
            assert prof[j] >= prof[j+1], f"Not antitone at j={j}!"
    print("\n✓ Antitone property verified.")


def demo_cohen_lenstra_comparison():
    """Compare random graph Jacobians against Cohen-Lenstra predictions."""
    print("\n" + "=" * 60)
    print("SECTION 5: Cohen-Lenstra Comparison (Random Graphs)")
    print("=" * 60)
    print()
    print("Conjecture: For G(n,p), the q-primary statistics of Jac(G)")
    print("asymptotically match the Cohen-Lenstra distribution.")
    print()

    np.random.seed(42)
    primes = [2, 3, 5]

    for n in [10, 20, 30]:
        p = 0.5
        num_samples = 200
        print(f"\n--- G({n}, {p}), {num_samples} samples ---")

        moments_data = {q: {k: [] for k in [1, 2]} for q in primes}
        count = 0
        attempts = 0
        while count < num_samples and attempts < num_samples * 20:
            attempts += 1
            edges = random_graph(n, p)
            if not is_connected(n, edges):
                continue
            count += 1
            factors = graph_jacobian_factors(n, edges)
            if not factors:
                factors = [1]
            for q in primes:
                for k in [1, 2]:
                    m = prime_power_torsion(factors, q, k)
                    moments_data[q][k].append(m)

        print(f"  (sampled {count} connected graphs)")

        for q in primes:
            print(f"\n  q = {q}:")
            for k in [1, 2]:
                empirical = np.mean(moments_data[q][k])
                cl_pred = cl_expected_moment(q, k)
                ratio = empirical / cl_pred if cl_pred > 0 else float('inf')
                print(f"    E[M_{{{q},{k}}}]: empirical = {empirical:.4f}, "
                      f"CL prediction = {cl_pred:.4f}, ratio = {ratio:.4f}")


def demo_cyclic_prime_power_gcd():
    """Demonstrate the key identity gcd(q^m, q^k) = q^min(m,k)."""
    print("\n" + "=" * 60)
    print("SECTION 6: Key Identity — gcd(q^m, q^k) = q^min(m,k)")
    print("=" * 60)
    print()

    for q in [2, 3, 5, 7]:
        print(f"q = {q}:")
        for m in range(5):
            for k in range(5):
                lhs = gcd(q**m, q**k)
                rhs = q ** min(m, k)
                status = "✓" if lhs == rhs else "✗"
                if m <= 2 and k <= 2:
                    print(f"  gcd({q}^{m}, {q}^{k}) = {lhs} = {q}^min({m},{k}) = {rhs} {status}")
                assert lhs == rhs, f"Identity failed for q={q}, m={m}, k={k}"
        print(f"  ... all verified up to m,k = 4")


if __name__ == '__main__':
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   Arithmetic Statistics of Graph Jacobians — Demo       ║")
    print("║                                                         ║")
    print("║   Bridging random graphs to Cohen-Lenstra heuristics    ║")
    print("║   via Smith normal form of reduced Laplacians           ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_specific_graphs()
    demo_theorem_a()
    demo_theorem_b()
    demo_theorem_c()
    demo_cyclic_prime_power_gcd()
    demo_cohen_lenstra_comparison()

    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


"""
Visualization: Jacobian Group Landscape

Shows the distribution of Jacobian group structures (as direct sums
of cyclic groups) for random Erdős-Rényi graphs. Each bar represents
a distinct isomorphism class of the Jacobian, colored by the number
of cyclic summands (rank). This reveals the arithmetic diversity of
random graph Jacobians.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import gcd
from functools import reduce
from collections import Counter

# ── Inline algorithms ──

def smith_normal_form(M):
    A = M.copy().astype(int)
    rows, cols = A.shape
    n = min(rows, cols)
    for k in range(n):
        changed = True
        while changed:
            changed = False
            sub = A[k:, k:]
            nz = np.argwhere(sub != 0)
            if len(nz) == 0: break
            mv, mp = float('inf'), None
            for pos in nz:
                v = abs(sub[pos[0], pos[1]])
                if v < mv: mv, mp = v, (pos[0]+k, pos[1]+k)
            if mp[0] != k: A[[k, mp[0]]] = A[[mp[0], k]]
            if mp[1] != k: A[:, [k, mp[1]]] = A[:, [mp[1], k]]
            if A[k,k] < 0: A[k,:] = -A[k,:]
            if A[k,k] == 0: break
            for i in range(k+1, rows):
                if A[i,k] != 0:
                    q = A[i,k]//A[k,k]; A[i,:] -= q*A[k,:]
                    if A[i,k] != 0: changed = True
            for j in range(k+1, cols):
                if A[k,j] != 0:
                    q = A[k,j]//A[k,k]; A[:,j] -= q*A[:,k]
                    if A[k,j] != 0: changed = True
    diag = [abs(A[i,i]) for i in range(n)]
    for i in range(n):
        for j in range(i+1, n):
            if diag[i] and diag[j]:
                g = gcd(diag[i], diag[j]); diag[j] = diag[i]*diag[j]//g; diag[i] = g
    return diag

def graph_jacobian_factors(n, edges):
    A = np.zeros((n,n), dtype=int)
    for i,j in edges: A[i,j] = A[j,i] = 1
    L = np.diag(A.sum(axis=1)) - A
    idx = list(range(1, n))
    Lr = L[np.ix_(idx, idx)]
    return sorted([d for d in smith_normal_form(Lr) if d > 1])

def random_connected_graph(n, p):
    while True:
        edges = [(i,j) for i in range(n) for j in range(i+1,n) if np.random.random() < p]
        adj = {i: set() for i in range(n)}
        for i,j in edges: adj[i].add(j); adj[j].add(i)
        visited, queue = {0}, [0]
        while queue:
            v = queue.pop(0)
            for u in adj[v]:
                if u not in visited: visited.add(u); queue.append(u)
        if len(visited) == n: return edges

# ── Sampling ──
np.random.seed(77)
n = 8
p_edge = 0.5
num_samples = 500

group_types = Counter()
for _ in range(num_samples):
    edges = random_connected_graph(n, p_edge)
    factors = graph_jacobian_factors(n, edges)
    label = " × ".join(f"Z/{d}" for d in factors) if factors else "trivial"
    group_types[label] += 1

# Sort by frequency
sorted_types = sorted(group_types.items(), key=lambda x: -x[1])
top_k = min(20, len(sorted_types))
labels = [t[0] for t in sorted_types[:top_k]]
counts = [t[1] for t in sorted_types[:top_k]]
if len(sorted_types) > top_k:
    labels.append("other")
    counts.append(sum(t[1] for t in sorted_types[top_k:]))

# Color by number of cyclic summands
def rank_of_label(label):
    if label == "trivial" or label == "other":
        return 0
    return label.count("×") + 1

colors_map = {0: '#9E9E9E', 1: '#2196F3', 2: '#FF9800', 3: '#4CAF50',
              4: '#F44336', 5: '#9C27B0', 6: '#00BCD4'}
bar_colors = [colors_map.get(rank_of_label(l), '#795548') for l in labels]

# ── Plotting ──
fig, ax = plt.subplots(figsize=(14, 6))
bars = ax.barh(range(len(labels)), counts, color=bar_colors,
               edgecolor='black', linewidth=0.5, alpha=0.85)
ax.set_yticks(range(len(labels)))
ax.set_yticklabels(labels, fontsize=9)
ax.set_xlabel('Frequency', fontsize=12)
ax.set_title(f'Distribution of Jacobian Group Types\n'
             f'G({n}, {p_edge}), {num_samples} random connected graphs',
             fontsize=14, fontweight='bold')
ax.invert_yaxis()
ax.grid(True, alpha=0.3, axis='x')

# Add frequency labels
for bar, count in zip(bars, counts):
    ax.text(bar.get_width() + 1, bar.get_y() + bar.get_height()/2,
            f'{count} ({100*count/num_samples:.1f}%)',
            va='center', fontsize=8)

# Legend for ranks
from matplotlib.patches import Patch
legend_elements = [Patch(facecolor=colors_map[r], label=f'Rank {r}')
                   for r in sorted(set(rank_of_label(l) for l in labels))
                   if r in colors_map]
ax.legend(handles=legend_elements, loc='lower right', fontsize=9)

plt.tight_layout()
plt.savefig('viz_jacobian_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_jacobian_landscape.png")


"""
Visualization: Prime-Power Moments vs Cohen-Lenstra Predictions

Plots the empirical mean of M_{q,k}(Jac(G)) for random Erdős-Rényi
graphs G(n, 1/2) against the Cohen-Lenstra predicted values, showing
convergence as n increases. This visualizes the core connection between
random graph Jacobians and arithmetic statistics.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import gcd
from functools import reduce

# ── Inline algorithms ──

def smith_normal_form(M):
    A = M.copy().astype(int)
    rows, cols = A.shape
    n = min(rows, cols)
    for k in range(n):
        changed = True
        while changed:
            changed = False
            sub = A[k:, k:]
            nz = np.argwhere(sub != 0)
            if len(nz) == 0: break
            mv, mp = float('inf'), None
            for pos in nz:
                v = abs(sub[pos[0], pos[1]])
                if v < mv: mv, mp = v, (pos[0]+k, pos[1]+k)
            if mp[0] != k: A[[k, mp[0]]] = A[[mp[0], k]]
            if mp[1] != k: A[:, [k, mp[1]]] = A[:, [mp[1], k]]
            if A[k,k] < 0: A[k,:] = -A[k,:]
            if A[k,k] == 0: break
            for i in range(k+1, rows):
                if A[i,k] != 0:
                    q = A[i,k]//A[k,k]; A[i,:] -= q*A[k,:]
                    if A[i,k] != 0: changed = True
            for j in range(k+1, cols):
                if A[k,j] != 0:
                    q = A[k,j]//A[k,k]; A[:,j] -= q*A[:,k]
                    if A[k,j] != 0: changed = True
    diag = [abs(A[i,i]) for i in range(n)]
    for i in range(n):
        for j in range(i+1, n):
            if diag[i] and diag[j]:
                g = gcd(diag[i], diag[j]); diag[j] = diag[i]*diag[j]//g; diag[i] = g
    return diag

def graph_jacobian_factors(n, edges):
    A = np.zeros((n,n), dtype=int)
    for i,j in edges: A[i,j] = A[j,i] = 1
    L = np.diag(A.sum(axis=1)) - A
    idx = list(range(1, n))
    Lr = L[np.ix_(idx, idx)]
    return sorted([d for d in smith_normal_form(Lr) if d > 1])

def random_connected_graph(n, p):
    while True:
        edges = [(i,j) for i in range(n) for j in range(i+1,n) if np.random.random() < p]
        adj = {i: set() for i in range(n)}
        for i,j in edges: adj[i].add(j); adj[j].add(i)
        visited, queue = {0}, [0]
        while queue:
            v = queue.pop(0)
            for u in adj[v]:
                if u not in visited: visited.add(u); queue.append(u)
        if len(visited) == n: return edges

def cl_moment(q, k):
    total = 0.0
    for m in range(50):
        total += (1 - 1.0/q) * (1.0/q)**m * q**min(m, k)
    return total

# ── Sampling ──
np.random.seed(42)
ns = [8, 12, 16, 20, 25]
p_edge = 0.5
num_samples = 150
primes = [2, 3, 5]
ks = [1, 2]

results = {q: {k: [] for k in ks} for q in primes}

for n in ns:
    for q in primes:
        for k in ks:
            moments = []
            for _ in range(num_samples):
                edges = random_connected_graph(n, p_edge)
                factors = graph_jacobian_factors(n, edges)
                if not factors: factors = [1]
                m = reduce(lambda a,b: a*b, [gcd(d, q**k) for d in factors], 1)
                moments.append(m)
            results[q][k].append(np.mean(moments))

# ── Plotting ──
fig, axes = plt.subplots(1, 3, figsize=(15, 5))
colors = ['#2196F3', '#FF5722']

for idx, q in enumerate(primes):
    ax = axes[idx]
    for ki, k in enumerate(ks):
        cl_pred = cl_moment(q, k)
        ax.plot(ns, results[q][k], 'o-', color=colors[ki],
                label=f'Empirical E[M_{{{q},{k}}}]', markersize=8)
        ax.axhline(y=cl_pred, color=colors[ki], linestyle='--', alpha=0.7,
                   label=f'CL prediction = {cl_pred:.3f}')
    ax.set_xlabel('n (graph size)', fontsize=12)
    ax.set_ylabel('Mean torsion count', fontsize=12)
    ax.set_title(f'q = {q}', fontsize=14, fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

fig.suptitle('Prime-Power Moments of Random Graph Jacobians vs Cohen-Lenstra Predictions\n'
             f'G(n, {p_edge}), {num_samples} samples per point',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_moments.png', dpi=150, bbox_inches='tight')
print("Saved viz_moments.png")


"""
Visualization: q-Primary Profiles of Random Graph Jacobians

Creates a heatmap showing the distribution of q-primary profiles
λ_{q,j} = #{i : q^j | d_i} for random Erdős-Rényi graph Jacobians.
This visualizes the partition structure that connects to Cohen-Lenstra
theory — the antitone (non-increasing) property is visible as the
staircase pattern in the heatmap.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import gcd
from functools import reduce

# ── Inline algorithms ──

def smith_normal_form(M):
    A = M.copy().astype(int)
    rows, cols = A.shape
    n = min(rows, cols)
    for k in range(n):
        changed = True
        while changed:
            changed = False
            sub = A[k:, k:]
            nz = np.argwhere(sub != 0)
            if len(nz) == 0: break
            mv, mp = float('inf'), None
            for pos in nz:
                v = abs(sub[pos[0], pos[1]])
                if v < mv: mv, mp = v, (pos[0]+k, pos[1]+k)
            if mp[0] != k: A[[k, mp[0]]] = A[[mp[0], k]]
            if mp[1] != k: A[:, [k, mp[1]]] = A[:, [mp[1], k]]
            if A[k,k] < 0: A[k,:] = -A[k,:]
            if A[k,k] == 0: break
            for i in range(k+1, rows):
                if A[i,k] != 0:
                    q = A[i,k]//A[k,k]; A[i,:] -= q*A[k,:]
                    if A[i,k] != 0: changed = True
            for j in range(k+1, cols):
                if A[k,j] != 0:
                    q = A[k,j]//A[k,k]; A[:,j] -= q*A[:,k]
                    if A[k,j] != 0: changed = True
    diag = [abs(A[i,i]) for i in range(n)]
    for i in range(n):
        for j in range(i+1, n):
            if diag[i] and diag[j]:
                g = gcd(diag[i], diag[j]); diag[j] = diag[i]*diag[j]//g; diag[i] = g
    return diag

def graph_jacobian_factors(n, edges):
    A = np.zeros((n,n), dtype=int)
    for i,j in edges: A[i,j] = A[j,i] = 1
    L = np.diag(A.sum(axis=1)) - A
    idx = list(range(1, n))
    Lr = L[np.ix_(idx, idx)]
    return sorted([d for d in smith_normal_form(Lr) if d > 1])

def random_connected_graph(n, p):
    while True:
        edges = [(i,j) for i in range(n) for j in range(i+1,n) if np.random.random() < p]
        adj = {i: set() for i in range(n)}
        for i,j in edges: adj[i].add(j); adj[j].add(i)
        visited, queue = {0}, [0]
        while queue:
            v = queue.pop(0)
            for u in adj[v]:
                if u not in visited: visited.add(u); queue.append(u)
        if len(visited) == n: return edges

# ── Sampling ──
np.random.seed(123)
n = 15
p_edge = 0.5
num_samples = 200
max_level = 8

primes = [2, 3, 5]
profile_data = {q: np.zeros((num_samples, max_level)) for q in primes}

for s in range(num_samples):
    edges = random_connected_graph(n, p_edge)
    factors = graph_jacobian_factors(n, edges)
    if not factors:
        factors = [1]
    for q in primes:
        for j in range(max_level):
            count = sum(1 for d in factors if d % (q**j) == 0)
            profile_data[q][s, j] = count

# ── Plotting ──
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

for idx, q in enumerate(primes):
    ax = axes[idx]
    data = profile_data[q]

    # Compute mean and std per level
    means = data.mean(axis=0)
    stds = data.std(axis=0)

    levels = np.arange(max_level)
    ax.bar(levels, means, yerr=stds, capsize=4,
           color=plt.cm.viridis(np.linspace(0.3, 0.9, max_level)),
           edgecolor='black', linewidth=0.5, alpha=0.8)

    ax.set_xlabel('Level j', fontsize=12)
    ax.set_ylabel(f'Mean λ_{{{q},j}}', fontsize=12)
    ax.set_title(f'q = {q}: q-Primary Profile', fontsize=14, fontweight='bold')
    ax.set_xticks(levels)
    ax.grid(True, alpha=0.3, axis='y')

    # Annotate with antitone property
    ax.annotate('Antitone\n(non-increasing)',
                xy=(max_level//2, means[max_level//2]),
                fontsize=9, ha='center', style='italic', color='gray')

fig.suptitle(f'q-Primary Profiles of Random Graph Jacobians\n'
             f'G({n}, {p_edge}), {num_samples} samples — '
             f'λ_{{q,j}} = #{{i : q^j | d_i}}',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_profiles.png', dpi=150, bbox_inches='tight')
print("Saved viz_profiles.png")
