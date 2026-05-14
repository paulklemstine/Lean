#!/usr/bin/env python3
"""
Applications of Pythagorean Lattice Factoring

Demonstrates real-world applications and connections:
1. RSA key analysis via square congruences
2. Berggren tree as a combinatorial structure
3. Lattice geometry visualization data
4. Complexity comparison of factoring approaches
"""

import math
import random
from typing import List, Tuple, Optional


# ────────────────────────────────────────────────────────────────
# Application 1: RSA-style Factoring Analysis
# ────────────────────────────────────────────────────────────────

def is_prime(n: int) -> bool:
    """Simple primality test."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def generate_rsa_like(bits: int) -> Tuple[int, int, int]:
    """Generate an RSA-like semiprime n = p * q."""
    while True:
        p = random.randrange(2**(bits-1), 2**bits)
        if is_prime(p):
            break
    while True:
        q = random.randrange(2**(bits-1), 2**bits)
        if is_prime(q) and q != p:
            break
    return p * q, p, q


def analyze_lattice_geometry(n: int, p: int, q: int):
    """
    Analyze the geometry of the divisibility lattice for n = p * q.
    
    The factor vectors are (p, q) and (q, p) with norms p² + q².
    The lattice volume is n, so Minkowski's theorem guarantees
    short vectors exist with norm ≤ 2n/π ≈ 0.64n.
    """
    factor_norm_sq = p**2 + q**2
    n_sq = n**2
    minkowski_bound = 2 * n / math.pi
    
    return {
        'n': n,
        'p': p,
        'q': q,
        'factor_vector_norm_sq': factor_norm_sq,
        'n_squared': n_sq,
        'ratio': factor_norm_sq / n_sq,
        'minkowski_bound': minkowski_bound,
        'minkowski_bound_sq': minkowski_bound**2,
    }


def demo_rsa_analysis():
    """Demonstrate lattice geometry for RSA-like numbers."""
    print("=" * 60)
    print("APPLICATION 1: RSA Lattice Geometry Analysis")
    print("=" * 60)
    
    random.seed(42)
    
    for bits in [4, 6, 8, 10]:
        n, p, q = generate_rsa_like(bits)
        if p > q:
            p, q = q, p
        analysis = analyze_lattice_geometry(n, p, q)
        
        print(f"\n  n = {n} = {p} × {q}  ({bits}-bit factors)")
        print(f"    Factor vector: ({p}, {q})")
        print(f"    ‖v‖² = {analysis['factor_vector_norm_sq']}")
        print(f"    n²   = {analysis['n_squared']}")
        print(f"    ‖v‖²/n² = {analysis['ratio']:.4f}")
        print(f"    Minkowski bound: {analysis['minkowski_bound']:.1f}")


# ────────────────────────────────────────────────────────────────
# Application 2: Berggren Tree Combinatorics
# ────────────────────────────────────────────────────────────────

def count_primitive_triples_up_to(bound: int) -> int:
    """Count primitive Pythagorean triples with hypotenuse ≤ bound."""
    count = 0
    for m in range(2, int(math.sqrt(bound)) + 1):
        for k in range(1, m):
            if math.gcd(m, k) == 1 and (m - k) % 2 == 1:
                c = m**2 + k**2
                if c <= bound:
                    count += 1
    return count


def lehmer_asymptotic(bound: int) -> float:
    """Lehmer's asymptotic formula: N(x) ~ x/(2π)."""
    return bound / (2 * math.pi)


def demo_berggren_combinatorics():
    """Compare actual triple counts with Lehmer's asymptotic."""
    print("\n" + "=" * 60)
    print("APPLICATION 2: Berggren Tree Combinatorics")
    print("=" * 60)
    
    print(f"\n  {'Bound':<12} {'Actual':<10} {'Lehmer':<12} {'Ratio'}")
    print(f"  {'-'*12} {'-'*10} {'-'*12} {'-'*8}")
    
    for bound in [100, 500, 1000, 5000, 10000, 50000]:
        actual = count_primitive_triples_up_to(bound)
        predicted = lehmer_asymptotic(bound)
        ratio = actual / predicted if predicted > 0 else 0
        print(f"  {bound:<12} {actual:<10} {predicted:<12.1f} {ratio:.4f}")


# ────────────────────────────────────────────────────────────────
# Application 3: Square Congruence Statistics
# ────────────────────────────────────────────────────────────────

def count_square_congruences(n: int) -> dict:
    """
    Count square congruences x² ≡ y² (mod n) with various properties.
    """
    total = 0
    trivial = 0
    nontrivial = 0
    
    for x in range(n):
        for y in range(n):
            if (x**2 - y**2) % n == 0:
                total += 1
                if (x - y) % n == 0 or (x + y) % n == 0:
                    trivial += 1
                else:
                    nontrivial += 1
    
    return {
        'n': n,
        'total': total,
        'trivial': trivial,
        'nontrivial': nontrivial,
        'ratio': nontrivial / total if total > 0 else 0,
    }


def demo_congruence_statistics():
    """Show how nontrivial square congruences relate to factoring."""
    print("\n" + "=" * 60)
    print("APPLICATION 3: Square Congruence Statistics")
    print("=" * 60)
    
    print(f"\n  {'n':<6} {'Type':<12} {'Total':<8} {'Trivial':<10} "
          f"{'Nontrivial':<12} {'NT/Total'}")
    print(f"  {'-'*6} {'-'*12} {'-'*8} {'-'*10} {'-'*12} {'-'*8}")
    
    test_numbers = [
        (7, "prime"),
        (11, "prime"),
        (15, "3×5"),
        (21, "3×7"),
        (35, "5×7"),
        (30, "2×3×5"),
    ]
    
    for n, ntype in test_numbers:
        stats = count_square_congruences(n)
        print(f"  {n:<6} {ntype:<12} {stats['total']:<8} {stats['trivial']:<10} "
              f"{stats['nontrivial']:<12} {stats['ratio']:.4f}")
    
    print("\n  Key insight: Primes have NO nontrivial square congruences.")
    print("  Composites with k distinct prime factors have more nontrivial congruences.")


# ────────────────────────────────────────────────────────────────
# Application 4: Certified Factoring Verification
# ────────────────────────────────────────────────────────────────

def verify_factoring_certificate(n: int, x: int, y: int) -> dict:
    """
    Verify a factoring certificate: a pair (x, y) with x² ≡ y² (mod n)
    that yields a nontrivial factor.
    
    This mirrors the formally verified theorem:
    certified_factor_extraction' in CongruenceLatticeFactoring.lean
    """
    result = {
        'n': n,
        'x': x,
        'y': y,
        'x_sq_mod_n': x**2 % n,
        'y_sq_mod_n': y**2 % n,
        'is_valid_congruence': (x**2 - y**2) % n == 0,
        'x_minus_y_mod_n': (x - y) % n,
        'x_plus_y_mod_n': (x + y) % n,
        'is_nontrivial': (x - y) % n != 0 and (x + y) % n != 0,
        'gcd_minus': math.gcd(abs(x - y), n),
        'gcd_plus': math.gcd(abs(x + y), n),
        'factor': None,
    }
    
    if result['is_valid_congruence'] and result['is_nontrivial']:
        d = math.gcd(abs(x - y), n)
        if 1 < d < n:
            result['factor'] = d
        else:
            d = math.gcd(abs(x + y), n)
            if 1 < d < n:
                result['factor'] = d
    
    return result


def demo_certified_verification():
    """Demonstrate certificate verification."""
    print("\n" + "=" * 60)
    print("APPLICATION 4: Certified Factoring Verification")
    print("=" * 60)
    
    certificates = [
        (91, 27, 1),
        (143, 12, 1),
        (35, 6, 1),
    ]
    
    for n, x, y in certificates:
        cert = verify_factoring_certificate(n, x, y)
        print(f"\n  Certificate for n = {n}:")
        print(f"    (x, y) = ({x}, {y})")
        print(f"    x² mod n = {cert['x_sq_mod_n']}, y² mod n = {cert['y_sq_mod_n']}")
        print(f"    Valid congruence: {cert['is_valid_congruence']}")
        print(f"    Nontrivial: {cert['is_nontrivial']}")
        print(f"    gcd(x-y, n) = {cert['gcd_minus']}")
        if cert['factor']:
            d = cert['factor']
            print(f"    ✓ Factor found: {d}, {n} = {d} × {n//d}")
        else:
            print(f"    ✗ No factor extracted")


# ────────────────────────────────────────────────────────────────
# Run all applications
# ────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("\n" + "━" * 60)
    print("  APPLICATIONS OF PYTHAGOREAN LATTICE FACTORING")
    print("━" * 60 + "\n")
    
    demo_rsa_analysis()
    demo_berggren_combinatorics()
    demo_congruence_statistics()
    demo_certified_verification()
    
    print("\n" + "━" * 60)
    print("  All applications complete.")
    print("━" * 60)


#!/usr/bin/env python3
"""
Demonstration of Pythagorean Lattice Factoring

This script demonstrates the core mathematical ideas behind the certified
reduction between integer factoring and finding short vectors in lattices
derived from Pythagorean triple arithmetic.

Key demonstrations:
1. Square-root collision factoring
2. Berggren tree generation of primitive Pythagorean triples
3. Euclid parametrization and congruence data extraction
4. Divisibility lattice factor embedding
"""

import math
from typing import Tuple, List, Optional

# ────────────────────────────────────────────────────────────────
# Demo 1: Square-Root Collision Factoring
# ────────────────────────────────────────────────────────────────

def factor_from_collision(n: int, x: int, y: int) -> Optional[int]:
    """
    Given x² ≡ y² (mod n) with x ≢ ±y (mod n),
    extract a nontrivial factor of n via gcd(x - y, n).
    
    This is the core arithmetic engine behind the quadratic sieve,
    number field sieve, and Shor's algorithm.
    """
    if (x**2 - y**2) % n != 0:
        return None  # Not a valid square congruence
    
    d = math.gcd(abs(x - y), n)
    if 1 < d < n:
        return d
    
    d = math.gcd(abs(x + y), n)
    if 1 < d < n:
        return d
    
    return None  # Trivial collision


def demo_square_collision():
    """Demonstrate factoring via square-root collisions."""
    print("=" * 60)
    print("DEMO 1: Square-Root Collision Factoring")
    print("=" * 60)
    
    examples = [
        (15, 4, 1),     # 4² ≡ 1² (mod 15), 16-1=15
        (21, 10, 1),    # 10² ≡ 1² (mod 21), 100-1=99=21*4+15... actually 100 mod 21 = 16, 1 mod 21 = 1
        (35, 6, 1),     # 36 - 1 = 35
        (77, 32, 10),   # 1024 - 100 = 924 = 77 * 12
        (91, 27, 1),    # 729 - 1 = 728 = 91 * 8
        (143, 12, 1),   # 144 - 1 = 143
        (221, 47, 21),  # Check: 2209 - 441 = 1768 = 221 * 8
    ]
    
    for n, x, y in examples:
        if (x**2 - y**2) % n != 0:
            continue
        d = factor_from_collision(n, x, y)
        if d:
            print(f"  n={n:>4}: {x}² ≡ {y}² (mod {n}), "
                  f"gcd({x}-{y}, {n}) = {math.gcd(abs(x-y), n)}, "
                  f"factor = {d}, {n} = {d} × {n//d}")
        else:
            print(f"  n={n:>4}: {x}² ≡ {y}² (mod {n}), collision is trivial")
    print()


# ────────────────────────────────────────────────────────────────
# Demo 2: Berggren Tree of Primitive Pythagorean Triples
# ────────────────────────────────────────────────────────────────

# The three Berggren matrices
BERGGREN_U = [[1, -2, 2], [2, -1, 2], [2, -2, 3]]   # Left child
BERGGREN_A = [[1, 2, 2], [2, 1, 2], [2, 2, 3]]       # Middle child
BERGGREN_D = [[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]]    # Right child

BERGGREN_MATRICES = [BERGGREN_U, BERGGREN_A, BERGGREN_D]
BERGGREN_NAMES = ['U', 'A', 'D']


def mat_vec_mul(M: List[List[int]], v: List[int]) -> List[int]:
    """Multiply 3×3 matrix by 3-vector."""
    return [sum(M[i][j] * v[j] for j in range(3)) for i in range(3)]


def generate_berggren_tree(root: List[int], depth: int) -> List[Tuple[List[int], str]]:
    """
    Generate all primitive Pythagorean triples up to given depth
    in the Berggren tree, starting from root = (3, 4, 5).
    """
    results = [(root, "")]
    queue = [(root, "", 0)]
    
    while queue:
        triple, word, d = queue.pop(0)
        if d >= depth:
            continue
        for i, (M, name) in enumerate(zip(BERGGREN_MATRICES, BERGGREN_NAMES)):
            child = mat_vec_mul(M, triple)
            child_word = word + name
            results.append((child, child_word))
            queue.append((child, child_word, d + 1))
    
    return results


def verify_pythagorean(a: int, b: int, c: int) -> bool:
    """Check a² + b² = c²."""
    return a**2 + b**2 == c**2


def verify_primitive(a: int, b: int, c: int) -> bool:
    """Check gcd(a, b, c) = 1."""
    return math.gcd(math.gcd(abs(a), abs(b)), abs(c)) == 1


def demo_berggren_tree():
    """Demonstrate the Berggren tree generation."""
    print("=" * 60)
    print("DEMO 2: Berggren Tree of Primitive Pythagorean Triples")
    print("=" * 60)
    
    triples = generate_berggren_tree([3, 4, 5], depth=3)
    
    print(f"  Generated {len(triples)} triples up to depth 3:\n")
    print(f"  {'Word':<8} {'Triple':<20} {'Pythagorean?':<14} {'Primitive?'}")
    print(f"  {'-'*8} {'-'*20} {'-'*14} {'-'*10}")
    
    for triple, word in sorted(triples, key=lambda x: x[0][2]):
        a, b, c = triple
        is_pyth = verify_pythagorean(a, b, c)
        is_prim = verify_primitive(a, b, c)
        word_str = word if word else "(root)"
        print(f"  {word_str:<8} ({a:>4},{b:>4},{c:>4})  "
              f"{'✓' if is_pyth else '✗':<14} {'✓' if is_prim else '✗'}")
    print()


# ────────────────────────────────────────────────────────────────
# Demo 3: Euclid Parametrization
# ────────────────────────────────────────────────────────────────

def euclid_triple(m: int, k: int) -> Tuple[int, int, int]:
    """Generate the Euclid triple (m²-k², 2mk, m²+k²)."""
    return (m**2 - k**2, 2*m*k, m**2 + k**2)


def demo_euclid_parametrization():
    """Demonstrate Euclid's parametrization and sum-difference identities."""
    print("=" * 60)
    print("DEMO 3: Euclid Parametrization & Congruence Data")
    print("=" * 60)
    
    print("\n  Euclid triple (m²-k², 2mk, m²+k²):")
    print(f"  {'(m,k)':<10} {'(a,b,c)':<20} {'c-a=2k²':<12} {'c+a=2m²':<12} {'a²+b²=c²?'}")
    print(f"  {'-'*10} {'-'*20} {'-'*12} {'-'*12} {'-'*10}")
    
    for m in range(2, 8):
        for k in range(1, m):
            if math.gcd(m, k) == 1 and (m - k) % 2 == 1:
                a, b, c = euclid_triple(m, k)
                is_pyth = verify_pythagorean(a, b, c)
                print(f"  ({m},{k})     ({a:>4},{b:>4},{c:>4})  "
                      f"{c-a:>4}={2*k**2:<6} {c+a:>4}={2*m**2:<6} "
                      f"{'✓' if is_pyth else '✗'}")
    print()


# ────────────────────────────────────────────────────────────────
# Demo 4: Divisibility Lattice Factor Embedding
# ────────────────────────────────────────────────────────────────

def demo_factor_embedding():
    """Demonstrate how factors embed as short vectors in the divisibility lattice."""
    print("=" * 60)
    print("DEMO 4: Factor Embedding in the Divisibility Lattice")
    print("=" * 60)
    
    composites = [15, 21, 35, 77, 91, 143, 221, 323, 1001, 10403]
    
    print(f"\n  For each composite n, each factor d gives vector (d, n/d):")
    print(f"  {'n':<8} {'d':<6} {'n/d':<6} {'‖v‖²=d²+(n/d)²':<18} {'n²':<12} {'‖v‖²≤n²?'}")
    print(f"  {'-'*8} {'-'*6} {'-'*6} {'-'*18} {'-'*12} {'-'*10}")
    
    for n in composites:
        for d in range(2, n):
            if n % d == 0 and d * d <= n:
                q = n // d
                norm_sq = d**2 + q**2
                n_sq = n**2
                print(f"  {n:<8} {d:<6} {q:<6} {norm_sq:<18} {n_sq:<12} "
                      f"{'✓' if norm_sq <= n_sq else '✗'}")
    print()


# ────────────────────────────────────────────────────────────────
# Demo 5: Pythagorean Factoring Pipeline
# ────────────────────────────────────────────────────────────────

def demo_pythagorean_factoring():
    """
    End-to-end demonstration: use Pythagorean triples to find
    square congruences modulo a composite number.
    """
    print("=" * 60)
    print("DEMO 5: Pythagorean Factoring Pipeline")
    print("=" * 60)
    
    n = 91  # = 7 × 13
    print(f"\n  Target: n = {n}")
    print(f"  Searching for Pythagorean triples with useful congruence data...\n")
    
    found = False
    for m in range(2, 50):
        for k in range(1, m):
            a, b, c = euclid_triple(m, k)
            # Check if b² ≡ 0 (mod n), giving c² ≡ a² (mod n)
            if b**2 % n == 0:
                d1 = math.gcd(abs(c - a), n)
                d2 = math.gcd(abs(c + a), n)
                if 1 < d1 < n or 1 < d2 < n:
                    factor = d1 if 1 < d1 < n else d2
                    print(f"  Found! m={m}, k={k}: triple ({a}, {b}, {c})")
                    print(f"    b² = {b**2} ≡ 0 (mod {n})")
                    print(f"    c² - a² = {c**2 - a**2} = b² = {b**2}")
                    print(f"    c - a = {c - a}, c + a = {c + a}")
                    print(f"    gcd(c-a, n) = {d1}, gcd(c+a, n) = {d2}")
                    print(f"    → Factor: {factor}, {n} = {factor} × {n // factor}")
                    found = True
                    break
            # Also check if (c² - a²) ≡ 0 (mod n)
            if (c**2 - a**2) % n == 0 and (c - a) % n != 0 and (c + a) % n != 0:
                d1 = math.gcd(abs(c - a), n)
                d2 = math.gcd(abs(c + a), n)
                if 1 < d1 < n or 1 < d2 < n:
                    factor = d1 if 1 < d1 < n else d2
                    print(f"  Found! m={m}, k={k}: triple ({a}, {b}, {c})")
                    print(f"    c² - a² = {c**2 - a**2} ≡ 0 (mod {n})")
                    print(f"    c - a = {c - a} (not ≡ 0 mod {n})")
                    print(f"    c + a = {c + a} (not ≡ 0 mod {n})")
                    print(f"    gcd(c-a, n) = {d1}")
                    print(f"    → Factor: {factor}, {n} = {factor} × {n // factor}")
                    found = True
                    break
        if found:
            break
    
    if not found:
        print("  No factoring triple found in search range.")
    print()


# ────────────────────────────────────────────────────────────────
# Run all demos
# ────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("\n" + "━" * 60)
    print("  PYTHAGOREAN LATTICE FACTORING — DEMONSTRATIONS")
    print("━" * 60 + "\n")
    
    demo_square_collision()
    demo_berggren_tree()
    demo_euclid_parametrization()
    demo_factor_embedding()
    demo_pythagorean_factoring()
    
    print("━" * 60)
    print("  All demonstrations complete.")
    print("━" * 60)


#!/usr/bin/env python3
"""
Visualizations for Pythagorean Lattice Factoring

Generates matplotlib figures saved as PNG files and base64-encoded strings.
"""

import math
import base64
import io

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import matplotlib.patches as mpatches
    HAS_MPL = True
except ImportError:
    HAS_MPL = False
    print("matplotlib not available; generating SVG fallbacks")


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def generate_berggren_tree_viz() -> str:
    """Visualize the first few levels of the Berggren tree."""
    if not HAS_MPL:
        return "<svg width='400' height='200'><text x='10' y='100'>Berggren Tree (matplotlib unavailable)</text></svg>"
    
    BERGGREN = {
        'U': [[1, -2, 2], [2, -1, 2], [2, -2, 3]],
        'A': [[1, 2, 2], [2, 1, 2], [2, 2, 3]],
        'D': [[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]],
    }
    
    def mat_vec(M, v):
        return [sum(M[i][j]*v[j] for j in range(3)) for i in range(3)]
    
    fig, ax = plt.subplots(1, 1, figsize=(14, 8))
    
    # Generate tree nodes with positions
    root = [3, 4, 5]
    levels = [[(root, "", 0.5)]]
    
    for depth in range(3):
        current = levels[-1]
        next_level = []
        for triple, word, x_pos in current:
            width = 0.5 ** (depth + 1)
            for i, (name, color) in enumerate(zip(['U', 'A', 'D'], ['#2196F3', '#4CAF50', '#FF9800'])):
                child = mat_vec(BERGGREN[name], triple)
                child_x = x_pos + (i - 1) * width
                next_level.append((child, word + name, child_x))
        levels.append(next_level)
    
    # Draw edges and nodes
    y_positions = [0.9, 0.65, 0.4, 0.15]
    
    for depth, level in enumerate(levels):
        y = y_positions[depth]
        for triple, word, x_pos in level:
            a, b, c = triple
            label = f"({a},{b},{c})"
            
            # Draw node
            ax.add_patch(plt.Circle((x_pos, y), 0.02, color='#1565C0', zorder=5))
            ax.text(x_pos, y - 0.04, label, ha='center', va='top', fontsize=6, fontweight='bold')
            
            # Draw edges to children
            if depth < 3:
                width = 0.5 ** (depth + 1)
                for i, color in enumerate(['#2196F3', '#4CAF50', '#FF9800']):
                    child_x = x_pos + (i - 1) * width
                    child_y = y_positions[depth + 1]
                    ax.plot([x_pos, child_x], [y, child_y], color=color, linewidth=1.5, alpha=0.6, zorder=1)
    
    ax.set_xlim(-0.1, 1.1)
    ax.set_ylim(0, 1)
    ax.set_aspect('auto')
    ax.axis('off')
    ax.set_title('Berggren Tree of Primitive Pythagorean Triples', fontsize=14, fontweight='bold', pad=20)
    
    # Legend
    legend_elements = [
        mpatches.Patch(color='#2196F3', label='U (left)'),
        mpatches.Patch(color='#4CAF50', label='A (middle)'),
        mpatches.Patch(color='#FF9800', label='D (right)'),
    ]
    ax.legend(handles=legend_elements, loc='upper right', fontsize=9)
    
    return fig_to_base64(fig)


def generate_lattice_viz() -> str:
    """Visualize the divisibility lattice for n=15."""
    if not HAS_MPL:
        return "<svg width='400' height='400'><text x='10' y='200'>Lattice (matplotlib unavailable)</text></svg>"
    
    n = 15
    fig, ax = plt.subplots(1, 1, figsize=(8, 8))
    
    # Plot lattice points where n | x*y
    for x in range(-20, 21):
        for y in range(-20, 21):
            if x == 0 and y == 0:
                continue
            if (x * y) % n == 0:
                ax.plot(x, y, 'o', color='#90CAF9', markersize=4, alpha=0.5)
    
    # Highlight factor vectors
    factors = [(3, 5), (5, 3), (-3, -5), (-5, -3), (3, -5), (5, -3), (-3, 5), (-5, 3)]
    for x, y in factors:
        ax.plot(x, y, 'o', color='#F44336', markersize=10, zorder=5)
        ax.annotate(f'({x},{y})', (x, y), textcoords="offset points", xytext=(8, 8), fontsize=8)
    
    # Draw factor vectors from origin
    ax.annotate('', xy=(3, 5), xytext=(0, 0),
                arrowprops=dict(arrowstyle='->', color='#D32F2F', lw=2))
    ax.annotate('', xy=(5, 3), xytext=(0, 0),
                arrowprops=dict(arrowstyle='->', color='#1976D2', lw=2))
    
    ax.plot(0, 0, 'ko', markersize=8, zorder=5)
    ax.set_xlim(-18, 18)
    ax.set_ylim(-18, 18)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)
    ax.axhline(y=0, color='k', linewidth=0.5)
    ax.axvline(x=0, color='k', linewidth=0.5)
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('y', fontsize=12)
    ax.set_title(f'Divisibility Lattice for n={n}\nFactor vectors (3,5) and (5,3) shown in red/blue',
                 fontsize=13, fontweight='bold')
    
    return fig_to_base64(fig)


def generate_norm_ratio_viz() -> str:
    """Visualize ‖v‖²/n² ratio for factor vectors across semiprimes."""
    if not HAS_MPL:
        return "<svg width='400' height='300'><text x='10' y='150'>Norm ratios (matplotlib unavailable)</text></svg>"
    
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    
    def is_prime(n):
        if n < 2: return False
        for i in range(2, int(n**0.5) + 1):
            if n % i == 0: return False
        return True
    
    primes = [p for p in range(3, 200) if is_prime(p)]
    
    ns = []
    ratios = []
    
    for i in range(len(primes)):
        for j in range(i, len(primes)):
            p, q = primes[i], primes[j]
            n = p * q
            if n > 10000:
                break
            norm_sq = p**2 + q**2
            ratio = norm_sq / n**2
            ns.append(n)
            ratios.append(ratio)
    
    ax.scatter(ns, ratios, alpha=0.4, s=15, color='#1976D2')
    ax.axhline(y=2/math.pi**2, color='#F44336', linestyle='--', linewidth=1.5,
               label=f'2/π² ≈ {2/math.pi**2:.4f}')
    ax.set_xlabel('n = p·q', fontsize=12)
    ax.set_ylabel('‖(p,q)‖² / n²', fontsize=12)
    ax.set_title('Factor Vector Norm Ratio for Semiprimes', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.set_ylim(0, 0.6)
    ax.grid(True, alpha=0.3)
    
    return fig_to_base64(fig)


def generate_triple_density_viz() -> str:
    """Visualize density of primitive Pythagorean triples vs Lehmer's asymptotic."""
    if not HAS_MPL:
        return "<svg width='400' height='300'><text x='10' y='150'>Density (matplotlib unavailable)</text></svg>"
    
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    
    bounds = list(range(10, 5001, 10))
    actual_counts = []
    lehmer_counts = []
    
    for bound in bounds:
        count = 0
        for m in range(2, int(math.sqrt(bound)) + 1):
            for k in range(1, m):
                if math.gcd(m, k) == 1 and (m - k) % 2 == 1:
                    if m**2 + k**2 <= bound:
                        count += 1
        actual_counts.append(count)
        lehmer_counts.append(bound / (2 * math.pi))
    
    ax.plot(bounds, actual_counts, color='#1976D2', linewidth=2, label='Actual count')
    ax.plot(bounds, lehmer_counts, color='#F44336', linewidth=2, linestyle='--', label='Lehmer: x/(2π)')
    ax.set_xlabel('Hypotenuse bound', fontsize=12)
    ax.set_ylabel('Number of primitive triples', fontsize=12)
    ax.set_title('Primitive Pythagorean Triple Density', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    
    viz1 = generate_berggren_tree_viz()
    print(f"  Berggren tree: {len(viz1)} chars")
    
    viz2 = generate_lattice_viz()
    print(f"  Lattice: {len(viz2)} chars")
    
    viz3 = generate_norm_ratio_viz()
    print(f"  Norm ratios: {len(viz3)} chars")
    
    viz4 = generate_triple_density_viz()
    print(f"  Triple density: {len(viz4)} chars")
    
    print("Done!")
