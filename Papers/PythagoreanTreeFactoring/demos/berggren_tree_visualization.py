#!/usr/bin/env python3
"""
Berggren Tree Visualization & Factoring Demo
=============================================

Demonstrates the Berggren ternary tree of primitive Pythagorean triples
and its application to integer factoring.

The Berggren tree generates ALL primitive Pythagorean triples from (3,4,5)
using three 3×3 matrix transformations that preserve the Pythagorean property.

Key insight: Inverse tree traversal = Euclidean algorithm = Gauss lattice reduction.
"""

import numpy as np
from math import gcd, isqrt
from collections import deque
import json
import time

# ============================================================================
# Berggren Matrices (3×3, acting on triples (a, b, c))
# ============================================================================

B1 = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]])
B2 = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]])
B3 = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])

# Berggren 2×2 matrices (acting on Euclid parameters (m, n))
M1 = np.array([[2, -1], [1, 0]])
M2 = np.array([[2, 1], [1, 0]])
M3 = np.array([[1, 2], [0, 1]])

# Inverses
M1_inv = np.array([[0, 1], [-1, 2]])
M3_inv = np.array([[1, -2], [0, 1]])


def euclid_to_triple(m, n):
    """Convert Euclid parameters (m, n) to Pythagorean triple (a, b, c)."""
    return (m*m - n*n, 2*m*n, m*m + n*n)


def triple_to_euclid(a, b, c):
    """Convert primitive Pythagorean triple to Euclid parameters.
    Assumes a is odd, b is even (swap if needed)."""
    if a % 2 == 0:
        a, b = b, a
    # c = m² + n², a = m² - n², b = 2mn
    # m² = (a + c) / 2, n² = (c - a) / 2
    m = isqrt((a + c) // 2)
    n = isqrt((c - a) // 2)
    return m, n


# ============================================================================
# Tree Generation (BFS)
# ============================================================================

def generate_berggren_tree(max_depth=5):
    """Generate the Berggren tree via BFS up to given depth."""
    root = np.array([3, 4, 5])
    tree = {0: [tuple(root)]}
    queue = deque([(root, 0)])

    while queue:
        node, depth = queue.popleft()
        if depth >= max_depth:
            continue

        if depth + 1 not in tree:
            tree[depth + 1] = []

        for B in [B1, B2, B3]:
            child = B @ node
            # Ensure positive values
            child = np.abs(child)
            tree[depth + 1].append(tuple(child))
            queue.append((child, depth + 1))

    return tree


def print_tree(tree, max_depth=4):
    """Pretty-print the Berggren tree."""
    print("=" * 60)
    print("BERGGREN TREE OF PRIMITIVE PYTHAGOREAN TRIPLES")
    print("=" * 60)
    for depth in sorted(tree.keys()):
        if depth > max_depth:
            break
        triples = tree[depth]
        print(f"\nDepth {depth} ({len(triples)} triple{'s' if len(triples) > 1 else ''}):")
        for t in sorted(triples):
            a, b, c = t
            # Verify
            check = "✓" if a*a + b*b == c*c else "✗"
            prim = "P" if gcd(gcd(a, b), c) == 1 else " "
            print(f"  ({a:4d}, {b:4d}, {c:4d})  {check} {prim}")


# ============================================================================
# Inverse Berggren Descent (= Euclidean Algorithm)
# ============================================================================

def berggren_descent(m, n, verbose=True):
    """Trace inverse Berggren descent from (m, n) to (2, 1).
    This is equivalent to the Euclidean algorithm on m/n.

    Returns the sequence of steps taken.
    """
    steps = []
    if verbose:
        print(f"\nBerggren descent from (m={m}, n={n}):")
        print(f"  {'Step':>6}  {'(m, n)':>12}  {'Action':>10}  {'Ratio m/n':>10}")
        print(f"  {'─'*6}  {'─'*12}  {'─'*10}  {'─'*10}")

    step_count = 0
    while m > 2 or n > 1:
        ratio = m / n if n > 0 else float('inf')
        if m > 2 * n:
            # Apply M₃⁻¹: (m, n) → (m - 2n, n)
            action = "M₃⁻¹"
            m_new, n_new = m - 2*n, n
        elif n > 0:
            # Apply M₁⁻¹: (m, n) → (n, 2n - m)
            action = "M₁⁻¹"
            m_new, n_new = n, 2*n - m
        else:
            break

        if verbose:
            print(f"  {step_count:6d}  ({m:4d},{n:4d})  {action:>10}  {ratio:10.4f}")

        steps.append((m, n, action))
        m, n = m_new, n_new
        step_count += 1

        if step_count > 10000:
            print("  [Exceeded 10000 steps, stopping]")
            break

    if verbose:
        print(f"  {step_count:6d}  ({m:4d},{n:4d})  {'DONE':>10}")
        print(f"  Total steps: {step_count}")

    return steps


def euclidean_algorithm(a, b, verbose=True):
    """Standard Euclidean algorithm for comparison."""
    if verbose:
        print(f"\nEuclidean algorithm on ({a}, {b}):")
    steps = []
    while b > 0:
        q, r = divmod(a, b)
        if verbose:
            print(f"  {a} = {q} × {b} + {r}")
        steps.append((a, b, q, r))
        a, b = b, r
    if verbose:
        print(f"  GCD = {a}")
    return steps


# ============================================================================
# Pythagorean Tree Factoring
# ============================================================================

def pythagorean_tree_factor(N, max_triples=None, verbose=True):
    """Attempt to factor N using Pythagorean tree traversal.

    For each Pythagorean triple (a, b, c) where a or b equals N
    (or more generally, where N divides the leg), check if
    gcd(other_leg, N) reveals a factor.

    Actually: We search for triples where N appears as a leg.
    If N = a (odd), then N² + b² = c² → (c-b)(c+b) = N².
    Each divisor pair of N² gives a triple.
    """
    if max_triples is None:
        max_triples = isqrt(N) + 10

    if verbose:
        print(f"\n{'='*60}")
        print(f"PYTHAGOREAN TREE FACTORING: N = {N}")
        print(f"{'='*60}")

    if N % 2 == 0:
        if verbose:
            print(f"  N is even, trivial factor: 2")
        return 2

    # Method: enumerate triples with leg N by finding divisor pairs of N²
    N_sq = N * N
    factors_found = []
    triples_checked = 0

    for d in range(1, isqrt(N_sq) + 1):
        if N_sq % d != 0:
            continue
        e = N_sq // d
        if d >= e:
            break
        if (d % 2) != (e % 2):
            continue

        # Divisor pair (d, e) with d*e = N², d < e, same parity
        b = (e - d) // 2
        c = (e + d) // 2
        triples_checked += 1

        # Check: gcd(b, N) or gcd(c, N)
        g = gcd(b, N)
        if 1 < g < N:
            if verbose:
                print(f"  Triple #{triples_checked}: ({N}, {b}, {c})")
                print(f"  gcd({b}, {N}) = {g}")
                print(f"  FACTOR FOUND: {N} = {g} × {N // g}")
            return g

        g = gcd(c, N)
        if 1 < g < N:
            if verbose:
                print(f"  Triple #{triples_checked}: ({N}, {b}, {c})")
                print(f"  gcd({c}, {N}) = {g}")
                print(f"  FACTOR FOUND: {N} = {g} × {N // g}")
            return g

        if triples_checked >= max_triples:
            break

    if verbose:
        print(f"  Checked {triples_checked} triples, no factor found")
        if N == int(N**0.5 + 0.5)**2:
            print(f"  (N appears to be a perfect square)")
    return None


# ============================================================================
# Complexity Measurement
# ============================================================================

def measure_complexity(bit_sizes=range(8, 40, 2), trials=5):
    """Measure the number of steps needed to factor balanced semiprimes
    of various sizes. Demonstrates the Θ(√N) complexity."""
    print("\n" + "="*70)
    print("COMPLEXITY MEASUREMENT: Pythagorean Tree Factoring")
    print("="*70)
    print(f"{'Bits':>6} {'N':>16} {'p':>10} {'q':>10} {'Steps':>8} {'√N':>10} {'Ratio':>8}")
    print("-"*70)

    results = []

    for bits in bit_sizes:
        total_steps = 0
        for _ in range(trials):
            # Generate a balanced semiprime
            p = _random_prime(bits // 2)
            q = _random_prime(bits // 2)
            if p > q:
                p, q = q, p
            N = p * q

            # Count divisor enumeration steps
            steps = 0
            N_sq = N * N
            for d in range(1, isqrt(N_sq) + 1):
                if N_sq % d != 0:
                    continue
                e = N_sq // d
                if d >= e:
                    break
                if (d % 2) != (e % 2):
                    continue
                steps += 1
                b = (e - d) // 2
                if gcd(b, N) > 1 and gcd(b, N) < N:
                    break
            total_steps += steps

        avg_steps = total_steps / trials
        sqrt_N = isqrt(N)
        ratio = avg_steps / sqrt_N if sqrt_N > 0 else 0
        results.append((bits, N, p, q, avg_steps, sqrt_N, ratio))
        print(f"{bits:6d} {N:16d} {p:10d} {q:10d} {avg_steps:8.1f} {sqrt_N:10d} {ratio:8.4f}")

    return results


def _random_prime(bits):
    """Find a random-ish prime with approximately `bits` bits."""
    import random
    while True:
        n = random.randint(2**(bits-1), 2**bits - 1)
        if n < 2:
            continue
        if all(n % p != 0 for p in range(2, min(n, 1000))):
            if _is_prime(n):
                return n


def _is_prime(n):
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


# ============================================================================
# Lattice-Tree Correspondence Demo
# ============================================================================

def demonstrate_correspondence():
    """Show that Berggren descent = Euclidean algorithm = Gauss reduction."""
    print("\n" + "="*70)
    print("LATTICE-TREE CORRESPONDENCE DEMONSTRATION")
    print("="*70)

    # Example: (m, n) = (13, 5) → triple (144, 130, 194) → no wait
    # Let's use (m, n) = (7, 4) → triple (33, 56, 65)
    m, n = 7, 4
    a, b, c = euclid_to_triple(m, n)
    print(f"\nExample: Euclid parameters (m, n) = ({m}, {n})")
    print(f"Triple: ({a}, {b}, {c})")
    print(f"Check: {a}² + {b}² = {a*a} + {b*b} = {a*a+b*b} = {c}² = {c*c}")

    print("\n--- Method 1: Berggren Descent ---")
    berggren_steps = berggren_descent(m, n)

    print("\n--- Method 2: Euclidean Algorithm ---")
    euclid_steps = euclidean_algorithm(m, n)

    print("\n--- Correspondence ---")
    print("Both methods compute the continued fraction of m/n:")
    print(f"  {m}/{n} = ", end="")
    # Compute CF
    a_cf, b_cf = m, n
    cf = []
    while b_cf > 0:
        q, r = divmod(a_cf, b_cf)
        cf.append(q)
        a_cf, b_cf = b_cf, r
    print(f"[{'; '.join(map(str, cf))}]")
    print(f"  Berggren uses quotients in pairs of 2 (M₃⁻¹ steps) with swaps (M₁⁻¹)")
    print(f"  Euclidean algorithm uses arbitrary quotients")
    print(f"  Both reach GCD in the same number of fundamental operations")


# ============================================================================
# Gauss Lattice Reduction in 2D
# ============================================================================

def gauss_lattice_reduction(b1, b2, verbose=True):
    """Gauss's algorithm for 2D lattice reduction.
    Given basis vectors b1, b2, find a reduced basis.

    Returns the reduced basis (v1, v2) with |v1| ≤ |v2|.
    """
    if verbose:
        print(f"\nGauss 2D Lattice Reduction:")
        print(f"  Input: b1 = {b1}, b2 = {b2}")

    v1 = np.array(b1, dtype=float)
    v2 = np.array(b2, dtype=float)
    steps = 0

    while True:
        # Ensure |v1| ≤ |v2|
        if np.linalg.norm(v1) > np.linalg.norm(v2):
            v1, v2 = v2, v1

        # Size-reduce v2 by v1
        mu = round(np.dot(v2, v1) / np.dot(v1, v1))
        v2 = v2 - mu * v1

        steps += 1
        if verbose:
            print(f"  Step {steps}: v1 = [{v1[0]:.0f}, {v1[1]:.0f}], "
                  f"v2 = [{v2[0]:.0f}, {v2[1]:.0f}], "
                  f"|v1| = {np.linalg.norm(v1):.2f}, |v2| = {np.linalg.norm(v2):.2f}")

        if np.linalg.norm(v2) >= np.linalg.norm(v1):
            break

    if verbose:
        print(f"  Reduced basis: v1 = {v1}, v2 = {v2}")
        print(f"  Steps: {steps}")

    return v1, v2, steps


# ============================================================================
# SCG (Scientific Computation Graph) Visualization Data
# ============================================================================

def generate_scg_data(max_depth=4):
    """Generate data for SCG visualization of the Berggren tree.
    Outputs JSON suitable for D3.js or similar visualization."""

    def build_node(triple, depth, parent_id=None):
        a, b, c = int(triple[0]), int(triple[1]), int(triple[2])
        node_id = f"{a}_{b}_{c}"
        return {
            "id": node_id,
            "triple": [a, b, c],
            "depth": depth,
            "parent": parent_id,
            "hypotenuse": c,
            "area": a * b // 2,
            "is_primitive": gcd(gcd(a, b), c) == 1,
            "children": []
        }

    root_triple = np.array([3, 4, 5])
    root = build_node(root_triple, 0)
    queue = deque([(root, root_triple, 0)])

    while queue:
        node, triple, depth = queue.popleft()
        if depth >= max_depth:
            continue

        for i, B in enumerate([B1, B2, B3]):
            child_triple = np.abs(B @ triple)
            child = build_node(child_triple, depth + 1, node["id"])
            node["children"].append(child)
            queue.append((child, child_triple, depth + 1))

    return root


def save_scg_json(filename="berggren_tree.json", max_depth=4):
    """Save SCG visualization data to JSON."""
    data = generate_scg_data(max_depth)
    with open(filename, 'w') as f:
        json.dump(data, f, indent=2)
    print(f"SCG data saved to {filename}")
    return data


# ============================================================================
# Main Demo
# ============================================================================

if __name__ == "__main__":
    import random
    random.seed(42)

    # 1. Show the Berggren tree
    tree = generate_berggren_tree(max_depth=3)
    print_tree(tree, max_depth=3)

    # 2. Demonstrate the lattice-tree correspondence
    demonstrate_correspondence()

    # 3. Factor some numbers
    for N in [15, 21, 77, 143, 221, 323, 1007, 10403]:
        pythagorean_tree_factor(N)

    # 4. Gauss lattice reduction example
    gauss_lattice_reduction([7, 4], [3, 2])

    # 5. Complexity measurement
    try:
        measure_complexity(bit_sizes=range(10, 30, 2), trials=3)
    except Exception as e:
        print(f"  (Complexity measurement skipped: {e})")

    # 6. Generate SCG data
    save_scg_json("berggren_tree.json", max_depth=4)

    print("\n" + "="*60)
    print("DEMO COMPLETE")
    print("="*60)
