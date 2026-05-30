"""
Algorithms for Primewise Persistent Homology

This module implements the core algorithms for computing persistence barcodes
from Frobenius orbit data, testing local-global principles, and evaluating
the separation conjecture.

Algorithms:
1. Frobenius orbit computation for conics mod p
2. Persistence barcode construction from orbit data
3. Pell separation test across prime ranges
4. Mod-9 obstruction classifier
5. Barcode distance computation (bottleneck distance)
"""

from typing import List, Tuple, Dict, Set, Optional
import math
from collections import Counter


# ── Algorithm 1: Frobenius Orbit Computation ──────────────────────────

def compute_frobenius_orbits(
    curve_points: List[Tuple[int, ...]],
    frobenius_map: callable,
    p: int
) -> List[int]:
    """
    Compute orbit sizes of a Frobenius-like map on a set of points.

    Args:
        curve_points: List of points (as tuples) on the curve mod p
        frobenius_map: Function (point, p) -> point representing Frobenius
        p: The prime

    Returns:
        List of orbit sizes (each positive)

    Time complexity: O(N * max_orbit_size) where N = len(curve_points)
    Space complexity: O(N)
    """
    visited = set()
    orbit_sizes = []

    for pt in curve_points:
        if pt in visited:
            continue

        # Trace the orbit
        orbit = []
        current = pt
        while current not in visited:
            visited.add(current)
            orbit.append(current)
            current = frobenius_map(current, p)

        if orbit:
            orbit_sizes.append(len(orbit))

    return orbit_sizes


def pell_conic_points(d: int, p: int) -> List[Tuple[int, int]]:
    """
    Compute points on the Pell conic x² - dy² = 1 over F_p.

    Time complexity: O(p²)
    Space complexity: O(p)
    """
    points = []
    for x in range(p):
        for y in range(p):
            if (x * x - d * y * y - 1) % p == 0:
                points.append((x, y))
    return points


def elliptic_curve_points(a: int, b: int, p: int) -> List[Tuple[int, int]]:
    """
    Compute affine points on y² = x³ + ax + b over F_p.

    Time complexity: O(p²)
    Space complexity: O(p)
    """
    points = []
    for x in range(p):
        rhs = (x * x * x + a * x + b) % p
        for y in range(p):
            if (y * y) % p == rhs:
                points.append((x, y))
    return points


# ── Algorithm 2: Persistence Barcode Construction ─────────────────────

def orbits_to_barcode(orbit_sizes: List[int]) -> List[Tuple[int, int]]:
    """
    Convert orbit sizes to persistence barcode intervals.

    Each orbit of size k produces interval [0, k).

    Args:
        orbit_sizes: List of positive integers (orbit sizes)

    Returns:
        List of (birth, death) pairs

    Time complexity: O(n) where n = len(orbit_sizes)
    Space complexity: O(n)

    Invariant (proved in Lean):
        sum of lifetimes = sum of orbit_sizes = total_points
    """
    return [(0, k) for k in orbit_sizes]


def barcode_total_persistence(barcode: List[Tuple[int, int]]) -> int:
    """Compute total persistence of a barcode."""
    return sum(d - b for b, d in barcode if d > 0)


def barcode_euler_characteristic(barcode: List[Tuple[int, int]]) -> int:
    """
    Compute the Euler characteristic of a barcode.
    Each interval with even birth contributes +1, odd birth contributes -1.
    """
    return sum(1 if b % 2 == 0 else -1 for b, _ in barcode)


def barcode_rank_function(barcode: List[Tuple[int, int]], t: int) -> int:
    """Count intervals alive at filtration level t."""
    return sum(1 for b, d in barcode if b <= t and (d == 0 or t < d))


# ── Algorithm 3: Pell Separation Test ─────────────────────────────────

def is_prime(n: int) -> bool:
    """Primality test. O(√n) time."""
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True


def primes_up_to(n: int) -> List[int]:
    """Sieve of Eratosthenes. O(n log log n) time."""
    if n < 2: return []
    sieve = [True] * (n + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(n**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, n + 1, i):
                sieve[j] = False
    return [i for i in range(2, n + 1) if sieve[i]]


def quadratic_residue_signature(d: int, prime_bound: int) -> Dict[int, int]:
    """
    Compute the quadratic residue signature of d:
    for each prime p ≤ prime_bound, count #{x ∈ F_p : x² ≡ d (mod p)}.

    Args:
        d: The integer to analyze
        prime_bound: Upper bound for primes

    Returns:
        Dict mapping prime -> count of square roots of d mod p

    Time complexity: O(π(B) * B) where B = prime_bound
    """
    primes = primes_up_to(prime_bound)
    return {p: sum(1 for x in range(p) if (x*x) % p == d % p) for p in primes}


def test_pell_separation(
    d_values: List[int],
    prime_bound: int
) -> Tuple[int, int, List[Tuple[int, int]]]:
    """
    Test the Pell separation conjecture: for distinct squarefree d₁ ≠ d₂,
    does there exist a prime p where the quadratic residue counts differ?

    Returns:
        (separated_count, total_pairs, unseparated_pairs)

    Time complexity: O(|D|² * π(B) * B) where D = d_values, B = prime_bound
    """
    signatures = {d: quadratic_residue_signature(d, prime_bound) for d in d_values}

    separated = 0
    total = 0
    unseparated = []

    for i, d1 in enumerate(d_values):
        for d2 in d_values[i+1:]:
            total += 1
            sig1 = signatures[d1]
            sig2 = signatures[d2]

            if any(sig1[p] != sig2[p] for p in sig1):
                separated += 1
            else:
                unseparated.append((d1, d2))

    return separated, total, unseparated


# ── Algorithm 4: Mod-9 Obstruction Classifier ─────────────────────────

def mod9_persistence(n: int) -> int:
    """
    Compute the mod-9 persistence indicator.
    Returns 0 if n ≡ 4 or 5 (mod 9), else 1.

    This implements the formal definition from the Lean proof:
    integers with vanishing persistence cannot be sums of three cubes.
    """
    return 0 if n % 9 in (4, 5) else 1


def classify_sum_three_cubes(n_max: int) -> Dict[str, List[int]]:
    """
    Classify integers up to n_max by their sum-of-three-cubes status.

    Returns dict with keys:
        'obstructed': n ≡ 4, 5 (mod 9), provably not representable
        'candidate': all other residues, potentially representable
    """
    result = {'obstructed': [], 'candidate': []}
    for n in range(1, n_max + 1):
        if mod9_persistence(n) == 0:
            result['obstructed'].append(n)
        else:
            result['candidate'].append(n)
    return result


# ── Algorithm 5: Bottleneck Distance ──────────────────────────────────

def bottleneck_distance(
    barcode1: List[Tuple[int, int]],
    barcode2: List[Tuple[int, int]]
) -> float:
    """
    Compute an approximation of the bottleneck distance between two barcodes.

    Uses a greedy matching approach (not optimal, but fast).

    Time complexity: O(n * m) where n, m are barcode sizes
    Space complexity: O(n + m)
    """
    # Augment with diagonal projections
    def diagonal_cost(interval):
        b, d = interval
        return (d - b) / 2.0

    intervals1 = list(barcode1)
    intervals2 = list(barcode2)

    # Greedy matching
    used2 = set()
    max_cost = 0.0

    for i, (b1, d1) in enumerate(intervals1):
        best_cost = diagonal_cost((b1, d1))  # cost of matching to diagonal
        best_j = -1

        for j, (b2, d2) in enumerate(intervals2):
            if j in used2:
                continue
            cost = max(abs(b1 - b2), abs(d1 - d2))
            if cost < best_cost:
                best_cost = cost
                best_j = j

        if best_j >= 0:
            used2.add(best_j)
        max_cost = max(max_cost, best_cost)

    # Unmatched intervals in barcode2
    for j, (b2, d2) in enumerate(intervals2):
        if j not in used2:
            max_cost = max(max_cost, diagonal_cost((b2, d2)))

    return max_cost


# ── Algorithm 6: Prime Signature Family ───────────────────────────────

def compute_signature_family(
    d: int,
    prime_bound: int
) -> Dict[int, List[Tuple[int, int]]]:
    """
    Compute the primewise persistence signature family for a Pell conic.

    For each good prime p, compute the Frobenius orbit barcode of x²-dy²=1.

    Returns: Dict mapping prime -> barcode (list of intervals)
    """
    primes = [p for p in primes_up_to(prime_bound) if p != 2 and d % p != 0]
    family = {}

    for p in primes:
        points = pell_conic_points(d, p)
        orbit_sizes = [1] * len(points)  # Frobenius is identity over F_p
        family[p] = orbits_to_barcode(orbit_sizes)

    return family


# ── Example Usage ─────────────────────────────────────────────────────

if __name__ == "__main__":
    # Example 1: Orbit computation
    print("Algorithm 1: Frobenius orbits for x² - 2y² = 1 mod 7")
    points = pell_conic_points(2, 7)
    print(f"  Points: {points}")
    print(f"  Orbit sizes: {[1] * len(points)}")

    # Example 2: Barcode construction
    print("\nAlgorithm 2: Barcode from orbits [1, 2, 3, 1, 5]")
    barcode = orbits_to_barcode([1, 2, 3, 1, 5])
    print(f"  Barcode: {barcode}")
    print(f"  Total persistence: {barcode_total_persistence(barcode)}")
    print(f"  Euler characteristic: {barcode_euler_characteristic(barcode)}")

    # Example 3: Pell separation
    print("\nAlgorithm 3: Pell separation test")
    sep, total, unsep = test_pell_separation([2, 3, 5, 6, 7, 10], 50)
    print(f"  {sep}/{total} pairs separated")
    if unsep:
        print(f"  Unseparated: {unsep}")

    # Example 4: Mod-9 classification
    print("\nAlgorithm 4: Mod-9 classification up to 30")
    classes = classify_sum_three_cubes(30)
    print(f"  Obstructed: {classes['obstructed']}")

    # Example 5: Bottleneck distance
    print("\nAlgorithm 5: Bottleneck distance")
    b1 = [(0, 3), (0, 1), (0, 5)]
    b2 = [(0, 2), (0, 1), (0, 4)]
    print(f"  d_B({b1}, {b2}) = {bottleneck_distance(b1, b2)}")

    # Example 6: Signature family
    print("\nAlgorithm 6: Signature family for d=2, primes ≤ 20")
    family = compute_signature_family(2, 20)
    for p, bc in sorted(family.items()):
        print(f"  p={p}: {len(bc)} intervals, "
              f"total_pers={barcode_total_persistence(bc)}")
