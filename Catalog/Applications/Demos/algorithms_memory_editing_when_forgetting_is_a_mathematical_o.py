#!/usr/bin/env python3
"""
Memory Algebra Algorithms: Type-hinted implementations.

Core algorithms for computing with memory systems, kernels,
congruences, quotients, and information loss measures.
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Optional
import math
from collections import defaultdict


@dataclass
class FiniteMonoid:
    """A finite monoid represented by its multiplication table.

    Elements are integers 0, 1, ..., size-1.
    Element 0 is always the identity.
    """
    size: int
    table: list[list[int]]  # table[i][j] = i * j

    def mul(self, a: int, b: int) -> int:
        """Multiply two elements."""
        return self.table[a][b]

    def identity(self) -> int:
        return 0

    def validate(self) -> bool:
        """Check associativity and identity laws."""
        n = self.size
        # Identity check
        for i in range(n):
            if self.table[0][i] != i or self.table[i][0] != i:
                return False
        # Associativity check
        for a in range(n):
            for b in range(n):
                for c in range(n):
                    if self.table[self.table[a][b]][c] != self.table[a][self.table[b][c]]:
                        return False
        return True


@dataclass
class MonoidHomomorphism:
    """A monoid homomorphism between finite monoids."""
    source: FiniteMonoid
    target: FiniteMonoid
    mapping: list[int]  # mapping[i] = image of element i

    def apply(self, x: int) -> int:
        return self.mapping[x]

    def is_valid(self) -> bool:
        """Check homomorphism property: f(a*b) = f(a)*f(b) and f(1) = 1."""
        if self.mapping[0] != 0:
            return False
        for a in range(self.source.size):
            for b in range(self.source.size):
                if self.mapping[self.source.mul(a, b)] != \
                   self.target.mul(self.mapping[a], self.mapping[b]):
                    return False
        return True

    def is_injective(self) -> bool:
        return len(set(self.mapping)) == len(self.mapping)

    def is_surjective(self) -> bool:
        return len(set(self.mapping)) == self.target.size


@dataclass
class MemorySystem:
    """A memory system: monoid homomorphism with finite target."""
    experience_monoid: FiniteMonoid
    state_monoid: FiniteMonoid
    encode: MonoidHomomorphism

    def kernel(self) -> list[int]:
        """Compute the memory kernel: elements mapping to identity."""
        return [e for e in range(self.experience_monoid.size)
                if self.encode.apply(e) == 0]

    def congruence_classes(self) -> dict[int, list[int]]:
        """Compute congruence classes: partition by image."""
        classes: dict[int, list[int]] = defaultdict(list)
        for e in range(self.experience_monoid.size):
            classes[self.encode.apply(e)].append(e)
        return dict(classes)

    def fiber_sizes(self) -> list[int]:
        """Compute sizes of all fibers."""
        classes = self.congruence_classes()
        return [len(v) for v in classes.values()]

    def information_loss(self) -> float:
        """Compute information loss in bits: log2(|E|) - log2(|image|)."""
        image_size = len(set(self.encode.mapping))
        return math.log2(self.experience_monoid.size) - math.log2(image_size)

    def max_fiber_size(self) -> int:
        """Compute the maximum fiber size (worst-case conflation)."""
        return max(self.fiber_sizes())


@dataclass
class ForgettingMap:
    """A surjective monoid homomorphism modeling targeted forgetting."""
    source_states: FiniteMonoid
    target_states: FiniteMonoid
    forget: MonoidHomomorphism

    def is_valid(self) -> bool:
        return self.forget.is_valid() and self.forget.is_surjective()


@dataclass
class MemoryRefinement:
    """A refinement between memory systems with commuting bridge."""
    fine: MemorySystem
    coarse: MemorySystem
    bridge: MonoidHomomorphism

    def commutes(self) -> bool:
        """Check bridge(fine.encode(e)) = coarse.encode(e) for all e."""
        for e in range(self.fine.experience_monoid.size):
            fine_state = self.fine.encode.apply(e)
            bridged = self.bridge.apply(fine_state)
            coarse_state = self.coarse.encode.apply(e)
            if bridged != coarse_state:
                return False
        return True

    def verify_kernel_monotonicity(self) -> bool:
        """Verify fine kernel ⊆ coarse kernel."""
        fine_kernel = set(self.fine.kernel())
        coarse_kernel = set(self.coarse.kernel())
        return fine_kernel.issubset(coarse_kernel)

    def verify_congruence_refinement(self) -> bool:
        """Verify: fine-congruent implies coarse-congruent."""
        fine_classes = self.fine.congruence_classes()
        coarse_classes = self.coarse.congruence_classes()
        # Each fine class should be a subset of some coarse class
        coarse_sets = [set(v) for v in coarse_classes.values()]
        for fine_class in fine_classes.values():
            fine_set = set(fine_class)
            if not any(fine_set.issubset(cs) for cs in coarse_sets):
                return False
        return True


def make_cyclic_monoid(n: int) -> FiniteMonoid:
    """Create the cyclic group Z/nZ as a monoid."""
    table = [[(i + j) % n for j in range(n)] for i in range(n)]
    return FiniteMonoid(size=n, table=table)


def make_mod_homomorphism(
    source: FiniteMonoid, target: FiniteMonoid, divisor: int
) -> MonoidHomomorphism:
    """Create the mod-divisor homomorphism Z/nZ -> Z/mZ."""
    mapping = [i % target.size for i in range(source.size)]
    return MonoidHomomorphism(source=source, target=target, mapping=mapping)


def compose_forgetting(
    f: ForgettingMap, g: ForgettingMap
) -> ForgettingMap:
    """Compose two forgetting maps."""
    composed_mapping = [
        g.forget.apply(f.forget.apply(i))
        for i in range(f.source_states.size)
    ]
    composed_hom = MonoidHomomorphism(
        source=f.source_states,
        target=g.target_states,
        mapping=composed_mapping,
    )
    return ForgettingMap(
        source_states=f.source_states,
        target_states=g.target_states,
        forget=composed_hom,
    )


def enumerate_homomorphisms(
    source: FiniteMonoid, target: FiniteMonoid
) -> list[MonoidHomomorphism]:
    """Enumerate all monoid homomorphisms from source to target.

    Uses the fact that a homomorphism from a cyclic monoid is determined
    by the image of the generator.
    """
    import itertools

    results: list[MonoidHomomorphism] = []

    # Brute force for small monoids: try all possible mappings
    if source.size > 12:
        raise ValueError("Source too large for brute-force enumeration")

    # For a cyclic monoid Z/nZ generated by 1, the homomorphism is
    # determined by f(1), and we need f(1)^n = f(0) = 0.
    for gen_image in range(target.size):
        # Build the mapping by repeatedly multiplying
        mapping = [0] * source.size
        current = 0  # identity
        valid = True
        for i in range(source.size):
            mapping[i] = current
            current = target.mul(current, gen_image)

        # Check it's actually a homomorphism
        hom = MonoidHomomorphism(source=source, target=target, mapping=mapping)
        if hom.is_valid():
            results.append(hom)

    return results


def optimal_memory_search(
    experience: FiniteMonoid, budget: int
) -> Optional[MemorySystem]:
    """Find the memory system with given budget that minimizes information loss.

    Searches over all monoids of the given size and all homomorphisms.
    """
    best: Optional[MemorySystem] = None
    best_loss = float("inf")

    # For simplicity, only search cyclic monoids as targets
    target = make_cyclic_monoid(budget)
    homs = enumerate_homomorphisms(experience, target)

    for hom in homs:
        system = MemorySystem(
            experience_monoid=experience,
            state_monoid=target,
            encode=hom,
        )
        loss = system.information_loss()
        if loss < best_loss:
            best_loss = loss
            best = system

    return best


if __name__ == "__main__":
    # Example usage
    exp = make_cyclic_monoid(12)
    state = make_cyclic_monoid(4)

    hom = make_mod_homomorphism(exp, state, 4)
    mem = MemorySystem(experience_monoid=exp, state_monoid=state, encode=hom)

    print(f"Memory system: Z/12Z -> Z/4Z")
    print(f"  Valid homomorphism: {hom.is_valid()}")
    print(f"  Injective: {hom.is_injective()}")
    print(f"  Kernel: {mem.kernel()}")
    print(f"  Congruence classes: {mem.congruence_classes()}")
    print(f"  Information loss: {mem.information_loss():.2f} bits")
    print(f"  Max fiber size: {mem.max_fiber_size()}")

    # Find optimal memory
    best = optimal_memory_search(exp, 4)
    if best:
        print(f"\nOptimal 4-state memory for Z/12Z:")
        print(f"  Mapping: {best.encode.mapping}")
        print(f"  Loss: {best.information_loss():.2f} bits")
