from itertools import combinations
from typing import List, Tuple

def stable_sets(n: int, k: int, s: int) -> List[Tuple[int, ...]]:
    result: List[Tuple[int, ...]] = []
    for a in combinations(range(1, n + 1), k):
        gaps = [a[i + 1] - a[i] for i in range(k - 1)] + [n + a[0] - a[-1]]
        if min(gaps) >= s:
            result.append(a)
    return result

def main() -> None:
    for n in range(9, 14):
        sets = stable_sets(n, 3, 3)
        colors = {a: a[0] for a in sets}
        proper = all(colors[a] != colors[b] for a, b in combinations(sets, 2) if set(a).isdisjoint(b))
        print(n, len(sets), len(set(colors.values())), n - 6, proper)

if __name__ == "__main__":
    main()
