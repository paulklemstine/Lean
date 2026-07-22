from typing import Sequence


def inner(u: Sequence[float], v: Sequence[float]) -> float:
    return sum(a * b for a, b in zip(u, v))


def global_obstruction(D: Sequence[float], E: Sequence[float]) -> float:
    """Gram determinant of the Neron-Tate height pairing: <D,D><E,E> - <D,E>^2.

    Nonnegative by Cauchy-Schwarz; zero iff D, E are linearly dependent
    (in particular if either is a torsion/zero class).
    """
    dd, ee, de = inner(D, D), inner(E, E), inner(D, E)
    return dd * ee - de * de
