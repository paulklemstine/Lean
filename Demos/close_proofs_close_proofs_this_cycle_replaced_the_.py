"""
The Fibonacci Divisibility Lattice — Numerical Demonstrations
=============================================================

Self-contained Python demonstrations of the six core results developed in the
accompanying article and research paper:

  1. gcd(F(m), F(n)) = F(gcd(m, n))            (the master identity, GCD-Hom)
  2. F injective on indices >= 2               (fib_inj_iff)
  3. F(k) = 1  <=>  k in {1, 2}                (fib_eq_one_iff)
  4. F(m) | F(n)  <=>  m | n      (for m >= 3) (converse divisibility law)
  5. coprime(F(m), F(n)) <=> gcd(m,n) in {1,2} (coprimality criterion)
  6. m | F(n)  <=>  entry(m) | n               (apparition law)

Run:  python demo.py
"""

from __future__ import annotations

from math import gcd
from typing import Dict, List, Tuple


# --------------------------------------------------------------------------- #
# Core utilities                                                              #
# --------------------------------------------------------------------------- #
def fib(n: int) -> int:
    """Return the n-th Fibonacci number with F(0)=0, F(1)=1 (iterative, exact)."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def fib_list(n: int) -> List[int]:
    """Return [F(0), F(1), ..., F(n)]."""
    seq = [0, 1]
    while len(seq) <= n:
        seq.append(seq[-1] + seq[-2])
    return seq[: n + 1]


def is_coprime(a: int, b: int) -> bool:
    """Two integers are coprime iff their gcd is 1."""
    return gcd(a, b) == 1


def entry_point(m: int) -> int:
    """Rank of apparition: least k > 0 with m | F(k).

    Iterates the residue recurrence (a, b) = (F(k) mod m, F(k+1) mod m).
    Terminates by Theorem 5.2 (existence); period <= m*m.
    """
    if m <= 0:
        raise ValueError("entry_point requires a positive modulus")
    if m == 1:
        return 1
    a, b = 0, 1  # (F(0) mod m, F(1) mod m)
    k = 0
    while True:
        k += 1
        a, b = b, (a + b) % m  # now (a, b) = (F(k) mod m, F(k+1) mod m)
        if a == 0:
            return k


# --------------------------------------------------------------------------- #
# Demonstration 1 — The master gcd identity                                  #
# --------------------------------------------------------------------------- #
def demo_gcd_identity(max_index: int = 16) -> None:
    print("=" * 70)
    print("DEMO 1: gcd(F(m), F(n)) = F(gcd(m, n))   [the master identity]")
    print("=" * 70)
    failures = 0
    for m in range(1, max_index + 1):
        for n in range(1, max_index + 1):
            lhs = gcd(fib(m), fib(n))
            rhs = fib(gcd(m, n))
            if lhs != rhs:
                failures += 1
                print(f"  MISMATCH at m={m}, n={n}: {lhs} != {rhs}")
    print(f"  Verified for all 1 <= m,n <= {max_index}.  Failures: {failures}")
    # A few explicit witnesses
    for (m, n) in [(12, 18), (10, 15), (8, 12)]:
        print(
            f"    gcd(F({m})={fib(m)}, F({n})={fib(n)}) = {gcd(fib(m), fib(n))} "
            f"= F(gcd({m},{n})=F({gcd(m,n)})) = {fib(gcd(m, n))}"
        )
    print()


# --------------------------------------------------------------------------- #
# Demonstration 2 — Injectivity above index 1 & the value 1                  #
# --------------------------------------------------------------------------- #
def demo_injectivity(max_index: int = 30) -> None:
    print("=" * 70)
    print("DEMO 2: F is injective on indices >= 2, and F(k)=1 iff k in {1,2}")
    print("=" * 70)
    seen: Dict[int, int] = {}
    collisions: List[Tuple[int, int]] = []
    for k in range(2, max_index + 1):
        v = fib(k)
        if v in seen:
            collisions.append((seen[v], k))
        seen[v] = k
    print(f"  Value collisions among indices 2..{max_index}: {collisions or 'NONE'}")
    ones = [k for k in range(0, max_index + 1) if fib(k) == 1]
    print(f"  Indices k with F(k) = 1: {ones}  (expected exactly [1, 2])")
    print()


# --------------------------------------------------------------------------- #
# Demonstration 3 — Converse divisibility law                                #
# --------------------------------------------------------------------------- #
def demo_converse_divisibility(max_index: int = 20) -> None:
    print("=" * 70)
    print("DEMO 3: F(m) | F(n)  <=>  m | n      (for m >= 3)")
    print("=" * 70)
    failures = 0
    for m in range(3, max_index + 1):
        for n in range(1, max_index + 1):
            value_side = (fib(n) % fib(m) == 0)
            index_side = (n % m == 0)
            if value_side != index_side:
                failures += 1
                print(f"  MISMATCH m={m}, n={n}: value={value_side}, index={index_side}")
    print(f"  Law holds for all 3 <= m <= {max_index}, 1 <= n <= {max_index}.")
    print(f"  Failures: {failures}")
    # Show why m=2 is excluded (m=1 trivially agrees since 1 | everything):
    print("  Boundary check (law FAILS for m=2 because F(2)=1 divides everything):")
    m = 2
    bad_n = next(n for n in range(1, 10) if n % m != 0)
    print(
        f"    m={m}: F({m})=1 divides F({bad_n})={fib(bad_n)} but {m} does not divide {bad_n}"
    )
    print()


# --------------------------------------------------------------------------- #
# Demonstration 4 — Coprimality criterion                                     #
# --------------------------------------------------------------------------- #
def demo_coprimality(max_index: int = 16) -> None:
    print("=" * 70)
    print("DEMO 4: coprime(F(m), F(n))  <=>  gcd(m, n) in {1, 2}")
    print("=" * 70)
    failures = 0
    for m in range(1, max_index + 1):
        for n in range(1, max_index + 1):
            value_side = is_coprime(fib(m), fib(n))
            index_side = gcd(m, n) in (1, 2)
            if value_side != index_side:
                failures += 1
                print(f"  MISMATCH m={m}, n={n}")
    print(f"  Criterion holds for all 1 <= m,n <= {max_index}.  Failures: {failures}")
    for (m, n) in [(5, 9), (6, 9), (4, 6)]:
        print(
            f"    m={m}, n={n}: gcd={gcd(m, n)} -> coprime(F={fib(m)},F={fib(n)}) "
            f"= {is_coprime(fib(m), fib(n))}"
        )
    print()


# --------------------------------------------------------------------------- #
# Demonstration 5 — Rank of apparition (entry point)                          #
# --------------------------------------------------------------------------- #
def demo_entry_points(max_modulus: int = 15) -> None:
    print("=" * 70)
    print("DEMO 5: entry(m) = least k>0 with m | F(k)  (rank of apparition)")
    print("=" * 70)
    for m in range(1, max_modulus + 1):
        e = entry_point(m)
        print(f"    entry({m:2d}) = {e:2d}   (F({e}) = {fib(e)} = {m} x {fib(e)//m})")
    print()


# --------------------------------------------------------------------------- #
# Demonstration 6 — The apparition law                                        #
# --------------------------------------------------------------------------- #
def demo_apparition_law(max_modulus: int = 12, max_index: int = 60) -> None:
    print("=" * 70)
    print("DEMO 6: m | F(n)  <=>  entry(m) | n   (apparition law)")
    print("=" * 70)
    failures = 0
    for m in range(1, max_modulus + 1):
        e = entry_point(m)
        for n in range(1, max_index + 1):
            value_side = (fib(n) % m == 0)
            index_side = (n % e == 0)
            if value_side != index_side:
                failures += 1
                print(f"  MISMATCH m={m}, n={n}, entry={e}")
    print(
        f"  Law holds for all 1 <= m <= {max_modulus}, 1 <= n <= {max_index}. "
        f"Failures: {failures}"
    )
    e7 = entry_point(7)
    multiples = [n for n in range(1, 33) if fib(n) % 7 == 0]
    print(f"    Example: entry(7)={e7}; positions where 7 | F(n): {multiples}")
    print()


# --------------------------------------------------------------------------- #
# Bonus — Conjecture probes (future directions)                               #
# --------------------------------------------------------------------------- #
def demo_future_conjectures(max_modulus: int = 30) -> None:
    print("=" * 70)
    print("BONUS: probing the two future-direction conjectures")
    print("=" * 70)
    # Direction 1: multiplicativity on coprime moduli
    from math import lcm

    print("  Direction 1: entry(a*b) = lcm(entry(a), entry(b)) for coprime a,b")
    bad = 0
    for a in range(2, max_modulus):
        for b in range(2, max_modulus):
            if gcd(a, b) == 1 and a * b <= 200:
                if entry_point(a * b) != lcm(entry_point(a), entry_point(b)):
                    bad += 1
                    print(f"    counterexample a={a}, b={b}")
    print(f"    coprime-multiplicativity counterexamples found: {bad}")

    # Direction 2: Wall-Sun-Sun, entry(p^2) = p * entry(p)
    print("  Direction 2: entry(p^2) = p * entry(p)  (Wall-Sun-Sun)")
    primes = [p for p in range(2, 60) if all(p % d for d in range(2, int(p**0.5) + 1))]
    bad2 = 0
    for p in primes:
        if entry_point(p * p) != p * entry_point(p):
            bad2 += 1
            print(f"    Wall-Sun-Sun candidate prime p={p}!")
    print(f"    Wall-Sun-Sun candidates found among p<60: {bad2}")
    print()


def main() -> None:
    demo_gcd_identity()
    demo_injectivity()
    demo_converse_divisibility()
    demo_coprimality()
    demo_entry_points()
    demo_apparition_law()
    demo_future_conjectures()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
