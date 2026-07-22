from typing import Hashable, Iterable, TypeVar

T = TypeVar("T", bound=Hashable)

def lower_level(witnesses: Iterable[T], level: int) -> list[T]:
    if level < 0:
        raise ValueError("level must be nonnegative")
    distinct = list(dict.fromkeys(witnesses))
    if level > len(distinct):
        raise ValueError("insufficient distinct witnesses")
    return distinct[:level]

if __name__ == "__main__":
    source = [(i, "payload") for i in range(5)]
    for level in range(6):
        selected = lower_level(source, level)
        assert len(selected) == level
        print(level, selected)
