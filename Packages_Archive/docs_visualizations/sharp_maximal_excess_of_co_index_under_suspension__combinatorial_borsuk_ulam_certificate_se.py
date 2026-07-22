from itertools import combinations, product
from typing import List, Tuple

OctVertex = Tuple[int, int]

def oct_vertices(n: int) -> List[OctVertex]:
    return [(i, s) for i in range(n + 1) for s in (+1, -1)]

def is_oct_face(s) -> bool:
    axes = [i for (i, _) in s]
    return len(axes) == len(set(axes))

def oct_alpha(v: OctVertex) -> OctVertex:
    i, s = v
    return (i, -s)

def _faces(vertices):
    return [combo for k in range(len(vertices) + 1)
            for combo in combinations(vertices, k) if is_oct_face(list(combo))]

def exists_equivariant_simplicial(n: int, k: int) -> bool:
    src, tgt = oct_vertices(n), oct_vertices(k)
    src_faces = _faces(src)
    for choice in product(tgt, repeat=n + 1):
        def f(v: OctVertex, choice=choice) -> OctVertex:
            i, s = v
            img = choice[i]
            return img if s == +1 else oct_alpha(img)
        if (all(f(oct_alpha(v)) == oct_alpha(f(v)) for v in src)
                and all(is_oct_face([f(v) for v in face]) for face in src_faces)):
            return True
    return False
