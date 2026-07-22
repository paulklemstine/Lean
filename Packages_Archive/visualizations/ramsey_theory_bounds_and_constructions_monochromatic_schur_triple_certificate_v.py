from typing import Callable, List, Tuple

Coloring = Callable[[int], int]

def monochromatic_schur_triples(n: int, color: Coloring
                                ) -> List[Tuple[int, int, int]]:
    bad: List[Tuple[int, int, int]] = []
    for x in range(1, n + 1):
        for y in range(x, n + 1):
            z = x + y
            if z > n:
                break
            if color(x) == color(y) == color(z):
                bad.append((x, y, z))
    return bad

def is_schur_coloring(n: int, color: Coloring) -> bool:
    return len(monochromatic_schur_triples(n, color)) == 0
