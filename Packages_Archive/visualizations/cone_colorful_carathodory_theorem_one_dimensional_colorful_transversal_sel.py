from typing import List, Sequence, Tuple

TOL = 1e-12


def colorful_transversal_1d(
    classes: Sequence[Sequence[float]],
) -> Tuple[List[float], List[float]]:
    r = len(classes)
    if r < 2:
        raise ValueError("threshold r >= 2 required")
    for i, cls in enumerate(classes):
        zeros = [x for x in cls if abs(x) <= TOL]
        if zeros:
            t = [zeros[0] if j == i else classes[j][0] for j in range(r)]
            w = [1.0 if j == i else 0.0 for j in range(r)]
            return t, w
    t: List[float] = []
    for j, cls in enumerate(classes):
        if j == 0:
            t.append(next(x for x in cls if x > TOL))
        elif j == 1:
            t.append(next(x for x in cls if x < -TOL))
        else:
            t.append(cls[0])
    a, b = t[0], t[1]
    w = [0.0] * r
    w[0], w[1] = -b, a
    return t, w
