"""
Applications of Graph Jacobian Arithmetic Statistics

This module demonstrates real-world applications of the theorems proved in
Catalog/Pythagorean/GraphJacobians/ArithmeticStatistics.lean:

1. **Network Vulnerability Analysis**: Using Jacobian invariant factors
   to detect structural bottlenecks in communication networks.

2. **Error-Correcting Code Design**: The Jacobian structure determines
   the performance of graph-based LDPC codes.

3. **Sandpile Dynamics Prediction**: Prime-power moments predict the
   recurrence structure of chip-firing/sandpile configurations.
"""

import numpy as np
from math import gcd, lcm
from functools import reduce
from typing import List, Tuple, Dict
from collections import Counter


# ============================================================
# Core algorithms (inlined for self-containment)
# ============================================================

def graph_laplacian(adj: np.ndarray) -> np.ndarray:
    return np.diag(adj.sum(axis=1)) - adj

def reduced_laplacian(L: np.ndarray, v: int = 0) -> np.ndarray:
    idx = [i for i in range(L.shape[0]) if i != v]
    return L[np.ix_(idx, idx)]

def smith_normal_form(M: np.ndarray) -> List[int]:
    M = M.copy().astype(int)
    n, m = M.shape
    r = min(n, m)
    for col in range(r):
        pf = False
        for i in range(col, n):
            for j in range(col, m):
                if M[i, j] != 0:
                    M[[col, i]] = M[[i, col]]
                    M[:, [col, j]] = M[:, [j, col]]
                    pf = True; break
            if pf: break
        if not pf: break
        changed = True
        while changed:
            changed = False
            if M[col, col] < 0: M[col] = -M[col]
            for i in range(col+1, n):
                if M[i, col] != 0:
                    q = M[i, col] // M[col, col]
                    M[i] -= q * M[col]
                    if M[i, col] != 0:
                        if abs(M[i, col]) < abs(M[col, col]):
                            M[[col, i]] = M[[i, col]]
                        changed = True
            for j in range(col+1, m):
                if M[col, j] != 0:
                    q = M[col, j] // M[col, col]
                    M[:, j] -= q * M[:, col]
                    if M[col, j] != 0:
                        if abs(M[col, j]) < abs(M[col, col]):
                            M[:, [col, j]] = M[:, [j, col]]
                        changed = True
            for i in range(col+1, n):
                for j in range(col+1, m):
                    if M[i, j] % M[col, col] != 0:
                        M[i] += M[col]; changed = True; break
                if changed: break
    return [abs(int(M[i, i])) for i in range(r) if M[i, i] != 0]

def jacobian_factors(adj: np.ndarray) -> List[int]:
    L = graph_laplacian(adj)
    Ls = reduced_laplacian(L)
    factors = smith_normal_form(Ls)
    return sorted([f for f in factors if f > 1])

def prime_power_moment(factors, q, k):
    qk = q**k; r = 1
    for d in factors: r *= gcd(d, qk)
    return r

def q_profile(factors, q):
    prof = []; j = 1
    while True:
        c = sum(1 for d in factors if d % (q**j) == 0)
        if c == 0: break
        prof.append(c); j += 1
    return prof

def group_exponent(factors):
    if not factors: return 1
    return reduce(lcm, factors)

def padic_val(n, p):
    if n == 0: return 999
    v = 0
    while n % p == 0: v += 1; n //= p
    return v

def erdos_renyi(n, p, rng=None):
    if rng is None: rng = np.random.default_rng()
    upper = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(i+1, n):
            if rng.random() < p: upper[i,j] = 1
    return upper + upper.T

def is_connected(adj):
    n = adj.shape[0]
    vis = {0}; q = [0]
    while q:
        v = q.pop(0)
        for u in range(n):
            if adj[v,u] and u not in vis:
                vis.add(u); q.append(u)
    return len(vis) == n


# ============================================================
# Application 1: Network Vulnerability via Jacobian Structure
# ============================================================

def network_vulnerability_score(adj: np.ndarray) -> Dict:
    """
    Analyze network vulnerability using Jacobian arithmetic invariants.

    The invariant factors of the graph Jacobian encode how "evenly"
    connectivity is distributed. A network with many small invariant
    factors is more resilient; one dominated by a single large factor
    has structural bottlenecks.

    Uses Theorem D: the exponent (= last invariant factor in divisibility
    order) measures the worst-case amplification of perturbations.

    Returns:
        Dictionary with vulnerability metrics.
    """
    factors = jacobian_factors(adj)
    if not factors:
        return {'vulnerability': 0, 'factors': [], 'exponent': 1,
                'spanning_trees': 1}

    n = adj.shape[0]
    exp = group_exponent(factors)
    order = reduce(lambda a, b: a*b, factors, 1)

    # Vulnerability score: ratio of exponent to geometric mean
    geo_mean = order ** (1.0 / len(factors))
    vulnerability = exp / geo_mean if geo_mean > 0 else float('inf')

    # 2-primary depth: how many times 2 divides the exponent
    depth_2 = padic_val(exp, 2) if exp > 0 else 0

    # Number of spanning trees (= |Jac(G)| = det of reduced Laplacian)
    L = graph_laplacian(adj)
    Ls = reduced_laplacian(L)
    num_trees = abs(int(round(np.linalg.det(Ls.astype(float)))))

    return {
        'n': n,
        'factors': factors,
        'exponent': exp,
        'jacobian_order': order,
        'num_spanning_trees': num_trees,
        'vulnerability_ratio': vulnerability,
        '2_primary_depth': depth_2,
        'num_invariant_factors': len(factors),
    }


# ============================================================
# Application 2: Sandpile Recurrence via Moments
# ============================================================

def sandpile_recurrence_analysis(adj: np.ndarray) -> Dict:
    """
    Analyze sandpile/chip-firing recurrence using prime-power moments.

    The chip-firing game on a graph has recurrent configurations that
    form the graph Jacobian group. The prime-power moments M_{q,k}
    (Theorem B) count how many configurations have period dividing q^k
    under the q-primary component of the dynamics.

    Returns:
        Dictionary with sandpile recurrence metrics.
    """
    factors = jacobian_factors(adj)
    if not factors:
        factors = [1]

    exp = group_exponent(factors)
    order = reduce(lambda a, b: a*b, factors, 1)

    # Compute moments for small primes
    moment_data = {}
    for q in [2, 3, 5, 7]:
        moments = []
        for k in range(1, 6):
            m = prime_power_moment(factors, q, k)
            moments.append(m)
            if m == order:  # saturated
                break
        moment_data[q] = moments

    # q-profiles
    profiles = {}
    for q in [2, 3, 5, 7]:
        profiles[q] = q_profile(factors, q)

    # Verify Theorem C: profile recovery
    recovery_ok = {}
    for q in [2, 3, 5]:
        ok = True
        max_j = max(padic_val(d, q) for d in factors) + 1
        for j in range(1, max_j + 1):
            lhs = sum(1 for d in factors if d % (q**j) == 0)
            s1 = sum(min(padic_val(d, q), j) for d in factors)
            s0 = sum(min(padic_val(d, q), j-1) for d in factors)
            if lhs != s1 - s0:
                ok = False
        recovery_ok[q] = ok

    return {
        'factors': factors,
        'exponent': exp,
        'order': order,
        'moments': moment_data,
        'profiles': profiles,
        'profile_recovery_verified': recovery_ok,
    }


# ============================================================
# Application 3: Random Network Ensemble Analysis
# ============================================================

def ensemble_analysis(n: int, p: float, num_samples: int = 200,
                      seed: int = 42) -> Dict:
    """
    Analyze an ensemble of random G(n,p) graphs for Cohen–Lenstra statistics.

    This implements the computational falsification test for the CL-ER conjecture:
    generate random graphs, compute Jacobian statistics, and compare to
    Cohen–Lenstra predictions.

    Uses Theorems A-F to compute all relevant observables.

    Returns:
        Dictionary with ensemble statistics and CL comparison.
    """
    rng = np.random.default_rng(seed)
    primes = [2, 3, 5]

    all_factors = []
    exponents = []
    moment_samples = {q: {k: [] for k in range(1, 4)} for q in primes}
    profile_samples = {q: [] for q in primes}

    collected = 0
    for _ in range(num_samples * 5):
        A = erdos_renyi(n, p, rng)
        if not is_connected(A):
            continue

        factors = jacobian_factors(A)
        if not factors:
            factors = [1]

        all_factors.append(factors)
        exponents.append(group_exponent(factors))

        for q in primes:
            for k in range(1, 4):
                moment_samples[q][k].append(prime_power_moment(factors, q, k))
            profile_samples[q].append(q_profile(factors, q))

        collected += 1
        if collected >= num_samples:
            break

    # Cohen-Lenstra predictions
    cl_predictions = {}
    for q in primes:
        cl_predictions[q] = {}
        for k in range(1, 4):
            cl_val = 1.0
            for j in range(1, k+1):
                cl_val *= q**j / (q**j - 1)
            cl_predictions[q][k] = cl_val

    # Empirical statistics
    emp_stats = {}
    for q in primes:
        emp_stats[q] = {}
        for k in range(1, 4):
            data = moment_samples[q][k]
            if data:
                emp_stats[q][k] = {
                    'mean': np.mean(data),
                    'std': np.std(data),
                    'cl_prediction': cl_predictions[q][k],
                    'ratio': np.mean(data) / cl_predictions[q][k],
                }

    return {
        'n': n,
        'p': p,
        'collected': collected,
        'empirical_stats': emp_stats,
        'cl_predictions': cl_predictions,
        'exponent_stats': {
            'mean': np.mean(exponents),
            'median': np.median(exponents),
            'max': max(exponents),
        },
    }


if __name__ == '__main__':
    print("=" * 70)
    print("APPLICATION 1: Network Vulnerability Analysis")
    print("=" * 70)

    # Compare different network topologies
    for name, adj in [
        ("Ring (C8)", (lambda: (lambda A: (
            [setattr(A, '__', None) or A.__setitem__((i, (i+1)%8), 1) or A.__setitem__(((i+1)%8, i), 1) for i in range(8)],
            A
        )[-1])(np.zeros((8,8), dtype=int)))()),
        ("Complete (K8)", np.ones((8,8), dtype=int) - np.eye(8, dtype=int)),
    ]:
        result = network_vulnerability_score(adj.astype(int))
        print(f"\n  {name}:")
        print(f"    Jacobian factors: {result['factors']}")
        print(f"    Exponent: {result['exponent']}")
        print(f"    Spanning trees: {result['num_spanning_trees']}")
        print(f"    Vulnerability ratio: {result['vulnerability_ratio']:.3f}")

    # Simple ring graph
    A_ring = np.zeros((8, 8), dtype=int)
    for i in range(8):
        A_ring[i, (i+1) % 8] = A_ring[(i+1) % 8, i] = 1
    result = network_vulnerability_score(A_ring)
    print(f"\n  Ring (C8) [clean]:")
    print(f"    Jacobian factors: {result['factors']}")
    print(f"    Exponent: {result['exponent']}")
    print(f"    Vulnerability ratio: {result['vulnerability_ratio']:.3f}")

    print("\n" + "=" * 70)
    print("APPLICATION 2: Sandpile Recurrence")
    print("=" * 70)

    # Petersen graph
    P = np.zeros((10, 10), dtype=int)
    for (u, v) in [(i, (i+1)%5) for i in range(5)] + \
                   [(5+i, 5+(i+2)%5) for i in range(5)] + \
                   [(i, 5+i) for i in range(5)]:
        P[u, v] = P[v, u] = 1

    result = sandpile_recurrence_analysis(P)
    print(f"\n  Petersen graph:")
    print(f"    Invariant factors: {result['factors']}")
    print(f"    Exponent: {result['exponent']}")
    print(f"    Order: {result['order']}")
    print(f"    Moments: {result['moments']}")
    print(f"    Profiles: {result['profiles']}")
    print(f"    Profile recovery: {result['profile_recovery_verified']}")

    print("\n" + "=" * 70)
    print("APPLICATION 3: Ensemble Analysis for Cohen–Lenstra")
    print("=" * 70)

    for n in [10, 15, 20]:
        result = ensemble_analysis(n, 0.5, num_samples=100)
        print(f"\n  G({n}, 0.5), {result['collected']} samples:")
        for q in [2, 3, 5]:
            if q in result['empirical_stats']:
                s = result['empirical_stats'][q].get(1, {})
                if s:
                    print(f"    q={q}: E[M_{{q,1}}]={s['mean']:.3f} "
                          f"(CL={s['cl_prediction']:.3f}, ratio={s['ratio']:.3f})")


"""
Demo: Arithmetic Statistics of Graph Jacobians

Interactive demonstration of the theorems connecting graph Jacobians
to Cohen–Lenstra arithmetic statistics via Smith normal form.

This demo:
1. Generates random G(n,p) graphs
2. Computes Jacobian invariant factors via reduced Laplacian SNF
3. Verifies Theorems A-F on concrete examples
4. Compares empirical Jacobian statistics to Cohen-Lenstra predictions
5. Plots empirical histograms vs reference distributions

Dependencies: numpy, matplotlib
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import gcd, lcm
from functools import reduce
from collections import Counter
from typing import List, Tuple, Dict


# ============================================================
# Core algorithms (self-contained)
# ============================================================

def graph_laplacian(adj: np.ndarray) -> np.ndarray:
    return np.diag(adj.sum(axis=1)) - adj

def reduced_laplacian(L: np.ndarray, v: int = 0) -> np.ndarray:
    idx = [i for i in range(L.shape[0]) if i != v]
    return L[np.ix_(idx, idx)]

def smith_normal_form(M: np.ndarray) -> List[int]:
    M = M.copy().astype(int)
    n, m = M.shape
    r = min(n, m)
    for col in range(r):
        pf = False
        for i in range(col, n):
            for j in range(col, m):
                if M[i, j] != 0:
                    M[[col, i]] = M[[i, col]]
                    M[:, [col, j]] = M[:, [j, col]]
                    pf = True; break
            if pf: break
        if not pf: break
        changed = True
        while changed:
            changed = False
            if M[col, col] < 0: M[col] = -M[col]
            for i in range(col+1, n):
                if M[i, col] != 0:
                    q = M[i, col] // M[col, col]
                    M[i] -= q * M[col]
                    if M[i, col] != 0:
                        if abs(M[i, col]) < abs(M[col, col]):
                            M[[col, i]] = M[[i, col]]
                        changed = True
            for j in range(col+1, m):
                if M[col, j] != 0:
                    q = M[col, j] // M[col, col]
                    M[:, j] -= q * M[:, col]
                    if M[col, j] != 0:
                        if abs(M[col, j]) < abs(M[col, col]):
                            M[:, [col, j]] = M[:, [j, col]]
                        changed = True
            for i in range(col+1, n):
                for j in range(col+1, m):
                    if M[i, j] % M[col, col] != 0:
                        M[i] += M[col]; changed = True; break
                if changed: break
    return [abs(int(M[i, i])) for i in range(r) if M[i, i] != 0]

def jacobian_factors(adj: np.ndarray) -> List[int]:
    L = graph_laplacian(adj)
    Ls = reduced_laplacian(L)
    factors = smith_normal_form(Ls)
    return sorted([f for f in factors if f > 1])

def erdos_renyi(n, p, rng=None):
    if rng is None: rng = np.random.default_rng()
    upper = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(i+1, n):
            if rng.random() < p: upper[i,j] = 1
    return upper + upper.T

def is_connected(adj):
    n = adj.shape[0]
    vis = {0}; q = [0]
    while q:
        v = q.pop(0)
        for u in range(n):
            if adj[v,u] and u not in vis:
                vis.add(u); q.append(u)
    return len(vis) == n

def prime_power_moment(factors, q, k):
    qk = q**k; r = 1
    for d in factors: r *= gcd(d, qk)
    return r

def q_profile(factors, q):
    prof = []; j = 1
    while True:
        c = sum(1 for d in factors if d % (q**j) == 0)
        if c == 0: break
        prof.append(c); j += 1
    return prof

def group_exponent(factors):
    if not factors: return 1
    return reduce(lcm, factors)

def padic_val(n, p):
    if n == 0: return 999
    v = 0
    while n % p == 0: v += 1; n //= p
    return v

def cl_expected_moment(q, k):
    r = 1.0
    for j in range(1, k+1): r *= q**j / (q**j - 1)
    return r


# ============================================================
# Demo functions
# ============================================================

def demo_theorem_verification():
    """Verify all theorems on concrete examples."""
    print("=" * 60)
    print("DEMO 1: Theorem Verification on Concrete Examples")
    print("=" * 60)

    # Example groups
    examples = [
        ("ℤ/6ℤ", [6]),
        ("ℤ/2ℤ × ℤ/6ℤ", [2, 6]),
        ("ℤ/4ℤ × ℤ/12ℤ × ℤ/36ℤ", [4, 12, 36]),
        ("ℤ/2ℤ × ℤ/2ℤ × ℤ/2ℤ", [2, 2, 2]),
        ("ℤ/30ℤ", [30]),
    ]

    for name, factors in examples:
        print(f"\n--- {name}, factors = {factors} ---")
        exp = group_exponent(factors)
        print(f"  Exponent = {exp}")

        # Theorem A: q^k | exp ⟺ ∃ i, q^k | d_i
        for q in [2, 3, 5]:
            for k in [1, 2, 3]:
                qk = q ** k
                dvd_exp = (exp % qk == 0)
                dvd_factor = any(d % qk == 0 for d in factors)
                status = "✓" if dvd_exp == dvd_factor else "✗"
                if dvd_exp or dvd_factor:
                    print(f"  Thm A: {q}^{k}={qk} | exp={exp}? {dvd_exp}  "
                          f"∃ factor? {dvd_factor}  {status}")

        # Theorem B: M_{q,k} = ∏ gcd(d_i, q^k)
        for q in [2, 3]:
            for k in [1, 2]:
                m = prime_power_moment(factors, q, k)
                prod_gcd = 1
                for d in factors:
                    prod_gcd *= gcd(d, q**k)
                status = "✓" if m == prod_gcd else "✗"
                print(f"  Thm B: M_{{{q},{k}}} = {m} = ∏gcd = {prod_gcd}  {status}")

        # Theorem C: Profile recovery
        for q in [2, 3, 5]:
            prof = q_profile(factors, q)
            if prof:
                max_j = len(prof) + 1
                ok = True
                for j in range(1, max_j + 1):
                    lhs = sum(1 for d in factors if d % (q**j) == 0)
                    s1 = sum(min(padic_val(d, q), j) for d in factors)
                    s0 = sum(min(padic_val(d, q), j-1) for d in factors)
                    rhs = s1 - s0
                    if lhs != rhs:
                        ok = False
                print(f"  Thm C: {q}-profile = {prof}, recovery: {'✓' if ok else '✗'}")

        # Theorem D: In divisibility order, exp = last factor
        is_div_ordered = all(factors[i] % factors[i-1] == 0
                           for i in range(1, len(factors)))
        if is_div_ordered:
            print(f"  Thm D: Divisibility order ✓, exp = last = {factors[-1]}  "
                  f"{'✓' if exp == factors[-1] else '✗'}")

        # Theorem E: Moment monotonicity
        for q in [2, 3]:
            m1 = prime_power_moment(factors, q, 1)
            m2 = prime_power_moment(factors, q, 2)
            m3 = prime_power_moment(factors, q, 3)
            ok = (m2 % m1 == 0) and (m3 % m2 == 0)
            print(f"  Thm E: M_{{{q},1}}={m1} | M_{{{q},2}}={m2} | M_{{{q},3}}={m3}  "
                  f"{'✓' if ok else '✗'}")

        # Theorem F: Profile monotonicity
        for q in [2, 3]:
            prof = q_profile(factors, q)
            if len(prof) >= 2:
                ok = all(prof[i] <= prof[i-1] for i in range(1, len(prof)))
                print(f"  Thm F: {q}-profile = {prof}, monotone: {'✓' if ok else '✗'}")


def demo_graph_jacobians():
    """Compute Jacobians of small named graphs."""
    print("\n" + "=" * 60)
    print("DEMO 2: Jacobians of Named Graphs")
    print("=" * 60)

    # Complete graphs K_n
    for n in [3, 4, 5, 6]:
        A = np.ones((n, n), dtype=int) - np.eye(n, dtype=int)
        factors = jacobian_factors(A)
        exp = group_exponent(factors) if factors else 1
        order = reduce(lambda a, b: a*b, factors, 1)
        print(f"  K_{n}: Jac ≅ {'×'.join(f'ℤ/{d}ℤ' for d in factors) if factors else 'trivial'}"
              f"  |Jac| = {order}  exp = {exp}")

    # Cycle graphs C_n
    for n in [3, 4, 5, 6, 7, 8]:
        A = np.zeros((n, n), dtype=int)
        for i in range(n):
            A[i, (i+1) % n] = 1
            A[(i+1) % n, i] = 1
        factors = jacobian_factors(A)
        print(f"  C_{n}: Jac ≅ {'×'.join(f'ℤ/{d}ℤ' for d in factors) if factors else 'trivial'}")

    # Petersen graph
    P = np.zeros((10, 10), dtype=int)
    outer = [(i, (i+1)%5) for i in range(5)]
    inner = [(5+i, 5+(i+2)%5) for i in range(5)]
    spokes = [(i, 5+i) for i in range(5)]
    for (u, v) in outer + inner + spokes:
        P[u, v] = P[v, u] = 1
    factors = jacobian_factors(P)
    exp = group_exponent(factors) if factors else 1
    order = reduce(lambda a, b: a*b, factors, 1)
    print(f"  Petersen: Jac ≅ {'×'.join(f'ℤ/{d}ℤ' for d in factors)}"
          f"  |Jac| = {order}  exp = {exp}")


def demo_cohen_lenstra_comparison():
    """Compare random graph Jacobian statistics to Cohen–Lenstra predictions."""
    print("\n" + "=" * 60)
    print("DEMO 3: Cohen–Lenstra Comparison for G(n, 1/2)")
    print("=" * 60)

    rng = np.random.default_rng(42)
    primes = [2, 3, 5]

    for n in [8, 12, 16, 20]:
        print(f"\n  n = {n}:")
        moments_data = {q: {k: [] for k in range(1, 4)} for q in primes}
        collected = 0
        for _ in range(500):
            A = erdos_renyi(n, 0.5, rng)
            if not is_connected(A):
                continue
            factors = jacobian_factors(A)
            if not factors:
                factors = [1]
            for q in primes:
                for k in range(1, 4):
                    moments_data[q][k].append(prime_power_moment(factors, q, k))
            collected += 1

        for q in primes:
            print(f"    q = {q}:")
            for k in range(1, 4):
                if moments_data[q][k]:
                    emp = np.mean(moments_data[q][k])
                    cl = cl_expected_moment(q, k)
                    ratio = emp / cl if cl > 0 else float('inf')
                    print(f"      k={k}: E[M_{{q,k}}] = {emp:.4f}  "
                          f"CL = {cl:.4f}  ratio = {ratio:.4f}")


def demo_plots():
    """Generate visualization plots."""
    print("\n" + "=" * 60)
    print("DEMO 4: Generating Plots")
    print("=" * 60)

    rng = np.random.default_rng(42)

    # Collect data for multiple n values
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    fig.suptitle('Graph Jacobian Statistics vs Cohen–Lenstra Predictions',
                 fontsize=14, fontweight='bold')

    for col, q in enumerate([2, 3, 5]):
        moments_by_n = {}
        for n in [10, 15, 20, 30]:
            moments = []
            for _ in range(300):
                A = erdos_renyi(n, 0.5, rng)
                if not is_connected(A):
                    continue
                factors = jacobian_factors(A)
                if not factors:
                    factors = [1]
                moments.append(prime_power_moment(factors, q, 1))
            moments_by_n[n] = moments

        # Plot 1: Histogram of M_{q,1}
        ax = axes[0, col]
        for n in [10, 20, 30]:
            if moments_by_n[n]:
                vals = moments_by_n[n]
                max_val = max(vals)
                bins = range(0, min(max_val + 2, 50))
                ax.hist(vals, bins=bins, alpha=0.5, density=True, label=f'n={n}')
        ax.axvline(cl_expected_moment(q, 1), color='red', linestyle='--',
                   linewidth=2, label=f'CL E[M]={cl_expected_moment(q, 1):.2f}')
        ax.set_title(f'Distribution of M_{{{q},1}}')
        ax.set_xlabel(f'M_{{{q},1}}')
        ax.set_ylabel('Density')
        ax.legend(fontsize=8)

        # Plot 2: Convergence of E[M_{q,k}] to CL
        ax = axes[1, col]
        n_values = [8, 10, 12, 15, 20, 25, 30]
        for k in [1, 2]:
            empirical_means = []
            for n in n_values:
                moms = []
                for _ in range(200):
                    A = erdos_renyi(n, 0.5, rng)
                    if not is_connected(A):
                        continue
                    factors = jacobian_factors(A)
                    if not factors: factors = [1]
                    moms.append(prime_power_moment(factors, q, k))
                empirical_means.append(np.mean(moms) if moms else 0)
            ax.plot(n_values, empirical_means, 'o-', label=f'k={k} empirical')
            ax.axhline(cl_expected_moment(q, k), color='red' if k==1 else 'blue',
                      linestyle='--', alpha=0.7, label=f'k={k} CL={cl_expected_moment(q,k):.2f}')
        ax.set_title(f'Convergence to CL for q={q}')
        ax.set_xlabel('n (graph size)')
        ax.set_ylabel(f'E[M_{{{q},k}}]')
        ax.legend(fontsize=8)

    plt.tight_layout()
    plt.savefig('jacobian_statistics.png', dpi=150, bbox_inches='tight')
    print("  Saved: jacobian_statistics.png")

    # Plot q-profile distributions
    fig2, axes2 = plt.subplots(1, 3, figsize=(15, 5))
    fig2.suptitle('q-Primary Profile Distributions for G(20, 0.5)',
                  fontsize=14, fontweight='bold')

    rng2 = np.random.default_rng(123)
    for col, q in enumerate([2, 3, 5]):
        q_ranks = []
        for _ in range(500):
            A = erdos_renyi(20, 0.5, rng2)
            if not is_connected(A):
                continue
            factors = jacobian_factors(A)
            if not factors: factors = [1]
            prof = q_profile(factors, q)
            q_ranks.append(prof[0] if prof else 0)

        ax = axes2[col]
        if q_ranks:
            counter = Counter(q_ranks)
            vals = sorted(counter.keys())
            freqs = [counter[v] / len(q_ranks) for v in vals]
            ax.bar(vals, freqs, alpha=0.7, color='steelblue')
        ax.set_title(f'{q}-rank distribution')
        ax.set_xlabel(f'{q}-rank')
        ax.set_ylabel('Frequency')

    plt.tight_layout()
    plt.savefig('q_profile_distributions.png', dpi=150, bbox_inches='tight')
    print("  Saved: q_profile_distributions.png")


if __name__ == '__main__':
    demo_theorem_verification()
    demo_graph_jacobians()
    demo_cohen_lenstra_comparison()
    demo_plots()
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


"""
Visualization: Invariant Factor Profile Heatmap

This script generates a heatmap showing the distribution of q-primary
invariant factor profiles across random graph ensembles. Each cell shows
the frequency of a particular (q-rank, max q-valuation) pair,
revealing the internal structure of random graph Jacobians.

SELF-CONTAINED: All algorithms are inlined (no local imports).
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import gcd
from collections import Counter


# Inlined algorithms
def graph_laplacian(adj):
    return np.diag(adj.sum(axis=1)) - adj

def reduced_laplacian(L, v=0):
    idx = [i for i in range(L.shape[0]) if i != v]
    return L[np.ix_(idx, idx)]

def smith_normal_form(M):
    M = M.copy().astype(int)
    n, m = M.shape; r = min(n, m)
    for col in range(r):
        pf = False
        for i in range(col, n):
            for j in range(col, m):
                if M[i,j] != 0:
                    M[[col,i]] = M[[i,col]]; M[:,[col,j]] = M[:,[j,col]]
                    pf = True; break
            if pf: break
        if not pf: break
        ch = True
        while ch:
            ch = False
            if M[col,col] < 0: M[col] = -M[col]
            for i in range(col+1, n):
                if M[i,col] != 0:
                    q = M[i,col]//M[col,col]; M[i] -= q*M[col]
                    if M[i,col] != 0:
                        if abs(M[i,col]) < abs(M[col,col]): M[[col,i]] = M[[i,col]]
                        ch = True
            for j in range(col+1, m):
                if M[col,j] != 0:
                    q = M[col,j]//M[col,col]; M[:,j] -= q*M[:,col]
                    if M[col,j] != 0:
                        if abs(M[col,j]) < abs(M[col,col]): M[:,[col,j]] = M[:,[j,col]]
                        ch = True
            for i in range(col+1, n):
                brk = False
                for j in range(col+1, m):
                    if M[i,j] % M[col,col] != 0:
                        M[i] += M[col]; ch = True; brk = True; break
                if brk: break
    return [abs(int(M[i,i])) for i in range(r) if M[i,i] != 0]

def jacobian_factors(adj):
    L = graph_laplacian(adj); Ls = reduced_laplacian(L)
    return sorted([f for f in smith_normal_form(Ls) if f > 1])

def erdos_renyi(n, p, rng):
    upper = np.zeros((n,n), dtype=int)
    for i in range(n):
        for j in range(i+1, n):
            if rng.random() < p: upper[i,j] = 1
    return upper + upper.T

def is_connected(adj):
    n = adj.shape[0]; vis = {0}; queue = [0]
    while queue:
        v = queue.pop(0)
        for u in range(n):
            if adj[v,u] and u not in vis: vis.add(u); queue.append(u)
    return len(vis) == n

def padic_val(n, p):
    if n == 0: return 0
    v = 0
    while n % p == 0: v += 1; n //= p
    return v


# ============================================================
# Data collection
# ============================================================

rng = np.random.default_rng(42)
n_graph = 20
p_edge = 0.5
num_samples = 300

# For each prime, collect (q-rank, max_valuation) pairs
prime_data = {}
for q in [2, 3, 5]:
    pairs = []
    collected = 0
    for _ in range(num_samples * 5):
        A = erdos_renyi(n_graph, p_edge, rng)
        if not is_connected(A): continue
        fac = jacobian_factors(A)
        if not fac: fac = [1]

        # q-rank = number of factors divisible by q
        q_rank = sum(1 for d in fac if d % q == 0)
        # max q-valuation
        max_val = max(padic_val(d, q) for d in fac) if fac else 0
        pairs.append((q_rank, max_val))

        collected += 1
        if collected >= num_samples: break
    prime_data[q] = pairs


# ============================================================
# Plotting
# ============================================================

fig, axes = plt.subplots(1, 3, figsize=(18, 6))
fig.suptitle(f'q-Primary Profile Distribution of Graph Jacobians\n'
             f'G({n_graph}, {p_edge}), {num_samples} samples per prime',
             fontsize=14, fontweight='bold')

for col, q in enumerate([2, 3, 5]):
    ax = axes[col]
    pairs = prime_data[q]

    if not pairs:
        ax.set_title(f'q = {q}: No data')
        continue

    # Create heatmap
    max_rank = max(r for r, v in pairs) + 1
    max_val = max(v for r, v in pairs) + 1

    heatmap = np.zeros((max_val, max_rank))
    for r, v in pairs:
        heatmap[v, r] += 1
    heatmap /= len(pairs)

    im = ax.imshow(heatmap, cmap='YlOrRd', aspect='auto', origin='lower',
                   interpolation='nearest')

    ax.set_xlabel(f'{q}-rank (# factors divisible by {q})', fontsize=11)
    ax.set_ylabel(f'Max {q}-adic valuation', fontsize=11)
    ax.set_title(f'Prime q = {q}', fontsize=13, fontweight='bold')

    # Add text annotations
    for i in range(min(max_val, 8)):
        for j in range(min(max_rank, 12)):
            if i < heatmap.shape[0] and j < heatmap.shape[1]:
                val = heatmap[i, j]
                if val > 0.005:
                    color = 'white' if val > 0.15 else 'black'
                    ax.text(j, i, f'{val:.2f}', ha='center', va='center',
                            fontsize=8, color=color, fontweight='bold')

    fig.colorbar(im, ax=ax, label='Frequency', shrink=0.8)

plt.tight_layout(rect=[0, 0, 1, 0.92])
plt.savefig('viz_invariant_factor_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved: viz_invariant_factor_heatmap.png")


"""
Visualization: Graph Jacobian Arithmetic Statistics vs Cohen–Lenstra Predictions

This script generates a comprehensive visualization showing:
1. Top row: Histograms of prime-power moments M_{q,1} for q=2,3,5
   across different graph sizes, compared to Cohen–Lenstra expected values.
2. Bottom row: Convergence of empirical E[M_{q,k}] to CL predictions
   as graph size n increases.

The plots demonstrate the CL-ER conjecture: random graph Jacobians
asymptotically obey Cohen–Lenstra statistics.

SELF-CONTAINED: All algorithms are inlined (no local imports).
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import gcd
from functools import reduce


# ============================================================
# Inlined core algorithms
# ============================================================

def graph_laplacian(adj):
    return np.diag(adj.sum(axis=1)) - adj

def reduced_laplacian(L, v=0):
    idx = [i for i in range(L.shape[0]) if i != v]
    return L[np.ix_(idx, idx)]

def smith_normal_form(M):
    M = M.copy().astype(int)
    n, m = M.shape
    r = min(n, m)
    for col in range(r):
        pf = False
        for i in range(col, n):
            for j in range(col, m):
                if M[i, j] != 0:
                    M[[col, i]] = M[[i, col]]
                    M[:, [col, j]] = M[:, [j, col]]
                    pf = True; break
            if pf: break
        if not pf: break
        ch = True
        while ch:
            ch = False
            if M[col, col] < 0: M[col] = -M[col]
            for i in range(col+1, n):
                if M[i, col] != 0:
                    q = M[i, col] // M[col, col]
                    M[i] -= q * M[col]
                    if M[i, col] != 0:
                        if abs(M[i, col]) < abs(M[col, col]):
                            M[[col, i]] = M[[i, col]]
                        ch = True
            for j in range(col+1, m):
                if M[col, j] != 0:
                    q = M[col, j] // M[col, col]
                    M[:, j] -= q * M[:, col]
                    if M[col, j] != 0:
                        if abs(M[col, j]) < abs(M[col, col]):
                            M[:, [col, j]] = M[:, [j, col]]
                        ch = True
            for i in range(col+1, n):
                brk = False
                for j in range(col+1, m):
                    if M[i, j] % M[col, col] != 0:
                        M[i] += M[col]; ch = True; brk = True; break
                if brk: break
    return [abs(int(M[i, i])) for i in range(r) if M[i, i] != 0]

def jacobian_factors(adj):
    L = graph_laplacian(adj)
    Ls = reduced_laplacian(L)
    fac = smith_normal_form(Ls)
    return sorted([f for f in fac if f > 1])

def erdos_renyi(n, p, rng):
    upper = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(i+1, n):
            if rng.random() < p: upper[i,j] = 1
    return upper + upper.T

def is_connected(adj):
    n = adj.shape[0]
    vis = {0}; queue = [0]
    while queue:
        v = queue.pop(0)
        for u in range(n):
            if adj[v,u] and u not in vis:
                vis.add(u); queue.append(u)
    return len(vis) == n

def prime_power_moment(factors, q, k):
    qk = q**k; r = 1
    for d in factors: r *= gcd(d, qk)
    return r

def cl_expected_moment(q, k):
    r = 1.0
    for j in range(1, k+1): r *= q**j / (q**j - 1)
    return r


# ============================================================
# Data collection
# ============================================================

rng = np.random.default_rng(42)
primes = [2, 3, 5]
n_values_hist = [10, 20, 30]
n_values_conv = [8, 10, 12, 15, 18, 22, 26, 30]
num_samples = 200

# Collect histogram data
hist_data = {q: {n: [] for n in n_values_hist} for q in primes}
for n in n_values_hist:
    collected = 0
    for _ in range(num_samples * 5):
        A = erdos_renyi(n, 0.5, rng)
        if not is_connected(A): continue
        fac = jacobian_factors(A)
        if not fac: fac = [1]
        for q in primes:
            hist_data[q][n].append(prime_power_moment(fac, q, 1))
        collected += 1
        if collected >= num_samples: break

# Collect convergence data
conv_data = {q: {k: [] for k in [1, 2]} for q in primes}
for n in n_values_conv:
    moments_n = {q: {k: [] for k in [1, 2]} for q in primes}
    collected = 0
    for _ in range(num_samples * 5):
        A = erdos_renyi(n, 0.5, rng)
        if not is_connected(A): continue
        fac = jacobian_factors(A)
        if not fac: fac = [1]
        for q in primes:
            for k in [1, 2]:
                moments_n[q][k].append(prime_power_moment(fac, q, k))
        collected += 1
        if collected >= num_samples: break

    for q in primes:
        for k in [1, 2]:
            data = moments_n[q][k]
            conv_data[q][k].append(np.mean(data) if data else 0)


# ============================================================
# Plotting
# ============================================================

fig, axes = plt.subplots(2, 3, figsize=(16, 11))
fig.suptitle('Graph Jacobian Statistics vs Cohen–Lenstra Predictions\n'
             'Random Erdős–Rényi Graphs G(n, 1/2)',
             fontsize=15, fontweight='bold', y=0.98)

colors = ['#2196F3', '#4CAF50', '#FF9800']
cl_color = '#E91E63'

for col, q in enumerate(primes):
    # Top: Histograms
    ax = axes[0, col]
    for idx, n in enumerate(n_values_hist):
        data = hist_data[q][n]
        if data:
            max_val = int(np.percentile(data, 95)) + 2
            bins = np.arange(0.5, max_val + 1.5, 1)
            ax.hist(data, bins=bins, alpha=0.5, density=True,
                    color=colors[idx], label=f'n={n}', edgecolor='white')

    cl_val = cl_expected_moment(q, 1)
    ax.axvline(cl_val, color=cl_color, linestyle='--', linewidth=2.5,
               label=f'CL E[M]={cl_val:.2f}')
    ax.set_title(f'Prime q = {q}: Distribution of M_{{q,1}}', fontsize=12)
    ax.set_xlabel(f'M_{{{q},1}}  (= ∏ gcd(dᵢ, {q}))', fontsize=10)
    ax.set_ylabel('Density', fontsize=10)
    ax.legend(fontsize=9, framealpha=0.9)
    ax.set_xlim(left=0)

    # Bottom: Convergence
    ax2 = axes[1, col]
    markers = ['o', 's']
    line_colors = ['#1565C0', '#C62828']
    for kidx, k in enumerate([1, 2]):
        means = conv_data[q][k]
        cl_k = cl_expected_moment(q, k)
        ax2.plot(n_values_conv, means, markers[kidx] + '-',
                 color=line_colors[kidx], markersize=6, linewidth=1.5,
                 label=f'k={k}: empirical', alpha=0.9)
        ax2.axhline(cl_k, color=line_colors[kidx], linestyle='--',
                    linewidth=1.5, alpha=0.6,
                    label=f'k={k}: CL = {cl_k:.3f}')

    ax2.set_title(f'q = {q}: Convergence of E[M_{{q,k}}]', fontsize=12)
    ax2.set_xlabel('Graph size n', fontsize=10)
    ax2.set_ylabel(f'E[M_{{{q},k}}]', fontsize=10)
    ax2.legend(fontsize=9, framealpha=0.9)

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('viz_jacobian_statistics.png', dpi=150, bbox_inches='tight')
print("Saved: viz_jacobian_statistics.png")


"""
Visualization: Moment Convergence Curves

This script visualizes the convergence of prime-power moments E[M_{q,k}]
to Cohen–Lenstra predictions as graph size n → ∞, for multiple edge
probabilities p. This directly tests the CL-ER conjecture.

The x-axis is graph size n, the y-axis is the ratio E_empirical / E_CL.
Convergence to 1.0 supports the conjecture.

SELF-CONTAINED: All algorithms are inlined (no local imports).
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import gcd


# Inlined algorithms
def graph_laplacian(adj):
    return np.diag(adj.sum(axis=1)) - adj

def reduced_laplacian(L, v=0):
    idx = [i for i in range(L.shape[0]) if i != v]
    return L[np.ix_(idx, idx)]

def smith_normal_form(M):
    M = M.copy().astype(int)
    n, m = M.shape; r = min(n, m)
    for col in range(r):
        pf = False
        for i in range(col, n):
            for j in range(col, m):
                if M[i,j] != 0:
                    M[[col,i]] = M[[i,col]]; M[:,[col,j]] = M[:,[j,col]]
                    pf = True; break
            if pf: break
        if not pf: break
        ch = True
        while ch:
            ch = False
            if M[col,col] < 0: M[col] = -M[col]
            for i in range(col+1, n):
                if M[i,col] != 0:
                    q = M[i,col]//M[col,col]; M[i] -= q*M[col]
                    if M[i,col] != 0:
                        if abs(M[i,col]) < abs(M[col,col]): M[[col,i]] = M[[i,col]]
                        ch = True
            for j in range(col+1, m):
                if M[col,j] != 0:
                    q = M[col,j]//M[col,col]; M[:,j] -= q*M[:,col]
                    if M[col,j] != 0:
                        if abs(M[col,j]) < abs(M[col,col]): M[:,[col,j]] = M[:,[j,col]]
                        ch = True
            for i in range(col+1, n):
                brk = False
                for j in range(col+1, m):
                    if M[i,j] % M[col,col] != 0:
                        M[i] += M[col]; ch = True; brk = True; break
                if brk: break
    return [abs(int(M[i,i])) for i in range(r) if M[i,i] != 0]

def jacobian_factors(adj):
    L = graph_laplacian(adj); Ls = reduced_laplacian(L)
    return sorted([f for f in smith_normal_form(Ls) if f > 1])

def erdos_renyi(n, p, rng):
    upper = np.zeros((n,n), dtype=int)
    for i in range(n):
        for j in range(i+1, n):
            if rng.random() < p: upper[i,j] = 1
    return upper + upper.T

def is_connected(adj):
    n = adj.shape[0]; vis = {0}; queue = [0]
    while queue:
        v = queue.pop(0)
        for u in range(n):
            if adj[v,u] and u not in vis: vis.add(u); queue.append(u)
    return len(vis) == n

def prime_power_moment(factors, q, k):
    qk = q**k; r = 1
    for d in factors: r *= gcd(d, qk)
    return r

def cl_expected_moment(q, k):
    r = 1.0
    for j in range(1, k+1): r *= q**j / (q**j - 1)
    return r


# ============================================================
# Data collection
# ============================================================

n_values = [6, 8, 10, 12, 15, 18, 22, 26, 30]
p_values = [0.3, 0.5, 0.7]
primes = [2, 3, 5]
num_samples = 150

# ratios[p_val][q][k] = list of ratios (one per n)
ratios = {p_val: {q: {k: [] for k in [1, 2, 3]}
          for q in primes} for p_val in p_values}

for p_val in p_values:
    rng = np.random.default_rng(42)
    for n in n_values:
        moment_sums = {q: {k: [] for k in [1, 2, 3]} for q in primes}
        collected = 0
        for _ in range(num_samples * 10):
            A = erdos_renyi(n, p_val, rng)
            if not is_connected(A): continue
            fac = jacobian_factors(A)
            if not fac: fac = [1]
            for q in primes:
                for k in [1, 2, 3]:
                    moment_sums[q][k].append(prime_power_moment(fac, q, k))
            collected += 1
            if collected >= num_samples: break

        for q in primes:
            for k in [1, 2, 3]:
                data = moment_sums[q][k]
                cl = cl_expected_moment(q, k)
                ratio = np.mean(data) / cl if data and cl > 0 else 0
                ratios[p_val][q][k].append(ratio)


# ============================================================
# Plotting
# ============================================================

fig, axes = plt.subplots(3, 3, figsize=(16, 14))
fig.suptitle('Convergence of E[M_{q,k}] / E_{CL}[M_{q,k}] → 1\n'
             'Testing the Cohen–Lenstra Conjecture for Erdős–Rényi Graphs',
             fontsize=15, fontweight='bold', y=0.99)

p_colors = {'0.3': '#1976D2', '0.5': '#388E3C', '0.7': '#E64A19'}
p_markers = {'0.3': 'o', '0.5': 's', '0.7': '^'}

for row, q in enumerate(primes):
    for col, k in enumerate([1, 2, 3]):
        ax = axes[row, col]

        for p_val in p_values:
            data = ratios[p_val][q][k]
            pkey = str(p_val)
            ax.plot(n_values[:len(data)], data,
                    p_markers[pkey] + '-',
                    color=p_colors[pkey],
                    markersize=6, linewidth=1.5,
                    label=f'p = {p_val}', alpha=0.85)

        # Reference line at 1.0
        ax.axhline(1.0, color='red', linestyle='--', linewidth=2, alpha=0.5,
                   label='CL prediction')

        # Shaded region ±10%
        ax.axhspan(0.9, 1.1, alpha=0.08, color='green')

        ax.set_title(f'q = {q}, k = {k}', fontsize=12, fontweight='bold')
        ax.set_xlabel('Graph size n', fontsize=10)
        ax.set_ylabel('Ratio E[M] / E_CL[M]', fontsize=10)
        ax.legend(fontsize=8, loc='best')
        ax.set_ylim(0.3, 2.5)
        ax.grid(True, alpha=0.3)

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('viz_moment_convergence.png', dpi=150, bbox_inches='tight')
print("Saved: viz_moment_convergence.png")
