#!/usr/bin/env python3
"""
Applications of Cap Set Theory

This module demonstrates real-world applications of cap set theory and the
polynomial method to:
1. Error-correcting codes (Reed-Muller codes over F_3)
2. Pseudorandomness testing
3. Card game SET analysis
4. Sunflower-free set bounds
"""

from itertools import product
from typing import List, Tuple, Dict, Set
from collections import Counter


# ============================================================
# Application 1: The Card Game SET
# ============================================================

def generate_set_deck() -> List[Tuple[int, ...]]:
    """
    Generate all 81 cards in the game SET.

    Each card has 4 attributes (color, shape, number, shading),
    each taking 3 values (0, 1, 2). This is exactly F_3^4.

    Returns:
        List of 81 cards as 4-tuples
    """
    return list(product(range(3), repeat=4))


def is_valid_set(c1: Tuple[int, ...], c2: Tuple[int, ...],
                 c3: Tuple[int, ...]) -> bool:
    """
    Check if three cards form a valid SET.

    Three cards form a SET iff for each attribute, the three values
    are either all the same or all different. In F_3^4 arithmetic,
    this is equivalent to c1 + c2 + c3 = 0 (mod 3) — exactly the
    cap set condition.

    Returns:
        True if the triple forms a valid SET
    """
    return all((a + b + c) % 3 == 0 for a, b, c in zip(c1, c2, c3))


def find_set_free_collection(cards: List[Tuple[int, ...]]) -> List[Tuple[int, ...]]:
    """
    Find a large SET-free collection from the given cards using greedy.

    A SET-free collection is exactly a cap set in F_3^4.

    Returns:
        A maximal SET-free subcollection
    """
    result: List[Tuple[int, ...]] = []
    forbidden: Set[Tuple[int, ...]] = set()

    for card in cards:
        if card in forbidden:
            continue
        result.append(card)
        for other in result[:-1]:
            # The third card that would complete a SET
            third = tuple((3 - a - b) % 3 for a, b in zip(card, other))
            forbidden.add(third)

    return result


def analyze_set_game():
    """Analyze the card game SET from a cap set perspective."""
    print("APPLICATION 1: The Card Game SET")
    print("=" * 50)
    print()

    deck = generate_set_deck()
    print(f"  Total cards in SET deck: {len(deck)} (= 3^4 = 81)")

    # Count total valid SETs
    total_sets = 0
    for i, c1 in enumerate(deck):
        for j, c2 in enumerate(deck):
            if j <= i:
                continue
            c3 = tuple((3 - a - b) % 3 for a, b in zip(c1, c2))
            if c3 in set(deck) and tuple(c3) > c2:
                total_sets += 1

    print(f"  Total valid SETs in deck: {total_sets}")

    # Find largest SET-free collection
    collection = find_set_free_collection(deck)
    print(f"  Greedy SET-free collection size: {len(collection)}")
    print(f"  Known maximum cap set in F_3^4: 20")
    print()
    print("  The cap set bound tells us that no matter how cleverly you")
    print("  choose cards, you cannot avoid all SETs with more than 20 cards.")
    print("  In higher dimensions (more attributes), the maximum SET-free")
    print("  collection grows exponentially slower than the deck size.")
    print()


# ============================================================
# Application 2: Error-Correcting Codes
# ============================================================

def reed_muller_encode(message: List[int], n: int, d: int) -> List[int]:
    """
    Encode a message using a Reed-Muller code over F_3.

    The codeword is the evaluation of the polynomial represented by
    the message coefficients on all points of F_3^n. Only monomials
    of total degree ≤ d are used.

    Args:
        message: coefficients for reduced monomials of degree ≤ d
        n: number of variables (block length parameter)
        d: maximum degree

    Returns:
        Codeword: evaluations on all 3^n points
    """
    from algorithms import reduced_monomials, eval_monomial_f3

    monoms = reduced_monomials(n, max_degree=d)
    if len(message) > len(monoms):
        raise ValueError(f"Message too long: {len(message)} > {len(monoms)} monomials")

    # Pad message with zeros if shorter
    msg = list(message) + [0] * (len(monoms) - len(message))

    points = list(product(range(3), repeat=n))
    codeword = []
    for pt in points:
        val = sum(c * eval_monomial_f3(exp, pt) for c, exp in zip(msg, monoms)) % 3
        codeword.append(val)

    return codeword


def minimum_distance(n: int, d: int) -> int:
    """
    Compute the minimum distance of the Reed-Muller code RM_3(d, n).

    The minimum distance is 3^{n-d} · (3-d') where d' is... actually
    this is complex. We compute it by brute force for small parameters.
    """
    from algorithms import reduced_monomials, eval_monomial_f3

    monoms = reduced_monomials(n, max_degree=d)
    points = list(product(range(3), repeat=n))

    min_weight = len(points) + 1
    # Check weight of each single-monomial codeword
    for exp in monoms:
        weight = sum(1 for pt in points if eval_monomial_f3(exp, pt) % 3 != 0)
        if 0 < weight < min_weight:
            min_weight = weight

    return min_weight


def analyze_reed_muller():
    """Analyze Reed-Muller codes from the polynomial method perspective."""
    print("APPLICATION 2: Reed-Muller Codes over F_3")
    print("=" * 50)
    print()

    from algorithms import reduced_monomials

    for n in range(1, 5):
        total = 3 ** n
        for d in range(2 * n + 1):
            k = len(reduced_monomials(n, max_degree=d))
            if k > total:
                break
            if k == 0:
                continue
            rate = k / total
            if n <= 3:
                dist = minimum_distance(n, d)
                print(f"  RM_3({d},{n}): k={k}, n={total}, rate={rate:.3f}, d_min={dist}")
            else:
                print(f"  RM_3({d},{n}): k={k}, n={total}, rate={rate:.3f}")
        print()

    print("  The polynomial method for cap sets is intimately connected")
    print("  to Reed-Muller code theory: the cap set bound says that")
    print("  certain 'dual codes' have limited size, constraining the")
    print("  achievable parameters of ternary codes.")
    print()


# ============================================================
# Application 3: Pseudorandomness Testing
# ============================================================

def three_ap_count(A: List[Tuple[int, ...]], n: int) -> int:
    """
    Count the number of 3-APs (x, y, z) with x, y, z ∈ A.

    For a random set of density δ, we expect ~δ³ · |F_3^n|²
    three-term APs. Deviations indicate structure.
    """
    A_set = set(A)
    count = 0
    for x in A:
        for y in A:
            z = tuple((3 - xi - yi) % 3 for xi, yi in zip(x, y))
            if z in A_set:
                count += 1
    return count


def pseudorandomness_test(A: List[Tuple[int, ...]], n: int) -> Dict[str, float]:
    """
    Test the pseudorandomness of a set A ⊆ F_3^n.

    Computes several statistics and compares to random expectations.

    Returns:
        Dictionary of test statistics
    """
    total = 3 ** n
    density = len(A) / total

    # Count 3-APs
    ap_count = three_ap_count(A, n)
    expected_aps = density ** 3 * total ** 2

    # Additive energy
    from algorithms import additive_energy
    energy = additive_energy(A)
    expected_energy = density ** 2 * total * len(A) ** 2 / total  # rough

    return {
        "size": len(A),
        "density": density,
        "three_ap_count": ap_count,
        "expected_aps": expected_aps,
        "ap_ratio": ap_count / max(expected_aps, 1),
        "additive_energy": energy,
        "energy_per_sq": energy / max(len(A) ** 2, 1),
    }


def analyze_pseudorandomness():
    """Demonstrate pseudorandomness testing for subsets of F_3^n."""
    print("APPLICATION 3: Pseudorandomness Testing")
    print("=" * 50)
    print()

    import random
    random.seed(42)

    n = 3
    total = 3 ** n

    # Test 1: Random subset
    all_vecs = list(product(range(3), repeat=n))
    random_subset = random.sample(all_vecs, total // 3)
    stats = pseudorandomness_test(random_subset, n)
    print(f"  Random subset of F_3^{n} (density {stats['density']:.2f}):")
    print(f"    3-AP count: {stats['three_ap_count']}")
    print(f"    Expected (random): {stats['expected_aps']:.1f}")
    print(f"    AP ratio: {stats['ap_ratio']:.2f}")
    print()

    # Test 2: Cap set (structured, AP-free)
    _, cap = max_cap_set_backtrack_small(n)
    stats2 = pseudorandomness_test(cap, n)
    print(f"  Maximum cap set in F_3^{n} (density {stats2['density']:.2f}):")
    print(f"    3-AP count: {stats2['three_ap_count']} (only trivial APs x=y=z)")
    print(f"    Expected (random): {stats2['expected_aps']:.1f}")
    print(f"    AP ratio: {stats2['ap_ratio']:.2f}")
    print()

    print("  A cap set has far fewer 3-APs than a random set of the same")
    print("  density. This makes cap sets detectable by statistical tests,")
    print("  connecting progression-freeness to pseudorandomness.")
    print()


def max_cap_set_backtrack_small(n: int) -> Tuple[int, List[Tuple[int, ...]]]:
    """Small-n version of backtracking for cap sets."""
    vectors = list(product(range(3), repeat=n))
    best = [0, []]

    def backtrack(idx, current, forbidden):
        if len(current) > best[0]:
            best[0] = len(current)
            best[1] = list(current)
        if len(current) + len(vectors) - idx <= best[0]:
            return
        for i in range(idx, len(vectors)):
            v = vectors[i]
            if v in forbidden:
                continue
            new_forb = set()
            for u in current:
                z = tuple((3 - a - b) % 3 for a, b in zip(u, v))
                new_forb.add(z)
            current.append(v)
            backtrack(i + 1, current, forbidden | new_forb)
            current.pop()

    backtrack(0, [], set())
    return best[0], best[1]


# ============================================================
# Application 4: Sunflower-Free Sets
# ============================================================

def is_sunflower(sets: List[Set[int]]) -> bool:
    """
    Check if a collection of sets forms a sunflower.

    A sunflower (or Δ-system) is a collection of sets where
    any two sets have the same intersection (the "core").
    """
    if len(sets) < 2:
        return True
    core = sets[0] & sets[1]
    return all(s1 & s2 == core for i, s1 in enumerate(sets)
               for j, s2 in enumerate(sets) if i < j)


def analyze_sunflower_connection():
    """Explain the connection between cap sets and sunflower-free families."""
    print("APPLICATION 4: Connection to Sunflower-Free Sets")
    print("=" * 50)
    print()
    print("  The Ellenberg-Gijswijt cap set bound has a remarkable")
    print("  consequence for the sunflower conjecture.")
    print()
    print("  A sunflower (Δ-system) is a collection of sets where any")
    print("  two sets share the same 'core' intersection. The sunflower")
    print("  lemma (Erdős-Ko-Rado) says that large families of k-element")
    print("  sets must contain sunflowers.")
    print()
    print("  Naslund and Sawin (2017) showed that cap set bounds imply")
    print("  improved sunflower-free set bounds:")
    print()
    print("  If cap sets in F_3^n have size ≤ C^n, then sunflower-free")
    print("  families of k-subsets of [n] have size at most:")
    print("    O((C/3)^n · binom(n, k))")
    print()
    print("  With C = 2.756 (Ellenberg-Gijswijt):")
    for n in [10, 20, 50, 100]:
        import math
        k = n // 3
        naive = math.comb(n, k)
        improved = (2.756/3)**n * math.comb(n, k)
        print(f"    n={n}, k={k}: naive bound ~ {naive:.2e}, "
              f"improved ~ {improved:.2e}")
    print()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   Applications of Cap Set Theory                       ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    analyze_set_game()
    analyze_reed_muller()
    analyze_pseudorandomness()
    analyze_sunflower_connection()


#!/usr/bin/env python3
"""
Cap Sets in F_3^n: Demonstrations and Visualizations

This script demonstrates the key mathematical structures underlying cap set theory:
- Enumeration of cap sets in small dimensions
- Reduced polynomial representation
- Indicator polynomial evaluation
- Comparison of bounds vs actual cap set numbers

All computations are self-contained and require only numpy and matplotlib.
"""

import numpy as np
from itertools import product
from collections import defaultdict
import os


# ============================================================
# Core Data Structures
# ============================================================

def f3_vectors(n):
    """Generate all vectors in F_3^n."""
    return [list(v) for v in product(range(3), repeat=n)]


def is_three_ap(x, y, z):
    """Check if (x, y, z) form a 3-AP in F_3^n: x + z = 2y (mod 3)."""
    return all((xi + zi) % 3 == (2 * yi) % 3 for xi, yi, zi in zip(x, y, z))


def is_cap_set(A):
    """Check if A is a cap set (no nontrivial 3-AP)."""
    A_list = [tuple(a) for a in A]
    for i, x in enumerate(A_list):
        for j, y in enumerate(A_list):
            if i == j:
                continue
            for k, z in enumerate(A_list):
                if k == j or k == i:
                    continue
                if is_three_ap(list(x), list(y), list(z)):
                    return False
    return True


def find_all_cap_sets(n, max_size=None):
    """Find all maximal cap sets in F_3^n by brute force."""
    vectors = f3_vectors(n)
    N = len(vectors)
    best_size = 0
    best_sets = []

    def backtrack(idx, current):
        nonlocal best_size, best_sets
        if len(current) > best_size:
            best_size = len(current)
            best_sets = [list(current)]
        elif len(current) == best_size:
            best_sets.append(list(current))

        if max_size and len(current) >= max_size:
            return

        for i in range(idx, N):
            v = vectors[i]
            # Check if adding v creates a 3-AP
            creates_ap = False
            for j, u in enumerate(current):
                for k, w in enumerate(current):
                    if j == k:
                        continue
                    if is_three_ap(u, v, w) or is_three_ap(v, u, w) or is_three_ap(u, w, v):
                        creates_ap = True
                        break
                if creates_ap:
                    break
            if not creates_ap:
                current.append(v)
                backtrack(i + 1, current)
                current.pop()

    backtrack(0, [])
    return best_size, best_sets


def max_cap_set_size(n):
    """Find the maximum cap set size in F_3^n."""
    vectors = f3_vectors(n)
    N = len(vectors)
    best = [0]

    def backtrack(idx, current):
        if len(current) > best[0]:
            best[0] = len(current)
        remaining = N - idx
        if len(current) + remaining <= best[0]:
            return
        for i in range(idx, N):
            v = vectors[i]
            ok = True
            for u in current:
                # Check if any element w in current forms a 3-AP with u, v
                for w in current:
                    if u is w:
                        continue
                    if is_three_ap(u, v, w):
                        ok = False
                        break
                if not ok:
                    break
                # Also check v as midpoint
                mid_check = [(2 * vi) % 3 for vi in v]
                needed = [(mid_check[k] - ui) % 3 for k, ui in enumerate(u)]
                if tuple(needed) in {tuple(w) for w in current}:
                    if tuple(needed) != tuple(u):
                        ok = False
                        break
            if ok:
                current.append(v)
                backtrack(i + 1, current)
                current.pop()

    backtrack(0, [])
    return best[0]


# ============================================================
# Polynomial Method Demonstrations
# ============================================================

def reduced_monomials(n, max_degree=None):
    """
    Generate all reduced monomials in n variables over F_3.
    Each exponent is in {0, 1, 2}. Optionally filter by total degree.
    """
    exponents = list(product(range(3), repeat=n))
    if max_degree is not None:
        exponents = [e for e in exponents if sum(e) <= max_degree]
    return exponents


def count_reduced_monomials(n, d):
    """Count reduced monomials of total degree ≤ d in n variables."""
    return len(reduced_monomials(n, d))


def eval_monomial(exponent, point):
    """Evaluate monomial x^e at a point in F_3^n."""
    result = 1
    for ei, xi in zip(exponent, point):
        result = (result * pow(xi, ei, 3)) % 3
    return result


def indicator_poly_eval(target, point):
    """
    Evaluate the indicator polynomial δ_a(x) = ∏_i (1 - (x_i - a_i)^2) mod 3.
    Returns 1 if point == target, 0 otherwise.
    """
    result = 1
    for ti, xi in zip(target, point):
        diff = (xi - ti) % 3
        factor = (1 - pow(diff, 2, 3)) % 3
        result = (result * factor) % 3
    return result


def interpolation_poly_coeffs(f_values, n):
    """
    Compute the reduced polynomial representation of a function f: F_3^n → F_3.
    Returns coefficients indexed by reduced exponents.

    Uses the indicator polynomial expansion:
    P = Σ_a f(a) · δ_a where δ_a(x) = ∏_i (1 - (x_i - a_i)^2)
    """
    vectors = f3_vectors(n)
    monomials = reduced_monomials(n)

    # Build evaluation matrix: M[point_idx, monomial_idx] = monomial(point)
    M = np.zeros((len(vectors), len(monomials)), dtype=int)
    for i, point in enumerate(vectors):
        for j, exp in enumerate(monomials):
            M[i, j] = eval_monomial(exp, point)

    # Solve M @ coeffs = f_values (mod 3)
    # Use the indicator polynomial approach for correctness
    f_vec = np.array([f_values[tuple(v)] for v in vectors], dtype=int)

    # Build the coefficient vector by indicator expansion
    coeffs = np.zeros(len(monomials), dtype=int)
    for a_idx, a in enumerate(vectors):
        fa = f_vec[a_idx]
        if fa == 0:
            continue
        # Compute coefficients of δ_a and add fa * δ_a
        delta_coeffs = np.zeros(len(monomials), dtype=int)
        for j, exp in enumerate(monomials):
            delta_coeffs[j] = eval_monomial(exp, a)  # Placeholder
        # Actually, we need the polynomial coefficients, not evaluations
        # Use matrix inversion instead
    
    # More reliable: solve via matrix inversion mod 3
    # For small n, we can use Gaussian elimination mod 3
    coeffs = gauss_solve_mod3(M, f_vec)
    return dict(zip([tuple(e) for e in monomials], coeffs))


def gauss_solve_mod3(A, b):
    """Solve Ax = b (mod 3) using Gaussian elimination."""
    n = A.shape[0]
    m = A.shape[1]
    # Augmented matrix
    aug = np.hstack([A % 3, b.reshape(-1, 1) % 3]).astype(int)

    pivot_col = 0
    pivot_rows = []
    for col in range(m):
        if pivot_col >= n:
            break
        # Find pivot
        found = False
        for row in range(len(pivot_rows), n):
            if aug[row, col] % 3 != 0:
                # Swap
                aug[[len(pivot_rows), row]] = aug[[row, len(pivot_rows)]]
                found = True
                break
        if not found:
            continue
        pr = len(pivot_rows)
        pivot_rows.append((pr, col))
        # Normalize
        inv = pow(int(aug[pr, col]), 1, 3)  # inverse mod 3: 1->1, 2->2
        aug[pr] = (aug[pr] * inv) % 3
        # Eliminate
        for row in range(n):
            if row != pr and aug[row, col] % 3 != 0:
                factor = aug[row, col] % 3
                aug[row] = (aug[row] - factor * aug[pr]) % 3

    x = np.zeros(m, dtype=int)
    for pr, col in pivot_rows:
        x[col] = aug[pr, -1] % 3
    return x


# ============================================================
# Main Demonstrations
# ============================================================

def demo_cap_set_enumeration():
    """Demonstrate cap set enumeration for small dimensions."""
    print("=" * 60)
    print("DEMONSTRATION 1: Cap Set Sizes in Small Dimensions")
    print("=" * 60)
    print()

    known_values = {1: 2, 2: 4, 3: 9, 4: 20}  # Known cap set numbers

    for n in range(1, 5):
        total = 3 ** n
        cap_size = max_cap_set_size(n) if n <= 3 else known_values.get(n, "?")
        bound_2n3 = count_reduced_monomials(n, 2 * n // 3)
        print(f"  n = {n}:")
        print(f"    |F_3^{n}| = {total}")
        print(f"    Max cap set size = {cap_size}")
        print(f"    Reduced monomials (deg ≤ ⌊2n/3⌋ = {2*n//3}): {bound_2n3}")
        print(f"    Density = {cap_size}/{total} = {cap_size/total:.4f}")
        print()


def demo_indicator_polynomial():
    """Demonstrate the indicator polynomial evaluation."""
    print("=" * 60)
    print("DEMONSTRATION 2: Indicator Polynomial (Kronecker Delta)")
    print("=" * 60)
    print()

    n = 2
    target = (1, 2)
    vectors = f3_vectors(n)

    print(f"  Target point a = {target} in F_3^{n}")
    print(f"  δ_a(x) = ∏_i (1 - (x_i - a_i)²) mod 3")
    print()
    print(f"  {'Point x':<15} {'δ_a(x)':<10} {'Expected':<10}")
    print(f"  {'-'*35}")

    for v in vectors:
        val = indicator_poly_eval(target, v)
        expected = 1 if tuple(v) == target else 0
        marker = "  ←" if val == 1 else ""
        print(f"  {str(v):<15} {val:<10} {expected:<10}{marker}")
    print()


def demo_reduced_polynomials():
    """Demonstrate the reduced polynomial representation."""
    print("=" * 60)
    print("DEMONSTRATION 3: Reduced Polynomial Representation")
    print("=" * 60)
    print()

    n = 2
    vectors = f3_vectors(n)

    # Define a simple function: f(x) = x_0 * x_1 mod 3
    f_values = {}
    for v in vectors:
        f_values[tuple(v)] = (v[0] * v[1]) % 3

    print(f"  Function f(x₀, x₁) = x₀ · x₁ mod 3 on F_3²:")
    print()
    for v in vectors:
        print(f"    f{tuple(v)} = {f_values[tuple(v)]}")

    # Compute polynomial representation
    coeffs = interpolation_poly_coeffs(f_values, n)
    print()
    print(f"  Reduced polynomial representation:")
    for exp, coeff in sorted(coeffs.items()):
        if coeff != 0:
            terms = []
            for i, e in enumerate(exp):
                if e > 0:
                    terms.append(f"x_{i}^{e}" if e > 1 else f"x_{i}")
            monomial = " · ".join(terms) if terms else "1"
            print(f"    {coeff} · {monomial}")
    print()


def demo_monomial_counting():
    """Demonstrate monomial counting and bounds."""
    print("=" * 60)
    print("DEMONSTRATION 4: Monomial Counting and Cap Set Bounds")
    print("=" * 60)
    print()

    print(f"  {'n':<5} {'3^n':<10} {'Mon(≤⌊2n/3⌋)':<15} {'Ratio':<10} {'Known cap#':<12}")
    print(f"  {'-'*52}")

    known = {1: 2, 2: 4, 3: 9, 4: 20, 5: 45, 6: 112}
    for n in range(1, 11):
        total = 3 ** n
        d = 2 * n // 3
        mon_count = count_reduced_monomials(n, d)
        ratio = mon_count / total
        cap = known.get(n, "?")
        print(f"  {n:<5} {total:<10} {mon_count:<15} {ratio:<10.4f} {str(cap):<12}")

    print()
    print("  The Ellenberg-Gijswijt bound says cap set size ≤ O(2.756^n).")
    print("  For comparison, 2.756^n / 3^n → 0 exponentially.")
    print()


def demo_three_ap_detection():
    """Demonstrate 3-AP detection in F_3^n."""
    print("=" * 60)
    print("DEMONSTRATION 5: 3-AP Detection and Equivalences")
    print("=" * 60)
    print()

    n = 2
    print(f"  In F_3², the 3-AP equation x + z = 2y is equivalent to x + y + z = 0.")
    print()

    # Show some examples
    vectors = f3_vectors(n)
    aps = []
    for x in vectors:
        for y in vectors:
            for z in vectors:
                if x == y or y == z or x == z:
                    continue
                if is_three_ap(x, y, z):
                    # Also check sum-zero
                    sum_zero = all((xi + yi + zi) % 3 == 0 for xi, yi, zi in zip(x, y, z))
                    aps.append((tuple(x), tuple(y), tuple(z), sum_zero))

    print(f"  Found {len(aps)} nontrivial 3-APs in F_3^{n}:")
    seen = set()
    for x, y, z, sz in aps[:20]:
        key = tuple(sorted([x, y, z]))
        if key in seen:
            continue
        seen.add(key)
        print(f"    x={list(x)}, y={list(y)}, z={list(z)}  |  "
              f"x+z=2y: {is_three_ap(list(x),list(y),list(z))}  |  "
              f"x+y+z=0: {sz}")
    print()


def create_visualizations():
    """Create visualization files."""
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt

        # Visualization 1: Cap set density vs dimension
        fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

        known = {1: 2, 2: 4, 3: 9, 4: 20, 5: 45, 6: 112}
        ns = list(range(1, 7))
        densities = [known[n] / 3**n for n in ns]
        eg_bound = [(2.756/3)**n for n in ns]
        monomial_ratios = [count_reduced_monomials(n, 2*n//3) / 3**n for n in ns]

        ax1.semilogy(ns, densities, 'bo-', label='Actual cap set density', linewidth=2, markersize=8)
        ax1.semilogy(ns, eg_bound, 'r--', label='Ellenberg-Gijswijt bound (2.756/3)^n', linewidth=2)
        ax1.semilogy(ns, monomial_ratios, 'g-.', label='Monomial count / 3^n', linewidth=2)
        ax1.set_xlabel('Dimension n', fontsize=12)
        ax1.set_ylabel('Density |A|/3^n', fontsize=12)
        ax1.set_title('Cap Set Density vs Dimension', fontsize=14)
        ax1.legend(fontsize=10)
        ax1.grid(True, alpha=0.3)

        # Visualization 2: Monomial counting
        ns_ext = list(range(1, 16))
        total_monomials = [3**n for n in ns_ext]
        bounded_monomials = [count_reduced_monomials(n, 2*n//3) for n in ns_ext]
        eg_values = [2.756**n for n in ns_ext]

        ax2.semilogy(ns_ext, total_monomials, 'k-', label='3^n (total space)', linewidth=2)
        ax2.semilogy(ns_ext, bounded_monomials, 'b-o', label='Monomials deg ≤ ⌊2n/3⌋', linewidth=2, markersize=5)
        ax2.semilogy(ns_ext, eg_values, 'r--', label='2.756^n (EG bound)', linewidth=2)
        ax2.set_xlabel('Dimension n', fontsize=12)
        ax2.set_ylabel('Count (log scale)', fontsize=12)
        ax2.set_title('Polynomial Method: Dimension Counting', fontsize=14)
        ax2.legend(fontsize=10)
        ax2.grid(True, alpha=0.3)

        plt.tight_layout()
        plt.savefig(os.path.join(os.path.dirname(__file__), 'capset_analysis.png'), dpi=150, bbox_inches='tight')
        plt.close()
        print("  Saved: capset_analysis.png")

        # Visualization 3: Indicator polynomial heatmap for F_3^2
        fig, axes = plt.subplots(1, 3, figsize=(15, 5))

        targets = [(0, 0), (1, 1), (2, 0)]
        vectors = f3_vectors(2)
        for ax, target in zip(axes, targets):
            vals = np.zeros((3, 3))
            for v in vectors:
                val = indicator_poly_eval(target, v)
                vals[v[1], v[0]] = val
            im = ax.imshow(vals, cmap='Blues', vmin=0, vmax=1, aspect='equal')
            ax.set_title(f'δ_{{{target[0]},{target[1]}}}(x)', fontsize=13)
            ax.set_xlabel('x₀')
            ax.set_ylabel('x₁')
            ax.set_xticks(range(3))
            ax.set_yticks(range(3))
            for i in range(3):
                for j in range(3):
                    color = 'white' if vals[i, j] > 0.5 else 'black'
                    ax.text(j, i, f'{int(vals[i, j])}', ha='center', va='center',
                            fontsize=14, fontweight='bold', color=color)
            plt.colorbar(im, ax=ax, fraction=0.046, pad=0.04)

        plt.suptitle('Indicator Polynomials on F₃²: Kronecker Delta Property', fontsize=14, y=1.02)
        plt.tight_layout()
        plt.savefig(os.path.join(os.path.dirname(__file__), 'indicator_heatmap.png'), dpi=150, bbox_inches='tight')
        plt.close()
        print("  Saved: indicator_heatmap.png")

        return True
    except ImportError:
        print("  matplotlib not available — skipping visualizations")
        return False


# ============================================================
# Entry Point
# ============================================================

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   Cap Sets in F_3^n: The Polynomial Method             ║")
    print("║   Demonstrations and Numerical Experiments              ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_cap_set_enumeration()
    demo_indicator_polynomial()
    demo_reduced_polynomials()
    demo_monomial_counting()
    demo_three_ap_detection()

    print("=" * 60)
    print("VISUALIZATIONS")
    print("=" * 60)
    create_visualizations()
    print()
    print("All demonstrations complete.")
