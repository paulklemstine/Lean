from typing import Callable, Dict, List, Set, Tuple

World = int
Relation = Set[Tuple[World, World]]

def reverse_topological(worlds: List[World], R: Relation) -> List[World]:
    """Post-order DFS yields nodes with all successors before themselves."""
    order: List[World] = []
    seen: Set[World] = set()
    def visit(u: World) -> None:
        seen.add(u)
        for v in worlds:
            if (u, v) in R and v not in seen:
                visit(v)
        order.append(u)
    for w in worlds:
        if w not in seen:
            visit(w)
    return order  # successors precede predecessors

def loeb_fixpoint(worlds: List[World], R: Relation,
                  loeb_hyp: Callable[[World], Callable[[bool], bool]]
                  ) -> Callable[[World], bool]:
    A: Dict[World, bool] = {}
    for w in reverse_topological(worlds, R):
        box_at_w = all(A[v] for v in worlds if (w, v) in R)
        A[w] = loeb_hyp(w)(box_at_w)
    return lambda w: all(A[v] for v in worlds if (w, v) in R)
