#!/usr/bin/env python3
"""
Proof Dynamics: Core Algorithms

Implements the certified normalization, complexity analysis, and
refinement-chain computation algorithms from the research paper.

All algorithms mirror the formally verified Lean definitions.
"""

from __future__ import annotations
from dataclasses import dataclass
from enum import Enum, auto
from typing import Optional


# ────────────────────────────────────────────────────────────────
# Data Types (self-contained)
# ────────────────────────────────────────────────────────────────

class TheoremLabel(Enum):
    IrrationalSqrt2 = auto()
    EvenPlusEvenEven = auto()
    DvdTrans = auto()
    ParityLemma = auto()

@dataclass
class ProofSketch:
    """Base class for proof sketch nodes."""
    pass

@dataclass
class Axiom(ProofSketch):
    label: TheoremLabel

@dataclass
class Lemma(ProofSketch):
    label: TheoremLabel
    sub: ProofSketch

@dataclass
class Trans(ProofSketch):
    left: ProofSketch
    right: ProofSketch

@dataclass
class Cases(ProofSketch):
    left: ProofSketch
    right: ProofSketch

@dataclass
class Redundant(ProofSketch):
    inner: ProofSketch

@dataclass
class Duplicate(ProofSketch):
    inner: ProofSketch


# ────────────────────────────────────────────────────────────────
# Algorithm 1: Multi-Dimensional Complexity
# ────────────────────────────────────────────────────────────────

@dataclass
class ProofComplexity:
    """Multi-component complexity vector.

    Attributes:
        length: total node count
        depth: tree height
        lemma_count: number of Lemma nodes

    Time complexity: O(n) where n = number of nodes
    Space complexity: O(d) where d = tree depth (recursion stack)
    """
    length: int
    depth: int
    lemma_count: int

    @property
    def score(self) -> int:
        """Scalar scalarization: sum of components."""
        return self.length + self.depth + self.lemma_count

    def lex_lt(self, other: ProofComplexity) -> bool:
        """Lexicographic comparison (self < other)."""
        if self.length != other.length:
            return self.length < other.length
        if self.depth != other.depth:
            return self.depth < other.depth
        return self.lemma_count < other.lemma_count

    def __repr__(self):
        return f"({self.length}, {self.depth}, {self.lemma_count})"


def compute_complexity(p: ProofSketch) -> ProofComplexity:
    """Compute the full complexity vector of a proof sketch.

    Time: O(n), Space: O(d)
    """
    if isinstance(p, Axiom):
        return ProofComplexity(1, 0, 0)
    if isinstance(p, Lemma):
        c = compute_complexity(p.sub)
        return ProofComplexity(1 + c.length, 1 + c.depth, 1 + c.lemma_count)
    if isinstance(p, (Trans, Cases)):
        cl = compute_complexity(p.left)
        cr = compute_complexity(p.right)
        return ProofComplexity(
            1 + cl.length + cr.length,
            1 + max(cl.depth, cr.depth),
            cl.lemma_count + cr.lemma_count
        )
    if isinstance(p, (Redundant, Duplicate)):
        c = compute_complexity(p.inner)
        return ProofComplexity(1 + c.length, 1 + c.depth, c.lemma_count)
    raise TypeError(f"Unknown node type: {type(p)}")


# ────────────────────────────────────────────────────────────────
# Algorithm 2: Semantic Extraction
# ────────────────────────────────────────────────────────────────

def semantics(p: ProofSketch) -> TheoremLabel:
    """Extract the theorem label established by this sketch.

    Time: O(d), Space: O(d)
    Invariant: preserved under all refinement steps.
    """
    if isinstance(p, Axiom): return p.label
    if isinstance(p, Lemma): return p.label
    if isinstance(p, Trans): return semantics(p.left)
    if isinstance(p, Cases): return semantics(p.left)
    if isinstance(p, Redundant): return semantics(p.inner)
    if isinstance(p, Duplicate): return semantics(p.inner)
    raise TypeError


# ────────────────────────────────────────────────────────────────
# Algorithm 3: Greedy Normalization
# ────────────────────────────────────────────────────────────────

def step_once(p: ProofSketch) -> Optional[ProofSketch]:
    """Apply one greedy refinement step.

    Returns None if p is already in normal form.
    Guarantees: score(result) < score(p) when result is not None.

    Time: O(n) per step, Space: O(d)

    Pseudocode:
        match p with
        | Redundant(q)        → q
        | Duplicate(q)        → q
        | Lemma(a, Redundant(q)) → Lemma(a, q)
        | Lemma(a, Axiom(_))  → Axiom(a)
        | Lemma(a, q)         → if q' = step(q) then Lemma(a, q')
        | Trans(p, q)         → try step(p), then step(q)
        | Cases(p, q)         → try step(p), then step(q)
        | Axiom(_)            → None  (normal form)
    """
    if isinstance(p, Redundant):
        return p.inner
    if isinstance(p, Duplicate):
        return p.inner
    if isinstance(p, Lemma):
        if isinstance(p.sub, Redundant):
            return Lemma(p.label, p.sub.inner)
        if isinstance(p.sub, Axiom):
            return Axiom(p.label)
        s = step_once(p.sub)
        return Lemma(p.label, s) if s is not None else None
    if isinstance(p, Trans):
        s = step_once(p.left)
        if s is not None: return Trans(s, p.right)
        s = step_once(p.right)
        if s is not None: return Trans(p.left, s)
        return None
    if isinstance(p, Cases):
        s = step_once(p.left)
        if s is not None: return Cases(s, p.right)
        s = step_once(p.right)
        if s is not None: return Cases(p.left, s)
        return None
    return None


def normalize(p: ProofSketch) -> tuple[ProofSketch, int]:
    """Normalize a proof sketch, returning (normal_form, steps_taken).

    Convergence: guaranteed by well-foundedness (score decreases at each step).
    Worst case: O(n) steps where n = initial size.
    Total time: O(n²) in the worst case.
    """
    steps = 0
    current = p
    while True:
        nxt = step_once(current)
        if nxt is None:
            return current, steps
        current = nxt
        steps += 1


# ────────────────────────────────────────────────────────────────
# Algorithm 4: Refinement Chain with Full Diagnostics
# ────────────────────────────────────────────────────────────────

@dataclass
class RefinementDiagnostics:
    """Full diagnostic report for a refinement chain."""
    chain: list[ProofSketch]
    complexities: list[ProofComplexity]
    scores: list[int]
    energy_drops: list[int]
    initial_semantics: TheoremLabel
    final_semantics: TheoremLabel
    semantics_preserved: bool
    total_energy_dissipated: int
    is_final_normal_form: bool

    def summary(self) -> str:
        lines = [
            f"Chain length: {len(self.chain)} states ({len(self.chain)-1} steps)",
            f"Initial score: {self.scores[0]}",
            f"Final score: {self.scores[-1]}",
            f"Total energy dissipated: {self.total_energy_dissipated}",
            f"Semantics preserved: {self.semantics_preserved}",
            f"Final is normal form: {self.is_final_normal_form}",
            f"Energy drops: {self.energy_drops}",
        ]
        return "\n".join(lines)


def full_refinement_analysis(p: ProofSketch) -> RefinementDiagnostics:
    """Run complete refinement analysis with diagnostics.

    Time: O(n²) total, Space: O(n·k) where k = chain length.
    """
    chain = [p]
    current = p
    while True:
        nxt = step_once(current)
        if nxt is None:
            break
        chain.append(nxt)
        current = nxt

    complexities = [compute_complexity(s) for s in chain]
    scores = [c.score for c in complexities]
    energy_drops = [scores[i] - scores[i+1] for i in range(len(scores)-1)]

    return RefinementDiagnostics(
        chain=chain,
        complexities=complexities,
        scores=scores,
        energy_drops=energy_drops,
        initial_semantics=semantics(chain[0]),
        final_semantics=semantics(chain[-1]),
        semantics_preserved=semantics(chain[0]) == semantics(chain[-1]),
        total_energy_dissipated=scores[0] - scores[-1],
        is_final_normal_form=step_once(chain[-1]) is None,
    )


# ────────────────────────────────────────────────────────────────
# Algorithm 5: Exhaustive Normal-Form Enumeration
# ────────────────────────────────────────────────────────────────

def sketch_fingerprint(p: ProofSketch) -> tuple:
    """Convert sketch to hashable fingerprint."""
    if isinstance(p, Axiom): return ('A', p.label.value)
    if isinstance(p, Lemma): return ('L', p.label.value, sketch_fingerprint(p.sub))
    if isinstance(p, Trans): return ('T', sketch_fingerprint(p.left), sketch_fingerprint(p.right))
    if isinstance(p, Cases): return ('C', sketch_fingerprint(p.left), sketch_fingerprint(p.right))
    if isinstance(p, Redundant): return ('R', sketch_fingerprint(p.inner))
    if isinstance(p, Duplicate): return ('D', sketch_fingerprint(p.inner))
    raise TypeError


def enumerate_sketches(depth: int, labels: list[TheoremLabel]) -> list[ProofSketch]:
    """Generate all proof sketches up to given depth."""
    if depth == 0:
        return [Axiom(l) for l in labels]
    smaller = enumerate_sketches(depth - 1, labels)
    result = list(smaller)
    for p in smaller:
        result.extend([Redundant(p), Duplicate(p)])
        for l in labels:
            result.append(Lemma(l, p))
    for p1 in smaller:
        for p2 in smaller:
            result.extend([Trans(p1, p2), Cases(p1, p2)])
    return result


def test_uniqueness_conjecture(max_depth: int,
                                labels: list[TheoremLabel]) -> dict:
    """Test normal-form uniqueness conjecture up to given depth.

    Returns dict mapping each label to set of distinct normal forms.
    """
    sketches = enumerate_sketches(max_depth, labels)
    groups: dict[TheoremLabel, set] = {}
    for p in sketches:
        nf, _ = normalize(p)
        fp = sketch_fingerprint(nf)
        s = semantics(p)
        groups.setdefault(s, set()).add(fp)
    return {k: len(v) for k, v in groups.items()}


# ────────────────────────────────────────────────────────────────
# Usage Example
# ────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    # Example: analyze a complex proof sketch
    sketch = Redundant(Duplicate(
        Lemma(TheoremLabel.IrrationalSqrt2,
            Trans(
                Redundant(Axiom(TheoremLabel.EvenPlusEvenEven)),
                Axiom(TheoremLabel.DvdTrans)
            ))))

    diag = full_refinement_analysis(sketch)
    print("Full Refinement Analysis:")
    print(diag.summary())
    print()

    # Test uniqueness conjecture
    labels = list(TheoremLabel)[:2]
    for d in range(1, 3):
        result = test_uniqueness_conjecture(d, labels)
        print(f"Depth {d}: normal forms per label = {result}")
