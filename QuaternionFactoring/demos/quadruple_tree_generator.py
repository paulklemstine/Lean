#!/usr/bin/env python3
"""
Pythagorean Quadruple Tree Generator
=====================================

Generates the infinite tree of Pythagorean quadruples using the SL(2,ℤ)
action on the parameter space (m, n, p, q).

The parametric formula:
    a = m² + n² - p² - q²
    b = 2(mq + np)
    c = 2(nq - mp)
    d = m² + n² + p² + q²

SL(2,ℤ) generators act on (m,n) while fixing (p,q):
    S: (m,n) ↦ (n, -m)  [rotation by 90°]
    T: (m,n) ↦ (m+n, n)  [shear]

This generates all primitive quadruples via tree traversal.

Usage:
    python quadruple_tree_generator.py
"""

import math
from collections import deque
from typing import List, Tuple, Set, Dict


def params_to_quadruple(m: int, n: int, p: int, q: int) -> Tuple[int, int, int, int]:
    """Convert parameters to a Pythagorean quadruple."""
    a = m*m + n*n - p*p - q*q
    b = 2*(m*q + n*p)
    c = 2*(n*q - m*p)
    d = m*m + n*n + p*p + q*q
    return (a, b, c, d)


def apply_S(m: int, n: int) -> Tuple[int, int]:
    """SL(2,ℤ) generator S: rotation."""
    return (n, -m)


def apply_T(m: int, n: int) -> Tuple[int, int]:
    """SL(2,ℤ) generator T: shear."""
    return (m + n, n)


def apply_T_inv(m: int, n: int) -> Tuple[int, int]:
    """SL(2,ℤ) generator T⁻¹."""
    return (m - n, n)


def generate_quadruple_tree(max_d: int = 100, max_nodes: int = 500) -> Dict:
    """Generate the tree of Pythagorean quadruples via BFS on parameter space."""
    tree = {
        'nodes': [],
        'edges': [],
        'params': []
    }

    visited = set()
    queue = deque()

    # Seed parameters
    seeds = [(1, 1, 0, 1), (2, 1, 0, 1), (1, 2, 1, 0), (1, 1, 1, 0),
             (2, 1, 1, 0), (1, 2, 0, 1), (2, 1, 1, 1), (3, 1, 0, 1)]

    for seed in seeds:
        queue.append((seed, None))

    while queue and len(tree['nodes']) < max_nodes:
        params, parent_idx = queue.popleft()
        m, n, p, q = params

        quad = params_to_quadruple(m, n, p, q)
        a, b, c, d = quad

        if d > max_d or d <= 0:
            continue

        # Normalize for dedup
        key = tuple(sorted([abs(a), abs(b), abs(c)])) + (abs(d),)
        if key in visited:
            continue
        visited.add(key)

        if a*a + b*b + c*c != d*d:
            continue

        node_idx = len(tree['nodes'])
        tree['nodes'].append({
            'quad': quad,
            'params': params,
            'd': d,
            'primitive': math.gcd(math.gcd(abs(a), abs(b)), math.gcd(abs(c), abs(d))) == 1
        })
        tree['params'].append(params)

        if parent_idx is not None:
            tree['edges'].append((parent_idx, node_idx))

        # Generate children via SL(2,ℤ) action
        children_mn = [
            apply_S(m, n),
            apply_T(m, n),
            apply_T_inv(m, n),
        ]

        for m2, n2 in children_mn:
            child_params = (m2, n2, p, q)
            queue.append((child_params, node_idx))

        # Also vary (p, q)
        children_pq = [
            apply_S(p, q),
            apply_T(p, q),
        ]
        for p2, q2 in children_pq:
            child_params = (m, n, p2, q2)
            queue.append((child_params, node_idx))

    return tree


def print_tree_stats(tree: Dict):
    """Print statistics about the generated tree."""
    nodes = tree['nodes']
    edges = tree['edges']

    print(f"\nTree Statistics:")
    print(f"  Total nodes: {len(nodes)}")
    print(f"  Total edges: {len(edges)}")

    primitives = [n for n in nodes if n['primitive']]
    print(f"  Primitive quadruples: {len(primitives)}")

    d_values = [n['d'] for n in nodes]
    print(f"  d range: [{min(d_values)}, {max(d_values)}]")

    print(f"\n  First 20 quadruples (sorted by d):")
    sorted_nodes = sorted(nodes, key=lambda x: (x['d'], x['quad']))
    for i, node in enumerate(sorted_nodes[:20]):
        a, b, c, d = node['quad']
        prim = "P" if node['primitive'] else " "
        m, n, p, q = node['params']
        print(f"    [{prim}] ({a:3d}, {b:3d}, {c:3d}, {d:3d})  "
              f"check: {a*a+b*b+c*c} = {d*d}  "
              f"params: ({m},{n},{p},{q})")


def brute_force_quadruples(max_d: int = 50) -> List[Tuple[int, int, int, int]]:
    """Generate all Pythagorean quadruples with d ≤ max_d by brute force."""
    quads = []
    for d in range(1, max_d + 1):
        for a in range(0, d):
            for b in range(a, d):
                c_sq = d*d - a*a - b*b
                if c_sq < b*b:
                    continue
                c = int(math.isqrt(c_sq))
                if c*c == c_sq:
                    quads.append((a, b, c, d))
    return quads


def coverage_analysis(max_d: int = 30):
    """Compare parametric tree coverage against brute force enumeration."""
    print("\n" + "="*60)
    print("Coverage Analysis: Parametric vs Brute Force")
    print("="*60)

    bf = brute_force_quadruples(max_d)
    bf_set = set()
    for q in bf:
        bf_set.add(tuple(sorted(q[:3])) + (q[3],))

    tree = generate_quadruple_tree(max_d=max_d, max_nodes=2000)
    tree_set = set()
    for node in tree['nodes']:
        a, b, c, d = node['quad']
        tree_set.add(tuple(sorted([abs(a), abs(b), abs(c)])) + (abs(d),))

    covered = bf_set & tree_set
    missed = bf_set - tree_set

    print(f"  Brute force (d ≤ {max_d}): {len(bf_set)} quadruples")
    print(f"  Parametric tree: {len(tree_set)} quadruples")
    print(f"  Covered: {len(covered)}")
    print(f"  Missed: {len(missed)}")

    if missed:
        print(f"\n  First 10 missed quadruples:")
        for q in sorted(missed)[:10]:
            print(f"    {q}")

    coverage = len(covered) / len(bf_set) * 100 if bf_set else 0
    print(f"\n  Coverage rate: {coverage:.1f}%")


def quaternion_product_decomposition():
    """Demonstrate quaternion product decomposition for composites."""
    print("\n" + "="*60)
    print("Quaternion Product Decomposition")
    print("="*60)

    composites = [
        (15, [(3, 5)]),
        (35, [(5, 7)]),
        (77, [(7, 11)]),
        (91, [(7, 13)]),
        (143, [(11, 13)]),
    ]

    def four_squares(n):
        for a in range(int(math.isqrt(n)) + 1):
            for b in range(int(math.isqrt(n - a*a)) + 1):
                for c in range(int(math.isqrt(n - a*a - b*b)) + 1):
                    d_sq = n - a*a - b*b - c*c
                    if d_sq >= 0:
                        d = int(math.isqrt(d_sq))
                        if d*d == d_sq:
                            return (a, b, c, d)
        return None

    for N, factors_list in composites:
        print(f"\n  N = {N}:")
        decomp_N = four_squares(N)
        if decomp_N:
            a, b, c, d = decomp_N
            print(f"    As sum of 4 squares: {N} = {a}² + {b}² + {c}² + {d}²")

        for p, q in factors_list:
            dp = four_squares(p)
            dq = four_squares(q)
            if dp and dq:
                print(f"    Factorization {p} × {q}:")
                print(f"      q_p = ({dp[0]}, {dp[1]}, {dp[2]}, {dp[3]})  norm = {sum(x*x for x in dp)}")
                print(f"      q_q = ({dq[0]}, {dq[1]}, {dq[2]}, {dq[3]})  norm = {sum(x*x for x in dq)}")

                # Quaternion product
                a1, b1, c1, d1 = dp
                a2, b2, c2, d2 = dq
                prod = (
                    a1*a2 - b1*b2 - c1*c2 - d1*d2,
                    a1*b2 + b1*a2 + c1*d2 - d1*c2,
                    a1*c2 - b1*d2 + c1*a2 + d1*b2,
                    a1*d2 + b1*c2 - c1*b2 + d1*a2,
                )
                norm_prod = sum(x*x for x in prod)
                print(f"      q_p · q_q = ({prod[0]}, {prod[1]}, {prod[2]}, {prod[3]})  norm = {norm_prod}")
                assert norm_prod == N, f"Norm mismatch: {norm_prod} ≠ {N}"


if __name__ == "__main__":
    print("╔" + "═"*58 + "╗")
    print("║" + "PYTHAGOREAN QUADRUPLE TREE GENERATOR".center(58) + "║")
    print("╚" + "═"*58 + "╝")

    tree = generate_quadruple_tree(max_d=100, max_nodes=300)
    print_tree_stats(tree)

    coverage_analysis(max_d=30)
    quaternion_product_decomposition()
