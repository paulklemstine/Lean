from __future__ import annotations
from typing import Sequence

def analyze(signal: Sequence[float]) -> list[tuple[int, float, float, float]]:
    if not signal:
        raise ValueError("signal must be nonempty")
    energy = sum(x*x for x in signal)
    rows = []
    for k in range(len(signal)):
        corr = sum(signal[i]*signal[(i+k)%len(signal)] for i in range(len(signal)))
        cost = sum((signal[i]-signal[(i+k)%len(signal)])**2 for i in range(len(signal)))
        rows.append((k, corr, cost, 2*corr-(2*energy-cost)))
    return rows

if __name__ == "__main__":
    for row in analyze([1.0, 2.0, 1.0, 2.0]):
        print(row)
