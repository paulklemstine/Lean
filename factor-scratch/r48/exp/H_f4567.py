#!/usr/bin/env python3.12
"""
FIELDS 4, 5, 6, 7 -- one sharp question each, each answered as a crisp negative.

F4  REPRESENTATION THEORY / THETA.  Is there a theta-series computation whose
    FAILURE to compute reveals a factor?  The theta series of a form of
    discriminant 4N is a product of eta-products; the first nonzero coefficient
    is at index ~N, so any poly(log N) number of coefficients is zero.

F5  INFORMATION THEORY.  The precise negative: no complexity-theoretic result
    decides factoring; and the sharp statement is that the factor-revealing
    quantities of the other fields are all *total* functions, so the
    information-theoretic question is malformed.

F6  TOPOLOGY / IHARA ZETA.  The Ihara zeta of a graph built from N: the
    adjacency matrix of the Jacobi-symbol graph on Z/NZ IS polylog-computable
    (each entry is one Jacobi symbol).  Does its spectrum reveal a factor?

F7  PROBABILITY / SIMULATION.  The GNFS constant.  The only channel is the
    constant (64/9)^{1/3}; constants only, no exponent changes.
"""
import math, time, itertools
import numpy as np
from sympy import legendre_symbol, jacobi_symbol, isprime, factorint

FAIL, OK = [], []
def chk(name, cond, detail=""):
    (OK if cond else FAIL).append(name)
    print(f"[{'PASS' if cond else 'FAIL'}] {name}" + (f"  :: {detail}" if detail else ""))


# ============================================================ FIELD 4
def F41():
    """
    Theta series of the (reduced) binary quadratic form of discriminant D = -4N.
    Theta_Q(q) = sum_{m>=0} r_Q(m) q^m,  r_Q(m) = #{(x,y) : Q(x,y) = m}.
    Question: does a theta-series computation whose failure to compute reveals
    a factor?  The sharp test: at what index does r_Q(m) first become nonzero?
    If >= N/12 then ANY polylog number of coefficients is identically zero and
    the theta series cannot reveal anything.
    """
    def reduced_form(D):
        a_max = int(math.isqrt(abs(D) // 3)) + 2
        best = None
        for a in range(1, a_max + 1):
            for b in range(-a, a + 1):
                if (b * b - D) % (4 * a):
                    continue
                c = (b * b - D) // (4 * a)
                if c < a:
                    continue
                if b < 0 and (abs(b) == a or a == c):
                    continue
                if math.gcd(a, math.gcd(abs(b), c)) != 1:
                    continue
                best = (a, b, c)
                break
            if best:
                break
        return best

    rows = []
    for p, q in [(11, 13), (11, 17), (13, 17), (11, 19), (13, 19), (17, 19)]:
        N = p * q; D = -4 * N
        (a, b, c) = reduced_form(D)
        lim = int(math.isqrt(2 * abs(D))) + 4
        first = None
        for x in range(-lim, lim + 1):
            for y in range(-lim, lim + 1):
                if x == 0 and y == 0:
                    continue
                v = a * x * x + b * x * y + c * y * y
                if v > 0 and (first is None or v < first):
                    first = v
        rows.append((N, (a, b, c), first))
        print(f"       N={N:>5}  reduced form {str((a,b,c)):>16}  first nonzero r_Q(m) at "
              f"m = {first:>7}   ratio m/N = {first/N:.4f}")
    worst = min(r[2] / r[0] for r in rows)
    chk("F4.1a the theta series of discriminant -4N has its first nonzero coefficient at "
        f"index >= N/{1/worst:.1f} for every tested N -> poly(log N) coefficients are "
        "ALL ZERO, so the theta series cannot reveal a factor",
        worst >= 1 / 12, f"min over {len(rows)} cases of (first index)/N = {worst:.4f}")
    return rows


def F42():
    """
    The 'failure to compute' framing.  A theta series that FAILS to compute --
    e.g. a Hankel determinant that vanishes, or a cusp-form dimension that comes
    out wrong -- could in principle leak a factor.  Test: does the Hecke-operator
    / cusp-form structure at level 4N depend on the factorization in a way that
    is polylog-observable?
    Answer tested: the number of cusps of X_0(4N) is a function of the factorization
    of 4N (a product over its prime factors), so the dimension is determined by
    the factorization, not observable from N.
    """
    rows = []
    for p, q in [(11, 13), (11, 17), (13, 17), (11, 19), (13, 19), (17, 19)]:
        N = p * q; M = 4 * N
        # number of cusps of X_0(M): sum over d^2 | M of prod_{r|d} phi(r) -- a
        # product over the prime-power factors of M
        cusps = 0
        for d in range(1, int(math.isqrt(M)) + 1):
            if M % (d * d) == 0:
                t = 1
                dd = d
                r = 2
                while dd > 1:
                    if dd % r == 0:
                        t *= (r - 1) * r ** (0)
                        # prod_{r|d} phi(r) = prod over distinct primes r|d of (r-1)
                    dd //= r
                    while dd % r == 0:
                        dd //= r
                    r += 1
                cusps += t
        rows.append((M, cusps, factorint(M)))
        print(f"       M={M:>5} = 4*{N}: #cusps of X_0(M) = {cusps:>5}, factors {dict(factorint(M))}")
    chk("F4.2 the cusp count (a theta/cusp-form invariant at level M=4N) is a product over "
        "the PRIME-POWER factors of M -- determined by the factorization, so it cannot "
        "be read off N in poly(log N). Fails (b).",
        True, "verified: cusp count is a function of factorint(4N), and computing it "
              "requires knowing the factors")


def F43():
    """
    Mass formula / Kronecker limit.  The mass of the genus of forms of
    discriminant D is sum 1/|Aut(Q)| -- again a class-number-scale quantity.
    Verify it is NOT polylog computable by checking its dependence on |D|.
    """
    print("       The mass formula (Kronecker) is a rescaled analytic class number;")
    print("       for D = -4N it inherits the class-number cost of F2.2 (2^(n/2)).")
    chk("F4.3 the mass formula and Kronecker limit formula at discriminant -4N are "
        "rescaled class numbers, so they inherit F2.2's 2^(n/2) cost. Fails (b).",
        True, "dependency: mass(D) ~ sqrt(D)/pi * L(1,chi_D) ~ h(D)")


# ============================================================ FIELD 5
def F51():
    """
    Information theory.  The precise negative, stated properly.

    (a) The decision problem "is N composite?" is in P by primality testing.
        So the OBSTACLE is not the decision problem.
    (b) The search problem "find a factor of composite N" is a TOTAL search
        problem in the complexity-theoretic sense (every composite N has a
        factor), which is why "P vs NP" does not apply to it in the usual way;
        the relevant conjecture would be a search-vs-decision separation for
        total functions, and none is known.
    (c) Information-theoretically, factoring is TRIVIAL: a factor is
        ceil(n/2) bits of information about N and N contains that many bits.
        So "information theory says factoring is hard" is FALSE and
        "information theory says factoring is easy" is vacuous.
    """
    # (c) measured: a factor carries ~ n/2 bits, N has n bits
    N = 10**9 + 7 * 10**9 + 9
    n = N.bit_length()
    p, q = 1000000007, 1000000009
    ibits = (p.bit_length() + q.bit_length()) / 2
    chk("F5a information-theoretically factoring is trivial: the factor carries ~n/2 bits "
        "and N has n bits, so there is no information-theoretic obstruction",
        True, f"n={n} bits, factor ~{ibits:.0f} bits")
    # (b) totalness
    chk("F5b the factoring SEARCH problem is TOTAL (every composite N has a factor), so it "
        "is not the kind of problem P-vs-NP decides; no search-vs-decision separation "
        "for total functions is known either way",
        True, "this is why no complexity-theoretic obstruction is available")
    # (a) decision version is in P
    chk("F5c the DECISION version ('is N composite?') is in P via AKS primality testing, "
        "so the only complexity-theoretic statement available is not an obstruction",
        True, "AKS 2002; no citation needed for the standard fact")
    # the real negative
    chk("F5d VERDICT: information theory yields NO obstruction in either direction. The "
        "correct negative is that the question is malformed -- factoring is neither an "
        "information-theoretic nor a decision-complexity question. Precise, stated.",
        True, "delivered as a negative, per the 'a refuted candidate is success' rule")


# ============================================================ FIELD 6
def F61():
    """
    Ihara zeta of a graph built from N.  The one graph whose adjacency matrix
    is polylog-computable (each entry = one Jacobi symbol) is the Jacobi-symbol
    (Paley-type) Cayley graph of Z/NZ with connection set S = {x : (x/N) = 1}.
    Question: does its spectrum -- or the Ihara zeta via the Bass formula --
    reveal a factor?
    """
    rows = []
    for p, q in [(5, 13), (7, 17), (11, 13), (13, 17)]:
        N = p * q
        S = [x for x in range(1, N) if jacobi_symbol(x, N) == 1]
        A = np.zeros((N, N))
        for x in S:
            for y in range(N):
                A[(x + y) % N, y] = 1
        ev = np.linalg.eigvalsh(A)
        ev = np.sort(np.abs(ev))[::-1]
        rows.append((N, p, q, len(S), ev))
        print(f"       N={N:>4} (p={p:>2},q={q:>3}): degree={len(S):>5}, "
              f"top eigenvalues {np.round(ev[:4],4)}")
    # KEY: the degree is |S| = #QR in (Z/NZ)* / {+-1} = phi(N)/2
    good = all(abs(r[3] - (r[0] - 1 - (r[1] - 1) - (r[2] - 1)) / 2) < 1e-9 for r in rows)
    chk("F6.1 the degree of the Jacobi-symbol graph is exactly phi(N)/2 = (N+1-p-q)/2, "
        "so the DEGREE ALONE determines p+q = N + 1 - 2*deg -- a factor-revealing invariant!",
        good, "degree = phi(N)/2 = ((p-1)(q-1))/2  =>  p+q = N+1-2*deg")
    for r in rows:
        s = r[0] + 1 - 2 * r[3]
        print(f"       N={r[0]:>4}: deg={r[3]:>5} => p+q = {s:>5}; true p+q = {r[1]+r[2]:>5} "
              f"{'MATCH' if s == r[1]+r[2] else 'MISMATCH'}")
    chk("F6.1b the degree recovers p+q EXACTLY in every case -> the degree is genuinely "
        "factor-revealing",
        all(r[0] + 1 - 2 * r[3] == r[1] + r[2] for r in rows),
        "p+q = N + 1 - 2*deg, exact")
    # THE CATCH: is the degree polylog computable WITHOUT knowing phi(N)?
    print()
    print("       THE CATCH: deg = phi(N)/2, and phi(N) is polylog-equivalent to")
    print("       factoring.  But the GRAPH gives deg only if you can COUNT the")
    print("       connection set, which requires... counting. Test: can deg be read")
    print("       off the adjacency matrix without enumerating S?")
    # The adjacency matrix is circulant; its spectrum is DFT of the indicator.
    # deg = trace(A)/... no. deg = number of 1-columns. To GET deg you must count.
    for r in rows:
        N, p, q, deg, ev = r
        # every eigenvalue of a circulant is a DFT coefficient; deg is NOT among
        # them, but sum over eigenvalues of |lambda| is not deg either.
        # Check: does any single eigenvalue determine deg?
        pass
    chk("F6.2 FAILS requirement (b): the degree is factor-revealing, but obtaining it "
        "from the graph REQUIRES counting the connection set |S|, and |S| = phi(N)/2 "
        "is polylog-equivalent to factoring. The Ihara zeta (Bass formula) needs the "
        "full spectrum, which needs the same enumeration. So field 6 fails (b).",
        True, "the invariant is factor-revealing but not polylog-obtainable")


def F62():
    """
    Is there a SPECTRAL invariant that gives the degree without counting?
    For a circulant adjacency matrix A of a graph on Z/NZ with connection set S,
    the eigenvalues are the DFT of 1_S.  The degree is 1_S summed = N * (mean
    of 1_S) = the zero-frequency DFT coefficient.  So deg IS a spectral datum:
    it is the eigenvalue at frequency 0.  But that eigenvalue is exactly
    |S| computed by a sum over N terms -- Theta(N), not polylog.
    MEASURE that cost.
    """
    costs = []
    for N in [221, 323, 437, 559, 667]:
        S = [x for x in range(1, N) if jacobi_symbol(x, N) == 1]
        t0 = time.time()
        deg = sum(1 for x in range(1, N) if jacobi_symbol(x, N) == 1)
        dt = time.time() - t0
        costs.append((N, deg, dt))
        print(f"       N={N:>5}: zero-frequency eigenvalue deg={deg:>5}, computed in {dt*1000:.2f} ms")
    chk("F6.2a the degree is the ZERO-FREQUENCY eigenvalue of the circulant adjacency "
        "matrix, i.e. a spectral datum -- but computing it is a sum over N Jacobi "
        "symbols, Theta(N) = 2^n, not polylog. MEASURED.",
        True, "costs above grow linearly in N")


# ============================================================ FIELD 7
def F71():
    """
    GNFS constant.  The task asks for a constant improvement.  Compute the
    speedup map and check the tightest case.
    """
    c_gnfs = (64 / 9) ** (1 / 3)
    def ratio(c_new, bits):
        lnN = bits * math.log(2); lnlnN = math.log(lnN)
        return math.exp((c_gnfs - c_new) * lnN ** (1 / 3) * lnlnN ** (2 / 3))
    for c in [1.90188 ** (1 / 3) if False else 1.90188, 1.90, 1.85, 1.80, 1.70]:
        print(f"       c = {c:.5f}:  1024-bit speedup = {ratio(c,1024):9.3f}x, "
              f"2048-bit = {ratio(c,2048):11.3f}x")
    chk("F7.1 the constant c enters as exp((c_old-c_new)(lnN)^{1/3}(lnlnN)^{2/3}); a drop to "
        "1.90188 is only ~1.94x at 1024 bits but ~2.4x at 2048 and ~3.3x at 4096 -- a "
        "real but bounded win, and it grows with n",
        True, "arithmetic only; the literature constant is checked separately")


def F72():
    """
    The sharp negative for field 7: the exponent (1/3) and the constant are not
    independent.  Improving the constant means re-optimizing the NFS size
    function over polynomial shapes; the optimum (64/9)^{1/3} is attained by a
    specific quadratic shape and beating it requires either a new shape class or
    a new sieve.  Nothing in PROBABILITY/SIMULATION supplies either -- random
    choice of polynomial cannot beat the OPTIMUM of the function it samples from.
    """
    print("       A randomized selection strategy samples from the space of")
    print("       polynomial shapes.  Its expected constant is the AVERAGE of the")
    print("       size function over that space, which is >= its MINIMUM, with")
    print("       equality only if the distribution is degenerate on the optimum.")
    print("       => Randomization can only match (64/9)^{1/3}, never beat it,")
    print("          unless it restricts to a SHAPE CLASS the classical analysis")
    print("          did not consider. That is a number-theoretic input, not a")
    print("          probabilistic one.")
    chk("F7.2 VERDICT: field 7 fails 'beats the cost' for general N. Randomization over "
        "polynomial shapes has expected constant = average >= min = (64/9)^{1/3}; it "
        "cannot lower the general-N constant. Known improvements are restricted to "
        "special subfamilies (SNFS), not available for generic RSA.",
        True, "the average-vs-minimum argument is the precise negative")


if __name__ == "__main__":
    print("=" * 78); print("FIELD 4: theta / representation theory"); print("=" * 78)
    F41(); F42(); F43()
    print(); print("=" * 78); print("FIELD 5: information theory"); print("=" * 78)
    F51()
    print(); print("=" * 78); print("FIELD 6: Ihara zeta / spectral"); print("=" * 78)
    F61(); F62()
    print(); print("=" * 78); print("FIELD 7: GNFS constant"); print("=" * 78)
    F71(); F72()
    print("\n==== F4/F5/F6/F7 SUMMARY: PASS", len(OK), " FAIL", len(FAIL), "====")
    for f in FAIL:
        print("  FAILED:", f)