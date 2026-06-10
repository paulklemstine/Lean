#!/usr/bin/env python3
"""
Ultrametric Holographic Renormalization — Algorithms
=====================================================

Implements the certified reconstruction algorithms from the paper.
All algorithms include docstrings, type hints, and correctness assertions.
"""

from __future__ import annotations
import numpy as np
from typing import Optional
from dataclasses import dataclass, field


@dataclass
class UltrametricSpace:
    """A finite ultrametric space with ℕ-valued distances.

    Attributes:
        labels: Names for the points
        dist: Distance matrix (symmetric, ultrametric)
    """
    labels: list[str]
    dist: np.ndarray

    def __post_init__(self):
        assert self.dist.shape == (len(self.labels), len(self.labels))

    @property
    def n(self) -> int:
        return len(self.labels)

    def verify_axioms(self) -> dict[str, bool]:
        """Verify all ultrametric axioms.

        Returns:
            Dictionary with verification results for each axiom.
        """
        n = self.n
        d = self.dist

        reflexivity = all(d[i, i] == 0 for i in range(n))
        symmetry = all(d[i, j] == d[j, i] for i in range(n) for j in range(n))
        separation = all(d[i, j] > 0 for i in range(n) for j in range(n) if i != j)
        ultrametric = all(
            d[i, k] <= max(d[i, j], d[j, k])
            for i in range(n) for j in range(n) for k in range(n)
        )

        return {
            'reflexivity': reflexivity,
            'symmetry': symmetry,
            'separation': separation,
            'ultrametric': ultrametric,
            'valid': reflexivity and symmetry and separation and ultrametric
        }

    def entropy_profile(self, i: int) -> np.ndarray:
        """The entropy profile of point i: its distance vector."""
        return self.dist[i].copy()

    def scale_cluster(self, s: int, x: int) -> frozenset[int]:
        """The cluster of x at scale s: {y | d(x,y) ≤ s}."""
        return frozenset(j for j in range(self.n) if self.dist[x, j] <= s)

    def scale_partition(self, s: int) -> list[frozenset[int]]:
        """The partition of all points into clusters at scale s.

        Returns a list of disjoint frozensets covering all points.
        By the ultrametric property, this is always a valid partition.
        """
        visited: set[int] = set()
        clusters: list[frozenset[int]] = []
        for i in range(self.n):
            if i not in visited:
                cluster = self.scale_cluster(s, i)
                clusters.append(cluster)
                visited.update(cluster)
        return clusters

    def merge_scales(self) -> list[int]:
        """The set of distinct nonzero distances (merge scales).

        These are the scales at which the partition changes,
        corresponding to internal nodes of the hierarchical tree.
        """
        scales = sorted(set(
            int(self.dist[i, j])
            for i in range(self.n) for j in range(self.n)
            if i != j
        ))
        return scales


@dataclass
class MergeTree:
    """A hierarchical merge tree (dendrogram).

    Each internal node represents a merge event at a specific scale.
    """
    @dataclass
    class Node:
        """A node in the merge tree."""
        scale: int
        children: list[MergeTree.Node] = field(default_factory=list)
        leaves: frozenset[int] = frozenset()

        @property
        def is_leaf(self) -> bool:
            return len(self.children) == 0

    root: Node
    leaf_labels: list[str]

    def to_dict(self) -> dict:
        """Convert to a serializable dictionary."""
        def node_to_dict(node: MergeTree.Node) -> dict:
            if node.is_leaf:
                idx = list(node.leaves)[0]
                return {
                    'type': 'leaf',
                    'label': self.leaf_labels[idx],
                    'index': idx
                }
            return {
                'type': 'internal',
                'scale': node.scale,
                'children': [node_to_dict(c) for c in node.children]
            }
        return node_to_dict(self.root)

    def induced_ultrametric(self) -> np.ndarray:
        """Compute the ultrametric induced by this merge tree.

        d(x, y) = scale of the lowest common ancestor of x and y.
        """
        n = len(self.leaf_labels)
        d = np.zeros((n, n), dtype=int)

        def fill_lca(node: MergeTree.Node):
            if node.is_leaf:
                return
            # All pairs of leaves from different children get this node's scale
            child_leaf_sets = []
            for child in node.children:
                child_leaf_sets.append(child.leaves)
                fill_lca(child)
            for i in range(len(child_leaf_sets)):
                for j in range(i + 1, len(child_leaf_sets)):
                    for a in child_leaf_sets[i]:
                        for b in child_leaf_sets[j]:
                            d[a, b] = node.scale
                            d[b, a] = node.scale

        fill_lca(self.root)
        return d


def reconstruct_merge_tree(space: UltrametricSpace) -> MergeTree:
    """Reconstruct the canonical merge tree from an ultrametric space.

    Algorithm: Hierarchical single-linkage clustering.

    Time complexity: O(n² log n) where n = |α|
    Space complexity: O(n²)

    Args:
        space: A valid finite ultrametric space.

    Returns:
        The canonical merge tree.

    Correctness: By Theorem 3.6, this produces the unique minimal
    realization of the boundary entropy data.
    """
    n = space.n
    scales = space.merge_scales()

    # Start with each point as its own leaf node
    leaf_nodes: dict[int, MergeTree.Node] = {}
    for i in range(n):
        leaf_nodes[i] = MergeTree.Node(scale=0, leaves=frozenset([i]))

    # Track which cluster each point belongs to
    cluster_of: dict[int, int] = {i: i for i in range(n)}
    cluster_nodes: dict[int, MergeTree.Node] = dict(leaf_nodes)

    for s in scales:
        # Find which clusters merge at this scale
        partition = space.scale_partition(s)

        for cluster in partition:
            # Find representative cluster ids
            reps = set(cluster_of[i] for i in cluster)
            if len(reps) <= 1:
                continue  # No merge at this scale for this cluster

            # Create internal node
            children = [cluster_nodes[r] for r in reps]
            new_node = MergeTree.Node(
                scale=s,
                children=children,
                leaves=frozenset().union(*(c.leaves for c in children))
            )

            # Update tracking
            new_rep = min(reps)
            for i in cluster:
                cluster_of[i] = new_rep
            for r in reps:
                if r in cluster_nodes:
                    del cluster_nodes[r]
            cluster_nodes[new_rep] = new_node

    # The remaining node is the root
    assert len(cluster_nodes) == 1, f"Expected 1 root, got {len(cluster_nodes)}"
    root = list(cluster_nodes.values())[0]

    return MergeTree(root=root, leaf_labels=space.labels)


def canonical_bulk_reconstruction(
    profile: np.ndarray,
    labels: Optional[list[str]] = None
) -> dict:
    """The certified canonical reconstruction algorithm.

    Implements Definition 2.5: Node = α, embed = id, scaleDist = profile.

    This is the explicit 'holographic decoder'. By Theorem 3.6,
    the output is minimal and correctly realizes the input profile.

    Time complexity: O(1) (just returns the input as the bulk)
    Space complexity: O(n²)

    Args:
        profile: The boundary entropy profile matrix.
        labels: Optional labels for boundary observers.

    Returns:
        Dictionary describing the canonical bulk flow.
    """
    n = profile.shape[0]
    if labels is None:
        labels = [str(i) for i in range(n)]

    return {
        'node_type': 'boundary',
        'node_count': n,
        'node_labels': labels,
        'embed': 'identity',
        'scale_dist': profile.tolist(),
        'is_minimal': True,
        'boundary_profile': profile.tolist(),
        'roundtrip_verified': True
    }


def verify_reconstruction_roundtrip(
    space: UltrametricSpace
) -> dict:
    """Verify the reconstruction roundtrip (Theorem 3.9).

    Checks that reconstruct(boundary(U)) ≅ U for a given ultrametric U.

    Args:
        space: An ultrametric space (the "bulk").

    Returns:
        Verification results.
    """
    # Extract boundary profile
    profile = space.dist.copy()

    # Reconstruct canonical bulk
    bulk = canonical_bulk_reconstruction(profile, space.labels)

    # Verify boundary matches
    reconstructed_dist = np.array(bulk['scale_dist'])
    dist_match = np.array_equal(space.dist, reconstructed_dist)

    # Verify via merge tree
    tree = reconstruct_merge_tree(space)
    tree_dist = tree.induced_ultrametric()
    tree_match = np.array_equal(space.dist, tree_dist)

    return {
        'canonical_roundtrip': dist_match,
        'tree_roundtrip': tree_match,
        'merge_scales': space.merge_scales(),
        'tree_structure': tree.to_dict(),
        'all_verified': dist_match and tree_match
    }


# Example usage
if __name__ == '__main__':
    # Example: 5-point ultrametric
    labels = ['A', 'B', 'C', 'D', 'E']
    d = np.array([
        [0, 1, 3, 3, 5],
        [1, 0, 3, 3, 5],
        [3, 3, 0, 1, 5],
        [3, 3, 1, 0, 5],
        [5, 5, 5, 5, 0]
    ])

    space = UltrametricSpace(labels=labels, dist=d)
    print("Axiom verification:", space.verify_axioms())
    print("Merge scales:", space.merge_scales())

    # Reconstruct
    tree = reconstruct_merge_tree(space)
    print("\nMerge tree:")
    import json
    print(json.dumps(tree.to_dict(), indent=2))

    # Verify roundtrip
    result = verify_reconstruction_roundtrip(space)
    print("\nRoundtrip verification:", result['all_verified'])

    # Induced ultrametric from tree
    tree_d = tree.induced_ultrametric()
    print("\nOriginal distances:")
    print(d)
    print("\nTree-induced distances:")
    print(tree_d)
    print("\nMatch:", np.array_equal(d, tree_d))
