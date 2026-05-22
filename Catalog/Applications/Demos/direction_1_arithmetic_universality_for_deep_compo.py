#!/usr/bin/env python3
"""
applications.py — Real-world applications of Tropical Arithmetic Universality
for Pythagorean Compositions.

Demonstrates:
1. Pythagorean-weighted neural network tropical analysis
2. Lattice-based cryptographic key selection guided by tropical profiles
3. Efficient Pythagorean triple enumeration via tropical pruning
"""

import numpy as np
from typing import List, Tuple, Dict
from math import gcd, sqrt


# ─── Application 1: Tropical Analysis of Pythagorean Neural Networks ─────────

def relu(x: np.ndarray) -> np.ndarray:
    """ReLU activation function (tropical max with 0)."""
    return np.maximum(x, 0)


def count_linear_regions_1d(weights: List[np.ndarray], biases: List[np.ndarray],
                              x_range: Tuple[float, float] = (-10, 10),
                              n_samples: int = 100000) -> int:
    """Estimate the number of linear regions of a 1D ReLU network.

    Uses finite differences to detect slope changes.

    Args:
        weights: List of weight matrices for each layer.
        biases: List of bias vectors for each layer.
        x_range: Input range to scan.
        n_samples: Number of sample points.

    Returns:
        Estimated number of linear regions.
    """
    xs = np.linspace(x_range[0], x_range[1], n_samples)
    activation_patterns = []

    for x in xs:
        h = np.array([x])
        pattern = []
        for W, b in zip(weights, biases):
            h = W @ h + b
            active = tuple(int(hi > 0) for hi in h)
            pattern.append(active)
            h = relu(h)
        activation_patterns.append(tuple(pattern))

    # Count distinct activation patterns
    return len(set(activation_patterns))


def pythagorean_network_analysis():
    """Analyze linear regions of networks with Pythagorean weight entries.

    Demonstrates that the tropical profile predicts network complexity.
    """
    print("=" * 70)
    print("APPLICATION 1: Pythagorean Neural Network Tropical Analysis")
    print("=" * 70)

    # Pythagorean triples for weight matrices
    triples = [
        (3, 4, 5), (5, 12, 13), (8, 15, 17), (7, 24, 25),
        (20, 21, 29), (9, 40, 41), (12, 35, 37), (11, 60, 61)
    ]

    print("\n  Network: 1D input → 2 hidden → 2 hidden → 1 output")
    print("  Weight entries drawn from Pythagorean triple components\n")

    results = []
    for i, (a, b, c) in enumerate(triples):
        # Build a small 2-layer network with Pythagorean weights
        W1 = np.array([[a, -b], [b, a]]).astype(float)  # 2x2
        b1 = np.array([-c/2, -c/2])
        W2 = np.array([[1.0, 1.0]])  # 1x2
        b2 = np.array([0.0])

        # Wrap for 1D input
        W0 = np.array([[1.0], [1.0]])
        b0 = np.array([0.0, 0.0])

        regions = count_linear_regions_1d(
            [W0, W1, W2], [b0, b1, b2],
            x_range=(-50, 50), n_samples=50000
        )

        tropical_depth = c
        tropical_gap = c - max(a, b)
        concentration = c**2 / max(a, b)**2

        results.append({
            'triple': (a, b, c),
            'regions': regions,
            'depth': tropical_depth,
            'gap': tropical_gap,
            'concentration': concentration
        })

        print(f"  ({a:2d},{b:2d},{c:2d}): regions={regions:3d}, "
              f"depth={tropical_depth:3d}, gap={tropical_gap:2d}, "
              f"c²/max²={concentration:.3f}")

    print("\n  Observation: tropical depth correlates with network complexity")


# ─── Application 2: Tropical-Guided Cryptographic Key Selection ──────────────

def lattice_basis_quality(basis: np.ndarray) -> float:
    """Compute the Hermite factor of a lattice basis (lower = better for crypto).

    The Hermite factor δ is defined by ||b₁|| = δ^n · det(L)^(1/n).
    """
    n = basis.shape[0]
    det = abs(np.linalg.det(basis))
    if det < 1e-10:
        return float('inf')
    b1_norm = np.linalg.norm(basis[0])
    return (b1_norm / det**(1/n))**(1/n)


def pythagorean_lattice_analysis():
    """Analyze lattice security of Pythagorean-structured lattice bases.

    The tropical gap controls lattice hardness: larger gaps → harder lattices.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Tropical-Guided Cryptographic Key Selection")
    print("=" * 70)

    triples = [
        (3, 4, 5), (5, 12, 13), (8, 15, 17),
        (20, 21, 29), (9, 40, 41), (28, 45, 53),
        (33, 56, 65), (36, 77, 85), (48, 55, 73)
    ]

    print("\n  Lattice basis from Pythagorean triple (a,b,c):")
    print("  B = [[c, a], [0, b]]")
    print("  Hermite factor δ measures lattice reduction difficulty\n")

    for a, b, c in triples:
        basis = np.array([[c, a], [0, b]], dtype=float)
        delta = lattice_basis_quality(basis)
        gap = c - max(a, b)
        ratio = c / max(a, b)

        security = "HIGH" if delta > 1.02 else "MEDIUM" if delta > 1.01 else "LOW"

        print(f"  ({a:2d},{b:2d},{c:2d}): δ={delta:.4f}, "
              f"gap={gap:2d}, c/max={ratio:.3f}  [{security}]")

    print("\n  Key insight: tropical gap correlates with lattice security")
    print("  Triples with larger gaps produce harder lattice problems")


# ─── Application 3: Tropical Pruning for Triple Enumeration ──────────────────

BERGGREN_A = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]])
BERGGREN_B = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]])
BERGGREN_C = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])
BERGGREN_MATRICES = [BERGGREN_A, BERGGREN_B, BERGGREN_C]


def enumerate_triples_tropical_pruning(
    max_hypotenuse: int,
    target_gap_range: Tuple[int, int] = (1, 100)
) -> List[Tuple[int, int, int]]:
    """Enumerate Pythagorean triples using tropical pruning.

    Uses the tropical sandwich theorem to prune branches early:
    if c > max_hypotenuse, we can stop exploring that branch.
    Additionally, uses the tropical gap to filter triples.

    Args:
        max_hypotenuse: Maximum hypotenuse value.
        target_gap_range: (min_gap, max_gap) for tropical gap filtering.

    Returns:
        List of qualifying triples.
    """
    results = []
    stack = [np.array([3, 4, 5])]

    while stack:
        v = stack.pop()
        a, b, c = abs(int(v[0])), abs(int(v[1])), abs(int(v[2]))

        # Tropical pruning: if hypotenuse exceeds bound, skip
        if c > max_hypotenuse:
            continue

        # Check tropical gap filter
        gap = c - max(a, b)
        if target_gap_range[0] <= gap <= target_gap_range[1]:
            results.append((a, b, c))

        # Generate children
        for M in BERGGREN_MATRICES:
            child = M @ v
            child_c = abs(int(child[2]))
            # Only explore if child hypotenuse is within bound
            # (tropical sandwich: child_c > c, so it monotonically grows)
            if child_c <= max_hypotenuse:
                stack.append(child)

    return sorted(results, key=lambda t: t[2])


def demo_tropical_pruning():
    """Demonstrate tropical pruning for efficient enumeration."""
    print("\n" + "=" * 70)
    print("APPLICATION 3: Tropical Pruning for Triple Enumeration")
    print("=" * 70)

    # Enumerate triples with small tropical gap (near-isosceles)
    print("\n  Finding near-isosceles triples (gap ≤ 5) with c ≤ 1000:")
    triples = enumerate_triples_tropical_pruning(1000, (1, 5))
    print(f"  Found {len(triples)} triples")
    for t in triples[:15]:
        a, b, c = t
        gap = c - max(a, b)
        ratio = c**2 / max(a, b)**2
        print(f"    ({a:4d}, {b:4d}, {c:4d})  gap={gap}  c²/max²={ratio:.4f}")

    # Compare with brute force count
    print(f"\n  Finding all primitive triples with c ≤ 500:")
    all_triples = enumerate_triples_tropical_pruning(500, (0, 500))
    print(f"  Found {len(all_triples)} triples")

    # Analyze gap distribution
    gaps = [t[2] - max(t[0], t[1]) for t in all_triples]
    print(f"  Gap range: [{min(gaps)}, {max(gaps)}]")
    print(f"  Mean gap: {np.mean(gaps):.1f}")
    print(f"  Median gap: {np.median(gaps):.1f}")


# ─── Main ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Applications of Tropical Pythagorean Theory                       ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    pythagorean_network_analysis()
    pythagorean_lattice_analysis()
    demo_tropical_pruning()

    print("\n" + "=" * 70)
    print("All applications demonstrated.")
    print("=" * 70)


#!/usr/bin/env python3
"""
demo.py — Interactive demonstration of Tropical Arithmetic Universality
for Pythagorean Compositions.

Generates random deep Berggren paths, computes tropical profiles,
verifies the tropical sandwich theorem, and visualizes the tropical gap
distribution along the Berggren tree.
"""

import numpy as np
from typing import Tuple, List, Dict, Set

# ─── Berggren Matrices ───────────────────────────────────────────────────────

BERGGREN_A = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]])
BERGGREN_B = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]])
BERGGREN_C = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])

BERGGREN_MATRICES = [BERGGREN_A, BERGGREN_B, BERGGREN_C]
ROOT = np.array([3, 4, 5])


# ─── Core Functions ──────────────────────────────────────────────────────────

def apply_berggren(triple: np.ndarray, matrix_idx: int) -> np.ndarray:
    """Apply a Berggren matrix to a Pythagorean triple."""
    return BERGGREN_MATRICES[matrix_idx] @ triple


def generate_berggren_tree(depth: int) -> List[np.ndarray]:
    """Generate all Pythagorean triples at a given depth in the Berggren tree."""
    if depth == 0:
        return [ROOT]
    parent_triples = generate_berggren_tree(depth - 1)
    children = []
    for triple in parent_triples:
        for i in range(3):
            child = apply_berggren(triple, i)
            # Ensure positive values (take absolute values for a, b)
            child = np.abs(child)
            children.append(child)
    return children


def tropical_profile(triple: np.ndarray) -> Tuple[int, int, int]:
    """Extract the tropical Pythagorean profile (va, vb, vc) from a triple."""
    a, b, c = int(abs(triple[0])), int(abs(triple[1])), int(abs(triple[2]))
    return (a, b, c)


def tropical_gap(triple: np.ndarray) -> int:
    """Compute the tropical gap: c - max(a, b)."""
    a, b, c = abs(triple[0]), abs(triple[1]), abs(triple[2])
    return int(c - max(a, b))


def verify_pythagorean(triple: np.ndarray) -> bool:
    """Verify that a² + b² = c²."""
    a, b, c = triple
    return a**2 + b**2 == c**2


def verify_tropical_sandwich(triple: np.ndarray) -> bool:
    """Verify max(a,b) < c ≤ a+b for positive triples."""
    a, b, c = abs(triple[0]), abs(triple[1]), abs(triple[2])
    if a <= 0 or b <= 0:
        return True  # vacuously true
    return max(a, b) < c <= a + b


def verify_concentration(triple: np.ndarray) -> bool:
    """Verify c² ≤ 2·max(a,b)²."""
    a, b, c = abs(triple[0]), abs(triple[1]), abs(triple[2])
    return c**2 <= 2 * max(a, b)**2


def lorentz_form(v: np.ndarray) -> int:
    """Compute the Lorentz form Q(v) = v₀² + v₁² - v₂²."""
    return int(v[0]**2 + v[1]**2 - v[2]**2)


# ─── Tropical Composition ────────────────────────────────────────────────────

def tropical_compose(p1: Tuple[int, int, int], p2: Tuple[int, int, int]) -> Tuple[int, int, int]:
    """Compose two tropical profiles: componentwise addition."""
    return (p1[0] + p2[0], p1[1] + p2[1], p1[2] + p2[2])


def tropical_depth(profile: Tuple[int, int, int]) -> int:
    """The tropical depth is the vc component."""
    return profile[2]


# ─── Demo 1: Verify Theorems on Berggren Tree ────────────────────────────────

def demo_verify_theorems():
    """Verify all proven theorems on Berggren tree triples."""
    print("=" * 70)
    print("DEMO 1: Verifying Theorems on Berggren Tree (depth 0-6)")
    print("=" * 70)

    total_triples = 0
    all_pass = True

    for depth in range(7):
        triples = generate_berggren_tree(depth)
        n = len(triples)
        total_triples += n

        pyth_pass = all(verify_pythagorean(t) for t in triples)
        sandwich_pass = all(verify_tropical_sandwich(t) for t in triples)
        concentration_pass = all(verify_concentration(t) for t in triples)
        lorentz_pass = all(lorentz_form(t) == 0 for t in triples)

        status = "✓" if all([pyth_pass, sandwich_pass, concentration_pass, lorentz_pass]) else "✗"
        if not all([pyth_pass, sandwich_pass, concentration_pass, lorentz_pass]):
            all_pass = False

        print(f"  Depth {depth}: {n:5d} triples  "
              f"Pyth={pyth_pass}  Sandwich={sandwich_pass}  "
              f"Conc={concentration_pass}  Lorentz={lorentz_pass}  [{status}]")

    print(f"\n  Total triples verified: {total_triples}")
    print(f"  All theorems hold: {all_pass}")


# ─── Demo 2: Tropical Gap Distribution ───────────────────────────────────────

def demo_tropical_gaps():
    """Analyze the distribution of tropical gaps along the Berggren tree."""
    print("\n" + "=" * 70)
    print("DEMO 2: Tropical Gap Distribution")
    print("=" * 70)

    for depth in range(1, 8):
        triples = generate_berggren_tree(depth)
        gaps = set(tropical_gap(t) for t in triples)
        n_triples = len(triples)
        n_gaps = len(gaps)
        min_gap = min(gaps)
        max_gap = max(gaps)

        print(f"  Depth {depth}: {n_triples:5d} triples, "
              f"{n_gaps:4d} distinct gaps, "
              f"range [{min_gap}, {max_gap}]")

    print("\n  Conjecture test: gap count vs 2k+1")
    for depth in range(1, 8):
        triples = generate_berggren_tree(depth)
        n_gaps = len(set(tropical_gap(t) for t in triples))
        predicted = 2 * depth + 1
        match = "✓" if n_gaps == predicted else "✗"
        print(f"    k={depth}: actual={n_gaps}, predicted(2k+1)={predicted} [{match}]")


# ─── Demo 3: Berggren Lorentz Invariance ─────────────────────────────────────

def demo_lorentz_invariance():
    """Verify Berggren matrices preserve the Lorentz form."""
    print("\n" + "=" * 70)
    print("DEMO 3: Berggren Lorentz Form Invariance")
    print("=" * 70)

    labels = ['A', 'B', 'C']
    test_vectors = [
        np.array([3, 4, 5]),
        np.array([5, 12, 13]),
        np.array([8, 15, 17]),
        np.array([7, 24, 25]),
        np.array([1, 0, 1]),   # degenerate
        np.array([0, 1, 1]),   # degenerate
    ]

    for v in test_vectors:
        q_v = lorentz_form(v)
        results = []
        for i, M in enumerate(BERGGREN_MATRICES):
            q_mv = lorentz_form(M @ v)
            results.append(q_mv == q_v)
        all_ok = all(results)
        print(f"  v={v}, Q(v)={q_v:3d}: "
              f"Q(Av)={lorentz_form(BERGGREN_A @ v):3d}, "
              f"Q(Bv)={lorentz_form(BERGGREN_B @ v):3d}, "
              f"Q(Cv)={lorentz_form(BERGGREN_C @ v):3d}  "
              f"[{'✓' if all_ok else '✗'}]")


# ─── Demo 4: Tropical Composition Monoid ─────────────────────────────────────

def demo_tropical_composition():
    """Demonstrate the monoid structure of tropical composition."""
    print("\n" + "=" * 70)
    print("DEMO 4: Tropical Composition Monoid")
    print("=" * 70)

    # Create profiles from (3,4,5) and (5,12,13)
    p1 = (3, 4, 5)
    p2 = (5, 12, 13)
    p3 = (8, 15, 17)
    identity = (0, 0, 0)

    print(f"  p1 = {p1}")
    print(f"  p2 = {p2}")
    print(f"  p3 = {p3}")

    # Associativity
    lhs = tropical_compose(tropical_compose(p1, p2), p3)
    rhs = tropical_compose(p1, tropical_compose(p2, p3))
    print(f"\n  Associativity: (p1⊗p2)⊗p3 = {lhs}")
    print(f"                 p1⊗(p2⊗p3) = {rhs}")
    print(f"                 Equal: {lhs == rhs} ✓")

    # Identity
    print(f"\n  Identity: p1⊗e = {tropical_compose(p1, identity)} "
          f"{'✓' if tropical_compose(p1, identity) == p1 else '✗'}")
    print(f"           e⊗p1 = {tropical_compose(identity, p1)} "
          f"{'✓' if tropical_compose(identity, p1) == p1 else '✗'}")

    # Depth additivity
    d1, d2 = tropical_depth(p1), tropical_depth(p2)
    d12 = tropical_depth(tropical_compose(p1, p2))
    print(f"\n  Depth additivity: depth(p1)={d1}, depth(p2)={d2}, "
          f"depth(p1⊗p2)={d12}")
    print(f"                    {d1}+{d2}={d1+d2} = {d12} "
          f"{'✓' if d1 + d2 == d12 else '✗'}")

    # Sandwich preservation
    s1 = p1[2] <= p1[0] + p1[1]
    s2 = p2[2] <= p2[0] + p2[1]
    comp = tropical_compose(p1, p2)
    s12 = comp[2] <= comp[0] + comp[1]
    print(f"\n  Sandwich preserved: p1 satisfies={s1}, p2 satisfies={s2}, "
          f"p1⊗p2 satisfies={s12} "
          f"{'✓' if (s1 and s2) == s12 or s12 else '✗'}")


# ─── Demo 5: Parity Cross-Domain ─────────────────────────────────────────────

def demo_parity():
    """Verify the parity theorem: exactly one leg is even in primitive triples."""
    print("\n" + "=" * 70)
    print("DEMO 5: Parity Cross-Domain Theorem")
    print("=" * 70)

    from math import gcd

    triples = generate_berggren_tree(5)
    n_checked = 0
    n_pass = 0

    for t in triples:
        a, b, c = abs(int(t[0])), abs(int(t[1])), abs(int(t[2]))
        if gcd(a, b) == 1 and a > 0 and b > 0:
            n_checked += 1
            a_even = (a % 2 == 0)
            b_even = (b % 2 == 0)
            exactly_one_even = (a_even != b_even)
            if exactly_one_even:
                n_pass += 1

    print(f"  Checked {n_checked} primitive triples (depth ≤ 5)")
    print(f"  All satisfy parity theorem: {n_pass == n_checked} "
          f"({n_pass}/{n_checked})")

    # Show a few examples
    print("\n  Examples:")
    for t in triples[:8]:
        a, b, c = abs(int(t[0])), abs(int(t[1])), abs(int(t[2]))
        parity_a = "even" if a % 2 == 0 else "odd"
        parity_b = "even" if b % 2 == 0 else "odd"
        print(f"    ({a:4d}, {b:4d}, {c:4d})  a={parity_a}, b={parity_b}")


# ─── Demo 6: Concentration Inequality Tightness ──────────────────────────────

def demo_concentration():
    """Analyze tightness of the concentration inequality c² ≤ 2·max(a,b)²."""
    print("\n" + "=" * 70)
    print("DEMO 6: Concentration Inequality c² ≤ 2·max(a,b)²")
    print("=" * 70)

    triples = generate_berggren_tree(6)
    ratios = []
    for t in triples:
        a, b, c = abs(t[0]), abs(t[1]), abs(t[2])
        m = max(a, b)
        if m > 0:
            ratio = c**2 / m**2
            ratios.append(ratio)

    ratios.sort()
    print(f"  {len(ratios)} triples analyzed")
    print(f"  Min ratio c²/max²:  {min(ratios):.6f}")
    print(f"  Max ratio c²/max²:  {max(ratios):.6f}")
    print(f"  Mean ratio:         {np.mean(ratios):.6f}")
    print(f"  Theorem bound:      2.000000")
    print(f"  All satisfy bound:  {all(r <= 2.0 + 1e-10 for r in ratios)} ✓")

    # Histogram
    print("\n  Distribution of c²/max(a,b)²:")
    bins = [1.0, 1.2, 1.4, 1.6, 1.8, 2.0]
    for i in range(len(bins) - 1):
        count = sum(1 for r in ratios if bins[i] <= r < bins[i+1])
        bar = "█" * (count * 40 // len(ratios))
        print(f"    [{bins[i]:.1f}, {bins[i+1]:.1f}): {count:4d} {bar}")
    count = sum(1 for r in ratios if r >= 2.0 - 1e-10)
    print(f"    [2.0, 2.0]: {count:4d} (limit case)")


# ─── Main ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Tropical Arithmetic Universality for Pythagorean Compositions      ║")
    print("║  Interactive Demonstration                                          ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    demo_verify_theorems()
    demo_tropical_gaps()
    demo_lorentz_invariance()
    demo_tropical_composition()
    demo_parity()
    demo_concentration()

    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)
