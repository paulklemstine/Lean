"""
Numerical demonstrations for
"Colorability Does Not Control Choosability: A Complete Planar Witness at k=2".

This self-contained script demonstrates:

  1. K_{2,4} is 2-colorable (an explicit proper 2-coloring exists).
  2. K_{2,4} is NOT 2-choosable: the diagonal two-element list assignment
     admits no proper list coloring (verified by exhaustive search).
  3. The gap generalizes: K_{k, k^k} is bipartite (chromatic number 2) yet
     not k-choosable.
  4. The greedy/degeneracy bound: a d-degenerate graph is (d+1)-choosable,
     illustrated by successfully list-coloring K_{2,4} with lists of size 3.

Run:  python demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Dict, List, Optional, Set, Tuple

# A vertex is a (side, index) pair: side 'A' = small side, 'B' = large side.
Vertex = Tuple[str, int]
Coloring = Dict[Vertex, int]
ListAssignment = Dict[Vertex, Set[int]]


def complete_bipartite(m: int, n: int) -> Tuple[List[Vertex], List[Tuple[Vertex, Vertex]]]:
    """Return the vertices and edges of the complete bipartite graph K_{m,n}."""
    left: List[Vertex] = [("A", i) for i in range(m)]
    right: List[Vertex] = [("B", j) for j in range(n)]
    vertices = left + right
    edges = [(a, b) for a in left for b in right]
    return vertices, edges


def is_proper(coloring: Coloring, edges: List[Tuple[Vertex, Vertex]]) -> bool:
    """Check that no edge is monochromatic."""
    return all(coloring[u] != coloring[v] for (u, v) in edges)


def find_list_coloring(
    vertices: List[Vertex],
    edges: List[Tuple[Vertex, Vertex]],
    lists: ListAssignment,
) -> Optional[Coloring]:
    """Exhaustively search for a proper coloring respecting the given lists.

    Returns a witnessing coloring if one exists, otherwise None.
    """
    order = list(vertices)
    choices = [sorted(lists[v]) for v in order]
    for combo in product(*choices):
        coloring: Coloring = dict(zip(order, combo))
        if is_proper(coloring, edges):
            return coloring
    return None


def diagonal_assignment_k24() -> ListAssignment:
    """The diagonal 2-list assignment on K_{2,4} that defeats 2-choosability.

    Small side gets disjoint lists {0,1} and {2,3}; large side gets the four
    cross pairs, i.e. all systems of distinct representatives.
    """
    return {
        ("A", 0): {0, 1},
        ("A", 1): {2, 3},
        ("B", 0): {0, 2},
        ("B", 1): {0, 3},
        ("B", 2): {1, 2},
        ("B", 3): {1, 3},
    }


def demo_k24_is_2colorable() -> None:
    vertices, edges = complete_bipartite(2, 4)
    coloring: Coloring = {v: (0 if v[0] == "A" else 1) for v in vertices}
    assert is_proper(coloring, edges)
    print("[1] K_{2,4} is 2-colorable.")
    print("    Proper 2-coloring:", {f"{s}{i}": c for (s, i), c in coloring.items()})
    print()


def demo_k24_not_2choosable() -> None:
    vertices, edges = complete_bipartite(2, 4)
    lists = diagonal_assignment_k24()
    assert all(len(lists[v]) == 2 for v in vertices), "all lists must have size 2"
    result = find_list_coloring(vertices, edges, lists)
    print("[2] K_{2,4} is NOT 2-choosable (diagonal assignment, all lists size 2):")
    for v in vertices:
        print(f"    L({v[0]}{v[1]}) = {sorted(lists[v])}")
    assert result is None, "unexpected: a proper list coloring was found!"
    print("    Exhaustive search over all list choices: NO proper coloring exists.")
    # Show the blocking vertex for each small-side choice.
    print("    Small-side choice -> blocked large-side vertex:")
    for alpha in sorted(lists[("A", 0)]):
        for beta in sorted(lists[("A", 1)]):
            blocked = next(
                v for v in vertices if v[0] == "B" and lists[v] == {alpha, beta}
            )
            print(f"      a0={alpha}, a1={beta}  ->  {blocked[0]}{blocked[1]} has list "
                  f"{sorted(lists[blocked])}, both forbidden")
    print()


def demo_generalization(k: int = 2) -> None:
    """K_{k, k^k} is bipartite (chi = 2) but not k-choosable."""
    n = k ** k
    vertices, edges = complete_bipartite(k, n)
    # Small side: disjoint k-lists S_i = {i*k, ..., i*k+k-1}.
    small_lists: List[List[int]] = [list(range(i * k, i * k + k)) for i in range(k)]
    lists: ListAssignment = {("A", i): set(small_lists[i]) for i in range(k)}
    # Large side: all systems of distinct representatives.
    systems = list(product(*small_lists))
    for j, sysrep in enumerate(systems):
        lists[("B", j)] = set(sysrep)
    result = find_list_coloring(vertices, edges, lists)
    print(f"[3] K_{{{k},{n}}} = K_{{k,k^k}} with k={k}: bipartite, chromatic number 2.")
    print(f"    Large side enumerates all {n} systems of distinct representatives.")
    assert result is None, "unexpected: a proper list coloring was found!"
    print(f"    k-choosable check with k={k}: NO proper list coloring exists.")
    print()


def demo_greedy_bound() -> None:
    """K_{2,4} is 2-degenerate, hence 3-choosable: lists of size 3 always work."""
    vertices, edges = complete_bipartite(2, 4)
    # A worst-case-looking assignment with all lists of size 3.
    lists: ListAssignment = {
        ("A", 0): {0, 1, 2},
        ("A", 1): {0, 1, 2},
        ("B", 0): {0, 1, 3},
        ("B", 1): {0, 2, 3},
        ("B", 2): {1, 2, 3},
        ("B", 3): {0, 1, 2},
    }
    result = find_list_coloring(vertices, edges, lists)
    print("[4] Greedy/degeneracy bound: K_{2,4} is 2-degenerate, hence 3-choosable.")
    assert result is not None, "a 3-assignment must be satisfiable"
    print("    A proper list coloring with all lists of size 3:")
    print("   ", {f"{s}{i}": c for (s, i), c in result.items()})
    print()


def main() -> None:
    print("=" * 68)
    print("Colorability does not control choosability: demonstrations")
    print("=" * 68)
    print()
    demo_k24_is_2colorable()
    demo_k24_not_2choosable()
    demo_generalization(k=2)
    demo_greedy_bound()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
