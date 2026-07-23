from typing import Callable, Iterable, TypeVar

T = TypeVar('T')

def expected_count(p: float, index_set: Iterable[T],
                   event_size: Callable[[T], int],
                   present: bool = True) -> float:
    """Exact E[# events that occur] = sum of per-event probabilities.

    present=True  uses P(allPresent S) = p**|S|;
    present=False uses P(allAbsent S)  = (1-p)**|S|.
    """
    total = 0.0
    for i in index_set:
        s = event_size(i)
        total += (p ** s) if present else ((1.0 - p) ** s)
    return total
