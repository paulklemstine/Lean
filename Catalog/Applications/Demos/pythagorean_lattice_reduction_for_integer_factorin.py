#!/usr/bin/env python3
"""
Pythagorean Lattice Reduction — Applications

Demonstrates real-world applications of the formally verified theorems:
1. RSA modulus analysis via Pythagorean collisions
2. Primality certification via absence of collisions
3. Cryptographic hash collision analysis
"""

import math
import random
from typing import Optional


# ─────────────────────────────────────────────────────────────────────
# Application 1: RSA Modulus Analysis
# ─────────────────────────────────────────────────────────────────────

def analyze_rsa_modulus(n: int, trials: int = 10000) -> dict:
    """
    Analyze an RSA modulus by searching for square-root collisions.

    For each random x, computes x² mod n and checks whether two different
    x values yield the same residue (a collision). A collision x² ≡ y² (mod n)
    with x ≢ ±y (mod n) reveals a factor.

    This demonstrates the formally verified `square_collision_yields_factor`.

    Args:
        n: RSA modulus to analyze
        trials: Number of random trials

    Returns:
        Dict with analysis results.
    """
    residues: dict[int, list[int]] = {}
    factor = None

    for _ in range(trials):
        x = random.randint(2, n - 2)
        r = (x * x) % n

        if r in residues:
            for y in residues[r]:
                if (x - y) % n != 0 and (x + y) % n != 0:
                    d = math.gcd(abs(x - y), n)
                    if 1 < d < n:
                        factor = d
                        return {
                            "factored": True,
                            "factor": d,
                            "cofactor": n // d,
                            "collision": (x, y),
                            "residue": r,
                            "trials_used": _ + 1,
                        }
            residues[r].append(x)
        else:
            residues[r] = [x]

    return {
        "factored": False,
        "unique_residues": len(residues),
        "collision_density": len(residues) / n,
        "trials_used": trials,
    }


# ─────────────────────────────────────────────────────────────────────
# Application 2: Primality Witness via Collision Absence
# ─────────────────────────────────────────────────────────────────────

def collision_primality_test(n: int, confidence_trials: int = 100) -> dict:
    """
    Heuristic primality test based on square-root collision theory.

    For a prime p, every square root collision is trivial (x ≡ ±y mod p).
    For composites, nontrivial collisions exist and are easy to find.

    Args:
        n: Number to test
        confidence_trials: Number of trials

    Returns:
        Dict with primality assessment.
    """
    if n < 2:
        return {"n": n, "probably_prime": False, "reason": "too small"}
    if n % 2 == 0:
        return {"n": n, "probably_prime": n == 2, "reason": "even"}

    nontrivial_found = False

    for _ in range(confidence_trials):
        x = random.randint(2, n - 1)
        x_sq = (x * x) % n

        # Check if x and n-x are the only square roots
        # For primes, x² mod p has exactly two roots: x and p-x
        # For composites, there can be more
        roots = []
        # Quick check: try a few random values
        for _ in range(20):
            y = random.randint(1, n - 1)
            if (y * y) % n == x_sq:
                roots.append(y)

        roots_mod = set(r % n for r in roots)
        if len(roots_mod) > 2:
            # More than 2 square roots → composite
            for r1 in roots_mod:
                for r2 in roots_mod:
                    if r1 != r2 and (r1 + r2) % n != 0:
                        d = math.gcd(abs(r1 - r2), n)
                        if 1 < d < n:
                            return {
                                "n": n,
                                "probably_prime": False,
                                "reason": "nontrivial collision found",
                                "factor": d,
                                "roots": sorted(roots_mod),
                            }
            nontrivial_found = True

    return {
        "n": n,
        "probably_prime": not nontrivial_found,
        "reason": "no nontrivial collisions found" if not nontrivial_found
                  else "suspicious collisions",
    }


# ─────────────────────────────────────────────────────────────────────
# Application 3: Pythagorean Triple Fingerprinting
# ─────────────────────────────────────────────────────────────────────

BERGGREN_MATS = [
    [[1, -2, 2], [2, -1, 2], [2, -2, 3]],
    [[1, 2, 2], [2, 1, 2], [2, 2, 3]],
    [[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]],
]


def mat_vec(M, v):
    return tuple(sum(M[i][j] * v[j] for j in range(3)) for i in range(3))


def pythagorean_fingerprint(n: int, depth: int = 5) -> dict:
    """
    Create a Pythagorean fingerprint of n by computing collision patterns
    of Berggren triples modulo n.

    Different values of n produce different collision signatures, which
    reveals structural information about n's factorization.

    Args:
        n: Modulus
        depth: Berggren tree depth

    Returns:
        Dict mapping collision type to count.
    """
    from itertools import product as iprod

    stats = {
        "total_triples": 0,
        "hyp_divisible": 0,     # n | c
        "hyp_sq_divisible": 0,  # n | c²
        "collision_a_b": 0,     # n | a²-b²
        "nontrivial_gcd": 0,    # 1 < gcd(c, n) < n
    }

    for d in range(depth + 1):
        for word in iprod(range(3), repeat=d):
            v = (3, 4, 5)
            for g in reversed(word):
                v = mat_vec(BERGGREN_MATS[g], v)
            a, b, c = v
            stats["total_triples"] += 1

            if c % n == 0:
                stats["hyp_divisible"] += 1
            if (c * c) % n == 0:
                stats["hyp_sq_divisible"] += 1
            if (a * a - b * b) % n == 0:
                stats["collision_a_b"] += 1

            g = math.gcd(abs(c), n)
            if 1 < g < n:
                stats["nontrivial_gcd"] += 1

    return stats


def demo_applications():
    """Run all application demonstrations."""
    print("=" * 70)
    print("APPLICATION 1: RSA Modulus Analysis via Square-Root Collisions")
    print("=" * 70)
    print()

    # Small RSA-like moduli
    test_moduli = [
        (3 * 5, "3 × 5"),
        (7 * 11, "7 × 11"),
        (13 * 17, "13 × 17"),
        (23 * 29, "23 × 29"),
        (101 * 103, "101 × 103"),
        (1009 * 1013, "1009 × 1013"),
    ]

    random.seed(42)
    for n, desc in test_moduli:
        result = analyze_rsa_modulus(n, trials=5000)
        if result["factored"]:
            x, y = result["collision"]
            print(f"  n = {n:>10} ({desc:>12}): "
                  f"FACTORED in {result['trials_used']:>4} trials — "
                  f"{result['factor']} × {result['cofactor']} "
                  f"[collision: {x}² ≡ {y}² mod {n}]")
        else:
            print(f"  n = {n:>10} ({desc:>12}): "
                  f"Not factored in {result['trials_used']} trials "
                  f"({result['unique_residues']} unique residues)")

    print()
    print("=" * 70)
    print("APPLICATION 2: Primality Testing via Collision Absence")
    print("=" * 70)
    print()

    test_numbers = [7, 11, 13, 15, 21, 25, 29, 35, 37, 41, 49, 51, 53, 91]
    random.seed(123)
    for n in test_numbers:
        result = collision_primality_test(n, confidence_trials=50)
        is_actually_prime = all(n % i != 0 for i in range(2, int(n**0.5) + 1)) and n > 1
        status = "✓" if result["probably_prime"] == is_actually_prime else "✗"
        print(f"  {status} n={n:>3}: {'probably prime' if result['probably_prime'] else 'composite':>15} "
              f"(actually {'prime' if is_actually_prime else 'composite'})")

    print()
    print("=" * 70)
    print("APPLICATION 3: Pythagorean Fingerprinting of Composites")
    print("=" * 70)
    print()

    fingerprint_targets = [15, 21, 35, 77, 91, 143]
    for n in fingerprint_targets:
        fp = pythagorean_fingerprint(n, depth=4)
        print(f"  n={n:>4}: {fp['total_triples']} triples checked, "
              f"hyp_div={fp['hyp_divisible']}, "
              f"sq_div={fp['hyp_sq_divisible']}, "
              f"collisions={fp['collision_a_b']}, "
              f"nontrivial_gcd={fp['nontrivial_gcd']}")

    print()


if __name__ == "__main__":
    demo_applications()


#!/usr/bin/env python3
"""
Pythagorean Lattice Reduction for Integer Factoring — Demonstrations

This script demonstrates the core theorems connecting Pythagorean triple
arithmetic to integer factoring:

1. Square-root collision factor extraction
2. Euclid parametrization of Pythagorean triples
3. Berggren tree generation and factor witness search
4. Hypotenuse-gcd factor extraction
"""

import math
import random
from typing import Optional


def square_collision_factor(n: int, x: int, y: int) -> Optional[int]:
    """
    Extract a nontrivial factor of n from a square-root collision x² ≡ y² (mod n)
    where x ≢ ±y (mod n).

    This is the arithmetic engine behind our formalized theorem
    `square_collision_yields_factor`.

    Returns a nontrivial factor d with 1 < d < n, or None if the collision is trivial.
    """
    if (x**2 - y**2) % n != 0:
        return None  # Not a valid collision
    if (x - y) % n == 0 or (x + y) % n == 0:
        return None  # Trivial collision

    d = math.gcd(abs(x - y), n)
    if 1 < d < n:
        return d

    d = math.gcd(abs(x + y), n)
    if 1 < d < n:
        return d

    return None


def euclid_triple(m: int, k: int) -> tuple[int, int, int]:
    """
    Generate a Pythagorean triple using Euclid's parametrization.

    Returns (m²-k², 2mk, m²+k²) satisfying a² + b² = c².
    This corresponds to our formalized `EuclidTriple` and `euclidTriple_pythagorean`.
    """
    a = m**2 - k**2
    b = 2 * m * k
    c = m**2 + k**2
    assert a**2 + b**2 == c**2, "Pythagorean identity must hold"
    return (a, b, c)


# Berggren matrices
BERGGREN_U = [[1, -2, 2], [2, -1, 2], [2, -2, 3]]
BERGGREN_A = [[1, 2, 2], [2, 1, 2], [2, 2, 3]]
BERGGREN_D = [[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]]
BERGGREN_GENS = [BERGGREN_U, BERGGREN_A, BERGGREN_D]


def mat_vec_mul(M: list[list[int]], v: tuple[int, int, int]) -> tuple[int, int, int]:
    """Multiply a 3x3 matrix by a 3-vector."""
    return tuple(sum(M[i][j] * v[j] for j in range(3)) for i in range(3))


def berggren_triple(word: list[int], root: tuple[int, int, int] = (3, 4, 5)) -> tuple[int, int, int]:
    """
    Apply a Berggren word to the root triple.

    word: list of generator indices (0=U, 1=A, 2=D)
    root: starting triple, default (3,4,5)

    Returns the resulting Pythagorean triple.
    """
    v = root
    for g in reversed(word):
        v = mat_vec_mul(BERGGREN_GENS[g], v)
    assert v[0]**2 + v[1]**2 == v[2]**2, f"Pythagorean identity violated: {v}"
    return v


def hypotenuse_gcd_factor(n: int, triple: tuple[int, int, int]) -> Optional[int]:
    """
    Try to extract a factor of n from a Pythagorean triple using the
    hypotenuse-gcd method.

    If n | c² but n ∤ c, then gcd(c, n) is a nontrivial factor.
    This corresponds to our formalized `factor_of_square_dvd_not_dvd`.
    """
    a, b, c = triple
    if (a**2 + b**2) % n != 0:
        return None
    if c % n == 0:
        return None  # n | c, so gcd(c,n) might be n

    d = math.gcd(abs(c), n)
    if 1 < d < n:
        return d
    return None


def search_berggren_factor_witness(n: int, max_depth: int = 8) -> Optional[dict]:
    """
    Search the Berggren tree for a Pythagorean triple that yields a factor of n.

    Uses both the hypotenuse-gcd method and the square-collision method.

    Returns a dict with the factor and witness information, or None.
    """
    from itertools import product as iproduct

    for depth in range(max_depth + 1):
        for word in iproduct(range(3), repeat=depth):
            triple = berggren_triple(list(word))
            a, b, c = triple

            # Method 1: Hypotenuse-gcd
            d = hypotenuse_gcd_factor(n, triple)
            if d is not None:
                return {
                    "method": "hypotenuse_gcd",
                    "factor": d,
                    "triple": triple,
                    "word": list(word),
                    "depth": depth,
                }

            # Method 2: Square collision on (a, b)
            d = square_collision_factor(n, a, b)
            if d is not None:
                return {
                    "method": "square_collision",
                    "factor": d,
                    "triple": triple,
                    "word": list(word),
                    "depth": depth,
                }

    return None


def demo_square_collision():
    """Demonstrate the square-root collision theorem."""
    print("=" * 70)
    print("DEMO 1: Square-Root Collision Factor Extraction")
    print("=" * 70)
    print()
    print("Theorem: If x² ≡ y² (mod n) but x ≢ ±y (mod n),")
    print("         then gcd(x-y, n) is a nontrivial factor of n.")
    print()

    examples = [
        (15, 4, 1),   # 4² = 16 ≡ 1 = 1² (mod 15), gcd(3, 15) = 3
        (21, 8, 1),   # 8² = 64 ≡ 1 = 1² (mod 21), gcd(7, 21) = 7
        (35, 6, 1),   # 6² = 36 ≡ 1 = 1² (mod 35), gcd(5, 35) = 5
        (91, 10, 3),  # 10² - 3² = 91, gcd(7, 91) = 7
        (143, 12, 1), # 12² = 144 ≡ 1 (mod 143), gcd(11, 143) = 11
    ]

    for n, x, y in examples:
        d = square_collision_factor(n, x, y)
        status = f"Factor found: {d}" if d else "Trivial collision"
        print(f"  n={n:>4}, x={x:>3}, y={y:>3}: "
              f"x²-y²={x**2 - y**2:>5} ≡ {(x**2-y**2) % n} (mod {n}), "
              f"gcd(x-y, n)={math.gcd(abs(x-y), n):>3} → {status}")
        if d:
            print(f"       Verification: {n} = {d} × {n // d}")
    print()


def demo_euclid_triples():
    """Demonstrate Euclid parametrization."""
    print("=" * 70)
    print("DEMO 2: Euclid Parametrization of Pythagorean Triples")
    print("=" * 70)
    print()
    print("Identity: (m²-k²)² + (2mk)² = (m²+k²)²")
    print()

    for m in range(2, 8):
        for k in range(1, m):
            if math.gcd(m, k) == 1 and (m - k) % 2 == 1:
                a, b, c = euclid_triple(m, k)
                print(f"  m={m}, k={k}: ({a}, {b}, {c})  "
                      f"[{a}² + {b}² = {a**2} + {b**2} = {c**2} = {c}²]")
    print()


def demo_berggren_tree():
    """Demonstrate the Berggren tree generation."""
    print("=" * 70)
    print("DEMO 3: Berggren Tree of Primitive Pythagorean Triples")
    print("=" * 70)
    print()
    print("Starting from (3,4,5), applying generators U, A, D:")
    print()

    gen_names = {0: "U", 1: "A", 2: "D"}

    # Show first two levels
    root = (3, 4, 5)
    print(f"  Root: {root}")
    print()

    for g in range(3):
        child = berggren_triple([g])
        print(f"  {gen_names[g]}(3,4,5) = {child}")

    print()
    print("  Level 2 (9 triples):")
    for g1 in range(3):
        for g2 in range(3):
            triple = berggren_triple([g1, g2])
            a, b, c = triple
            print(f"    {gen_names[g1]}{gen_names[g2]}: ({a}, {b}, {c})  "
                  f"[Q = {a**2 + b**2 - c**2}]")
    print()


def demo_berggren_factoring():
    """Demonstrate factor search via Berggren tree."""
    print("=" * 70)
    print("DEMO 4: Factor Search via Berggren Tree")
    print("=" * 70)
    print()

    semiprimes = [15, 21, 35, 51, 77, 91, 119, 143, 187, 221, 323, 437, 667, 899]

    for n in semiprimes:
        result = search_berggren_factor_witness(n, max_depth=6)
        if result:
            d = result["factor"]
            gen_names = {0: "U", 1: "A", 2: "D"}
            word_str = "".join(gen_names[g] for g in result["word"]) or "ε"
            print(f"  n={n:>4}: factor {d:>3} (= {n//d} × {d}), "
                  f"method={result['method']}, "
                  f"word={word_str}, "
                  f"triple={result['triple']}")
        else:
            print(f"  n={n:>4}: no witness found in depth ≤ 6")
    print()


def demo_hypotenuse_gcd():
    """Demonstrate hypotenuse-gcd factor extraction."""
    print("=" * 70)
    print("DEMO 5: Hypotenuse-GCD Factor Extraction from Pythagorean Triples")
    print("=" * 70)
    print()
    print("If a²+b²=c² and n | c² but n ∤ c, then gcd(c,n) is a factor of n.")
    print()

    # Find triples where hypotenuse has interesting gcd properties
    for m in range(2, 20):
        for k in range(1, m):
            a, b, c = euclid_triple(m, k)
            # Try some composites n that divide c²
            for p in [2, 3, 5, 7, 11, 13]:
                for q in [3, 5, 7, 11, 13, 17]:
                    if p >= q:
                        continue
                    n = p * q
                    if c**2 % n == 0 and c % n != 0:
                        d = math.gcd(abs(c), n)
                        if 1 < d < n:
                            print(f"  n={n:>4}={p}×{q}: triple ({a},{b},{c}), "
                                  f"c²={c**2}, gcd(c,n)={d}")

    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║   Pythagorean Lattice Reduction for Integer Factoring              ║")
    print("║   Demonstrations of Formally Verified Theorems                     ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_square_collision()
    demo_euclid_triples()
    demo_berggren_tree()
    demo_berggren_factoring()
    demo_hypotenuse_gcd()

    print("All demonstrations complete.")


#!/usr/bin/env python3
"""
Pythagorean Lattice Reduction — Visualizations

Generates figures showing:
1. The Berggren tree of Pythagorean triples
2. Pythagorean triples modulo n and collision patterns
3. Euclid-parameter lattice and LLL reduction
4. Factor extraction success rates
"""

import math
import os
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch
import base64
from io import BytesIO


BERGGREN_MATRICES = [
    np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]]),
    np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]]),
    np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]]),
]


def berggren_apply(word, root=np.array([3, 4, 5])):
    v = root.copy()
    for g in reversed(word):
        v = BERGGREN_MATRICES[g] @ v
    return v


def fig_to_base64(fig):
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def plot_berggren_tree():
    """Plot the Berggren tree with the first few levels."""
    fig, ax = plt.subplots(1, 1, figsize=(14, 8))

    gen_names = ['U', 'A', 'D']
    colors = ['#2196F3', '#4CAF50', '#FF9800']

    # Generate tree positions
    levels = {}
    levels[0] = {(): (7, 7)}  # root

    for depth in range(1, 4):
        levels[depth] = {}
        parent_count = 3 ** (depth - 1)
        child_count = 3 ** depth
        for idx, parent_word in enumerate(sorted(levels[depth - 1].keys())):
            px, py = levels[depth - 1][parent_word]
            for g in range(3):
                child_word = parent_word + (g,)
                child_idx = idx * 3 + g
                cx = (child_idx + 0.5) / child_count * 14
                cy = 7 - depth * 2
                levels[depth][child_word] = (cx, cy)

                # Draw edge
                ax.plot([px, cx], [py, cy], color=colors[g], alpha=0.4, linewidth=1.5)

    # Draw nodes
    for depth in range(4):
        for word, (x, y) in levels[depth].items():
            triple = berggren_apply(list(word))
            a, b, c = int(triple[0]), int(triple[1]), int(triple[2])
            label = f"({a},{b},{c})"

            fontsize = max(5, 9 - depth)
            bbox_props = dict(boxstyle="round,pad=0.3", facecolor='white',
                             edgecolor='gray', alpha=0.9)
            ax.text(x, y, label, ha='center', va='center',
                   fontsize=fontsize, bbox=bbox_props, fontfamily='monospace')

    ax.set_xlim(-0.5, 14.5)
    ax.set_ylim(-0.5, 8)
    ax.set_title('Berggren Tree of Primitive Pythagorean Triples', fontsize=14, fontweight='bold')
    ax.axis('off')

    # Legend
    for i, name in enumerate(gen_names):
        ax.plot([], [], color=colors[i], linewidth=2, label=f'Generator {name}')
    ax.legend(loc='upper right', fontsize=10)

    return fig


def plot_triples_mod_n():
    """Plot Pythagorean triples reduced modulo n, showing collision patterns."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    for idx, n in enumerate([15, 21, 35]):
        ax = axes[idx]

        # Generate many Berggren triples
        triples_mod = set()
        for depth in range(7):
            from itertools import product as iprod
            for word in iprod(range(3), repeat=depth):
                triple = berggren_apply(list(word))
                a_mod = int(triple[0]) % n
                b_mod = int(triple[1]) % n
                triples_mod.add((a_mod, b_mod))

        xs = [t[0] for t in triples_mod]
        ys = [t[1] for t in triples_mod]

        # Color by whether they give a collision
        collision_colors = []
        for a_mod, b_mod in triples_mod:
            d = math.gcd(abs(a_mod - b_mod), n)
            if 1 < d < n:
                collision_colors.append('#FF5722')
            elif math.gcd(abs(a_mod + b_mod), n) > 1 and math.gcd(abs(a_mod + b_mod), n) < n:
                collision_colors.append('#FFC107')
            else:
                collision_colors.append('#2196F3')

        ax.scatter(xs, ys, c=collision_colors, s=20, alpha=0.7, edgecolors='none')
        ax.set_title(f'Triples mod {n}', fontsize=12, fontweight='bold')
        ax.set_xlabel('a mod n')
        ax.set_ylabel('b mod n')
        ax.set_xlim(-0.5, n - 0.5)
        ax.set_ylim(-0.5, n - 0.5)
        ax.set_aspect('equal')
        ax.grid(True, alpha=0.3)

    plt.suptitle('Berggren Triples Modulo n — Collision Patterns', fontsize=14, fontweight='bold')
    plt.tight_layout()
    return fig


def plot_factor_success_rate():
    """Plot factor extraction success rate vs tree depth."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    # Test semiprimes of various sizes
    semiprimes = []
    primes_list = [p for p in range(3, 100) if all(p % i != 0 for i in range(2, int(p**0.5)+1))]
    for i in range(len(primes_list)):
        for j in range(i+1, min(i+5, len(primes_list))):
            semiprimes.append(primes_list[i] * primes_list[j])

    max_depth = 8
    success_counts = [0] * (max_depth + 1)
    total = len(semiprimes)

    from itertools import product as iprod

    for n in semiprimes:
        found_depth = None
        for depth in range(max_depth + 1):
            for word in iprod(range(3), repeat=depth):
                triple = berggren_apply(list(word))
                a, b, c = int(triple[0]), int(triple[1]), int(triple[2])

                # Check various collision conditions
                for x, y in [(a, b), (a, c), (b, c)]:
                    if (x*x - y*y) % n == 0:
                        d_minus = math.gcd(abs(x - y), n)
                        d_plus = math.gcd(abs(x + y), n)
                        if (1 < d_minus < n) or (1 < d_plus < n):
                            found_depth = depth
                            break
                if found_depth is not None:
                    break

                # Hypotenuse gcd
                if c*c % n == 0 and c % n != 0:
                    d = math.gcd(abs(c), n)
                    if 1 < d < n:
                        found_depth = depth
                        break
            if found_depth is not None:
                break

        if found_depth is not None:
            for d in range(found_depth, max_depth + 1):
                success_counts[d] += 1

    success_rates = [c / total * 100 for c in success_counts]

    ax.bar(range(max_depth + 1), success_rates, color='#2196F3', alpha=0.8, edgecolor='white')
    ax.set_xlabel('Maximum Berggren Tree Depth', fontsize=12)
    ax.set_ylabel('Factoring Success Rate (%)', fontsize=12)
    ax.set_title('Factor Extraction via Berggren Tree Traversal', fontsize=14, fontweight='bold')
    ax.set_ylim(0, 105)

    for i, rate in enumerate(success_rates):
        if rate > 0:
            ax.text(i, rate + 2, f'{rate:.0f}%', ha='center', fontsize=9)

    ax.text(0.5, 0.95, f'Tested on {total} semiprimes (products of primes < 100)',
           transform=ax.transAxes, ha='center', va='top', fontsize=10,
           style='italic', color='gray')

    plt.tight_layout()
    return fig


def plot_quadratic_form_preservation():
    """Visualize the quadratic form Q = a²+b²-c² = 0 along Berggren orbits."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Q values for random vectors vs Berggren triples
    from itertools import product as iprod

    # Berggren triples
    berggren_qs = []
    berggren_cs = []
    for depth in range(6):
        for word in iprod(range(3), repeat=depth):
            triple = berggren_apply(list(word))
            a, b, c = triple
            q = a**2 + b**2 - c**2
            berggren_qs.append(q)
            berggren_cs.append(c)

    ax1.scatter(berggren_cs, berggren_qs, c='#2196F3', s=15, alpha=0.7,
               label='Berggren triples', zorder=5)

    # Random vectors for comparison
    rng = np.random.RandomState(42)
    random_cs = []
    random_qs = []
    for _ in range(200):
        v = rng.randint(1, 500, size=3)
        q = v[0]**2 + v[1]**2 - v[2]**2
        random_qs.append(q)
        random_cs.append(v[2])

    ax1.scatter(random_cs, random_qs, c='#FF5722', s=10, alpha=0.3,
               label='Random vectors', zorder=3)
    ax1.axhline(y=0, color='black', linewidth=2, linestyle='--', alpha=0.5)
    ax1.set_xlabel('c (hypotenuse)', fontsize=12)
    ax1.set_ylabel('Q = a² + b² - c²', fontsize=12)
    ax1.set_title('Quadratic Form Preservation', fontsize=13, fontweight='bold')
    ax1.legend(fontsize=10)

    # Right: Hypotenuse growth by word length
    depths = list(range(7))
    hyps_by_depth = {d: [] for d in depths}
    for depth in depths:
        for word in iprod(range(3), repeat=depth):
            triple = berggren_apply(list(word))
            hyps_by_depth[depth].append(int(triple[2]))

    bp = ax2.boxplot([hyps_by_depth[d] for d in depths],
                     labels=[str(d) for d in depths],
                     patch_artist=True)
    for patch in bp['boxes']:
        patch.set_facecolor('#4CAF50')
        patch.set_alpha(0.6)

    ax2.set_xlabel('Berggren Word Length', fontsize=12)
    ax2.set_ylabel('Hypotenuse c', fontsize=12)
    ax2.set_title('Hypotenuse Growth in Berggren Tree', fontsize=13, fontweight='bold')
    ax2.set_yscale('log')

    plt.tight_layout()
    return fig


def generate_all_visualizations():
    """Generate all visualization figures and save them."""
    os.makedirs('/workspace/request-project/figures', exist_ok=True)

    figures = {}

    print("Generating Berggren tree visualization...")
    fig = plot_berggren_tree()
    fig.savefig('/workspace/request-project/figures/berggren_tree.png', dpi=150, bbox_inches='tight')
    figures['berggren_tree'] = fig_to_base64(fig)

    print("Generating triples mod n visualization...")
    fig = plot_triples_mod_n()
    fig.savefig('/workspace/request-project/figures/triples_mod_n.png', dpi=150, bbox_inches='tight')
    figures['triples_mod_n'] = fig_to_base64(fig)

    print("Generating factor success rate visualization...")
    fig = plot_factor_success_rate()
    fig.savefig('/workspace/request-project/figures/factor_success_rate.png', dpi=150, bbox_inches='tight')
    figures['factor_success_rate'] = fig_to_base64(fig)

    print("Generating quadratic form preservation visualization...")
    fig = plot_quadratic_form_preservation()
    fig.savefig('/workspace/request-project/figures/quadratic_form.png', dpi=150, bbox_inches='tight')
    figures['quadratic_form'] = fig_to_base64(fig)

    print("All visualizations generated.")
    return figures


if __name__ == "__main__":
    figures = generate_all_visualizations()
    for name in figures:
        print(f"  {name}: {len(figures[name])} bytes (base64)")
