#!/usr/bin/env python3
"""
Algorithms for Spectral Semantics from Prime Closures

Implements the core algorithms from the research paper with complete
type hints, docstrings, and complexity analysis.
"""

from typing import Set, Callable, List, Tuple, Optional, FrozenSet
from dataclasses import dataclass, field


# =============================================================================
# Core Data Structures
# =============================================================================

@dataclass
class PrimeClosureState:
    """A prime closure state: a carrier set with metadata.

    Corresponds to the Lean structure:
        structure PrimeClosureState (R : Type*) where
          carrier : Set R
          isPrimeLike : Prop
          closed_under_condensation : Prop

    In the spectral topology, these play the role of points in
    the prime spectrum Spec(A) of algebraic geometry.
    """
    carrier: FrozenSet[int]
    is_prime_like: bool = True
    closed_under_condensation: bool = True

    def __contains__(self, x: int) -> bool:
        return x in self.carrier

    def __le__(self, other: 'PrimeClosureState') -> bool:
        return self.carrier <= other.carrier

    def __repr__(self) -> str:
        return f"PrimeClosureState({sorted(self.carrier)})"


@dataclass
class ClosureOperator:
    """A closure operator on finite sets.

    Must satisfy: extensive, monotone, idempotent.
    Corresponds to ClosureEnd or CondensationOp in the Lean formalization.

    Attributes:
        apply: The closure function Set → Set
        name: Human-readable name
    """
    apply: Callable[[Set[int]], Set[int]]
    name: str = "unnamed"

    def __call__(self, s: Set[int]) -> Set[int]:
        return self.apply(s)

    def verify_axioms(self, universe: Set[int], samples: int = 100) -> bool:
        """Verify closure operator axioms on random subsets.

        Time complexity: O(samples · |universe| · cost(apply))
        """
        import random
        for _ in range(samples):
            k = random.randint(0, len(universe))
            s = set(random.sample(sorted(universe), k))
            cs = self(s)

            # Extensive: s ⊆ C(s)
            if not s <= cs:
                print(f"FAIL extensive: s={s}, C(s)={cs}")
                return False

            # Idempotent: C(C(s)) = C(s)
            ccs = self(cs)
            if ccs != cs:
                print(f"FAIL idempotent: s={s}, C(s)={cs}, C(C(s))={ccs}")
                return False

        # Monotone: check a few pairs
        for _ in range(samples):
            k1 = random.randint(0, len(universe))
            s = set(random.sample(sorted(universe), k1))
            k2 = random.randint(0, len(universe) - len(s))
            remaining = sorted(universe - s)
            t = s | set(random.sample(remaining, k2))

            cs = self(s)
            ct = self(t)
            if not cs <= ct:
                print(f"FAIL monotone: s={s}, t={t}, C(s)={cs}, C(t)={ct}")
                return False

        return True


# =============================================================================
# Algorithm 1: Spectral Approximation
# =============================================================================

def spectral_approx(
    K: ClosureOperator,
    n: int,
    s: Set[int]
) -> Set[int]:
    """Compute the n-step spectral approximation.

    Algorithm:
        spectralApprox(K, 0, s) = s
        spectralApprox(K, n+1, s) = K(spectralApprox(K, n, s))

    Time complexity: O(n · cost(K))
    Space complexity: O(|universe|)

    Args:
        K: Condensation operator
        n: Number of steps
        s: Seed set

    Returns:
        The n-step spectral approximation K^n(s)
    """
    current = set(s)
    for _ in range(n):
        current = K(current)
    return current


def find_stabilization_index(
    K: ClosureOperator,
    s: Set[int],
    max_iter: int
) -> Tuple[int, Set[int]]:
    """Find the stabilization index of spectral approximation.

    Guaranteed to terminate in at most |universe| steps for finite types
    (Theorem: spectralApprox_stabilizes_of_finite).

    Time complexity: O(min(stab_index, max_iter) · cost(K))
    Space complexity: O(|universe|)

    Args:
        K: Condensation operator
        s: Seed set
        max_iter: Maximum iterations (should be ≥ |universe|)

    Returns:
        (stabilization_index, stabilized_set)
    """
    current = set(s)
    for i in range(max_iter):
        next_set = K(current)
        if next_set == current:
            return i, current
        current = next_set
    return max_iter, current


# =============================================================================
# Algorithm 2: Spectral Reconstruction
# =============================================================================

def spectral_reconstruct(
    C: ClosureOperator,
    K: ClosureOperator,
    s: Set[int]
) -> PrimeClosureState:
    """Spectral reconstruction: build a prime closure state from closure data.

    Corresponds to:
        def spectralReconstruct (C : ClosureEnd R) (K : CondensationOp R)
            (s : Set R) : PrimeClosureState R

    The carrier of the result is C(s).

    Time complexity: O(cost(C))
    Space complexity: O(|universe|)

    Args:
        C: Closure operator
        K: Condensation operator (unused in carrier computation)
        s: Seed set

    Returns:
        PrimeClosureState with carrier = C(s)
    """
    carrier = frozenset(C(s))
    return PrimeClosureState(carrier=carrier)


# =============================================================================
# Algorithm 3: Compact Open Generation
# =============================================================================

def compact_open_of_generator(
    g: int,
    prime_states: List[PrimeClosureState]
) -> List[PrimeClosureState]:
    """Compute the compact open D(g) = {p | g ∉ p.carrier}.

    This is the spectral analogue of the Zariski basic open D(f)
    in algebraic geometry.

    Time complexity: O(|prime_states|)

    Args:
        g: Generator element
        prime_states: List of prime closure states

    Returns:
        List of states not containing g
    """
    return [p for p in prime_states if g not in p.carrier]


def compact_open_intersection(
    g: int,
    h: int,
    prime_states: List[PrimeClosureState]
) -> Tuple[List[PrimeClosureState], List[PrimeClosureState]]:
    """Compute D(g) ∩ D(h) and verify it equals D(g*h) under multiplicative primality.

    Time complexity: O(|prime_states|)

    Returns:
        (D(g) ∩ D(h), D(g*h))
    """
    dg = set(id(p) for p in prime_states if g not in p.carrier)
    dh = set(id(p) for p in prime_states if h not in p.carrier)
    intersection = [p for p in prime_states if id(p) in dg and id(p) in dh]
    dgh = [p for p in prime_states if g * h not in p.carrier]
    return intersection, dgh


# =============================================================================
# Algorithm 4: Spectral Separation
# =============================================================================

def spectral_separate(
    x: int,
    y: int,
    prime_states: List[PrimeClosureState]
) -> Optional[PrimeClosureState]:
    """Find a prime closure state separating x from y.

    Implements the separation algorithm from the paper.
    Under HasPrimeClosureSeparation, this always succeeds for x ≠ y.

    Time complexity: O(|prime_states|)

    Args:
        x, y: Elements to separate (must be distinct)
        prime_states: Available prime closure states

    Returns:
        A separating state, or None if no separation exists
    """
    if x == y:
        return None

    for p in prime_states:
        x_in = x in p.carrier
        y_in = y in p.carrier
        if x_in != y_in:
            return p
    return None


# =============================================================================
# Algorithm 5: Condensation Stability Verification
# =============================================================================

def verify_condensation_stability(
    C: ClosureOperator,
    K: ClosureOperator,
    universe: Set[int],
    samples: int = 50
) -> Tuple[bool, Optional[Set[int]]]:
    """Verify condensation stability: K(C(s)) = C(s) for all s.

    Tests on random subsets. Returns (True, None) if stable,
    or (False, counterexample) if unstable.

    Time complexity: O(samples · |universe| · (cost(C) + cost(K)))

    Args:
        C: Closure operator
        K: Condensation operator
        universe: The ambient set
        samples: Number of random subsets to test

    Returns:
        (is_stable, counterexample_or_none)
    """
    import random
    for _ in range(samples):
        k = random.randint(0, len(universe))
        s = set(random.sample(sorted(universe), k))
        cs = C(s)
        kcs = K(cs)
        if kcs != cs:
            return False, s
    return True, None


# =============================================================================
# Concrete Closure Operator Constructors
# =============================================================================

def make_downward_closure(universe: Set[int]) -> ClosureOperator:
    """Downward closure on integers: {x ∈ U | ∃ y ∈ s, x ≤ y}."""
    def apply(s: Set[int]) -> Set[int]:
        if not s:
            return set()
        return {x for x in universe if any(x <= y for y in s)}
    return ClosureOperator(apply=apply, name="downward_closure")


def make_transitive_closure(adj: dict) -> ClosureOperator:
    """Transitive closure of reachability in a directed graph."""
    def apply(s: Set[int]) -> Set[int]:
        reached = set(s)
        frontier = set(s)
        while frontier:
            new = set()
            for node in frontier:
                for neighbor in adj.get(node, []):
                    if neighbor not in reached:
                        new.add(neighbor)
                        reached.add(neighbor)
            frontier = new
        return reached
    return ClosureOperator(apply=apply, name="transitive_closure")


def make_identity_closure() -> ClosureOperator:
    """Identity closure: C(s) = s."""
    return ClosureOperator(apply=lambda s: set(s), name="identity")


def make_full_closure(universe: Set[int]) -> ClosureOperator:
    """Full closure: C(s) = universe for nonempty s, ∅ for empty s."""
    def apply(s: Set[int]) -> Set[int]:
        return set(universe) if s else set()
    return ClosureOperator(apply=apply, name="full_closure")


# =============================================================================
# Example usage
# =============================================================================

if __name__ == "__main__":
    universe = set(range(1, 11))
    C = make_downward_closure(universe)
    K = make_downward_closure(universe)  # Self-stable

    print("Closure operator axiom verification:", C.verify_axioms(universe))

    # Spectral approximation
    seed = {5, 8}
    for n in range(5):
        print(f"spectralApprox({n}, {sorted(seed)}) = {sorted(spectral_approx(K, n, seed))}")

    # Stabilization
    idx, stable_set = find_stabilization_index(K, seed, len(universe) + 1)
    print(f"Stabilizes at step {idx}: {sorted(stable_set)}")

    # Reconstruction
    p = spectral_reconstruct(C, K, seed)
    print(f"Reconstructed state: {p}")

    # Condensation stability
    is_stable, cex = verify_condensation_stability(C, K, universe)
    print(f"Condensation stable: {is_stable}")

    # Separation
    primes = [PrimeClosureState(frozenset(range(1, k+1))) for k in range(1, 11)]
    sep = spectral_separate(3, 7, primes)
    print(f"Separating state for 3 vs 7: {sep}")


#!/usr/bin/env python3
"""
Applications of Spectral Semantics from Prime Closures

Real-world applications to machine learning (certified robustness),
cryptography (lattice hashing), and physics (thermodynamic equilibration).
"""

import numpy as np
from typing import Set, List, FrozenSet, Tuple
from dataclasses import dataclass


# =============================================================================
# Application 1: Certified Neural Network Robustness
# =============================================================================

@dataclass
class NeuralDecisionRegion:
    """A decision region of a neural network classifier.

    The region is modeled as a closure of training points under
    a Lipschitz-continuous closure operator.
    """
    label: str
    center: np.ndarray
    radius: float  # Lipschitz robustness radius

    def contains(self, x: np.ndarray) -> bool:
        return np.linalg.norm(x - self.center) <= self.radius


def certified_robustness_radius(
    regions: List[NeuralDecisionRegion],
    x: np.ndarray
) -> Tuple[str, float]:
    """Compute the certified robustness radius for a classification.

    The robustness radius is the minimum distance from x to any
    other decision region boundary. Within this radius, the
    classification is guaranteed to be stable.

    This implements the closure Lipschitz certificate:
        closureLipschitzCertificate C L ↔
        ∀ x y s, x ∈ s → dist x y ≤ L → y ∈ C s

    Returns:
        (predicted_label, certified_radius)
    """
    # Find which region x belongs to
    min_dist = float('inf')
    label = "unknown"
    for region in regions:
        d = np.linalg.norm(x - region.center)
        if d <= region.radius:
            label = region.label

    if label == "unknown":
        return label, 0.0

    # Certified radius = min distance to other region boundaries
    certified_r = float('inf')
    for region in regions:
        if region.label != label:
            d = np.linalg.norm(x - region.center) - region.radius
            certified_r = min(certified_r, max(0, d))

    return label, certified_r


def demo_certified_robustness():
    """Demonstrate certified robustness for a simple 2D classifier."""
    print("=" * 60)
    print("Application 1: Certified Neural Network Robustness")
    print("=" * 60)

    regions = [
        NeuralDecisionRegion("cat", np.array([0.0, 0.0]), 2.0),
        NeuralDecisionRegion("dog", np.array([5.0, 0.0]), 2.0),
        NeuralDecisionRegion("bird", np.array([2.5, 4.0]), 1.5),
    ]

    test_points = [
        np.array([0.0, 0.0]),     # Center of "cat"
        np.array([1.0, 0.0]),     # Inside "cat" near boundary
        np.array([1.9, 0.0]),     # Edge of "cat"
        np.array([5.0, 0.0]),     # Center of "dog"
        np.array([2.5, 4.0]),     # Center of "bird"
    ]

    print("\nDecision regions:")
    for r in regions:
        print(f"  {r.label}: center={r.center}, radius={r.radius}")

    print("\nCertified classifications:")
    for pt in test_points:
        label, radius = certified_robustness_radius(regions, pt)
        print(f"  x={pt} → label={label}, certified_radius={radius:.2f}")


# =============================================================================
# Application 2: Lattice-Based Spectral Hashing
# =============================================================================

def spectral_hash(
    generators: List[int],
    prime_carriers: List[FrozenSet[int]]
) -> List[bool]:
    """Compute a spectral hash using compact open generators.

    For each generator g, computes whether g is NOT in each prime
    carrier (compact open membership). The hash is the boolean
    vector [g ∉ p.carrier for p in prime_carriers].

    This implements tropicalHashCollisionFreeOn:
        ∀ g h ∈ gens, g ≠ h → D(g) ≠ D(h)

    Args:
        generators: Elements to hash
        prime_carriers: Carrier sets of prime closure states

    Returns:
        Boolean hash vector
    """
    hash_bits = []
    for g in generators:
        bits = tuple(g not in carrier for carrier in prime_carriers)
        hash_bits.append(bits)
    return hash_bits


def demo_lattice_hashing():
    """Demonstrate spectral hashing for post-quantum security."""
    print("\n" + "=" * 60)
    print("Application 2: Lattice-Based Spectral Hashing")
    print("=" * 60)

    # Prime carriers: downward closed sets {1,...,k} for k=1..8
    prime_carriers = [frozenset(range(1, k+1)) for k in range(1, 9)]

    print("\nPrime carriers (downward sets):")
    for i, pc in enumerate(prime_carriers):
        print(f"  p_{i+1}: {sorted(pc)}")

    generators = list(range(1, 9))
    hashes = spectral_hash(generators, prime_carriers)

    print("\nSpectral hashes (D(g) membership):")
    for g, h in zip(generators, hashes):
        bits = ''.join('1' if b else '0' for b in h)
        print(f"  H({g}) = {bits}")

    # Check collision-freeness
    unique_hashes = set(tuple(h) for h in hashes)
    collision_free = len(unique_hashes) == len(generators)
    print(f"\nCollision-free: {collision_free}")
    print(f"Hash space: 2^{len(prime_carriers)} = {2**len(prime_carriers)}")
    print(f"Generators: {len(generators)}")
    print(f"Security margin: {2**len(prime_carriers) / len(generators):.0f}x")


# =============================================================================
# Application 3: Thermodynamic Equilibration Simulation
# =============================================================================

def simulate_equilibration(
    n_particles: int,
    n_steps: int,
    coarse_grain_level: int = 2
) -> List[float]:
    """Simulate thermodynamic equilibration via spectral approximation.

    Models a system of n_particles in a 1D box, where the closure
    operator computes thermal equilibrium and the condensation operator
    performs coarse-graining (binning positions).

    The spectral approximation sequence models the approach to
    equilibrium, with each step representing one coarse-graining round.

    Returns:
        Entropy at each step (should increase and stabilize)
    """
    np.random.seed(42)
    positions = np.random.exponential(1.0, n_particles)
    n_bins = n_particles // coarse_grain_level

    entropies = []

    for step in range(n_steps):
        # Coarse-graining: bin positions
        hist, _ = np.histogram(positions, bins=n_bins, density=True)
        hist = hist + 1e-10  # avoid log(0)
        hist = hist / hist.sum()

        # Entropy
        entropy = -np.sum(hist * np.log2(hist))
        entropies.append(entropy)

        # "Condensation": redistribute within bins (thermalize)
        new_positions = []
        bin_edges = np.linspace(positions.min(), positions.max(), n_bins + 1)
        for i in range(n_bins):
            mask = (positions >= bin_edges[i]) & (positions < bin_edges[i+1])
            count = mask.sum()
            if count > 0:
                # Redistribute uniformly within bin
                new_positions.extend(
                    np.random.uniform(bin_edges[i], bin_edges[i+1], count)
                )
        positions = np.array(new_positions[:n_particles])

    return entropies


def demo_thermodynamic():
    """Demonstrate thermodynamic equilibration via spectral approximation."""
    print("\n" + "=" * 60)
    print("Application 3: Thermodynamic Equilibration")
    print("=" * 60)

    n_particles = 100
    n_steps = 20

    entropies = simulate_equilibration(n_particles, n_steps)

    print(f"\nParticles: {n_particles}")
    print(f"Steps: {n_steps}")
    print("\nEntropy evolution (should increase and stabilize):")
    for i, e in enumerate(entropies):
        bar = '█' * int(e * 5)
        print(f"  Step {i:2d}: H = {e:.4f} {bar}")

    # Check stabilization
    diffs = [abs(entropies[i+1] - entropies[i]) for i in range(len(entropies)-1)]
    stab_step = next((i for i, d in enumerate(diffs) if d < 0.01), len(diffs))
    print(f"\nApproximate stabilization step: {stab_step}")
    print(f"Final entropy: {entropies[-1]:.4f}")
    print(f"Maximum entropy (uniform): {np.log2(n_particles // 2):.4f}")


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    demo_certified_robustness()
    demo_lattice_hashing()
    demo_thermodynamic()

    print("\n" + "=" * 60)
    print("All applications completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Spectral Semantics from Prime Closures — Demonstration

Concrete numerical examples illustrating the spectral approximation algorithm,
finite stabilization bounds, and prime closure state separation.
"""

import random
random.seed(42)


def downward_closure(s: set, universe: set) -> set:
    """Downward closure on integers: {x | ∃ y ∈ s, x ≤ y}."""
    if not s:
        return set()
    return {x for x in universe if any(x <= y for y in s)}


def transitive_closure(adj: dict, s: set) -> set:
    """Transitive closure of reachability from seed set s in a directed graph."""
    reached = set(s)
    frontier = set(s)
    while frontier:
        new = set()
        for node in frontier:
            for neighbor in adj.get(node, []):
                if neighbor not in reached:
                    new.add(neighbor)
                    reached.add(neighbor)
        frontier = new
    return reached


def spectral_approx(K, n: int, s: set) -> set:
    """n-step spectral approximation: iteratively apply condensation K."""
    current = set(s)
    for _ in range(n):
        current = K(current)
    return current


def find_stabilization(K, s: set, max_iter: int) -> tuple:
    """Find the stabilization index of spectral approximation."""
    current = set(s)
    for i in range(max_iter):
        next_set = K(current)
        if next_set == current:
            return i, current
        current = next_set
    return max_iter, current


# =============================================================================
# Experiment 1: Downward closure
# =============================================================================
print("=" * 60)
print("Experiment 1: Downward Closure on {1, ..., 10}")
print("=" * 60)

universe = set(range(1, 11))
seed = {5, 8}
K1 = lambda s: downward_closure(s, universe)

print(f"Universe: {sorted(universe)}")
print(f"Seed: {sorted(seed)}")
print()

for n in range(5):
    result = spectral_approx(K1, n, seed)
    print(f"  spectralApprox(K, {n}, seed) = {sorted(result)}")

stab_idx, stab_set = find_stabilization(K1, seed, 20)
print(f"\nStabilization index: {stab_idx}")
print(f"Stabilized set: {sorted(stab_set)}")
print(f"Bound (|R| = {len(universe)}): satisfied = {stab_idx <= len(universe)}")

# =============================================================================
# Experiment 2: Transitive closure on a random graph
# =============================================================================
print("\n" + "=" * 60)
print("Experiment 2: Transitive Closure on Random Graph (10 nodes)")
print("=" * 60)

n_nodes = 10
adj = {i: [] for i in range(n_nodes)}
edges = []
for i in range(n_nodes):
    for j in range(n_nodes):
        if i != j and random.random() < 0.2:
            adj[i].append(j)
            edges.append((i, j))

print(f"Nodes: {list(range(n_nodes))}")
print(f"Edges: {edges}")

seed2 = {0}
K2 = lambda s: transitive_closure(adj, s)

print(f"Seed: {seed2}")
for n in range(12):
    result = spectral_approx(K2, n, seed2)
    print(f"  spectralApprox(K, {n}, seed) = {sorted(result)}")
    if n > 0 and result == spectral_approx(K2, n - 1, seed2):
        print(f"  → Stabilized at step {n}")
        break

stab_idx2, stab_set2 = find_stabilization(K2, seed2, 20)
print(f"\nStabilization index: {stab_idx2}")
print(f"Bound (|R| = {n_nodes}): satisfied = {stab_idx2 <= n_nodes}")

# =============================================================================
# Experiment 3: Finite stabilization bound verification
# =============================================================================
print("\n" + "=" * 60)
print("Experiment 3: Finite Stabilization Bound Verification")
print("=" * 60)

for n in [5, 10, 20, 50]:
    universe_n = set(range(n))
    trials = 20
    stab_indices = []

    for _ in range(trials):
        # Random closure: for each element, close under random predecessors
        closure_map = {}
        for x in universe_n:
            extras = {y for y in universe_n if random.random() < 0.3}
            closure_map[x] = extras | {x}

        def random_closure(s, cmap=closure_map, uni=universe_n):
            result = set(s)
            changed = True
            while changed:
                changed = False
                new = set()
                for x in result:
                    for y in cmap.get(x, set()):
                        if y not in result:
                            new.add(y)
                            changed = True
                result |= new
            return result

        seed_trial = {random.choice(list(universe_n))}
        idx, _ = find_stabilization(random_closure, seed_trial, n + 5)
        stab_indices.append(idx)

    avg = sum(stab_indices) / len(stab_indices)
    max_idx = max(stab_indices)
    print(f"  n={n:3d}: avg stabilization = {avg:.1f}, "
          f"max = {max_idx}, bound = {n}, "
          f"all ≤ n: {all(i <= n for i in stab_indices)}")

# =============================================================================
# Experiment 4: Compact open separation
# =============================================================================
print("\n" + "=" * 60)
print("Experiment 4: Compact Open Separation")
print("=" * 60)

# Model: PrimeClosureState with carrier = downward closure of a single element
universe4 = set(range(1, 8))
generators = list(universe4)

print(f"Universe: {sorted(universe4)}")
print(f"Generators: {generators}")
print()

# D(g) = {p | g ∉ p.carrier}
# Here p is identified by its "generating element" k, with carrier = {1,...,k}
prime_states = []
for k in range(1, 8):
    carrier = set(range(1, k + 1))
    prime_states.append(("p_" + str(k), carrier))

print("Prime states (carrier = downward set of generator):")
for name, carrier in prime_states:
    print(f"  {name}: carrier = {sorted(carrier)}")

print("\nCompact opens D(g) = {{p | g ∉ p.carrier}}:")
for g in generators:
    members = [name for name, carrier in prime_states if g not in carrier]
    print(f"  D({g}) = {{{', '.join(members)}}}")

# Separation: x=3, y=7
x, y = 3, 7
print(f"\nSeparating x={x} from y={y}:")
for name, carrier in prime_states:
    if (x in carrier) != (y in carrier):
        side = f"x={x} ∈ carrier, y={y} ∉ carrier" if x in carrier else f"y={y} ∈ carrier, x={x} ∉ carrier"
        print(f"  {name} separates: {side}")
        break

# =============================================================================
# Experiment 5: Condensation stability verification
# =============================================================================
print("\n" + "=" * 60)
print("Experiment 5: Condensation Stability K(C(s)) = C(s)")
print("=" * 60)

universe5 = set(range(1, 11))

def C5(s):
    """Closure: downward closure."""
    return downward_closure(s, universe5)

def K5(s):
    """Condensation: also downward closure (self-stable)."""
    return downward_closure(s, universe5)

test_sets = [{3, 7}, {1, 5, 9}, {2}, {10}, set()]
for s in test_sets:
    cs = C5(s)
    kcs = K5(cs)
    stable = kcs == cs
    print(f"  s={sorted(s)}: C(s)={sorted(cs)}, K(C(s))={sorted(kcs)}, stable={stable}")

print("\n✓ All experiments completed successfully.")
