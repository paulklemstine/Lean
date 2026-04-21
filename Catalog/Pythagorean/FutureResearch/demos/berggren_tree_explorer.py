#!/usr/bin/env python3
"""
Berggren Tree Explorer
======================
Interactive exploration of the Berggren ternary tree of primitive
Pythagorean triples (PPTs) and their connections to factoring.

Features:
- Generate the Berggren tree to arbitrary depth
- Find the ancestry path of any PPT
- Compute ghost ancestors and verify closed-form formulas
- Explore multi-path ancestry for factoring
- Baby-Step Giant-Step (BSGS) Pell factoring
"""

import math
from typing import List, Tuple, Optional
import json

# ============================================================
# Berggren Matrices
# ============================================================

def mat_mul(A, v):
    """Multiply 3x3 matrix A by 3-vector v."""
    return tuple(sum(A[i][j] * v[j] for j in range(3)) for i in range(3))

# Berggren matrices
B1 = ((1, -2, 2), (2, -1, 2), (2, -2, 3))   # Branch A
B2 = ((1, 2, 2), (2, 1, 2), (2, 2, 3))      # Branch B
B3 = ((-1, 2, 2), (-2, 1, 2), (-2, 2, 3))   # Branch C

# Inverse of B₂ (ghost matrix)
M = ((1, 2, -2), (2, 1, -2), (-2, -2, 3))

BRANCHES = {'A': B1, 'B': B2, 'C': B3}

def generate_tree(depth: int, root=(3, 4, 5)) -> dict:
    """Generate the Berggren tree to given depth."""
    if depth == 0:
        return {'triple': root, 'children': {}}

    children = {}
    for name, matrix in BRANCHES.items():
        child = mat_mul(matrix, root)
        children[name] = generate_tree(depth - 1, child)

    return {'triple': root, 'children': children}


def print_tree(tree: dict, indent: int = 0, max_depth: int = 4):
    """Pretty-print the tree."""
    prefix = "  " * indent
    a, b, c = tree['triple']
    print(f"{prefix}({a}, {b}, {c})  [a²+b²={a**2+b**2}, c²={c**2}]")
    if indent < max_depth:
        for name, child in tree['children'].items():
            print(f"{prefix}  ├─ {name}:")
            print_tree(child, indent + 2, max_depth)


def find_parent(a: int, b: int, c: int) -> Tuple[str, Tuple[int, int, int]]:
    """Find the parent of a PPT in the Berggren tree.
    Returns (branch_name, parent_triple).

    The inverse matrices are:
    B₁⁻¹ = [[1, 2, -2], [-2, -1, 2], [2, 2, -3]] (det=-1, negate)
    Actually, since det(Bi)=-1, B₁⁻¹ = -adj(B₁).
    But we can just check which inverse gives positive legs.
    """
    # The three inverse matrices (for det = -1)
    B1_inv = ((1, -2, 2), (2, -1, 2), (2, -2, 3))  # Same as original due to special structure
    # Actually the inverses are different. Let me compute properly.
    # For det=-1: B⁻¹ = -(1/det) * adj(B) = adj(B)
    # B₁⁻¹:
    B1_inv = ((1, 2, -2), (-2, -1, 2), (2, 2, -3))
    B2_inv = M  # Already defined
    B3_inv = ((-1, 2, -2), (-2, 1, -2), (-2, 2, -3))

    # Actually let me just use the known inverse formulas
    # For B₁: parent = B₁⁻¹ · child
    for name, inv in [('A', B1_inv), ('B', B2_inv), ('C', B3_inv)]:
        pa, pb, pc = mat_mul(inv, (a, b, c))
        if pa > 0 and pb > 0 and pc > 0 and pa*pa + pb*pb == pc*pc:
            return (name, (pa, pb, pc))
        # Try swapping a,b
        pa, pb, pc = mat_mul(inv, (b, a, c))
        if pa > 0 and pb > 0 and pc > 0 and pa*pa + pb*pb == pc*pc:
            return (name, (pa, pb, pc))

    return ('root', (3, 4, 5))


def ancestry_path(a: int, b: int, c: int, max_depth: int = 100) -> List[Tuple[str, Tuple[int, int, int]]]:
    """Find the path from a PPT back to (3,4,5)."""
    path = []
    current = (a, b, c)
    for _ in range(max_depth):
        if current == (3, 4, 5) or current == (4, 3, 5):
            break
        branch, parent = find_parent(*current)
        path.append((branch, current))
        current = parent
    path.append(('root', (3, 4, 5)))
    return path


# ============================================================
# Pell Sequence Functions
# ============================================================

def pell_H(n: int) -> int:
    if n == 0: return 1
    h0, h1 = 1, 1
    for _ in range(n - 1):
        h0, h1 = h1, 2 * h1 + h0
    return h1

def pell_P(n: int) -> int:
    if n == 0: return 0
    p0, p1 = 0, 1
    for _ in range(n - 1):
        p0, p1 = p1, 2 * p1 + p0
    return p1


def ghost_ancestor_closed(a, b, c, n):
    """Compute n-th ghost ancestor using Pell closed form."""
    H = pell_H(n)
    P = pell_P(n)
    eps = (-1) ** n
    p = H**2 * a + 2 * P**2 * b - 2 * P * H * c
    q = 2 * P**2 * a + H**2 * b - 2 * P * H * c
    h = -2 * P * H * a - 2 * P * H * b + (4 * P**2 + eps) * c
    return (p, q, h)


def ghost_ancestor_iterative(a, b, c, n):
    """Compute n-th ghost ancestor by applying M n times."""
    current = (a, b, c)
    for _ in range(n):
        current = mat_mul(M, current)
    return current


# ============================================================
# BSGS Pell Factoring
# ============================================================

def pell_mod(n: int, m: int) -> Tuple[int, int]:
    """Compute (H_n mod m, P_n mod m)."""
    if n == 0: return (1 % m, 0)
    h0, h1 = 1, 1
    p0, p1 = 0, 1
    for _ in range(n - 1):
        h0, h1 = h1 % m, (2 * h1 + h0) % m
        p0, p1 = p1 % m, (2 * p1 + p0) % m
    return (h1 % m, p1 % m)


def factor_bsgs(N: int, B: int = 10000) -> Optional[int]:
    """Baby-Step Giant-Step factoring using Pell sequences.

    1. Baby steps: compute P_j mod N for j=0..m-1, store in a set
    2. Giant steps: compute P_{km} mod N for k=1,2,...
    3. Use addition formulas: (H_{a+b}, P_{a+b}) from (H_a,P_a) and (H_b,P_b)
    4. Accumulate products and check GCD periodically
    """
    m = int(math.isqrt(B)) + 1

    # Baby steps
    baby_products = 1
    h0, h1 = 1, 1
    p0, p1 = 0, 1

    for j in range(1, m):
        baby_products = (baby_products * p1) % N
        if baby_products == 0:
            g = math.gcd(p1, N)
            if 1 < g < N:
                return g
            baby_products = 1

        h0, h1 = h1 % N, (2 * h1 + h0) % N
        p0, p1 = p1 % N, (2 * p1 + p0) % N

    g = math.gcd(baby_products, N)
    if 1 < g < N:
        return g

    # Giant step base
    Hm, Pm = pell_mod(m, N)

    # Giant steps
    Hg, Pg = Hm, Pm
    product = 1

    for k in range(1, B // m + 2):
        product = (product * Pg) % N

        if k % 20 == 0:
            g = math.gcd(product, N)
            if 1 < g < N:
                return g
            if g == N:
                # Overshoot: need to refine
                pass
            product = 1

        # Advance: (H_{(k+1)m}, P_{(k+1)m}) via addition formula
        Hg_new = (Hg * Hm + 2 * Pg * Pm) % N
        Pg_new = (Pg * Hm + Hg * Pm) % N
        Hg, Pg = Hg_new, Pg_new

    g = math.gcd(product, N)
    if 1 < g < N:
        return g

    return None


# ============================================================
# Multi-Path Exploration
# ============================================================

def multi_path_ghost(a, b, c, path_word: str):
    """Apply a sequence of inverse Berggren matrices.
    path_word is a string like 'BBABC' meaning apply B₂⁻¹, B₂⁻¹, B₁⁻¹, B₂⁻¹, B₃⁻¹.
    """
    B1_inv = ((1, 2, -2), (-2, -1, 2), (2, 2, -3))
    B2_inv = M
    B3_inv = ((-1, 2, -2), (-2, 1, -2), (-2, 2, -3))

    inv_map = {'A': B1_inv, 'B': B2_inv, 'C': B3_inv}

    current = (a, b, c)
    for ch in path_word:
        current = mat_mul(inv_map[ch], current)
    return current


# ============================================================
# Demonstrations
# ============================================================

def demo_tree():
    """Show the Berggren tree."""
    print("=" * 60)
    print("DEMO 1: Berggren Tree (depth 2)")
    print("=" * 60)
    tree = generate_tree(2)
    print_tree(tree, max_depth=3)
    print()


def demo_ghost_closed_form():
    """Verify closed form matches iterative computation."""
    print("=" * 60)
    print("DEMO 2: Ghost Ancestor Closed Form Verification")
    print("=" * 60)
    a, b, c = 3, 4, 5
    all_ok = True
    for n in range(12):
        closed = ghost_ancestor_closed(a, b, c, n)
        iterative = ghost_ancestor_iterative(a, b, c, n)
        ok = closed == iterative
        if not ok:
            all_ok = False
        if n < 8:
            print(f"  n={n:2d}: closed={closed}  iter={iterative}  {'✓' if ok else '✗'}")
    print(f"  ... all n=0..11: {'✓ All match' if all_ok else '✗ Mismatch found'}")
    print()


def demo_multi_path():
    """Explore different branch sequences for factoring potential."""
    print("=" * 60)
    print("DEMO 3: Multi-Path Ghost Ancestry")
    print("=" * 60)
    a, b, c = 5, 12, 13
    print(f"  Starting triple: ({a}, {b}, {c})")
    paths = ['B', 'A', 'C', 'BB', 'BA', 'BC', 'AB', 'BBB', 'BAB']
    for path in paths:
        result = multi_path_ghost(a, b, c, path)
        p, q, h = result
        pyth = p**2 + q**2 == h**2
        deficit = p**2 + q**2 - h**2
        print(f"  Path {path:4s}: ({p:6d}, {q:6d}, {h:6d})  "
              f"deficit={deficit:4d}  "
              f"{'PPT' if pyth else 'quasi'}")
    print()


def demo_bsgs_factoring():
    """Demonstrate BSGS factoring."""
    print("=" * 60)
    print("DEMO 4: Baby-Step Giant-Step Pell Factoring")
    print("=" * 60)
    test_cases = [
        (15, "3×5"),
        (77, "7×11"),
        (221, "13×17"),
        (1189, "29×41"),
        (10403, "101×103"),
        (25117, "prime" if all(25117 % i != 0 for i in range(2, 159)) else "composite"),
        (100127, ""),
        (1000003, ""),
    ]
    for N, desc in test_cases:
        factor = factor_bsgs(N, B=5000)
        if factor:
            print(f"  N={N:>8d} ({desc:>10s}): "
                  f"factor={factor}, other={N//factor}")
        else:
            if all(N % i != 0 for i in range(2, int(math.isqrt(N)) + 1)):
                print(f"  N={N:>8d} ({'prime':>10s}): no factor (prime!)")
            else:
                print(f"  N={N:>8d} ({desc:>10s}): no factor found in B=5000")
    print()


def demo_pell_rank_distribution():
    """Analyze the distribution of Pell ranks for small primes."""
    print("=" * 60)
    print("DEMO 5: Pell Rank Distribution")
    print("=" * 60)

    def pell_rank(p):
        h0, h1 = 1, 1
        p0, p1 = 0, 1
        for T in range(1, 2 * p + 2):
            if p1 % p == 0:
                return T
            h0, h1 = h1, (2 * h1 + h0) % p
            p0, p1 = p1, (2 * p1 + p0) % p
        return -1

    # Compute ranks for primes up to 100
    primes = [p for p in range(3, 200) if all(p % i != 0 for i in range(2, int(math.sqrt(p)) + 1))]

    smooth_count = 0
    total = 0
    rank_data = []

    for p in primes:
        T = pell_rank(p)
        p_mod_8 = p % 8
        leg = 1 if p_mod_8 in [1, 7] else -1
        target = p - leg
        is_smooth = all(T % q != 0 for q in primes if q > 20 and q <= T)

        rank_data.append((p, T, target, target // T))
        total += 1
        if T <= 20:
            smooth_count += 1

    print(f"  Primes analyzed: {total}")
    print(f"  Primes with rank ≤ 20: {smooth_count} ({100*smooth_count/total:.1f}%)")
    print()

    # Show distribution of rank/target ratios
    print("  Rank statistics:")
    ranks = [r[1] for r in rank_data]
    print(f"    Min rank: {min(ranks)}")
    print(f"    Max rank: {max(ranks)}")
    print(f"    Mean rank: {sum(ranks)/len(ranks):.1f}")
    print(f"    Median rank: {sorted(ranks)[len(ranks)//2]}")
    print()

    # Show rank factorizations for first 20 primes
    print("  First 20 primes:")
    for p, T, target, ratio in rank_data[:20]:
        def factorize(n):
            factors = []
            d = 2
            while d * d <= n:
                while n % d == 0:
                    factors.append(d)
                    n //= d
                d += 1
            if n > 1:
                factors.append(n)
            return factors

        T_factors = factorize(T)
        print(f"    p={p:3d}: T(p)={T:3d} = {'·'.join(map(str, T_factors)):>15s}  "
              f"p-(2/p)={target:3d}  ratio={ratio}")
    print()


def demo_tropical_analog():
    """Explore the tropical Berggren tree."""
    print("=" * 60)
    print("DEMO 6: Tropical Pythagorean Triples")
    print("=" * 60)
    print("  In the tropical semiring (R∪{∞}, min, +):")
    print("  The Pythagorean equation a²+b²=c² becomes min(2a,2b)=2c")
    print("  i.e., min(a,b)=c")
    print()

    # Generate tropical "triples"
    print("  Tropical triples (a,b,c) with min(a,b)=c and a≤b:")
    for a in range(1, 6):
        for b in range(a, 8):
            c = min(a, b)
            print(f"    ({a}, {b}, {c})")
    print()
    print("  Key insight: In the tropical world, EVERY pair (a,b) with a≤b")
    print("  gives a 'triple' (a,b,a). The tree structure collapses!")
    print()


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  BERGGREN TREE EXPLORER")
    print("=" * 60 + "\n")

    demo_tree()
    demo_ghost_closed_form()
    demo_multi_path()
    demo_bsgs_factoring()
    demo_pell_rank_distribution()
    demo_tropical_analog()

    print("=" * 60)
    print("  Explorer complete!")
    print("=" * 60)
