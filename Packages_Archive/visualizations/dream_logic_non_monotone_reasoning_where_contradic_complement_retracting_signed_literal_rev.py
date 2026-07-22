from typing import FrozenSet, Tuple
Literal = Tuple[str, bool]
State = FrozenSet[Literal]
def opposite(lit: Literal) -> Literal:
    return lit[0], not lit[1]
def revise(state: State, lit: Literal) -> State:
    return frozenset((set(state) - {opposite(lit)}) | {lit})
