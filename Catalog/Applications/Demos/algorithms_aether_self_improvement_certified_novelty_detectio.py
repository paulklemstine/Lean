#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Certified Novelty Detection

Implements the core algorithms from the novelty certification framework:
  1. NoveltyCertifier: sound certification via nearest-neighbor distance
  2. FeatureGapAnalyzer: coordinate-wise obstruction certificates
  3. CatalogManager: catalog construction with separation verification
  4. PackingAnalyzer: region counting and packing bounds
"""

import numpy as np
from dataclasses import dataclass, field
from typing import List, Tuple, Optional, Dict, Callable
from itertools import combinations


@dataclass
class TheoremDescriptor:
    """Theorem descriptor with embedding into ℝⁿ.

    Attributes:
        name: Human-readable theorem identifier.
        features: Dict mapping feature names to numeric values.
    """
    name: str
    features: Dict[str, float]

    def to_vector(self, feature_order: List[str]) -> np.ndarray:
        """Embed into ℝⁿ using the given feature ordering."""
        return np.array([self.features.get(f, 0.0) for f in feature_order])


class NoveltyCertifier:
    """Sound novelty certification via nearest-neighbor distance.

    Algorithm (Nearest-Neighbor Novelty Certification):
        Input: candidate x, catalog K, equivalence radius δ, embedding E
        Output: (is_novel: bool, certificate: str)

        1. Compute d_min = min_{a ∈ K} dist(E(x), E(a))
        2. If d_min > δ: return (True, "certified novel")
        3. Else: return (False, "not certifiably novel")

    Soundness Guarantee (Theorem novelty_of_nearestDist_gt):
        If ∀ x y, Equivalent x y → dist(E x, E y) ≤ δ,
        and δ < nearestDist(E, K, x),
        then x is novel (not equivalent to any a ∈ K).

    Time complexity: O(|K| · dim) where dim is the embedding dimension.
    Space complexity: O(|K| · dim) for storing the catalog embeddings.
    """

    def __init__(self, feature_order: List[str], delta: float):
        """
        Args:
            feature_order: List of feature names defining the embedding.
            delta: Equivalence radius — maximum dist between equivalent theorems.
        """
        self.feature_order = feature_order
        self.delta = delta
        self.catalog: List[TheoremDescriptor] = []
        self._catalog_vectors: Optional[np.ndarray] = None

    def add_to_catalog(self, descriptor: TheoremDescriptor) -> None:
        """Add a theorem descriptor to the catalog."""
        self.catalog.append(descriptor)
        self._catalog_vectors = None  # invalidate cache

    def _ensure_vectors(self) -> np.ndarray:
        if self._catalog_vectors is None:
            self._catalog_vectors = np.array([
                d.to_vector(self.feature_order) for d in self.catalog
            ])
        return self._catalog_vectors

    def nearest_distance(self, candidate: TheoremDescriptor) -> Tuple[float, int]:
        """Compute nearest-neighbor distance and index.

        Returns:
            (distance, index) where index is the index into self.catalog.
        """
        vectors = self._ensure_vectors()
        v = candidate.to_vector(self.feature_order)
        dists = np.linalg.norm(vectors - v, axis=1)
        idx = np.argmin(dists)
        return float(dists[idx]), int(idx)

    def certify(self, candidate: TheoremDescriptor) -> Tuple[bool, float, str]:
        """Certify novelty of a candidate.

        Returns:
            (is_novel, novelty_score, explanation)

        Soundness: If is_novel is True, then by Theorem novelty_of_nearestDist_gt,
        the candidate is provably non-equivalent to every catalog theorem
        (assuming the embedding soundness axiom holds with radius δ).
        """
        if len(self.catalog) == 0:
            return True, float('inf'), "Empty catalog — trivially novel"

        score, idx = self.nearest_distance(candidate)
        nearest = self.catalog[idx]

        if score > self.delta:
            return True, score, (
                f"CERTIFIED NOVEL: noveltyScore = {score:.4f} > δ = {self.delta:.4f}. "
                f"Nearest: '{nearest.name}' at distance {score:.4f}."
            )
        else:
            return False, score, (
                f"NOT CERTIFIABLY NOVEL: noveltyScore = {score:.4f} ≤ δ = {self.delta:.4f}. "
                f"Nearest: '{nearest.name}' at distance {score:.4f}."
            )


class FeatureGapAnalyzer:
    """Coordinate-wise obstruction certificate generator.

    Algorithm (Feature-Gap Obstruction):
        Input: descriptors x, y, feature f, tolerance δ_f
        Output: (obstructs: bool, gap: float)

        1. Compute gap = |f(x) - f(y)|
        2. If gap > δ_f: return (True, gap)  — certified non-equivalent
        3. Else: return (False, gap)

    Soundness Guarantee (Theorem not_equivalent_of_coordinate_gap):
        If ∀ x y, Equivalent x y → |f(x) - f(y)| ≤ δ,
        and δ < |f(x) - f(y)|,
        then ¬ Equivalent x y.

    Time complexity: O(1) per feature check.
    """

    def __init__(self, feature_tolerances: Dict[str, float]):
        """
        Args:
            feature_tolerances: Map from feature name to equivalence tolerance δ_f.
        """
        self.tolerances = feature_tolerances

    def check_gap(self, x: TheoremDescriptor, y: TheoremDescriptor,
                  feature: str) -> Tuple[bool, float]:
        """Check if a single feature gap certifies non-equivalence."""
        delta_f = self.tolerances.get(feature, float('inf'))
        gap = abs(x.features.get(feature, 0) - y.features.get(feature, 0))
        return gap > delta_f, gap

    def full_analysis(self, x: TheoremDescriptor, y: TheoremDescriptor
                      ) -> List[Tuple[str, bool, float, float]]:
        """Analyze all features for obstruction certificates.

        Returns list of (feature_name, obstructs, gap, tolerance).
        """
        results = []
        for feat, tol in self.tolerances.items():
            obstructs, gap = self.check_gap(x, y, feat)
            results.append((feat, obstructs, gap, tol))
        return results


class CatalogManager:
    """Manage a theorem catalog with separation verification.

    Verifies the Catalog Class Separation property:
        ∀ a ∈ K, ∀ b ∈ K, ¬ Equivalent a b → 2δ < dist(E a, E b)

    This ensures that equivalence classes in the catalog are well-separated,
    enabling the catalog_separation_disjoint theorem.
    """

    def __init__(self, feature_order: List[str], delta: float):
        self.feature_order = feature_order
        self.delta = delta
        self.catalog: List[TheoremDescriptor] = []

    def add(self, descriptor: TheoremDescriptor) -> bool:
        """Add a descriptor to the catalog. Returns True if separation is maintained."""
        v = descriptor.to_vector(self.feature_order)
        for existing in self.catalog:
            w = existing.to_vector(self.feature_order)
            d = np.linalg.norm(v - w)
            if d <= 2 * self.delta:
                return False  # Would violate separation
        self.catalog.append(descriptor)
        return True

    def verify_separation(self) -> Tuple[bool, Optional[Tuple[str, str, float]]]:
        """Verify that all catalog pairs satisfy the separation condition.

        Returns (is_separated, violation_info).
        """
        for i, a in enumerate(self.catalog):
            for j, b in enumerate(self.catalog):
                if i >= j:
                    continue
                va = a.to_vector(self.feature_order)
                vb = b.to_vector(self.feature_order)
                d = np.linalg.norm(va - vb)
                if d <= 2 * self.delta:
                    return False, (a.name, b.name, d)
        return True, None

    def packing_density(self) -> float:
        """Compute the catalog packing density: |K| / (volume estimate).

        Uses the minimum pairwise distance to estimate packing efficiency.
        """
        if len(self.catalog) < 2:
            return 0.0
        min_dist = float('inf')
        for i, a in enumerate(self.catalog):
            for j, b in enumerate(self.catalog):
                if i >= j:
                    continue
                va = a.to_vector(self.feature_order)
                vb = b.to_vector(self.feature_order)
                d = np.linalg.norm(va - vb)
                min_dist = min(min_dist, d)
        return len(self.catalog) / (min_dist ** len(self.feature_order)) if min_dist > 0 else float('inf')


def demo():
    """Run a complete demonstration of all algorithms."""
    features = ['arity', 'symbol_count', 'quantifier_depth',
                'dependency_count', 'has_induction', 'has_contradiction']

    # Build catalog
    catalog_data = [
        TheoremDescriptor("Pythagorean", {'arity': 3, 'symbol_count': 12,
            'quantifier_depth': 1, 'dependency_count': 2,
            'has_induction': 0, 'has_contradiction': 0}),
        TheoremDescriptor("FTA", {'arity': 2, 'symbol_count': 25,
            'quantifier_depth': 2, 'dependency_count': 8,
            'has_induction': 0, 'has_contradiction': 1}),
        TheoremDescriptor("Fermat-Little", {'arity': 2, 'symbol_count': 15,
            'quantifier_depth': 1, 'dependency_count': 3,
            'has_induction': 1, 'has_contradiction': 0}),
    ]

    delta = 5.0
    certifier = NoveltyCertifier(features, delta)
    for d in catalog_data:
        certifier.add_to_catalog(d)

    # Test candidates
    novel_candidate = TheoremDescriptor("Novel Theorem", {
        'arity': 6, 'symbol_count': 45, 'quantifier_depth': 4,
        'dependency_count': 15, 'has_induction': 1, 'has_contradiction': 1
    })
    derivative_candidate = TheoremDescriptor("Pythagoras Variant", {
        'arity': 3, 'symbol_count': 13, 'quantifier_depth': 1,
        'dependency_count': 2, 'has_induction': 0, 'has_contradiction': 0
    })

    print("=== Novelty Certification ===")
    for c in [novel_candidate, derivative_candidate]:
        is_novel, score, explanation = certifier.certify(c)
        print(f"\n{c.name}: {explanation}")

    # Feature gap analysis
    print("\n=== Feature Gap Analysis ===")
    analyzer = FeatureGapAnalyzer({f: 3.0 for f in features})
    results = analyzer.full_analysis(novel_candidate, catalog_data[0])
    for feat, obstructs, gap, tol in results:
        marker = "✓ OBSTRUCTION" if obstructs else "  no obstruction"
        print(f"  {feat:20s}: gap={gap:.1f}, tol={tol:.1f} → {marker}")

    # Catalog separation
    print("\n=== Catalog Separation ===")
    manager = CatalogManager(features, delta)
    for d in catalog_data:
        ok = manager.add(d)
        print(f"  Added '{d.name}': separation maintained = {ok}")
    sep, violation = manager.verify_separation()
    print(f"  Catalog separation verified: {sep}")


if __name__ == "__main__":
    demo()
