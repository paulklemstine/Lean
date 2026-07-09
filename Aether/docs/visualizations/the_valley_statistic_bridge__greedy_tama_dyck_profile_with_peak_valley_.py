"""Visualize a Dyck path profile and highlight its peaks and valleys,
confirming the peak = valley + 1 alternation identity."""
from __future__ import annotations
from typing import List, Tuple


def profile(path: Tuple[int, ...]) -> str:
    heights: List[int] = [0]
    for s in path:
        heights.append(heights[-1] + s)
    top = max(heights)
    rows: List[str] = []
    for level in range(top, 0, -1):
        row = ""
        for i in range(len(path)):
            up = heights[i] + (1 if path[i] == 1 else 0)
            row += "/" if (path[i] == 1 and heights[i] + 1 == level) else \
                   ("\\" if (path[i] == -1 and heights[i] == level) else " ")
        rows.append(row)
    return "\n".join(rows)


def peaks_valleys(path: Tuple[int, ...]) -> Tuple[int, int]:
    pk = sum(1 for a, b in zip(path, path[1:]) if a == 1 and b == -1)
    vl = sum(1 for a, b in zip(path, path[1:]) if a == -1 and b == 1)
    return pk, vl


if __name__ == "__main__":
    p = (1, 1, -1, 1, -1, -1, 1, -1)
    word = "".join("U" if s == 1 else "D" for s in p)
    pk, vl = peaks_valleys(p)
    print(f"path = {word}")
    print(profile(p))
    print(f"peaks = {pk}, valleys = {vl}, peaks - valleys = {pk - vl}")
