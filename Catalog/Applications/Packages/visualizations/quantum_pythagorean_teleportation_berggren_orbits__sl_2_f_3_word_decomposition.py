#!/usr/bin/env python3
"""
Algorithms for the Berggren Symplectic Bridge

Implements:
1. Berggren tree generation
2. Euclidean parameter extraction
3. SL(2, F_3) word decomposition
4. Shortest symplectic transport computation
"""

from itertools import product
from collections import deque
from typing import Tuple, List, Optional, Dict


def mat_mul_mod(A: List[List[int]], B: List[List[int]], p: int) -> List[List[int]]:
    """Multiply two 2x2 matrices modulo p.

    Time: O(1)  Space: O(1)

    Args:
        A: 2x2 matrix as list of lists
        B: 2x2 matrix as list of lists
        p: prime modulus

    Returns:
        Product A*B mod p as 2x2 list of lists
    """
    return [
        [(A[0][0]*B[0][0] + A[0][1]*B[1][0]) % p,
         (A[0][0]*B[0][1] + A[0][1]*B[1][1]) % p],
        [(A[1][0]*B[0][0] + A[1][1]*B[1][0]) % p,
         (A[1][0]*B[0][1] + A[1][1]*B[1][1]) % p]
    ]


def mat_vec_mod(M: List[List[int]], v: Tuple[int, int], p: int) -> Tuple[int, int]:
    """Multiply 2x2 matrix by 2-vector modulo p.

    Args:
        M: 2x2 matrix
        v: 2-vector
        p: prime modulus

    Returns:
        M*v mod p as tuple
    """
    return (
        (M[0][0]*v[0] + M[0][1]*v[1]) % p,
        (M[1][0]*v[0] + M[1][1]*v[1]) % p
    )


def mat_pow_mod(M: List[List[int]], k: int, p: int) -> List[List[int]]:
    """Compute M^k mod p for a 2x2 matrix.

    Time: O(log k)  Space: O(1)
    """
    result = [[1, 0], [0, 1]]  # Identity
    base = [row[:] for row in M]
    while k > 0:
        if k % 2 == 1:
            result = mat_mul_mod(result, base, p)
        base = mat_mul_mod(base, base, p)
        k //= 2
    return result


# Berggren generators on Euclidean parameters
E1 = [[2, -1], [1, 0]]   # det = 1
E2 = [[2, 1], [1, 0]]    # det = -1
E3 = [[1, 2], [0, 1]]    # det = 1

# Mod-3 reductions
E1_MOD3 = [[2, 2], [1, 0]]
E3_MOD3 = [[1, 2], [0, 1]]


def berggren_triple(m: int, n: int) -> Tuple[int, int, int]:
    """Compute the Pythagorean triple from Euclidean parameters.

    Args:
        m, n: coprime integers with m > n > 0 and m - n odd

    Returns:
        (a, b, c) where a = m²-n², b = 2mn, c = m²+n²
    """
    return (m*m - n*n, 2*m*n, m*m + n*n)


def berggren_tree(depth: int) -> List[Tuple[int, int, int, int, List[str]]]:
    """Generate the Berggren tree to a given depth.

    BFS traversal of the ternary Berggren tree starting from (3,4,5).

    Time: O(3^depth)  Space: O(3^depth)

    Args:
        depth: maximum tree depth

    Returns:
        List of (a, b, c, depth, path) tuples
    """
    import numpy as np

    B1 = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]])
    B2 = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]])
    B3 = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])

    root = np.array([3, 4, 5])
    result = [(3, 4, 5, 0, [])]
    queue = deque([(root, 0, [])])

    while queue:
        triple, d, path = queue.popleft()
        if d >= depth:
            continue
        for name, B in [("B1", B1), ("B2", B2), ("B3", B3)]:
            child = B @ triple
            new_path = path + [name]
            result.append((int(child[0]), int(child[1]), int(child[2]), d + 1, new_path))
            queue.append((child, d + 1, new_path))

    return result


def enumerate_sl2_f3() -> List[List[List[int]]]:
    """Enumerate all elements of SL(2, F_3).

    Returns:
        List of 24 matrices [[a,b],[c,d]] with ad-bc ≡ 1 mod 3
    """
    elements = []
    for a, b, c, d in product(range(3), repeat=4):
        if (a * d - b * c) % 3 == 1:
            elements.append([[a, b], [c, d]])
    return elements


def word_decomposition(target: List[List[int]], max_len: int = 8) -> Optional[List[str]]:
    """Find the shortest word in {E1, E1^2, E3, E3^2} expressing a target in SL(2, F_3).

    BFS over words in the generators.

    Time: O(4^max_len) worst case  Space: O(|SL(2,F_3)|) = O(1)

    Args:
        target: 2x2 matrix over F_3
        max_len: maximum word length to search

    Returns:
        List of generator names, or None if not found
    """
    target_key = (target[0][0], target[0][1], target[1][0], target[1][1])
    identity = [[1, 0], [0, 1]]
    identity_key = (1, 0, 0, 1)

    if target_key == identity_key:
        return []

    generators = {
        "E1": E1_MOD3,
        "E1^2": mat_pow_mod(E1_MOD3, 2, 3),
        "E3": E3_MOD3,
        "E3^2": mat_pow_mod(E3_MOD3, 2, 3),
    }

    visited: Dict[Tuple[int, ...], List[str]] = {identity_key: []}
    queue = deque([(identity, [])])

    while queue:
        current, path = queue.popleft()
        if len(path) >= max_len:
            continue
        for name, gen in generators.items():
            prod = mat_mul_mod(current, gen, 3)
            key = (prod[0][0], prod[0][1], prod[1][0], prod[1][1])
            if key not in visited:
                new_path = path + [name]
                visited[key] = new_path
                if key == target_key:
                    return new_path
                queue.append((prod, new_path))

    return None


def shortest_transport(source: Tuple[int, int], target: Tuple[int, int],
                       p: int = 3) -> Optional[List[str]]:
    """Find the shortest Berggren word transporting source to target in F_p^2.

    This implements the "compiler optimality" theorem: find the minimum-cost
    sequence of Berggren generators mapping one F_p-vector to another.

    Args:
        source: starting vector in F_p^2 (nonzero)
        target: target vector in F_p^2 (nonzero)
        p: prime (default 3)

    Returns:
        Shortest word as list of generator names, or None
    """
    if source == (0, 0) or target == (0, 0):
        return None

    # BFS over the 8 nonzero vectors
    generators = {
        "E1": E1_MOD3,
        "E1^2": mat_pow_mod(E1_MOD3, 2, 3),
        "E3": E3_MOD3,
        "E3^2": mat_pow_mod(E3_MOD3, 2, 3),
    }

    visited = {source: []}
    queue = deque([(source, [])])

    while queue:
        current, path = queue.popleft()
        if current == target:
            return path
        for name, gen in generators.items():
            new_vec = mat_vec_mod(gen, current, p)
            if new_vec not in visited:
                new_path = path + [name]
                visited[new_vec] = new_path
                queue.append((new_vec, new_path))

    return None


def cayley_graph_sl2_f3() -> Dict[Tuple[int, ...], Dict[str, Tuple[int, ...]]]:
    """Compute the Cayley graph of SL(2, F_3) with Berggren generators.

    Returns:
        Dictionary mapping matrix (as tuple) to dict of {generator_name: neighbor}
    """
    generators = {
        "E1": E1_MOD3,
        "E1^(-1)": mat_pow_mod(E1_MOD3, 2, 3),
        "E3": E3_MOD3,
        "E3^(-1)": mat_pow_mod(E3_MOD3, 2, 3),
    }

    elements = enumerate_sl2_f3()
    graph = {}

    for M in elements:
        key = (M[0][0], M[0][1], M[1][0], M[1][1])
        neighbors = {}
        for name, gen in generators.items():
            prod = mat_mul_mod(M, gen, 3)
            prod_key = (prod[0][0], prod[0][1], prod[1][0], prod[1][1])
            neighbors[name] = prod_key
        graph[key] = neighbors

    return graph


if __name__ == "__main__":
    print("=" * 60)
    print("Algorithm 1: Word Decomposition in SL(2, F_3)")
    print("=" * 60)

    elements = enumerate_sl2_f3()
    max_word_len = 0
    for M in elements:
        word = word_decomposition(M)
        key = f"[[{M[0][0]},{M[0][1]}],[{M[1][0]},{M[1][1]}]]"
        if word is not None:
            print(f"  {key} = {'·'.join(word) if word else 'I'} (length {len(word)})")
            max_word_len = max(max_word_len, len(word))
        else:
            print(f"  {key} = NOT FOUND")
    print(f"\nMaximum word length (diameter): {max_word_len}")

    print()
    print("=" * 60)
    print("Algorithm 2: Shortest Symplectic Transport")
    print("=" * 60)

    root = (2, 1)
    for target in [(0, 1), (0, 2), (1, 0), (1, 1), (1, 2), (2, 0), (2, 1), (2, 2)]:
        path = shortest_transport(root, target)
        print(f"  ({root[0]},{root[1]}) -> ({target[0]},{target[1]}): "
              f"{'·'.join(path) if path else 'identity'} (cost {len(path) if path else 0})")

    print()
    print("=" * 60)
    print("Algorithm 3: Berggren Tree (depth 3)")
    print("=" * 60)

    tree = berggren_tree(3)
    for a, b, c, d, path in tree[:13]:  # First 13 nodes
        path_str = " -> ".join(path) if path else "root"
        m_sq = (a + c) // 2
        n_sq = (c - a) // 2
        m_val = int(round(m_sq ** 0.5))
        n_val = int(round(n_sq ** 0.5))
        print(f"  Depth {d}: ({a},{b},{c}), Euclid ({m_val},{n_val}), "
              f"mod 3: ({m_val%3},{n_val%3}), path: {path_str}")
