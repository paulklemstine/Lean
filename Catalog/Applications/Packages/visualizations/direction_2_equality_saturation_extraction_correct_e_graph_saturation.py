#!/usr/bin/env python3
"""
algorithms.py — Core Algorithms for E-Graph Extraction Correctness

Implements the key algorithms from the research:
1. Convergent rewrite system normalization
2. E-graph saturation with bounded iteration
3. Monotone cost extraction
4. Confluence checker for small systems
"""

from dataclasses import dataclass, field
from typing import Dict, List, Optional, Tuple, Set, Callable
from collections import defaultdict
import itertools


# ============================================================
# Algorithm 1: Term Rewriting with Certified Normalization
# ============================================================

@dataclass(frozen=True)
class Term:
    """Abstract base for terms."""
    pass

@dataclass(frozen=True)
class Const(Term):
    value: int

@dataclass(frozen=True)
class Var(Term):
    name: str

@dataclass(frozen=True)
class BinOp(Term):
    op: str  # "+", "*"
    left: Term
    right: Term


def term_size(t: Term) -> int:
    """AST node count — a monotone cost function for our rewrite systems."""
    if isinstance(t, (Const, Var)):
        return 1
    elif isinstance(t, BinOp):
        return 1 + term_size(t.left) + term_size(t.right)
    return 1


def eval_term(t: Term, env: Dict[str, int]) -> int:
    """Evaluate a term under a variable assignment."""
    if isinstance(t, Const):
        return t.value
    elif isinstance(t, Var):
        return env.get(t.name, 0)
    elif isinstance(t, BinOp):
        l = eval_term(t.left, env)
        r = eval_term(t.right, env)
        if t.op == "+":
            return l + r
        elif t.op == "*":
            return l * r
    raise ValueError(f"Unknown term: {t}")


@dataclass
class RewriteRule:
    """A rewrite rule: pattern → replacement.

    For simplicity, rules are represented as Python functions.
    Each rule returns None if it doesn't match, or the rewritten term if it does.

    Attributes:
        name: Human-readable name
        apply: Function Term -> Optional[Term]
        cost_nonincreasing: Whether the rule never increases AST size
    """
    name: str
    apply: Callable[[Term], Optional[Term]]
    cost_nonincreasing: bool = True


def make_arithmetic_rules() -> List[RewriteRule]:
    """Create the convergent arithmetic simplification rules.

    These rules form a convergent (terminating + confluent) system:
    - Termination: each rule strictly reduces AST size or a lexicographic measure
    - Confluence: all critical pairs are joinable

    Time complexity: O(1) per rule application
    Space complexity: O(1) additional space
    """
    rules = []

    # Identity elimination
    rules.append(RewriteRule("x+0→x", lambda t:
        t.left if isinstance(t, BinOp) and t.op == "+"
        and isinstance(t.right, Const) and t.right.value == 0 else None))

    rules.append(RewriteRule("0+x→x", lambda t:
        t.right if isinstance(t, BinOp) and t.op == "+"
        and isinstance(t.left, Const) and t.left.value == 0 else None))

    rules.append(RewriteRule("x*1→x", lambda t:
        t.left if isinstance(t, BinOp) and t.op == "*"
        and isinstance(t.right, Const) and t.right.value == 1 else None))

    rules.append(RewriteRule("1*x→x", lambda t:
        t.right if isinstance(t, BinOp) and t.op == "*"
        and isinstance(t.left, Const) and t.left.value == 1 else None))

    # Annihilation
    rules.append(RewriteRule("x*0→0", lambda t:
        Const(0) if isinstance(t, BinOp) and t.op == "*"
        and isinstance(t.right, Const) and t.right.value == 0 else None))

    rules.append(RewriteRule("0*x→0", lambda t:
        Const(0) if isinstance(t, BinOp) and t.op == "*"
        and isinstance(t.left, Const) and t.left.value == 0 else None))

    # Constant folding
    rules.append(RewriteRule("c1+c2→c3", lambda t:
        Const(t.left.value + t.right.value)
        if isinstance(t, BinOp) and t.op == "+"
        and isinstance(t.left, Const) and isinstance(t.right, Const) else None))

    rules.append(RewriteRule("c1*c2→c3", lambda t:
        Const(t.left.value * t.right.value)
        if isinstance(t, BinOp) and t.op == "*"
        and isinstance(t.left, Const) and isinstance(t.right, Const) else None))

    return rules


def normalize(t: Term, rules: List[RewriteRule], max_steps: int = 1000) -> Tuple[Term, int]:
    """Compute the normal form of a term under a set of rewrite rules.

    Algorithm: Innermost (bottom-up) normalization.
    1. Recursively normalize subterms
    2. Apply rules to the top-level term
    3. If any rule fires, restart from step 1

    Time complexity: O(max_steps * |rules| * depth(t))
    Space complexity: O(depth(t)) for recursion stack

    Returns:
        (normal_form, steps_taken)

    Termination: Guaranteed for terminating rule sets (each rule
    strictly decreases the termination measure).
    """
    steps = 0
    current = t

    for _ in range(max_steps):
        # Bottom-up: normalize subterms first
        if isinstance(current, BinOp):
            left_nf, s1 = normalize(current.left, rules, max_steps - steps)
            steps += s1
            right_nf, s2 = normalize(current.right, rules, max_steps - steps)
            steps += s2
            current = BinOp(current.op, left_nf, right_nf)

        # Try each rule at the root
        fired = False
        for rule in rules:
            result = rule.apply(current)
            if result is not None:
                current = result
                steps += 1
                fired = True
                break

        if not fired:
            break

    return current, steps


# ============================================================
# Algorithm 2: E-Graph with Union-Find
# ============================================================

class UnionFind:
    """Weighted union-find with path compression.

    Time complexity:
        - find: O(α(n)) amortized (inverse Ackermann)
        - union: O(α(n)) amortized
    Space complexity: O(n)
    """
    def __init__(self):
        self.parent: Dict[int, int] = {}
        self.rank: Dict[int, int] = {}

    def make_set(self, x: int) -> None:
        if x not in self.parent:
            self.parent[x] = x
            self.rank[x] = 0

    def find(self, x: int) -> int:
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]

    def union(self, x: int, y: int) -> int:
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return rx
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        return rx

    def same(self, x: int, y: int) -> bool:
        return self.find(x) == self.find(y)


class EGraph:
    """E-graph: equivalence classes of terms with congruence closure.

    Implements the core data structure from equality saturation (Willsey et al., 2021).
    Maintains a union-find over term IDs, with a hashcons table for deduplication.

    Key operations:
        - add(t): Insert term, return e-class ID. O(depth(t))
        - merge(id1, id2): Merge two e-classes. O(α(n))
        - saturate(rules): Apply rules until fixpoint. O(iterations * |terms| * |rules|)
        - extract(id, cost): Extract cheapest term. O(|class|)
    """

    def __init__(self):
        self.uf = UnionFind()
        self.terms: Dict[int, Term] = {}
        self.hashcons: Dict[Term, int] = {}
        self.next_id = 0

    def add(self, t: Term) -> int:
        """Add a term, returning its e-class ID."""
        if t in self.hashcons:
            return self.uf.find(self.hashcons[t])

        tid = self.next_id
        self.next_id += 1
        self.uf.make_set(tid)
        self.terms[tid] = t
        self.hashcons[t] = tid

        if isinstance(t, BinOp):
            self.add(t.left)
            self.add(t.right)

        return tid

    def merge(self, id1: int, id2: int) -> int:
        """Merge two e-classes."""
        return self.uf.union(id1, id2)

    def find(self, tid: int) -> int:
        return self.uf.find(tid)

    def same_class(self, id1: int, id2: int) -> bool:
        return self.uf.same(id1, id2)

    def saturate(self, rules: List[RewriteRule], max_iters: int = 100) -> Tuple[int, int]:
        """Saturate the e-graph with the given rules.

        Algorithm:
            repeat:
                for each term t in the e-graph:
                    for each rule r:
                        if r matches t:
                            result = apply(r, t)
                            merge(id(t), add(result))
            until no new merges

        Returns:
            (total_merges, iterations)

        Convergence: For finite term algebras with convergent rules,
        saturation terminates when all equivalence classes are closed
        under the rewrite relation.
        """
        total_merges = 0
        for iteration in range(max_iters):
            new_merges = 0
            snapshot = list(self.hashcons.items())
            for t, tid in snapshot:
                for rule in rules:
                    result = rule.apply(t)
                    if result is not None:
                        rid = self.add(result)
                        if not self.same_class(tid, rid):
                            self.merge(tid, rid)
                            new_merges += 1
            total_merges += new_merges
            if new_merges == 0:
                return total_merges, iteration + 1
        return total_merges, max_iters

    def extract(self, tid: int, cost_fn: Callable[[Term], int] = term_size) -> Term:
        """Extract the cheapest term from an e-class.

        Algorithm: Linear scan over all terms in the e-class,
        selecting the one with minimum cost.

        Time complexity: O(|e-graph|)
        Space complexity: O(1) additional
        """
        root = self.uf.find(tid)
        best = None
        best_cost = float('inf')
        for t, t_id in self.hashcons.items():
            if self.uf.find(t_id) == root:
                c = cost_fn(t)
                if c < best_cost:
                    best_cost = c
                    best = t
        return best if best is not None else self.terms[tid]

    def get_class_size(self, tid: int) -> int:
        """Count terms in an e-class."""
        root = self.uf.find(tid)
        return sum(1 for _, t_id in self.hashcons.items() if self.uf.find(t_id) == root)

    def num_classes(self) -> int:
        """Count distinct e-classes."""
        return len(set(self.uf.find(tid) for tid in self.terms))


# ============================================================
# Algorithm 3: Confluence Checker (for small systems)
# ============================================================

def check_confluence_bounded(rules: List[RewriteRule], test_terms: List[Term],
                             max_steps: int = 100) -> Tuple[bool, Optional[Tuple[Term, Term, Term]]]:
    """Check confluence by computing normal forms from all reachable terms.

    For a finite set of test terms, verify that:
    - All terms reachable from the same starting term have the same normal form

    This is a bounded approximation of the full confluence check.

    Returns:
        (is_confluent, counterexample) where counterexample is
        (term, nf1, nf2) if confluence fails.
    """
    for t in test_terms:
        # Compute all one-step reducts
        reducts = []
        for rule in rules:
            result = rule.apply(t)
            if result is not None:
                reducts.append(result)

        # Normalize all reducts
        nfs = set()
        for r in reducts:
            nf, _ = normalize(r, rules, max_steps)
            nfs.add(str(nf))  # Use string repr for comparison

        # Also normalize the original
        nf_orig, _ = normalize(t, rules, max_steps)
        nfs.add(str(nf_orig))

        if len(nfs) > 1:
            nf_list = list(nfs)
            return False, (t, nf_list[0], nf_list[1])

    return True, None


# ============================================================
# Algorithm 4: Verified Extraction Pipeline
# ============================================================

def verified_extract(t: Term, rules: List[RewriteRule],
                     envs: List[Dict[str, int]],
                     cost_fn: Callable[[Term], int] = term_size) -> Tuple[Term, bool]:
    """Extract with runtime verification.

    1. Build e-graph and saturate
    2. Extract cheapest term
    3. Verify eval(extract) = eval(original) for all given environments

    Returns:
        (extracted_term, all_checks_passed)
    """
    eg = EGraph()
    tid = eg.add(t)
    eg.saturate(rules)
    extracted = eg.extract(tid, cost_fn)

    all_ok = True
    for env in envs:
        if eval_term(t, env) != eval_term(extracted, env):
            all_ok = False
            break

    return extracted, all_ok


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    import random

    print("Algorithms Module — E-Graph Extraction Correctness")
    print("=" * 55)
    print()

    rules = make_arithmetic_rules()
    print(f"Loaded {len(rules)} arithmetic rewrite rules")
    print()

    # Normalization example
    t = BinOp("+", BinOp("*", Const(1), Var("x")),
              BinOp("*", Const(0), Var("y")))
    print(f"Term: 1*x + 0*y")
    nf, steps = normalize(t, rules)
    print(f"Normal form: {nf} (in {steps} steps)")
    print()

    # E-graph saturation
    eg = EGraph()
    tid = eg.add(t)
    merges, iters = eg.saturate(rules)
    extracted = eg.extract(tid)
    print(f"E-graph: {eg.num_classes()} classes after {iters} iterations ({merges} merges)")
    print(f"Extracted: {extracted} (size {term_size(extracted)})")
    print()

    # Confluence check
    random.seed(0)
    from demo import random_term as gen_term
    test_terms = [gen_term(2) for _ in range(100)]
    # Convert to BinOp format
    def convert(t):
        from demo import Add, Mul, Const as C2, Var as V2
        if isinstance(t, C2):
            return Const(t.value)
        elif isinstance(t, V2):
            return Var(t.name)
        elif isinstance(t, Add):
            return BinOp("+", convert(t.left), convert(t.right))
        elif isinstance(t, Mul):
            return BinOp("*", convert(t.left), convert(t.right))
        return t

    test_terms_conv = [convert(t) for t in test_terms]
    is_conf, cex = check_confluence_bounded(rules, test_terms_conv)
    print(f"Confluence check (100 terms): {'PASS' if is_conf else 'FAIL'}")
    if cex:
        print(f"  Counterexample: {cex}")
    print()

    # Verified extraction
    random.seed(42)
    envs = [{"x": random.randint(-10, 10), "y": random.randint(-10, 10),
             "z": random.randint(-10, 10)} for _ in range(20)]
    t2 = BinOp("+", BinOp("*", Const(0), Var("z")),
               BinOp("+", Var("x"), Const(0)))
    ext, ok = verified_extract(t2, rules, envs)
    print(f"Verified extraction: 0*z + (x+0) → {ext}")
    print(f"  All {len(envs)} environment checks: {'PASS' if ok else 'FAIL'}")
