#!/usr/bin/env python3
"""
Algorithms for Information-Theoretic Subgroup Universality

Implements verified algorithms for computing subgroup entropy,
partition functions, and mutual information diagnostics.

Time complexity: O(|S|) per entropy computation where |S| is family size.
Space complexity: O(|S|) for weight/probability storage.

Application keywords: Shannon entropy, mutual information, subgroup growth,
universality classes, partition function, algebraic combinatorics.
"""

import math
from typing import List, Tuple, Dict, Optional


def divisors(n: int) -> List[int]:
    """
    Compute all divisors of n.

    Time: O(sqrt(n))
    Space: O(d(n)) where d(n) is the number of divisors

    >>> divisors(12)
    [1, 2, 3, 4, 6, 12]
    """
    divs = []
    for i in range(1, int(n**0.5) + 1):
        if n % i == 0:
            divs.append(i)
            if i != n // i:
                divs.append(n // i)
    return sorted(divs)


class SubgroupEntropyCalculator:
    """
    Computes information-theoretic invariants for subgroup families.

    Given a finite family of subgroup indices {[G:H_i]}, computes:
    - weights w(H) = [G:H]^{-2}
    - partition function Z = sum w(H)
    - probabilities p(H) = w(H) / Z
    - Shannon entropy H = -sum p log p
    - self-information I(H) = -log p(H)

    Attributes:
        indices: List of subgroup indices [G:H_i]
        weights: Computed Boltzmann weights
        Z: Partition function
        probs: Normalized probability distribution
        entropy: Shannon entropy
    """

    def __init__(self, indices: List[int]):
        """
        Initialize with a list of subgroup indices.

        Args:
            indices: List of positive integers [G:H_i] for each subgroup H_i

        Raises:
            ValueError: If indices is empty or contains non-positive values

        Time: O(|S|) where |S| = len(indices)
        """
        if not indices:
            raise ValueError("Subgroup family must be nonempty")
        if any(i <= 0 for i in indices):
            raise ValueError("All indices must be positive")

        self.indices = indices
        self.weights = [1.0 / (idx ** 2) for idx in indices]
        self.Z = sum(self.weights)
        self.probs = [w / self.Z for w in self.weights]
        self.entropy = -sum(p * math.log(p) for p in self.probs if p > 0)

    def self_information(self, i: int) -> float:
        """Surprisal of the i-th subgroup: I(H_i) = -log p(H_i)."""
        return -math.log(self.probs[i])

    def expected_self_info(self) -> float:
        """Expected self-information E[I] = sum p(H) I(H). Equals entropy by Gibbs identity."""
        return sum(p * (-math.log(p)) for p in self.probs if p > 0)

    def max_entropy(self) -> float:
        """Maximum possible entropy log|S|."""
        return math.log(len(self.indices))

    def entropy_deficit(self) -> float:
        """Concentration measure: log|S| - H(S). Zero iff uniform."""
        return self.max_entropy() - self.entropy

    def kl_divergence_from_uniform(self) -> float:
        """KL divergence D(p || u) where u is uniform. Equals entropy deficit."""
        n = len(self.indices)
        return sum(p * math.log(p * n) for p in self.probs if p > 0)

    def summary(self) -> Dict:
        """Return a dictionary summary of all computed quantities."""
        return {
            "indices": self.indices,
            "n_subgroups": len(self.indices),
            "partition_function": self.Z,
            "entropy": self.entropy,
            "max_entropy": self.max_entropy(),
            "entropy_deficit": self.entropy_deficit(),
            "kl_from_uniform": self.kl_divergence_from_uniform(),
            "gibbs_check": abs(self.entropy - self.expected_self_info()) < 1e-12,
        }


class ProductFamilyAnalyzer:
    """
    Analyzes product families for entropy additivity and independence.

    Given two subgroup families S_G and S_K, constructs the product family
    {H × L : H ∈ S_G, L ∈ S_K} and verifies:
    - Z(G×K) = Z(G) · Z(K)  (partition function multiplicativity)
    - H(G×K) = H(G) + H(K)  (entropy additivity)
    - I(G;K) = 0             (statistical independence)

    Time: O(|S_G| · |S_K|) for all computations
    """

    def __init__(self, indices_G: List[int], indices_K: List[int]):
        self.calc_G = SubgroupEntropyCalculator(indices_G)
        self.calc_K = SubgroupEntropyCalculator(indices_K)

        # Product family: [G×K : H×L] = [G:H] · [K:L]
        prod_indices = [ig * ik for ig in indices_G for ik in indices_K]
        self.calc_prod = SubgroupEntropyCalculator(prod_indices)

    def verify_partition_multiplicativity(self, tol: float = 1e-10) -> Tuple[bool, float]:
        """Check Z(G×K) = Z(G) · Z(K)."""
        expected = self.calc_G.Z * self.calc_K.Z
        actual = self.calc_prod.Z
        error = abs(actual - expected)
        return error < tol, error

    def verify_entropy_additivity(self, tol: float = 1e-10) -> Tuple[bool, float]:
        """Check H(G×K) = H(G) + H(K)."""
        expected = self.calc_G.entropy + self.calc_K.entropy
        actual = self.calc_prod.entropy
        error = abs(actual - expected)
        return error < tol, error

    def mutual_information(self) -> float:
        """I(G;K) = H(G) + H(K) - H(G×K)."""
        return self.calc_G.entropy + self.calc_K.entropy - self.calc_prod.entropy

    def full_report(self) -> Dict:
        """Complete diagnostic report."""
        z_ok, z_err = self.verify_partition_multiplicativity()
        h_ok, h_err = self.verify_entropy_additivity()
        return {
            "H_G": self.calc_G.entropy,
            "H_K": self.calc_K.entropy,
            "H_GxK": self.calc_prod.entropy,
            "H_G_plus_H_K": self.calc_G.entropy + self.calc_K.entropy,
            "partition_multiplicative": z_ok,
            "partition_error": z_err,
            "entropy_additive": h_ok,
            "entropy_error": h_err,
            "mutual_information": self.mutual_information(),
        }


def cyclic_group_family(n: int) -> List[int]:
    """
    Subgroup indices for Z/nZ.
    Each divisor d of n gives a unique subgroup of index d.

    >>> cyclic_group_family(6)
    [1, 2, 3, 6]
    """
    return divisors(n)


def universality_class_comparison(families: Dict[str, List[int]]) -> None:
    """
    Compare universality classes by entropy scaling.

    Groups with similar entropy are in the same universality class,
    regardless of their algebraic structure.

    Args:
        families: Dict mapping group names to index lists
    """
    print("\nUniversality Class Comparison")
    print("-" * 60)
    print(f"{'Group':<15} {'|S|':>5} {'H':>8} {'log|S|':>8} {'H/log|S|':>8}")
    print("-" * 60)

    results = []
    for name, indices in families.items():
        calc = SubgroupEntropyCalculator(indices)
        ratio = calc.entropy / calc.max_entropy() if calc.max_entropy() > 0 else 0
        results.append((name, len(indices), calc.entropy, calc.max_entropy(), ratio))
        print(f"{name:<15} {len(indices):>5} {calc.entropy:>8.4f} {calc.max_entropy():>8.4f} {ratio:>8.4f}")

    # Cluster by H/log|S| ratio
    print("\nUniversality classes (grouped by H/log|S| ratio):")
    sorted_results = sorted(results, key=lambda x: x[4])
    for name, n, h, m, r in sorted_results:
        bar = "#" * int(r * 40)
        print(f"  {name:<15} [{bar:<40}] {r:.3f}")


if __name__ == "__main__":
    # Example usage
    print("=== SubgroupEntropyCalculator Demo ===\n")

    calc = SubgroupEntropyCalculator(cyclic_group_family(12))
    print(f"Z/12Z summary: {calc.summary()}\n")

    print("=== ProductFamilyAnalyzer Demo ===\n")
    analyzer = ProductFamilyAnalyzer(
        cyclic_group_family(6),
        cyclic_group_family(4)
    )
    report = analyzer.full_report()
    for k, v in report.items():
        print(f"  {k}: {v}")

    print("\n=== Universality Class Comparison ===")
    families = {
        "Z/2Z": cyclic_group_family(2),
        "Z/3Z": cyclic_group_family(3),
        "Z/4Z": cyclic_group_family(4),
        "Z/6Z": cyclic_group_family(6),
        "Z/12Z": cyclic_group_family(12),
        "Z/30Z": cyclic_group_family(30),
        "Z/60Z": cyclic_group_family(60),
    }
    universality_class_comparison(families)
