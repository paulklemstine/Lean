#!/usr/bin/env python3
"""
The posterior filter equals the sham: numerical companion.

Every statement checked here is an exact identity in the residue model of trial
division (factor residues a, b uniform in a finite group G, public residue c = a*b),
verified by exhaustive enumeration over all |G|^2 factor pairs, followed by a
Monte-Carlo experiment on genuine semiprimes showing the same behaviour in the wild.

Sections
  1. Flat transport and the flat posterior (barrier 2)
  2. The keep-rate law and real = sham
  3. No-fallback failure rate 1/n
  4. Ordering invariance
  5. Honest cost accounting: the 1x cap and the exact 0.5x law
  6. Sham co-inflation of an unpriced-test bug
  7. N-blind optimality under an arbitrary prior on the target
  8. The unordered event: where the sham law stops
  9. Information: zero bits to the target, full capacity on the pair
 10. Real semiprimes: posterior filter vs coin-flip sham

Pure Python 3 standard library only.  Run:  python3 demo.py
"""
from __future__ import annotations

import math
import random
from collections import Counter, defaultdict
from fractions import Fraction
from typing import Callable, Dict, List, Sequence, Set, Tuple

# ---------------------------------------------------------------------------
# The group (Z/mZ)^x
# ---------------------------------------------------------------------------


def units(m: int) -> List[int]:
    """Residues coprime to m: the elements of the unit group (Z/mZ)^x."""
    return [x for x in range(1, m) if math.gcd(x, m) == 1] if m > 1 else [0]


def inv(x: int, m: int) -> int:
    """Multiplicative inverse of x modulo m."""
    return pow(x, -1, m)


Policy = Dict[int, Set[int]]          # public residue c -> kept classes K(c)
Ranking = Dict[int, Dict[int, int]]   # public residue c -> (class -> rank 0..n-1)


def pairs(G: Sequence[int]) -> List[Tuple[int, int]]:
    return [(a, b) for a in G for b in G]


def hit_count(G: Sequence[int], m: int, K: Policy) -> int:
    """Number of factor pairs (a, b) with a in K(a*b)."""
    return sum(1 for a, b in pairs(G) if a in K[(a * b) % m])


def section(title: str) -> None:
    print("\n" + "=" * 78 + f"\n{title}\n" + "=" * 78)


# ---------------------------------------------------------------------------
# 1. Flat transport and flat posterior
# ---------------------------------------------------------------------------


def demo_flat_posterior(m: int = 15) -> None:
    section(f"1. Flat posterior (barrier 2) in (Z/{m}Z)^x")
    G = units(m)
    n = len(G)
    # A public dial: any function of c.  Use the Legendre-like pair (c mod 3, c mod 5 square?).
    def dial(c: int) -> Tuple[int, bool]:
        return (c % 3, any((x * x - c) % 5 == 0 for x in range(5)))
    table: Dict[Tuple[int, bool], Counter] = defaultdict(Counter)
    for a, b in pairs(G):
        table[dial((a * b) % m)][a] += 1
    for d, cnt in sorted(table.items()):
        fib = sum(1 for c in G if dial(c) == d)
        counts = sorted(set(cnt[r] for r in G))
        print(f"  dial reading {d}: |dial^-1(d)| = {fib}; counts over the {n} target classes = {counts}")
        assert counts == [fib]
    print("  -> every target class has the same posterior weight, whatever the dial shows.")


# ---------------------------------------------------------------------------
# 2. Keep-rate law, real = sham
# ---------------------------------------------------------------------------


def posterior_filter(G: Sequence[int], m: int, k: int, score: Callable[[int, int], float]) -> Policy:
    """'Real' filter: for each public residue keep the k classes with the highest score."""
    return {c: set(sorted(G, key=lambda x: (-score(c, x), x))[:k]) for c in G}


def sham_filter(G: Sequence[int], k: int, rng: random.Random) -> Policy:
    """Sham: for each public residue keep k classes chosen by coin flips."""
    return {c: set(rng.sample(list(G), k)) for c in G}


def demo_keep_rate(m: int = 21, seed: int = 20260821) -> None:
    section(f"2. Keep-rate law: success = sum_c |K(c)|   (G = (Z/{m}Z)^x)")
    rng = random.Random(seed)
    G = units(m)
    n = len(G)
    # a "clever" score: prefer classes x for which the cofactor c/x is small (a fake structure signal)
    clever = lambda c, x: -((c * inv(x, m)) % m)
    for k in range(1, n + 1, max(1, n // 6)):
        Kr = posterior_filter(G, m, k, clever)
        Ks = sham_filter(G, k, rng)
        hr, hs = hit_count(G, m, Kr), hit_count(G, m, Ks)
        print(f"  k={k:2d}: real hits={hr:4d}  sham hits={hs:4d}  n*k={n*k:4d}  "
              f"rate={Fraction(hr, n*n)} = k/n={Fraction(k, n)}")
        assert hr == hs == n * k
    # varying keep sizes
    sizes = {c: rng.randint(0, n) for c in G}
    Kv = {c: set(rng.sample(G, sizes[c])) for c in G}
    print(f"  variable sizes: hits={hit_count(G, m, Kv)}  sum|K(c)|={sum(sizes.values())}")
    assert hit_count(G, m, Kv) == sum(sizes.values())


# ---------------------------------------------------------------------------
# 3. No-fallback failures
# ---------------------------------------------------------------------------


def demo_no_fallback(m: int = 35, seed: int = 1) -> None:
    section(f"3. Dropping one class per public residue fails with probability exactly 1/n")
    rng = random.Random(seed)
    G = units(m)
    n = len(G)
    K = {c: set(G) - {rng.choice(G)} for c in G}
    fails = sum(1 for a, b in pairs(G) if a not in K[(a * b) % m])
    print(f"  n = {n}: failures = {fails} of {n*n}  -> rate {Fraction(fails, n*n)} = 1/{n}")
    assert fails == n


# ---------------------------------------------------------------------------
# 4. Ordering invariance
# ---------------------------------------------------------------------------


def demo_ordering(m: int = 33, seed: int = 7) -> None:
    section("4. Ordering invariance: expected rank is (n-1)/2 for EVERY ordering policy")
    rng = random.Random(seed)
    G = units(m)
    n = len(G)
    policies: Dict[str, Ranking] = {}
    policies["plain scan (ascending)"] = {c: {x: i for i, x in enumerate(sorted(G))} for c in G}
    policies["'posterior' (cofactor small first)"] = {
        c: {x: i for i, x in enumerate(sorted(G, key=lambda x: (c * inv(x, m)) % m))} for c in G}
    def shuffled() -> Dict[int, int]:
        L = list(G); rng.shuffle(L); return {x: i for i, x in enumerate(L)}
    policies["random per public residue"] = {c: shuffled() for c in G}
    for name, r in policies.items():
        tot = sum(r[(a * b) % m][a] for a, b in pairs(G))
        print(f"  {name:38s}: mean rank = {Fraction(tot, n*n)}  ((n-1)/2 = {Fraction(n-1, 2)})")
        assert 2 * tot == n * n * (n - 1)


# ---------------------------------------------------------------------------
# 5. Honest accounting
# ---------------------------------------------------------------------------


def costs(G: Sequence[int], m: int, r: Ranking, K: Policy) -> Tuple[int, int]:
    """(total baseline cost, total honest filter cost) over all factor pairs."""
    base = filt = 0
    for a, b in pairs(G):
        c = (a * b) % m
        examined = [x for x in G if r[c][x] <= r[c][a]]
        base += len(examined)
        filt += sum(1 + (1 if x in K[c] else 0) for x in examined)
    return base, filt


def demo_costs(m: int = 26, seed: int = 3) -> None:
    section("5. Honest accounting: membership test = one division")
    rng = random.Random(seed)
    G = units(m)
    n = len(G)
    r = {c: {x: i for i, x in enumerate(sorted(G))} for c in G}
    for k in [0, n // 4, n // 2, 3 * n // 4, n]:
        K = sham_filter(G, k, rng)
        base, filt = costs(G, m, r, K)
        print(f"  keep {k:2d}/{n}: baseline={base:5d}  filter={filt:5d}  speedup={base/filt:.3f}x")
        assert filt >= base
    full = {c: set(G) for c in G}
    base, filt = costs(G, m, r, full)
    print(f"  full keep: filter / baseline = {Fraction(filt, base)}  (exactly the 0.5x law)")
    assert filt == 2 * base and 2 * base == n * n * (n + 1)


# ---------------------------------------------------------------------------
# 6. Sham co-inflation
# ---------------------------------------------------------------------------


def demo_coinflation(m: int = 39, seed: int = 11) -> None:
    section("6. Sham co-inflation: an unpriced-test bug inflates real and sham identically")
    rng = random.Random(seed)
    G = units(m)
    n = len(G)
    k = n // 3
    clever = lambda c, x: -((c * inv(x, m)) % m)
    Kr = posterior_filter(G, m, k, clever)
    Ks = sham_filter(G, k, rng)
    r = {c: {x: i for i, x in enumerate(sorted(G))} for c in G}
    def buggy(K: Policy) -> Tuple[int, int]:
        tot = succ = 0
        for a, b in pairs(G):
            c = (a * b) % m
            if a in K[c]:
                succ += 1
                tot += sum(1 for x in K[c] if r[c][x] <= r[c][a])
        return tot, succ
    (tr, sr), (ts, ss) = buggy(Kr), buggy(Ks)
    print(f"  real : buggy total cost on successes = {tr}  (successes {sr})")
    print(f"  sham : buggy total cost on successes = {ts}  (successes {ss})")
    print(f"  formula sum_c |K|(|K|+1)/2 = {n * k * (k + 1) // 2}")
    # plain scan costs (n+1)/2 on average; the bug reports (n+1)/2 divided by mean buggy cost per success
    rep_r = Fraction(n + 1, 2) / Fraction(tr, sr)
    rep_s = Fraction(n + 1, 2) / Fraction(ts, ss)
    print(f"  the bug reports {float(rep_r):.2f}x (real) and {float(rep_s):.2f}x (sham) = (n+1)/(k+1)"
          " -> the speedup is an artefact")
    assert rep_r == rep_s == Fraction(n + 1, k + 1)
    assert tr == ts == n * k * (k + 1) // 2


# ---------------------------------------------------------------------------
# 7. N-blind optimality
# ---------------------------------------------------------------------------


def hit_weight(G: Sequence[int], m: int, mu: Dict[int, float], K: Policy) -> float:
    return sum(mu[a] for a, b in pairs(G) if a in K[(a * b) % m])


def demo_nblind(m: int = 20, seed: int = 5) -> None:
    section("7. Arbitrary prior on the target: the best filter ignores N")
    rng = random.Random(seed)
    G = units(m)
    n = len(G)
    w = [rng.random() ** 3 for _ in G]
    mu = {x: wi / sum(w) for x, wi in zip(G, w)}
    k = 3
    K = sham_filter(G, k, rng)
    best_c = max(G, key=lambda c: sum(mu[a] for a in K[c]))
    blind = {c: K[best_c] for c in G}
    top = set(sorted(G, key=lambda x: -mu[x])[:k])
    print(f"  N-reading policy weight     = {hit_weight(G, m, mu, K):.4f}")
    print(f"  blind copy of its best set  = {hit_weight(G, m, mu, blind):.4f}")
    print(f"  blind top-{k} prior classes   = {hit_weight(G, m, mu, {c: top for c in G}):.4f}")
    assert hit_weight(G, m, mu, blind) >= hit_weight(G, m, mu, K) - 1e-12


# ---------------------------------------------------------------------------
# 8. Unordered boundary
# ---------------------------------------------------------------------------


def demo_unordered() -> None:
    section("8. Scoring 'either factor kept' breaks the sham law (cyclic group of order 3)")
    # Multiplicative copy of Z/3: (Z/7Z)^x subgroup {1,2,4} of order 3 under mult mod 7
    C3 = [1, 2, 4]
    m = 7
    K1 = {c: {1} for c in C3}
    K2 = {c: {(c * c) % m} for c in C3}
    def ordered(K: Policy) -> int:
        return sum(1 for a in C3 for b in C3 if a in K[(a * b) % m])
    def unordered(K: Policy) -> int:
        return sum(1 for a in C3 for b in C3 if a in K[(a*b) % m] or b in K[(a*b) % m])
    print(f"  K1(c) = {{1}}   : ordered = {ordered(K1)}, unordered = {unordered(K1)}")
    print(f"  K2(c) = {{c^2}} : ordered = {ordered(K2)}, unordered = {unordered(K2)}")
    assert ordered(K1) == ordered(K2) == 3 and unordered(K1) == 5 and unordered(K2) == 3


# ---------------------------------------------------------------------------
# 9. Information
# ---------------------------------------------------------------------------


def mutual_info(samples: List[Tuple[object, object]]) -> float:
    """I(X;Y) in bits for the uniform distribution on a list of (x, y) samples."""
    N = len(samples)
    px, py, pxy = Counter(), Counter(), Counter()
    for x, y in samples:
        px[x] += 1; py[y] += 1; pxy[(x, y)] += 1
    return sum(v / N * math.log2(v * N / (px[x] * py[y])) for (x, y), v in pxy.items())


def demo_information(m: int = 105) -> None:
    section(f"9. Information: capacity is real but orthogonal to the target  (Z/{m}Z)^x")
    G = units(m)
    P = pairs(G)
    dials: Dict[str, Callable[[int], object]] = {
        "c mod 3 (1 bit)": lambda c: c % 3,
        "(c mod 3, c mod 5)": lambda c: (c % 3, c % 5),
        "c itself": lambda c: c,
    }
    for name, f in dials.items():
        to_pair = mutual_info([((a, b), f((a * b) % m)) for a, b in P])
        to_target = mutual_info([(a, f((a * b) % m)) for a, b in P])
        print(f"  dial {name:22s}: I(pair; dial) = {to_pair:.4f} bits,  I(target; dial) = {to_target:.2e}")
        assert abs(to_target) < 1e-9
    print(f"  log2 |G| = {math.log2(len(G)):.4f}")
    leak = mutual_info([(a, a % 3) for a, b in P])
    print(f"  a 'dummy' dial reading a table through the factor (a mod 3) leaks {leak:.4f} bits -> NOT public")


# ---------------------------------------------------------------------------
# 10. Real semiprimes
# ---------------------------------------------------------------------------


def primes_between(lo: int, hi: int) -> List[int]:
    sieve = bytearray([1]) * (hi + 1)
    sieve[0:2] = b"\x00\x00"
    for i in range(2, int(hi ** 0.5) + 1):
        if sieve[i]:
            sieve[i * i::i] = bytearray(len(sieve[i * i::i]))
    return [p for p in range(lo, hi + 1) if sieve[p]]


def demo_semiprimes(m: int = 35, samples: int = 20000, batches: int = 5, seed: int = 20260821) -> None:
    section(f"10. Real semiprimes: Bayesian posterior filter vs coin-flip sham (modulus {m})")
    rng = random.Random(seed)
    P = [p for p in primes_between(1000, 60000) if math.gcd(p, m) == 1]
    G = units(m)
    n = len(G)
    # training set: empirical posterior of (smaller factor mod m) given (N mod m)
    post: Dict[int, Counter] = defaultdict(Counter)
    for _ in range(100000):
        p, q = rng.sample(P, 2)
        p, q = min(p, q), max(p, q)
        post[(p * q) % m][p % m] += 1
    print(f"  {'keep k':>6} {'real':>8} {'sham':>8} {'|diff|':>8} {'k/n':>8}")
    worst = 0.0
    for k in [n // 6, n // 3, n // 2, 2 * n // 3, 5 * n // 6]:
        real_rates, sham_rates = [], []
        for _ in range(batches):
            hr = hs = 0
            for _ in range(samples):
                p, q = rng.sample(P, 2)
                p, q = min(p, q), max(p, q)
                c = (p * q) % m
                ranked = sorted(G, key=lambda x: (-post[c][x], x))
                hr += (p % m) in ranked[:k]
                hs += (p % m) in rng.sample(G, k)
            real_rates.append(hr / samples); sham_rates.append(hs / samples)
        r, s = sum(real_rates) / batches, sum(sham_rates) / batches
        worst = max(worst, abs(r - s))
        print(f"  {k:6d} {r:8.4f} {s:8.4f} {abs(r-s):8.4f} {k/n:8.4f}")
    print(f"  max |real - sham| = {worst:.4f}; the posterior-ranked filter hits at the keep rate.")


def main() -> None:
    demo_flat_posterior()
    demo_keep_rate()
    demo_no_fallback()
    demo_ordering()
    demo_costs()
    demo_coinflation()
    demo_nblind()
    demo_unordered()
    demo_information()
    demo_semiprimes()
    print("\nAll exact identities verified by exhaustive enumeration.")


if __name__ == "__main__":
    main()
