"""
Round 35 -- CHANNEL: two-level / variable-step BSGS on Harvey Alg. 4.2
(arXiv:2010.05450, read from the PDF, Prop 4.2 + the final cost combination).

Falsifiable scaling test.  Exact integer/real operation counts for
  (0) Harvey's uniform 1-level baby list   (the baseline we must beat)
  (1) a nested 2-level baby list,  m1 | m2
  (2) a variable-step / geometric-ladder baby list
with (X, Y) = (log_N r, log_N m) RE-OPTIMISED for every N, and the exponent of
N recovered by least squares on the LARGE-N range (small N is contaminated by
the N-independent constants 1/frac and by the r-term, so it is excluded).

PREDICTION: every variant has slope 0.200.  Only the constant factor differs,
and the 2-level constant is always > 1 (Cauchy-Schwarz).
"""
import math

# ---------------------------------------------------------------- pool size
# Harvey Prop 4.2: with r = N^X the giant-step pool for one k=ab is
# N^{1/2}/(4 r m (ab)^{1/2}); summing over 1<=ab<=r (Remark 3.4) gives
#     s = O( N^{1/2}/(r^{1/2} m) + r lg r ).
# The m-INDEPENDENT search space (the POOL) is
#     S(N,X) = N^{1/2} / r^{1/2},          exponent 1/2 - X/2,
# and m only PARTITIONS S between a stored baby-step list and a linear scan.


def pool(N, X):
    return N ** 0.5 / (N ** X) ** 0.5


def cost_uniform(N, X, Y):
    """Harvey Alg 4.2: baby list of size m, interior scan S/m, r pairs."""
    return N ** X + N ** Y + pool(N, X) / N ** Y


def cost_two_level(N, X, Y, frac):
    """Nested 2-level baby list, m1 = frac*m2 (so the inner step is smaller).
    Outer: list m2, scan S/m2.  Every outer giant step additionally has to
    clear the m2/m1 intermediate offsets: + (m2/m1) entries and + (m2/m1)
    inner scans, i.e. + S/m1 = S/(frac*m2)."""
    m2 = N ** Y
    S = pool(N, X)
    return N ** X + m2 + (1.0 / frac) + S / m2 + S / (frac * m2)


def cost_variable(N, X, Y, J):
    """Variable-step / geometric ladder: J levels, level j covering a
    geometrically shrinking slice phi_j = 2^{-(j+1)} of the pool, each with its
    own optimal split.  cost_j = 2*sqrt(phi_j*S) + its list size."""
    S = pool(N, X)
    tot = N ** X
    for j in range(J):
        phi = 0.5 ** (j + 1)
        tot += 2.0 * math.sqrt(phi * S) + math.sqrt(phi * S)
    return tot


def optimise(costfn, N, lo=0.01, hi=0.60, step=0.002):
    best, arg, x = None, None, lo
    while x <= hi:
        y = lo
        while y <= hi:
            c = costfn(N, x, y)
            if best is None or c < best:
                best, arg = c, (round(x, 4), round(y, 4))
            y += step
        x += step
    return best, arg


def fit(make, Ns):
    xs = [math.log10(n) for n in Ns]
    ys = [math.log10(make(n)) for n in Ns]
    mx, my = sum(xs) / len(xs), sum(ys) / len(ys)
    num = sum((a - mx) * (b - my) for a, b in zip(xs, ys))
    den = sum((a - mx) ** 2 for a in xs)
    return num / den


if __name__ == "__main__":
    Ns = [10.0 ** e for e in (8, 10, 12, 14, 16, 18)]

    def make_opt(costfn, **kw):
        return lambda n: optimise(lambda N, X, Y: costfn(N, X, Y, **kw), n)[0]

    print("Ns = 1e8 .. 1e18, (X,Y) re-optimised per N, exponent of N by least squares")
    print()
    print("--- EXPONENT OF N of the OPTIMISED cost ---")
    print(f"  uniform 1-level (Harvey)            slope = "
          f"{fit(make_opt(cost_uniform), Ns):.4f}")
    for frac in (0.5, 0.2, 0.05, 0.01, 0.001):
        print(f"  2-level, inner frac = {frac:<6}     slope = "
              f"{fit(make_opt(cost_two_level, frac=frac), Ns):.4f}")
    for J in (2, 3, 5, 8):
        print(f"  variable-step ladder, J = {J:<2}          slope = "
              f"{fit(make_opt(cost_variable, J=J), Ns):.4f}")

    print()
    print("--- CONSTANT FACTOR vs uniform at N = 1e14 (must be >= 1 always) ---")
    N = 1e14
    c1, a1 = optimise(cost_uniform, N)
    print(f"  uniform: cost = {c1:.4e}  at (X,Y) = {a1}")
    for frac in (0.5, 0.2, 0.1, 0.05, 0.02, 0.01, 0.005, 0.001):
        c2, a2 = optimise(lambda n, X, Y, f=frac: cost_two_level(n, X, Y, f), N)
        pred = math.sqrt(1.0 + 1.0 / frac)
        print(f"  2-level frac={frac:<6} ratio = {c2/c1:9.4f}   "
              f"closed form sqrt(1+1/frac) = {pred:9.4f}   at (X,Y)={a2}")
    for J in (2, 3, 5, 8):
        cJ, aJ = optimise(lambda n, X, Y, jj=J: cost_variable(n, X, Y, jj), N)
        print(f"  ladder J={J:<2}            ratio = {cJ/c1:9.4f}                    at (X,Y)={aJ}")

    print()
    print("--- CLEAN-ROOM CHECK: the pool part alone (r term removed, m free) ---")
    # min over m of (m + S/m) is 2*sqrt(S) for ANY level structure.
    for frac in (0.5, 0.2, 0.05):
        best2 = min(cost_two_level(1e14, 0.20, 0.20, frac) - 1e14 ** 0.20 - 1.0 / frac
                    for _ in [0])
        # optimise the m-part directly: m2 + S/m2 + S/(frac*m2)
        m2 = math.sqrt((1.0 + 1.0 / frac) * pool(1e14, 0.20))
        val = m2 + pool(1e14, 0.20) / m2 + pool(1e14, 0.20) / (frac * m2)
        base = 2.0 * math.sqrt(pool(1e14, 0.20))
        print(f"  frac={frac:<6} min(pool part) = {val:.4e}   uniform 2*sqrt(S) = {base:.4e}"
              f"   ratio = {val/base:.4f}  (= sqrt(1+1/frac) = {math.sqrt(1+1/frac):.4f})")
