from dataclasses import dataclass
from typing import Callable


@dataclass
class TropicalValuationCarrier:
    """N-valued tropical valuation carrier (mirrors the Lean structure).

    val must satisfy: val(0)=0, val(-x)=val(x), val(x*y)=val(x)*val(y),
    and the strong/tropical additivity law val(x+y) <= max(val x, val y).
    """
    add: Callable[[int, int], int]
    neg: Callable[[int], int]
    mul: Callable[[int, int], int]
    zero: int
    val: Callable[[int], int]


def reconstruct_norm(carrier: TropicalValuationCarrier) -> Callable[[int], int]:
    """valuationReconstruct: the ultrametric norm IS the valuation.
    The four ultrametric axioms hold automatically from the carrier axioms."""
    return carrier.val


def verify_ultrametric(carrier: TropicalValuationCarrier,
                       sample: list[int]) -> bool:
    """Check norm(x+y) <= max(norm x, norm y) on a finite sample."""
    norm = reconstruct_norm(carrier)
    return all(
        norm(carrier.add(x, y)) <= max(norm(x), norm(y))
        for x in sample for y in sample
    )
