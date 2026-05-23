"""
Algorithms for Equality Saturation and E-Graph Extraction.

Implements:
1. Union-Find data structure for e-class management
2. Bounded saturation algorithm
3. Cost-guided extraction
4. Normal-form computation for convergent systems
"""

from __future__ import annotations
from typing import Callable, Dict, List, Set, Tuple, Optional
from dataclasses import dataclass, field
import random


class UnionFind:
    """Union-Find data structure with path compression and union by rank."""

    def __init__(self, elements: List[int]):
        self.parent: Dict[int, int] = {x: x for x in elements}
        self.rank: Dict[int, int] = {x: 0 for x in elements}

    def find(self, x: int) -> int:
        """Find the root representative of x's class with path compression."""
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]

    def union(self, x: int, y: int) -> bool:
        """Merge classes of x and y. Returns True if a merge occurred."""
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        return True

    def same_class(self, x: int, y: int) -> bool:
        """Check if x and y are in the same equivalence class."""
        return self.find(x) == self.find(y)

    def get_classes(self) -> Dict[int, List[int]]:
        """Return a dictionary mapping each root to its class members."""
        classes: Dict[int, List[int]] = {}
        for x in self.parent:
            root = self.find(x)
            classes.setdefault(root, []).append(x)
        return classes


@dataclass
class RewriteRule:
    """A rewrite rule: if source matches, rewrite to target.

    For finite systems, rules are just pairs (source, target).
    """
    source: int
    target: int


@dataclass
class RewriteSystem:
    """A rewrite system on a finite carrier."""
    carrier: List[int]
    rules: List[RewriteRule]

    def applies(self, term: int) -> List[int]:
        """Return all terms reachable from `term` by a single rule application."""
        return [r.target for r in self.rules if r.source == term]

    def is_normal_form(self, term: int) -> bool:
        """Check if no rule applies to `term`."""
        return len(self.applies(term)) == 0

    def compute_nf(self, term: int, max_steps: int = 1000) -> Optional[int]:
        """Compute the normal form by iteratively applying rules.

        For convergent systems, this always terminates.
        Returns None if max_steps exceeded (non-terminating system).
        """
        current = term
        for _ in range(max_steps):
            nexts = self.applies(current)
            if not nexts:
                return current
            current = nexts[0]  # deterministic choice
        return None

    def is_confluent_on(self, terms: List[int]) -> bool:
        """Check confluence by computing normal forms.

        For finite systems, confluence holds iff all terms in each
        EqvGen class have the same normal form.
        """
        nfs = {}
        for t in terms:
            nf = self.compute_nf(t)
            if nf is None:
                return False
            nfs[t] = nf

        # Check: if two terms are connected by rules (in either direction),
        # they should have the same normal form
        # Build equivalence closure
        uf = UnionFind(terms)
        for r in self.rules:
            if r.source in nfs and r.target in nfs:
                uf.union(r.source, r.target)

        # Check each class has a unique normal form
        classes = uf.get_classes()
        for members in classes.values():
            nf_set = {nfs[m] for m in members if m in nfs}
            if len(nf_set) > 1:
                return False
        return True


@dataclass
class EGraph:
    """An e-graph implementing bounded equality saturation.

    Attributes:
        uf: Union-Find structure managing equivalence classes
        terms: set of all terms in the e-graph
        system: the underlying rewrite system
    """
    uf: UnionFind
    terms: Set[int]
    system: RewriteSystem
    saturation_depth: int = 0

    @classmethod
    def from_seeds(cls, system: RewriteSystem, seeds: List[int]) -> 'EGraph':
        """Create an e-graph from seed terms."""
        terms = set(seeds)
        uf = UnionFind(list(terms))
        return cls(uf=uf, terms=terms, system=system)

    def saturate_step(self) -> bool:
        """Perform one saturation step. Returns True if any change occurred."""
        changed = False
        new_terms: Set[int] = set()

        for t in list(self.terms):
            for r in self.system.rules:
                # Forward: if t matches source, add target
                if t == r.source:
                    new_terms.add(r.target)
                    if r.target not in self.uf.parent:
                        self.uf.parent[r.target] = r.target
                        self.uf.rank[r.target] = 0
                    if self.uf.union(t, r.target):
                        changed = True
                # Backward: if t matches target, add source
                if t == r.target:
                    new_terms.add(r.source)
                    if r.source not in self.uf.parent:
                        self.uf.parent[r.source] = r.source
                        self.uf.rank[r.source] = 0
                    if self.uf.union(t, r.source):
                        changed = True

        if new_terms - self.terms:
            changed = True
        self.terms |= new_terms
        return changed

    def saturate(self, max_depth: int = 100) -> int:
        """Run saturation until fixed point or max_depth.

        Returns the number of steps taken.
        """
        for step in range(1, max_depth + 1):
            if not self.saturate_step():
                self.saturation_depth = step
                return step
        self.saturation_depth = max_depth
        return max_depth

    def same_class(self, a: int, b: int) -> bool:
        """Check if a and b are in the same e-class."""
        if a not in self.uf.parent or b not in self.uf.parent:
            return False
        return self.uf.same_class(a, b)

    def extract_cheapest(self, term: int, cost: Callable[[int], int]) -> int:
        """Extract the cheapest representative from term's e-class."""
        root = self.uf.find(term)
        classes = self.uf.get_classes()
        members = classes.get(root, [term])
        return min(members, key=cost)

    def get_classes(self) -> Dict[int, List[int]]:
        """Get all equivalence classes."""
        return self.uf.get_classes()


def generate_random_convergent_system(
    n: int,
    num_rules: int,
    seed: Optional[int] = None
) -> RewriteSystem:
    """Generate a random convergent (terminating + confluent) rewrite system.

    Strategy: assign a natural ordering to elements. Rules always go from
    higher to lower elements, ensuring termination. Then check confluence
    and retry if needed.

    Args:
        n: carrier size
        num_rules: number of rewrite rules
        seed: random seed

    Returns:
        A convergent rewrite system on {0, 1, ..., n-1}
    """
    if seed is not None:
        random.seed(seed)

    carrier = list(range(n))

    for _ in range(100):  # retry if not confluent
        rules = []
        for _ in range(num_rules):
            # Source must be > target for termination
            source = random.randint(1, n - 1)
            target = random.randint(0, source - 1)
            rules.append(RewriteRule(source=source, target=target))

        system = RewriteSystem(carrier=carrier, rules=rules)

        # Check confluence
        if system.is_confluent_on(carrier):
            return system

    # Fallback: identity system (no rules)
    return RewriteSystem(carrier=carrier, rules=[])


def verify_extraction_soundness(
    system: RewriteSystem,
    seeds: List[int],
    eval_fn: Callable[[int], int],
    cost_fn: Callable[[int], int],
    max_depth: int = 50
) -> Tuple[bool, str]:
    """Verify that extraction preserves semantics.

    This is the computational analogue of extraction_semantics_preserved.

    Returns:
        (success, message) tuple
    """
    egraph = EGraph.from_seeds(system, seeds)
    egraph.saturate(max_depth)

    for t in seeds:
        extracted = egraph.extract_cheapest(t, cost_fn)
        if eval_fn(extracted) != eval_fn(t):
            return False, (
                f"Semantic violation: eval({t})={eval_fn(t)} "
                f"but eval(extract({t}))=eval({extracted})={eval_fn(extracted)}"
            )

    return True, "All extractions preserve semantics"


def verify_nf_agreement(
    system: RewriteSystem,
    seeds: List[int],
    eval_fn: Callable[[int], int],
    cost_fn: Callable[[int], int],
    max_depth: int = 50
) -> Tuple[bool, str]:
    """Verify that extraction agrees with normal-form computation semantically.

    This is the computational analogue of
    extraction_agrees_with_quotient_nf_semantically.

    Returns:
        (success, message) tuple
    """
    egraph = EGraph.from_seeds(system, seeds)
    egraph.saturate(max_depth)

    for t in seeds:
        extracted = egraph.extract_cheapest(t, cost_fn)
        nf = system.compute_nf(t)
        if nf is None:
            return False, f"Normal form computation did not terminate for {t}"
        if eval_fn(extracted) != eval_fn(nf):
            return False, (
                f"NF disagreement: eval(extract({t}))=eval({extracted})"
                f"={eval_fn(extracted)} but eval(nf({t}))=eval({nf})={eval_fn(nf)}"
            )

    return True, "Extraction agrees with normal forms semantically"
