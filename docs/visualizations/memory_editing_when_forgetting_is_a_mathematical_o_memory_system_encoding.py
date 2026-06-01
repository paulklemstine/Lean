#!/usr/bin/env python3
"""
Memory Algebra Algorithms: Type-hinted implementations of core constructions.

Implements:
1. MemorySystem: monoid homomorphism from free monoid to finite monoid
2. InformationLossCongruence: equivalence classes under memory encoding
3. OblivionKernel: streams mapping to identity
4. ForgettingComparison: comparing memory systems by forgetting order
5. ForgettingFactorization: constructing quotient maps
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Callable, Dict, FrozenSet, List, Optional, Set, Tuple
from itertools import product as iterproduct
from collections import defaultdict


@dataclass
class FiniteMonoid:
    """A finite monoid represented by its multiplication table."""
    elements: List[int]
    identity: int
    multiply: Callable[[int, int], int]
    name: str = "M"

    def order(self) -> int:
        return len(self.elements)

    def element_order(self, a: int) -> Optional[int]:
        """Order of element a (if monoid is actually a group). None if no finite order."""
        current = a
        for n in range(1, self.order() + 1):
            if current == self.identity:
                return n
            current = self.multiply(current, a)
        return None


def cyclic_group(n: int) -> FiniteMonoid:
    """Construct Z/nZ as a FiniteMonoid."""
    return FiniteMonoid(
        elements=list(range(n)),
        identity=0,
        multiply=lambda a, b: (a + b) % n,
        name=f"Z/{n}"
    )


@dataclass
class MemorySystem:
    """A memory system: monoid homomorphism from FreeMonoid(alphabet) to a finite monoid.

    Specified by the images of generators (alphabet symbols).
    """
    alphabet: List[int]
    target: FiniteMonoid
    generator_images: Dict[int, int]

    def encode(self, stream: Tuple[int, ...]) -> int:
        """Apply the homomorphism to an experience stream."""
        result = self.target.identity
        for symbol in stream:
            result = self.target.multiply(result, self.generator_images[symbol])
        return result

    def all_streams(self, max_length: int) -> List[Tuple[int, ...]]:
        """Generate all streams up to max_length."""
        streams: List[Tuple[int, ...]] = [()]
        for length in range(1, max_length + 1):
            streams.extend(iterproduct(self.alphabet, repeat=length))
        return streams

    def is_lossy(self, check_length: int = 6) -> bool:
        """Check lossiness by finding a collision up to check_length."""
        seen: Dict[int, Tuple[int, ...]] = {}
        for stream in self.all_streams(check_length):
            state = self.encode(stream)
            if state in seen and seen[state] != stream:
                return True
            seen[state] = stream
        return False


@dataclass
class InformationLossCongruence:
    """The congruence relation induced by a memory system on experience streams."""
    memory: MemorySystem
    max_length: int
    _classes: Dict[int, List[Tuple[int, ...]]] = field(default_factory=dict, init=False)

    def __post_init__(self) -> None:
        self._compute_classes()

    def _compute_classes(self) -> None:
        self._classes = defaultdict(list)
        for stream in self.memory.all_streams(self.max_length):
            state = self.memory.encode(stream)
            self._classes[state].append(stream)

    def num_classes(self) -> int:
        """Number of distinct congruence classes."""
        return len(self._classes)

    def class_sizes(self) -> Dict[int, int]:
        """Map from state to number of streams in that class."""
        return {state: len(members) for state, members in self._classes.items()}

    def largest_class_size(self) -> int:
        return max(len(m) for m in self._classes.values())

    def smallest_class_size(self) -> int:
        return min(len(m) for m in self._classes.values())

    def are_congruent(self, x: Tuple[int, ...], y: Tuple[int, ...]) -> bool:
        """Check if two streams are congruent (map to same state)."""
        return self.memory.encode(x) == self.memory.encode(y)


@dataclass
class OblivionKernel:
    """The monoid kernel: streams mapping to the identity element."""
    memory: MemorySystem
    max_length: int
    _elements: List[Tuple[int, ...]] = field(default_factory=list, init=False)

    def __post_init__(self) -> None:
        self._compute()

    def _compute(self) -> None:
        identity = self.memory.target.identity
        self._elements = []
        for stream in self.memory.all_streams(self.max_length):
            if len(stream) > 0 and self.memory.encode(stream) == identity:
                self._elements.append(stream)

    def elements(self) -> List[Tuple[int, ...]]:
        return list(self._elements)

    def size(self) -> int:
        return len(self._elements)

    def is_submonoid(self) -> bool:
        """Verify closure under concatenation (for elements within max_length)."""
        kernel_set = set(self._elements)
        identity = self.memory.target.identity
        for a in self._elements:
            for b in self._elements:
                ab = a + b
                if len(ab) <= self.max_length:
                    if self.memory.encode(ab) != identity:
                        return False
        return True

    def explicit_ghost_experiences(self) -> List[Tuple[int, Tuple[int, ...]]]:
        """Construct ghost experiences using element orders (for group targets)."""
        ghosts = []
        for symbol in self.memory.alphabet:
            img = self.memory.generator_images[symbol]
            order = self.memory.target.element_order(img)
            if order is not None and order >= 1:
                ghost = tuple([symbol] * order)
                ghosts.append((symbol, ghost))
        return ghosts


def compare_forgetting(mem1: MemorySystem, mem2: MemorySystem,
                       max_length: int = 5) -> Tuple[bool, bool]:
    """Compare two memory systems by forgetting order.

    Returns (mem1_leq_mem2, mem2_leq_mem1) where
    mem1_leq_mem2 means Con.ker(mem1) ≤ Con.ker(mem2).
    """
    streams = mem1.all_streams(max_length)

    # Check mem1 ≤ mem2
    mem1_leq_mem2 = True
    mem2_leq_mem1 = True

    # Group by mem1 encoding
    classes1: Dict[int, List[Tuple[int, ...]]] = defaultdict(list)
    classes2: Dict[int, List[Tuple[int, ...]]] = defaultdict(list)
    for s in streams:
        classes1[mem1.encode(s)].append(s)
        classes2[mem2.encode(s)].append(s)

    # mem1 ≤ mem2: if mem1(x) = mem1(y) then mem2(x) = mem2(y)
    for members in classes1.values():
        images2 = {mem2.encode(m) for m in members}
        if len(images2) > 1:
            mem1_leq_mem2 = False
            break

    # mem2 ≤ mem1: if mem2(x) = mem2(y) then mem1(x) = mem1(y)
    for members in classes2.values():
        images1 = {mem1.encode(m) for m in members}
        if len(images1) > 1:
            mem2_leq_mem1 = False
            break

    return mem1_leq_mem2, mem2_leq_mem1


def construct_forgetting_map(mem1: MemorySystem, mem2: MemorySystem,
                             max_length: int = 5) -> Optional[Dict[int, int]]:
    """Construct the forgetting map from mem1's quotient to mem2's state space.

    Only valid when Con.ker(mem1) ≤ Con.ker(mem2).
    Returns a dict mapping mem1 states to mem2 states, or None if not valid.
    """
    leq, _ = compare_forgetting(mem1, mem2, max_length)
    if not leq:
        return None

    forgetting: Dict[int, int] = {}
    for stream in mem1.all_streams(max_length):
        s1 = mem1.encode(stream)
        s2 = mem2.encode(stream)
        if s1 in forgetting:
            if forgetting[s1] != s2:
                return None  # Inconsistency
        else:
            forgetting[s1] = s2

    return forgetting


if __name__ == "__main__":
    # Example usage
    Z4 = cyclic_group(4)
    Z2 = cyclic_group(2)

    mem1 = MemorySystem(
        alphabet=[0, 1],
        target=Z4,
        generator_images={0: 1, 1: 3}
    )

    mem2 = MemorySystem(
        alphabet=[0, 1],
        target=Z2,
        generator_images={0: 1, 1: 1}
    )

    print("Memory System 1:", mem1.target.name)
    print("Memory System 2:", mem2.target.name)
    print()

    print("Is mem1 lossy?", mem1.is_lossy())
    print("Is mem2 lossy?", mem2.is_lossy())
    print()

    cong = InformationLossCongruence(mem1, max_length=4)
    print("Congruence classes (mem1, length ≤ 4):", cong.num_classes())
    print("Class sizes:", cong.class_sizes())
    print()

    kernel = OblivionKernel(mem1, max_length=5)
    print("Oblivion kernel size (mem1, length ≤ 5):", kernel.size())
    print("Is submonoid:", kernel.is_submonoid())
    print("Ghost experiences:", kernel.explicit_ghost_experiences())
    print()

    leq12, leq21 = compare_forgetting(mem1, mem2)
    print(f"mem1 ≤ mem2 (forgetting order): {leq12}")
    print(f"mem2 ≤ mem1 (forgetting order): {leq21}")
    print()

    fmap = construct_forgetting_map(mem1, mem2)
    if fmap:
        print("Forgetting map (mem1 state → mem2 state):", fmap)
