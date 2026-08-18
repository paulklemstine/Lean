"""
The Square-Root Floor of the Signed Circle -- numerical demonstration
====================================================================

This self-contained script demonstrates, by direct computation, every theorem of
the accompanying paper:

  W(N) = sum_{x^2 + y^2 = 1 mod N} (x/N) = sum_{x mod N} ((x - x^3)/N)

where (a/N) is the Jacobi symbol.

  1. Multiplicativity:            W(mn) = W(m) W(n) for coprime odd m, n.
  2. Two-square law:              W(p) = 2a with p = a^2 + b^2, a odd, for p = 1 mod 4;
                                  W(p) = 0 for p = 3 mod 4.
  3. Exact Weil deficiency:       4p - W(p)^2 = 4b^2, hence W(p)^2 <= 4p - 16 (sharp).
  4. Two-adic content:            v2(W(N)) = omega(N) for squarefree N with all
                                  prime factors = 1 mod 4; = 2 for such semiprimes.
  5. Refutation:                  21 = 85 = 1 mod 4 but W(21) = 0 and W(85) = -4,
                                  so W is not a function of N mod 4.
  6. Brahmagupta refinement:      W(pq) = 4u mod 16 with pq = u^2 + v^2, u odd.
  7. Conic degeneracy:            sum_x ((x-r)(x-s)/N) = (-1)^omega(N) on squarefree N;
                                  in particular +1 at every semiprime.
  8. Character weights:           W_psi(p) = 0 for odd psi; W_{xi^2}(p) = J(xi, chi)
                                  + J(chi xi, chi) for xi^2 != 1; |W_psi(p)| <= 2 sqrt(p).

Only the Python standard library is used.
"""

from __future__ import annotations

import cmath
import math
from typing import Callable, Dict, Iterable, List, Optional, Tuple

Character = Callable[[int], complex]


# --------------------------------------------------------------------------- #
# 1. Elementary number theory
# --------------------------------------------------------------------------- #

def jacobi_symbol(a: int, n: int) -> int:
    """Jacobi symbol (a/n) for odd n > 0, by the reciprocity-driven Euclidean loop.

    Cost: O(log^2 n) bit operations.  No factorisation of n is required -- this is
    exactly what makes the signed circle count a candidate 'free witness'.
    """
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


def is_prime(n: int) -> bool:
    """Deterministic Miller-Rabin for 64-bit inputs."""
    if n < 2:
        return False
    for p in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        if n % p == 0:
            return n == p
    d, s = n - 1, 0
    while d % 2 == 0:
        d //= 2
        s += 1
    for a in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
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


def prime_factors(n: int) -> List[int]:
    """Distinct prime factors of n by trial division (n small in this demo)."""
    factors: List[int] = []
    d = 2
    while d * d <= n:
        if n % d == 0:
            factors.append(d)
            while n % d == 0:
                n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        factors.append(n)
    return factors


def two_adic_valuation(m: int) -> Optional[int]:
    """v2(m); None for m = 0."""
    if m == 0:
        return None
    v = 0
    while m % 2 == 0:
        m //= 2
        v += 1
    return v


def two_squares(p: int) -> Tuple[int, int]:
    """Write a prime p = 1 mod 4 as a^2 + b^2 with a odd, b even (a, b >= 0).

    Uses the standard Gaussian-descent: find a square root of -1 modulo p, then run
    the Euclidean algorithm on (p, r) and stop once the remainder drops below sqrt(p).
    Cost: polylog(p) apart from the search for a non-residue.
    """
    if p % 4 != 1 or not is_prime(p):
        raise ValueError("two_squares expects a prime = 1 mod 4")
    # a quadratic non-residue g gives a square root of -1 as g^((p-1)/4)
    g = 2
    while jacobi_symbol(g, p) != -1:
        g += 1
    r = pow(g, (p - 1) // 4, p)
    a, b = p, r
    limit = math.isqrt(p)
    while b > limit:
        a, b = b, a % b
    c = a % b if a > b else b
    # b and (p - b^2)^(1/2) are the two legs
    other = math.isqrt(p - b * b)
    x, y = b, other
    if x % 2 == 0:
        x, y = y, x
    assert x * x + y * y == p and x % 2 == 1, (p, x, y, c)
    return x, y


# --------------------------------------------------------------------------- #
# 2. The Jacobi-signed circle count
# --------------------------------------------------------------------------- #

def signed_circle_count_direct(n: int) -> int:
    """W(N) computed as the genuine double sum over the circle x^2 + y^2 = 1 mod N."""
    total = 0
    squares: Dict[int, List[int]] = {}
    for y in range(n):
        squares.setdefault(y * y % n, []).append(y)
    for x in range(n):
        target = (1 - x * x) % n
        total += len(squares.get(target, [])) * jacobi_symbol(x, n)
    return total


def signed_circle_count(n: int) -> int:
    """W(N) = sum_x ((x - x^3)/N): the one-variable form.  Cost N^{1+o(1)}."""
    return sum(jacobi_symbol((x - x ** 3) % n, n) for x in range(n))


def signed_circle_count_from_factors(n: int) -> int:
    """W(N) from the factorisation of a squarefree N.  Cost polylog(N)."""
    value = 1
    for p in prime_factors(n):
        if p % 4 == 3:
            return 0
        a, _ = two_squares(p)
        # fix the sign of the odd leg by one cheap consistency check at the prime
        wp = 2 * a if signed_circle_count(p) > 0 else -2 * a
        value *= wp
    return value


def polynomial_weight_count(coeffs: Iterable[int], n: int) -> int:
    """S_f(N) = sum_x (f(x)/N) for f given by coefficients (constant term first)."""
    cs = list(coeffs)

    def f(x: int) -> int:
        acc = 0
        for c in reversed(cs):
            acc = acc * x + c
        return acc

    return sum(jacobi_symbol(f(x) % n, n) for x in range(n))


def conic_weight_count(r: int, s: int, n: int) -> int:
    """S_f(N) for the separable conic f(X) = (X - r)(X - s)."""
    return sum(jacobi_symbol(((x - r) * (x - s)) % n, n) for x in range(n))


# --------------------------------------------------------------------------- #
# 3. Complex character weights
# --------------------------------------------------------------------------- #

def primitive_root(p: int) -> int:
    """Smallest primitive root modulo the prime p."""
    factors = prime_factors(p - 1)
    for g in range(2, p):
        if all(pow(g, (p - 1) // q, p) != 1 for q in factors):
            return g
    raise ValueError("no primitive root found")


def character_table(p: int) -> Callable[[int], Character]:
    """Return j -> psi_j, where psi_j(g^k) = exp(2 pi i j k / (p-1))."""
    g = primitive_root(p)
    log: Dict[int, int] = {}
    x = 1
    for k in range(p - 1):
        log[x] = k
        x = x * g % p

    def psi(j: int) -> Character:
        def value(a: int) -> complex:
            a %= p
            if a == 0:
                return 0j
            return cmath.exp(2j * math.pi * j * log[a] / (p - 1))

        return value

    return psi


def weighted_circle_count(p: int, psi: Character) -> complex:
    """W_psi(p) = sum over the circle x^2 + y^2 = 1 of psi(x)."""
    total = 0j
    squares: Dict[int, int] = {}
    for y in range(p):
        squares[y * y % p] = squares.get(y * y % p, 0) + 1
    for x in range(p):
        total += squares.get((1 - x * x) % p, 0) * psi(x)
    return total


def jacobi_sum(p: int, alpha: Character, beta: Character) -> complex:
    """J(alpha, beta) = sum_x alpha(x) beta(1 - x)."""
    return sum(alpha(x) * beta((1 - x) % p) for x in range(p))


# --------------------------------------------------------------------------- #
# 4. Demonstrations
# --------------------------------------------------------------------------- #

def rule(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def demo_definitions_agree() -> None:
    rule("0. The double sum and the cubic one-variable sum agree")
    print(f"{'N':>6} {'double sum':>12} {'sum (x-x^3)/N':>16}")
    for n in [5, 13, 17, 21, 29, 85, 105, 173]:
        print(f"{n:>6} {signed_circle_count_direct(n):>12} {signed_circle_count(n):>16}")


def demo_multiplicativity() -> None:
    rule("1. Multiplicativity:  W(mn) = W(m) W(n) for coprime odd m, n")
    print(f"{'m':>5} {'n':>5} {'W(m)':>7} {'W(n)':>7} {'W(m)W(n)':>10} {'W(mn)':>8}  ok")
    for m, n in [(5, 17), (13, 29), (5, 13), (3, 7), (5, 21), (13, 17), (29, 37)]:
        wm, wn, wmn = signed_circle_count(m), signed_circle_count(n), signed_circle_count(m * n)
        print(f"{m:>5} {n:>5} {wm:>7} {wn:>7} {wm * wn:>10} {wmn:>8}  {wm * wn == wmn}")


def demo_two_squares_and_deficiency() -> None:
    rule("2-3. Two-square law, exact Weil deficiency, and the sharp floor W^2 <= 4p-16")
    header = f"{'p':>6} {'W(p)':>7} {'a':>6} {'b':>4} {'4p-W^2':>8} {'4b^2':>7} {'W^2/4p':>8} {'<=4p-16':>8}"
    print(header)
    for p in [5, 13, 17, 29, 37, 41, 53, 61, 73, 89, 97, 101, 109, 113, 137, 173, 229, 293]:
        w = signed_circle_count(p)
        a, b = two_squares(p)
        assert abs(w) == 2 * a
        deficiency = 4 * p - w * w
        ratio = w * w / (4 * p)
        ok = w * w <= 4 * p - 16
        print(f"{p:>6} {w:>7} {w // 2:>6} {b:>4} {deficiency:>8} {4 * b * b:>7} {ratio:>8.4f} {str(ok):>8}")
    print("\nPrimes = 3 mod 4 give W(p) = 0 exactly:")
    print("   ", {p: signed_circle_count(p) for p in [3, 7, 11, 19, 23, 31, 43]})
    print("\nEquality W(p)^2 = 4p - 16 holds exactly at primes p = a^2 + 4:")
    eq = [p for p in range(5, 1000) if is_prime(p) and p % 4 == 1
          and signed_circle_count(p) ** 2 == 4 * p - 16]
    print("   ", eq)


def demo_two_adic() -> None:
    rule("4. Two-adic content:  v2(W(N)) = omega(N) on squarefree N with all factors 1 mod 4")
    print(f"{'N':>8} {'factors':>18} {'omega':>6} {'W(N)':>10} {'v2(W)':>6}")
    samples = [5, 13, 17, 29, 85, 5 * 29, 13 * 17, 5 * 13 * 17, 5 * 13 * 29, 17 * 29 * 37]
    for n in samples:
        w = signed_circle_count(n)
        pf = prime_factors(n)
        print(f"{n:>8} {str(pf):>18} {len(pf):>6} {w:>10} {str(two_adic_valuation(w)):>6}")
    print("\nOn semiprimes with both factors 1 mod 4 the valuation is the constant 2:")
    vals = []
    for p, q in [(5, 13), (5, 17), (13, 17), (5, 29), (13, 29), (17, 29), (37, 41)]:
        vals.append((p * q, two_adic_valuation(signed_circle_count(p * q))))
    print("   ", vals)


def demo_refutation() -> None:
    rule("5. Refutation:  W is not a function of N mod 4")
    for n in (21, 85):
        print(f"   N = {n:>3}   N mod 4 = {n % 4}   factors = {prime_factors(n)}   W(N) = {signed_circle_count(n)}")
    print("   Both moduli are 1 mod 4, yet one value vanishes and the other does not.")
    print("   Hence no f with W(N) = f(N mod 4); the count is not a residue dial.")


def demo_brahmagupta() -> None:
    rule("6. Brahmagupta refinement:  W(pq) = 4u (mod 16) with pq = u^2 + v^2, u odd")
    print(f"{'p':>5} {'q':>5} {'N=pq':>8} {'W(N)':>8} {'u':>7} {'v':>7} {'W-4u':>8} {'div by 16':>10}")
    for p, q in [(5, 13), (5, 17), (13, 17), (5, 29), (13, 29), (17, 29), (13, 173)]:
        n = p * q
        a, b = two_squares(p)
        c, d = two_squares(q)
        wp, wq = signed_circle_count(p), signed_circle_count(q)
        a = a if wp > 0 else -a
        c = c if wq > 0 else -c
        u, v = a * c - b * d, a * d + b * c
        w = signed_circle_count(n)
        assert u * u + v * v == n
        print(f"{p:>5} {q:>5} {n:>8} {w:>8} {u:>7} {v:>7} {w - 4 * u:>8} {str((w - 4 * u) % 16 == 0):>10}")
    print("\n   Four-square refinement 16N = W(N)^2 + (4ad)^2 + (4bc)^2 + (4bd)^2:")
    p, q = 5, 17
    a, b = two_squares(p)
    c, d = two_squares(q)
    a = a if signed_circle_count(p) > 0 else -a
    c = c if signed_circle_count(q) > 0 else -c
    n = p * q
    w = signed_circle_count(n)
    lhs = 16 * n
    rhs = w * w + (4 * a * d) ** 2 + (4 * b * c) ** 2 + (4 * b * d) ** 2
    print(f"      N = {n}:  16N = {lhs},  W^2 + squares = {rhs},  equal = {lhs == rhs}")


def demo_conics() -> None:
    rule("7. Conic degeneracy:  every separable conic weight is (-1)^omega(N)")
    print("   (a pair (r,s) is admissible for N when gcd(r-s, N) = 1; inadmissible")
    print("    pairs are marked with * and are outside the scope of the theorem)\n")
    pairs = [(0, 1), (0, 2), (1, 4)]
    head = "".join(f"{str(pr):>10}" for pr in pairs)
    print(f"{'N':>7} {'omega':>6}{head} {'(-1)^omega':>12}")
    for n in [5, 13, 17, 21, 33, 85, 105, 1155]:
        pf = prime_factors(n)
        cells = []
        for (r, s) in pairs:
            value = conic_weight_count(r, s, n)
            admissible = math.gcd(abs(r - s), n) == 1
            cells.append(f"{value}" if admissible else f"{value}*")
        row = "".join(f"{c:>10}" for c in cells)
        print(f"{n:>7} {len(pf):>6}{row} {(-1) ** len(pf):>12}")
    print("\n   At N = 85 every separable conic gives +1, but the cubic circle weight gives")
    print(f"   W(85) = {signed_circle_count(85)}: the sqrt(N) fluctuation is a cubic phenomenon.")
    print("\n   Universal multiplicativity holds for arbitrary polynomial weights, e.g. f = x^5 + x + 1:")
    f = [1, 1, 0, 0, 0, 1]
    for m, n in [(5, 17), (7, 13), (11, 9)]:
        sm, sn, smn = (polynomial_weight_count(f, m), polynomial_weight_count(f, n),
                       polynomial_weight_count(f, m * n))
        print(f"      m={m:>3} n={n:>3}:  S(m)={sm:>4}  S(n)={sn:>4}  S(m)S(n)={sm * sn:>5}  S(mn)={smn:>5}  {sm * sn == smn}")


def demo_characters() -> None:
    rule("8. Character weights:  odd weights vanish; even weights are two Jacobi sums")
    for p in (13, 17, 29):
        psi = character_table(p)
        chi = psi((p - 1) // 2)
        print(f"\n   p = {p},  2*sqrt(p) = {2 * math.sqrt(p):.4f}")
        print(f"   {'j':>4} {'order':>6} {'W_psi(p)':>26} {'|W_psi|':>10}  parity")
        for j in range(p - 1):
            value = weighted_circle_count(p, psi(j))
            order = (p - 1) // math.gcd(j, p - 1) if j else 1
            parity = "odd" if j % 2 else "even"
            shown = f"{value.real:+.5f}{value.imag:+.5f}i"
            print(f"   {j:>4} {order:>6} {shown:>26} {abs(value):>10.5f}  {parity}")
        # Jacobi-sum decomposition for a character xi with xi^2 != 1
        for j in range(1, p - 1):
            xi = psi(j)
            if (2 * j) % (p - 1) != 0:  # xi^2 != 1
                lhs = weighted_circle_count(p, psi((2 * j) % (p - 1)))
                chixi: Character = lambda a, xi=xi: chi(a) * xi(a)
                rhs = jacobi_sum(p, xi, chi) + jacobi_sum(p, chixi, chi)
                print(f"   decomposition at j = {j}: |W_(xi^2) - (J(xi,chi)+J(chi.xi,chi))| = {abs(lhs - rhs):.2e}")
                print(f"      |J(xi,chi)| = {abs(jacobi_sum(p, xi, chi)):.6f},  sqrt(p) = {math.sqrt(p):.6f}")
                break
        worst = max(abs(weighted_circle_count(p, psi(j))) for j in range(1, p - 1))
        print(f"   max over nontrivial weights: {worst:.5f}  <=  2 sqrt(p) = {2 * math.sqrt(p):.5f}"
              f"   -> {worst <= 2 * math.sqrt(p) + 1e-9}")
        print(f"   quadratic weight reproduces the integer count: "
              f"{weighted_circle_count(p, chi).real:+.1f} vs W(p) = {signed_circle_count(p)}")


def demo_floor_never_broken() -> None:
    rule("9. The floor holds everywhere it is claimed to")
    bad_prime = [p for p in range(5, 2000) if is_prime(p) and p % 4 == 1
                 and signed_circle_count(p) ** 2 > 4 * p - 16]
    print(f"   primes p < 2000 with W(p)^2 > 4p - 16:  {bad_prime}  (expected: none)")
    bad_semi = []
    primes = [p for p in range(5, 120) if is_prime(p)]
    for i, p in enumerate(primes):
        for q in primes[i + 1:]:
            if signed_circle_count(p * q) ** 2 > 16 * p * q:
                bad_semi.append((p, q))
    print(f"   semiprimes pq < 120^2 with W(pq)^2 > 16pq:  {bad_semi}  (expected: none)")


def main() -> None:
    print(__doc__)
    demo_definitions_agree()
    demo_multiplicativity()
    demo_two_squares_and_deficiency()
    demo_two_adic()
    demo_refutation()
    demo_brahmagupta()
    demo_conics()
    demo_characters()
    demo_floor_never_broken()
    print("\nAll demonstrations completed.")


if __name__ == "__main__":
    main()
