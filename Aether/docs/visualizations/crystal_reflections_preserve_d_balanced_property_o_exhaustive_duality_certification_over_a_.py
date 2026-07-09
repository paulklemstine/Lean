from typing import List, Iterator


def partitions(n: int) -> Iterator[List[int]]:
    """Yield every partition of n as a weakly decreasing list of parts."""
    def gen(n: int, cap: int) -> Iterator[List[int]]:
        if n == 0:
            yield []
            return
        for first in range(min(n, cap), 0, -1):
            for rest in gen(n - first, first):
                yield [first] + rest
    yield from gen(n, n)


def conjugate(lam: List[int]) -> List[int]:
    if not lam:
        return []
    return [sum(1 for p in lam if p > j) for j in range(lam[0])]


def is_d_balanced(lam: List[int], d: int, e: int) -> bool:
    conj = conjugate(lam)
    for i, part in enumerate(lam):
        for j in range(part):
            arm = lam[i] - (j + 1)
            leg = conj[j] - (i + 1)
            if (arm + leg + 1) % e == 0 and arm % d != 0:
                return False
    return True


def is_leg_d_balanced(lam: List[int], d: int, e: int) -> bool:
    conj = conjugate(lam)
    for i, part in enumerate(lam):
        for j in range(part):
            arm = lam[i] - (j + 1)
            leg = conj[j] - (i + 1)
            if (arm + leg + 1) % e == 0 and leg % d != 0:
                return False
    return True


def verify_duality(nmax: int, d_vals: List[int], e_vals: List[int]) -> int:
    """Verify: transpose(lam) is d-balanced iff lam is leg-d-balanced.

    Returns the number of (partition, d, e) instances checked.
    """
    checked = 0
    for n in range(nmax + 1):
        for lam in partitions(n):
            t = conjugate(lam)
            for d in d_vals:
                for e in e_vals:
                    assert is_d_balanced(t, d, e) == is_leg_d_balanced(lam, d, e)
                    checked += 1
    return checked
