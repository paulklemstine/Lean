#!/usr/bin/env python3
"""
Memory Algebra: Core Algorithms

Type-hinted implementations of the key algorithms from the memory algebra framework.
"""

from typing import (
    Callable, Dict, FrozenSet, Generic, List, Optional,
    Set, Tuple, TypeVar
)
from dataclasses import dataclass
from collections import defaultdict
import math

T = TypeVar('T')
E = TypeVar('E')
S = TypeVar('S')


@dataclass
class MemorySystem(Generic[E, S]):
    """A memory system: a structure-preserving map from experiences to states.

    The encode function should satisfy:
        encode(identity) == state_identity
        encode(a * b) == encode(a) * encode(b)
    """
    encode: Callable[[E], S]
    identity_exp: E
    identity_state: S
    compose_exp: Callable[[E, E], E]
    compose_state: Callable[[S, S], S]

    def is_homomorphism(self, samples: List[E]) -> bool:
        """Test homomorphism property on sample inputs."""
        # Check identity preservation
        if self.encode(self.identity_exp) != self.identity_state:
            return False
        # Check multiplicativity
        for a in samples:
            for b in samples:
                ab = self.compose_exp(a, b)
                if self.encode(ab) != self.compose_state(
                    self.encode(a), self.encode(b)
                ):
                    return False
        return True


def compute_kernel_congruence(
    encode: Callable[[E], S],
    domain: List[E]
) -> Dict[S, List[E]]:
    """Compute the kernel congruence by grouping domain elements by their image.

    Returns a dictionary mapping each state to the list of experiences that
    produce it (i.e., the fibers of the encoding map).
    """
    fibers: Dict[S, List[E]] = defaultdict(list)
    for x in domain:
        fibers[encode(x)].append(x)
    return dict(fibers)


def check_refinement(
    encode1: Callable[[E], S],
    encode2: Callable[[E], S],
    domain: List[E]
) -> bool:
    """Check if memory system 1 refines memory system 2.

    Returns True iff encode1(a) == encode1(b) implies encode2(a) == encode2(b)
    for all a, b in domain. Equivalently, ker(encode1) ⊆ ker(encode2).
    """
    for i, a in enumerate(domain):
        for b in domain[i + 1:]:
            if encode1(a) == encode1(b) and encode2(a) != encode2(b):
                return False
    return True


def fiber_cardinality_bound(domain_size: int, codomain_size: int) -> int:
    """Compute the pigeonhole lower bound on the maximum fiber size.

    For any function f: A → B with |A| = domain_size and |B| = codomain_size,
    at least one fiber has at least this many elements.
    """
    if codomain_size == 0:
        raise ValueError("Codomain must be nonempty")
    return domain_size // codomain_size


def compute_information_loss(
    encode: Callable[[E], S],
    domain: List[E]
) -> float:
    """Compute the information loss of a memory system in bits.

    Information loss = H(E) - H(encode(E))
    where H is the Shannon entropy with uniform distribution on domain.

    Returns the entropy of the kernel congruence (in bits).
    """
    n = len(domain)
    if n == 0:
        return 0.0
    fibers = compute_kernel_congruence(encode, domain)
    # Entropy of the output distribution
    output_entropy = 0.0
    for fiber in fibers.values():
        p = len(fiber) / n
        if p > 0:
            output_entropy -= p * math.log2(p)
    # Entropy of uniform input
    input_entropy = math.log2(n) if n > 0 else 0.0
    return input_entropy - output_entropy


def idempotent_compression(
    compress: Callable[[S], S],
    states: List[S]
) -> Tuple[List[S], List[S]]:
    """Apply idempotent compression and return (fixed_points, transient_states).

    An idempotent function r satisfies r(r(x)) = r(x). The fixed points
    (states where r(x) = x) are exactly the image of r.
    """
    fixed_points = []
    transient = []
    for s in states:
        if compress(s) == s:
            fixed_points.append(s)
        else:
            transient.append(s)
    return fixed_points, transient


def salience_aggregate(values: List[float]) -> float:
    """Aggregate values using max (salience = supremum in the real number lattice).

    Properties:
    - Idempotent: aggregate([x, x]) == x
    - Commutative: order doesn't matter
    - Associative: grouping doesn't matter
    """
    if not values:
        return float('-inf')
    return max(values)


def congruence_lattice(
    domain: List[E],
    memory_systems: Dict[str, Callable[[E], S]]
) -> Dict[str, Set[str]]:
    """Compute the refinement lattice of a collection of memory systems.

    Returns a dictionary mapping each system name to the set of systems
    it refines (is finer than).
    """
    lattice: Dict[str, Set[str]] = {name: set() for name in memory_systems}
    names = list(memory_systems.keys())
    for i, name1 in enumerate(names):
        for name2 in names[i + 1:]:
            enc1 = memory_systems[name1]
            enc2 = memory_systems[name2]
            if check_refinement(enc1, enc2, domain):
                lattice[name1].add(name2)
            if check_refinement(enc2, enc1, domain):
                lattice[name2].add(name1)
    return lattice


def tropical_memory_step(
    weights: List[List[float]],
    state: List[float]
) -> List[float]:
    """One step of tropical (min-plus) memory update.

    Computes T(x)_i = min_j(W_ij + x_j) for the tropical matrix-vector product.
    This models a memory system in the min-plus semiring.
    """
    n = len(state)
    result = []
    for i in range(n):
        val = min(weights[i][j] + state[j] for j in range(n))
        result.append(val)
    return result


def tropical_iterate_to_convergence(
    weights: List[List[float]],
    initial: List[float],
    max_iter: int = 100,
    tol: float = 1e-10
) -> Tuple[List[float], int]:
    """Iterate tropical memory update until convergence.

    Returns (fixed_point, num_iterations).
    """
    state = initial[:]
    for step in range(max_iter):
        new_state = tropical_memory_step(weights, state)
        if all(abs(a - b) < tol for a, b in zip(state, new_state)):
            return new_state, step + 1
        state = new_state
    return state, max_iter


if __name__ == "__main__":
    # Example: Z/12Z memory systems
    domain = list(range(12))

    # Create a memory system
    ms = MemorySystem(
        encode=lambda x: x % 4,
        identity_exp=0,
        identity_state=0,
        compose_exp=lambda a, b: (a + b) % 12,
        compose_state=lambda a, b: (a + b) % 4,
    )
    print(f"Is homomorphism: {ms.is_homomorphism(domain)}")

    # Compute fibers
    fibers = compute_kernel_congruence(ms.encode, domain)
    print(f"Fibers: {fibers}")

    # Information loss
    loss = compute_information_loss(ms.encode, domain)
    print(f"Information loss: {loss:.2f} bits")

    # Fiber bound
    bound = fiber_cardinality_bound(12, 4)
    print(f"Minimum fiber size ≥ {bound}")

    # Tropical iteration
    W = [[0, 1, 3], [2, 0, 1], [1, 3, 0]]
    x0 = [10.0, 20.0, 30.0]
    fp, iters = tropical_iterate_to_convergence(W, x0)
    print(f"Tropical convergence: {iters} iterations → {fp}")
