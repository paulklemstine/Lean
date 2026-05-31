"""
Holographic Verification: Algorithms for Proof Certificate Construction

This module implements the core algorithms for constructing and verifying
holographic certificates for tree-structured proofs, based on Merkle tree
authentication paths.

Type-hinted implementations matching the Lean 4 formalization in
Computation/HolographicCertificate.lean.
"""

from __future__ import annotations
import hashlib
from dataclasses import dataclass
from typing import List, Optional, Tuple
from enum import Enum
import math


# =============================================================================
# Core Data Structures
# =============================================================================

class Direction(Enum):
    """Navigation direction in a binary proof tree."""
    LEFT = "L"
    RIGHT = "R"


@dataclass
class ProofTree:
    """A binary proof tree. Leaves carry labels, internal nodes combine sub-proofs.

    Corresponds to HolographicVerification.ProofTree in Lean.
    """
    label: Optional[str]      # Non-None for leaves
    left: Optional['ProofTree']   # Non-None for internal nodes
    right: Optional['ProofTree']  # Non-None for internal nodes

    @staticmethod
    def leaf(label: str) -> 'ProofTree':
        """Create a leaf node (axiom instance)."""
        return ProofTree(label=label, left=None, right=None)

    @staticmethod
    def node(left: 'ProofTree', right: 'ProofTree') -> 'ProofTree':
        """Create an internal node (inference step)."""
        return ProofTree(label=None, left=left, right=right)

    def is_leaf(self) -> bool:
        return self.left is None and self.right is None

    def num_leaves(self) -> int:
        """Count the number of leaves (axiom instances)."""
        if self.is_leaf():
            return 1
        assert self.left is not None and self.right is not None
        return self.left.num_leaves() + self.right.num_leaves()

    def depth(self) -> int:
        """Compute the depth (height) of the tree."""
        if self.is_leaf():
            return 0
        assert self.left is not None and self.right is not None
        return 1 + max(self.left.depth(), self.right.depth())

    def size(self) -> int:
        """Total number of nodes."""
        if self.is_leaf():
            return 1
        assert self.left is not None and self.right is not None
        return 1 + self.left.size() + self.right.size()

    def extract_leaves(self) -> List[str]:
        """Extract all leaf labels (the 'boundary' of the proof)."""
        if self.is_leaf():
            return [self.label or ""]
        assert self.left is not None and self.right is not None
        return self.left.extract_leaves() + self.right.extract_leaves()


# =============================================================================
# Merkle Hash Scheme
# =============================================================================

class MerkleHashScheme:
    """A Merkle hash scheme with domain separation between leaves and nodes.

    Corresponds to HolographicVerification.MerkleHash in Lean.
    Uses SHA-256 with domain separation prefixes.
    """

    @staticmethod
    def hash_leaf(label: str) -> str:
        """Hash a leaf label with domain separation prefix 0x00."""
        data = b'\x00' + label.encode('utf-8')
        return hashlib.sha256(data).hexdigest()

    @staticmethod
    def hash_node(left_hash: str, right_hash: str) -> str:
        """Hash two child hashes with domain separation prefix 0x01."""
        data = b'\x01' + bytes.fromhex(left_hash) + bytes.fromhex(right_hash)
        return hashlib.sha256(data).hexdigest()


def merkle_root(tree: ProofTree, scheme: MerkleHashScheme = MerkleHashScheme()) -> str:
    """Compute the Merkle root hash of a proof tree.

    Corresponds to HolographicVerification.merkleRoot in Lean.
    """
    if tree.is_leaf():
        return scheme.hash_leaf(tree.label or "")
    assert tree.left is not None and tree.right is not None
    left_hash = merkle_root(tree.left, scheme)
    right_hash = merkle_root(tree.right, scheme)
    return scheme.hash_node(left_hash, right_hash)


# =============================================================================
# Holographic Certificate Construction
# =============================================================================

@dataclass
class HolographicCertificate:
    """A holographic certificate for verifying a specific leaf in a proof tree.

    Contains:
    - root_hash: The Merkle root of the full proof tree
    - leaf_label: The label of the target leaf
    - auth_path: List of sibling hashes along the path from leaf to root
    - directions: Navigation path from root to the target leaf
    """
    root_hash: str
    leaf_label: str
    auth_path: List[str]
    directions: List[Direction]

    @property
    def certificate_length(self) -> int:
        """The length of the certificate (number of sibling hashes)."""
        return len(self.auth_path)


def extract_auth_path(
    tree: ProofTree,
    path: List[Direction],
    scheme: MerkleHashScheme = MerkleHashScheme()
) -> List[str]:
    """Extract the authentication path for a given navigation path.

    Corresponds to HolographicVerification.extractAuthPath in Lean.
    """
    if tree.is_leaf() or not path:
        return []
    assert tree.left is not None and tree.right is not None

    direction = path[0]
    rest = path[1:]

    if direction == Direction.LEFT:
        sub_path = extract_auth_path(tree.left, rest, scheme)
        return sub_path + [merkle_root(tree.right, scheme)]
    else:
        sub_path = extract_auth_path(tree.right, rest, scheme)
        return sub_path + [merkle_root(tree.left, scheme)]


def construct_certificate(
    tree: ProofTree,
    path: List[Direction],
    scheme: MerkleHashScheme = MerkleHashScheme()
) -> HolographicCertificate:
    """Construct a holographic certificate for a specific leaf.

    Args:
        tree: The full proof tree
        path: Navigation path from root to the target leaf
        scheme: The Merkle hash scheme to use

    Returns:
        A HolographicCertificate that can verify the leaf without the full tree.
    """
    # Navigate to the target leaf
    current = tree
    for d in path:
        if current.is_leaf():
            break
        assert current.left is not None and current.right is not None
        current = current.left if d == Direction.LEFT else current.right

    return HolographicCertificate(
        root_hash=merkle_root(tree, scheme),
        leaf_label=current.label or "",
        auth_path=extract_auth_path(tree, path, scheme),
        directions=path
    )


def verify_certificate(
    cert: HolographicCertificate,
    scheme: MerkleHashScheme = MerkleHashScheme()
) -> bool:
    """Verify a holographic certificate.

    Reconstructs the Merkle root from the leaf hash and authentication path,
    then checks it matches the claimed root hash.

    Time complexity: O(certificate_length) = O(log n) for balanced trees.
    """
    current_hash = scheme.hash_leaf(cert.leaf_label)

    # Walk up the authentication path from leaf to root
    # The auth_path is ordered leaf-to-root
    for i, sibling_hash in enumerate(cert.auth_path):
        # Determine which side we're on based on directions (reversed)
        dir_index = len(cert.directions) - 1 - i
        if dir_index >= 0 and dir_index < len(cert.directions):
            direction = cert.directions[dir_index]
            if direction == Direction.LEFT:
                current_hash = scheme.hash_node(current_hash, sibling_hash)
            else:
                current_hash = scheme.hash_node(sibling_hash, current_hash)

    return current_hash == cert.root_hash


# =============================================================================
# Proof Tree Construction Utilities
# =============================================================================

def build_balanced_tree(labels: List[str]) -> ProofTree:
    """Build a balanced binary proof tree from a list of leaf labels.

    This produces trees with depth ⌈log₂(n)⌉, achieving the
    optimal certificate length bound.
    """
    if len(labels) == 0:
        return ProofTree.leaf("empty")
    if len(labels) == 1:
        return ProofTree.leaf(labels[0])

    mid = len(labels) // 2
    left = build_balanced_tree(labels[:mid])
    right = build_balanced_tree(labels[mid:])
    return ProofTree.node(left, right)


def build_linear_tree(labels: List[str]) -> ProofTree:
    """Build a maximally unbalanced (linear) proof tree.

    This produces trees with depth n-1, representing the worst case
    for certificate length.
    """
    if len(labels) == 0:
        return ProofTree.leaf("empty")
    if len(labels) == 1:
        return ProofTree.leaf(labels[0])

    return ProofTree.node(
        ProofTree.leaf(labels[0]),
        build_linear_tree(labels[1:])
    )


def leftmost_path(tree: ProofTree) -> List[Direction]:
    """Get the path to the leftmost leaf."""
    if tree.is_leaf():
        return []
    return [Direction.LEFT] + leftmost_path(tree.left)  # type: ignore


def rightmost_path(tree: ProofTree) -> List[Direction]:
    """Get the path to the rightmost leaf."""
    if tree.is_leaf():
        return []
    return [Direction.RIGHT] + rightmost_path(tree.right)  # type: ignore


# =============================================================================
# Analysis Functions
# =============================================================================

def analyze_certificate_scaling(max_n: int = 1000) -> List[Tuple[int, int, int, float]]:
    """Analyze how certificate length scales with proof size.

    Returns list of (n, balanced_cert_len, linear_cert_len, log2_n) tuples.
    """
    results = []
    for n in range(2, max_n + 1, max(1, max_n // 50)):
        labels = [f"axiom_{i}" for i in range(n)]

        balanced = build_balanced_tree(labels)
        linear = build_linear_tree(labels)

        balanced_path = leftmost_path(balanced)
        linear_path = leftmost_path(linear)

        balanced_cert = extract_auth_path(balanced, balanced_path)
        linear_cert = extract_auth_path(linear, linear_path)

        log2_n = math.log2(n) if n > 0 else 0

        results.append((n, len(balanced_cert), len(linear_cert), log2_n))

    return results


def certificate_compression_ratio(tree: ProofTree, path: List[Direction]) -> float:
    """Compute the compression ratio: certificate_length / proof_size.

    For balanced trees, this should approach 0 as n grows (O(log n / n)).
    """
    cert_len = len(extract_auth_path(tree, path))
    proof_size = tree.size()
    return cert_len / proof_size if proof_size > 0 else 0.0
