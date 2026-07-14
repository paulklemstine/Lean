"""Numerical demonstrations for the sharp/flat supersingular degree sequences.

This self-contained script illustrates, for arbitrary primes ``p``, the five
arithmetic results governing the growth of the sharp and flat characteristic
degrees of a supersingular elliptic curve along its cyclotomic tower:

    1. Generalised Jacobsthal closed form:   (p+1) q_n = p^n - (-1)^n
    2. Consecutive-sum law:                  q_n + q_{n+1} = p^n
    3. Base-p^2 flat-degree closed form:     (p^2-1) flatDeg_p(n) + 1 = p^{2n}
    4. Sharp/flat ratio:                      sharpDeg_p(n) = p * flatDeg_p(n)
    5. Bridge:                                q_{2n} = (p-1) flatDeg_p(n)

Running the file checks every identity numerically over a range of primes and
levels and prints a formatted report.
"""

from __future__ import annotations


def qgen(p: int, n: int) -> int:
    """Generalised Jacobsthal number q_n for the recurrence

        q_0 = 0,  q_1 = 1,  q_{n+2} = (p-1) q_{n+1} + p q_n.

    At p = 2 this is the classical Jacobsthal sequence 0,1,1,3,5,11,21,...
    """
    if n == 0:
        return 0
    if n == 1:
        return 1
    prev, cur = 0, 1
    for _ in range(2, n + 1):
        prev, cur = cur, (p - 1) * cur + p * prev
    return cur


def qgen_closed(p: int, n: int) -> int:
    """The closed-form value (p^n - (-1)^n) // (p+1), equal to q_n."""
    return (p ** n - (-1) ** n) // (p + 1)


def flat_deg(p: int, n: int) -> int:
    """Flat characteristic degree: sum_{i<n} p^(2i) (base-p^2 partial sum)."""
    return sum(p ** (2 * i) for i in range(n))


def sharp_deg(p: int, n: int) -> int:
    """Sharp characteristic degree: sum_{i<n} p^(2i+1)."""
    return sum(p ** (2 * i + 1) for i in range(n))


def check_closed_form(p: int, n_max: int) -> bool:
    """Verify (p+1) q_n = p^n - (-1)^n for 0 <= n <= n_max."""
    return all(
        (p + 1) * qgen(p, n) == p ** n - (-1) ** n for n in range(n_max + 1)
    )


def check_consecutive_sum(p: int, n_max: int) -> bool:
    """Verify q_n + q_{n+1} = p^n for 0 <= n <= n_max."""
    return all(qgen(p, n) + qgen(p, n + 1) == p ** n for n in range(n_max + 1))


def check_flat_closed(p: int, n_max: int) -> bool:
    """Verify (p^2-1) flatDeg_p(n) + 1 = p^(2n) for 0 <= n <= n_max."""
    return all(
        (p ** 2 - 1) * flat_deg(p, n) + 1 == p ** (2 * n)
        for n in range(n_max + 1)
    )


def check_sharp_flat_ratio(p: int, n_max: int) -> bool:
    """Verify sharpDeg_p(n) = p * flatDeg_p(n) for 0 <= n <= n_max."""
    return all(sharp_deg(p, n) == p * flat_deg(p, n) for n in range(n_max + 1))


def check_bridge(p: int, n_max: int) -> bool:
    """Verify q_{2n} = (p-1) flatDeg_p(n) for 0 <= n <= n_max."""
    return all(qgen(p, 2 * n) == (p - 1) * flat_deg(p, n) for n in range(n_max + 1))


def report(primes: list[int], n_max: int = 8) -> None:
    """Print a full verification report over the given primes."""
    print("=" * 68)
    print("Sharp/flat supersingular degree sequences — numerical report")
    print("=" * 68)

    print("\nGeneralised Jacobsthal sequences q_0..q_9:")
    for p in primes:
        seq = [qgen(p, n) for n in range(10)]
        print(f"  p = {p:>2}: {seq}")

    print("\nFlat / sharp degrees flatDeg_p(n), sharpDeg_p(n) for n = 0..6:")
    for p in primes:
        flats = [flat_deg(p, n) for n in range(7)]
        sharps = [sharp_deg(p, n) for n in range(7)]
        print(f"  p = {p:>2}: flat  {flats}")
        print(f"        sharp {sharps}")

    print("\nBridge  q_{2n} = (p-1)*flatDeg_p(n)  for n = 0..5:")
    for p in primes:
        lhs = [qgen(p, 2 * n) for n in range(6)]
        rhs = [(p - 1) * flat_deg(p, n) for n in range(6)]
        print(f"  p = {p:>2}: q_2n {lhs}  ==  (p-1)flat {rhs}  -> {lhs == rhs}")

    print("\nIdentity checks (all must be True):")
    checks = [
        ("closed form   (p+1)q_n = p^n-(-1)^n", check_closed_form),
        ("consec. sum   q_n+q_{n+1} = p^n     ", check_consecutive_sum),
        ("flat closed   (p^2-1)flat+1 = p^2n  ", check_flat_closed),
        ("sharp/flat    sharp = p*flat        ", check_sharp_flat_ratio),
        ("bridge        q_2n = (p-1)flat      ", check_bridge),
    ]
    for p in primes:
        results = [fn(p, n_max) for _, fn in checks]
        print(f"  p = {p:>2}: {all(results)}  ({[r for r in results]})")

    print("\nConsistency: qgen == qgen_closed for p in primes, n = 0..12:")
    ok = all(
        qgen(p, n) == qgen_closed(p, n) for p in primes for n in range(13)
    )
    print(f"  {ok}")

    print("\nSpecialisation p = 2: even Jacobsthal numbers equal flat degrees")
    even_j = [qgen(2, 2 * n) for n in range(7)]
    flats2 = [flat_deg(2, n) for n in range(7)]
    print(f"  q_2n      = {even_j}")
    print(f"  flatDeg_2 = {flats2}")
    print(f"  equal? {even_j == flats2}")
    print("=" * 68)


if __name__ == "__main__":
    report(primes=[2, 3, 5, 7, 11], n_max=10)
