"""Visualization: the bridge as a truth table, and a trajectory orbit.

Generates two panels with matplotlib:
  (left)  a grid over example theories showing Realizable == Consistent;
  (right) the cyclic trajectory produced by a serial step relation."""
from typing import Callable, List, Sequence, TypeVar
import math
import matplotlib.pyplot as plt

Law = Callable[[int], bool]


def is_model(theory: List[Law], s: int) -> bool:
    return all(law(s) for law in theory)


def realizable(theory: List[Law], space: Sequence[int]) -> bool:
    return any(is_model(theory, s) for s in space)


def consistent(theory: List[Law], space: Sequence[int]) -> bool:
    return not all(False for s in space if is_model(theory, s))


def main() -> None:
    space = list(range(-3, 4))
    theories = {
        "pos & even": [lambda s: s > 0, lambda s: s % 2 == 0],
        "pos & neg": [lambda s: s > 0, lambda s: s < 0],
        "== 5": [lambda s: s == 5],
        "empty": [],
    }
    fig, (ax0, ax1) = plt.subplots(1, 2, figsize=(11, 4))

    names = list(theories)
    rvals = [1 if realizable(theories[n], space) else 0 for n in names]
    cvals = [1 if consistent(theories[n], space) else 0 for n in names]
    x = range(len(names))
    ax0.bar([i - 0.2 for i in x], rvals, width=0.4, label="Realizable")
    ax0.bar([i + 0.2 for i in x], cvals, width=0.4, label="Consistent")
    ax0.set_xticks(list(x))
    ax0.set_xticklabels(names, rotation=20)
    ax0.set_yticks([0, 1])
    ax0.set_yticklabels(["False", "True"])
    ax0.set_title("Realizable == Consistent (the bridge)")
    ax0.legend()

    # serial cyclic relation s -> (s+1) mod 6, trajectory orbit
    n = 6
    pts = [(math.cos(2 * math.pi * k / n), math.sin(2 * math.pi * k / n)) for k in range(n)]
    traj = [0]
    for _ in range(11):
        traj.append((traj[-1] + 1) % n)
    xs = [pts[k][0] for k in traj]
    ys = [pts[k][1] for k in traj]
    ax1.plot(xs, ys, "-o")
    for k, (px, py) in enumerate(pts):
        ax1.annotate(str(k), (px, py))
    ax1.set_aspect("equal")
    ax1.set_title("Serial law -> eternal trajectory")
    fig.tight_layout()
    fig.savefig("logic_physics_bridge.png", dpi=150)
    print("wrote logic_physics_bridge.png")


if __name__ == "__main__":
    main()
