"""
r113/lattice-obj : the IDEAL-LATTICE route on Z[sqrt(N)] (sub-candidate b).

This is the literal axis object: a lattice/arithmetic construction on the
algebraic number field Q(sqrt(N)) rather than on f(x,y)=0.

Mechanism (derived, not ported):
  Walk the continued fraction of sqrt(N).  For its convergents (P_i,Q_i) the
  classical identity is
        P_i^2 - N Q_i^2 = (-1)^(i+1) d_{i+1}                       (*)
  where d_{i+1} is the (i+1)-th partial denominator.  So each step produces a
  SMALL integer d = |P^2 - NQ^2| that is a difference-of-squares residue.
  If such a d is a PERFECT SQUARE c^2 then (*) gives
        P^2 - NQ^2 = +- c^2   =>   P^2 -+ c^2 = N Q^2
  so N | (P-c)(P+c) in the + case, and N | (P^2 + c^2) in the - case.
  A perfect-square partial denominator is a "square form" (Shanks' SQUFOF);
  testing gcd at that point is what extracts a factor.

Every factor is verified by MULTIPLICATION BACK to N.  The trivial baseline
(PARI factor()) and Pollard rho are measured on the SAME instances.
"""
import sys, time, math
sys.path.insert(0, '/home/raver1975/lean/factor-scratch/r113/lattice-obj')
from lib import gen_N, ok, pari_time, rho
from sage.all import Integer, isqrt as Zisqrt, gcd as ZZgcd


def cf_state(N):
    """Generator of (i, m_i, d_i, a_i) for sqrt(N), standard recursion."""
    S = Zisqrt(N)
    m, d, a = 0, 1, S
    i = 0
    while True:
        yield i, m, d, a
        m = d * a - m
        d = (N - m * m) // d
        a = (S + m) // d
        i += 1


def ideal_lattice(N, maxsteps=4000000):
    """Walk the CF of sqrt(N) looking for square forms; return (factor, steps).

    Returns factor=None if no square form fires within maxsteps.
    """
    S = Zisqrt(N)
    # convergent state: P_{-2}=0,P_{-1}=1 ; Q_{-2}=1,Q_{-1}=0
    P2, P1 = 0, 1
    Q2, Q1 = 1, 0
    dnext = None
    steps = 0
    for (i, m, d, a) in cf_state(N):
        steps += 1
        if steps > maxsteps:
            return None, steps
        P = a * P1 + P2
        Q = a * Q1 + Q2
        t = P * P - N * Q * Q          # = (-1)^(i+1) * d_{i+1}
        # |t| equals the partial denominator that has just been produced
        A = abs(t)
        c = Zisqrt(A)
        if c * c == A and A > 1:
            # square form.  Sign decides which gcd is informative.
            if t > 0:                  # N | (P-c)(P+c)
                for cand in (P - c, P + c):
                    g = ZZgcd(cand, N)
                    if 1 < g < N:
                        return int(g), steps
            else:                      # N | (P^2 + c^2): use P directly
                g = ZZgcd(P, N)
                if 1 < g < N:
                    return int(g), steps
                g = ZZgcd(c, N)
                if 1 < g < N:
                    return int(g), steps
        P2, P1 = P1, P
        Q2, Q1 = Q1, Q


def dvals(N, n):
    """The partial denominators |P^2 - NQ^2| -- used for the smoothness test."""
    out = []
    P2, P1 = 0, 1
    Q2, Q1 = 1, 0
    for (i, m, d, a) in cf_state(N):
        P = a * P1 + P2
        Q = a * Q1 + Q2
        out.append((i, P, Q, abs(P * P - N * Q * Q)))
        P2, P1 = P1, P
        Q2, Q1 = Q1, Q
        if len(out) >= n:
            break
    return out


def identity_check(N, n=40):
    """Assert the classical identity (*) rather than trusting it."""
    S = Zisqrt(N)
    rows = []
    P2, P1 = 0, 1
    Q2, Q1 = 1, 0
    for (i, m, d, a) in cf_state(N):
        P = a * P1 + P2
        Q = a * Q1 + Q2
        rows.append((i, P, Q, d))
        P2, P1 = P1, P
        Q2, Q1 = Q1, Q
        if len(rows) >= n:
            break
    hold = 0
    for k in range(len(rows) - 1):
        i, P, Q, d = rows[k]
        lhs = P * P - N * Q * Q
        rhs = (-1) ** (i + 1) * rows[k + 1][3]
        if lhs == rhs:
            hold += 1
    return hold, len(rows) - 1


def selftest():
    """POSITIVE CONTROL.  The harness MUST fire where the phenomenon is known
    present.  A harness never shown to fire has measured nothing."""
    print("=== SELFTEST ===")
    N, p, q = gen_N(41, seed=3)
    hold, tot = identity_check(N, 40)
    print("  identity (*) P^2-NQ^2 == (-1)^(i+1) d_{i+1} : %d/%d hold" % (hold, tot))
    assert hold == tot, "IDENTITY FAILS -- convention slip, do not trust results"
    g, s = ideal_lattice(N, maxsteps=300000)
    good = ok(g, p, q, N)
    print("  ideal_lattice: factor=%s verified=%s steps=%d" % (g, good, s))
    assert good, "SELFTEST FAILED: ideal-lattice harness never fired"
    # cross-check against PARI on the same instance
    tf, ff = pari_time(N)
    print("  PARI factor() same instance: %.4f s, verified=%s"
          % (tf, ok(ff, p, q, N)))
    print("  SELFTEST PASSED")


if __name__ == "__main__":
    selftest()
