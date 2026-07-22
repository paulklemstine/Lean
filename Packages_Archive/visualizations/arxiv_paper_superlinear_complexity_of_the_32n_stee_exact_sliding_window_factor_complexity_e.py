from collections import defaultdict
from typing import DefaultDict, Dict, List, Sequence, Tuple

def factor_occurrences(word: Sequence[int], k: int) -> Dict[Tuple[int, ...], List[int]]:
    if not 0 <= k <= len(word):
        raise ValueError("invalid factor length")
    table: DefaultDict[Tuple[int, ...], List[int]] = defaultdict(list)
    for i in range(len(word)-k+1):
        table[tuple(word[i:i+k])].append(i)
    return dict(table)

if __name__ == "__main__":
    word=[1,-2,0,1,1,-2,1]
    for k in range(1,5):
        table=factor_occurrences(word,k)
        print(f"k={k}: complexity={len(table)}, factors={list(table)}")
