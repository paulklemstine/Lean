from typing import List, Optional, Tuple

def verify_copy_free(chi: List[int], N: int,
                     pattern: Tuple[int, int, int] = (0, 2, 5)
                     ) -> Optional[Tuple[int, int]]:
    """
    Decide whether coloring chi (1-indexed as chi[i-1]) of {1..N} is free of
    monochromatic homothetic copies of `pattern`. Returns the first witnessing
    (b, a) or None if copy-free. Time Theta(N^2).
    """
    top = pattern[-1]
    a = 1
    while 1 + top * a <= N:
        b = 1
        while b + top * a <= N:
            if len({chi[b + a * s - 1] for s in pattern}) == 1:
                return (b, a)
            b += 1
        a += 1
    return None
