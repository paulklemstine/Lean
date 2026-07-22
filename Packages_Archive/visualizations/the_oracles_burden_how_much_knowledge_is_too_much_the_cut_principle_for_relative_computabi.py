from typing import Callable, Dict, Iterable, List, Set

Fn = Callable[[int], int]

def recursive_in(closure_base: Set[str], oracle_names: Iterable[str],
                 reducible_to: Dict[str, Set[str]], target: str, richer: Set[str]) -> bool:
    """Decide Rec(O) subset Rec(O') via the cut principle.

    reducible_to[g] lists everything already reducible to g. The cut principle:
    if every oracle in O is reducible to O', then everything in Rec(O) is in Rec(O').
    """
    # every oracle in O must be reducible into the richer set O'
    return all(any(target in reducible_to.get(r, set()) or g == r
                   for r in richer) or g in richer
               for g in oracle_names) and            any(target in reducible_to.get(r, set()) or target == r for r in richer)
