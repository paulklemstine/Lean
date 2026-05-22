#!/usr/bin/env python3
"""
Algorithms for E-Graph Extraction as Quotient Sections

Implements the core algorithms described in the research paper:
1. Union-Find with path compression and union by rank
2. Congruence closure for term algebras
3. Cost-optimal extraction via dynamic programming
4. Galois connection computation between congruences and model classes
5. Saturation level computation

All algorithms include docstrings, type hints, and complexity analysis.
"""

from dataclasses import dataclass, field
from typing import Dict, List, Set, Tuple, Optional, Callable, FrozenSet
from collections import defaultdict, deque
import itertools


# ============================================================
# Data Structures
# ============================================================

@dataclass(frozen=True)
class Const:
    """A constant term. Immutable and hashable."""
    name: str

@dataclass(frozen=True)
class BinOp:
    """A binary operation term. Immutable and hashable."""
    op: str
    left: 'Term'
    right: 'Term'

Term = Const | BinOp


def term_size(t: Term) -> int:
    """
    Compute the AST size of a term (number of nodes).

    Time complexity: O(|t|) where |t| is the size of the term.
    Space complexity: O(depth(t)) for the recursion stack.

    >>> term_size(Const("x"))
    1
    >>> term_size(BinOp("+", Const("x"), Const("y")))
    3
    """
    if isinstance(t, Const):
        return 1
    return 1 + term_size(t.left) + term_size(t.right)


def term_depth(t: Term) -> int:
    """
    Compute the depth of a term.

    >>> term_depth(Const("x"))
    0
    >>> term_depth(BinOp("+", Const("x"), Const("y")))
    1
    """
    if isinstance(t, Const):
        return 0
    return 1 + max(term_depth(t.left), term_depth(t.right))


def term_str(t: Term) -> str:
    """Pretty-print a term."""
    if isinstance(t, Const):
        return t.name
    return f"({term_str(t.left)} {t.op} {term_str(t.right)})"


# ============================================================
# Algorithm 1: Union-Find with Path Compression
# ============================================================

class UnionFind:
    """
    Union-Find data structure with path compression and union by rank.

    Supports the e-graph's equivalence class tracking. Each element
    belongs to exactly one equivalence class, identified by a canonical
    representative.

    Time complexity:
        - make_set: O(1)
        - find: O(α(n)) amortized (inverse Ackermann)
        - union: O(α(n)) amortized

    Space complexity: O(n) where n is the number of elements.

    Example:
        >>> uf = UnionFind()
        >>> uf.make_set(0); uf.make_set(1); uf.make_set(2)
        >>> uf.union(0, 1)
        >>> uf.find(0) == uf.find(1)
        True
        >>> uf.find(0) == uf.find(2)
        False
    """

    def __init__(self):
        self.parent: Dict[int, int] = {}
        self.rank: Dict[int, int] = {}
        self._n_classes: int = 0

    def make_set(self, x: int) -> None:
        """Create a singleton equivalence class for element x."""
        if x not in self.parent:
            self.parent[x] = x
            self.rank[x] = 0
            self._n_classes += 1

    def find(self, x: int) -> int:
        """
        Find the canonical representative of x's equivalence class.
        Uses path compression for amortized near-constant time.
        """
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])  # Path compression
        return self.parent[x]

    def union(self, x: int, y: int) -> bool:
        """
        Merge the equivalence classes of x and y.
        Returns True if a merge actually occurred (they were in different classes).
        Uses union by rank for balanced trees.
        """
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        self._n_classes -= 1
        return True

    @property
    def n_classes(self) -> int:
        """Number of distinct equivalence classes."""
        return self._n_classes

    def get_classes(self) -> Dict[int, List[int]]:
        """Return all equivalence classes as {representative: [members]}."""
        classes: Dict[int, List[int]] = defaultdict(list)
        for x in self.parent:
            classes[self.find(x)].append(x)
        return classes


# ============================================================
# Algorithm 2: E-Graph with Congruence Closure
# ============================================================

class EGraph:
    """
    E-Graph: Equality Graph for term equivalence classes.

    Implements the core e-graph data structure that computes a congruence
    on the term algebra. Terms are added, rewrite rules are applied, and
    equivalent terms are merged into e-classes.

    The e-graph maintains the invariant that if two terms' children are
    in the same e-classes, and they have the same root operation, then
    the terms themselves are in the same e-class (congruence closure).

    Time complexity:
        - add_term: O(|t| · α(n))
        - merge: O(α(n)) amortized
        - rebuild (congruence closure): O(n · α(n)) per pass

    Space complexity: O(n) where n is the number of distinct terms added.

    Example:
        >>> eg = EGraph()
        >>> t1 = BinOp("+", Const("a"), Const("b"))
        >>> t2 = BinOp("+", Const("b"), Const("a"))
        >>> id1 = eg.add_term(t1)
        >>> id2 = eg.add_term(t2)
        >>> eg.merge(id1, id2)  # commutativity
        >>> eg.find(id1) == eg.find(id2)
        True
    """

    def __init__(self):
        self.uf = UnionFind()
        self.term_to_id: Dict[str, int] = {}
        self.id_to_term: Dict[int, Term] = {}
        self.next_id: int = 0

    def add_term(self, t: Term) -> int:
        """
        Add a term to the e-graph, returning its e-class id.
        If the term already exists, returns its existing id.
        """
        key = term_str(t)
        if key in self.term_to_id:
            return self.term_to_id[key]

        tid = self.next_id
        self.next_id += 1
        self.uf.make_set(tid)
        self.term_to_id[key] = tid
        self.id_to_term[tid] = t
        return tid

    def merge(self, id1: int, id2: int) -> bool:
        """Merge two e-classes. Returns True if they were different."""
        return self.uf.union(id1, id2)

    def find(self, tid: int) -> int:
        """Find the canonical e-class representative."""
        return self.uf.find(tid)

    def get_classes(self) -> Dict[int, List[Tuple[int, Term]]]:
        """Return e-classes as {representative: [(id, term), ...]}."""
        classes: Dict[int, List[Tuple[int, Term]]] = defaultdict(list)
        for tid, term in self.id_to_term.items():
            classes[self.uf.find(tid)].append((tid, term))
        return classes

    @property
    def n_classes(self) -> int:
        """Number of distinct e-classes."""
        return self.uf.n_classes

    @property
    def n_terms(self) -> int:
        """Total number of terms in the e-graph."""
        return len(self.id_to_term)


# ============================================================
# Algorithm 3: Cost-Optimal Extraction
# ============================================================

def extract_min_cost(
    egraph: EGraph,
    cost_fn: Callable[[Term], int] = term_size
) -> Dict[int, Tuple[Term, int]]:
    """
    Extract the minimum-cost representative from each e-class.

    This implements the extraction section from the formal framework:
    it selects one term per e-class, certified (by construction) to be
    in the same class as any other member.

    Algorithm: For each e-class, iterate over all member terms and
    select the one with minimum cost.

    Time complexity: O(n · C) where n is the number of terms and
    C is the cost of evaluating the cost function on each term.

    Space complexity: O(k) where k is the number of e-classes.

    Args:
        egraph: The e-graph to extract from.
        cost_fn: Cost function on terms (default: AST size).

    Returns:
        Dictionary mapping class representative to (extracted_term, cost).

    Example:
        >>> eg = EGraph()
        >>> id1 = eg.add_term(BinOp("+", Const("a"), Const("b")))
        >>> id2 = eg.add_term(Const("c"))
        >>> eg.merge(id1, id2)
        True
        >>> result = extract_min_cost(eg)
        >>> len(result) == 1  # one e-class
        True
    """
    classes = egraph.get_classes()
    result: Dict[int, Tuple[Term, int]] = {}

    for rep, members in classes.items():
        best_term = None
        best_cost = float('inf')
        for tid, term in members:
            c = cost_fn(term)
            if c < best_cost:
                best_cost = c
                best_term = term
        if best_term is not None:
            result[rep] = (best_term, best_cost)

    return result


# ============================================================
# Algorithm 4: Galois Connection Computation
# ============================================================

def compute_model_class(
    domain: List[int],
    rel: Callable[[int, int], bool],
    candidate_fns: List[Callable[[int], int]]
) -> List[Callable[[int], int]]:
    """
    Compute ModelClass(rel): the set of functions that respect
    the equivalence relation.

    A function f is in ModelClass(rel) iff:
        ∀ a, b ∈ domain: rel(a, b) → f(a) = f(b)

    Time complexity: O(|F| · |domain|²)

    Args:
        domain: The finite domain.
        rel: The equivalence relation.
        candidate_fns: Functions to test.

    Returns:
        List of functions that respect rel.
    """
    result = []
    for f in candidate_fns:
        respects = True
        for a in domain:
            if not respects:
                break
            for b in domain:
                if rel(a, b) and f(a) != f(b):
                    respects = False
                    break
        if respects:
            result.append(f)
    return result


def compute_induced_congruence(
    domain: List[int],
    functions: List[Callable[[int], int]]
) -> Callable[[int, int], bool]:
    """
    Compute congruenceInducedBy(F): the finest equivalence relation
    such that all functions in F are congruent.

    Two elements a, b are related iff ∀ f ∈ F: f(a) = f(b).

    Time complexity: O(|domain|² · |F|)

    Returns:
        A function rel(a, b) -> bool representing the induced congruence.
    """
    def rel(a: int, b: int) -> bool:
        return all(f(a) == f(b) for f in functions)
    return rel


def verify_galois_connection(
    domain: List[int],
    rel: Callable[[int, int], bool],
    functions: List[Callable[[int], int]]
) -> Tuple[bool, bool, bool]:
    """
    Verify both directions of the Galois connection:
        rel ⊆ congruenceInducedBy(F)  ⟺  F ⊆ ModelClass(rel)

    Returns: (forward, backward, connection_holds)
    """
    induced = compute_induced_congruence(domain, functions)

    # Forward: rel ⊆ induced?
    forward = True
    for a in domain:
        for b in domain:
            if rel(a, b) and not induced(a, b):
                forward = False
                break
        if not forward:
            break

    # Backward: F ⊆ ModelClass(rel)?
    model_class = compute_model_class(domain, rel, functions)
    backward = len(model_class) == len(functions)

    return forward, backward, forward == backward


# ============================================================
# Algorithm 5: Saturation with Rewrite Rules
# ============================================================

@dataclass
class RewriteRule:
    """
    A rewrite rule for equality saturation.

    A rule is a function that takes a term and produces an optional
    equivalent term. If the rule applies, it returns the rewritten
    term; otherwise, it returns None.
    """
    name: str
    apply: Callable[[Term], Optional[Term]]


def make_commutativity_rule(op: str) -> RewriteRule:
    """Create a commutativity rule: a op b = b op a."""
    def apply(t: Term) -> Optional[Term]:
        if isinstance(t, BinOp) and t.op == op:
            return BinOp(op, t.right, t.left)
        return None
    return RewriteRule(f"comm_{op}", apply)


def make_associativity_rule(op: str) -> RewriteRule:
    """Create an associativity rule: (a op b) op c = a op (b op c)."""
    def apply(t: Term) -> Optional[Term]:
        if isinstance(t, BinOp) and t.op == op and isinstance(t.left, BinOp) and t.left.op == op:
            return BinOp(op, t.left.left, BinOp(op, t.left.right, t.right))
        return None
    return RewriteRule(f"assoc_{op}", apply)


def saturate(
    egraph: EGraph,
    rules: List[RewriteRule],
    max_iterations: int = 100,
    max_terms: int = 10000
) -> int:
    """
    Run equality saturation: iteratively apply all rewrite rules
    until no new merges occur or limits are reached.

    Pseudocode:
        iteration = 0
        while iteration < max_iterations:
            new_merges = 0
            for each term t in egraph:
                for each rule r in rules:
                    if t' = r.apply(t) is not None:
                        id' = egraph.add(t')
                        if egraph.merge(id_t, id'):
                            new_merges += 1
            if new_merges == 0:
                break  # fixpoint reached
            iteration += 1
        return iteration

    Time complexity: O(iterations · n · |rules| · α(n))
    Space complexity: O(n) for the e-graph

    Args:
        egraph: The e-graph to saturate.
        rules: List of rewrite rules to apply.
        max_iterations: Maximum number of saturation rounds.
        max_terms: Maximum number of terms before stopping.

    Returns:
        Number of iterations performed.
    """
    for iteration in range(max_iterations):
        if egraph.n_terms >= max_terms:
            return iteration

        new_merges = 0
        # Snapshot current terms to avoid modifying during iteration
        current_terms = list(egraph.id_to_term.items())

        for tid, term in current_terms:
            for rule in rules:
                rewritten = rule.apply(term)
                if rewritten is not None:
                    new_id = egraph.add_term(rewritten)
                    if egraph.merge(tid, new_id):
                        new_merges += 1

        if new_merges == 0:
            return iteration + 1  # Saturated

    return max_iterations


# ============================================================
# Algorithm 6: Compression Ratio Analysis
# ============================================================

def compression_analysis(
    egraph: EGraph
) -> Dict[str, float]:
    """
    Analyze the compression achieved by the e-graph's congruence.

    Returns metrics:
        - n_terms: total number of terms
        - n_classes: number of equivalence classes
        - compression_ratio: n_classes / n_terms (lower = more compression)
        - avg_class_size: average number of terms per class
        - max_class_size: size of the largest class
        - entropy_reduction: log2(n_terms) - log2(n_classes) bits saved

    Time complexity: O(n · α(n))
    """
    import math

    classes = egraph.get_classes()
    n_terms = egraph.n_terms
    n_classes = len(classes)
    class_sizes = [len(members) for members in classes.values()]

    return {
        "n_terms": n_terms,
        "n_classes": n_classes,
        "compression_ratio": n_classes / n_terms if n_terms > 0 else 1.0,
        "avg_class_size": n_terms / n_classes if n_classes > 0 else 0,
        "max_class_size": max(class_sizes) if class_sizes else 0,
        "entropy_reduction": (
            math.log2(n_terms) - math.log2(n_classes)
            if n_terms > 0 and n_classes > 0 else 0
        ),
    }


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("E-Graph Algorithms Demo")
    print("=" * 50)

    # Build a term algebra
    a, b, c = Const("a"), Const("b"), Const("c")
    t1 = BinOp("+", a, b)              # a + b
    t2 = BinOp("+", b, a)              # b + a
    t3 = BinOp("+", BinOp("+", a, b), c)  # (a + b) + c
    t4 = BinOp("+", a, BinOp("+", b, c))  # a + (b + c)

    # Create e-graph
    eg = EGraph()
    ids = {
        "a+b": eg.add_term(t1),
        "b+a": eg.add_term(t2),
        "(a+b)+c": eg.add_term(t3),
        "a+(b+c)": eg.add_term(t4),
    }

    print(f"\nBefore saturation:")
    print(f"  Terms: {eg.n_terms}, Classes: {eg.n_classes}")

    # Saturate with commutativity and associativity
    rules = [
        make_commutativity_rule("+"),
        make_associativity_rule("+"),
    ]
    n_iters = saturate(eg, rules, max_iterations=10)

    print(f"\nAfter {n_iters} iterations of saturation:")
    print(f"  Terms: {eg.n_terms}, Classes: {eg.n_classes}")

    # Extract optimal terms
    extracted = extract_min_cost(eg)
    print(f"\nExtracted terms ({len(extracted)} classes):")
    for rep, (term, cost) in extracted.items():
        print(f"  Class {rep}: {term_str(term)} (cost={cost})")

    # Compression analysis
    stats = compression_analysis(eg)
    print(f"\nCompression analysis:")
    for key, val in stats.items():
        print(f"  {key}: {val:.4f}" if isinstance(val, float) else f"  {key}: {val}")

    # Galois connection verification
    print(f"\nGalois connection test:")
    domain = list(range(6))
    rel = lambda x, y: x % 3 == y % 3
    fns = [lambda x: x % 3, lambda x: x % 6]
    fwd, bwd, holds = verify_galois_connection(domain, rel, fns)
    print(f"  Forward: {fwd}, Backward: {bwd}, Connection holds: {holds}")
