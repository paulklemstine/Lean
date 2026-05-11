#!/usr/bin/env python3
"""
Berggren Tree Demo: Generating and exploring primitive Pythagorean triples.

This script demonstrates the Berggren ternary tree structure, where every
positive primitive Pythagorean triple has a unique address as a word in {A,B,C}.
"""

import numpy as np
from collections import deque

# The three Berggren matrices
A = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]], dtype=int)
B = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]], dtype=int)
C = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]], dtype=int)

ROOT = np.array([3, 4, 5], dtype=int)
MATRICES = {'A': A, 'B': B, 'C': C}


def apply_word(word: str, v=None) -> np.ndarray:
    """Apply a Berggren word to the root triple (right-fold: first letter outermost)."""
    if v is None:
        v = ROOT.copy()
    result = v.copy()
    for letter in reversed(word):
        result = MATRICES[letter] @ result
    return result


def is_pythagorean(triple):
    """Check if a² + b² = c²."""
    a, b, c = triple
    return a*a + b*b == c*c


def is_primitive(triple):
    """Check if gcd(a,b,c) = 1."""
    from math import gcd
    return gcd(gcd(abs(triple[0]), abs(triple[1])), abs(triple[2])) == 1


def enumerate_triples(max_depth=4):
    """Enumerate all triples in the Berggren tree up to given depth."""
    queue = deque([(ROOT.copy(), "")])
    results = []
    while queue:
        triple, word = queue.popleft()
        results.append((triple, word if word else "ε"))
        if len(word) < max_depth:
            for letter, matrix in MATRICES.items():
                child = matrix @ triple
                queue.append((child, word + letter))
    return results


def verify_uniqueness(triples):
    """Verify that all triples are distinct (collision-free)."""
    seen = set()
    for triple, word in triples:
        key = tuple(triple)
        if key in seen:
            return False, key
        seen.add(key)
    return True, None


def demo_tree():
    """Main demo: explore the Berggren tree."""
    print("=" * 60)
    print("BERGGREN TREE OF PRIMITIVE PYTHAGOREAN TRIPLES")
    print("=" * 60)
    
    print("\nRoot triple: (3, 4, 5)")
    print(f"  Pythagorean: {is_pythagorean(ROOT)}")
    print(f"  Primitive: {is_primitive(ROOT)}")
    
    print("\n--- First-level children ---")
    for letter in "ABC":
        child = apply_word(letter)
        print(f"  {letter}(3,4,5) = ({child[0]}, {child[1]}, {child[2]})")
        print(f"    Pythagorean: {is_pythagorean(child)}, Primitive: {is_primitive(child)}")
        print(f"    Hypotenuse: {child[2]} (growth: +{child[2] - 5})")
    
    print("\n--- Hypotenuse growth verification ---")
    print(f"  {'Word':<8} {'Triple':<20} {'Hyp':>5} {'5+2n':>5} {'OK?':>5}")
    for depth in range(6):
        for word in [''.join(w) for w in _words_of_length(depth)]:
            triple = apply_word(word)
            hyp = triple[2]
            bound = 5 + 2 * len(word)
            ok = hyp >= bound
            if depth <= 2 or (depth <= 4 and word in ['AAA', 'BBB', 'CCC', 'ABC', 'CBA']):
                name = word if word else "ε"
                print(f"  {name:<8} ({triple[0]:>3},{triple[1]:>3},{triple[2]:>3}) {hyp:>5} {bound:>5} {'✓' if ok else '✗':>5}")
    
    print("\n--- Uniqueness verification ---")
    triples = enumerate_triples(max_depth=5)
    unique, collision = verify_uniqueness(triples)
    print(f"  Total triples (depth ≤ 5): {len(triples)}")
    print(f"  All unique: {unique}")
    if not unique:
        print(f"  Collision at: {collision}")
    
    print("\n--- Determinants ---")
    for name, M in MATRICES.items():
        print(f"  det({name}) = {int(np.linalg.det(M))}")
    
    print("\n--- Form preservation ---")
    for word in ['A', 'B', 'C', 'AB', 'ABC', 'ABCABC']:
        triple = apply_word(word)
        form = triple[0]**2 + triple[1]**2 - triple[2]**2
        print(f"  q({word}(root)) = {form}")


def _words_of_length(n):
    """Generate all words of length n over {A,B,C}."""
    if n == 0:
        return ['']
    shorter = _words_of_length(n - 1)
    return [w + l for w in shorter for l in 'ABC']


if __name__ == '__main__':
    demo_tree()
