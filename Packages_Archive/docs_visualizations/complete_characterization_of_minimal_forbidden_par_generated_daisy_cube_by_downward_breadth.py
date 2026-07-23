from typing import FrozenSet, Iterable, List, Set

Vertex = FrozenSet[int]


def down_closure(generators: Iterable[Vertex]) -> Set[Vertex]:
    """Smallest daisy cube containing the generators (the operator dc(X)).

    Implements downClosure as a downward breadth-first closure: repeatedly strip
    one element at a time from each generator, collecting all reachable subsets.
    Correctness: isDaisy_downClosure (output is down-closed) + downClosure_minimal
    (it is contained in every daisy cube containing X).
    Complexity: O(|dc(X)| * n); each vertex is finalized once.
    """
    closure: Set[Vertex] = set()
    frontier: List[Vertex] = list(generators)
    while frontier:
        a = frontier.pop()
        if a in closure:
            continue
        closure.add(a)
        for x in a:
            frontier.append(a - {x})
    return closure
