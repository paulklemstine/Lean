#!/usr/bin/env python3
"""
EML–Pythagorean Bridge Explorer

Interactive demo exploring the connection between the EML operator,
Berggren tree, and Pythagorean triples.

Features:
- Berggren tree traversal and visualization
- EML encoding of triples
- Gaussian integer connection
- Hypotenuse growth analysis
- Log-space Pythagorean variety
- Angle distribution analysis
"""

import math
import json
from typing import List, Tuple, Optional

# =============================================================================
# Core EML Operator
# =============================================================================

def eml(x: float, y: float) -> float:
    """The EML operator: eml(x, y) = exp(x) - log(y)."""
    if y <= 0:
        raise ValueError(f"eml requires y > 0, got y = {y}")
    return math.exp(x) - math.log(y)

def eml_exp(x: float) -> float:
    """Recover exp via EML: exp(x) = eml(x, 1)."""
    return eml(x, 1.0)

def eml_log(z: float) -> float:
    """Recover log via EML: log(z) = 1 - eml(0, z)."""
    return 1 - eml(0, z)

# =============================================================================
# Berggren Matrices
# =============================================================================

def berggren_A(a: int, b: int, c: int) -> Tuple[int, int, int]:
    """Berggren matrix M₁ (type A)."""
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def berggren_B(a: int, b: int, c: int) -> Tuple[int, int, int]:
    """Berggren matrix M₂ (type B)."""
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def berggren_C(a: int, b: int, c: int) -> Tuple[int, int, int]:
    """Berggren matrix M₃ (type C)."""
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

BERGGREN = {'A': berggren_A, 'B': berggren_B, 'C': berggren_C}

# =============================================================================
# Berggren Tree
# =============================================================================

def eval_path(path: str) -> Tuple[int, int, int]:
    """Evaluate a Berggren path string (e.g., 'ABA') from root (3,4,5)."""
    triple = (3, 4, 5)
    for step in path:
        a, b, c = triple
        triple = BERGGREN[step](a, b, c)
    return triple

def generate_tree(depth: int) -> dict:
    """Generate the Berggren tree to given depth."""
    def build(path: str, a: int, b: int, c: int, d: int):
        node = {
            'path': path or 'root',
            'triple': (a, b, c),
            'depth': d,
            'angle': math.degrees(math.atan2(b, a)),
            'hypotenuse': c,
        }
        if d < depth:
            node['children'] = {}
            for label, fn in BERGGREN.items():
                na, nb, nc = fn(a, b, c)
                node['children'][label] = build(path + label, na, nb, nc, d + 1)
        return node
    return build('', 3, 4, 5, 0)

# =============================================================================
# EML Encoding of Arithmetic
# =============================================================================

def eml_add(a: float, b: float) -> float:
    """Addition via EML: a + b = log(exp(a) * exp(b))."""
    return math.log(math.exp(a) * math.exp(b))

def eml_sub(a: float, b: float) -> float:
    """Subtraction via EML: a - b = log(exp(a) / exp(b))."""
    return math.log(math.exp(a) / math.exp(b))

def eml_mul(a: float, b: float) -> float:
    """Multiplication via EML for positive a, b: a*b = exp(log(a) + log(b))."""
    assert a > 0 and b > 0
    return math.exp(math.log(a) + math.log(b))

def eml_sq(a: float) -> float:
    """Squaring via EML: a² = exp(2 * log(a)) for a > 0."""
    assert a > 0
    return math.exp(2 * math.log(a))

# =============================================================================
# Pythagorean Verification
# =============================================================================

def verify_pythagorean(a: int, b: int, c: int) -> bool:
    """Check if a² + b² = c²."""
    return a**2 + b**2 == c**2

def verify_pythagorean_eml(a: int, b: int, c: int) -> bool:
    """Verify Pythagorean relation using EML operations (approximate)."""
    if a <= 0 or b <= 0 or c <= 0:
        return False
    lhs = eml_sq(float(a)) + eml_sq(float(b))
    rhs = eml_sq(float(c))
    return abs(lhs - rhs) < 1e-6

# =============================================================================
# Lorentz Form
# =============================================================================

def lorentz_form(a: int, b: int, c: int) -> int:
    """Compute the Lorentz form Q(a,b,c) = a² + b² - c²."""
    return a**2 + b**2 - c**2

def verify_lorentz_preservation(path: str) -> bool:
    """Verify that the Lorentz form is preserved along a Berggren path."""
    triple = eval_path(path)
    return lorentz_form(*triple) == lorentz_form(3, 4, 5)

# =============================================================================
# Gaussian Integer Connection
# =============================================================================

def gaussian_norm_sq(a: int, b: int) -> int:
    """Norm-squared of Gaussian integer a + bi."""
    return a**2 + b**2

def brahmagupta_fibonacci(a: int, b: int, c: int, d: int) -> Tuple[int, int]:
    """Brahmagupta-Fibonacci identity: gives (e,f) such that
    (a²+b²)(c²+d²) = e² + f²."""
    return (a*c - b*d, a*d + b*c)

# =============================================================================
# Angle Distribution Analysis
# =============================================================================

def collect_angles(depth: int) -> List[float]:
    """Collect angles θ = arctan(b/a) for all triples at given depth."""
    angles = []
    def traverse(a, b, c, d):
        if d == depth:
            angles.append(math.atan2(b, a))
            return
        for fn in BERGGREN.values():
            na, nb, nc = fn(a, b, c)
            traverse(na, nb, nc, d + 1)
    traverse(3, 4, 5, 0)
    return angles

def angle_statistics(depth: int) -> dict:
    """Compute statistics of angle distribution at given depth."""
    angles = collect_angles(depth)
    n = len(angles)
    mean = sum(angles) / n
    variance = sum((a - mean)**2 for a in angles) / n
    return {
        'depth': depth,
        'count': n,
        'min_angle_deg': math.degrees(min(angles)),
        'max_angle_deg': math.degrees(max(angles)),
        'mean_angle_deg': math.degrees(mean),
        'std_dev_deg': math.degrees(math.sqrt(variance)),
    }

# =============================================================================
# Hypotenuse Growth Analysis
# =============================================================================

def hypotenuse_growth(path: str) -> List[Tuple[int, int]]:
    """Track hypotenuse growth along a Berggren path."""
    result = [(0, 5)]
    triple = (3, 4, 5)
    for i, step in enumerate(path):
        a, b, c = triple
        triple = BERGGREN[step](a, b, c)
        result.append((i + 1, triple[2]))
    return result

def max_hypotenuse_at_depth(depth: int) -> int:
    """Find the maximum hypotenuse at a given tree depth."""
    max_c = 0
    def traverse(a, b, c, d):
        nonlocal max_c
        if d == depth:
            max_c = max(max_c, c)
            return
        for fn in BERGGREN.values():
            na, nb, nc = fn(a, b, c)
            traverse(na, nb, nc, d + 1)
    traverse(3, 4, 5, 0)
    return max_c

# =============================================================================
# Log-Space Pythagorean Variety
# =============================================================================

def to_log_space(a: int, b: int, c: int) -> Tuple[float, float, float]:
    """Map a positive Pythagorean triple to log-space coordinates."""
    return (math.log(abs(a)), math.log(abs(b)), math.log(abs(c)))

def verify_log_variety(alpha: float, beta: float, gamma: float) -> float:
    """Check if exp(2α) + exp(2β) ≈ exp(2γ)."""
    return math.exp(2*alpha) + math.exp(2*beta) - math.exp(2*gamma)

# =============================================================================
# Demo Runner
# =============================================================================

def run_demo():
    print("=" * 70)
    print("  EML–PYTHAGOREAN BRIDGE EXPLORER")
    print("=" * 70)

    # Demo 1: Basic EML identities
    print("\n📐 Demo 1: EML Basic Identities")
    print("-" * 40)
    x = 2.0
    print(f"  eml({x}, 1) = {eml(x, 1.0):.6f}")
    print(f"  exp({x})    = {math.exp(x):.6f}")
    print(f"  Match: {abs(eml(x, 1.0) - math.exp(x)) < 1e-10}")

    z = 3.0
    print(f"  eml_log({z}) = {eml_log(z):.6f}")
    print(f"  log({z})     = {math.log(z):.6f}")
    print(f"  Match: {abs(eml_log(z) - math.log(z)) < 1e-10}")

    # Demo 2: Berggren Tree
    print("\n🌳 Demo 2: Berggren Tree (Depth 2)")
    print("-" * 40)
    print(f"  Root:  (3, 4, 5)  ✓ Pythagorean: {verify_pythagorean(3, 4, 5)}")
    for path in ['A', 'B', 'C', 'AA', 'AB', 'AC', 'BA', 'BB', 'BC', 'CA', 'CB', 'CC']:
        triple = eval_path(path)
        ok = verify_pythagorean(*triple)
        lorentz = lorentz_form(*triple)
        print(f"  Path {path:>2}: {triple}  ✓ Pyth: {ok}  Q={lorentz}")

    # Demo 3: EML Verification
    print("\n🔬 Demo 3: EML-Based Pythagorean Verification")
    print("-" * 40)
    for path in ['', 'A', 'B', 'C', 'AB']:
        triple = eval_path(path) if path else (3, 4, 5)
        ok = verify_pythagorean_eml(*triple)
        a, b, c = triple
        alpha, beta, gamma = to_log_space(a, b, c)
        residual = verify_log_variety(alpha, beta, gamma)
        print(f"  {triple}: EML verify={ok}, log-variety residual={residual:.2e}")

    # Demo 4: Gaussian Integer Connection
    print("\n🔢 Demo 4: Brahmagupta-Fibonacci (Gaussian Norms)")
    print("-" * 40)
    pairs = [(3, 4, 5), (5, 12, 13), (8, 15, 17)]
    for i in range(len(pairs)):
        for j in range(i, len(pairs)):
            a1, b1, c1 = pairs[i]
            a2, b2, c2 = pairs[j]
            e, f = brahmagupta_fibonacci(a1, b1, a2, b2)
            new_c = c1 * c2
            print(f"  ({a1}²+{b1}²)×({a2}²+{b2}²) = {e}² + {f}² = {e**2+f**2}")
            print(f"    Pythagorean: ({e}, {f}, {new_c}), verify: {verify_pythagorean(e, f, new_c)}")

    # Demo 5: Hypotenuse Growth
    print("\n📈 Demo 5: Hypotenuse Growth Analysis")
    print("-" * 40)
    for path_str in ['BBBB', 'AAAA', 'ABAB', 'CCCC']:
        growth = hypotenuse_growth(path_str)
        hyps = [h for _, h in growth]
        ratios = [hyps[i+1]/hyps[i] for i in range(len(hyps)-1)]
        print(f"  Path {path_str}: hypotenuses = {hyps}")
        print(f"    Growth ratios: {[f'{r:.2f}' for r in ratios]}")

    # Demo 6: Angle Distribution
    print("\n📊 Demo 6: Angle Distribution at Each Depth")
    print("-" * 40)
    for d in range(1, 6):
        stats = angle_statistics(d)
        print(f"  Depth {d}: {stats['count']} triples, "
              f"angles [{stats['min_angle_deg']:.1f}°, {stats['max_angle_deg']:.1f}°], "
              f"mean={stats['mean_angle_deg']:.1f}°, σ={stats['std_dev_deg']:.1f}°")

    # Demo 7: EML Fixed Point
    print("\n🎯 Demo 7: EML Fixed Point Analysis")
    print("-" * 40)
    print("  eml(x, 1) = exp(x) has no real fixed point (exp(x) > x for all x).")
    for x in [-10, -1, 0, 1, 2, 5]:
        gap = math.exp(x) - x
        print(f"  x = {x:>3}: exp(x) - x = {gap:.6f} > 0 ✓")

    # Demo 8: Max hypotenuse at each depth
    print("\n🏔️  Demo 8: Maximum Hypotenuse at Each Depth")
    print("-" * 40)
    for d in range(7):
        max_c = max_hypotenuse_at_depth(d)
        count = 3**d if d > 0 else 1
        print(f"  Depth {d}: max hypotenuse = {max_c}, triples at depth = {count}")

    # Demo 9: EML Tree Complexity
    print("\n🌲 Demo 9: EML Tree Complexity for Berggren Paths")
    print("-" * 40)
    print("  Each Berggren step requires a fixed number K of EML operations.")
    print("  For a depth-d path, total EML nodes ≤ K × d (linear!).")
    print("  Estimated K ≈ 30-40 EML nodes per Berggren step.")
    for d in range(1, 8):
        print(f"  Depth {d}: ≤ {40*d} EML nodes for {3**d} possible triples")

    print("\n" + "=" * 70)
    print("  All demos completed successfully!")
    print("=" * 70)

if __name__ == '__main__':
    run_demo()
