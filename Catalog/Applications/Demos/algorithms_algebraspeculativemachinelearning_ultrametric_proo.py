#!/usr/bin/env python3
"""
Algorithms for Ultrametric Proof-Learning Representation Duality

Implements the core algorithms from the research paper:
1. Profile Computation (O(|ι| · T_obs))
2. Certified Predictor Construction (O(|S| · |ι|))
3. Canonical Tree Construction (O(|range(C)|²))
4. Spectral Filtration Construction
5. Observer Separation Verification

All algorithms include type hints, docstrings, and complexity analysis.
"""

from typing import (
    TypeVar, Callable, Sequence, Dict, Tuple, Set, List, Optional, Any
)
from collections import defaultdict
from dataclasses import dataclass, field

S = TypeVar('S')
Score = TypeVar('Score')


# =============================================================================
# §1. Core Data Structures
# =============================================================================

@dataclass
class UltrametricProofSystem:
    """A finite ultrametric proof system (S, d, C, obs).

    Attributes:
        states: Finite set of proof states
        compress: Idempotent compression operator C : S → S
        observers: List of observer functions obs_i : S → Score
        distance: Ultrametric distance d : S × S → float
    """
    states: List[Any]
    compress: Callable
    observers: List[Callable]
    distance: Callable

    @property
    def compressed_states(self) -> List[Any]:
        """range(C) — the set of compressed (fixed-point) states."""
        return sorted(set(self.compress(x) for x in self.states))

    @property
    def num_observers(self) -> int:
        return len(self.observers)


@dataclass
class ObserverProfile:
    """An observer profile: a tuple of scores, one per observer."""
    scores: Tuple

    def __hash__(self):
        return hash(self.scores)

    def __eq__(self, other):
        return isinstance(other, ObserverProfile) and self.scores == other.scores


@dataclass
class CertifiedPredictor:
    """A certified predictor with lookup table and correctness certificate.

    Attributes:
        lookup: Map from observer profiles to compressed states
        compress: The compression operator
        observers: The observer family
        certificate: Description of the correctness guarantee
    """
    lookup: Dict[Tuple, Any]
    compress: Callable
    observers: List[Callable]
    certificate: str = "Theorem C: predict ∘ evalProfile ∘ predict = evalProfile"

    def predict(self, profile: Tuple) -> Optional[Any]:
        """Predict compressed state from observer profile.

        Time: O(1) average (hash table lookup)
        Space: O(1)
        """
        return self.lookup.get(profile, None)

    def eval_and_predict(self, x) -> Any:
        """Compress, observe, predict.

        Time: O(|ι|) for profile computation + O(1) for lookup
        """
        cx = self.compress(x)
        profile = tuple(obs(cx) for obs in self.observers)
        return self.predict(profile)


@dataclass
class TreeNode:
    """A node in the canonical ultrametric tree.

    Attributes:
        states: Compressed states in this cluster
        radius: The cluster radius
        children: Child nodes (finer clusters)
    """
    states: List[Any]
    radius: float
    children: List['TreeNode'] = field(default_factory=list)

    def is_leaf(self) -> bool:
        return len(self.children) == 0

    def depth(self) -> int:
        if self.is_leaf():
            return 0
        return 1 + max(c.depth() for c in self.children)

    def to_dict(self) -> dict:
        """Convert to dictionary for serialization."""
        return {
            'states': self.states,
            'radius': self.radius,
            'children': [c.to_dict() for c in self.children]
        }


# =============================================================================
# §2. Algorithm 1: Profile Computation
# =============================================================================

def compute_profile(x, system: UltrametricProofSystem) -> Tuple:
    """Compute the observer profile of state x.

    Algorithm: ComputeProfile
    1. Compress x to C(x)
    2. Evaluate each observer on C(x)
    3. Return tuple of scores

    Time:  O(|ι| · T_obs) where T_obs is per-observer evaluation time
    Space: O(|ι|)

    Args:
        x: A proof state
        system: The ultrametric proof system

    Returns:
        Tuple of observer scores
    """
    cx = system.compress(x)
    return tuple(obs(cx) for obs in system.observers)


def compute_all_profiles(system: UltrametricProofSystem) -> Dict[Any, Tuple]:
    """Compute observer profiles for all compressed states.

    Time:  O(|S| · |ι| · T_obs)
    Space: O(|range(C)| · |ι|)
    """
    profiles = {}
    for x in system.compressed_states:
        profiles[x] = compute_profile(x, system)
    return profiles


# =============================================================================
# §3. Algorithm 2: Certified Predictor Construction
# =============================================================================

def build_certified_predictor(
    system: UltrametricProofSystem
) -> CertifiedPredictor:
    """Build a certified predictor with correctness guarantee.

    Algorithm: BuildCertifiedPredictor
    1. For each state x ∈ S, compute profile f = evalProfile(x)
    2. Store mapping f → C(x) in lookup table
    3. Return predictor with certificate

    Time:  O(|S| · |ι| · T_obs)
    Space: O(|range(C)| · |ι|)

    Certificate: By Theorem C (certified_hierarchical_predictor_reconstruction),
    for all x ∈ S:
        evalProfile(C, obs)(predict(evalProfile(C, obs)(x))) = evalProfile(C, obs)(x)

    Args:
        system: The ultrametric proof system

    Returns:
        CertifiedPredictor with lookup table and certificate
    """
    lookup = {}
    for x in system.states:
        profile = compute_profile(x, system)
        if profile not in lookup:
            lookup[profile] = system.compress(x)

    return CertifiedPredictor(
        lookup=lookup,
        compress=system.compress,
        observers=system.observers,
        certificate=(
            "Correctness: ∀ x ∈ S, evalProfile(predict(evalProfile(x))) = evalProfile(x)\n"
            "Proof: By Theorem C. For any x, evalProfile(x) is realizable (witnessed by x),\n"
            "so predict returns C(s) for some s with evalProfile(s) = evalProfile(x).\n"
            "By factorization, evalProfile(C(s)) = evalProfile(s) = evalProfile(x). □"
        )
    )


def verify_predictor(
    predictor: CertifiedPredictor,
    system: UltrametricProofSystem
) -> bool:
    """Verify the certified predictor on all states.

    Time: O(|S| · |ι|)
    """
    for x in system.states:
        profile = compute_profile(x, system)
        predicted = predictor.predict(profile)
        if predicted is None:
            return False
        predicted_profile = tuple(obs(system.compress(predicted))
                                  for obs in system.observers)
        if predicted_profile != profile:
            return False
    return True


# =============================================================================
# §4. Algorithm 3: Canonical Tree Construction
# =============================================================================

def build_canonical_tree(system: UltrametricProofSystem) -> TreeNode:
    """Build the canonical ultrametric tree from the proof system.

    Algorithm: BuildCanonicalTree
    1. Compute compressed states
    2. Collect all pairwise distances
    3. Sort distances in decreasing order
    4. Build tree top-down by splitting clusters at each distance threshold

    Time:  O(|range(C)|² · T_dist + |range(C)|² · log|range(C)|)
    Space: O(|range(C)|²) for distance matrix

    The resulting tree satisfies:
    - Leaves = compressed states
    - sameCluster(x, y, r) ⟺ d(C(x), C(y)) ≤ r
    - Unique up to cluster equivalence (Theorem B')

    Args:
        system: The ultrametric proof system

    Returns:
        Root node of the canonical tree
    """
    compressed = system.compressed_states
    d = system.distance

    if len(compressed) <= 1:
        return TreeNode(states=compressed, radius=0)

    # Collect distinct positive distances
    distances = sorted(set(
        d(a, b) for a in compressed for b in compressed if a != b
    ), reverse=True)

    if not distances:
        return TreeNode(states=compressed, radius=0)

    # Start with root containing all states
    root_radius = max(distances)

    def build_subtree(states_list: List, level: int) -> TreeNode:
        if level >= len(distances) or len(states_list) <= 1:
            return TreeNode(states=states_list, radius=0)

        r = distances[level]

        # Partition by ultrametric balls at radius r
        remaining = set(states_list)
        clusters = []
        while remaining:
            x = min(remaining)
            cluster = [y for y in remaining if d(x, y) <= r]
            clusters.append(sorted(cluster))
            remaining -= set(cluster)

        if len(clusters) == 1:
            # No split at this level, try next
            return build_subtree(states_list, level + 1)

        node = TreeNode(states=states_list, radius=r)
        for cluster in clusters:
            child = build_subtree(cluster, level + 1)
            node.children.append(child)

        return node

    root = TreeNode(states=compressed, radius=root_radius)
    # Find the first level that splits
    for level, r in enumerate(distances):
        remaining = set(compressed)
        clusters = []
        while remaining:
            x = min(remaining)
            cluster = [y for y in remaining if d(x, y) <= r]
            clusters.append(sorted(cluster))
            remaining -= set(cluster)

        if len(clusters) > 1:
            for cluster in clusters:
                child = build_subtree(cluster, level + 1)
                root.children.append(child)
            break

    return root


def print_tree(node: TreeNode, indent: int = 0):
    """Pretty-print a tree node."""
    prefix = "  " * indent
    if node.is_leaf():
        print(f"{prefix}Leaf: {node.states}")
    else:
        print(f"{prefix}Node (r={node.radius}): {node.states}")
        for child in node.children:
            print_tree(child, indent + 1)


# =============================================================================
# §5. Algorithm 4: Spectral Filtration
# =============================================================================

def build_spectral_filtration(
    system: UltrametricProofSystem,
    thresholds: List[Tuple]
) -> Dict[Tuple, List]:
    """Build the spectral filtration from observer thresholds.

    For each threshold t ∈ (ι → σ), compute:
        F_t = {x ∈ S | ∀ i, obs_i(C(x)) ≤ t_i}

    Time:  O(|thresholds| · |S| · |ι|)
    Space: O(|thresholds| · |S|)

    Properties (proved formally):
    - Monotonicity: t ≤ t' ⟹ F_t ⊆ F_{t'} (Theorem 7.1)
    - Compression stability: x ∈ F_t ⟹ C(x) ∈ F_t (Theorem 7.2)
    """
    filtration = {}
    for t in thresholds:
        sublevel = []
        for x in system.states:
            cx = system.compress(x)
            if all(obs(cx) <= ti for obs, ti in zip(system.observers, t)):
                sublevel.append(x)
        filtration[t] = sublevel
    return filtration


# =============================================================================
# §6. Algorithm 5: Observer Separation Verification
# =============================================================================

def verify_observer_separation(
    system: UltrametricProofSystem
) -> Tuple[bool, Optional[Tuple]]:
    """Verify that observers separate all distinct compressed states.

    Time:  O(|range(C)|² · |ι|)
    Space: O(1)

    Returns:
        (True, None) if separation holds
        (False, (a, b)) if states a, b are not separated
    """
    compressed = system.compressed_states
    for i, a in enumerate(compressed):
        for b in compressed[i+1:]:
            profile_a = tuple(obs(a) for obs in system.observers)
            profile_b = tuple(obs(b) for obs in system.observers)
            if profile_a == profile_b:
                return False, (a, b)
    return True, None


def verify_ultrametricity(
    system: UltrametricProofSystem
) -> Tuple[bool, Optional[Tuple]]:
    """Verify the ultrametric inequality on compressed states.

    Time: O(|range(C)|³)
    """
    compressed = system.compressed_states
    d = system.distance
    for x in compressed:
        for y in compressed:
            for z in compressed:
                if d(x, z) > max(d(x, y), d(y, z)) + 1e-10:
                    return False, (x, y, z)
    return True, None


# =============================================================================
# Main demo
# =============================================================================

if __name__ == "__main__":
    # Build the example system
    def C(x): return x % 4
    def obs_0(x): return x % 2
    def obs_1(x): return x // 2

    compressed_dist = {
        (0,0):0, (1,1):0, (2,2):0, (3,3):0,
        (0,1):1, (1,0):1, (0,2):2, (2,0):2,
        (0,3):2, (3,0):2, (1,2):2, (2,1):2,
        (1,3):2, (3,1):2, (2,3):1, (3,2):1,
    }
    def d(x, y): return compressed_dist[(C(x), C(y))]

    system = UltrametricProofSystem(
        states=list(range(8)),
        compress=C,
        observers=[obs_0, obs_1],
        distance=d
    )

    print("=== Algorithms Demo ===\n")

    # Algorithm 1: Profiles
    profiles = compute_all_profiles(system)
    print("Observer profiles:", profiles)

    # Algorithm 2: Certified Predictor
    predictor = build_certified_predictor(system)
    print(f"\nPredictor lookup table: {predictor.lookup}")
    print(f"Predictor verified: {verify_predictor(predictor, system)}")
    print(f"Certificate:\n{predictor.certificate}")

    # Algorithm 3: Canonical Tree
    tree = build_canonical_tree(system)
    print("\nCanonical tree:")
    print_tree(tree)

    # Algorithm 4: Spectral Filtration
    thresholds = [(0,0), (0,1), (1,0), (1,1)]
    filtration = build_spectral_filtration(system, thresholds)
    print("\nSpectral filtration:")
    for t, states in filtration.items():
        print(f"  F_{t}: {states}")

    # Algorithm 5: Verification
    sep_ok, _ = verify_observer_separation(system)
    ultra_ok, _ = verify_ultrametricity(system)
    print(f"\nObserver separation: {'✓' if sep_ok else '✗'}")
    print(f"Ultrametricity: {'✓' if ultra_ok else '✗'}")
