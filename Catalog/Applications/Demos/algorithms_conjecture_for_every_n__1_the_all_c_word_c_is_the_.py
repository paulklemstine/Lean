#!/usr/bin/env python3
"""
Algorithms for Berggren Semigroup Dynamics

Implements key algorithms from the research paper:
1. Optimal word computation using the ray optimality principle
2. Depth-shell enumeration and extremal classification
3. Modular orbit computation for finite-field dynamics
"""

from typing import List, Tuple, Dict, Optional
from collections import deque


# === Matrix Utilities ===

def matmul_3x3(M: List[List[int]], v: List[int]) -> List[int]:
    """Multiply a 3x3 integer matrix by a 3-vector.

    Time: O(1) (fixed dimension)
    Space: O(1)
    """
    return [sum(M[i][j] * v[j] for j in range(3)) for i in range(3)]


def matmul_mod(M: List[List[int]], v: List[int], p: int) -> List[int]:
    """Multiply a 3x3 matrix by a 3-vector modulo p.

    Time: O(1) (fixed dimension)
    Space: O(1)
    """
    return [sum(M[i][j] * v[j] for j in range(3)) % p for i in range(3)]


# === Berggren Generators ===

BERG_A = [[1, -2, 2], [2, -1, 2], [2, -2, 3]]
BERG_B = [[1, 2, 2], [2, 1, 2], [2, 2, 3]]
BERG_C = [[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]]
GENERATORS = [BERG_A, BERG_B, BERG_C]
GEN_NAMES = ['A', 'B', 'C']
ROOT = [3, 4, 5]


# === Algorithm 1: Closed-Form Hypotenuse Computation ===

def hyp_a_ray(n: int) -> int:
    """Compute hypotenuse of A^n(3,4,5) in O(1) time.

    Uses the proven closed form: c(A^n) = 2n² + 6n + 5.

    Args:
        n: Depth (number of A generators)

    Returns:
        Hypotenuse value

    Examples:
        >>> hyp_a_ray(0)
        5
        >>> hyp_a_ray(1)
        13
        >>> hyp_a_ray(5)
        85
    """
    return 2 * n**2 + 6 * n + 5


def hyp_c_ray(n: int) -> int:
    """Compute hypotenuse of C^n(3,4,5) in O(1) time.

    Uses the proven closed form: c(C^n) = 4n² + 8n + 5.

    Args:
        n: Depth (number of C generators)

    Returns:
        Hypotenuse value

    Examples:
        >>> hyp_c_ray(0)
        5
        >>> hyp_c_ray(1)
        17
        >>> hyp_c_ray(5)
        145
    """
    return 4 * n**2 + 8 * n + 5


def hyp_pure_ray_from(m: int, a: int, b: int, c: int,
                       ray: str = 'A') -> int:
    """Compute hypotenuse of A^m or C^m from arbitrary triple (a,b,c).

    Uses the generalized unipotent formulas:
        hyp(A^m from v) = 2m·a - 2m²·b + (2m²+1)·c
        hyp(C^m from v) = -2m²·a + 2m·b + (2m²+1)·c

    Time: O(1)

    Args:
        m: Number of generator applications
        a, b, c: Starting triple
        ray: 'A' or 'C'

    Returns:
        Hypotenuse value
    """
    if ray == 'A':
        return 2 * m * a - 2 * m**2 * b + (2 * m**2 + 1) * c
    else:
        return -2 * m**2 * a + 2 * m * b + (2 * m**2 + 1) * c


# === Algorithm 2: Optimal Word Prediction ===

def predict_optimal_suffix(a: int, b: int, c: int, m: int) -> str:
    """Predict the optimal (hyp-minimizing) word of length m from triple (a,b,c).

    Based on the Ray Optimality Theorem:
    - If a ≥ b: optimal is C^m
    - If b ≥ a: optimal is A^m

    This is exact for positive Pythagorean triples (proven theorem).

    Time: O(1) for prediction, O(m) for word construction
    Space: O(m) for the word string

    Args:
        a, b, c: Starting Pythagorean triple (positive)
        m: Word length

    Returns:
        Optimal word string
    """
    if a >= b:
        return 'C' * m
    else:
        return 'A' * m


def optimal_hyp_from(a: int, b: int, c: int, m: int) -> int:
    """Compute the minimum hypotenuse achievable in m steps from (a,b,c).

    Uses the Ray Optimality Theorem for O(1) computation.

    Args:
        a, b, c: Starting Pythagorean triple
        m: Number of steps

    Returns:
        Minimum achievable hypotenuse
    """
    if a >= b:
        return hyp_pure_ray_from(m, a, b, c, 'C')
    else:
        return hyp_pure_ray_from(m, a, b, c, 'A')


# === Algorithm 3: Depth-Shell Extremal Ranking ===

def depth_shell_ranking(n: int, top_k: int = 10) -> List[Tuple[int, str]]:
    """Enumerate all 3^n words at depth n and rank by hypotenuse.

    Time: O(3^n) — exponential, use only for small n
    Space: O(3^n)

    Args:
        n: Depth
        top_k: Number of top results to return

    Returns:
        List of (hypotenuse, word_string) pairs, sorted ascending
    """
    from itertools import product as cart_product
    results = []
    for word in cart_product(range(3), repeat=n):
        v = list(ROOT)
        for g in word:
            v = matmul_3x3(GENERATORS[g], v)
        name = ''.join(GEN_NAMES[g] for g in word)
        results.append((v[2], name))
    results.sort()
    return results[:top_k]


# === Algorithm 4: Modular Berggren Orbit ===

def berggren_orbit_mod_p(p: int) -> Dict[Tuple[int, int, int], int]:
    """Compute the Berggren orbit of (3,4,5) mod p using BFS.

    Returns the orbit as a dict mapping triples to their BFS distance.

    Time: O(|orbit| * 3) — linear in orbit size
    Space: O(|orbit|)

    Args:
        p: Modulus (should be prime ≥ 7 for meaningful results)

    Returns:
        Dictionary mapping orbit points to their BFS distance from root
    """
    root = tuple(x % p for x in ROOT)
    visited = {root: 0}
    queue = deque([root])

    while queue:
        v = queue.popleft()
        dist = visited[v]
        for M in GENERATORS:
            w = tuple(matmul_mod(M, list(v), p))
            if w not in visited:
                visited[w] = dist + 1
                queue.append(w)

    return visited


def check_strong_connectivity(p: int) -> Tuple[bool, int, int]:
    """Check if the Berggren orbit mod p is strongly connected.

    Tests both forward and backward reachability.

    Args:
        p: Prime modulus

    Returns:
        (is_connected, orbit_size, diameter_estimate)
    """
    forward = berggren_orbit_mod_p(p)
    orbit_size = len(forward)

    # Check backward reachability: from each point, can we reach base?
    # Build reverse graph
    orbit_points = set(forward.keys())
    reverse_visited = set()
    queue = deque([tuple(x % p for x in ROOT)])
    reverse_visited.add(tuple(x % p for x in ROOT))

    # BFS on reverse edges
    while queue:
        v = queue.popleft()
        for point in orbit_points:
            if point in reverse_visited:
                continue
            for M in GENERATORS:
                if tuple(matmul_mod(M, list(point), p)) == v:
                    reverse_visited.add(point)
                    queue.append(point)
                    break

    is_connected = len(reverse_visited) == orbit_size
    diameter = max(forward.values()) if forward else 0

    return is_connected, orbit_size, diameter


# === Algorithm 5: Extremal Word Classification ===

def classify_extremal_words(n: int) -> Dict[str, dict]:
    """Classify the extremal (lowest hypotenuse) words at depth n.

    Returns closed-form values for the known extremal families:
    1st: A^n with c = 2n²+6n+5
    2nd: C^n with c = 4n²+8n+5
    3rd: A^(n-1)C with c = 10n²+6n+1 (for n ≥ 2)

    Args:
        n: Depth

    Returns:
        Dictionary with extremal word information
    """
    result = {
        'first': {
            'word': 'A' * n,
            'hyp_formula': '2n²+6n+5',
            'hyp_value': 2 * n**2 + 6 * n + 5,
        },
        'second': {
            'word': 'C' * n,
            'hyp_formula': '4n²+8n+5',
            'hyp_value': 4 * n**2 + 8 * n + 5,
        },
    }
    if n >= 2:
        result['third'] = {
            'word': 'A' * (n - 1) + 'C',
            'hyp_formula': '10n²+6n+1',
            'hyp_value': 10 * n**2 + 6 * n + 1,
        }
    return result


# === Main Demo ===

if __name__ == '__main__':
    print("=== Algorithm Demonstrations ===\n")

    # Closed forms
    print("1. Closed-form computations (O(1) time):")
    for n in [10, 100, 1000]:
        print(f"   n={n:4d}: hyp(A^n)={hyp_a_ray(n):>12,}, hyp(C^n)={hyp_c_ray(n):>12,}")
    print()

    # Optimal word prediction
    print("2. Optimal word prediction:")
    triples = [(15, 8, 17), (5, 12, 13), (99, 20, 101)]
    for a, b, c in triples:
        word = predict_optimal_suffix(a, b, c, 5)
        h = optimal_hyp_from(a, b, c, 5)
        print(f"   From ({a},{b},{c}): optimal 5-word = {word}, min hyp = {h}")
    print()

    # Depth-shell ranking
    print("3. Depth-shell ranking (depth 6):")
    ranking = depth_shell_ranking(6, top_k=5)
    for rank, (h, word) in enumerate(ranking, 1):
        print(f"   {rank}. {word} → c = {h}")
    print()

    # Modular orbits
    print("4. Modular Berggren orbits:")
    for p in [7, 11, 13, 17, 19, 23, 29, 31]:
        connected, size, diam = check_strong_connectivity(p)
        status = "CONNECTED" if connected else "NOT connected"
        print(f"   p={p:2d}: orbit size={size:4d}, diameter≤{diam:2d}, {status}")
    print()

    # Extremal classification
    print("5. Extremal word classification:")
    for n in [5, 10, 20]:
        info = classify_extremal_words(n)
        print(f"   n={n}: 1st={info['first']['word'][:8]}... (c={info['first']['hyp_value']}), "
              f"2nd={info['second']['word'][:8]}... (c={info['second']['hyp_value']}), "
              f"3rd={info['third']['word'][:8]}... (c={info['third']['hyp_value']})")
