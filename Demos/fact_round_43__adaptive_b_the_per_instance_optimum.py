#!/usr/bin/env python3
"""
Adaptive smoothness bounds in the quadratic sieve: numerical demonstrations.

Standard library only.  Sections:

  1. Two square roots modulo an odd prime (exhaustive check).
  2. Paid touch of a real quadratic-sieve factor base versus the closed form
     2*M*sum_{odd p} 1/p + M/2, with the guaranteed error bar 2|S| - 1.
  3. Oracle <= best feature rule <= best fixed value, the per-fibre argmin rule,
     and the exact zero-gain criterion, on a synthetic cost table.
  4. The train/test reversal example (a train-optimal rule that loses on test).
  5. "Real but oracle-only": a simulation with a small per-instance prize buried
     in large unexplained noise (signal/noise ~ 0.09).
  6. The elasticity d log Q / d log m = 1 + c/Q and the secant band [1, 1 + c/Q1].
"""
from __future__ import annotations

import math
import random
import statistics
from fractions import Fraction
from typing import Callable, Dict, Hashable, List, Sequence, Tuple

# ---------------------------------------------------------------------------
# Number-theoretic helpers
# ---------------------------------------------------------------------------


def primes_up_to(n: int) -> List[int]:
    """Sieve of Eratosthenes."""
    if n < 2:
        return []
    is_p = bytearray([1]) * (n + 1)
    is_p[0] = is_p[1] = 0
    for i in range(2, int(n ** 0.5) + 1):
        if is_p[i]:
            is_p[i * i :: i] = bytearray(len(is_p[i * i :: i]))
    return [i for i in range(n + 1) if is_p[i]]


def is_probable_prime(n: int) -> bool:
    """Deterministic Miller-Rabin for n < 3.3e24."""
    if n < 2:
        return False
    small = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41]
    for p in small:
        if n % p == 0:
            return n == p
    d, s = n - 1, 0
    while d % 2 == 0:
        d //= 2
        s += 1
    for a in small:
        x = pow(a, d, n)
        if x in (1, n - 1):
            continue
        for _ in range(s - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


def tonelli_shanks(a: int, p: int) -> int:
    """A square root of a quadratic residue a modulo an odd prime p."""
    a %= p
    if p % 4 == 3:
        return pow(a, (p + 1) // 4, p)
    q, s = p - 1, 0
    while q % 2 == 0:
        q //= 2
        s += 1
    z = 2
    while pow(z, (p - 1) // 2, p) != p - 1:
        z += 1
    m, c, t, r = s, pow(z, q, p), pow(a, q, p), pow(a, (q + 1) // 2, p)
    while t != 1:
        i, t2 = 0, t
        while t2 != 1:
            t2 = t2 * t2 % p
            i += 1
        b = pow(c, 1 << (m - i - 1), p)
        m, c, t, r = i, b * b % p, t * b * b % p, r * b % p
    return r


# ---------------------------------------------------------------------------
# 1. Two roots
# ---------------------------------------------------------------------------


def count_sq_roots(a: int, p: int) -> int:
    return sum(1 for x in range(p) if (x * x - a) % p == 0)


def demo_two_roots() -> None:
    print("=" * 72)
    print("1. Two square roots of a nonzero square modulo an odd prime")
    print("=" * 72)
    total, bad = 0, 0
    for p in primes_up_to(400)[1:]:
        squares = {x * x % p for x in range(1, p)}
        for a in squares:
            total += 1
            if count_sq_roots(a, p) != 2:
                bad += 1
    print(f"   checked {total} pairs (p odd prime < 400, a nonzero square): "
          f"{bad} exceptions")
    print(f"   p = 2 is different: x^2 = 1 mod 2 has {count_sq_roots(1, 2)} root\n")


# ---------------------------------------------------------------------------
# 2. Paid touch versus closed form
# ---------------------------------------------------------------------------


def class_touch(M: int, p: int, r: int) -> int:
    """#{x in [0, M) : x = r mod p}, exact formula."""
    return M // p + (1 if r < M % p else 0)


def class_touch_bruteforce(M: int, p: int, r: int) -> int:
    return len(range(r, M, p))


def qs_factor_base(N: int, B: int) -> Dict[int, List[int]]:
    """Factor base of the single-polynomial QS f(x) = (x+s)^2 - N with root
    classes of x, for primes p <= B: 2 (one class) and split odd primes (two)."""
    s = math.isqrt(N)
    if s * s < N:
        s += 1
    fb: Dict[int, List[int]] = {}
    for p in primes_up_to(B):
        if p == 2:
            fb[2] = [(1 - s) % 2]  # (x+s)^2 - N even  iff  x+s odd (N odd)
            continue
        if N % p == 0 or pow(N % p, (p - 1) // 2, p) != 1:
            continue
        x0 = tonelli_shanks(N, p)
        fb[p] = sorted({(x0 - s) % p, (-x0 - s) % p})
    return fb


def paid_touch(M: int, fb: Dict[int, List[int]]) -> int:
    return sum(class_touch(M, p, r) for p, roots in fb.items() for r in roots)


def closed_form(M: int, fb: Dict[int, List[int]]) -> float:
    return 2 * M * sum(1.0 / p for p in fb if p != 2) + M / 2


def random_balanced_semiprime(bits: int, rng: random.Random) -> Tuple[int, int, int]:
    half = bits // 2
    while True:
        p = rng.randrange(1 << (half - 1), 1 << half) | 1
        q = rng.randrange(1 << (bits - half - 1), 1 << (bits - half)) | 1
        if p != q and is_probable_prime(p) and is_probable_prime(q):
            N = p * q
            if N.bit_length() == bits:
                return N, p, q


def demo_paid_touch() -> None:
    print("=" * 72)
    print("2. Paid touch = 2 M sum_{odd p} 1/p + M/2  (error <= 2|S| - 1)")
    print("=" * 72)
    rng = random.Random(43)
    N, p, q = random_balanced_semiprime(41, rng)
    M = 150_000
    print(f"   N = {N} = {p} x {q}  ({N.bit_length()} bits), M = {M}")
    # sanity: exact class-touch formula versus brute force
    assert all(class_touch(M, pp, r) == class_touch_bruteforce(M, pp, r)
               for pp in (2, 3, 101, 9973) for r in range(0, pp, max(1, pp // 7)))
    # sanity: every root class really makes p divide f(x)
    s = math.isqrt(N) + 1
    ladder = [150, 300, 600, 1200, 2400, 4800, 9600, 19000]
    print(f"   {'B':>6} {'|S|':>5} {'paid touch':>11} {'closed form':>13} "
          f"{'|diff|':>8} {'bound':>6} {'rel.dev':>9}")
    worst = 0.0
    for B in ladder:
        fb = qs_factor_base(N, B)
        for pp, roots in fb.items():
            for r in roots:
                assert ((r + s) ** 2 - N) % pp == 0
        pt = paid_touch(M, fb)
        cf = closed_form(M, fb)
        bound = 2 * len(fb) - 1
        diff = abs(pt - cf)
        assert diff <= bound
        worst = max(worst, diff / pt)
        print(f"   {B:>6} {len(fb):>5} {pt:>11} {cf:>13.1f} {diff:>8.1f} "
              f"{bound:>6} {diff / pt:>9.2e}")
    print(f"   worst relative deviation on this instance: {worst:.2e}\n")


# ---------------------------------------------------------------------------
# 3. Oracle / fibre-best / fixed on a cost table
# ---------------------------------------------------------------------------

Cost = Callable[[Hashable, Hashable], float]


def oracle_cost(I: Sequence[Hashable], L: Sequence[Hashable], c: Cost) -> float:
    return sum(min(c(i, b) for b in L) for i in I)


def fixed_cost(I: Sequence[Hashable], c: Cost, b: Hashable) -> float:
    return sum(c(i, b) for i in I)


def fibre_costs(I: Sequence[Hashable], L: Sequence[Hashable], c: Cost,
                phi: Callable[[Hashable], Hashable]) -> Dict[Hashable, Dict[Hashable, float]]:
    out: Dict[Hashable, Dict[Hashable, float]] = {}
    for i in I:
        row = out.setdefault(phi(i), {b: 0.0 for b in L})
        for b in L:
            row[b] += c(i, b)
    return out


def fibre_best(I: Sequence[Hashable], L: Sequence[Hashable], c: Cost,
               phi: Callable[[Hashable], Hashable]) -> Tuple[float, Dict[Hashable, Hashable]]:
    """Return FB(phi) and the per-fibre argmin rule g* that attains it."""
    fc = fibre_costs(I, L, c, phi)
    g = {f: min(L, key=lambda b: row[b]) for f, row in fc.items()}
    return sum(fc[f][g[f]] for f in fc), g


def zero_gain(I: Sequence[Hashable], L: Sequence[Hashable], c: Cost,
              phi: Callable[[Hashable], Hashable], b: Hashable, tol: float = 1e-12) -> bool:
    """Zero-gain criterion: b optimal on every fibre."""
    fc = fibre_costs(I, L, c, phi)
    return all(row[b] <= min(row.values()) + tol for row in fc.values())


def demo_ordering() -> None:
    print("=" * 72)
    print("3. Oracle <= best feature rule <= best fixed value; zero-gain criterion")
    print("=" * 72)
    rng = random.Random(7)
    L = list(range(6))
    I = list(range(40))
    feat = {i: i % 4 for i in I}           # a free feature with 4 fibres
    pref = {f: rng.choice(L) for f in range(4)}  # each fibre prefers some b
    table = {(i, b): (b - pref[feat[i]]) ** 2 * 0.05 + rng.gauss(0, 0.3) + 5
             for i in I for b in L}
    c: Cost = lambda i, b: table[(i, b)]
    phi = lambda i: feat[i]
    Or = oracle_cost(I, L, c)
    FB, g = fibre_best(I, L, c, phi)
    bfix = min(L, key=lambda b: fixed_cost(I, c, b))
    Fb = fixed_cost(I, c, bfix)
    print(f"   oracle {Or:.3f} <= fibre-best {FB:.3f} <= best fixed (b={bfix}) {Fb:.3f}")
    assert Or <= FB + 1e-9 <= Fb + 2e-9
    regrets = {f: row[bfix] - min(row.values())
               for f, row in fibre_costs(I, L, c, phi).items()}
    print(f"   gain F(b) - FB = {Fb - FB:.3f} = sum of fibre regrets "
          f"{sum(regrets.values()):.3f}")
    print(f"   per-fibre argmin rule g* = {g};  zero gain? "
          f"{zero_gain(I, L, c, phi, bfix)}")
    # a feature whose fibres all agree: constant preference
    table2 = {(i, b): (b - 2) ** 2 * 0.05 + 5 + 0.01 * i for i in I for b in L}
    c2: Cost = lambda i, b: table2[(i, b)]
    FB2, _ = fibre_best(I, L, c2, phi)
    print(f"   agreeing fibres: FB = {FB2:.3f}, F(2) = {fixed_cost(I, c2, 2):.3f}, "
          f"zero gain? {zero_gain(I, L, c2, phi, 2)}")
    # refinement: identity feature refines phi, so FB(id) <= FB(phi)
    FBid, _ = fibre_best(I, L, c, lambda i: i)
    print(f"   refinement: FB(identity) = {FBid:.3f} (= oracle {Or:.3f}) <= FB(phi) = {FB:.3f}\n")


# ---------------------------------------------------------------------------
# 4. Train/test reversal
# ---------------------------------------------------------------------------


def demo_reversal() -> None:
    print("=" * 72)
    print("4. A train-optimal feature rule that loses on test")
    print("=" * 72)
    T, F = True, False
    tr = {(T, T): Fraction(9, 10), (T, F): Fraction(1), (F, T): Fraction(6, 5), (F, F): Fraction(1)}
    te = {(T, T): Fraction(3, 2), (T, F): Fraction(1), (F, T): Fraction(1), (F, F): Fraction(1)}
    I = [T, F]
    fixF_tr = sum(tr[(i, F)] for i in I)
    fixT_tr = sum(tr[(i, T)] for i in I)
    rule_tr = sum(tr[(i, i)] for i in I)
    fixF_te = sum(te[(i, F)] for i in I)
    rule_te = sum(te[(i, i)] for i in I)
    print(f"   train: fixed F = {fixF_tr}, fixed T = {fixT_tr}, rule id = {rule_tr}")
    print(f"   test : fixed F = {fixF_te}, rule id = {rule_te}")
    assert fixF_tr < fixT_tr and rule_tr < fixF_tr and fixF_te < rule_te
    print("   -> the rule wins on train and loses on test.\n")


# ---------------------------------------------------------------------------
# 5. Real but oracle-only
# ---------------------------------------------------------------------------


def demo_oracle_only(n: int = 120, seed: int = 2026) -> None:
    print("=" * 72)
    print("5. 'Real but oracle-only': small prize, large unexplained noise")
    print("=" * 72)
    rng = random.Random(seed)
    ladder = [150, 200, 300, 400, 600, 800, 1200, 1600, 2400, 3200, 4800,
              6400, 9600, 14000, 19000]
    logL = [math.log(b) for b in ladder]
    # instance i has a hidden preferred log B (not visible to free features),
    # a common level offset (huge between-instance noise), and a feature that
    # is only weakly informative about the preferred log B.
    inst = []
    for _ in range(n):
        hidden = rng.gauss(math.log(4800), 1.2)
        level = rng.gauss(0.0, 0.5)
        feature = int(hidden + rng.gauss(0, 3.0) > math.log(4800))  # weak
        costs = [level + 0.012 * (lb - hidden) ** 2 + rng.gauss(0, 0.01) for lb in logL]
        inst.append((feature, costs))
    idx = list(range(n))
    rng.shuffle(idx)
    train, test = idx[: n // 2], idx[n // 2 :]

    def fixed(js: List[int], k: int) -> float:
        return sum(inst[j][1][k] for j in js)

    kfix = min(range(len(ladder)), key=lambda k: fixed(train, k))
    rule: Dict[int, int] = {}
    for f in (0, 1):
        js = [j for j in train if inst[j][0] == f] or train
        rule[f] = min(range(len(ladder)), key=lambda k: fixed(js, k))
    d_or = [min(inst[j][1]) - inst[j][1][kfix] for j in test]
    d_rule = [inst[j][1][rule[inst[j][0]]] - inst[j][1][kfix] for j in test]

    def summary(d: List[float]) -> str:
        m, sd = statistics.mean(d), statistics.stdev(d)
        t = m / (sd / math.sqrt(len(d))) if sd > 0 else float("nan")
        return f"{math.exp(m):.4f}x  (t = {t:+.2f})"

    argmins = [ladder[min(range(len(ladder)), key=lambda k: inst[j][1][k])] for j in idx]
    resid = statistics.stdev([inst[j][1][kfix] for j in test])
    prize = -statistics.mean(d_or)
    print(f"   B* ranges over [{min(argmins)}, {max(argmins)}], median "
          f"{statistics.median(argmins)}; best fixed B = {ladder[kfix]}")
    print(f"   held-out oracle         : {summary(d_or)}; worsened "
          f"{sum(x > 1e-12 for x in d_or)}/{len(d_or)}")
    print(f"   held-out stratified rule: {summary(d_rule)}")
    print(f"   prize {prize:.4f} vs residual sd {resid:.3f}: signal/noise "
          f"{prize / resid:.3f}")
    print("   (measured in the study: oracle 0.9590x, stratified 1.0047x,"
          " regression 1.0290x, signal/noise 0.089)\n")


# ---------------------------------------------------------------------------
# 6. Elasticity
# ---------------------------------------------------------------------------


def demo_elasticity() -> None:
    print("=" * 72)
    print("6. d log Q / d log m = 1 + c/Q, secant slopes in [1, 1 + c/Q1]")
    print("=" * 72)
    c = 2.0
    pairs = [(20.0, 40.0), (100.0, 200.0), (500.0, 1000.0), (1000.0, 1100.0)]
    for m1, m2 in pairs:
        Q1, Q2 = m1 - c, m2 - c
        slope = math.log(Q2 / Q1) / math.log(m2 / m1)
        hi = 1 + c / Q1
        assert 1 - 1e-12 <= slope <= hi + 1e-12
        print(f"   m: {m1:>6.0f} -> {m2:>6.0f}   secant slope {slope:.5f} "
              f"in [1, {hi:.5f}]   instantaneous at m1: {m1 / (m1 - c):.5f}")
    # with a real factor base: Q = split odd primes, m = Q + 2 (sign and 2)
    rng = random.Random(43)
    N, _, _ = random_balanced_semiprime(41, rng)
    ladder = [150, 300, 600, 1200, 2400, 4800, 9600, 19000]
    Qs = [len(qs_factor_base(N, B)) - 1 for B in ladder]
    xs = [math.log(q + 2) for q in Qs]
    ys = [math.log(q) for q in Qs]
    mx, my = statistics.mean(xs), statistics.mean(ys)
    slope = sum((x - mx) * (y - my) for x, y in zip(xs, ys)) / sum((x - mx) ** 2 for x in xs)
    print(f"   real instance: Q along ladder = {Qs}")
    print(f"   regression slope of log Q on log m (m = Q + 2): {slope:.5f}")
    pis = [len(primes_up_to(B)) for B in ladder]
    xs2 = [math.log(v) for v in pis]
    mx2 = statistics.mean(xs2)
    slope2 = sum((x - mx2) * (y - my) for x, y in zip(xs2, ys)) / sum((x - mx2) ** 2 for x in xs2)
    print(f"   slope of log Q on log pi(B) (all primes up to B): {slope2:.5f}"
          "  (split fraction fluctuates around 1/2)\n")


if __name__ == "__main__":
    demo_two_roots()
    demo_paid_touch()
    demo_ordering()
    demo_reversal()
    demo_oracle_only()
    demo_elasticity()
