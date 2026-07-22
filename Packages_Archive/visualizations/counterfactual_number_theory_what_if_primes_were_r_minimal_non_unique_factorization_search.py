from __future__ import annotations


def in_H(n: int) -> bool:
    return n % 4 == 1


def is_H_irreducible(n: int) -> bool:
    if n < 2 or not in_H(n):
        return False
    a = 1
    while a * a <= n:
        if n % a == 0 and a > 1 and (n // a) > 1 and in_H(a) and in_H(n // a):
            return False
        a += 1
    return True


def smallest_nonunique(limit: int) -> int | None:
    """Return the least element of H below `limit` with two distinct
    factorizations into H-irreducibles, or None if none is found."""
    irr = [m for m in range(2, limit + 1) if is_H_irreducible(m)]

    def factorizations(n: int) -> set[tuple[int, ...]]:
        out: set[tuple[int, ...]] = set()

        def rec(rem: int, start: int, acc: list[int]) -> None:
            if rem == 1:
                if acc:
                    out.add(tuple(sorted(acc)))
                return
            for p in irr:
                if p < start or p > rem:
                    continue
                if rem % p == 0:
                    acc.append(p)
                    rec(rem // p, p, acc)
                    acc.pop()

        rec(n, 2, [])
        return out

    for n in range(5, limit + 1):
        if in_H(n) and len(factorizations(n)) >= 2:
            return n
    return None
