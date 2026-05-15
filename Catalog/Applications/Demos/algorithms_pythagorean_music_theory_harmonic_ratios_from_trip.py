#!/usr/bin/env python3
"""
Algorithms for Pythagorean Harmonic-Tropical Theory
====================================================

Implements the core algorithms from the research paper:
1. Berggren tree generation with harmonic annotation
2. Tropical embedding computation
3. Consonance classification and search
4. Tropical height analysis
"""

import math
from fractions import Fraction
from typing import List, Tuple, Optional, Dict, Generator
from collections import defaultdict


# ============================================================
# Algorithm 1: Berggren Tree with Harmonic Annotation
# ============================================================

class BerggrenNode:
    """A node in the Berggren tree, annotated with harmonic data."""
    
    def __init__(self, a: int, b: int, c: int, depth: int = 0,
                 parent: Optional['BerggrenNode'] = None,
                 generator: Optional[str] = None):
        self.a = a
        self.b = b
        self.c = c
        self.depth = depth
        self.parent = parent
        self.generator = generator  # 'A', 'B', or 'C'
        
        # Harmonic annotations (computed lazily)
        self._tropical_coords = None
        self._consonance = None
    
    @property
    def triple(self) -> Tuple[int, int, int]:
        return (self.a, self.b, self.c)
    
    @property
    def is_pythagorean(self) -> bool:
        return self.a**2 + self.b**2 == self.c**2
    
    @property
    def tropical_coords(self) -> Tuple[float, float]:
        """Tropical embedding: (τ(a/c), τ(b/c)) where τ = -log₂."""
        if self._tropical_coords is None:
            tau_a = -math.log2(self.a / self.c)
            tau_b = -math.log2(self.b / self.c)
            self._tropical_coords = (tau_a, tau_b)
        return self._tropical_coords
    
    @property
    def tropical_height(self) -> float:
        """min(τ(a/c), τ(b/c))."""
        return min(self.tropical_coords)
    
    @property
    def fifth_coordinate(self) -> float:
        """log₂(b/a) — the inter-leg interval in octave units."""
        return math.log2(self.b / self.a)
    
    def side_ratios(self) -> Dict[str, Fraction]:
        """All six pairwise side ratios."""
        return {
            'c/a': Fraction(self.c, self.a),
            'c/b': Fraction(self.c, self.b),
            'b/a': Fraction(self.b, self.a),
            'a/c': Fraction(self.a, self.c),
            'b/c': Fraction(self.b, self.c),
            'a/b': Fraction(self.a, self.b),
        }
    
    def children(self) -> List['BerggrenNode']:
        """Generate the three Berggren children."""
        a, b, c = self.a, self.b, self.c
        return [
            BerggrenNode(a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c,
                        self.depth + 1, self, 'A'),
            BerggrenNode(a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c,
                        self.depth + 1, self, 'B'),
            BerggrenNode(-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c,
                        self.depth + 1, self, 'C'),
        ]
    
    def path_word(self) -> str:
        """The generator word from root to this node."""
        if self.parent is None:
            return ""
        return self.parent.path_word() + self.generator
    
    def __repr__(self):
        return f"BerggrenNode({self.a}, {self.b}, {self.c}, depth={self.depth})"


def berggren_bfs(max_depth: int) -> Generator[BerggrenNode, None, None]:
    """
    Breadth-first traversal of the Berggren tree.
    
    Time complexity: O(3^d) where d = max_depth
    Space complexity: O(3^d) for the queue
    
    Yields BerggrenNode objects with full harmonic annotation.
    """
    root = BerggrenNode(3, 4, 5)
    queue = [root]
    while queue:
        node = queue.pop(0)
        yield node
        if node.depth < max_depth:
            queue.extend(node.children())


# ============================================================
# Algorithm 2: Consonance Classification
# ============================================================

# Standard just-intonation consonant ratios
JUST_CONSONANCES = {
    Fraction(1, 1): ("unison", 0),
    Fraction(16, 15): ("minor second", 1),
    Fraction(9, 8): ("major second", 2),
    Fraction(6, 5): ("minor third", 3),
    Fraction(5, 4): ("major third", 4),
    Fraction(4, 3): ("perfect fourth", 5),
    Fraction(45, 32): ("tritone", 6),
    Fraction(3, 2): ("perfect fifth", 7),
    Fraction(8, 5): ("minor sixth", 8),
    Fraction(5, 3): ("major sixth", 9),
    Fraction(9, 5): ("minor seventh", 10),
    Fraction(15, 8): ("major seventh", 11),
    Fraction(2, 1): ("octave", 12),
}

# Restrict to the "simple" consonances used in our formal theory
SIMPLE_CONSONANCES = {
    Fraction(1, 1): "unison",
    Fraction(6, 5): "minor third",
    Fraction(5, 4): "major third",
    Fraction(4, 3): "perfect fourth",
    Fraction(3, 2): "perfect fifth",
}


def classify_triple(a: int, b: int, c: int,
                    ratio_set: Dict = None) -> List[Tuple[str, Fraction, Optional[str]]]:
    """
    Classify all side-ratios of a Pythagorean triple against a consonance dictionary.
    
    Args:
        a, b, c: Triple entries (positive integers)
        ratio_set: Dictionary mapping Fraction -> interval name
    
    Returns:
        List of (ratio_label, ratio_value, interval_name_or_None)
    
    Time complexity: O(|ratio_set|) per ratio, O(1) total since |ratios| = 6
    """
    if ratio_set is None:
        ratio_set = SIMPLE_CONSONANCES
    
    results = []
    pairs = [(c, a, "c/a"), (c, b, "c/b"), (b, a, "b/a")]
    for num, den, label in pairs:
        r = Fraction(num, den)
        name = ratio_set.get(r, None)
        results.append((label, r, name))
    return results


def is_simply_consonant(a: int, b: int, c: int) -> bool:
    """Check if a triple has any simple consonant side-ratio."""
    return any(name is not None for _, _, name in classify_triple(a, b, c))


# ============================================================
# Algorithm 3: Consonance Search in the Berggren Tree
# ============================================================

def search_consonant_triples(max_depth: int,
                              ratio_set: Dict = None) -> List[BerggrenNode]:
    """
    Search the Berggren tree for consonant triples up to a given depth.
    
    Time complexity: O(3^d) where d = max_depth
    
    Returns list of consonant nodes with their tree positions.
    """
    if ratio_set is None:
        ratio_set = SIMPLE_CONSONANCES
    
    consonant_nodes = []
    for node in berggren_bfs(max_depth):
        if is_simply_consonant(node.a, node.b, node.c):
            consonant_nodes.append(node)
    return consonant_nodes


def consonance_density(max_depth: int) -> List[Tuple[int, int, int, float]]:
    """
    Compute consonance density at each depth level.
    
    Returns: List of (depth, consonant_count, total_count, density)
    """
    counts = defaultdict(lambda: [0, 0])  # [consonant, total]
    for node in berggren_bfs(max_depth):
        counts[node.depth][1] += 1
        if is_simply_consonant(node.a, node.b, node.c):
            counts[node.depth][0] += 1
    
    results = []
    for d in sorted(counts.keys()):
        c, t = counts[d]
        results.append((d, c, t, c / t if t > 0 else 0.0))
    return results


# ============================================================
# Algorithm 4: Tropical Height Analysis
# ============================================================

def tropical_height_along_path(path: str, max_steps: int = 10) -> List[Tuple[int, Tuple[int, int, int], float]]:
    """
    Compute tropical heights along a fixed generator path.
    
    Args:
        path: String of 'A', 'B', 'C' characters (repeated cyclically)
        max_steps: Number of steps to take
    
    Returns: List of (step, triple, tropical_height)
    """
    generators = {'A': lambda a, b, c: (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c),
                  'B': lambda a, b, c: (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c),
                  'C': lambda a, b, c: (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)}
    
    triple = (3, 4, 5)
    results = [(0, triple, min(-math.log2(triple[0]/triple[2]),
                                -math.log2(triple[1]/triple[2])))]
    
    for i in range(max_steps):
        gen = path[i % len(path)]
        triple = generators[gen](*triple)
        h = min(-math.log2(triple[0]/triple[2]), -math.log2(triple[1]/triple[2]))
        results.append((i + 1, triple, h))
    
    return results


# ============================================================
# Main demonstration
# ============================================================

if __name__ == "__main__":
    print("Berggren Tree — Harmonic-Tropical Analysis")
    print("=" * 60)
    
    # Consonance density analysis
    print("\nConsonance density by depth:")
    print(f"{'Depth':<8} {'Consonant':<12} {'Total':<10} {'Density':<10}")
    for d, c, t, density in consonance_density(6):
        print(f"{d:<8} {c:<12} {t:<10} {density:<10.4f}")
    
    # Tropical height along paths
    print("\nTropical height along A-path:")
    for step, triple, h in tropical_height_along_path('A', 8):
        print(f"  Step {step}: {triple}  height = {h:.6f}")
    
    # Search for consonant triples
    print(f"\nConsonant triples up to depth 5:")
    consonant = search_consonant_triples(5)
    for node in consonant:
        ratios = classify_triple(node.a, node.b, node.c)
        cons_ratios = [(l, r, n) for l, r, n in ratios if n]
        print(f"  {node.triple} (depth {node.depth}, word '{node.path_word()}')")
        for label, ratio, name in cons_ratios:
            print(f"    {label} = {ratio} ({name})")
