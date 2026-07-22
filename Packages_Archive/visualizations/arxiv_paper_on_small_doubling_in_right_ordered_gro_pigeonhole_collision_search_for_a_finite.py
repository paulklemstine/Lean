from typing import Callable, Dict, Hashable, Tuple, TypeVar
S = TypeVar("S", bound=Hashable)
def collision(identity: S, transition: Callable[[S], S], number_of_states: int) -> Tuple[int, int, S]:
    seen: Dict[S, int] = {identity: 0}
    state = identity
    for j in range(1, number_of_states + 1):
        state = transition(state)
        if state in seen:
            return seen[state], j, state
        seen[state] = j
    raise RuntimeError("The supplied state bound is inconsistent")
if __name__ == "__main__":
    print(collision(0, lambda x: (x + 1) % 7, 7))
