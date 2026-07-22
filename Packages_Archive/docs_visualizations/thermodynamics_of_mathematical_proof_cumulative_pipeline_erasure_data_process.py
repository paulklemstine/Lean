from math import log2
from typing import Callable, Hashable, Sequence, TypeVar

A = TypeVar("A", bound=Hashable)
B = TypeVar("B", bound=Hashable)
C = TypeVar("C", bound=Hashable)


def pipeline_erasure(steps: Sequence[Callable], domain: Sequence[A]) -> list[float]:
    """Cumulative bits erased after each prefix of a proof pipeline of steps.

    Returns a nondecreasing list (data-processing inequality): once a step
    collapses states, later steps cannot recover them. Composed by folding the
    domain through each step and recording the running erasure from the origin.
    """
    n: int = len(domain)
    base: float = log2(n)
    current: list = list(domain)
    cumulative: list[float] = []
    for step in steps:
        current = [step(x) for x in current]
        image_size: int = len(set(current))
        cumulative.append(base - log2(image_size))
    return cumulative
