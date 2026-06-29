from itertools import product
from typing import Tuple, List, Dict

Mat = Tuple[int, int, int, int]  # [[a,b],[c,d]]

def det(p: int, x: Mat) -> int:
    a, b, c, d = x
    return (a * d - b * c) % p

def charpoly_has_root(p: int, x: Mat) -> bool:
    a, b, c, d = x
    tr, dt = (a + d) % p, det(p, x)
    return any((r * r - tr * r + dt) % p == 0 for r in range(p))

def proj_key(p: int, v: Tuple[int, int]) -> Tuple[int, int]:
    if v[0] % p != 0:
        inv = pow(v[0], -1, p)
        return (1, (v[1] * inv) % p)
    return (0, 1)

def eigen_proj(p: int, x: Mat) -> set:
    a, b, c, d = x
    out = set()
    for v0, v1 in product(range(p), repeat=2):
        if v0 == 0 and v1 == 0:
            continue
        w = ((a * v0 + b * v1) % p, (c * v0 + d * v1) % p)
        ref = v0 if v0 % p != 0 else v1
        scal = (w[0] if v0 % p != 0 else w[1]) * pow(ref, -1, p) % p
        if w == ((scal * v0) % p, (scal * v1) % p):
            out.add(proj_key(p, (v0, v1)))
    return out

def verify_gl2_certificate(p: int, s: Mat, t: Mat) -> Dict[str, object]:
    if det(p, s) == 0 or det(p, t) == 0:
        return {'certified': False, 'reason': 'singular'}
    if charpoly_has_root(p, s):
        return {'certified': False, 'reason': 'reducible charpoly of s'}
    common = eigen_proj(p, s) & eigen_proj(p, t)
    return {'certified': not common,
            'common_eigenvectors': sorted(common)}
