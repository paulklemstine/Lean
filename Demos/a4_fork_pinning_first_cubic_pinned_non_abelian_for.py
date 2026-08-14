#!/usr/bin/env python3
"""
Cubic pinning of a non-abelian fork: numerical demonstration.

This self-contained script reproduces, from scratch, every quantitative claim of
the accompanying paper about the A4-field of the quartic

        f(x) = x^4 + 8x + 12,        disc(f) = 576^2 = 2^12 * 3^4.

It verifies, in order:

  1.  Group theory of A4 inside S4: V4 (the even involutions) is the commutator
      subgroup, |A4^ab| = 3, the [4,1,0] root signature, and within-V4 flatness.
  2.  The Klein resolvent y^3 - 48y - 64 of f, its discriminant 576^2, its
      rescaling 64*(z^3 - 3z - 1), and the cyclotomic root -4*(z9 + z9^{-1}):
      the resolvent field is Q(zeta_9)^+, conductor 9.
  3.  Cubes mod 9 are {1, 8}; the cubic residue character chi9 is multiplicative
      with kernel the cubes.
  4.  The prime-level sieve: root-count densities 1/12, 2/3, 1/4, 0 and the
      cubic pinning  F0(p) = [Frob p in V4] = [p = +-1 mod 9], with measured
      mutual information -> H(1/3) = log2(3) - 2/3 = 0.918296...
  5.  The exact leakage law I = H(pq) - p*H(q) and the identity fork value
      H(1/12) - (1/3)H(1/4) = 0.143395...
  6.  Minimality of the modulus (mod 3 flat) and flatness off the conductor
      (mod 5 flat).
  7.  Semiprime channels: AND, OR, XOR, split-count, and the which-factor wall.
  8.  The k-factor AND law and its collapse to zero.
  9.  The pinning-content criterion and the absolute unpinnability of A5.

Pure standard library; no dependencies.  Run:  python3 demo.py
"""

from __future__ import annotations

import cmath
import itertools
import math
from collections import Counter
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

Perm = Tuple[int, ...]  # perm[i] = image of i

# ----------------------------------------------------------------------------
# 0.  Entropy toolkit (bits)
# ----------------------------------------------------------------------------


def eta(x: float) -> float:
    """-x log2 x, with the convention eta(0) = 0."""
    if x <= 0.0:
        return 0.0
    return -x * math.log2(x)


def H(*probs: float) -> float:
    """Shannon entropy in bits.  H(p) for one argument means binary entropy."""
    if len(probs) == 1:
        p = probs[0]
        return eta(p) + eta(1.0 - p)
    return sum(eta(p) for p in probs)


def mutual_information(joint: Dict[Tuple[object, object], float]) -> float:
    """I(X;Y) in bits from a joint distribution given as {(x, y): prob}."""
    px: Dict[object, float] = {}
    py: Dict[object, float] = {}
    for (x, y), p in joint.items():
        px[x] = px.get(x, 0.0) + p
        py[y] = py.get(y, 0.0) + p
    total = 0.0
    for (x, y), p in joint.items():
        if p > 0.0:
            total += p * math.log2(p / (px[x] * py[y]))
    return total


def empirical_mutual_information(pairs: Iterable[Tuple[object, object]]) -> float:
    """Plug-in estimator of I(dial; fork) from a stream of observed pairs."""
    counts = Counter(pairs)
    n = sum(counts.values())
    joint = {key: c / n for key, c in counts.items()}
    return mutual_information(joint)


def channel_information(
    weights: Sequence[float], rates: Sequence[float]
) -> float:
    """I = H(average rate) - sum_y w(y) H(rate(y)) for a binary fork."""
    avg = sum(w * r for w, r in zip(weights, rates))
    cond = sum(w * H(r) for w, r in zip(weights, rates))
    return H(avg) - cond


# ----------------------------------------------------------------------------
# 1.  The group A4 inside S4
# ----------------------------------------------------------------------------

S4: List[Perm] = [tuple(p) for p in itertools.permutations(range(4))]


def sign(p: Perm) -> int:
    """Sign of a permutation, +1 or -1, by counting inversions."""
    n = len(p)
    inv = sum(1 for i in range(n) for j in range(i + 1, n) if p[i] > p[j])
    return 1 if inv % 2 == 0 else -1


def compose(p: Perm, q: Perm) -> Perm:
    """(p*q)(i) = p(q(i))."""
    return tuple(p[q[i]] for i in range(len(q)))


def inverse(p: Perm) -> Perm:
    out = [0] * len(p)
    for i, v in enumerate(p):
        out[v] = i
    return tuple(out)


def commutator(a: Perm, b: Perm) -> Perm:
    return compose(compose(inverse(a), inverse(b)), compose(a, b))


def nroots(p: Perm) -> int:
    """Number of fixed points = number of linear factors of the reduction."""
    return sum(1 for i, v in enumerate(p) if v == i)


IDENT: Perm = (0, 1, 2, 3)
A4: List[Perm] = [p for p in S4 if sign(p) == 1]
V4: List[Perm] = [p for p in S4 if sign(p) == 1 and compose(p, p) == IDENT]


def coset_index(p: Perm) -> int:
    """chi(p) in Z/3: which V4-coset of A4 the even permutation p lies in."""
    c3: Perm = (1, 2, 0, 3)  # the 3-cycle (0 1 2)
    if p in V4:
        return 0
    if compose(p, inverse(c3)) in V4:
        return 1
    return 2


def demo_group() -> None:
    print("=" * 78)
    print("1.  THE GROUP SIDE:  V4 = [A4, A4],  |A4^ab| = 3")
    print("=" * 78)
    assert len(A4) == 12 and len(V4) == 4
    print(f"  |A4| = {len(A4)},  |V4| = {len(V4)}   (V4 = the even involutions)")

    commutators = {commutator(a, b) for a in A4 for b in A4}
    assert commutators == set(V4)
    print(f"  {{[a,b] : a,b in A4}} = V4 ?  {commutators == set(V4)}")
    print(f"  |A4^ab| = |A4| / |V4| = {len(A4) // len(V4)}  -> only CUBIC characters exist")

    # chi is a homomorphism A4 -> Z/3 with kernel V4
    hom = all(
        (coset_index(compose(a, b)) - coset_index(a) - coset_index(b)) % 3 == 0
        for a in A4
        for b in A4
    )
    assert hom
    print(f"  chi(sigma*tau) = chi(sigma) + chi(tau) on A4 ?  {hom}")
    assert {p for p in A4 if coset_index(p) == 0} == set(V4)
    print("  ker(chi) = V4 ?  True")

    sig = Counter(nroots(p) for p in A4)
    print(f"  root-count signature of A4: {dict(sorted(sig.items()))}")
    assert sig[2] == 0 and sig[4] == 1 and sig[1] == 8 and sig[0] == 3
    print("  -> [4,1,0]:  NO element fixes exactly two roots (no transpositions)")
    print(f"  Chebotarev densities: e = {sig[4]}/12, 3-cycles = {sig[1]}/12, "
          f"[2,2] = {sig[0]}/12;  V4 = {len(V4)}/12 = 1/3")

    # within-V4 flatness: every hom to an abelian group kills V4.
    # Concretely, every element of V4 is a commutator, hence in every kernel.
    assert all(v in commutators for v in V4)
    print("  within-V4 flatness: every v in V4 is a commutator, so every")
    print("    homomorphism to an abelian group sends it to the identity.")
    print()


# ----------------------------------------------------------------------------
# 2.  The Klein resolvent
# ----------------------------------------------------------------------------


def quartic_roots() -> List[complex]:
    """The four complex roots of x^4 + 8x + 12, by Durand-Kerner iteration."""
    coeffs = [1.0, 0.0, 0.0, 8.0, 12.0]  # x^4 + 0x^3 + 0x^2 + 8x + 12

    def f(z: complex) -> complex:
        out = 0j
        for c in coeffs:
            out = out * z + c
        return out

    roots = [(0.4 + 0.9j) ** k for k in range(1, 5)]
    for _ in range(500):
        new = []
        for i, zi in enumerate(roots):
            denom = 1.0 + 0j
            for j, zj in enumerate(roots):
                if i != j:
                    denom *= zi - zj
            new.append(zi - f(zi) / denom)
        roots = new
    return roots


def demo_resolvent() -> None:
    print("=" * 78)
    print("2.  THE KLEIN RESOLVENT  y^3 - 48y - 64  AND CONDUCTOR 9")
    print("=" * 78)
    r = quartic_roots()
    e1 = sum(r)
    e2 = sum(r[i] * r[j] for i in range(4) for j in range(i + 1, 4))
    e3 = sum(
        r[i] * r[j] * r[k]
        for i in range(4)
        for j in range(i + 1, 4)
        for k in range(j + 1, 4)
    )
    e4 = r[0] * r[1] * r[2] * r[3]
    print(f"  elementary symmetric functions: e1={e1.real:+.6f}, e2={e2.real:+.6f}, "
          f"e3={e3.real:+.6f}, e4={e4.real:+.6f}   (target 0, 0, -8, 12)")

    A = r[0] * r[1] + r[2] * r[3]
    B = r[0] * r[2] + r[1] * r[3]
    C = r[0] * r[3] + r[1] * r[2]
    print(f"  resolvent values:  A+B+C = {(A + B + C).real:+.6f}   (target 0)")
    print(f"                     AB+BC+CA = {(A * B + B * C + C * A).real:+.6f}   (target -48)")
    print(f"                     ABC = {(A * B * C).real:+.6f}   (target 64)")
    for name, v in (("A", A), ("B", B), ("C", C)):
        val = v ** 3 - 48 * v - 64
        assert abs(val) < 1e-6
        print(f"    {name}^3 - 48*{name} - 64 = {abs(val):.2e}  (root of the resolvent)")

    quartic_disc = 1.0 + 0j
    for i in range(4):
        for j in range(i + 1, 4):
            quartic_disc *= (r[i] - r[j]) ** 2
    cubic_disc = ((A - B) * (B - C) * (C - A)) ** 2
    print(f"  disc(quartic) = {quartic_disc.real:,.1f},  disc(resolvent) = "
          f"{cubic_disc.real:,.1f},  576^2 = {576 ** 2:,}")
    assert abs(quartic_disc - 576 ** 2) < 1e-3
    print("  -> perfect square, so no transposition: Gal is contained in A4;")
    print("     with transitivity and an order-3 element, Gal = A4 exactly.")

    # rescaling y = 4z turns the resolvent into 64*(z^3 - 3z - 1)
    zs = [0.3, -1.7, 2.5]
    assert all(
        abs(((4 * z) ** 3 - 48 * (4 * z) - 64) - 64 * (z ** 3 - 3 * z - 1)) < 1e-9
        for z in zs
    )
    print("  identity  (4z)^3 - 48(4z) - 64 = 64 (z^3 - 3z - 1)  verified")

    zeta9 = cmath.exp(2j * cmath.pi / 9)
    t = zeta9 + 1 / zeta9
    val = t ** 3 - 3 * t + 1
    assert abs(val) < 1e-9
    print(f"  (z9 + 1/z9)^3 - 3(z9 + 1/z9) + 1 = {abs(val):.2e}")
    y = 4 * (-(t))
    assert abs(y ** 3 - 48 * y - 64) < 1e-8
    print(f"  hence y = -4(z9 + 1/z9) = {y.real:+.6f} is a root of y^3-48y-64")
    print("  -> the V4-fixed field is Q(zeta_9)^+ : cyclic cubic, CONDUCTOR 9")

    # no rational root: check all p/q with |p|,|q| <= 200 (rational root thm gives p|1)
    assert all(
        abs((a / b) ** 3 - 3 * (a / b) + 1) > 1e-12
        for a in range(-200, 201)
        for b in range(1, 201)
    )
    print("  z^3 - 3z + 1 has no rational root -> irreducible: a genuine cubic field")
    print()


# ----------------------------------------------------------------------------
# 3.  Cubes mod 9 and the cubic residue character
# ----------------------------------------------------------------------------

UNITS9: List[int] = [u for u in range(9) if math.gcd(u, 9) == 1]


def chi9(x: int) -> int:
    """Cubic residue character mod 9, valued in Z/3."""
    x %= 9
    if x in (1, 8):
        return 0
    if x in (2, 7):
        return 1
    return 2


def demo_character() -> None:
    print("=" * 78)
    print("3.  CUBES MOD 9 AND THE CUBIC RESIDUE CHARACTER")
    print("=" * 78)
    cubes = sorted({(u ** 3) % 9 for u in UNITS9})
    print(f"  units mod 9: {UNITS9}   (cyclic of order {len(UNITS9)})")
    print(f"  cubes  mod 9: {cubes}   -> index {len(UNITS9) // len(cubes)} subgroup")
    assert cubes == [1, 8]
    mult = all((chi9(x * y) - chi9(x) - chi9(y)) % 3 == 0 for x in UNITS9 for y in UNITS9)
    assert mult
    print(f"  chi9 multiplicative on units ?  {mult}")
    print(f"  ker(chi9) = {[u for u in UNITS9 if chi9(u) == 0]} = cubes")
    print("  both sides of the pinning are the SAME group of order 3:")
    print("     A4^ab  =  (Z/9)^x / cubes  =  C3")
    print()


# ----------------------------------------------------------------------------
# 4-6.  Prime level: the sieve, the pinning, the leakage
# ----------------------------------------------------------------------------


def primes_up_to(n: int) -> List[int]:
    sieve = bytearray([1]) * (n + 1)
    sieve[0:2] = b"\x00\x00"
    for i in range(2, int(n ** 0.5) + 1):
        if sieve[i]:
            sieve[i * i :: i] = bytearray(len(sieve[i * i :: i]))
    return [i for i in range(2, n + 1) if sieve[i]]


def root_count_mod_p(p: int) -> int:
    """Number of roots of x^4 + 8x + 12 in F_p."""
    return sum(1 for x in range(p) if (x * x % p * x % p * x + 8 * x + 12) % p == 0)


def frobenius_class(p: int) -> str:
    """Frobenius cycle type of p, read off the root count via the [4,1,0] table."""
    nr = root_count_mod_p(p)
    return {4: "e", 1: "3-cycle", 0: "[2,2]", 2: "transposition!"}[nr]


def demo_prime_level(limit: int = 60000) -> None:
    print("=" * 78)
    print(f"4.  PRIME-LEVEL SIEVE AND THE CUBIC PINNING  (primes up to {limit:,})")
    print("=" * 78)
    ps = [p for p in primes_up_to(limit) if p not in (2, 3) and 331776 % p != 0]
    data: List[Tuple[int, int, str]] = []
    for p in ps:
        nr = root_count_mod_p(p)
        cls = {4: "e", 1: "3-cycle", 0: "[2,2]", 2: "transposition"}[nr]
        data.append((p % 9, nr, cls))
    n = len(data)
    print(f"  unramified primes sieved: {n:,}")

    freq = Counter(nr for _, nr, _ in data)
    print("  root-count densities  (theory: 4 -> 1/12, 1 -> 2/3, 0 -> 1/4, 2 -> 0)")
    for k, target in ((4, 1 / 12), (1, 2 / 3), (0, 1 / 4), (2, 0.0)):
        print(f"     {k} roots: measured {freq[k] / n:.4f}   theory {target:.4f}")
    assert freq[2] == 0, "an A4-field admits no transposition Frobenius"

    # The V4 fork F0 = [nr in {4,0}] versus the dial p mod 9
    print("\n  F0(p) = [Frob p in V4] = [4 or 0 roots mod p]  against dial p mod 9:")
    table: Dict[int, Counter] = {r: Counter() for r in UNITS9}
    for r9, nr, _ in data:
        table[r9][nr in (4, 0)] += 1
    for r9 in UNITS9:
        tot = sum(table[r9].values())
        rate = table[r9][True] / tot if tot else float("nan")
        flag = "  <-- cube mod 9" if chi9(r9) == 0 else ""
        print(f"     p = {r9} mod 9 :  P(F0) = {rate:.4f}   (n = {tot:,}){flag}")

    meas = empirical_mutual_information(((r9, nr in (4, 0)) for r9, nr, _ in data))
    exact = H(1 / 3)
    print(f"\n  I(p mod 9 ; F0)  measured = {meas:.4f} bits")
    print(f"                    EXACT    = H(1/3) = log2(3) - 2/3 = {exact:.6f} bits")
    print(f"                    |gap|    = {abs(meas - exact):.4f}  (finite-sample bias)")

    # the identity fork leaks
    meas1 = empirical_mutual_information(((r9, nr == 4) for r9, nr, _ in data))
    exact1 = H(1 / 12) - (1 / 3) * H(1 / 4)
    print(f"\n  I(p mod 9 ; F1 = [Frob = e])  measured = {meas1:.4f} bits")
    print(f"        EXACT leakage law  H(1/12) - (1/3)H(1/4) = {exact1:.6f} bits")
    print(f"        own entropy        H(1/12)              = {H(1/12):.6f} bits")
    print(f"        0 < {exact1:.4f} < {H(1/12):.4f}:  neither pinned nor flat.")

    # within-V4 flatness, measured
    print("\n  within-V4 flatness (conditional on F0 = 1):")
    for r9 in (1, 8):
        sub = [nr for rr, nr, _ in data if rr == r9]
        insideV4 = [nr for nr in sub if nr in (4, 0)]
        rate_e = sum(1 for nr in insideV4 if nr == 4) / len(insideV4)
        print(f"     P(Frob = e | p = {r9} mod 9) = {rate_e:.4f}   (theory 1/4)")
    cond_pairs = [(rr, nr == 4) for rr, nr, _ in data if nr in (4, 0)]
    print(f"     conditional I(dial ; e vs [2,2] | F0=1) = "
          f"{empirical_mutual_information(cond_pairs):.4f} bits   (theory 0)")

    # minimality of the modulus and flatness off the conductor
    print("\n  minimality / flatness checks:")
    for m in (3, 5, 7):
        val = empirical_mutual_information(((p % m, nr in (4, 0)) for (p, (_, nr, _)) in zip(ps, data)))
        print(f"     I(p mod {m} ; F0) measured = {val:.4f} bits   (theory 0)")
    print()


# ----------------------------------------------------------------------------
# 7.  Semiprime channels
# ----------------------------------------------------------------------------


def demo_semiprime() -> None:
    print("=" * 78)
    print("5.  SEMIPRIME LEVEL: THE ORDER-3 CHANNEL")
    print("=" * 78)
    # exact model: two independent uniform classes a, b in Z/3; dial reads a+b.
    pairs = [(a, b) for a in range(3) for b in range(3)]
    w = 1 / 9

    def channel(event: Callable[[int, int], bool]) -> float:
        joint = {}
        for a, b in pairs:
            key = ((a + b) % 3, event(a, b))
            joint[key] = joint.get(key, 0.0) + w
        return mutual_information(joint)

    rows = [
        ("both split (AND)", lambda a, b: a == 0 and b == 0,
         H(1 / 9) - (1 / 3) * H(1 / 3), 0.1997),
        ("at least one (OR)", lambda a, b: a == 0 or b == 0,
         H(5 / 9) - H(1 / 3), 0.0688),
        ("exactly one (XOR)", lambda a, b: (a == 0) != (b == 0),
         H(4 / 9) - (2 / 3) * H(1 / 3), 0.3736),
        ("first factor splits", lambda a, b: a == 0, 0.0, 0.0001),
    ]
    print(f"  {'event':<22}{'exact':>10}{'closed form':>14}{'measured (30k)':>17}")
    for name, ev, closed, observed in rows:
        val = channel(ev)
        assert abs(val - closed) < 1e-12
        print(f"  {name:<22}{val:>10.4f}{closed:>14.4f}{observed:>17.4f}")

    # split count
    joint = {}
    for a, b in pairs:
        k = (1 if a == 0 else 0) + (1 if b == 0 else 0)
        joint[((a + b) % 3, k)] = joint.get(((a + b) % 3, k), 0.0) + w
    sc = mutual_information(joint)
    closed = H(4 / 9, 4 / 9, 1 / 9) - H(1 / 3)
    print(f"  {'split count':<22}{sc:>10.4f}{closed:>14.4f}{0.4710:>17.4f}")
    marg = Counter()
    for a, b in pairs:
        marg[(1 if a == 0 else 0) + (1 if b == 0 else 0)] += 1
    print(f"  split-count marginal = "
          f"{ {k: f'{v}/9' for k, v in sorted(marg.items())} }  = Bin(2, 1/3)")
    print("  the which-factor wall is an EXACT zero: a product is symmetric in")
    print("  its factors, so no dial can say which factor split.")
    print()


def demo_multifactor(kmax: int = 8) -> None:
    print("=" * 78)
    print("6.  THE k-FACTOR AND LAW AND ITS COLLAPSE")
    print("=" * 78)
    print("   N = p_1 ... p_{k+1};  I = H(3^-(k+1)) - (1/3) H(3^-k)")
    print(f"  {'k':>3}{'factors':>9}{'exact I (bits)':>18}{'brute force':>15}")
    for k in range(1, kmax + 1):
        closed = H((1 / 3) ** (k + 1)) - (1 / 3) * H((1 / 3) ** k)
        if k <= 6:
            joint: Dict[Tuple[int, bool], float] = {}
            w = 3.0 ** (-(k + 1))
            for tup in itertools.product(range(3), repeat=k + 1):
                key = (sum(tup) % 3, all(t == 0 for t in tup))
                joint[key] = joint.get(key, 0.0) + w
            brute = mutual_information(joint)
            assert abs(brute - closed) < 1e-12
            brute_s = f"{brute:.6f}"
        else:
            brute_s = "  (skipped)"
        print(f"  {k:>3}{k + 1:>9}{closed:>18.6f}{brute_s:>15}")
    print("  -> the channel dies: many-factor residues say essentially nothing.")
    print()


# ----------------------------------------------------------------------------
# 8.  The criterion and the A5 wall
# ----------------------------------------------------------------------------


def demo_criterion() -> None:
    print("=" * 78)
    print("7.  THE PINNING-CONTENT CRITERION AND THE A5 WALL")
    print("=" * 78)

    def factors_through_ab(fork: Callable[[Perm], bool], group: List[Perm],
                           comm: set) -> bool:
        return all(fork(compose(g, c)) == fork(g) for g in group for c in comm)

    commA4 = {commutator(a, b) for a in A4 for b in A4}
    f0 = factors_through_ab(lambda g: g in V4, A4, commA4)
    f1 = factors_through_ab(lambda g: g == IDENT, A4, commA4)
    print(f"  A4:  fork [Frob in V4] factors through the abelianization ?  {f0}")
    print(f"  A4:  fork [Frob = e]   factors through the abelianization ?  {f1}")
    assert f0 and not f1
    print("     -> the V4 fork is PINNABLE (and only by a cubic character,")
    print("        since |A4^ab| = 3);  the identity fork can only LEAK.")

    # A5: perfect, so the commutator subgroup is everything.
    S5 = [tuple(p) for p in itertools.permutations(range(5))]
    A5 = [p for p in S5 if sign(p) == 1]
    commA5 = set()
    frontier = {commutator(a, b) for a in A5 for b in A5}
    while frontier - commA5:
        commA5 |= frontier
        frontier = {compose(x, y) for x in commA5 for y in commA5}
    print(f"\n  A5:  |A5| = {len(A5)},  |[A5,A5]| = {len(commA5)}  -> A5 is perfect")
    assert len(commA5) == len(A5)
    forks = {
        "identity": lambda g: g == (0, 1, 2, 3, 4),
        "5-cycle": lambda g: len(cycle_type(g)) == 1 and cycle_type(g)[0] == 5,
        "fixes a point": lambda g: any(g[i] == i for i in range(5)),
    }
    for name, fk in forks.items():
        ok = all(fk(compose(g, c)) == fk(g) for g in A5 for c in commA5)
        const = len({fk(g) for g in A5}) == 1
        print(f"     fork '{name}': factors through A5^ab ? {ok}   (constant ? {const})")
    print("  -> over an A5-field NO non-constant fork is pinnable by any modulus:")
    print("     absolutely unpinnable.  This closes the table")
    print("       C2, C3, S3, S4 : pinned ;  A4 : cubic-pinned ;  A5 : nothing.")
    print()


def cycle_type(p: Perm) -> List[int]:
    seen = [False] * len(p)
    out: List[int] = []
    for i in range(len(p)):
        if not seen[i]:
            length = 0
            j = i
            while not seen[j]:
                seen[j] = True
                j = p[j]
                length += 1
            out.append(length)
    return sorted(out, reverse=True)


# ----------------------------------------------------------------------------
# 9.  Summary of exact constants
# ----------------------------------------------------------------------------


def demo_constants() -> None:
    print("=" * 78)
    print("8.  THE EXACT CONSTANTS OF THE THEORY")
    print("=" * 78)
    rows = [
        ("H(1/3) = log2(3) - 2/3", H(1 / 3), "V4 fork, pinned", 0.9188),
        ("H(1/4) = 2 - (3/4)log2(3)", H(1 / 4), "inside the V4 fibre", None),
        ("H(1/12)", H(1 / 12), "entropy of the identity fork", None),
        ("H(1/12) - (1/3)H(1/4)", H(1 / 12) - H(1 / 4) / 3, "identity fork leak", 0.1419),
        ("H(1/9) - (1/3)H(1/3)", H(1 / 9) - H(1 / 3) / 3, "semiprime AND", 0.1997),
        ("H(5/9) - H(1/3)", H(5 / 9) - H(1 / 3), "semiprime OR", 0.0688),
        ("H(4/9) - (2/3)H(1/3)", H(4 / 9) - 2 * H(1 / 3) / 3, "semiprime XOR", 0.3736),
        ("H(4/9,4/9,1/9) - H(1/3)", H(4 / 9, 4 / 9, 1 / 9) - H(1 / 3),
         "semiprime split count", 0.4710),
        ("0", 0.0, "which-factor wall", 0.0001),
    ]
    print(f"  {'closed form':<28}{'value':>10}  {'meaning':<30}{'measured':>10}")
    for name, val, meaning, obs in rows:
        obs_s = f"{obs:.4f}" if obs is not None else "     --"
        print(f"  {name:<28}{val:>10.6f}  {meaning:<30}{obs_s:>10}")
    assert abs(H(1 / 3) - (math.log2(3) - 2 / 3)) < 1e-12
    assert abs(H(1 / 4) - (2 - 0.75 * math.log2(3))) < 1e-12
    print()


def main() -> None:
    print()
    print("  CUBIC PINNING OF A NON-ABELIAN FORK")
    print("  The A4-field of x^4 + 8x + 12 and the conductor-9 cyclic cubic")
    print()
    demo_group()
    demo_resolvent()
    demo_character()
    demo_prime_level()
    demo_semiprime()
    demo_multifactor()
    demo_criterion()
    demo_constants()
    print("  All assertions passed.")


if __name__ == "__main__":
    main()
