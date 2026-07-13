"""
Numerical demonstrations for "The Topological Structure of Proof Dependency Graphs".

A proof is modeled as a directed acyclic graph (DAG): nodes are statements, and an
edge a -> b means "statement a is used directly in the proof of b." Acyclicity is
the absence of circular arguments. This script demonstrates, on concrete examples,
the paper's main results:

  1. Reachability (transitive closure) and detection of circular arguments.
  2. The rank function f(v) = |ancestors(v)|, strictly increasing along edges
     (Topological Numbering Theorem).
  3. Existence of foundational (source) and capstone (sink) statements.
  4. The sparsity bound 2|E| <= n(n-1).
  5. Longest dependency chain (proof depth / critical path).

Run directly:  python demo.py
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, List, Set, Tuple

Graph = Dict[str, List[str]]


# --------------------------------------------------------------------------- #
# Core routines                                                               #
# --------------------------------------------------------------------------- #
def reachable_from(graph: Graph, start: str) -> Set[str]:
    """Return all nodes reachable from `start` via nonempty directed chains."""
    seen: Set[str] = set()
    stack: List[str] = list(graph.get(start, []))
    while stack:
        node = stack.pop()
        if node not in seen:
            seen.add(node)
            stack.extend(graph.get(node, []))
    return seen


def is_acyclic(graph: Graph) -> bool:
    """True iff no node reaches itself (no circular argument)."""
    return all(node not in reachable_from(graph, node) for node in graph)


def ancestor_sets(graph: Graph) -> Dict[str, Set[str]]:
    """For each node v, the set of statements that reach v (strict ancestors)."""
    nodes = list(graph.keys())
    anc: Dict[str, Set[str]] = {v: set() for v in nodes}
    for u in nodes:
        for v in reachable_from(graph, u):
            anc[v].add(u)
    return anc


def rank_function(graph: Graph) -> Dict[str, int]:
    """Topological rank f(v) = |ancestors(v)| from the paper's Theorem 4.5."""
    return {v: len(a) for v, a in ancestor_sets(graph).items()}


def sources(graph: Graph) -> List[str]:
    """Foundational statements: nodes with no incoming edge."""
    has_incoming = {w for outs in graph.values() for w in outs}
    return [v for v in graph if v not in has_incoming]


def sinks(graph: Graph) -> List[str]:
    """Capstone statements: nodes with no outgoing edge."""
    return [v for v in graph if not graph.get(v)]


def edge_count(graph: Graph) -> int:
    return sum(len(outs) for outs in graph.values())


def longest_chain(graph: Graph) -> Tuple[int, List[str]]:
    """Longest directed chain length (proof depth) and one realizing path."""
    memo: Dict[str, Tuple[int, List[str]]] = {}

    def best(v: str) -> Tuple[int, List[str]]:
        if v in memo:
            return memo[v]
        result = (1, [v])
        for w in graph.get(v, []):
            length, path = best(w)
            if 1 + length > result[0]:
                result = (1 + length, [v] + path)
        memo[v] = result
        return result

    overall = (0, [])
    for v in graph:
        length, path = best(v)
        if length > overall[0]:
            overall = (length, path)
    return overall


def verify_rank_increases(graph: Graph) -> bool:
    """Check f(a) < f(b) for every edge a -> b (Topological Numbering Theorem)."""
    f = rank_function(graph)
    return all(f[a] < f[b] for a, outs in graph.items() for b in outs)


def verify_sparsity(graph: Graph) -> Tuple[bool, int, int]:
    """Check 2|E| <= n(n-1); return (ok, 2|E|, n(n-1))."""
    n = len(graph)
    lhs = 2 * edge_count(graph)
    rhs = n * (n - 1)
    return lhs <= rhs, lhs, rhs


# --------------------------------------------------------------------------- #
# Example proof DAG                                                            #
# --------------------------------------------------------------------------- #
# A miniature "theory": Peano-style foundations building up to a capstone.
MATH_DAG: Graph = {
    "Axioms": ["Induction", "Order"],
    "Induction": ["AddAssoc", "MulComm"],
    "Order": ["MulComm", "WellOrder"],
    "AddAssoc": ["Distributivity"],
    "MulComm": ["Distributivity"],
    "WellOrder": ["Distributivity"],
    "Distributivity": ["FundThmArith"],
    "FundThmArith": [],
}


def demo() -> None:
    g = MATH_DAG
    print("=" * 66)
    print("Proof Dependency Graph demo")
    print("=" * 66)

    print(f"\nStatements (n): {len(g)}")
    print(f"Direct dependencies (|E|): {edge_count(g)}")

    print(f"\nAcyclic (no circular argument)? {is_acyclic(g)}")

    f = rank_function(g)
    print("\nTopological rank  f(v) = |ancestors(v)|:")
    for v in sorted(g, key=lambda x: f[x]):
        print(f"  {f[v]:>2}  {v}")
    print(f"\nRank strictly increases along every edge? {verify_rank_increases(g)}")

    print(f"\nFoundational statements (sources): {sources(g)}")
    print(f"Capstone statements (sinks):        {sinks(g)}")

    ok, lhs, rhs = verify_sparsity(g)
    print(f"\nSparsity 2|E| <= n(n-1):  {lhs} <= {rhs}  -> {ok}")

    depth, path = longest_chain(g)
    print(f"\nProof depth (longest chain): {depth}")
    print("  path: " + " -> ".join(path))

    # A CYCLIC (invalid) example: circular reasoning is detected.
    print("\n" + "-" * 66)
    circular: Graph = {"A": ["B"], "B": ["C"], "C": ["A"]}
    print("Circular 'proof'  A -> B -> C -> A")
    print(f"  Acyclic? {is_acyclic(circular)}  (correctly rejected)")

    # Sanity: the sparsity bound is tight for a total order (transitive tournament).
    print("\n" + "-" * 66)
    chain_nodes = ["s0", "s1", "s2", "s3", "s4"]
    total_order: Graph = {
        u: chain_nodes[i + 1:] for i, u in enumerate(chain_nodes)
    }
    ok, lhs, rhs = verify_sparsity(total_order)
    print("Transitive tournament on 5 nodes (densest acyclic graph):")
    print(f"  |E| = {edge_count(total_order)},  bound n(n-1)/2 = {rhs // 2}")
    print(f"  2|E| <= n(n-1):  {lhs} <= {rhs}  -> {ok}  (tight)")


if __name__ == "__main__":
    demo()
