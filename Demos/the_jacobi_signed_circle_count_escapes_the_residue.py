"""
The Jacobi-Signed Circle Count: numerical demonstration.
========================================================

For an odd modulus N let

    S(N) = { (x, y) in (Z/NZ)^2 : x^2 + y^2 = 1 }

be the unit circle over Z/NZ, and define the Jacobi-signed circle count

    W(N) = sum over (x, y) in S(N) of  (x / N)          [Jacobi symbol]

This script verifies, numerically, every structural result about W:

  1. Collapse identity      W(p) = sum_x chi(x(1 - x^2))     (chi = Legendre symbol)
  2. Multiplicativity       W(mn) = W(m) W(n) for gcd(m, n) = 1
  3. Vanishing              W(p) = 0 for p = 3 (mod 4)
  4. Exact parity           W(p) = 2 (mod 4) for p = 1 (mod 4)
  5. Second moment          sum_d A(d)^2 = 2 p (p - 1),  A(d) = sum_x chi(x^3 - d x)
  6. Weil bound             W(p)^2 <= 4p,  and |W(N)| <= 4 sqrt(N) for semiprimes
  7. Jacobsthal identity    A(1)^2 + A(nu)^2 = 4p  for any nonresidue nu
  8. Two squares            p = (W(p)/2)^2 + (A(nu)/2)^2 with W(p)/2 odd
  9. Not a residue dial     W is not a function of N mod 8 (nor mod 4)
 10. Decorrelation          W(N) carries no low-order signal about p, q

Self-contained: standard library only.
"""

from __future__ import annotations

import math
import random
from typing import Callable, Dict, List, Sequence, Tuple

# ---------------------------------------------------------------------------
# Basic number theory
# ---------------------------------------------------------------------------


def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test (n small in this demo)."""
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    d = 3
    while d * d <= n:
        if n % d == 0:
            return False
        d += 2
    return True


def primes_up_to(limit: int) -> List[int]:
    """All primes < limit, by sieve of Eratosthenes."""
    sieve = [True] * limit
    sieve[0:2] = [False, False]
    for i in range(2, int(limit ** 0.5) + 1):
        if sieve[i]:
            for j in range(i * i, limit, i):
                sieve[j] = False
    return [i for i, ok in enumerate(sieve) if ok]


def legendre(a: int, p: int) -> int:
    """Legendre symbol (a/p) for odd prime p, by Euler's criterion."""
    a %= p
    if a == 0:
        return 0
    return 1 if pow(a, (p - 1) // 2, p) == 1 else -1


def jacobi(a: int, n: int) -> int:
    """Jacobi symbol (a/n) for odd n >= 1, by quadratic reciprocity."""
    if n <= 0 or n % 2 == 0:
        raise ValueError("Jacobi symbol requires an odd positive lower argument")
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


# ---------------------------------------------------------------------------
# The statistic, in both of its guises
# ---------------------------------------------------------------------------


def circle_weight_geometric(n: int) -> int:
    """W(n) computed straight from the definition: sum over circle points of (x/n).

    Cost O(n^2); used only for small n as an independent cross-check.
    """
    total = 0
    for x in range(n):
        jx = jacobi(x, n)
        if jx == 0:
            continue
        for y in range(n):
            if (x * x + y * y) % n == 1 % n:
                total += jx
    return total


def circle_weight(n: int) -> int:
    """W(n) via the collapse identity: sum_x (x(1 - x^2) / n).  Cost O(n)."""
    return sum(jacobi(x * (1 - x * x) % n, n) for x in range(n))


def twist_sum(p: int, d: int) -> int:
    """A(d) = sum_x chi(x^3 - d x): (minus) the trace of Frobenius of y^2 = x^3 - dx."""
    return sum(legendre((x * x * x - d * x) % p, p) for x in range(p))


def a_nonresidue(p: int) -> int:
    """Smallest quadratic nonresidue mod p."""
    for v in range(2, p):
        if legendre(v, p) == -1:
            return v
    raise ValueError("no nonresidue found")


def two_squares_from_statistic(p: int) -> Tuple[int, int]:
    """Return (a, b) with p = a^2 + b^2, a = W(p)/2 odd, b = A(nu)/2."""
    if p % 4 != 1:
        raise ValueError("p must be 1 mod 4")
    a = circle_weight(p) // 2
    b = twist_sum(p, a_nonresidue(p)) // 2
    return a, b


# ---------------------------------------------------------------------------
# Statistics helpers
# ---------------------------------------------------------------------------


def pearson(xs: Sequence[float], ys: Sequence[float]) -> float:
    n = len(xs)
    mx, my = sum(xs) / n, sum(ys) / n
    sx = math.sqrt(sum((x - mx) ** 2 for x in xs))
    sy = math.sqrt(sum((y - my) ** 2 for y in ys))
    if sx == 0 or sy == 0:
        return 0.0
    return sum((x - mx) * (y - my) for x, y in zip(xs, ys)) / (sx * sy)


def permutation_threshold(
    values: Sequence[float], covariate: Sequence[float], trials: int, seed: int
) -> float:
    """95th percentile of |corr| under random reshuffling of `values`."""
    rng = random.Random(seed)
    shuffled = list(values)
    nulls: List[float] = []
    for _ in range(trials):
        rng.shuffle(shuffled)
        nulls.append(abs(pearson(shuffled, covariate)))
    nulls.sort()
    return nulls[int(0.95 * trials)]


def banner(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------


def demo_collapse_identity() -> None:
    banner("1. Collapse identity:  geometric circle weight == cubic character sum")
    print(f"{'n':>6} {'geometric W(n)':>16} {'cubic sum W(n)':>16}   match")
    for n in [5, 13, 17, 21, 29, 33, 41, 85]:
        g, c = circle_weight_geometric(n), circle_weight(n)
        print(f"{n:>6} {g:>16} {c:>16}   {'OK' if g == c else 'MISMATCH'}")
        assert g == c


def demo_multiplicativity() -> None:
    banner("2. Multiplicativity:  W(pq) = W(p) W(q)")
    print(f"{'N=pq':>8} {'p':>5} {'q':>5} {'W(p)':>7} {'W(q)':>7} {'W(p)W(q)':>10} {'W(N)':>8}")
    for p, q in [(3, 7), (5, 17), (5, 41), (13, 17), (13, 29), (17, 29), (29, 53)]:
        wp, wq, wn = circle_weight(p), circle_weight(q), circle_weight(p * q)
        print(f"{p*q:>8} {p:>5} {q:>5} {wp:>7} {wq:>7} {wp*wq:>10} {wn:>8}")
        assert wn == wp * wq


def demo_vanishing_and_parity() -> None:
    banner("3-4. Vanishing for p = 3 (mod 4);  W(p) = 2 (mod 4) for p = 1 (mod 4)")
    print(f"{'p':>6} {'p mod 8':>8} {'W(p)':>8} {'W(p) mod 4':>12}")
    for p in [3, 7, 11, 19, 23, 5, 13, 17, 29, 37, 41, 53, 61, 73, 89, 97, 113]:
        w = circle_weight(p)
        print(f"{p:>6} {p % 8:>8} {w:>8} {w % 4:>12}")
        if p % 4 == 3:
            assert w == 0, "must vanish"
        else:
            assert w % 4 == 2, "must be twice an odd number"


def demo_second_moment_and_weil() -> None:
    banner("5-6. Exact second moment  sum_d A(d)^2 = 2p(p-1),  and the Weil bound")
    print(f"{'p':>6} {'sum_d A(d)^2':>14} {'2p(p-1)':>12} {'W(p)':>7} {'W^2':>8} {'4p':>7} {'ratio':>7}")
    for p in [5, 13, 17, 29, 41, 53, 61, 73, 97, 173]:
        moment = sum(twist_sum(p, d) ** 2 for d in range(p))
        w = circle_weight(p)
        print(
            f"{p:>6} {moment:>14} {2*p*(p-1):>12} {w:>7} {w*w:>8} {4*p:>7} "
            f"{w*w/(4*p):>7.3f}"
        )
        assert moment == 2 * p * (p - 1)
        assert w * w <= 4 * p


def demo_jacobsthal_and_two_squares() -> None:
    banner("7-8. Jacobsthal identity  A(1)^2 + A(nu)^2 = 4p,  and Fermat two squares")
    print(f"{'p':>6} {'A(1)=W(p)':>10} {'A(nu)':>8} {'A1^2+Anu^2':>12} {'4p':>7}   p = a^2 + b^2")
    for p in [5, 13, 17, 29, 41, 53, 73, 97, 113, 173, 293]:
        nu = a_nonresidue(p)
        a1, anu = twist_sum(p, 1), twist_sum(p, nu)
        w = circle_weight(p)
        a, b = two_squares_from_statistic(p)
        print(
            f"{p:>6} {a1:>10} {anu:>8} {a1*a1+anu*anu:>12} {4*p:>7}   "
            f"{p} = {a}^2 + {b}^2   (a odd: {a % 2 == 1})"
        )
        assert w == a1
        assert a1 * a1 + anu * anu == 4 * p
        assert a * a + b * b == p
        assert a % 2 == 1


def demo_not_a_residue_dial() -> None:
    banner("9. Not a residue dial:  W is not a function of N mod 8 (nor mod 4)")
    print("Primes congruent to 1 mod 8:")
    for p in [17, 41, 73, 89, 97, 113]:
        print(f"    p = {p:>4}   p mod 8 = {p % 8}   W(p) = {circle_weight(p):>4}")
    assert circle_weight(17) != circle_weight(41)
    print("  -> W(17) = -2 but W(41) = -10: no function of p mod 8 can do this.")

    print("\nPrimes congruent to 1 mod 4:")
    for p in [13, 17]:
        print(f"    p = {p:>4}   p mod 4 = {p % 4}   W(p) = {circle_weight(p):>4}")
    assert circle_weight(13) != circle_weight(17)
    print("  -> the mod-4 dial dies too.")

    print("\nComposite moduli congruent to 5 mod 8:")
    for n in [21, 85, 205, 221]:
        print(f"    N = {n:>5}   N mod 8 = {n % 8}   W(N) = {circle_weight(n):>5}")
    assert circle_weight(21) != circle_weight(85)
    print("  -> W(21) = 0 but W(85) = -4: the dial is broken at composite level too.")

    print("\nBUT the value mod 8 *is* a dial (the residual public part):")
    for p in [17, 41, 73, 89, 5, 13, 29, 37]:
        print(f"    p mod 8 = {p % 8}  =>  W(p) mod 8 = {circle_weight(p) % 8}")


def demo_blindness() -> None:
    banner("Blind families and collisions")
    print("W(3q) = 0 for every prime q != 3 -- an infinite zero-information family:")
    for q in [5, 7, 11, 13, 17, 19, 23]:
        w = circle_weight(3 * q)
        print(f"    N = 3 * {q:>3} = {3*q:>4}   W(N) = {w}")
        assert w == 0
    print("\nCollisions: W(15) = W(21) = 0, so W cannot determine a factorisation.")


def demo_weil_floor_attainment() -> None:
    banner("Near-attainment of the Weil bound  |W(p)| <= 2 sqrt(p)")
    print(f"{'p':>6} {'W(p)':>7} {'2 sqrt(p)':>11} {'ratio W^2/(4p)':>16}")
    best: List[Tuple[float, int, int]] = []
    for p in primes_up_to(500):
        if p % 4 != 1:
            continue
        w = circle_weight(p)
        best.append((w * w / (4 * p), p, w))
    best.sort(reverse=True)
    for ratio, p, w in best[:8]:
        print(f"{p:>6} {w:>7} {2*math.sqrt(p):>11.3f} {ratio:>16.4f}")
    print("\nThe bound is sharp: no constant c < 3.9 works in W(p)^2 <= c p.")


def demo_decorrelation(trials: int = 2000, seed: int = 20260813) -> None:
    banner("10. Factor-dependent but unstructured: permutation test on 40 semiprimes")
    rng = random.Random(seed)
    good = [p for p in primes_up_to(400) if p % 4 == 1 and p > 3]
    cache: Dict[int, int] = {p: circle_weight(p) for p in good}

    pairs: List[Tuple[int, int]] = []
    seen = set()
    while len(pairs) < 40:
        p, q = sorted(rng.sample(good, 2))
        if (p, q) not in seen:
            seen.add((p, q))
            pairs.append((p, q))

    w_values = [cache[p] * cache[q] for p, q in pairs]
    covariates: Dict[str, Callable[[Tuple[int, int]], float]] = {
        "p (smaller factor)": lambda pq: float(pq[0]),
        "q (larger factor)": lambda pq: float(pq[1]),
        "p + q": lambda pq: float(pq[0] + pq[1]),
        "|p - q|": lambda pq: float(abs(pq[0] - pq[1])),
    }

    print(f"{'covariate':>20} {'|corr|':>9} {'null 95%':>10}   verdict")
    for name, fn in covariates.items():
        cov = [fn(pq) for pq in pairs]
        obs = abs(pearson(w_values, cov))
        thr = permutation_threshold(w_values, cov, trials, seed)
        verdict = "inside null (no signal)" if obs < thr else "EXCEEDS NULL"
        print(f"{name:>20} {obs:>9.3f} {thr:>10.3f}   {verdict}")

    print("\nAlso check the semiprime Weil floor |W(N)| <= 4 sqrt(N) on the sample:")
    worst = max((abs(w) / (4 * math.sqrt(p * q)), p, q, w)
                for (p, q), w in zip(pairs, w_values))
    ratio, p, q, w = worst
    print(f"    tightest case: N = {p} * {q} = {p*q}, W(N) = {w}, "
          f"|W(N)|/(4 sqrt N) = {ratio:.4f}")
    for (p, q), w in zip(pairs, w_values):
        assert w * w <= 16 * p * q


def main() -> None:
    print(__doc__)
    demo_collapse_identity()
    demo_multiplicativity()
    demo_vanishing_and_parity()
    demo_second_moment_and_weil()
    demo_jacobsthal_and_two_squares()
    demo_not_a_residue_dial()
    demo_blindness()
    demo_weil_floor_attainment()
    demo_decorrelation()
    banner("All assertions passed.")


if __name__ == "__main__":
    main()
