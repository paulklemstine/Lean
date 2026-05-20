#!/usr/bin/env python3
"""
Applications of the Erdős–Szekeres theory to computational geometry.

Demonstrates:
1. Convex polygon detection in point clouds
2. Order type classification
3. Extremal configuration search
4. Energy landscape computation for order types
"""

import random
import math
from itertools import combinations, permutations
from typing import List, Tuple, Optional, Set
from algorithms import orient, compute_cup_cap_lengths, cups_caps_bound

Point = Tuple[float, float]


def compute_order_type(points: List[Point]) -> Tuple[int, ...]:
    """Compute the order type (chirotope) of a point set.

    The order type records the sign of orient(p_i, p_j, p_k)
    for all ordered triples i < j < k.

    Returns tuple of signs (+1, -1) for each triple.
    """
    n = len(points)
    signs = []
    for i, j, k in combinations(range(n), 3):
        o = orient(points[i], points[j], points[k])
        signs.append(1 if o > 0 else -1)
    return tuple(signs)


def count_convex_subsets(points: List[Point], size: int) -> int:
    """Count the number of convex subsets of given size.

    A subset is convex if all triples have the same orient sign
    (ordered convex position = cup or cap).
    """
    n = len(points)
    count = 0
    for subset in combinations(range(n), size):
        pts = [points[i] for i in subset]
        if len(pts) < 3:
            count += 1
            continue
        signs = set()
        all_consistent = True
        for i, j, k in combinations(range(len(pts)), 3):
            o = orient(pts[i], pts[j], pts[k])
            s = 1 if o > 0 else -1
            signs.add(s)
            if len(signs) > 1:
                all_consistent = False
                break
        if all_consistent:
            count += 1
    return count


def geometric_convex_subsets(points: List[Point], size: int) -> int:
    """Count subsets in geometric convex position (every point on convex hull).

    This is weaker than ordered convex position.
    """
    from functools import reduce
    n = len(points)
    count = 0
    for subset in combinations(range(n), size):
        pts = [points[i] for i in subset]
        # Check if all points are on convex hull
        hull = convex_hull(pts)
        if len(hull) == len(pts):
            count += 1
    return count


def convex_hull(points: List[Point]) -> List[Point]:
    """Compute convex hull using Andrew's monotone chain algorithm."""
    pts = sorted(points)
    if len(pts) <= 1:
        return pts

    # Build lower hull
    lower = []
    for p in pts:
        while len(lower) >= 2 and orient(lower[-2], lower[-1], p) <= 0:
            lower.pop()
        lower.append(p)

    # Build upper hull
    upper = []
    for p in reversed(pts):
        while len(upper) >= 2 and orient(upper[-2], upper[-1], p) <= 0:
            upper.pop()
        upper.append(p)

    return lower[:-1] + upper[:-1]


def signature_energy(points: List[Point]) -> float:
    """Compute an 'energy' of a point configuration based on signatures.

    Lower energy = more extremal (harder to find convex polygons).
    Energy is defined as the sum of (cupLen * capLen) over all points,
    normalized by the number of points.

    This connects to statistical physics: extremal configurations
    (those avoiding large convex subsets) have low energy.
    """
    sigs = compute_cup_cap_lengths(points)
    n = len(points)
    if n == 0:
        return 0.0
    return sum(c * d for c, d in sigs) / n


def search_extremal_config(n: int, target_cup: int, target_cap: int,
                           num_trials: int = 10000,
                           seed: int = 42) -> Optional[List[Point]]:
    """Search for a point configuration avoiding target-cup and target-cap.

    Uses random search with perturbation to find configurations
    with no cup of length target_cup and no cap of length target_cap.

    This is the computational side of the Erdős–Szekeres problem:
    finding extremal configurations that avoid convex subsets.
    """
    rng = random.Random(seed)
    best_config = None
    best_score = float('inf')

    for trial in range(num_trials):
        # Generate random points
        pts = [(rng.uniform(-10, 10), rng.uniform(-10, 10)) for _ in range(n)]
        pts.sort(key=lambda p: p[0])

        sigs = compute_cup_cap_lengths(pts)
        max_cup = max(c for c, d in sigs)
        max_cap = max(d for c, d in sigs)

        score = max(0, max_cup - target_cup + 1) + max(0, max_cap - target_cap + 1)

        if score < best_score:
            best_score = score
            best_config = pts[:]

        if score == 0:
            return best_config

    return best_config if best_score == 0 else None


def demo_applications():
    """Demonstrate applications of the Erdős–Szekeres theory."""
    print("=" * 70)
    print("APPLICATIONS OF ERDŐS–SZEKERES THEORY")
    print("=" * 70)

    # Application 1: Order type analysis
    print("\n--- Application 1: Order Type Analysis ---")
    random.seed(42)
    for n in [4, 5]:
        pts = sorted(
            [(random.uniform(-5, 5), random.uniform(-5, 5)) for _ in range(n)],
            key=lambda p: p[0]
        )
        ot = compute_order_type(pts)
        print(f"  {n} points: order type = {ot}")
        sigs = compute_cup_cap_lengths(pts)
        print(f"  Signatures: {sigs}")

    # Application 2: Convex subset counting
    print("\n--- Application 2: Convex Subset Counting ---")
    for n in [5, 6, 7, 8]:
        random.seed(n * 13)
        pts = sorted(
            [(random.uniform(-5, 5), random.uniform(-5, 5)) for _ in range(n)],
            key=lambda p: p[0]
        )
        for k in range(3, min(n + 1, 6)):
            ordered = count_convex_subsets(pts, k)
            geo = geometric_convex_subsets(pts, k)
            print(f"  n={n}, k={k}: ordered convex={ordered}, "
                  f"geometric convex={geo}")

    # Application 3: Energy landscape
    print("\n--- Application 3: Signature Energy Landscape ---")
    energies = []
    for trial in range(100):
        random.seed(trial)
        pts = sorted(
            [(random.uniform(-5, 5), random.uniform(-5, 5)) for _ in range(8)],
            key=lambda p: p[0]
        )
        e = signature_energy(pts)
        energies.append(e)
    energies.sort()
    print(f"  Energy statistics for 8-point configurations:")
    print(f"    Min:    {energies[0]:.3f}")
    print(f"    Median: {energies[len(energies)//2]:.3f}")
    print(f"    Max:    {energies[-1]:.3f}")
    print(f"    Mean:   {sum(energies)/len(energies):.3f}")

    # Application 4: Extremal configuration search
    print("\n--- Application 4: Extremal Configuration Search ---")
    for r, s in [(3, 3), (3, 4), (4, 4)]:
        bound = cups_caps_bound(r, s)
        n_test = bound - 1
        result = search_extremal_config(n_test, r, s, num_trials=5000)
        if result:
            sigs = compute_cup_cap_lengths(result)
            max_c = max(c for c, d in sigs)
            max_d = max(d for c, d in sigs)
            print(f"  Avoiding {r}-cup and {s}-cap with {n_test} points: "
                  f"FOUND (max_cup={max_c}, max_cap={max_d})")
        else:
            print(f"  Avoiding {r}-cup and {s}-cap with {n_test} points: "
                  f"NOT FOUND")

    # Application 5: Comparison of bounds
    print("\n--- Application 5: Bound Comparison ---")
    print("  n | Cups-Caps Bound | ES Conjecture (2^(n-2)+1)")
    print("  --+----------------+-------------------------")
    for n in range(3, 12):
        cc = cups_caps_bound(n, n)
        es_conj = 2**(n-2) + 1
        print(f"  {n:2d} | {cc:14d} | {es_conj:23d}")


if __name__ == "__main__":
    demo_applications()


#!/usr/bin/env python3
"""
Interactive demonstration of the Erdős–Szekeres Happy End Problem.

This script:
1. Generates random planar points in general position
2. Sorts them by x-coordinate
3. Computes cup/cap lengths and convex chain signatures
4. Finds and highlights convex polygons (cups/caps)
5. Tests the signature rigidity conjecture on small examples
"""

import random
import math
from itertools import combinations
from typing import List, Tuple, Optional

Point = Tuple[float, float]


def orient(a: Point, b: Point, c: Point) -> float:
    """Signed area × 2 of triangle abc. Positive = CCW, negative = CW."""
    return (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])


def is_general_position(points: List[Point], tol: float = 1e-9) -> bool:
    """Check if no three points are collinear."""
    n = len(points)
    for i, j, k in combinations(range(n), 3):
        if abs(orient(points[i], points[j], points[k])) < tol:
            return False
    return True


def generate_gp_points(n: int, seed: Optional[int] = None) -> List[Point]:
    """Generate n points in general position with distinct x-coordinates."""
    rng = random.Random(seed)
    while True:
        pts = [(rng.uniform(-10, 10), rng.uniform(-10, 10)) for _ in range(n)]
        # Ensure distinct x-coordinates
        xs = [p[0] for p in pts]
        if len(set(round(x, 6) for x in xs)) == n and is_general_position(pts):
            pts.sort(key=lambda p: p[0])
            return pts


def find_longest_cup(points: List[Point]) -> List[int]:
    """Find the longest cup (consecutive triples positive orient) via DP."""
    n = len(points)
    if n <= 1:
        return list(range(n))
    # dp[i] = (max cup length ending at i, predecessor index)
    dp = [(1, -1)] * n
    for j in range(1, n):
        dp[j] = (2, 0)  # pair (points[0], points[j]) is a 2-cup
        for i in range(j):
            if dp[i][0] >= 2:
                # Check if we can extend the cup ending at i
                pred = dp[i][1]
                # Find the second-to-last point of the cup ending at i
                # For simplicity, track the predecessor chain
                pass
    # Simplified: find longest cup by DP on slopes
    best_cup = [0]
    for i in range(1, n):
        # Try to extend existing cups
        for cup in [best_cup]:
            if len(cup) < 2 or orient(points[cup[-2]], points[cup[-1]], points[i]) > 0:
                new_cup = cup + [i]
                if len(new_cup) > len(best_cup):
                    best_cup = new_cup
    return best_cup


def compute_cup_len(points: List[Point], idx: int) -> int:
    """Compute maximum cup length ending at points[idx] using DP."""
    n = len(points)
    # dp[i] = max cup length ending at index i
    dp = [1] * n
    prev = [-1] * n
    for j in range(1, n):
        # Pair (any earlier point, j) is a 2-cup
        dp[j] = 2
        for i in range(j):
            if dp[i] >= 2 and prev[i] >= 0:
                if orient(points[prev[i]], points[i], points[j]) > 0:
                    if dp[i] + 1 > dp[j]:
                        dp[j] = dp[i] + 1
                        prev[j] = i
            elif dp[i] == 1:
                if dp[j] < 2:
                    dp[j] = 2
                    prev[j] = i
    return dp[idx]


def compute_signatures(points: List[Point]) -> List[Tuple[int, int]]:
    """Compute convex chain signatures (cupLen, capLen) for each point.

    Uses dynamic programming to find the longest cup and cap ending
    at each point. A cup has increasing slopes (positive orient for
    consecutive triples), a cap has decreasing slopes.
    """
    n = len(points)
    cup_len = [1] * n
    cap_len = [1] * n
    cup_prev = [-1] * n  # second-to-last index in best cup
    cap_prev = [-1] * n

    for j in range(1, n):
        for i in range(j):
            # Try extending cups ending at i by j
            if cup_len[i] == 1:
                # Pair (i, j) is a 2-cup, always
                if cup_len[j] < 2:
                    cup_len[j] = 2
                    cup_prev[j] = i
            elif cup_prev[i] >= 0:
                if orient(points[cup_prev[i]], points[i], points[j]) > 0:
                    if cup_len[i] + 1 > cup_len[j]:
                        cup_len[j] = cup_len[i] + 1
                        cup_prev[j] = i

            # Try extending caps ending at i by j
            if cap_len[i] == 1:
                if cap_len[j] < 2:
                    cap_len[j] = 2
                    cap_prev[j] = i
            elif cap_prev[i] >= 0:
                if orient(points[cap_prev[i]], points[i], points[j]) < 0:
                    if cap_len[i] + 1 > cap_len[j]:
                        cap_len[j] = cap_len[i] + 1
                        cap_prev[j] = i

    return list(zip(cup_len, cap_len))


def find_cup_or_cap(points: List[Point], min_len: int = 3) -> Optional[Tuple[str, List[int]]]:
    """Find a cup or cap of length >= min_len, returning type and indices."""
    n = len(points)
    sigs = compute_signatures(points)

    # Find point with longest cup
    best_cup_idx = max(range(n), key=lambda i: sigs[i][0])
    best_cap_idx = max(range(n), key=lambda i: sigs[i][1])

    if sigs[best_cup_idx][0] >= min_len:
        # Reconstruct cup
        return ("cup", reconstruct_chain(points, best_cup_idx, "cup"))
    if sigs[best_cap_idx][1] >= min_len:
        return ("cap", reconstruct_chain(points, best_cap_idx, "cap"))
    return None


def reconstruct_chain(points: List[Point], end_idx: int, chain_type: str) -> List[int]:
    """Reconstruct a cup or cap ending at end_idx by backtracking."""
    n = len(points)
    # Recompute with full tracking
    if chain_type == "cup":
        dp = [1] * n
        prev = [-1] * n
        for j in range(1, n):
            for i in range(j):
                can_extend = False
                if dp[i] == 1:
                    can_extend = True
                elif prev[i] >= 0:
                    can_extend = orient(points[prev[i]], points[i], points[j]) > 0
                if can_extend and dp[i] + 1 > dp[j]:
                    dp[j] = dp[i] + 1
                    prev[j] = i
    else:
        dp = [1] * n
        prev = [-1] * n
        for j in range(1, n):
            for i in range(j):
                can_extend = False
                if dp[i] == 1:
                    can_extend = True
                elif prev[i] >= 0:
                    can_extend = orient(points[prev[i]], points[i], points[j]) < 0
                if can_extend and dp[i] + 1 > dp[j]:
                    dp[j] = dp[i] + 1
                    prev[j] = i

    # Backtrack from end_idx
    chain = []
    idx = end_idx
    while idx >= 0:
        chain.append(idx)
        idx = prev[idx]
    chain.reverse()
    return chain


def is_ordered_convex(points: List[Point], indices: List[int]) -> bool:
    """Check if the indexed points form an ordered convex polygon
    (all triples have consistent orientation sign)."""
    if len(indices) < 3:
        return True
    pts = [points[i] for i in indices]
    sign = None
    for i, j, k in combinations(range(len(pts)), 3):
        o = orient(pts[i], pts[j], pts[k])
        if sign is None:
            sign = 1 if o > 0 else -1
        elif (o > 0 and sign < 0) or (o < 0 and sign > 0):
            return False
    return True


def test_signature_rigidity(n: int, num_trials: int = 1000) -> bool:
    """Test the signature rigidity conjecture for configurations of size n.

    Conjecture: In configurations with no ordered convex n-gon,
    if cup length increases from point i to j, then cap length decreases.
    """
    violations = 0
    for trial in range(num_trials):
        pts = generate_gp_points(n, seed=trial * 137 + 42)
        sigs = compute_signatures(pts)

        # Check if there's an ordered convex n-gon
        has_convex = False
        for indices in combinations(range(n), n):
            if is_ordered_convex(pts, list(indices)):
                has_convex = True
                break

        if has_convex:
            continue

        # Test staircase property
        for i in range(n):
            for j in range(i + 1, n):
                if sigs[i][0] < sigs[j][0] and sigs[j][1] > sigs[i][1]:
                    violations += 1

    return violations == 0


def cups_caps_bound(r: int, s: int) -> int:
    """Compute the cups-caps extremal bound C(r+s-4, r-2) + 1."""
    if r < 2 or s < 2:
        return 2
    return math.comb(r + s - 4, r - 2) + 1


def demo_main():
    """Main demonstration."""
    print("=" * 70)
    print("THE HAPPY END PROBLEM — Erdős–Szekeres Convex Polygon Theorem")
    print("=" * 70)

    # Demo 1: Small configuration
    print("\n--- Demo 1: Convex Chain Signatures ---")
    pts = generate_gp_points(8, seed=42)
    print(f"Generated {len(pts)} points in general position:")
    for i, p in enumerate(pts):
        print(f"  p[{i}] = ({p[0]:.3f}, {p[1]:.3f})")

    sigs = compute_signatures(pts)
    print("\nConvex Chain Signatures (cupLen, capLen):")
    for i, (c, d) in enumerate(sigs):
        print(f"  p[{i}]: cup={c}, cap={d}, signature=({c},{d})")

    # Demo 2: Find cups and caps
    print("\n--- Demo 2: Cup/Cap Detection ---")
    result = find_cup_or_cap(pts, min_len=3)
    if result:
        chain_type, indices = result
        print(f"Found a {len(indices)}-{chain_type}: indices {indices}")
        chain_pts = [pts[i] for i in indices]
        print("Points:", [(f"({p[0]:.3f}, {p[1]:.3f})") for p in chain_pts])
        print(f"Ordered convex: {is_ordered_convex(pts, indices)}")
    else:
        print("No cup or cap of length ≥ 3 found.")

    # Demo 3: Cups-caps bounds
    print("\n--- Demo 3: Cups-Caps Extremal Bounds ---")
    print("f(r,s) = C(r+s-4, r-2) + 1:")
    for r in range(2, 8):
        row = [str(cups_caps_bound(r, s)).rjust(6) for s in range(2, 8)]
        print(f"  r={r}: {' '.join(row)}")

    # Demo 4: Verify forcing on random configurations
    print("\n--- Demo 4: Forcing Verification ---")
    for r, s in [(3, 3), (3, 4), (4, 4), (3, 5)]:
        B = cups_caps_bound(r, s)
        success = 0
        trials = 100
        for trial in range(trials):
            pts = generate_gp_points(B, seed=trial * 31 + r * 7 + s)
            sigs = compute_signatures(pts)
            max_cup = max(c for c, d in sigs)
            max_cap = max(d for c, d in sigs)
            if max_cup >= r or max_cap >= s:
                success += 1
        print(f"  f({r},{s})={B}: {success}/{trials} configurations "
              f"have {r}-cup or {s}-cap")

    # Demo 5: Signature rigidity test
    print("\n--- Demo 5: Signature Rigidity Conjecture ---")
    for n in range(4, 8):
        rigid = test_signature_rigidity(n, num_trials=200)
        status = "HOLDS" if rigid else "VIOLATED"
        print(f"  n={n}: Staircase property {status}")

    # Demo 6: Happy End bounds
    print("\n--- Demo 6: Happy End Bounds ---")
    print("Upper bounds on ES(n) via cups-caps:")
    for n in range(3, 10):
        bound = cups_caps_bound(n, n)
        print(f"  ES({n}) ≤ f({n},{n}) = C({2*n-4},{n-2})+1 = {bound}")


if __name__ == "__main__":
    demo_main()
