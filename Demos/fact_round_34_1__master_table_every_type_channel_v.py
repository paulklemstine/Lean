#!/usr/bin/env python3
"""
The Master Table of splitting-type channels, degrees 3..6 and beyond.

Everything is computed by brute-force enumeration over the Galois group
(uniform Frobenius, as predicted by the Chebotarev density theorem) and
compared against the closed forms of the paper:

  * cyclic group C_n  : Frobenius = uniform a in Z/n, type T = order of a,
                        root count R = n if T = 1 else 0;
  * dihedral group D_n: acting on the n vertices of the regular n-gon
                        (the n roots of x^n - a), type T = number of fixed
                        vertices, dial = rotation character (0 on rotations,
                        1 on reflections).

Self-contained: only the Python standard library is used.
"""
from __future__ import annotations

from collections import Counter
from math import gcd, log2
from typing import Callable, Hashable, Iterable, List, Sequence, Tuple

L3: float = log2(3)
L5: float = log2(5)


# ---------------------------------------------------------------------------
# Counting entropy on a finite uniform source
# ---------------------------------------------------------------------------
def entropy(values: Iterable[Hashable]) -> float:
    """Shannon entropy (bits) of the empirical distribution of `values`."""
    c = Counter(values)
    n = sum(c.values())
    return -sum(v / n * log2(v / n) for v in c.values())


def cond_entropy(pairs: Sequence[Tuple[Hashable, Hashable]]) -> float:
    """H(X | Y) for a uniform source listed as (x, y) pairs."""
    return entropy(pairs) - entropy(y for _, y in pairs)


def mutual_info(pairs: Sequence[Tuple[Hashable, Hashable]]) -> float:
    """I(X ; Y) = H(X) - H(X | Y)."""
    return entropy(x for x, _ in pairs) - cond_entropy(pairs)


def pin_ent(n: int) -> float:
    """Pinning entropy h(1/n) = log2 n - ((n-1)/n) log2(n-1)."""
    if n <= 1:
        return 0.0
    return log2(n) - (n - 1) / n * log2(n - 1)


# ---------------------------------------------------------------------------
# Cyclic channel C_n
# ---------------------------------------------------------------------------
def cyc_type(n: int, a: int) -> int:
    """Splitting type of a Frobenius a in Z/n: its order n / gcd(a, n)."""
    return n // gcd(a, n)


def cyc_root_count(n: int, t: int) -> int:
    """Number of roots mod p of a defining polynomial: n iff p splits completely."""
    return n if t == 1 else 0


def cyclic_type_entropy(n: int) -> float:
    return entropy(cyc_type(n, a) for a in range(n))


def cyclic_root_count_entropy(n: int) -> float:
    return entropy(cyc_root_count(n, cyc_type(n, a)) for a in range(n))


def totient(d: int) -> int:
    return sum(1 for k in range(1, d + 1) if gcd(k, d) == 1)


def cyclic_type_entropy_totient(n: int) -> float:
    """Closed form H(T) = log2 n - (1/n) sum_{d | n} phi(d) log2 phi(d)."""
    s = sum(totient(d) * log2(totient(d)) for d in range(1, n + 1) if n % d == 0)
    return log2(n) - s / n


def semiprime_pair_info(n: int) -> float:
    """I((T_p, T_q) ; T_pq): the pair of types of two independent Frobenius
    elements a, b versus the type of the product class a + b."""
    pairs = [((cyc_type(n, a), cyc_type(n, b)), cyc_type(n, (a + b) % n))
             for a in range(n) for b in range(n)]
    return mutual_info(pairs)


# ---------------------------------------------------------------------------
# Dihedral channel D_n
# ---------------------------------------------------------------------------
Elem = Tuple[str, int]  # ("r", i) rotation by i, ("s", i) reflection v -> i - v


def dihedral(n: int) -> List[Elem]:
    return [("r", i) for i in range(n)] + [("s", i) for i in range(n)]


def act(g: Elem, v: int, n: int) -> int:
    kind, i = g
    return (v + i) % n if kind == "r" else (i - v) % n


def fix_count(g: Elem, n: int) -> int:
    return sum(1 for v in range(n) if act(g, v, n) == v)


def rot_sign(g: Elem) -> int:
    return 0 if g[0] == "r" else 1


def dihedral_channel(n: int) -> Tuple[float, float, float]:
    """(H(T), H(T | rotSign), I(rotSign ; T)) for D_n acting on the n-gon."""
    pairs = [(fix_count(g, n), rot_sign(g)) for g in dihedral(n)]
    h = entropy(t for t, _ in pairs)
    c = cond_entropy(pairs)
    return h, c, h - c


def dihedral_type_entropy_closed(n: int) -> float:
    if n % 2 == 1:
        return 1 + pin_ent(n) / 2
    m = n // 2
    return log2(4 * m) - ((3 * m - 1) * log2(3 * m - 1) + m * log2(m)) / (4 * m)


def binary_entropy(p: float) -> float:
    return -p * log2(p) - (1 - p) * log2(1 - p)


# ---------------------------------------------------------------------------
# The published master table (closed forms)
# ---------------------------------------------------------------------------
TABLE = {
    3: (L3 - 2 / 3, L3 - 2 / 3, L3 - 10 / 9, 2 / 3 + L3 / 2, L3 / 2 - 1 / 3, 1.0),
    4: (3 / 2, 2 - 3 * L3 / 4, 5 / 4, 11 / 4 - 5 * L5 / 8, 3 / 2 - 3 * L3 / 8,
        5 / 4 + 3 * L3 / 8 - 5 * L5 / 8),
    5: (L5 - 8 / 5, L5 - 8 / 5, L5 + 12 * L3 / 25 - 72 / 25, 1 / 5 + L5 / 2,
        L5 / 2 - 4 / 5, 1.0),
    6: (1 / 3 + L3, 1 + L3 - 5 * L5 / 6, L3 - 1 / 9, 3 * L3 / 4,
        1 + L3 / 2 - 5 * L5 / 12, L3 / 4 + 5 * L5 / 12 - 1),
}
COLS = ["H(T) C_n", "H(#roots)", "I_pair", "H(T) D_n", "H(T|rot)", "I(rot;T)"]


def check(label: str, got: float, want: float, tol: float = 1e-12) -> None:
    ok = abs(got - want) < tol
    print(f"    {label:<12} enumerated {got: .10f}   closed form {want: .10f}   "
          f"{'OK' if ok else 'MISMATCH'}")
    assert ok


def main() -> None:
    print("=" * 78)
    print("1. The master table, degrees 3..6: enumeration vs closed forms")
    print("=" * 78)
    for n in (3, 4, 5, 6):
        print(f"  degree {n}")
        h, c, i = dihedral_channel(n)
        got = (cyclic_type_entropy(n), cyclic_root_count_entropy(n),
               semiprime_pair_info(n), h, c, i)
        for lab, g, w in zip(COLS, got, TABLE[n]):
            check(lab, g, w)

    print("\n2. General laws, tested for n = 3..30")
    for n in range(3, 31):
        assert abs(cyclic_root_count_entropy(n) - pin_ent(n)) < 1e-12
        assert abs(cyclic_type_entropy(n) - cyclic_type_entropy_totient(n)) < 1e-12
        h, c, i = dihedral_channel(n)
        assert abs(h - dihedral_type_entropy_closed(n)) < 1e-12
        if n % 2:
            assert abs(c - pin_ent(n) / 2) < 1e-12 and abs(i - 1) < 1e-12
        else:
            assert abs(c - (pin_ent(n) / 2 + 0.5)) < 1e-12 and i < 1
    print("   root count = pinning entropy; totient formula; dihedral closed forms;")
    print("   dial = 1 bit exactly at odd n  ... all confirmed.")

    print("\n3. Root count is lossless iff n is prime")
    for n in range(2, 21):
        loss = cyclic_type_entropy(n) - cyclic_root_count_entropy(n)
        prime = all(n % d for d in range(2, n))
        print(f"   n={n:2d}  loss = {loss:.6f}  {'prime' if prime else ''}")
        assert (abs(loss) < 1e-12) == prime

    print("\n4. Binary cap of the semiprime pair channel (odd < 1 < even)")
    for n in (3, 4, 5, 6):
        print(f"   n={n}  I_pair = {semiprime_pair_info(n):.6f}")

    print("\n5. Abelian saturation along odd degrees:  share = 1/(1 + h(1/n)/2)")
    for n in (3, 5, 7, 11, 21, 51, 101, 1001, 10001):
        print(f"   n={n:6d}  residue h(1/n)/2 = {pin_ent(n) / 2:.6f}  "
              f"share = {1 / (1 + pin_ent(n) / 2):.6f}")

    print("\n6. Even-degree dial (open conjecture: limit h(1/4) - 1/2 = "
          f"{binary_entropy(0.25) - 0.5:.6f})")
    for n in (4, 6, 8, 10, 20, 40, 100, 400):
        _, _, i = dihedral_channel(n)
        print(f"   n={n:4d}  I(rot;T) = {i:.6f}")


if __name__ == "__main__":
    main()
