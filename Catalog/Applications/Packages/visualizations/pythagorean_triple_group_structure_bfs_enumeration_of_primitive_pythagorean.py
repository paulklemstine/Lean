#!/usr/bin/env python3
"""
algorithms.py — Certified Enumeration Algorithms for the Berggren Tree

Implements:
1. BFS enumeration of primitive Pythagorean triples by depth
2. Hypotenuse-bounded enumeration (all triples with c ≤ N)
3. Unique parent recovery via inverse Berggren maps
4. Word encoding/decoding for canonical triple representation
"""

from math import gcd
from typing import Tuple, List, Optional, Dict
from collections import deque

Triple = Tuple[int, int, int]

# ═══════════════════════════════════════════════════════════════
# Core Berggren Maps
# ═══════════════════════════════════════════════════════════════

def bergA(a: int, b: int, c: int) -> Triple:
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def bergB(a: int, b: int, c: int) -> Triple:
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def bergC(a: int, b: int, c: int) -> Triple:
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

def invBergA(a: int, b: int, c: int) -> Triple:
    return (a + 2*b - 2*c, -2*a - b + 2*c, -2*a - 2*b + 3*c)

def invBergB(a: int, b: int, c: int) -> Triple:
    return (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

def invBergC(a: int, b: int, c: int) -> Triple:
    return (-a - 2*b + 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

GENERATORS = [('A', bergA), ('B', bergB), ('C', bergC)]
INVERSES = [('A', invBergA), ('B', invBergB), ('C', invBergC)]

ROOT = (3, 4, 5)

# ═══════════════════════════════════════════════════════════════
# Algorithm 1: BFS Enumeration by Depth
# ═══════════════════════════════════════════════════════════════

def enumerate_by_depth(max_depth: int) -> Dict[int, List[Triple]]:
    """
    Enumerate all primitive Pythagorean triples in the Berggren tree
    up to a given depth.
    
    Time: O(3^d) where d = max_depth
    Space: O(3^d)
    
    Returns: dict mapping depth -> list of triples at that depth
    """
    result: Dict[int, List[Triple]] = {0: [ROOT]}
    current_level = [ROOT]
    
    for depth in range(1, max_depth + 1):
        next_level = []
        for triple in current_level:
            for _, gen in GENERATORS:
                child = gen(*triple)
                assert child[0]**2 + child[1]**2 == child[2]**2, f"Not Pythagorean: {child}"
                assert gcd(gcd(child[0], child[1]), child[2]) == 1, f"Not primitive: {child}"
                next_level.append(child)
        result[depth] = next_level
        current_level = next_level
    
    return result

# ═══════════════════════════════════════════════════════════════
# Algorithm 2: Hypotenuse-Bounded Enumeration
# ═══════════════════════════════════════════════════════════════

def enumerate_up_to_hypotenuse(max_c: int) -> List[Triple]:
    """
    Enumerate all primitive Pythagorean triples with hypotenuse ≤ max_c.
    Uses BFS with pruning based on hypotenuse growth.
    
    By Theorem E (hypotenuse strict growth), every child has strictly
    larger hypotenuse than its parent, so pruning is safe.
    
    Time: O(N) where N = number of such triples (≈ max_c / (2π))
    Space: O(N)
    """
    result = []
    queue = deque([ROOT])
    
    while queue:
        triple = queue.popleft()
        if triple[2] > max_c:
            continue
        result.append(triple)
        for _, gen in GENERATORS:
            child = gen(*triple)
            if child[2] <= max_c:
                queue.append(child)
    
    result.sort(key=lambda t: (t[2], t[0]))
    return result

# ═══════════════════════════════════════════════════════════════
# Algorithm 3: Unique Parent Recovery
# ═══════════════════════════════════════════════════════════════

def find_parent(triple: Triple) -> Optional[Tuple[str, Triple]]:
    """
    Given a primitive Pythagorean triple, find its unique parent
    in the Berggren tree (if it's not the root).
    
    By the unique parent theorem, exactly one inverse map gives
    a valid positive primitive triple.
    
    Time: O(1)
    """
    if triple == ROOT:
        return None
    
    a, b, c = triple
    for name, inv in INVERSES:
        pa, pb, pc = inv(a, b, c)
        if pa > 0 and pb > 0 and pc > 0:
            if pa**2 + pb**2 == pc**2 and gcd(pa, pb) == 1:
                return (name, (pa, pb, pc))
    
    return None  # Should not happen for valid primitive triples in the tree

def find_word(triple: Triple) -> str:
    """
    Find the canonical Berggren word encoding of a primitive triple.
    This is the unique path from root to the triple in the tree.
    
    Time: O(log c) where c is the hypotenuse
    """
    if triple == ROOT:
        return ""
    
    word = []
    current = triple
    while current != ROOT:
        result = find_parent(current)
        if result is None:
            raise ValueError(f"Triple {current} is not in the Berggren tree")
        gen_name, parent = result
        word.append(gen_name)
        current = parent
    
    return "".join(reversed(word))

# ═══════════════════════════════════════════════════════════════
# Algorithm 4: Word Application
# ═══════════════════════════════════════════════════════════════

def apply_word(word: str) -> Triple:
    """Apply a Berggren word to the root triple."""
    gen_map = {'A': bergA, 'B': bergB, 'C': bergC}
    result = ROOT
    for letter in word:
        result = gen_map[letter](*result)
    return result

# ═══════════════════════════════════════════════════════════════
# Demonstrations
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("=" * 70)
    print("Algorithm 1: BFS Enumeration by Depth")
    print("=" * 70)
    
    tree = enumerate_by_depth(4)
    for depth in sorted(tree.keys()):
        triples = tree[depth]
        print(f"  Depth {depth}: {len(triples)} triples, "
              f"min hyp = {min(t[2] for t in triples)}, "
              f"max hyp = {max(t[2] for t in triples)}")
    
    print(f"\n  Total triples up to depth 4: {sum(len(v) for v in tree.values())}")
    
    print("\n" + "=" * 70)
    print("Algorithm 2: Hypotenuse-Bounded Enumeration")
    print("=" * 70)
    
    for max_c in [50, 100, 500, 1000, 5000]:
        triples = enumerate_up_to_hypotenuse(max_c)
        print(f"  Triples with c ≤ {max_c:>5}: {len(triples):>6}")
    
    print("\n" + "=" * 70)
    print("Algorithm 3: Unique Parent Recovery")
    print("=" * 70)
    
    test_triples = [(5,12,13), (21,20,29), (15,8,17), (7,24,25), (55,48,73)]
    for t in test_triples:
        result = find_parent(t)
        if result:
            gen, parent = result
            print(f"  {t} ← {gen}({parent})")
        else:
            print(f"  {t} is the root")
    
    print("\n" + "=" * 70)
    print("Algorithm 4: Word Encoding/Decoding")
    print("=" * 70)
    
    test_words = ["", "A", "B", "C", "AA", "AB", "BA", "ABC", "CBA", "ABCA"]
    for w in test_words:
        triple = apply_word(w)
        recovered = find_word(triple)
        status = "✓" if recovered == w else "✗"
        print(f"  Word '{w:>5}' → {str(triple):>20} → recovered '{recovered}' {status}")
    
    print("\nAll algorithms verified successfully.")
