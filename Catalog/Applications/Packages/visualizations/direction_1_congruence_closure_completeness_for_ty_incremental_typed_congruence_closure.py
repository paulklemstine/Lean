#!/usr/bin/env python3
"""
Typed Congruence Closure Algorithms
====================================

Complete implementations of the algorithms from the research paper,
including incremental congruence closure, normal-form computation,
and partition comparison.

Each algorithm includes:
- Full implementation with type hints
- Docstrings with complexity analysis
- Example usage
"""

from collections import defaultdict
from dataclasses import dataclass, field
from typing import Dict, List, Tuple, Set, Optional, FrozenSet, Callable


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 1: Union-Find with Path Compression and Union by Rank
# ═══════════════════════════════════════════════════════════════════════════

class UnionFind:
    """
    Union-Find (Disjoint Set Union) data structure.

    Supports near-O(1) amortized find and union operations via
    path compression and union by rank.

    Time complexity:
        - make_set: O(1)
        - find: O(α(n)) amortized (inverse Ackermann)
        - union: O(α(n)) amortized

    Space complexity: O(n)
    """

    def __init__(self):
        self._parent: Dict = {}
        self._rank: Dict = defaultdict(int)
        self._size: Dict = defaultdict(lambda: 1)

    def make_set(self, x) -> None:
        """Create a singleton set containing x."""
        if x not in self._parent:
            self._parent[x] = x
            self._rank[x] = 0
            self._size[x] = 1

    def find(self, x):
        """Find the representative of x's equivalence class."""
        root = x
        while self._parent[root] != root:
            root = self._parent[root]
        # Path compression
        while self._parent[x] != root:
            self._parent[x], x = root, self._parent[x]
        return root

    def union(self, x, y) -> bool:
        """
        Merge the equivalence classes of x and y.
        Returns True if a merge occurred (they were in different classes).
        """
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False
        # Union by rank
        if self._rank[rx] < self._rank[ry]:
            rx, ry = ry, rx
        self._parent[ry] = rx
        self._size[rx] += self._size[ry]
        if self._rank[rx] == self._rank[ry]:
            self._rank[rx] += 1
        return True

    def same_class(self, x, y) -> bool:
        """Check if x and y are in the same equivalence class."""
        return self.find(x) == self.find(y)

    def class_of(self, x) -> Set:
        """Return all elements in x's equivalence class."""
        rep = self.find(x)
        return {e for e in self._parent if self.find(e) == rep}

    def num_classes(self) -> int:
        """Return the number of distinct equivalence classes."""
        return len({self.find(x) for x in self._parent})

    def all_classes(self) -> Dict[object, Set]:
        """Return all equivalence classes as a dict from representative to members."""
        classes = defaultdict(set)
        for x in self._parent:
            classes[self.find(x)].add(x)
        return dict(classes)


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 2: Typed Term Representation
# ═══════════════════════════════════════════════════════════════════════════

@dataclass(frozen=True)
class TypedTerm:
    """
    A typed first-order term.

    Attributes:
        sort: The sort (type) of the term
        symbol: The function symbol at the root
        children: The argument subterms (empty for constants)
    """
    sort: str
    symbol: str
    children: Tuple['TypedTerm', ...] = ()

    def __repr__(self):
        if not self.children:
            return self.symbol
        args = ", ".join(str(c) for c in self.children)
        return f"{self.symbol}({args})"

    def depth(self) -> int:
        """The depth of the term tree."""
        if not self.children:
            return 0
        return 1 + max(c.depth() for c in self.children)

    def size(self) -> int:
        """The total number of nodes in the term tree."""
        return 1 + sum(c.size() for c in self.children)


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 3: Incremental Typed Congruence Closure
# ═══════════════════════════════════════════════════════════════════════════

@dataclass
class CongruenceClosureResult:
    """Result of running congruence closure."""
    partition: Dict[TypedTerm, Set[TypedTerm]]
    num_merges: int
    num_congruence_checks: int
    merge_log: List[Tuple[TypedTerm, TypedTerm, str]]


def incremental_congruence_closure(
    terms: List[TypedTerm],
    rewrite_edges: List[Tuple[TypedTerm, TypedTerm]],
) -> CongruenceClosureResult:
    """
    Incremental typed congruence closure algorithm.

    Given a set of terms and rewrite edges, computes the congruence closure:
    the smallest equivalence relation on terms that:
    1. Contains all rewrite edges
    2. Is closed under congruence: if f(a₁,...,aₙ) and f(b₁,...,bₙ) are terms
       and aᵢ ~ bᵢ for all i, then f(a₁,...,aₙ) ~ f(b₁,...,bₙ)

    Algorithm:
        1. Initialize union-find with all terms
        2. Add all rewrite edges to worklist
        3. While worklist is non-empty:
           a. Pop edge (a, b), merge classes
           b. For each function symbol f and each pair of terms
              f(a₁,...,aₙ), f(b₁,...,bₙ) where aᵢ ~ bᵢ:
              add (f(a₁,...,aₙ), f(b₁,...,bₙ)) to worklist

    Time complexity: O(n² · s · α(n)) where n = |terms|, s = |symbols|
    Space complexity: O(n + |rewrite_edges|)

    Args:
        terms: List of typed terms to close over
        rewrite_edges: List of (lhs, rhs) pairs to merge

    Returns:
        CongruenceClosureResult with the partition and statistics
    """
    uf = UnionFind()
    merge_log: List[Tuple[TypedTerm, TypedTerm, str]] = []
    num_merges = 0
    num_checks = 0

    # Initialize
    for t in terms:
        uf.make_set(t)

    # Index terms by symbol for congruence lookup
    terms_by_symbol: Dict[str, List[TypedTerm]] = defaultdict(list)
    for t in terms:
        if t.children:  # Only index compound terms
            terms_by_symbol[t.symbol].append(t)

    # Worklist of edges to process
    worklist: List[Tuple[TypedTerm, TypedTerm, str]] = [
        (lhs, rhs, "rewrite") for lhs, rhs in rewrite_edges
        if lhs in uf._parent and rhs in uf._parent
    ]

    def find_congruent_pairs() -> List[Tuple[TypedTerm, TypedTerm]]:
        """Find all congruent pairs not yet in the same class."""
        nonlocal num_checks
        pairs = []
        for sym, sym_terms in terms_by_symbol.items():
            for i, t1 in enumerate(sym_terms):
                for t2 in sym_terms[i+1:]:
                    num_checks += 1
                    if t1.sort != t2.sort:
                        continue
                    if len(t1.children) != len(t2.children):
                        continue
                    if not uf.same_class(t1, t2):
                        if all(uf.same_class(c1, c2)
                               for c1, c2 in zip(t1.children, t2.children)):
                            pairs.append((t1, t2))
        return pairs

    # Process worklist
    while worklist:
        a, b, reason = worklist.pop()
        if uf.union(a, b):
            num_merges += 1
            merge_log.append((a, b, reason))

            # Check for new congruences
            new_pairs = find_congruent_pairs()
            for t1, t2 in new_pairs:
                worklist.append((t1, t2, f"congruence({t1.symbol})"))

    # Build final partition
    partition = uf.all_classes()

    return CongruenceClosureResult(
        partition=partition,
        num_merges=num_merges,
        num_congruence_checks=num_checks,
        merge_log=merge_log,
    )


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 4: Normal Form Computation for Convergent Systems
# ═══════════════════════════════════════════════════════════════════════════

def compute_normal_form(
    term: TypedTerm,
    rules: List[Tuple[TypedTerm, TypedTerm]],
    max_steps: int = 1000,
) -> TypedTerm:
    """
    Compute the normal form of a term under a convergent rewrite system.

    Applies rewrite rules exhaustively (innermost-first strategy) until
    no more rules apply.

    For convergent systems, the result is independent of the strategy
    (by confluence) and always terminates (by termination).

    Time complexity: O(max_steps · |rules| · |term|)
    Space complexity: O(|term|)

    Args:
        term: The term to normalize
        rules: List of (lhs, rhs) rewrite rules
        max_steps: Maximum number of rewrite steps

    Returns:
        The normal form of the term
    """
    current = term
    for _ in range(max_steps):
        rewritten = False

        # First, normalize children (innermost strategy)
        if current.children:
            new_children = []
            child_changed = False
            for child in current.children:
                nf_child = compute_normal_form(child, rules, max_steps=1)
                new_children.append(nf_child)
                if nf_child != child:
                    child_changed = True
            if child_changed:
                current = TypedTerm(current.sort, current.symbol,
                                    tuple(new_children))
                rewritten = True

        # Then try to rewrite at root
        if not rewritten:
            for lhs, rhs in rules:
                if current == lhs:
                    current = rhs
                    rewritten = True
                    break

        if not rewritten:
            break

    return current


def compute_all_normal_forms(
    terms: List[TypedTerm],
    rules: List[Tuple[TypedTerm, TypedTerm]],
) -> Dict[TypedTerm, TypedTerm]:
    """Compute normal forms for all terms."""
    return {t: compute_normal_form(t, rules) for t in terms}


def nf_partition(
    terms: List[TypedTerm],
    nf_map: Dict[TypedTerm, TypedTerm],
) -> Dict[TypedTerm, Set[TypedTerm]]:
    """Partition terms by their normal forms."""
    classes: Dict[TypedTerm, Set[TypedTerm]] = defaultdict(set)
    for t in terms:
        classes[nf_map[t]].add(t)
    return dict(classes)


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 5: Partition Comparison (Completeness Verification)
# ═══════════════════════════════════════════════════════════════════════════

def partitions_agree(
    terms: List[TypedTerm],
    partition1: Dict[TypedTerm, Set[TypedTerm]],
    partition2: Dict[TypedTerm, Set[TypedTerm]],
) -> Tuple[bool, List[Tuple[TypedTerm, TypedTerm, str]]]:
    """
    Check if two partitions agree on all pairs of terms.

    Returns (agree, disagreements) where disagreements is a list of
    (term1, term2, description) triples showing where they differ.
    """
    # Build membership lookup for partition1
    class1: Dict[TypedTerm, FrozenSet[TypedTerm]] = {}
    for rep, members in partition1.items():
        frozen = frozenset(members)
        for m in members:
            class1[m] = frozen

    class2: Dict[TypedTerm, FrozenSet[TypedTerm]] = {}
    for rep, members in partition2.items():
        frozen = frozenset(members)
        for m in members:
            class2[m] = frozen

    disagreements = []
    for i, t1 in enumerate(terms):
        for t2 in terms[i+1:]:
            same1 = (class1.get(t1) == class1.get(t2)) if t1 in class1 and t2 in class1 else (t1 == t2)
            same2 = (class2.get(t1) == class2.get(t2)) if t1 in class2 and t2 in class2 else (t1 == t2)
            # More robust: check if they share a class
            same1 = t1 in class1 and t2 in class1 and class1[t1] is class1[t2]
            same2 = t1 in class2 and t2 in class2 and class2[t1] is class2[t2]
            if same1 != same2:
                desc = f"P1={'same' if same1 else 'diff'}, P2={'same' if same2 else 'diff'}"
                disagreements.append((t1, t2, desc))

    return len(disagreements) == 0, disagreements


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 6: Candidate Tuple Bound Computation
# ═══════════════════════════════════════════════════════════════════════════

def candidate_tuple_bound(
    num_symbols: int,
    arities: List[int],
    universe_size: int,
) -> Tuple[int, int]:
    """
    Compute the exact number of candidate tuples and the polynomial bound.

    By Theorem 7: Σ_i m^{arity(i)} ≤ n · m^k

    Args:
        num_symbols: Number of function symbols (n)
        arities: List of arities for each symbol
        universe_size: Size of the explored universe (m)

    Returns:
        (exact_count, upper_bound) tuple
    """
    if not arities:
        return 0, 0
    max_arity = max(arities)
    exact = sum(universe_size ** a for a in arities)
    bound = num_symbols * (universe_size ** max_arity)
    return exact, bound


# ═══════════════════════════════════════════════════════════════════════════
# Example Usage
# ═══════════════════════════════════════════════════════════════════════════

def example():
    """Demonstrate all algorithms on a concrete example."""
    print("Typed Congruence Closure — Algorithm Demonstrations")
    print("=" * 60)

    # Define terms
    a = TypedTerm("Nat", "a")
    b = TypedTerm("Nat", "b")
    c = TypedTerm("Nat", "c")
    fa = TypedTerm("Nat", "f", (a,))
    fb = TypedTerm("Nat", "f", (b,))
    fc = TypedTerm("Nat", "f", (c,))
    ga = TypedTerm("Nat", "g", (a,))
    gb = TypedTerm("Nat", "g", (b,))
    ffa = TypedTerm("Nat", "f", (fa,))
    ffb = TypedTerm("Nat", "f", (fb,))

    terms = [a, b, c, fa, fb, fc, ga, gb, ffa, ffb]

    print("\n1. Terms:")
    for t in terms:
        print(f"   {t} : {t.sort}")

    # Rewrite edges: a ≡ b (e.g., from rule a → b)
    edges = [(a, b)]
    print(f"\n2. Rewrite edges: {[(str(l), str(r)) for l, r in edges]}")

    # Run congruence closure
    result = incremental_congruence_closure(terms, edges)

    print(f"\n3. Congruence closure result:")
    print(f"   Merges: {result.num_merges}")
    print(f"   Congruence checks: {result.num_congruence_checks}")
    print(f"   Merge log:")
    for t1, t2, reason in result.merge_log:
        print(f"     {t1} ≡ {t2}  [{reason}]")

    print(f"\n4. Equivalence classes:")
    for rep, members in result.partition.items():
        members_str = ", ".join(str(m) for m in sorted(members, key=str))
        print(f"   [{members_str}]")

    # Normal forms
    rules = [(a, b)]  # a → b
    nf_map = compute_all_normal_forms(terms, rules)
    print(f"\n5. Normal forms:")
    for t in terms:
        if nf_map[t] != t:
            print(f"   nf({t}) = {nf_map[t]}")

    # Compare partitions
    nf_part = nf_partition(terms, nf_map)
    agree, disagreements = partitions_agree(terms, result.partition, nf_part)
    print(f"\n6. Partition agreement: {agree}")
    if not agree:
        for t1, t2, desc in disagreements:
            print(f"   Disagreement: {t1}, {t2}: {desc}")

    # Candidate tuple bound
    arities = [1, 1]  # f and g are unary
    exact, bound = candidate_tuple_bound(2, arities, len(terms))
    print(f"\n7. Candidate tuple bound:")
    print(f"   Exact: {exact}, Bound: {bound}, Ratio: {exact/bound:.3f}")


if __name__ == "__main__":
    example()
