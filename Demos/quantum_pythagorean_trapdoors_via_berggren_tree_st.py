#!/usr/bin/env python3
"""
Berggren Tree Algorithms: Encoding, Decoding, and Quantum Simulation

Implements:
1. Berggren word evaluation (forward trapdoor)
2. Bounded-depth decoder (inverse search)
3. Collision separation oracle
4. Quantum state preparation simulation
5. Hypotenuse growth bounds
"""

import numpy as np
from itertools import product as iter_product
from typing import Optional, List, Tuple
from math import gcd

# === Core Matrices ===

A = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]], dtype=np.int64)
B = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]], dtype=np.int64)
C = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]], dtype=np.int64)

MATRICES = {'A': A, 'B': B, 'C': C}
ROOT = np.array([3, 4, 5], dtype=np.int64)


def berggren_eval(word: str) -> np.ndarray:
    """
    Evaluate a Berggren word on the root triple (3,4,5).
    
    Time complexity: O(9 * len(word) + 3) multiplications.
    
    Args:
        word: String over alphabet {A, B, C}
        
    Returns:
        3-vector (a, b, c) primitive Pythagorean triple
    """
    v = ROOT.copy()
    for ch in reversed(word):
        v = MATRICES[ch] @ v
    return v


def is_primitive_pythagorean(v: np.ndarray) -> bool:
    """Check if v = (a,b,c) is a primitive Pythagorean triple."""
    a, b, c = int(v[0]), int(v[1]), int(v[2])
    return (a > 0 and b > 0 and c > 0 and
            a*a + b*b == c*c and
            gcd(abs(a), abs(b)) == 1)


def bounded_decode(triple: np.ndarray, max_depth: int) -> Optional[str]:
    """
    Bounded-depth decoder: find the Berggren word that produces `triple`.
    
    This is the "hard direction" of the trapdoor — requires exhaustive
    search over 3^N words for depth N.
    
    Time complexity: O(3^max_depth * 9 * max_depth)
    
    Args:
        triple: Target (a, b, c) vector
        max_depth: Maximum word length to search
        
    Returns:
        The unique word producing `triple`, or None if not found
    """
    target = tuple(int(x) for x in triple)
    for depth in range(max_depth + 1):
        for word_tuple in iter_product('ABC', repeat=depth):
            word = ''.join(word_tuple)
            v = berggren_eval(word)
            if tuple(int(x) for x in v) == target:
                return word
    return None


def l1_distance(u: np.ndarray, v: np.ndarray) -> int:
    """L1 distance between two integer vectors."""
    return int(np.sum(np.abs(u - v)))


def collision_separation_oracle(word1: str, word2: str) -> dict:
    """
    Compute collision separation data for two Berggren words.
    
    Returns a dictionary with:
    - l1_dist: L1 distance between evaluated triples
    - first_divergence: index of first character difference
    - hyp_ratio: ratio of hypotenuses
    """
    v1 = berggren_eval(word1)
    v2 = berggren_eval(word2)
    
    # Find first divergence
    div_idx = None
    for i in range(min(len(word1), len(word2))):
        if word1[i] != word2[i]:
            div_idx = i
            break
    if div_idx is None:
        div_idx = min(len(word1), len(word2))
    
    return {
        'word1': word1,
        'word2': word2,
        'triple1': tuple(int(x) for x in v1),
        'triple2': tuple(int(x) for x in v2),
        'l1_dist': l1_distance(v1, v2),
        'first_divergence': div_idx,
        'hyp1': int(v1[2]),
        'hyp2': int(v2[2]),
    }


def quantum_state_amplitudes(words: List[str], amplitudes: List[float]) -> dict:
    """
    Simulate a quantum superposition over Berggren words.
    
    Args:
        words: List of Berggren words (basis labels)
        amplitudes: Complex amplitudes (real part only for simplicity)
        
    Returns:
        Dictionary with state info, norm, and triple-space pushforward
    """
    assert len(words) == len(amplitudes)
    
    sq_norm = sum(a**2 for a in amplitudes)
    
    # Pushforward to triple space
    triple_amps = {}
    for w, a in zip(words, amplitudes):
        v = tuple(int(x) for x in berggren_eval(w))
        triple_amps[v] = triple_amps.get(v, 0.0) + a
    
    return {
        'words': words,
        'amplitudes': amplitudes,
        'sq_norm': sq_norm,
        'triple_amplitudes': triple_amps,
        'support_size': len(triple_amps),
    }


def hypotenuse_growth_table(max_depth: int) -> List[dict]:
    """
    Compute hypotenuse statistics at each depth.
    
    Returns list of dicts with min/max/mean hypotenuse at each depth.
    """
    results = []
    for depth in range(max_depth + 1):
        if depth == 0:
            hyps = [5]
        else:
            hyps = []
            for word_tuple in iter_product('ABC', repeat=depth):
                word = ''.join(word_tuple)
                v = berggren_eval(word)
                hyps.append(int(v[2]))
        
        results.append({
            'depth': depth,
            'count': len(hyps),
            'min_hyp': min(hyps),
            'max_hyp': max(hyps),
            'mean_hyp': sum(hyps) / len(hyps),
            'lower_bound': 5 + depth,  # Proved: 5 + depth ≤ hypotenuse
        })
    
    return results


def eval_cost(word_length: int) -> int:
    """Evaluation cost in multiplications."""
    return 9 * word_length + 3


# === Main Demo ===

if __name__ == '__main__':
    print("=== Berggren Tree Algorithms ===\n")
    
    # 1. Forward evaluation
    print("1. Forward Evaluation (Trapdoor Easy Direction)")
    for w in ['', 'A', 'B', 'C', 'AB', 'ABC', 'ABCA']:
        v = berggren_eval(w)
        prim = is_primitive_pythagorean(v)
        print(f"   eval('{w}') = ({v[0]}, {v[1]}, {v[2]})  "
              f"primitive: {prim}  cost: {eval_cost(len(w))}")
    
    # 2. Bounded decoding
    print("\n2. Bounded Decoding (Trapdoor Hard Direction)")
    test_triples = [
        np.array([5, 12, 13]),
        np.array([21, 20, 29]),
        np.array([15, 8, 17]),
        np.array([119, 120, 169]),
    ]
    for t in test_triples:
        w = bounded_decode(t, max_depth=4)
        print(f"   decode({tuple(t)}) = '{w}'  (depth ≤ 4)")
    
    # 3. Collision separation
    print("\n3. Collision Separation Data")
    pairs = [('A', 'B'), ('AB', 'AC'), ('ABC', 'ABB'), ('AAAA', 'BBBB')]
    for w1, w2 in pairs:
        data = collision_separation_oracle(w1, w2)
        print(f"   {w1} vs {w2}: L1 = {data['l1_dist']}, "
              f"diverge at {data['first_divergence']}")
    
    # 4. Hypotenuse growth
    print("\n4. Hypotenuse Growth Statistics")
    table = hypotenuse_growth_table(5)
    print(f"   {'Depth':>5s} {'Count':>6s} {'Min':>8s} {'Max':>8s} "
          f"{'Mean':>10s} {'Lower':>6s}")
    for row in table:
        print(f"   {row['depth']:>5d} {row['count']:>6d} {row['min_hyp']:>8d} "
              f"{row['max_hyp']:>8d} {row['mean_hyp']:>10.1f} "
              f"{row['lower_bound']:>6d}")
    
    # 5. Quantum state
    print("\n5. Quantum State Simulation")
    words = ['A', 'B', 'C']
    amps = [1/np.sqrt(3)] * 3
    state = quantum_state_amplitudes(words, amps)
    print(f"   Uniform superposition over {words}")
    print(f"   ||ψ||² = {state['sq_norm']:.6f}")
    print(f"   Triple-space support: {state['support_size']} distinct triples")
    
    print("\nAll algorithms completed successfully.")


#!/usr/bin/env python3
"""
Applications of Berggren Tree Cryptography

1. Toy trapdoor demonstration (key generation / public commitment)
2. Collision resistance measurement
3. Certified robustness bounds
4. Quantum distinguishability simulation
"""

import numpy as np
from itertools import product as iter_product
from math import gcd
import hashlib
import time

A = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]], dtype=np.int64)
B = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]], dtype=np.int64)
C = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]], dtype=np.int64)
MATRICES = {'A': A, 'B': B, 'C': C}
ROOT = np.array([3, 4, 5], dtype=np.int64)

def berggren_eval(word):
    v = ROOT.copy()
    for ch in reversed(word):
        v = MATRICES[ch] @ v
    return v

def l1_dist(u, v):
    return int(np.sum(np.abs(u - v)))


# === Application 1: Toy Trapdoor Key System ===

print("=" * 60)
print("APPLICATION 1: Berggren Trapdoor Key System")
print("=" * 60)

# Key generation: choose a random Berggren word as secret key
import random
random.seed(42)
key_length = 8
secret_key = ''.join(random.choice('ABC') for _ in range(key_length))
public_triple = berggren_eval(secret_key)

print(f"Secret key (word):  {secret_key}")
print(f"Public triple:      ({public_triple[0]}, {public_triple[1]}, {public_triple[2]})")
print(f"Hypotenuse:         {public_triple[2]}")
print(f"Key space size:     3^{key_length} = {3**key_length}")
print(f"Forward eval cost:  {9 * key_length + 3} multiplications")
print(f"Brute-force cost:   ~{3**key_length * 9 * key_length} multiplications")
print()

# Verify injectivity: all depth-4 words produce distinct triples
print("Injectivity verification (depth ≤ 4):")
triples_seen = {}
collisions = 0
for depth in range(5):
    for w in iter_product('ABC', repeat=depth):
        word = ''.join(w)
        v = tuple(int(x) for x in berggren_eval(word))
        if v in triples_seen:
            collisions += 1
        triples_seen[v] = word
print(f"  Total words checked: {len(triples_seen)}")
print(f"  Collisions found: {collisions}")
print()


# === Application 2: Collision Resistance Measurement ===

print("=" * 60)
print("APPLICATION 2: Collision Resistance Measurement")
print("=" * 60)

# Measure minimum L1 separation at each depth
for depth in range(1, 5):
    words = [''.join(w) for w in iter_product('ABC', repeat=depth)]
    min_dist = float('inf')
    min_pair = None
    for i in range(len(words)):
        for j in range(i+1, len(words)):
            d = l1_dist(berggren_eval(words[i]), berggren_eval(words[j]))
            if d < min_dist:
                min_dist = d
                min_pair = (words[i], words[j])
    print(f"  Depth {depth}: min L1 separation = {min_dist}  "
          f"(between {min_pair[0]} and {min_pair[1]})")
print()


# === Application 3: Certified Robustness Bounds ===

print("=" * 60)
print("APPLICATION 3: Certified Robustness Bounds")
print("=" * 60)
print("Lipschitz-style bounds: how much can the triple change")
print("when a word is perturbed by changing one character?")
print()

for depth in range(1, 5):
    max_change = 0
    words = [''.join(w) for w in iter_product('ABC', repeat=depth)]
    perturbations = 0
    for word in words:
        for pos in range(len(word)):
            for new_ch in 'ABC':
                if new_ch != word[pos]:
                    perturbed = word[:pos] + new_ch + word[pos+1:]
                    d = l1_dist(berggren_eval(word), berggren_eval(perturbed))
                    max_change = max(max_change, d)
                    perturbations += 1
    print(f"  Depth {depth}: max L1 change from 1-char perturbation = {max_change}")
    print(f"    ({perturbations} perturbations checked)")
print()


# === Application 4: Quantum Distinguishability ===

print("=" * 60)
print("APPLICATION 4: Quantum Distinguishability Simulation")
print("=" * 60)

# Two quantum states: uniform over {AA, AB, AC} vs {BA, BB, BC}
words1 = ['AA', 'AB', 'AC']
words2 = ['BA', 'BB', 'BC']
amp = 1.0 / np.sqrt(3)

print(f"|ψ₁⟩ = (1/√3)(|AA⟩ + |AB⟩ + |AC⟩)")
print(f"|ψ₂⟩ = (1/√3)(|BA⟩ + |BB⟩ + |BC⟩)")
print()

# Compute inner product in triple basis
triples1 = {tuple(int(x) for x in berggren_eval(w)): amp for w in words1}
triples2 = {tuple(int(x) for x in berggren_eval(w)): amp for w in words2}

# Since all triples are distinct (by injectivity), inner product is 0
common = set(triples1.keys()) & set(triples2.keys())
inner_prod = sum(triples1[t] * triples2[t] for t in common)

print(f"Triple-space overlap: {len(common)} common triples")
print(f"Inner product ⟨ψ₁|ψ₂⟩ = {inner_prod:.6f}")
print(f"States are {'perfectly distinguishable' if inner_prod == 0 else 'not perfectly distinguishable'}")
print()

# Min distance between the triple sets
min_cross_dist = float('inf')
for t1 in triples1:
    for t2 in triples2:
        d = sum(abs(a - b) for a, b in zip(t1, t2))
        min_cross_dist = min(min_cross_dist, d)
print(f"Min L1 distance between triple sets: {min_cross_dist}")
print()

print("All applications completed successfully.")


#!/usr/bin/env python3
"""
Berggren Tree Demonstrations: Pythagorean Triple Generation and Trapdoor Encoding

This script demonstrates:
1. Berggren matrix action on primitive Pythagorean triples
2. Tree traversal and triple generation
3. Hypotenuse growth visualization
4. Collision separation measurements
5. Quantum state preparation simulation
"""

import numpy as np
from itertools import product as iter_product

# Berggren matrices
A = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]])
B = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]])
C = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])

MATRICES = {'A': A, 'B': B, 'C': C}
ROOT = np.array([3, 4, 5])

def berggren_eval(word: str) -> np.ndarray:
    """Evaluate a Berggren word on the root triple (3,4,5)."""
    v = ROOT.copy()
    for ch in reversed(word):
        v = MATRICES[ch] @ v
    return v

def is_pythagorean(v):
    """Check if v = (a,b,c) satisfies a² + b² = c²."""
    return v[0]**2 + v[1]**2 == v[2]**2

def l1_dist(u, v):
    """L1 distance between two vectors."""
    return int(np.sum(np.abs(u - v)))

# Demo 1: Generate all triples up to depth 3
print("=" * 60)
print("DEMO 1: Berggren Tree — First 3 Levels")
print("=" * 60)
print(f"Root: {tuple(ROOT)}")
print(f"  Pythagorean check: {ROOT[0]}² + {ROOT[1]}² = {ROOT[0]**2 + ROOT[1]**2} = {ROOT[2]}² ✓")
print()

for depth in range(1, 4):
    words = [''.join(w) for w in iter_product('ABC', repeat=depth)]
    print(f"Depth {depth} ({len(words)} triples):")
    for w in words[:9]:  # Show first 9
        v = berggren_eval(w)
        check = "✓" if is_pythagorean(v) else "✗"
        print(f"  {w:>4s} → ({v[0]:>5d}, {v[1]:>5d}, {v[2]:>5d})  "
              f"{v[0]}² + {v[1]}² = {v[0]**2 + v[1]**2} = {v[2]}² {check}")
    if len(words) > 9:
        print(f"  ... ({len(words) - 9} more)")
    print()

# Demo 2: Hypotenuse growth
print("=" * 60)
print("DEMO 2: Hypotenuse Growth Along Paths")
print("=" * 60)
for path in ['AAAA', 'BBBB', 'CCCC', 'ABCA', 'CBAC']:
    hyps = [5]
    for i in range(1, len(path) + 1):
        v = berggren_eval(path[:i])
        hyps.append(int(v[2]))
    growth = [hyps[i+1] / hyps[i] for i in range(len(hyps)-1)]
    print(f"  Path {path}: hypotenuses = {hyps}")
    print(f"    Growth factors: {[f'{g:.2f}' for g in growth]}")
print()

# Demo 3: Collision separation
print("=" * 60)
print("DEMO 3: Collision Separation (L1 Distance)")
print("=" * 60)
print("Distinct depth-1 words:")
for w1, w2 in [('A', 'B'), ('A', 'C'), ('B', 'C')]:
    v1, v2 = berggren_eval(w1), berggren_eval(w2)
    d = l1_dist(v1, v2)
    print(f"  d({w1}, {w2}) = L1({tuple(v1)}, {tuple(v2)}) = {d}")

print("\nDistinct depth-2 words (sample):")
words2 = [''.join(w) for w in iter_product('ABC', repeat=2)]
dists = []
for i in range(len(words2)):
    for j in range(i+1, len(words2)):
        d = l1_dist(berggren_eval(words2[i]), berggren_eval(words2[j]))
        dists.append((d, words2[i], words2[j]))
dists.sort()
for d, w1, w2 in dists[:5]:
    print(f"  d({w1}, {w2}) = {d}")
print(f"  Minimum separation at depth 2: {dists[0][0]}")
print()

# Demo 4: Trapdoor evaluation cost
print("=" * 60)
print("DEMO 4: Trapdoor Forward Evaluation Cost")
print("=" * 60)
for n in [1, 5, 10, 50, 100, 1000]:
    cost = 9 * n + 3
    print(f"  Depth {n:>4d}: cost = 9·{n} + 3 = {cost:>6d} multiplications")
print()

# Demo 5: Quantum state simulation
print("=" * 60)
print("DEMO 5: Quantum State Preparation Simulation")
print("=" * 60)
# Simulate a uniform superposition over depth-1 words
amp = 1.0 / np.sqrt(3)
states = {w: amp for w in 'ABC'}
sq_norm = sum(a**2 for a in states.values())
print(f"Uniform superposition over {{A, B, C}}:")
print(f"  |ψ⟩ = {amp:.4f}|A⟩ + {amp:.4f}|B⟩ + {amp:.4f}|C⟩")
print(f"  ||ψ||² = {sq_norm:.6f}")
print(f"  Triple images:")
for w, a in states.items():
    v = berggren_eval(w)
    print(f"    |{w}⟩ → ({v[0]}, {v[1]}, {v[2]})  amplitude = {a:.4f}")
print()

# Demo 6: Determinant verification
print("=" * 60)
print("DEMO 6: Unimodularity — det = ±1")
print("=" * 60)
for name, M in MATRICES.items():
    d = int(round(np.linalg.det(M)))
    print(f"  det(Berggren {name}) = {d}")
# Product determinant for a word
word = "ABCBA"
prod_det = 1
for ch in word:
    prod_det *= int(round(np.linalg.det(MATRICES[ch])))
print(f"  det(product along '{word}') = {prod_det}")
print()

print("All demos completed successfully.")
