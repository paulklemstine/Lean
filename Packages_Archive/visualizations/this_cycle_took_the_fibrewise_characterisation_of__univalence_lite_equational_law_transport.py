from itertools import product
from typing import Callable, Hashable, Sequence, TypeVar
A = TypeVar("A", bound=Hashable)
B = TypeVar("B", bound=Hashable)

def transport_operation(op_M: Callable[[A, A], A],
                        phi: Callable[[A], B],
                        psi: Callable[[B], A]) -> Callable[[B, B], B]:
    """Induced operation on N along an equivalence phi (inverse psi):
       x *_N y := phi( psi(x) *_M psi(y) )."""
    return lambda x, y: phi(op_M(psi(x), psi(y)))

def law_transports(op_M: Callable[[A, A], A], carrier_M: Sequence[A],
                   phi: Callable[[A], B], psi: Callable[[B], A],
                   carrier_N: Sequence[B]) -> bool:
    """Verify commutativity and associativity transport across phi
    (univalence-lite)."""
    op_N = transport_operation(op_M, phi, psi)
    comm = all(op_N(x, y) == op_N(y, x)
               for x, y in product(carrier_N, repeat=2))
    assoc = all(op_N(op_N(x, y), z) == op_N(x, op_N(y, z))
                for x, y, z in product(carrier_N, repeat=3))
    return comm and assoc
