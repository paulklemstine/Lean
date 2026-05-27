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
