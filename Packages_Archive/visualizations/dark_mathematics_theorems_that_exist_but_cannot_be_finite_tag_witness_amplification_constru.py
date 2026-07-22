from typing import Callable, Hashable, TypeVar

T = TypeVar("T", bound=Hashable)

def amplify(witness: T, level: int) -> list[tuple[int, T]]:
    if level < 1:
        raise ValueError("level must be positive")
    result = [(tag, witness) for tag in range(level)]
    assert len(set(result)) == level
    return result

def tagged_truth(predicate: Callable[[T], bool], pair: tuple[int, T]) -> bool:
    return predicate(pair[1])

if __name__ == "__main__":
    predicate = lambda x: x == 42
    for level in range(1, 7):
        witnesses = amplify(42, level)
        assert all(tagged_truth(predicate, z) for z in witnesses)
        print(f"level {level}: {witnesses}")
