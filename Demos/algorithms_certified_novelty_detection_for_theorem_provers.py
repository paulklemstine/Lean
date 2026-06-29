#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for the Novelty Certification Framework.

Implements archive distance computation, novelty certification, batch analysis,
and archive management with full type hints and docstrings.
"""

from __future__ import annotations
import math
from dataclasses import dataclass, field
from typing import Optional


@dataclass(frozen=True)
class Descriptor:
    """
    A theorem descriptor encoding 9 syntactic/semantic features.
    
    Corresponds to the formal Lean `Descriptor` structure.
    """
    quant_depth: int = 0
    symbol_count: int = 0
    binder_count: int = 0
    has_eq: bool = False
    has_forall: bool = False
    has_exists: bool = False
    nat_arity: int = 0
    fin_arity: int = 0
    bool_arity: int = 0

    def embed(self) -> list[float]:
        """
        Embed descriptor into R^9.
        
        Maps each field to a real coordinate:
        - Natural number fields → their real value
        - Boolean fields → 1.0 (True) or 0.0 (False)
        
        Returns:
            A 9-dimensional real vector.
        """
        return [
            float(self.quant_depth),
            float(self.symbol_count),
            float(self.binder_count),
            1.0 if self.has_eq else 0.0,
            1.0 if self.has_forall else 0.0,
            1.0 if self.has_exists else 0.0,
            float(self.nat_arity),
            float(self.fin_arity),
            float(self.bool_arity),
        ]


def sup_norm(v: list[float]) -> float:
    """
    Compute the sup (L∞) norm: max_i |v_i|.
    
    Args:
        v: A real vector.
    
    Returns:
        The supremum norm.
    """
    if not v:
        return 0.0
    return max(abs(x) for x in v)


def euclidean_norm(v: list[float]) -> float:
    """
    Compute the Euclidean (L2) norm: sqrt(sum(v_i^2)).
    
    Args:
        v: A real vector.
    
    Returns:
        The Euclidean norm.
    """
    return math.sqrt(sum(x * x for x in v))


def embedding_distance(d1: Descriptor, d2: Descriptor,
                       norm_fn=sup_norm) -> float:
    """
    Compute ‖embed(d1) - embed(d2)‖.
    
    Args:
        d1: First descriptor.
        d2: Second descriptor.
        norm_fn: Norm function (default: sup_norm).
    
    Returns:
        The distance between embeddings.
    """
    e1, e2 = d1.embed(), d2.embed()
    return norm_fn([a - b for a, b in zip(e1, e2)])


@dataclass
class NoveltyCertificate:
    """
    A certificate attesting to the novelty status of a descriptor.
    
    Fields:
        is_novel: Whether the descriptor is ε-novel.
        distance: The archive distance.
        threshold: The ε threshold.
        nearest_neighbor: The closest archived descriptor (if archive nonempty).
        nearest_index: Index of nearest neighbor in the archive.
    """
    is_novel: bool
    distance: float
    threshold: float
    nearest_neighbor: Optional[Descriptor] = None
    nearest_index: Optional[int] = None

    def __repr__(self) -> str:
        status = "NOVEL" if self.is_novel else "NOT NOVEL"
        return (f"NoveltyCertificate({status}, dist={self.distance:.4f}, "
                f"ε={self.threshold:.4f})")


class TheoremArchive:
    """
    A finite archive of theorem descriptors with novelty certification.
    
    Supports:
    - Adding descriptors
    - Computing archive distances
    - Issuing novelty certificates
    - Batch novelty analysis
    
    All operations have complexity O(|archive| · dim) where dim = 9.
    """

    def __init__(self, descriptors: Optional[list[Descriptor]] = None):
        """Initialize with an optional list of descriptors."""
        self._descriptors: list[Descriptor] = list(descriptors) if descriptors else []
        self._descriptor_set: set[Descriptor] = set(self._descriptors)

    @property
    def size(self) -> int:
        """Number of descriptors in the archive."""
        return len(self._descriptors)

    @property
    def is_nonempty(self) -> bool:
        """Whether the archive is nonempty."""
        return len(self._descriptors) > 0

    def add(self, d: Descriptor) -> bool:
        """
        Add a descriptor to the archive.
        
        Returns True if the descriptor was new, False if already present.
        """
        if d in self._descriptor_set:
            return False
        self._descriptors.append(d)
        self._descriptor_set.add(d)
        return True

    def contains(self, d: Descriptor) -> bool:
        """Check if a descriptor is in the archive."""
        return d in self._descriptor_set

    def archive_dist(self, d: Descriptor) -> tuple[float, Optional[Descriptor], Optional[int]]:
        """
        Compute the archive distance of d and return the nearest neighbor.
        
        Implements the formal `archiveDist` definition:
        - Returns 0 if archive is empty
        - Returns inf_{a ∈ A} ‖embed(d) - embed(a)‖ otherwise
        
        Returns:
            (distance, nearest_descriptor, nearest_index)
        """
        if not self._descriptors:
            return 0.0, None, None

        best_dist = float('inf')
        best_desc = None
        best_idx = None

        for i, a in enumerate(self._descriptors):
            dist = embedding_distance(d, a)
            if dist < best_dist:
                best_dist = dist
                best_desc = a
                best_idx = i

        return best_dist, best_desc, best_idx

    def certify(self, d: Descriptor, epsilon: float) -> NoveltyCertificate:
        """
        Issue a novelty certificate for descriptor d at threshold ε.
        
        By the Novelty Certificate Theorem (novelty_certificate_iff),
        this is equivalent to checking ∀ a ∈ A, ε ≤ ‖embed(d) - embed(a)‖.
        
        Args:
            d: Candidate descriptor.
            epsilon: Novelty threshold.
        
        Returns:
            A NoveltyCertificate.
        """
        dist, nearest, idx = self.archive_dist(d)
        return NoveltyCertificate(
            is_novel=(epsilon <= dist),
            distance=dist,
            threshold=epsilon,
            nearest_neighbor=nearest,
            nearest_index=idx,
        )

    def batch_certify(self, candidates: list[Descriptor],
                      epsilon: float) -> list[tuple[Descriptor, NoveltyCertificate]]:
        """
        Certify novelty for a batch of candidates.
        
        Returns results sorted by distance (most novel first).
        """
        results = [(d, self.certify(d, epsilon)) for d in candidates]
        results.sort(key=lambda x: x[1].distance, reverse=True)
        return results

    def coverage_radius(self) -> float:
        """
        Compute the coverage radius: max_{a ∈ A} min_{b ∈ A, b ≠ a} ‖embed(a) - embed(b)‖.
        
        This is the maximum nearest-neighbor distance within the archive,
        characterizing how "spread out" the archive is.
        """
        if len(self._descriptors) <= 1:
            return 0.0

        max_nn_dist = 0.0
        for i, a in enumerate(self._descriptors):
            min_dist = float('inf')
            for j, b in enumerate(self._descriptors):
                if i != j:
                    dist = embedding_distance(a, b)
                    if dist < min_dist:
                        min_dist = dist
            max_nn_dist = max(max_nn_dist, min_dist)
        return max_nn_dist

    def pairwise_distances(self) -> list[tuple[int, int, float]]:
        """
        Compute all pairwise distances between archived descriptors.
        
        Returns:
            List of (i, j, distance) for all i < j.
        """
        result = []
        n = len(self._descriptors)
        for i in range(n):
            for j in range(i + 1, n):
                dist = embedding_distance(self._descriptors[i], self._descriptors[j])
                result.append((i, j, dist))
        result.sort(key=lambda x: x[2])
        return result


def verify_lipschitz(archive: TheoremArchive, d1: Descriptor,
                     d2: Descriptor) -> dict:
    """
    Verify the Lipschitz transfer inequality for two descriptors.
    
    The formal theorem states:
        archiveDist(A, d₁) - ‖embed(d₁) - embed(d₂)‖ ≤ archiveDist(A, d₂)
    
    Returns a dict with the computation and verification result.
    """
    dist1, _, _ = archive.archive_dist(d1)
    dist2, _, _ = archive.archive_dist(d2)
    emb_dist = embedding_distance(d1, d2)

    lhs = dist1 - emb_dist
    holds = lhs <= dist2 + 1e-10  # numerical tolerance

    return {
        "archiveDist_d1": dist1,
        "archiveDist_d2": dist2,
        "embedding_distance": emb_dist,
        "lhs": lhs,
        "rhs": dist2,
        "lipschitz_holds": holds,
    }


# ─────────────────────────────────────────────────────────────────────
# Example Usage
# ─────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    # Create an archive of "known theorems"
    archive = TheoremArchive([
        Descriptor(2, 5, 3, True, True, True, 2, 0, 0),
        Descriptor(1, 3, 1, True, True, False, 1, 0, 0),
        Descriptor(1, 4, 2, True, True, False, 2, 0, 0),
        Descriptor(0, 2, 0, True, False, False, 0, 0, 1),
    ])

    print(f"Archive size: {archive.size}")
    print(f"Coverage radius: {archive.coverage_radius():.2f}")

    # Certify a candidate
    candidate = Descriptor(3, 8, 4, True, True, True, 1, 2, 0)
    cert = archive.certify(candidate, epsilon=2.0)
    print(f"\nCertificate: {cert}")

    # Batch certification
    import random
    random.seed(42)
    candidates = [Descriptor(
        random.randint(0, 5), random.randint(1, 20),
        random.randint(0, 10), random.choice([True, False]),
        random.choice([True, False]), random.choice([True, False]),
        random.randint(0, 5), random.randint(0, 5), random.randint(0, 5),
    ) for _ in range(5)]

    results = archive.batch_certify(candidates, epsilon=3.0)
    print("\nBatch results (sorted by distance, most novel first):")
    for d, c in results:
        print(f"  {c}")
