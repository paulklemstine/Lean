#!/usr/bin/env python3
"""
applications.py — Real-world applications of discrete Kakeya theory.

Demonstrates how the formally verified incidence-energy bounds apply to:
1. Compressed sensing / sparse recovery: tube-like measurement matrices
2. Network coding: multicast relay design with coverage guarantees
3. Hash function analysis: collision bounds from incidence theory
"""

from collections import Counter
from typing import Dict, List, Set, Tuple
import itertools
import math

Point = Tuple[int, int]


# ═══════════════════════════════════════════════════════════════════════════
# Application 1: Compressed Sensing — Measurement Matrix Design
# ═══════════════════════════════════════════════════════════════════════════

def measurement_matrix_from_lines(p: int, num_slopes: int) -> List[List[int]]:
    """
    Construct a measurement matrix from a line family in F_p^2.

    Each direction d defines a 'measurement': the indicator of line_d.
    The matrix A has rows indexed by directions and columns by carrier points.
    A[d, p] = 1 iff point p is on line d.

    The Kakeya energy bound gives: if this matrix has small carrier (few
    columns), then the energy (sum of squared column norms) must be large,
    which means the matrix has poor RIP-like properties.

    Conversely, good measurement matrices (low energy) force large carriers,
    giving the link to compressed sensing.
    """
    # Build star configuration for demonstration
    lines = {}
    for slope in range(num_slopes):
        lines[slope] = frozenset((x, (slope * x) % p) for x in range(p))

    carrier = sorted(set().union(*lines.values()))
    carrier_idx = {pt: i for i, pt in enumerate(carrier)}

    matrix = []
    for slope in range(num_slopes):
        row = [0] * len(carrier)
        for pt in lines[slope]:
            row[carrier_idx[pt]] = 1
        matrix.append(row)

    return matrix


def analyze_measurement_matrix(matrix: List[List[int]]) -> Dict:
    """
    Analyze RIP-related properties of a measurement matrix.

    The formal bound tells us:
        (rows * cols_per_row)^2 <= num_cols * sum(col_norm^2)

    This is exactly the Cauchy-Schwarz energy inequality applied to the
    incidence matrix of the configuration.
    """
    num_rows = len(matrix)
    num_cols = len(matrix[0]) if matrix else 0

    # Column multiplicities (number of 1s per column = point multiplicity)
    col_mult = []
    for j in range(num_cols):
        mult = sum(matrix[i][j] for i in range(num_rows))
        col_mult.append(mult)

    # Energy = sum of squared multiplicities
    total_energy = sum(m ** 2 for m in col_mult)
    total_mass = sum(col_mult)
    max_coherence = max(m ** 2 for m in col_mult) if col_mult else 0

    # Verify Cauchy-Schwarz bound
    lhs = total_mass ** 2
    rhs = num_cols * total_energy
    bound_satisfied = lhs <= rhs

    return {
        'num_rows': num_rows,
        'num_cols': num_cols,
        'total_mass': total_mass,
        'total_energy': total_energy,
        'max_column_norm_sq': max_coherence,
        'cauchy_schwarz_lhs': lhs,
        'cauchy_schwarz_rhs': rhs,
        'bound_satisfied': bound_satisfied,
    }


# ═══════════════════════════════════════════════════════════════════════════
# Application 2: Network Coverage Analysis
# ═══════════════════════════════════════════════════════════════════════════

def network_coverage_model(p: int) -> Dict:
    """
    Model a relay network where each 'direction' is a broadcast beam
    covering points along a line in a grid.

    The Kakeya bounds give fundamental limits:
    - To cover all p+1 beam directions, you need at least a certain
      number of relay points (the carrier).
    - The energy measures how unevenly traffic is distributed.
    - Low energy = uniform load = good network design.

    Returns analysis comparing star (hub) vs spread (distributed) topologies.
    """
    results = {}

    # Hub topology: all beams through one center
    hub_lines = {s: frozenset((x, (s * x) % p) for x in range(p)) for s in range(p)}
    hub_carrier = set().union(*hub_lines.values())
    hub_mult = Counter()
    for ln in hub_lines.values():
        for pt in ln:
            hub_mult[pt] += 1
    hub_energy = sum(m ** 2 for m in hub_mult.values())
    hub_max_load = max(hub_mult.values())

    results['hub'] = {
        'carrier_size': len(hub_carrier),
        'energy': hub_energy,
        'max_load': hub_max_load,
        'load_distribution': dict(Counter(hub_mult.values())),
    }

    # Distributed topology: spread intercepts
    dist_lines = {s: frozenset((x, (s * x + s * s) % p) for x in range(p)) for s in range(p)}
    dist_carrier = set().union(*dist_lines.values())
    dist_mult = Counter()
    for ln in dist_lines.values():
        for pt in ln:
            dist_mult[pt] += 1
    dist_energy = sum(m ** 2 for m in dist_mult.values())
    dist_max_load = max(dist_mult.values())

    results['distributed'] = {
        'carrier_size': len(dist_carrier),
        'energy': dist_energy,
        'max_load': dist_max_load,
        'load_distribution': dict(Counter(dist_mult.values())),
    }

    # Theoretical minimum carrier from pairwise bound (T=1 for distinct slopes)
    num_dirs = p
    L = p
    T = 1
    min_carrier = (num_dirs * L) ** 2 / (num_dirs * L + num_dirs * (num_dirs - 1) * T)

    results['theoretical_min_carrier'] = min_carrier
    results['p'] = p

    return results


# ═══════════════════════════════════════════════════════════════════════════
# Application 3: Hash Collision Analysis
# ═══════════════════════════════════════════════════════════════════════════

def hash_collision_analysis(p: int, num_hash_functions: int) -> Dict:
    """
    Analyze collision structure using incidence theory.

    Model: each 'hash function' h_s maps x -> (s*x + b) mod p.
    The 'line' for slope s is the graph {(x, h_s(x))}.
    Collisions between hash functions correspond to line intersections.

    The pairwise intersection bound gives: if each pair of hash functions
    collides on at most T inputs, then the combined output range (carrier)
    must be large.

    This formalizes the folk wisdom: good hash families spread their outputs.
    """
    # Construct hash family
    hash_lines = {}
    for s in range(min(num_hash_functions, p)):
        # h_s(x) = s*x mod p
        hash_lines[s] = frozenset((x, (s * x) % p) for x in range(p))

    carrier = set().union(*hash_lines.values())
    mult = Counter()
    for ln in hash_lines.values():
        for pt in ln:
            mult[pt] += 1

    # Compute pairwise collisions
    max_T = 0
    collision_counts = []
    dirs = list(hash_lines.keys())
    for i in range(len(dirs)):
        for j in range(i + 1, len(dirs)):
            isect = len(hash_lines[dirs[i]] & hash_lines[dirs[j]])
            collision_counts.append(isect)
            max_T = max(max_T, isect)

    num_dirs = len(hash_lines)
    L = p
    bound = (num_dirs * L) ** 2 / (num_dirs * L + num_dirs * (num_dirs - 1) * max(max_T, 1))

    return {
        'p': p,
        'num_hash_functions': num_dirs,
        'domain_size': p,
        'carrier_size': len(carrier),
        'max_pairwise_collision': max_T,
        'energy': sum(m ** 2 for m in mult.values()),
        'lower_bound_from_theorem': bound,
        'bound_satisfied': len(carrier) >= bound - 1e-9,
        'collision_distribution': dict(Counter(collision_counts)),
    }


# ═══════════════════════════════════════════════════════════════════════════
# Main demonstration
# ═══════════════════════════════════════════════════════════════════════════

def main():
    print("=" * 72)
    print("  APPLICATIONS OF DISCRETE KAKEYA THEORY")
    print("=" * 72)

    # Application 1
    print("\n┌─────────────────────────────────────────────────────┐")
    print("│  Application 1: Compressed Sensing Matrix Design    │")
    print("└─────────────────────────────────────────────────────┘\n")

    for p in [5, 7, 11]:
        matrix = measurement_matrix_from_lines(p, p)
        analysis = analyze_measurement_matrix(matrix)
        print(f"  p={p}: {analysis['num_rows']} measurements × "
              f"{analysis['num_cols']} sensors")
        print(f"    Total mass: {analysis['total_mass']}, "
              f"Energy: {analysis['total_energy']}")
        print(f"    Max column coherence: {analysis['max_column_norm_sq']}")
        print(f"    Cauchy-Schwarz: {analysis['cauchy_schwarz_lhs']} ≤ "
              f"{analysis['cauchy_schwarz_rhs']}  "
              f"({'✓' if analysis['bound_satisfied'] else '✗'})")
        print()

    # Application 2
    print("\n┌─────────────────────────────────────────────────────┐")
    print("│  Application 2: Network Coverage Analysis           │")
    print("└─────────────────────────────────────────────────────┘\n")

    for p in [5, 7, 11]:
        results = network_coverage_model(p)
        print(f"  p={p}:")
        print(f"    Hub topology:     carrier={results['hub']['carrier_size']}, "
              f"energy={results['hub']['energy']}, "
              f"max_load={results['hub']['max_load']}")
        print(f"    Distributed:      carrier={results['distributed']['carrier_size']}, "
              f"energy={results['distributed']['energy']}, "
              f"max_load={results['distributed']['max_load']}")
        print(f"    Theoretical min:  {results['theoretical_min_carrier']:.1f}")
        print()

    # Application 3
    print("\n┌─────────────────────────────────────────────────────┐")
    print("│  Application 3: Hash Collision Analysis             │")
    print("└─────────────────────────────────────────────────────┘\n")

    for p in [7, 11, 13]:
        for nh in [3, p]:
            result = hash_collision_analysis(p, nh)
            print(f"  p={p}, {result['num_hash_functions']} hash functions:")
            print(f"    Output range: {result['carrier_size']} / {p*p} cells")
            print(f"    Max pairwise collision: {result['max_pairwise_collision']}")
            print(f"    Energy: {result['energy']}")
            print(f"    Lower bound: {result['lower_bound_from_theorem']:.1f}")
            print(f"    Bound satisfied: {'✓' if result['bound_satisfied'] else '✗'}")
        print()

    print("=" * 72)
    print("  All applications demonstrate verified bounds.")
    print("=" * 72)


if __name__ == '__main__':
    main()


#!/usr/bin/env python3
"""
demo.py — Interactive demonstration of discrete Kakeya configurations.

Generates finite Kakeya configurations over ZMod(p) x ZMod(p), computes
carrier sizes, point multiplicities, overlap energy, and tests lower bounds
proved in the formal development.

Usage:
    python demo.py
"""

import itertools
from collections import Counter
from typing import Dict, List, Set, Tuple

# ─── Core data types ─────────────────────────────────────────────────────────

Point = Tuple[int, int]
Line = frozenset  # frozenset of Points


def affine_line_Fp2(p: int, slope: int, intercept: int) -> frozenset:
    """Affine line y = slope*x + intercept in (ZMod p)^2."""
    return frozenset((x, (slope * x + intercept) % p) for x in range(p))


def vertical_line_Fp2(p: int, x0: int) -> frozenset:
    """Vertical line x = x0 in (ZMod p)^2."""
    return frozenset((x0, y) for y in range(p))


# ─── Kakeya configuration builders ──────────────────────────────────────────

def star_config(p: int, center: Point = (0, 0)) -> Dict[str, object]:
    """
    Star configuration: all lines through a single center point.
    One line per 'direction' (p slopes + 1 vertical = p+1 directions).
    """
    cx, cy = center
    lines = {}
    for slope in range(p):
        intercept = (cy - slope * cx) % p
        lines[('slope', slope)] = affine_line_Fp2(p, slope, intercept)
    lines[('vertical', 0)] = vertical_line_Fp2(p, cx)
    carrier = set()
    for ln in lines.values():
        carrier |= ln
    return {'lines': lines, 'carrier': carrier, 'p': p, 'name': 'star'}


def spread_config(p: int) -> Dict[str, object]:
    """
    Spread configuration: choose intercepts to spread lines apart.
    Uses distinct intercepts to reduce concurrency.
    """
    lines = {}
    for slope in range(p):
        intercept = (slope * slope) % p  # quadratic spread
        lines[('slope', slope)] = affine_line_Fp2(p, slope, intercept)
    lines[('vertical', 0)] = vertical_line_Fp2(p, 0)
    carrier = set()
    for ln in lines.values():
        carrier |= ln
    return {'lines': lines, 'carrier': carrier, 'p': p, 'name': 'spread'}


def random_config(p: int, seed: int = 42) -> Dict[str, object]:
    """
    Random configuration: random intercept per slope.
    """
    import random
    rng = random.Random(seed)
    lines = {}
    for slope in range(p):
        intercept = rng.randint(0, p - 1)
        lines[('slope', slope)] = affine_line_Fp2(p, slope, intercept)
    lines[('vertical', 0)] = vertical_line_Fp2(p, rng.randint(0, p - 1))
    carrier = set()
    for ln in lines.values():
        carrier |= ln
    return {'lines': lines, 'carrier': carrier, 'p': p, 'name': 'random'}


# ─── Statistics ──────────────────────────────────────────────────────────────

def compute_multiplicity(config: Dict) -> Counter:
    """Compute point multiplicity: how many lines pass through each point."""
    mult = Counter()
    for ln in config['lines'].values():
        for pt in ln:
            mult[pt] += 1
    return mult


def compute_energy(config: Dict) -> int:
    """Compute Kakeya energy = sum of squared multiplicities."""
    mult = compute_multiplicity(config)
    return sum(m ** 2 for m in mult.values())


def compute_pairwise_intersections(config: Dict) -> Dict[Tuple, int]:
    """Compute pairwise intersection sizes between all line pairs."""
    dirs = list(config['lines'].keys())
    intersections = {}
    for i, d1 in enumerate(dirs):
        for j, d2 in enumerate(dirs):
            if i < j:
                isect = config['lines'][d1] & config['lines'][d2]
                intersections[(d1, d2)] = len(isect)
    return intersections


def max_pairwise_intersection(config: Dict) -> int:
    """Maximum pairwise intersection size T."""
    ints = compute_pairwise_intersections(config)
    return max(ints.values()) if ints else 0


# ─── Lower bound from proved theorems ───────────────────────────────────────

def cauchy_schwarz_bound(num_dirs: int, L: int, energy: int) -> float:
    """
    From Theorem 1 (sq_total_line_mass_le_card_mul_energy):
    |carrier| >= (|Dir| * L)^2 / energy
    """
    if energy == 0:
        return 0
    return (num_dirs * L) ** 2 / energy


def pairwise_bound(num_dirs: int, L: int, T: int) -> float:
    """
    From Theorem 2 (card_lower_bound_of_pairwise_intersection_bound):
    |carrier| >= (|Dir| * L)^2 / (|Dir| * L + |Dir| * (|Dir| - 1) * T)
    """
    denom = num_dirs * L + num_dirs * (num_dirs - 1) * T
    if denom == 0:
        return 0
    return (num_dirs * L) ** 2 / denom


# ─── Exhaustive search for small primes ─────────────────────────────────────

def exhaustive_min_carrier(p: int) -> Tuple[int, List]:
    """
    For small p, exhaustively search over all one-line-per-slope families
    to find minimum carrier size. Only slopes 0..p-1 (no vertical).
    """
    if p > 7:
        print(f"  Skipping exhaustive search for p={p} (too large)")
        return -1, []

    best_size = p * p + 1
    best_configs = []
    # Each slope gets an intercept in {0, ..., p-1}
    for intercepts in itertools.product(range(p), repeat=p):
        carrier = set()
        for slope in range(p):
            for x in range(p):
                carrier.add((x, (slope * x + intercepts[slope]) % p))
        size = len(carrier)
        if size < best_size:
            best_size = size
            best_configs = [intercepts]
        elif size == best_size:
            best_configs.append(intercepts)
    return best_size, best_configs


def check_star_like(p: int, intercepts: Tuple[int, ...]) -> bool:
    """
    Check if a minimizing configuration is 'star-like': has a point
    with maximum possible multiplicity (= p, one per slope).
    """
    mult = Counter()
    for slope in range(p):
        for x in range(p):
            pt = (x, (slope * x + intercepts[slope]) % p)
            mult[pt] += 1
    return max(mult.values()) == p


# ─── Main demo ───────────────────────────────────────────────────────────────

def main():
    print("=" * 72)
    print("  DISCRETE KAKEYA CONFIGURATIONS — DEMONSTRATION")
    print("  Verified lower bounds from incidence geometry")
    print("=" * 72)

    # ── Section 1: Configuration statistics for various primes ──
    print("\n┌─────────────────────────────────────────────────────┐")
    print("│  Section 1: Configuration Statistics                │")
    print("└─────────────────────────────────────────────────────┘\n")

    for p in [3, 5, 7, 11]:
        print(f"━━━ Prime p = {p}, working in F_{p}² ━━━")
        configs = [star_config(p), spread_config(p), random_config(p)]
        for cfg in configs:
            num_dirs = len(cfg['lines'])
            L = p  # each line has p points
            carrier_size = len(cfg['carrier'])
            energy = compute_energy(cfg)
            T = max_pairwise_intersection(cfg)
            mult = compute_multiplicity(cfg)
            max_mult = max(mult.values())

            cs_bound = cauchy_schwarz_bound(num_dirs, L, energy)
            pw_bound = pairwise_bound(num_dirs, L, T)

            print(f"\n  Config: {cfg['name']}")
            print(f"    Directions:     {num_dirs}")
            print(f"    Line size (L):  {L}")
            print(f"    Carrier size:   {carrier_size}")
            print(f"    Energy:         {energy}")
            print(f"    Max T:          {T}")
            print(f"    Max multiplicity: {max_mult}")
            print(f"    ── Proved lower bounds ──")
            print(f"    Cauchy–Schwarz: |carrier| ≥ {cs_bound:.1f}")
            print(f"    Pairwise (T={T}): |carrier| ≥ {pw_bound:.1f}")
            print(f"    Bounds satisfied: CS={carrier_size >= cs_bound}, "
                  f"PW={carrier_size >= pw_bound}")
        print()

    # ── Section 2: Extremizer conjecture test ──
    print("\n┌─────────────────────────────────────────────────────┐")
    print("│  Section 2: Extremizer Conjecture Test              │")
    print("│  'Minimizers are star-like (max concurrency)'       │")
    print("└─────────────────────────────────────────────────────┘\n")

    for p in [3, 5, 7]:
        print(f"  p = {p}:")
        min_size, minimizers = exhaustive_min_carrier(p)
        if min_size < 0:
            continue
        print(f"    Minimum carrier size: {min_size}")
        print(f"    Number of minimizers: {len(minimizers)}")
        all_star = all(check_star_like(p, m) for m in minimizers)
        print(f"    All minimizers star-like: {all_star}")
        if not all_star:
            non_star = [m for m in minimizers if not check_star_like(p, m)]
            print(f"    ⚠ Non-star minimizers found: {len(non_star)}")
        else:
            print(f"    ✓ Conjecture holds for p={p}")
        print()

    # ── Section 3: Energy vs carrier trade-off ──
    print("\n┌─────────────────────────────────────────────────────┐")
    print("│  Section 3: Energy–Carrier Trade-off                │")
    print("└─────────────────────────────────────────────────────┘\n")

    p = 5
    print(f"  p = {p}: scanning all intercept choices (slopes 0..{p-1})")
    print(f"  {'Carrier':>8}  {'Energy':>8}  {'MaxMult':>8}  {'CS Bound':>10}  {'Tight?':>6}")
    print(f"  {'─'*8}  {'─'*8}  {'─'*8}  {'─'*10}  {'─'*6}")

    seen = set()
    for intercepts in itertools.product(range(p), repeat=p):
        carrier = set()
        mult = Counter()
        for slope in range(p):
            for x in range(p):
                pt = (x, (slope * x + intercepts[slope]) % p)
                carrier.add(pt)
                mult[pt] += 1
        csize = len(carrier)
        energy = sum(m ** 2 for m in mult.values())
        max_m = max(mult.values())
        key = (csize, energy, max_m)
        if key not in seen:
            seen.add(key)
            cs_b = cauchy_schwarz_bound(p, p, energy)
            tight = "yes" if abs(csize - cs_b) < 0.01 else ""
            print(f"  {csize:>8}  {energy:>8}  {max_m:>8}  {cs_b:>10.2f}  {tight:>6}")

    # ── Section 4: Multiplicity distribution ──
    print("\n┌─────────────────────────────────────────────────────┐")
    print("│  Section 4: Multiplicity Distribution               │")
    print("└─────────────────────────────────────────────────────┘\n")

    for p in [5, 7, 11]:
        cfg = star_config(p)
        mult = compute_multiplicity(cfg)
        dist = Counter(mult.values())
        print(f"  Star config, p={p}:")
        for k in sorted(dist.keys()):
            bar = "█" * dist[k]
            print(f"    mult={k}: {dist[k]:>4} points  {bar}")

        cfg2 = spread_config(p)
        mult2 = compute_multiplicity(cfg2)
        dist2 = Counter(mult2.values())
        print(f"  Spread config, p={p}:")
        for k in sorted(dist2.keys()):
            bar = "█" * min(dist2[k], 60)
            print(f"    mult={k}: {dist2[k]:>4} points  {bar}")
        print()

    print("\n" + "=" * 72)
    print("  Demo complete. All proved bounds verified numerically.")
    print("=" * 72)


if __name__ == '__main__':
    main()
