"""
Tree Metric Reconstruction Algorithms

Implementation of the Buneman reconstruction algorithm for additive (tree) metrics.
Given a distance matrix satisfying the four-point condition, reconstructs the
unique weighted tree whose leaf-to-leaf distances match the input.

References:
    Buneman, P. (1971). The recovery of trees from measures of dissimilarity.
    Semple, C. and Steel, M. (2003). Phylogenetics.
"""

import numpy as np
from typing import Optional


def is_finite_metric(D: np.ndarray, tol: float = 1e-10) -> bool:
    """Check if D is a valid finite metric matrix.
    
    Tests: zero diagonal, nonnegativity, symmetry, triangle inequality.
    
    Args:
        D: Square distance matrix
        tol: Numerical tolerance
    
    Returns:
        True if D satisfies all metric axioms
    """
    n = D.shape[0]
    if D.shape != (n, n):
        return False
    # Zero diagonal
    if not np.allclose(np.diag(D), 0, atol=tol):
        return False
    # Nonnegativity
    if np.any(D < -tol):
        return False
    # Symmetry
    if not np.allclose(D, D.T, atol=tol):
        return False
    # Triangle inequality
    for i in range(n):
        for j in range(n):
            for k in range(n):
                if D[i, k] > D[i, j] + D[j, k] + tol:
                    return False
    return True


def four_point_condition(D: np.ndarray, tol: float = 1e-10) -> bool:
    """Check if D satisfies the four-point (additive/tree) condition.
    
    For every quadruple (i,j,k,l), the two largest of
    {D[i,j]+D[k,l], D[i,k]+D[j,l], D[i,l]+D[j,k]} must be equal.
    
    Args:
        D: Square distance matrix
        tol: Numerical tolerance
    
    Returns:
        True if the four-point condition holds
    """
    n = D.shape[0]
    for i in range(n):
        for j in range(i + 1, n):
            for k in range(j + 1, n):
                for l in range(k + 1, n):
                    sums = sorted([
                        D[i, j] + D[k, l],
                        D[i, k] + D[j, l],
                        D[i, l] + D[j, k]
                    ])
                    # Two largest must be equal
                    if abs(sums[1] - sums[2]) > tol:
                        return False
    return True


def pendant_length(D: np.ndarray, i: int, j: int, k: int) -> float:
    """Compute the pendant edge length (Gromov product) at vertex i.
    
    Returns (D[i,j] + D[i,k] - D[j,k]) / 2, which in a tree metric
    equals the length of the pendant edge at leaf i.
    
    Args:
        D: Distance matrix
        i, j, k: Vertex indices
    
    Returns:
        The pendant length at i relative to j and k
    """
    return (D[i, j] + D[i, k] - D[j, k]) / 2


class TreeNode:
    """A node in a weighted tree.
    
    Attributes:
        label: Leaf label (None for internal nodes)
        children: List of (weight, child) pairs
        parent: Parent node reference
        parent_weight: Weight of edge to parent
    """
    def __init__(self, label: Optional[int] = None):
        self.label = label
        self.children: list[tuple[float, 'TreeNode']] = []
        self.parent: Optional['TreeNode'] = None
        self.parent_weight: float = 0.0
    
    def is_leaf(self) -> bool:
        return len(self.children) == 0
    
    def add_child(self, weight: float, child: 'TreeNode'):
        self.children.append((weight, child))
        child.parent = self
        child.parent_weight = weight
    
    def leaves(self) -> list['TreeNode']:
        if self.is_leaf():
            return [self]
        result = []
        for _, child in self.children:
            result.extend(child.leaves())
        return result
    
    def num_vertices(self) -> int:
        if self.is_leaf():
            return 1
        return 1 + sum(child.num_vertices() for _, child in self.children)
    
    def distance_to(self, other: 'TreeNode') -> float:
        """Compute tree distance between this node and another."""
        # BFS/path-finding through the tree
        path_self = self._path_to_root()
        path_other = other._path_to_root()
        
        # Find LCA
        ancestors_self = {id(node): dist for node, dist in path_self}
        for node, dist_other in path_other:
            if id(node) in ancestors_self:
                return ancestors_self[id(node)] + dist_other
        return float('inf')
    
    def _path_to_root(self) -> list[tuple['TreeNode', float]]:
        """Return path from this node to root with cumulative distances."""
        path = [(self, 0.0)]
        node = self
        total = 0.0
        while node.parent is not None:
            total += node.parent_weight
            node = node.parent
            path.append((node, total))
        return path
    
    def to_newick(self) -> str:
        """Convert tree to Newick format string."""
        if self.is_leaf():
            return str(self.label) if self.label is not None else ""
        children_str = ",".join(
            f"{child.to_newick()}:{weight:.4f}"
            for weight, child in self.children
        )
        return f"({children_str})"
    
    def __repr__(self):
        if self.is_leaf():
            return f"Leaf({self.label})"
        return f"Internal({len(self.children)} children)"


def find_cherry_pair(D: np.ndarray, tol: float = 1e-10) -> tuple[int, int]:
    """Find a cherry pair in a four-point metric.
    
    Uses the Gromov product maximization at a reference point:
    fix r=0, choose (i,j) maximizing (D[0,i]+D[0,j]-D[i,j])/2.
    
    Args:
        D: Distance matrix satisfying four-point condition
        tol: Numerical tolerance
    
    Returns:
        (i, j) indices forming a cherry pair
    
    Complexity: O(n²)
    """
    n = D.shape[0]
    if n < 3:
        raise ValueError("Need n >= 3 for cherry detection")
    
    r = 0
    best_score = -float('inf')
    best_i, best_j = 1, 2
    
    for i in range(n):
        if i == r:
            continue
        for j in range(i + 1, n):
            if j == r:
                continue
            score = (D[r, i] + D[r, j] - D[i, j]) / 2
            if score > best_score + tol:
                best_score = score
                best_i, best_j = i, j
    
    return best_i, best_j


def reconstruct_tree(D: np.ndarray, labels: Optional[list[int]] = None) -> TreeNode:
    """Reconstruct a weighted tree from an additive distance matrix.
    
    Implements the Buneman cherry-picking reconstruction algorithm:
    1. For n <= 2, construct directly.
    2. For n = 3, use the tripod (star tree) construction.
    3. For n >= 4, find a cherry pair, reduce, recurse, and reattach.
    
    Args:
        D: Distance matrix satisfying the four-point condition
        labels: Optional leaf labels (default: 0, 1, ..., n-1)
    
    Returns:
        Root TreeNode of the reconstructed tree
    
    Complexity: O(n³) total distance evaluations
    """
    n = D.shape[0]
    if labels is None:
        labels = list(range(n))
    
    if n == 0:
        return TreeNode(label=0)
    
    if n == 1:
        return TreeNode(label=labels[0])
    
    if n == 2:
        root = TreeNode()
        leaf0 = TreeNode(label=labels[0])
        leaf1 = TreeNode(label=labels[1])
        w = D[0, 1] / 2
        root.add_child(w, leaf0)
        root.add_child(w, leaf1)
        return root
    
    if n == 3:
        # Tripod construction
        w0 = pendant_length(D, 0, 1, 2)
        w1 = pendant_length(D, 1, 0, 2)
        w2 = pendant_length(D, 2, 0, 1)
        
        root = TreeNode()
        root.add_child(w0, TreeNode(label=labels[0]))
        root.add_child(w1, TreeNode(label=labels[1]))
        root.add_child(w2, TreeNode(label=labels[2]))
        return root
    
    # n >= 4: Cherry reduction
    ci, cj = find_cherry_pair(D)
    
    # Compute pendant edge weights
    # Pick any reference point k != ci, cj
    k_ref = next(k for k in range(n) if k != ci and k != cj)
    w_ci = pendant_length(D, ci, cj, k_ref)
    w_cj = pendant_length(D, cj, ci, k_ref)
    
    # Build reduced metric: merge ci and cj into one point
    # The merged point has distance to k: D[ci,k] - w_ci = D[cj,k] - w_cj
    keep_indices = [i for i in range(n) if i != cj]
    m = len(keep_indices)
    D_reduced = np.zeros((m, m))
    reduced_labels = []
    ci_new = -1
    
    for a, ia in enumerate(keep_indices):
        if ia == ci:
            ci_new = a
        reduced_labels.append(labels[ia])
        for b, ib in enumerate(keep_indices):
            if ia == ci and ib == ci:
                D_reduced[a, b] = 0
            elif ia == ci:
                D_reduced[a, b] = D[ci, ib] - w_ci
            elif ib == ci:
                D_reduced[a, b] = D[ia, ci] - w_ci
            else:
                D_reduced[a, b] = D[ia, ib]
    
    # Recurse
    subtree = reconstruct_tree(D_reduced, reduced_labels)
    
    # Find the leaf corresponding to the merged point and split it
    merged_leaf = None
    for leaf in subtree.leaves():
        if leaf.label == labels[ci]:
            merged_leaf = leaf
            break
    
    if merged_leaf is None:
        raise RuntimeError("Could not find merged leaf in subtree")
    
    # Replace merged_leaf with a cherry: internal node -> (ci, cj)
    internal = TreeNode()
    leaf_ci = TreeNode(label=labels[ci])
    leaf_cj = TreeNode(label=labels[cj])
    internal.add_child(w_ci, leaf_ci)
    internal.add_child(w_cj, leaf_cj)
    
    # Replace merged_leaf in parent
    if merged_leaf.parent is not None:
        parent = merged_leaf.parent
        parent_weight = merged_leaf.parent_weight
        parent.children = [
            (w, c) if c is not merged_leaf else (parent_weight, internal)
            for w, c in parent.children
        ]
        internal.parent = parent
        internal.parent_weight = parent_weight
    else:
        # merged_leaf was root (shouldn't happen for n >= 4)
        subtree = internal
    
    return subtree


def tree_distance_matrix(root: TreeNode, n: int) -> np.ndarray:
    """Compute the pairwise distance matrix from a tree.
    
    Args:
        root: Root node of the tree
        n: Number of leaves
    
    Returns:
        n x n distance matrix
    """
    leaves = root.leaves()
    label_to_leaf = {leaf.label: leaf for leaf in leaves}
    
    D = np.zeros((n, n))
    for i in range(n):
        for j in range(i + 1, n):
            if i in label_to_leaf and j in label_to_leaf:
                d = label_to_leaf[i].distance_to(label_to_leaf[j])
                D[i, j] = d
                D[j, i] = d
    return D


def verify_reconstruction(D_original: np.ndarray, root: TreeNode,
                          tol: float = 1e-10) -> bool:
    """Verify that a tree correctly realizes a distance matrix.
    
    Args:
        D_original: Original distance matrix
        root: Reconstructed tree
        tol: Numerical tolerance
    
    Returns:
        True if tree distances match D_original within tolerance
    """
    n = D_original.shape[0]
    D_tree = tree_distance_matrix(root, n)
    return np.allclose(D_original, D_tree, atol=tol)


if __name__ == "__main__":
    # Example: reconstruct a 5-point tree metric
    print("=== Tree Metric Reconstruction Demo ===\n")
    
    # Create a known tree and extract its distance matrix
    # Tree: ((0:2, 1:3):1, (2:1, (3:2, 4:1):1):2)
    D = np.array([
        [0, 5, 6, 8, 7],
        [5, 0, 7, 9, 8],
        [6, 7, 0, 4, 3],
        [8, 9, 4, 0, 3],
        [7, 8, 3, 3, 0]
    ], dtype=float)
    
    print("Input distance matrix:")
    print(D)
    print()
    
    print(f"Is finite metric: {is_finite_metric(D)}")
    print(f"Satisfies four-point: {four_point_condition(D)}")
    print()
    
    tree = reconstruct_tree(D)
    print(f"Reconstructed tree (Newick): {tree.to_newick()}")
    print(f"Number of vertices: {tree.num_vertices()}")
    print(f"Number of leaves: {len(tree.leaves())}")
    print()
    
    D_check = tree_distance_matrix(tree, 5)
    print("Reconstructed distances:")
    print(D_check)
    print()
    
    print(f"Reconstruction correct: {verify_reconstruction(D, tree)}")
    print(f"Max error: {np.max(np.abs(D - D_check)):.2e}")
