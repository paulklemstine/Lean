"""ASCII bar chart of the valley distribution of Dyck lower endpoints for a
chosen semilength, illustrating the symmetric unimodal Narayana shape."""
from __future__ import annotations
from math import comb
from typing import List


def narayana(n: int, k: int) -> int:
    if n == 0:
        return 1 if k == 0 else 0
    if k < 1 or k > n:
        return 0
    return comb(n, k) * comb(n, k - 1) // n


def bar_chart(n: int) -> str:
    counts: List[int] = [narayana(n, k + 1) for k in range(0, n)]
    peak = max(counts) if counts else 1
    width = 50
    lines = [f"Valley distribution of Dyck lower endpoints, semilength n = {n}", ""]
    for k, c in enumerate(counts):
        bar = "#" * max(1, round(width * c / peak))
        lines.append(f"  k={k:<2} | {bar} {c}")
    lines.append(f"  total = {sum(counts)} (Catalan number C_{n})")
    return "\n".join(lines)


if __name__ == "__main__":
    print(bar_chart(8))
