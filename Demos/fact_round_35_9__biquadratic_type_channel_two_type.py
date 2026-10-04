#!/usr/bin/env python3
"""
The biquadratic type channel of x^4 - 10x^2 + 1: numerical demonstrations.

The script is self-contained and uses only the Python standard library. It illustrates:

  1. Only two types: for every prime p >= 5 the quartic has 4 roots mod p
     if p = +-1 (mod 24) and 0 roots otherwise (checked by brute force).
  2. The root set is {+-a +-b} where a^2 = 2 and b^2 = 3, and in the
     root-free case there is an explicit factorisation into two quadratics.
  3. The conductor is exactly 24: no proper divisor of 24 determines the type.
  4. Exact class-level entropy H(T) = 2 - (3/4) log2 3 and full pinning.
  5. Rigorous bounds 84/53 < log2 3 < 485/306 from integer inequalities.
  6. The semiprime pair channel I = 19/8 - (21/16) log2 3.
  7. The swap-symmetry law: N mod 24 carries exactly 0 bits about which
     factor of a mixed semiprime splits.
  8. A class-level check of the multiquadratic pair-channel formula.
"""
from __future__ import annotations

import math
from collections import Counter, defaultdict
from typing import Callable, Hashable, Iterable, Sequence, TypeVar

X = TypeVar("X")

U24: tuple[int, ...] = (1, 5, 7, 11, 13, 17, 19, 23)
LOG2_3: float = math.log2(3)


# ---------------------------------------------------------------------------
# Basic arithmetic
# ---------------------------------------------------------------------------

def primes_up_to(n: int) -> list[int]:
    """Sieve of Eratosthenes."""
    sieve = bytearray([1]) * (n + 1)
    sieve[0:2] = b"\x00\x00"
    for i in range(2, int(n ** 0.5) + 1):
        if sieve[i]:
            sieve[i * i:: i] = bytearray(len(range(i * i, n + 1, i)))
    return [i for i in range(n + 1) if sieve[i]]


def quartic(x: int, p: int) -> int:
    """Value of x^4 - 10x^2 + 1 modulo p."""
    return (pow(x, 4, p) - 10 * x * x + 1) % p


def roots_mod_p(p: int) -> list[int]:
    """All roots of x^4 - 10x^2 + 1 in Z/p (brute force)."""
    return [x for x in range(p) if quartic(x, p) == 0]


def class_type(r: int) -> int:
    """Predicted type from the residue class: 4 on +-1 mod 24, else 0."""
    return 4 if r in (1, 23) else 0


def sqrt_mod(a: int, p: int) -> int | None:
    """A square root of a modulo p (brute force; fine for small p)."""
    a %= p
    for x in range(p):
        if x * x % p == a:
            return x
    return None


def factor_certificate(p: int) -> str:
    """An explicit factorisation of x^4 - 10x^2 + 1 over Z/p into two monic quadratics,
    built from whichever of 2, 3, 6 is a square (the three difference-of-squares shapes)."""
    a, b = 2, 3
    al = sqrt_mod(a, p)
    if al is not None:
        u, v = (-2 * al) % p, (a - b) % p
        return f"(x^2 + {u}x + {v})(x^2 + {(2 * al) % p}x + {v})   [2 = {al}^2]"
    be = sqrt_mod(b, p)
    if be is not None:
        u, v = (-2 * be) % p, (b - a) % p
        return f"(x^2 + {u}x + {v})(x^2 + {(2 * be) % p}x + {v})   [3 = {be}^2]"
    ga = sqrt_mod(a * b, p)
    assert ga is not None, "one of 2, 3, 6 is always a square"
    return (f"(x^2 + {(-(a + b) - 2 * ga) % p})(x^2 + {(-(a + b) + 2 * ga) % p})"
            f"   [6 = {ga}^2]")


def expand_check(p: int) -> bool:
    """Verify the certificate by brute-force evaluation at every x mod p."""
    for sq, shape in ((2, "a"), (3, "b"), (6, "ab")):
        r = sqrt_mod(sq, p)
        if r is None:
            continue
        for x in range(p):
            if shape == "a":
                val = (x * x - 2 * r * x - 1) * (x * x + 2 * r * x - 1)
            elif shape == "b":
                val = (x * x - 2 * r * x + 1) * (x * x + 2 * r * x + 1)
            else:
                val = (x * x - 5 - 2 * r) * (x * x - 5 + 2 * r)
            if (val - (x ** 4 - 10 * x * x + 1)) % p:
                return False
        return True
    return False


# ---------------------------------------------------------------------------
# Information theory on finite sets (uniform measure)
# ---------------------------------------------------------------------------

def entropy(sample: Sequence[X], g: Callable[[X], Hashable]) -> float:
    """H_S(g) = sum_v (n_v/N) log2(N/n_v)."""
    n = len(sample)
    if n == 0:
        return 0.0
    counts = Counter(g(x) for x in sample)
    return sum(c / n * math.log2(n / c) for c in counts.values())


def cond_entropy(sample: Sequence[X], g: Callable[[X], Hashable],
                 k: Callable[[X], Hashable]) -> float:
    """H_S(g | k) = sum_c (|S_c|/|S|) H_{S_c}(g)."""
    n = len(sample)
    fibres: dict[Hashable, list[X]] = defaultdict(list)
    for x in sample:
        fibres[k(x)].append(x)
    return sum(len(f) / n * entropy(f, g) for f in fibres.values())


def mut_info(sample: Sequence[X], g: Callable[[X], Hashable],
             k: Callable[[X], Hashable]) -> float:
    """I_S(g ; k) = H_S(g) - H_S(g | k)."""
    return entropy(sample, g) - cond_entropy(sample, g, k)


def is_swap_symmetric(sample: Iterable[X], g: Callable[[X], bool],
                      k: Callable[[X], Hashable], sigma: Callable[[X], X]) -> bool:
    """Check the three hypotheses of the swap-symmetry law pointwise."""
    s = list(sample)
    members = set(s)  # type: ignore[arg-type]
    return all(sigma(x) in members and sigma(sigma(x)) == x
               and g(sigma(x)) == (not g(x)) and k(sigma(x)) == k(x) for x in s)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_two_types(bound: int = 3000) -> None:
    print("=" * 72)
    print("1. ONLY TWO TYPES: #roots of x^4-10x^2+1 mod p versus p mod 24")
    print("=" * 72)
    ps = [p for p in primes_up_to(bound) if p >= 5]
    mismatches = 0
    hist: Counter[int] = Counter()
    for p in ps:
        t = len(roots_mod_p(p))
        hist[t] += 1
        if t != class_type(p % 24):
            mismatches += 1
    print(f"primes 5 <= p <= {bound}: {len(ps)}; root-count histogram {dict(hist)}")
    print(f"mismatches with the mod-24 rule: {mismatches}")
    for p in (5, 7, 23, 47, 73, 97):
        rs = roots_mod_p(p)
        print(f"  p={p:3d}  p mod 24={p % 24:2d}  roots={rs}")
    print()


def demo_root_structure() -> None:
    print("=" * 72)
    print("2. ROOT SET {+-a +-b} AND QUADRATIC FACTORISATIONS")
    print("=" * 72)
    for p in (23, 47, 73):
        a, b = sqrt_mod(2, p), sqrt_mod(3, p)
        assert a is not None and b is not None
        predicted = sorted({(s * a + t * b) % p for s in (1, -1) for t in (1, -1)})
        print(f"  p={p}: sqrt2={a}, sqrt3={b}, +-a+-b = {predicted}, "
              f"actual = {roots_mod_p(p)}")
    for p in (2, 3, 5, 7, 11, 13, 17, 19):
        print(f"  p={p:2d}: {factor_certificate(p)}  verified={expand_check(p)}")
    ok = all(expand_check(p) for p in primes_up_to(600))
    print(f"  quadratic factorisation verified for all primes <= 600: {ok}")
    print()


def demo_conductor() -> None:
    print("=" * 72)
    print("3. THE CONDUCTOR IS EXACTLY 24")
    print("=" * 72)
    ps = [p for p in primes_up_to(200) if p >= 5]
    for d in (1, 2, 3, 4, 6, 8, 12, 24):
        witness = None
        for p in ps:
            for q in ps:
                if p < q and p % d == q % d and class_type(p % 24) != class_type(q % 24):
                    witness = (p, q)
                    break
            if witness:
                break
        status = f"fails, witness {witness}" if witness else "pins the type"
        print(f"  modulus {d:2d}: {status}")
    print()


def demo_entropy_and_pinning(bound: int = 200000) -> None:
    print("=" * 72)
    print("4/5. TYPE ENTROPY, BOUNDS ON log2 3, FULL PINNING")
    print("=" * 72)
    exact = 2 - 0.75 * LOG2_3
    cls = entropy(list(U24), class_type)
    print(f"  class-level H(T) = {cls:.6f};  2 - (3/4)log2 3 = {exact:.6f}")
    print(f"  2^84 < 3^53 : {2 ** 84 < 3 ** 53};   3^306 < 2^485 : {3 ** 306 < 2 ** 485}")
    lo, hi = 2 - 0.75 * 485 / 306, 2 - 0.75 * 84 / 53
    print(f"  hence {lo:.6f} < H(T) < {hi:.6f}  (window 0.8109 .. 0.8114)")
    ps = [p for p in primes_up_to(bound) if p >= 5]
    def t(p: int) -> int: return class_type(p % 24)
    h = entropy(ps, t)
    i = mut_info(ps, t, lambda p: p % 24)
    frac = sum(1 for p in ps if t(p) == 4) / len(ps)
    print(f"  primes up to {bound}: split fraction {frac:.5f}, H_S(T) = {h:.5f}, "
          f"I(T; p mod 24) = {i:.5f}  (equal: {abs(h - i) < 1e-12})")
    for m in (8, 12):
        print(f"  for comparison I(T; p mod {m}) = {mut_info(ps, t, lambda p: p % m):.5f}")
    print()


def demo_pair_channel(bound: int = 3000) -> None:
    print("=" * 72)
    print("6. SEMIPRIME PAIR CHANNEL")
    print("=" * 72)
    pairs = [(r, s) for r in U24 for s in U24]
    def pt(x: tuple[int, int]) -> tuple[int, int]:
        return (class_type(x[0] % 24), class_type(x[1] % 24))
    def nk(x: tuple[int, int]) -> int:
        return x[0] * x[1] % 24
    exact = 19 / 8 - 21 / 16 * LOG2_3
    print(f"  class-level H(pair) = {entropy(pairs, pt):.6f}  (4 - 1.5 log2 3 = "
          f"{4 - 1.5 * LOG2_3:.6f})")
    print(f"  class-level I(pair; N mod 24) = {mut_info(pairs, pt, nk):.6f};  "
          f"19/8 - (21/16) log2 3 = {exact:.6f}")
    for c in U24:
        fib = [x for x in pairs if nk(x) == c]
        print(f"    fibre N={c:2d}: {len(fib)} pairs, H = {entropy(fib, pt):.4f}")
    ps = [p for p in primes_up_to(bound) if p >= 5]
    sample = [(p, q) for p in ps for q in ps]
    print(f"  all ordered prime pairs up to {bound}: I = {mut_info(sample, pt, nk):.5f}")
    print()


def demo_swap_symmetry(bound: int = 3000) -> None:
    print("=" * 72)
    print("7. SWAP SYMMETRY: WHICH FACTOR SPLITS?")
    print("=" * 72)
    def split(n: int) -> bool: return class_type(n % 24) == 4
    def first(x: tuple[int, int]) -> bool: return split(x[0])
    def nk(x: tuple[int, int]) -> int: return x[0] * x[1] % 24
    def swap(x: tuple[int, int]) -> tuple[int, int]: return (x[1], x[0])
    mixed_cls = [(r, s) for r in U24 for s in U24 if split(r) != split(s)]
    print(f"  mixed class pairs: {len(mixed_cls)}; swap-symmetric: "
          f"{is_swap_symmetric(mixed_cls, first, nk, swap)}")
    print(f"  H(which) = {entropy(mixed_cls, first):.6f}, "
          f"I(which; N mod 24) = {mut_info(mixed_cls, first, nk):.6f}")
    ps = [p for p in primes_up_to(bound) if p >= 5]
    mixed = [(p, q) for p in ps for q in ps if split(p) != split(q)]
    print(f"  mixed prime pairs up to {bound}: {len(mixed)}; "
          f"I = {mut_info(mixed, first, nk):.3e} (exactly 0)")
    # A non-symmetric sample (p < q) breaks the hypothesis and leaks information.
    ordered = [(p, q) for (p, q) in mixed if p < q]
    print(f"  same pairs restricted to p < q (NOT swap-closed): "
          f"I = {mut_info(ordered, first, nk):.5f}")
    print()


def demo_multiquadratic() -> None:
    print("=" * 72)
    print("8. MULTIQUADRATIC PAIR-CHANNEL FORMULA (class level, n = 2, 4, 8)")
    print("=" * 72)
    def h(t: float) -> float: return -t * math.log2(t) - (1 - t) * math.log2(1 - t)
    def h3(a: float, b: float, c: float) -> float:
        return -sum(x * math.log2(x) for x in (a, b, c) if x > 0)
    def predicted(n: int) -> float:
        return (2 - 1 / n) * h(1 / n) - (n - 1) / n * h3(1 / n, 1 / n, 1 - 2 / n)
    pairs = [(r, s) for r in U24 for s in U24]
    # split subgroups of (Z/24)^x of index 2, 4, 8
    subgroups = {2: {1, 5, 19, 23}, 4: {1, 23}, 8: {1}}
    for n, sub in subgroups.items():
        def pt(x: tuple[int, int], sub: set[int] = sub) -> tuple[bool, bool]:
            return (x[0] in sub, x[1] in sub)
        actual = mut_info(pairs, pt, lambda x: x[0] * x[1] % 24)
        print(f"  n={n}: computed I = {actual:.6f},  formula I_n = {predicted(n):.6f}")
    print()


if __name__ == "__main__":
    demo_two_types()
    demo_root_structure()
    demo_conductor()
    demo_entropy_and_pinning()
    demo_pair_channel()
    demo_swap_symmetry()
    demo_multiquadratic()
