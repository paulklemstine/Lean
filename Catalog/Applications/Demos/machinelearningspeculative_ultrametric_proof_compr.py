"""
Operadic Ultrametric Compression: Algorithms

Implements the core algorithms from the operadic ultrametric compression theory:
1. Observer distillation computation
2. Equivalence class extraction (compression quotient)
3. Certificate map construction
4. Finite observer family generation from operadic generators
"""

from typing import List, Callable, Dict, Set, Tuple, Any
from dataclasses import dataclass
import math


@dataclass
class ObserverSystemConfig:
    """Configuration for a closed observer system.

    Attributes:
        state_type: description of the state type
        n_contexts: number of context maps
        compression_type: description of the compression method
    """
    state_type: str
    n_contexts: int
    compression_type: str


def compute_observer_distillation(
    d: Callable[[Any, Any], float],
    C: Callable[[Any], Any],
    contexts: List[Callable[[Any], Any]],
    x: Any,
    y: Any,
) -> float:
    """
    Compute the observer distillation δ_O(x, y) = sup_i d(C(ctx_i(x)), C(ctx_i(y))).

    This is the central algorithm: it computes the maximum distance between
    compressed images of x and y across all operadic observer contexts.

    Time complexity: O(n · T_d · T_C · T_ctx) where n = len(contexts),
    T_d = cost of distance computation, T_C = cost of compression,
    T_ctx = cost of context application.

    Space complexity: O(1) additional space (streaming maximum).

    Args:
        d: Ultrametric distance function
        C: Compression operator
        contexts: List of context maps
        x: First proof state
        y: Second proof state

    Returns:
        The observer distillation distance δ_O(x, y)
    """
    if not contexts:
        raise ValueError("Context family must be nonempty")

    max_score = 0.0
    for ctx in contexts:
        score = d(C(ctx(x)), C(ctx(y)))
        max_score = max(max_score, score)
    return max_score


def extract_equivalence_classes(
    states: List[Any],
    d: Callable[[Any, Any], float],
    C: Callable[[Any], Any],
    contexts: List[Callable[[Any], Any]],
    tolerance: float = 1e-10,
) -> List[List[int]]:
    """
    Extract the compression quotient P/~_O by computing equivalence classes.

    Algorithm: Union-Find with observer distillation as the equivalence test.
    Two states are equivalent iff δ_O(x, y) = 0 (within tolerance).

    Time complexity: O(n² · k · T) where n = len(states), k = len(contexts),
    T = cost per distance/compression evaluation.

    Space complexity: O(n²) for the distillation matrix.

    Args:
        states: List of proof states
        d: Ultrametric distance function
        C: Compression operator
        contexts: List of context maps
        tolerance: Numerical tolerance for zero comparison

    Returns:
        List of equivalence classes, each a list of state indices
    """
    n = len(states)
    parent = list(range(n))

    def find(i: int) -> int:
        while parent[i] != i:
            parent[i] = parent[parent[i]]  # path compression
            i = parent[i]
        return i

    def union(i: int, j: int):
        ri, rj = find(i), find(j)
        if ri != rj:
            parent[ri] = rj

    for i in range(n):
        for j in range(i + 1, n):
            dist = compute_observer_distillation(d, C, contexts, states[i], states[j])
            if dist < tolerance:
                union(i, j)

    # Group by root
    classes: Dict[int, List[int]] = {}
    for i in range(n):
        root = find(i)
        if root not in classes:
            classes[root] = []
        classes[root].append(i)

    return list(classes.values())


def compute_certificate_map(
    states: List[Any],
    reference: Any,
    d: Callable[[Any, Any], float],
    C: Callable[[Any], Any],
    contexts: List[Callable[[Any], Any]],
) -> List[float]:
    """
    Compute the certificate map cert(x) = δ_O(p₀, x) for all states.

    The certificate is constant on equivalence classes and nonexpansive.
    It provides a tropical-style valuation that factors through the
    compression quotient.

    Time complexity: O(n · k · T) where n = len(states), k = len(contexts).

    Args:
        states: List of proof states
        reference: Reference point p₀
        d: Ultrametric distance function
        C: Compression operator
        contexts: List of context maps

    Returns:
        List of certificate values, one per state
    """
    return [
        compute_observer_distillation(d, C, contexts, reference, s)
        for s in states
    ]


def generate_context_family(
    generators: List[Callable[[Any], Any]],
    max_depth: int,
    include_identity: bool = True,
) -> List[Callable[[Any], Any]]:
    """
    Generate all operadic contexts (words in generators) up to given depth.

    This implements the finite observer extraction: from k generators,
    produce all compositions of length ≤ max_depth.

    The number of generated contexts is:
        sum_{i=0}^{max_depth} k^i = (k^{max_depth+1} - 1) / (k - 1) for k > 1

    Time complexity: O(k^{max_depth}) for context enumeration.

    Args:
        generators: List of generator functions
        max_depth: Maximum composition depth
        include_identity: Whether to include the identity context

    Returns:
        List of context functions
    """
    contexts = []
    if include_identity:
        contexts.append(lambda x: x)

    current_level = [lambda x: x]  # start with identity

    for depth in range(1, max_depth + 1):
        next_level = []
        for g in generators:
            for w in current_level:
                # Capture g and w in closure
                composed = (lambda g, w: lambda x: g(w(x)))(g, w)
                next_level.append(composed)
        contexts.extend(next_level)
        current_level = next_level

    return contexts


def verify_ultrametric_property(
    states: List[Any],
    d: Callable[[Any, Any], float],
    C: Callable[[Any], Any],
    contexts: List[Callable[[Any], Any]],
    tolerance: float = 1e-10,
) -> Tuple[bool, int]:
    """
    Verify the ultrametric inequality for the observer distillation.

    Checks: δ_O(x, z) ≤ max(δ_O(x, y), δ_O(y, z)) for all triples.

    Time complexity: O(n³ · k · T) where n = len(states), k = len(contexts).

    Args:
        states: List of proof states
        d: Ultrametric distance function
        C: Compression operator
        contexts: List of context maps
        tolerance: Numerical tolerance

    Returns:
        Tuple of (is_ultrametric, n_violations)
    """
    n = len(states)
    # Precompute distillation matrix
    dist = [[0.0] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            dist[i][j] = compute_observer_distillation(d, C, contexts, states[i], states[j])

    violations = 0
    for i in range(n):
        for j in range(n):
            for k in range(n):
                if dist[i][k] > max(dist[i][j], dist[j][k]) + tolerance:
                    violations += 1

    return violations == 0, violations


def verify_congruence_property(
    states: List[Any],
    d: Callable[[Any, Any], float],
    C: Callable[[Any], Any],
    contexts: List[Callable[[Any], Any]],
    tolerance: float = 1e-10,
) -> Tuple[bool, int]:
    """
    Verify the operadic congruence: if x ~_O y then ctx_i(x) ~_O ctx_i(y).

    This checks the flagship structural theorem computationally.

    Time complexity: O(n² · k² · T).

    Args:
        states: List of proof states
        d: Ultrametric distance function
        C: Compression operator
        contexts: List of context maps
        tolerance: Numerical tolerance

    Returns:
        Tuple of (is_congruence, n_violations)
    """
    n = len(states)
    violations = 0

    for i in range(n):
        for j in range(i + 1, n):
            if compute_observer_distillation(d, C, contexts, states[i], states[j]) < tolerance:
                # States i, j are equivalent; check congruence
                for ctx in contexts:
                    ctx_i = ctx(states[i])
                    ctx_j = ctx(states[j])
                    if compute_observer_distillation(d, C, contexts, ctx_i, ctx_j) >= tolerance:
                        violations += 1

    return violations == 0, violations


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    # Define ultrametric tree distance on binary sequences
    def tree_distance(x: list, y: list) -> float:
        k = 0
        for a, b in zip(x, y):
            if a != b:
                break
            k += 1
        if k == min(len(x), len(y)) and len(x) == len(y):
            return 0.0
        return 2.0 ** (-k)

    # Compression: truncate to first 2 bits
    def compress(x: list) -> list:
        return x[:2] + [0] * (len(x) - 2)

    # Generators
    def shift(x: list) -> list:
        return [x[-1]] + x[:-1]

    def flip(x: list) -> list:
        return [1 - x[0]] + x[1:]

    # Generate states
    states = [[int(b) for b in format(i, '04b')] for i in range(16)]

    # Generate contexts
    contexts = generate_context_family([shift, flip], max_depth=2)
    print(f"Generated {len(contexts)} contexts from 2 generators at depth ≤ 2")

    # Extract equivalence classes
    classes = extract_equivalence_classes(states, tree_distance, compress, contexts)
    print(f"Found {len(classes)} equivalence classes from {len(states)} states")
    for i, cls in enumerate(classes):
        print(f"  Class {i}: {[format(j, '04b') for j in cls]}")

    # Verify properties
    is_ultra, n_viol = verify_ultrametric_property(states, tree_distance, compress, contexts)
    print(f"Ultrametric: {is_ultra} ({n_viol} violations)")

    is_congr, n_viol = verify_congruence_property(states, tree_distance, compress, contexts)
    print(f"Congruence: {is_congr} ({n_viol} violations)")


"""
Operadic Ultrametric Compression: Applications

Demonstrates real-world applications of the operadic ultrametric compression theory:
1. Proof-state clustering for theorem prover optimization
2. Compression-aware proof replay
3. Neural network weight pruning via ultrametric certificates
"""

import math
from typing import List, Tuple, Dict, Any
from dataclasses import dataclass


# ============================================================
# Application 1: Proof-State Clustering
# ============================================================

@dataclass
class ProofState:
    """A simplified proof state representation."""
    goals: Tuple[str, ...]      # remaining goals
    hypotheses: Tuple[str, ...]  # available hypotheses
    depth: int                   # search depth

    def to_vector(self) -> list:
        """Convert to a numerical vector for distance computation."""
        # Hash-based embedding for demonstration
        goal_hash = hash(self.goals) % 256
        hyp_hash = hash(self.hypotheses) % 256
        return [
            (goal_hash >> i) & 1 for i in range(8)
        ] + [
            (hyp_hash >> i) & 1 for i in range(8)
        ] + [
            (self.depth >> i) & 1 for i in range(4)
        ]


def ultrametric_hamming(x: list, y: list) -> float:
    """Ultrametric-like distance based on first differing position."""
    for i, (a, b) in enumerate(zip(x, y)):
        if a != b:
            return 2.0 ** (-i)
    if len(x) != len(y):
        return 2.0 ** (-min(len(x), len(y)))
    return 0.0


def cluster_proof_states(
    states: List[ProofState],
    compression_depth: int = 4,
) -> Dict[int, List[int]]:
    """
    Cluster proof states using ultrametric observer distillation.

    This demonstrates how the compression quotient P/~_O can be used
    to identify proof states that are semantically equivalent under
    all operadic observers.

    Args:
        states: List of proof states
        compression_depth: Number of leading bits to retain in compression

    Returns:
        Dictionary mapping cluster_id to list of state indices
    """
    vectors = [s.to_vector() for s in states]

    def compress(v):
        return v[:compression_depth] + [0] * (len(v) - compression_depth)

    def identity(v):
        return list(v)

    def reverse_bits(v):
        return list(reversed(v))

    contexts = [identity, reverse_bits]

    # Compute distillation
    n = len(states)
    clusters: Dict[int, List[int]] = {}
    parent = list(range(n))

    def find(i):
        while parent[i] != i:
            parent[i] = parent[parent[i]]
            i = parent[i]
        return i

    def union(i, j):
        ri, rj = find(i), find(j)
        if ri != rj:
            parent[ri] = rj

    for i in range(n):
        for j in range(i + 1, n):
            score = max(
                ultrametric_hamming(compress(ctx(vectors[i])),
                                    compress(ctx(vectors[j])))
                for ctx in contexts
            )
            if score < 1e-10:
                union(i, j)

    for i in range(n):
        root = find(i)
        if root not in clusters:
            clusters[root] = []
        clusters[root].append(i)

    return clusters


# ============================================================
# Application 2: Compression-Aware Proof Replay
# ============================================================

@dataclass
class ProofTrace:
    """A proof trace: sequence of tactic applications."""
    tactics: Tuple[str, ...]
    success: bool
    depth: int

    def compressed(self, max_depth: int) -> 'ProofTrace':
        """Compress by truncating to max_depth tactics."""
        return ProofTrace(
            tactics=self.tactics[:max_depth],
            success=self.success,
            depth=min(self.depth, max_depth),
        )


def proof_trace_distance(t1: ProofTrace, t2: ProofTrace) -> float:
    """Ultrametric distance on proof traces: 2^{-k} where k is the
    length of the longest common prefix of tactic sequences."""
    k = 0
    for a, b in zip(t1.tactics, t2.tactics):
        if a != b:
            break
        k += 1
    if k == min(len(t1.tactics), len(t2.tactics)) and \
       len(t1.tactics) == len(t2.tactics):
        return 0.0
    return 2.0 ** (-k)


def build_replay_index(
    traces: List[ProofTrace],
    compression_depth: int = 3,
) -> Dict[int, List[int]]:
    """
    Build a compression-aware replay index for proof traces.

    Clusters traces by observer distillation, so that traces in the
    same cluster are interchangeable for replay purposes.

    This is the practical application of the compression quotient:
    instead of storing all traces, store one representative per class.

    Args:
        traces: List of proof traces
        compression_depth: Depth for compression

    Returns:
        Dictionary mapping cluster_id to list of trace indices
    """
    def compress(t: ProofTrace) -> ProofTrace:
        return t.compressed(compression_depth)

    n = len(traces)
    parent = list(range(n))

    def find(i):
        while parent[i] != i:
            parent[i] = parent[parent[i]]
            i = parent[i]
        return i

    def union(i, j):
        ri, rj = find(i), find(j)
        if ri != rj:
            parent[ri] = rj

    for i in range(n):
        for j in range(i + 1, n):
            d = proof_trace_distance(compress(traces[i]), compress(traces[j]))
            if d < 1e-10:
                union(i, j)

    clusters: Dict[int, List[int]] = {}
    for i in range(n):
        root = find(i)
        if root not in clusters:
            clusters[root] = []
        clusters[root].append(i)

    return clusters


# ============================================================
# Application 3: Ultrametric Network Pruning
# ============================================================

def ultrametric_pruning_bound(
    individual_errors: List[float],
) -> Tuple[float, float, float]:
    """
    Compute pruning error bounds in ultrametric vs Archimedean settings.

    Key result: In an ultrametric space, the total pruning error is
    max(individual_errors), not sum(individual_errors).
    This gives an O(n) improvement factor.

    Args:
        individual_errors: List of per-weight pruning errors

    Returns:
        Tuple of (ultrametric_bound, archimedean_bound, improvement_factor)
    """
    ultra_bound = max(individual_errors)
    archi_bound = sum(individual_errors)
    improvement = archi_bound / ultra_bound if ultra_bound > 0 else float('inf')
    return ultra_bound, archi_bound, improvement


# ============================================================
# Demo
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("APPLICATION 1: Proof-State Clustering")
    print("=" * 60)

    states = [
        ProofState(goals=("∀ x, P x",), hypotheses=("h : Q",), depth=0),
        ProofState(goals=("∀ x, P x",), hypotheses=("h : Q", "h2 : R"), depth=0),
        ProofState(goals=("∃ x, P x",), hypotheses=("h : Q",), depth=1),
        ProofState(goals=("P a",), hypotheses=("h : Q", "ha : a ∈ S"), depth=2),
        ProofState(goals=("∀ x, P x",), hypotheses=("h : Q",), depth=0),
        ProofState(goals=("P a",), hypotheses=("h : Q", "ha : a ∈ S"), depth=2),
    ]

    clusters = cluster_proof_states(states, compression_depth=4)
    print(f"\n{len(states)} proof states → {len(clusters)} clusters")
    for cid, members in clusters.items():
        print(f"  Cluster: {[str(states[i].goals[0][:20]) for i in members]}")

    print("\n" + "=" * 60)
    print("APPLICATION 2: Compression-Aware Proof Replay")
    print("=" * 60)

    traces = [
        ProofTrace(tactics=("intro", "apply", "exact"), success=True, depth=3),
        ProofTrace(tactics=("intro", "apply", "simp"), success=True, depth=3),
        ProofTrace(tactics=("intro", "apply", "exact"), success=True, depth=3),
        ProofTrace(tactics=("intro", "cases", "exact"), success=True, depth=3),
        ProofTrace(tactics=("intro", "apply", "ring"), success=False, depth=3),
        ProofTrace(tactics=("rewrite", "apply", "exact"), success=True, depth=3),
    ]

    index = build_replay_index(traces, compression_depth=2)
    print(f"\n{len(traces)} traces → {len(index)} replay groups")
    for gid, members in index.items():
        print(f"  Group: {[traces[i].tactics for i in members]}")

    # Compression ratio
    total_tactics = sum(len(t.tactics) for t in traces)
    compressed_tactics = sum(
        len(traces[members[0]].tactics) for members in index.values()
    )
    print(f"\n  Storage: {total_tactics} tactics → {compressed_tactics} "
          f"(one per group), ratio = {total_tactics/compressed_tactics:.1f}x")

    print("\n" + "=" * 60)
    print("APPLICATION 3: Ultrametric Pruning Advantage")
    print("=" * 60)

    errors = [0.01, 0.02, 0.005, 0.015, 0.03, 0.01, 0.025, 0.02,
              0.01, 0.005, 0.02, 0.015, 0.01, 0.03, 0.025, 0.02]

    ultra, archi, improvement = ultrametric_pruning_bound(errors)
    print(f"\n  {len(errors)} weights pruned")
    print(f"  Archimedean bound (sum):  {archi:.4f}")
    print(f"  Ultrametric bound (max):  {ultra:.4f}")
    print(f"  Improvement factor:       {improvement:.1f}x")
    print(f"\n  The ultrametric bound is {improvement:.0f}× tighter because")
    print(f"  errors combine via max, not sum — no cancellation needed.")


"""
Operadic Ultrametric Compression: Demonstration

This script demonstrates the key mathematical constructions from the
operadic ultrametric compression theory with concrete numerical examples.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import List, Callable, Tuple
import json

# ============================================================
# 1. Ultrametric Pseudo-Distance
# ============================================================

def p_adic_valuation(n: int, p: int = 2) -> int:
    """Compute the p-adic valuation of integer n."""
    if n == 0:
        return float('inf')
    v = 0
    while n % p == 0:
        n //= p
        v += 1
    return v

def p_adic_distance(x: int, y: int, p: int = 2) -> float:
    """Compute p-adic distance |x - y|_p."""
    if x == y:
        return 0.0
    return p ** (-p_adic_valuation(abs(x - y), p))

def ultrametric_tree_distance(x: List[int], y: List[int]) -> float:
    """
    Ultrametric distance on sequences: 2^{-k} where k is the length
    of the longest common prefix.
    """
    k = 0
    for a, b in zip(x, y):
        if a != b:
            break
        k += 1
    if k == min(len(x), len(y)) and len(x) == len(y):
        return 0.0
    return 2.0 ** (-k)

def verify_ultrametric(d: Callable, points: list) -> bool:
    """Verify the ultrametric inequality for all triples."""
    for x in points:
        for y in points:
            for z in points:
                if d(x, z) > max(d(x, y), d(y, z)) + 1e-10:
                    return False
    return True

# Demo 1: p-adic ultrametric
print("=" * 60)
print("DEMO 1: p-adic Ultrametric Distance")
print("=" * 60)
points = list(range(1, 17))
print(f"\nPoints: {points}")
print(f"\n2-adic distances (selected pairs):")
for i in range(0, len(points), 3):
    for j in range(i+1, min(i+4, len(points))):
        d = p_adic_distance(points[i], points[j], 2)
        print(f"  |{points[i]} - {points[j]}|_2 = {d:.4f}")

print(f"\nUltrametric inequality verified: {verify_ultrametric(lambda x, y: p_adic_distance(x, y, 2), points)}")

# ============================================================
# 2. Observer Distillation Construction
# ============================================================

class ClosedObserverSystem:
    """
    A closed observer system on R^n with ultrametric-like distance.

    Attributes:
        d: distance function
        C: compression operator
        contexts: list of context maps (endomorphisms)
    """
    def __init__(self, d, C, contexts):
        self.d = d
        self.C = C
        self.contexts = contexts

    def ctx_observer_score(self, i: int, x, y) -> float:
        """d(C(ctx_i(x)), C(ctx_i(y)))"""
        return self.d(self.C(self.contexts[i](x)), self.C(self.contexts[i](y)))

    def observer_distillation(self, x, y) -> float:
        """sup_i d(C(ctx_i(x)), C(ctx_i(y)))"""
        return max(self.ctx_observer_score(i, x, y)
                   for i in range(len(self.contexts)))

    def observer_kernel(self, x, y, tol=1e-10) -> bool:
        """x ~_O y iff delta_O(x, y) = 0"""
        return self.observer_distillation(x, y) < tol

    def certificate_map(self, p0, x) -> float:
        """cert(x) = delta_O(p0, x)"""
        return self.observer_distillation(p0, x)


# Demo 2: Concrete observer system on integer sequences
print("\n" + "=" * 60)
print("DEMO 2: Observer Distillation on Proof-State Sequences")
print("=" * 60)

# Proof states as binary sequences of length 4
proof_states = [
    [0, 0, 0, 0], [0, 0, 0, 1], [0, 0, 1, 0], [0, 0, 1, 1],
    [0, 1, 0, 0], [0, 1, 0, 1], [0, 1, 1, 0], [0, 1, 1, 1],
    [1, 0, 0, 0], [1, 0, 0, 1], [1, 0, 1, 0], [1, 0, 1, 1],
]

# Ultrametric tree distance
d = ultrametric_tree_distance

# Compression: truncate to first 2 bits
def compress(x):
    return x[:2] + [0] * (len(x) - 2)

# Context generators: cyclic shifts and bit flips
def shift_right(x):
    return [x[-1]] + x[:-1]

def flip_first(x):
    return [1 - x[0]] + x[1:]

identity = lambda x: list(x)

contexts = [identity, shift_right, flip_first]

system = ClosedObserverSystem(d, compress, contexts)

# Compute distillation matrix
n_states = len(proof_states)
distillation_matrix = np.zeros((n_states, n_states))
for i in range(n_states):
    for j in range(n_states):
        distillation_matrix[i, j] = system.observer_distillation(
            proof_states[i], proof_states[j])

print("\nProof states (binary sequences):")
for i, s in enumerate(proof_states):
    print(f"  P{i}: {s}")

print("\nObserver distillation matrix (δ_O):")
print("     ", "  ".join(f"P{i:d}" for i in range(n_states)))
for i in range(n_states):
    row = " ".join(f"{distillation_matrix[i,j]:.2f}" for j in range(n_states))
    print(f"  P{i}: {row}")

# Find equivalence classes
equiv_classes = []
assigned = set()
for i in range(n_states):
    if i in assigned:
        continue
    cls = [i]
    for j in range(i+1, n_states):
        if system.observer_kernel(proof_states[i], proof_states[j]):
            cls.append(j)
            assigned.add(j)
    equiv_classes.append(cls)
    assigned.add(i)

print(f"\nObserver equivalence classes (P/~_O):")
for k, cls in enumerate(equiv_classes):
    members = ", ".join(f"P{i}" for i in cls)
    print(f"  Class {k}: {{{members}}}")
print(f"  Compression ratio: {n_states} states → {len(equiv_classes)} classes")

# Verify ultrametric property
print("\nVerifying ultrametric inequality for δ_O...")
violations = 0
for i in range(n_states):
    for j in range(n_states):
        for k in range(n_states):
            if distillation_matrix[i, k] > max(distillation_matrix[i, j],
                                                distillation_matrix[j, k]) + 1e-10:
                violations += 1
print(f"  Violations: {violations} (should be 0)")

# ============================================================
# 3. Certificate Map and Tropical Structure
# ============================================================

print("\n" + "=" * 60)
print("DEMO 3: Certificate Map (Tropical Valuation)")
print("=" * 60)

p0 = proof_states[0]  # Reference point
certificates = [system.certificate_map(p0, s) for s in proof_states]

print(f"\nReference point: P0 = {p0}")
print(f"\nCertificate values cert(x) = δ_O(P0, x):")
for i, c in enumerate(certificates):
    print(f"  cert(P{i}) = {c:.4f}")

# Verify constancy on equivalence classes
print(f"\nVerifying certificate constancy on equivalence classes:")
for k, cls in enumerate(equiv_classes):
    vals = [certificates[i] for i in cls]
    print(f"  Class {k}: certs = {[f'{v:.4f}' for v in vals]}, "
          f"constant: {all(abs(v - vals[0]) < 1e-10 for v in vals)}")

# Verify nonexpansiveness
print(f"\nVerifying certificate nonexpansiveness:")
max_violation = 0
for i in range(n_states):
    for j in range(n_states):
        diff = abs(certificates[i] - certificates[j])
        dist = distillation_matrix[i, j]
        if diff > dist + 1e-10:
            max_violation = max(max_violation, diff - dist)
print(f"  Max violation of |cert(x) - cert(y)| ≤ δ(x,y): {max_violation:.6f}")

# ============================================================
# 4. Generator-Depth Complexity Analysis
# ============================================================

print("\n" + "=" * 60)
print("DEMO 4: Observer Complexity vs. Generator Depth")
print("=" * 60)

def generate_contexts(generators, max_depth):
    """Generate all context words up to given depth."""
    contexts = [lambda x: list(x)]  # identity
    current_words = [lambda x: list(x)]

    for depth in range(1, max_depth + 1):
        new_words = []
        for g in generators:
            for w in current_words:
                # Create composition g ∘ w
                new_word = (lambda g, w: lambda x: g(w(x)))(g, w)
                new_words.append(new_word)
        contexts.extend(new_words)
        current_words = new_words

    return contexts

generators = [shift_right, flip_first]
for depth in range(1, 5):
    ctxs = generate_contexts(generators, depth)
    sys = ClosedObserverSystem(d, compress, ctxs)

    # Count distinct equivalence classes
    n = len(proof_states)
    equiv = np.zeros((n, n), dtype=bool)
    for i in range(n):
        for j in range(n):
            equiv[i, j] = sys.observer_kernel(proof_states[i], proof_states[j])

    n_classes = 0
    seen = set()
    for i in range(n):
        if i not in seen:
            n_classes += 1
            for j in range(i, n):
                if equiv[i, j]:
                    seen.add(j)

    print(f"  Depth {depth}: {len(ctxs)} contexts, {n_classes} equivalence classes, "
          f"bound = (k+1)^d = {(len(generators)+1)**depth}")

# ============================================================
# 5. Visualization: Distillation Heatmap
# ============================================================

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Original distance
orig_matrix = np.zeros((n_states, n_states))
for i in range(n_states):
    for j in range(n_states):
        orig_matrix[i, j] = d(proof_states[i], proof_states[j])

im0 = axes[0].imshow(orig_matrix, cmap='YlOrRd', aspect='equal')
axes[0].set_title('Original Ultrametric\nd(x, y)', fontsize=12)
axes[0].set_xticks(range(n_states))
axes[0].set_yticks(range(n_states))
axes[0].set_xticklabels([f'P{i}' for i in range(n_states)], fontsize=8)
axes[0].set_yticklabels([f'P{i}' for i in range(n_states)], fontsize=8)
plt.colorbar(im0, ax=axes[0], shrink=0.8)

# Observer distillation
im1 = axes[1].imshow(distillation_matrix, cmap='YlOrRd', aspect='equal')
axes[1].set_title('Observer Distillation\nδ_O(x, y)', fontsize=12)
axes[1].set_xticks(range(n_states))
axes[1].set_yticks(range(n_states))
axes[1].set_xticklabels([f'P{i}' for i in range(n_states)], fontsize=8)
axes[1].set_yticklabels([f'P{i}' for i in range(n_states)], fontsize=8)
plt.colorbar(im1, ax=axes[1], shrink=0.8)

# Compression quotient (equivalence classes)
quotient_matrix = np.zeros((n_states, n_states))
for i in range(n_states):
    for j in range(n_states):
        quotient_matrix[i, j] = 0 if system.observer_kernel(
            proof_states[i], proof_states[j]) else 1

im2 = axes[2].imshow(quotient_matrix, cmap='Blues', aspect='equal')
axes[2].set_title('Observer Kernel\n(0 = equivalent)', fontsize=12)
axes[2].set_xticks(range(n_states))
axes[2].set_yticks(range(n_states))
axes[2].set_xticklabels([f'P{i}' for i in range(n_states)], fontsize=8)
axes[2].set_yticklabels([f'P{i}' for i in range(n_states)], fontsize=8)
plt.colorbar(im2, ax=axes[2], shrink=0.8)

plt.suptitle('Operadic Ultrametric Compression: From Distance to Quotient',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('distillation_heatmap.png', dpi=150, bbox_inches='tight')
plt.close()
print("\nSaved: distillation_heatmap.png")

# ============================================================
# 6. Visualization: Certificate Map
# ============================================================

fig, ax = plt.subplots(figsize=(10, 5))

colors = plt.cm.Set3(np.linspace(0, 1, len(equiv_classes)))
for k, cls in enumerate(equiv_classes):
    for i in cls:
        ax.bar(i, certificates[i], color=colors[k],
               edgecolor='black', linewidth=0.5,
               label=f'Class {k}' if i == cls[0] else '')

ax.set_xlabel('Proof State', fontsize=12)
ax.set_ylabel('Certificate Value cert(x) = δ_O(P0, x)', fontsize=12)
ax.set_title('Certificate Map: Tropical Valuation on Proof States', fontsize=14)
ax.set_xticks(range(n_states))
ax.set_xticklabels([f'P{i}' for i in range(n_states)])
ax.legend(loc='upper right')
ax.grid(axis='y', alpha=0.3)

plt.tight_layout()
plt.savefig('certificate_map.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: certificate_map.png")

# ============================================================
# 7. Contraction Dynamics Visualization
# ============================================================

fig, ax = plt.subplots(figsize=(10, 6))

q = 0.7  # Contraction ratio
d0 = 1.0  # Initial distance
n_steps = 15

steps = np.arange(n_steps)
bounds = d0 * q**steps

ax.plot(steps, bounds, 'b-o', linewidth=2, markersize=6,
        label=f'q^n · d(F(x), x), q={q}')
ax.fill_between(steps, 0, bounds, alpha=0.1, color='blue')
ax.axhline(y=0, color='black', linewidth=0.5)

# Mark compression threshold
eps = 0.1
n_threshold = int(np.ceil(np.log(eps / d0) / np.log(q)))
ax.axhline(y=eps, color='red', linestyle='--', linewidth=1,
           label=f'ε = {eps}')
ax.axvline(x=n_threshold, color='red', linestyle=':', alpha=0.5)
ax.annotate(f'N = {n_threshold}', xy=(n_threshold, eps),
            xytext=(n_threshold + 1, eps + 0.1),
            arrowprops=dict(arrowstyle='->', color='red'),
            fontsize=11, color='red')

ax.set_xlabel('Iteration n', fontsize=12)
ax.set_ylabel('Distance Bound', fontsize=12)
ax.set_title('Ultrametric Contraction Dynamics: Geometric Decay', fontsize=14)
ax.legend(fontsize=11)
ax.grid(alpha=0.3)

plt.tight_layout()
plt.savefig('contraction_dynamics.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: contraction_dynamics.png")

print("\n" + "=" * 60)
print("ALL DEMOS COMPLETE")
print("=" * 60)
