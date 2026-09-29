#!/usr/bin/env python3
"""
The hint map of the cyclic splitting-type channel and its CRT defect law.

Numerical companion to "The Hint Extends Beyond Degree Five".  Everything is computed by
exact enumeration of finite populations (fibre counting); entropies are in bits.

Sections
  1. The round-31 battery over the real sextic field Q(zeta_13)^+ (conductor 13, group C6).
  2. The hint map h(n) of the abstract cyclic type channel, n = 2..20.
  3. The unordered-pair entropy law  H(unordered) = H(ordered) - P(distinct).
  4. The CRT defect law  h(mn) = h(m) + h(n) + delta(m) delta(n)  for coprime m, n.
  5. The totient closed form  delta(n) = 1 - sum_{d | n} phi(d)^2 / n^2.
  6. Open conjectures (numerical evidence only): prime rungs, field transfer, reality.

Self-contained: standard library only.
"""
from __future__ import annotations

from collections import Counter
from fractions import Fraction
from itertools import product
from math import gcd, log2
from typing import Callable, Hashable, Iterable, Sequence, TypeVar

T = TypeVar("T")
K = Hashable


# ---------------------------------------------------------------------------
# Generic counting entropy over a uniform finite population
# ---------------------------------------------------------------------------

def entropy(pop: Sequence[T], f: Callable[[T], K]) -> float:
    """Shannon entropy (bits) of f(X) for X uniform on pop."""
    n = len(pop)
    counts = Counter(f(x) for x in pop)
    return -sum(c / n * log2(c / n) for c in counts.values())


def cond_entropy(pop: Sequence[T], f: Callable[[T], K], g: Callable[[T], K]) -> float:
    """H(f | g) = H(f, g) - H(g)."""
    return entropy(pop, lambda x: (f(x), g(x))) - entropy(pop, g)


def mutual_info(pop: Sequence[T], f: Callable[[T], K], g: Callable[[T], K]) -> float:
    """I(f ; g) = H(f) - H(f | g)."""
    return entropy(pop, f) - cond_entropy(pop, f, g)


# ---------------------------------------------------------------------------
# The cyclic type channel of degree n
# ---------------------------------------------------------------------------

def ord_type(n: int, a: int) -> int:
    """Splitting type of exponent a mod n: the order of a in Z/n, i.e. n / gcd(a, n)."""
    return n // gcd(a % n, n)


def box(n: int) -> list[tuple[int, int]]:
    """All ordered exponent pairs (a, b) in (Z/n)^2, uniformly weighted."""
    return list(product(range(n), repeat=2))


def type_pair(n: int) -> Callable[[tuple[int, int]], tuple[int, int]]:
    """The label: the unordered pair of splitting types {T(a), T(b)}."""
    def lab(x: tuple[int, int]) -> tuple[int, int]:
        s, t = ord_type(n, x[0]), ord_type(n, x[1])
        return (min(s, t), max(s, t))
    return lab


def prod_res(n: int) -> Callable[[tuple[int, int]], int]:
    """The product view: N = pq corresponds to the exponent a + b mod n."""
    return lambda x: (x[0] + x[1]) % n


def hint_map(n: int) -> float:
    """h(n) = H(label) - I(label ; N) = H(label | N)."""
    return cond_entropy(box(n), type_pair(n), prod_res(n))


def pair_entropy(n: int) -> float:
    return entropy(box(n), type_pair(n))


def ipair(n: int) -> float:
    return mutual_info(box(n), type_pair(n), prod_res(n))


def type_entropy(n: int) -> float:
    return entropy(list(range(n)), lambda a: ord_type(n, a))


def distinct_prob(n: int) -> Fraction:
    """delta(n) = P(T(a) != T(b)) for independent uniform a, b mod n (exact)."""
    k = sum(1 for a, b in box(n) if ord_type(n, a) != ord_type(n, b))
    return Fraction(k, n * n)


def phi(n: int) -> int:
    return sum(1 for k in range(1, n + 1) if gcd(k, n) == 1)


def sum_phi_sq(n: int) -> int:
    return sum(phi(d) ** 2 for d in range(1, n + 1) if n % d == 0)


def hb(p: float) -> float:
    """Binary entropy function."""
    return 0.0 if p in (0.0, 1.0) else -p * log2(p) - (1 - p) * log2(1 - p)


# ---------------------------------------------------------------------------
# The field-level battery: unit pairs mod a prime conductor f
# ---------------------------------------------------------------------------

def primitive_root(f: int) -> int:
    for g in range(2, f):
        if len({pow(g, k, f) for k in range(1, f)}) == f - 1:
            return g
    raise ValueError("no primitive root")


def field_battery(f: int, n: int) -> dict[str, float]:
    """Round-31 battery over the degree-n subfield of Q(zeta_f) (n | f - 1).

    The residue degree of a prime p = u (mod f) in that subfield is the order of the
    Frobenius, i.e. n / gcd(ind_g(u), n) where ind_g is the discrete logarithm.
    """
    g = primitive_root(f)
    ind = {pow(g, k, f): k for k in range(f - 1)}
    deg = {u: ord_type(n, ind[u]) for u in ind}
    pop = [(p, q) for p in ind for q in ind]

    def label(x: tuple[int, int]) -> tuple[int, int]:
        s, t = deg[x[0]], deg[x[1]]
        return (min(s, t), max(s, t))

    N = lambda x: x[0] * x[1] % f
    S = lambda x: (x[0] + x[1]) % f
    D = lambda x: (x[0] - x[1]) % f
    I_N = mutual_info(pop, label, N)
    I_pq = mutual_info(pop, label, lambda x: x)
    I_sd = mutual_info(pop, label, lambda x: (S(x), D(x)))
    I_Ns = mutual_info(pop, label, lambda x: (N(x), S(x)))
    I_Nd = mutual_info(pop, label, lambda x: (N(x), D(x)))
    hint = I_pq - I_N
    sum_hint, gap_hint = I_Ns - I_N, I_Nd - I_N
    return {
        "H(label)": entropy(pop, label),
        "I(label;N)": I_N,
        "I(label;s,d)": I_sd,
        "hint": hint,
        "sumHint": sum_hint,
        "gapHint": gap_hint,
        "synergy": hint - sum_hint - gap_hint,
        "I(label;s)": mutual_info(pop, label, S),
    }


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def section(title: str) -> None:
    print("\n" + "=" * 78 + f"\n{title}\n" + "=" * 78)


def demo_round31() -> None:
    section("1. Round-31 battery over Q(zeta_13)^+  (degree 6, C6, conductor 13)")
    L3 = log2(3)
    b = field_battery(13, 6)
    rows = [
        ("product view I(label;N)", b["I(label;N)"], L3 - 1 / 9, 1.4704),
        ("joint view I(label;s,d)", b["I(label;s,d)"], 2 * L3 - 1 / 18, 3.1110),
        ("hint value", b["hint"], L3 + 1 / 18, 1.6407),
    ]
    print(f"{'row':28s}{'enumerated':>14s}{'closed form':>14s}{'reported':>10s}")
    for name, got, exact, rep in rows:
        print(f"{name:28s}{got:14.6f}{exact:14.6f}{rep:10.4f}")
        assert abs(got - exact) < 1e-12
    print(f"\nlabel entropy H(label)     = {b['H(label)']:.6f}  (= 2 log2 3 - 1/18)")
    print(f"sumHint = gapHint          = {b['sumHint']:.6f}, {b['gapHint']:.6f}")
    print(f"hint synergy               = {b['synergy']:.6f}  (= -(log2 3 + 1/18): lower wall attained)")
    exact_s = 2 * L3 + 29 / 36 - 11 / 12 * log2(11)
    print(f"sum dial alone I(label;s)  = {b['I(label;s)']:.6f}  (closed form {exact_s:.6f})")
    print(f"field model = exponent model: hint = h(6) = {hint_map(6):.12f}")
    print(f"reported 1.6407 overshoots exact value by {1.6407 - b['hint']:.2e} bits")


def demo_hint_ladder() -> None:
    section("2. The hint map ladder h(n) = H(label | N)")
    closed = {
        2: 0.5,
        3: log2(3) - 2 / 3,
        4: 9 / 8,
        5: log2(5) - 12 / 25 * log2(3) - 16 / 25,
        6: log2(3) + 1 / 18,
    }
    for n in range(2, 21):
        h = hint_map(n)
        bar = "#" * int(round(h * 20))
        extra = f"  closed form {closed[n]:.6f}" if n in closed else ""
        print(f"n={n:2d}  h={h:8.5f}  <= log2 n = {log2(n):6.3f}  {bar}{extra}")
        assert 0 <= h <= min(pair_entropy(n), log2(n)) + 1e-12
    print("order on the first rungs: h(2) < h(3) < h(5) < h(4) < h(6):",
          hint_map(2) < hint_map(3) < hint_map(5) < hint_map(4) < hint_map(6))


def demo_unordered_law() -> None:
    section("3. Unordered-pair entropy law  H({g x, g y}) = H(g x, g y) - P(g x != g y)")
    for n in (5, 6, 12, 30):
        B = box(n)
        ordered = entropy(B, lambda x: (ord_type(n, x[0]), ord_type(n, x[1])))
        unordered = pair_entropy(n)
        d = float(distinct_prob(n))
        print(f"n={n:2d}: H(unordered)={unordered:.9f}  H(ordered)-delta={ordered - d:.9f}"
              f"   2*T(n)-delta={2 * type_entropy(n) - d:.9f}")
        assert abs(unordered - (ordered - d)) < 1e-12


def demo_crt_law() -> None:
    section("4. CRT defect law  h(mn) = h(m) + h(n) + delta(m) delta(n)")
    worst = 0.0
    for m in range(2, 13):
        for n in range(m + 1, 13):
            if gcd(m, n) != 1 or m * n > 60:
                continue
            lhs = hint_map(m * n)
            defect = float(distinct_prob(m) * distinct_prob(n))
            rhs = hint_map(m) + hint_map(n) + defect
            ip = ipair(m * n) - ipair(m) - ipair(n)
            worst = max(worst, abs(lhs - rhs))
            print(f"({m:2d},{n:2d}) -> {m*n:3d}: h(mn)={lhs:.6f}  h(m)+h(n)={hint_map(m)+hint_map(n):.6f}"
                  f"  defect={defect:.6f}  [I_pair nonadditivity {ip:+.1e}]")
    print(f"max |error| = {worst:.2e}")
    print(f"degree-6 defect delta(2)delta(3) = {distinct_prob(2) * distinct_prob(3)}")


def demo_totient() -> None:
    section("5. delta(n) = 1 - sum_{d|n} phi(d)^2 / n^2, and multiplicativity of sum phi(d)^2")
    for n in range(1, 16):
        closed = 1 - Fraction(sum_phi_sq(n), n * n)
        assert closed == distinct_prob(n)
        print(f"n={n:2d}: sum phi(d)^2 = {sum_phi_sq(n):4d}   delta = {distinct_prob(n)}")
    for m, n in [(2, 3), (3, 4), (4, 5), (5, 9), (7, 8)]:
        assert sum_phi_sq(m * n) == sum_phi_sq(m) * sum_phi_sq(n)
    print("multiplicativity checked on (2,3),(3,4),(4,5),(5,9),(7,8)")


def demo_conjectures() -> None:
    section("6. Open conjectures -- numerical evidence only, not proved")
    print("(a) prime rungs: h(q) = ((q-1)/q) Hb(2/q) + (1/q) Hb(1/q)")
    for q in (2, 3, 5, 7, 11, 13, 17, 19):
        pred = (q - 1) / q * hb(2 / q) + hb(1 / q) / q
        print(f"    q={q:2d}: h(q)={hint_map(q):.12f}  formula={pred:.12f}")
    print("(b) field-exponent transfer: hint over degree-n subfield of Q(zeta_f) vs h(n)")
    for f in (7, 11, 13, 17):
        for n in range(2, f):
            if (f - 1) % n == 0:
                b = field_battery(f, n)
                print(f"    f={f:2d} n={n:2d}: field hint={b['hint']:.9f}  h(n)={hint_map(n):.9f}")
    print("(c) reality criterion for the gap dial at conductor 13")
    for n in (2, 3, 4, 6, 12):
        b = field_battery(13, n)
        real = (12 // n) % 2 == 0  # subfield real iff -1 lies in the index-n subgroup
        print(f"    n={n:2d} ({'real' if real else 'imaginary'}): hint={b['hint']:.6f} "
              f"gapHint={b['gapHint']:.6f} sumHint={b['sumHint']:.6f}")


if __name__ == "__main__":
    demo_round31()
    demo_hint_ladder()
    demo_unordered_law()
    demo_crt_law()
    demo_totient()
    demo_conjectures()
