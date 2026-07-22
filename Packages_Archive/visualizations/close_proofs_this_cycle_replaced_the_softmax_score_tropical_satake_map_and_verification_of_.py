from typing import Callable, List, Optional, Tuple, TypeVar
T = TypeVar("T")
WithBot = Optional[int]   # None = -infinity (BOT)

def is_simple_summand(carrier: List[T], leq: Callable[[T, T], bool],
                      bot: T, cl: Callable[[T], T], val: T) -> bool:
    """val is a simple summand: non-bottom, closed, and closure-prime."""
    if val == bot:
        return False
    if cl(val) != val:                       # must be closed
        return False
    # closure-prime: val <= cl(x)  =>  val <= x
    return all((not leq(val, cl(x))) or leq(val, x) for x in carrier)

def summand_indicator(leq: Callable[[T, T], bool], val: T) -> Callable[[T], WithBot]:
    """mu_val(x) = 0 if val <= x else BOT."""
    def mu(x: T) -> WithBot:
        return 0 if leq(val, x) else None
    return mu

def satake_map_injective(carrier: List[T], leq: Callable[[T, T], bool],
                         bot: T, cl: Callable[[T], T]) -> bool:
    """Verify the main theorem: distinct summands -> distinct eigenmeasures."""
    summands = [v for v in carrier if is_simple_summand(carrier, leq, bot, cl, v)]
    fps: List[Tuple[WithBot, ...]] = []
    for v in summands:
        mu = summand_indicator(leq, v)
        fps.append(tuple(mu(x) for x in carrier))
    return len(set(fps)) == len(fps)
