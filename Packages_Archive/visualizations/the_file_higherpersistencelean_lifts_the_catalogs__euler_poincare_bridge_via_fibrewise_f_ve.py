from itertools import combinations
from typing import Dict, List, Sequence, Tuple

Face = Tuple[int, ...]

def f_vector(faces: Sequence[Face]) -> Dict[int, int]:
    fv: Dict[int, int] = {}
    for f in faces:
        if f:
            fv[len(f)] = fv.get(len(f), 0) + 1
    return fv

def euler_char_fin(faces: Sequence[Face]) -> int:
    return sum((-1) ** (len(f) - 1) for f in faces if f)

def euler_from_fvector(fv: Dict[int, int]) -> int:
    return sum((-1) ** (k - 1) * c for k, c in fv.items())

def full_simplex_faces(n: int) -> List[Face]:
    out: List[Face] = []
    for k in range(1, n + 1):
        out.extend(combinations(range(n), k))
    return out
