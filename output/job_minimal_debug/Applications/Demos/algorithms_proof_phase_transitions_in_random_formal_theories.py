"""
Algorithms for Proof Phase Transitions

Implements exact and Monte Carlo computation of provability probabilities
for monotone certificate systems, including the parallel path model.
"""

from __future__ import annotations
import math
from itertools import combinations
from typing import List, Set, FrozenSet, Tuple
import random


class MonotoneProvabilitySystem:
    """A finite monotone provability system.

    Attributes:
        axioms: List of axiom identifiers.
        certificates: Dict mapping target names to lists of certificates.
            Each certificate is a frozenset of axiom identifiers.
    """

    def __init__(self, axioms: List[int], certificates: dict[str, List[FrozenSet[int]]]):
        """Initialize a monotone provability system.

        Args:
            axioms: List of axiom identifiers (integers).
            certificates: Maps target name -> list of frozensets of axioms.
        """
        self.axioms = list(axioms)
        self.n = len(self.axioms)
        self.certificates = certificates

    def is_provable(self, target: str, selected: Set[int]) -> bool:
        """Check if target is provable from the selected axiom set.

        Args:
            target: Name of the target statement.
            selected: Set of selected axiom identifiers.

        Returns:
            True if some certificate for target is contained in selected.
        """
        for cert in self.certificates.get(target, []):
            if cert.issubset(selected):
                return True
        return False

    def exact_provable_count(self, target: str) -> int:
        """Count the number of axiom subsets from which target is provable.

        Enumerates all 2^n subsets. Only feasible for small n (n ≤ 20).

        Args:
            target: Name of the target statement.

        Returns:
            Number of subsets A ⊆ axioms such that target is provable from A.

        Complexity: O(2^n * |Cert| * k)
        """
        count = 0
        for size in range(self.n + 1):
            for subset in combinations(self.axioms, size):
                if self.is_provable(target, set(subset)):
                    count += 1
        return count

    def exact_provability_probability(self, target: str, p: float) -> float:
        """Compute exact provability probability at parameter p.

        Uses inclusion over all 2^n subsets, weighting each by p^|A| (1-p)^(n-|A|).
        Only feasible for small n (n ≤ 20).

        Args:
            target: Name of the target statement.
            p: Axiom inclusion probability.

        Returns:
            Exact probability that target is provable under p-random selection.
        """
        prob = 0.0
        for size in range(self.n + 1):
            weight = p ** size * (1 - p) ** (self.n - size)
            for subset in combinations(self.axioms, size):
                if self.is_provable(target, set(subset)):
                    prob += weight
        return prob

    def monte_carlo_probability(
        self, target: str, p: float, num_samples: int = 10000
    ) -> float:
        """Estimate provability probability by Monte Carlo sampling.

        Args:
            target: Name of the target statement.
            p: Axiom inclusion probability.
            num_samples: Number of random samples.

        Returns:
            Estimated probability that target is provable.

        Complexity: O(num_samples * |Cert| * k)
        """
        successes = 0
        for _ in range(num_samples):
            selected = {a for a in self.axioms if random.random() < p}
            if self.is_provable(target, selected):
                successes += 1
        return successes / num_samples

    def union_bound(self, target: str, p: float) -> float:
        """Compute the union bound on provability probability.

        Pr[provable] ≤ sum_{S in Cert(t)} p^|S|

        Args:
            target: Name of the target statement.
            p: Axiom inclusion probability.

        Returns:
            Union bound upper estimate.
        """
        return sum(p ** len(cert) for cert in self.certificates.get(target, []))

    def min_cert_size(self, target: str) -> int:
        """Return the minimum certificate size for a target.

        Args:
            target: Name of the target statement.

        Returns:
            Minimum size among all certificates for target.
        """
        certs = self.certificates.get(target, [])
        if not certs:
            return float('inf')
        return min(len(c) for c in certs)

    def cert_size_bound(self, target: str, p: float) -> float:
        """Compute the certificate-size upper bound.

        Pr[provable] ≤ |Cert(t)| * p^k where k = min cert size.

        Args:
            target: Name of the target statement.
            p: Axiom inclusion probability.

        Returns:
            Certificate-size bound estimate.
        """
        k = self.min_cert_size(target)
        num_certs = len(self.certificates.get(target, []))
        return num_certs * p ** k

    def proof_partition_function(self, target: str, lam: float) -> float:
        """Compute the proof partition function Z_t(λ).

        Z_t(λ) = sum_{A: t provable from A} λ^|A|

        Only feasible for small n.

        Args:
            target: Name of the target statement.
            lam: Weight parameter λ.

        Returns:
            Value of the partition function.
        """
        z = 0.0
        for size in range(self.n + 1):
            weight = lam ** size
            for subset in combinations(self.axioms, size):
                if self.is_provable(target, set(subset)):
                    z += weight
        return z


def parallel_path_system(k: int, r: int) -> MonotoneProvabilitySystem:
    """Construct a parallel path provability system.

    Creates r disjoint certificates, each of size k.
    Axiom pool has r*k axioms: {0, 1, ..., r*k - 1}.
    Certificate i = {i*k, i*k+1, ..., i*k+k-1}.

    Args:
        k: Path length (certificate size).
        r: Number of parallel paths (certificates).

    Returns:
        MonotoneProvabilitySystem with one target "tau".
    """
    axioms = list(range(r * k))
    certs = [frozenset(range(i * k, (i + 1) * k)) for i in range(r)]
    return MonotoneProvabilitySystem(axioms, {"tau": certs})


def parallel_path_exact_probability(k: int, r: int, p: float) -> float:
    """Exact provability probability for the parallel path model.

    Pr[provable] = 1 - (1 - p^k)^r

    Args:
        k: Path length.
        r: Number of paths.
        p: Axiom inclusion probability.

    Returns:
        Exact probability.
    """
    return 1.0 - (1.0 - p ** k) ** r


def parallel_path_threshold(k: int, r: int) -> float:
    """Approximate 1/2-threshold for the parallel path model.

    p_{1/2} = (1 - 2^{-1/r})^{1/k}

    Args:
        k: Path length.
        r: Number of paths.

    Returns:
        The probability p at which provability probability equals 1/2.
    """
    return (1.0 - 2.0 ** (-1.0 / r)) ** (1.0 / k)


def parallel_path_susceptibility(k: int, r: int, p: float) -> float:
    """Derivative of provability probability for parallel paths.

    χ(p) = d/dp [1 - (1-p^k)^r] = r * k * p^{k-1} * (1 - p^k)^{r-1}

    Args:
        k: Path length.
        r: Number of paths.
        p: Axiom inclusion probability.

    Returns:
        Value of the susceptibility (derivative).
    """
    if p <= 0:
        return 0.0
    return r * k * p ** (k - 1) * (1.0 - p ** k) ** (r - 1)


def random_certificate_system(
    n: int, num_certs: int, cert_size: int, overlap: int = 0
) -> MonotoneProvabilitySystem:
    """Generate a random certificate system with controlled overlap.

    Args:
        n: Total number of axioms.
        num_certs: Number of certificates to generate.
        cert_size: Size of each certificate.
        overlap: Number of shared axioms between consecutive certificates.

    Returns:
        MonotoneProvabilitySystem with one target "tau".
    """
    axioms = list(range(n))
    certs = []
    for i in range(num_certs):
        if overlap > 0 and i > 0 and certs:
            # Share 'overlap' axioms with previous certificate
            prev = list(certs[-1])
            shared = prev[:overlap]
            remaining = [a for a in axioms if a not in shared]
            new_axioms = random.sample(remaining, cert_size - overlap)
            cert = frozenset(shared + new_axioms)
        else:
            cert = frozenset(random.sample(axioms, cert_size))
        certs.append(cert)
    return MonotoneProvabilitySystem(axioms, {"tau": certs})


# ---- Horn Clause Derivation System ----

class HornClauseSystem:
    """A Horn clause derivation system.

    Models a simple implication logic: given source facts and directed
    implications a → b, derives new facts by forward chaining.
    """

    def __init__(self, variables: List[str], sources: List[str],
                 implications: List[Tuple[str, str]], target: str):
        """Initialize a Horn clause system.

        Args:
            variables: List of propositional variable names.
            sources: Initially true variables.
            implications: List of (antecedent, consequent) pairs.
            target: Variable to derive.
        """
        self.variables = variables
        self.sources = set(sources)
        self.implications = implications
        self.target = target

    def derive(self, selected_implications: Set[int]) -> Set[str]:
        """Forward-chain from sources using selected implications.

        Args:
            selected_implications: Indices into self.implications to use.

        Returns:
            Set of derived variables.
        """
        derived = set(self.sources)
        changed = True
        while changed:
            changed = False
            for idx in selected_implications:
                ante, cons = self.implications[idx]
                if ante in derived and cons not in derived:
                    derived.add(cons)
                    changed = True
        return derived

    def is_target_derivable(self, selected: Set[int]) -> bool:
        """Check if the target is derivable from selected implications."""
        return self.target in self.derive(selected)

    def to_provability_system(self) -> MonotoneProvabilitySystem:
        """Convert to a MonotoneProvabilitySystem by enumerating certificates.

        Note: This is exponential in the worst case. Only use for small systems.
        """
        n = len(self.implications)
        axioms = list(range(n))

        # Find all minimal sufficient sets (certificates) by brute force
        certs = []
        for size in range(1, n + 1):
            for subset in combinations(range(n), size):
                s = set(subset)
                if self.is_target_derivable(s):
                    # Check minimality
                    is_minimal = True
                    for cert in certs:
                        if cert.issubset(s):
                            is_minimal = False
                            break
                    if is_minimal:
                        certs.append(frozenset(s))

        return MonotoneProvabilitySystem(axioms, {"tau": certs})


if __name__ == "__main__":
    # Example usage
    print("=== Parallel Path System (k=3, r=5) ===")
    sys = parallel_path_system(3, 5)
    print(f"Axioms: {sys.n}")
    print(f"Certificates: {len(sys.certificates['tau'])}")
    print(f"Min cert size: {sys.min_cert_size('tau')}")

    for p in [0.1, 0.3, 0.5, 0.7, 0.9]:
        exact = parallel_path_exact_probability(3, 5, p)
        bound = sys.union_bound("tau", p)
        print(f"  p={p:.1f}: exact={exact:.4f}, union_bound={bound:.4f}")

    print(f"\n1/2-threshold: {parallel_path_threshold(3, 5):.4f}")

    print("\n=== Horn Clause System ===")
    horn = HornClauseSystem(
        variables=["v0", "v1", "v2", "v3"],
        sources=["v0"],
        implications=[("v0", "v1"), ("v1", "v2"), ("v2", "v3"),
                       ("v0", "v2"), ("v0", "v3")],
        target="v3"
    )
    mps = horn.to_provability_system()
    print(f"Certificates found: {len(mps.certificates['tau'])}")
    for cert in mps.certificates["tau"]:
        impls = [f"{horn.implications[i][0]}→{horn.implications[i][1]}" for i in cert]
        print(f"  {impls}")
