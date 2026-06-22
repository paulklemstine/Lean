from typing import Dict, List, Set, Tuple

Frame = Tuple[List[object], Set[Tuple[object, object]]]

def rank(frame: Frame) -> Dict[object, int]:
    worlds, R = frame
    memo: Dict[object, int] = {}
    def succ(w: object) -> Set[object]:
        return {v for (a, v) in R if a == w}
    def r(w: object) -> int:
        if w in memo:
            return memo[w]
        s = succ(w)
        memo[w] = 0 if not s else 1 + max(r(v) for v in s)
        return memo[w]
    return {w: r(w) for w in worlds}
