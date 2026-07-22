from __future__ import annotations
from typing import Optional

def disjoint_count(window: str, word: str) -> int:
    count = pos = 0
    while (hit := window.find(word, pos)) >= 0:
        count += 1
        pos = hit + len(word)
    return count

def qualifies(window: str, m: int, r: int) -> bool:
    words = {window[i:i+m] for i in range(len(window)-m+1)}
    return any(disjoint_count(window, word) >= r for word in words)

def uniform_threshold(genome: str, m: int, r: int) -> Optional[int]:
    if not genome or not qualifies(genome, m, r):
        return None
    lo, hi = 1, len(genome)
    while lo < hi:
        mid = (lo + hi) // 2
        if all(qualifies(genome[i:i+mid], m, r) for i in range(len(genome)-mid+1)):
            hi = mid
        else:
            lo = mid + 1
    return lo

if __name__ == "__main__":
    print(uniform_threshold("ACGT" * 40 + "A" * 20, 4, 2))
