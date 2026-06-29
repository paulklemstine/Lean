from typing import Callable, TypeVar, Hashable
A = TypeVar('A', bound=Hashable); T = TypeVar('T', bound=Hashable)
PATH = ()  # the unique reflexivity marker for (a0 = a)

def encode(rflR: T, a0: A, a: A) -> Callable[[tuple], T]:
    # transport of rflR along the only path (which exists iff a == a0)
    return lambda _p: rflR

def decode(a0: A, a: A) -> Callable[[T], tuple]:
    # contractibility forces (a, r) == (a0, rflR), hence a == a0
    return lambda _r: PATH

def fundamental(rflR: T, a0: A, a: A,
                fibre: list) -> dict:
    return {
        'domain': [PATH] if a == a0 else [],
        'codomain': fibre,
        'to_fun': encode(rflR, a0, a),
        'inv_fun': decode(a0, a),
    }
