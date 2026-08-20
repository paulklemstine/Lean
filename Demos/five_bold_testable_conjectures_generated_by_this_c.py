"""
Denominator primes of multiples of points on Mordell curves E_N : y^2 = x^3 + N.

This self-contained script demonstrates, numerically, every result of the
accompanying paper on the quadrupling ("layer 4") stratum:

  1. The key polynomial identity
         (x^4 - 8Nx)^3 + 64N (x^3 + N)^3 = (x^6 + 20N x^3 - 8N^2)^2 .
  2. The quadrupling formula
         x(4P) = phi4(N,x) / ( 16 (x^3+N) S(N,x)^2 ),
     checked against exact rational chord-and-tangent arithmetic.
  3. The layer-4 denominator criterion: for a prime l >= 5 with l does not divide N,
         l | den x(4P)  <=>  l | Psi4(N,x) = (x^3+N)(x^6+20N x^3 - 8N^2).
  4. Non-cancellation: on the branch x^3 = -N the numerator reduces to
     -3^8 N^5 x, and on the branch S = 0 to -2^6 3^2 N (x^4-8Nx)(x^3+N)^3 --
     constants built out of the primes 2 and 3 only.
  5. The class-count dichotomy
         sum_c #V4(c) = 3l - 2   if 3 is a square mod l,
                      = l        otherwise,
     with 3 a square mod l exactly for l = +-1 (mod 12).
  6. Layer 4 activates no new residues: V4(c) nonempty <=> V2(c) nonempty,
     via the hidden cube root ((-1-g)/2 * t)^3 = -c where g^2 = 3.
  7. The information barrier: for a semiprime N = pq with p,q > B there is a
     prime M with identical layer-2/3/4 criteria at all primes l <= B.

Run with:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from math import factorial
from typing import Dict, List, Optional, Tuple

# ---------------------------------------------------------------------------
# Basic number theory helpers
# ---------------------------------------------------------------------------


def is_prime(n: int) -> bool:
    """Deterministic Miller-Rabin, correct for all n < 3.3 * 10^24."""
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


def factorize(n: int) -> Dict[int, int]:
    """Trial-division factorisation, adequate for the sizes used here."""
    n = abs(n)
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


def fmt_factorization(n: int) -> str:
    """Pretty-print a factorisation such as 2^4 * 7^2 * 827 * 1583."""
    if n == 0:
        return "0"
    sign = "-" if n < 0 else ""
    parts = [f"{p}^{e}" if e > 1 else f"{p}" for p, e in sorted(factorize(n).items())]
    return sign + (" * ".join(parts) if parts else "1")


def is_square_mod(a: int, l: int) -> bool:
    """Euler's criterion for an odd prime l."""
    a %= l
    if a == 0:
        return True
    return pow(a, (l - 1) // 2, l) == 1


# ---------------------------------------------------------------------------
# The Mordell curve and exact rational group law
# ---------------------------------------------------------------------------

Point = Optional[Tuple[Fraction, Fraction]]  # None is the point at infinity


def on_curve(N: int, P: Point) -> bool:
    if P is None:
        return True
    x, y = P
    return y * y == x * x * x + N


def double_point(N: int, P: Point) -> Point:
    """Tangent-line doubling on y^2 = x^3 + N."""
    if P is None:
        return None
    x, y = P
    if y == 0:
        return None
    lam = Fraction(3 * x * x, 1) / (2 * y)
    x2 = lam * lam - 2 * x
    y2 = lam * (x - x2) - y
    return (x2, y2)


def multiple_x_denominator(N: int, P: Point, n: int) -> int:
    """Denominator of x(nP) computed by repeated doubling (n a power of two)."""
    assert n & (n - 1) == 0 and n >= 1, "n must be a power of two"
    Q = P
    k = n
    while k > 1:
        Q = double_point(N, Q)
        k //= 2
    assert Q is not None
    return Q[0].denominator


# ---------------------------------------------------------------------------
# The layer polynomials
# ---------------------------------------------------------------------------


def psi2_locus(N: int, x: int) -> int:
    """Layer-2 criterion polynomial x^3 + N."""
    return x**3 + N


def psi3_locus(N: int, x: int) -> int:
    """Layer-3 criterion polynomial 3x^4 + 12Nx = 3x(x^3 + 4N)."""
    return 3 * x**4 + 12 * N * x


def sextic(N: int, x: int) -> int:
    """The new layer-4 factor S(N,x) = x^6 + 20N x^3 - 8N^2."""
    return x**6 + 20 * N * x**3 - 8 * N**2


def Psi4(N: int, x: int) -> int:
    """Layer-4 criterion polynomial (x^3+N) S(N,x) = x^9+21Nx^6+12N^2x^3-8N^3."""
    return (x**3 + N) * sextic(N, x)


def phi4(N: int, x: int) -> int:
    """Numerator of x(4P)."""
    A = x**4 - 8 * N * x
    return A * (A**3 - 512 * N * (x**3 + N) ** 3)


def den4(N: int, x: int) -> int:
    """Denominator of x(4P) before cancellation: 16 (x^3+N) S(N,x)^2."""
    return 16 * (x**3 + N) * sextic(N, x) ** 2


# ---------------------------------------------------------------------------
# 1. The key identity
# ---------------------------------------------------------------------------


def demo_key_identity() -> None:
    print("=" * 78)
    print("1. KEY IDENTITY   (x^4-8Nx)^3 + 64N(x^3+N)^3 = (x^6+20Nx^3-8N^2)^2")
    print("=" * 78)
    ok = True
    for N in range(-6, 7):
        for x in range(-6, 7):
            lhs = (x**4 - 8 * N * x) ** 3 + 64 * N * (x**3 + N) ** 3
            rhs = sextic(N, x) ** 2
            ok &= lhs == rhs
    print(f"   verified on all (N,x) in [-6,6]^2 : {ok}")
    N, x = 55, 9
    print(f"   at N={N}, x={x}:  S = {sextic(N,x)} = {fmt_factorization(sextic(N,x))}")
    print(f"   and indeed (x^4-8Nx)^3 + 64N(x^3+N)^3 = S^2 = {sextic(N,x)**2}")
    print()


# ---------------------------------------------------------------------------
# 2. Quadrupling formula against exact group law
# ---------------------------------------------------------------------------


def demo_quadrupling_formula() -> None:
    print("=" * 78)
    print("2. QUADRUPLING FORMULA  x(4P) = phi4 / (16 (x^3+N) S^2)")
    print("=" * 78)
    samples: List[Tuple[int, int, int]] = [
        (55, 9, 28),  # 28^2 = 9^3 + 55
        (2, -1, 1),  # 1 = -1 + 2
        (17, 2, 5),  # 25 = 8 + 17
        (-2, 3, 5),  # 25 = 27 - 2
        (24, 1, 5),  # 25 = 1 + 24
    ]
    for N, x, y in samples:
        P = (Fraction(x), Fraction(y))
        assert on_curve(N, P), (N, x, y)
        Q4 = double_point(N, double_point(N, P))
        assert Q4 is not None
        predicted = Fraction(phi4(N, x), den4(N, x))
        status = "OK" if Q4[0] == predicted else "MISMATCH"
        print(f"   N={N:>4}  P=({x},{y})   x(4P) = {Q4[0]}   [{status}]")
    print()


# ---------------------------------------------------------------------------
# 3. + 4. The layer-4 criterion and non-cancellation
# ---------------------------------------------------------------------------


def layer4_predicted_primes(N: int, x: int, bound: int) -> List[int]:
    """All good primes 5 <= l <= bound with l | Psi4(N,x) and l does not divide N."""
    value = Psi4(N, x)
    return [
        l
        for l in range(5, bound + 1)
        if is_prime(l) and N % l != 0 and value % l == 0
    ]


def demo_criterion_running_example() -> None:
    print("=" * 78)
    print("3. LAYER-4 CRITERION,  RUNNING EXAMPLE  N = 55,  P = (9,28)")
    print("=" * 78)
    N, x, y = 55, 9, 28
    P = (Fraction(x), Fraction(y))
    assert on_curve(N, P)

    for n, poly, name in ((2, psi2_locus, "x^3+N"), (3, psi3_locus, "3x(x^3+4N)"),
                          (4, Psi4, "(x^3+N)(x^6+20Nx^3-8N^2)")):
        v = poly(N, x)
        good = [l for l in factorize(v) if l >= 5 and N % l != 0]
        print(f"   layer {n}: {name:<28} = {v} = {fmt_factorization(v)}")
        print(f"            good primes predicted: {good}")

    d2 = multiple_x_denominator(N, P, 2)
    d4 = multiple_x_denominator(N, P, 4)
    print(f"   actual den x(2P) = {d2} = {fmt_factorization(d2)}")
    print(f"   actual den x(4P) = {d4} = {fmt_factorization(d4)}")

    predicted = set(layer4_predicted_primes(N, x, 2000))
    observed = {l for l in factorize(d4) if l >= 5 and N % l != 0}
    print(f"   predicted good layer-4 primes = {sorted(predicted)}")
    print(f"   observed  good layer-4 primes = {sorted(observed)}")
    print(f"   criterion holds: {predicted == observed}")
    print()


def demo_criterion_sweep(bound: int = 200) -> None:
    print("=" * 78)
    print("3b. CRITERION VERIFIED OVER MANY CURVES AND POINTS")
    print("=" * 78)
    checked, failures = 0, 0
    for N in list(range(-30, 0)) + list(range(1, 31)):
        for x in range(-20, 21):
            v = x**3 + N
            if v <= 0:
                continue
            r = int(round(v ** 0.5))
            if r * r != v or r == 0 or sextic(N, x) == 0:
                continue
            P = (Fraction(x), Fraction(r))
            d4 = multiple_x_denominator(N, P, 4)
            predicted = set(layer4_predicted_primes(N, x, bound))
            observed = {
                l for l in factorize(d4) if 5 <= l <= bound and N % l != 0
            }
            checked += 1
            if predicted != observed:
                failures += 1
                print(f"   FAILURE at N={N}, P=({x},{r}): {predicted} vs {observed}")
    print(f"   integral points checked: {checked};  criterion failures: {failures}")
    print()


def demo_non_cancellation(l: int = 13) -> None:
    print("=" * 78)
    print(f"4. NON-CANCELLATION MODULO l = {l}: the exceptional constants 3^8, 2^6*3^2")
    print("=" * 78)
    bad = 0
    for M in range(1, l):  # N mod l, nonzero
        for X in range(l):
            if Psi4(M, X) % l != 0:
                continue
            A = (X**4 - 8 * M * X) % l
            branch_A = (X**3 + M) % l == 0
            if branch_A:
                expected = (-(3**8) * M**5 * X) % l
            else:
                expected = (-576 * M * A * (X**3 + M) ** 3) % l
            actual = phi4(M, X) % l
            if actual != expected or actual == 0:
                bad += 1
                print(f"   PROBLEM at (N,x) = ({M},{X}) mod {l}")
    print(f"   every point of the layer-4 locus has nonzero numerator: {bad == 0}")
    print(f"   3^8 = {3**8} and 2^6*3^2 = {2**6*3**2} are units mod every prime l >= 5")
    print()


# ---------------------------------------------------------------------------
# 5. Class counts and the reciprocity dichotomy
# ---------------------------------------------------------------------------


def V4_size(l: int, c: int) -> int:
    """#{ t mod l : (t^3+c)(t^6+20c t^3-8c^2) = 0 }."""
    return sum(
        1
        for t in range(l)
        if ((t**3 + c) * (t**6 + 20 * c * t**3 - 8 * c * c)) % l == 0
    )


def layer4_total(l: int) -> int:
    """T_4(l) = sum over residues c of #V4(c); O(l^2) field operations."""
    return sum(V4_size(l, c) for c in range(l))


def layer2_total(l: int) -> int:
    return sum(
        1 for c in range(l) for t in range(l) if (t**3 + c) % l == 0
    )


def layer3_total(l: int) -> int:
    return sum(
        1 for c in range(l) for t in range(l) if (3 * t**4 + 12 * c * t) % l == 0
    )


def demo_class_counts() -> None:
    print("=" * 78)
    print("5. CLASS COUNTS:  T4(l) = 3l-2 if 3 is a square mod l, else l")
    print("=" * 78)
    print(f"   {'l':>4} {'l%12':>5} {'3 sq?':>6} {'T2':>5} {'T3':>6} {'T4':>6} "
          f"{'pred':>6} {'ok':>4}")
    for l in [5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61]:
        sq = is_square_mod(3, l)
        t4 = layer4_total(l)
        pred = 3 * l - 2 if sq else l
        print(f"   {l:>4} {l%12:>5} {str(sq):>6} {layer2_total(l):>5} "
              f"{layer3_total(l):>6} {t4:>6} {pred:>6} {str(t4==pred):>4}")
    print()
    print("   note: T2(l) = l and T3(l) = 2l-1 always (Kummer layers), while T4")
    print("   alternates between slope 1 and slope 3 -- no k with |T4 - k*l| = O(1).")
    print("   The mean of 3l-2 and l is 2l, which is exactly the discredited guess.")
    print()


# ---------------------------------------------------------------------------
# 6. Layer 4 activates no new residues (the hidden cube)
# ---------------------------------------------------------------------------


def demo_no_new_residues() -> None:
    print("=" * 78)
    print("6. LAYER 4 ACTIVATES NO NEW RESIDUES  (V4 nonempty <=> V2 nonempty)")
    print("=" * 78)
    for l in [5, 7, 11, 13, 17, 19, 23, 31, 37, 43, 61, 73]:
        active2 = {c for c in range(l) if any((t**3 + c) % l == 0 for t in range(l))}
        active4 = {c for c in range(l) if V4_size(l, c) > 0}
        blind = l - len(active2)
        print(f"   l={l:>3}  active at layer 2: {len(active2):>3}  "
              f"active at layer 4: {len(active4):>3}  blind: {blind:>3}  "
              f"equal: {active2 == active4}")
    print()
    print("   The mechanism: if t^6+20ct^3-8c^2 = 0 with t != 0, then")
    print("   g = (4c-5t^3)/(3t^3) satisfies g^2 = 3 and ((-1-g)/2 * t)^3 = -c.")
    # exhibit the hidden cube explicitly
    l = 13
    for c in range(1, l):
        for t in range(1, l):
            if (t**6 + 20 * c * t**3 - 8 * c * c) % l == 0:
                g = ((4 * c - 5 * t**3) * pow(3 * t**3, -1, l)) % l
                inv2 = pow(2, -1, l)
                root = ((-1 - g) * inv2 * t) % l
                print(f"   example mod {l}: c={c}, t={t}, g={g} (g^2={g*g%l}), "
                      f"cube root of -c is {root} since {root}^3 = {root**3%l} "
                      f"= -c = {(-c)%l}")
                break
        else:
            continue
        break
    print()


# ---------------------------------------------------------------------------
# 7. The information barrier
# ---------------------------------------------------------------------------


def barrier_witness(N: int, B: int, max_k: int = 100000) -> Optional[int]:
    """Smallest prime M > N with M = N (mod B!)."""
    step = factorial(B)
    M = N + step
    for _ in range(max_k):
        if is_prime(M):
            return M
        M += step
    return None


def criteria_agree(N: int, M: int, B: int, x_range: int = 40) -> bool:
    """Do the layer-2/3/4 criteria agree for N and M at all primes l <= B?"""
    for l in range(2, B + 1):
        if not is_prime(l):
            continue
        for x in range(-x_range, x_range + 1):
            for poly in (psi2_locus, psi3_locus, Psi4):
                if (poly(N, x) % l == 0) != (poly(M, x) % l == 0):
                    return False
    return True


def demo_barrier() -> None:
    print("=" * 78)
    print("7. INFORMATION BARRIER THROUGH LAYER 4")
    print("=" * 78)
    for (p, q, B) in [(11, 13, 7), (101, 103, 11), (1009, 1013, 13)]:
        N = p * q
        M = barrier_witness(N, B)
        assert M is not None
        agree = criteria_agree(N, M, B)
        print(f"   N = {p}*{q} = {N},  B = {B}:  prime witness M = {M}")
        print(f"      M = N (mod {B}!) : {(M - N) % factorial(B) == 0};  "
              f"all layer-2/3/4 criteria at primes <= {B} agree: {agree}")
    print()
    print("   Consequence: the small-prime denominator profile of layers 2,3,4 is a")
    print("   function of N mod B! alone, so it cannot distinguish the semiprime N")
    print("   from a prime M -- it carries no information about the factorisation.")
    print()


# ---------------------------------------------------------------------------


def main() -> None:
    demo_key_identity()
    demo_quadrupling_formula()
    demo_criterion_running_example()
    demo_criterion_sweep()
    demo_non_cancellation()
    demo_class_counts()
    demo_no_new_residues()
    demo_barrier()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
