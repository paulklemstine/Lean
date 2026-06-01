"""
Memory Algebra: Algorithms for Memory Systems over Finite Monoids

This module implements the core algorithms for constructing, simulating,
and analyzing memory systems as monoid homomorphisms from free monoids
to finite monoids.
"""

from typing import Dict, List, Set, Tuple, Optional
from dataclasses import dataclass, field
from collections import defaultdict
from itertools import product


@dataclass
class FiniteMonoid:
    """A finite monoid defined by its multiplication table.

    Elements are integers 0..n-1, with 0 as the identity by convention.
    """
    size: int
    table: List[List[int]]  # table[i][j] = i * j
    identity: int = 0

    def mul(self, a: int, b: int) -> int:
        """Multiply two elements."""
        return self.table[a][b]

    def mul_list(self, elements: List[int]) -> int:
        """Multiply a list of elements left to right."""
        result = self.identity
        for e in elements:
            result = self.mul(result, e)
        return result

    def validate(self) -> bool:
        """Check associativity and identity laws."""
        n = self.size
        # Check identity
        for i in range(n):
            if self.mul(self.identity, i) != i or self.mul(i, self.identity) != i:
                return False
        # Check associativity (exhaustive for small monoids)
        for a in range(n):
            for b in range(n):
                for c in range(n):
                    if self.mul(self.mul(a, b), c) != self.mul(a, self.mul(b, c)):
                        return False
        return True


def cyclic_monoid(n: int) -> FiniteMonoid:
    """Construct the cyclic group Z/nZ as a monoid."""
    table = [[(i + j) % n for j in range(n)] for i in range(n)]
    return FiniteMonoid(size=n, table=table, identity=0)


def trivial_monoid() -> FiniteMonoid:
    """The trivial monoid with one element (total amnesia)."""
    return FiniteMonoid(size=1, table=[[0]], identity=0)


@dataclass
class MemorySystem:
    """A memory system: monoid homomorphism from FreeMonoid(alphabet) to a finite monoid.

    Determined by the images of the generators (alphabet symbols).
    """
    alphabet_size: int
    monoid: FiniteMonoid
    generator_images: List[int]  # generator_images[i] = φ(letter i)

    def encode(self, stream: List[int]) -> int:
        """Encode an experience stream to a memory state.

        Args:
            stream: List of alphabet indices representing the experience stream.

        Returns:
            The memory state (element of the monoid).
        """
        return self.monoid.mul_list([self.generator_images[s] for s in stream])

    def is_confused(self, x: List[int], y: List[int]) -> bool:
        """Check if two experience streams are confused (map to same state)."""
        return self.encode(x) == self.encode(y)


def enumerate_streams(alphabet_size: int, max_length: int) -> List[List[int]]:
    """Enumerate all streams over the alphabet up to a given length."""
    streams: List[List[int]] = []
    for length in range(max_length + 1):
        for stream in product(range(alphabet_size), repeat=length):
            streams.append(list(stream))
    return streams


def compute_confusion_classes(
    sys: MemorySystem,
    max_length: int
) -> Dict[int, List[List[int]]]:
    """Compute confusion classes for streams up to a given length.

    Returns:
        Dict mapping memory states to lists of streams that map to that state.
    """
    classes: Dict[int, List[List[int]]] = defaultdict(list)
    for stream in enumerate_streams(sys.alphabet_size, max_length):
        state = sys.encode(stream)
        classes[state].append(stream)
    return dict(classes)


def count_confusion_classes(sys: MemorySystem, max_length: int) -> int:
    """Count the number of distinct confusion classes up to a given stream length."""
    return len(compute_confusion_classes(sys, max_length))


def detect_lossiness(sys: MemorySystem, max_length: int) -> Optional[Tuple[List[int], List[int]]]:
    """Find two distinct streams that are confused, if any exist up to max_length.

    Returns:
        A pair of confused distinct streams, or None if no confusion found.
    """
    seen: Dict[int, List[int]] = {}
    for stream in enumerate_streams(sys.alphabet_size, max_length):
        state = sys.encode(stream)
        if state in seen and seen[state] != stream:
            return (seen[state], stream)
        seen[state] = stream
    return None


def compose_memory_system(
    sys: MemorySystem,
    target_monoid: FiniteMonoid,
    hom: List[int]  # hom[i] = image of monoid element i in target
) -> MemorySystem:
    """Compose a memory system with a monoid homomorphism.

    Args:
        sys: Original memory system.
        target_monoid: Target monoid for composition.
        hom: The homomorphism as a list mapping source elements to target elements.

    Returns:
        The composed memory system.
    """
    new_images = [hom[g] for g in sys.generator_images]
    return MemorySystem(
        alphabet_size=sys.alphabet_size,
        monoid=target_monoid,
        generator_images=new_images
    )


def compute_kernel(sys: MemorySystem, max_length: int) -> List[List[int]]:
    """Find all streams up to max_length that map to the identity.

    These are the "perfectly forgotten" experiences.
    """
    identity = sys.monoid.identity
    kernel = []
    for stream in enumerate_streams(sys.alphabet_size, max_length):
        if sys.encode(stream) == identity:
            kernel.append(stream)
    return kernel


def verify_congruence_property(
    sys: MemorySystem, max_length: int
) -> bool:
    """Verify the congruence property: if x~y then zx~zy and xz~yz for all z.

    Tests exhaustively up to max_length.
    """
    streams = enumerate_streams(sys.alphabet_size, max_length)

    # Find all confused pairs
    confused_pairs: List[Tuple[List[int], List[int]]] = []
    for i, x in enumerate(streams):
        for j, y in enumerate(streams):
            if i < j and sys.is_confused(x, y):
                confused_pairs.append((x, y))

    # Check congruence for each confused pair and each context
    contexts = enumerate_streams(sys.alphabet_size, max(0, max_length - 1))
    for x, y in confused_pairs:
        for z in contexts:
            # Right congruence: x~y => xz~yz
            if not sys.is_confused(x + z, y + z):
                return False
            # Left congruence: x~y => zx~zy
            if not sys.is_confused(z + x, z + y):
                return False
    return True


def memory_capacity_analysis(sys: MemorySystem, max_length: int) -> dict:
    """Analyze the capacity of a memory system.

    Returns:
        Dictionary with capacity metrics.
    """
    classes = compute_confusion_classes(sys, max_length)
    total_streams = sum(len(v) for v in classes.values())
    num_classes = len(classes)
    max_class_size = max(len(v) for v in classes.values()) if classes else 0
    min_class_size = min(len(v) for v in classes.values()) if classes else 0

    return {
        "total_streams": total_streams,
        "num_confusion_classes": num_classes,
        "monoid_size": sys.monoid.size,
        "capacity_ratio": num_classes / sys.monoid.size if sys.monoid.size > 0 else 0,
        "max_class_size": max_class_size,
        "min_class_size": min_class_size,
        "compression_ratio": total_streams / num_classes if num_classes > 0 else float('inf'),
    }


def forgetting_lattice_comparison(
    sys1: MemorySystem,
    sys2: MemorySystem,
    max_length: int
) -> dict:
    """Compare two memory systems in the forgetting lattice.

    Returns:
        Dictionary indicating the lattice relationship.
    """
    streams = enumerate_streams(sys1.alphabet_size, max_length)

    sys1_coarser = True  # sys1's confusion contains sys2's
    sys2_coarser = True  # sys2's confusion contains sys1's

    for i, x in enumerate(streams):
        for j, y in enumerate(streams):
            if i < j:
                c1 = sys1.is_confused(x, y)
                c2 = sys2.is_confused(x, y)
                if c1 and not c2:
                    sys2_coarser = False
                if c2 and not c1:
                    sys1_coarser = False

    if sys1_coarser and sys2_coarser:
        relationship = "equivalent"
    elif sys1_coarser:
        relationship = "sys1 is coarser (forgets more)"
    elif sys2_coarser:
        relationship = "sys2 is coarser (forgets more)"
    else:
        relationship = "incomparable"

    return {
        "relationship": relationship,
        "sys1_coarser": sys1_coarser,
        "sys2_coarser": sys2_coarser,
    }
