#!/usr/bin/env python3
"""
Batch Certification Algorithms

Complete implementations of the algorithms from the research paper,
with docstrings, type hints, and example usage.
"""

import numpy as np
from dataclasses import dataclass
from typing import Optional


@dataclass
class FacetFamily:
    """A precomputed family of affine facets for certification.

    Attributes:
        normals: (m, d) array of facet normal vectors
        offsets: (m,) array of affine offsets
        norms: (m,) array of precomputed ‖nⱼ‖ values
        m: number of facets
        d: dimension
    """
    normals: np.ndarray
    offsets: np.ndarray
    norms: np.ndarray
    m: int
    d: int

    @classmethod
    def from_normals_and_offsets(cls, normals: np.ndarray,
                                 offsets: np.ndarray) -> 'FacetFamily':
        """Create a FacetFamily from raw normals and offsets.

        Args:
            normals: (m, d) array of normal vectors, all nonzero
            offsets: (m,) array of offsets

        Returns:
            FacetFamily with precomputed norms

        Raises:
            ValueError: if any normal vector is zero
        """
        norms = np.linalg.norm(normals, axis=1)
        if np.any(norms < 1e-15):
            raise ValueError("All normal vectors must be nonzero")
        return cls(
            normals=normals,
            offsets=offsets,
            norms=norms,
            m=normals.shape[0],
            d=normals.shape[1]
        )


def affine_scores(facets: FacetFamily, X: np.ndarray) -> np.ndarray:
    """Compute all affine scores: S[i,j] = ⟨nⱼ, Xᵢ⟩ + cⱼ.

    This is the core matrix multiplication step.

    Args:
        facets: precomputed facet family
        X: (N, d) dataset

    Returns:
        (N, m) array of affine scores
    """
    return X @ facets.normals.T + facets.offsets[np.newaxis, :]


def facet_distances(facets: FacetFamily, X: np.ndarray) -> np.ndarray:
    """Compute all facet distances: D[i,j] = S[i,j] / ‖nⱼ‖.

    Args:
        facets: precomputed facet family
        X: (N, d) dataset

    Returns:
        (N, m) array of signed distances to each facet
    """
    scores = affine_scores(facets, X)
    return scores / facets.norms[np.newaxis, :]


def batch_certify(facets: FacetFamily, X: np.ndarray) -> np.ndarray:
    """Algorithm 1: Batch certification via matrix multiplication.

    Computes the certified radius for each point in the dataset.

    Complexity: O(md) preprocessing (in FacetFamily), O(mdN) evaluation.

    Args:
        facets: precomputed facet family
        X: (N, d) dataset

    Returns:
        (N,) array of certified radii (min facet distance per point)

    Example:
        >>> facets = FacetFamily.from_normals_and_offsets(
        ...     np.array([[1., 0.], [0., 1.]]),
        ...     np.array([1., 2.])
        ... )
        >>> X = np.array([[0., 0.], [1., 1.]])
        >>> batch_certify(facets, X)
        array([1., 2.])  # min(1, 2)=1 for first, min(2, 3)=2 for second
    """
    dists = facet_distances(facets, X)
    return dists.min(axis=1)


def incremental_certify(facets: FacetFamily,
                        x_new: np.ndarray) -> float:
    """Algorithm 2: Incremental certification for a single new point.

    Computes the certificate for x_new without touching existing certificates.

    Complexity: O(md) per point.

    Args:
        facets: precomputed facet family
        x_new: (d,) new point

    Returns:
        Certified radius for x_new
    """
    scores = facets.normals @ x_new + facets.offsets  # (m,)
    dists = scores / facets.norms                      # (m,)
    return float(dists.min())


@dataclass
class LinearRegion:
    """A linear region with local certificate and boundary distance.

    Attributes:
        local_facets: FacetFamily for class-separating hyperplanes within R
        boundary_facets: FacetFamily for region boundary hyperplanes
    """
    local_facets: FacetFamily
    boundary_facets: Optional[FacetFamily] = None

    def local_cert(self, x: np.ndarray) -> float:
        """Local certificate: min distance to class-switching hyperplanes."""
        return incremental_certify(self.local_facets, x)

    def dist_boundary(self, x: np.ndarray) -> float:
        """Distance to region boundary."""
        if self.boundary_facets is None:
            return float('inf')
        return incremental_certify(self.boundary_facets, x)

    def global_cert(self, x: np.ndarray) -> float:
        """Algorithm 3: Global certificate = min(local cert, dist boundary).

        This is Theorem C: the global certified radius accounts for both
        local robustness and region containment.
        """
        return min(self.local_cert(x), self.dist_boundary(x))


class BatchCertifier:
    """Online batch certifier with incremental updates.

    Maintains a dataset and its certificates. Supports:
    - Initial batch certification
    - Incremental point insertion (Theorem B)
    - Certificate queries

    Example:
        >>> facets = FacetFamily.from_normals_and_offsets(normals, offsets)
        >>> certifier = BatchCertifier(facets)
        >>> certifier.add_batch(X_train)
        >>> certifier.add_point(x_new)  # O(md), doesn't change existing certs
        >>> print(certifier.certificates)
    """

    def __init__(self, facets: FacetFamily):
        self.facets = facets
        self.points: list = []
        self.certificates: list = []

    def add_batch(self, X: np.ndarray) -> np.ndarray:
        """Add a batch of points and compute their certificates.

        Args:
            X: (N, d) batch of points

        Returns:
            (N,) array of certificates for the new points
        """
        certs = batch_certify(self.facets, X)
        self.points.extend(X)
        self.certificates.extend(certs.tolist())
        return certs

    def add_point(self, x: np.ndarray) -> float:
        """Add a single point incrementally (Theorem B).

        Existing certificates are NOT modified (persistence guarantee).

        Args:
            x: (d,) new point

        Returns:
            Certificate for the new point
        """
        cert = incremental_certify(self.facets, x)
        self.points.append(x)
        self.certificates.append(cert)
        return cert

    @property
    def min_certificate(self) -> float:
        """Minimum certificate in the dataset (worst-case robustness)."""
        if not self.certificates:
            return float('inf')
        return min(self.certificates)

    @property
    def mean_certificate(self) -> float:
        """Mean certificate (average robustness)."""
        if not self.certificates:
            return 0.0
        return float(np.mean(self.certificates))

    def __len__(self) -> int:
        return len(self.points)


class MultiRegionCertifier:
    """Certifier for piecewise-linear networks with multiple regions.

    Given a collection of linear regions, computes the global certificate
    for any point by:
    1. Identifying which region contains the point
    2. Computing the region-local certificate
    3. Computing the boundary distance
    4. Taking the minimum (Theorem C)
    """

    def __init__(self, regions: list):
        """
        Args:
            regions: list of LinearRegion objects
        """
        self.regions = regions

    def certify(self, x: np.ndarray, region_idx: int) -> float:
        """Certify a point in a known region.

        Args:
            x: (d,) point
            region_idx: index of the region containing x

        Returns:
            Global certificate for x
        """
        return self.regions[region_idx].global_cert(x)

    def batch_certify_by_region(self, X: np.ndarray,
                                 region_indices: np.ndarray) -> np.ndarray:
        """Certify a batch where each point's region is known.

        Args:
            X: (N, d) dataset
            region_indices: (N,) array of region indices

        Returns:
            (N,) array of global certificates
        """
        N = len(X)
        certs = np.zeros(N)
        for i in range(N):
            certs[i] = self.certify(X[i], region_indices[i])
        return certs


# ============================================================
# Example usage
# ============================================================
if __name__ == "__main__":
    print("Batch Certification Algorithms — Example Usage")
    print("=" * 60)

    # Create a simple 2D classifier with 3 facets
    normals = np.array([
        [1.0, 0.0],   # vertical hyperplane
        [0.0, 1.0],   # horizontal hyperplane
        [1.0, 1.0],   # diagonal hyperplane
    ])
    offsets = np.array([1.0, 2.0, 1.5])

    facets = FacetFamily.from_normals_and_offsets(normals, offsets)
    print(f"\nFacet family: {facets.m} facets in ℝ^{facets.d}")
    print(f"Precomputed norms: {facets.norms}")

    # Batch certification
    X = np.array([
        [0.0, 0.0],
        [1.0, 1.0],
        [-1.0, 2.0],
        [3.0, -1.0],
    ])
    certs = batch_certify(facets, X)
    print(f"\nBatch certificates: {certs.round(4)}")

    # Incremental certification
    certifier = BatchCertifier(facets)
    certifier.add_batch(X)
    print(f"\nAfter batch add: {len(certifier)} points")
    print(f"Min certificate: {certifier.min_certificate:.4f}")
    print(f"Mean certificate: {certifier.mean_certificate:.4f}")

    x_new = np.array([2.0, 3.0])
    new_cert = certifier.add_point(x_new)
    print(f"\nAfter adding point {x_new}:")
    print(f"New point certificate: {new_cert:.4f}")
    print(f"Total points: {len(certifier)}")
    print(f"Min certificate: {certifier.min_certificate:.4f}")

    # Region-local certification
    region = LinearRegion(
        local_facets=facets,
        boundary_facets=FacetFamily.from_normals_and_offsets(
            np.array([[1., 0.], [-1., 0.], [0., 1.], [0., -1.]]),
            np.array([5., 5., 5., 5.])  # box [-5, 5]^2
        )
    )

    x_interior = np.array([0.0, 0.0])
    x_near_boundary = np.array([4.5, 0.0])

    print(f"\nRegion-local certification:")
    print(f"  Interior point {x_interior}:")
    print(f"    Local cert: {region.local_cert(x_interior):.4f}")
    print(f"    Dist boundary: {region.dist_boundary(x_interior):.4f}")
    print(f"    Global cert: {region.global_cert(x_interior):.4f}")
    print(f"  Near-boundary point {x_near_boundary}:")
    print(f"    Local cert: {region.local_cert(x_near_boundary):.4f}")
    print(f"    Dist boundary: {region.dist_boundary(x_near_boundary):.4f}")
    print(f"    Global cert: {region.global_cert(x_near_boundary):.4f}")
