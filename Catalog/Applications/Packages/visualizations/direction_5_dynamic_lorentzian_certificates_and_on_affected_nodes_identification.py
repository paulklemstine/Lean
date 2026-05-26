#!/usr/bin/env python3
"""
Algorithms for Dynamic Lorentzian Certificate Maintenance

Implements the core algorithms from the research paper:
1. AffectedNodes — identify derivative nodes affected by a rank-1 update
2. DynamicCertificateUpdate — update only affected certificate leaves
3. WarmStartDiscrepancy — estimate distribution drift from coefficient perturbation
4. CompareUpdateStrategies — benchmark dynamic vs full rebuild
"""

from itertools import product
from collections import defaultdict
import random
import math
from typing import List, Tuple, Dict, Set, Optional


# ============================================================================
# Algorithm 1: Affected Nodes Identification
# ============================================================================

def affected_nodes(alpha: Tuple[int, ...], max_depth: int) -> Dict[int, List[Tuple[int, ...]]]:
    """
    Identify all derivative tree nodes affected by a rank-1 monomial update X^α.

    For each derivative depth k (0 ≤ k ≤ max_depth), computes the set:
        Affected(α, k) = {β : sum(β) = k and β_i ≤ α_i for all i}

    Args:
        alpha: Monomial exponent vector (n-tuple of nonneg ints)
        max_depth: Maximum derivative depth to check (typically d-2)

    Returns:
        Dictionary mapping depth k to list of affected multiindices β

    Complexity: O(∏(α_i + 1)) total across all depths
    """
    n = len(alpha)
    ranges = [range(a + 1) for a in alpha]
    result: Dict[int, List[Tuple[int, ...]]] = defaultdict(list)

    for beta in product(*ranges):
        k = sum(beta)
        if k <= max_depth:
            result[k].append(beta)

    return dict(result)


def affected_count_fast(alpha: Tuple[int, ...], k: int) -> int:
    """
    Count affected multiindices at depth k using dynamic programming.

    Uses the recurrence: count(α, k, i) = sum over j=0..min(α_i, k) of count(α, k-j, i-1)

    Complexity: O(n * k * max(α_i))
    """
    n = len(alpha)
    if k < 0:
        return 0

    # dp[j] = number of ways to achieve sum j using first i coordinates
    dp = [0] * (k + 1)
    dp[0] = 1

    for i in range(n):
        new_dp = [0] * (k + 1)
        for j in range(k + 1):
            if dp[j] == 0:
                continue
            for v in range(min(alpha[i], k - j) + 1):
                new_dp[j + v] += dp[j]
        dp = new_dp

    return dp[k]


# ============================================================================
# Algorithm 2: Dynamic Certificate Update
# ============================================================================

class CertificateNode:
    """A node in the Lorentzian certificate tree."""

    def __init__(self, depth: int, multiindex: Tuple[int, ...], value: float = 0.0):
        self.depth = depth
        self.multiindex = multiindex
        self.value = value  # e.g., spectral gap or eigenvalue check result
        self.children: List['CertificateNode'] = []
        self.is_valid = True


class LorentzianCertificate:
    """
    A certificate tree for Lorentzian-ness verification.

    The tree has depth d-2, with each internal node at depth k corresponding
    to an iterated partial derivative ∂^β f of total order k.
    Leaves (at depth d-2) correspond to quadratic forms whose negative
    semidefiniteness certifies the Lorentzian property.
    """

    def __init__(self, n: int, d: int):
        self.n = n
        self.d = d
        self.max_depth = max(0, d - 2)
        self.nodes: Dict[Tuple[int, ...], CertificateNode] = {}
        self._build_tree()

    def _build_tree(self):
        """Build the certificate tree with all derivative nodes."""
        for k in range(self.max_depth + 1):
            for beta in self._multiindices(k):
                node = CertificateNode(k, beta, value=random.uniform(0, 1))
                self.nodes[beta] = node

    def _multiindices(self, k: int) -> List[Tuple[int, ...]]:
        """Generate all multiindices of total order k on n variables."""
        if self.n == 0:
            return [()]
        result = []
        self._gen_multiindices(k, self.n, [], result)
        return result

    def _gen_multiindices(self, remaining: int, dims: int,
                          current: list, result: list):
        if dims == 1:
            result.append(tuple(current + [remaining]))
            return
        for v in range(remaining + 1):
            self._gen_multiindices(remaining - v, dims - 1,
                                   current + [v], result)

    def total_nodes(self) -> int:
        return len(self.nodes)

    def dynamic_update(self, alpha: Tuple[int, ...],
                       recompute_fn=None) -> Tuple[int, int]:
        """
        Perform a dynamic certificate update for rank-1 monomial X^α.

        Only recomputes nodes whose multiindex is coordinatewise ≤ α.
        Returns (nodes_updated, nodes_total).
        """
        n = len(alpha)
        updated = 0

        for beta, node in self.nodes.items():
            # Check if β ≤ α coordinatewise
            if all(beta[i] <= alpha[i] for i in range(n)):
                # This node is affected — recompute
                if recompute_fn:
                    node.value = recompute_fn(beta)
                else:
                    node.value = random.uniform(0, 1)
                updated += 1

        return updated, self.total_nodes()

    def full_rebuild(self, recompute_fn=None) -> Tuple[int, int]:
        """Full certificate rebuild: recompute all nodes."""
        for beta, node in self.nodes.items():
            if recompute_fn:
                node.value = recompute_fn(beta)
            else:
                node.value = random.uniform(0, 1)
        total = self.total_nodes()
        return total, total


def dynamic_certificate_update(n: int, d: int, alpha: Tuple[int, ...]) -> Dict:
    """
    Main algorithm: compare dynamic update vs full rebuild.

    Args:
        n: Number of variables
        d: Polynomial degree
        alpha: Monomial exponent for rank-1 update

    Returns:
        Dictionary with cost comparison metrics
    """
    cert = LorentzianCertificate(n, d)

    updated, total = cert.dynamic_update(alpha)
    rebuild_total, _ = cert.full_rebuild()

    return {
        'n': n,
        'd': d,
        'alpha': alpha,
        'dynamic_nodes_updated': updated,
        'total_nodes': total,
        'rebuild_nodes': rebuild_total,
        'speedup': total / max(updated, 1),
        'fraction_affected': updated / max(total, 1),
    }


# ============================================================================
# Algorithm 3: Warm-Start Discrepancy Estimation
# ============================================================================

def warm_start_discrepancy(w: List[float], w_prime: List[float]) -> Dict:
    """
    Estimate warm-start discrepancy between normalized distributions.

    Computes:
    - ℓ₁ distance between weight vectors
    - Total variation between normalized distributions
    - Upper bound TV ≤ Δ/min(Z, Z')

    Args:
        w: Original weight vector (nonneg)
        w_prime: Updated weight vector (nonneg)

    Returns:
        Dictionary with discrepancy metrics
    """
    n = len(w)
    assert len(w_prime) == n

    Z = sum(w)
    Z_prime = sum(w_prime)

    if Z == 0 or Z_prime == 0:
        return {'error': 'Zero total weight'}

    mu = [x / Z for x in w]
    nu = [x / Z_prime for x in w_prime]

    l1_dist = sum(abs(a - b) for a, b in zip(w, w_prime))
    tv_dist = 0.5 * sum(abs(a - b) for a, b in zip(mu, nu))
    bound = l1_dist / min(Z, Z_prime)

    return {
        'n': n,
        'Z': Z,
        'Z_prime': Z_prime,
        'l1_distance': l1_dist,
        'tv_distance': tv_dist,
        'tv_bound': bound,
        'bound_tight': tv_dist / max(bound, 1e-15),
        'bound_holds': tv_dist <= bound + 1e-10,
    }


# ============================================================================
# Algorithm 4: Full Comparison Pipeline
# ============================================================================

def compare_update_strategies(n: int, d: int,
                               alpha: Tuple[int, ...]) -> Dict:
    """
    Full comparison of dynamic vs rebuild strategies.

    Combines certificate cost analysis with warm-start discrepancy estimation.
    """
    # Certificate costs
    max_depth = max(0, d - 2)
    affected = affected_nodes(alpha, max_depth)
    total_affected = sum(len(v) for v in affected.values())

    # Generate example weight vectors
    random.seed(hash(alpha) % 2**31)
    n_bases = max(10, 2 * n)
    w = [random.uniform(0.1, 2.0) for _ in range(n_bases)]
    w_prime = w.copy()
    # Perturb one weight (simulating rank-1 update effect on coefficients)
    perturb_idx = hash(alpha) % n_bases
    w_prime[perturb_idx] += 0.5

    disc = warm_start_discrepancy(w, w_prime)

    return {
        'certificate': {
            'n': n,
            'd': d,
            'alpha': alpha,
            'max_depth': max_depth,
            'affected_by_depth': {k: len(v) for k, v in affected.items()},
            'total_affected': total_affected,
            'dynamic_cost': n**2 * total_affected,
            'rebuild_cost': n**d,
        },
        'warm_start': disc,
    }


# ============================================================================
# Example Usage
# ============================================================================

if __name__ == "__main__":
    print("Dynamic Lorentzian Certificate Algorithms")
    print("=" * 50)

    # Example 1: Affected nodes
    alpha = (2, 1, 1, 0)
    d = sum(alpha)
    print(f"\n1. Affected nodes for α = {alpha}, d = {d}:")
    nodes = affected_nodes(alpha, d - 2)
    for k, betas in sorted(nodes.items()):
        print(f"   Depth {k}: {len(betas)} affected nodes")

    # Example 2: Fast counting
    print(f"\n2. Fast affected count comparison:")
    for k in range(d):
        fast = affected_count_fast(alpha, k)
        exact = len(affected_nodes(alpha, k).get(k, []))
        print(f"   k={k}: fast={fast}, exact={exact}, match={fast==exact}")

    # Example 3: Dynamic update
    print(f"\n3. Dynamic certificate update:")
    result = dynamic_certificate_update(4, 4, alpha)
    for key, val in result.items():
        print(f"   {key}: {val}")

    # Example 4: Warm-start discrepancy
    print(f"\n4. Warm-start discrepancy:")
    w = [1.0, 2.0, 1.5, 3.0, 0.5]
    w_prime = [1.0, 2.3, 1.5, 3.0, 0.5]
    disc = warm_start_discrepancy(w, w_prime)
    for key, val in disc.items():
        if isinstance(val, float):
            print(f"   {key}: {val:.6f}")
        else:
            print(f"   {key}: {val}")

    # Example 5: Full comparison
    print(f"\n5. Full comparison pipeline:")
    comp = compare_update_strategies(4, 4, (1, 1, 1, 1))
    for section, data in comp.items():
        print(f"\n   {section}:")
        for key, val in data.items():
            print(f"     {key}: {val}")
