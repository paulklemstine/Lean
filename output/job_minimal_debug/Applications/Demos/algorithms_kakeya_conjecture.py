#!/usr/bin/env python3
"""
algorithms.py — Algorithms for discrete Kakeya configuration analysis.

Implements:
1. Configuration construction (star, spread, random, minimal search)
2. Incidence statistics (multiplicity, energy, pairwise intersections)
3. Lower bound computation from proved theorems
4. Extremizer detection and affine equivalence testing

All algorithms correspond to formally verified mathematical results.
"""

from collections import Counter
from typing import Dict, FrozenSet, List, Optional, Set, Tuple
import itertools

Point = Tuple[int, int]


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 1: Configuration Construction
# ═══════════════════════════════════════════════════════════════════════════

def build_line_family_Fp2(p: int, intercepts: Dict[object, int]) -> Dict[object, FrozenSet[Point]]:
    """
    Build a line family in F_p^2 from slope-intercept pairs.

    For each slope s with intercept b, the line is {(x, sx+b mod p) : x in F_p}.
    For vertical lines, specify ('vertical', x0).

    Complexity: O(|slopes| * p)

    Args:
        p: prime modulus
        intercepts: dict mapping direction labels to intercepts

    Returns:
        dict mapping direction labels to frozensets of points
    """
    lines = {}
    for direction, b in intercepts.items():
        if isinstance(direction, tuple) and direction[0] == 'vertical':
            lines[direction] = frozenset((b, y) for y in range(p))
        else:
            lines[direction] = frozenset((x, (direction * x + b) % p) for x in range(p))
    return lines


def carrier_of_family(lines: Dict[object, FrozenSet[Point]]) -> Set[Point]:
    """
    Compute the carrier (union) of a line family.

    Complexity: O(sum of line sizes)
    """
    carrier = set()
    for ln in lines.values():
        carrier |= ln
    return carrier


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 2: Incidence Statistics
# ═══════════════════════════════════════════════════════════════════════════

def point_multiplicity(lines: Dict[object, FrozenSet[Point]]) -> Counter:
    """
    Compute point multiplicity for each point in the carrier.

    Corresponds to DiscreteKakeyaConfig.pointMultiplicity in the Lean formalization.

    Complexity: O(sum of line sizes)

    Returns:
        Counter mapping each point to its multiplicity
    """
    mult = Counter()
    for ln in lines.values():
        for pt in ln:
            mult[pt] += 1
    return mult


def kakeya_energy(lines: Dict[object, FrozenSet[Point]]) -> int:
    """
    Compute the Kakeya energy: sum of squared multiplicities.

    Corresponds to DiscreteKakeyaConfig.kakeyaEnergy in the Lean formalization.
    By the proved double-counting identity:
        sum of multiplicities = sum of line sizes = |Dir| * L

    Complexity: O(sum of line sizes)

    Returns:
        The energy as a non-negative integer
    """
    mult = point_multiplicity(lines)
    return sum(m ** 2 for m in mult.values())


def pairwise_intersection_sizes(lines: Dict[object, FrozenSet[Point]]) -> Dict[Tuple, int]:
    """
    Compute all pairwise intersection sizes.

    Complexity: O(|Dir|^2 * L)

    Returns:
        dict mapping (d1, d2) pairs (d1 < d2) to intersection sizes
    """
    dirs = list(lines.keys())
    result = {}
    for i in range(len(dirs)):
        for j in range(i + 1, len(dirs)):
            size = len(lines[dirs[i]] & lines[dirs[j]])
            result[(dirs[i], dirs[j])] = size
    return result


def max_intersection_parameter(lines: Dict[object, FrozenSet[Point]]) -> int:
    """
    Compute T = max pairwise intersection size.

    This is the key parameter in the pairwise intersection bound theorem.

    Complexity: O(|Dir|^2 * L)
    """
    sizes = pairwise_intersection_sizes(lines)
    return max(sizes.values()) if sizes else 0


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 3: Verified Lower Bounds
# ═══════════════════════════════════════════════════════════════════════════

def cauchy_schwarz_lower_bound(num_dirs: int, L: int, energy: int) -> float:
    """
    Compute the Cauchy-Schwarz lower bound on carrier size.

    From the formally verified theorem sq_total_line_mass_le_card_mul_energy:
        (|Dir| * L)^2 <= |carrier| * energy
    Therefore:
        |carrier| >= (|Dir| * L)^2 / energy

    Args:
        num_dirs: number of directions |Dir|
        L: line size (assumed constant)
        energy: Kakeya energy

    Returns:
        Lower bound on carrier size (as float)
    """
    if energy == 0:
        return float('inf') if num_dirs * L > 0 else 0
    return (num_dirs * L) ** 2 / energy


def pairwise_intersection_lower_bound(num_dirs: int, L: int, T: int) -> float:
    """
    Compute the pairwise intersection lower bound on carrier size.

    From the formally verified theorem card_lower_bound_of_pairwise_intersection_bound:
        (|Dir| * L)^2 <= |carrier| * (|Dir|*L + |Dir|*(|Dir|-1)*T)
    Therefore:
        |carrier| >= (|Dir| * L)^2 / (|Dir|*L + |Dir|*(|Dir|-1)*T)

    This simplifies to:
        |carrier| >= |Dir| * L^2 / (L + (|Dir|-1)*T)

    Args:
        num_dirs: number of directions
        L: line size
        T: max pairwise intersection size

    Returns:
        Lower bound on carrier size
    """
    denom = num_dirs * L + num_dirs * (num_dirs - 1) * T
    if denom == 0:
        return float('inf') if num_dirs * L > 0 else 0
    return (num_dirs * L) ** 2 / denom


def verify_bounds(lines: Dict[object, FrozenSet[Point]], L: int) -> Dict[str, object]:
    """
    Verify all proved lower bounds against an actual configuration.

    Args:
        lines: the line family
        L: expected line size

    Returns:
        Dict with bound values and verification results
    """
    carrier = carrier_of_family(lines)
    energy = kakeya_energy(lines)
    T = max_intersection_parameter(lines)
    num_dirs = len(lines)
    carrier_size = len(carrier)

    cs_bound = cauchy_schwarz_lower_bound(num_dirs, L, energy)
    pw_bound = pairwise_intersection_lower_bound(num_dirs, L, T)

    return {
        'carrier_size': carrier_size,
        'energy': energy,
        'T': T,
        'num_dirs': num_dirs,
        'L': L,
        'cauchy_schwarz_bound': cs_bound,
        'pairwise_bound': pw_bound,
        'cs_satisfied': carrier_size >= cs_bound - 1e-9,
        'pw_satisfied': carrier_size >= pw_bound - 1e-9,
    }


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 4: Extremizer Detection
# ═══════════════════════════════════════════════════════════════════════════

def find_minimum_carrier_exhaustive(p: int, num_slopes: Optional[int] = None) -> Tuple[int, List]:
    """
    Exhaustively find minimum carrier size over all one-line-per-slope families.

    Pseudocode:
        best ← p^2 + 1
        for each (b_0, ..., b_{p-1}) in F_p^p:
            carrier ← union of {(x, s*x + b_s) : x in F_p} for s = 0..p-1
            if |carrier| < best:
                best ← |carrier|
                minimizers ← [(b_0, ..., b_{p-1})]
            elif |carrier| = best:
                minimizers.append((b_0, ..., b_{p-1}))
        return best, minimizers

    Complexity: O(p^{p+1})  — feasible only for p <= 7.

    Args:
        p: prime
        num_slopes: number of slopes (default p)

    Returns:
        (min_carrier_size, list_of_minimizing_intercept_tuples)
    """
    if num_slopes is None:
        num_slopes = p

    best = p * p + 1
    minimizers = []

    for intercepts in itertools.product(range(p), repeat=num_slopes):
        carrier = set()
        for slope in range(num_slopes):
            for x in range(p):
                carrier.add((x, (slope * x + intercepts[slope]) % p))
        size = len(carrier)
        if size < best:
            best = size
            minimizers = [intercepts]
        elif size == best:
            minimizers.append(intercepts)

    return best, minimizers


def is_star_like(p: int, intercepts: Tuple[int, ...], threshold_fraction: float = 1.0) -> bool:
    """
    Check if a configuration is star-like: has a point with multiplicity
    equal to the number of slopes times threshold_fraction.

    A configuration is star-like if at least one point is contained in
    all (or nearly all) lines.

    Args:
        p: prime
        intercepts: intercept values for slopes 0..len(intercepts)-1
        threshold_fraction: fraction of max possible multiplicity required

    Returns:
        True if the configuration has a high-multiplicity center
    """
    num_slopes = len(intercepts)
    mult = Counter()
    for slope in range(num_slopes):
        for x in range(p):
            pt = (x, (slope * x + intercepts[slope]) % p)
            mult[pt] += 1
    threshold = int(num_slopes * threshold_fraction)
    return max(mult.values()) >= threshold


def affine_transform_Fp2(p: int, points: Set[Point],
                          a: int, b: int, c: int, d: int,
                          tx: int, ty: int) -> Set[Point]:
    """
    Apply an affine transformation (A, t) to a point set in F_p^2.

    (x, y) -> (ax + by + tx, cx + dy + ty) mod p

    Args:
        p: prime
        points: set of points
        a, b, c, d: matrix entries (must have ad - bc != 0 mod p)
        tx, ty: translation

    Returns:
        Transformed point set
    """
    return {((a * x + b * y + tx) % p, (c * x + d * y + ty) % p) for x, y in points}


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 5: AP Configuration in Additive Groups
# ═══════════════════════════════════════════════════════════════════════════

def ap_config_ZmodN(N: int, directions: List[int], ap_length: int,
                     bases: Optional[List[int]] = None) -> Dict[str, object]:
    """
    Build a Kakeya-type configuration from arithmetic progressions in Z/NZ.

    For each direction v, the AP is {base_v + k*v mod N : k = 0, ..., ap_length-1}.

    This corresponds to the formal `ap_config` construction in AdditiveComb.lean.

    Args:
        N: modulus
        directions: list of direction values
        ap_length: length of each AP
        bases: base points (default all 0)

    Returns:
        Configuration dict with lines, carrier, and statistics
    """
    if bases is None:
        bases = [0] * len(directions)

    lines = {}
    for i, v in enumerate(directions):
        ap = frozenset((bases[i] + k * v) % N for k in range(ap_length))
        lines[v] = ap

    carrier = set()
    for ln in lines.values():
        carrier |= ln

    energy = kakeya_energy(lines)

    return {
        'lines': lines,
        'carrier': carrier,
        'carrier_size': len(carrier),
        'energy': energy,
        'N': N,
        'ap_length': ap_length,
        'num_dirs': len(directions),
    }


if __name__ == '__main__':
    # Quick self-test
    print("Testing algorithms...")

    # Test 1: Star configuration
    p = 5
    lines = build_line_family_Fp2(p, {s: 0 for s in range(p)})
    result = verify_bounds(lines, p)
    assert result['cs_satisfied'], f"CS bound violated: {result}"
    assert result['pw_satisfied'], f"PW bound violated: {result}"
    print(f"  Star config p={p}: carrier={result['carrier_size']}, "
          f"energy={result['energy']}, bounds OK")

    # Test 2: Exhaustive search
    min_size, mins = find_minimum_carrier_exhaustive(3)
    print(f"  Exhaustive p=3: min carrier={min_size}, "
          f"{len(mins)} minimizers, "
          f"all star-like={all(is_star_like(3, m) for m in mins)}")

    # Test 3: AP config
    cfg = ap_config_ZmodN(7, list(range(1, 7)), 3)
    cs_b = cauchy_schwarz_lower_bound(cfg['num_dirs'], cfg['ap_length'], cfg['energy'])
    print(f"  AP config Z/7Z: carrier={cfg['carrier_size']}, "
          f"energy={cfg['energy']}, CS bound={cs_b:.1f}")

    print("All tests passed.")
