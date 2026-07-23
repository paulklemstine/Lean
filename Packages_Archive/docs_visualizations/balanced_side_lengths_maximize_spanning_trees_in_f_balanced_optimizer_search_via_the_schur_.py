from typing import Callable, List, Sequence, Tuple


def exchange_maximizer(d: int, k: int,
                       value: Callable[[Tuple[int, ...]], int]) -> Tuple[int, ...]:
    """Find the balanced maximizer of an exchange-increasing `value` over all
    multisets of d nonnegative integers summing to k, by exhaustive search.

    The balancing engine guarantees the returned argmax is balanced
    (max - min <= 1) whenever `value` strictly increases under the move
    (a, b) -> (a+1, b-1) for a + 2 <= b.
    """
    comps: List[Tuple[int, ...]] = []

    def rec(remaining: int, parts: int, low: int, acc: List[int]) -> None:
        if parts == 1:
            if remaining >= low:
                comps.append(tuple(acc + [remaining]))
            return
        v = low
        while v * parts <= remaining:
            rec(remaining - v, parts - 1, v, acc + [v])
            v += 1

    rec(k, d, 0, [])
    best = max(comps, key=value)
    assert max(best) - min(best) <= 1, "engine guarantees a balanced maximizer"
    return best
