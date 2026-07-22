from collections import Counter
from typing import Hashable, Mapping, Sequence, TypeVar
T = TypeVar("T", bound=Hashable)

def component_mode_impute(components: Sequence[Sequence[int]], observations: Mapping[int, T], values: Sequence[T]) -> list[T]:
    n = 1 + max(v for c in components for v in c)
    answer = [values[0]] * n
    for component in components:
        counts = Counter(observations[v] for v in component if v in observations)
        choice = max(values, key=lambda value: counts[value])
        for v in component:
            answer[v] = choice
    return answer
