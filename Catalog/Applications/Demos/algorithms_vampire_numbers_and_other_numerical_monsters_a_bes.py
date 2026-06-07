"""
Algorithms for Vampire Numbers and Arithmetic Creatures

Type-hinted implementations for enumerating and classifying vampire numbers,
ghost numbers, werewolf numbers, and computing creature spectra.
"""

from collections import Counter
from typing import List, Tuple, Optional, Dict, Set


def digits_of(n: int) -> List[int]:
    """Return the list of decimal digits of n."""
    if n == 0:
        return [0]
    result = []
    while n > 0:
        result.append(n % 10)
        n //= 10
    return result


def digit_multiset(n: int) -> Counter:
    """Return the multiset (Counter) of decimal digits of n."""
    return Counter(digits_of(n))


def digit_set(n: int) -> Set[int]:
    """Return the set of distinct decimal digits of n."""
    return set(digits_of(n))


def num_digits(n: int) -> int:
    """Return the number of decimal digits of n."""
    if n == 0:
        return 1
    count = 0
    while n > 0:
        count += 1
        n //= 10
    return count


def is_vampire(v: int) -> Optional[Tuple[int, int]]:
    """Check if v is a vampire number. Returns (x, y) fangs if yes, None otherwise.

    A vampire number v has 2n digits (n >= 2) and v = x * y where:
    - x, y each have n digits
    - The digit multiset of v equals the combined digit multisets of x, y
    - Not both x and y end in 0
    """
    nd = num_digits(v)
    if nd < 4 or nd % 2 != 0:
        return None
    n = nd // 2
    lo = 10 ** (n - 1)
    hi = 10 ** n
    dv = digit_multiset(v)
    for x in range(lo, hi):
        if v % x != 0:
            continue
        y = v // x
        if y < lo or y >= hi:
            continue
        if x > y:
            break
        if x % 10 == 0 and y % 10 == 0:
            continue
        if digit_multiset(x) + digit_multiset(y) == dv:
            return (x, y)
    return None


def creature_spectrum(v: int, x: int, y: int) -> Dict[str, int]:
    """Compute the creature spectrum of the factorization v = x * y.

    Returns a dict with keys 'overlap', 'deficit', 'surplus':
    - overlap = |digitMultiset(v) ∩ (digitMultiset(x) + digitMultiset(y))|
    - deficit = |digitMultiset(v) \\ (digitMultiset(x) + digitMultiset(y))|
    - surplus = |(digitMultiset(x) + digitMultiset(y)) \\ digitMultiset(v)|
    """
    dv = digit_multiset(v)
    dxy = digit_multiset(x) + digit_multiset(y)
    overlap = sum((dv & dxy).values())
    deficit = sum((dv - dxy).values())
    surplus = sum((dxy - dv).values())
    return {'overlap': overlap, 'deficit': deficit, 'surplus': surplus}


def is_ghost(v: int, x: int, y: int) -> bool:
    """Check if v = x * y is a ghost-type factorization.

    Ghost: digit sets of x and y are completely disjoint from digit set of v.
    """
    dv = digit_set(v)
    dx = digit_set(x)
    dy = digit_set(y)
    return len(dv & dx) == 0 and len(dv & dy) == 0


def find_ghost_factorizations(v: int) -> List[Tuple[int, int]]:
    """Find all ghost-type factorizations of v."""
    results = []
    dv = digit_set(v)
    for x in range(2, int(v**0.5) + 1):
        if v % x != 0:
            continue
        y = v // x
        if y <= 1:
            continue
        dx = digit_set(x)
        dy = digit_set(y)
        if len(dv & dx) == 0 and len(dv & dy) == 0:
            results.append((x, y))
    return results


def is_werewolf(v: int, x: int, y: int) -> bool:
    """Check if v = x * y is a werewolf-type factorization.

    Werewolf: the combined digit multiset of x and y shares exactly
    one digit (with multiplicity) with v's digit multiset.
    """
    dv = digit_multiset(v)
    dxy = digit_multiset(x) + digit_multiset(y)
    overlap = sum((dv & dxy).values())
    return overlap == 1


def valid_fang_residues_mod9() -> List[Tuple[int, int]]:
    """Enumerate all valid fang residue pairs (a, b) mod 9.

    The constraint is a*b ≡ a+b (mod 9), equivalently (a-1)(b-1) ≡ 1 (mod 9).
    """
    pairs = []
    for a in range(9):
        for b in range(9):
            if (a * b) % 9 == (a + b) % 9:
                pairs.append((a, b))
    return pairs


def enumerate_vampires(limit: int) -> List[Tuple[int, int, int]]:
    """Enumerate all vampire numbers up to limit.

    Returns list of (v, x, y) tuples.
    """
    vampires = []
    # Only check 4-digit, 6-digit, 8-digit numbers
    nd = 4
    while 10**(nd-1) < limit:
        n = nd // 2
        lo = 10**(n-1)
        hi = 10**n
        v_lo = max(10**(nd-1), lo * lo)
        v_hi = min(limit, 10**nd)
        for x in range(lo, hi):
            y_lo = max(lo, (v_lo + x - 1) // x)
            y_hi = min(hi - 1, (v_hi - 1) // x)
            if y_lo > y_hi:
                continue
            for y in range(max(x, y_lo), y_hi + 1):
                v = x * y
                if v >= v_hi or v < v_lo:
                    continue
                if x % 10 == 0 and y % 10 == 0:
                    continue
                dv = digit_multiset(v)
                dxy = digit_multiset(x) + digit_multiset(y)
                if dv == dxy:
                    vampires.append((v, x, y))
        nd += 2
    vampires.sort()
    return vampires


def enumerate_ghosts(limit: int) -> List[Tuple[int, int, int]]:
    """Enumerate ghost-type factorizations up to limit."""
    ghosts = []
    for v in range(4, limit):
        for x in range(2, int(v**0.5) + 1):
            if v % x != 0:
                continue
            y = v // x
            if y <= 1:
                continue
            if is_ghost(v, x, y):
                ghosts.append((v, x, y))
                break  # just one factorization per v
    return ghosts


def vampire_density(k: int) -> float:
    """Compute the density of vampire numbers in [10^(2k), 10^(2k+2))."""
    lo = 10**(2*k)
    hi = 10**(2*k + 2)
    count = len([v for v, _, _ in enumerate_vampires(hi) if v >= lo])
    return count / (hi - lo)
