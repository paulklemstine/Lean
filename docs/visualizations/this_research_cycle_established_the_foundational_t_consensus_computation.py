"""
Algorithms for Phantom Topology Theory

This module implements the core algorithms for computing phantom topological
invariants on finite sets.

Classes:
    FiniteTopology: Represents a topology on a finite set.
    PhantomSystem: A collection of observer topologies.
    PhantomFiltration: Sequential observer addition framework.

Algorithms:
    - Consensus computation (intersection of open-set families)
    - Phantom number computation (minimum decomposition)
    - Phantom spectrum enumeration
    - Phantom filtration with stabilization detection
    - Phantom entropy computation
"""

from itertools import combinations, chain
from typing import FrozenSet, Set, List, Optional, Tuple
from functools import reduce


class FiniteTopology:
    """
    A topology on a finite set, represented as a collection of open sets.

    The underlying set X is inferred from the maximal open set.
    Open sets are stored as frozensets of frozensets for hashability.

    Attributes:
        X: The underlying set.
        opens: The collection of open sets.
    """

    def __init__(self, X: FrozenSet, opens: FrozenSet[FrozenSet]):
        """
        Initialize a topology.

        Args:
            X: The underlying set.
            opens: Collection of open sets (must form a valid topology).
        """
        self.X = frozenset(X)
        self.opens = frozenset(opens)

    @classmethod
    def discrete(cls, X) -> 'FiniteTopology':
        """The discrete topology: every subset is open."""
        X = frozenset(X)
        all_subs = []
        items = list(X)
        for r in range(len(items) + 1):
            for c in combinations(items, r):
                all_subs.append(frozenset(c))
        return cls(X, frozenset(all_subs))

    @classmethod
    def indiscrete(cls, X) -> 'FiniteTopology':
        """The indiscrete topology: only ∅ and X are open."""
        X = frozenset(X)
        return cls(X, frozenset([frozenset(), X]))

    def is_open(self, U: FrozenSet) -> bool:
        """Check if a set is open in this topology."""
        return frozenset(U) in self.opens

    def __eq__(self, other):
        return isinstance(other, FiniteTopology) and self.opens == other.opens

    def __hash__(self):
        return hash(self.opens)

    def __le__(self, other):
        """τ₁ ≤ τ₂ means τ₁ is finer (has more open sets)."""
        return other.opens.issubset(self.opens)

    def __repr__(self):
        return f"Topology(|opens|={len(self.opens)})"

    def is_hausdorff(self) -> bool:
        """Check if the topology is T₂ (Hausdorff)."""
        for x in self.X:
            for y in self.X:
                if x != y:
                    # Find disjoint open sets separating x and y
                    separated = False
                    for U in self.opens:
                        if x in U and y not in U:
                            for V in self.opens:
                                if y in V and x not in V:
                                    if not (U & V):
                                        separated = True
                                        break
                        if separated:
                            break
                    if not separated:
                        return False
        return True


def consensus(*topologies: FiniteTopology) -> FiniteTopology:
    """
    Compute the consensus (supremum) of topologies.

    The consensus topology has as open sets exactly those sets that
    are open in ALL input topologies. This is the supremum in the
    complete lattice of topologies.

    Time complexity: O(k * |opens|) where k = number of topologies.

    Args:
        topologies: Variable number of FiniteTopology instances.

    Returns:
        The consensus topology.
    """
    if not topologies:
        raise ValueError("Need at least one topology for consensus")

    X = topologies[0].X
    result_opens = set(topologies[0].opens)
    for t in topologies[1:]:
        result_opens &= set(t.opens)
    return FiniteTopology(X, frozenset(result_opens))


def all_topologies_on(X) -> List[FiniteTopology]:
    """
    Enumerate all topologies on a finite set X.

    Uses brute-force enumeration of subsets of the power set,
    checking the topology axioms for each.

    Time complexity: O(2^(2^n)) where n = |X|.

    Args:
        X: The underlying set (iterable).

    Returns:
        List of all valid topologies on X.
    """
    X = frozenset(X)
    items = list(X)
    subsets = []
    for r in range(len(items) + 1):
        for c in combinations(items, r):
            subsets.append(frozenset(c))

    def is_valid_topology(opens_list):
        opens_set = set(opens_list)
        if frozenset() not in opens_set or X not in opens_set:
            return False
        for U in opens_list:
            for V in opens_list:
                if U & V not in opens_set:
                    return False
        for r in range(len(opens_list) + 1):
            for combo in combinations(opens_list, r):
                union = frozenset().union(*combo) if combo else frozenset()
                if union not in opens_set:
                    return False
        return True

    topologies = []
    for r in range(len(subsets) + 1):
        for combo in combinations(subsets, r):
            opens = list(combo)
            if is_valid_topology(opens):
                topologies.append(FiniteTopology(X, frozenset(opens)))
    return topologies


def phantom_number(target: FiniteTopology, all_tops: List[FiniteTopology]) -> int:
    """
    Compute the phantom number of a topology.

    The phantom number is the minimum k such that the target topology
    can be expressed as the consensus of k topologies.

    Time complexity: O(sum_{k=0}^{N} C(N,k)) where N = number of topologies.

    Args:
        target: The target topology.
        all_tops: List of all available topologies.

    Returns:
        The phantom number (0 if discrete, inf if not decomposable).
    """
    discrete = FiniteTopology.discrete(target.X)
    if target == discrete:
        return 0

    for k in range(1, len(all_tops) + 1):
        for combo in combinations(all_tops, k):
            if consensus(*combo) == target:
                return k
    return float('inf')


class PhantomSystem:
    """
    A phantom system: a collection of observer topologies on the same set.

    Attributes:
        X: The underlying set.
        observers: List of observer topologies.
    """

    def __init__(self, X, observers: List[FiniteTopology]):
        self.X = frozenset(X)
        self.observers = observers

    def consensus_topology(self) -> FiniteTopology:
        """Compute the consensus of all observers."""
        if not self.observers:
            return FiniteTopology.discrete(self.X)
        return consensus(*self.observers)

    def spectrum(self) -> Set[FiniteTopology]:
        """
        Compute the phantom spectrum: all consensus topologies
        achievable from subsets of observers.

        Time complexity: O(2^k * k * |opens|) where k = number of observers.

        Returns:
            Set of all achievable consensus topologies.
        """
        spec = {FiniteTopology.discrete(self.X)}  # Empty subset
        for r in range(1, len(self.observers) + 1):
            for combo in combinations(self.observers, r):
                spec.add(consensus(*combo))
        return spec

    def entropy(self) -> int:
        """
        Compute the phantom entropy: |spectrum| - 1.

        This measures the diversity of observer viewpoints.
        """
        return len(self.spectrum()) - 1

    def is_observer_independent(self, i: int, j: int) -> bool:
        """
        Check if observers i and j are independent
        (neither's topology refines the other's).
        """
        ti = self.observers[i]
        tj = self.observers[j]
        return not (ti <= tj) and not (tj <= ti)


class PhantomFiltration:
    """
    A phantom filtration: sequential observer addition.

    At stage n, the consensus is computed from the first n observers.
    The consensus sequence is monotone (non-decreasing in the ≤ ordering,
    meaning it gets coarser as more observers are added).

    Attributes:
        X: The underlying set.
        observer_seq: Sequence of observer topologies.
    """

    def __init__(self, X, observer_seq: List[FiniteTopology]):
        self.X = frozenset(X)
        self.observer_seq = observer_seq

    def consensus_at(self, n: int) -> FiniteTopology:
        """
        Compute the consensus at stage n (first n observers).

        Args:
            n: Stage number (0 = discrete, 1 = first observer, ...).

        Returns:
            The consensus topology at stage n.
        """
        if n == 0:
            return FiniteTopology.discrete(self.X)
        return consensus(*self.observer_seq[:n])

    def stages(self) -> List[Tuple[int, FiniteTopology]]:
        """Compute all filtration stages."""
        return [(n, self.consensus_at(n))
                for n in range(len(self.observer_seq) + 1)]

    def stabilization_stage(self) -> Optional[int]:
        """
        Find the stabilization stage, if any.

        The filtration stabilizes at stage n if C(n+1) = C(n).
        By the Stabilization Theorem, this means C(m) = C(n) for all m ≥ n.

        Returns:
            The stabilization stage, or None if not stabilized.
        """
        prev = self.consensus_at(0)
        for n in range(1, len(self.observer_seq) + 1):
            curr = self.consensus_at(n)
            if curr == prev:
                return n - 1
            prev = curr
        return None

    def limit_consensus(self) -> FiniteTopology:
        """
        Compute the limit consensus (all observers).

        By the Limit Characterization Theorem, this equals
        the consensus at the stabilization stage (if it stabilizes).
        """
        if not self.observer_seq:
            return FiniteTopology.discrete(self.X)
        return consensus(*self.observer_seq)


def verify_stabilization_theorem(filt: PhantomFiltration) -> bool:
    """
    Verify the Stabilization Theorem: if the filtration stabilizes
    at stage n, then the limit equals C(n).

    Args:
        filt: A phantom filtration.

    Returns:
        True if the theorem holds (it always should).
    """
    stab = filt.stabilization_stage()
    if stab is not None:
        limit = filt.limit_consensus()
        c_n = filt.consensus_at(stab)
        return limit == c_n
    return True  # No stabilization to check


def verify_decomposition_formula(filt: PhantomFiltration) -> bool:
    """
    Verify the Consensus Decomposition Formula:
    C(n+1) = C(n) ⊔ τ_n for all n.

    In finite topologies, C(n) ⊔ τ_n is the intersection of
    their open set collections (consensus = supremum = intersection).

    Args:
        filt: A phantom filtration.

    Returns:
        True if the formula holds for all stages (it always should).
    """
    for n in range(len(filt.observer_seq)):
        c_n = filt.consensus_at(n)
        c_n1 = filt.consensus_at(n + 1)
        tau_n = filt.observer_seq[n]
        # C(n) ⊔ τ_n = consensus of C(n) and τ_n
        expected = consensus(c_n, tau_n)
        if c_n1 != expected:
            return False
    return True


if __name__ == "__main__":
    # Example usage
    X = {0, 1}

    # Create some topologies
    discrete = FiniteTopology.discrete(X)
    indiscrete = FiniteTopology.indiscrete(X)
    sierp0 = FiniteTopology(frozenset(X),
        frozenset([frozenset(), frozenset({0}), frozenset(X)]))
    sierp1 = FiniteTopology(frozenset(X),
        frozenset([frozenset(), frozenset({1}), frozenset(X)]))

    print("Topologies on {0, 1}:")
    print(f"  Discrete: {discrete.opens}")
    print(f"  Indiscrete: {indiscrete.opens}")
    print(f"  Sierpinski-0: {sierp0.opens}")
    print(f"  Sierpinski-1: {sierp1.opens}")

    # Phantom system
    system = PhantomSystem(X, [sierp0, sierp1])
    print(f"\nConsensus: {system.consensus_topology().opens}")
    print(f"Spectrum size: {len(system.spectrum())}")
    print(f"Phantom entropy: {system.entropy()}")

    # Filtration
    filt = PhantomFiltration(X, [sierp0, sierp1])
    print(f"\nFiltration stages:")
    for stage, top in filt.stages():
        print(f"  Stage {stage}: |opens| = {len(top.opens)}")

    stab = filt.stabilization_stage()
    print(f"Stabilization: stage {stab}")

    # Verify theorems
    print(f"\nStabilization theorem holds: {verify_stabilization_theorem(filt)}")
    print(f"Decomposition formula holds: {verify_decomposition_formula(filt)}")
