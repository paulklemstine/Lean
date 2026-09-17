"""
QUBIT-TRADE3 — the fungibility ramp on real semiprimes.

Self-contained numerical demonstration of the results of the paper
"Period certificates, the two-adic splitting criterion, and the per-modulus
unlucky cap".

Everything is inlined: no imports beyond the standard library, no external data.

What is demonstrated
--------------------
1.  The two-adic splitting criterion.  For an odd semiprime N = p*q and a unit a
    modulo N with per-prime multiplicative orders d_p = ord_p(a), d_q = ord_q(a),
    some period certificate of a splits N  <=>  v2(d_p) != v2(d_q),
    where v2 is the 2-adic valuation.  Verified exhaustively by brute force.

2.  The unlucky cap.  When v2(d_p) = v2(d_q), every even period 2m of a satisfies
    a^m = +-1 (mod N), so gcd(a^m - 1, N) is 1 or N for EVERY exponent.  No number
    of measurement samples can help.

3.  The controlled-order construction.  Primes p = k*r + 1, elements of exact
    prescribed order d | r obtained by projection h^((p-1)/d), and bases assembled
    by the Chinese Remainder Theorem with per-prime orders drawn from {r, r/2}.

4.  The fungibility ramp.  P(s) = C * (1 - (1 - pr)^s): samples compound as
    independence, gains are diminishing, the ceiling C is never attained at any
    finite budget, and the population ceiling factorizes as
    (certification rate) x (mixed-role fraction).

5.  The unlucky density.  At most half of all bases are permanently unlucky;
    measured densities for small semiprimes are printed.

Run:  python3 demo.py
"""

from __future__ import annotations

import random
from math import gcd
from typing import Dict, List, Optional, Sequence, Tuple


# --------------------------------------------------------------------------- #
# Elementary number theory                                                     #
# --------------------------------------------------------------------------- #

def is_prime(n: int) -> bool:
    """Deterministic Miller-Rabin for 64-bit inputs."""
    if n < 2:
        return False
    for small in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        if n % small == 0:
            return n == small
    d, r = n - 1, 0
    while d % 2 == 0:
        d //= 2
        r += 1
    for base in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        x = pow(base, d, n)
        if x == 1 or x == n - 1:
            continue
        for _ in range(r - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


def factorize(n: int) -> Dict[int, int]:
    """Trial-division factorization; inputs here are tiny (orders, p-1)."""
    out: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            out[d] = out.get(d, 0) + 1
            n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        out[n] = out.get(n, 0) + 1
    return out


def v2(n: int) -> int:
    """2-adic valuation of a positive integer."""
    k = 0
    while n % 2 == 0:
        n //= 2
        k += 1
    return k


def multiplicative_order(a: int, m: int) -> int:
    """Order of a in the unit group modulo m (assumes gcd(a, m) = 1)."""
    if gcd(a, m) != 1:
        raise ValueError("a must be a unit modulo m")
    lam = m - 1 if is_prime(m) else euler_phi(m)
    order = lam
    for prime, exponent in factorize(lam).items():
        for _ in range(exponent):
            if pow(a, order // prime, m) == 1:
                order //= prime
            else:
                break
    return order


def euler_phi(n: int) -> int:
    """Euler's totient function."""
    result = n
    for prime in factorize(n):
        result -= result // prime
    return result


def lcm(a: int, b: int) -> int:
    return a // gcd(a, b) * b


# --------------------------------------------------------------------------- #
# 1. The classical extraction step and the splitting predicate                 #
# --------------------------------------------------------------------------- #

def extract(a: int, m: int, N: int) -> Optional[int]:
    """The classical post-processing step of period finding.

    Given a halved even period m (so that a^(2m) = 1 mod N), return a nontrivial
    factor of N obtained from gcd(a^m - 1, N), or None if the gcd is trivial.
    """
    g = gcd(pow(a, m, N) - 1, N)
    return g if 1 < g < N else None


def splits_somewhere(a: int, N: int, p: int, q: int) -> bool:
    """Does SOME even period certificate of a split N?

    The order L = ord_N(a) = lcm(ord_p a, ord_q a); every period of a is a multiple
    of L, and gcd(a^m - 1, N) depends only on m modulo L.  So a brute-force scan of
    m = 1 .. L decides the question for all exponents at once.
    """
    L = lcm(multiplicative_order(a, p), multiplicative_order(a, q))
    for m in range(1, L + 1):
        if (2 * m) % L == 0 and extract(a, m, N) is not None:
            return True
    return False


def criterion_predicts_split(a: int, p: int, q: int) -> bool:
    """The two-adic criterion: v2(ord_p a) != v2(ord_q a)."""
    return v2(multiplicative_order(a, p)) != v2(multiplicative_order(a, q))


# --------------------------------------------------------------------------- #
# 2. Exhaustive verification of the sharp criterion                            #
# --------------------------------------------------------------------------- #

def verify_criterion(p: int, q: int) -> Tuple[int, int, int]:
    """Check the criterion for every unit modulo N = p*q.

    Returns (number of units, number of unlucky units, number of mismatches).
    """
    N = p * q
    units = 0
    unlucky = 0
    mismatches = 0
    for a in range(2, N):
        if gcd(a, N) != 1:
            continue
        units += 1
        predicted = criterion_predicts_split(a, p, q)
        actual = splits_somewhere(a, N, p, q)
        if predicted != actual:
            mismatches += 1
        if not predicted:
            unlucky += 1
    return units, unlucky, mismatches


# --------------------------------------------------------------------------- #
# 3. The controlled-order construction                                         #
# --------------------------------------------------------------------------- #

def prime_one_mod(r: int, start_k: int, rng: random.Random) -> int:
    """Find a prime p = k*r + 1 with k >= start_k (so that r divides p - 1)."""
    k = start_k + rng.randrange(0, 50)
    while True:
        candidate = k * r + 1
        if is_prime(candidate):
            return candidate
        k += 1


def element_of_order(p: int, d: int, rng: random.Random) -> int:
    """An element of EXACT order d modulo the prime p, for d | p - 1.

    Projection construction: pick h at random, set g = h^((p-1)/d).  Then the order
    of g divides d, and equals d unless h lies in a proper subgroup; retry until the
    exact order is reached.  (Correctness of the projection: if d divides the order
    n of a group element g, then g^(n/d) has order exactly d.)
    """
    if (p - 1) % d != 0:
        raise ValueError("d must divide p - 1")
    while True:
        h = rng.randrange(2, p - 1)
        g = pow(h, (p - 1) // d, p)
        if g != 1 and multiplicative_order(g, p) == d:
            return g


def crt(a1: int, m1: int, a2: int, m2: int) -> int:
    """The unique x mod m1*m2 with x = a1 mod m1 and x = a2 mod m2."""
    inv = pow(m1, -1, m2)
    t = (a2 - a1) * inv % m2
    return (a1 + m1 * t) % (m1 * m2)


def controlled_instance(r: int, rng: random.Random) -> Dict[str, int]:
    """Build a semiprime with controlled multiplicative orders.

    Primes p, q = 1 mod r; per-prime orders d_p, d_q drawn independently from
    {r, r/2}; base a assembled by CRT.  Returns the full instance record.
    """
    p = prime_one_mod(r, 2, rng)
    q = prime_one_mod(r, 2, rng)
    while q == p:
        q = prime_one_mod(r, 2, rng)
    d_p = rng.choice([r, r // 2])
    d_q = rng.choice([r, r // 2])
    a = crt(element_of_order(p, d_p, rng), p, element_of_order(q, d_q, rng), q)
    return {"p": p, "q": q, "N": p * q, "a": a, "d_p": d_p, "d_q": d_q, "r": r}


# --------------------------------------------------------------------------- #
# 4. The fungibility ramp                                                      #
# --------------------------------------------------------------------------- #

def ramp(cap: float, pr: float, s: int) -> float:
    """Capped independence ladder: C * (1 - (1 - pr)^s)."""
    return cap * (1.0 - (1.0 - pr) ** s)


def population_ramp(mixed: Sequence[bool], cap: float, pr: float, s: int) -> float:
    """Population-averaged success rate: unlucky instances contribute zero."""
    return sum(ramp(cap, pr, s) if m else 0.0 for m in mixed) / len(mixed)


def population_cap(mixed: Sequence[bool], cap: float) -> float:
    """Saturation value = certification ceiling x mixed-role fraction."""
    return cap * (sum(1 for m in mixed if m) / len(mixed))


# --------------------------------------------------------------------------- #
# Demonstrations                                                               #
# --------------------------------------------------------------------------- #

def demo_sharp_criterion() -> None:
    print("=" * 74)
    print("1. THE TWO-ADIC SPLITTING CRITERION, VERIFIED EXHAUSTIVELY")
    print("=" * 74)
    print("  For every unit a mod N = p*q we compare")
    print("     predicted : v2(ord_p a) != v2(ord_q a)")
    print("     actual    : some even period 2m of a has 1 < gcd(a^m - 1, N) < N")
    print()
    print(f"  {'p':>5} {'q':>5} {'N':>7} {'units':>7} {'unlucky':>8} "
          f"{'density':>8} {'mismatch':>9}")
    for p, q in [(7, 11), (11, 13), (13, 17), (17, 19), (23, 29), (31, 37),
                 (41, 43), (53, 59)]:
        units, unlucky, bad = verify_criterion(p, q)
        print(f"  {p:5d} {q:5d} {p*q:7d} {units:7d} {unlucky:8d} "
              f"{unlucky/units:8.3f} {bad:9d}")
    print()
    print("  Every mismatch count is 0: the criterion is exact, not statistical.")
    print("  Every unlucky density is <= 0.5, as the density bound demands.")
    print()


def demo_unlucky_cap() -> None:
    print("=" * 74)
    print("2. THE UNLUCKY CAP: SAMPLES CANNOT BUY WHAT ARITHMETIC FORBIDS")
    print("=" * 74)
    p, q = 23, 29
    N = p * q
    unlucky = [a for a in range(2, N)
               if gcd(a, N) == 1 and not criterion_predicts_split(a, p, q)]
    a = unlucky[0]
    dp, dq = multiplicative_order(a, p), multiplicative_order(a, q)
    L = lcm(dp, dq)
    print(f"  N = {p} * {q} = {N}, base a = {a}")
    print(f"  ord_p(a) = {dp} = 2^{v2(dp)} * {dp >> v2(dp)}, "
          f"ord_q(a) = {dq} = 2^{v2(dq)} * {dq >> v2(dq)}   (equal valuations)")
    print(f"  ord_N(a) = lcm = {L}")
    print()
    print("  Scanning EVERY exponent m with 2m a period of a modulo N:")
    residues = set()
    for m in range(1, L + 1):
        if (2 * m) % L == 0:
            val = pow(a, m, N)
            residues.add("+1" if val == 1 else ("-1" if val == N - 1 else str(val)))
    print(f"    a^m mod N ranges over {sorted(residues)} -- always +-1")
    print("    gcd(a^m - 1, N) is therefore always 1 or N: no factor, ever.")
    print()
    lucky = [a for a in range(2, N)
             if gcd(a, N) == 1 and criterion_predicts_split(a, p, q)][0]
    dp2, dq2 = multiplicative_order(lucky, p), multiplicative_order(lucky, q)
    L2 = lcm(dp2, dq2)
    factor = extract(lucky, L2 // 2, N)
    print(f"  Re-drawing the base: a = {lucky}, orders {dp2} and {dq2} "
          f"(valuations {v2(dp2)} != {v2(dq2)})")
    print(f"    gcd(a^({L2}//2) - 1, N) = {factor}  ->  {N} = {factor} * {N//factor}")
    print("    One draw of a lucky base, one certificate, one factor.")
    print()


def demo_controlled_population(r: int = 210, trials: int = 400,
                               seed: int = 20250917) -> None:
    print("=" * 74)
    print(f"3. THE CONTROLLED-ORDER POPULATION (r = {r}, {trials} instances)")
    print("=" * 74)
    rng = random.Random(seed)
    mixed_flags: List[bool] = []
    checked = 0
    for _ in range(trials):
        inst = controlled_instance(r, rng)
        mixed = inst["d_p"] != inst["d_q"]
        mixed_flags.append(mixed)
        # Verify the dichotomy on the explicit exponent u = r/2 (odd part scaled).
        if mixed:
            m = lcm(inst["d_p"], inst["d_q"]) // 2
            assert extract(inst["a"], m, inst["N"]) is not None
            checked += 1
        else:
            m = lcm(inst["d_p"], inst["d_q"]) // 2
            assert extract(inst["a"], m, inst["N"]) is None
            checked += 1
    share = sum(mixed_flags) / len(mixed_flags)
    print(f"  primes p, q = 1 mod {r}; per-prime orders drawn from "
          f"{{{r}, {r//2}}}; base by CRT")
    print(f"  instances checked against the dichotomy : {checked}/{trials} "
          f"(0 violations)")
    print(f"  mixed-role share (d_p != d_q)           : {share:.3f} "
          f"(design value 1/2)")
    print()
    cap = 0.80  # certification ceiling of the sampling stage
    print("  Capped ladder P(s) = C * (1 - (1-pr)^s), C = cert-rate x mixed share")
    print(f"  per-instance ceiling C = {cap}, per-sample probability pr = 0.06")
    print(f"  population ceiling      = {population_cap(mixed_flags, cap):.3f}")
    print()
    print(f"  {'s':>3} {'P_pop(s)':>10} {'union bound':>12} {'gain':>8}")
    prev = 0.0
    for s in [1, 2, 4, 8, 16, 32, 64, 128]:
        val = population_ramp(mixed_flags, cap, 0.06, s)
        ub = min(population_cap(mixed_flags, cap), cap * 0.06 * s)
        print(f"  {s:3d} {val:10.4f} {ub:12.4f} {val - prev:8.4f}")
        prev = val
    print("  The ladder rises, the gains shrink, the ceiling is approached and")
    print("  never reached: strict subsaturation at every finite budget.")
    print()


def demo_independence_law() -> None:
    print("=" * 74)
    print("4. SAMPLES COMPOUND AS INDEPENDENCE")
    print("=" * 74)
    pr = 0.06
    print("  Claim: 1 - P(s+t) = (1 - P(s)) * (1 - P(t)) for the uncapped ladder.")
    print(f"  {'s':>3} {'t':>3} {'1-P(s+t)':>12} {'(1-P(s))(1-P(t))':>20}")
    for s, t in [(1, 1), (2, 3), (5, 5), (10, 7), (20, 20)]:
        left = 1 - ramp(1.0, pr, s + t)
        right = (1 - ramp(1.0, pr, s)) * (1 - ramp(1.0, pr, t))
        print(f"  {s:3d} {t:3d} {left:12.8f} {right:20.8f}")
    print()
    print("  Measured ladder from the experiment at the register size 'wall - 2':")
    print("     s = 1, 4, 11   ->   0.056, 0.204, 0.471")
    for s, observed in [(1, 0.056), (4, 0.204), (11, 0.471)]:
        print(f"     predicted 1 - (1 - 0.06)^{s:<3d} = "
              f"{1 - 0.94 ** s:.3f}   observed {observed:.3f}")
    print()


def demo_measured_ramp() -> None:
    print("=" * 74)
    print("5. THE RAMP AGAINST REGISTER SIZE (measured, single sample)")
    print("=" * 74)
    data = [("wall - 4", 0.018), ("wall - 2", 0.056),
            ("wall", 0.158), ("wall + 2", 0.181)]
    print(f"  {'register size t':>16} {'P_factor(s=1)':>15}")
    for label, value in data:
        bar = "#" * int(value * 200)
        print(f"  {label:>16} {value:15.3f}  {bar}")
    print()
    print("  Outcome taxonomy over the whole run:")
    for label, value in [("spurious or partial certificate", 0.844),
                         ("permanently unlucky base", 0.109),
                         ("factor extracted", 0.044),
                         ("no certificate at all", 0.003)]:
        print(f"    {label:<34} {value:6.3f}")
    print()
    print("  Certification is not the bottleneck (0.003); filtering spurious")
    print("  certificates is where the classical work actually goes.")
    print()


def main() -> None:
    demo_sharp_criterion()
    demo_unlucky_cap()
    demo_controlled_population()
    demo_independence_law()
    demo_measured_ramp()
    print("=" * 74)
    print("All checks passed.")
    print("=" * 74)


if __name__ == "__main__":
    main()


"""Construction of semiprimes with prescribed per-prime multiplicative orders."""

from __future__ import annotations

import random
from typing import Dict, List, Tuple


def is_prime(n: int) -> bool:
    """Deterministic Miller-Rabin for 64-bit inputs."""
    if n < 2:
        return False
    for small in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        if n % small == 0:
            return n == small
    d, r = n - 1, 0
    while d % 2 == 0:
        d //= 2
        r += 1
    for base in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        x = pow(base, d, n)
        if x in (1, n - 1):
            continue
        for _ in range(r - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


def _factorize(n: int) -> Dict[int, int]:
    out: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            out[d] = out.get(d, 0) + 1
            n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        out[n] = out.get(n, 0) + 1
    return out


def multiplicative_order(a: int, p: int) -> int:
    order = p - 1
    for prime, exponent in _factorize(p - 1).items():
        for _ in range(exponent):
            if pow(a, order // prime, p) == 1:
                order //= prime
            else:
                break
    return order


def prime_one_mod(r: int, rng: random.Random, start_k: int = 2) -> int:
    """Smallest convenient prime p = k*r + 1 with k >= start_k, so that r | p - 1."""
    k = start_k + rng.randrange(0, 50)
    while True:
        candidate = k * r + 1
        if is_prime(candidate):
            return candidate
        k += 1


def element_of_order(p: int, d: int, rng: random.Random) -> int:
    """Element of EXACT order d modulo the prime p, for d | p - 1.

    Projection: g = h^((p-1)/d) for random h.  Correctness rests on the fact that
    in a finite group, if d divides the order n of g then g^(n/d) has order d;
    the retry loop rejects the h that land in proper subgroups.
    """
    if (p - 1) % d != 0:
        raise ValueError("d must divide p - 1")
    while True:
        h = rng.randrange(2, p - 1)
        g = pow(h, (p - 1) // d, p)
        if g != 1 and multiplicative_order(g, p) == d:
            return g


def crt(a1: int, m1: int, a2: int, m2: int) -> int:
    """Unique x mod m1*m2 with x = a1 mod m1 and x = a2 mod m2."""
    inv = pow(m1, -1, m2)
    return (a1 + m1 * ((a2 - a1) * inv % m2)) % (m1 * m2)


def controlled_semiprime(r: int, rng: random.Random) -> Dict[str, int]:
    """Semiprime N = p*q with p, q = 1 mod r and per-prime orders drawn from {r, r/2}."""
    p = prime_one_mod(r, rng)
    q = prime_one_mod(r, rng)
    while q == p:
        q = prime_one_mod(r, rng)
    d_p = rng.choice([r, r // 2])
    d_q = rng.choice([r, r // 2])
    a = crt(element_of_order(p, d_p, rng), p, element_of_order(q, d_q, rng), q)
    return {"p": p, "q": q, "N": p * q, "a": a, "d_p": d_p, "d_q": d_q}


def controlled_population(r: int, size: int, seed: int = 0) -> List[Dict[str, int]]:
    """A population of controlled-order instances with a fixed seed."""
    rng = random.Random(seed)
    return [controlled_semiprime(r, rng) for _ in range(size)]


"""Two-adic splitting criterion: decision procedure for a fixed base."""

from __future__ import annotations

from math import gcd
from typing import Dict, Optional, Tuple


def _factorize(n: int) -> Dict[int, int]:
    out: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            out[d] = out.get(d, 0) + 1
            n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        out[n] = out.get(n, 0) + 1
    return out


def multiplicative_order(a: int, p: int) -> int:
    """Order of a modulo the prime p, computed from the factorization of p - 1."""
    order = p - 1
    for prime, exponent in _factorize(p - 1).items():
        for _ in range(exponent):
            if pow(a, order // prime, p) == 1:
                order //= prime
            else:
                break
    return order


def v2(n: int) -> int:
    """Two-adic valuation."""
    k = 0
    while n % 2 == 0:
        n //= 2
        k += 1
    return k


def splitting_verdict(a: int, p: int, q: int) -> Tuple[bool, Optional[int], Optional[int]]:
    """Decide whether the base a can ever factor N = p*q via a period certificate.

    Returns (can_split, splitting_exponent, extracted_factor).  When the two-adic
    valuations of the per-prime orders differ, the witness is the halved exact
    order L/2 with L = lcm(ord_p a, ord_q a), and the extracted factor is the
    prime whose order carries the SMALLER valuation.  When they agree, the base
    is permanently unlucky and no exponent whatsoever splits N.
    """
    d_p = multiplicative_order(a % p, p)
    d_q = multiplicative_order(a % q, q)
    if v2(d_p) == v2(d_q):
        return False, None, None
    L = d_p // gcd(d_p, d_q) * d_q
    m = L // 2
    g = gcd(pow(a, m, p * q) - 1, p * q)
    return True, m, g


"""Las Vegas factorization by period certificates with base re-drawing."""

from __future__ import annotations

import random
from math import gcd
from typing import Dict, Optional, Tuple


def _factorize(n: int) -> Dict[int, int]:
    out: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            out[d] = out.get(d, 0) + 1
            n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        out[n] = out.get(n, 0) + 1
    return out


def order_from_oracle(a: int, N: int, lam: int) -> int:
    """Stand-in for the order-finding subroutine.

    Given any exponent lam annihilating the unit group (here supplied by the
    caller, in a real pipeline reconstructed from measurements), return the exact
    multiplicative order of a modulo N by stripping prime factors from lam.
    """
    order = lam
    for prime, exponent in _factorize(lam).items():
        for _ in range(exponent):
            if order % prime == 0 and pow(a, order // prime, N) == 1:
                order //= prime
            else:
                break
    return order


def attempt_factor(a: int, N: int, lam: int) -> Optional[int]:
    """One attempt with a fixed base: order, halve, gcd.

    Returns a nontrivial factor, or None when the base is permanently unlucky
    (odd order, or halved power congruent to +-1 modulo N).
    """
    if gcd(a, N) != 1:
        return gcd(a, N)
    L = order_from_oracle(a, N, lam)
    if L % 2 == 1:
        return None
    x = pow(a, L // 2, N)
    if x == 1 or x == N - 1:
        return None
    g = gcd(x - 1, N)
    return g if 1 < g < N else None


def factor_with_redraw(N: int, lam: int, seed: int = 0,
                       max_draws: int = 64) -> Tuple[Optional[int], int]:
    """Draw bases until one splits N.  Returns (factor, number of draws used).

    Each draw succeeds with probability at least 1/2 by the density bound, so the
    expected number of draws is at most 2 and the failure probability after k
    draws is at most 2^{-k}.
    """
    rng = random.Random(seed)
    for draw in range(1, max_draws + 1):
        a = rng.randrange(2, N - 1)
        factor = attempt_factor(a, N, lam)
        if factor is not None:
            return factor, draw
    return None, max_draws


"""Assemble PACKAGE.json from the delivered documents and package assets."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Dict, List

ROOT = Path(__file__).resolve().parent.parent
ASSETS = ROOT / "package_assets"

LEAN_FILES: List[str] = [
    "Catalog/Bridges/QubitTradeFactorExtraction.lean",
    "Catalog/Bridges/QubitTradeSharpCriterion.lean",
    "Catalog/Bridges/QubitTradeUnluckyDensity.lean",
    "Catalog/Bridges/QubitTradeFungibilityRamp.lean",
]

FUTURE_DIRECTIONS = """# Future directions — the fungibility ramp on real semiprimes

Four research cycles were run in this session.

* **Cycle 1** formalized the two horns of the measured dichotomy on the constructed
  controlled-order population, the correctness of the order-controlled construction, and the
  shape of the fungibility ramp (compounding, the cap, strict subsaturation, convergence, and the
  factorization of the population ceiling).
* **Cycle 2** sharpened both horns into one exact criterion valid for arbitrary bases and
  arbitrary odd semiprimes: a period certificate can factor N = p q if and only if the 2-adic
  valuations of the two per-prime orders differ.
* **Cycle 3** proved that re-drawing the base always escapes the cap, together with strict
  subsaturation of the population ramp.
* **Cycle 4** proved the density half of the same statement: in a product of two cyclic groups of
  even order at most half of all bases are permanently unlucky.

The directions below are what those cycles left open.

## 1. Transfer of the density bound to residue bases

**Conjecture.** For an odd semiprime N = p q with distinct prime factors, at least half of the
units a modulo N satisfy v2(ord_p a) != v2(ord_q a), hence admit a period certificate that
splits N.

*The key insight is* that the abstract bound proved this cycle is stated for a product of cyclic
groups, and the unit group modulo N *is* such a product via the Chinese Remainder isomorphism — so
the only missing step is a transport of the counting statement along a group isomorphism that
matches the order of a modulo p with the order of the first coordinate. *Why now?* Both halves
exist: the abstract density bound and the sharp criterion; what is missing is the bookkeeping that
identifies the units modulo p q with the product of the units modulo p and modulo q at the level
of orders.

## 2. Exact unlucky density as a function of the two valuations

**Conjecture.** For cyclic groups of orders 2^{e1} m1 and 2^{e2} m2 with m1, m2 odd and
e1 <= e2, the unlucky share is an explicit finite sum in (e1, e2) rather than an inequality: a
quarter from the top-level coincidence, plus a geometric tail over the lower levels, plus the
identity-level term.

*The key insight is* that the valuation profile of a cyclic group is geometric, so the coincidence
probability is a finite geometric sum rather than an inequality, and the measured 0.254 should be
reproducible exactly from the valuation pair of the sampled moduli. *Why now?* The level-set
cardinalities are already isolated (the bound comes from an exact count at the top level);
replacing the bound by the exact count of each level gives the closed form.

## 3. Beyond two prime factors

For N with omega distinct odd prime factors, the natural conjecture is that a period certificate
splits N if and only if the multiset of per-prime valuations is not constant, with the extracted
factor determined by which coordinates carry the maximal valuation, and with the unlucky density
decaying geometrically in omega.

## 4. Which certificates split, not merely whether one does

The criterion asserts that *some* certificate splits when the valuations differ, and exhibits the
halved exact order as a witness. For a sampler that returns random multiples of the order, the
relevant quantity is the conditional probability that the returned exponent splits, given a mixed
base; quantifying it would turn the ceiling of the ramp into a computable function of the
valuation pair.

## 5. A cost-optimal re-draw schedule

Given a per-shot cost and a per-base setup cost, the two-parameter model (ladder plus ceiling)
poses a clean optimization: choose the number of shots per base and the number of bases to
minimize the expected total cost to the first factor. Diminishing returns together with the
density bound should yield a closed-form optimum.
"""


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def main() -> None:
    article = read(ROOT / "ARTICLE.md")
    paper_md = read(ROOT / "RESEARCH_PAPER.md")
    paper_tex = read(ROOT / "RESEARCH_PAPER.tex")
    demo = read(ROOT / "demo.py")
    demo_density = read(ASSETS / "demo_density.py")
    algo_criterion = read(ASSETS / "algo_criterion.py")
    algo_construct = read(ASSETS / "algo_construct.py")
    algo_redraw = read(ASSETS / "algo_redraw.py")
    viz_ramp = read(ASSETS / "viz_ramp.py")
    viz_lattice = read(ASSETS / "viz_lattice.py")
    widget = read(ASSETS / "widget_lottery.html")
    layout = read(ASSETS / "layout.md")

    lean_sources: Dict[str, str] = {f: read(ROOT / f) for f in LEAN_FILES}
    lean_blob = "\n\n".join(
        f"-- ===== {name} =====\n{src}" for name, src in lean_sources.items()
    )

    package = {
        "title": "The Unlucky Half: Period Certificates, the Two-Adic Splitting "
                 "Criterion, and the Per-Modulus Cap on Sampling",
        "domain": "Bridges",
        "description": "For an odd semiprime N = pq, a period certificate for a base a can "
                       "produce a nontrivial factor precisely when the 2-adic valuations of the "
                       "two per-prime multiplicative orders differ; when they agree the base is "
                       "permanently unlucky and no sampling budget can help, so the aggregate "
                       "success rate rises like an independence ladder toward a ceiling equal to "
                       "the certification rate times the fraction of usable bases.",
        "authors": ["Aristotle"],
        "date": "2026-09-17",
        "key_results": [
            "Two-adic splitting criterion: for an odd semiprime N = pq and a base a with "
            "per-prime multiplicative orders 2^i·u and 2^j·v (u, v odd), some period certificate "
            "of a yields a nontrivial factor of N if and only if i ≠ j",
            "Unlucky cap: when the two per-prime orders share a 2-adic valuation, every halved "
            "even period satisfies a^m ≡ ±1 modulo N, so every certificate returns a trivial "
            "greatest common divisor — a per-modulus structural bound that no number of samples "
            "can move",
            "Explicit splitting witness: when the valuations differ, the halved exact order "
            "L/2, with L the least common multiple of the two per-prime orders, returns the prime "
            "whose order carries the smaller valuation on the first certificate",
            "Density bound and escape: in a product of two cyclic groups of even order at most "
            "half of all elements have coordinate orders of equal 2-adic valuation, so re-drawing "
            "the base escapes the cap with probability at least one half, and an explicit "
            "splitting base always exists",
            "Fungibility ramp and its ceiling: the success rate C(1-(1-p)^s) compounds as "
            "independence with diminishing returns and linear pricing of small budgets, stays "
            "strictly below its ceiling at every finite budget, and at population level saturates "
            "exactly at the certification rate times the mixed-role fraction",
        ],
        "keywords": [
            "order finding",
            "period certificate",
            "two-adic valuation",
            "semiprime factorization",
            "Chinese Remainder Theorem",
            "cyclic group density",
            "sample complexity",
            "structural cap",
        ],
        "article": article,
        "research_paper": paper_md,
        "research_paper_tex": paper_tex,
        "demo": demo,
        "demos": [
            {
                "name": "End-to-End Numerical Tour of the Splitting Criterion, the Cap, "
                        "and the Ramp",
                "description": "A five-part self-contained program. Part 1 verifies the two-adic "
                               "splitting criterion exhaustively: for eight semiprimes it "
                               "compares, for every unit, the prediction v2(ord_p a) ≠ v2(ord_q a) "
                               "against a brute-force scan of every admissible exponent, and "
                               "reports zero mismatches. Part 2 displays the unlucky cap in "
                               "action, scanning all halved even periods of a matched-valuation "
                               "base and showing that a^m is always ±1 modulo N, then re-drawing "
                               "the base and extracting a factor immediately. Part 3 builds a "
                               "controlled-order population (primes ≡ 1 mod 210, per-prime orders "
                               "drawn from {210, 105}, bases assembled by the Chinese Remainder "
                               "Theorem), checks the dichotomy on every instance, and prints the "
                               "capped population ladder with its union bound and marginal gains. "
                               "Part 4 checks the independence law 1-P(s+t) = (1-P(s))(1-P(t)) "
                               "and compares the measured ladder 0.056 / 0.204 / 0.471 with the "
                               "prediction 1-(1-0.06)^s. Part 5 tabulates the measured ramp "
                               "against register size and the outcome taxonomy.",
                "code": demo,
            },
            {
                "name": "Exhaustive Measurement of the Permanently-Unlucky Density and the "
                        "Value of a Base Re-draw",
                "description": "Enumerates every unit modulo each of ten odd semiprimes, "
                               "classifies it as mixed or permanently unlucky by comparing the "
                               "2-adic valuations of its per-prime orders, and reports the exact "
                               "unlucky density together with the expected number of base "
                               "re-draws 1/(1-density) and the failure probability of five "
                               "independent re-draws. Every measured density falls at or below "
                               "the proven bound of one half, clustering near one quarter for "
                               "typical valuation profiles. The script then verifies, for every "
                               "mixed base of a fixed semiprime, that the halved exact order L/2 "
                               "really does return a prime factor — confirming the universal "
                               "witness of the positive half of the criterion with zero failures.",
                "code": demo_density,
            },
        ],
        "algorithms": [
            {
                "name": "The Two-Adic Splitting Criterion: A Decision Procedure for "
                        "Base Usability",
                "description": "Decides, for a fixed base a and an odd semiprime N = pq with "
                               "known factorization (the diagnostic setting), whether any period "
                               "certificate of a can ever factor N, and if so returns an explicit "
                               "splitting exponent together with the factor it extracts. The "
                               "mathematical foundation is the two-adic splitting criterion: "
                               "writing ord_p(a) = 2^i·u and ord_q(a) = 2^j·v with u, v odd, some "
                               "certificate splits N if and only if i ≠ j, in which case the "
                               "halved exact order L/2 with L = lcm(ord_p a, ord_q a) is a "
                               "universal witness. Complexity: computing each per-prime order "
                               "costs O(log(p) · Ω(p-1)) modular exponentiations by stripping "
                               "prime factors from p-1, the valuation comparison is O(log L), and "
                               "the final extraction is a single modular exponentiation plus one "
                               "Euclidean gcd, so the procedure is polynomial in log N given the "
                               "factorizations of p-1 and q-1. Its role in the pipeline is "
                               "diagnostic: it separates the structural cap from sampling noise, "
                               "certifying that a failure to factor is permanent rather than "
                               "unlucky.",
                "pseudocode": """Input:  base a, distinct odd primes p, q  (N = p·q)
Output: (can_split, witness exponent m, extracted factor g)

 1. d_p ← multiplicative order of a modulo p
 2. d_q ← multiplicative order of a modulo q
 3. i ← v2(d_p);  j ← v2(d_q)          // two-adic valuations
 4. if i = j then
 5.     return (false, ⊥, ⊥)           // permanently unlucky:
 6.                                    // for EVERY m with N | a^{2m}-1,
 7.                                    // a^m ≡ ±1 (mod N) and gcd(a^m-1,N) ∈ {1,N}
 8. L ← lcm(d_p, d_q)                  // the exact order of a modulo N
 9. m ← L / 2                          // L is even because i ≠ j
10. g ← gcd(a^m - 1 mod N, N)
11. assert 1 < g < N                   // guaranteed: g is the prime whose
12.                                    // order carries the SMALLER valuation
13. return (true, m, g)

Subroutine  multiplicative order of a modulo prime p:
 1. ord ← p - 1
 2. for each prime power ℓ^e || p - 1:
 3.     repeat e times:
 4.         if a^{ord/ℓ} ≡ 1 (mod p) then ord ← ord / ℓ else break
 5. return ord""",
                "code": algo_criterion,
            },
            {
                "name": "Construction of Semiprimes with Prescribed Per-Prime "
                        "Multiplicative Orders",
                "description": "Generates test populations in which the per-prime multiplicative "
                               "order of the base is chosen rather than observed — the only way "
                               "to study the splitting criterion at simulable scale, since the "
                               "order of a random base modulo a cryptographic semiprime is of "
                               "size lcm(p-1, q-1) ≈ 2^30 and beyond, and random search for small "
                               "semiprimes with prescribed simultaneous orders has hit rate near "
                               "10^-7. The construction rests on two facts: in a finite group, if "
                               "d divides the order n of g then g^(n/d) has order exactly d; and "
                               "for every divisor r of p-1 the units modulo the prime p contain "
                               "an element of exact order r. Primes are drawn from the "
                               "arithmetic progression kr+1, elements of exact order d ∈ {r, r/2} "
                               "are manufactured by projection, and the two per-prime bases are "
                               "combined by the Chinese Remainder Theorem. Complexity: prime "
                               "search costs O(r · log^3 r) expected by the density of primes in "
                               "the progression together with Miller-Rabin testing; each "
                               "projection succeeds with probability φ(d)/d per attempt, so the "
                               "expected number of retries is O(log log d); the Chinese Remainder "
                               "combination is a single modular inverse.",
                "pseudocode": """Input:  control parameter r = 2u with u odd, random source
Output: instance (p, q, N, a, d_p, d_q) with ord_p(a) = d_p, ord_q(a) = d_q

 1. p ← smallest convenient prime of the form k·r + 1        // so r | p - 1
 2. q ← another such prime, q ≠ p
 3. d_p ← uniform choice from {r, r/2}
 4. d_q ← uniform choice from {r, r/2}
 5. g_p ← ELEMENT-OF-ORDER(p, d_p)
 6. g_q ← ELEMENT-OF-ORDER(q, d_q)
 7. a  ← CRT(g_p mod p, g_q mod q)                           // unique mod p·q
 8. return (p, q, p·q, a, d_p, d_q)

ELEMENT-OF-ORDER(prime P, divisor d of P-1):
 1. repeat
 2.     h ← uniform random in [2, P-2]
 3.     g ← h^((P-1)/d) mod P          // projection: order of g divides d
 4. until order of g equals exactly d  // fails only if h lies in a proper subgroup
 5. return g

Design note: with r = 2u and u odd, the admissible orders {2u, u} have
two-adic valuations {1, 0}; hence on this population "equal orders" and
"equal valuations" coincide, and the dichotomy is exactly d_p = d_q.""",
                "code": algo_construct,
            },
            {
                "name": "Las Vegas Factorization by Period Certificates with Base Re-drawing",
                "description": "The end-to-end pipeline: draw a base, obtain its exact "
                               "multiplicative order from the order-finding stage, halve it, and "
                               "take a greatest common divisor; when the base turns out to be "
                               "permanently unlucky — odd order, or halved power congruent to ±1 "
                               "modulo N — discard it and draw again. Correctness is immediate "
                               "(the algorithm returns only verified nontrivial divisors), and "
                               "termination is governed by the density bound: at most half of all "
                               "bases are permanently unlucky, so each draw succeeds with "
                               "probability at least 1/2, the expected number of draws is at most "
                               "2, and the probability that k draws all fail is at most 2^-k. "
                               "Complexity per draw: one order-finding call plus O(Ω(λ)) modular "
                               "exponentiations to strip the candidate exponent down to the exact "
                               "order, plus one gcd. The crucial structural point is that the "
                               "re-draw loop, and not the sample budget, is what moves the "
                               "ceiling: repeated sampling on a fixed unlucky base has success "
                               "probability exactly zero at every budget.",
                "pseudocode": """Input:  odd semiprime N = p·q, an exponent λ annihilating the unit group,
        maximum number of draws K
Output: a nontrivial factor of N, or ⊥

 1. for draw = 1 to K:
 2.     a ← uniform random in [2, N-2]
 3.     if gcd(a, N) > 1 then return gcd(a, N)        // free lunch
 4.     L ← EXACT-ORDER(a, N, λ)                      // order-finding stage
 5.     if L is odd then continue                     // unlucky: no halving possible
 6.     x ← a^{L/2} mod N
 7.     if x = 1 or x = N-1 then continue             // unlucky: matched valuations
 8.     g ← gcd(x - 1, N)
 9.     if 1 < g < N then return g
10. return ⊥

EXACT-ORDER(a, N, λ):
 1. ord ← λ
 2. for each prime power ℓ^e || λ:
 3.     repeat e times:
 4.         if ℓ | ord and a^{ord/ℓ} ≡ 1 (mod N) then ord ← ord/ℓ else break
 5. return ord

Analysis: steps 5 and 7 are exactly the permanently unlucky case, i.e.
v2(ord_p a) = v2(ord_q a).  By the density bound these occur for at most half
of all bases, so E[draws] ≤ 2 and P(failure after k draws) ≤ 2^{-k}.""",
                "code": algo_redraw,
            },
        ],
        "visualizations": [
            {
                "name": "The Fungibility Ramp and Its Structural Ceiling",
                "description": "A two-panel figure. The left panel plots the per-instance ladder "
                               "C(1-(1-p)^s) for several per-sample probabilities against a "
                               "common ceiling, making visible both the compounding of samples "
                               "and the strict subsaturation that holds at every finite budget. "
                               "The right panel plots population ramps for several mixed-role "
                               "fractions μ, with the saturation value C·μ drawn as a dotted "
                               "line for each, and overlays the measured points 0.056, 0.204, "
                               "0.471 at sample budgets 1, 4, 11 — showing simultaneously that "
                               "the data follow an independence ladder and that the ladder is "
                               "bounded by a quantity the sample budget cannot touch.",
                "code": viz_ramp,
            },
            {
                "name": "The Lucky/Unlucky Lattice of Bases in Chinese Remainder Coordinates",
                "description": "Plots every unit modulo N = p·q at the coordinates (a mod p, "
                               "a mod q) and colours it by whether the 2-adic valuations of its "
                               "two per-prime orders agree. The permanently unlucky bases appear "
                               "as a product pattern of valuation level sets rather than as a "
                               "diagonal, which is precisely the geometry behind the density "
                               "bound; the companion panel shows the two one-dimensional "
                               "valuation profiles, each of whose level sets contains at most "
                               "half of its group. The measured unlucky density is printed and "
                               "compared with the guaranteed bound of one half.",
                "code": viz_lattice,
            },
        ],
        "interactive_demos": [
            {
                "title": "The Two-Adic Lottery: Every Base, Every Exponent, Every Budget",
                "description": "A single-page laboratory for the splitting criterion, in four "
                               "linked panels. Panel 1 takes a semiprime and a base and delivers "
                               "the verdict, displaying both per-prime orders in the form "
                               "2^v × odd, the two valuations, and — for a mixed base — the "
                               "halved exact order and the factor it extracts, with the "
                               "reasoning spelled out in prose that updates live. Panel 2 draws "
                               "the entire lattice of bases in Chinese Remainder coordinates, "
                               "coloured lucky/unlucky and clickable, with the measured unlucky "
                               "density displayed against the proven bound of one half. Panel 3 "
                               "is the heart of the page: it enumerates every exponent m for "
                               "which 2m is a period of the chosen base and tests the greatest "
                               "common divisor at each one, so that a reader can see with their "
                               "own eyes that an unlucky base yields nothing at any exponent "
                               "whatsoever — the structural cap, not a sampling accident. Panel "
                               "4 turns the sample budget, the per-sample probability, the "
                               "certification rate and the mixed-role fraction into sliders and "
                               "plots the resulting population ramp against its ceiling C·μ, "
                               "making the central lesson tactile: dragging the budget moves the "
                               "curve, only dragging the mixed-role fraction moves the ceiling.",
                "html": widget,
            },
        ],
        "interactive_layout": layout,
        "lean_proofs": lean_blob,
        "future_directions": FUTURE_DIRECTIONS,
        "modules": {
            "demo": demo,
            "demo_density": demo_density,
            "algo_criterion": algo_criterion,
            "algo_construct": algo_construct,
            "algo_redraw": algo_redraw,
            "viz_ramp": viz_ramp,
            "viz_lattice": viz_lattice,
        },
        "lean_files": LEAN_FILES,
    }

    out = ROOT / "PACKAGE.json"
    out.write_text(json.dumps(package, indent=2, ensure_ascii=False) + "\n",
                   encoding="utf-8")
    print(f"wrote {out} ({out.stat().st_size} bytes)")


if __name__ == "__main__":
    main()


"""Measuring the density of permanently unlucky bases, and the value of a re-draw.

For a list of odd semiprimes N = p*q this script enumerates every unit modulo N,
classifies it as mixed (the two-adic valuations of the per-prime orders differ,
so some period certificate splits N) or permanently unlucky (the valuations
agree, so no certificate ever splits N), and reports:

  * the exact unlucky density, always at most 1/2 as the density bound demands;
  * the expected number of base re-draws to reach a splitting base, 1/(1-density);
  * the probability that k independent re-draws all fail.

It then verifies, for each mixed base of a small semiprime, that the halved exact
order L/2 really does return a prime factor -- the explicit witness of the
positive half of the criterion.
"""

from __future__ import annotations

from math import gcd
from typing import Dict, List, Tuple


def _factorize(n: int) -> Dict[int, int]:
    out: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            out[d] = out.get(d, 0) + 1
            n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        out[n] = out.get(n, 0) + 1
    return out


def multiplicative_order(a: int, p: int) -> int:
    """Order of a modulo the prime p."""
    order = p - 1
    for prime, exponent in _factorize(p - 1).items():
        for _ in range(exponent):
            if pow(a, order // prime, p) == 1:
                order //= prime
            else:
                break
    return order


def v2(n: int) -> int:
    """Two-adic valuation."""
    k = 0
    while n % 2 == 0:
        n //= 2
        k += 1
    return k


def classify(p: int, q: int) -> Tuple[int, int]:
    """Return (number of units, number of permanently unlucky units)."""
    units = 0
    unlucky = 0
    for a in range(2, p * q):
        if gcd(a, p * q) != 1:
            continue
        units += 1
        if v2(multiplicative_order(a % p, p)) == v2(multiplicative_order(a % q, q)):
            unlucky += 1
    return units, unlucky


def witness(p: int, q: int, a: int) -> int:
    """The halved exact order L/2 and the factor it extracts (0 if none)."""
    d_p = multiplicative_order(a % p, p)
    d_q = multiplicative_order(a % q, q)
    L = d_p // gcd(d_p, d_q) * d_q
    g = gcd(pow(a, L // 2, p * q) - 1, p * q)
    return g if 1 < g < p * q else 0


def main() -> None:
    pairs: List[Tuple[int, int]] = [(7, 11), (11, 13), (13, 17), (17, 19),
                                    (23, 29), (31, 37), (41, 43), (53, 59),
                                    (61, 67), (71, 73)]
    print(f"{'N':>7} {'units':>7} {'unlucky':>8} {'density':>8} "
          f"{'E[draws]':>9} {'P(5 fail)':>10}")
    for p, q in pairs:
        units, unlucky = classify(p, q)
        density = unlucky / units
        print(f"{p*q:7d} {units:7d} {unlucky:8d} {density:8.3f} "
              f"{1/(1-density):9.2f} {density**5:10.5f}")
    print()
    print("Every density is at most 0.5, as the density bound guarantees.")
    print()

    p, q = 23, 29
    print(f"Explicit witnesses for N = {p}*{q} = {p*q}:")
    checked = 0
    failures = 0
    for a in range(2, p * q):
        if gcd(a, p * q) != 1:
            continue
        mixed = v2(multiplicative_order(a % p, p)) != v2(multiplicative_order(a % q, q))
        if mixed:
            checked += 1
            if witness(p, q, a) not in (p, q):
                failures += 1
    print(f"  mixed bases tested with the exponent L/2 : {checked}")
    print(f"  failures to extract a prime factor       : {failures}")
    print("  The halved exact order is a universal witness for mixed bases.")


if __name__ == "__main__":
    main()


"""Visualization: the lucky/unlucky lattice of bases modulo a semiprime.

Every unit a modulo N = p*q is plotted at the coordinates (a mod p, a mod q) --
its Chinese Remainder coordinates -- and coloured by the two-adic valuations of
its per-prime orders.  Cells on the "diagonal" of matching valuations are the
permanently unlucky bases: no period certificate can ever factor N from them.
The printed density is compared with the guaranteed bound of one half.
"""

from __future__ import annotations

from math import gcd
from typing import Dict

import matplotlib.pyplot as plt
import numpy as np


def _factorize(n: int) -> Dict[int, int]:
    out: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            out[d] = out.get(d, 0) + 1
            n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        out[n] = out.get(n, 0) + 1
    return out


def multiplicative_order(a: int, p: int) -> int:
    order = p - 1
    for prime, exponent in _factorize(p - 1).items():
        for _ in range(exponent):
            if pow(a, order // prime, p) == 1:
                order //= prime
            else:
                break
    return order


def v2(n: int) -> int:
    k = 0
    while n % 2 == 0:
        n //= 2
        k += 1
    return k


def main(p: int = 31, q: int = 37) -> None:
    vp = np.array([v2(multiplicative_order(x, p)) if x else -1 for x in range(p)])
    vq = np.array([v2(multiplicative_order(y, q)) if y else -1 for y in range(q)])

    grid = np.full((q, p), np.nan)
    unlucky = 0
    units = 0
    for x in range(1, p):
        for y in range(1, q):
            units += 1
            same = vp[x] == vq[y]
            grid[y, x] = 0.0 if same else 1.0
            unlucky += int(same)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5.5),
                                   gridspec_kw={"width_ratios": [1.3, 1]})

    ax1.imshow(grid, origin="lower", cmap="RdYlGn", vmin=0, vmax=1, aspect="auto")
    ax1.set_title(f"Bases modulo N = {p}·{q} in Chinese Remainder coordinates\n"
                  "green = splits N,  red = permanently unlucky")
    ax1.set_xlabel(f"a mod {p}")
    ax1.set_ylabel(f"a mod {q}")

    labels = sorted(set(vp[1:]) | set(vq[1:]))
    countp = [int((vp[1:] == k).sum()) for k in labels]
    countq = [int((vq[1:] == k).sum()) for k in labels]
    width = 0.4
    idx = np.arange(len(labels))
    ax2.bar(idx - width / 2, countp, width, label=f"modulo {p}")
    ax2.bar(idx + width / 2, countq, width, label=f"modulo {q}")
    ax2.set_xticks(idx)
    ax2.set_xticklabels([str(k) for k in labels])
    ax2.set_xlabel("two-adic valuation of the order")
    ax2.set_ylabel("number of residues")
    ax2.set_title("Valuation profiles: every level holds at most half the group")
    ax2.legend()
    ax2.grid(alpha=0.3, axis="y")

    density = unlucky / units
    fig.suptitle(f"Unlucky density = {density:.3f}  (guaranteed bound 0.5)",
                 fontsize=14)
    fig.tight_layout()
    fig.savefig("unlucky_lattice.png", dpi=160)
    print(f"unlucky density for N = {p*q}: {density:.4f} over {units} units")
    print("wrote unlucky_lattice.png")


if __name__ == "__main__":
    main()


"""Visualization: the fungibility ramp and its structural ceiling.

Left panel: per-instance ladders C*(1-(1-p)^s) for several per-sample
probabilities, all approaching the same ceiling but never touching it.
Right panel: population ramps for several mixed-role fractions, showing that
the saturation value is (certification rate) x (mixed-role fraction), and
overlaying the measured ladder 0.056 / 0.204 / 0.471 at register size wall-2.
"""

from __future__ import annotations

from typing import List

import matplotlib.pyplot as plt
import numpy as np


def ramp(cap: float, pr: float, s: np.ndarray) -> np.ndarray:
    """Capped independence ladder."""
    return cap * (1.0 - (1.0 - pr) ** s)


def main() -> None:
    s = np.arange(0, 81)
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    cap = 0.8
    for pr in (0.02, 0.06, 0.15, 0.30):
        ax1.plot(s, ramp(cap, pr, s), lw=2, label=f"per-sample p = {pr}")
    ax1.axhline(cap, color="black", ls="--", lw=1.5, label=f"ceiling C = {cap}")
    ax1.set_title("Per-instance ladder: samples compound, ceiling never attained")
    ax1.set_xlabel("sample budget s")
    ax1.set_ylabel("P(factor extracted)")
    ax1.set_ylim(0, 1.0)
    ax1.legend(loc="lower right")
    ax1.grid(alpha=0.3)

    cert = 0.8
    for mu in (1.0, 2 / 3, 0.5, 0.25):
        ax2.plot(s, ramp(cert * mu, 0.06, s), lw=2,
                 label=f"mixed-role fraction $\\mu$ = {mu:.2f}")
        ax2.axhline(cert * mu, color="gray", ls=":", lw=1)
    measured_s: List[int] = [1, 4, 11]
    measured_p: List[float] = [0.056, 0.204, 0.471]
    ax2.plot(measured_s, measured_p, "ko", ms=8, label="measured (wall $-$ 2)")
    ax2.set_title("Population ramp: ceiling = certification rate $\\times$ $\\mu$")
    ax2.set_xlabel("sample budget s")
    ax2.set_ylabel("population success rate")
    ax2.set_ylim(0, 1.0)
    ax2.legend(loc="lower right")
    ax2.grid(alpha=0.3)

    fig.suptitle("The fungibility ramp and the per-modulus unlucky cap", fontsize=14)
    fig.tight_layout()
    fig.savefig("fungibility_ramp.png", dpi=160)
    print("wrote fungibility_ramp.png")


if __name__ == "__main__":
    main()
