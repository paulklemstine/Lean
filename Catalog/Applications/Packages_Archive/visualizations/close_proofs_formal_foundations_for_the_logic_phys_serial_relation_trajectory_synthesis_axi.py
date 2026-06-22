from typing import Callable, List, Sequence, TypeVar

S = TypeVar("S")


def is_serial(step: Callable[[S, S], bool], space: Sequence[S]) -> bool:
    """Serial: every state has at least one legal successor (modal axiom D)."""
    return all(any(step(s, t) for t in space) for s in space)


def build_trajectory(
    init: Sequence[S],
    step: Callable[[S, S], bool],
    space: Sequence[S],
    length: int,
) -> List[S]:
    """Construct a prefix of an eternal trajectory from a serial step relation.

    Mirrors the Lean proof of `serial_realizable`: pick s0 in init, then at each
    step *choose* a legal successor (the choice function next : S -> S obtained
    from seriality via the Axiom of Choice)."""
    assert init, "initial set must be nonempty"
    assert is_serial(step, space), "step relation must be serial"
    traj: List[S] = [next(iter(init))]
    for _ in range(length - 1):
        s: S = traj[-1]
        successor: S = next(t for t in space if step(s, t))
        traj.append(successor)
    return traj
