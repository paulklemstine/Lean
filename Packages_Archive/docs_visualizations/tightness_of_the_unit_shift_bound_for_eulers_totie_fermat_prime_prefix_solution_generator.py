from typing import Tuple

def fermat_number(k: int) -> int:
    return 2 ** (2 ** k) + 1

def fermat_family_solution(m: int) -> Tuple[int, int]:
    N = 1
    for k in range(m):
        N *= fermat_number(k)
    assert N + 1 == 2 ** (2 ** m)
    common_totient = 2 ** (2 ** m - 1)
    return N, common_totient
