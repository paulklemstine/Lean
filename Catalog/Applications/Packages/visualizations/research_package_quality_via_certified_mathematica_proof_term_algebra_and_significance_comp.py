#!/usr/bin/env python3
"""
Certified Mathematical Significance Theory — Algorithms

Complete implementations of the algorithms from the research paper,
with docstrings, type hints, and example usage.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Callable, Optional
import random


# ═══════════════════════════════════════════════════════════════════════════
# 1. Proof Term Algebra
# ═══════════════════════════════════════════════════════════════════════════

@dataclass
class ProofTerm:
    """Base class for proof terms in the abstract proof object language."""
    pass

@dataclass
class AxiomTerm(ProofTerm):
    """Axiom invocation: a leaf node referencing axiom number n."""
    n: int

@dataclass
class AppTerm(ProofTerm):
    """Application: applying proof p to proof q (modus ponens)."""
    p: ProofTerm
    q: ProofTerm

@dataclass
class LamTerm(ProofTerm):
    """Abstraction: generalizing over a hypothesis to produce proof p."""
    p: ProofTerm

@dataclass
class PairTerm(ProofTerm):
    """Pairing: combining proofs p and q into a conjunction."""
    p: ProofTerm
    q: ProofTerm


def proof_size(t: ProofTerm) -> int:
    """
    Compute the structural size of a proof term.

    Size counts all constructor nodes in the proof tree.
    Time complexity: O(size(t))
    Space complexity: O(height(t)) due to recursion stack

    >>> proof_size(AxiomTerm(0))
    1
    >>> proof_size(AppTerm(AxiomTerm(0), AxiomTerm(1)))
    3
    >>> proof_size(LamTerm(AxiomTerm(0)))
    2
    """
    if isinstance(t, AxiomTerm):
        return 1
    elif isinstance(t, AppTerm):
        return proof_size(t.p) + proof_size(t.q) + 1
    elif isinstance(t, LamTerm):
        return proof_size(t.p) + 1
    elif isinstance(t, PairTerm):
        return proof_size(t.p) + proof_size(t.q) + 1
    raise TypeError(f"Unknown proof term type: {type(t)}")


def proof_height(t: ProofTerm) -> int:
    """
    Compute the height (depth) of a proof term.

    Height measures the longest root-to-leaf path.
    Invariant: height(t) <= size(t) for all t (Theorem C₁).

    >>> proof_height(AxiomTerm(0))
    1
    >>> proof_height(AppTerm(AxiomTerm(0), AxiomTerm(1)))
    2
    """
    if isinstance(t, AxiomTerm):
        return 1
    elif isinstance(t, AppTerm):
        return max(proof_height(t.p), proof_height(t.q)) + 1
    elif isinstance(t, LamTerm):
        return proof_height(t.p) + 1
    elif isinstance(t, PairTerm):
        return max(proof_height(t.p), proof_height(t.q)) + 1
    raise TypeError(f"Unknown proof term type: {type(t)}")


def is_subterm(p: ProofTerm, q: ProofTerm) -> bool:
    """
    Check if p is a subterm of q.

    >>> is_subterm(AxiomTerm(0), AppTerm(AxiomTerm(0), AxiomTerm(1)))
    True
    >>> is_subterm(AxiomTerm(2), AppTerm(AxiomTerm(0), AxiomTerm(1)))
    False
    """
    if p == q:
        return True
    if isinstance(q, AppTerm):
        return is_subterm(p, q.p) or is_subterm(p, q.q)
    elif isinstance(q, LamTerm):
        return is_subterm(p, q.p)
    elif isinstance(q, PairTerm):
        return is_subterm(p, q.p) or is_subterm(p, q.q)
    return False


# ═══════════════════════════════════════════════════════════════════════════
# 2. Significance Computation
# ═══════════════════════════════════════════════════════════════════════════

def compute_significance(
    weights: dict[int, int],
    K: set[int]
) -> int:
    """
    Compute the significance of a knowledge state K.

    σ(K) = Σ_{a ∈ K} w(a)

    Time complexity: O(|K|)
    Space complexity: O(1)

    >>> compute_significance({0: 5, 1: 3, 2: 8}, {0, 2})
    13
    """
    return sum(weights.get(a, 0) for a in K)


def compute_significance_from_proofs(
    proofs: dict[int, ProofTerm],
    K: set[int]
) -> int:
    """
    Compute significance using proof-term sizes as weights.

    σ_π(K) = Σ_{a ∈ K} size(π(a))

    >>> proofs = {0: AxiomTerm(0), 1: AppTerm(AxiomTerm(0), AxiomTerm(1))}
    >>> compute_significance_from_proofs(proofs, {0, 1})
    4
    """
    return sum(proof_size(proofs[a]) for a in K if a in proofs)


# ═══════════════════════════════════════════════════════════════════════════
# 3. Quality Gate
# ═══════════════════════════════════════════════════════════════════════════

def evaluate_quality_gate(
    weights: dict[int, int],
    threshold: int,
    K: set[int]
) -> bool:
    """
    Evaluate the Boolean quality gate.

    Returns True iff threshold ≤ σ(K).
    Monotone: if gate(K₁) = True and K₁ ⊆ K₂, then gate(K₂) = True.

    Time complexity: O(|K|)

    >>> evaluate_quality_gate({0: 10, 1: 20, 2: 30}, 25, {0, 1})
    True
    >>> evaluate_quality_gate({0: 10, 1: 20, 2: 30}, 35, {0, 1})
    False
    """
    return threshold <= compute_significance(weights, K)


# ═══════════════════════════════════════════════════════════════════════════
# 4. Package Depth
# ═══════════════════════════════════════════════════════════════════════════

def compute_package_depth(
    proofs: dict[int, ProofTerm],
    K: set[int]
) -> int:
    """
    Compute the package depth: maximum proof size across K.

    depth(K) = max_{a ∈ K} size(π(a))

    Time complexity: O(|K| · max_size)

    >>> proofs = {0: AxiomTerm(0), 1: AppTerm(AxiomTerm(0), AxiomTerm(1))}
    >>> compute_package_depth(proofs, {0, 1})
    3
    """
    if not K:
        return 0
    return max(proof_size(proofs[a]) for a in K if a in proofs)


def is_master_class_contribution(
    proofs: dict[int, ProofTerm],
    K: set[int],
    a: int
) -> bool:
    """
    Check if adding theorem a is a master-class contribution.

    True iff size(π(a)) > depth(K), meaning the new theorem's proof
    complexity exceeds all existing proofs.

    >>> proofs = {0: AxiomTerm(0), 1: AppTerm(AxiomTerm(0), AxiomTerm(1)),
    ...           2: PairTerm(AppTerm(AxiomTerm(0), AxiomTerm(1)), AxiomTerm(2))}
    >>> is_master_class_contribution(proofs, {0, 1}, 2)
    True
    """
    current_depth = compute_package_depth(proofs, K)
    new_size = proof_size(proofs[a])
    return new_size > current_depth


# ═══════════════════════════════════════════════════════════════════════════
# 5. Strict Advancement Check
# ═══════════════════════════════════════════════════════════════════════════

def check_strict_advancement(
    weights: dict[int, int],
    K1: set[int],
    K2: set[int]
) -> tuple[bool, str]:
    """
    Check if K2 strictly advances beyond K1.

    Returns (is_strict_advancement, reason).

    >>> check_strict_advancement({0: 5, 1: 3}, {0}, {0, 1})
    (True, 'K1 ⊆ K2 and σ(K1)=5 < σ(K2)=8')
    """
    subset = K1.issubset(K2)
    sig1 = compute_significance(weights, K1)
    sig2 = compute_significance(weights, K2)
    strict = sig1 < sig2

    if subset and strict:
        return True, f"K1 ⊆ K2 and σ(K1)={sig1} < σ(K2)={sig2}"
    elif not subset:
        return False, f"K1 ⊄ K2"
    else:
        return False, f"σ(K1)={sig1} = σ(K2)={sig2}, no strict increase"


# ═══════════════════════════════════════════════════════════════════════════
# 6. Closure Operators
# ═══════════════════════════════════════════════════════════════════════════

class ClosureOperator:
    """
    A closure operator on finite sets of integers.

    Satisfies:
    - Extensive: K ⊆ cl(K)
    - Monotone: K1 ⊆ K2 → cl(K1) ⊆ cl(K2)
    - Idempotent: cl(cl(K)) = cl(K)
    """

    def __init__(self, cl: Callable[[set[int]], set[int]]):
        self._cl = cl

    def close(self, K: set[int]) -> set[int]:
        return self._cl(K)

    def is_nonconservative(self, K: set[int], a: int) -> bool:
        """Check if adding a to K is a nonconservative extension."""
        cl_K = self.close(K)
        cl_Ka = self.close(K | {a})
        return cl_K < cl_Ka  # strict subset

    def closure_significance(
        self, weights: dict[int, int], K: set[int]
    ) -> int:
        """Compute closure-based significance: |cl(K)| + Σ_{cl(K)} w."""
        cl_K = self.close(K)
        return len(cl_K) + sum(weights.get(a, 0) for a in cl_K)


def make_downward_closure() -> ClosureOperator:
    """
    Create a downward closure: cl(K) = {j : j ≤ max(K)}.

    This models a system where knowing theorem i implies knowing all
    prerequisites j < i.

    >>> cl = make_downward_closure()
    >>> sorted(cl.close({2, 5}))
    [0, 1, 2, 3, 4, 5]
    """
    def cl(K: set[int]) -> set[int]:
        if not K:
            return set()
        return set(range(max(K) + 1))
    return ClosureOperator(cl)


def make_dependency_closure(deps: dict[int, set[int]]) -> ClosureOperator:
    """
    Create a dependency-based closure operator.

    deps[i] gives the set of theorems that i depends on.
    cl(K) = K ∪ {all transitive dependencies of elements in K}.

    >>> deps = {0: set(), 1: {0}, 2: {0, 1}, 3: {1}}
    >>> cl = make_dependency_closure(deps)
    >>> sorted(cl.close({2}))
    [0, 1, 2]
    """
    def cl(K: set[int]) -> set[int]:
        result = set(K)
        queue = list(K)
        while queue:
            a = queue.pop()
            for dep in deps.get(a, set()):
                if dep not in result:
                    result.add(dep)
                    queue.append(dep)
        return result
    return ClosureOperator(cl)


# ═══════════════════════════════════════════════════════════════════════════
# Example Usage
# ═══════════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    import doctest
    doctest.testmod(verbose=True)

    print("\n" + "=" * 60)
    print("ALGORITHM EXAMPLES")
    print("=" * 60)

    # Proof terms
    p0 = AxiomTerm(0)
    p1 = AppTerm(AxiomTerm(0), AxiomTerm(1))
    p2 = LamTerm(AppTerm(AxiomTerm(0), AxiomTerm(1)))
    p3 = PairTerm(p1, p2)
    p4 = AppTerm(p3, LamTerm(AxiomTerm(2)))

    proofs = {0: p0, 1: p1, 2: p2, 3: p3, 4: p4}
    print("\nProof terms:")
    for i, p in proofs.items():
        print(f"  Theorem {i}: size={proof_size(p)}, height={proof_height(p)}, "
              f"height≤size: {proof_height(p) <= proof_size(p)}")

    # Significance
    weights = {i: proof_size(proofs[i]) for i in proofs}
    K = {0, 1, 2}
    print(f"\nSignificance of {sorted(K)}: {compute_significance(weights, K)}")

    # Quality gate
    print(f"Quality gate (τ=5): {evaluate_quality_gate(weights, 5, K)}")
    print(f"Quality gate (τ=10): {evaluate_quality_gate(weights, 10, K)}")

    # Package depth
    print(f"Package depth of {sorted(K)}: {compute_package_depth(proofs, K)}")

    # Master-class
    print(f"Is theorem 4 a master-class contribution to {sorted(K)}? "
          f"{is_master_class_contribution(proofs, K, 4)}")

    # Closure
    deps = {0: set(), 1: {0}, 2: {0, 1}, 3: {1}, 4: {2, 3}}
    cl = make_dependency_closure(deps)
    print(f"\nDependency closure of {{4}}: {sorted(cl.close({4}))}")
    print(f"Nonconservative to add 4 to {{0,1}}? "
          f"{cl.is_nonconservative({0, 1}, 4)}")
    print(f"Nonconservative to add 0 to {{0,1}}? "
          f"{cl.is_nonconservative({0, 1}, 0)}")
