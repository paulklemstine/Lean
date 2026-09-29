#!/usr/bin/env python3
"""
Septic Frontier: numerical demonstrations.

The polynomial x^7 - 3 has Galois group the Frobenius group
F42 = AGL(1,7) = { x -> a x + b : a in (Z/7)^*, b in Z/7 }.
This script

  1. computes the exact entropies of the splitting-type channel on AGL(1,q)
     (type entropy, conductor information, residual) and checks the closed forms
         I(T ; p mod q) = H(order of a uniform element of C_{q-1})
         H(T | p mod q) = (q log2 q - (q-1) log2(q-1)) / (q (q-1))  <=  log2 q / (q-1);
  2. factors x^7 - 3 modulo tens of thousands of actual primes, recording the
     splitting type, and measures the empirical mutual information between the
     type and p mod m for several moduli m (signal at 7 | m, flat otherwise);
  3. checks the commutator identity behind the "abelian characters kill
     translations" theorem.

Pure Python 3, no dependencies.
"""
from __future__ import annotations

import math
from collections import Counter
from typing import Callable, Dict, Hashable, Iterable, List, Sequence, Tuple

Poly = List[int]  # coefficients, lowest degree first, reduced mod p


# ---------------------------------------------------------------------------
# 1. Information theory on finite uniform sample spaces
# ---------------------------------------------------------------------------

def entropy(labels: Iterable[Hashable]) -> float:
    """Shannon entropy (bits) of the empirical distribution of `labels`."""
    counts = Counter(labels)
    n = sum(counts.values())
    return -sum(c / n * math.log2(c / n) for c in counts.values())


def mutual_information(pairs: Sequence[Tuple[Hashable, Hashable]]) -> float:
    """I(X;Y) = H(X) + H(Y) - H(X,Y) for the empirical distribution of pairs."""
    xs = [x for x, _ in pairs]
    ys = [y for _, y in pairs]
    return entropy(xs) + entropy(ys) - entropy(pairs)


def mult_order(a: int, q: int) -> int:
    """Multiplicative order of a modulo the prime q (a != 0 mod q)."""
    k, x = 1, a % q
    while x != 1:
        x = x * a % q
        k += 1
    return k


def cyclic_type_entropy(n: int) -> float:
    """typeEntropy(n): entropy of the order of a uniform element of C_n."""
    return entropy(n // math.gcd(k, n) for k in range(n))


def affine_type(a: int, b: int, q: int) -> Tuple[int, int]:
    """Cycle data (fixed points, length of non-trivial cycles) of x -> a x + b on Z/q."""
    if a % q == 1:
        return (q, 1) if b % q == 0 else (0, q)
    return (1, mult_order(a, q))


def affine_cycle_data_bruteforce(a: int, b: int, q: int) -> Tuple[int, int]:
    """Same data computed by literally following orbits (a faithfulness check)."""
    fixed = sum(1 for x in range(q) if (a * x + b) % q == x)
    lengths = set()
    for x in range(q):
        if (a * x + b) % q == x:
            continue
        y, k = (a * x + b) % q, 1
        while y != x:
            y, k = (a * y + b) % q, k + 1
        lengths.add(k)
    assert len(lengths) <= 1, "all non-trivial cycles must have equal length"
    return (fixed, lengths.pop() if lengths else 1)


def agl_channel(q: int) -> Dict[str, float]:
    """Exact entropies of the type channel on AGL(1,q)."""
    group = [(a, b) for a in range(1, q) for b in range(q)]
    for a, b in group:
        assert affine_type(a, b, q) == affine_cycle_data_bruteforce(a, b, q)
    pairs = [(affine_type(a, b, q), a) for a, b in group]
    h_t = entropy(t for t, _ in pairs)
    info = mutual_information(pairs)
    return {"H(T)": h_t, "I(T;a)": info, "H(T|a)": h_t - info}


def residual_formula(q: int) -> float:
    return (q * math.log2(q) - (q - 1) * math.log2(q - 1)) / (q * (q - 1))


# ---------------------------------------------------------------------------
# 2. Factoring x^7 - 3 modulo primes (distinct-degree factorisation)
# ---------------------------------------------------------------------------

def primes_up_to(n: int) -> List[int]:
    sieve = bytearray([1]) * (n + 1)
    sieve[0:2] = b"\x00\x00"
    for i in range(2, int(n ** 0.5) + 1):
        if sieve[i]:
            sieve[i * i:: i] = bytearray(len(sieve[i * i:: i]))
    return [i for i in range(n + 1) if sieve[i]]


def trim(f: Poly) -> Poly:
    while f and f[-1] == 0:
        f.pop()
    return f


def poly_mod(f: Poly, g: Poly, p: int) -> Poly:
    f = f[:]
    inv = pow(g[-1], p - 2, p)
    while len(f) >= len(g):
        c = f[-1] * inv % p
        shift = len(f) - len(g)
        for i, gi in enumerate(g):
            f[shift + i] = (f[shift + i] - c * gi) % p
        trim(f)
    return f


def poly_mulmod(f: Poly, g: Poly, m: Poly, p: int) -> Poly:
    if not f or not g:
        return []
    out = [0] * (len(f) + len(g) - 1)
    for i, fi in enumerate(f):
        if fi:
            for j, gj in enumerate(g):
                out[i + j] = (out[i + j] + fi * gj) % p
    return poly_mod(trim(out), m, p)


def poly_powmod(f: Poly, e: int, m: Poly, p: int) -> Poly:
    result: Poly = [1]
    base = poly_mod(f, m, p)
    while e:
        if e & 1:
            result = poly_mulmod(result, base, m, p)
        base = poly_mulmod(base, base, m, p)
        e >>= 1
    return result


def poly_gcd(f: Poly, g: Poly, p: int) -> Poly:
    f, g = trim(f[:]), trim(g[:])
    while g:
        f, g = g, poly_mod(f, g, p)
    inv = pow(f[-1], p - 2, p)
    return [c * inv % p for c in f]


def poly_sub(f: Poly, g: Poly, p: int) -> Poly:
    n = max(len(f), len(g))
    return trim([((f[i] if i < len(f) else 0) - (g[i] if i < len(g) else 0)) % p
                 for i in range(n)])


def poly_divexact(f: Poly, g: Poly, p: int) -> Poly:
    f = f[:]
    q = [0] * (len(f) - len(g) + 1)
    inv = pow(g[-1], p - 2, p)
    while len(f) >= len(g) and f:
        c = f[-1] * inv % p
        shift = len(f) - len(g)
        q[shift] = c
        for i, gi in enumerate(g):
            f[shift + i] = (f[shift + i] - c * gi) % p
        trim(f)
    return q


def factor_degrees(f: Poly, p: int) -> List[int]:
    """Sorted degrees of the irreducible factors of a squarefree f over F_p."""
    degrees: List[int] = []
    h: Poly = [0, 1]  # x
    d = 0
    while len(f) - 1 >= 2 * (d + 1):
        d += 1
        h = poly_powmod(h, p, f, p)  # x^(p^d) mod f
        g = poly_gcd(f, poly_sub(h, [0, 1], p), p)
        if len(g) > 1:
            degrees += [d] * ((len(g) - 1) // d)
            f = poly_divexact(f, g, p)
            h = poly_mod(h, f, p)
    if len(f) > 1:
        degrees.append(len(f) - 1)
    return sorted(degrees)


def septic_type_from_degrees(degs: List[int]) -> Tuple[int, int]:
    """Translate a factorisation pattern into (fixed roots, cycle length)."""
    ones = degs.count(1)
    rest = [d for d in degs if d != 1]
    if not rest:
        return (ones, 1)
    assert len(set(rest)) == 1
    return (ones, rest[0])


# ---------------------------------------------------------------------------
# 3. The commutator identity behind the abelian obstruction
# ---------------------------------------------------------------------------

def compose(f: Callable[[int], int], g: Callable[[int], int]) -> Callable[[int], int]:
    return lambda x: f(g(x))


def check_commutator(q: int = 7) -> bool:
    """t_{(a-1)c} = s_a t_c s_a^{-1} t_c^{-1} for all a != 0,1 and c in Z/q."""
    for a in range(2, q):
        ainv = pow(a, q - 2, q)
        for c in range(q):
            s = lambda x, a=a: a * x % q
            s_inv = lambda x, ainv=ainv: ainv * x % q
            t = lambda x, c=c: (x + c) % q
            t_inv = lambda x, c=c: (x - c) % q
            comm = compose(s, compose(t, compose(s_inv, t_inv)))
            target = (a - 1) * c % q
            if any(comm(x) != (x + target) % q for x in range(q)):
                return False
    return True


# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------

def main() -> None:
    print("=" * 72)
    print("PART 1. Exact type channel on AGL(1,q)")
    print("=" * 72)
    l3, l7 = math.log2(3), math.log2(7)
    ch = agl_channel(7)
    print(f"q = 7 (the Frobenius group F42 of x^7 - 3)")
    print(f"  H(T)          = {ch['H(T)']:.6f}   closed form 4/21 + (6/7)log2 3 + (1/6)log2 7 "
          f"= {4/21 + 6/7*l3 + l7/6:.6f}")
    print(f"  I(T; p mod 7) = {ch['I(T;a)']:.6f}   closed form 1/3 + log2 3 = {1/3 + l3:.6f}")
    print(f"  typeEntropy(6)= {cyclic_type_entropy(6):.6f}   (the sextic cyclic channel)")
    print(f"  H(T | p mod 7)= {ch['H(T|a)']:.6f}   residual formula = {residual_formula(7):.6f}")
    print()
    print(f"{'q':>4} {'H(T)':>9} {'I(T;a)':>9} {'tE(q-1)':>9} {'resid':>9} "
          f"{'formula':>9} {'bound':>9} {'I/H':>7} {'1-lg q/(q-1)':>13}")
    for q in [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43]:
        c = agl_channel(q)
        te = cyclic_type_entropy(q - 1)
        assert abs(c["I(T;a)"] - te) < 1e-9
        assert abs(c["H(T|a)"] - residual_formula(q)) < 1e-9
        assert residual_formula(q) <= math.log2(q) / (q - 1) + 1e-12
        assert c["I(T;a)"] >= 1 - 1e-12
        print(f"{q:>4} {c['H(T)']:>9.5f} {c['I(T;a)']:>9.5f} {te:>9.5f} {c['H(T|a)']:>9.5f} "
              f"{residual_formula(q):>9.5f} {math.log2(q)/(q-1):>9.5f} "
              f"{c['I(T;a)']/c['H(T)']:>7.4f} {1-math.log2(q)/(q-1):>13.4f}")
    print("  all closed forms, bounds and the one-bit floor confirmed.")

    print()
    print("=" * 72)
    print("PART 2. Factoring x^7 - 3 modulo real primes")
    print("=" * 72)
    bound = 200_000
    f = None
    data: List[Tuple[int, Tuple[int, int]]] = []
    for p in primes_up_to(bound):
        if p in (3, 7):  # the ramified primes
            continue
        f = [(-3) % p, 0, 0, 0, 0, 0, 0, 1]
        degs = factor_degrees(f, p)
        data.append((p, septic_type_from_degrees(degs)))
    n = len(data)
    freq = Counter(t for _, t in data)
    predicted = {(7, 1): 1, (0, 7): 6, (1, 2): 7, (1, 3): 14, (1, 6): 14}
    print(f"{n} unramified primes p < {bound}")
    print(f"{'type':>8} {'observed':>10} {'Chebotarev':>11}")
    for t, k in predicted.items():
        print(f"{str(t):>8} {freq[t]/n:>10.5f} {k/42:>11.5f}")
    print(f"empirical H(T) = {entropy(t for _, t in data):.5f}   (theory {ch['H(T)']:.5f})")
    print()
    print("Mutual information between the splitting type and p mod m:")
    for m in [2, 3, 4, 5, 6, 7, 11, 13, 14, 21, 35]:
        info = mutual_information([(t, p % m) for p, t in data])
        flag = "SIGNAL" if m % 7 == 0 else "flat"
        print(f"  m = {m:>3}:  I = {info:.6f} bits   [{flag}]")
    print(f"  theory at 7 | m: 1/3 + log2 3 = {1/3 + l3:.6f};  coprime / 3-adic: 0")

    print()
    print("=" * 72)
    print("PART 3. Abelian obstruction: translations are commutators")
    print("=" * 72)
    print(f"  t_(a-1)c = [s_a, t_c] for all a in {{2..6}}, c in Z/7: {check_commutator(7)}")


if __name__ == "__main__":
    main()
