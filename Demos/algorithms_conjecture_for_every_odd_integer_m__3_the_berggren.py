#!/usr/bin/env python3
"""
Algorithms for Berggren Tree Arithmetic Dynamics

Implements algorithms from the research paper:
1. Berggren word evaluation (matrix product)
2. Modular residue graph construction
3. Strong connectivity verification
4. Extremal word ranking at fixed depth
5. C-ray / A-ray closed-form computation
"""

from typing import Tuple, List, Set, Dict, Optional
from collections import deque
from itertools import product as iproduct

Triple = Tuple[int, int, int]


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 1: Berggren Generator Application
# ═══════════════════════════════════════════════════════════════════════

def berggren_A(t: Triple) -> Triple:
    """Apply Berggren generator A to a triple.

    Matrix: [[1,-2,2],[2,-1,2],[2,-2,3]]
    Time: O(1), Space: O(1)

    >>> berggren_A((3, 4, 5))
    (5, 12, 13)
    """
    a, b, c = t
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)


def berggren_B(t: Triple) -> Triple:
    """Apply Berggren generator B to a triple.

    Matrix: [[1,2,2],[2,1,2],[2,2,3]]
    Time: O(1), Space: O(1)

    >>> berggren_B((3, 4, 5))
    (21, 20, 29)
    """
    a, b, c = t
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)


def berggren_C(t: Triple) -> Triple:
    """Apply Berggren generator C to a triple.

    Matrix: [[-1,2,2],[-2,1,2],[-2,2,3]]
    Time: O(1), Space: O(1)

    >>> berggren_C((3, 4, 5))
    (15, 8, 17)
    """
    a, b, c = t
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)


GENERATORS = {'A': berggren_A, 'B': berggren_B, 'C': berggren_C}
ROOT = (3, 4, 5)


def apply_word(word: str, t: Triple = ROOT) -> Triple:
    """Apply a Berggren word to a triple.

    Args:
        word: String of 'A', 'B', 'C' characters
        t: Starting triple (default: root (3,4,5))

    Returns:
        The resulting primitive Pythagorean triple

    Time: O(|word|), Space: O(1)

    >>> apply_word("AC", (3, 4, 5))
    (45, 28, 53)
    """
    for ch in word:
        t = GENERATORS[ch](t)
    return t


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 2: Closed-Form Ray Computation
# ═══════════════════════════════════════════════════════════════════════

def a_ray_formula(d: int) -> Triple:
    """Compute the d-th triple on the A-ray using the closed form.

    Formula: A^d · (3,4,5) = (2d+3, 2d²+6d+4, 2d²+6d+5)

    Time: O(1), Space: O(1)

    >>> a_ray_formula(0)
    (3, 4, 5)
    >>> a_ray_formula(3)
    (9, 40, 41)
    """
    return (2*d + 3, 2*d**2 + 6*d + 4, 2*d**2 + 6*d + 5)


def c_ray_formula(d: int) -> Triple:
    """Compute the d-th triple on the C-ray using the closed form.

    Formula: C^d · (3,4,5) = (4d²+8d+3, 4d+4, 4d²+8d+5)

    Time: O(1), Space: O(1)

    >>> c_ray_formula(0)
    (3, 4, 5)
    >>> c_ray_formula(2)
    (35, 12, 37)
    """
    return (4*d**2 + 8*d + 3, 4*d + 4, 4*d**2 + 8*d + 5)


def adc_hypotenuse_formula(d: int) -> int:
    """Hypotenuse of A^d · C · (3,4,5).

    Formula: 10(d+1)² + 6(d+1) + 1 = 10d² + 26d + 17

    Time: O(1)

    >>> adc_hypotenuse_formula(0)  # C · (3,4,5) = (15,8,17)
    17
    >>> adc_hypotenuse_formula(1)  # AC · (3,4,5) = (45,28,53)
    53
    """
    return 10*(d+1)**2 + 6*(d+1) + 1


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 3: Modular Residue Graph Construction
# ═══════════════════════════════════════════════════════════════════════

def berggren_mod(gen: str, t: Triple, m: int) -> Triple:
    """Apply a Berggren generator modulo m.

    Time: O(1), Space: O(1)
    """
    result = GENERATORS[gen](t)
    return (result[0] % m, result[1] % m, result[2] % m)


def compute_reachable_set(m: int) -> Set[Triple]:
    """Compute all residue classes reachable from (3,4,5) mod m.

    Uses BFS from the root. Since the state space (ZMod m)³ is finite
    with at most m³ elements, this always terminates.

    Time: O(m³), Space: O(m³) worst case

    >>> len(compute_reachable_set(3))
    4
    >>> len(compute_reachable_set(5))
    12
    """
    root_mod = (3 % m, 4 % m, 5 % m)
    reachable: Set[Triple] = {root_mod}
    frontier = {root_mod}

    while frontier:
        new_frontier: Set[Triple] = set()
        for t in frontier:
            for gen in 'ABC':
                v = berggren_mod(gen, t, m)
                if v not in reachable:
                    reachable.add(v)
                    new_frontier.add(v)
        frontier = new_frontier

    return reachable


def build_residue_digraph(m: int) -> Dict[Triple, List[Triple]]:
    """Build the Berggren residue digraph modulo m.

    Returns adjacency list representation.

    Time: O(|Reachable(m)|), Space: O(|Reachable(m)|)
    """
    reachable = compute_reachable_set(m)
    adj: Dict[Triple, List[Triple]] = {}

    for t in reachable:
        neighbors = []
        for gen in 'ABC':
            v = berggren_mod(gen, t, m)
            neighbors.append(v)
        adj[t] = neighbors

    return adj


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 4: Strong Connectivity Verification
# ═══════════════════════════════════════════════════════════════════════

def is_strongly_connected(m: int) -> bool:
    """Check if the Berggren residue graph mod m is strongly connected.

    Uses BFS from every reachable node to verify all-pairs reachability.

    Time: O(|V|² · 3) where V = Reachable(m)
    Space: O(|V|)

    >>> is_strongly_connected(3)
    True
    >>> is_strongly_connected(5)
    True
    >>> is_strongly_connected(7)
    True
    """
    adj = build_residue_digraph(m)
    nodes = list(adj.keys())
    n = len(nodes)

    if n == 0:
        return True

    for start in nodes:
        visited = {start}
        queue = deque([start])
        while queue:
            node = queue.popleft()
            for nb in adj.get(node, []):
                if nb not in visited:
                    visited.add(nb)
                    queue.append(nb)
        if len(visited) != n:
            return False

    return True


def find_connecting_word(m: int, source: Triple, target: Triple,
                         max_len: int = 100) -> Optional[str]:
    """Find a Berggren word that maps source to target modulo m.

    Uses BFS in the word space.

    Returns None if no word of length ≤ max_len exists.

    >>> find_connecting_word(5, (3, 4, 0), (3, 4, 0)) is not None
    True
    """
    if source == target:
        return ""

    visited = {source: ""}
    queue = deque([(source, "")])

    while queue:
        t, word = queue.popleft()
        if len(word) >= max_len:
            continue
        for gen_name in 'ABC':
            v = berggren_mod(gen_name, t, m)
            if v not in visited:
                new_word = word + gen_name
                if v == target:
                    return new_word
                visited[v] = new_word
                queue.append((v, new_word))

    return None


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 5: Extremal Word Ranking
# ═══════════════════════════════════════════════════════════════════════

def rank_words_by_hypotenuse(depth: int) -> List[Tuple[str, int]]:
    """Rank all Berggren words of a given depth by hypotenuse.

    Time: O(3^d · d), Space: O(3^d)

    >>> rank_words_by_hypotenuse(2)[0]
    ('AA', 25)
    >>> rank_words_by_hypotenuse(2)[1]
    ('CC', 37)
    """
    words = [''.join(w) for w in iproduct('ABC', repeat=depth)]
    ranked = sorted(
        [(w, apply_word(w)[2]) for w in words],
        key=lambda x: x[1]
    )
    return ranked


def verify_second_extremal(max_depth: int = 6) -> Dict[int, dict]:
    """Verify the corrected second extremal conjecture at each depth.

    Returns a dict mapping depth to verification results.

    >>> results = verify_second_extremal(3)
    >>> all(r['c_ray_is_second'] for r in results.values())
    True
    """
    results = {}
    for d in range(1, max_depth + 1):
        ranked = rank_words_by_hypotenuse(d)
        first_word, first_hyp = ranked[0]
        second_word, second_hyp = ranked[1]

        a_ray_hyp = 2*d**2 + 6*d + 5
        c_ray_hyp = 4*d**2 + 8*d + 5

        results[d] = {
            'first_word': first_word,
            'first_hyp': first_hyp,
            'second_word': second_word,
            'second_hyp': second_hyp,
            'a_ray_formula': a_ray_hyp,
            'c_ray_formula': c_ray_hyp,
            'a_ray_is_first': first_word == 'A' * d and first_hyp == a_ray_hyp,
            'c_ray_is_second': second_word == 'C' * d and second_hyp == c_ray_hyp,
        }

    return results


# ═══════════════════════════════════════════════════════════════════════
# Self-test
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Running algorithm self-tests...\n")

    # Test closed forms
    for d in range(10):
        assert apply_word('A' * d) == a_ray_formula(d), f"A-ray mismatch at d={d}"
        assert apply_word('C' * d) == c_ray_formula(d), f"C-ray mismatch at d={d}"
    print("✓ A-ray and C-ray closed forms verified for d=0..9")

    # Test A^d·C formula
    for d in range(10):
        word = 'A' * d + 'C'
        assert apply_word(word)[2] == adc_hypotenuse_formula(d), f"AdC mismatch at d={d}"
    print("✓ A^d·C hypotenuse formula verified for d=0..9")

    # Test strong connectivity
    for m in range(3, 32, 2):
        assert is_strongly_connected(m), f"Strong connectivity failed at m={m}"
    print("✓ Strong connectivity verified for all odd m in [3, 31]")

    # Test second extremal
    results = verify_second_extremal(5)
    for d, r in results.items():
        assert r['a_ray_is_first'], f"A-ray not first at d={d}"
        assert r['c_ray_is_second'], f"C-ray not second at d={d}"
    print("✓ Corrected second extremal verified for d=1..5")

    # Test Pythagorean property
    for d in range(20):
        t = a_ray_formula(d)
        assert t[0]**2 + t[1]**2 == t[2]**2, f"A-ray not Pythagorean at d={d}"
        t = c_ray_formula(d)
        assert t[0]**2 + t[1]**2 == t[2]**2, f"C-ray not Pythagorean at d={d}"
    print("✓ Pythagorean property verified for A-ray and C-ray")

    # Test connecting words
    w = find_connecting_word(7, (3 % 7, 4 % 7, 5 % 7), (3 % 7, 4 % 7, 5 % 7))
    assert w is not None
    print(f"✓ Connecting word mod 7 from root to root: '{w}'")

    print("\nAll self-tests passed!")
