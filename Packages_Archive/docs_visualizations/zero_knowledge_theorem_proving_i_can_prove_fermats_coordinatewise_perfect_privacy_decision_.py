from typing import Sequence

def coordinate_private(witnesses: Sequence[tuple[int, ...]], i: int) -> bool:
    return len({w[i] for w in witnesses}) <= 1

def all_private(witnesses: Sequence[tuple[int, ...]]) -> bool:
    return not witnesses or all(coordinate_private(witnesses, i) for i in range(len(witnesses[0])))

print(coordinate_private([(0,), (1,)], 0))
print(all_private([(1, 0, 1)]))
