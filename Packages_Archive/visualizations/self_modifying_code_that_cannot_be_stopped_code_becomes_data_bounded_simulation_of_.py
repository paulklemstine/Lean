from __future__ import annotations
from typing import Callable, Optional, Tuple

Prog = object
State = object
Step = Callable[[Prog, State], Optional[Tuple[Prog, State]]]

def bounded_simulate(step: Step, prog: Prog, state: State, budget: int) -> str:
    """Run a self-modifying machine as a fixed-program machine over (prog, state).

    Returns "HALTED@<t>" if the machine halts within `budget` steps, else
    "RUNNING" (a sound but inconclusive verdict)."""
    data: Tuple[Prog, State] = (prog, state)
    for t in range(budget):
        result = step(data[0], data[1])
        if result is None:
            return f"HALTED@{t}"
        data = result
    return "RUNNING"
