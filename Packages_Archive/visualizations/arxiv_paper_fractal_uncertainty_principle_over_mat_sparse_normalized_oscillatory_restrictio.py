from __future__ import annotations
import cmath
import math
from typing import Callable, Sequence

def restricted_transform(x_set: Sequence[int], y_set: Sequence[int], n: int,
                         signal: Callable[[int], complex],
                         phase: Callable[[int, int], float]) -> list[complex]:
    return [sum(cmath.exp(1j * phase(y, x)) * signal(x) for x in x_set)
            / math.sqrt(n) for y in y_set]

def energy(zs: Sequence[complex]) -> float:
    return sum(abs(z) ** 2 for z in zs)

if __name__ == "__main__":
    n = 125
    x_set = [0, 1, 5, 6, 25, 26, 30, 31]
    y_set = [0, 2, 10, 12, 50, 52, 60, 62]
    signal = lambda x: complex(math.cos(x), math.sin(x / 3))
    phase = lambda y, x: 2 * math.pi * x * y / n
    output = restricted_transform(x_set, y_set, n, signal, phase)
    e_in = energy([signal(x) for x in x_set])
    e_out = energy(output)
    bound = len(x_set) * len(y_set) * e_in / n
    print("input energy", e_in)
    print("output energy", e_out)
    print("universal bound", bound)
    assert e_out <= bound + 1e-12
