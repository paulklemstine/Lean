#!/usr/bin/env python3
"""
The Whole Exceeds the Sum -- numerical companion.

Self-contained demonstrations (standard library only) of the main results:

  1. Mutual information of observables on a finite probability space.
  2. The fibre-swap criterion: blind observables carry exactly zero bits.
  3. Sum labels on k uniform components of a finite abelian group Z_m:
     every proper sub-family is blind, the whole carries log2(m) bits.
  4. The capacity bound I(X;Y) <= log|labels| and saturation of the synergy.
  5. The Jacobi label of a unit modulo a squarefree odd N: each prime residue
     carries 0 bits, the whole residue carries exactly 1 bit.
  6. The four-types bound: a read of 1.8170 bits needs at least 4 label values,
     because log2(3) < 1.6 (3^5 = 243 < 256 = 2^8).
"""
from __future__ import annotations

import itertools
import math
import random
from collections import Counter
from fractions import Fraction
from typing import Callable, Dict, Hashable, Iterable, List, Sequence, Tuple, TypeVar

Omega = TypeVar("Omega")


# ---------------------------------------------------------------------------
# 1. Mutual information of observables
# ---------------------------------------------------------------------------
def joint_law(
    space: Sequence[Omega],
    weight: Callable[[Omega], float],
    X: Callable[[Omega], Hashable],
    Y: Callable[[Omega], Hashable],
) -> Dict[Tuple[Hashable, Hashable], float]:
    """Joint table p(a, b) = sum of weights of outcomes with X = a and Y = b."""
    table: Dict[Tuple[Hashable, Hashable], float] = Counter()
    for w in space:
        table[(X(w), Y(w))] += weight(w)
    return dict(table)


def mutual_information_bits(table: Dict[Tuple[Hashable, Hashable], float]) -> float:
    """I(X;Y) = sum p log2( p / (p_X p_Y) ), with the convention 0 log 0 = 0."""
    px: Dict[Hashable, float] = Counter()
    py: Dict[Hashable, float] = Counter()
    for (a, b), p in table.items():
        px[a] += p
        py[b] += p
    total = 0.0
    for (a, b), p in table.items():
        if p > 0:
            total += p * math.log2(p / (px[a] * py[b]))
    return 0.0 if abs(total) < 1e-12 else total


def info_bits(
    space: Sequence[Omega],
    X: Callable[[Omega], Hashable],
    Y: Callable[[Omega], Hashable],
) -> float:
    """Mutual information (bits) between X and Y under the uniform law on `space`."""
    n = len(space)
    return mutual_information_bits(joint_law(space, lambda _w: 1.0 / n, X, Y))


def entropy_bits(probs: Iterable[float]) -> float:
    return -sum(p * math.log2(p) for p in probs if p > 0)


# ---------------------------------------------------------------------------
# 2-4. Sum labels on (Z_m)^k
# ---------------------------------------------------------------------------
def sum_label_space(m: int, k: int) -> List[Tuple[int, ...]]:
    return list(itertools.product(range(m), repeat=k))


def demo_sum_label(m: int = 4, k: int = 3) -> None:
    print(f"\n=== Sum label on (Z_{m})^{k}: L(x) = x_1 + ... + x_{k} mod {m} ===")
    space = sum_label_space(m, k)
    L = lambda w: sum(w) % m
    whole = info_bits(space, lambda w: w, L)
    print(f"  whole tuple           : {whole:.6f} bits   (log2 {m} = {math.log2(m):.6f})")
    parts = 0.0
    for size in range(1, k):
        for S in itertools.combinations(range(k), size):
            v = info_bits(space, lambda w, S=S: tuple(w[i] for i in S), L)
            if size == 1:
                parts += v
            print(f"  sub-family {S!s:<12}: {v:.6f} bits")
    print(f"  synergy  I(whole) - sum_i I(x_i) = {whole - parts:.6f} bits")
    # k = 1: no emergence
    one = info_bits(sum_label_space(m, 1), lambda w: w[0], lambda w: w[0] % m)
    print(f"  k = 1 control         : single component carries {one:.6f} bits (no emergence)")


def demo_fibre_swap(m: int = 5, k: int = 2) -> None:
    print(f"\n=== Fibre-swap criterion on (Z_{m})^{k} ===")
    space = sum_label_space(m, k)
    L = lambda w: sum(w) % m
    # Swap fibre b -> b' by translating the LAST coordinate by b' - b; it fixes x_0.
    ok = True
    for b in range(m):
        for bp in range(m):
            tau = lambda w: w[:-1] + ((w[-1] + bp - b) % m,)
            for w in space:
                if tau(w)[0] != w[0] or ((L(tau(w)) == bp) != (L(w) == b)):
                    ok = False
    print(f"  translations of x_{k-1} fix x_0 and swap every pair of fibres: {ok}")
    table = joint_law(space, lambda _w: 1 / len(space), lambda w: w[0], L)
    counts = sorted(set(round(v * len(space)) for v in table.values()))
    print(f"  joint table of (x_0, L) is flat: every cell has count {counts}")


def demo_capacity(m: int = 4, k: int = 3, trials: int = 2000, seed: int = 1) -> None:
    print(f"\n=== Capacity bound: no observable beats log2 |A| = {math.log2(m):.3f} bits ===")
    rng = random.Random(seed)
    space = sum_label_space(m, k)
    L = lambda w: sum(w) % m
    best = 0.0
    for _ in range(trials):
        r = rng.randint(2, 12)
        f = {w: rng.randrange(r) for w in space}
        best = max(best, info_bits(space, lambda w: f[w], L))
    print(f"  best of {trials} random observables: {best:.6f} bits  (<= {math.log2(m):.6f})")
    print(f"  identity observable (the whole) : {info_bits(space, lambda w: w, L):.6f} bits")


# ---------------------------------------------------------------------------
# 5. Jacobi label at the semiprime / multi-prime level
# ---------------------------------------------------------------------------
def is_qr(p: int, a: int) -> bool:
    return any((x * x - a) % p == 0 for x in range(1, p))


def jacobi_bit(primes: Sequence[int], a: int) -> int:
    """Additive Jacobi parity: number of primes modulo which a is a non-residue, mod 2."""
    return sum(0 if is_qr(p, a) else 1 for p in primes) % 2


def jacobi_symbol(a: int, n: int) -> int:
    """Standard Jacobi symbol (a | n) for odd n > 0 via quadratic reciprocity."""
    a %= n
    result = 1
    while a:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a %= n
    return result if n == 1 else 0


def demo_jacobi(primes: Sequence[int]) -> None:
    N = math.prod(primes)
    units = [a for a in range(N) if math.gcd(a, N) == 1]
    J = lambda a: jacobi_bit(primes, a)
    print(f"\n=== Jacobi label of a uniform unit mod N = {N} = {' x '.join(map(str, primes))} ===")
    bridge = all((jacobi_symbol(a, N) == 1) == (J(a) == 0) for a in units)
    print(f"  J(a|N) = 1  <=>  Legendre bits sum to 0 (mod 2), for all units: {bridge}")
    for p in primes:
        print(f"  residue mod {p:<3}       : {info_bits(units, lambda a, p=p: a % p, J):.6f} bits")
    if len(primes) >= 3:
        for p, q in itertools.combinations(primes, 2):
            v = info_bits(units, lambda a, p=p, q=q: (a % p, a % q), J)
            print(f"  residues mod {p},{q:<5}: {v:.6f} bits   (a pair is still blind)")
    legendre_vec = lambda a: tuple(0 if is_qr(p, a) else 1 for p in primes)
    print(f"  Legendre-bit vector  : {info_bits(units, legendre_vec, J):.6f} bits")
    print(f"  full residue a mod N : {info_bits(units, lambda a: a, J):.6f} bits")
    c = Counter(J(a) for a in units)
    print(f"  label counts (J=+1 / J=-1): {c[0]} / {c[1]}")


def demo_lab_tables() -> None:
    print("\n=== Exact count tables (N = 15 and N = 105) ===")
    units15 = [a for a in range(15) if math.gcd(a, 15) == 1]
    t3 = Counter((a % 3, jacobi_bit([3, 5], a)) for a in units15)
    t5 = Counter((a % 5, jacobi_bit([3, 5], a)) for a in units15)
    print("  N=15, (a mod 3, label):", dict(sorted(t3.items())))
    print("  N=15, (a mod 5, label):", dict(sorted(t5.items())))
    units105 = [a for a in range(105) if math.gcd(a, 105) == 1]
    flat = all(
        sum(1 for a in units105 if a % 15 == r and jacobi_bit([3, 5, 7], a) == 0)
        == sum(1 for a in units105 if a % 15 == r and jacobi_bit([3, 5, 7], a) == 1)
        for r in range(15)
    )
    print(f"  N=105, every class mod 15 splits evenly between the two labels: {flat}")


# ---------------------------------------------------------------------------
# 6. The four-types bound
# ---------------------------------------------------------------------------
def demo_four_types(read_bits: float = 1.8170) -> None:
    print(f"\n=== How many label types does a read of {read_bits} bits require? ===")
    for n in range(2, 6):
        cap = math.log2(n)
        print(f"  {n} types: capacity log2 {n} = {cap:.4f} bits  -> {'possible' if cap >= read_bits else 'impossible'}")
    print(f"  exact certificate: 3^5 = {3**5} < 2^8 = {2**8}, so log2 3 < 8/5 = {float(Fraction(8, 5))} < {read_bits}")
    print(f"  minimal alphabet size: {math.ceil(2 ** read_bits)}")
    # A 4-type label read below capacity: a symmetric noisy channel on 4 symbols.
    def noisy_info(eps: float) -> float:
        rows = [[(1 - eps) if i == j else eps / 3 for j in range(4)] for i in range(4)]
        table = {(i, j): rows[i][j] / 4 for i in range(4) for j in range(4)}
        return mutual_information_bits(table)
    lo, hi = 0.0, 0.75
    for _ in range(60):
        mid = (lo + hi) / 2
        if noisy_info(mid) > read_bits:
            lo = mid
        else:
            hi = mid
    print(f"  illustration: a 4-symbol label observed with symmetric error {lo:.4f}"
          f" yields {noisy_info(lo):.4f} bits (below the 2-bit capacity)")


def demo_gibbs(trials: int = 5, seed: int = 7) -> None:
    print("\n=== Gibbs' inequality: H(q) <= log2 n ===")
    rng = random.Random(seed)
    for _ in range(trials):
        n = rng.randint(2, 8)
        w = [rng.random() for _ in range(n)]
        s = sum(w)
        q = [x / s for x in w]
        print(f"  n = {n}: H = {entropy_bits(q):.4f} <= log2 n = {math.log2(n):.4f}")


def main() -> None:
    demo_sum_label(4, 3)
    demo_fibre_swap(5, 2)
    demo_capacity(4, 3)
    demo_gibbs()
    demo_jacobi([3, 5])
    demo_jacobi([3, 5, 7])
    demo_jacobi([5, 7, 11])
    demo_lab_tables()
    demo_four_types()


if __name__ == "__main__":
    main()
