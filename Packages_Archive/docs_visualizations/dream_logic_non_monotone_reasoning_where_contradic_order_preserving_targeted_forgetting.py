from typing import Callable, Sequence, Tuple, TypeVar
T = TypeVar("T")
def targeted_forgetting(stream: Sequence[T], retain: Callable[[T], bool]) -> Tuple[T, ...]:
    return tuple(x for x in stream if retain(x))
