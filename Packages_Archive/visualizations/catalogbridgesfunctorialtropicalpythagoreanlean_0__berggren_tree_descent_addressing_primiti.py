from typing import Callable, List, Sequence, Tuple

Triple = Tuple[int, int, int]


def child_a(t: Triple) -> Triple:
    a, b, c = t
    return (a - 2 * b + 2 * c, 2 * a - b + 2 * c, 2 * a - 2 * b + 3 * c)


def child_b(t: Triple) -> Triple:
    a, b, c = t
    return (a + 2 * b + 2 * c, 2 * a + b + 2 * c, 2 * a + 2 * b + 3 * c)


def child_c(t: Triple) -> Triple:
    a, b, c = t
    return (-a + 2 * b + 2 * c, -2 * a + b + 2 * c, -2 * a + 2 * b + 3 * c)


CHILDREN: List[Callable[[Triple], Triple]] = [child_a, child_b, child_c]


def descend(word: Sequence[int], seed: Triple = (3, 4, 5)) -> Triple:
    """Return the primitive Pythagorean triple at the tree address `word`.

    Each letter in {0,1,2} selects branch A, B, or C. The map runs in
    O(len(word)) integer operations; the resulting hypotenuse grows
    geometrically, so the address length is Theta(log c)."""
    t = seed
    for k in word:
        t = CHILDREN[k](t)
    return t
