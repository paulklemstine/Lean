from typing import Callable, Hashable, Sequence, Tuple, TypeVar
S = TypeVar("S", bound=Hashable)
def targeted_filter(word: Sequence[S], retain: Callable[[S], bool]) -> Tuple[S, ...]:
    return tuple(x for x in word if retain(x))
if __name__ == "__main__":
    keep = lambda x: x in {"a", "c"}
    print("".join(targeted_filter(tuple("abbcba"), keep)))
