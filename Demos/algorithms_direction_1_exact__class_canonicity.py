#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for β-class structural canonicity.

Implements:
1. Partition refinement for bisimulation quotient computation
2. Canonical labeling for LTS isomorphism checking
3. Nerode index computation and stabilization detection
4. Canonical representative extraction
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Optional
from collections import defaultdict


# ─── Lambda Calculus Core ──────────────────────────────────────────────────

@dataclass(frozen=True)
class Var:
    name: int
    def __repr__(self): return f"x{self.name}"
    def size(self): return 1
    def free_vars(self): return {self.name}

@dataclass(frozen=True)
class Lam:
    var: int
    body: 'Term'
    def __repr__(self): return f"(λx{self.var}. {self.body})"
    def size(self): return 1 + self.body.size()
    def free_vars(self): return self.body.free_vars() - {self.var}

@dataclass(frozen=True)
class App:
    fun: 'Term'
    arg: 'Term'
    def __repr__(self): return f"({self.fun} {self.arg})"
    def size(self): return 1 + self.fun.size() + self.arg.size()
    def free_vars(self): return self.fun.free_vars() | self.arg.free_vars()

Term = Var | Lam | App


def subst(t: Term, x: int, s: Term) -> Term:
    if isinstance(t, Var):
        return s if t.name == x else t
    elif isinstance(t, Lam):
        return t if t.var == x else Lam(t.var, subst(t.body, x, s))
    elif isinstance(t, App):
        return App(subst(t.fun, x, s), subst(t.arg, x, s))


def is_normal_form(t: Term) -> bool:
    if isinstance(t, Var):
        return True
    elif isinstance(t, Lam):
        return is_normal_form(t.body)
    elif isinstance(t, App):
        if isinstance(t.fun, Lam):
            return False
        return is_normal_form(t.fun) and is_normal_form(t.arg)


def beta_reduce_one(t: Term) -> list[Term]:
    """All possible one-step β-reducts of t."""
    results = []
    if isinstance(t, Var):
        pass
    elif isinstance(t, Lam):
        for b in beta_reduce_one(t.body):
            results.append(Lam(t.var, b))
    elif isinstance(t, App):
        if isinstance(t.fun, Lam):
            results.append(subst(t.fun.body, t.fun.var, t.arg))
        for f in beta_reduce_one(t.fun):
            results.append(App(f, t.arg))
        for a in beta_reduce_one(t.arg):
            results.append(App(t.fun, a))
    return results


def normalize(t: Term, max_steps: int = 1000) -> Optional[Term]:
    for _ in range(max_steps):
        if is_normal_form(t):
            return t
        reducts = beta_reduce_one(t)
        if not reducts:
            return t
        t = reducts[0]
    return None


# ─── Algorithm 1: Partition Refinement ─────────────────────────────────────

def partition_refinement(states: set, transitions: set) -> dict[str, int]:
    """
    Compute bisimulation quotient via partition refinement.

    Algorithm (Paige-Tarjan style):
    1. Start with all states in one block.
    2. Iteratively split blocks: two states remain in the same block
       iff they have successors in the same set of blocks.
    3. Repeat until stable.

    Complexity: O(n * m * log n) where n = |states|, m = |transitions|.

    Args:
        states: Set of state identifiers
        transitions: Set of (source, target) pairs

    Returns:
        Mapping from states to equivalence class indices
    """
    successors = defaultdict(set)
    for s, t in transitions:
        successors[s].add(t)

    partition = {s: 0 for s in states}
    prev_num_classes = 0

    while True:
        num_classes = len(set(partition.values()))
        if num_classes == prev_num_classes:
            break
        prev_num_classes = num_classes

        new_partition = {}
        signatures = {}
        next_id = 0

        for s in states:
            sig = frozenset(partition[t] for t in successors[s])
            key = (partition[s], sig)
            if key not in signatures:
                signatures[key] = next_id
                next_id += 1
            new_partition[s] = signatures[key]

        partition = new_partition

    return partition


# ─── Algorithm 2: Canonical Labeling ───────────────────────────────────────

def canonical_labeling(
    num_states: int,
    transitions: frozenset[tuple[int, int]],
    init: int
) -> tuple[int, frozenset[tuple[int, int]], int]:
    """
    Compute a canonical form for an LTS via BFS-based labeling.

    This is a simplified version of the nauty algorithm for graph
    isomorphism. It assigns canonical labels to states via BFS
    from the initial state, breaking ties by sorted successor lists.

    Complexity: O(n log n + m) where n = states, m = transitions.

    Args:
        num_states: Number of states
        transitions: Set of (source, target) transitions
        init: Initial state index

    Returns:
        Canonical triple (num_states, canonical_transitions, canonical_init)
    """
    adj = defaultdict(list)
    for s, t in transitions:
        adj[s].append(t)
    for s in adj:
        adj[s].sort()

    # BFS from init
    labels = {}
    queue = [init]
    next_label = 0

    while queue:
        s = queue.pop(0)
        if s in labels:
            continue
        labels[s] = next_label
        next_label += 1
        for t in adj[s]:
            if t not in labels:
                queue.append(t)

    # Assign labels to unreachable states
    for s in range(num_states):
        if s not in labels:
            labels[s] = next_label
            next_label += 1

    canon_trans = frozenset(
        (labels[s], labels[t]) for s, t in transitions
        if s in labels and t in labels
    )
    return (num_states, canon_trans, labels.get(init, 0))


# ─── Algorithm 3: LTS Isomorphism Check ───────────────────────────────────

def check_lts_isomorphism(fts1_data: dict, fts2_data: dict) -> bool:
    """
    Check if two FTS have isomorphic bisimulation quotients.

    Algorithm:
    1. Compute bisimulation quotient of each FTS via partition refinement.
    2. Compute canonical labeling of each quotient.
    3. Compare canonical forms for equality.

    Complexity: O((n₁ + n₂) * (m₁ + m₂) * log(max(n₁, n₂)))

    Args:
        fts1_data: dict with 'states', 'transitions', 'init'
        fts2_data: dict with 'states', 'transitions', 'init'

    Returns:
        True iff the bisimulation quotients are isomorphic
    """
    # Compute quotients
    q1 = partition_refinement(fts1_data['states'], fts1_data['transitions'])
    q2 = partition_refinement(fts2_data['states'], fts2_data['transitions'])

    n1 = len(set(q1.values()))
    n2 = len(set(q2.values()))
    if n1 != n2:
        return False

    # Compute quotient transitions
    def quotient_transitions(partition, transitions, init):
        q_trans = set()
        for s, t in transitions:
            q_trans.add((partition[s], partition[t]))
        return (len(set(partition.values())),
                frozenset(q_trans),
                partition[init])

    qt1 = quotient_transitions(q1, fts1_data['transitions'], fts1_data['init'])
    qt2 = quotient_transitions(q2, fts2_data['transitions'], fts2_data['init'])

    # Canonical labeling
    c1 = canonical_labeling(*qt1)
    c2 = canonical_labeling(*qt2)

    return c1 == c2


# ─── Algorithm 4: Nerode Index Computation ─────────────────────────────────

def compute_nerode_index(t: Term, depth: int) -> int:
    """
    Compute the Nerode index of term t at depth d.

    This is the number of distinct bisimulation equivalence classes
    among states reachable within d β-reduction steps.

    Complexity: O(d * B^d * (d * B^d) * log(d * B^d))
    where B is the max branching factor.

    Args:
        t: Lambda term
        depth: Maximum reduction depth

    Returns:
        Number of bisimulation equivalence classes
    """
    # Build FTS
    states = set()
    transitions = set()
    queue = [(t, 0)]
    visited = set()

    while queue:
        term, d = queue.pop(0)
        key = repr(term)
        if key in visited or d > depth:
            continue
        visited.add(key)
        states.add(key)
        if d < depth:
            for reduct in beta_reduce_one(term):
                rkey = repr(reduct)
                states.add(rkey)
                transitions.add((key, rkey))
                queue.append((reduct, d + 1))

    # Compute quotient
    partition = partition_refinement(states, transitions)
    return len(set(partition.values()))


def detect_stabilization(t: Term, max_depth: int = 20) -> tuple[int, list[int]]:
    """
    Detect the stabilization depth of the Nerode index.

    Returns:
        (stabilization_depth, index_sequence)
    """
    indices = []
    for d in range(max_depth):
        idx = compute_nerode_index(t, d)
        indices.append(idx)

        # Check for stabilization (3 consecutive equal values)
        if len(indices) >= 3 and indices[-1] == indices[-2] == indices[-3]:
            return (d - 2, indices)

    return (max_depth, indices)


# ─── Algorithm 5: Canonical Representative ─────────────────────────────────

def canonical_representative(t: Term) -> Term:
    """
    Compute the canonical representative of the β-equivalence class of t.

    Algorithm: Normalize t to its unique β-normal form. By Church-Rosser
    and strong normalization (for simply typed terms), this is the unique
    canonical representative satisfying:
      BetaEq(t, canonical_representative(t))
      BetaEq(t, u) ⟹ canonical_representative(t) = canonical_representative(u)

    Complexity: O(reduction_length * term_size) amortized.
    May not terminate for untyped terms without normal forms.

    Args:
        t: A lambda term (should be strongly normalizing)

    Returns:
        The β-normal form of t
    """
    result = normalize(t)
    if result is None:
        raise ValueError(f"Term {t} does not appear to have a normal form")
    return result


# ─── Example Usage ─────────────────────────────────────────────────────────

if __name__ == "__main__":
    I = Lam(0, Var(0))
    K = Lam(0, Lam(1, Var(0)))
    S = Lam(0, Lam(1, Lam(2, App(App(Var(0), Var(2)), App(Var(1), Var(2))))))
    SKK = App(App(S, K), K)
    II = App(I, I)

    print("=== Canonical Representatives ===")
    for name, t in [("I", I), ("II", II), ("SKK", SKK)]:
        cr = canonical_representative(t)
        print(f"  canonical_representative({name}) = {cr}")

    print()
    print("=== Nerode Index Stabilization ===")
    for name, t in [("I", I), ("II", II), ("SKK", SKK)]:
        depth, indices = detect_stabilization(t, max_depth=10)
        print(f"  {name}: stabilizes at depth {depth}")
        print(f"    indices = {indices}")

    print()
    print("=== Isomorphism Check ===")
    for d in range(5):
        states1, trans1 = set(), set()
        states2, trans2 = set(), set()

        # Build FTS for I at depth d
        q = [(I, 0)]
        v = set()
        while q:
            term, dd = q.pop(0)
            k = repr(term)
            if k in v or dd > d: continue
            v.add(k)
            states1.add(k)
            if dd < d:
                for r in beta_reduce_one(term):
                    rk = repr(r)
                    states1.add(rk)
                    trans1.add((k, rk))
                    q.append((r, dd + 1))

        # Build FTS for II at depth d
        q = [(II, 0)]
        v = set()
        while q:
            term, dd = q.pop(0)
            k = repr(term)
            if k in v or dd > d: continue
            v.add(k)
            states2.add(k)
            if dd < d:
                for r in beta_reduce_one(term):
                    rk = repr(r)
                    states2.add(rk)
                    trans2.add((k, rk))
                    q.append((r, dd + 1))

        iso = check_lts_isomorphism(
            {'states': states1, 'transitions': trans1, 'init': repr(I)},
            {'states': states2, 'transitions': trans2, 'init': repr(II)}
        )
        print(f"  depth {d}: I ≅ II ? {iso}")
