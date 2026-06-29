#!/usr/bin/env python3
"""
Ordinal Research Governance: Algorithms

Implements the core algorithms for ordinal depth computation,
research cycle triage, and proof shape analysis.
"""

from dataclasses import dataclass, field
from typing import List, Set, Tuple, Optional
from enum import Enum
import math


# ─── Core Data Types ──────────────────────────────────────────────────────────

@dataclass
class AetherOutput:
    """
    A finite syntactic object encoding a research output.

    Attributes:
        size: Total size of the output (e.g., proof term size)
        height: Depth of the derivation tree
        branching: Number of distinct derivation branches
        novelty_atoms: Set of novel atomic concepts introduced
        dependencies: Set of prior results used
    """
    size: int
    height: int
    branching: int
    novelty_atoms: Set[int] = field(default_factory=set)
    dependencies: Set[int] = field(default_factory=set)

    def aether_depth(self) -> int:
        """
        Compute ordinal depth (finite projection).
        Time complexity: O(1)
        """
        return self.height + self.branching

    def is_shallow(self) -> bool:
        """Check if output is in the shallow fragment. O(1)."""
        return self.height <= 1 and self.branching <= 1

    def is_nontrivial(self) -> bool:
        """Check if output is non-trivial (outside shallow fragment). O(1)."""
        return not self.is_shallow()

    def innovation_rank(self) -> int:
        """
        Compute innovation rank: |novelty_atoms| + |dependencies|.
        Time complexity: O(1) (set cardinality is cached)
        """
        return len(self.novelty_atoms) + len(self.dependencies)


class TriageDecision(Enum):
    """Governance decision for a research cycle."""
    REJECT = "REJECT"       # All outputs trivial, below threshold
    ESCALATE = "ESCALATE"   # Below threshold but contains nontrivial work
    ACCEPT = "ACCEPT"       # Meets or exceeds threshold


@dataclass
class ResearchCycle:
    """A finite collection of AetherOutputs forming a research cycle."""
    outputs: List[AetherOutput]

    def cycle_depth(self) -> int:
        """
        Compute cycle depth as supremum (max) of output depths.
        Time complexity: O(n) where n = |outputs|
        """
        if not self.outputs:
            return 0
        return max(o.aether_depth() for o in self.outputs)

    def all_below(self, threshold: int) -> bool:
        """
        Check if all outputs are below threshold.
        Time complexity: O(n)

        This implements the verified theorem:
            cycleDepth(C) < τ  ⟺  ∀ x ∈ C, aetherDepth(x) < τ
        """
        return all(o.aether_depth() < threshold for o in self.outputs)


# ─── Algorithm 1: Depth-Based Triage ─────────────────────────────────────────

def triage(threshold: int, cycle: ResearchCycle) -> TriageDecision:
    """
    Automated triage of a research cycle.

    This implements the formally verified triage theorem:
        If cycleDepth(C) < τ:
            - All trivial → REJECT
            - Some nontrivial → ESCALATE
        If cycleDepth(C) ≥ τ:
            → ACCEPT

    Time complexity: O(n) where n = |cycle.outputs|
    Space complexity: O(1)

    Args:
        threshold: The ordinal threshold τ (finite projection)
        cycle: The research cycle to triage

    Returns:
        TriageDecision indicating REJECT, ESCALATE, or ACCEPT
    """
    cd = cycle.cycle_depth()

    if cd >= threshold:
        return TriageDecision.ACCEPT

    has_nontrivial = any(o.is_nontrivial() for o in cycle.outputs)
    if has_nontrivial:
        return TriageDecision.ESCALATE
    else:
        return TriageDecision.REJECT


# ─── Algorithm 2: Batch Cycle Screening ──────────────────────────────────────

def batch_screen(threshold: int, cycles: List[ResearchCycle]) -> dict:
    """
    Screen a batch of research cycles for governance decisions.

    Time complexity: O(N) where N = total outputs across all cycles
    Space complexity: O(k) where k = number of cycles

    Returns:
        Dictionary mapping decision type to list of cycle indices
    """
    result = {d: [] for d in TriageDecision}
    for i, cycle in enumerate(cycles):
        decision = triage(threshold, cycle)
        result[decision].append(i)
    return result


# ─── Algorithm 3: ProofShape Depth Analysis ──────────────────────────────────

class ProofShape:
    """Base class for proof shape constructors."""
    def ps_depth_symbolic(self) -> str:
        """Return symbolic ordinal depth representation."""
        raise NotImplementedError

    def ps_depth_finite(self) -> Optional[int]:
        """Return finite depth if < ω, else None."""
        raise NotImplementedError

    def has_reflect(self) -> bool:
        raise NotImplementedError

    def constructor_count(self) -> dict:
        """Count occurrences of each constructor type."""
        raise NotImplementedError


class Axm(ProofShape):
    def ps_depth_symbolic(self): return "0"
    def ps_depth_finite(self): return 0
    def has_reflect(self): return False
    def constructor_count(self): return {"axm": 1, "compose": 0, "iterate": 0, "reflect": 0}


class Compose(ProofShape):
    def __init__(self, a: ProofShape, b: ProofShape):
        self.a, self.b = a, b

    def ps_depth_symbolic(self):
        return f"succ(max({self.a.ps_depth_symbolic()}, {self.b.ps_depth_symbolic()}))"

    def ps_depth_finite(self):
        da, db = self.a.ps_depth_finite(), self.b.ps_depth_finite()
        if da is None or db is None:
            return None
        return max(da, db) + 1

    def has_reflect(self):
        return self.a.has_reflect() or self.b.has_reflect()

    def constructor_count(self):
        ca, cb = self.a.constructor_count(), self.b.constructor_count()
        return {k: ca.get(k, 0) + cb.get(k, 0) + (1 if k == "compose" else 0) for k in ca}


class Iterate(ProofShape):
    def __init__(self, n: int, a: ProofShape):
        self.n, self.a = n, a

    def ps_depth_symbolic(self):
        return f"{self.a.ps_depth_symbolic()} + {self.n}"

    def ps_depth_finite(self):
        da = self.a.ps_depth_finite()
        if da is None:
            return None
        return da + self.n

    def has_reflect(self):
        return self.a.has_reflect()

    def constructor_count(self):
        c = self.a.constructor_count()
        c["iterate"] = c.get("iterate", 0) + 1
        return c


class Reflect(ProofShape):
    def __init__(self, a: ProofShape):
        self.a = a

    def ps_depth_symbolic(self):
        return f"ω^({self.a.ps_depth_symbolic()})"

    def ps_depth_finite(self):
        da = self.a.ps_depth_finite()
        if da is not None and da == 0:
            return 1  # ω^0 = 1
        return None  # ≥ ω

    def has_reflect(self):
        return True

    def constructor_count(self):
        c = self.a.constructor_count()
        c["reflect"] = c.get("reflect", 0) + 1
        return c


def analyze_proof_shape(shape: ProofShape) -> dict:
    """
    Analyze a proof shape for depth classification.

    Returns a dictionary with:
    - symbolic_depth: symbolic ordinal representation
    - finite_depth: integer depth if < ω, else None
    - is_transfinite: True if depth ≥ ω
    - has_reflect: whether shape contains reflect
    - constructor_counts: counts of each constructor type

    Time complexity: O(|shape|) where |shape| is the number of nodes
    """
    fd = shape.ps_depth_finite()
    return {
        "symbolic_depth": shape.ps_depth_symbolic(),
        "finite_depth": fd,
        "is_transfinite": fd is None,
        "has_reflect": shape.has_reflect(),
        "constructor_counts": shape.constructor_count(),
    }


# ─── Algorithm 4: Innovation-Depth Certification ─────────────────────────────

def certify_innovation(output: AetherOutput) -> Tuple[bool, str]:
    """
    Certify that an output's innovation rank is bounded by its depth.

    Checks the structural condition:
        |novelty_atoms| ≤ height  AND  |dependencies| ≤ branching
    If satisfied, guarantees InnovationRank ≤ aetherDepth.

    Time complexity: O(1)

    Returns:
        (is_certified, explanation)
    """
    n_atoms = len(output.novelty_atoms)
    n_deps = len(output.dependencies)

    cond1 = n_atoms <= output.height
    cond2 = n_deps <= output.branching

    if cond1 and cond2:
        return True, (
            f"Certified: InnovRank={output.innovation_rank()} ≤ "
            f"Depth={output.aether_depth()} "
            f"(atoms={n_atoms}≤h={output.height}, deps={n_deps}≤b={output.branching})"
        )
    else:
        violations = []
        if not cond1:
            violations.append(f"|atoms|={n_atoms} > height={output.height}")
        if not cond2:
            violations.append(f"|deps|={n_deps} > branching={output.branching}")
        return False, f"Not certifiable: {', '.join(violations)}"


# ─── Algorithm 5: Threshold Optimization ─────────────────────────────────────

def optimal_threshold(cycles: List[ResearchCycle],
                      target_accept_rate: float = 0.5) -> int:
    """
    Find the optimal governance threshold that achieves a target acceptance rate.

    Performs binary search over possible thresholds to find the value
    that accepts approximately `target_accept_rate` fraction of cycles.

    Time complexity: O(k * n * log(D)) where k = cycles, n = max outputs, D = max depth
    Space complexity: O(1)

    Args:
        cycles: List of research cycles to evaluate
        target_accept_rate: Desired fraction of cycles to accept (0 to 1)

    Returns:
        Optimal threshold value
    """
    if not cycles:
        return 0

    depths = [c.cycle_depth() for c in cycles]
    lo, hi = 0, max(depths) + 1

    while lo < hi:
        mid = (lo + hi) // 2
        accept_rate = sum(1 for d in depths if d >= mid) / len(depths)
        if accept_rate > target_accept_rate:
            lo = mid + 1
        else:
            hi = mid

    return lo


# ─── Main ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Ordinal Research Governance: Algorithm Demonstrations")
    print("=" * 60)

    # Demo: Triage
    cycle = ResearchCycle([
        AetherOutput(size=10, height=2, branching=1, novelty_atoms={1, 2}, dependencies={10}),
        AetherOutput(size=20, height=1, branching=0),
    ])
    decision = triage(threshold=4, cycle=cycle)
    print(f"\nTriage decision for cycle (τ=4): {decision.value}")

    # Demo: Proof shape analysis
    shape = Reflect(Compose(Iterate(3, Axm()), Axm()))
    analysis = analyze_proof_shape(shape)
    print(f"\nProof shape analysis:")
    for k, v in analysis.items():
        print(f"  {k}: {v}")

    # Demo: Innovation certification
    output = AetherOutput(size=50, height=5, branching=3,
                          novelty_atoms={1, 2, 3, 4}, dependencies={10, 20})
    certified, explanation = certify_innovation(output)
    print(f"\n{explanation}")

    # Demo: Optimal threshold
    import random
    random.seed(42)
    cycles = [
        ResearchCycle([
            AetherOutput(size=random.randint(1, 100),
                         height=random.randint(0, 8),
                         branching=random.randint(0, 5))
            for _ in range(random.randint(1, 5))
        ])
        for _ in range(50)
    ]
    opt_tau = optimal_threshold(cycles, target_accept_rate=0.3)
    print(f"\nOptimal threshold for 30% acceptance: τ = {opt_tau}")
    actual_rate = sum(1 for c in cycles if c.cycle_depth() >= opt_tau) / len(cycles)
    print(f"Actual acceptance rate: {actual_rate:.1%}")
