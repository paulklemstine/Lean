from typing import Dict, Sequence, Tuple
Point = Tuple[int, int]
def build_intersection_index(c: Sequence[Sequence[int]], r: Sequence[Sequence[int]]) -> Dict[Tuple[int,int], Point]:
    index: Dict[Tuple[int,int], Point] = {}
    for i, row in enumerate(c):
        for j, q in enumerate(row):
            pair = (q, r[i][j])
            if pair in index: raise ValueError("cross-coordinate pair is not unique")
            index[pair] = (i, j)
    return index
