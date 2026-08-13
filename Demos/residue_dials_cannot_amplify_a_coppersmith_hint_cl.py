#!/usr/bin/env python3
"""
Residue dials cannot amplify a partial-key hint: numerical demonstrations.
==========================================================================

Setting.  A secret prime `p` is known only through a partial-key hint
`p = r (mod m)` (a Coppersmith-style hint, `m ~ N^{1/4}`).  A "residue dial" is
any integer-valued statistic of `p` that is periodic with some conductor `c`;
the motivating examples are the Kronecker symbols `(D | p)`, of conductor
`4|D|`.  A dial system `D_1, ..., D_K` has conductor lcm

    M* = lcm(c_1, ..., c_K),

and its dial vector V(p) = (chi_1(p), ..., chi_K(p)) depends only on p mod M*.

This script verifies, by exhaustive finite computation, the following results.

  (1) MASTER BOUND.  On a candidate set inside one hint class mod m the dial
      vector takes at most  M*/gcd(M*, m)  distinct values.
  (2) SHARPNESS.  The bound is an equality for the resolution dial p |-> p mod M
      on the window [0, lcm(M, m)).
  (3) CRT INDEPENDENCE.  Coprime conductors compound: two resolution dials of
      coprime conductors a, b realize all a*b joint readings.
  (4) REGIME 1 (M* | m).  The dial vector is constant on the candidate set; the
      dial cut removes nothing; it is exactly independent of every secret.
      Instance: N ~ 8.08e8, m = 168, dials at D = -3, 21, 42 (conductors
      12, 84, 168), witnessed by the primes 28393 and 28729.
  (5) REGIME 2 (M* does not divide m).  The dial is informative but not
      computable from the hint.  Instance: m = 135, dial (-4 | .) of conductor
      16, witnessed by the primes 541 and 811.  Universal form: for every odd m
      the dial (-4 | .) separates 1 and 1 + 2m.
  (6) JOINT RESOLUTION CAP / PINNING THRESHOLD.  The pair (hint, dials) resolves
      p only modulo lcm(m, M*); pinning a window [0, X) forces X <= lcm(m, M*),
      hence M* >= X/m, hence M* >= m in the Coppersmith regime X = m^2.
  (7) COUNTING BARRIER.  K sign dials separate at most 3^K candidates (2^K when
      the readings never vanish).

Everything below is self-contained: no imports beyond the standard library.
"""

from __future__ import annotations

from itertools import combinations
from math import gcd, isqrt
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

Reading = Tuple[int, ...]


# ---------------------------------------------------------------------------
# 1.  Elementary arithmetic
# ---------------------------------------------------------------------------


def lcm(a: int, b: int) -> int:
    """Least common multiple of two positive integers."""
    return a // gcd(a, b) * b


def lcm_list(xs: Iterable[int]) -> int:
    """Least common multiple of a list of positive integers."""
    out = 1
    for x in xs:
        out = lcm(out, x)
    return out


def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test (inputs here are small)."""
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    for d in range(3, isqrt(n) + 1, 2):
        if n % d == 0:
            return False
    return True


def jacobi(a: int, n: int) -> int:
    """Jacobi symbol (a | n) for odd n >= 1; returns -1, 0 or 1."""
    if n <= 0 or n % 2 == 0:
        raise ValueError("jacobi: lower argument must be odd and positive")
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


def kronecker(a: int, n: int) -> int:
    """Kronecker symbol (a | n) for n >= 0, extending the Jacobi symbol."""
    if n == 0:
        return 1 if a in (1, -1) else 0
    sign = 1
    if n < 0:
        n = -n
        if a < 0:
            sign = -1
    # factor out powers of two from n
    e = 0
    while n % 2 == 0:
        n //= 2
        e += 1
    if e:
        if a % 2 == 0:
            return 0
        two = 1 if a % 8 in (1, 7) else -1
        sign *= two ** e
    return sign * jacobi(a, n) if n > 1 else sign


# ---------------------------------------------------------------------------
# 2.  Dials
# ---------------------------------------------------------------------------


class Dial:
    """A residue dial: an integer statistic of the candidate, periodic in it.

    Attributes
    ----------
    cond : the conductor (the period).
    chi  : the reading, a function of the candidate; chi(n + cond) == chi(n).
    name : a human-readable label.
    """

    def __init__(self, cond: int, chi: Callable[[int], int], name: str) -> None:
        if cond < 1:
            raise ValueError("conductor must be positive")
        self.cond = cond
        self.chi = chi
        self.name = name

    def __repr__(self) -> str:  # pragma: no cover - cosmetic
        return f"Dial({self.name}, cond={self.cond})"


def kron_dial(D: int) -> Dial:
    """The Kronecker dial (D | .) of conductor 4|D|, realized as a periodic map."""
    if D == 0:
        raise ValueError("discriminant must be nonzero")
    c = 4 * abs(D)
    return Dial(c, lambda n, D=D, c=c: kronecker(D, n % c), f"({D}|.)")


def res_dial(M: int) -> Dial:
    """The resolution dial of conductor M: it reads the whole residue p mod M."""
    return Dial(M, lambda n, M=M: n % M, f"(. mod {M})")


def cond_lcm(dials: Sequence[Dial]) -> int:
    """M*, the conductor lcm of a dial system."""
    return lcm_list([d.cond for d in dials]) if dials else 1


def dial_vec(dials: Sequence[Dial], p: int) -> Reading:
    """The dial vector V(p) = (chi_1(p), ..., chi_K(p))."""
    return tuple(d.chi(p) for d in dials)


def budget(dials: Sequence[Dial], m: int) -> int:
    """The amplification budget M*/gcd(M*, m)."""
    Ms = cond_lcm(dials)
    return Ms // gcd(Ms, m)


def hint_class(m: int, r: int, X: int) -> List[int]:
    """The candidate set {x < X : x = r (mod m)}."""
    return [x for x in range(r % m, X, m)]


# ---------------------------------------------------------------------------
# 3.  The results, verified numerically
# ---------------------------------------------------------------------------


def check_master_bound(dials: Sequence[Dial], m: int, r: int, X: int) -> Tuple[int, int]:
    """Count distinct dial readings on a hint class and compare with the budget."""
    omega = hint_class(m, r, X)
    seen = {dial_vec(dials, p) for p in omega}
    return len(seen), budget(dials, m)


def demo_master_bound() -> None:
    print("=" * 78)
    print("(1)  MASTER BOUND:  #readings on a hint class  <=  M*/gcd(M*, m)")
    print("=" * 78)
    systems = [
        ([kron_dial(-3), kron_dial(21), kron_dial(42)], 168, 1),
        ([kron_dial(-4)], 135, 1),
        ([kron_dial(-3), kron_dial(-4), kron_dial(5)], 21, 4),
        ([res_dial(35)], 14, 3),
        ([kron_dial(-7), kron_dial(8)], 100, 7),
    ]
    print(f"{'dials':<34}{'m':>6}{'M*':>8}{'budget':>9}{'actual':>9}  ok")
    for dials, m, r in systems:
        Ms = cond_lcm(dials)
        window = 40 * lcm(m, Ms)
        actual, b = check_master_bound(dials, m, r, window)
        names = ",".join(d.name for d in dials)
        ok = actual <= b
        print(f"{names:<34}{m:>6}{Ms:>8}{b:>9}{actual:>9}  {'YES' if ok else 'NO'}")
        assert ok
    print()


def demo_sharpness() -> None:
    print("=" * 78)
    print("(2)  SHARPNESS: the resolution dial attains M/gcd(M, m) exactly")
    print("=" * 78)
    print(f"{'M':>6}{'m':>6}{'gcd':>6}{'M/gcd':>8}{'realized':>10}  ok")
    for M, m in [(12, 8), (16, 135), (168, 168), (35, 14), (100, 30), (9, 25)]:
        d = [res_dial(M)]
        L = lcm(M, m)
        omega = hint_class(m, 1, L)
        realized = len({dial_vec(d, p) for p in omega})
        predicted = M // gcd(M, m)
        ok = realized == predicted
        print(f"{M:>6}{m:>6}{gcd(M, m):>6}{predicted:>8}{realized:>10}  {'YES' if ok else 'NO'}")
        assert ok
    print()


def demo_crt_independence() -> None:
    print("=" * 78)
    print("(3)  CRT INDEPENDENCE: coprime conductors compound multiplicatively")
    print("=" * 78)
    for a, b in [(3, 5), (4, 9), (16, 27), (7, 8)]:
        dials = [res_dial(a), res_dial(b)]
        realized = len({dial_vec(dials, x) for x in range(a * b)})
        print(f"  conductors ({a}, {b}):  M* = {cond_lcm(dials):>4}, "
              f"joint readings realized = {realized:>4}  (= a*b = {a*b})")
        assert realized == a * b and cond_lcm(dials) == a * b
    print()


def demo_regime1() -> None:
    print("=" * 78)
    print("(4)  REGIME 1  (M* | m):  computable from the hint, hence useless")
    print("     instance: N ~ 8.08e8, hint modulus m = 168, dials D = -3, 21, 42")
    print("=" * 78)
    dials = [kron_dial(-3), kron_dial(21), kron_dial(42)]
    m = 168
    Ms = cond_lcm(dials)
    print(f"  conductors     : {[d.cond for d in dials]}")
    print(f"  M*             : {Ms}      (divides m = {m}: {Ms % m == 0 or m % Ms == 0})")
    print(f"  budget M*/gcd  : {budget(dials, m)}   <- 1 means zero amplification")
    assert m % Ms == 0
    assert budget(dials, m) == 1

    p1, p2 = 28393, 28729
    print(f"\n  two genuine candidates: {p1} (prime: {is_prime(p1)}), "
          f"{p2} (prime: {is_prime(p2)})")
    print(f"  product ~ {p1 * p2:.3e} -- the scale of the instance")
    print(f"  hints  : {p1} mod {m} = {p1 % m},   {p2} mod {m} = {p2 % m}")
    v1, v2 = dial_vec(dials, p1), dial_vec(dials, p2)
    print(f"  dial readings: V({p1}) = {v1}")
    print(f"                 V({p2}) = {v2}")
    print(f"  the dials CONFUSE them: {v1 == v2}")
    assert v1 == v2

    # the dial cut is the identity, and all candidates survive
    C = 60
    omega = hint_class(m, 1, m * C)
    v0 = dial_vec(dials, omega[0])
    survivors = [p for p in omega if dial_vec(dials, p) == v0]
    print(f"\n  window [0, {m*C}) intersected with the hint class: "
          f"{len(omega)} candidates")
    print(f"  after the dial cut: {len(survivors)} survive "
          f"-- removed {len(omega) - len(survivors)}")
    assert len(survivors) == len(omega) == C
    print()


def zero_information(omega: Sequence[int],
                     T: Callable[[int], object],
                     S: Callable[[int], object]) -> bool:
    """Exact independence of the reading T and the secret S on omega:

        #{T = t and S = s} * #omega  ==  #{T = t} * #{S = s}   for all t, s.
    """
    n = len(omega)
    joint: Dict[Tuple[object, object], int] = {}
    tc: Dict[object, int] = {}
    sc: Dict[object, int] = {}
    for p in omega:
        t, s = T(p), S(p)
        joint[(t, s)] = joint.get((t, s), 0) + 1
        tc[t] = tc.get(t, 0) + 1
        sc[s] = sc.get(s, 0) + 1
    for t, ct in tc.items():
        for s, cs in sc.items():
            if joint.get((t, s), 0) * n != ct * cs:
                return False
    return True


def demo_zero_information() -> None:
    print("=" * 78)
    print("(4b) REGIME 1: exact zero information, before and after post-processing")
    print("=" * 78)
    dials = [kron_dial(-3), kron_dial(21), kron_dial(42)]
    m = 168
    omega = hint_class(m, 1, m * 200)
    secrets: List[Tuple[str, Callable[[int], object]]] = [
        ("p mod 1000", lambda p: p % 1000),
        ("is p prime", lambda p: is_prime(p)),
        ("floor(p / 5000)", lambda p: p // 5000),
        ("number of binary 1s of p", lambda p: bin(p).count("1")),
    ]
    posts: List[Tuple[str, Callable[[Reading], object]]] = [
        ("identity", lambda v: v),
        ("sum of readings", lambda v: sum(v)),
        ("first coordinate", lambda v: v[0]),
        ("hash-like fold", lambda v: (7 * v[0] + 3 * v[1] - v[2]) % 5),
    ]
    for sname, S in secrets:
        for hname, h in posts:
            T = lambda p, h=h: h(dial_vec(dials, p))
            ok = zero_information(omega, T, S)
            print(f"  secret = {sname:<26} post-processing = {hname:<18} "
                  f"zero information: {'YES' if ok else 'NO'}")
            assert ok
    print()


def demo_regime2() -> None:
    print("=" * 78)
    print("(5)  REGIME 2  (M* does not divide m):  informative, but not computable")
    print("     instance: N ~ 3.4e8, hint modulus m = 135, dial (-4 | .)")
    print("=" * 78)
    dials = [kron_dial(-4)]
    m = 135
    Ms = cond_lcm(dials)
    print(f"  M* = {Ms},  m = {m},  M* | m ? {m % Ms == 0}")
    print(f"  budget M*/gcd(M*, m) = {budget(dials, m)}")
    assert m % Ms != 0

    p1, p2 = 541, 811
    print(f"\n  candidates {p1} (prime: {is_prime(p1)}) and {p2} (prime: {is_prime(p2)})")
    print(f"  hints  : {p1} mod {m} = {p1 % m},  {p2} mod {m} = {p2 % m}  -> same class")
    print(f"  (-4|{p1}) = {kronecker(-4, p1):+d},   (-4|{p2}) = {kronecker(-4, p2):+d}"
          f"   -> SEPARATED")
    assert p1 % m == p2 % m
    assert dial_vec(dials, p1) != dial_vec(dials, p2)

    # non-computability: exhibit two integers with the same hint, different reading
    witnesses = [(a, b) for a in range(0, 4 * m) for b in range(a + 1, 4 * m)
                 if a % m == b % m and dial_vec(dials, a) != dial_vec(dials, b)]
    a, b = witnesses[0]
    print(f"\n  non-computability witness: {a} = {b} (mod {m}) but readings "
          f"{dial_vec(dials, a)} != {dial_vec(dials, b)}")
    print("  => no function of (p mod 135) can output this dial: not hint-computable")

    print("\n  universal form: for every ODD m the dial (-4|.) separates 1 and 1+2m")
    for mm in [3, 5, 9, 15, 21, 135, 1001, 65537 - 2]:
        v1 = kronecker(-4, 1)
        v2 = kronecker(-4, 1 + 2 * mm)
        assert (1 % mm == (1 + 2 * mm) % mm) and v1 != v2
        print(f"    m = {mm:>6}: (-4|1) = {v1:+d},  (-4|{1+2*mm}) = {v2:+d}   separated")
    print()


def demo_threshold() -> None:
    print("=" * 78)
    print("(6)  JOINT RESOLUTION CAP AND THE PINNING THRESHOLD")
    print("=" * 78)
    print("  Pinning inside [0, X) requires X <= lcm(m, M*).  Search for the largest")
    print("  window a system actually pins, and compare with the cap.\n")

    def largest_pinned_window(dials: Sequence[Dial], m: int, cap_search: int) -> int:
        """Largest X <= cap_search such that (hint, dials) is injective on [0, X)."""
        best = 0
        seen: Dict[Tuple[int, Reading], int] = {}
        for x in range(cap_search + 1):
            key = (x % m, dial_vec(dials, x))
            if key in seen:
                return x  # collision at x: the window [0, x) is the largest pinned
            seen[key] = x
            best = x + 1
        return best

    cases = [
        ([res_dial(7)], 5),
        ([res_dial(16)], 9),
        ([kron_dial(-4)], 9),
        ([kron_dial(-3), kron_dial(-4)], 5),
        ([res_dial(11)], 11),
    ]
    print(f"{'dials':<26}{'m':>5}{'M*':>6}{'lcm(m,M*)':>12}{'pinned X':>10}  cap ok")
    for dials, m in cases:
        Ms = cond_lcm(dials)
        L = lcm(m, Ms)
        X = largest_pinned_window(dials, m, 4 * L)
        names = ",".join(d.name for d in dials)
        print(f"{names:<26}{m:>5}{Ms:>6}{L:>12}{X:>10}  {'YES' if X <= L else 'NO'}")
        assert X <= L
    print("\n  Coppersmith regime: window X = m^2 (p < N^{1/2}, m ~ N^{1/4}).")
    print("  Pinning then forces M* >= X/m = m: the dial conductor lcm must be of")
    print("  hint size -- as expensive as a second hint.\n")
    for m in [8, 9, 16, 25, 135, 168]:
        need = (m * m + m - 1) // m  # ceil(m^2 / m) = m
        print(f"    m = {m:>4}: window m^2 = {m*m:>6}  =>  required M* >= {need}")
    print()

    print("  Threshold attained: with gcd(m, C) = 1 the single resolution dial of")
    print("  conductor C pins the whole window [0, m*C).")
    for m, C in [(5, 7), (9, 16), (8, 27), (135, 16)]:
        dials = [res_dial(C)]
        keys = {(x % m, dial_vec(dials, x)) for x in range(m * C)}
        ok = gcd(m, C) == 1 and len(keys) == m * C
        print(f"    m = {m:>4}, C = {C:>3}, gcd = {gcd(m, C)}: "
              f"pins all {m*C} candidates: {'YES' if ok else 'NO'}")
        assert ok
    print()


def demo_capacity() -> None:
    print("=" * 78)
    print("(7)  COUNTING BARRIER: K sign dials separate at most 3^K candidates")
    print("=" * 78)
    discs = [-3, -4, 5, -7, 8, -11, 13, 17]
    print("  Pinning C candidates needs K >= log_3(C)  (log_2(C) if no zero readings).")
    print(f"{'K':>3}{'3^K':>8}{'2^K':>8}{'best separation over dial families':>38}")
    pool = list(range(1, 400, 2))  # odd candidates
    for K in range(1, 5):
        best = 0
        for combo in combinations(discs, K):
            dials = [kron_dial(D) for D in combo]
            readings = {dial_vec(dials, p) for p in pool}
            best = max(best, len(readings))
        print(f"{K:>3}{3**K:>8}{2**K:>8}{best:>28}")
        assert best <= 3 ** K
    print("\n  With C ~ N^{1/4} candidates this forces K = Theta(log N) dials --")
    print("  and, simultaneously, every one of them must have a large conductor.\n")


def main() -> None:
    print()
    print("#" * 78)
    print("#  RESIDUE DIALS CANNOT AMPLIFY A PARTIAL-KEY HINT".ljust(77) + "#")
    print("#  numerical verification of the conductor-budget theorems".ljust(77) + "#")
    print("#" * 78)
    print()
    demo_master_bound()
    demo_sharpness()
    demo_crt_independence()
    demo_regime1()
    demo_zero_information()
    demo_regime2()
    demo_threshold()
    demo_capacity()
    print("=" * 78)
    print("ALL CHECKS PASSED.")
    print("  computable dials (M* | m)  -> constant on the candidate set, zero info")
    print("  informative dials          -> not computable from the hint")
    print("  pinning a window [0, X)    -> M* >= X/m, i.e. M* >= m when X = m^2")
    print("The partial-key hint must be genuinely external.")
    print("=" * 78)


if __name__ == "__main__":
    main()


"""Conductor-budget evaluation and regime classification.

Given a hint modulus m and a family of residue dials specified by their
conductors, this decides -- without evaluating a single dial and without
touching the modulus N -- whether the family can possibly help an attacker.
"""

from __future__ import annotations

from math import gcd
from typing import Dict, List, Sequence


def lcm(a: int, b: int) -> int:
    """Least common multiple of two positive integers."""
    return a // gcd(a, b) * b


def conductor_lcm(conductors: Sequence[int]) -> int:
    """M* = lcm of all dial conductors (1 for the empty family)."""
    out = 1
    for c in conductors:
        if c < 1:
            raise ValueError("conductors must be positive")
        out = lcm(out, c)
    return out


def kronecker_conductors(discriminants: Sequence[int]) -> List[int]:
    """Conductors 4|D| of Kronecker dials (D | .)."""
    return [4 * abs(D) for D in discriminants]


def classify(conductors: Sequence[int], m: int, window: int | None = None) -> Dict[str, object]:
    """Full verdict for a dial family against a hint modulus m.

    Returns the conductor lcm M*, the amplification budget M*/gcd(M*, m)
    (an a priori upper bound on candidate-set shrinkage), the regime, and --
    if a search window size is supplied -- the pinning feasibility test
    window <= lcm(m, M*) together with the conductor the dials would need.

    Complexity: O(K) gcd computations, i.e. O(K log^2 max_i c_i) bit
    operations.  Independent of N and of the number of candidates.
    """
    if m < 1:
        raise ValueError("hint modulus must be positive")
    Ms = conductor_lcm(conductors)
    g = gcd(Ms, m)
    budget = Ms // g
    divides = (m % Ms == 0)
    verdict: Dict[str, object] = {
        "conductors": list(conductors),
        "M_star": Ms,
        "gcd(M*, m)": g,
        "budget": budget,
        "regime": 1 if divides else 2,
        "hint_computable": divides,
        "max_shrink_factor": budget,
        "explanation": (
            "Regime 1: M* divides m. The dial vector is a function of the hint, "
            "hence constant on the candidate set: the dial cut removes nothing "
            "and the readings are exactly independent of every secret, before "
            "and after any post-processing."
            if divides else
            "Regime 2: M* does not divide m. The hint does not determine "
            "p mod M*, so the attacker cannot evaluate the dials at all; the "
            "readings are informative but unavailable."
        ),
    }
    if window is not None:
        cap = lcm(m, Ms)
        verdict["joint_resolution_cap"] = cap
        verdict["pinning_possible"] = window <= cap
        verdict["required_M_star"] = -(-window // m)  # ceil(window / m)
    return verdict


if __name__ == "__main__":
    # Regime 1: the D = -3, 21, 42 family against the hint modulus 168.
    print(classify(kronecker_conductors([-3, 21, 42]), 168, window=168 * 168))
    # Regime 2: the single dial (-4 | .) against the hint modulus 135.
    print(classify(kronecker_conductors([-4]), 135, window=135 * 135))


"""Exhaustive candidate-set shrinkage simulator.

Enumerates a hint class, evaluates a family of Kronecker dials on every
candidate, groups candidates by their dial reading, and compares the realized
shrinkage with the theoretical amplification budget M*/gcd(M*, m).
"""

from __future__ import annotations

from math import gcd, isqrt
from typing import Dict, List, Sequence, Tuple

Reading = Tuple[int, ...]


def lcm(a: int, b: int) -> int:
    """Least common multiple of two positive integers."""
    return a // gcd(a, b) * b


def jacobi(a: int, n: int) -> int:
    """Jacobi symbol (a | n) for odd n >= 1."""
    if n <= 0 or n % 2 == 0:
        raise ValueError("lower argument must be odd and positive")
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


def kronecker(a: int, n: int) -> int:
    """Kronecker symbol (a | n) for n >= 0."""
    if n == 0:
        return 1 if a in (1, -1) else 0
    sign, e = 1, 0
    while n % 2 == 0:
        n //= 2
        e += 1
    if e:
        if a % 2 == 0:
            return 0
        sign *= (1 if a % 8 in (1, 7) else -1) ** e
    return sign * jacobi(a, n) if n > 1 else sign


def dial_vector(discriminants: Sequence[int], p: int) -> Reading:
    """Reading of the Kronecker dial family at the candidate p."""
    return tuple(kronecker(D, p % (4 * abs(D))) for D in discriminants)


def is_prime(n: int) -> bool:
    """Deterministic trial division; adequate for the small ranges used here."""
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    return all(n % d for d in range(3, isqrt(n) + 1, 2))


def shrinkage_report(discriminants: Sequence[int], m: int, r: int, window: int,
                     primes_only: bool = False) -> Dict[str, object]:
    """Realized versus predicted shrinkage on the hint class r mod m in [0, window).

    Complexity: O(|Omega| * K) Kronecker evaluations, each O(log^2 c).
    """
    Ms = 1
    for D in discriminants:
        Ms = lcm(Ms, 4 * abs(D))
    budget = Ms // gcd(Ms, m)

    omega: List[int] = [x for x in range(r % m, window, m)]
    if primes_only:
        omega = [p for p in omega if is_prime(p)]

    fibres: Dict[Reading, List[int]] = {}
    for p in omega:
        fibres.setdefault(dial_vector(discriminants, p), []).append(p)

    largest = max((len(v) for v in fibres.values()), default=0)
    return {
        "M_star": Ms,
        "budget": budget,
        "candidates": len(omega),
        "distinct_readings": len(fibres),
        "largest_surviving_fibre": largest,
        "realized_shrink_factor": (len(omega) / largest) if largest else float("nan"),
        "bound_respected": len(fibres) <= budget,
        "fibre_sizes": sorted((len(v) for v in fibres.values()), reverse=True),
    }


if __name__ == "__main__":
    print("Regime 1 (M* | m): D = -3, 21, 42 against m = 168")
    print(shrinkage_report([-3, 21, 42], m=168, r=1, window=168 * 200))
    print()
    print("Regime 2 (M* does not divide m): D = -4 against m = 135")
    print(shrinkage_report([-4], m=135, r=1, window=135 * 200))


"""Joint-resolution pinning-threshold test.

The attacker's total knowledge is the pair (hint, dial vector).  It resolves a
candidate only modulo lcm(m, M*), so uniqueness inside a search window [0, X)
is possible only when X <= lcm(m, M*).  This module measures the largest window
a given family actually pins and checks it against the cap, and reports the
conductor a family would need in the Coppersmith regime X = m^2.
"""

from __future__ import annotations

from math import gcd
from typing import Callable, Dict, List, Sequence, Tuple

Reading = Tuple[int, ...]


def lcm(a: int, b: int) -> int:
    """Least common multiple of two positive integers."""
    return a // gcd(a, b) * b


def resolution_dial(M: int) -> Callable[[int], int]:
    """The most discriminating dial of conductor M: it reads p mod M."""
    return lambda n: n % M


def largest_pinned_window(readings: Sequence[Callable[[int], int]], m: int,
                          search_cap: int) -> int:
    """Largest X <= search_cap with (hint, readings) injective on [0, X).

    Scans upward and stops at the first collision.  Complexity O(X * K).
    """
    seen: Dict[Tuple[int, Reading], int] = {}
    for x in range(search_cap + 1):
        key = (x % m, tuple(f(x) for f in readings))
        if key in seen:
            return x
        seen[key] = x
    return search_cap + 1


def pinning_report(conductors: Sequence[int], m: int) -> Dict[str, object]:
    """Cap, realized pinning window, and the Coppersmith requirement."""
    Ms = 1
    for c in conductors:
        Ms = lcm(Ms, c)
    cap = lcm(m, Ms)
    dials: List[Callable[[int], int]] = [resolution_dial(c) for c in conductors]
    realized = largest_pinned_window(dials, m, 4 * cap)
    return {
        "M_star": Ms,
        "joint_resolution_cap": cap,
        "largest_pinned_window": realized,
        "cap_respected": realized <= cap,
        "coppersmith_window": m * m,
        "required_M_star_for_coppersmith": m,
        "coppersmith_pinning_possible": m * m <= cap,
    }


if __name__ == "__main__":
    for conductors, m in [([7], 5), ([16], 9), ([16], 135), ([12, 84, 168], 168)]:
        print(f"conductors={conductors}, m={m}: {pinning_report(conductors, m)}")


"""Assemble PACKAGE.json from the deliverable files in the project."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
A = ROOT / "package_assets"


def read(p: Path) -> str:
    return p.read_text(encoding="utf-8")


LEAN_FILES = [
    "Catalog/Combinatorics/DialThresholdNoAmplification.lean",
    "Catalog/Combinatorics/DialThresholdSharpness.lean",
    "Catalog/Combinatorics/DialThresholdConductorThreshold.lean",
]

lean_proofs = "\n\n".join(
    f"-- ===== {f} =====\n" + read(ROOT / f) for f in LEAN_FILES
)

INTERACTIVE_LAYOUT = read(A / "interactive_layout.md")
FUTURE = read(A / "future_directions.md")

package = {
    "title": "Residue Dials Cannot Amplify a Partial-Key Hint: Conductor Budgets for Periodic Side Statistics",
    "domain": "Cryptography",
    "description": (
        "A family of periodic residue statistics of a hidden prime with conductor least common "
        "multiple M* can shrink the candidate set left by a partial-key hint p mod m by at most "
        "the factor M*/gcd(M*, m), and this budget is exactly attained; consequently dials "
        "computable from the hint are constant on the candidate set and carry zero information, "
        "while informative dials require p modulo a number of hint size and are therefore as "
        "expensive as a second hint."
    ),
    "authors": ["Aristotle"],
    "date": "2026-08-13",
    "key_results": [
        "Master bound: on any candidate set inside a single hint class modulo m, a residue-dial family with conductor least common multiple M* takes at most M*/gcd(M*, m) distinct readings, so the candidate set cannot shrink by more than that factor.",
        "Sharpness of the amplification budget: for every conductor M and every hint modulus m, the resolution dial of conductor M realizes exactly M/gcd(M, m) readings on a candidate set inside one hint class, and dials of coprime conductors compound multiplicatively.",
        "No-amplification dichotomy: if M* divides m the dial vector is a function of the hint, constant on the candidate set, and exactly independent of every secret even after arbitrary post-processing; if M* does not divide m the hint fails to determine the residue the dials read, so the dials are not computable by the attacker.",
        "Joint resolution cap and Coppersmith threshold: the pair (hint, dial readings) resolves the prime only modulo lcm(m, M*), so pinning it inside a window of size X forces M* at least X/m; in the Coppersmith regime X equals the square of the hint modulus, forcing M* at least m, and this threshold is attained by a resolution dial of conductor coprime to m.",
        "Counting barrier: K sign dials separate at most 3^K candidates (2^K when the readings never vanish), so pinning C candidates requires at least log_3 C dials.",
    ],
    "keywords": [
        "Coppersmith partial-key exposure",
        "Kronecker symbol",
        "conductor",
        "residue dial",
        "side-channel information bound",
        "Chinese Remainder Theorem",
        "pigeonhole principle",
        "RSA factoring",
    ],
    "article": read(ROOT / "ARTICLE.md"),
    "research_paper": read(ROOT / "RESEARCH_PAPER.md"),
    "research_paper_tex": read(ROOT / "RESEARCH_PAPER.tex"),
    "demo": read(ROOT / "demo.py"),
    "demos": [
        {
            "name": "Exhaustive Verification of the Conductor-Budget Theorems",
            "description": (
                "A self-contained verification suite for the whole theory. It implements Jacobi and "
                "Kronecker symbols from scratch, builds residue dials as genuinely periodic maps, and "
                "then checks, by exhaustive finite computation: (1) the master bound, comparing the "
                "number of distinct dial readings on a hint class with the budget M*/gcd(M*, m); "
                "(2) the sharpness of that bound for the resolution dial on the window of length "
                "lcm(M, m); (3) Chinese-Remainder independence, where two dials of coprime conductors "
                "realize all products of readings; (4) the Regime 1 instance with dials at "
                "D = -3, 21, 42 against the hint modulus 168, where the primes 28393 and 28729 receive "
                "identical readings and the dial cut removes zero candidates; (4b) exact statistical "
                "independence of the readings from four different secret statistics under four "
                "different post-processing maps; (5) the Regime 2 instance with the dial (-4 | .) "
                "against the hint modulus 135, where the primes 541 and 811 are separated, plus the "
                "universal statement that (-4 | .) separates 1 and 1 + 2m for every odd m; (6) the "
                "joint resolution cap, measuring the largest window each family actually pins and "
                "confirming it never exceeds lcm(m, M*), together with the attainment of the "
                "threshold by a resolution dial of coprime conductor; and (7) the 3^K counting "
                "barrier. Every check is asserted, so the script fails loudly if any prediction is "
                "violated."
            ),
            "code": read(ROOT / "demo.py"),
        },
        {
            "name": "Sub-Threshold Coppersmith Simulation with Honest and Oracle Attackers",
            "description": (
                "Builds a genuine semiprime N = 28393 x 28729 of size about 8.16e8, hands the attacker "
                "the partial-key hint p = 1 (mod 168) with 168 just below N^(1/4), and enumerates the "
                "57 prime candidates below N^(1/2) that match the hint. Two attackers are then run "
                "side by side. The honest attacker uses only dials it can evaluate from the hint "
                "(conductor lcm dividing m) and achieves a shrink factor of exactly 1: not one "
                "candidate is eliminated. The oracle attacker is handed the true readings of an "
                "informative family and does shrink the set, but the simulation simultaneously "
                "exhibits two integers sharing the hint yet carrying different readings, which proves "
                "no function of the hint could have produced them. The script closes with the pinning "
                "threshold for this instance: isolating the prime in the window below N^(1/2) would "
                "require a conductor lcm of at least N^(1/2)/m, that is, a second hint."
            ),
            "code": read(A / "demo2_coppersmith.py"),
        },
    ],
    "algorithms": [
        {
            "name": "Conductor-Budget Evaluation and Regime Classification",
            "description": (
                "The practical payoff of the theory: a decision procedure that rules an entire class "
                "of side channels in or out before a single dial is evaluated. Given the hint modulus "
                "m and the conductors c_1, ..., c_K of a proposed dial family, it computes the "
                "conductor least common multiple M* = lcm(c_i), the greatest common divisor "
                "g = gcd(M*, m), and the amplification budget B = M*/g, which is an a priori upper "
                "bound on the factor by which reading the dials can shrink the candidate set. It then "
                "classifies the family: Regime 1 (M* divides m) means the dial vector is a function "
                "of the hint, hence constant on the candidate set and provably information-free even "
                "after arbitrary post-processing; Regime 2 means the hint does not determine "
                "p mod M*, so the family cannot be evaluated at all. Given a target search window of "
                "size X it also reports the joint resolution cap lcm(m, M*), whether pinning inside "
                "the window is even arithmetically possible, and the conductor a family would need "
                "(at least ceil(X/m)). Complexity: O(K) gcd computations, i.e. O(K log^2 max_i c_i) "
                "bit operations; the procedure never touches N and never evaluates a Kronecker symbol."
            ),
            "pseudocode": (
                "INPUT : conductors c_1..c_K (positive integers), hint modulus m >= 1,\n"
                "        optional search window size X\n"
                "OUTPUT: conductor lcm M*, amplification budget B, regime, pinning verdict\n"
                "\n"
                "1.  M* <- 1\n"
                "2.  for i = 1..K:\n"
                "3.      M* <- M* / gcd(M*, c_i) * c_i          // running least common multiple\n"
                "4.  g <- gcd(M*, m)\n"
                "5.  B <- M* / g                                 // amplification budget\n"
                "6.  if m mod M* = 0 then\n"
                "7.      regime <- 1                             // B = 1 necessarily\n"
                "8.      report 'hint-computable: dial vector constant on the candidate set;\n"
                "               the dial cut removes nothing; zero information about every\n"
                "               secret, before and after any post-processing'\n"
                "9.  else\n"
                "10.     regime <- 2\n"
                "11.     report 'not hint-computable: evaluating the dials needs p mod M*,\n"
                "               which p mod m does not determine'\n"
                "12. if X is given then\n"
                "13.     L <- m / gcd(m, M*) * M*                // joint resolution cap\n"
                "14.     pinning_possible <- (X <= L)            // necessary condition\n"
                "15.     required_M* <- ceil(X / m)\n"
                "16.     if X = m*m then required_M* = m         // Coppersmith regime\n"
                "17. return (M*, g, B, regime, L, pinning_possible, required_M*)"
            ),
            "code": read(A / "alg1_budget.py"),
        },
        {
            "name": "Exhaustive Candidate-Set Shrinkage Simulator",
            "description": (
                "Measures the shrinkage a dial family actually achieves and compares it with the "
                "theoretical budget. The algorithm enumerates the hint class {x < X : x = r (mod m)} "
                "(optionally restricted to primes, which is the realistic candidate set in a "
                "factoring attack), evaluates the Kronecker dial vector at every candidate, groups "
                "the candidates into the fibres of the dial vector, and reports the number of "
                "distinct readings, the largest surviving fibre, the realized shrink factor, and "
                "whether the master bound holds. The largest fibre is the operative quantity: it is "
                "what an attacker is left with in the worst case, and the theory guarantees it is at "
                "least a gcd(M*, m)/M* fraction of the class. Complexity: O(|Omega| K) Kronecker "
                "evaluations, each O(log^2 c) bit operations, plus O(|Omega|) hashing; memory "
                "O(|Omega|)."
            ),
            "pseudocode": (
                "INPUT : discriminants D_1..D_K, hint modulus m, residue r, window X,\n"
                "        flag primes_only\n"
                "OUTPUT: realized shrinkage versus the amplification budget\n"
                "\n"
                "1.  M* <- lcm_i (4|D_i|);  B <- M* / gcd(M*, m)\n"
                "2.  Omega <- { x in [0, X) : x = r (mod m) }\n"
                "3.  if primes_only then Omega <- { p in Omega : p is prime }\n"
                "4.  F <- empty map from readings to lists\n"
                "5.  for p in Omega:\n"
                "6.      v <- ( Kronecker(D_i, p mod 4|D_i|) )_{i=1..K}\n"
                "7.      append p to F[v]\n"
                "8.  largest <- max_v |F[v]|\n"
                "9.  assert |keys(F)| <= B                        // master bound\n"
                "10. assert |Omega| <= B * largest                // shrinkage bound\n"
                "11. return (M*, B, |Omega|, |keys(F)|, largest, |Omega| / largest)"
            ),
            "code": read(A / "alg2_shrinkage.py"),
        },
        {
            "name": "Joint-Resolution Pinning-Threshold Test",
            "description": (
                "Determines how large a search window the pair (hint, dial readings) can possibly "
                "resolve, and what conductor a family would need to resolve a prescribed one. The "
                "theoretical content is that two candidates congruent modulo L = lcm(m, M*) produce "
                "identical hints and identical readings, so uniqueness inside a window [0, X) forces "
                "X <= L; the algorithm confirms this empirically by scanning upward from 0, hashing "
                "the joint key (x mod m, readings of x), and stopping at the first collision, which "
                "is exactly the largest pinned window. It then reports the Coppersmith requirement: "
                "with the window X = m^2 arising from p < N^(1/2) and m ~ N^(1/4), pinning forces "
                "M* >= m. Complexity: O(X K) evaluations and O(X) memory for the empirical scan; the "
                "threshold arithmetic itself is O(K) gcd computations."
            ),
            "pseudocode": (
                "INPUT : conductors c_1..c_K, hint modulus m\n"
                "OUTPUT: joint resolution cap, largest pinned window, Coppersmith requirement\n"
                "\n"
                "1.  M* <- lcm_i c_i;   L <- lcm(m, M*)\n"
                "2.  seen <- empty hash map\n"
                "3.  for x = 0, 1, 2, ... up to a search cap:\n"
                "4.      key <- ( x mod m, (x mod c_1, ..., x mod c_K) )\n"
                "5.      if key in seen then\n"
                "6.          X_pinned <- x            // window [0, x) is pinned, [0, x] is not\n"
                "7.          break\n"
                "8.      seen[key] <- x\n"
                "9.  assert X_pinned <= L             // joint resolution cap\n"
                "10. X_coppersmith <- m * m           // p < N^(1/2), m ~ N^(1/4)\n"
                "11. return (M*, L, X_pinned, X_coppersmith <= L, required M* = m)"
            ),
            "code": read(A / "alg3_pinning.py"),
        },
    ],
    "visualizations": [
        {
            "name": "Amplification-Budget Landscape over Conductor and Hint Modulus",
            "description": (
                "A heatmap of the amplification budget B(M*, m) = M*/gcd(M*, m) over all pairs of "
                "dial conductor lcm and hint modulus up to 36, on a logarithmic colour scale. The "
                "cells where M* divides m are outlined: these are the Regime 1 configurations, where "
                "the budget collapses to 1 and the dials are exactly the ones an attacker can "
                "evaluate — and exactly the ones that are provably worthless. The picture makes "
                "visible the central tension of the theory: brightness (useful) and outline "
                "(available) never coincide."
            ),
            "code": read(A / "viz1_budget_grid.py"),
        },
        {
            "name": "Candidate Survival under a Dial Cut: the Two Experimental Regimes",
            "description": (
                "A two-panel scatter comparing the experiment's own instances. The left panel shows "
                "the Regime 1 family — Kronecker dials at D = -3, 21, 42, conductors 12, 84, 168 — "
                "against the hint modulus 168: every candidate of the hint class falls into a single "
                "fibre, so the dial cut removes nothing and all candidates survive. The right panel "
                "shows the Regime 2 dial (-4 | .) of conductor 16 against the hint modulus 135: here "
                "the candidates genuinely split into fibres, which is precisely the reason the dial "
                "cannot be evaluated from the hint, since the split is governed by p mod 4 and an odd "
                "hint modulus says nothing about it. Each panel is annotated with M*, the hint "
                "modulus, the budget, and the number of fibres realized."
            ),
            "code": read(A / "viz2_survival.py"),
        },
    ],
    "interactive_demos": [
        {
            "title": "The Dial Bench: Turn the Dials and Watch the Sieve Fail",
            "description": (
                "A full laboratory for the theory in a single page. Choose a hint modulus and residue, "
                "toggle any subset of sixteen discriminants to build a Kronecker dial family, and the "
                "bench instantly computes the conductor least common multiple, the greatest common "
                "divisor with the hint modulus, the amplification budget, and the regime. A canvas "
                "displays the candidate set of the hint class, grouped and coloured by dial reading, "
                "so you can literally see the fibres — and see them collapse into a single column the "
                "moment the conductor lcm divides the hint modulus. A live table re-checks five "
                "theorems on your configuration: the master bound, the shrinkage bound, the Regime 1 "
                "constancy statement, the joint resolution cap against the Coppersmith window m^2, and "
                "the threshold M* >= m. Four presets reproduce the instances of the experiment, "
                "including the Regime 1 family at D = -3, 21, 42 against m = 168 and the Regime 2 dial "
                "(-4 | .) against m = 135. Collapsible panels give the three-line proof of the master "
                "bound, the computability dichotomy, and the pinning threshold."
            ),
            "html": read(A / "widget_dial_bench.html"),
        },
        {
            "title": "The Resolution Lattice: What the Hint and the Dials Jointly See",
            "description": (
                "A geometric view of why the budget is what it is. Two sliders set the hint modulus m "
                "and the dial conductor lcm M*; the widget draws the grid of pairs (p mod m, p mod M*) "
                "and highlights exactly those cells that some integer actually realizes — the image of "
                "the Chinese Remainder map, of size lcm(m, M*). One row is the hint class: it meets "
                "exactly M*/gcd(m, M*) reachable cells, which is the amplification budget, and when M* "
                "divides m the row shrinks to a single cell, the visual form of the statement that the "
                "dials are constant on the candidate set. The total number of occupied cells is the "
                "joint resolution, so any window longer than that necessarily contains two candidates "
                "with identical hint and identical readings — the pinning cap, made visible."
            ),
            "html": read(A / "widget_crt_lattice.html"),
        },
    ],
    "interactive_layout": INTERACTIVE_LAYOUT,
    "lean_proofs": lean_proofs,
    "future_directions": FUTURE,
    "modules": {
        "demo": read(ROOT / "demo.py"),
        "coppersmith_simulation": read(A / "demo2_coppersmith.py"),
        "budget_classifier": read(A / "alg1_budget.py"),
        "shrinkage_simulator": read(A / "alg2_shrinkage.py"),
        "pinning_threshold": read(A / "alg3_pinning.py"),
    },
    "lean_files": LEAN_FILES,
}

out = ROOT / "PACKAGE.json"
out.write_text(json.dumps(package, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print(f"wrote {out} ({out.stat().st_size} bytes)")


"""A sub-threshold Coppersmith simulation: dials against a real candidate set.

We build a genuine semiprime N = p*q, hand the attacker a partial-key hint
p = r (mod m) with m just below the Coppersmith scale N^{1/4}, and then let the
attacker try to sieve the resulting candidate set with residue dials.

Two attackers are simulated.

  * The HONEST attacker uses only dials whose conductor lcm M* divides m -- the
    ones it can actually evaluate from the hint.  Theory predicts the candidate
    set does not shrink at all.  The simulation confirms it exactly.

  * The ORACLE attacker is granted the true readings of an informative dial
    (conductor not dividing m).  The candidate set does shrink -- but the
    simulation also exhibits two integers sharing the hint with different
    readings, which is a proof that no function of the hint could have produced
    those readings.  The oracle attacker's advantage is not obtainable.

Finally we display the pinning threshold: to isolate the prime inside the
window [0, N^{1/2}) the joint statistic would need lcm(m, M*) >= N^{1/2}, hence
M* >= N^{1/2}/m ~ N^{1/4} -- a second hint.
"""

from __future__ import annotations

from math import gcd, isqrt
from typing import Dict, List, Sequence, Tuple

Reading = Tuple[int, ...]


def lcm(a: int, b: int) -> int:
    """Least common multiple of two positive integers."""
    return a // gcd(a, b) * b


def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test."""
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    return all(n % d for d in range(3, isqrt(n) + 1, 2))


def jacobi(a: int, n: int) -> int:
    """Jacobi symbol (a | n) for odd n >= 1."""
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


def kronecker(a: int, n: int) -> int:
    """Kronecker symbol (a | n) for n >= 0."""
    if n == 0:
        return 1 if a in (1, -1) else 0
    sign, e = 1, 0
    while n % 2 == 0:
        n //= 2
        e += 1
    if e:
        if a % 2 == 0:
            return 0
        sign *= (1 if a % 8 in (1, 7) else -1) ** e
    return sign * jacobi(a, n) if n > 1 else sign


def dial_vector(discs: Sequence[int], p: int) -> Reading:
    """Reading of a Kronecker dial family at the candidate p."""
    return tuple(kronecker(D, p % (4 * abs(D))) for D in discs)


def cond_lcm(discs: Sequence[int]) -> int:
    """M* = lcm_i 4|D_i|."""
    out = 1
    for D in discs:
        out = lcm(out, 4 * abs(D))
    return out


def sieve_report(discs: Sequence[int], candidates: Sequence[int], truth: int,
                 m: int) -> Dict[str, object]:
    """Shrinkage achieved by filtering candidates on the true dial reading."""
    v = dial_vector(discs, truth)
    survivors = [p for p in candidates if dial_vector(discs, p) == v]
    Ms = cond_lcm(discs)
    return {
        "discriminants": list(discs),
        "M_star": Ms,
        "budget": Ms // gcd(Ms, m),
        "before": len(candidates),
        "after": len(survivors),
        "shrink_factor": len(candidates) / len(survivors),
        "hint_computable": (m % Ms == 0),
    }


def non_computability_witness(discs: Sequence[int], m: int) -> Tuple[int, int] | None:
    """Two integers with the same hint but different readings, if any."""
    Ms = cond_lcm(discs)
    bound = lcm(m, Ms)
    seen: Dict[int, Tuple[int, Reading]] = {}
    for x in range(bound + m):
        key = x % m
        v = dial_vector(discs, x)
        if key in seen and seen[key][1] != v:
            return seen[key][0], x
        seen.setdefault(key, (x, v))
    return None


def main() -> None:
    p, q = 28393, 28729                     # both prime, both = 1 (mod 168)
    N = p * q
    m = 168                                 # the partial-key hint modulus
    r = p % m
    root = isqrt(N)

    print("=" * 76)
    print("SUB-THRESHOLD COPPERSMITH SIMULATION")
    print("=" * 76)
    print(f"  N = p*q = {N}   (~{N:.3e}),  N^(1/2) ~ {root}")
    print(f"  secret prime p = {p} (prime: {is_prime(p)}),  q = {q}")
    print(f"  hint: p = {r} (mod {m}),   m ~ N^(1/4) = {round(N ** 0.25)}")

    candidates: List[int] = [x for x in range(r, root + 1, m) if is_prime(x)]
    print(f"  prime candidates in [0, N^(1/2)) matching the hint: {len(candidates)}")
    assert p in candidates

    print("\n  HONEST attacker -- dials computable from the hint (M* | m):")
    honest = sieve_report([-3, 21, 42], candidates, p, m)
    for k, v in honest.items():
        print(f"    {k:>18}: {v}")
    assert honest["after"] == honest["before"]
    print("    => the dial cut removed NOTHING: budget 1, exactly as predicted.")

    print("\n  ORACLE attacker -- an informative dial (M* does not divide m):")
    oracle = sieve_report([-4, 5], candidates, p, m)
    for k, v in oracle.items():
        print(f"    {k:>18}: {v}")
    w = non_computability_witness([-4, 5], m)
    assert w is not None
    a, b = w
    print(f"    but {a} and {b} share the hint ({a % m} mod {m}) and read")
    print(f"    {dial_vector([-4, 5], a)} vs {dial_vector([-4, 5], b)}:")
    print("    no function of the hint can produce these readings -- the oracle")
    print("    attacker's advantage is not obtainable from public data.")

    print("\n  PINNING THRESHOLD for this instance:")
    for discs in ([-3, 21, 42], [-4, 5], [-3, -4, 5, -7, 8, -11]):
        Ms = cond_lcm(discs)
        cap = lcm(m, Ms)
        print(f"    dials {str(discs):<26} M* = {Ms:>6}, lcm(m, M*) = {cap:>8}, "
              f"pins window {root}? {cap >= root}")
    print(f"    required M* to pin [0, N^(1/2)):  >= {-(-root // m)} "
          f"(~ N^(1/4) = {round(N ** 0.25)}) -- i.e. a second hint.")
    print("=" * 76)


if __name__ == "__main__":
    main()


"""Visualization: the amplification budget as a function of (M*, m).

Draws a heatmap of the budget B(M*, m) = M*/gcd(M*, m) -- the maximum factor by
which a dial family of conductor lcm M* can shrink a candidate set inside a hint
class mod m -- and highlights the Regime 1 cells (M* | m), where the budget
collapses to 1 and the dials are provably worthless.
"""

from __future__ import annotations

from math import gcd

import matplotlib.pyplot as plt
import numpy as np


def budget(M_star: int, m: int) -> int:
    """Amplification budget M*/gcd(M*, m)."""
    return M_star // gcd(M_star, m)


def main() -> None:
    m_max, M_max = 36, 36
    ms = np.arange(1, m_max + 1)
    Ms = np.arange(1, M_max + 1)
    grid = np.array([[budget(int(M), int(m)) for m in ms] for M in Ms], dtype=float)

    fig, ax = plt.subplots(figsize=(9.0, 7.4))
    im = ax.imshow(np.log10(grid), origin="lower", cmap="magma",
                   extent=(0.5, m_max + 0.5, 0.5, M_max + 0.5), aspect="auto")
    cb = fig.colorbar(im, ax=ax)
    cb.set_label(r"$\log_{10}$ amplification budget  $M^*/\gcd(M^*,m)$")

    # Mark the Regime 1 cells: M* | m  =>  budget 1  =>  zero amplification.
    xs, ys = [], []
    for M in Ms:
        for m in ms:
            if m % M == 0:
                xs.append(m)
                ys.append(M)
    ax.scatter(xs, ys, s=14, marker="s", facecolors="none", edgecolors="cyan",
               linewidths=0.8, label=r"Regime 1: $M^*\mid m$ (budget $=1$)")

    ax.set_xlabel("hint modulus  $m$")
    ax.set_ylabel("dial conductor lcm  $M^*$")
    ax.set_title("Amplification budget of a residue-dial family\n"
                 "cyan cells: dials computable from the hint, hence information-free")
    ax.legend(loc="lower right", framealpha=0.9)
    fig.tight_layout()
    fig.savefig("budget_grid.png", dpi=160)
    print("wrote budget_grid.png")


if __name__ == "__main__":
    main()


"""Visualization: candidate survival under a dial cut, Regime 1 versus Regime 2.

Left panel: the experiment's Regime 1 instance -- Kronecker dials at
D = -3, 21, 42 (conductors 12, 84, 168) against the hint modulus m = 168.  The
conductor lcm is 168, which divides m, so every candidate of the hint class
carries the same reading and the dial cut removes nothing.

Right panel: the Regime 2 instance -- the single dial (-4 | .) of conductor 16
against m = 135.  The readings do split the candidates, which is exactly why the
dial is not computable from the hint: an attacker holding only p mod 135 cannot
tell which column a candidate falls into.
"""

from __future__ import annotations

from math import gcd
from typing import Dict, List, Sequence, Tuple

import matplotlib.pyplot as plt


def jacobi(a: int, n: int) -> int:
    """Jacobi symbol (a | n) for odd n >= 1."""
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


def kronecker(a: int, n: int) -> int:
    """Kronecker symbol (a | n) for n >= 0."""
    if n == 0:
        return 1 if a in (1, -1) else 0
    sign, e = 1, 0
    while n % 2 == 0:
        n //= 2
        e += 1
    if e:
        if a % 2 == 0:
            return 0
        sign *= (1 if a % 8 in (1, 7) else -1) ** e
    return sign * jacobi(a, n) if n > 1 else sign


def readings(discs: Sequence[int], p: int) -> Tuple[int, ...]:
    """Dial vector of the Kronecker family at p."""
    return tuple(kronecker(D, p % (4 * abs(D))) for D in discs)


def fibres(discs: Sequence[int], m: int, r: int, count: int
           ) -> Dict[Tuple[int, ...], List[int]]:
    """Group the first `count` candidates of the hint class by dial reading."""
    out: Dict[Tuple[int, ...], List[int]] = {}
    p = r % m
    while sum(len(v) for v in out.values()) < count:
        out.setdefault(readings(discs, p), []).append(p)
        p += m
    return out


def panel(ax, discs: Sequence[int], m: int, title: str, count: int = 120) -> None:
    f = fibres(discs, m, 1, count)
    Ms = 1
    for D in discs:
        c = 4 * abs(D)
        Ms = Ms // gcd(Ms, c) * c
    keys = sorted(f, key=lambda k: (-len(f[k]), k))
    colors = plt.cm.viridis([i / max(1, len(keys) - 1) for i in range(len(keys))])
    for col, (k, color) in enumerate(zip(keys, colors)):
        pts = f[k]
        ax.scatter([col] * len(pts), pts, s=18, color=color)
        ax.annotate(f"{len(pts)}", (col, max(pts)), textcoords="offset points",
                    xytext=(0, 8), ha="center", fontsize=9)
    ax.set_xticks(range(len(keys)))
    ax.set_xticklabels([str(k) for k in keys], fontsize=8, rotation=30)
    ax.set_xlabel("dial reading (fibre)")
    ax.set_ylabel("candidate value")
    ax.set_title(f"{title}\n$M^*={Ms}$, $m={m}$, budget $={Ms // gcd(Ms, m)}$, "
                 f"fibres realized $={len(keys)}$")


def main() -> None:
    fig, axes = plt.subplots(1, 2, figsize=(12.5, 6.2))
    panel(axes[0], [-3, 21, 42], 168,
          "Regime 1: computable, hence useless\n(all candidates survive the cut)")
    panel(axes[1], [-4], 135,
          "Regime 2: informative, hence unavailable\n(the split needs $p$ mod $4$)")
    fig.suptitle("Candidate survival under a residue-dial cut", fontsize=13)
    fig.tight_layout()
    fig.savefig("dial_survival.png", dpi=160)
    print("wrote dial_survival.png")


if __name__ == "__main__":
    main()
