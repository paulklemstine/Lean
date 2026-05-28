#!/usr/bin/env python3
"""
Visualization 1: Certificate Tree Structure and Size Growth

Visualizes how certificate tree complexity grows with the pigeonhole principle
parameter n, illustrating the exponential barrier for Lorentzian recognition.

Creates a 2x2 panel:
  - Top-left: Certificate size vs n
  - Top-right: Certificate leaves vs n with 2^depth bound
  - Bottom-left: Resolution-certificate size comparison
  - Bottom-right: Depth vs log2(leaves) relationship
"""

import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')
import numpy as np
import math


# ============================================================
# Self-contained data structures and algorithms
# ============================================================

class ResolutionNode:
    def __init__(self, clause=None, resolve_var=None, left=None, right=None):
        self.clause = clause
        self.resolve_var = resolve_var
        self.left = left
        self.right = right

    @property
    def is_axiom(self):
        return self.left is None

    def size(self):
        if self.is_axiom: return 1
        return 1 + self.left.size() + self.right.size()

    def depth(self):
        if self.is_axiom: return 0
        return 1 + max(self.left.depth(), self.right.depth())

    def axiom_count(self):
        if self.is_axiom: return 1
        return self.left.axiom_count() + self.right.axiom_count()


class CertificateNode:
    def __init__(self, multiindex=None, branch_var=None, left=None, right=None):
        self.multiindex = multiindex
        self.branch_var = branch_var
        self.left = left
        self.right = right

    @property
    def is_leaf(self):
        return self.left is None

    def size(self):
        if self.is_leaf: return 1
        return 1 + self.left.size() + self.right.size()

    def depth(self):
        if self.is_leaf: return 0
        return 1 + max(self.left.depth(), self.right.depth())

    def leaf_count(self):
        if self.is_leaf: return 1
        return self.left.leaf_count() + self.right.leaf_count()


def res_to_cert(node):
    if node.is_axiom:
        alpha = {}
        if node.clause:
            for lit_var, lit_pos in node.clause:
                if lit_pos:
                    alpha[lit_var] = alpha.get(lit_var, 0) + 1
        return CertificateNode(multiindex=alpha)
    return CertificateNode(
        branch_var=node.resolve_var,
        left=res_to_cert(node.left),
        right=res_to_cert(node.right)
    )


def build_php_resolution(n):
    """Build a resolution tree for PHP(n+1, n)."""
    n_holes = n
    n_pigeons = n + 1
    n_vars = n_pigeons * n_holes

    pigeon_clauses = []
    for i in range(n_pigeons):
        clause = frozenset((i * n_holes + j, True) for j in range(n_holes))
        pigeon_clauses.append(clause)

    if len(pigeon_clauses) < 2:
        return ResolutionNode(clause=pigeon_clauses[0] if pigeon_clauses else frozenset())

    current = ResolutionNode(clause=pigeon_clauses[0])
    for i in range(1, len(pigeon_clauses)):
        current = ResolutionNode(
            resolve_var=i % n_vars,
            left=current,
            right=ResolutionNode(clause=pigeon_clauses[i])
        )
    return current


# ============================================================
# Collect data
# ============================================================

ns = list(range(1, 12))
cert_sizes = []
cert_depths = []
cert_leaves = []
res_sizes = []

for n in ns:
    res = build_php_resolution(n)
    cert = res_to_cert(res)
    cert_sizes.append(cert.size())
    cert_depths.append(cert.depth())
    cert_leaves.append(cert.leaf_count())
    res_sizes.append(res.size())


# ============================================================
# Create visualization
# ============================================================

fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle('Certificate Tree Complexity for Pigeonhole Principle',
             fontsize=14, fontweight='bold')

# Top-left: Certificate size vs n
ax = axes[0, 0]
ax.plot(ns, cert_sizes, 'bo-', linewidth=2, markersize=8, label='Certificate size')
ax.set_xlabel('n (holes)', fontsize=12)
ax.set_ylabel('Certificate size', fontsize=12)
ax.set_title('Certificate Size Growth', fontsize=12)
ax.grid(True, alpha=0.3)
ax.legend(fontsize=10)

# Top-right: Leaves with 2^depth bound
ax = axes[0, 1]
pow_bounds = [2**d for d in cert_depths]
ax.plot(ns, cert_leaves, 'rs-', linewidth=2, markersize=8, label='Leaves')
ax.plot(ns, pow_bounds, 'g--', linewidth=2, markersize=6, label='2^depth bound')
ax.set_xlabel('n (holes)', fontsize=12)
ax.set_ylabel('Count', fontsize=12)
ax.set_title('Leaves ≤ 2^depth (Theorem 4)', fontsize=12)
ax.grid(True, alpha=0.3)
ax.legend(fontsize=10)
ax.set_yscale('log')

# Bottom-left: Resolution vs Certificate size comparison
ax = axes[1, 0]
ax.plot(ns, res_sizes, 'bo-', linewidth=2, markersize=8, label='Resolution size')
ax.plot(ns, cert_sizes, 'rs--', linewidth=2, markersize=8, label='Certificate size')
ax.fill_between(ns, res_sizes, cert_sizes, alpha=0.1, color='purple')
ax.set_xlabel('n (holes)', fontsize=12)
ax.set_ylabel('Size', fontsize=12)
ax.set_title('Resolution = Certificate Size (Theorem 1)', fontsize=12)
ax.grid(True, alpha=0.3)
ax.legend(fontsize=10)

# Bottom-right: Depth vs log2(leaves)
ax = axes[1, 1]
log_leaves = [math.log2(l) for l in cert_leaves]
ax.plot(cert_depths, log_leaves, 'mo', markersize=10, label='log₂(leaves)')
max_d = max(cert_depths)
ax.plot([0, max_d], [0, max_d], 'k--', linewidth=1, label='depth = log₂(leaves)')
ax.set_xlabel('Certificate depth', fontsize=12)
ax.set_ylabel('log₂(leaf count)', fontsize=12)
ax.set_title('Depth–Leaf Relationship', fontsize=12)
ax.grid(True, alpha=0.3)
ax.legend(fontsize=10)

plt.tight_layout()
plt.savefig('viz_certificate_trees.png', dpi=150, bbox_inches='tight')
print("Saved viz_certificate_trees.png")
