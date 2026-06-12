from typing import List, Tuple

Vec3 = Tuple[int, int, int]


def child_A(v: Vec3) -> Vec3:
    a, b, c = v
    return (a - 2 * b + 2 * c, 2 * a - b + 2 * c, 2 * a - 2 * b + 3 * c)


def child_B(v: Vec3) -> Vec3:
    a, b, c = v
    return (a + 2 * b + 2 * c, 2 * a + b + 2 * c, 2 * a + 2 * b + 3 * c)


def child_C(v: Vec3) -> Vec3:
    a, b, c = v
    return (-a + 2 * b + 2 * c, -2 * a + b + 2 * c, -2 * a + 2 * b + 3 * c)


def berggren_tree(max_hyp: int, seed: Vec3 = (3, 4, 5)) -> List[Vec3]:
    """All primitive Pythagorean triples with hypotenuse <= max_hyp,
    each produced exactly once. Depth is O(log max_hyp)."""
    out: List[Vec3] = []
    stack: List[Vec3] = [seed]
    while stack:
        v = stack.pop()
        if v[2] > max_hyp:
            continue
        out.append(v)
        for child in (child_A(v), child_B(v), child_C(v)):
            if child[2] <= max_hyp:
                stack.append(child)
    return out
