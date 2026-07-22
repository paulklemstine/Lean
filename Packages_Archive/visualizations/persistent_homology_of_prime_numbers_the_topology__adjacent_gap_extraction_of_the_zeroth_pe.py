from typing import Sequence

def gap_barcode(points: Sequence[float]) -> tuple[list[float], int]:
    xs = sorted(points)
    if len(xs) != len(set(xs)):
        raise ValueError("points must be distinct")
    deaths = sorted(b - a for a, b in zip(xs, xs[1:]))
    return deaths, (1 if xs else 0)

print(gap_barcode([2, 3, 5, 7, 11, 13]))
