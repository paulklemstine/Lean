"""
Fiber Geometry: Core Algorithms

Type-hinted implementations of the key algorithms from the fiber geometry theory.
"""

from __future__ import annotations
import math
from collections import Counter
from typing import Callable, Dict, Generic, List, Optional, Set, Tuple, TypeVar

T = TypeVar('T')
S = TypeVar('S')
R = TypeVar('R')


class FiberProfile:
    """The fiber profile of a function: the multiset of preimage sizes.

    Given a function f : domain → codomain, the fiber profile records
    how many domain elements map to each codomain element.
    """

    def __init__(self, sizes: List[int]):
        """Initialize from a list of nonzero fiber sizes."""
        self.sizes = sorted([s for s in sizes if s > 0], reverse=True)
        self._total = sum(self.sizes)

    @classmethod
    def from_function(cls, f: Callable[[T], S], domain: List[T]) -> 'FiberProfile':
        """Compute the fiber profile of f on the given domain."""
        counter: Counter[S] = Counter()
        for x in domain:
            counter[f(x)] += 1
        return cls(list(counter.values()))

    @property
    def domain_size(self) -> int:
        """Total domain size = sum of all fiber sizes."""
        return self._total

    @property
    def image_size(self) -> int:
        """Image size = number of nonempty fibers."""
        return len(self.sizes)

    @property
    def deficiency(self) -> int:
        """deficiency = |domain| - |image|, measuring information loss."""
        return self._total - len(self.sizes)

    @property
    def max_fiber(self) -> int:
        """Maximum fiber cardinality."""
        return self.sizes[0] if self.sizes else 0

    @property
    def min_fiber(self) -> int:
        """Minimum fiber cardinality."""
        return self.sizes[-1] if self.sizes else 0

    @property
    def is_injective(self) -> bool:
        """True iff all fibers have size 1 (deficiency = 0)."""
        return self.deficiency == 0

    @property
    def is_balanced(self) -> bool:
        """True iff all fibers have equal size."""
        return len(set(self.sizes)) <= 1

    def depth_bound(self) -> int:
        """Information-theoretic depth bound = floor(log2(maxFiber))."""
        mf = self.max_fiber
        return int(math.log2(mf)) if mf > 1 else 0

    def landauer_bits(self) -> float:
        """Information erased, in bits = log2(domain) - log2(image)."""
        if self.image_size == 0 or self.domain_size == 0:
            return 0.0
        return math.log2(self.domain_size) - math.log2(self.image_size)

    def landauer_cost(self, kT: float) -> float:
        """Landauer erasure cost in joules = kT * ln(2) * bits_erased."""
        return kT * math.log(2) * self.landauer_bits()

    def min_aux_space(self) -> int:
        """Minimum auxiliary space for reversible computation = maxFiber."""
        return self.max_fiber

    def shannon_entropy(self) -> float:
        """Shannon entropy of the normalized fiber profile."""
        if self._total == 0:
            return 0.0
        probs = [s / self._total for s in self.sizes]
        return -sum(p * math.log2(p) for p in probs if p > 0)

    def __repr__(self) -> str:
        return f"FiberProfile({self.sizes})"


class RevWitness:
    """A reversible computation witness.

    For a function f : domain → codomain, a RevWitness provides:
    - An encoding: domain → codomain × aux_space
    - Such that the first component recovers f
    - And the encoding is a bijection (invertible)
    """

    def __init__(
        self,
        encode: Callable[[T], Tuple[S, int]],
        decode: Callable[[Tuple[S, int]], T],
        aux_size: int
    ):
        self.encode = encode
        self.decode = decode
        self.aux_size = aux_size

    @classmethod
    def from_fiber_history(
        cls,
        f: Callable[[T], S],
        domain: List[T]
    ) -> 'RevWitness':
        """Construct a RevWitness by recording fiber index as auxiliary data.

        This is the Bennett construction: for each output y, number the
        elements of f^{-1}(y) as 0, 1, 2, ... and use this index as
        the auxiliary data.
        """
        # Group domain by output
        fibers: Dict[S, List[T]] = {}
        for x in domain:
            y = f(x)
            fibers.setdefault(y, []).append(x)

        # Create encoding: x -> (f(x), index within fiber)
        element_to_index: Dict[T, int] = {}  # type: ignore
        for y, fiber in fibers.items():
            for i, x in enumerate(fiber):
                element_to_index[x] = i  # type: ignore

        # Create decoding: (y, index) -> x
        decode_map: Dict[Tuple[S, int], T] = {}
        for y, fiber in fibers.items():
            for i, x in enumerate(fiber):
                decode_map[(y, i)] = x

        max_fiber = max(len(fiber) for fiber in fibers.values())

        def encode(x: T) -> Tuple[S, int]:
            return (f(x), element_to_index[x])  # type: ignore

        def decode(pair: Tuple[S, int]) -> T:
            return decode_map[pair]

        return cls(encode, decode, max_fiber)

    def verify(self, domain: List[T], f: Callable[[T], S]) -> bool:
        """Verify that the witness is correct: decode(encode(x)) = x for all x."""
        for x in domain:
            pair = self.encode(x)
            if pair[0] != f(x):
                return False
            if self.decode(pair) != x:
                return False
        return True


def compose_witnesses(
    wf: RevWitness, wg: RevWitness
) -> RevWitness:
    """Compose two RevWitnesses. Auxiliary space is multiplicative."""
    def encode(x: T) -> Tuple[R, Tuple[int, int]]:
        y, aux_f = wf.encode(x)
        z, aux_g = wg.encode(y)
        return (z, (aux_f, aux_g))

    def decode(pair: Tuple[R, Tuple[int, int]]) -> T:
        z, (aux_f, aux_g) = pair
        y = wg.decode((z, aux_g))
        return wf.decode((y, aux_f))

    return RevWitness(encode, decode, wf.aux_size * wg.aux_size)


def verify_fiber_partition(f: Callable[[int], int], domain: List[int]) -> bool:
    """Verify that sum of fiber sizes = domain size."""
    profile = FiberProfile.from_function(f, domain)
    return sum(profile.sizes) == len(domain)


def verify_deficiency_monotonicity(
    f: Callable[[int], int],
    g: Callable[[int], int],
    domain: List[int]
) -> bool:
    """Verify that deficiency(f) <= deficiency(g ∘ f)."""
    gf = lambda x: g(f(x))
    pf = FiberProfile.from_function(f, domain)
    pgf = FiberProfile.from_function(gf, domain)
    return pf.deficiency <= pgf.deficiency


def verify_pigeonhole(
    f: Callable[[int], int],
    domain: List[int],
    codomain_size: int
) -> bool:
    """Verify that maxFiber(f) >= |domain| / |codomain|."""
    profile = FiberProfile.from_function(f, domain)
    return profile.max_fiber >= len(domain) // codomain_size


if __name__ == "__main__":
    # Quick test
    domain = list(range(24))

    # Balanced surjection
    f = lambda x: x % 6
    profile = FiberProfile.from_function(f, domain)
    print(f"f(x) = x mod 6 on {{0,...,23}}:")
    print(f"  Profile: {profile}")
    print(f"  Deficiency: {profile.deficiency}")
    print(f"  MaxFiber: {profile.max_fiber}")
    print(f"  Depth bound: {profile.depth_bound()}")
    print(f"  Landauer bits: {profile.landauer_bits():.4f}")
    print(f"  Min aux space: {profile.min_aux_space()}")
    print(f"  Balanced: {profile.is_balanced}")

    # Build and verify a RevWitness
    witness = RevWitness.from_fiber_history(f, domain)
    print(f"\n  RevWitness aux_size: {witness.aux_size}")
    print(f"  Witness valid: {witness.verify(domain, f)}")

    # Verify invariants
    print(f"\n  Fiber partition: {verify_fiber_partition(f, domain)}")
    g = lambda x: x % 3
    print(f"  Deficiency monotonicity: {verify_deficiency_monotonicity(f, g, domain)}")
    print(f"  Pigeonhole: {verify_pigeonhole(f, domain, 6)}")
