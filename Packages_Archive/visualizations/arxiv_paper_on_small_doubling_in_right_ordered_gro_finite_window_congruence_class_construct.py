from collections import defaultdict
from itertools import product
from typing import Callable, DefaultDict, Dict, Hashable, List, Sequence, Tuple, TypeVar
A = TypeVar("A", bound=Hashable)
R = TypeVar("R", bound=Hashable)
def bounded_classes(alphabet: Sequence[A], bound: int, memory: Callable[[Tuple[A, ...]], R]) -> Dict[R, List[Tuple[A, ...]]]:
    groups: DefaultDict[R, List[Tuple[A, ...]]] = defaultdict(list)
    for n in range(bound + 1):
        for word in product(alphabet, repeat=n):
            groups[memory(word)].append(word)
    return dict(groups)
if __name__ == "__main__":
    print({k: len(v) for k, v in bounded_classes(("a", "b"), 5, lambda w: len(w) % 2).items()})
