from typing import Callable, Hashable, Tuple

State = Hashable
Symbol = Hashable

def pump_down(
    num_states: int,
    step: Callable[[State, Symbol], State],
    start: State,
    x: Tuple[Symbol, ...],
) -> Tuple[Tuple[Symbol, ...], Tuple[Symbol, ...], Tuple[Symbol, ...], Tuple[Symbol, ...]]:
    """Return (a, b, c, a+c) with x=a+b+c, b nonempty, |a|+|b|<=s, a+c accepted."""
    assert len(x) >= num_states
    prefix_state = [start]
    s = start
    for a in x[:num_states]:
        s = step(s, a)
        prefix_state.append(s)
    seen = {}
    for i, st in enumerate(prefix_state):
        if st in seen:
            j = i
            i0 = seen[st]
            a, b, c = x[:i0], x[i0:j], x[j:]
            return a, b, c, a + c
        seen[st] = i
    raise RuntimeError('no repetition: |x| < s')
