"""
ECM-PARITY: numerical demonstration of the parity law for the order of the
elliptic curve  E0 : y^2 = x^3 + x + 1  over finite prime fields.

Everything in this file is self-contained (standard library only).

The mathematics demonstrated here:

  (1) PARITY DICHOTOMY.  For an odd prime p and a separable depressed cubic
      f(x) = x^3 + A x + B over F_p, the projective point count

          #E(F_p) = 1 + #{(x, y) in F_p^2 : y^2 = f(x)}

      is even if and only if f has a root in F_p.

  (2) CUBIC PARITY LAW (Stickelberger).  Writing D = -4A^3 - 27B^2, the
      discriminant D is a non-square mod p exactly when f has precisely one
      root, i.e. exactly when the Frobenius acts on the three geometric roots
      as a transposition.  Consequently (D|p) = -1 forces 2 | #E(F_p).

  (3) SYMMETRIC JACOBI SHADOW.  For E0 one has D = -31, and by quadratic
      reciprocity (-31|p) = (p mod 31 | 31).  Hence for a semiprime N = p q,
      the Jacobi symbol (N|31) = -1 forces the order of E0 to be even at p or
      at q -- a residue condition on N alone, with conditional probability
      exactly 1.

  (4) THE ORDER MOD 4.  Three rational roots force 4 | #E.  With a unique
      rational root a, #E = 2 (mod 4) if and only if k = 3a^2 + A is a
      non-square mod p; p = 23 is an explicit case where k IS a square and
      #E0(F_23) = 28 = 0 (mod 4).

  (5) CLASS FIELD DICTIONARY.  The cubic x^3 + x + 1 splits completely mod p
      if and only if 4p = A^2 + 31 B^2 for integers A, B of equal parity.

  (6) JENSEN DEFICIT.  For a fork with class-wise even-order rates theta_i,
      the union probability equals its "flat" value minus exactly the variance
      of the fork.
"""

from __future__ import annotations

import math
import random
from typing import Dict, Iterable, List, Optional, Tuple

# ----------------------------------------------------------------------------
# Basic arithmetic helpers
# ----------------------------------------------------------------------------


def primes_up_to(n: int) -> List[int]:
    """All primes <= n by a simple sieve of Eratosthenes."""
    sieve = bytearray([1]) * (n + 1)
    sieve[0:2] = b"\x00\x00"
    for i in range(2, int(n**0.5) + 1):
        if sieve[i]:
            sieve[i * i :: i] = bytearray(len(sieve[i * i :: i]))
    return [i for i in range(n + 1) if sieve[i]]


def legendre(a: int, p: int) -> int:
    """Legendre symbol (a|p) for an odd prime p, valued in {-1, 0, 1}."""
    a %= p
    if a == 0:
        return 0
    t = pow(a, (p - 1) // 2, p)
    return 1 if t == 1 else -1


def jacobi(a: int, n: int) -> int:
    """Jacobi symbol (a|n) for odd n > 0, valued in {-1, 0, 1}."""
    assert n > 0 and n % 2 == 1
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


# ----------------------------------------------------------------------------
# Curve arithmetic:  y^2 = x^3 + A x + B  over F_p
# ----------------------------------------------------------------------------


def cubic_disc(A: int, B: int) -> int:
    """Discriminant -4A^3 - 27B^2 of the depressed cubic x^3 + A x + B."""
    return -4 * A**3 - 27 * B**2


def curve_card(A: int, B: int, p: int) -> int:
    """Projective point count of y^2 = x^3 + A x + B over F_p (p odd)."""
    total = 1  # the point at infinity
    for x in range(p):
        fx = (x * x % p * x + A * x + B) % p
        total += 1 + legendre(fx, p)
    return total


def root_set(A: int, B: int, p: int) -> List[int]:
    """The roots of x^3 + A x + B in F_p."""
    return [x for x in range(p) if (x * x % p * x + A * x + B) % p == 0]


def frobenius_cycle_type(A: int, B: int, p: int) -> str:
    """Cycle type of Frobenius on the roots: '[1,1,1]', '[1]' or '[3]'."""
    r = len(root_set(A, B, p))
    return {3: "[1,1,1]", 1: "[1]", 0: "[3]"}[r]


# ----------------------------------------------------------------------------
# (1) + (2)  Parity dichotomy and the cubic parity law
# ----------------------------------------------------------------------------


def check_parity_dichotomy(A: int, B: int, bound: int) -> Tuple[int, int]:
    """Check '2 | #E  <=>  the cubic has a root' for all good primes <= bound."""
    checked = failures = 0
    D = cubic_disc(A, B)
    for p in primes_up_to(bound):
        if p == 2 or D % p == 0:
            continue
        even = curve_card(A, B, p) % 2 == 0
        has_root = len(root_set(A, B, p)) > 0
        checked += 1
        failures += int(even != has_root)
    return checked, failures


def check_stickelberger(A: int, B: int, bound: int) -> Tuple[int, int]:
    """Check '(D|p) = -1  <=>  exactly one rational root'."""
    checked = failures = 0
    D = cubic_disc(A, B)
    for p in primes_up_to(bound):
        if p == 2 or D % p == 0:
            continue
        checked += 1
        failures += int((legendre(D, p) == -1) != (len(root_set(A, B, p)) == 1))
    return checked, failures


# ----------------------------------------------------------------------------
# (3)  The symmetric Jacobi shadow and its information content
# ----------------------------------------------------------------------------


def entropy(probabilities: Iterable[float]) -> float:
    """Shannon entropy in bits."""
    return -sum(q * math.log2(q) for q in probabilities if q > 0)


def mutual_information(pairs: List[Tuple[int, int]]) -> float:
    """Mutual information I(X;Y) in bits of an empirical sample of (x, y)."""
    n = len(pairs)
    joint: Dict[Tuple[int, int], int] = {}
    px: Dict[int, int] = {}
    py: Dict[int, int] = {}
    for x, y in pairs:
        joint[(x, y)] = joint.get((x, y), 0) + 1
        px[x] = px.get(x, 0) + 1
        py[y] = py.get(y, 0) + 1
    total = 0.0
    for (x, y), c in joint.items():
        pxy = c / n
        total += pxy * math.log2(pxy / ((px[x] / n) * (py[y] / n)))
    return total


def semiprime_sample(
    primes: List[int], size: int, seed: int = 404
) -> List[Tuple[int, int]]:
    """A reproducible random sample of ordered prime pairs (p, q), p != q."""
    rng = random.Random(seed)
    out: List[Tuple[int, int]] = []
    while len(out) < size:
        p = rng.choice(primes)
        q = rng.choice(primes)
        if p != q:
            out.append((p, q))
    return out


# ----------------------------------------------------------------------------
# (5)  Class field dictionary:  4p = A^2 + 31 B^2
# ----------------------------------------------------------------------------


def represented_by_principal_form(p: int, ell: int = 31) -> Optional[Tuple[int, int]]:
    """Return (A, B) with 4p = A^2 + ell*B^2, A = B (mod 2), if it exists."""
    limit = int(math.isqrt(4 * p // ell)) + 1
    for B in range(limit + 1):
        rest = 4 * p - ell * B * B
        if rest < 0:
            continue
        A = math.isqrt(rest)
        if A * A == rest and (A - B) % 2 == 0:
            return (A, B)
    return None


# ----------------------------------------------------------------------------
# (6)  The Jensen deficit identity
# ----------------------------------------------------------------------------


def jensen_report(theta: List[float]) -> Tuple[float, float, float]:
    """Union probability, its flat value, and the variance of the fork."""
    n = len(theta)
    mean = sum(theta) / n
    union = 1.0 - sum((1.0 - t) ** 2 for t in theta) / n
    flat = 1.0 - (1.0 - mean) ** 2
    var = sum((t - mean) ** 2 for t in theta) / n
    return union, flat, var


# ----------------------------------------------------------------------------
# Driver
# ----------------------------------------------------------------------------


def channel_constants() -> Dict[str, float]:
    """Exact information content of the two residue channels, in bits.

    Single prime:  X = (p|31) in {-1,+1} (each with density 1/2),
                   Y = [2 | #E0(F_p)];  P(Y|X=-1) = 1, P(Y|X=+1) = 1/3.
    Semiprime:     X = (N|31) = (p|31)(q|31),  Y = [2 | #E0(F_p) or 2 | #E0(F_q)];
                   P(Y|X=-1) = 1, P(Y|X=+1) = 7/9.
    """

    def h(x: float) -> float:
        return entropy([x, 1.0 - x])

    single = h(2 / 3) - 0.5 * h(1 / 3)
    semi = h(8 / 9) - 0.5 * h(7 / 9)
    return {"single prime channel": single, "semiprime channel": semi}


def main() -> None:
    A0, B0 = 1, 1  # the generic ECM curve E0 : y^2 = x^3 + x + 1, D = -31
    A1, B1 = -1, 1  # the robustness curve E1 : y^2 = x^3 - x + 1, D = -23
    D0, D1 = cubic_disc(A0, B0), cubic_disc(A1, B1)
    print(f"E0 : y^2 = x^3 + x + 1     discriminant {D0}")
    print(f"E1 : y^2 = x^3 - x + 1     discriminant {D1}")

    print("\n=== (1) Parity dichotomy: 2 | #E  <=>  the cubic has a root ===")
    for (A, B, name) in ((A0, B0, "E0"), (A1, B1, "E1")):
        checked, bad = check_parity_dichotomy(A, B, 2000)
        print(f"  {name}: {checked} primes checked, {bad} failures")

    print("\n=== (2) Cubic parity law: (D|p) = -1  <=>  exactly one root ===")
    for (A, B, name) in ((A0, B0, "E0"), (A1, B1, "E1")):
        checked, bad = check_stickelberger(A, B, 2000)
        print(f"  {name}: {checked} primes checked, {bad} failures")

    print("\n=== Densities of the three Frobenius faces for E0 (p < 20000) ===")
    good = [p for p in primes_up_to(20000) if p not in (2, 31)]
    faces = {"[1,1,1]": 0, "[1]": 0, "[3]": 0}
    even_all = even_pos = pos = 0
    for p in good:
        t = frobenius_cycle_type(A0, B0, p)
        faces[t] += 1
        is_even = t != "[3]"
        even_all += int(is_even)
        if legendre(D0, p) == 1:
            pos += 1
            even_pos += int(is_even)
    n = len(good)
    print(f"  sample size                              {n}")
    for t in ("[1,1,1]", "[1]", "[3]"):
        print(f"  P(Frobenius = {t:<8})                {faces[t] / n:.4f}"
              f"   (theory {[1/6, 1/2, 1/3][['[1,1,1]', '[1]', '[3]'].index(t)]:.4f})")
    print(f"  P(2 | #E0)                               {even_all / n:.4f}"
          f"   (theory {2/3:.4f})")
    print(f"  P(2 | #E0 | (D|p) = -1)                  1.0000   (a theorem)")
    print(f"  P(2 | #E0 | (D|p) = +1)                  {even_pos / pos:.4f}"
          f"   (theory {1/3:.4f})")

    print("\n=== (4) The order mod 4 ===")
    bad4 = 0
    split_not_div4 = 0
    for p in good:
        roots = root_set(A0, B0, p)
        card = curve_card(A0, B0, p)
        if len(roots) == 3:
            split_not_div4 += int(card % 4 != 0)
        elif len(roots) == 1:
            a = roots[0]
            k = (3 * a * a + A0) % p
            predicted = 0 if legendre(k, p) == 1 else 2
            bad4 += int(card % 4 != predicted)
    print(f"  split face [1,1,1]: violations of 4 | #E      {split_not_div4}")
    print(f"  unique-root face [1]: violations of the k-law {bad4}")
    a23 = root_set(A0, B0, 23)
    print(f"  counterexample to a blanket '#E = 2 (mod 4)' on the [1] face:")
    print(f"    p = 23, unique root a = {a23[0]}, k = 3a^2+1 = "
          f"{(3 * a23[0] ** 2 + 1) % 23} mod 23, (k|23) = "
          f"{legendre(3 * a23[0] ** 2 + 1, 23)}, #E0(F_23) = {curve_card(1, 1, 23)}")

    print("\n=== (5) Class field: [1,1,1]  <=>  4p = A^2 + 31 B^2 ===")
    mism = tested = 0
    for p in good:
        split = frobenius_cycle_type(A0, B0, p) == "[1,1,1]"
        rep = represented_by_principal_form(p, 31) is not None
        tested += 1
        mism += int(split != rep)
    print(f"  {tested} primes tested, {mism} mismatches")
    for p in good[:400]:
        if frobenius_cycle_type(A0, B0, p) == "[1,1,1]":
            A, B = represented_by_principal_form(p, 31)  # type: ignore[misc]
            print(f"    first split prime p = {p}: 4p = {A}^2 + 31*{B}^2 = {4 * p}")
            break

    print("\n=== (3) The symmetric residue shadow on semiprimes ===")
    sample_primes = [p for p in primes_up_to(60000) if p not in (2, 31)]
    sample = semiprime_sample(sample_primes, 40000)
    even_cache: Dict[int, bool] = {}

    def is_even_order(p: int) -> bool:
        if p not in even_cache:
            even_cache[p] = len(root_set(A0, B0, p)) > 0
        return even_cache[p]

    pairs_res: List[Tuple[int, int]] = []
    pairs_jac: List[Tuple[int, int]] = []
    or_given_minus = [0, 0]
    or_given_plus = [0, 0]
    for p, q in sample:
        N = p * q
        y = int(is_even_order(p) or is_even_order(q))
        pairs_res.append((N % 31, y))
        j = jacobi(N, 31)
        pairs_jac.append((j, y))
        if j == -1:
            or_given_minus[0] += y
            or_given_minus[1] += 1
        else:
            or_given_plus[0] += y
            or_given_plus[1] += 1
    i_res = mutual_information(pairs_res)
    i_jac = mutual_information(pairs_jac)
    print(f"  sample of {len(sample)} semiprimes N = p q")
    print(f"  I(N mod 31 ; even order at p or q)   = {i_res:.4f} bits")
    print(f"  I(Jacobi (N|31) ; same event)        = {i_jac:.4f} bits")
    print(f"  residual beyond the Jacobi symbol     = {i_res - i_jac:.4f} bits")
    print(f"  P(OR | (N|31) = -1)                   = "
          f"{or_given_minus[0] / or_given_minus[1]:.4f}   (a theorem: exactly 1)")
    print(f"  P(OR | (N|31) = +1)                   = "
          f"{or_given_plus[0] / or_given_plus[1]:.4f}   (flat value 7/9 = {7/9:.4f})")

    print("\n=== (6) The Jensen deficit of the split/non-split fork ===")
    theta: Dict[int, List[int]] = {}
    for p in [x for x in primes_up_to(200000) if x not in (2, 31)]:
        if legendre(D0, p) != 1:
            continue
        c = p % 31
        theta.setdefault(c, [0, 0])
        theta[c][0] += int(frobenius_cycle_type(A0, B0, p) == "[1,1,1]")
        theta[c][1] += 1
    rates = sorted(v[0] / v[1] for v in theta.values())
    union, flat, var = jensen_report(rates)
    print(f"  {len(rates)} quadratic-residue classes mod 31")
    print(f"  per-class split rates range over [{rates[0]:.3f}, {rates[-1]:.3f}]")
    print(f"  mean split rate                {sum(rates) / len(rates):.4f}"
          f"   (theory 1/3)")
    print(f"  union probability              {union:.4f}")
    print(f"  flat value 1-(1-mean)^2        {flat:.4f}")
    print(f"  variance of the fork           {var:.4f}")
    print(f"  identity  flat - union - var = {flat - union - var:.2e}")

    print("\n=== (7) Exact information content of the residue channels ===")
    for name, value in channel_constants().items():
        print(f"  {name:<24} {value:.4f} bits")
    print("  the semiprime channel is symmetric: it never says WHICH factor")


if __name__ == "__main__":
    main()
