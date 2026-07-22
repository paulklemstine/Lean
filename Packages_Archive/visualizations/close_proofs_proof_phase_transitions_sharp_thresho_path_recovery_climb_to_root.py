from typing import List, Tuple

Vec3 = Tuple[int, int, int]
Mat3 = List[List[int]]

INV_A: Mat3 = [[1, 2, -2], [-2, -1, 2], [-2, -2, 3]]
INV_B: Mat3 = [[1, 2, -2], [2, 1, -2], [-2, -2, 3]]
INV_C: Mat3 = [[-1, -2, 2], [2, 1, -2], [-2, -2, 3]]


def mat_vec(m: Mat3, v: Vec3) -> Vec3:
    return tuple(sum(m[i][k] * v[k] for k in range(3)) for i in range(3))  # type: ignore


def climb_to_root(v: Vec3) -> List[str]:
    """Recover the unique A/B/C address of a primitive triple by applying the
    integer inverses, always choosing the one keeping coords positive and
    strictly shrinking the hypotenuse. O(log c) steps."""
    path: List[str] = []
    cur = v
    while cur != (3, 4, 5):
        for name, inv in (("A", INV_A), ("B", INV_B), ("C", INV_C)):
            cand = mat_vec(inv, cur)
            if all(x > 0 for x in cand) and cand[2] < cur[2]:
                path.append(name)
                cur = cand
                break
        else:
            raise ValueError(f"no valid parent for {v}")
    return list(reversed(path))
