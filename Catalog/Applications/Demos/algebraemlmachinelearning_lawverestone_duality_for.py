#!/usr/bin/env python3
"""
Applications of Lawvere-Stone Attention Duality
================================================

Real-world applications demonstrating:
1. Attention weight compression for transformers
2. Model identifiability / equivalence checking
3. Tropical optimization via observable kernels
4. Belief state reconstruction from partial observations
"""

import numpy as np
from typing import List, Tuple, Dict
from algorithms import (
    LawvereMetricSpace, compute_observable_kernel,
    build_minimal_frame, compress_frame,
    find_kernel_equivalence_classes, generate_random_lawvere_metric,
    tropical_shortest_path
)


def softmax(x: np.ndarray, temperature: float = 1.0) -> np.ndarray:
    """Softmax function with temperature."""
    e_x = np.exp(x / temperature)
    return e_x / e_x.sum(axis=-1, keepdims=True)


# ============================================================================
# APPLICATION 1: Attention Weight Compression
# ============================================================================

def app_attention_compression():
    """
    Application: Compressing attention weight matrices.

    Given a trained attention weight matrix, find the minimal frame that
    preserves the observable kernel. This corresponds to removing redundant
    attention heads / tokens.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 1: Attention Weight Compression")
    print("=" * 70)

    np.random.seed(42)

    # Simulate a 10-token attention weight matrix
    n_tokens = 10
    # Generate random attention scores and tropicalize
    raw_scores = np.random.randn(n_tokens, n_tokens) * 2
    # Convert to integer distances (larger = more distant = less attention)
    distances = np.abs(raw_scores).astype(int)
    np.fill_diagonal(distances, 0)

    # Enforce triangle inequality to make it a valid Lawvere metric
    M = generate_random_lawvere_metric(n_tokens, max_val=8)

    print(f"\nOriginal attention frame: {n_tokens} tokens")
    print(f"Weight matrix (Lawvere distances):")
    print(M.dist)

    # Compute observable kernel
    K = compute_observable_kernel(M, list(range(n_tokens)))

    # Find compression
    compressed_K, reps, ratio = compress_frame(K)
    classes = find_kernel_equivalence_classes(K)

    print(f"\nKernel equivalence classes:")
    for key, members in classes.items():
        if len(members) > 1:
            print(f"  Equivalent tokens: {members}")

    print(f"\nCompression result:")
    print(f"  Original tokens: {n_tokens}")
    print(f"  Minimal tokens:  {len(reps)}")
    print(f"  Representatives: {reps}")
    print(f"  Compression ratio: {ratio:.2%}")
    print(f"\nCompressed kernel:")
    print(compressed_K)

    # Verify the compressed kernel preserves all pairwise relationships
    for i, ri in enumerate(reps):
        for j, rj in enumerate(reps):
            assert compressed_K[i, j] == K[ri, rj], \
                f"Kernel not preserved at ({ri},{rj})"
    print("✓ Compressed kernel preserves all pairwise relationships")


# ============================================================================
# APPLICATION 2: Model Identifiability
# ============================================================================

def app_model_identifiability():
    """
    Application: Determining when two attention models are semantically equivalent.

    Two models are equivalent iff they have the same minimal frame
    (same observable kernel up to permutation).
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Model Identifiability")
    print("=" * 70)

    # Model 1: 5 tokens (ultrametric)
    M1 = LawvereMetricSpace(n=5, dist=np.array([
        [0, 2, 3, 2, 3],
        [2, 0, 3, 0, 3],
        [3, 3, 0, 3, 0],
        [2, 0, 3, 0, 3],  # Token 3 = Token 1
        [3, 3, 0, 3, 0],  # Token 4 = Token 2
    ]))
    assert M1.verify()

    # Model 2: 3 tokens (already minimal, ultrametric)
    M2 = LawvereMetricSpace(n=3, dist=np.array([
        [0, 2, 3],
        [2, 0, 3],
        [3, 3, 0],
    ]))
    assert M2.verify()

    # Compute minimal frames
    K1 = compute_observable_kernel(M1, list(range(5)))
    comp1, reps1, _ = compress_frame(K1)

    K2 = compute_observable_kernel(M2, list(range(3)))
    comp2, reps2, _ = compress_frame(K2)

    print(f"\nModel 1: {M1.n} tokens → minimal frame {comp1.shape[0]} tokens")
    print(f"  Representatives: {reps1}")
    print(f"  Minimal kernel:\n{comp1}")

    print(f"\nModel 2: {M2.n} tokens → minimal frame {comp2.shape[0]} tokens")
    print(f"  Representatives: {reps2}")
    print(f"  Minimal kernel:\n{comp2}")

    # Check equivalence: same minimal kernel?
    equivalent = np.array_equal(comp1, comp2)
    print(f"\nModels semantically equivalent: {equivalent}")
    if equivalent:
        print("  → Both models collapse to the same minimal attention frame")
        print("  → They are observationally indistinguishable")


# ============================================================================
# APPLICATION 3: Tropical Optimization
# ============================================================================

def app_tropical_optimization():
    """
    Application: Tropical shortest paths as observable kernels.

    The observable kernel of a weighted graph corresponds to the
    tropical shortest-path matrix. Compression identifies redundant nodes.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Tropical Shortest Path Optimization")
    print("=" * 70)

    # A weighted directed graph (6 nodes)
    n = 6
    INF = 99
    raw_weights = np.array([
        [0,   3,  INF,  7,  INF, INF],
        [3,   0,   2,  INF, INF, INF],
        [INF, 2,   0,   1,   4,  INF],
        [7,  INF,  1,   0,  INF,  5],
        [INF,INF,  4,  INF,  0,   2],
        [INF,INF, INF,  5,   2,   0],
    ])

    # Compute tropical shortest paths
    sp = tropical_shortest_path(raw_weights)

    print(f"\nOriginal weight matrix ({n} nodes):")
    print(raw_weights)

    print(f"\nTropical shortest-path matrix (observable kernel):")
    print(sp)

    # Check if this is a valid Lawvere metric
    M = LawvereMetricSpace(n=n, dist=sp)
    valid = M.verify()
    print(f"\nShortest-path matrix is valid Lawvere metric: {valid}")

    if valid:
        K = compute_observable_kernel(M, list(range(n)))
        _, reps, ratio = compress_frame(K)
        print(f"Compressible to {len(reps)} nodes (ratio: {ratio:.2%})")
        print(f"Representative nodes: {reps}")


# ============================================================================
# APPLICATION 4: Belief State Reconstruction
# ============================================================================

def app_belief_reconstruction():
    """
    Application: Reconstructing belief states from partial observations.

    Given observations of some generators, reconstruct the full belief state
    using the observable kernel and the duality theorem.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Belief State Reconstruction from Observations")
    print("=" * 70)

    # A 6-element belief semimodule (ultrametric)
    M = LawvereMetricSpace(n=6, dist=np.array([
        [0, 2, 3, 3, 4, 4],
        [2, 0, 3, 3, 4, 4],
        [3, 3, 0, 2, 4, 4],
        [3, 3, 2, 0, 4, 4],
        [4, 4, 4, 4, 0, 2],
        [4, 4, 4, 4, 2, 0],
    ]))
    assert M.verify()

    # Choose 3 generators
    generators = [0, 2, 5]
    K = compute_observable_kernel(M, generators)

    print(f"\nFull metric space: {M.n} elements")
    print(f"Generators: {generators}")
    print(f"\nObservable kernel (3×3):")
    print(K)

    # The observable kernel captures the "essential structure"
    # Any element x is characterized by its distances to generators
    print(f"\nDistance profiles of all elements to generators:")
    for x in range(M.n):
        profile = [M.dist[x, g] for g in generators]
        print(f"  Element {x}: d(x, {generators}) = {profile}")

    # Check which elements are distinguishable by generators
    profiles = {}
    for x in range(M.n):
        key = tuple(M.dist[x, g] for g in generators)
        if key not in profiles:
            profiles[key] = []
        profiles[key].append(x)

    print(f"\nDistinguishability by generators:")
    for profile, elements in profiles.items():
        status = "unique" if len(elements) == 1 else "INDISTINGUISHABLE"
        print(f"  Profile {profile}: elements {elements} [{status}]")

    n_distinguishable = sum(1 for v in profiles.values() if len(v) == 1)
    print(f"\n{n_distinguishable}/{M.n} elements uniquely determined by generators")
    print(f"Generators {'separate' if n_distinguishable == M.n else 'do NOT separate'} all points")


if __name__ == "__main__":
    print("Applications of Lawvere-Stone Attention Duality")
    print("=" * 70)

    app_attention_compression()
    app_model_identifiability()
    app_tropical_optimization()
    app_belief_reconstruction()

    print("\n" + "=" * 70)
    print("All applications completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Demonstration of Lawvere-Stone Attention Duality
================================================

Concrete numerical examples showing:
1. Belief semimodule construction
2. Observable kernel computation
3. Minimal frame construction and roundtrip verification
4. Separation checking
5. Certified compression
"""

import numpy as np
from typing import List, Tuple, Dict, Optional


class CompleteLattice:
    """A finite complete lattice represented as {0, 1, ..., n-1} with max as sup."""

    def __init__(self, n: int):
        self.n = n
        self.bot = 0
        self.top = n - 1

    def sup(self, a: int, b: int) -> int:
        return max(a, b)

    def le(self, a: int, b: int) -> bool:
        return a <= b


class BeliefSemimodule:
    """
    A finite belief semimodule over a complete lattice S.

    Components:
    - carrier: list of elements (indices 0..m-1)
    - closure: cl[i] = closure of element i
    - dist: dist[i][j] = Lawvere pseudo-metric from i to j
    """

    def __init__(self, S: CompleteLattice, m: int,
                 closure: List[int], dist: List[List[int]]):
        self.S = S
        self.m = m
        self.closure = closure
        self.dist = dist
        self._verify()

    def _verify(self):
        """Verify the belief semimodule axioms."""
        # Closure idempotence
        for x in range(self.m):
            assert self.closure[self.closure[x]] == self.closure[x], \
                f"Closure not idempotent at {x}"

        # Distance reflexivity
        for x in range(self.m):
            assert self.dist[x][x] == self.S.bot, \
                f"Distance not reflexive at {x}"

        # Triangle inequality
        for x in range(self.m):
            for y in range(self.m):
                for z in range(self.m):
                    assert self.S.le(self.dist[x][z],
                                     self.S.sup(self.dist[x][y], self.dist[y][z])), \
                        f"Triangle inequality fails at ({x},{y},{z})"

        # Closure nonexpansiveness
        for x in range(self.m):
            for y in range(self.m):
                assert self.S.le(self.dist[self.closure[x]][self.closure[y]],
                                 self.dist[x][y]), \
                    f"Closure not nonexpansive at ({x},{y})"

        print(f"✓ Belief semimodule verified: {self.m} elements over lattice of size {self.S.n}")


class AttentionObservable:
    """An attention observable: closure-stable, nonexpansive function M → S."""

    def __init__(self, B: BeliefSemimodule, values: List[int]):
        self.B = B
        self.values = values
        self._verify()

    def _verify(self):
        # Closure stability
        for x in range(self.B.m):
            assert self.values[self.B.closure[x]] == self.values[x], \
                f"Observable not closure-stable at {x}"

        # Lipschitz/nonexpansiveness
        for x in range(self.B.m):
            for y in range(self.B.m):
                assert self.B.S.le(self.values[y],
                                   self.B.S.sup(self.values[x], self.B.dist[x][y])), \
                    f"Observable not nonexpansive at ({x},{y})"

    def __call__(self, x: int) -> int:
        return self.values[x]


class AttentionFrame:
    """A finite attention frame: tokens with Lawvere-compatible weight kernel."""

    def __init__(self, S: CompleteLattice, n: int, weights: List[List[int]]):
        self.S = S
        self.n = n
        self.weights = weights
        self._verify()

    def _verify(self):
        for t in range(self.n):
            assert self.weights[t][t] == self.S.bot, \
                f"Weight not reflexive at {t}"

        for a in range(self.n):
            for b in range(self.n):
                for c in range(self.n):
                    assert self.S.le(self.weights[a][c],
                                     self.S.sup(self.weights[a][b], self.weights[b][c])), \
                        f"Triangle inequality fails at ({a},{b},{c})"

        print(f"✓ Attention frame verified: {self.n} tokens over lattice of size {self.S.n}")


def observable_kernel(B: BeliefSemimodule, generators: List[int]) -> List[List[int]]:
    """Compute the observable kernel K(i,j) = d(e_i, e_j)."""
    n = len(generators)
    K = [[B.dist[generators[i]][generators[j]] for j in range(n)] for i in range(n)]
    return K


def minimal_frame(B: BeliefSemimodule, generators: List[int]) -> AttentionFrame:
    """Construct the minimal attention frame from generators."""
    K = observable_kernel(B, generators)
    return AttentionFrame(B.S, len(generators), K)


def belief_of_frame(F: AttentionFrame) -> BeliefSemimodule:
    """Construct a belief semimodule from an attention frame."""
    return BeliefSemimodule(F.S, F.n, list(range(F.n)), F.weights)


def check_separation(B: BeliefSemimodule, observables: List[AttentionObservable]) -> bool:
    """Check whether observables separate points of B."""
    for x in range(B.m):
        for y in range(x + 1, B.m):
            separated = False
            for phi in observables:
                if phi(x) != phi(y):
                    separated = True
                    break
            if not separated:
                return False
    return True


def roundtrip_belief_frame_belief(B: BeliefSemimodule,
                                   generators: List[int]) -> bool:
    """Verify the roundtrip Belief → Frame → Belief preserves the metric."""
    F = minimal_frame(B, generators)
    B_prime = belief_of_frame(F)
    for i in range(len(generators)):
        for j in range(len(generators)):
            if B_prime.dist[i][j] != B.dist[generators[i]][generators[j]]:
                return False
    return True


def roundtrip_frame_belief_frame(F: AttentionFrame) -> bool:
    """Verify the roundtrip Frame → Belief → Frame recovers the kernel."""
    B = belief_of_frame(F)
    generators = list(range(F.n))
    K = observable_kernel(B, generators)
    for i in range(F.n):
        for j in range(F.n):
            if K[i][j] != F.weights[i][j]:
                return False
    return True


# ============================================================================
# DEMONSTRATIONS
# ============================================================================

def demo_1_basic_duality():
    """Demo 1: Basic 4-element belief semimodule with tropical metric."""
    print("\n" + "=" * 70)
    print("DEMO 1: Basic Belief Semimodule and Minimal Frame")
    print("=" * 70)

    S = CompleteLattice(6)  # {0, 1, 2, 3, 4, 5}

    # 4-element belief semimodule with identity closure
    # Distance matrix satisfying sup-triangle inequality: d(x,z) ≤ max(d(x,y),d(y,z))
    # This is an ultrametric (tree metric)
    dist = [
        [0, 2, 3, 3],
        [2, 0, 3, 3],
        [3, 3, 0, 2],
        [3, 3, 2, 0],
    ]
    closure = [0, 1, 2, 3]  # identity closure

    B = BeliefSemimodule(S, 4, closure, dist)

    # Use all elements as generators
    generators = [0, 1, 2, 3]
    K = observable_kernel(B, generators)

    print(f"\nObservable kernel K:")
    for row in K:
        print(f"  {row}")

    F = minimal_frame(B, generators)
    print(f"\nMinimal frame constructed with {F.n} tokens")
    print(f"Weights = K (by construction)")

    # Roundtrip verification
    rt1 = roundtrip_belief_frame_belief(B, generators)
    rt2 = roundtrip_frame_belief_frame(F)
    print(f"\n✓ Roundtrip Belief→Frame→Belief correct: {rt1}")
    print(f"✓ Roundtrip Frame→Belief→Frame correct: {rt2}")


def demo_2_compression():
    """Demo 2: Compression via kernel equivalence."""
    print("\n" + "=" * 70)
    print("DEMO 2: Certified Compression via Kernel Equivalence")
    print("=" * 70)

    S = CompleteLattice(10)

    # 6-element ultrametric where elements 1 and 4 are metrically equivalent
    dist = [
        [0, 3, 4, 5, 3, 3],
        [3, 0, 4, 5, 0, 3],  # row 1
        [4, 4, 0, 5, 4, 4],
        [5, 5, 5, 0, 5, 5],
        [3, 0, 4, 5, 0, 3],  # row 4 = row 1 (equivalent to 1)
        [3, 3, 4, 5, 3, 0],
    ]
    closure = [0, 1, 2, 3, 4, 5]

    B = BeliefSemimodule(S, 6, closure, dist)

    # All generators
    all_gens = [0, 1, 2, 3, 4, 5]
    K_full = observable_kernel(B, all_gens)

    # Identify equivalent generators (same kernel row)
    equivalence_classes = {}
    for i in all_gens:
        key = tuple(K_full[i])
        if key not in equivalence_classes:
            equivalence_classes[key] = []
        equivalence_classes[key].append(i)

    print(f"\nOriginal: {len(all_gens)} generators")
    print(f"Equivalence classes:")
    for key, members in equivalence_classes.items():
        print(f"  {members} (kernel row: {list(key)})")

    # Minimal generators: one per equivalence class
    min_gens = [members[0] for members in equivalence_classes.values()]
    K_min = observable_kernel(B, min_gens)

    print(f"\nMinimal generators: {min_gens}")
    print(f"Compressed frame size: {len(min_gens)} (from {len(all_gens)})")
    print(f"Compression ratio: {len(min_gens)/len(all_gens):.2f}")

    F_min = minimal_frame(B, min_gens)
    print(f"\nMinimal frame kernel:")
    for row in K_min:
        print(f"  {row}")


def demo_3_separation():
    """Demo 3: Separation by observables."""
    print("\n" + "=" * 70)
    print("DEMO 3: Separation by Attention Observables")
    print("=" * 70)

    S = CompleteLattice(8)

    # Simple 3-element ultrametric semimodule
    dist = [
        [0, 2, 3],
        [2, 0, 3],
        [3, 3, 0],
    ]
    closure = [0, 1, 2]

    B = BeliefSemimodule(S, 3, closure, dist)

    # Construct observables from distance columns (contravariant Yoneda)
    # φ_u(x) = d(u, x) is Lipschitz by triangle inequality
    observables = []
    for u in range(B.m):
        values = [B.dist[u][x] for x in range(B.m)]
        try:
            obs = AttentionObservable(B, values)
            observables.append(obs)
            print(f"  Observable φ_{u}: {values} ✓")
        except AssertionError as e:
            print(f"  Observable φ_{u}: {values} ✗ ({e})")

    separated = check_separation(B, observables)
    print(f"\nPoints separated by observables: {separated}")

    # Show evaluation profiles
    print("\nEvaluation profiles η(x):")
    for x in range(B.m):
        profile = [phi(x) for phi in observables]
        print(f"  η({x}) = {profile}")

    # Check injectivity
    profiles = [tuple(phi(x) for phi in observables) for x in range(B.m)]
    injective = len(set(profiles)) == len(profiles)
    print(f"\nEvaluation map injective: {injective}")


def demo_4_frame_separation():
    """Demo 4: Frame with separating weights yields separated belief semimodule."""
    print("\n" + "=" * 70)
    print("DEMO 4: Frame Separation → Belief Separation")
    print("=" * 70)

    S = CompleteLattice(10)

    # 4-token frame with separating weights (ultrametric)
    weights = [
        [0, 3, 4, 4],
        [3, 0, 4, 4],
        [4, 4, 0, 3],
        [4, 4, 3, 0],
    ]

    F = AttentionFrame(S, 4, weights)

    # Check weight separation
    weight_separated = True
    for s in range(F.n):
        for t in range(s + 1, F.n):
            if all(F.weights[s][u] == F.weights[t][u] for u in range(F.n)):
                weight_separated = False
                print(f"  Tokens {s} and {t} not separated by outgoing weights")
                break

    print(f"\nFrame has separating weights: {weight_separated}")

    # Construct belief semimodule
    B = belief_of_frame(F)

    # Construct observables from weight columns
    obs_list = []
    for u in range(F.n):
        values = [F.weights[u][x] for x in range(F.n)]
        try:
            obs = AttentionObservable(B, values)
            obs_list.append(obs)
        except AssertionError:
            pass

    if obs_list:
        separated = check_separation(B, obs_list)
        print(f"Belief semimodule separated: {separated}")
    else:
        print("No valid observables found (asymmetric weights)")

    # Roundtrip
    rt = roundtrip_frame_belief_frame(F)
    print(f"Roundtrip Frame→Belief→Frame correct: {rt}")


def demo_5_tropical_integers():
    """Demo 5: Tropical metric on integers."""
    print("\n" + "=" * 70)
    print("DEMO 5: Tropical Metric Space on Integers")
    print("=" * 70)

    n = 5
    S = CompleteLattice(2 * n + 1)  # Enough room for distances

    # Points: 0, 1, 2, 3, 4 with ultrametric from binary tree
    # Pairs in same leaf-pair get distance 1, same subtree gets 2, etc.
    # Tree: ((0,1),(2,3)),4 -> d(0,1)=1, d(2,3)=1, d(0,2)=2, d(0,4)=3, etc.
    dist = [
        [0, 1, 2, 2, 3],
        [1, 0, 2, 2, 3],
        [2, 2, 0, 1, 3],
        [2, 2, 1, 0, 3],
        [3, 3, 3, 3, 0],
    ]
    closure = list(range(n))

    B = BeliefSemimodule(S, n, closure, dist)

    generators = list(range(n))
    K = observable_kernel(B, generators)

    print(f"\n{n}-point integer metric space")
    print(f"Distance matrix = Observable kernel:")
    for row in K:
        print(f"  {row}")

    F = minimal_frame(B, generators)

    # Check that the metric is rigid (no compression possible)
    equivalence_classes = {}
    for i in generators:
        key = tuple(K[i])
        if key not in equivalence_classes:
            equivalence_classes[key] = []
        equivalence_classes[key].append(i)

    print(f"\nDistinct kernel rows: {len(equivalence_classes)}")
    print(f"Metric rigidity: {'rigid (no compression)' if len(equivalence_classes) == n else 'compressible'}")

    rt1 = roundtrip_belief_frame_belief(B, generators)
    rt2 = roundtrip_frame_belief_frame(F)
    print(f"Roundtrip Belief→Frame→Belief: {rt1}")
    print(f"Roundtrip Frame→Belief→Frame: {rt2}")


if __name__ == "__main__":
    print("Lawvere-Stone Attention Duality: Demonstrations")
    print("=" * 70)

    demo_1_basic_duality()
    demo_2_compression()
    demo_3_separation()
    demo_4_frame_separation()
    demo_5_tropical_integers()

    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualizations for Lawvere-Stone Attention Duality
===================================================

Generates publication-quality figures illustrating:
1. Observable kernel heatmap
2. Compression comparison
3. Duality roundtrip diagram
4. Tropical shortest paths
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from algorithms import (
    LawvereMetricSpace, compute_observable_kernel,
    compress_frame, find_kernel_equivalence_classes,
    generate_random_lawvere_metric, tropical_shortest_path
)
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def viz_observable_kernel():
    """Visualize the observable kernel as a heatmap."""
    np.random.seed(42)

    M = LawvereMetricSpace(n=8, dist=np.array([
        [0, 2, 4, 6, 2, 4, 6, 8],
        [2, 0, 2, 4, 0, 2, 4, 6],
        [4, 2, 0, 2, 2, 0, 2, 4],
        [6, 4, 2, 0, 4, 2, 0, 2],
        [2, 0, 2, 4, 0, 2, 4, 6],
        [4, 2, 0, 2, 2, 0, 2, 4],
        [6, 4, 2, 0, 4, 2, 0, 2],
        [8, 6, 4, 2, 6, 4, 2, 0],
    ]))

    K = compute_observable_kernel(M, list(range(8)))

    fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))

    # Full kernel
    im1 = axes[0].imshow(K, cmap='YlOrRd', aspect='equal')
    axes[0].set_title('Observable Kernel (Full)', fontsize=14, fontweight='bold')
    axes[0].set_xlabel('Generator j')
    axes[0].set_ylabel('Generator i')
    for i in range(K.shape[0]):
        for j in range(K.shape[1]):
            axes[0].text(j, i, str(K[i, j]), ha='center', va='center',
                        fontsize=10, color='black' if K[i, j] < 5 else 'white')
    plt.colorbar(im1, ax=axes[0], label='Distance d(eᵢ, eⱼ)')

    # Compressed kernel
    comp_K, reps, ratio = compress_frame(K)
    im2 = axes[1].imshow(comp_K, cmap='YlOrRd', aspect='equal')
    axes[1].set_title(f'Minimal Frame Kernel ({len(reps)} tokens)', fontsize=14, fontweight='bold')
    axes[1].set_xlabel('Token j')
    axes[1].set_ylabel('Token i')
    axes[1].set_xticks(range(len(reps)))
    axes[1].set_yticks(range(len(reps)))
    axes[1].set_xticklabels([str(r) for r in reps])
    axes[1].set_yticklabels([str(r) for r in reps])
    for i in range(comp_K.shape[0]):
        for j in range(comp_K.shape[1]):
            axes[1].text(j, i, str(comp_K[i, j]), ha='center', va='center',
                        fontsize=11, color='black' if comp_K[i, j] < 5 else 'white')
    plt.colorbar(im2, ax=axes[1], label='Weight w(i, j)')

    fig.suptitle('Lawvere–Stone Attention Duality: Observable Kernel & Compression',
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()

    fig.savefig('/workspace/request-project/viz_kernel.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_compression_scaling():
    """Visualize compression ratio vs. problem size."""
    np.random.seed(123)

    sizes = [4, 6, 8, 10, 12, 15, 20]
    ratios = []
    min_sizes = []

    for n in sizes:
        # Generate multiple random instances and average
        instance_ratios = []
        instance_mins = []
        for _ in range(20):
            M = generate_random_lawvere_metric(n, max_val=8)
            K = compute_observable_kernel(M, list(range(n)))
            _, reps, ratio = compress_frame(K)
            instance_ratios.append(ratio)
            instance_mins.append(len(reps))
        ratios.append(np.mean(instance_ratios))
        min_sizes.append(np.mean(instance_mins))

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    # Compression ratio
    ax1.plot(sizes, ratios, 'o-', color='#2196F3', linewidth=2, markersize=8)
    ax1.fill_between(sizes, ratios, 1.0, alpha=0.15, color='#2196F3')
    ax1.set_xlabel('Original Frame Size', fontsize=12)
    ax1.set_ylabel('Compression Ratio', fontsize=12)
    ax1.set_title('Compression Ratio vs. Frame Size', fontsize=14, fontweight='bold')
    ax1.set_ylim(0, 1.1)
    ax1.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5, label='No compression')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Minimal frame size
    ax2.plot(sizes, sizes, '--', color='gray', alpha=0.5, label='No compression (n=n)')
    ax2.plot(sizes, min_sizes, 'o-', color='#FF5722', linewidth=2, markersize=8,
             label='Avg. minimal frame')
    ax2.fill_between(sizes, min_sizes, sizes, alpha=0.15, color='#FF5722')
    ax2.set_xlabel('Original Frame Size', fontsize=12)
    ax2.set_ylabel('Minimal Frame Size', fontsize=12)
    ax2.set_title('Certified Minimum vs. Original Size', fontsize=14, fontweight='bold')
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Certified Compression: Random Lawvere Metric Spaces',
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()

    fig.savefig('/workspace/request-project/viz_compression.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_duality_diagram():
    """Visualize the duality roundtrip as a commutative diagram."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    ax.set_xlim(-1, 11)
    ax.set_ylim(-1, 7)
    ax.set_aspect('equal')
    ax.axis('off')

    # Boxes
    box_style = dict(boxstyle='round,pad=0.6', facecolor='#E3F2FD', edgecolor='#1565C0', linewidth=2)
    frame_style = dict(boxstyle='round,pad=0.6', facecolor='#FFF3E0', edgecolor='#E65100', linewidth=2)
    result_style = dict(boxstyle='round,pad=0.6', facecolor='#E8F5E9', edgecolor='#2E7D32', linewidth=2)

    # Nodes
    ax.text(2, 5.5, 'Belief\nSemimodule\n(M, cl, d)', ha='center', va='center',
            fontsize=13, fontweight='bold', bbox=box_style)
    ax.text(8, 5.5, 'Attention\nFrame\n(F, w)', ha='center', va='center',
            fontsize=13, fontweight='bold', bbox=frame_style)
    ax.text(2, 1.5, 'Belief\nSemimodule\n(M\', cl\', d\')', ha='center', va='center',
            fontsize=13, fontweight='bold', bbox=box_style)
    ax.text(8, 1.5, 'Attention\nFrame\n(F\', w\')', ha='center', va='center',
            fontsize=13, fontweight='bold', bbox=frame_style)
    ax.text(5, 3.5, '≅', ha='center', va='center', fontsize=28,
            fontweight='bold', color='#2E7D32')

    # Arrows
    arrow_style = dict(arrowstyle='->', color='#1565C0', linewidth=2.5)
    frame_arrow = dict(arrowstyle='->', color='#E65100', linewidth=2.5)

    # Top: M → F (Spec)
    ax.annotate('', xy=(6.5, 5.5), xytext=(3.5, 5.5),
                arrowprops=arrow_style)
    ax.text(5, 6.0, 'Spec(M, e)', ha='center', va='center',
            fontsize=11, fontstyle='italic', color='#1565C0')

    # Right: F → M' (Belief of Frame)
    ax.annotate('', xy=(8, 2.8), xytext=(8, 4.2),
                arrowprops=frame_arrow)
    ax.text(9.2, 3.5, 'B(F)', ha='center', va='center',
            fontsize=11, fontstyle='italic', color='#E65100')

    # Bottom: M' → F' (Spec again)
    ax.annotate('', xy=(6.5, 1.5), xytext=(3.5, 1.5),
                arrowprops=arrow_style)
    ax.text(5, 0.9, 'Spec(M\', id)', ha='center', va='center',
            fontsize=11, fontstyle='italic', color='#1565C0')

    # Left: M → M' (roundtrip = iso)
    ax.annotate('', xy=(2, 2.8), xytext=(2, 4.2),
                arrowprops=dict(arrowstyle='->', color='#2E7D32', linewidth=2.5, linestyle='--'))
    ax.text(0.5, 3.5, 'Roundtrip\n≅ on gens', ha='center', va='center',
            fontsize=10, fontstyle='italic', color='#2E7D32')

    ax.set_title('Lawvere–Stone Duality: Roundtrip Diagram',
                 fontsize=16, fontweight='bold', pad=20)

    fig.savefig('/workspace/request-project/viz_duality.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_tropical_paths():
    """Visualize tropical shortest paths on a graph."""
    n = 6
    INF = 99
    raw = np.array([
        [0,   3,  INF,  7,  INF, INF],
        [3,   0,   2,  INF, INF, INF],
        [INF, 2,   0,   1,   4,  INF],
        [7,  INF,  1,   0,  INF,  5],
        [INF,INF,  4,  INF,  0,   2],
        [INF,INF, INF,  5,   2,   0],
    ])

    sp = tropical_shortest_path(raw)

    fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))

    # Original graph weights
    mask = raw >= INF
    display_raw = raw.copy().astype(float)
    display_raw[mask] = np.nan

    im1 = axes[0].imshow(np.where(mask, 0, raw), cmap='YlOrRd', aspect='equal')
    axes[0].set_title('Original Graph Weights', fontsize=14, fontweight='bold')
    axes[0].set_xlabel('Node j')
    axes[0].set_ylabel('Node i')
    for i in range(n):
        for j in range(n):
            val = '∞' if mask[i, j] else str(raw[i, j])
            axes[0].text(j, i, val, ha='center', va='center',
                        fontsize=11, color='black')

    # Shortest path distances
    im2 = axes[1].imshow(sp, cmap='YlOrRd', aspect='equal')
    axes[1].set_title('Tropical Shortest Paths\n(Observable Kernel)', fontsize=14, fontweight='bold')
    axes[1].set_xlabel('Node j')
    axes[1].set_ylabel('Node i')
    for i in range(n):
        for j in range(n):
            axes[1].text(j, i, str(sp[i, j]), ha='center', va='center',
                        fontsize=11, color='black' if sp[i, j] < 5 else 'white')
    plt.colorbar(im2, ax=axes[1], label='Shortest path distance')

    fig.suptitle('Tropical Shortest Paths as Observable Kernels',
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()

    fig.savefig('/workspace/request-project/viz_tropical.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")

    b64_kernel = viz_observable_kernel()
    print("✓ Observable kernel heatmap saved to viz_kernel.png")

    b64_comp = viz_compression_scaling()
    print("✓ Compression scaling chart saved to viz_compression.png")

    b64_duality = viz_duality_diagram()
    print("✓ Duality roundtrip diagram saved to viz_duality.png")

    b64_tropical = viz_tropical_paths()
    print("✓ Tropical shortest paths saved to viz_tropical.png")

    print("\nAll visualizations generated.")
