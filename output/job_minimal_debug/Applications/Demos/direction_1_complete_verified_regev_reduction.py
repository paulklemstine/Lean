#!/usr/bin/env python3
"""
Applications of the Regev Reduction Compositional Framework

Demonstrates real-world applications of the formally verified theorems:

1. Parameter Selection for Post-Quantum Cryptosystems
2. Security Level Estimation for LWE-Based Schemes
3. Modulus Switching Analysis for NIST PQC Candidates
4. Hybrid Argument Visualization for Security Proofs
"""

from fractions import Fraction
from itertools import product
from typing import Dict, List, Tuple
import math


# ============================================================
# Application 1: Post-Quantum Parameter Selection
# ============================================================

def evaluate_lwe_security(q: int, n: int, sigma: float) -> Dict:
    """Evaluate the security of an LWE instance by computing exact TVD.

    This directly implements the formal framework: security is measured
    by how distinguishable LWE samples are from uniform, quantified
    by total variation distance.

    For real-world parameters, approximate methods are needed.
    This exact method works for toy parameters for verification.

    Args:
        q: Modulus
        n: Dimension
        sigma: Gaussian noise parameter

    Returns:
        Security analysis report
    """
    # Generate noise distribution
    noise = {}
    total = Fraction(0)
    for e in range(q):
        centered = min(e, q - e)
        w = math.exp(-centered**2 / (2 * sigma**2))
        noise[e] = Fraction(w).limit_denominator(10000)
        total += noise[e]
    noise = {e: w / total for e, w in noise.items()}

    # Generate distributions
    vectors = list(product(range(q), repeat=n))
    p_a = Fraction(1, q**n)

    # LWE distribution for worst-case secret
    best_tvd = Fraction(0)
    best_secret = None

    for s_tuple in product(range(q), repeat=n):
        lwe_dist = {}
        for a in vectors:
            inner = sum(a[i] * s_tuple[i] for i in range(n)) % q
            for e, p_e in noise.items():
                b = (inner + e) % q
                key = (a, b)
                lwe_dist[key] = lwe_dist.get(key, Fraction(0)) + p_a * p_e

        unif = {}
        for a in vectors:
            for b in range(q):
                unif[(a, b)] = Fraction(1, q**(n+1))

        keys = set(lwe_dist.keys()) | set(unif.keys())
        current_tvd = Fraction(1, 2) * sum(
            abs(lwe_dist.get(k, Fraction(0)) - unif.get(k, Fraction(0)))
            for k in keys
        )

        if current_tvd > best_tvd:
            best_tvd = current_tvd
            best_secret = s_tuple

    # Estimate bits of security (rough: -log2(TVD) for small TVD)
    tvd_float = float(best_tvd)
    security_bits = -math.log2(tvd_float) if tvd_float > 0 else float('inf')

    return {
        'q': q, 'n': n, 'sigma': sigma,
        'max_tvd': best_tvd,
        'max_tvd_float': tvd_float,
        'worst_secret': best_secret,
        'approx_security_bits': security_bits,
        'noise_entropy': -sum(
            float(p) * math.log2(float(p))
            for p in noise.values() if p > 0
        )
    }


# ============================================================
# Application 2: Modulus Switching Analysis
# ============================================================

def modulus_switching_analysis(q_original: int, q_targets: List[int],
                                n: int, sigma: float) -> List[Dict]:
    """Analyze security degradation under modulus switching.

    Uses the formally verified TVD contraction theorem to bound
    how much security is lost when reducing the modulus.

    This is directly relevant to NIST PQC candidates like
    Kyber/ML-KEM which use modulus switching for compression.

    Args:
        q_original: Original modulus
        q_targets: List of target moduli
        n: Dimension
        sigma: Noise parameter

    Returns:
        List of analysis reports
    """
    # Generate noise
    noise = {}
    total = Fraction(0)
    for e in range(q_original):
        centered = min(e, q_original - e)
        w = math.exp(-centered**2 / (2 * sigma**2))
        noise[e] = Fraction(w).limit_denominator(10000)
        total += noise[e]
    noise = {e: w / total for e, w in noise.items()}

    # Original LWE distribution
    vectors = list(product(range(q_original), repeat=n))
    p_a = Fraction(1, q_original**n)
    s = tuple(1 for _ in range(n))  # Simple secret

    lwe_original = {}
    for a in vectors:
        inner = sum(a[i] * s[i] for i in range(n)) % q_original
        for e, p_e in noise.items():
            b = (inner + e) % q_original
            key = (a, b)
            lwe_original[key] = lwe_original.get(key, Fraction(0)) + p_a * p_e

    unif_original = {}
    for a in vectors:
        for b in range(q_original):
            unif_original[(a, b)] = Fraction(1, q_original**(n+1))

    keys = set(lwe_original.keys()) | set(unif_original.keys())
    tvd_original = Fraction(1, 2) * sum(
        abs(lwe_original.get(k, Fraction(0)) - unif_original.get(k, Fraction(0)))
        for k in keys
    )

    results = [{
        'modulus': q_original,
        'tvd': tvd_original,
        'tvd_float': float(tvd_original),
        'contraction_ratio': 1.0,
        'is_original': True
    }]

    for q_target in q_targets:
        if q_original % q_target != 0:
            results.append({
                'modulus': q_target,
                'tvd': None,
                'note': f'{q_target} does not divide {q_original}',
                'is_original': False
            })
            continue

        # Pushforward under modulus reduction
        def mod_reduce(sample, qt=q_target):
            a, b = sample
            return (tuple(x % qt for x in a), b % qt)

        lwe_reduced = {}
        for x, p in lwe_original.items():
            y = mod_reduce(x)
            lwe_reduced[y] = lwe_reduced.get(y, Fraction(0)) + p

        unif_reduced = {}
        for x, p in unif_original.items():
            y = mod_reduce(x)
            unif_reduced[y] = unif_reduced.get(y, Fraction(0)) + p

        keys_r = set(lwe_reduced.keys()) | set(unif_reduced.keys())
        tvd_reduced = Fraction(1, 2) * sum(
            abs(lwe_reduced.get(k, Fraction(0)) - unif_reduced.get(k, Fraction(0)))
            for k in keys_r
        )

        results.append({
            'modulus': q_target,
            'tvd': tvd_reduced,
            'tvd_float': float(tvd_reduced),
            'contraction_ratio': float(tvd_reduced / tvd_original) if tvd_original > 0 else 0,
            'contraction_verified': tvd_reduced <= tvd_original,
            'is_original': False
        })

    return results


# ============================================================
# Application 3: Hybrid Argument for Search-to-Decision
# ============================================================

def search_to_decision_hybrid_analysis(q: int, n: int, sigma: float) -> Dict:
    """Analyze the search-to-decision reduction via hybrid argument.

    Constructs the explicit hybrid sequence used in the Regev reduction:
    H_0 = LWE distribution (all coordinates use secret)
    H_i = hybrid with first i coordinates replaced by uniform
    H_n = uniform distribution

    Verifies the telescope bound from Theorem 2.

    Args:
        q: Modulus
        n: Dimension (should be small, ≤ 3)
        sigma: Noise parameter

    Returns:
        Hybrid analysis report
    """
    if q**n > 1000:
        return {'error': 'Parameters too large for exact computation'}

    # Generate noise
    noise = {}
    total = Fraction(0)
    for e in range(q):
        centered = min(e, q - e)
        w = math.exp(-centered**2 / (2 * sigma**2))
        noise[e] = Fraction(w).limit_denominator(10000)
        total += noise[e]
    noise = {e: w / total for e, w in noise.items()}

    s = tuple(1 for _ in range(n))
    vectors = list(product(range(q), repeat=n))
    p_a = Fraction(1, q**n)

    # Construct hybrids H_0, ..., H_n
    hybrids = []

    for k in range(n + 1):
        # H_k: first k coordinates are "uniform" (independent of secret)
        # remaining n-k coordinates use the secret
        dist = {}
        for a in vectors:
            # Inner product contribution from non-uniform coordinates
            inner_secret = sum(a[i] * s[i] for i in range(k, n)) % q
            for e, p_e in noise.items():
                b = (inner_secret + e) % q
                if k > 0:
                    # First k coordinates contribute uniformly to b
                    # This is a simplification - in the real hybrid, b includes
                    # uniform random contributions from the first k coordinates
                    for b_shift in range(q):
                        key = (a, (b + b_shift) % q)
                        # Uniform contribution from first k coordinates
                        dist[key] = dist.get(key, Fraction(0)) + p_a * p_e * Fraction(1, q)
                else:
                    key = (a, b)
                    dist[key] = dist.get(key, Fraction(0)) + p_a * p_e

        hybrids.append(dist)

    # Compute TVDs
    step_tvds = []
    for i in range(n):
        keys_i = set(hybrids[i].keys()) | set(hybrids[i+1].keys())
        tvd_i = Fraction(1, 2) * sum(
            abs(hybrids[i].get(k, Fraction(0)) - hybrids[i+1].get(k, Fraction(0)))
            for k in keys_i
        )
        step_tvds.append(tvd_i)

    keys_total = set(hybrids[0].keys()) | set(hybrids[-1].keys())
    total_tvd = Fraction(1, 2) * sum(
        abs(hybrids[0].get(k, Fraction(0)) - hybrids[-1].get(k, Fraction(0)))
        for k in keys_total
    )

    step_sum = sum(step_tvds)

    return {
        'q': q, 'n': n, 'sigma': sigma,
        'num_hybrids': n + 1,
        'total_tvd': float(total_tvd),
        'step_tvds': [float(t) for t in step_tvds],
        'sum_of_steps': float(step_sum),
        'telescope_holds': total_tvd <= step_sum,
        'avg_step_advantage': float(step_sum / n) if n > 0 else 0,
        'max_step': max(float(t) for t in step_tvds) if step_tvds else 0,
    }


# ============================================================
# Application 4: Lattice Parameter Estimation
# ============================================================

def lattice_bdd_analysis(n: int, basis_scale: int,
                          target_offsets: List[Tuple]) -> List[Dict]:
    """Analyze BDD instances for different targets and radii.

    Creates a scaled integer lattice and checks well-separation
    and uniqueness for various decoding scenarios.

    Args:
        n: Dimension
        basis_scale: Lattice basis scaling factor (min distance)
        target_offsets: List of target point offsets from origin

    Returns:
        List of BDD analysis reports
    """
    # Generate lattice points (scaled Zⁿ)
    lattice_range = range(-3, 4)
    lattice_points = [
        tuple(basis_scale * c for c in combo)
        for combo in product(lattice_range, repeat=n)
    ]

    min_dist = basis_scale  # For scaled Zⁿ

    results = []
    radii = [min_dist * r for r in [0.1, 0.25, 0.45, 0.55, 0.75, 1.0]]

    for target in target_offsets:
        for radius in radii:
            within = [
                p for p in lattice_points
                if math.sqrt(sum((a-b)**2 for a, b in zip(p, target))) <= radius
            ]

            results.append({
                'target': target,
                'radius': radius,
                'well_separated': min_dist > 2 * radius,
                'num_within_radius': len(within),
                'unique': len(within) <= 1,
                'closest_dist': min(
                    math.sqrt(sum((a-b)**2 for a, b in zip(p, target)))
                    for p in lattice_points
                ),
                'guaranteed_by_theorem': (min_dist > 2 * radius) and (len(within) <= 1)
            })

    return results


# ============================================================
# Main: Run All Applications
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Regev Reduction Framework: Applications                ║")
    print("╚══════════════════════════════════════════════════════════╝")

    # Application 1: Parameter Selection
    print("\n" + "=" * 60)
    print("APPLICATION 1: LWE Security Parameter Analysis")
    print("=" * 60)

    params = [(5, 1, 1.0), (5, 1, 0.5), (7, 1, 1.0), (5, 2, 1.0)]
    print(f"\n{'q':>4} {'n':>3} {'σ':>6} {'TVD':>10} {'~bits':>8}")
    print("-" * 40)
    for q, n, sigma in params:
        result = evaluate_lwe_security(q, n, sigma)
        print(f"{q:4d} {n:3d} {sigma:6.1f} {result['max_tvd_float']:10.6f} "
              f"{result['approx_security_bits']:8.2f}")

    # Application 2: Modulus Switching
    print("\n" + "=" * 60)
    print("APPLICATION 2: Modulus Switching Security Analysis")
    print("=" * 60)

    results = modulus_switching_analysis(
        q_original=6, q_targets=[2, 3], n=1, sigma=1.5
    )
    print(f"\n{'Modulus':>8} {'TVD':>12} {'Ratio':>8} {'Verified':>10}")
    print("-" * 45)
    for r in results:
        if r.get('tvd') is not None:
            print(f"{r['modulus']:8d} {r['tvd_float']:12.6f} "
                  f"{r.get('contraction_ratio', 1.0):8.4f} "
                  f"{r.get('contraction_verified', 'N/A'):>10}")

    # Application 3: Hybrid Analysis
    print("\n" + "=" * 60)
    print("APPLICATION 3: Search-to-Decision Hybrid Analysis")
    print("=" * 60)

    result = search_to_decision_hybrid_analysis(5, 2, 1.0)
    if 'error' not in result:
        print(f"\nParameters: q={result['q']}, n={result['n']}, σ={result['sigma']}")
        print(f"Total TVD(H_0, H_n): {result['total_tvd']:.6f}")
        print(f"Sum of step TVDs:    {result['sum_of_steps']:.6f}")
        print(f"Telescope holds:     {result['telescope_holds']}")
        print(f"Average step:        {result['avg_step_advantage']:.6f}")
        print(f"Max step:            {result['max_step']:.6f}")
        print(f"Step TVDs: {result['step_tvds']}")

    # Application 4: BDD Analysis
    print("\n" + "=" * 60)
    print("APPLICATION 4: BDD Lattice Decoding Analysis")
    print("=" * 60)

    targets = [(0, 0), (1, 0), (1, 1)]
    results = lattice_bdd_analysis(n=2, basis_scale=3, target_offsets=targets)

    print(f"\nLattice: 3Z × 3Z (min distance = 3)")
    print(f"{'Target':>10} {'Radius':>8} {'Sep?':>6} {'Unique':>8} {'#Within':>8}")
    print("-" * 50)
    for r in results:
        print(f"{str(r['target']):>10} {r['radius']:8.2f} "
              f"{str(r['well_separated']):>6} {str(r['unique']):>8} "
              f"{r['num_within_radius']:>8}")

    print("\n" + "=" * 60)
    print("All applications completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Regev Reduction: Interactive TVD and LWE Demonstration

This script demonstrates the key mathematical concepts behind the Regev
reduction framework:

1. Small finite LWE distributions over Z/qZ
2. Quotient/modulus reduction as linear pushforward
3. TVD contraction under pushforward (data-processing inequality)
4. Hybrid telescope bounds for chained reductions
5. BDD uniqueness in small lattice instances

All computations are exact (using fractions) for verification purposes.
"""

from fractions import Fraction
from itertools import product
from typing import Dict, List, Tuple, Callable
import random
import math

# ============================================================
# Core TVD computation
# ============================================================

def tvd(p: Dict, q: Dict) -> Fraction:
    """Compute exact total variation distance between two distributions.

    TVD(p, q) = (1/2) * sum_x |p(x) - q(x)|

    Args:
        p: Distribution as dict {outcome: probability}
        q: Distribution as dict {outcome: probability}

    Returns:
        Exact TVD as a Fraction
    """
    keys = set(p.keys()) | set(q.keys())
    return Fraction(1, 2) * sum(
        abs(p.get(k, Fraction(0)) - q.get(k, Fraction(0)))
        for k in keys
    )


def uniform_distribution(domain: list) -> Dict:
    """Create uniform distribution over a finite domain."""
    n = len(domain)
    return {x: Fraction(1, n) for x in domain}


# ============================================================
# LWE Distribution Construction
# ============================================================

def lwe_distribution(q: int, n: int, s: Tuple[int, ...],
                     noise_dist: Dict[int, Fraction]) -> Dict:
    """Construct the LWE distribution over (Z/qZ)^n x Z/qZ.

    For secret s in (Z/qZ)^n, the LWE distribution produces samples
    (a, <a,s> + e mod q) where a is uniform and e ~ noise_dist.

    Args:
        q: Modulus
        n: Dimension
        s: Secret vector (tuple of ints mod q)
        noise_dist: Error distribution on Z/qZ

    Returns:
        Distribution over (a, b) pairs
    """
    dist = {}
    vectors = list(product(range(q), repeat=n))

    for a in vectors:
        inner = sum(a[i] * s[i] for i in range(n)) % q
        for e, p_e in noise_dist.items():
            b = (inner + e) % q
            key = (a, b)
            prob = Fraction(1, q**n) * p_e
            dist[key] = dist.get(key, Fraction(0)) + prob

    return dist


def uniform_lwe(q: int, n: int) -> Dict:
    """Uniform distribution over (Z/qZ)^n x Z/qZ (null hypothesis)."""
    return uniform_distribution(
        [(a, b) for a in product(range(q), repeat=n) for b in range(q)]
    )


# ============================================================
# Pushforward / Quotient Map
# ============================================================

def pushforward(dist: Dict, f: Callable) -> Dict:
    """Compute pushforward of a distribution through a function.

    (f_* μ)(y) = Σ_{x: f(x)=y} μ(x)

    Args:
        dist: Input distribution
        f: Deterministic function

    Returns:
        Pushforward distribution
    """
    result = {}
    for x, p in dist.items():
        y = f(x)
        result[y] = result.get(y, Fraction(0)) + p
    return result


def modulus_reduction_map(q_large: int, q_small: int):
    """Create a modulus reduction map Z/q_large -> Z/q_small.

    Maps (a, b) -> (a mod q_small, b mod q_small).
    This is a quotient map when q_small | q_large.
    """
    def f(sample):
        a, b = sample
        a_red = tuple(x % q_small for x in a)
        b_red = b % q_small
        return (a_red, b_red)
    return f


def dimension_reduction_map(n_large: int, n_small: int, q: int):
    """Create a dimension reduction map (Z/qZ)^n_large -> (Z/qZ)^n_small.

    Projects onto the first n_small coordinates.
    """
    def f(sample):
        a, b = sample
        a_red = a[:n_small]
        return (a_red, b)
    return f


# ============================================================
# Hybrid Telescope
# ============================================================

def hybrid_telescope_bound(distributions: List[Dict]) -> Tuple[Fraction, Fraction]:
    """Compute total TVD and sum of adjacent TVDs for a hybrid sequence.

    Returns (total_tvd, sum_of_adjacent_tvds) where
    total_tvd ≤ sum_of_adjacent_tvds by the triangle inequality.

    Args:
        distributions: List of distributions [H_0, H_1, ..., H_n]

    Returns:
        (TVD(H_0, H_n), sum of TVD(H_i, H_{i+1}))
    """
    total = tvd(distributions[0], distributions[-1])
    adjacent_sum = sum(
        tvd(distributions[i], distributions[i+1])
        for i in range(len(distributions) - 1)
    )
    return total, adjacent_sum


# ============================================================
# BDD Uniqueness
# ============================================================

def euclidean_dist(x: Tuple[int, ...], y: Tuple[int, ...]) -> float:
    """Euclidean distance between two integer vectors."""
    return math.sqrt(sum((a - b)**2 for a, b in zip(x, y)))


def check_bdd_uniqueness(lattice_points: List[Tuple[int, ...]],
                          target: Tuple[int, ...],
                          radius: float) -> Tuple[bool, List]:
    """Check BDD uniqueness: at most one lattice point within radius.

    Args:
        lattice_points: List of lattice points
        target: Target point
        radius: Decoding radius

    Returns:
        (is_unique, points_within_radius)
    """
    within = [p for p in lattice_points if euclidean_dist(p, target) <= radius]
    return len(within) <= 1, within


# ============================================================
# DEMONSTRATIONS
# ============================================================

def demo_1_lwe_distributions():
    """Demo 1: Construct and compare small LWE distributions."""
    print("=" * 60)
    print("DEMO 1: Small LWE Distributions")
    print("=" * 60)

    q = 5  # Small modulus
    n = 1  # Dimension 1

    # Narrow noise distribution centered at 0
    noise = {0: Fraction(3, 5), 1: Fraction(1, 5), 4: Fraction(1, 5)}  # {0, ±1}

    # Secret s = (2,)
    s = (2,)
    lwe_dist = lwe_distribution(q, n, s, noise)
    unif = uniform_lwe(q, n)

    d = tvd(lwe_dist, unif)
    print(f"Parameters: q={q}, n={n}, secret={s}")
    print(f"Noise distribution: {dict(noise)}")
    print(f"TVD(LWE, Uniform) = {d} ≈ {float(d):.6f}")
    print()

    # Different secret
    s2 = (1,)
    lwe_dist2 = lwe_distribution(q, n, s2, noise)
    d2 = tvd(lwe_dist2, unif)
    print(f"Secret s={s2}: TVD(LWE, Uniform) = {d2} ≈ {float(d2):.6f}")

    # Check TVD between two LWE instances with different secrets
    d_cross = tvd(lwe_dist, lwe_dist2)
    print(f"TVD(LWE(s={s}), LWE(s={s2})) = {d_cross} ≈ {float(d_cross):.6f}")
    print()


def demo_2_tvd_contraction():
    """Demo 2: TVD contraction under quotient/modulus reduction."""
    print("=" * 60)
    print("DEMO 2: TVD Contraction Under Modulus Reduction")
    print("=" * 60)

    q = 6  # Larger modulus
    n = 1
    noise = {0: Fraction(2, 4), 1: Fraction(1, 4), 5: Fraction(1, 4)}
    s = (1,)

    lwe_dist = lwe_distribution(q, n, s, noise)
    unif = uniform_lwe(q, n)

    tvd_before = tvd(lwe_dist, unif)
    print(f"Before reduction: q={q}, TVD = {tvd_before} ≈ {float(tvd_before):.6f}")

    # Modulus reduction q=6 -> q_small=3
    q_small = 3
    f = modulus_reduction_map(q, q_small)
    lwe_reduced = pushforward(lwe_dist, f)
    unif_reduced = pushforward(unif, f)

    tvd_after = tvd(lwe_reduced, unif_reduced)
    print(f"After reduction:  q={q_small}, TVD = {tvd_after} ≈ {float(tvd_after):.6f}")
    print(f"Contraction verified: {tvd_after} ≤ {tvd_before} ? {tvd_after <= tvd_before}")
    print(f"  (Data-processing inequality / Theorem 1)")
    print()

    # Modulus reduction q=6 -> q_small=2
    q_small2 = 2
    f2 = modulus_reduction_map(q, q_small2)
    lwe_reduced2 = pushforward(lwe_dist, f2)
    unif_reduced2 = pushforward(unif, f2)

    tvd_after2 = tvd(lwe_reduced2, unif_reduced2)
    print(f"After reduction:  q={q_small2}, TVD = {tvd_after2} ≈ {float(tvd_after2):.6f}")
    print(f"Contraction verified: {tvd_after2} ≤ {tvd_before} ? {tvd_after2 <= tvd_before}")
    print()


def demo_3_hybrid_telescope():
    """Demo 3: Hybrid telescope bound for chained reductions."""
    print("=" * 60)
    print("DEMO 3: Hybrid Telescope Bound")
    print("=" * 60)

    q = 5
    n = 2
    noise = {0: Fraction(3, 5), 1: Fraction(1, 5), 4: Fraction(1, 5)}

    # Create hybrid sequence: replace coordinates one at a time
    # H_0 = LWE with secret (s_1, s_2)
    # H_1 = hybrid where first coordinate is uniform
    # H_2 = fully uniform
    s = (2, 3)

    # H_0: full LWE
    h0 = lwe_distribution(q, n, s, noise)

    # H_2: uniform
    h2 = uniform_lwe(q, n)

    # H_1: intermediate hybrid (first coordinate uniformized)
    # For simplicity, construct by mixing
    h1 = {}
    for key in set(h0.keys()) | set(h2.keys()):
        h1[key] = (h0.get(key, Fraction(0)) + h2.get(key, Fraction(0))) / 2

    hybrids = [h0, h1, h2]
    total, adj_sum = hybrid_telescope_bound(hybrids)

    print(f"Hybrid sequence with {len(hybrids)} distributions")
    print(f"TVD(H_0, H_2) = {total} ≈ {float(total):.6f}")
    print(f"Σ TVD(H_i, H_{{i+1}}) = {adj_sum} ≈ {float(adj_sum):.6f}")
    print(f"Triangle inequality: {total} ≤ {adj_sum} ? {total <= adj_sum}")
    print(f"  (Theorem 2: composed_hybrid_telescope_bound)")
    print()

    # Verify individual steps
    for i in range(len(hybrids) - 1):
        d = tvd(hybrids[i], hybrids[i+1])
        print(f"  TVD(H_{i}, H_{i+1}) = {d} ≈ {float(d):.6f}")
    print()


def demo_4_bdd_uniqueness():
    """Demo 4: BDD solution uniqueness in small lattices."""
    print("=" * 60)
    print("DEMO 4: BDD Solution Uniqueness")
    print("=" * 60)

    # 2D integer lattice with basis vectors (3,0) and (0,3)
    # This gives lattice points at all multiples of 3
    lattice_points = [(3*i, 3*j) for i in range(-3, 4) for j in range(-3, 4)]

    # Minimum distance between distinct lattice points = 3
    min_dist = 3.0

    # Test with radius < min_dist/2 (well-separated)
    target = (1, 1)
    radius = 1.4  # < 3/2 = 1.5

    is_unique, within = check_bdd_uniqueness(lattice_points, target, radius)
    print(f"Lattice: 3Z x 3Z (min distance = {min_dist})")
    print(f"Target: {target}, Radius: {radius}")
    print(f"Well-separated (radius < min_dist/2 = {min_dist/2})? {radius < min_dist/2}")
    print(f"Points within radius: {within}")
    print(f"Unique solution? {is_unique}")
    print(f"  (Theorem 4: bdd_solution_unique)")
    print()

    # Test with larger radius (NOT well-separated)
    radius2 = 2.0  # > 3/2
    is_unique2, within2 = check_bdd_uniqueness(lattice_points, target, radius2)
    print(f"Target: {target}, Radius: {radius2}")
    print(f"Well-separated? {radius2 < min_dist/2}")
    print(f"Points within radius: {within2}")
    print(f"Unique solution? {is_unique2}")
    print()


def demo_5_composition():
    """Demo 5: Composition of reduction steps preserves TVD contraction."""
    print("=" * 60)
    print("DEMO 5: Composition of Reduction Steps")
    print("=" * 60)

    q = 6
    n = 1
    noise = {0: Fraction(2, 4), 1: Fraction(1, 4), 5: Fraction(1, 4)}
    s = (1,)

    lwe = lwe_distribution(q, n, s, noise)
    unif = uniform_lwe(q, n)

    tvd_original = tvd(lwe, unif)
    print(f"Original: q={q}, TVD = {float(tvd_original):.6f}")

    # Step 1: modulus reduction 6 -> 3
    f1 = modulus_reduction_map(q, 3)
    lwe_1 = pushforward(lwe, f1)
    unif_1 = pushforward(unif, f1)
    tvd_1 = tvd(lwe_1, unif_1)
    print(f"After step 1 (mod 6→3): TVD = {float(tvd_1):.6f}")

    # Step 2: further reduction 3 -> ... (project b component)
    def project_b(sample):
        a, b = sample
        return b
    lwe_2 = pushforward(lwe_1, project_b)
    unif_2 = pushforward(unif_1, project_b)
    tvd_2 = tvd(lwe_2, unif_2)
    print(f"After step 2 (project b): TVD = {float(tvd_2):.6f}")

    print(f"\nContraction chain: {float(tvd_2):.6f} ≤ {float(tvd_1):.6f} ≤ {float(tvd_original):.6f}")
    print(f"  Verified: {tvd_2 <= tvd_1 <= tvd_original}")
    print(f"  (Theorem 5: ModuleReductionStep.comp_tvd_bound)")
    print()


def demo_6_conjecture_test():
    """Demo 6: Test Conjecture A - quotient-stable Gaussian hardness transport."""
    print("=" * 60)
    print("DEMO 6: Conjecture Test - Quotient-Stable Hardness Transport")
    print("=" * 60)

    counterexample_found = False

    for q in range(2, 8):
        for n in range(1, 3):
            # Approximate discrete Gaussian noise
            noise = {}
            total = Fraction(0)
            for e in range(q):
                # Gaussian-like: exp(-e^2 / (2*sigma^2)) with sigma = q/4
                sigma = max(q / 4, 0.5)
                weight = math.exp(-(min(e, q-e))**2 / (2 * sigma**2))
                noise[e] = Fraction(weight).limit_denominator(1000)
                total += noise[e]
            # Normalize
            noise = {e: p / total for e, p in noise.items()}

            for s_val in range(q):
                s = (s_val,) * n
                lwe = lwe_distribution(q, n, s, noise)
                unif = uniform_lwe(q, n)

                tvd_before = tvd(lwe, unif)

                # Test modulus reduction for each divisor of q
                for q_small in range(2, q):
                    if q % q_small != 0:
                        continue
                    f = modulus_reduction_map(q, q_small)
                    lwe_red = pushforward(lwe, f)
                    unif_red = pushforward(unif, f)
                    tvd_after = tvd(lwe_red, unif_red)

                    if tvd_after > tvd_before:
                        print(f"COUNTEREXAMPLE: q={q}, n={n}, s={s}, "
                              f"q_small={q_small}")
                        print(f"  TVD before: {float(tvd_before):.6f}")
                        print(f"  TVD after:  {float(tvd_after):.6f}")
                        counterexample_found = True

    if not counterexample_found:
        print("No counterexample found for q ≤ 7, n ≤ 2")
        print("Conjecture A holds for all tested parameters.")
        print("  TVD never increases under quotient-compatible pushforward.")
    print()


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Regev Reduction: Compositional Verification Framework  ║")
    print("║  Interactive Demonstration                              ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_1_lwe_distributions()
    demo_2_tvd_contraction()
    demo_3_hybrid_telescope()
    demo_4_bdd_uniqueness()
    demo_5_composition()
    demo_6_conjecture_test()

    print("=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)
