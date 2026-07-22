from __future__ import annotations
from dataclasses import dataclass, field
from typing import Callable, Dict, List, Optional, Tuple, Union

CNF = List[Tuple[int, int]]


@dataclass
class Mate: ...
@dataclass
class Step:
    child: "Game"
@dataclass
class Bsup:
    family: Callable[[int], "Game"]
    bound: int
@dataclass
class Graft:
    a: "Game"
    b: "Game"

Game = Union[Mate, Step, Bsup, Graft]


def game_value(g: Game,
               ordinal_add: Callable[[CNF, CNF], CNF],
               ordinal_sup: Callable[[List[CNF]], Optional[CNF]]) -> Optional[CNF]:
    """Compute the ordinal game value of a winning game tree.

    Returns a Cantor-normal-form ordinal below omega^omega, or None for the top
    ordinal omega^omega. Winner Step nodes add one; the lazy Graft node uses the
    additivity law value(graft a b) = value(b) + value(a); loser Bsup nodes take
    the supremum over the (incremented) values of Black's countable options.
    """
    memo: Dict[int, Optional[CNF]] = {}

    def succ(o: Optional[CNF]) -> Optional[CNF]:
        return None if o is None else ordinal_add(o, [(0, 1)])

    def go(node: Game) -> Optional[CNF]:
        key = id(node)
        if key in memo:
            return memo[key]
        if isinstance(node, Mate):
            res: Optional[CNF] = []
        elif isinstance(node, Step):
            res = succ(go(node.child))
        elif isinstance(node, Graft):
            vb, va = go(node.b), go(node.a)
            res = None if (vb is None or va is None) else ordinal_add(vb, va)
        elif isinstance(node, Bsup):
            children = [node.family(n) for n in range(node.bound)]  # pin alive
            vals = [succ(go(c)) for c in children]
            res = None if any(v is None for v in vals) else ordinal_sup(
                [v for v in vals if v is not None])
        else:
            raise TypeError
        memo[key] = res
        return res

    return go(g)
