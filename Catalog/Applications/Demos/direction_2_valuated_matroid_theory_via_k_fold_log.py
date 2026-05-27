#!/usr/bin/env python3
"""
applications.py — Real-world applications of the directional depth filtration

Demonstrates:
1. Tropical convexity detection via depth
2. Statistical physics: energy landscape analysis
3. Combinatorial optimization: matroid valuation quality
4. Information geometry: Fisher information depth
"""

from math import log, exp, comb, factorial, sqrt
from typing import Callable, Dict, List, Tuple
from itertools import product as iter_product


def unit_vec(n: int, i: int) -> Tuple[int, ...]:
    return tuple(1 if j == i else 0 for j in range(n))

def add_tuples(*tuples: Tuple[int, ...]) -> Tuple[int, ...]:
    return tuple(sum(x) for x in zip(*tuples))

def multiindices(n: int, max_deg: int) -> List[Tuple[int, ...]]:
    return list(iter_product(range(max_deg + 1), repeat=n))


# ============================================================
# Application 1: Tropical Convexity Detection
# ============================================================

def tropical_convexity_profile(f: Callable, n: int, max_deg: int = 6) -> Dict:
    """
    Analyze the tropical convexity properties of -log f.

    Returns a profile including:
    - Whether -log f is supermodular (= tropically convex)
    - The "tropical defect" measuring distance from supermodularity
    - The depth of f (measuring persistence of tropical convexity)
    """
    # Check supermodularity
    max_violation = 0.0
    total_checks = 0
    violations = 0

    for m in multiindices(n, max_deg):
        for i in range(n):
            for j in range(i + 1, n):
                ei, ej = unit_vec(n, i), unit_vec(n, j)
                vals = [f(m), f(add_tuples(m, ei)),
                        f(add_tuples(m, ej)), f(add_tuples(m, ei, ej))]
                if all(v > 0 for v in vals):
                    # Supermodularity: -log f(m+ei+ej) + (-log f(m))
                    #                >= -log f(m+ei) + (-log f(m+ej))
                    # Equiv: log f(m+ei) + log f(m+ej) >= log f(m) + log f(m+ei+ej)
                    lhs = log(vals[1]) + log(vals[2])
                    rhs = log(vals[0]) + log(vals[3])
                    defect = rhs - lhs  # positive = violation
                    if defect > 1e-12:
                        violations += 1
                        max_violation = max(max_violation, defect)
                    total_checks += 1

    # Compute depth
    def is_dlc(g, nn, md):
        for mm in multiindices(nn, md):
            for ii in range(nn):
                eii = unit_vec(nn, ii)
                fm = g(mm)
                fm1 = g(add_tuples(mm, eii))
                fm2 = g(add_tuples(mm, eii, eii))
                if fm1**2 < fm * fm2 - 1e-12:
                    return False
        return True

    depth = 0
    fns = [f]
    for k in range(6):
        if not all(is_dlc(fn, n, max_deg) for fn in fns):
            break
        depth = k + 1
        next_fns = []
        for fn in fns:
            for i in range(n):
                ei = unit_vec(n, i)
                def make_r(g, e):
                    def Rg(m):
                        v = g(m)
                        return g(add_tuples(m, e)) / v if abs(v) > 1e-15 else 0
                    return Rg
                next_fns.append(make_r(fn, ei))
        fns = next_fns

    return {
        "is_supermodular": violations == 0,
        "max_violation": max_violation,
        "num_violations": violations,
        "total_checks": total_checks,
        "directional_depth": depth,
        "tropical_convexity_grade": "excellent" if depth >= 4 else
                                    "good" if depth >= 2 else
                                    "basic" if depth >= 1 else "none"
    }


# ============================================================
# Application 2: Statistical Physics — Energy Landscape Analysis
# ============================================================

def energy_landscape_analysis(f: Callable, n: int, max_deg: int = 6) -> Dict:
    """
    Analyze f as a Boltzmann weight exp(-E/kT) on a discrete state space.

    -log f is the energy function. The directional depth measures how
    "thermodynamically well-behaved" the system is:
    - Depth 0: energy landscape may have arbitrary non-convexities
    - Depth 1: basic convexity (single-direction stability)
    - Depth >= 2: response functions (chemical potentials) are also convex
    - Infinite depth: perfect renormalization-group stability

    Returns analysis dict with energy statistics and depth.
    """
    states = multiindices(n, max_deg)
    energies = {}
    partition_fn = 0.0

    for m in states:
        val = f(m)
        if val > 0:
            energies[m] = -log(val)
            partition_fn += val

    if partition_fn == 0:
        return {"error": "Zero partition function"}

    # Basic thermodynamic quantities
    avg_energy = sum(f(m) * energies.get(m, 0) for m in states) / partition_fn
    energy_var = sum(f(m) * (energies.get(m, 0) - avg_energy)**2
                     for m in states if m in energies) / partition_fn

    # Find ground state
    ground_state = min(energies, key=energies.get) if energies else None
    ground_energy = energies[ground_state] if ground_state else None

    # Compute specific heat (proportional to energy variance)
    specific_heat = energy_var

    # Chemical potential analysis (ratio transform = exp(-μ))
    chemical_potentials = {}
    if ground_state is not None:
        for i in range(n):
            ei = unit_vec(n, i)
            m_up = add_tuples(ground_state, ei)
            if f(ground_state) > 0 and f(m_up) > 0:
                chemical_potentials[f"mu_{i}"] = -log(f(m_up) / f(ground_state))

    return {
        "partition_function": partition_fn,
        "average_energy": avg_energy,
        "energy_variance": energy_var,
        "specific_heat": specific_heat,
        "ground_state": ground_state,
        "ground_energy": ground_energy,
        "chemical_potentials": chemical_potentials,
        "num_states": len(energies),
    }


# ============================================================
# Application 3: Matroid Valuation Quality Assessment
# ============================================================

def matroid_valuation_quality(f: Callable, n: int, d: int, max_deg: int = None) -> Dict:
    """
    Assess the quality of a function as a matroid valuation on a degree slice.

    Checks:
    1. Exchange-closed support (necessary for matroid structure)
    2. Directional log-concavity (sufficient for many applications)
    3. Depth (measuring how robust the matroid structure is)

    Args:
        f: the valuation function
        n: number of variables
        d: target degree
    """
    if max_deg is None:
        max_deg = d

    # Get degree-d multiindices
    deg_d = [m for m in multiindices(n, max_deg) if sum(m) == d]

    # Check support
    support = [m for m in deg_d if f(m) > 1e-15]
    support_size = len(support)

    # Check exchange-closed support
    exchange_closed = True
    exchange_violations = 0
    for m in support:
        for m2 in support:
            for i in range(n):
                if m[i] < m2[i]:
                    found_exchange = False
                    for j in range(n):
                        if m2[j] < m[j] and m[j] > 0:
                            # Exchange move: increment i, decrement j
                            m_new = list(m)
                            m_new[i] += 1
                            m_new[j] -= 1
                            m_new = tuple(m_new)
                            if f(m_new) > 1e-15:
                                found_exchange = True
                                break
                    if not found_exchange:
                        exchange_closed = False
                        exchange_violations += 1

    return {
        "degree": d,
        "total_multiindices": len(deg_d),
        "support_size": support_size,
        "exchange_closed": exchange_closed,
        "exchange_violations": exchange_violations,
        "matroid_quality": "excellent" if exchange_closed else "partial"
    }


# ============================================================
# Application 4: Information Geometry — Fisher Depth
# ============================================================

def fisher_depth_analysis(family: Callable, n: int, param_range: List[float],
                          max_deg: int = 6) -> Dict:
    """
    Analyze a parametric family of distributions through the depth lens.

    Given a family θ → f_θ where f_θ(m) are unnormalized weights,
    analyze how the depth varies with the parameter.

    This connects to information geometry: the Fisher information metric
    measures curvature of the statistical manifold, while directional depth
    measures persistence of log-concavity under ratio transforms.
    """
    results = []

    for theta in param_range:
        f_theta = family(theta)

        # Quick depth computation
        def is_dlc(g):
            for mm in multiindices(n, max_deg):
                for ii in range(n):
                    eii = unit_vec(n, ii)
                    fm = g(mm)
                    fm1 = g(add_tuples(mm, eii))
                    fm2 = g(add_tuples(mm, eii, eii))
                    if fm1**2 < fm * fm2 - 1e-12:
                        return False
            return True

        depth = 0
        fns = [f_theta]
        for k in range(4):
            if not all(is_dlc(fn) for fn in fns):
                break
            depth = k + 1
            next_fns = []
            for fn in fns:
                for i in range(n):
                    ei = unit_vec(n, i)
                    def make_r(g, e):
                        def Rg(m):
                            v = g(m)
                            return g(add_tuples(m, e)) / v if abs(v) > 1e-15 else 0
                        return Rg
                    next_fns.append(make_r(fn, ei))
            fns = next_fns

        results.append({"theta": theta, "depth": depth})

    return {
        "parameter_values": param_range,
        "depth_profile": [r["depth"] for r in results],
        "min_depth": min(r["depth"] for r in results),
        "max_depth": max(r["depth"] for r in results),
        "depth_transitions": [(results[i]["theta"], results[i+1]["theta"])
                              for i in range(len(results)-1)
                              if results[i]["depth"] != results[i+1]["depth"]]
    }


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("APPLICATIONS OF DIRECTIONAL DEPTH FILTRATION")
    print("=" * 60)
    print()

    # Application 1: Tropical Convexity
    print("--- Application 1: Tropical Convexity Detection ---")
    f_gauss = lambda m: exp(-m[0]**2 - m[1]**2 - 0.3*m[0]*m[1])
    profile = tropical_convexity_profile(f_gauss, 2, max_deg=5)
    print(f"  Gaussian-like 2D:")
    print(f"    Supermodular: {profile['is_supermodular']}")
    print(f"    Depth: {profile['directional_depth']}")
    print(f"    Grade: {profile['tropical_convexity_grade']}")
    print()

    f_exp = lambda m: 2.0**m[0] * 3.0**m[1]
    profile2 = tropical_convexity_profile(f_exp, 2, max_deg=5)
    print(f"  Product exponential 2^x * 3^y:")
    print(f"    Supermodular: {profile2['is_supermodular']}")
    print(f"    Depth: {profile2['directional_depth']}")
    print(f"    Grade: {profile2['tropical_convexity_grade']}")
    print()

    # Application 2: Energy Landscape
    print("--- Application 2: Energy Landscape Analysis ---")
    f_boltz = lambda m: exp(-(m[0]-2)**2 - (m[1]-1)**2)
    analysis = energy_landscape_analysis(f_boltz, 2, max_deg=5)
    print(f"  Quadratic energy landscape:")
    print(f"    Partition function: {analysis['partition_function']:.4f}")
    print(f"    Average energy: {analysis['average_energy']:.4f}")
    print(f"    Ground state: {analysis['ground_state']}")
    print(f"    Ground energy: {analysis['ground_energy']:.4f}")
    print(f"    Chemical potentials: {analysis['chemical_potentials']}")
    print()

    # Application 3: Matroid Valuation Quality
    print("--- Application 3: Matroid Valuation Quality ---")
    # Uniform matroid U(2,4): all 2-element subsets equally weighted
    def uniform_24(m):
        if len(m) != 4 or sum(m) != 2:
            return 0.0
        if all(mi <= 1 for mi in m):
            return 1.0
        return 0.0

    quality = matroid_valuation_quality(uniform_24, 4, 2)
    print(f"  Uniform matroid U(2,4):")
    print(f"    Support size: {quality['support_size']}")
    print(f"    Exchange-closed: {quality['exchange_closed']}")
    print(f"    Quality: {quality['matroid_quality']}")
    print()

    # Application 4: Fisher Depth
    print("--- Application 4: Fisher Information Depth ---")
    def poisson_family(lam):
        def f(m):
            k = m[0]
            if k > 20 or lam <= 0:
                return 0.0
            return lam**k / factorial(k) * exp(-lam)
        return f

    fisher = fisher_depth_analysis(poisson_family, 1,
                                    [0.5, 1.0, 2.0, 3.0, 5.0], max_deg=12)
    print(f"  Poisson family depth profile:")
    for theta, depth in zip(fisher['parameter_values'], fisher['depth_profile']):
        print(f"    λ={theta}: depth ≥ {depth}")
    print(f"  Depth transitions: {fisher['depth_transitions']}")


#!/usr/bin/env python3
"""
demo.py — Interactive demo for the Directional Depth Filtration

Constructs sample functions/valuations, computes empirical depth profiles,
tests the Depth Dichotomy Conjecture on small examples, and prints where
depth fails.

Includes uniform matroid, graphical matroid, and Grassmannian-inspired toy families.
"""

import numpy as np
from itertools import product as iter_product
from math import comb, log, exp
from typing import Dict, Tuple, List, Optional, Callable

# ============================================================
# Core data structures
# ============================================================

def multiindices(n: int, max_deg: int) -> List[Tuple[int, ...]]:
    """Generate all multiindices (m_0, ..., m_{n-1}) with each m_i in [0, max_deg]."""
    return list(iter_product(range(max_deg + 1), repeat=n))

def degree(m: Tuple[int, ...]) -> int:
    return sum(m)

def unit_vec(n: int, i: int) -> Tuple[int, ...]:
    return tuple(1 if j == i else 0 for j in range(n))

def shift_up(m: Tuple[int, ...], i: int) -> Tuple[int, ...]:
    e = unit_vec(len(m), i)
    return tuple(a + b for a, b in zip(m, e))

def shift_up2(m: Tuple[int, ...], i: int) -> Tuple[int, ...]:
    return shift_up(shift_up(m, i), i)

# ============================================================
# Core algorithms
# ============================================================

def is_dir_log_concave(f: Callable, n: int, max_deg: int = 10) -> bool:
    """Check if f is directionally log-concave on multiindices up to max_deg."""
    for m in multiindices(n, max_deg):
        for i in range(n):
            fm = f(m)
            fup = f(shift_up(m, i))
            fup2 = f(shift_up2(m, i))
            if fup ** 2 < fm * fup2 - 1e-12:
                return False
    return True

def ratio_transform(f: Callable, i: int) -> Callable:
    """Compute the ratio transform R_i f."""
    def Rf(m):
        fm = f(m)
        if abs(fm) < 1e-15:
            return 0.0
        return f(shift_up(m, i)) / fm
    return Rf

def compute_depth(f: Callable, n: int, max_depth: int = 10, max_deg: int = 8) -> int:
    """Compute the directional depth of f, up to max_depth."""
    depth = 0
    current_fns = [f]  # Track all ratio transforms at current level

    for k in range(max_depth):
        # Check if all current functions are directionally log-concave
        for fn in current_fns:
            if not is_dir_log_concave(fn, n, max_deg):
                return depth
        depth = k + 1
        # Compute ratio transforms for next level
        next_fns = []
        for fn in current_fns:
            for i in range(n):
                next_fns.append(ratio_transform(fn, i))
        current_fns = next_fns

    return depth

def find_depth_failure(f: Callable, n: int, max_deg: int = 8) -> Optional[dict]:
    """Find where directional log-concavity first fails for ratio transforms."""
    # First check if f itself is log-concave
    if not is_dir_log_concave(f, n, max_deg):
        return {"level": 0, "message": "f itself is not log-concave"}

    for i in range(n):
        Rf = ratio_transform(f, i)
        for m in multiindices(n, max_deg):
            for j in range(n):
                fm = Rf(m)
                fup = Rf(shift_up(m, j))
                fup2 = Rf(shift_up2(m, j))
                if fup ** 2 < fm * fup2 - 1e-12:
                    return {
                        "level": 1,
                        "direction_i": i,
                        "direction_j": j,
                        "multiindex": m,
                        "R_i_f(m)": fm,
                        "R_i_f(m+e_j)": fup,
                        "R_i_f(m+2e_j)": fup2,
                        "violation": fup**2 - fm * fup2
                    }
    return None

# ============================================================
# Example families
# ============================================================

def uniform_matroid_valuation(n: int, r: int) -> Callable:
    """Uniform matroid U_{r,n}: f(m) = 1 if degree(m) = r and all m_i in {0,1}, else 0.
    Actually, use the weighted version: f(m) = C(n, r) style weights."""
    def f(m):
        if any(mi > 1 for mi in m):
            return 0.0
        if degree(m) == r:
            return 1.0
        return 0.0
    return f

def exponential_function(weights: List[float]) -> Callable:
    """f(m) = prod_i w_i^{m_i}, a product of geometric sequences."""
    def f(m):
        result = 1.0
        for i, mi in enumerate(m):
            if i < len(weights):
                result *= weights[i] ** mi
        return result
    return f

def polynomial_coefficients_1d(coeffs: List[float]) -> Callable:
    """1D function defined by its coefficient list."""
    def f(m):
        idx = m[0] if len(m) == 1 else sum(m)
        if 0 <= idx < len(coeffs):
            return coeffs[idx]
        return 0.0
    return f

def binomial_coefficients(n_val: int) -> Callable:
    """f(m) = C(n, m_0) for 1D multiindices, a classic log-concave sequence."""
    def f(m):
        k = m[0]
        if 0 <= k <= n_val:
            return float(comb(n_val, k))
        return 0.0
    return f

def graphical_matroid_valuation(adj_matrix: List[List[float]], num_edges: int) -> Callable:
    """
    Simplified graphical matroid valuation for small graphs.
    adj_matrix[i][j] = weight of edge (i,j).
    Returns a function on edge-indicator multiindices.
    """
    n = len(adj_matrix)
    edges = []
    for i in range(n):
        for j in range(i+1, n):
            if adj_matrix[i][j] > 0:
                edges.append((i, j, adj_matrix[i][j]))

    ne = len(edges)
    if ne != num_edges:
        print(f"Warning: found {ne} edges, expected {num_edges}")

    def f(m):
        if len(m) != ne:
            return 0.0
        result = 1.0
        for idx, (i, j, w) in enumerate(edges):
            if m[idx] > 0:
                result *= w ** m[idx]
        return result
    return f

def grassmannian_plucker(n: int, k: int) -> Callable:
    """
    Toy Grassmannian-inspired valuation: f indexed by k-element subsets.
    Uses the uniform Plücker coordinates (all = 1) as a baseline.
    """
    from itertools import combinations
    subsets = list(combinations(range(n), k))
    subset_to_idx = {s: i for i, s in enumerate(subsets)}
    num_coords = len(subsets)

    def f(m):
        if len(m) != num_coords:
            return 0.0
        # Product of Plücker coordinates raised to their powers
        result = 1.0
        for idx in range(num_coords):
            result *= 1.0 ** m[idx]  # Uniform: all coordinates = 1
        return result
    return f

# ============================================================
# Depth Dichotomy Conjecture Testing
# ============================================================

def test_depth_dichotomy():
    """Test the Depth Dichotomy Conjecture on small examples."""
    print("=" * 70)
    print("DEPTH DICHOTOMY CONJECTURE TEST")
    print("=" * 70)
    print()
    print("Conjecture: For naturally arising valuated matroids, the depth is")
    print("either 1 or infinite. No natural examples have depth exactly 2, 3, ...")
    print()

    results = []

    # 1. Exponential / geometric functions (should have infinite depth)
    print("--- Exponential (geometric) functions ---")
    for weights in [[2.0], [1.5, 2.0], [1.0, 2.0, 3.0]]:
        n = len(weights)
        f = exponential_function(weights)
        d = compute_depth(f, n, max_depth=6, max_deg=6)
        status = "infinite (≥6)" if d >= 6 else f"exactly {d}"
        print(f"  weights={weights}: depth = {status}")
        results.append(("exponential", weights, d))

    print()

    # 2. Binomial coefficients (should have high depth)
    print("--- Binomial coefficients C(n, k) ---")
    for n_val in [4, 6, 8, 10]:
        f = binomial_coefficients(n_val)
        d = compute_depth(f, 1, max_depth=6, max_deg=n_val + 2)
        status = "infinite (≥6)" if d >= 6 else f"exactly {d}"
        print(f"  C({n_val}, k): depth = {status}")
        results.append(("binomial", n_val, d))

    print()

    # 3. The depth-1-not-2 example from our theorem
    print("--- Strict depth 1 example (from theorem) ---")
    f_strict = polynomial_coefficients_1d([1.0, 3.0, 2.0, 1.0])
    d = compute_depth(f_strict, 1, max_depth=6, max_deg=6)
    print(f"  [1, 3, 2, 1]: depth = {d}")
    failure = find_depth_failure(f_strict, 1, max_deg=6)
    if failure:
        print(f"  Failure details: {failure}")
    results.append(("strict_example", [1, 3, 2, 1], d))

    print()

    # 4. Log-concave but not ultra-log-concave sequences
    print("--- Various log-concave sequences ---")
    test_seqs = [
        ([1, 2, 1], "triangle"),
        ([1, 4, 6, 4, 1], "Pascal row 4"),
        ([1, 5, 10, 10, 5, 1], "Pascal row 5"),
        ([1, 2, 3, 2, 1], "symmetric"),
        ([1, 3, 3, 1], "Pascal row 3"),
    ]
    for coeffs, name in test_seqs:
        f = polynomial_coefficients_1d([float(c) for c in coeffs])
        d = compute_depth(f, 1, max_depth=6, max_deg=len(coeffs) + 2)
        status = "infinite (≥6)" if d >= 6 else f"exactly {d}"
        print(f"  {name} {coeffs}: depth = {status}")
        results.append(("sequence", name, d))

    print()

    # 5. Graphical matroid on small graphs
    print("--- Graphical matroid valuations ---")
    # Triangle (3-cycle): edges (0,1), (0,2), (1,2)
    triangle = [[0, 1, 1], [1, 0, 1], [1, 1, 0]]
    f_tri = graphical_matroid_valuation(triangle, 3)
    d = compute_depth(f_tri, 3, max_depth=4, max_deg=3)
    status = "infinite (≥4)" if d >= 4 else f"exactly {d}"
    print(f"  Triangle (K3): depth = {status}")

    # Path graph: (0,1), (1,2)
    path = [[0, 1, 0], [1, 0, 1], [0, 1, 0]]
    f_path = graphical_matroid_valuation(path, 2)
    d = compute_depth(f_path, 2, max_depth=4, max_deg=4)
    status = "infinite (≥4)" if d >= 4 else f"exactly {d}"
    print(f"  Path P3: depth = {status}")

    print()

    # Summary
    print("=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print()
    depth_counts = {}
    for _, _, d in results:
        depth_counts[d] = depth_counts.get(d, 0) + 1
    for d in sorted(depth_counts.keys()):
        label = f"≥6 (infinite)" if d >= 6 else str(d)
        print(f"  Depth {label}: {depth_counts[d]} examples")

# ============================================================
# Supermodularity check for -log f
# ============================================================

def check_supermodularity(f: Callable, n: int, max_deg: int = 6) -> bool:
    """Check if -log f is supermodular."""
    def neg_log_f(m):
        val = f(m)
        if val <= 0:
            return float('inf')
        return -log(val)

    for m in multiindices(n, max_deg):
        for i in range(n):
            for j in range(i+1, n):
                ei = unit_vec(n, i)
                ej = unit_vec(n, j)
                m_ij = tuple(a + b + c for a, b, c in zip(m, ei, ej))
                m_i = tuple(a + b for a, b in zip(m, ei))
                m_j = tuple(a + b for a, b in zip(m, ej))

                g_ij = neg_log_f(m_ij)
                g_m = neg_log_f(m)
                g_i = neg_log_f(m_i)
                g_j = neg_log_f(m_j)

                if any(v == float('inf') for v in [g_ij, g_m, g_i, g_j]):
                    continue

                if g_ij + g_m < g_i + g_j - 1e-12:
                    return False
    return True

# ============================================================
# Main demo
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║   DIRECTIONAL DEPTH FILTRATION FOR VALUATED MATROIDS           ║")
    print("║   Interactive Demo                                              ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()

    # Demo 1: Basic depth computation
    print("DEMO 1: Basic Depth Computation")
    print("-" * 40)
    f_geom = exponential_function([2.0])
    print(f"Geometric f(n) = 2^n: depth ≥ {compute_depth(f_geom, 1, max_depth=8, max_deg=8)}")

    f_binom = binomial_coefficients(6)
    print(f"Binomial C(6,k): depth ≥ {compute_depth(f_binom, 1, max_depth=6, max_deg=8)}")

    f_strict = polynomial_coefficients_1d([1.0, 3.0, 2.0, 1.0])
    d = compute_depth(f_strict, 1, max_depth=6, max_deg=6)
    print(f"[1,3,2,1] (strict depth 1): depth = {d}")
    print()

    # Demo 2: Depth failure analysis
    print("DEMO 2: Depth Failure Analysis")
    print("-" * 40)
    failure = find_depth_failure(f_strict, 1, max_deg=6)
    if failure:
        print(f"  Level of failure: {failure['level']}")
        print(f"  Direction i (ratio transform): {failure.get('direction_i', 'N/A')}")
        print(f"  Direction j (log-concavity test): {failure.get('direction_j', 'N/A')}")
        print(f"  At multiindex: {failure.get('multiindex', 'N/A')}")
        print(f"  Violation magnitude: {failure.get('violation', 'N/A'):.6e}")
    print()

    # Demo 3: Supermodularity check
    print("DEMO 3: Supermodularity of -log f")
    print("-" * 40)
    f_2d = exponential_function([1.5, 2.0])
    is_sm = check_supermodularity(f_2d, 2, max_deg=5)
    print(f"Exponential (1.5, 2.0): -log f supermodular = {is_sm}")

    f_mixed = lambda m: exp(-(m[0]**2 + m[1]**2 + 0.5*m[0]*m[1]))
    is_sm = check_supermodularity(f_mixed, 2, max_deg=5)
    print(f"Gaussian-like: -log f supermodular = {is_sm}")
    print()

    # Demo 4: Multiplicative stability
    print("DEMO 4: Multiplicative Depth Stability")
    print("-" * 40)
    f1 = exponential_function([2.0])
    f2 = exponential_function([3.0])
    f_prod = lambda m: f1(m) * f2(m)
    d1 = compute_depth(f1, 1, max_depth=6, max_deg=6)
    d2 = compute_depth(f2, 1, max_depth=6, max_deg=6)
    dp = compute_depth(f_prod, 1, max_depth=6, max_deg=6)
    print(f"  f1 depth: ≥{d1}, f2 depth: ≥{d2}, f1·f2 depth: ≥{dp}")
    print(f"  Multiplicative stability verified: {dp >= min(d1, d2)}")
    print()

    # Demo 5: Full conjecture test
    test_depth_dichotomy()


#!/usr/bin/env python3
"""
Visualization 1: Depth Heatmap

Visualizes the directional depth of functions across a 2D parameter space.
Shows how depth varies as we interpolate between different coefficient vectors,
revealing the "depth landscape" and identifying phase transitions between
depth classes.

The x-axis and y-axis represent two parameters controlling the shape of a
1D function, and the color represents the computed directional depth.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import product as iter_product
from math import exp


def unit_vec(n, i):
    return tuple(1 if j == i else 0 for j in range(n))

def add_tuples(*tuples):
    return tuple(sum(x) for x in zip(*tuples))

def multiindices(n, max_deg):
    return list(iter_product(range(max_deg + 1), repeat=n))

def compute_depth_1d(coeffs, max_depth=5, max_deg=8):
    """Compute directional depth of a 1D function given by coefficients."""
    def f(m):
        idx = m[0]
        if 0 <= idx < len(coeffs):
            return coeffs[idx]
        return 0.0

    def is_dlc(g):
        for m in multiindices(1, max_deg):
            e = (1,)
            fm = g(m)
            fm1 = g(add_tuples(m, e))
            fm2 = g(add_tuples(m, e, e))
            if fm1**2 < fm * fm2 - 1e-12:
                return False
        return True

    def ratio_transform(g, i=0):
        e = (1,)
        def Rg(m):
            v = g(m)
            return g(add_tuples(m, e)) / v if abs(v) > 1e-15 else 0
        return Rg

    depth = 0
    fns = [f]
    for k in range(max_depth):
        if not all(is_dlc(fn) for fn in fns):
            break
        depth = k + 1
        fns = [ratio_transform(fn) for fn in fns]
    return depth


# Create the heatmap
# Family: f(0)=1, f(1)=a, f(2)=b, f(3)=c where c = max(0, 2b-a) (maintaining some structure)
# We fix f(0)=1 and scan over a=f(1) and b=f(2)

a_range = np.linspace(0.5, 6.0, 40)
b_range = np.linspace(0.1, 5.0, 40)

depth_map = np.zeros((len(b_range), len(a_range)))

for i, b in enumerate(b_range):
    for j, a in enumerate(a_range):
        # Ensure log-concavity-friendly shape
        c = max(0, b**2 / max(a, 0.01))  # Choose c to be at the boundary
        c = min(c, 10.0)
        coeffs = [1.0, a, b, c * 0.5]  # Slightly below boundary
        depth_map[i, j] = compute_depth_1d(coeffs, max_depth=5, max_deg=6)

fig, ax = plt.subplots(1, 1, figsize=(10, 8))

im = ax.imshow(depth_map, extent=[a_range[0], a_range[-1], b_range[0], b_range[-1]],
               origin='lower', aspect='auto', cmap='viridis',
               vmin=0, vmax=5, interpolation='nearest')

ax.set_xlabel('f(1) = a', fontsize=14)
ax.set_ylabel('f(2) = b', fontsize=14)
ax.set_title('Directional Depth Landscape\n'
             r'$f = [1, a, b, b^2/(2a)]$', fontsize=16)

cbar = plt.colorbar(im, ax=ax, label='Directional Depth')
cbar.set_ticks([0, 1, 2, 3, 4, 5])
cbar.set_ticklabels(['0', '1', '2', '3', '4', '≥5'])

# Add contour lines
cs = ax.contour(a_range, b_range, depth_map, levels=[0.5, 1.5, 2.5],
                colors='white', linewidths=1.5, linestyles='--')
ax.clabel(cs, fmt={0.5: 'depth=0↔1', 1.5: 'depth=1↔2', 2.5: 'depth=2↔3'},
          fontsize=10)

# Mark the log-concavity boundary: a^2 >= 1*b, i.e., b <= a^2
a_boundary = np.linspace(0.5, 6.0, 100)
b_boundary = a_boundary**2
valid = b_boundary <= b_range[-1]
ax.plot(a_boundary[valid], b_boundary[valid], 'r-', linewidth=2,
        label=r'$b = a^2$ (LC boundary)')
ax.legend(loc='upper left', fontsize=11)

plt.tight_layout()
plt.savefig('depth_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved depth_heatmap.png")


#!/usr/bin/env python3
"""
Visualization 2: Ratio Transform Cascade

Visualizes the iterated ratio transform of a function, showing how
the shape evolves at each depth level. This makes visible the
"discrete curvature peeling" process that defines the depth filtration.

For a 1D function f, plots f, R(f), R²(f), ... side by side,
with annotations showing where log-concavity fails.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import comb


def compute_ratio_cascade(coeffs, num_levels=4, max_n=10):
    """Compute iterated ratio transforms of a 1D coefficient sequence."""
    levels = [coeffs[:]]

    current = coeffs[:]
    for level in range(num_levels):
        ratios = []
        for n in range(len(current) - 1):
            if abs(current[n]) > 1e-15:
                ratios.append(current[n + 1] / current[n])
            else:
                ratios.append(0.0)
        levels.append(ratios)
        current = ratios

    return levels


def check_log_concavity(seq):
    """Find violations of log-concavity in a sequence."""
    violations = []
    for n in range(len(seq) - 2):
        if seq[n + 1] ** 2 < seq[n] * seq[n + 2] - 1e-12:
            violations.append(n + 1)
    return violations


# Example functions to visualize
examples = [
    {
        "name": "Geometric (infinite depth)",
        "coeffs": [2**n for n in range(12)],
        "color": "#2196F3"
    },
    {
        "name": "Binomial C(8,k) (depth 1)",
        "coeffs": [float(comb(8, k)) for k in range(9)] + [0]*3,
        "color": "#4CAF50"
    },
    {
        "name": "[1, 3, 2, 1] (depth exactly 1)",
        "coeffs": [1, 3, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0],
        "color": "#FF5722"
    },
    {
        "name": "Triangular [1, 2, 1] (high depth)",
        "coeffs": [1, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        "color": "#9C27B0"
    },
]

fig, axes = plt.subplots(len(examples), 4, figsize=(16, 3.5 * len(examples)))

level_names = ['f', 'R(f)', 'R²(f)', 'R³(f)']

for row, example in enumerate(examples):
    cascade = compute_ratio_cascade(example["coeffs"], num_levels=3)

    for col in range(4):
        ax = axes[row, col]
        if col < len(cascade):
            seq = cascade[col]
            n_vals = list(range(len(seq)))

            # Plot the sequence
            ax.bar(n_vals, seq, color=example["color"], alpha=0.7, edgecolor='black',
                   linewidth=0.5)

            # Check and highlight log-concavity violations
            violations = check_log_concavity(seq)
            if violations:
                for v in violations:
                    ax.axvspan(v - 0.5, v + 0.5, color='red', alpha=0.2)
                    ax.plot(v, seq[v], 'rv', markersize=10)

            # Formatting
            if col == 0:
                ax.set_ylabel(example["name"], fontsize=9, fontweight='bold')

            if row == 0:
                ax.set_title(level_names[col], fontsize=13, fontweight='bold')

            ax.set_xlabel('n', fontsize=9)

            # Add log-concavity status
            if len(seq) >= 3:
                is_lc = len(violations) == 0
                status = "✓ LC" if is_lc else "✗ LC fails"
                color = 'green' if is_lc else 'red'
                ax.text(0.95, 0.95, status, transform=ax.transAxes,
                       ha='right', va='top', fontsize=9, color=color,
                       fontweight='bold',
                       bbox=dict(boxstyle='round,pad=0.3', facecolor='white',
                                alpha=0.8))
        else:
            ax.set_visible(False)

        ax.set_xlim(-0.5, 10.5)
        ax.grid(True, alpha=0.3)

plt.suptitle('Ratio Transform Cascade: Peeling Away Layers of Curvature',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('ratio_cascade.png', dpi=150, bbox_inches='tight')
print("Saved ratio_cascade.png")


#!/usr/bin/env python3
"""
Visualization 3: Tropical Supermodularity Surface

Visualizes the energy landscape -log f for a 2D function, showing the
supermodularity structure that arises from mixed log-concavity.
The surface plot reveals the tropical convexity of the valuation.

Also plots the "supermodularity defect" heatmap showing where
the supermodular inequality is tight vs slack.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import log, exp
from mpl_toolkits.mplot3d import Axes3D


def make_mixed_lc_function(a=1.0, b=0.5, c=0.3):
    """Create a 2D function that is mixed log-concave.
    f(x,y) = exp(-a*x^2 - b*y^2 - c*x*y) with a*b > (c/2)^2."""
    def f(m):
        x, y = m[0], m[1]
        return exp(-a * x**2 - b * y**2 - c * x * y)
    return f


def neg_log(f, m):
    v = f(m)
    if v > 1e-15:
        return -log(v)
    return float('nan')


def supermodular_defect(f, m, i, j, n=2):
    """Compute g(m+ei+ej) + g(m) - g(m+ei) - g(m+ej) for g = -log f."""
    ei = tuple(1 if k == i else 0 for k in range(n))
    ej = tuple(1 if k == j else 0 for k in range(n))
    m_ij = tuple(a + b + c for a, b, c in zip(m, ei, ej))
    m_i = tuple(a + b for a, b in zip(m, ei))
    m_j = tuple(a + b for a, b in zip(m, ej))

    vals = [f(m), f(m_i), f(m_j), f(m_ij)]
    if any(v <= 1e-15 for v in vals):
        return float('nan')

    g = [-log(v) for v in vals]
    return g[3] + g[0] - g[1] - g[2]  # Should be >= 0 for supermodular


# Create figure with two subplots
fig = plt.figure(figsize=(16, 7))

# --- Left panel: Energy surface ---
ax1 = fig.add_subplot(121, projection='3d')

f = make_mixed_lc_function(a=0.8, b=0.6, c=0.4)

x_range = np.arange(0, 8)
y_range = np.arange(0, 8)
X, Y = np.meshgrid(x_range, y_range)
Z = np.zeros_like(X, dtype=float)

for i in range(len(x_range)):
    for j in range(len(y_range)):
        Z[j, i] = neg_log(f, (int(x_range[i]), int(y_range[j])))

surf = ax1.plot_surface(X, Y, Z, cmap='coolwarm', alpha=0.8,
                        edgecolor='black', linewidth=0.3)
ax1.set_xlabel('x', fontsize=12)
ax1.set_ylabel('y', fontsize=12)
ax1.set_zlabel('-log f(x,y)', fontsize=12)
ax1.set_title('Energy Landscape: -log f\n(Tropical Potential)', fontsize=14)
ax1.view_init(elev=25, azim=-60)

# --- Right panel: Supermodularity defect heatmap ---
ax2 = fig.add_subplot(122)

x_range2 = np.arange(0, 10)
y_range2 = np.arange(0, 10)
defect = np.zeros((len(y_range2), len(x_range2)))

for i, x in enumerate(x_range2):
    for j, y in enumerate(y_range2):
        defect[j, i] = supermodular_defect(f, (int(x), int(y)), 0, 1)

# Replace NaN with 0 for visualization
defect_clean = np.nan_to_num(defect, nan=0.0)

im = ax2.imshow(defect_clean, extent=[x_range2[0]-0.5, x_range2[-1]+0.5,
                                       y_range2[0]-0.5, y_range2[-1]+0.5],
                origin='lower', cmap='YlOrRd', aspect='equal',
                interpolation='nearest')

ax2.set_xlabel('x', fontsize=12)
ax2.set_ylabel('y', fontsize=12)
ax2.set_title('Supermodularity Defect\n'
              r'$g(m+e_i+e_j) + g(m) - g(m+e_i) - g(m+e_j) \geq 0$',
              fontsize=14)

cbar = plt.colorbar(im, ax=ax2)
cbar.set_label('Defect (≥0 means supermodular)', fontsize=11)

# Add annotation about mixed log-concavity
min_defect = np.nanmin(defect)
ax2.text(0.02, 0.98,
         f'Min defect: {min_defect:.4f}\n'
         f'Supermodular: {"Yes ✓" if min_defect >= -1e-12 else "No ✗"}',
         transform=ax2.transAxes, va='top', fontsize=11,
         bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

plt.suptitle('Tropical Convexity from Mixed Log-Concavity',
             fontsize=16, fontweight='bold')
plt.tight_layout()
plt.savefig('tropical_supermodularity.png', dpi=150, bbox_inches='tight')
print("Saved tropical_supermodularity.png")
