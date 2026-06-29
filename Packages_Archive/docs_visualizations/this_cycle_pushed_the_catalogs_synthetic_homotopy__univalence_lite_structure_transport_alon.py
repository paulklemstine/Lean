from itertools import product
from typing import Callable, Hashable, List, TypeVar

A = TypeVar('A', bound=Hashable)
B = TypeVar('B', bound=Hashable)

def transport_operation(phi: Callable[[A], B],
                        phi_inv: Callable[[B], A],
                        op_M: Callable[[A, A], A]) -> Callable[[B, B], B]:
    return lambda x, y: phi(op_M(phi_inv(x), phi_inv(y)))

def is_associative(op: Callable[[A, A], A], carrier: List[A]) -> bool:
    return all(op(op(x, y), z) == op(x, op(y, z))
               for x, y, z in product(carrier, repeat=3))

def is_commutative(op: Callable[[A, A], A], carrier: List[A]) -> bool:
    return all(op(x, y) == op(y, x)
               for x in carrier for y in carrier)
