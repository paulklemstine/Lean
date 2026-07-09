"""Erdos-Szekeres monotone-subsequence extraction: the engine of the
Descent Theorem. Any long enough sequence of distinct comparable values contains
a long monotone run; in an infinite co-wellfounded chain the ascending option is
bounded, so the extracted run must descend, giving the copy of N^op."""
from __future__ import annotations
from typing import List, Sequence


def longest_monotone(seq: Sequence[float], increasing: bool) -> List[int]:
    n = len(seq)
    if n == 0:
        return []
    length = [1] * n
    prev = [-1] * n
    for i in range(n):
        for j in range(i):
            better = seq[j] < seq[i] if increasing else seq[j] > seq[i]
            if better and length[j] + 1 > length[i]:
                length[i] = length[j] + 1
                prev[i] = j
    end = max(range(n), key=lambda i: length[i])
    out: List[int] = []
    while end != -1:
        out.append(end)
        end = prev[end]
    return out[::-1]


if __name__ == "__main__":
    window = [7, 2, 9, 1, 8, 3, 6, 0, 5, 4]
    inc = longest_monotone(window, increasing=True)
    dec = longest_monotone(window, increasing=False)
    print("labels        :", window)
    print("ascending run :", [window[i] for i in inc], "len", len(inc))
    print("descending run:", [window[i] for i in dec], "len", len(dec))
    print("The descending run is the N^op witness guaranteed by the theorem.")
