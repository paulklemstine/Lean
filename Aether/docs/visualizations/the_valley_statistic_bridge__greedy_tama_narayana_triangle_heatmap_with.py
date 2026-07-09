"""Render the Narayana triangle (valley distribution of Dyck lower
endpoints) as a text heatmap, with Catalan row sums annotated."""
from __future__ import annotations
from math import comb


def narayana(n: int, k: int) -> int:
    if n == 0:
        return 1 if k == 0 else 0
    if k < 1 or k > n:
        return 0
    return comb(n, k) * comb(n, k - 1) // n


def catalan(n: int) -> int:
    return comb(2 * n, n) // (n + 1)


def render(max_n: int = 8) -> str:
    lines = ["Narayana triangle N(n,k)  (row n sums to Catalan C_n)", ""]
    for n in range(1, max_n + 1):
        row = [narayana(n, k) for k in range(1, n + 1)]
        cells = "  ".join(f"{v:>5}" for v in row)
        lines.append(f"n={n:<2} | {cells}   | sum = {sum(row)} = C_{n} ({catalan(n)})")
    return "\n".join(lines)


if __name__ == "__main__":
    print(render(8))
