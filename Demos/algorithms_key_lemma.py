"""
Tree Metric Reconstruction Algorithms

Implements cherry-picking reconstruction, cherry detection, and
noisy stability analysis for tree metrics.
"""

import numpy as np
from typing import List, Tuple, Optional, Set
from dataclasses import dataclass


@dataclass
class TreeNode:
    """A node in a labeled binary tree."""
    left: Optional['TreeNode'] = None
    right: Optional['TreeNode'] = None
    left_weight: float = 0.0
    right_weight: float = 0.0
    label: Optional[int] = None  # Only for leaves

    @property
    def is_leaf(self) -> bool:
        return self.label is not None

    def leaves(self) -> Set[int]:
        if self.is_leaf:
            return {self.label}
        return self.left.leaves() | self.right.leaves()

    def dist(self, i: int, j: int) -> float:
        """Compute the tree distance between leaves i and j."""
        if self.is_leaf:
            return 0.0
        left_labels = self.left.leaves()
        right_labels = self.right.leaves()
        if i in left_labels and j in left_labels:
            return self.left.dist(i, j)
        elif i in right_labels and j in right_labels:
            return self.right.dist(i, j)
        elif i in left_labels and j in right_labels:
            return (self.left.root_dist(i) + self.left_weight +
                    self.right_weight + self.right.root_dist(j))
        elif i in right_labels and j in left_labels:
            return (self.right.root_dist(i) + self.right_weight +
                    self.left_weight + self.left.root_dist(j))
        return 0.0

    def root_dist(self, i: int) -> float:
        """Distance from leaf i to the root of this subtree."""
        if self.is_leaf:
            return 0.0
        if i in self.left.leaves():
            return self.left.root_dist(i) + self.left_weight
        elif i in self.right.leaves():
            return self.right.root_dist(i) + self.right_weight
        return 0.0

    def cherry_pairs(self) -> List[Tuple[int, int]]:
        """Find all structural cherry pairs in the tree."""
        if self.is_leaf:
            return []
        pairs = []
        if self.left.is_leaf and self.right.is_leaf:
            a, b = self.left.label, self.right.label
            pairs.append((min(a, b), max(a, b)))
        pairs.extend(self.left.cherry_pairs())
        pairs.extend(self.right.cherry_pairs())
        return pairs

    def is_reduced(self) -> bool:
        """Check if the tree is reduced (positive internal edge weights)."""
        if self.is_leaf:
            return True
        if not self.left.is_leaf and self.left_weight <= 0:
            return False
        if not self.right.is_leaf and self.right_weight <= 0:
            return False
        return self.left.is_reduced() and self.right.is_reduced()

    def __repr__(self) -> str:
        if self.is_leaf:
            return f"Leaf({self.label})"
        return f"Branch({self.left_weight:.2f}, {self.left}, {self.right_weight:.2f}, {self.right})"


def distance_matrix(tree: TreeNode) -> np.ndarray:
    """Compute the distance matrix of a tree."""
    leaves = sorted(tree.leaves())
    n = len(leaves)
    D = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            D[i][j] = tree.dist(leaves[i], leaves[j])
    return D


def is_four_point(D: np.ndarray, tol: float = 1e-10) -> bool:
    """Check the four-point condition for a distance matrix."""
    n = D.shape[0]
    for i in range(n):
        for j in range(i + 1, n):
            for k in range(j + 1, n):
                for l in range(k + 1, n):
                    s1 = D[i][j] + D[k][l]
                    s2 = D[i][k] + D[j][l]
                    s3 = D[i][l] + D[j][k]
                    sums = sorted([s1, s2, s3])
                    if abs(sums[1] - sums[2]) > tol:
                        return False
    return True


def gromov_product(D: np.ndarray, i: int, j: int, r: int) -> float:
    """Compute the Gromov product (i|j)_r = (D[r,i] + D[r,j] - D[i,j]) / 2."""
    return (D[r][i] + D[r][j] - D[i][j]) / 2.0


def detect_cherry_pair(D: np.ndarray) -> Tuple[int, int]:
    """Detect a cherry pair using the Gromov product maximization.

    For a reference point r, the pair (i,j) maximizing (i|j)_r
    is guaranteed to be a cherry pair in any reduced tree realizing D.

    Returns:
        Tuple of leaf indices forming a cherry pair.

    Time complexity: O(n^2) for a fixed reference point.
    """
    n = D.shape[0]
    if n <= 1:
        raise ValueError("Need at least 2 leaves")
    if n == 2:
        return (0, 1)

    r = 0  # Reference point
    best_gp = -np.inf
    best_pair = (1, 2)
    for i in range(n):
        if i == r:
            continue
        for j in range(i + 1, n):
            if j == r:
                continue
            gp = gromov_product(D, i, j, r)
            if gp > best_gp:
                best_gp = gp
                best_pair = (i, j)
    return best_pair


def pendant_length(D: np.ndarray, i: int, j: int, k: int) -> float:
    """Compute pendant edge length: (D[i,j] + D[i,k] - D[j,k]) / 2."""
    return (D[i][j] + D[i][k] - D[j][k]) / 2.0


def is_cherry_pair_metric(D: np.ndarray, a: int, b: int) -> bool:
    """Check the metric cherry condition (IsCherryPair).

    Note: This is NECESSARY but NOT SUFFICIENT for being a structural cherry.
    It characterizes splits, not cherries. A pair (a,b) satisfying this
    condition may not share a parent in the tree.

    Returns:
        True if D(a,k) + D(b,l) = D(a,l) + D(b,k) for all k,l ≠ a,b.
    """
    n = D.shape[0]
    tol = 1e-10
    if a == b:
        return False
    for k in range(n):
        if k == a or k == b:
            continue
        for l in range(n):
            if l == a or l == b:
                continue
            if abs(D[a][k] + D[b][l] - D[a][l] - D[b][k]) > tol:
                return False
    return True


def cherry_picking_reconstruct(D: np.ndarray) -> TreeNode:
    """Reconstruct a tree from a distance matrix using cherry picking.

    Algorithm:
    1. If n <= 2, return a trivial tree.
    2. Find a cherry pair (a, b) via Gromov product maximization.
    3. Compute pendant edge lengths.
    4. Create a reduced matrix by replacing (a, b) with their parent.
    5. Recursively reconstruct from the reduced matrix.
    6. Re-attach the cherry.

    Time complexity: O(n^3) overall (O(n^2) per step, n steps).
    Space complexity: O(n^2) for the distance matrix.

    Returns:
        A TreeNode representing the reconstructed tree.
    """
    n = D.shape[0]

    if n == 0:
        return TreeNode(label=0)
    if n == 1:
        return TreeNode(label=0)
    if n == 2:
        return TreeNode(
            left=TreeNode(label=0),
            right=TreeNode(label=1),
            left_weight=D[0][1],
            right_weight=0.0
        )

    # Find cherry pair
    a, b = detect_cherry_pair(D)

    # Compute pendant lengths using any reference k ≠ a, b
    ref = next(k for k in range(n) if k != a and k != b)
    w_a = pendant_length(D, a, b, ref)
    w_b = pendant_length(D, b, a, ref)

    # Create reduced matrix: remove b, adjust distances for a → parent
    remaining = [i for i in range(n) if i != b]
    m = len(remaining)
    D_reduced = np.zeros((m, m))
    idx_map = {old: new for new, old in enumerate(remaining)}

    for i_new, i_old in enumerate(remaining):
        for j_new, j_old in enumerate(remaining):
            if i_old == a:
                if j_old == a:
                    D_reduced[i_new][j_new] = 0.0
                else:
                    # Distance from parent of cherry to j
                    D_reduced[i_new][j_new] = D[a][j_old] - w_a
            elif j_old == a:
                D_reduced[i_new][j_new] = D[i_old][a] - w_a
            else:
                D_reduced[i_new][j_new] = D[i_old][j_old]

    # Recursively reconstruct
    sub_tree = cherry_picking_reconstruct(D_reduced)

    # Find the node labeled idx_map[a] in the sub_tree and replace it
    # with the cherry subtree
    cherry_node = TreeNode(
        left=TreeNode(label=a),
        right=TreeNode(label=b),
        left_weight=w_a,
        right_weight=w_b
    )

    def replace_leaf(node: TreeNode, old_label: int, new_subtree: TreeNode,
                     edge_weight: float) -> TreeNode:
        """Replace a leaf with a subtree, distributing edge weight."""
        if node.is_leaf:
            if node.label == old_label:
                return new_subtree
            return node
        return TreeNode(
            left=replace_leaf(node.left, old_label, new_subtree, edge_weight),
            right=replace_leaf(node.right, old_label, new_subtree, edge_weight),
            left_weight=node.left_weight,
            right_weight=node.right_weight
        )

    # Relabel the sub_tree to use original indices
    def relabel(node: TreeNode) -> TreeNode:
        if node.is_leaf:
            return TreeNode(label=remaining[node.label])
        return TreeNode(
            left=relabel(node.left),
            right=relabel(node.right),
            left_weight=node.left_weight,
            right_weight=node.right_weight
        )

    relabeled = relabel(sub_tree)

    # The parent of the cherry in the reduced tree has label a
    # We need to find this leaf and expand it to the cherry
    def expand_cherry(node: TreeNode) -> TreeNode:
        if node.is_leaf:
            if node.label == a:
                return cherry_node
            return node
        return TreeNode(
            left=expand_cherry(node.left),
            right=expand_cherry(node.right),
            left_weight=node.left_weight,
            right_weight=node.right_weight
        )

    return expand_cherry(relabeled)


def noisy_cherry_detection(D: np.ndarray, threshold: float
                           ) -> List[Tuple[int, int]]:
    """Detect cherry pairs in a potentially noisy distance matrix.

    Uses the four-point deviation: for each pair (a,b), compute
    max_{k,l} |D[a,k] + D[b,l] - D[a,l] - D[b,k]|.
    Pairs with small maximum deviation are candidate cherries.

    Args:
        D: Distance matrix (potentially noisy).
        threshold: Maximum allowed four-point deviation.

    Returns:
        List of candidate cherry pairs.
    """
    n = D.shape[0]
    candidates = []
    for a in range(n):
        for b in range(a + 1, n):
            max_dev = 0.0
            for k in range(n):
                if k == a or k == b:
                    continue
                for l in range(n):
                    if l == a or l == b:
                        continue
                    dev = abs(D[a][k] + D[b][l] - D[a][l] - D[b][k])
                    max_dev = max(max_dev, dev)
            if max_dev <= threshold:
                candidates.append((a, b))
    return candidates


def cherry_separation_margin(D: np.ndarray, cherry_pairs: List[Tuple[int, int]]
                             ) -> float:
    """Compute the cherry separation margin of a tree metric.

    The margin is the minimum four-point deviation among non-cherry pairs.
    It quantifies how robustly cherries can be detected under perturbation.

    Args:
        D: Tree metric distance matrix.
        cherry_pairs: Known cherry pairs.

    Returns:
        The separation margin δ > 0.
    """
    n = D.shape[0]
    cherry_set = set(cherry_pairs) | {(b, a) for a, b in cherry_pairs}
    min_deviation = np.inf

    for a in range(n):
        for b in range(a + 1, n):
            if (a, b) in cherry_set:
                continue
            for k in range(n):
                if k == a or k == b:
                    continue
                for l in range(n):
                    if l == a or l == b:
                        continue
                    dev = abs(D[a][k] + D[b][l] - D[a][l] - D[b][k])
                    if dev > 0:
                        min_deviation = min(min_deviation, dev)

    return min_deviation if min_deviation < np.inf else 0.0


if __name__ == "__main__":
    # Example: balanced tree with 4 leaves
    tree = TreeNode(
        left=TreeNode(
            left=TreeNode(label=0),
            right=TreeNode(label=1),
            left_weight=1.0,
            right_weight=1.0
        ),
        right=TreeNode(
            left=TreeNode(label=2),
            right=TreeNode(label=3),
            left_weight=1.0,
            right_weight=1.0
        ),
        left_weight=1.0,
        right_weight=1.0
    )

    D = distance_matrix(tree)
    print("Distance matrix:")
    print(D)
    print(f"\nFour-point condition: {is_four_point(D)}")
    print(f"Cherry pairs: {tree.cherry_pairs()}")
    print(f"Detected cherry: {detect_cherry_pair(D)}")

    # Reconstruct
    T_recon = cherry_picking_reconstruct(D)
    D_recon = distance_matrix(T_recon)
    print(f"\nReconstructed tree cherries: {T_recon.cherry_pairs()}")
    print(f"Reconstruction error: {np.max(np.abs(D - D_recon)):.10f}")
