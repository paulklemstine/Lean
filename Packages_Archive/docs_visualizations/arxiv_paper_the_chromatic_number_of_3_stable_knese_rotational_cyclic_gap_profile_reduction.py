from collections import Counter
from itertools import combinations
from typing import Counter as CounterType, Tuple

def profiles(n: int) -> CounterType[Tuple[int, int, int]]:
    counts: CounterType[Tuple[int, int, int]] = Counter()
    for a, b, c in combinations(range(1, n + 1), 3):
        gaps = (b-a, c-b, n+a-c)
        if min(gaps) >= 3:
            rotations = [gaps[i:]+gaps[:i] for i in range(3)]
            counts[min(rotations)] += 1
    return counts

def main() -> None:
    for n in range(9, 13):
        print(f"n={n}, slack={n-9}, profiles={dict(profiles(n))}")

if __name__ == "__main__": main()
