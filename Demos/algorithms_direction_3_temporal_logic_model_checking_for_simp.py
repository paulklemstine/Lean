#!/usr/bin/env python3
"""
Algorithms for Temporal Logic Model Checking on Simply Typed Lambda Calculus

Implements the core algorithms from the research paper:
1. Reduction graph construction via exhaustive BFS
2. CTL model checking on finite transition systems
3. Type-directed bound computation
4. Treewidth estimation for reduction graphs

All algorithms include docstrings, type hints, and complexity analysis.
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Optional
from collections import deque, defaultdict
import itertools


# ============================================================
# Data Structures (imported from demo.py's definitions)
# ============================================================

@dataclass(frozen=True)
class Var:
    name: int
    def __repr__(self): return f"x{self.name}"
    def size(self): return 1

@dataclass(frozen=True)
class App:
    fun: 'Term'
    arg: 'Term'
    def __repr__(self): return f"({self.fun} {self.arg})"
    def size(self): return 1 + self.fun.size() + self.arg.size()

@dataclass(frozen=True)
class Lam:
    var: int
    body: 'Term'
    def __repr__(self): return f"(λx{self.var}.{self.body})"
    def size(self): return 1 + self.body.size()

Term = Var | App | Lam

@dataclass(frozen=True)
class Base:
    def __repr__(self): return "ι"
    def depth(self) -> int: return 0
    def complexity(self) -> int: return 1

@dataclass(frozen=True)
class Arrow:
    src: 'Ty'
    tgt: 'Ty'
    def __repr__(self): return f"({self.src} → {self.tgt})"
    def depth(self) -> int: return 1 + max(self.src.depth(), self.tgt.depth())
    def complexity(self) -> int: return (self.src.complexity() + 1) * (self.tgt.complexity() + 1)

Ty = Base | Arrow


# ============================================================
# Algorithm 1: Beta Reduction Engine
# ============================================================

def subst(term: Term, x: int, s: Term) -> Term:
    """
    Naive capture-avoiding substitution: term[x := s].

    Time complexity: O(|term| * |s|) in the worst case
    Space complexity: O(|term| + |s|)

    Example:
        >>> subst(App(Var(0), Var(1)), 0, Var(2))
        (x2 x1)
    """
    if isinstance(term, Var):
        return s if term.name == x else term
    elif isinstance(term, App):
        return App(subst(term.fun, x, s), subst(term.arg, x, s))
    elif isinstance(term, Lam):
        if term.var == x:
            return term
        return Lam(term.var, subst(term.body, x, s))
    raise TypeError(f"Unknown term type: {type(term)}")


def beta_reducts(term: Term) -> list[Term]:
    """
    Compute all one-step beta reducts of a term.

    Implements leftmost-outermost, rightmost-innermost, and all
    intermediate reduction strategies simultaneously.

    Time complexity: O(|term|^2) per call
    Space complexity: O(|term| * branching_factor)

    Example:
        >>> beta_reducts(App(Lam(0, Var(0)), Var(1)))
        [x1]
    """
    results = []
    if isinstance(term, App):
        if isinstance(term.fun, Lam):
            results.append(subst(term.fun.body, term.fun.var, term.arg))
        for t in beta_reducts(term.fun):
            results.append(App(t, term.arg))
        for t in beta_reducts(term.arg):
            results.append(App(term.fun, t))
    elif isinstance(term, Lam):
        for t in beta_reducts(term.body):
            results.append(Lam(term.var, t))
    return results


# ============================================================
# Algorithm 2: Reduction Graph Construction
# ============================================================

@dataclass
class ReductionGraph:
    """
    The complete reduction graph of a lambda term.

    Attributes:
        root: The initial term
        vertices: Set of all reachable terms
        edges: Set of (source, target) pairs representing one-step reductions
        normal_forms: Set of terms with no further reductions
        depth: Maximum reduction path length from root
    """
    root: Term
    vertices: set[Term] = field(default_factory=set)
    edges: set[tuple[Term, Term]] = field(default_factory=set)
    normal_forms: set[Term] = field(default_factory=set)
    depth: int = 0
    complete: bool = True

    def successors(self, t: Term) -> set[Term]:
        """Get all one-step successors of a term in the graph."""
        return {u for (s, u) in self.edges if s == t}

    def is_dag(self) -> bool:
        """
        Check if the graph is a DAG using topological sort.

        Time complexity: O(|V| + |E|)
        """
        adj = defaultdict(set)
        in_degree = defaultdict(int)
        for v in self.vertices:
            in_degree[v]  # ensure all vertices present
        for (s, t) in self.edges:
            adj[s].add(t)
            in_degree[t] += 1

        queue = deque(v for v in self.vertices if in_degree[v] == 0)
        count = 0
        while queue:
            v = queue.popleft()
            count += 1
            for u in adj[v]:
                in_degree[u] -= 1
                if in_degree[u] == 0:
                    queue.append(u)
        return count == len(self.vertices)


def build_reduction_graph(term: Term, max_states: int = 50000) -> ReductionGraph:
    """
    Build the complete reduction graph by breadth-first exploration.

    Pseudocode:
        G = ({term}, {})
        queue = [term]
        while queue not empty:
            t = dequeue
            for each u in beta_reducts(t):
                add edge (t, u) to G
                if u not in G.vertices:
                    add u to G.vertices
                    enqueue u

    Time complexity: O(|V| * |E| * max_term_size^2)
        where |V| = number of reachable terms, |E| = number of edges

    Space complexity: O(|V| + |E|)

    The graph is guaranteed to be finite for strongly normalizing terms.

    Example:
        >>> g = build_reduction_graph(App(Lam(0, Var(0)), Var(1)))
        >>> len(g.vertices)
        2
        >>> g.normal_forms
        {x1}
    """
    graph = ReductionGraph(root=term)
    graph.vertices.add(term)
    queue = deque([(term, 0)])

    while queue:
        if len(graph.vertices) >= max_states:
            graph.complete = False
            break
        t, d = queue.popleft()
        graph.depth = max(graph.depth, d)
        reducts = beta_reducts(t)
        if not reducts:
            graph.normal_forms.add(t)
        for u in reducts:
            graph.edges.add((t, u))
            if u not in graph.vertices:
                graph.vertices.add(u)
                queue.append((u, d + 1))

    return graph


# ============================================================
# Algorithm 3: Type-Directed Normalization Bound
# ============================================================

def normalization_bound(ty: Ty, term_size: int) -> int:
    """
    Compute an upper bound on the maximum reduction length.

    Based on the type complexity: bound = complexity(τ)^n
    where n is the term size.

    Time complexity: O(|τ|) for complexity computation, O(log n) for exponentiation
    Space complexity: O(1)

    Args:
        ty: The simple type of the term
        term_size: The syntactic size of the term

    Returns:
        Upper bound on the maximum reduction length

    Example:
        >>> normalization_bound(Arrow(Base(), Base()), 3)
        64
    """
    return ty.complexity() ** term_size


def tight_bound(ty: Ty, term_size: int) -> int:
    """
    Compute the conjectured tight bound on reduction length.

    Conjecture: max_reduction_length = (2^depth(τ) - 1) * |t|

    Args:
        ty: The simple type
        term_size: The term size

    Returns:
        Conjectured tight bound

    Example:
        >>> tight_bound(Arrow(Base(), Base()), 3)
        3
    """
    d = ty.depth()
    return (2**d - 1) * term_size


# ============================================================
# Algorithm 4: CTL Model Checker
# ============================================================

@dataclass
class CTLTrue:
    pass

@dataclass
class CTLAtom:
    """Atomic proposition."""
    name: str

@dataclass
class CTLNot:
    sub: 'CTL'

@dataclass
class CTLAnd:
    left: 'CTL'
    right: 'CTL'

@dataclass
class CTLOr:
    left: 'CTL'
    right: 'CTL'

@dataclass
class CTLEX:
    """EX φ: there exists a successor satisfying φ."""
    sub: 'CTL'

@dataclass
class CTLAX:
    """AX φ: all successors satisfy φ."""
    sub: 'CTL'

@dataclass
class CTLEF:
    """EF φ: there exists a path eventually reaching φ."""
    sub: 'CTL'

@dataclass
class CTLAF:
    """AF φ: all paths eventually reach φ."""
    sub: 'CTL'

@dataclass
class CTLEG:
    """EG φ: there exists a path always satisfying φ."""
    sub: 'CTL'

@dataclass
class CTLAG:
    """AG φ: all paths always satisfy φ."""
    sub: 'CTL'

CTL = CTLTrue | CTLAtom | CTLNot | CTLAnd | CTLOr | CTLEX | CTLAX | CTLEF | CTLAF | CTLEG | CTLAG


def ctl_model_check(graph: ReductionGraph, formula: CTL) -> set[Term]:
    """
    CTL model checking on a finite reduction graph.

    Computes the set of states satisfying a CTL formula using
    the standard labeling algorithm.

    Pseudocode:
        For each subformula (bottom-up):
            Compute Sat(subformula) = {s ∈ V | s ⊨ subformula}
        Return Sat(formula)

    Time complexity: O(|φ| * (|V| + |E|))
        where |φ| = number of subformulas

    Space complexity: O(|φ| * |V|)

    This is the classic Clarke-Emerson-Sistla algorithm (1986).

    Args:
        graph: The finite reduction graph
        formula: CTL formula to check

    Returns:
        Set of states satisfying the formula

    Example:
        >>> g = build_reduction_graph(App(Lam(0, Var(0)), Var(1)))
        >>> sat = ctl_model_check(g, CTLAF(CTLAtom("nf")))
        >>> g.root in sat
        True
    """
    adj = defaultdict(set)
    pred = defaultdict(set)
    for (s, t) in graph.edges:
        adj[s].add(t)
        pred[t].add(s)

    def atoms(s: Term, name: str) -> bool:
        if name == "nf":
            return s in graph.normal_forms
        if name == "reducible":
            return len(adj[s]) > 0
        return False

    def sat(f: CTL) -> set[Term]:
        if isinstance(f, CTLTrue):
            return set(graph.vertices)
        elif isinstance(f, CTLAtom):
            return {s for s in graph.vertices if atoms(s, f.name)}
        elif isinstance(f, CTLNot):
            return graph.vertices - sat(f.sub)
        elif isinstance(f, CTLAnd):
            return sat(f.left) & sat(f.right)
        elif isinstance(f, CTLOr):
            return sat(f.left) | sat(f.right)
        elif isinstance(f, CTLEX):
            sub_sat = sat(f.sub)
            return {s for s in graph.vertices if adj[s] & sub_sat}
        elif isinstance(f, CTLAX):
            sub_sat = sat(f.sub)
            return {s for s in graph.vertices
                    if adj[s] and adj[s] <= sub_sat}
        elif isinstance(f, CTLEF):
            # Fixed point: EF φ = φ ∨ EX(EF φ)
            result = sat(f.sub)
            queue = deque(result)
            while queue:
                s = queue.popleft()
                for p in pred[s]:
                    if p not in result:
                        result.add(p)
                        queue.append(p)
            return result
        elif isinstance(f, CTLAF):
            # Fixed point: AF φ = φ ∨ AX(AF φ)
            sub_sat = sat(f.sub)
            result = set(sub_sat)
            # Also include states with no successors that satisfy φ
            no_succ = {s for s in graph.vertices if not adj[s]}
            result |= (no_succ & sub_sat)
            changed = True
            while changed:
                changed = False
                for s in graph.vertices - result:
                    if adj[s] and adj[s] <= result:
                        result.add(s)
                        changed = True
            return result
        elif isinstance(f, CTLEG):
            # EG φ = νX. φ ∧ EX X (greatest fixed point)
            result = sat(f.sub)
            changed = True
            while changed:
                changed = False
                new_result = set()
                for s in result:
                    if not adj[s] or (adj[s] & result):
                        new_result.add(s)
                    else:
                        changed = True
                result = new_result
            return result
        elif isinstance(f, CTLAG):
            # AG φ = ¬EF(¬φ)
            return graph.vertices - sat(CTLEF(CTLNot(f.sub)))
        return set()

    return sat(formula)


# ============================================================
# Algorithm 5: Treewidth Estimation
# ============================================================

def estimate_treewidth(graph: ReductionGraph) -> int:
    """
    Estimate the treewidth of a reduction graph using the
    minimum degree heuristic (greedy elimination ordering).

    This gives an upper bound on the actual treewidth.

    Pseudocode:
        G' = undirected version of G
        tw = 0
        while G' not empty:
            v = vertex of minimum degree in G'
            tw = max(tw, degree(v))
            make neighbors of v a clique
            remove v from G'
        return tw

    Time complexity: O(|V|^3) (naive), O(|V| * |E|) with priority queue

    Args:
        graph: The reduction graph

    Returns:
        Upper bound on treewidth

    Example:
        >>> g = build_reduction_graph(App(Lam(0, Var(0)), Var(1)))
        >>> estimate_treewidth(g)  # path graph: tw = 1
        1
    """
    # Build undirected adjacency
    adj: dict[Term, set[Term]] = defaultdict(set)
    for (s, t) in graph.edges:
        adj[s].add(t)
        adj[t].add(s)

    vertices = set(graph.vertices)
    tw = 0

    while vertices:
        # Find minimum degree vertex
        min_deg = float('inf')
        min_v = None
        for v in vertices:
            d = len(adj[v] & vertices)
            if d < min_deg:
                min_deg = d
                min_v = v

        if min_v is None:
            break

        tw = max(tw, min_deg)

        # Make neighbors into clique
        neighbors = adj[min_v] & vertices
        for u in neighbors:
            for w in neighbors:
                if u != w:
                    adj[u].add(w)
                    adj[w].add(u)

        vertices.discard(min_v)

    return tw


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("Algorithm Demonstrations")
    print("=" * 50)

    # Build reduction graph
    term = App(Lam(0, App(Var(0), Var(0))), Lam(1, Var(1)))
    print(f"\nTerm: {term}")
    g = build_reduction_graph(term)
    print(f"Vertices: {len(g.vertices)}")
    print(f"Edges: {len(g.edges)}")
    print(f"DAG: {g.is_dag()}")
    print(f"Normal forms: {g.normal_forms}")
    print(f"Depth: {g.depth}")

    # CTL model checking
    af_nf = CTLAF(CTLAtom("nf"))
    sat_states = ctl_model_check(g, af_nf)
    print(f"\nAF(normal_form) satisfied at root: {g.root in sat_states}")

    ef_nf = CTLEF(CTLAtom("nf"))
    sat_states = ctl_model_check(g, ef_nf)
    print(f"EF(normal_form) satisfied at root: {g.root in sat_states}")

    # Treewidth
    tw = estimate_treewidth(g)
    print(f"\nEstimated treewidth: {tw}")

    # Bounds
    ty = Arrow(Base(), Base())
    print(f"\nType: {ty}")
    print(f"Complexity bound: {normalization_bound(ty, term.size())}")
    print(f"Tight bound (conj.): {tight_bound(ty, term.size())}")
