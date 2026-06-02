#!/usr/bin/env python3
"""
Persistent Homology of Musical Harmony: Demo
=============================================

Demonstrates the topological analysis of chord progressions, computing
persistent homology of pitch class set point clouds and comparing
Bach-style circle-of-fifths progressions with random chord sequences.
"""

import numpy as np
from itertools import combinations

# ============================================================
# Pitch Class Representations
# ============================================================

def pitch_class_to_chroma(pcs: set) -> np.ndarray:
    """Convert a pitch class set to a 12-dimensional binary chroma vector."""
    vec = np.zeros(12)
    for p in pcs:
        vec[p % 12] = 1.0
    return vec

def pitch_class_to_fourier(pcs: set) -> np.ndarray:
    """Map a pitch class set to a point in C^6 via the DFT.
    
    Each pitch class k maps to e^{2πik/12}. The chord maps to
    the sum of its pitch class vectors, giving a point that
    captures the harmonic spectrum of the chord.
    """
    result = np.zeros(12, dtype=complex)
    for freq in range(12):
        for p in pcs:
            result[freq] += np.exp(2j * np.pi * p * freq / 12)
    return np.abs(result)

def major_triad(root: int) -> set:
    """Major triad: {root, root+4, root+7} mod 12."""
    return {root % 12, (root + 4) % 12, (root + 7) % 12}

def minor_triad(root: int) -> set:
    """Minor triad: {root, root+3, root+7} mod 12."""
    return {root % 12, (root + 3) % 12, (root + 7) % 12}

# ============================================================
# Circle of Fifths
# ============================================================

def circle_of_fifths(start: int = 0, n: int = 12) -> list:
    """Generate the circle of fifths: start, start+7, start+14, ... mod 12."""
    return [(start + 7 * k) % 12 for k in range(n)]

def fifths_progression(start: int = 0, n: int = 12) -> list:
    """Major triad progression following the circle of fifths."""
    roots = circle_of_fifths(start, n)
    return [major_triad(r) for r in roots]

# ============================================================
# Hamming Distance & Vietoris-Rips
# ============================================================

def hamming_distance(A: set, B: set) -> int:
    """Hamming distance between two pitch class sets."""
    return len(A.symmetric_difference(B))

def distance_matrix(chords: list) -> np.ndarray:
    """Compute the pairwise Hamming distance matrix."""
    n = len(chords)
    D = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(i + 1, n):
            d = hamming_distance(chords[i], chords[j])
            D[i, j] = d
            D[j, i] = d
    return D

def rips_edges(chords: list, epsilon: int) -> list:
    """Edges in the Vietoris-Rips graph at scale epsilon."""
    edges = []
    for i in range(len(chords)):
        for j in range(i + 1, len(chords)):
            if hamming_distance(chords[i], chords[j]) <= epsilon:
                edges.append((i, j))
    return edges

def count_components(n: int, edges: list) -> int:
    """Count connected components using union-find."""
    parent = list(range(n))
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    def union(x, y):
        px, py = find(x), find(y)
        if px != py:
            parent[px] = py
    for i, j in edges:
        union(i, j)
    return len(set(find(i) for i in range(n)))

def count_cycles(n: int, edges: list) -> int:
    """Count independent cycles: |E| - |V| + components."""
    components = count_components(n, edges)
    return len(edges) - n + components

# ============================================================
# Persistence Computation (simplified H_0 and H_1)
# ============================================================

def compute_h0_persistence(chords: list) -> list:
    """Compute H_0 persistence bars (connected components)."""
    n = len(chords)
    D = distance_matrix(chords)
    
    # Get all unique distances as filtration values
    distances = sorted(set(D[i, j] for i in range(n) for j in range(i + 1, n)))
    
    # Track component births and deaths using union-find
    parent = list(range(n))
    rank = [0] * n
    birth = [0] * n  # All components born at scale 0
    bars = []
    
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    
    def union(x, y, death_time):
        px, py = find(x), find(y)
        if px == py:
            return
        # Younger component dies (higher index = younger by convention)
        if rank[px] < rank[py]:
            parent[px] = py
            bars.append((birth[px], death_time))
        elif rank[px] > rank[py]:
            parent[py] = px
            bars.append((birth[py], death_time))
        else:
            parent[py] = px
            bars.append((birth[py], death_time))
            rank[px] += 1
    
    for d in distances:
        for i in range(n):
            for j in range(i + 1, n):
                if D[i, j] == d:
                    union(i, j, d)
    
    # Add the surviving component (infinite death)
    max_d = max(distances) if distances else 0
    bars.append((0, max_d + 1))  # The one surviving component
    
    return bars

def compute_h1_persistence(chords: list) -> list:
    """Compute approximate H_1 persistence bars.
    
    Uses the simplified algorithm: track when cycles form (birth)
    and when they become boundaries (death) in the Rips filtration.
    """
    n = len(chords)
    D = distance_matrix(chords)
    distances = sorted(set(D[i, j] for i in range(n) for j in range(i + 1, n)))
    
    h1_bars = []
    prev_beta1 = 0
    prev_edges = []
    
    for d in distances:
        edges = [(i, j) for i in range(n) for j in range(i + 1, n) if D[i, j] <= d]
        beta1 = count_cycles(n, edges)
        
        if beta1 > prev_beta1:
            # New cycle born
            for _ in range(beta1 - prev_beta1):
                h1_bars.append([d, None])
        elif beta1 < prev_beta1:
            # Cycles died (became boundaries via triangle fills)
            open_bars = [b for b in h1_bars if b[1] is None]
            for _ in range(prev_beta1 - beta1):
                if open_bars:
                    bar = open_bars.pop(0)
                    bar[1] = d
        
        prev_beta1 = beta1
        prev_edges = edges
    
    # Close remaining bars
    max_d = max(distances) if distances else 0
    for bar in h1_bars:
        if bar[1] is None:
            bar[1] = max_d
    
    return [(b, d) for b, d in h1_bars]

# ============================================================
# Musical Analysis
# ============================================================

def random_chord_progression(n: int = 12, chord_size: int = 3) -> list:
    """Generate a random chord progression."""
    chords = []
    for _ in range(n):
        notes = set(np.random.choice(12, chord_size, replace=False))
        chords.append(notes)
    return chords

def bach_style_progression() -> list:
    """A Bach-style chorale progression following circle of fifths."""
    # I - IV - vii° - iii - vi - ii - V - I in C major
    # Using circle of fifths relationships
    return [
        major_triad(0),   # C major: C E G
        major_triad(5),   # F major: F A C  
        minor_triad(11),  # B diminished approx: B D F
        minor_triad(4),   # E minor: E G B
        minor_triad(9),   # A minor: A C E
        minor_triad(2),   # D minor: D F A
        major_triad(7),   # G major: G B D
        major_triad(0),   # C major: C E G
    ]

# ============================================================
# Main Demo
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("PERSISTENT HOMOLOGY OF MUSICAL HARMONY")
    print("=" * 60)
    
    # 1. Circle of Fifths
    print("\n--- Circle of Fifths ---")
    note_names = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
    cof = circle_of_fifths(0)
    print("Circle of fifths:", " → ".join(note_names[p] for p in cof))
    print(f"All 12 pitch classes visited: {len(set(cof)) == 12}")
    
    # 2. Bach-style progression analysis
    print("\n--- Bach-style Chorale Progression ---")
    bach = bach_style_progression()
    for i, chord in enumerate(bach):
        names = sorted([note_names[p] for p in chord])
        print(f"  Chord {i+1}: {{{', '.join(names)}}}")
    
    D_bach = distance_matrix(bach)
    print(f"\nDistance matrix (Hamming):")
    print(D_bach)
    
    # 3. Persistence analysis
    print("\n--- H_0 Persistence (Connected Components) ---")
    h0_bach = compute_h0_persistence(bach)
    print(f"Bach H_0 bars: {h0_bach}")
    max_h0 = max(d - b for b, d in h0_bach)
    print(f"Maximum H_0 persistence: {max_h0}")
    
    print("\n--- H_1 Persistence (Cycles) ---")
    h1_bach = compute_h1_persistence(bach)
    print(f"Bach H_1 bars: {h1_bach}")
    if h1_bach:
        max_h1 = max(d - b for b, d in h1_bach)
        print(f"Maximum H_1 persistence: {max_h1}")
    
    # 4. Comparison with random
    print("\n--- Random Progression Comparison ---")
    np.random.seed(42)
    n_trials = 20
    bach_h1_max = []
    random_h1_max = []
    
    for trial in range(n_trials):
        # Bach-like (circle of fifths)
        start = np.random.randint(12)
        bach_prog = fifths_progression(start, 8)
        h1 = compute_h1_persistence(bach_prog)
        bach_h1_max.append(max((d - b for b, d in h1), default=0))
        
        # Random
        rand_prog = random_chord_progression(8)
        h1 = compute_h1_persistence(rand_prog)
        random_h1_max.append(max((d - b for b, d in h1), default=0))
    
    print(f"Bach-style avg max H_1 persistence: {np.mean(bach_h1_max):.2f}")
    print(f"Random avg max H_1 persistence: {np.mean(random_h1_max):.2f}")
    
    # 5. Fourier analysis
    print("\n--- Fourier Analysis ---")
    c_major = major_triad(0)
    f_major = major_triad(5)
    print(f"C major DFT magnitudes: {pitch_class_to_fourier(c_major).round(2)}")
    print(f"F major DFT magnitudes: {pitch_class_to_fourier(f_major).round(2)}")
    
    # 6. Filtration visualization
    print("\n--- Rips Filtration ---")
    bach = bach_style_progression()
    for eps in range(7):
        edges = rips_edges(bach, eps)
        comps = count_components(len(bach), edges)
        cycles = count_cycles(len(bach), edges)
        print(f"  ε={eps}: {len(edges)} edges, {comps} components, β₁={cycles}")
    
    print("\n✓ Demo complete")


#!/usr/bin/env python3
"""
Visualization: Persistence Barcodes for Musical Styles
======================================================

Compares persistent homology barcodes of Bach-style, pop, and atonal
chord progressions side by side.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch


def hamming_distance(A, B):
    return len(A.symmetric_difference(B))


def major_triad(root):
    return frozenset({root % 12, (root + 4) % 12, (root + 7) % 12})


def minor_triad(root):
    return frozenset({root % 12, (root + 3) % 12, (root + 7) % 12})


def dominant_seventh(root):
    return frozenset({root % 12, (root + 4) % 12, (root + 7) % 12, (root + 10) % 12})


def compute_h1_bars(chords):
    n = len(chords)
    D = np.zeros((n, n))
    for i in range(n):
        for j in range(i + 1, n):
            d = hamming_distance(chords[i], chords[j])
            D[i, j] = d
            D[j, i] = d

    thresholds = sorted(set(D[i, j] for i in range(n) for j in range(i + 1, n) if D[i,j] > 0))

    def count_components(edges_list):
        parent = list(range(n))
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        def union(x, y):
            px, py = find(x), find(y)
            if px != py:
                parent[px] = py
        for i, j in edges_list:
            union(i, j)
        return len(set(find(x) for x in range(n)))

    bars = []
    prev_beta1 = 0
    for eps in thresholds:
        edges = [(i, j) for i in range(n) for j in range(i + 1, n) if D[i, j] <= eps]
        comps = count_components(edges)
        beta1 = len(edges) - n + comps
        if beta1 > prev_beta1:
            for _ in range(beta1 - prev_beta1):
                bars.append([eps, None])
        elif beta1 < prev_beta1:
            open_bars = [b for b in bars if b[1] is None]
            for _ in range(prev_beta1 - beta1):
                if open_bars:
                    open_bars.pop(0)[1] = eps
        prev_beta1 = beta1

    max_d = thresholds[-1] if thresholds else 0
    for bar in bars:
        if bar[1] is None:
            bar[1] = max_d
    return [(b, d) for b, d in bars]


def bach_chords(n=16):
    chords = []
    root = 0
    for i in range(n):
        if i % 4 == 3:
            chords.append(dominant_seventh(root))
        elif i % 3 == 1:
            chords.append(minor_triad(root))
        else:
            chords.append(major_triad(root))
        root = (root + 7) % 12
    return chords


def pop_chords(n=16):
    pattern = [0, 7, 9, 5]
    chords = []
    for i in range(n):
        root = pattern[i % len(pattern)]
        if i % len(pattern) == 2:
            chords.append(minor_triad(root))
        else:
            chords.append(major_triad(root))
    return chords


def atonal_chords(n=16):
    rng = np.random.RandomState(42)
    chords = []
    for _ in range(n):
        size = rng.randint(3, 7)
        chord = frozenset(rng.choice(12, size, replace=False))
        chords.append(chord)
    return chords


fig, axes = plt.subplots(1, 3, figsize=(15, 5), sharey=True)

styles = [
    ("Bach (Circle of Fifths)", bach_chords, '#2E86AB'),
    ("Pop (I-V-vi-IV)", pop_chords, '#A23B72'),
    ("Atonal (Random)", atonal_chords, '#F18F01'),
]

for ax, (title, gen, color) in zip(axes, styles):
    bars = compute_h1_bars(gen(16))
    bars_sorted = sorted(bars, key=lambda x: x[1] - x[0], reverse=True)

    for i, (b, d) in enumerate(bars_sorted):
        ax.barh(i, d - b, left=b, height=0.7, color=color, alpha=0.8, edgecolor='black', linewidth=0.5)

    ax.set_xlabel('Scale (Hamming distance)', fontsize=12)
    ax.set_title(title, fontsize=13, fontweight='bold')
    ax.set_xlim(0, 10)
    if not bars_sorted:
        ax.text(5, 0.5, 'No H₁ bars', ha='center', va='center', fontsize=14, color='gray')

axes[0].set_ylabel('H₁ Persistence Bars', fontsize=12)
fig.suptitle('Persistent Homology of Musical Chord Progressions', fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('persistence_barcodes.png', dpi=150, bbox_inches='tight')
print("Saved persistence_barcodes.png")
