"""
Berggren Spectral Eigenvalues: Modular Energy Resonance for Integer Factorization
=================================================================================

Self-contained numerical demonstration of the results described in the
accompanying article and research paper.

The objects of study are the three integer matrices that generate the tree of
primitive Pythagorean triples (the Barning-Hall-Berggren tree):

    M1 = [[ 1, -2, 2],      M2 = [[1, 2, 2],      M3 = [[-1, 2, 2],
          [ 2, -1, 2],            [2, 1, 2],            [-2, 1, 2],
          [ 2, -2, 3]]            [2, 2, 3]]            [-2, 2, 3]]

Everything demonstrated here:

  1. Spectral data:  char(M1) = char(M3) = (X-1)^3   (unipotent),
                     char(M2) = (X+1)(X^2-6X+1)      (hyperbolic, eigenvalues
                     -1 and 3 +- 2*sqrt(2) = (1 +- sqrt 2)^2).
  2. Closed-form unipotent powers and the resulting factoring barrier:
     the order of M1 mod an odd m is exactly m, and any gcd it produces
     divides gcd(k^2, m).
  3. Hyperbolic resonance: mod an odd prime p the order of M2 divides p-1 if
     p = +-1 (mod 8) and divides p+1 if p = +-3 (mod 8); always divides p^2-1.
  4. The exact order formula  ord_p(M2) = lcm(2, ord_p(U)),  U = [[3,2],[4,3]].
  5. The eigenvalue dichotomy mod p: the quadratic X^2-6X+1 splits in F_p iff
     2 is a quadratic residue mod p iff p = +-1 (mod 8).
  6. The Berggren-Lucas trace sequence t(k) = tr(M2^k), its recurrence
     t(k+3) = 5 t(k+2) + 5 t(k+1) - t(k), and the Fermat-type congruence
     t(p) = 5 (mod p) for every odd prime p, used as a compositeness test.
  7. Resonance factorization: if k is a resonance of p but not of q, then the
     gcd of a suitable entry of M2^k - 1 with N = pq is exactly p.

Run with:  python3 demo.py
No third-party dependencies.
"""

from __future__ import annotations

from math import gcd
from typing import List, Optional, Tuple

Matrix = Tuple[Tuple[int, ...], ...]

# --------------------------------------------------------------------------
# The three Berggren generators
# --------------------------------------------------------------------------

M1: Matrix = ((1, -2, 2), (2, -1, 2), (2, -2, 3))
M2: Matrix = ((1, 2, 2), (2, 1, 2), (2, 2, 3))
M3: Matrix = ((-1, 2, 2), (-2, 1, 2), (-2, 2, 3))

IDENTITY3: Matrix = ((1, 0, 0), (0, 1, 0), (0, 0, 1))

# The 2x2 hyperbolic block of M2 in the basis (1,1,0), (0,0,1).
U_BLOCK: Matrix = ((3, 2), (4, 3))
IDENTITY2: Matrix = ((1, 0), (0, 1))


# --------------------------------------------------------------------------
# Basic modular matrix arithmetic
# --------------------------------------------------------------------------

def mat_mul(a: Matrix, b: Matrix, mod: Optional[int] = None) -> Matrix:
    """Multiply two square matrices, optionally reducing modulo `mod`."""
    n = len(a)
    out: List[Tuple[int, ...]] = []
    for i in range(n):
        row: List[int] = []
        for j in range(n):
            s = sum(a[i][k] * b[k][j] for k in range(n))
            row.append(s % mod if mod is not None else s)
        out.append(tuple(row))
    return tuple(out)


def mat_pow(a: Matrix, e: int, mod: Optional[int] = None) -> Matrix:
    """Fast exponentiation of a square matrix, optionally modulo `mod`."""
    n = len(a)
    result: Matrix = tuple(
        tuple(1 if i == j else 0 for j in range(n)) for i in range(n)
    )
    base = tuple(tuple(x % mod for x in row) for row in a) if mod is not None else a
    while e > 0:
        if e & 1:
            result = mat_mul(result, base, mod)
        base = mat_mul(base, base, mod)
        e >>= 1
    return result


def mat_sub_identity(a: Matrix) -> Matrix:
    """Return A - I."""
    n = len(a)
    return tuple(
        tuple(a[i][j] - (1 if i == j else 0) for j in range(n)) for i in range(n)
    )


def is_identity_mod(a: Matrix, mod: int) -> bool:
    """Test whether A = I modulo `mod`."""
    n = len(a)
    return all(
        a[i][j] % mod == (1 if i == j else 0) % mod for i in range(n) for j in range(n)
    )


def trace(a: Matrix) -> int:
    return sum(a[i][i] for i in range(len(a)))


def char_poly_3x3(a: Matrix) -> Tuple[int, int, int]:
    """Coefficients (c2, c1, c0) of X^3 + c2 X^2 + c1 X + c0 for a 3x3 matrix."""
    t = trace(a)
    a2 = mat_mul(a, a)
    t2 = trace(a2)
    # e1 = tr, e2 = (tr^2 - tr(A^2))/2, e3 = det
    e1 = t
    e2 = (t * t - t2) // 2
    e3 = det_3x3(a)
    return (-e1, e2, -e3)


def det_3x3(a: Matrix) -> int:
    return (
        a[0][0] * (a[1][1] * a[2][2] - a[1][2] * a[2][1])
        - a[0][1] * (a[1][0] * a[2][2] - a[1][2] * a[2][0])
        + a[0][2] * (a[1][0] * a[2][1] - a[1][1] * a[2][0])
    )


# --------------------------------------------------------------------------
# Elementary number theory helpers
# --------------------------------------------------------------------------

def is_prime(n: int) -> bool:
    """Deterministic Miller-Rabin, correct for all n < 3.3 * 10^24."""
    if n < 2:
        return False
    for p in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        if n % p == 0:
            return n == p
    d, r = n - 1, 0
    while d % 2 == 0:
        d //= 2
        r += 1
    for a in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        x = pow(a, d, n)
        if x == 1 or x == n - 1:
            continue
        for _ in range(r - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


def primes_up_to(limit: int) -> List[int]:
    sieve = [True] * (limit + 1)
    sieve[0:2] = [False, False]
    for i in range(2, int(limit ** 0.5) + 1):
        if sieve[i]:
            for j in range(i * i, limit + 1, i):
                sieve[j] = False
    return [i for i, ok in enumerate(sieve) if ok]


def divisors(n: int) -> List[int]:
    out: List[int] = []
    i = 1
    while i * i <= n:
        if n % i == 0:
            out.append(i)
            if i != n // i:
                out.append(n // i)
        i += 1
    return sorted(out)


def lcm(a: int, b: int) -> int:
    return a * b // gcd(a, b)


def matrix_order_mod(a: Matrix, mod: int, bound: int) -> Optional[int]:
    """Least k >= 1 with A^k = I (mod `mod`), searched among divisors of `bound`."""
    for d in divisors(bound):
        if d >= 1 and is_identity_mod(mat_pow(a, d, mod), mod):
            return d
    return None


def legendre_two(p: int) -> int:
    """The Legendre symbol (2|p) for an odd prime p: +1 if p = +-1 mod 8, else -1."""
    return 1 if p % 8 in (1, 7) else -1


# --------------------------------------------------------------------------
# 1. Spectral data of the three generators
# --------------------------------------------------------------------------

def demo_spectra() -> None:
    print("=" * 74)
    print("1.  EXACT SPECTRAL DATA OF THE THREE BERGGREN GENERATORS")
    print("=" * 74)
    for name, M in (("M1", M1), ("M2", M2), ("M3", M3)):
        c2, c1, c0 = char_poly_3x3(M)
        print(f"  {name}:  det = {det_3x3(M):>3},  tr = {trace(M):>2},  "
              f"char(X) = X^3 + ({c2})X^2 + ({c1})X + ({c0})")
    print()
    print("  char(M1) = char(M3) = (X-1)^3            -> unipotent")
    print("  char(M2) = (X+1)(X^2 - 6X + 1)           -> hyperbolic")
    print("  roots of X^2 - 6X + 1 :  3 +- 2*sqrt(2) = (1 +- sqrt 2)^2,")
    print("  the square of the silver ratio; product = 1, so the two hyperbolic")
    print("  eigenvalues are inverse units of norm 1 in Z[sqrt 2].")
    print()
    # Exact nilpotency index of M1 - I and M3 - I.
    for name, M in (("M1", M1), ("M3", M3)):
        A = mat_sub_identity(M)
        A2 = mat_mul(A, A)
        A3 = mat_mul(A2, A)
        z2 = all(all(x == 0 for x in row) for row in A2)
        z3 = all(all(x == 0 for x in row) for row in A3)
        print(f"  ({name} - I)^2 = 0 ? {z2}      ({name} - I)^3 = 0 ? {z3}"
              "      -> nilpotency index exactly 3")
    print()
    # M2 preserves the Lorentz form a^2 + b^2 - c^2.
    v = (3, 4, 5)
    for name, M in (("M1", M1), ("M2", M2), ("M3", M3)):
        w = tuple(sum(M[i][j] * v[j] for j in range(3)) for i in range(3))
        q_before = v[0] ** 2 + v[1] ** 2 - v[2] ** 2
        q_after = w[0] ** 2 + w[1] ** 2 - w[2] ** 2
        print(f"  {name} * (3,4,5) = {w},  a^2+b^2-c^2 : {q_before} -> {q_after}")
    print("  All three generators are isometries of the Lorentz form"
          " diag(1,1,-1).")
    print()


# --------------------------------------------------------------------------
# 2. The unipotent branch: closed form and the factoring barrier
# --------------------------------------------------------------------------

def unipotent_power_closed_form(k: int) -> Matrix:
    """The proved closed form for M1^k."""
    return (
        (1, -2 * k, 2 * k),
        (2 * k, 1 - 2 * k * k, 2 * k * k),
        (2 * k, -2 * k * k, 1 + 2 * k * k),
    )


def demo_unipotent_barrier() -> None:
    print("=" * 74)
    print("2.  THE UNIPOTENT BRANCH: CLOSED FORM AND THE FACTORING BARRIER")
    print("=" * 74)
    print("  M1^k = [[1, -2k, 2k], [2k, 1-2k^2, 2k^2], [2k, -2k^2, 1+2k^2]]")
    ok = all(mat_pow(M1, k) == unipotent_power_closed_form(k) for k in range(0, 12))
    print(f"  closed form verified for k = 0..11 : {ok}")
    print()
    print("  Order of M1 modulo an odd m is exactly m (never a proper divisor):")
    for m in (3, 5, 9, 15, 21, 35, 45):
        order = matrix_order_mod(M1, m, m * 4)
        print(f"    m = {m:>3} :  ord_m(M1) = {order}")
    print()
    print("  Consequence (the barrier): every gcd extracted from the unipotent")
    print("  branch divides gcd(k^2, N), so it reveals only primes already")
    print("  dividing the exponent k.  Example N = 3233 = 53 * 61:")
    for k in (4, 7, 10, 53):
        A = mat_sub_identity(mat_pow(M1, k))
        gs = sorted({gcd(abs(A[i][j]), 3233) for i in range(3) for j in range(3)
                     if A[i][j] != 0})
        print(f"    k = {k:>3} :  gcds with N = {gs},  gcd(k^2, N) = "
              f"{gcd(k * k, 3233)}")
    print("  Nothing but 1 unless k already contains a factor of N.")
    print()


# --------------------------------------------------------------------------
# 3-5. Hyperbolic resonance, exact orders, eigenvalue dichotomy
# --------------------------------------------------------------------------

def resonant_frequency(p: int) -> int:
    """The predicted resonant frequency p-1 or p+1 according to p mod 8."""
    return p - 1 if p % 8 in (1, 7) else p + 1


def quadratic_roots_mod(p: int) -> List[int]:
    """Roots of X^2 - 6X + 1 in F_p, by brute force (p small)."""
    return [x for x in range(p) if (x * x - 6 * x + 1) % p == 0]


def demo_resonance_table(limit: int = 80) -> None:
    print("=" * 74)
    print("3.  HYPERBOLIC RESONANCE AND THE EIGENVALUE DICHOTOMY MOD p")
    print("=" * 74)
    header = (f"{'p':>4} {'p%8':>4} {'(2|p)':>6} {'predicted':>10} "
              f"{'ord_p(M2)':>10} {'ord|pred':>9} {'sharp':>6} "
              f"{'roots of X^2-6X+1':>20}")
    print("  " + header)
    print("  " + "-" * len(header))
    for p in primes_up_to(limit):
        if p == 2:
            continue
        pred = resonant_frequency(p)
        order = matrix_order_mod(M2, p, 2 * (p * p - 1))
        assert order is not None
        roots = quadratic_roots_mod(p)
        u_order = matrix_order_mod(U_BLOCK, p, p * p - 1)
        assert u_order is not None
        assert order == lcm(2, u_order), "order formula failed"
        rs = ",".join(str(r) for r in roots) if roots else "-  (inert)"
        print(f"  {p:>4} {p % 8:>4} {legendre_two(p):>6} {pred:>10} "
              f"{order:>10} {str(pred % order == 0):>9} "
              f"{str(order == pred):>6} {rs:>20}")
    print()
    print("  Every row satisfies:  ord_p(M2) divides the predicted frequency,")
    print("  ord_p(M2) = lcm(2, ord_p(U)) with U = [[3,2],[4,3]], and the")
    print("  quadratic X^2-6X+1 splits in F_p exactly when p = +-1 (mod 8),")
    print("  i.e. exactly when the predicted frequency is p-1.")
    print("  ('sharp' = the frequency bound is attained exactly.)")
    print()


def demo_split_inert_correspondence(limit: int = 200) -> None:
    print("=" * 74)
    print("4.  THE SPLIT/INERT DICHOTOMY IS THE FREQUENCY DICHOTOMY")
    print("=" * 74)
    bad = 0
    for p in primes_up_to(limit):
        if p == 2:
            continue
        roots = quadratic_roots_mod(p)
        split = len(roots) > 0
        freq_is_p_minus_1 = (p % 8 in (1, 7))
        if split != freq_is_p_minus_1:
            bad += 1
        # verify the resonance itself
        if not is_identity_mod(mat_pow(M2, resonant_frequency(p), p), p):
            bad += 1
        # and the uniform p^2 - 1 statement
        if not is_identity_mod(mat_pow(M2, p * p - 1, p), p):
            bad += 1
    n_primes = len([p for p in primes_up_to(limit) if p != 2])
    print(f"  Checked all {n_primes} odd primes p < {limit}.")
    print(f"  Mismatches between 'spectrum splits mod p' and 'frequency = p-1',")
    print(f"  or failures of M2^(p-+1) = I or M2^(p^2-1) = I mod p :  {bad}")
    print()


# --------------------------------------------------------------------------
# 6. The Berggren-Lucas trace sequence
# --------------------------------------------------------------------------

def berggren_trace(k: int) -> int:
    """t(k) = tr(M2^k) via the recurrence t(k+3) = 5t(k+2) + 5t(k+1) - t(k)."""
    t: List[int] = [3, 5, 35, 197]
    if k < 4:
        return t[k]
    for i in range(4, k + 1):
        t.append(5 * t[i - 1] + 5 * t[i - 2] - t[i - 3])
    return t[k]


def berggren_trace_mod(k: int, mod: int) -> int:
    """t(k) mod `mod`, computed in O(k) with small numbers."""
    a, b, c = 3 % mod, 5 % mod, 35 % mod
    if k == 0:
        return a
    if k == 1:
        return b
    if k == 2:
        return c
    for _ in range(3, k + 1):
        a, b, c = b, c, (5 * c + 5 * b - a) % mod
    return c


def demo_trace_sequence() -> None:
    print("=" * 74)
    print("5.  THE BERGGREN-LUCAS TRACE SEQUENCE AND ITS FERMAT CONGRUENCE")
    print("=" * 74)
    seq = [berggren_trace(k) for k in range(10)]
    print(f"  t(k) = tr(M2^k) = (3+2rt2)^k + (3-2rt2)^k + (-1)^k")
    print(f"  t(0..9) = {seq}")
    ok = all(berggren_trace(k) == trace(mat_pow(M2, k)) for k in range(0, 12))
    print(f"  recurrence agrees with the matrix traces for k = 0..11 : {ok}")
    print()
    print("  Fermat-type congruence  t(p) = 5 (mod p)  for every odd prime p:")
    row = []
    for p in primes_up_to(60):
        if p == 2:
            continue
        row.append(f"t({p}) = {berggren_trace_mod(p, p)} = 5 (mod {p})")
    for i in range(0, len(row), 3):
        print("    " + " | ".join(row[i:i + 3]))
    print()
    print("  Contrapositive = a compositeness test.  Odd composites n < 400")
    print("  detected by t(n) != 5 (mod n):")
    detected, missed = 0, []
    for n in range(9, 400, 2):
        if is_prime(n):
            continue
        if berggren_trace_mod(n, n) % n != 5 % n:
            detected += 1
        else:
            missed.append(n)
    total = len([n for n in range(9, 400, 2) if not is_prime(n)])
    print(f"    detected {detected} of {total} odd composites; "
          f"pseudoprimes (missed): {missed}")
    print(f"    worked example: t(9) = {berggren_trace(9)} = "
          f"{berggren_trace(9) % 9} (mod 9), not 5, so 9 is composite.")
    print()


# --------------------------------------------------------------------------
# 7. Resonance factorization
# --------------------------------------------------------------------------

def berggren_resonance_factor(N: int, bound: int) -> Optional[Tuple[int, int]]:
    """Berggren p +- 1 style factoring.

    Accumulate the exponent E = lcm(1..bound) into M2 modulo N one prime power
    at a time and take gcds of the entries of M2^E - I with N.  Returns
    (factor, exponent used) if a nontrivial factor is found.
    """
    A = tuple(tuple(x % N for x in row) for row in M2)
    e = 1
    for q in primes_up_to(bound):
        power = q
        while power * q <= bound:
            power *= q
        A = mat_pow(A, power, N)
        e *= power
        D = mat_sub_identity(A)
        g = 0
        for i in range(3):
            for j in range(3):
                g = gcd(g, D[i][j] % N)
        g = gcd(g, N)
        if 1 < g < N:
            return g, e
        if g == N:
            return None  # resonances aligned: the method stalls
    return None


def demo_factorization() -> None:
    print("=" * 74)
    print("6.  RESONANCE FACTORIZATION")
    print("=" * 74)
    print("  Worked instance N = 15 = 3 * 5.  Since 3 = 3 (mod 8), the resonant")
    print("  frequency of p = 3 is 3 + 1 = 4.")
    A = mat_pow(M2, 4)
    D = mat_sub_identity(A)
    print(f"    M2^4 - I = {D}")
    print(f"    M2^4 = I mod 3 ? {is_identity_mod(mat_pow(M2, 4, 3), 3)}"
          f"    M2^4 = I mod 5 ? {is_identity_mod(mat_pow(M2, 4, 5), 5)}")
    gs = {gcd(abs(D[i][j]), 15) for i in range(3) for j in range(3)}
    print(f"    gcds of entries of M2^4 - I with 15 : {sorted(gs)}   -> 3 found")
    print()
    print("  Worked RSA-style instance N = 3233 = 53 * 61.  Since 53 = 5 (mod 8)")
    print("  the resonant frequency of p = 53 is 54, while 61 has frequency 62.")
    print(f"    M2^54 = I mod 53 ? {is_identity_mod(mat_pow(M2, 54, 53), 53)}")
    print(f"    M2^54 = I mod 61 ? {is_identity_mod(mat_pow(M2, 54, 61), 61)}")
    A = mat_pow(M2, 54, 3233)
    D = mat_sub_identity(A)
    gs = sorted({gcd(D[i][j] % 3233, 3233) for i in range(3) for j in range(3)})
    print(f"    gcds of entries of M2^54 - I with 3233 : {gs}   -> 53 found")
    print()
    print("  Automatic smoothness search (no knowledge of p or q):")
    for N in (15, 3233, 1189, 10403, 2**31 - 1, 6557, 25777, 1000003 * 1000033):
        res = berggren_resonance_factor(N, 200)
        if res is None:
            print(f"    N = {N:<16}  no factor within bound 200")
        else:
            f, e = res
            print(f"    N = {N:<16}  factor {f} found  "
                  f"(N = {f} * {N // f})")
    print()
    print("  Boundary of the method: if an exponent is a resonance of the whole")
    print("  modulus, every gcd equals N and nothing is learned.  E.g. mod 15,")
    print("  M2^lcm(4,6) = M2^12 = I, so the exponent 12 yields only gcd = 15:")
    D = mat_sub_identity(mat_pow(M2, 12, 15))
    print(f"    gcds at k = 12 : "
          f"{sorted({gcd(D[i][j] % 15, 15) for i in range(3) for j in range(3)})}")
    print()


def demo_semiprime_period() -> None:
    print("=" * 74)
    print("7.  PERIOD OF THE TREE DYNAMICS MODULO A SEMIPRIME")
    print("=" * 74)
    for p, q in ((3, 5), (7, 11), (53, 61), (17, 19)):
        N = p * q
        bound = lcm(p * p - 1, q * q - 1)
        ok = is_identity_mod(mat_pow(M2, bound, N), N)
        order = matrix_order_mod(M2, N, bound)
        print(f"  N = {p}*{q} = {N:>5} :  lcm(p^2-1, q^2-1) = {bound:>6},  "
              f"M2^that = I mod N ? {ok},  exact order = {order}")
    print()
    print("  The root triple (3,4,5) returns to itself after p^2 - 1 Berggren")
    print("  steps modulo p:")
    for p in (3, 5, 7, 11, 13, 17):
        A = mat_pow(M2, p * p - 1, p)
        w = tuple(sum(A[i][j] * (3, 4, 5)[j] for j in range(3)) % p for i in range(3))
        print(f"    p = {p:>3} :  M2^{p*p-1} * (3,4,5) = {w} = (3,4,5) mod {p}"
              f"  -> {w == (3 % p, 4 % p, 5 % p)}")
    print()


def main() -> None:
    print()
    print("BERGGREN SPECTRAL EIGENVALUES: MODULAR ENERGY RESONANCE")
    print("Numerical demonstration")
    print()
    demo_spectra()
    demo_unipotent_barrier()
    demo_resonance_table()
    demo_split_inert_correspondence()
    demo_trace_sequence()
    demo_factorization()
    demo_semiprime_period()
    print("=" * 74)
    print("All demonstrations completed.")
    print("=" * 74)


if __name__ == "__main__":
    main()
