from __future__ import annotations


def is_squarefree(n: int) -> bool:
    n = abs(n)
    if n == 0:
        return False
    d = 2
    while d * d <= n:
        if n % (d * d) == 0:
            return False
        if n % d == 0:
            n //= d
        else:
            d += 1
    return True


def is_fundamental_discriminant(D: int) -> bool:
    if D == 0:
        return False
    if D % 4 == 1:
        return D != 1 and is_squarefree(D)
    if D % 4 == 0:
        e = D // 4
        return (e % 4 in (2, 3)) and is_squarefree(e)
    return False


def enumerate_characters(Q0: int) -> list[int]:
    out: list[int] = []
    for n in range(Q0 + 1):
        for D in (n, -n):
            if is_fundamental_discriminant(D):
                out.append(D)
    return sorted(set(out), key=lambda d: (abs(d), d))
