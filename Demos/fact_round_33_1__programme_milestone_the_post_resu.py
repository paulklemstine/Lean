#!/usr/bin/env python3
"""
The type-channel law, numerically.

For a finite Galois group G (acting on the n roots of a polynomial f), let G' be its
derived subgroup, c(g) the coset of G' containing g (by class field theory: the residue
class of the prime p modulo the conductor of the maximal abelian subfield), and T(g) the
cycle type of g (by Chebotarev: the splitting type of f mod p).  With g uniform on G:

    I(c ; T) = H(T) - H(T | c) = log2[G:G'] - H(c | T)                      (law)
    max(0, H(T) - log2|G'|) <= I(c ; T) <= min(H(T), log2[G:G'])            (sandwich)
    I(c ; (T1,T2)) = I(c ; T1) + I(c ; T2 | T1)                             (battery chain rule)

Part 1 computes everything exactly from the group.
Part 2 samples real primes, factors f mod p, and watches the empirical channel converge.

Pure Python 3 (standard library only).
"""
from __future__ import annotations

import math
import random
from collections import Counter
from itertools import product
from typing import Callable, Dict, Hashable, Iterable, List, Sequence, Tuple

Perm = Tuple[int, ...]
L3: float = math.log2(3)

# ----------------------------------------------------------------------------------------
# Part 0: permutation groups
# ----------------------------------------------------------------------------------------


def compose(a: Perm, b: Perm) -> Perm:
    """(a*b)(x) = a(b(x))."""
    return tuple(a[b[x]] for x in range(len(a)))


def inverse(a: Perm) -> Perm:
    inv = [0] * len(a)
    for i, ai in enumerate(a):
        inv[ai] = i
    return tuple(inv)


def generate(gens: Sequence[Perm]) -> List[Perm]:
    """Closure of a set of permutations under composition (breadth-first)."""
    n = len(gens[0])
    ident: Perm = tuple(range(n))
    seen = {ident}
    frontier = [ident]
    while frontier:
        new = []
        for g in frontier:
            for s in gens:
                h = compose(s, g)
                if h not in seen:
                    seen.add(h)
                    new.append(h)
        frontier = new
    return sorted(seen)


def derived_subgroup(G: Sequence[Perm]) -> List[Perm]:
    comms = {compose(compose(a, b), compose(inverse(a), inverse(b))) for a in G for b in G}
    return generate(sorted(comms))


def coset_readout(G: Sequence[Perm], N: Sequence[Perm]) -> Dict[Perm, int]:
    """Label each g in G by the index of its coset gN."""
    label: Dict[Perm, int] = {}
    k = 0
    for g in G:
        if g not in label:
            for h in N:
                label[compose(g, h)] = k
            k += 1
    return label


def cycle_type(g: Perm) -> Tuple[int, ...]:
    """Faithful splitting type: sorted cycle lengths (= degrees of the factors of f mod p)."""
    n, seen, lens = len(g), set(), []
    for x in range(n):
        if x not in seen:
            m, y = 0, x
            while y not in seen:
                seen.add(y)
                y = g[y]
                m += 1
            lens.append(m)
    return tuple(sorted(lens, reverse=True))


def quartic_readout(g: Perm) -> Tuple[int, int]:
    """(#fixed points, #points on 2-cycles): faithful only up to degree 4."""
    ct = cycle_type(g)
    return (ct.count(1), 2 * ct.count(2))


# ----------------------------------------------------------------------------------------
# Part 0b: finite Shannon calculus on a uniform sample space
# ----------------------------------------------------------------------------------------


def entropy_of_counts(counts: Iterable[int]) -> float:
    cs = list(counts)
    tot = sum(cs)
    return -sum(c / tot * math.log2(c / tot) for c in cs if c)


def H(S: Sequence, f: Callable) -> float:
    return entropy_of_counts(Counter(f(w) for w in S).values())


def I(S: Sequence, f: Callable, g: Callable) -> float:
    return H(S, f) + H(S, g) - H(S, lambda w: (f(w), g(w)))


def condH(S: Sequence, f: Callable, t: Callable) -> float:
    """H(f | t) = H(f, t) - H(t)."""
    return H(S, lambda w: (f(w), t(w))) - H(S, t)


def condI(S: Sequence, f: Callable, g: Callable, t: Callable) -> float:
    """I(f ; g | t) = sum_b p(t=b) I(f ; g | t=b)."""
    fibres: Dict[Hashable, List] = {}
    for w in S:
        fibres.setdefault(t(w), []).append(w)
    return sum(len(F) / len(S) * I(F, f, g) for F in fibres.values())


# ----------------------------------------------------------------------------------------
# Part 1: the named Galois groups
# ----------------------------------------------------------------------------------------


def affine_group(n: int, units: Sequence[int]) -> List[Perm]:
    """{ k -> u*k + a mod n : u in units }."""
    return sorted({tuple((u * k + a) % n for k in range(n)) for u in units for a in range(n)})


def named_groups() -> Dict[str, Tuple[str, List[Perm]]]:
    s = lambda *p: tuple(p)
    return {
        "C4": ("x^4+x^3+x^2+x+1", generate([s(1, 2, 3, 0)])),
        "V4": ("x^4-10x^2+1", generate([s(1, 0, 3, 2), s(2, 3, 0, 1)])),
        "S3": ("x^3+x+1", generate([s(1, 0, 2), s(1, 2, 0)])),
        "D4": ("x^4-2", affine_group(4, [1, 3])),
        "A4": ("x^4+8x+12", generate([s(1, 2, 0, 3), s(1, 0, 3, 2)])),
        "S4": ("x^4+x+1", generate([s(1, 0, 2, 3), s(1, 2, 3, 0)])),
        "D5": ("x^5-5x+12", affine_group(5, [1, 4])),
        "F20": ("x^5-2", affine_group(5, [1, 2, 3, 4])),
        "A5": ("x^5+20x+16", generate([s(1, 2, 0, 3, 4), s(0, 1, 3, 4, 2), s(1, 2, 3, 4, 0)])),
        "S5": ("x^5-x-1", generate([s(1, 0, 2, 3, 4), s(1, 2, 3, 4, 0)])),
        "D6": ("x^6-2", affine_group(6, [1, 5])),
        "S3 regular": ("closure of x^3-2", generate([s(2, 3, 4, 5, 0, 1), s(1, 0, 5, 4, 3, 2)])),
    }


def channel_report(G: List[Perm], T: Callable[[Perm], Hashable] = cycle_type) -> Dict[str, float]:
    N = derived_subgroup(G)
    lab = coset_readout(G, N)
    c = lambda g: lab[g]
    k = len(G) // len(N)
    HT = H(G, T)
    info = I(G, c, T)
    return {
        "|G|": len(G), "|G'|": len(N), "index": k,
        "H(T)": HT, "I": info, "cap": math.log2(k),
        "loss=H(c|T)": condH(G, c, T), "H(T|c)": condH(G, T, c),
        "lower": max(0.0, HT - math.log2(len(N))), "upper": min(HT, math.log2(k)),
    }


def part1() -> None:
    print("=" * 96)
    print("PART 1 - exact type channels  I(coset of G' ; cycle type)")
    print("=" * 96)
    hdr = f"{'G':>11} {'polynomial':>18} {'|G|':>4} {'index':>6} {'H(T)':>7} {'lower':>7} {'I':>7} {'upper':>7} {'loss':>7}"
    print(hdr)
    print("-" * len(hdr))
    for name, (poly, G) in named_groups().items():
        r = channel_report(G)
        # the law, both forms, and the sandwich
        assert abs(r["I"] - (r["H(T)"] - r["H(T|c)"])) < 1e-12
        assert abs(r["I"] - (r["cap"] - r["loss=H(c|T)"])) < 1e-12
        assert r["lower"] - 1e-12 <= r["I"] <= r["upper"] + 1e-12
        print(f"{name:>11} {poly:>18} {r['|G|']:>4} {r['index']:>6} {r['H(T)']:7.4f} "
              f"{r['lower']:7.4f} {r['I']:7.4f} {r['upper']:7.4f} {r['loss=H(c|T)']:7.4f}")

    g = named_groups()
    print("\nClosed forms (L = log2 3):")
    checks = [
        ("S3 channel = 1", channel_report(g["S3"][1])["I"], 1.0),
        ("D4 channel = 9/4 - 3L/8", channel_report(g["D4"][1], quartic_readout)["I"], 9 / 4 - 3 * L3 / 8),
        ("D4 H(T) = 5/2 - 3L/8", channel_report(g["D4"][1], quartic_readout)["H(T)"], 5 / 2 - 3 * L3 / 8),
        ("D4 sandwich lower = 3/2 - 3L/8", channel_report(g["D4"][1])["lower"], 3 / 2 - 3 * L3 / 8),
        ("D6 H(T) = 1 + 3L/4", channel_report(g["D6"][1])["H(T)"], 1 + 3 * L3 / 4),
        ("D6 channel = 4/3 + L/4", channel_report(g["D6"][1])["I"], 4 / 3 + L3 / 4),
        ("D6 loss = 2/3 - L/4", channel_report(g["D6"][1])["loss=H(c|T)"], 2 / 3 - L3 / 4),
        ("D6 quartic-readout channel = 1 + L/4", channel_report(g["D6"][1], quartic_readout)["I"], 1 + L3 / 4),
        ("S3 regular H(T) = 2/3 + L/2", channel_report(g["S3 regular"][1])["H(T)"], 2 / 3 + L3 / 2),
        ("S3 regular channel = 1", channel_report(g["S3 regular"][1])["I"], 1.0),
    ]
    for label, got, want in checks:
        assert abs(got - want) < 1e-12, label
        print(f"  {label:<40} computed {got:.6f}   closed form {want:.6f}   OK")

    # the critic's counterexample to "I = H(coset | T)"
    r = channel_report(g["S3"][1])
    print(f"\nCounterexample to the wording 'I = H(G^ab-class | T)':  S3 has I = {r['I']:.0f} bit "
          f"but H(coset | T) = {r['loss=H(c|T)']:.0f}.")

    # universality: conjugating D4 by the transposition (1 2)
    D4 = g["D4"][1]
    h: Perm = (0, 2, 1, 3)
    D4c = sorted(compose(compose(h, x), inverse(h)) for x in D4)
    print(f"\nUniversality: D4 conjugated by (1 2) is a different subgroup of S4: {set(D4c) != set(D4)}; "
          f"channel {channel_report(D4c)['I']:.6f} vs {channel_report(D4)['I']:.6f}")

    # batteries
    S4 = g["S4"][1]
    N = derived_subgroup(S4)
    lab = coset_readout(S4, N)
    c = lambda x: lab[x]
    root = lambda x: x[0]
    print(f"\nS4 battery (type, image of root 0): I(c;T) = {I(S4, c, cycle_type):.4f}, "
          f"I(c;root | T) = {condI(S4, c, root, cycle_type):.4f}, "
          f"I(c;(T,root)) = {I(S4, c, lambda x: (cycle_type(x), root(x))):.4f}  (saturated)")
    D4N = derived_subgroup(D4)
    lab4 = coset_readout(D4, D4N)
    c4 = lambda x: lab4[x]
    a, b = I(D4, c4, cycle_type), I(D4, c4, root)
    ab = I(D4, c4, lambda x: (cycle_type(x), root(x)))
    ci = condI(D4, c4, root, cycle_type)
    assert abs(ab - (a + ci)) < 1e-12
    print(f"D4 battery: I(c;T) = {a:.4f}, I(c;root) = {b:.4f}, I(c;(T,root)) = {ab:.4f} "
          f"= I(c;T) + I(c;root|T) = {a:.4f} + {ci:.4f}   (cap 2)")
    print(f"Redundant battery (c, c) on D4: I(c;c) + I(c;c) = {2 * I(D4, c4, c4):.1f} > "
          f"I(c;(c,c)) = {I(D4, c4, lambda x: (c4(x), c4(x))):.1f}   (super-additivity fails)")


# ----------------------------------------------------------------------------------------
# Part 2: real primes (Chebotarev + class field theory in action)
# ----------------------------------------------------------------------------------------

Poly = List[int]  # coefficients, low degree first, reduced mod p


def trim(a: Poly) -> Poly:
    while a and a[-1] == 0:
        a.pop()
    return a


def pmod(a: Poly, m: Poly, p: int) -> Poly:
    a = [x % p for x in a]
    trim(a)
    inv = pow(m[-1], p - 2, p)
    while len(a) >= len(m):
        q = a[-1] * inv % p
        sh = len(a) - len(m)
        for i, mi in enumerate(m):
            a[sh + i] = (a[sh + i] - q * mi) % p
        trim(a)
    return a


def pmul(a: Poly, b: Poly, m: Poly, p: int) -> Poly:
    if not a or not b:
        return []
    out = [0] * (len(a) + len(b) - 1)
    for i, x in enumerate(a):
        if x:
            for j, y in enumerate(b):
                out[i + j] += x * y
    return pmod(out, m, p)


def ppow(base: Poly, e: int, m: Poly, p: int) -> Poly:
    result: Poly = [1]
    base = pmod(base, m, p)
    while e:
        if e & 1:
            result = pmul(result, base, m, p)
        base = pmul(base, base, m, p)
        e >>= 1
    return result


def pgcd(a: Poly, b: Poly, p: int) -> Poly:
    a, b = trim([x % p for x in a]), trim([x % p for x in b])
    while b:
        a, b = b, pmod(a, b, p)
    inv = pow(a[-1], p - 2, p)
    return [x * inv % p for x in a]


def pdiv(a: Poly, b: Poly, p: int) -> Poly:
    a = [x % p for x in a]
    inv = pow(b[-1], p - 2, p)
    q = [0] * (len(a) - len(b) + 1)
    while len(a) >= len(b) and trim(a):
        c = a[-1] * inv % p
        sh = len(a) - len(b)
        q[sh] = c
        for i, bi in enumerate(b):
            a[sh + i] = (a[sh + i] - c * bi) % p
        trim(a)
    return trim(q)


def splitting_type(f: Poly, p: int) -> Tuple[int, ...]:
    """Degrees of the irreducible factors of squarefree f mod p (distinct-degree factorization)."""
    f = trim([x % p for x in f])
    degs: List[int] = []
    h: Poly = [0, 1]
    d = 0
    while len(f) > 1:
        d += 1
        if 2 * d > len(f) - 1:
            degs.append(len(f) - 1)
            break
        h = ppow(h, p, f, p)
        diff = trim([(x - y) % p for x, y in zip(h + [0] * 3, [0, 1] + [0] * (len(h) + 1))])
        g = pgcd(f, diff, p) if diff else f
        k = (len(g) - 1) // d
        degs.extend([d] * k)
        if k:
            f = pdiv(f, g, p)
            h = pmod(h, f, p)
    return tuple(sorted(degs, reverse=True))


def primes_upto(n: int) -> List[int]:
    sieve = bytearray([1]) * (n + 1)
    sieve[0:2] = b"\x00\x00"
    for i in range(2, int(n ** 0.5) + 1):
        if sieve[i]:
            sieve[i * i::i] = bytearray(len(sieve[i * i::i]))
    return [i for i in range(n + 1) if sieve[i]]


def empirical_channel(f: Poly, residue: Callable[[int], Hashable], bad: int, primes: Sequence[int],
                      readout: Callable[[Tuple[int, ...]], Hashable] = lambda t: t) -> float:
    rows = [(residue(p), readout(splitting_type(f, p))) for p in primes if bad % p != 0]
    return I(rows, lambda r: r[0], lambda r: r[1])


def part2(limit: int = 60000) -> None:
    print("\n" + "=" * 96)
    print(f"PART 2 - real primes p < {limit}: empirical I(p mod m ; splitting type of f mod p)")
    print("=" * 96)
    ps = primes_upto(limit)
    coarse = lambda t: (t.count(1), 2 * t.count(2))
    experiments = [
        ("x^3-2   (S3, p mod 3)", [-2, 0, 0, 1], lambda p: p % 3, 6, 1.0, None),
        ("x^4-2   (D4, p mod 8)", [-2, 0, 0, 0, 1], lambda p: p % 8, 2, 9 / 4 - 3 * L3 / 8, None),
        ("x^6-2   (D6, p mod 24)", [-2, 0, 0, 0, 0, 0, 1], lambda p: p % 24, 6, 4 / 3 + L3 / 4, None),
        ("x^6-2   quartic readout", [-2, 0, 0, 0, 0, 0, 1], lambda p: p % 24, 6, 1 + L3 / 4, coarse),
        ("x^5-x-1 (S5, (2869/p))", [-1, -1, 0, 0, 0, 1], lambda p: pow(2869, (p - 1) // 2, p) == 1, 2 * 2869,
         1.0, None),
    ]
    for label, f, res, bad, theory, ro in experiments:
        emp = empirical_channel(f, res, bad, ps, ro or (lambda t: t))
        th = f"{theory:.4f}" if theory is not None else "  n/a "
        print(f"  {label:<26} empirical {emp:.4f}   group-theoretic {th}")
    print("  (For S5 the abelianization is S5/A5 = C2, read by the Legendre symbol of the")
    print("   discriminant 2869 = 19*151; the splitting type determines the parity, so 1 bit.)")


def main() -> None:
    random.seed(0)
    part1()
    part2()


if __name__ == "__main__":
    main()
