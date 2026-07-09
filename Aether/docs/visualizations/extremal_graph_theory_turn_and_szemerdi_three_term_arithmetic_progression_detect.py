from typing import Optional, Set, Tuple


def find_3ap(A: Set[int], N: int) -> Optional[Tuple[int, int]]:
    for a in A:
        for d in range(1, N):
            if (a + d) % N in A and (a + 2 * d) % N in A:
                return a, d
    return None


def count_3aps(A: Set[int], N: int) -> int:
    total = 0
    for a in A:
        for d in range(1, N):
            if (a + d) % N in A and (a + 2 * d) % N in A:
                total += 1
    return total
