from __future__ import annotations
from math import gcd, lcm
from typing import Dict, List, Tuple


def order_spectrum(orders: List[int]) -> Dict[int, int]:
    """Bucket a list of element orders into a {order: multiplicity} spectrum."""
    spec: Dict[int, int] = {}
    for o in orders:
        spec[o] = spec.get(o, 0) + 1
    return spec


def cyclic_orders(n: int) -> List[int]:
    return [1 if a == 0 else n // gcd(a, n) for a in range(n)]


def product_orders(dims: Tuple[int, ...]) -> List[int]:
    """Element orders of the additive group Z/dims[0] x ... x Z/dims[-1]."""
    from itertools import product

    def ord1(a: int, m: int) -> int:
        return 1 if a % m == 0 else m // gcd(a % m, m)

    orders: List[int] = []
    for tup in product(*[range(m) for m in dims]):
        o = 1
        for a, m in zip(tup, dims):
            o = lcm(o, ord1(a, m))
        orders.append(o)
    return orders


def same_order_spectrum(a: List[int], b: List[int]) -> bool:
    """Necessary condition for isomorphism: matching order spectra."""
    return order_spectrum(a) == order_spectrum(b)
