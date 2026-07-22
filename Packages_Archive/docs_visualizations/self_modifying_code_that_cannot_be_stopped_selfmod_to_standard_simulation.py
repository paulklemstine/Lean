from typing import Optional, Callable, TypeVar

P = TypeVar('P')
S = TypeVar('S')

def simulate_selfmod(
    step: Callable[[int, int], Optional[tuple[int, int]]],
    prog: int,
    state: int,
    max_steps: int
) -> list[tuple[int, int]]:
    """Simulate a self-modifying machine using a fixed standard machine."""
    trace = [(prog, state)]
    for _ in range(max_steps):
        result = step(prog, state)
        if result is None:
            break
        prog, state = result
        trace.append((prog, state))
    return trace

# Example: program increments itself, state accumulates
def step(p, s):
    return (p+1, s+p) if s < 100 else None

print(simulate_selfmod(step, 1, 0, 50))