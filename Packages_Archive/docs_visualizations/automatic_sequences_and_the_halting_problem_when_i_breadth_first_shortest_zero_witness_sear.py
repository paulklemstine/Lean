from collections import deque
from typing import Callable, Hashable, Iterable, Optional, TypeVar
Q = TypeVar("Q", bound=Hashable)
A = TypeVar("A", bound=Hashable)
def shortest_target_word(start: Q, alphabet: Iterable[A], step: Callable[[Q, A], Q], is_target: Callable[[Q], bool]) -> Optional[tuple[A, ...]]:
    queue = deque([(start, ())])
    seen = {start}
    while queue:
        state, word = queue.popleft()
        if is_target(state): return word
        for symbol in alphabet:
            nxt = step(state, symbol)
            if nxt not in seen:
                seen.add(nxt); queue.append((nxt, word + (symbol,)))
    return None
