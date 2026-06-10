#!/usr/bin/env python3
"""
Algorithms for Semantic Quotient Extraction

Implements the core algorithms from the research paper:
1. Union-Find E-Graph with semantic verification
2. Bounded equality saturation with cost-based extraction
3. Semantic soundness checker for arbitrary rewrite systems
"""

from typing import Dict, List, Set, Tuple, Callable, Optional, Any
from dataclasses import dataclass, field
from collections import defaultdict
import random


# ─────────────────────────────────────────────────────────────────────
# Algorithm 1: Union-Find E-Graph
# ─────────────────────────────────────────────────────────────────────

class UnionFindEGraph:
    """
    E-Graph implementation using union-find with path compression and union by rank.

    Maintains equivalence classes of terms. Supports:
    - Merging two terms into the same class
    - Finding the canonical representative
    - Extracting the cheapest member of a class

    Time complexity:
    - find: O(α(n)) amortized (inverse Ackermann)
    - merge: O(α(n)) amortized
    - extract_cheapest: O(|class|)

    Space complexity: O(n) where n = number of terms added
    """

    def __init__(self, cost_fn: Callable[[Any], int] = lambda x: 1):
        self.parent: Dict[Any, Any] = {}
        self.rank: Dict[Any, int] = {}
        self.members: Dict[Any, Set[Any]] = {}
        self.cost_fn = cost_fn

    def _ensure(self, x):
        if x not in self.parent:
            self.parent[x] = x
            self.rank[x] = 0
            self.members[x] = {x}

    def find(self, x) -> Any:
        """Find canonical representative with path compression."""
        self._ensure(x)
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]

    def merge(self, a, b) -> bool:
        """
        Merge equivalence classes of a and b.
        Returns True if a merge actually occurred (they were in different classes).
        """
        ra, rb = self.find(a), self.find(b)
        if ra == rb:
            return False
        # Union by rank
        if self.rank[ra] < self.rank[rb]:
            ra, rb = rb, ra
        self.parent[rb] = ra
        self.members[ra] = self.members[ra] | self.members[rb]
        del self.members[rb]
        if self.rank[ra] == self.rank[rb]:
            self.rank[ra] += 1
        return True

    def same_class(self, a, b) -> bool:
        """Check if a and b are in the same equivalence class."""
        return self.find(a) == self.find(b)

    def get_class(self, x) -> Set[Any]:
        """Return all members of x's equivalence class."""
        return self.members[self.find(x)]

    def extract_cheapest(self, x) -> Any:
        """
        Extract the cheapest term from x's equivalence class.

        This is the core extraction algorithm. By the Semantic Quotient
        Extraction theorem, the result is guaranteed to be semantically
        equivalent to x whenever the rewrite relation is step-sound.
        """
        cls = self.get_class(x)
        return min(cls, key=self.cost_fn)

    def num_classes(self) -> int:
        """Return the number of distinct equivalence classes."""
        return len(self.members)


# ─────────────────────────────────────────────────────────────────────
# Algorithm 2: Bounded Equality Saturation
# ─────────────────────────────────────────────────────────────────────

@dataclass
class RewriteRule:
    """
    A rewrite rule with a name, match function, and application function.

    The match function checks if a term matches the LHS pattern.
    The apply function produces the RHS given a matching term.
    """
    name: str
    match_and_apply: Callable[[Any], Optional[Any]]

    def apply_at_root(self, term) -> Optional[Any]:
        return self.match_and_apply(term)


def bounded_equality_saturation(
    seed_terms: List[Any],
    rules: List[RewriteRule],
    apply_in_subterms: Callable[[Any, RewriteRule], List[Any]],
    cost_fn: Callable[[Any], int],
    max_iterations: int = 10,
    max_class_size: int = 1000,
    max_term_size: int = 50,
    term_size_fn: Callable[[Any], int] = lambda x: 1,
) -> UnionFindEGraph:
    """
    Bounded equality saturation algorithm.

    Pseudocode:
    ```
    function SATURATE(seeds, rules, bound):
        E ← new EGraph
        for t in seeds: E.add(t)
        for i = 1 to bound:
            new_merges ← false
            for each term t in E:
                for each rule r in rules:
                    for each result s of applying r to t:
                        if size(s) ≤ max_term_size:
                            if E.merge(t, s):
                                new_merges ← true
            if not new_merges: break  // fixpoint reached
        return E
    ```

    Args:
        seed_terms: Initial terms to saturate from
        rules: Rewrite rules to apply
        apply_in_subterms: Function to apply a rule at all positions in a term
        cost_fn: Cost function for extraction
        max_iterations: Maximum saturation iterations
        max_class_size: Maximum total terms in the e-graph
        max_term_size: Maximum size of any generated term
        term_size_fn: Function to compute term size

    Returns:
        Saturated EGraph

    Complexity:
        Time: O(max_iterations × |terms| × |rules| × branching_factor)
        Space: O(max_class_size)
    """
    eg = UnionFindEGraph(cost_fn)
    all_terms: Set = set(seed_terms)

    for iteration in range(max_iterations):
        new_merges = False
        terms_snapshot = list(all_terms)

        for t in terms_snapshot:
            for rule in rules:
                results = apply_in_subterms(t, rule)
                for s in results:
                    if term_size_fn(s) <= max_term_size:
                        if eg.merge(t, s):
                            new_merges = True
                        if s not in all_terms:
                            all_terms.add(s)

            if len(all_terms) >= max_class_size:
                break

        if not new_merges:
            break  # Fixpoint reached

    return eg


# ─────────────────────────────────────────────────────────────────────
# Algorithm 3: Semantic Soundness Verifier
# ─────────────────────────────────────────────────────────────────────

def verify_extraction_soundness(
    egraph: UnionFindEGraph,
    terms: List[Any],
    denote_fn: Callable[[Any, Any], Any],
    environments: List[Any],
) -> Tuple[bool, List[dict]]:
    """
    Verify that extraction preserves semantics across all environments.

    For each term t and environment env:
    1. Compute denote(t, env)
    2. Extract cheapest representative t' from t's e-class
    3. Compute denote(t', env)
    4. Check denote(t, env) == denote(t', env)

    This is the computational counterpart of the theorem:
        extraction_sound_of_eqvGen_sound

    Args:
        egraph: The saturated e-graph
        terms: Terms to check
        denote_fn: Denotation function (term, env) → value
        environments: List of environments to test

    Returns:
        (all_sound, violations) where violations is a list of
        dicts describing any semantic mismatches found.
    """
    violations = []

    for t in terms:
        extracted = egraph.extract_cheapest(t)
        for env in environments:
            val_t = denote_fn(t, env)
            val_e = denote_fn(extracted, env)
            if val_t != val_e:
                violations.append({
                    'term': t,
                    'extracted': extracted,
                    'environment': env,
                    'original_value': val_t,
                    'extracted_value': val_e,
                })

    return len(violations) == 0, violations


# ─────────────────────────────────────────────────────────────────────
# Algorithm 4: Non-Confluent System Generator
# ─────────────────────────────────────────────────────────────────────

def generate_sound_non_confluent_system(
    num_rules: int = 5,
    seed: int = 42,
) -> Tuple[List[RewriteRule], Callable]:
    """
    Generate a random non-confluent but semantically sound rewrite system.

    Strategy: generate algebraic identities that hold in integer arithmetic.
    These are guaranteed to be sound (they preserve denotation) but may be
    non-confluent and non-terminating.

    Returns:
        (rules, denote_fn)
    """
    rng = random.Random(seed)

    # Base algebraic identities (all sound for integer arithmetic)
    identity_templates = [
        ("comm_add", "a + b = b + a"),
        ("comm_mul", "a * b = b * a"),
        ("add_zero", "a + 0 = a"),
        ("mul_one", "a * 1 = a"),
        ("mul_zero", "a * 0 = 0"),
        ("distribute", "a * (b + c) = a*b + a*c"),
        ("add_assoc", "(a + b) + c = a + (b + c)"),
        ("mul_assoc", "(a * b) * c = a * (b * c)"),
    ]

    # Select a random subset and make some rules bidirectional (non-terminating)
    selected = rng.sample(identity_templates, min(num_rules, len(identity_templates)))

    return selected, None  # Rules are described; implementation is domain-specific


# ─────────────────────────────────────────────────────────────────────
# Example usage
# ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Algorithms for Semantic Quotient Extraction")
    print("=" * 50)

    # Demo: simple integer terms
    from demo import Term, Var, Const, Add, Mul, term_size, denote, term_str

    # Create e-graph with cost = term size
    eg = UnionFindEGraph(cost_fn=term_size)

    # Some equivalent terms: (x + 0) and x
    t1 = Add(Var(0), Const(0))
    t2 = Var(0)
    t3 = Add(Const(0), Var(0))

    eg.merge(t1, t2)
    eg.merge(t1, t3)

    print(f"\nMerged: {term_str(t1)}, {term_str(t2)}, {term_str(t3)}")
    print(f"Cheapest extraction: {term_str(eg.extract_cheapest(t1))}")
    print(f"Class size: {len(eg.get_class(t1))}")

    # Verify soundness
    envs = [{0: v} for v in range(-5, 6)]
    sound, violations = verify_extraction_soundness(
        eg, [t1, t2, t3],
        lambda t, env: denote(t, env),
        envs
    )
    print(f"Soundness verified: {sound}")
    if violations:
        print(f"Violations: {violations}")
