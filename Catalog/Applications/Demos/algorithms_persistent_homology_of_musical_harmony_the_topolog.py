#!/usr/bin/env python3
"""
Algorithms for Persistent Homology of Musical Harmony
=====================================================

Type-hinted implementations of the core algorithms used to analyze
the topology of harmonic spaces.
"""

from typing import List, Set, Tuple, Optional, Dict
import numpy as np


# ============================================================
# Core Data Structures
# ============================================================

PitchClass = int  # 0-11
PitchClassSet = frozenset  # frozenset of PitchClass
PersistenceBar = Tuple[float, float]  # (birth, death)


def chroma_vector(pcs: PitchClassSet) -> np.ndarray:
    """Convert pitch class set to 12-dim binary vector.
    
    Args:
        pcs: A frozenset of integers in {0, ..., 11}
    
    Returns:
        12-dimensional numpy array with 1s at pitch class positions
    """
    vec = np.zeros(12, dtype=float)
    for p in pcs:
        vec[p % 12] = 1.0
    return vec


def fourier_profile(pcs: PitchClassSet) -> np.ndarray:
    """Compute the DFT magnitude profile of a pitch class set.
    
    The k-th coefficient is |sum_{p in S} exp(2*pi*i*p*k/12)|.
    This captures the harmonic spectrum: coefficient 5 measures
    "fifthness", coefficient 1 measures chromaticity, etc.
    
    Args:
        pcs: A pitch class set
    
    Returns:
        12-dimensional real array of DFT magnitudes
    """
    magnitudes = np.zeros(12)
    for k in range(12):
        z = sum(np.exp(2j * np.pi * p * k / 12) for p in pcs)
        magnitudes[k] = abs(z)
    return magnitudes


# ============================================================
# Distance Functions
# ============================================================

def hamming_distance(A: PitchClassSet, B: PitchClassSet) -> int:
    """Hamming distance: |A △ B|."""
    return len(A.symmetric_difference(B))


def fourier_distance(A: PitchClassSet, B: PitchClassSet) -> float:
    """L2 distance between Fourier profiles."""
    fa, fb = fourier_profile(A), fourier_profile(B)
    return float(np.linalg.norm(fa - fb))


def voice_leading_distance(A: PitchClassSet, B: PitchClassSet) -> int:
    """Minimal voice leading distance (sum of semitone movements).
    
    Computed as the minimum over all bijections from A to B of
    the sum of |a - b| mod 12 (taking the shorter path around
    the circle).
    """
    from itertools import permutations
    if len(A) != len(B):
        return hamming_distance(A, B) * 6  # fallback
    
    a_list = sorted(A)
    min_dist = float('inf')
    for perm in permutations(sorted(B)):
        dist = sum(min((a - b) % 12, (b - a) % 12)
                   for a, b in zip(a_list, perm))
        min_dist = min(min_dist, dist)
    return int(min_dist)


# ============================================================
# Chord Generation
# ============================================================

def major_triad(root: PitchClass) -> PitchClassSet:
    """Major triad: {root, root+4, root+7}."""
    return frozenset({root % 12, (root + 4) % 12, (root + 7) % 12})


def minor_triad(root: PitchClass) -> PitchClassSet:
    """Minor triad: {root, root+3, root+7}."""
    return frozenset({root % 12, (root + 3) % 12, (root + 7) % 12})


def diminished_triad(root: PitchClass) -> PitchClassSet:
    """Diminished triad: {root, root+3, root+6}."""
    return frozenset({root % 12, (root + 3) % 12, (root + 6) % 12})


def dominant_seventh(root: PitchClass) -> PitchClassSet:
    """Dominant 7th: {root, root+4, root+7, root+10}."""
    return frozenset({root % 12, (root + 4) % 12, (root + 7) % 12, (root + 10) % 12})


def circle_of_fifths(start: PitchClass = 0, n: int = 12) -> List[PitchClass]:
    """Generate circle of fifths sequence."""
    return [(start + 7 * k) % 12 for k in range(n)]


# ============================================================
# Union-Find for Persistence
# ============================================================

class UnionFind:
    """Weighted union-find with path compression."""
    
    def __init__(self, n: int):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.size = [1] * n
        self.n_components = n
    
    def find(self, x: int) -> int:
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x
    
    def union(self, x: int, y: int) -> Optional[int]:
        """Union x and y. Returns the root that was absorbed, or None."""
        px, py = self.find(x), self.find(y)
        if px == py:
            return None
        self.n_components -= 1
        if self.rank[px] < self.rank[py]:
            self.parent[px] = py
            self.size[py] += self.size[px]
            return px
        elif self.rank[px] > self.rank[py]:
            self.parent[py] = px
            self.size[px] += self.size[py]
            return py
        else:
            self.parent[py] = px
            self.size[px] += self.size[py]
            self.rank[px] += 1
            return py


# ============================================================
# Persistent Homology
# ============================================================

def compute_distance_matrix(
    chords: List[PitchClassSet],
    metric: str = "hamming"
) -> np.ndarray:
    """Compute pairwise distance matrix.
    
    Args:
        chords: List of pitch class sets
        metric: "hamming", "fourier", or "voice_leading"
    
    Returns:
        n x n distance matrix
    """
    dist_fn = {
        "hamming": hamming_distance,
        "fourier": fourier_distance,
        "voice_leading": voice_leading_distance,
    }[metric]
    
    n = len(chords)
    D = np.zeros((n, n))
    for i in range(n):
        for j in range(i + 1, n):
            d = dist_fn(chords[i], chords[j])
            D[i, j] = d
            D[j, i] = d
    return D


def persistent_homology_h0(
    chords: List[PitchClassSet],
    metric: str = "hamming"
) -> List[PersistenceBar]:
    """Compute H_0 persistence diagram.
    
    Algorithm: Process edges in order of increasing weight.
    Each edge that merges two components kills the younger one.
    
    Returns:
        List of (birth, death) pairs. One bar has death = infinity
        (represented as max_distance + 1).
    """
    n = len(chords)
    D = compute_distance_matrix(chords, metric)
    
    # Sort edges by weight
    edges: List[Tuple[float, int, int]] = []
    for i in range(n):
        for j in range(i + 1, n):
            edges.append((D[i, j], i, j))
    edges.sort()
    
    uf = UnionFind(n)
    bars: List[PersistenceBar] = []
    
    for weight, i, j in edges:
        absorbed = uf.union(i, j)
        if absorbed is not None:
            bars.append((0.0, float(weight)))
    
    # The surviving component
    max_d = edges[-1][0] if edges else 0
    bars.append((0.0, float(max_d + 1)))
    
    return bars


def persistent_homology_h1(
    chords: List[PitchClassSet],
    metric: str = "hamming"
) -> List[PersistenceBar]:
    """Compute approximate H_1 persistence diagram.
    
    Uses incremental Betti number tracking: β₁ = |E| - |V| + components.
    When β₁ increases, a cycle is born. When β₁ decreases (due to
    triangle fills), a cycle dies.
    
    Returns:
        List of (birth, death) persistence bars.
    """
    n = len(chords)
    D = compute_distance_matrix(chords, metric)
    
    # Get unique filtration values
    thresholds = sorted(set(
        D[i, j] for i in range(n) for j in range(i + 1, n)
    ))
    
    bars: List[List[Optional[float]]] = []
    prev_beta1 = 0
    
    for eps in thresholds:
        edges = [(i, j) for i in range(n) for j in range(i + 1, n) if D[i, j] <= eps]
        
        # β₁ = |E| - |V| + components
        uf = UnionFind(n)
        for i, j in edges:
            uf.union(i, j)
        beta1 = len(edges) - n + uf.n_components
        
        if beta1 > prev_beta1:
            for _ in range(beta1 - prev_beta1):
                bars.append([eps, None])
        elif beta1 < prev_beta1:
            open_bars = [b for b in bars if b[1] is None]
            for _ in range(prev_beta1 - beta1):
                if open_bars:
                    open_bars.pop(0)[1] = eps
        
        prev_beta1 = beta1
    
    # Close remaining
    max_d = thresholds[-1] if thresholds else 0
    for bar in bars:
        if bar[1] is None:
            bar[1] = max_d
    
    return [(b, d) for b, d in bars]


def harmonic_persistence_signature(
    chords: List[PitchClassSet],
    metric: str = "hamming"
) -> Dict[str, float]:
    """Compute a numerical signature of harmonic complexity.
    
    Returns:
        Dictionary with:
        - max_h1_persistence: longest H_1 bar
        - mean_h1_persistence: average H_1 bar length
        - n_h1_bars: number of H_1 bars
        - harmonic_diameter: max pairwise distance
    """
    h1 = persistent_homology_h1(chords, metric)
    D = compute_distance_matrix(chords, metric)
    
    persistences = [d - b for b, d in h1] if h1 else [0]
    
    return {
        "max_h1_persistence": max(persistences),
        "mean_h1_persistence": float(np.mean(persistences)),
        "n_h1_bars": len(h1),
        "harmonic_diameter": float(D.max()),
    }


# ============================================================
# Musical Style Analysis
# ============================================================

def bach_chorale_model(n_chords: int = 16) -> List[PitchClassSet]:
    """Generate a Bach-style chorale progression.
    
    Uses circle-of-fifths motion with mixture of major/minor triads
    and occasional dominant 7ths. This models Bach's systematic
    harmonic motion through related keys.
    """
    chords = []
    root = 0  # Start on C
    for i in range(n_chords):
        if i % 4 == 3:
            chords.append(dominant_seventh(root))
        elif i % 3 == 1:
            chords.append(minor_triad(root))
        else:
            chords.append(major_triad(root))
        root = (root + 7) % 12  # Move by fifth
    return chords


def pop_progression_model(n_chords: int = 16) -> List[PitchClassSet]:
    """Generate a pop-style progression.
    
    Uses the I-V-vi-IV pattern with limited harmonic vocabulary.
    """
    pattern = [0, 7, 9, 5]  # I V vi IV
    chords = []
    for i in range(n_chords):
        root = pattern[i % len(pattern)]
        if i % len(pattern) == 2:
            chords.append(minor_triad(root))
        else:
            chords.append(major_triad(root))
    return chords


def atonal_model(n_chords: int = 16) -> List[PitchClassSet]:
    """Generate an atonal progression (random pitch class sets)."""
    rng = np.random.RandomState(42)
    chords = []
    for _ in range(n_chords):
        size = rng.randint(3, 7)
        chord = frozenset(rng.choice(12, size, replace=False))
        chords.append(chord)
    return chords


if __name__ == "__main__":
    print("Harmonic Persistence Signatures")
    print("=" * 50)
    
    for name, gen in [("Bach", bach_chorale_model),
                       ("Pop", pop_progression_model),
                       ("Atonal", atonal_model)]:
        chords = gen(16)
        sig = harmonic_persistence_signature(chords)
        print(f"\n{name}:")
        for k, v in sig.items():
            print(f"  {k}: {v:.3f}")
