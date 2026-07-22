from itertools import product
from typing import TypeVar, Sequence
T=TypeVar("T")
def trace(radius: int, prefix: tuple[T,...], alphabet: Sequence[T]) -> set[tuple[T,...]]:
    if len(prefix)>radius: return set()
    return {prefix+s for n in range(radius-len(prefix)+1) for s in product(alphabet,repeat=n)}
alphabet=("e","a","b"); radius=3
words=[w for n in range(radius+1) for w in product(alphabet,repeat=n)]
signatures={w:frozenset(trace(radius,w,alphabet)) for w in words}
assert len(set(signatures.values()))==len(words)
print(f"All {len(words)} bounded words have distinct traces.")
