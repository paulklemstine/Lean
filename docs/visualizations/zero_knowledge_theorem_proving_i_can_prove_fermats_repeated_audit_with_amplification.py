#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Locally Auditable Derivation Certificates

Implements the core algorithms from the research paper:
  1. Certificate verification (full and local)
  2. Single-step audit protocol
  3. Repeated audit with configurable parameters
  4. Defect density computation
  5. Leakage cost computation
  6. Soundness amplification analysis

All algorithms include docstrings, type hints, and complexity analysis.
"""

import random
import math
from dataclasses import dataclass, field
from typing import List, Set, Dict, Optional, Tuple, Callable, Any
from abc import ABC, abstractmethod


# ============================================================
# Abstract Local Rule System
# ============================================================

class LocalRuleSystem(ABC):
    """Abstract base class for a local rule system.

    A local rule system defines:
    - valid_step(premises, step) -> bool: whether step follows from premises
    - concludes(step) -> statement: what a step establishes
    - is_axiomatic(step) -> bool: whether step needs no premises

    Time complexity per validation: O(|premises| * C) where C is the
    cost of checking a single rule application.
    """

    @abstractmethod
    def valid_step(self, premises: List[Any], step: Any) -> bool:
        """Check if step is locally derivable from the given premises.

        Args:
            premises: List of premise steps that this step depends on
            step: The step to validate

        Returns:
            True if step is a valid consequence of premises

        Time: O(|premises| * rule_check_cost)
        """
        pass

    @abstractmethod
    def concludes(self, step: Any) -> Any:
        """Extract the statement concluded by a step.

        Args:
            step: A proof step

        Returns:
            The statement (formula, proposition, etc.) established

        Time: O(1)
        """
        pass

    @abstractmethod
    def is_axiomatic(self, step: Any) -> bool:
        """Check if step is an axiom (requires no premises).

        Args:
            step: A proof step

        Returns:
            True if step is an axiom

        Time: O(step_size)
        """
        pass


# ============================================================
# Raw Certificate
# ============================================================

@dataclass
class RawCertificate:
    """A raw derivation certificate of length n.

    Attributes:
        steps: List of proof steps
        deps: For each step, the set of indices it depends on
        n: Number of steps (computed)

    Space: O(n * max_dep_card)
    """
    steps: List[Any]
    deps: List[List[int]]

    @property
    def n(self) -> int:
        return len(self.steps)

    def max_dep_card(self) -> int:
        """Maximum dependency fan-in.

        Time: O(n)
        """
        if not self.deps:
            return 0
        return max(len(d) for d in self.deps)

    def validate_structure(self) -> bool:
        """Check structural validity: deps reference valid indices.

        Time: O(n * max_dep_card)
        """
        n = self.n
        if len(self.deps) != n:
            return False
        for i, dep_list in enumerate(self.deps):
            for j in dep_list:
                if j < 0 or j >= n:
                    return False
        return True


# ============================================================
# Algorithm 1: Step Verification (Local Audit)
# ============================================================

def step_ok(rule_system: LocalRuleSystem, cert: RawCertificate, i: int) -> bool:
    """Check if step i of a certificate is locally valid.

    A step is OK if it is axiomatic OR if it is derivable from its
    declared dependencies.

    Args:
        rule_system: The local rule system
        cert: The derivation certificate
        i: Index of the step to check

    Returns:
        True if step is locally valid

    Time: O(|deps[i]| * rule_check_cost)
    Space: O(|deps[i]|) for constructing the premise list

    Example:
        >>> rs = HilbertSystem()
        >>> cert = generate_certificate(rs)
        >>> step_ok(rs, cert, 0)  # Check first step
        True
    """
    step = cert.steps[i]

    # Check if axiomatic
    if rule_system.is_axiomatic(step):
        return True

    # Gather premises
    premises = [cert.steps[j] for j in cert.deps[i]]

    # Check if derivable
    return rule_system.valid_step(premises, step)


# ============================================================
# Algorithm 2: Single-Step Audit Protocol
# ============================================================

@dataclass
class AuditTranscript:
    """Transcript of a single-step audit.

    Contains only the information revealed to the verifier:
    - The challenged index
    - The revealed step
    - The dependency indices and their steps
    - The verification result

    Space: O(1 + |deps[challenge]|)
    """
    challenge: int
    step: Any
    dep_indices: List[int]
    dep_steps: List[Any]
    accepted: bool


def single_step_audit(rule_system: LocalRuleSystem,
                       cert: RawCertificate,
                       challenge: int) -> AuditTranscript:
    """Execute a single-step audit protocol.

    The verifier challenges step `challenge`. The prover reveals that step
    and its dependencies. The verifier checks local validity.

    Args:
        rule_system: The local rule system
        cert: The derivation certificate
        challenge: Index of the step to audit

    Returns:
        AuditTranscript with the interaction record

    Time: O(|deps[challenge]| * rule_check_cost)
    Space: O(|deps[challenge]|)

    Example:
        >>> transcript = single_step_audit(rs, cert, 3)
        >>> transcript.accepted
        True
        >>> transcript.leakage_cost()
        3  # 1 step + 2 dependencies
    """
    step = cert.steps[challenge]
    dep_indices = cert.deps[challenge]
    dep_steps = [cert.steps[j] for j in dep_indices]
    accepted = step_ok(rule_system, cert, challenge)

    return AuditTranscript(
        challenge=challenge,
        step=step,
        dep_indices=dep_indices,
        dep_steps=dep_steps,
        accepted=accepted
    )


# ============================================================
# Algorithm 3: Repeated Audit Protocol
# ============================================================

@dataclass
class RepeatedAuditResult:
    """Result of a k-round repeated audit.

    Attributes:
        k: Number of rounds
        transcripts: Individual audit transcripts
        all_accepted: Whether all rounds accepted
        total_leakage: Total information revealed

    Space: O(k * max_dep_card)
    """
    k: int
    transcripts: List[AuditTranscript]
    all_accepted: bool
    total_leakage: int


def repeated_audit(rule_system: LocalRuleSystem,
                    cert: RawCertificate,
                    challenges: List[int]) -> RepeatedAuditResult:
    """Execute a k-round repeated audit protocol.

    Args:
        rule_system: The local rule system
        cert: The derivation certificate
        challenges: List of k challenge indices

    Returns:
        RepeatedAuditResult with aggregated results

    Time: O(k * max_dep_card * rule_check_cost)
    Space: O(k * max_dep_card)

    Example:
        >>> result = repeated_audit(rs, cert, [0, 3, 5, 7])
        >>> result.all_accepted
        True
        >>> result.total_leakage
        12
    """
    transcripts = [single_step_audit(rule_system, cert, c) for c in challenges]
    all_accepted = all(t.accepted for t in transcripts)
    total_leakage = sum(1 + len(t.dep_indices) for t in transcripts)

    return RepeatedAuditResult(
        k=len(challenges),
        transcripts=transcripts,
        all_accepted=all_accepted,
        total_leakage=total_leakage
    )


# ============================================================
# Algorithm 4: Defect Analysis
# ============================================================

def compute_bad_indices(rule_system: LocalRuleSystem,
                         cert: RawCertificate) -> Set[int]:
    """Compute the set of defective step indices.

    Args:
        rule_system: The local rule system
        cert: The derivation certificate

    Returns:
        Set of indices where steps fail local verification

    Time: O(n * max_dep_card * rule_check_cost)
    Space: O(n) worst case

    Example:
        >>> bad = compute_bad_indices(rs, corrupted_cert)
        >>> len(bad)
        5  # 5 corrupted steps detected
    """
    return {i for i in range(cert.n) if not step_ok(rule_system, cert, i)}


def defect_density(rule_system: LocalRuleSystem,
                    cert: RawCertificate) -> float:
    """Compute the defect density (fraction of bad steps).

    Args:
        rule_system: The local rule system
        cert: The derivation certificate

    Returns:
        Fraction of defective steps in [0, 1]

    Time: O(n * max_dep_card * rule_check_cost)
    """
    if cert.n == 0:
        return 0.0
    return len(compute_bad_indices(rule_system, cert)) / cert.n


# ============================================================
# Algorithm 5: Leakage Analysis
# ============================================================

def leakage_cost(cert: RawCertificate, challenge: int) -> int:
    """Compute leakage cost of auditing a single step.

    The leakage is 1 (the step itself) plus the number of dependencies revealed.

    Args:
        cert: The derivation certificate
        challenge: Index of audited step

    Returns:
        Number of proof nodes revealed

    Time: O(1)

    Example:
        >>> leakage_cost(cert, 3)
        3  # step 3 has 2 dependencies
    """
    return 1 + len(cert.deps[challenge])


def total_leakage(cert: RawCertificate, challenges: List[int]) -> int:
    """Compute total leakage over multiple audit rounds.

    Args:
        cert: The derivation certificate
        challenges: List of audited indices

    Returns:
        Total number of proof nodes revealed

    Time: O(k)
    """
    return sum(leakage_cost(cert, c) for c in challenges)


def max_dep_card(cert: RawCertificate) -> int:
    """Compute maximum dependency fan-in.

    Time: O(n)
    """
    return cert.max_dep_card()


# ============================================================
# Algorithm 6: Soundness Amplification Analysis
# ============================================================

def theoretical_accept_bound(single_accept_prob: float, k: int) -> float:
    """Compute the theoretical upper bound on k-round acceptance probability.

    By the exponential amplification theorem:
        P[k rounds all accept] ≤ (1 - ε)^k

    where ε is the single-round rejection probability.

    Args:
        single_accept_prob: Probability a single random audit accepts
        k: Number of independent rounds

    Returns:
        Upper bound (1 - ε)^k = single_accept_prob^k

    Time: O(log k) via exponentiation
    """
    return single_accept_prob ** k


def empirical_accept_probability(rule_system: LocalRuleSystem,
                                   cert: RawCertificate,
                                   k: int,
                                   num_trials: int = 10000,
                                   seed: int = 42) -> float:
    """Estimate k-round acceptance probability empirically.

    Args:
        rule_system: The local rule system
        cert: The derivation certificate
        k: Number of audit rounds
        num_trials: Number of Monte Carlo trials
        seed: Random seed for reproducibility

    Returns:
        Estimated acceptance probability

    Time: O(num_trials * k * max_dep_card * rule_check_cost)
    """
    rng = random.Random(seed)
    n = cert.n
    accepts = 0
    for _ in range(num_trials):
        challenges = [rng.randrange(n) for _ in range(k)]
        result = repeated_audit(rule_system, cert, challenges)
        if result.all_accepted:
            accepts += 1
    return accepts / num_trials


# ============================================================
# Concrete Implementation: Propositional Hilbert System
# ============================================================

@dataclass
class PropFormula:
    """Simple propositional formula."""
    kind: str  # 'var', 'neg', 'imp'
    var: Optional[str] = None
    left: Optional['PropFormula'] = None
    right: Optional['PropFormula'] = None

    def __repr__(self):
        if self.kind == 'var':
            return self.var or '?'
        elif self.kind == 'neg':
            return f"¬{self.left}"
        elif self.kind == 'imp':
            return f"({self.left} → {self.right})"
        return "?"

    def __eq__(self, other):
        if not isinstance(other, PropFormula):
            return False
        return repr(self) == repr(other)

    def __hash__(self):
        return hash(repr(self))


@dataclass
class HilbertStep:
    """A step in a Hilbert-style propositional derivation."""
    formula: PropFormula
    rule: str  # 'axiom_k', 'axiom_s', 'mp', 'assumption'


class HilbertSystem(LocalRuleSystem):
    """Hilbert-style propositional proof system with axioms K and S.

    Axiom K: A → (B → A)
    Axiom S: (A → B → C) → (A → B) → (A → C)
    Rule MP: From A and A → B, derive B
    """

    def valid_step(self, premises: List[HilbertStep], step: HilbertStep) -> bool:
        if step.rule == 'mp' and len(premises) == 2:
            a_step, imp_step = premises[0], premises[1]
            f = imp_step.formula
            if f.kind == 'imp' and f.left == a_step.formula and f.right == step.formula:
                return True
        return False

    def concludes(self, step: HilbertStep) -> PropFormula:
        return step.formula

    def is_axiomatic(self, step: HilbertStep) -> bool:
        f = step.formula
        if step.rule == 'assumption':
            return True
        if step.rule == 'axiom_k':
            # A → (B → A)
            if f.kind == 'imp' and f.right and f.right.kind == 'imp':
                return f.left == f.right.right
            return False
        if step.rule == 'axiom_s':
            # (A → B → C) → (A → B) → (A → C)
            if f.kind != 'imp':
                return False
            abc = f.left
            if abc.kind != 'imp' or abc.right.kind != 'imp':
                return False
            a, b, c = abc.left, abc.right.left, abc.right.right
            abac = f.right
            if abac.kind != 'imp' or abac.left.kind != 'imp' or abac.right.kind != 'imp':
                return False
            return (abac.left.left == a and abac.left.right == b and
                    abac.right.left == a and abac.right.right == c)
        return False


def make_hilbert_certificate(steps: List[HilbertStep],
                               deps: List[List[int]]) -> RawCertificate:
    """Create a RawCertificate from Hilbert steps."""
    return RawCertificate(steps=steps, deps=deps)


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("Algorithms for Locally Auditable Derivation Certificates")
    print("=" * 60)

    # Create Hilbert system
    hs = HilbertSystem()

    # Build a proof of P → P
    P = PropFormula('var', var='P')
    PP = PropFormula('imp', left=P, right=P)

    s_inst = PropFormula('imp',
        left=PropFormula('imp', left=P, right=PropFormula('imp', left=PP, right=P)),
        right=PropFormula('imp',
            left=PropFormula('imp', left=P, right=PP),
            right=PP))

    steps = [
        HilbertStep(s_inst, 'axiom_s'),
        HilbertStep(PropFormula('imp', left=P, right=PropFormula('imp', left=PP, right=P)), 'axiom_k'),
        HilbertStep(PropFormula('imp', left=PropFormula('imp', left=P, right=PP), right=PP), 'mp'),
        HilbertStep(PropFormula('imp', left=P, right=PP), 'axiom_k'),
        HilbertStep(PP, 'mp'),
    ]
    deps = [[], [], [1, 0], [], [3, 2]]

    cert = make_hilbert_certificate(steps, deps)

    print(f"\nCertificate: {cert.n} steps, max dep card: {cert.max_dep_card()}")

    # Verify all steps
    bad = compute_bad_indices(hs, cert)
    print(f"Bad indices: {bad}")
    print(f"Defect density: {defect_density(hs, cert):.4f}")

    # Single audit
    for i in range(cert.n):
        t = single_step_audit(hs, cert, i)
        print(f"  Step {i}: {'ACCEPT' if t.accepted else 'REJECT'}, leakage={1+len(t.dep_indices)}")

    # Repeated audit
    result = repeated_audit(hs, cert, [0, 1, 2, 3, 4])
    print(f"\nRepeated audit (all steps): accepted={result.all_accepted}, leakage={result.total_leakage}")
