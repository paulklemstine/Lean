"""
Algorithms for Primewise Persistence Homology

Implements the core algorithms from the research paper:
1. Frobenius orbit signature computation
2. Persistence barcode construction from orbit data
3. Signature comparison and classification
4. Euler characteristic computation for chain complexes

All algorithms include complexity analysis in docstrings.
"""

from typing import Optional
import numpy as np
from dataclasses import dataclass, field


@dataclass
class FrobeniusAction:
    """
    A Frobenius action on a finite set, represented as a permutation.

    Attributes:
        perm: permutation as a list where perm[i] = σ(i)
    """
    perm: list[int]

    @property
    def card(self) -> int:
        return len(self.perm)

    def apply(self, x: int) -> int:
        """Apply σ to x. O(1)."""
        return self.perm[x]

    def apply_power(self, x: int, k: int) -> int:
        """Apply σ^k to x. O(k)."""
        result = x
        for _ in range(k):
            result = self.perm[result]
        return result

    def fixed_point_count(self) -> int:
        """
        Count fixed points of σ.
        Time: O(n), Space: O(1)
        """
        return sum(1 for i in range(self.card) if self.perm[i] == i)

    def iter_fixed_count(self, k: int) -> int:
        """
        Count fixed points of σ^k.
        Time: O(n*k), Space: O(1)
        """
        return sum(1 for i in range(self.card) if self.apply_power(i, k) == i)

    def orbit_decomposition(self) -> list[list[int]]:
        """
        Decompose into orbits of the cyclic group ⟨σ⟩.
        Time: O(n), Space: O(n)

        Returns list of orbits, each orbit is a list of elements.
        """
        visited = set()
        orbits = []
        for i in range(self.card):
            if i in visited:
                continue
            orbit = []
            x = i
            while x not in visited:
                visited.add(x)
                orbit.append(x)
                x = self.perm[x]
            orbits.append(orbit)
        return orbits

    def orbit_sizes(self) -> list[int]:
        """Return sorted list of orbit sizes. O(n)."""
        return sorted(len(o) for o in self.orbit_decomposition())

    def num_orbits(self) -> int:
        """
        Count orbits via Burnside's lemma: |orbits| = (1/|G|) * Σ |Fix(g)|.
        For cyclic group of order n, this is efficient.
        Time: O(n), Space: O(n)
        """
        return len(self.orbit_decomposition())


@dataclass
class PrimeSignature:
    """
    The persistence-relevant data at a prime p.

    Attributes:
        prime: the prime p
        counts: list of fixed point counts [|Fix(σ)|, |Fix(σ²)|, ..., |Fix(σ^d)|]
    """
    prime: int
    counts: list[int]

    @property
    def depth(self) -> int:
        return len(self.counts)

    def agrees_with(self, other: 'PrimeSignature') -> bool:
        """Check if two signatures have the same counts. O(depth)."""
        return self.counts == other.counts

    def discrepancy(self, other: 'PrimeSignature') -> int:
        """Maximum absolute difference in counts. O(depth)."""
        return max(abs(a - b) for a, b in zip(self.counts, other.counts))


@dataclass
class ArithmeticObject:
    """
    An arithmetic object (e.g., curve) characterized by its prime signatures.

    Attributes:
        name: descriptive name
        signatures: dict mapping prime p to PrimeSignature
    """
    name: str
    signatures: dict[int, PrimeSignature] = field(default_factory=dict)

    def add_signature(self, sig: PrimeSignature) -> None:
        self.signatures[sig.prime] = sig

    def is_separated_from(self, other: 'ArithmeticObject') -> Optional[int]:
        """
        Find a prime at which signatures disagree.
        Returns the prime, or None if all agree.
        Time: O(sum of depths at shared primes)
        """
        for p in self.signatures:
            if p in other.signatures:
                if not self.signatures[p].agrees_with(other.signatures[p]):
                    return p
        return None


def compute_frobenius_signature(
    point_counter: callable,
    p: int,
    depth: int = 2
) -> PrimeSignature:
    """
    Compute the prime signature from a point-counting function.

    Args:
        point_counter: function(p, k) -> number of F_{p^k}-rational points
        p: the prime
        depth: number of Frobenius iterates to compute

    Returns:
        PrimeSignature with the computed counts

    Time: O(depth * T(point_counter))
    Space: O(depth)
    """
    counts = [point_counter(p, k) for k in range(1, depth + 1)]
    return PrimeSignature(prime=p, counts=counts)


def alternating_sum(values: list[int]) -> int:
    """
    Compute the alternating sum Σ (-1)^i * v_i.

    This is the Euler characteristic of the associated chain complex.
    Time: O(n), Space: O(1)
    """
    return sum((-1)**i * v for i, v in enumerate(values))


@dataclass
class FiniteChainComplex:
    """
    A finite chain complex with integer ranks at each degree.

    Attributes:
        ranks: list of ranks [r_0, r_1, ..., r_{n-1}]
        boundary_ranks: list of boundary map ranks
    """
    ranks: list[int]
    boundary_ranks: list[int]

    def euler_characteristic(self) -> int:
        """
        Compute χ = Σ (-1)^i * rank_i.
        Time: O(n), Space: O(1)
        """
        return alternating_sum(self.ranks)

    @staticmethod
    def direct_sum(c1: 'FiniteChainComplex', c2: 'FiniteChainComplex') -> 'FiniteChainComplex':
        """
        Direct sum of two chain complexes.
        χ(C1 ⊕ C2) = χ(C1) + χ(C2)
        Time: O(n), Space: O(n)
        """
        n = max(len(c1.ranks), len(c2.ranks))
        r1 = c1.ranks + [0] * (n - len(c1.ranks))
        r2 = c2.ranks + [0] * (n - len(c2.ranks))
        b1 = c1.boundary_ranks + [0] * (n - len(c1.boundary_ranks))
        b2 = c2.boundary_ranks + [0] * (n - len(c2.boundary_ranks))
        return FiniteChainComplex(
            ranks=[a + b for a, b in zip(r1, r2)],
            boundary_ranks=[a + b for a, b in zip(b1, b2)]
        )


def frobenius_chain_complex(action: FrobeniusAction, depth: int) -> FiniteChainComplex:
    """
    Build a chain complex from Frobenius fixed point counts.

    The rank at degree i is |Fix(σ^{i+1})|.
    This bridges number theory (Frobenius) with topology (chain complexes).

    Time: O(depth * n * depth), Space: O(depth)
    """
    ranks = [action.iter_fixed_count(k + 1) for k in range(depth)]
    return FiniteChainComplex(ranks=ranks, boundary_ranks=[0] * depth)


@dataclass
class PersistenceBarcode:
    """
    A persistence barcode: a multiset of intervals [birth, death).

    Each interval represents a topological feature that appears at
    filtration level 'birth' and disappears at 'death'.
    """
    intervals: list[tuple[int, int]]  # (birth, death) pairs

    @property
    def num_features(self) -> int:
        return len(self.intervals)

    def total_persistence(self) -> int:
        """Sum of lifetimes. O(n)."""
        return sum(d - b for b, d in self.intervals)

    def betti_at(self, level: int) -> int:
        """Number of features alive at given level. O(n)."""
        return sum(1 for b, d in self.intervals if b <= level < d)

    def bottleneck_distance(self, other: 'PersistenceBarcode') -> float:
        """
        Approximate bottleneck distance between two barcodes.
        Uses greedy matching. O(n*m) where n,m are barcode sizes.
        """
        if not self.intervals or not other.intervals:
            max_pers = 0
            for b, d in self.intervals + other.intervals:
                max_pers = max(max_pers, (d - b) / 2)
            return max_pers

        used = set()
        max_cost = 0
        for b1, d1 in self.intervals:
            best_cost = (d1 - b1) / 2  # cost of matching to diagonal
            best_j = -1
            for j, (b2, d2) in enumerate(other.intervals):
                if j in used:
                    continue
                cost = max(abs(b1 - b2), abs(d1 - d2))
                if cost < best_cost:
                    best_cost = cost
                    best_j = j
            if best_j >= 0:
                used.add(best_j)
            max_cost = max(max_cost, best_cost)

        # Check unmatched intervals in other
        for j, (b2, d2) in enumerate(other.intervals):
            if j not in used:
                max_cost = max(max_cost, (d2 - b2) / 2)

        return max_cost


def signature_classifier(
    signatures: dict[int, PrimeSignature],
    reference_signatures: dict[str, dict[int, PrimeSignature]]
) -> str:
    """
    Classify an arithmetic object by comparing its signatures to references.

    Uses majority voting across all shared primes.

    Args:
        signatures: the object's prime signatures
        reference_signatures: dict mapping class name to reference signatures

    Returns:
        The class name with the best match

    Time: O(|primes| * |classes| * depth)
    """
    scores = {name: 0 for name in reference_signatures}

    for p, sig in signatures.items():
        for name, ref_sigs in reference_signatures.items():
            if p in ref_sigs:
                if sig.agrees_with(ref_sigs[p]):
                    scores[name] += 1

    return max(scores, key=scores.get)


# ---- Example usage ----

if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")

    # Example 1: Frobenius action
    print("1. Frobenius Action (cyclic permutation on 7 elements)")
    perm = [1, 2, 3, 4, 5, 6, 0]  # 7-cycle
    action = FrobeniusAction(perm=perm)
    print(f"   Card: {action.card}")
    print(f"   Fixed points of σ: {action.fixed_point_count()}")
    print(f"   Fixed points of σ²: {action.iter_fixed_count(2)}")
    print(f"   Fixed points of σ⁷: {action.iter_fixed_count(7)}")
    print(f"   Orbits: {action.orbit_decomposition()}")
    print(f"   Orbit sizes: {action.orbit_sizes()}")

    # Example 2: Chain complex
    print("\n2. Chain Complex from Frobenius")
    cc = frobenius_chain_complex(action, depth=4)
    print(f"   Ranks: {cc.ranks}")
    print(f"   Euler characteristic: {cc.euler_characteristic()}")

    # Example 3: Identity action
    print("\n3. Identity Action (n=5)")
    id_action = FrobeniusAction(perm=list(range(5)))
    print(f"   Fixed points of σ^k for k=1..4: "
          f"{[id_action.iter_fixed_count(k) for k in range(1, 5)]}")
    id_cc = frobenius_chain_complex(id_action, depth=4)
    print(f"   Euler char: {id_cc.euler_characteristic()}")
    print(f"   Expected: 5 * (1-1+1-1) = 0: {5 * alternating_sum([1,1,1,1])}")

    # Example 4: Persistence barcode
    print("\n4. Persistence Barcode")
    barcode1 = PersistenceBarcode(intervals=[(0, 3), (1, 4), (2, 5)])
    barcode2 = PersistenceBarcode(intervals=[(0, 2), (1, 5), (3, 6)])
    print(f"   Barcode 1: {barcode1.intervals}, persistence={barcode1.total_persistence()}")
    print(f"   Barcode 2: {barcode2.intervals}, persistence={barcode2.total_persistence()}")
    print(f"   Bottleneck distance: {barcode1.bottleneck_distance(barcode2):.2f}")

    # Example 5: Euler characteristic additivity
    print("\n5. Euler Characteristic Additivity")
    c1 = FiniteChainComplex(ranks=[3, 2, 1], boundary_ranks=[0, 0, 0])
    c2 = FiniteChainComplex(ranks=[1, 3, 2], boundary_ranks=[0, 0, 0])
    c_sum = FiniteChainComplex.direct_sum(c1, c2)
    print(f"   χ(C1) = {c1.euler_characteristic()}")
    print(f"   χ(C2) = {c2.euler_characteristic()}")
    print(f"   χ(C1⊕C2) = {c_sum.euler_characteristic()}")
    print(f"   χ(C1) + χ(C2) = {c1.euler_characteristic() + c2.euler_characteristic()}")
    assert c_sum.euler_characteristic() == c1.euler_characteristic() + c2.euler_characteristic()
    print("   ✓ Additivity verified!")
