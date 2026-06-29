"""
Algorithms for Closure–Nucleus Spectral Duality

Implements the core algorithms from the duality theory:
1. Closure operator computation
2. Nucleus application
3. Join-prime detection
4. Spectral evaluation map
5. Implicational basis extraction
6. Kripke frame construction and entailment checking
7. Certified closure reconstruction from spectral data

All algorithms work on finite sets represented as frozensets over a finite universe.
"""

from __future__ import annotations
from typing import Callable, FrozenSet, Set, List, Tuple, Dict, Optional
from itertools import combinations
from functools import lru_cache


# Type aliases
Element = int
Subset = FrozenSet[Element]
ClosureOp = Callable[[Subset], Subset]
Rule = Tuple[Subset, Element]  # (premise, conclusion)


class ClosureOperator:
    """A closure operator on a finite set.

    A closure operator cl on a finite universe U satisfies:
    1. Extensive: A ⊆ cl(A)
    2. Monotone: A ⊆ B → cl(A) ⊆ cl(B)
    3. Idempotent: cl(cl(A)) = cl(A)

    Time complexity: O(2^|U|) space to cache all closed sets.
    """

    def __init__(self, universe: Set[Element], cl: ClosureOp):
        self.universe = frozenset(universe)
        self._cl = cl
        self._closed_sets: Optional[List[Subset]] = None

    def closure(self, s: Subset) -> Subset:
        """Compute cl(s). O(|rules| * |U|) for rule-based closure."""
        return self._cl(s)

    def is_closed(self, s: Subset) -> bool:
        """Check if s is a fixed point of cl."""
        return self.closure(s) == s

    def verify_extensive(self) -> bool:
        """Verify extensivity: A ⊆ cl(A) for all A."""
        for r in range(len(self.universe) + 1):
            for s in combinations(self.universe, r):
                fs = frozenset(s)
                if not fs.issubset(self.closure(fs)):
                    return False
        return True

    def verify_monotone(self) -> bool:
        """Verify monotonicity on a sample of pairs."""
        subs = [frozenset(s) for r in range(len(self.universe) + 1)
                for s in combinations(self.universe, r)]
        for a in subs:
            for b in subs:
                if a.issubset(b) and not self.closure(a).issubset(self.closure(b)):
                    return False
        return True

    def verify_idempotent(self) -> bool:
        """Verify idempotency: cl(cl(A)) = cl(A) for all A."""
        for r in range(len(self.universe) + 1):
            for s in combinations(self.universe, r):
                fs = frozenset(s)
                if self.closure(self.closure(fs)) != self.closure(fs):
                    return False
        return True

    def all_closed_sets(self) -> List[Subset]:
        """Enumerate all closed sets. O(2^|U|) time."""
        if self._closed_sets is None:
            self._closed_sets = []
            for r in range(len(self.universe) + 1):
                for s in combinations(self.universe, r):
                    fs = frozenset(s)
                    if self.is_closed(fs):
                        self._closed_sets.append(fs)
        return self._closed_sets


class Nucleus:
    """A nucleus on a closure operator's closed-set lattice.

    A nucleus j on the lattice of closed sets satisfies:
    1. Maps closed sets to closed sets
    2. Monotone
    3. Idempotent: j(j(s)) = j(s)
    4. Extensive on closed sets: s ⊆ j(s)
    """

    def __init__(self, cl_op: ClosureOperator, nuc: ClosureOp):
        self.cl_op = cl_op
        self._nuc = nuc

    def apply(self, s: Subset) -> Subset:
        """Apply the nucleus."""
        return self._nuc(s)

    def is_stable(self, s: Subset) -> bool:
        """Check if s is a fixed point of the nucleus."""
        return self.apply(s) == s

    def stable_closed_sets(self) -> List[Subset]:
        """All closed sets that are also nucleus-stable."""
        return [s for s in self.cl_op.all_closed_sets() if self.is_stable(s)]


class JoinPrimeDetector:
    """Detects spectral prime points: nonempty, closed, nucleus-stable sets
    that form a separating family.

    A spectral prime is:
    1. Closed under the closure operator
    2. Stable under the nucleus
    3. Nonempty
    4. Not the full universe (to be useful for separation)

    The separation condition (a hypothesis of the duality theorem) requires
    that for every closed s and x ∉ s, there exists a prime p with s ⊆ p
    and x ∉ p.

    Time complexity: O(|stable|) for enumeration.
    """

    def __init__(self, cl_op: ClosureOperator, nucleus: Nucleus):
        self.cl_op = cl_op
        self.nucleus = nucleus
        self._stable = None

    def _get_stable(self) -> List[Subset]:
        if self._stable is None:
            self._stable = self.nucleus.stable_closed_sets()
        return self._stable

    def is_spectral_prime(self, p: Subset) -> bool:
        """Check if p qualifies as a spectral prime point."""
        if not p:  # nonempty check
            return False
        if not self.cl_op.is_closed(p):
            return False
        if not self.nucleus.is_stable(p):
            return False
        # Must be a proper subset of the universe to help with separation
        if p == self.cl_op.universe:
            return False
        return True

    def all_join_primes(self) -> List[Subset]:
        """Find all spectral prime points (nonempty, proper, closed, stable)."""
        return [p for p in self._get_stable() if self.is_spectral_prime(p)]


class SpectralEvaluator:
    """The spectral evaluation map from closed sets to observables on primes.

    Maps a closed set s to its evaluation profile:
    eval(s) = {p ∈ Primes | s ⊆ p}

    This is the fundamental bridge from closure data to spectral observables.
    """

    def __init__(self, cl_op: ClosureOperator, nucleus: Nucleus,
                 primes: List[Subset]):
        self.cl_op = cl_op
        self.nucleus = nucleus
        self.primes = primes

    def evaluate(self, s: Subset) -> FrozenSet[int]:
        """Evaluate s on all prime points. Returns indices of containing primes."""
        return frozenset(i for i, p in enumerate(self.primes) if s.issubset(p))

    def is_injective_on_closed(self) -> bool:
        """Check if the evaluation map is injective on closed sets."""
        closed = self.cl_op.all_closed_sets()
        profiles: Dict[FrozenSet[int], Subset] = {}
        for s in closed:
            profile = self.evaluate(s)
            if profile in profiles and profiles[profile] != s:
                return False
            profiles[profile] = s
        return True

    def reconstruct_closure(self, a: Subset) -> Subset:
        """Reconstruct cl(A) as intersection of primes containing A.

        cl(A) = ⋂ {p ∈ Primes | A ⊆ p}

        This is the certified reconstruction algorithm.
        Time complexity: O(|Primes| * |U|).
        """
        result = self.cl_op.universe  # start with everything
        for p in self.primes:
            if a.issubset(p):
                result = result & p
        return result


class ImplicationalBasis:
    """Extract and work with implicational bases for closure operators.

    An implicational basis is a set of rules {(Γ_i, x_i)} such that
    cl(A) = the smallest set containing A and closed under all rules.

    Time complexity: O(2^|U| * |U|) for full basis extraction.
    """

    def __init__(self, cl_op: ClosureOperator):
        self.cl_op = cl_op

    def canonical_basis(self) -> List[Rule]:
        """Extract the canonical (complete) implicational basis.

        Returns all valid rules (Γ, x) where x ∈ cl(Γ) and x ∉ Γ.
        This is the maximal basis; a minimal basis can be obtained by
        removing redundant rules.
        """
        rules: List[Rule] = []
        universe = self.cl_op.universe
        for r in range(len(universe) + 1):
            for gamma in combinations(universe, r):
                fg = frozenset(gamma)
                closure = self.cl_op.closure(fg)
                for x in closure - fg:
                    rules.append((fg, x))
        return rules

    def minimal_basis(self) -> List[Rule]:
        """Extract a minimal implicational basis.

        Greedily removes redundant rules from the canonical basis.
        A rule is redundant if the remaining rules generate the same closure.
        Time complexity: O(|canonical|^2 * 2^|U|).
        """
        canonical = self.canonical_basis()
        minimal = list(canonical)

        for rule in canonical:
            test_rules = [r for r in minimal if r != rule]
            test_cl = self._closure_from_rules(test_rules)
            if all(test_cl(frozenset(s)) == self.cl_op.closure(frozenset(s))
                   for r in range(len(self.cl_op.universe) + 1)
                   for s in combinations(self.cl_op.universe, r)):
                minimal = test_rules

        return minimal

    def _closure_from_rules(self, rules: List[Rule]) -> ClosureOp:
        """Build a closure operator from a set of rules."""
        def cl(s: Subset) -> Subset:
            current = s
            changed = True
            while changed:
                changed = False
                for gamma, x in rules:
                    if gamma.issubset(current) and x not in current:
                        current = current | frozenset([x])
                        changed = True
            return current
        return cl

    def nucleus_fixed_basis(self, nucleus: Nucleus) -> List[Rule]:
        """Extract rules that are stable under the nucleus.

        A rule (Γ, x) is nucleus-fixed if x ∈ nuc(cl(Γ)).
        These generate exactly the nucleus-stable fragment.
        """
        full_basis = self.canonical_basis()
        fixed = []
        for gamma, x in full_basis:
            cl_gamma = self.cl_op.closure(gamma)
            nuc_cl_gamma = nucleus.apply(cl_gamma)
            if x in nuc_cl_gamma:
                fixed.append((gamma, x))
        return fixed


class KripkeFrame:
    """A finite Kripke frame for the closure operator.

    Points are join-prime stable closed sets.
    The preorder is reverse inclusion: p ≤ q iff q ⊆ p.
    Forcing: p ⊩ x iff x ∈ p.

    Theorem (soundness + completeness):
    x ∈ cl(A) iff for all prime p, (A ⊆ p → x ∈ p)
    """

    def __init__(self, primes: List[Subset]):
        self.primes = primes
        self.n_points = len(primes)

    def preorder_matrix(self) -> List[List[bool]]:
        """Compute the specialization preorder matrix.

        preorder[i][j] = True iff primes[j] ⊆ primes[i] (reverse inclusion).
        """
        n = self.n_points
        matrix = [[False] * n for _ in range(n)]
        for i in range(n):
            for j in range(n):
                matrix[i][j] = self.primes[j].issubset(self.primes[i])
        return matrix

    def forces(self, point_idx: int, x: Element) -> bool:
        """Check if point forces atom x."""
        return x in self.primes[point_idx]

    def entails(self, a: Subset, x: Element) -> bool:
        """Check Kripke entailment: A ⊩ x.

        True iff for all prime p, A ⊆ p → x ∈ p.
        """
        for p in self.primes:
            if a.issubset(p) and x not in p:
                return False
        return True

    def validate_rule(self, rule: Rule) -> bool:
        """Check if an implicational rule is valid in the frame."""
        gamma, x = rule
        return self.entails(gamma, x)


def build_closure_from_rules(universe: Set[Element],
                              rules: List[Rule]) -> ClosureOperator:
    """Build a closure operator from implicational rules.

    cl(A) = smallest superset of A closed under all rules (Γ, x):
    if Γ ⊆ A then x ∈ cl(A).

    Time complexity per closure: O(|rules| * |U|) iterations until fixpoint.

    Args:
        universe: The finite ground set.
        rules: List of (premise, conclusion) pairs.

    Returns:
        A ClosureOperator instance.
    """
    def cl(s: Subset) -> Subset:
        current = set(s)
        changed = True
        while changed:
            changed = False
            for gamma, x in rules:
                if gamma.issubset(current) and x not in current:
                    current.add(x)
                    changed = True
        return frozenset(current)

    return ClosureOperator(universe, cl)


def full_duality_pipeline(universe: Set[Element],
                           cl_op: ClosureOperator,
                           nucleus: Nucleus) -> Dict:
    """Run the complete duality pipeline.

    1. Enumerate closed sets
    2. Find join-prime stable closed sets
    3. Build spectral evaluation map
    4. Verify injectivity (separation)
    5. Reconstruct closure from spectral data
    6. Extract implicational basis
    7. Build Kripke frame and verify completeness

    Returns a dictionary with all computed data.

    Time complexity: O(2^|U| * |U|^2) overall.
    """
    # Step 1: Enumerate closed sets
    closed_sets = cl_op.all_closed_sets()

    # Step 2: Find join-primes
    detector = JoinPrimeDetector(cl_op, nucleus)
    primes = detector.all_join_primes()

    # Step 3: Build spectral evaluator
    evaluator = SpectralEvaluator(cl_op, nucleus, primes)

    # Step 4: Verify injectivity
    injective = evaluator.is_injective_on_closed()

    # Step 5: Verify reconstruction
    reconstruction_correct = True
    for r in range(len(universe) + 1):
        for s in combinations(universe, r):
            fs = frozenset(s)
            reconstructed = evaluator.reconstruct_closure(fs)
            actual = cl_op.closure(fs)
            if reconstructed != actual:
                reconstruction_correct = False
                break

    # Step 6: Extract basis
    basis_extractor = ImplicationalBasis(cl_op)
    canonical = basis_extractor.canonical_basis()
    nuc_fixed = basis_extractor.nucleus_fixed_basis(nucleus)

    # Step 7: Build Kripke frame
    frame = KripkeFrame(primes)

    # Verify Kripke completeness
    kripke_complete = True
    for r in range(len(universe) + 1):
        for s in combinations(universe, r):
            fs = frozenset(s)
            cl_s = cl_op.closure(fs)
            for x in universe:
                in_closure = x in cl_s
                kripke_entails = frame.entails(fs, x)
                if in_closure != kripke_entails:
                    kripke_complete = False
                    break

    return {
        "universe": universe,
        "n_closed_sets": len(closed_sets),
        "closed_sets": closed_sets,
        "n_primes": len(primes),
        "primes": primes,
        "injective": injective,
        "reconstruction_correct": reconstruction_correct,
        "n_canonical_rules": len(canonical),
        "canonical_basis": canonical,
        "n_nucleus_fixed_rules": len(nuc_fixed),
        "nucleus_fixed_basis": nuc_fixed,
        "kripke_complete": kripke_complete,
        "preorder_matrix": frame.preorder_matrix(),
    }


if __name__ == "__main__":
    # Quick test with a simple example
    universe = {1, 2, 3}

    # Closure: generated by rule {1} → 2
    rules = [(frozenset([1]), 2)]
    cl_op = build_closure_from_rules(universe, rules)

    # Identity nucleus
    nucleus = Nucleus(cl_op, lambda s: s)

    result = full_duality_pipeline(universe, cl_op, nucleus)
    print(f"Universe: {universe}")
    print(f"Closed sets: {result['n_closed_sets']}")
    print(f"Join-primes: {result['n_primes']}")
    print(f"Injective: {result['injective']}")
    print(f"Reconstruction correct: {result['reconstruction_correct']}")
    print(f"Kripke complete: {result['kripke_complete']}")
    print(f"Canonical basis size: {result['n_canonical_rules']}")
