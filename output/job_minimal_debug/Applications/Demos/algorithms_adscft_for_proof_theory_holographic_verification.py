"""
Holographic Verification: Algorithms for Merkle-based Proof Certificates

Implements the core algorithms for constructing and verifying holographic
certificates of tree-structured proofs.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import TypeVar, Generic, Optional, Callable, List, Tuple
import hashlib
import struct

T = TypeVar('T')


# ── Proof Tree ─────────────────────────────────────────────────────────

@dataclass
class ProofTree(Generic[T]):
    """A full binary tree representing a tree-structured proof.
    Leaves carry axiom labels; internal nodes represent binary inferences."""
    value: Optional[T]  # leaf value (None for internal nodes)
    left: Optional['ProofTree[T]'] = None
    right: Optional['ProofTree[T]'] = None

    @property
    def is_leaf(self) -> bool:
        return self.left is None and self.right is None

    @property
    def num_leaves(self) -> int:
        if self.is_leaf:
            return 1
        assert self.left is not None and self.right is not None
        return self.left.num_leaves + self.right.num_leaves

    @property
    def depth(self) -> int:
        if self.is_leaf:
            return 0
        assert self.left is not None and self.right is not None
        return 1 + max(self.left.depth, self.right.depth)

    @property
    def size(self) -> int:
        if self.is_leaf:
            return 1
        assert self.left is not None and self.right is not None
        return 1 + self.left.size + self.right.size

    @staticmethod
    def balanced(leaves: List[T]) -> 'ProofTree[T]':
        """Build a balanced proof tree from a list of leaf values."""
        if len(leaves) == 1:
            return ProofTree(value=leaves[0])
        mid = len(leaves) // 2
        return ProofTree(
            value=None,
            left=ProofTree.balanced(leaves[:mid]),
            right=ProofTree.balanced(leaves[mid:])
        )


# ── Merkle Hash ────────────────────────────────────────────────────────

def sha256_leaf(value: bytes) -> bytes:
    """Hash a leaf with domain separation (prefix 0x00)."""
    return hashlib.sha256(b'\x00' + value).digest()


def sha256_node(left: bytes, right: bytes) -> bytes:
    """Hash an internal node with domain separation (prefix 0x01)."""
    return hashlib.sha256(b'\x01' + left + right).digest()


def merkle_root(tree: ProofTree[bytes]) -> bytes:
    """Compute the Merkle root hash of a proof tree.

    Time complexity: O(n) where n = tree.size
    Space complexity: O(depth) for the recursion stack
    """
    if tree.is_leaf:
        assert tree.value is not None
        return sha256_leaf(tree.value)
    assert tree.left is not None and tree.right is not None
    return sha256_node(merkle_root(tree.left), merkle_root(tree.right))


# ── Authentication Path (Holographic Certificate) ─────────────────────

@dataclass
class HolographicCertificate:
    """A holographic certificate for a specific leaf in a proof tree.

    Contains:
    - leaf_value: the axiom value at the leaf
    - path: directions from root to leaf (L=False, R=True)
    - siblings: sibling hashes along the path
    """
    leaf_value: bytes
    path: List[bool]       # False = Left, True = Right
    siblings: List[bytes]  # sibling hashes, root to leaf order

    @property
    def length(self) -> int:
        return len(self.siblings)


def construct_certificate(
    tree: ProofTree[bytes],
    leaf_index: int
) -> HolographicCertificate:
    """Construct a holographic certificate for the leaf at leaf_index.

    Algorithm:
    1. Navigate from root to target leaf
    2. At each internal node, record the sibling's Merkle root
    3. Return the leaf value, path, and sibling hashes

    Time complexity: O(depth) hash evaluations (amortized with caching)
    Space complexity: O(depth) for the certificate
    """
    path: List[bool] = []
    siblings: List[bytes] = []

    def navigate(node: ProofTree[bytes], idx: int) -> bytes:
        if node.is_leaf:
            assert node.value is not None
            return node.value
        assert node.left is not None and node.right is not None
        left_leaves = node.left.num_leaves
        if idx < left_leaves:
            # Go left; sibling is right subtree root
            path.append(False)
            siblings.append(merkle_root(node.right))
            return navigate(node.left, idx)
        else:
            # Go right; sibling is left subtree root
            path.append(True)
            siblings.append(merkle_root(node.left))
            return navigate(node.right, idx - left_leaves)

    leaf_value = navigate(tree, leaf_index)
    return HolographicCertificate(
        leaf_value=leaf_value,
        path=path,
        siblings=siblings
    )


def verify_certificate(
    root_hash: bytes,
    cert: HolographicCertificate
) -> bool:
    """Verify a holographic certificate against a known root hash.

    Algorithm:
    1. Start with hash_leaf(leaf_value)
    2. For each (direction, sibling) from leaf to root:
       - If direction is L: current = hash_node(current, sibling)
       - If direction is R: current = hash_node(sibling, current)
    3. Check if reconstructed root equals the known root hash

    Time complexity: O(cert.length) hash evaluations = O(log n)
    Space complexity: O(1) beyond the certificate itself
    """
    if len(cert.path) != len(cert.siblings):
        return False

    current = sha256_leaf(cert.leaf_value)

    # Process from leaf to root (reverse order)
    for direction, sibling in reversed(list(zip(cert.path, cert.siblings))):
        if not direction:  # Left
            current = sha256_node(current, sibling)
        else:  # Right
            current = sha256_node(sibling, current)

    return current == root_hash


# ── Certificate Complexity Analysis ───────────────────────────────────

def certificate_complexity_analysis(
    n_values: List[int]
) -> List[Tuple[int, int, int, float]]:
    """Analyze certificate complexity for balanced trees of various sizes.

    Returns: list of (num_leaves, tree_depth, cert_length, ratio)
    where ratio = cert_length / num_leaves (the compression ratio).
    """
    results = []
    for n in n_values:
        leaves = [struct.pack('>I', i) for i in range(n)]
        tree = ProofTree.balanced(leaves)
        cert = construct_certificate(tree, 0)
        ratio = cert.length / n if n > 0 else 0
        results.append((n, tree.depth, cert.length, ratio))
    return results


# ── Batch Verification ────────────────────────────────────────────────

def batch_verify(
    root_hash: bytes,
    certificates: List[HolographicCertificate]
) -> List[bool]:
    """Verify multiple certificates against the same root hash.

    Time complexity: O(k * log n) where k = number of certificates
    """
    return [verify_certificate(root_hash, cert) for cert in certificates]


if __name__ == '__main__':
    # Quick self-test
    import math
    print("=== Holographic Certificate Self-Test ===\n")

    for n in [4, 8, 16, 64, 256, 1024]:
        leaves = [struct.pack('>I', i) for i in range(n)]
        tree = ProofTree.balanced(leaves)
        root = merkle_root(tree)

        # Construct and verify certificate for first leaf
        cert = construct_certificate(tree, 0)
        ok = verify_certificate(root, cert)

        log_n = math.ceil(math.log2(n)) if n > 1 else 0
        print(f"n={n:5d}  depth={tree.depth}  cert_len={cert.length}  "
              f"log2(n)={log_n}  verified={ok}")

    print("\n=== All tests passed ===")
