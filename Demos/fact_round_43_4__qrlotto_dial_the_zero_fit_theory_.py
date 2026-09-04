"""
The quadratic-residue lottery: numerical demonstration of the zero-fit dial.

This self-contained script verifies, by direct computation, every quantitative
claim of the accompanying paper:

  1. Root-count identity:      #{x mod p : x^2 = N} = legendre(N, p) + 1.
  2. Lottery law (sufficiency): the measured hit fraction is exactly 2/p when N
     is a residue mod p and exactly 0 otherwise.
  3. Zero-fit theorem:          T(N) = sum over residue primes of 2/p equals the
     exact expected footprint sum_p #roots(p, N)/p.
  4. Fairness:                  exactly (p-1)/2 of the p classes are winners.
  5. Exact independence:        every one of the 2^k bit patterns occurs with the
     same multiplicity |Omega| / 2^k.
  6. Moments:                   E[T] = sum 1/q, Var[T] = sum 1/q^2.
  7. Optimality:                risk(w) = (sum d_i/2)^2 + sum d_i^2/4 per sample
     point, with d_i = 2/q_i - w_i; unique zero at the theory weights.
  8. Truncation cost:           dropping primes costs (sum_tail 1/q)^2 + sum_tail 1/q^2.
  9. Concentration:             empirical deviating fractions versus the Chebyshev
     bound 1/(2t^2) and the sub-Gaussian bound 2 exp(-t^2/(2V)).
 10. Position-side duality:     the mean number of factor-base hits per sieve
     position equals T(N), with variance sum p_i (1 - p_i).

Run:  python3 demo.py
No third-party dependencies.
"""

from __future__ import annotations

import itertools
import math
import random
from typing import Dict, Iterable, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# Elementary number theory
# ----------------------------------------------------------------------------


def primes_up_to(bound: int) -> List[int]:
    """All primes <= bound by the sieve of Eratosthenes."""
    if bound < 2:
        return []
    flags = bytearray([1]) * (bound + 1)
    flags[0] = flags[1] = 0
    for m in range(2, int(bound**0.5) + 1):
        if flags[m]:
            flags[m * m :: m] = bytearray(len(flags[m * m :: m]))
    return [m for m in range(bound + 1) if flags[m]]


def legendre_symbol(a: int, p: int) -> int:
    """Legendre symbol (a|p) for an odd prime p, via Euler's criterion."""
    a %= p
    if a == 0:
        return 0
    t = pow(a, (p - 1) // 2, p)
    return 1 if t == 1 else -1


def root_count(p: int, n: int) -> int:
    """Number of x in [0, p) with x^2 = n (mod p), computed by brute force."""
    n %= p
    return sum(1 for x in range(p) if (x * x - n) % p == 0)


def root_set(p: int, n: int) -> List[int]:
    """The residues x in [0, p) with x^2 = n (mod p)."""
    n %= p
    return [x for x in range(p) if (x * x - n) % p == 0]


# ----------------------------------------------------------------------------
# The dial
# ----------------------------------------------------------------------------


def qr_bit(p: int, n: int) -> int:
    """The quadratic-residue indicator bit of n at p (1 if n is a nonzero square)."""
    return 1 if legendre_symbol(n, p) == 1 else 0


def theory_dial(base: Sequence[int], n: int) -> float:
    """T(n) = sum of 2/p over the primes p in the factor base with n a QR mod p."""
    return sum(2.0 / p for p in base if qr_bit(p, n) == 1)


def total_dial(base: Sequence[int], n: int) -> float:
    """The total dial: ramified primes (p | n) carry the half weight 1/p."""
    total = 0.0
    for p in base:
        if n % p == 0:
            total += 1.0 / p
        elif qr_bit(p, n) == 1:
            total += 2.0 / p
    return total


def footprint(base: Sequence[int], n: int) -> float:
    """The exact expected footprint sum_p #roots(p, n)/p, by brute-force counting."""
    return sum(root_count(p, n) / p for p in base)


def mertens_weight(base: Sequence[int]) -> float:
    """The Mertens main term sum_p 1/p."""
    return sum(1.0 / p for p in base)


def variance_proxy(base: Sequence[int]) -> float:
    """The exact variance of the dial, sum_p 1/p^2."""
    return sum(1.0 / (p * p) for p in base)


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------


def banner(title: str) -> None:
    print()
    print("=" * 76)
    print(title)
    print("=" * 76)


def demo_root_count_identity(max_prime: int = 60, n_range: int = 40) -> None:
    banner("1. Root-count identity:  #roots(p, N) = legendre(N, p) + 1")
    odd_primes = [p for p in primes_up_to(max_prime) if p != 2]
    checked = 0
    for p in odd_primes:
        for n in range(-n_range, n_range + 1):
            assert root_count(p, n) == legendre_symbol(n, p) + 1, (p, n)
            checked += 1
    print(f"verified for {len(odd_primes)} odd primes x {2*n_range+1} targets "
          f"= {checked} instances -- no exceptions")
    print("sample rows (p, N, #roots, legendre):")
    for p, n in [(7, 2), (7, 3), (11, 5), (13, 0), (17, 4), (23, 22)]:
        print(f"   p={p:3d}  N={n:3d}   #roots={root_count(p,n)}   "
              f"legendre={legendre_symbol(n,p):+d}   roots={root_set(p,n)}")


def demo_lottery_law(base: Sequence[int], n: int) -> None:
    banner("2. Lottery law: the measured hit fraction is 2/p or exactly 0")
    print(f"target N = {n}")
    print(f"{'p':>5} {'bit':>4} {'#roots':>7} {'measured r/p':>14} {'2/p if bit':>12}")
    for p in base[:12]:
        bit = qr_bit(p, n)
        measured = root_count(p, n) / p
        predicted = (2.0 / p) if bit else 0.0
        assert abs(measured - predicted) < 1e-15
        print(f"{p:>5} {bit:>4} {root_count(p,n):>7} {measured:>14.8f} {predicted:>12.8f}")
    print("the measured fraction is a deterministic function of the single bit:")
    print("the bit is a sufficient statistic, so no fitted per-prime number can help.")


def demo_zero_fit(base: Sequence[int], targets: Iterable[int]) -> None:
    banner("3. Zero-fit theorem:  T(N) = footprint(N) exactly")
    print(f"{'N':>12} {'T(N)':>14} {'footprint':>14} {'difference':>14}")
    for n in targets:
        t = total_dial(base, n)
        f = footprint(base, n)
        print(f"{n:>12} {t:>14.9f} {f:>14.9f} {abs(t-f):>14.2e}")
        assert abs(t - f) < 1e-12


def demo_fairness(max_prime: int = 60) -> None:
    banner("4. Fairness of the lottery: 2W + 1 = p")
    print(f"{'p':>5} {'winners W':>10} {'losers':>8} {'2W+1':>6} {'W/(p-1)':>9}")
    for p in [q for q in primes_up_to(max_prime) if q != 2]:
        winners = sum(1 for n in range(p) if root_count(p, n) == 2)
        losers = sum(1 for n in range(p) if root_count(p, n) == 0)
        assert 2 * winners + 1 == p and winners == losers
        print(f"{p:>5} {winners:>10} {losers:>8} {2*winners+1:>6} "
              f"{winners/(p-1):>9.4f}")


def sample_space(base: Sequence[int]) -> List[Tuple[int, ...]]:
    """All residue vectors with every coordinate invertible (the CRT sample space)."""
    return list(itertools.product(*[range(1, p) for p in base]))


def bit_pattern(base: Sequence[int], x: Sequence[int]) -> Tuple[int, ...]:
    return tuple(qr_bit(p, xi) for p, xi in zip(base, x))


def dial_of(base: Sequence[int], x: Sequence[int]) -> float:
    return sum(2.0 / p for p, xi in zip(base, x) if qr_bit(p, xi) == 1)


def demo_independence(base: Sequence[int]) -> None:
    banner("5. Exact independence: every bit pattern occurs equally often")
    omega = sample_space(base)
    counts: Dict[Tuple[int, ...], int] = {}
    for x in omega:
        counts[bit_pattern(base, x)] = counts.get(bit_pattern(base, x), 0) + 1
    expected = len(omega) // (2 ** len(base))
    print(f"factor base {list(base)},  |Omega| = {len(omega)},  "
          f"patterns = {2**len(base)},  predicted count per pattern = {expected}")
    for pattern, c in sorted(counts.items()):
        assert c == expected
        print(f"   pattern {''.join(map(str, pattern))} : {c}")
    print("all counts equal -- the bits are exactly independent fair coins.")


def demo_moments(base: Sequence[int]) -> None:
    banner("6. Moments: E[T] = sum 1/q,  Var[T] = sum 1/q^2")
    omega = sample_space(base)
    values = [dial_of(base, x) for x in omega]
    emp_mean = sum(values) / len(values)
    emp_var = sum((v - emp_mean) ** 2 for v in values) / len(values)
    print(f"factor base {list(base)}")
    print(f"   empirical mean     = {emp_mean:.12f}")
    print(f"   predicted  sum 1/q = {mertens_weight(base):.12f}")
    print(f"   empirical variance = {emp_var:.12f}")
    print(f"   predicted sum 1/q^2= {variance_proxy(base):.12f}")
    assert abs(emp_mean - mertens_weight(base)) < 1e-12
    assert abs(emp_var - variance_proxy(base)) < 1e-12


def risk_exact(base: Sequence[int], weights: Sequence[float]) -> float:
    """Per-sample-point risk from the closed formula (sum d/2)^2 + sum d^2/4."""
    deltas = [2.0 / p - w for p, w in zip(base, weights)]
    return (sum(d / 2 for d in deltas)) ** 2 + sum(d * d / 4 for d in deltas)


def risk_empirical(base: Sequence[int], weights: Sequence[float]) -> float:
    """Per-sample-point risk by brute-force averaging over the sample space."""
    omega = sample_space(base)
    total = 0.0
    for x in omega:
        bits = bit_pattern(base, x)
        pred = sum(w * b for w, b in zip(weights, bits))
        true = sum((2.0 / p) * b for p, b in zip(base, bits))
        total += (true - pred) ** 2
    return total / len(omega)


def demo_optimality(base: Sequence[int], seed: int = 20260926) -> None:
    banner("7. Optimality: the theory weights are the unique risk minimiser")
    rng = random.Random(seed)
    theory = [2.0 / p for p in base]
    candidates: List[Tuple[str, List[float]]] = [
        ("theory weights 2/p", theory),
        ("all weights 1/p (halved)", [1.0 / p for p in base]),
        ("uniform weight 0.05", [0.05] * len(base)),
        ("theory + tiny noise", [w + rng.uniform(-0.01, 0.01) for w in theory]),
        ("first prime perturbed", [theory[0] + 0.001] + theory[1:]),
        ("all zero", [0.0] * len(base)),
    ]
    print(f"{'candidate weight vector':>28} {'closed form':>14} {'brute force':>14}")
    for name, w in candidates:
        a, b = risk_exact(base, w), risk_empirical(base, w)
        assert abs(a - b) < 1e-12, (name, a, b)
        print(f"{name:>28} {a:>14.10f} {b:>14.10f}")
    print("only the theory weights achieve risk 0; every perturbation is strictly worse.")


def demo_truncation(base: Sequence[int]) -> None:
    banner("8. Truncation is strictly costly")
    print(f"{'kept primes':>28} {'dropped':>16} {'risk':>14}")
    for keep in range(len(base), 0, -1):
        kept = list(base[:keep])
        dropped = list(base[keep:])
        weights = [2.0 / p if p in kept else 0.0 for p in base]
        r = risk_exact(base, weights)
        pred = (sum(1.0 / p for p in dropped)) ** 2 + sum(1.0 / (p * p) for p in dropped)
        assert abs(r - pred) < 1e-14
        print(f"{str(kept):>28} {str(dropped):>16} {r:>14.10f}")
    print("dropping even the largest prime costs a strictly positive amount:")
    print("full support dominates every truncation.")


def demo_concentration(base: Sequence[int]) -> None:
    banner("9. Concentration: empirical tails versus Chebyshev and sub-Gaussian bounds")
    omega = sample_space(base)
    mean = mertens_weight(base)
    var = variance_proxy(base)
    values = [dial_of(base, x) for x in omega]
    print(f"factor base {list(base)}")
    print(f"mean = {mean:.6f}   variance V = {var:.6f}   (bound V < 1/2: "
          f"{'ok' if var < 0.5 else 'FAIL'})")
    print(f"{'t':>6} {'empirical frac':>16} {'Chebyshev V/t^2':>18} "
          f"{'sub-Gaussian':>16} {'uniform 2e^-t^2':>18}")
    for t in [0.05, 0.1, 0.2, 0.3, 0.5]:
        frac = sum(1 for v in values if abs(v - mean) >= t) / len(values)
        cheb = min(1.0, var / (t * t))
        subg = min(1.0, 2 * math.exp(-(t * t) / (2 * var)))
        unif = min(1.0, 2 * math.exp(-(t * t)))
        assert frac <= cheb + 1e-12 and frac <= subg + 1e-12
        print(f"{t:>6.2f} {frac:>16.6f} {cheb:>18.6f} {subg:>16.6f} {unif:>18.6f}")


def demo_variance_bound() -> None:
    banner("9b. The variance is bounded uniformly in the factor base")
    print(f"{'bound B':>10} {'#odd primes':>12} {'mean sum 1/p':>14} "
          f"{'variance sum 1/p^2':>20}")
    for bound in [50, 100, 200, 400, 2000, 20000, 200000]:
        base = [p for p in primes_up_to(bound) if p != 2]
        print(f"{bound:>10} {len(base):>12} {mertens_weight(base):>14.6f} "
              f"{variance_proxy(base):>20.9f}")
    print("the mean diverges (like log log B) while the variance stays below 1/2.")


def demo_positions(base: Sequence[int], n: int) -> None:
    banner("10. Position side: mean hits per sieve position equals the dial")
    modulus = 1
    for p in base:
        modulus *= p
    hits = []
    for x in range(modulus):
        hits.append(sum(1 for p in base if (x * x - n) % p == 0))
    emp_mean = sum(hits) / modulus
    emp_var = sum((h - emp_mean) ** 2 for h in hits) / modulus
    pred_mean = total_dial(base, n)
    pred_var = sum((root_count(p, n) / p) * (1 - root_count(p, n) / p) for p in base)
    print(f"factor base {list(base)}, target N = {n}, period = {modulus} positions")
    print(f"   empirical mean hits/position = {emp_mean:.12f}")
    print(f"   dial T(N)                    = {pred_mean:.12f}")
    print(f"   empirical variance           = {emp_var:.12f}")
    print(f"   predicted sum p_i(1 - p_i)   = {pred_var:.12f}")
    assert abs(emp_mean - pred_mean) < 1e-12
    assert abs(emp_var - pred_var) < 1e-12


def demo_dial_spectrum(base: Sequence[int]) -> None:
    banner("11. Steerability: the dial realises its whole 2^k-point spectrum")
    values = sorted({round(dial_of(base, x), 12) for x in sample_space(base)})
    print(f"factor base {list(base)}")
    print(f"   number of distinct dial values = {len(values)} "
          f"(2^k = {2**len(base)})")
    print(f"   minimum = {values[0]:.6f}   maximum = {values[-1]:.6f} "
          f"(= sum 2/q = {sum(2.0/p for p in base):.6f})")
    print("   spectrum:", ", ".join(f"{v:.4f}" for v in values))


def demo_ranking(bound: int = 400, count: int = 12, seed: int = 20260926) -> None:
    banner("12. Practical use: ranking targets by the zero-fit dial (p <= 400)")
    base = [p for p in primes_up_to(bound) if p != 2]
    rng = random.Random(seed)
    targets = [rng.randrange(10**14, 10**15) | 1 for _ in range(count)]
    rows = [(n, total_dial(base, n)) for n in targets]
    rows.sort(key=lambda r: -r[1])
    mean = mertens_weight(base)
    sd = math.sqrt(variance_proxy(base))
    print(f"|base| = {len(base)} odd primes,  mean = {mean:.6f},  sd = {sd:.6f}")
    print(f"{'rank':>5} {'N':>18} {'T(N)':>12} {'(T-mean)/sd':>14}")
    for i, (n, t) in enumerate(rows, start=1):
        print(f"{i:>5} {n:>18} {t:>12.6f} {(t-mean)/sd:>14.4f}")
    print("higher dial = more factor-base primes hit = a more hospitable target.")
    print("cost of the whole ranking: a few hundred Legendre symbols per target.")


def main() -> None:
    small_base = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41]

    demo_root_count_identity()
    demo_lottery_law(small_base, n=1234567)
    demo_zero_fit(small_base, [101, 1234567, 2**31 - 1, 3 * 5 * 7 * 1009, 10**12 + 39])
    demo_fairness()
    demo_independence([3, 5, 7])
    demo_moments([3, 5, 7, 11])
    demo_optimality([3, 5, 7, 11])
    demo_truncation([3, 5, 7, 11, 13])
    demo_concentration([3, 5, 7, 11, 13])
    demo_variance_bound()
    demo_positions([3, 5, 7], n=1234567)
    demo_dial_spectrum([3, 5, 7, 11])
    demo_ranking()

    banner("All assertions passed.")


if __name__ == "__main__":
    main()


"""Algorithm 1 — Legendre-symbol evaluation of the zero-fit dial T(N)."""

from __future__ import annotations

from typing import Dict, List, Sequence, Tuple


def primes_up_to(bound: int) -> List[int]:
    """Sieve of Eratosthenes: all primes <= bound in O(B log log B)."""
    if bound < 2:
        return []
    flags = bytearray([1]) * (bound + 1)
    flags[0] = flags[1] = 0
    for m in range(2, int(bound**0.5) + 1):
        if flags[m]:
            flags[m * m :: m] = bytearray(len(flags[m * m :: m]))
    return [m for m in range(bound + 1) if flags[m]]


def jacobi_symbol(a: int, n: int) -> int:
    """Jacobi symbol (a|n) for odd n > 0, by binary quadratic reciprocity.

    For prime n this is the Legendre symbol. Runs in O(log^2 n) bit operations.
    """
    if n <= 0 or n % 2 == 0:
        raise ValueError("n must be a positive odd integer")
    a %= n
    result = 1
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a %= n
    return result if n == 1 else 0


def theory_dial(n: int, base: Sequence[int]) -> float:
    """T(N) = sum of 2/p over factor-base primes p with N a quadratic residue."""
    total = 0.0
    for p in base:
        if jacobi_symbol(n, p) == 1:
            total += 2.0 / p
    return total


def total_dial(n: int, base: Sequence[int]) -> float:
    """The total dial: ramified primes p | N carry the half weight 1/p."""
    total = 0.0
    for p in base:
        s = jacobi_symbol(n, p)
        if s == 0:
            total += 1.0 / p
        elif s == 1:
            total += 2.0 / p
    return total


def dial_report(n: int, bound: int = 400) -> Dict[str, object]:
    """Full diagnostic report for a target: dial, mean, variance, z-score."""
    base = [p for p in primes_up_to(bound) if p != 2]
    mean = sum(1.0 / p for p in base)
    var = sum(1.0 / (p * p) for p in base)
    value = total_dial(n, base)
    bits: List[Tuple[int, int]] = [(p, 1 if jacobi_symbol(n, p) == 1 else 0) for p in base]
    return {
        "target": n,
        "bound": bound,
        "num_primes": len(base),
        "dial": value,
        "mertens_mean": mean,
        "variance": var,
        "z_score": (value - mean) / (var**0.5),
        "num_winning_primes": sum(b for _, b in bits),
        "bits": bits,
    }


if __name__ == "__main__":
    rep = dial_report(1234567891011)
    for key in ("target", "num_primes", "dial", "mertens_mean", "variance",
                "z_score", "num_winning_primes"):
        print(f"{key:>20}: {rep[key]}")


"""Algorithm 2 — Closed-form risk audit of an arbitrary fitted weight vector."""

from __future__ import annotations

from typing import Dict, List, Sequence


def theory_weights(base: Sequence[int]) -> List[float]:
    """The first-principles weights 2/p, forced by the root-count identity."""
    return [2.0 / p for p in base]


def risk_per_point(base: Sequence[int], weights: Sequence[float]) -> float:
    """Exact mean squared error of a linear read-out, per sample point.

    risk(w) = (sum_i d_i / 2)^2 + sum_i d_i^2 / 4,   d_i = 2/q_i - w_i.

    Runs in O(k). Zero if and only if w_i = 2/q_i for every i.
    """
    if len(base) != len(weights):
        raise ValueError("weight vector must have one entry per factor-base prime")
    deltas = [2.0 / p - w for p, w in zip(base, weights)]
    mean_term = sum(d / 2.0 for d in deltas) ** 2
    var_term = sum(d * d / 4.0 for d in deltas)
    return mean_term + var_term


def truncation_risk(base: Sequence[int], kept: Sequence[int]) -> float:
    """Exact risk of dropping every prime outside `kept`.

    Equals (sum_tail 1/q)^2 + sum_tail 1/q^2, strictly positive unless
    nothing is dropped.
    """
    keep = set(kept)
    tail = [p for p in base if p not in keep]
    return (sum(1.0 / p for p in tail)) ** 2 + sum(1.0 / (p * p) for p in tail)


def audit(base: Sequence[int], weights: Sequence[float]) -> Dict[str, float]:
    """Decompose the excess risk of a candidate weight vector."""
    deltas = [2.0 / p - w for p, w in zip(base, weights)]
    return {
        "risk": risk_per_point(base, weights),
        "mean_term": sum(d / 2.0 for d in deltas) ** 2,
        "variance_term": sum(d * d / 4.0 for d in deltas),
        "max_abs_deviation": max((abs(d) for d in deltas), default=0.0),
        "is_theory_optimal": all(abs(d) < 1e-15 for d in deltas),
    }


if __name__ == "__main__":
    base = [3, 5, 7, 11, 13, 17, 19, 23]
    print("theory    :", audit(base, theory_weights(base)))
    print("halved    :", audit(base, [1.0 / p for p in base]))
    print("truncated :", truncation_risk(base, base[:4]))


"""Algorithm 3 — Constructing a target with a prescribed pattern of lottery wins."""

from __future__ import annotations

from typing import List, Sequence, Tuple


def legendre_symbol(a: int, p: int) -> int:
    """Legendre symbol (a|p) for an odd prime p, by Euler's criterion."""
    a %= p
    if a == 0:
        return 0
    return 1 if pow(a, (p - 1) // 2, p) == 1 else -1


def representative_with_bit(p: int, bit: int) -> int:
    """Smallest positive residue mod p with the prescribed quadratic character.

    Exactly (p-1)/2 of the p-1 invertible classes have each character, so a
    linear scan terminates after O(1) trials in expectation.
    """
    want = 1 if bit else -1
    for a in range(1, p):
        if legendre_symbol(a, p) == want:
            return a
    raise ValueError(f"no residue with bit {bit} modulo {p}")


def crt_combine(residues: Sequence[Tuple[int, int]]) -> int:
    """Chinese remainder theorem for pairwise coprime moduli.

    Input pairs (a_i, m_i); output the unique x in [0, prod m_i) with
    x = a_i (mod m_i). Runs in O(k log^2 M).
    """
    x, modulus = 0, 1
    for a, m in residues:
        # solve x + modulus * t = a (mod m)
        inv = pow(modulus % m, -1, m)
        t = ((a - x) % m) * inv % m
        x += modulus * t
        modulus *= m
    return x % modulus


def steer_target(base: Sequence[int], pattern: Sequence[int]) -> int:
    """Return a positive integer N whose lottery bits over `base` are `pattern`.

    Guaranteed to exist for distinct odd primes: every one of the 2^k patterns
    is realised by exactly |Omega| / 2^k residue vectors.
    """
    if len(base) != len(pattern):
        raise ValueError("pattern must have one bit per factor-base prime")
    residues = [(representative_with_bit(p, b), p) for p, b in zip(base, pattern)]
    n = crt_combine(residues)
    modulus = 1
    for p in base:
        modulus *= p
    return n if n > 0 else modulus


def maximise_dial(base: Sequence[int]) -> int:
    """A target hitting every factor-base prime: the dial attains sum 2/q."""
    return steer_target(base, [1] * len(base))


def minimise_dial(base: Sequence[int]) -> int:
    """A target hitting no factor-base prime at all: the dial is 0."""
    return steer_target(base, [0] * len(base))


if __name__ == "__main__":
    base = [3, 5, 7, 11, 13]
    hi, lo = maximise_dial(base), minimise_dial(base)
    dial = lambda n: sum(2.0 / p for p in base if legendre_symbol(n, p) == 1)
    print(f"maximiser N = {hi}, dial = {dial(hi):.6f} "
          f"(max = {sum(2.0/p for p in base):.6f})")
    print(f"minimiser N = {lo}, dial = {dial(lo):.6f}")
    bits: List[int] = [1, 0, 1, 0, 1]
    n = steer_target(base, bits)
    print(f"prescribed {bits} -> N = {n}, realised "
          f"{[1 if legendre_symbol(n,p)==1 else 0 for p in base]}")


"""Assemble PACKAGE.json from the individual deliverable files."""

from __future__ import annotations

import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
SRC = ROOT / "package_src"

FUTURE_DIRECTIONS = """# Future directions — the quadratic-residue lottery dial

## What this cycle settled

Five strands of the theory are now complete, with exact statements and full proofs.

1. **The dial is an expectation, not a fit.** Over a factor base of odd primes not dividing the target,
   the closed form $\\sum_{p:\\,N\\text{ QR}} 2/p$ equals the expected footprint $\\sum_p \\#\\mathrm{roots}(p,N)/p$
   exactly. The coefficient $2/p$ is forced by the root-count identity $\\#\\mathrm{roots} = \\chi_p(N) + 1$,
   so there is no coefficient left to fit. The accompanying sufficiency statement records that the measured
   hit fraction is a deterministic function of the single quadratic-residue indicator bit.

2. **The exact distribution of the dial.** The bits are exactly independent fair coins — every one of the
   $2^k$ patterns is realised by exactly $|\\Omega|/2^k$ residue vectors — the mean is the Mertens weight
   $\\sum 1/p$, the variance is $\\sum 1/p^2$, and every bit pattern is realised by an actual integer via the
   Chinese remainder theorem.

3. **No fit can beat the theory weights.** An exact risk formula gives the squared error of *any* per-prime
   weight vector; the theory weights $2/p$ are its unique minimiser; and bit truncation is priced exactly at
   $|\\Omega|\\big[(\\sum_{\\text{tail}} 1/p)^2 + \\sum_{\\text{tail}} 1/p^2\\big] > 0$, so full $p \\le B$ support
   strictly dominates any truncation.

4. **The dial concentrates, uniformly in the factor base.** A finite Chebyshev inequality applied to the
   exact variance, together with the elementary telescoping bound $\\sum 1/p^2 \\le \\sum_{m \\ge 3} 1/m^2 \\le 1/2$
   for distinct odd primes, shows that at most a fraction $1/(2t^2)$ of residue classes read more than $t$
   from the Mertens weight — a bound with *no* dependence on the primes or on how many there are, although
   the mean $\\sum 1/p$ itself diverges. Consequences: the mean is always attained up to $1$, and a fraction
   $c$ of targets can deviate by at most $\\sqrt{1/(2c)}$.

5. **The dial concentrates sub-Gaussianly.** The exponential half of the concentration conjecture is now
   closed. The moment generating function of a single centred coin is computed exactly — it is
   $(p-1)\\cosh(sw/2)$, with no first-order term because the two tickets are equinumerous — the generating
   function of the whole dial factorises over the factor base, and $\\cosh u \\le \\exp(u^2/2)$ turns this into
   a sub-Gaussian bound with the *exact* variance proxy $\\sum 1/p^2$. A finite Chernoff/Markov step then
   gives the two-sided tail: a fraction at most $2\\exp(-t^2/(2\\sum 1/p^2))$, and hence at most $2e^{-t^2}$
   uniformly, of the residue classes coprime to the factor base read more than $t$ away from the Mertens
   weight.

## Open directions

- **From footprint to smoothness yield.** The results describe the expected number of factor-base
  divisions, not the smoothness yield a factoring run ultimately consumes. Combining the position-side
  Bernoulli structure with a Dickman/Buchstab analysis of the residual cofactor is the natural route to a
  theorem relating the dial to yield.

- **Higher moments and Poisson limits.** The generating-function factorisation gives all cumulants of the
  dial in closed form from $\\log\\cosh(s/q_i)$. Extracting a Poisson or compound-Poisson limit for the
  per-position hit counter as the factor base grows looks tractable.

- **Non-uniform target ensembles.** Replace the uniform measure on residue vectors by one reflecting an
  actual workload (for instance semiprimes of fixed bit length) and determine whether the bit vector
  remains uniform — an equidistribution question with a large-sieve flavour.

- **Character-sum sharpening.** The fluctuation term is a genuine Legendre character sum over primes.
  Combining exact distributional control over the target with classical bounds for a fixed target could
  give hybrid statements, such as counting the $N \\le X$ whose dial exceeds the Mertens weight by more
  than $t$.

- **Multiple polynomials and other sieves.** For multiple-polynomial variants with $f(x) = ax^2 + bx + c$
  the same root-count identity holds with the Legendre symbol of the discriminant; for the number field
  sieve the analogue counts degree-one primes above $p$. Both should admit a zero-fit dial with the
  coefficient forced by the same mechanism.

- **Steering as a design tool.** Every bit pattern is realisable by an integer, turning the descriptive
  theory into a constructive one: benchmark construction, best- and worst-case instance generation, and
  the selection of a small multiplier $m$ maximising the dial of $mN$ all become concrete finite
  optimisations.

- **Optimal read-outs beyond the linear class.** Optimality of the weights $2/p$ is established within
  the class of linear functions of the bit vector. If the eventual target is yield rather than footprint,
  the optimal read-out may be nonlinear; characterising it in a larger function class — with the bits
  still sufficient — is the natural next optimality question.

- **Remaining barriers.** The programme's structural barriers (5 of 8) are unchanged by this cycle: the
  footprint-to-yield gap above is the principal one, followed by the passage from a fixed factor base to
  uniformity in $B$ with an explicit dependence on the target size.
"""


def read(path: pathlib.Path) -> str:
    return path.read_text(encoding="utf-8")


LEAN_FILES = [
    "Catalog/Bridges/QRLottoDial.lean",
    "Catalog/Bridges/QRLottoDialIndependence.lean",
    "Catalog/Bridges/QRLottoDialOptimality.lean",
    "Catalog/Bridges/QRLottoDialPositions.lean",
    "Catalog/Bridges/QRLottoDialConcentration.lean",
    "Catalog/Bridges/QRLottoDialHoeffding.lean",
]


def lean_bundle() -> str:
    parts = []
    for rel in LEAN_FILES:
        parts.append(f"-- ===== {rel} =====\n" + read(ROOT / rel))
    return "\n\n".join(parts)


def main() -> None:
    article = read(ROOT / "ARTICLE.md")
    paper_md = read(ROOT / "RESEARCH_PAPER.md")
    paper_tex = read(ROOT / "RESEARCH_PAPER.tex")
    demo = read(ROOT / "demo.py")

    package = {
        "title": "The Quadratic-Residue Lottery: A Zero-Parameter Closed Form "
                 "for the Per-Target Sieve Footprint",
        "domain": "Bridges",
        "description": (
            "The sum of 2/p over the factor-base primes modulo which a target N is a "
            "quadratic residue is proved to be exactly the expected per-target sieve "
            "footprint, with the coefficient 2/p forced by the identity #roots = "
            "Legendre symbol + 1 rather than fitted. The dial's full distribution is "
            "computed exactly — independent fair coins, mean equal to the Mertens weight "
            "and variance the sum of 1/p^2 — yielding a uniqueness theorem for the "
            "weights, an exact price for truncation, and sub-Gaussian concentration "
            "uniform in the factor base."
        ),
        "authors": ["Aristotle"],
        "date": "2026-09-04",
        "key_results": [
            "Root-count identity: for every odd prime p, the number of square roots of N "
            "modulo p equals the Legendre symbol of N at p plus one, so the per-prime "
            "sieve footprint is 2/p, 0 or 1/p with no other possibility",
            "Zero-fit theorem: the closed form obtained by summing 2/p over the "
            "quadratic-residue primes of a factor base equals the expected sieve "
            "footprint exactly, with no fitted coefficient",
            "Sufficiency of the indicator bit: the measured per-prime hit fraction is a "
            "deterministic two-valued function of the quadratic-residue bit, so no "
            "per-prime measurement can carry information beyond the bit",
            "Exact distribution: the bits are exactly independent fair coins, every one of "
            "the 2^k patterns is realised equally often and by an actual integer, the mean "
            "of the dial is the Mertens weight and its variance is the sum of 1/p^2",
            "Unique optimality and the price of truncation: the exact squared-error risk of "
            "any per-prime weight vector is a positive quadratic form in its deviation from "
            "2/p, vanishing only at the theory weights, and dropping any prime costs a "
            "strictly positive, explicitly computable amount",
            "Concentration uniform in the factor base: the variance never reaches 1/2 for "
            "distinct odd primes, giving a Chebyshev bound 1/(2t^2) and a sub-Gaussian tail "
            "2exp(-t^2) on the fraction of targets deviating by t from the Mertens weight, "
            "even though that mean diverges",
        ],
        "keywords": [
            "quadratic residues",
            "Legendre symbol",
            "quadratic sieve",
            "factor base",
            "sufficient statistic",
            "Mertens theorem",
            "sub-Gaussian concentration",
            "Chinese remainder theorem",
        ],
        "article": article,
        "research_paper": paper_md,
        "research_paper_tex": paper_tex,
        "demo": demo,
        "demos": [
            {
                "name": "Complete Numerical Verification of the Quadratic-Residue Lottery",
                "description": (
                    "A twelve-part verification suite that checks every quantitative claim of "
                    "the theory by direct computation. It confirms the root-count identity "
                    "over thousands of prime-target pairs; exhibits the lottery law, where "
                    "the measured hit fraction is exactly 2/p or exactly 0; verifies that the "
                    "closed-form dial equals the brute-force footprint for large targets; "
                    "checks the fairness identity 2W + 1 = p prime by prime; enumerates the "
                    "full Chinese-remainder sample space to confirm that every bit pattern "
                    "occurs with identical multiplicity; matches the empirical mean and "
                    "variance of the dial against the closed forms; compares the closed-form "
                    "risk of six candidate weight vectors against brute-force averaging; "
                    "prices every truncation of the factor base; tabulates the empirical "
                    "deviation fractions against both the Chebyshev and Chernoff-Hoeffding "
                    "bounds; exhibits the divergence of the mean alongside the boundedness of "
                    "the variance out to a factor base of 200000; verifies the position-side "
                    "mean and variance over a full sieve period; displays the complete "
                    "2^k-point spectrum of the dial; and finally ranks random fifteen-digit "
                    "targets by their dial over the primes below 400."
                ),
                "code": demo,
            },
            {
                "name": "Fitted Weights Versus Forced Weights: A Controlled Regression Experiment",
                "description": (
                    "A controlled experiment pitting ordinary least squares against the "
                    "zero-parameter theory. Synthetic footprint measurements are generated for "
                    "thousands of random targets, per-prime weights are fitted by solving the "
                    "normal equations with Gaussian elimination, and the fitted model is then "
                    "compared with the theory weights on held-out targets. In the noiseless "
                    "regime the fit recovers 2/p to machine precision, confirming that fitting "
                    "can only rediscover the forced coefficients. With measurement noise the "
                    "fit lands at strictly positive risk, exactly as the closed-form risk "
                    "formula predicts, while the theory weights remain exact. In the truncated "
                    "regime the held-out error tracks the predicted truncation cost "
                    "(sum of 1/q over the tail)^2 + (sum of 1/q^2 over the tail), showing that "
                    "dropping even a few large primes is strictly and measurably costly. Uses "
                    "only the standard library."
                ),
                "code": read(SRC / "demo_fit_vs_theory.py"),
            },
        ],
        "algorithms": [
            {
                "name": "Legendre-Symbol Evaluation of the Zero-Fit Dial",
                "description": (
                    "Computes the dial T(N) for a target N over the factor base of odd primes "
                    "up to B. The mathematical foundation is the root-count identity: the "
                    "number of solutions of x^2 = N mod p is the Legendre symbol plus one, so "
                    "the footprint contributed by p is 2/p when the symbol is +1, 1/p in the "
                    "ramified case p | N, and 0 otherwise. The symbols are evaluated by the "
                    "binary quadratic-reciprocity (Jacobi) algorithm rather than by Euler's "
                    "criterion, replacing a modular exponentiation with a gcd-like loop. "
                    "Complexity: one cacheable sieve of Eratosthenes at O(B log log B), then "
                    "O(pi(B) log^2 B) bit operations per target — microseconds for B = 400, "
                    "so the dial is effectively a free pre-screen before any factoring attempt. "
                    "The routine also returns the diagnostic package (Mertens mean, exact "
                    "variance, z-score, full bit vector) needed to place a target inside the "
                    "known distribution of the dial."
                ),
                "pseudocode": (
                    "Input:  target N (positive integer), bound B\n"
                    "Output: dial T(N), plus mean, variance and z-score diagnostics\n"
                    "\n"
                    "1. P <- all odd primes <= B                        [sieve of Eratosthenes; cache]\n"
                    "2. T <- 0 ; bits <- empty list\n"
                    "3. for each p in P do\n"
                    "4.     s <- JACOBI(N mod p, p)                     [binary reciprocity, O(log^2 p)]\n"
                    "5.     if s = 0 then                               [p divides N: ramified class]\n"
                    "6.         T <- T + 1/p ; append 0 to bits\n"
                    "7.     else if s = +1 then                         [N is a quadratic residue]\n"
                    "8.         T <- T + 2/p ; append 1 to bits\n"
                    "9.     else                                        [non-residue: no roots]\n"
                    "10.        append 0 to bits\n"
                    "11. mu  <- sum over p in P of 1/p                  [Mertens weight = E[T]]\n"
                    "12. V   <- sum over p in P of 1/p^2                [exact variance of T]\n"
                    "13. return (T, mu, V, (T - mu)/sqrt(V), bits)\n"
                    "\n"
                    "JACOBI(a, n) for odd n > 0:\n"
                    "  r <- 1\n"
                    "  while a != 0 do\n"
                    "      while a is even do  a <- a/2 ;  if n mod 8 in {3,5} then r <- -r\n"
                    "      swap(a, n)\n"
                    "      if a = 3 mod 4 and n = 3 mod 4 then r <- -r\n"
                    "      a <- a mod n\n"
                    "  return r if n = 1 else 0"
                ),
                "code": read(SRC / "algo_dial.py"),
            },
            {
                "name": "Closed-Form Risk Audit of an Arbitrary Fitted Weight Vector",
                "description": (
                    "Evaluates, in closed form and without any data, the exact mean squared "
                    "error incurred by replacing the forced weights 2/p with an arbitrary "
                    "per-prime weight vector w. Because the quadratic-residue bits are exactly "
                    "independent fair coins over the Chinese-remainder sample space, the risk "
                    "of a linear read-out is a positive-semidefinite quadratic form in the "
                    "deviations d_i = 2/q_i - w_i, namely (sum d_i/2)^2 + sum d_i^2/4 per "
                    "sample point: a mean-squared term plus a variance term. The form vanishes "
                    "if and only if w is the theory vector, so the global optimum of any "
                    "fitting procedure is known before the search begins and every candidate "
                    "can be scored against it in O(k) time with no cross-validation. The same "
                    "routine specialises to the exact cost of truncating the factor base, "
                    "(sum over the tail of 1/q)^2 + sum over the tail of 1/q^2, which is "
                    "strictly positive as soon as one prime is dropped."
                ),
                "pseudocode": (
                    "Input:  factor base q_1..q_k of distinct odd primes, weight vector w_1..w_k\n"
                    "Output: exact risk per sample point, decomposed into its two terms\n"
                    "\n"
                    "1. for i = 1..k do  d_i <- 2/q_i - w_i             [deviation from theory]\n"
                    "2. mean_term     <- ( sum_i d_i / 2 )^2\n"
                    "3. variance_term <- sum_i d_i^2 / 4\n"
                    "4. risk <- mean_term + variance_term\n"
                    "5. return (risk, mean_term, variance_term, max_i |d_i|, risk = 0)\n"
                    "\n"
                    "TRUNCATION-RISK(q_1..q_k, kept set S):\n"
                    "1. tail <- { q_i : i not in S }\n"
                    "2. return ( sum over tail of 1/q )^2 + sum over tail of 1/q^2\n"
                    "3. [ strictly positive whenever tail is nonempty ]"
                ),
                "code": read(SRC / "algo_risk.py"),
            },
            {
                "name": "Chinese-Remainder Steering of a Prescribed Lottery Pattern",
                "description": (
                    "Constructs an integer N whose win/lose pattern across a given factor base "
                    "is any prescribed bit vector, making the descriptive distribution theory "
                    "constructive. The construction is guaranteed to succeed because exactly "
                    "(q-1)/2 of the invertible classes modulo each prime q carry each quadratic "
                    "character, so every ticket set is nonempty, and the moduli are pairwise "
                    "coprime. A linear scan finds a representative with the desired character "
                    "at each prime in O(1) trials in expectation, since half of all classes "
                    "qualify; the Chinese remainder theorem then glues the representatives "
                    "together in O(k log^2 Q) bit operations, where Q is the product of the "
                    "moduli. Specialising the pattern to all-ones or all-zeros produces targets "
                    "attaining the maximum value sum 2/q and the minimum value 0 of the dial, "
                    "confirming that the full 2^k-point spectrum is realised by integers."
                ),
                "pseudocode": (
                    "Input:  distinct odd primes q_1..q_k, desired bit pattern e_1..e_k\n"
                    "Output: a positive integer N realising that pattern\n"
                    "\n"
                    "1. for i = 1..k do\n"
                    "2.     want <- +1 if e_i = 1 else -1\n"
                    "3.     a_i  <- least a in {1..q_i-1} with LEGENDRE(a, q_i) = want\n"
                    "4.               [ exists: exactly (q_i-1)/2 classes carry each character ]\n"
                    "5. x <- 0 ; M <- 1                                 [CRT accumulation]\n"
                    "6. for i = 1..k do\n"
                    "7.     t <- (a_i - x) * (M^{-1} mod q_i)  mod q_i\n"
                    "8.     x <- x + M * t ;  M <- M * q_i\n"
                    "9. return x if x > 0 else M\n"
                    "\n"
                    "MAXIMISE: run with e = (1,...,1)  -> dial attains sum_i 2/q_i\n"
                    "MINIMISE: run with e = (0,...,0)  -> dial attains 0"
                ),
                "code": read(SRC / "algo_steer.py"),
            },
        ],
        "visualizations": [
            {
                "name": "The Exact Law of the Dial and Its Sub-Gaussian Envelope",
                "description": (
                    "A four-panel study of the distribution of the dial. Panel (a) plots the "
                    "exact 2^k-atom law obtained by exhaustive enumeration of bit patterns, "
                    "with the Mertens mean and the one-standard-deviation band overlaid. Panel "
                    "(b) centres the law and compares it with the Gaussian carrying the exact "
                    "variance sum 1/p^2, exhibiting the sub-Gaussian shape. Panel (c) plots the "
                    "exact deviating fraction against the Chebyshev bound V/t^2, the "
                    "Chernoff-Hoeffding bound 2exp(-t^2/2V) and the factor-base-free bound "
                    "2exp(-t^2), showing where the exponential bound overtakes the polynomial "
                    "one. Panel (d) traces the mean and the variance as the factor-base bound "
                    "grows to 100000, displaying the central dichotomy: the mean diverges while "
                    "the variance never reaches the universal ceiling 1/2."
                ),
                "code": read(SRC / "viz_distribution.py"),
            },
            {
                "name": "The Risk Landscape Around the Forced Weights",
                "description": (
                    "A three-panel picture of the optimality theorem. Panel (a) is a contour "
                    "map of a two-dimensional slice of the exact risk surface, obtained by "
                    "perturbing the weights of two chosen primes while the rest are held at "
                    "their theory values: a positive-semidefinite quadratic bowl with a single "
                    "zero, marked at the theory point. Panel (b) plots the exact cost of "
                    "truncating the factor base as primes are dropped one at a time on a "
                    "logarithmic scale, showing that the cost is strictly positive from the "
                    "very first omission. Panel (c) scatters the risk of thousands of randomly "
                    "perturbed weight vectors against the size of the perturbation, making the "
                    "quadratic penalty visible and confirming that no direction in weight space "
                    "is free."
                ),
                "code": read(SRC / "viz_risk.py"),
            },
        ],
        "interactive_demos": [
            {
                "title": "The Quadratic-Residue Lottery Bench",
                "description": (
                    "A complete laboratory for the dial. Type any target and choose a "
                    "factor-base bound, and the bench evaluates every Legendre symbol live "
                    "(with exact big-integer arithmetic) and reports the dial, the Mertens "
                    "mean, the exact standard deviation, the target's z-score and the "
                    "sub-Gaussian tail bound at that deviation. Four linked panels bring the "
                    "theory to life: a per-prime lottery table whose bar heights are the "
                    "forced footprints 2/p, coloured by win, loss and ramification; the dial "
                    "accumulating prime by prime against the Mertens curve, so the Legendre "
                    "character fluctuation is the visible gap between them; the exact law of "
                    "the dial with the target's position marked and the sub-Gaussian envelope "
                    "drawn from the exact variance; and two experiment panels. In the first, "
                    "sliders let the reader rescale or reshape the weights and watch the "
                    "closed-form risk climb away from zero in every direction — a hands-on "
                    "demonstration that the theory weights are the unique minimiser. In the "
                    "second, a truncation slider prices the exact cost of dropping the tail of "
                    "the factor base and displays the target-dependent dial deficit. Buttons "
                    "invoke Chinese-remainder steering to construct, on the spot, targets that "
                    "win every lottery or lose every one."
                ),
                "html": read(SRC / "widget.html"),
            },
            {
                "title": "The Lottery Table of a Single Prime",
                "description": (
                    "The microscope for the root-count identity. Choose an odd prime and see "
                    "all of its residue classes laid out as lottery tickets, coloured by their "
                    "number of square roots: two for a winning quadratic residue, none for a "
                    "losing non-residue, and exactly one for the ramified class. Hovering a "
                    "class reveals its actual square roots and displays the identity "
                    "#roots = Legendre symbol + 1 instantiated at that class, together with the "
                    "resulting footprint. A live tally underneath verifies the fairness "
                    "identity 2W + 1 = p, the exact win probability 1/2 among invertible "
                    "classes, the fact that the root counts over a full period always sum to "
                    "exactly p, and the resulting mean hit density of exactly 1/p — the Mertens "
                    "weight, with no constant fitted anywhere."
                ),
                "html": read(SRC / "widget2.html"),
            },
        ],
        "interactive_layout": read(SRC / "interactive_layout.md"),
        "lean_proofs": lean_bundle(),
        "future_directions": FUTURE_DIRECTIONS,
        "modules": {
            "demo": demo,
            "demo_fit_vs_theory": read(SRC / "demo_fit_vs_theory.py"),
            "algo_dial": read(SRC / "algo_dial.py"),
            "algo_risk": read(SRC / "algo_risk.py"),
            "algo_steer": read(SRC / "algo_steer.py"),
            "viz_distribution": read(SRC / "viz_distribution.py"),
            "viz_risk": read(SRC / "viz_risk.py"),
        },
        "lean_files": LEAN_FILES,
    }

    out = ROOT / "PACKAGE.json"
    out.write_text(json.dumps(package, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"wrote {out} ({out.stat().st_size} bytes)")


if __name__ == "__main__":
    main()


"""Fitting versus theory: a controlled experiment on the quadratic-residue dial.

We generate synthetic "measured footprints" for random targets, fit per-prime
weights by ordinary least squares, and compare the fitted model with the
zero-parameter theory weights 2/p on held-out targets.

Three regimes are examined.

  * Noiseless data. The least-squares fit recovers 2/p to machine precision:
    fitting can only rediscover the forced coefficients.
  * Noisy data. The fit lands at strictly positive risk against the true
    footprint, and the closed-form risk formula
        risk(w) = (sum d_i / 2)^2 + sum d_i^2 / 4,   d_i = 2/q_i - w_i,
    gives the exact error averaged over the residue sample space, which the
    held-out error reproduces up to sampling fluctuation.
  * Truncated support. Dropping the tail primes costs
        (sum_tail 1/q)^2 + sum_tail 1/q^2,
    strictly positive however small the dropped weights.

Pure standard library: the normal equations are solved by Gaussian elimination
with partial pivoting.
"""

from __future__ import annotations

import random
from typing import List, Sequence, Tuple


def primes_up_to(bound: int) -> List[int]:
    if bound < 2:
        return []
    flags = bytearray([1]) * (bound + 1)
    flags[0] = flags[1] = 0
    for m in range(2, int(bound**0.5) + 1):
        if flags[m]:
            flags[m * m :: m] = bytearray(len(flags[m * m :: m]))
    return [m for m in range(bound + 1) if flags[m]]


def legendre_symbol(a: int, p: int) -> int:
    a %= p
    if a == 0:
        return 0
    return 1 if pow(a, (p - 1) // 2, p) == 1 else -1


def bit_vector(n: int, base: Sequence[int]) -> List[float]:
    return [1.0 if legendre_symbol(n, p) == 1 else 0.0 for p in base]


def true_footprint(n: int, base: Sequence[int]) -> float:
    return sum(2.0 / p for p, b in zip(base, bit_vector(n, base)) if b)


def solve(matrix: List[List[float]], rhs: List[float]) -> List[float]:
    """Gaussian elimination with partial pivoting for a square system."""
    k = len(rhs)
    aug = [row[:] + [rhs[i]] for i, row in enumerate(matrix)]
    for col in range(k):
        pivot = max(range(col, k), key=lambda r: abs(aug[r][col]))
        if abs(aug[pivot][col]) < 1e-14:
            continue
        aug[col], aug[pivot] = aug[pivot], aug[col]
        piv = aug[col][col]
        for r in range(k):
            if r == col:
                continue
            factor = aug[r][col] / piv
            for c in range(col, k + 1):
                aug[r][c] -= factor * aug[col][c]
    return [aug[i][k] / aug[i][i] if abs(aug[i][i]) > 1e-14 else 0.0 for i in range(k)]


def least_squares(design: List[List[float]], targets: List[float]) -> List[float]:
    """Ordinary least squares via the normal equations X^T X w = X^T y."""
    k = len(design[0])
    gram = [[sum(row[i] * row[j] for row in design) for j in range(k)] for i in range(k)]
    moment = [sum(row[i] * y for row, y in zip(design, targets)) for i in range(k)]
    return solve(gram, moment)


def risk_closed_form(base: Sequence[int], weights: Sequence[float]) -> float:
    deltas = [2.0 / p - w for p, w in zip(base, weights)]
    return sum(d / 2.0 for d in deltas) ** 2 + sum(d * d / 4.0 for d in deltas)


def held_out_error(base: Sequence[int], weights: Sequence[float],
                   targets: Sequence[int]) -> float:
    total = 0.0
    for n in targets:
        bits = bit_vector(n, base)
        pred = sum(w * b for w, b in zip(weights, bits))
        total += (true_footprint(n, base) - pred) ** 2
    return total / len(targets)


def experiment(bound: int = 60, n_train: int = 4000, n_test: int = 4000,
               noise: float = 0.05, seed: int = 20260926) -> None:
    base = [p for p in primes_up_to(bound) if p != 2]
    rng = random.Random(seed)
    train = [rng.randrange(10**9, 10**10) for _ in range(n_train)]
    test = [rng.randrange(10**9, 10**10) for _ in range(n_test)]
    theory = [2.0 / p for p in base]

    design = [bit_vector(n, base) for n in train]

    print(f"factor base: {len(base)} odd primes up to {bound}")
    print(f"training targets: {n_train}, held-out targets: {n_test}\n")

    # Regime 1: noiseless
    y_clean = [true_footprint(n, base) for n in train]
    w_clean = least_squares(design, y_clean)
    print("Regime 1 -- noiseless measurements")
    print(f"   max |w_fit - 2/p|        = "
          f"{max(abs(a-b) for a, b in zip(w_clean, theory)):.3e}")
    print(f"   closed-form risk of fit  = {risk_closed_form(base, w_clean):.3e}")
    print("   the fit rediscovers the forced coefficients; it cannot improve on them.\n")

    # Regime 2: noisy
    y_noisy = [v + rng.gauss(0.0, noise) for v in y_clean]
    w_noisy = least_squares(design, y_noisy)
    print(f"Regime 2 -- measurements with Gaussian noise of scale {noise}")
    print(f"   max |w_fit - 2/p|        = "
          f"{max(abs(a-b) for a, b in zip(w_noisy, theory)):.6f}")
    print(f"   closed-form risk of fit  = {risk_closed_form(base, w_noisy):.8f}")
    print(f"   held-out error of fit    = {held_out_error(base, w_noisy, test):.8f}")
    print(f"   held-out error of theory = {held_out_error(base, theory, test):.8f}")
    print("   the fitted vector is strictly worse; the theory weights are exact.\n")

    # Regime 3: truncation
    print("Regime 3 -- truncating the support of the weight vector")
    print(f"{'kept up to':>12} {'dropped':>9} {'closed-form risk':>18} "
          f"{'held-out error':>16}")
    for cutoff in [bound, 41, 29, 19, 11, 5]:
        w = [2.0 / p if p <= cutoff else 0.0 for p in base]
        tail = [p for p in base if p > cutoff]
        predicted = (sum(1.0 / p for p in tail)) ** 2 + sum(1.0 / (p * p) for p in tail)
        assert abs(predicted - risk_closed_form(base, w)) < 1e-12
        print(f"{cutoff:>12} {len(tail):>9} {predicted:>18.8f} "
              f"{held_out_error(base, w, test):>16.8f}")
    print("\n   every truncation is strictly costly, and the closed formula prices it.")


if __name__ == "__main__":
    experiment()


"""Visualization — the exact law of the dial against its sub-Gaussian envelope.

Draws, for a chosen factor base:
  (a) the exact 2^k-atom distribution of T = sum_i (2/q_i) * Bernoulli(1/2),
      obtained by exhaustive convolution over bit patterns;
  (b) the Mertens mean sum 1/q and the one-standard-deviation band
      sqrt(sum 1/q^2);
  (c) the empirical tail fraction P[|T - mean| >= t] against the Chebyshev
      bound V/t^2 and the Chernoff-Hoeffding bound 2 exp(-t^2 / 2V);
  (d) the divergence of the mean against the boundedness of the variance
      as the factor-base bound B grows.

Requires matplotlib and numpy.
"""

from __future__ import annotations

import itertools
import math
from typing import List, Sequence, Tuple

import matplotlib.pyplot as plt
import numpy as np


def primes_up_to(bound: int) -> List[int]:
    if bound < 2:
        return []
    flags = bytearray([1]) * (bound + 1)
    flags[0] = flags[1] = 0
    for m in range(2, int(bound**0.5) + 1):
        if flags[m]:
            flags[m * m :: m] = bytearray(len(flags[m * m :: m]))
    return [m for m in range(bound + 1) if flags[m]]


def exact_distribution(base: Sequence[int]) -> List[float]:
    """All 2^k atoms of the dial, each carrying equal probability 2^-k."""
    weights = [2.0 / p for p in base]
    return [sum(w for w, b in zip(weights, pattern) if b)
            for pattern in itertools.product([0, 1], repeat=len(base))]


def moments(base: Sequence[int]) -> Tuple[float, float]:
    """The exact mean sum 1/q and variance sum 1/q^2."""
    return sum(1.0 / p for p in base), sum(1.0 / (p * p) for p in base)


def make_figure(bound: int = 60, outfile: str = "qr_dial_distribution.png") -> None:
    base = [p for p in primes_up_to(bound) if p != 2]
    values = np.array(exact_distribution(base))
    mean, var = moments(base)
    sd = math.sqrt(var)

    fig, axes = plt.subplots(2, 2, figsize=(13, 9))
    fig.suptitle(
        f"The zero-fit quadratic-residue dial  $T(N)=\\sum_{{QR}} 2/p$   "
        f"(factor base: {len(base)} odd primes up to {bound})",
        fontsize=13,
    )

    # (a) exact law
    ax = axes[0][0]
    ax.hist(values, bins=64, color="#3b6ea5", alpha=0.85, density=True)
    ax.axvline(mean, color="crimson", lw=2, label=f"Mertens mean $\\sum 1/p={mean:.3f}$")
    ax.axvspan(mean - sd, mean + sd, color="crimson", alpha=0.12,
               label=f"$\\pm\\sigma$, $\\sigma=\\sqrt{{\\sum 1/p^2}}={sd:.3f}$")
    ax.set_xlabel("dial value $T$")
    ax.set_ylabel("density")
    ax.set_title("(a) exact $2^k$-atom law of the dial")
    ax.legend(fontsize=8)

    # (b) Gaussian comparison of the centred law
    ax = axes[0][1]
    centred = values - mean
    ax.hist(centred, bins=64, density=True, color="#6a994e", alpha=0.8,
            label="centred dial")
    grid = np.linspace(centred.min(), centred.max(), 400)
    ax.plot(grid, np.exp(-grid**2 / (2 * var)) / math.sqrt(2 * math.pi * var),
            color="black", lw=2, label="Gaussian with the exact variance")
    ax.set_xlabel("$T-\\mathbb{E}[T]$")
    ax.set_title("(b) the dial is sub-Gaussian with proxy $V=\\sum 1/p^2$")
    ax.legend(fontsize=8)

    # (c) tails
    ax = axes[1][0]
    ts = np.linspace(0.05, 3 * sd, 200)
    emp = [np.mean(np.abs(centred) >= t) for t in ts]
    ax.semilogy(ts, np.maximum(emp, 1e-6), label="exact deviating fraction", lw=2)
    ax.semilogy(ts, np.minimum(1.0, var / ts**2), "--",
                label="Chebyshev $V/t^2$")
    ax.semilogy(ts, np.minimum(1.0, 2 * np.exp(-ts**2 / (2 * var))), "--",
                label="Chernoff $2e^{-t^2/2V}$")
    ax.semilogy(ts, np.minimum(1.0, 2 * np.exp(-ts**2)), ":",
                label="uniform $2e^{-t^2}$")
    ax.set_xlabel("deviation $t$")
    ax.set_ylabel("fraction of targets")
    ax.set_title("(c) tails: exact law versus the two bounds")
    ax.legend(fontsize=8)

    # (d) diverging mean, bounded variance
    ax = axes[1][1]
    bounds = [10, 20, 50, 100, 200, 400, 1000, 5000, 20000, 100000]
    means, vars_ = [], []
    for b in bounds:
        bb = [p for p in primes_up_to(b) if p != 2]
        m, v = moments(bb)
        means.append(m)
        vars_.append(v)
    ax.semilogx(bounds, means, "o-", color="crimson", label="mean: sum of $1/p$")
    ax.semilogx(bounds, vars_, "s-", color="#3b6ea5",
                label="variance: sum of $1/p^2$")
    ax.axhline(0.5, color="black", ls=":", label="universal variance ceiling $1/2$")
    ax.set_xlabel("factor-base bound $B$")
    ax.set_title("(d) the mean diverges; the variance never reaches $1/2$")
    ax.legend(fontsize=8)

    fig.tight_layout(rect=(0, 0, 1, 0.96))
    fig.savefig(outfile, dpi=150)
    print(f"wrote {outfile}")


if __name__ == "__main__":
    make_figure()


"""Visualization — the risk landscape around the forced weights 2/p.

Panel (a): a two-dimensional slice of the exact risk surface
    risk(w) = (sum_i d_i/2)^2 + sum_i d_i^2/4,   d_i = 2/q_i - w_i,
obtained by perturbing the weights of two chosen primes while holding the rest
at their theory values. The surface is a positive-semidefinite quadratic form
with a single zero at the theory point.

Panel (b): the exact cost of truncating the factor base, prime by prime, showing
that dropping even the largest prime is strictly costly.

Panel (c): risk of randomly perturbed weight vectors versus the size of the
perturbation, with the closed-form quadratic law overlaid.

Requires matplotlib and numpy.
"""

from __future__ import annotations

import random
from typing import List, Sequence

import matplotlib.pyplot as plt
import numpy as np


def primes_up_to(bound: int) -> List[int]:
    if bound < 2:
        return []
    flags = bytearray([1]) * (bound + 1)
    flags[0] = flags[1] = 0
    for m in range(2, int(bound**0.5) + 1):
        if flags[m]:
            flags[m * m :: m] = bytearray(len(flags[m * m :: m]))
    return [m for m in range(bound + 1) if flags[m]]


def risk(base: Sequence[int], weights: Sequence[float]) -> float:
    deltas = [2.0 / p - w for p, w in zip(base, weights)]
    return sum(d / 2.0 for d in deltas) ** 2 + sum(d * d / 4.0 for d in deltas)


def make_figure(outfile: str = "qr_dial_risk.png", seed: int = 20260926) -> None:
    base = [p for p in primes_up_to(60) if p != 2]
    theory = [2.0 / p for p in base]
    rng = random.Random(seed)

    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    fig.suptitle("No fit can beat the forced weights $2/p$", fontsize=14)

    # (a) 2-D slice of the risk surface
    ax = axes[0]
    span = np.linspace(-0.25, 0.25, 220)
    grid = np.zeros((len(span), len(span)))
    for a, da in enumerate(span):
        for b, db in enumerate(span):
            w = list(theory)
            w[0] += da
            w[1] += db
            grid[b][a] = risk(base, w)
    cs = ax.contourf(span, span, grid, levels=28, cmap="magma")
    ax.plot(0, 0, "o", color="cyan", markersize=9, label="theory point $2/p$")
    fig.colorbar(cs, ax=ax, label="risk per sample point")
    ax.set_xlabel(f"perturbation of $w$ at $p={base[0]}$")
    ax.set_ylabel(f"perturbation of $w$ at $p={base[1]}$")
    ax.set_title("(a) risk surface: a single global zero")
    ax.legend(fontsize=8)

    # (b) truncation cost
    ax = axes[1]
    costs, labels = [], []
    for keep in range(len(base), 0, -1):
        w = [2.0 / p if i < keep else 0.0 for i, p in enumerate(base)]
        costs.append(risk(base, w))
        labels.append(base[keep - 1] if keep < len(base) else 0)
    kept_counts = list(range(len(base), 0, -1))
    ax.semilogy(kept_counts, np.maximum(costs, 1e-9), "o-", color="#3b6ea5")
    ax.invert_xaxis()
    ax.set_xlabel("number of primes retained")
    ax.set_ylabel("exact risk of truncation")
    ax.set_title("(b) truncation is always strictly costly")
    ax.grid(alpha=0.3)

    # (c) random perturbations
    ax = axes[2]
    sizes, risks = [], []
    for _ in range(3000):
        eps = rng.uniform(0.0, 0.2)
        w = [t + rng.uniform(-eps, eps) for t in theory]
        sizes.append(max(abs(t - wi) for t, wi in zip(theory, w)))
        risks.append(risk(base, w))
    ax.scatter(sizes, risks, s=4, alpha=0.35, color="#6a994e")
    ax.set_xlabel(r"$\max_i |w_i - 2/q_i|$")
    ax.set_ylabel("risk")
    ax.set_title("(c) every deviation is strictly penalised")
    ax.grid(alpha=0.3)

    fig.tight_layout(rect=(0, 0, 1, 0.93))
    fig.savefig(outfile, dpi=150)
    print(f"wrote {outfile}")


if __name__ == "__main__":
    make_figure()
