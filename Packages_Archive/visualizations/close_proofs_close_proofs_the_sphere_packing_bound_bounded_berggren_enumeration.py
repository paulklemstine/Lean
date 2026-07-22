from __future__ import annotations
from typing import List, Set, Tuple

Triple = Tuple[int, int, int]


def child_A(t: Triple) -> Triple:
    a, b, c = t
    return (a - 2 * b + 2 * c, 2 * a - b + 2 * c, 2 * a - 2 * b + 3 * c)


def child_B(t: Triple) -> Triple:
    a, b, c = t
    return (a + 2 * b + 2 * c, 2 * a + b + 2 * c, 2 * a + 2 * b + 3 * c)


def child_C(t: Triple) -> Triple:
    a, b, c = t
    return (-a + 2 * b + 2 * c, -2 * a + b + 2 * c, -2 * a + 2 * b + 3 * c)


def enumerate_triples(bound: int) -> Set[Triple]:
    """All primitive Pythagorean triples with hypotenuse <= bound."""
    result: Set[Triple] = set()
    stack: List[Triple] = [(3, 4, 5)]
    while stack:
        a, b, c = stack.pop()
        if c > bound:
            continue
        result.add((min(a, b), max(a, b), c))
        for ch in (child_A((a, b, c)), child_B((a, b, c)), child_C((a, b, c))):
            if ch[2] <= bound:
                stack.append(ch)
    return result


if __name__ == "__main__":
    triples = enumerate_triples(100)
    for t in sorted(triples):
        a, b, c = t
        assert a * a + b * b == c * c
        print(t)
    print(f"{len(triples)} primitive triples with hypotenuse <= 100")
