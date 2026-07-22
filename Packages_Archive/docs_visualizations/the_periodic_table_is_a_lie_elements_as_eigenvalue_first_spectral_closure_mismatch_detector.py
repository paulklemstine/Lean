from __future__ import annotations
from typing import Sequence

def first_mismatch(predicted: Sequence[int], observed: Sequence[int]) -> tuple[int, int, int] | None:
    for i, (p, o) in enumerate(zip(predicted, observed)):
        if p != o:
            return i, p, o
    return None

def compare(count: int = 6) -> None:
    coulomb = [n * (n + 1) * (2 * n + 1) // 3 for n in range(1, count + 1)]
    oscillator = [(n + 1) * (n + 2) * (n + 3) // 3 for n in range(count)]
    print(first_mismatch(coulomb, [2, 10, 18, 36, 54, 86]))
    print(first_mismatch(oscillator, [2, 8, 20, 28, 50, 82]))

if __name__ == "__main__":
    compare()
