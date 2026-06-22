from typing import Callable, Sequence, TypeVar

State = TypeVar('State')
Block = TypeVar('Block')

def md_hash(f: Callable[[State, Block], State],
            iv: State,
            msg: Sequence[Block]) -> State:
    """Merkle-Damgard hash: left fold of f over msg from iv."""
    state = iv
    for block in msg:
        state = f(state, block)
    return state
